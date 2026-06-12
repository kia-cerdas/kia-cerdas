package middlewares

import (
	"encoding/json"
	"net/http"
	"path"
	"strconv"
	"strings"

	"monitoring-service/app/models"

	"github.com/labstack/echo/v4"
)

type AuditRecorder interface {
	Record(entry *models.AuditTrail) error
}

func AuditTrail(recorder AuditRecorder) echo.MiddlewareFunc {
	return func(next echo.HandlerFunc) echo.HandlerFunc {
		return func(c echo.Context) error {
			if recorder == nil {
				return next(c)
			}

			err := next(c)

			requestPath := c.Path()
			if requestPath == "" {
				requestPath = c.Request().URL.Path
			}

			if !shouldRecordAudit(c.Request().Method, requestPath) {
				return err
			}

			claims, _ := c.Get("auth_claims").(*models.AuthClaims)
			actorIdentifier := "anonymous"
			actorRole := ""
			var actorUserID *int32
			if claims != nil {
				actorUserID = &claims.UserID
				actorRole = claims.Role
				if claims.Email != "" {
					actorIdentifier = claims.Email
				} else if claims.PhoneNumber != "" {
					actorIdentifier = claims.PhoneNumber
				} else {
					actorIdentifier = strconv.Itoa(int(claims.UserID))
				}
			}

			statusCode := c.Response().Status
			if err != nil {
				if httpErr, ok := err.(*echo.HTTPError); ok && httpErr.Code > 0 {
					statusCode = httpErr.Code
				} else if statusCode < http.StatusBadRequest {
					statusCode = http.StatusInternalServerError
				}
			}

			entry := &models.AuditTrail{
				ActorUserID:     actorUserID,
				ActorIdentifier: actorIdentifier,
				ActorRole:       actorRole,
				Action:          auditActionFromRequest(c.Request().Method, requestPath, statusCode),
				Resource:        auditResourceFromPath(requestPath),
				Method:          c.Request().Method,
				Path:            requestPath,
				StatusCode:      statusCode,
				Success:         statusCode < http.StatusBadRequest,
				IPAddress:       c.RealIP(),
				UserAgent:       c.Request().UserAgent(),
				RequestID:       c.Request().Header.Get("X-Request-ID"),
			}

			details := map[string]string{}
			if c.QueryString() != "" {
				details["query"] = c.QueryString()
			}
			if err != nil {
				details["error"] = err.Error()
			}
			if len(details) > 0 {
				if payload, marshalErr := json.Marshal(details); marshalErr == nil {
					entry.Details = string(payload)
				}
			}

			if recordErr := recorder.Record(entry); recordErr != nil {
				c.Logger().Warnf("audit trail recording failed: %v", recordErr)
			}

			return err
		}
	}
}

func auditActionFromRequest(method, requestPath string, statusCode int) string {
	lowerPath := strings.ToLower(requestPath)
	switch {
	case strings.Contains(lowerPath, "/auth/login"):
		if statusCode < http.StatusBadRequest {
			return "LOGIN"
		}
		return "LOGIN_FAILED"
	case strings.Contains(lowerPath, "/auth/logout"):
		return "LOGOUT"
	case method == http.MethodPost:
		return "CREATE"
	case method == http.MethodPut || method == http.MethodPatch:
		return "UPDATE"
	case method == http.MethodDelete:
		return "DELETE"
	case method == http.MethodGet:
		return "READ"
	default:
		return strings.ToUpper(method)
	}
}

func auditResourceFromPath(requestPath string) string {
	cleaned := strings.Trim(strings.TrimSpace(requestPath), "/")
	if cleaned == "" {
		return "system"
	}

	segments := strings.Split(cleaned, "/")
	for i := len(segments) - 1; i >= 0; i-- {
		segment := strings.TrimSpace(segments[i])
		if segment == "" || strings.HasPrefix(segment, ":") {
			continue
		}
		return strings.Trim(path.Base("/"+segment), "/")
	}

	return "system"
}

func shouldRecordAudit(method, requestPath string) bool {
	lowerPath := strings.ToLower(strings.TrimSpace(requestPath))
	if lowerPath == "" {
		return false
	}

	if strings.Contains(lowerPath, "/auth/login") || strings.Contains(lowerPath, "/auth/logout") {
		return true
	}
	if strings.Contains(lowerPath, "backup") || strings.Contains(lowerPath, "restore") {
		return true
	}
	if method != http.MethodGet {
		return true
	}

	sensitiveGetHints := []string{
		"/audit-trail",
		"/summary",
		"/dashboard",
		"/history",
		"/detail",
		"/me",
		"/profile",
		"/report",
		"/rekap",
		"/monitoring",
		"/stat",
		"/stats",
	}
	for _, hint := range sensitiveGetHints {
		if strings.Contains(lowerPath, hint) {
			return true
		}
	}

	return false
}
