package controllers

import (
	"net/http"
	"strconv"
	"strings"
	"time"

	"monitoring-service/app/constants"
	"monitoring-service/app/helpers"
	"monitoring-service/app/models"
	"monitoring-service/app/repositories"
	"monitoring-service/app/usecases"
	"monitoring-service/pkg/customerror"

	"github.com/labstack/echo/v4"
)

type AuditTrailController struct {
	usecase *usecases.AuditTrailUsecase
}

func NewAuditTrailController(usecase *usecases.AuditTrailUsecase) *AuditTrailController {
	return &AuditTrailController{usecase: usecase}
}

func (m *AuditTrailController) Record(entry *models.AuditTrail) error {
	if m == nil || m.usecase == nil {
		return nil
	}

	return m.usecase.Record(entry)
}

func (m *AuditTrailController) List(c echo.Context) error {
	filter, err := auditTrailFilterFromContext(c)
	if err != nil {
		return helpers.Response(c, http.StatusBadRequest, []string{err.Error()})
	}

	data, listErr := m.usecase.List(filter)
	if listErr != nil {
		return helpers.Response(c, customerror.GetStatusCode(listErr), []string{listErr.Error()})
	}

	return helpers.StandardResponse(c, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, data, nil)
}

func (m *AuditTrailController) Summary(c echo.Context) error {
	filter, err := auditTrailFilterFromContext(c)
	if err != nil {
		return helpers.Response(c, http.StatusBadRequest, []string{err.Error()})
	}

	data, summaryErr := m.usecase.Summary(filter)
	if summaryErr != nil {
		return helpers.Response(c, customerror.GetStatusCode(summaryErr), []string{summaryErr.Error()})
	}

	return helpers.StandardResponse(c, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, data, nil)
}

func auditTrailFilterFromContext(c echo.Context) (repositories.AuditTrailFilter, error) {
	page, err := parsePositiveInt(c.QueryParam("page"), 1)
	if err != nil {
		return repositories.AuditTrailFilter{}, err
	}
	limit, err := parsePositiveInt(c.QueryParam("limit"), 20)
	if err != nil {
		return repositories.AuditTrailFilter{}, err
	}

	var success *bool
	if value := strings.TrimSpace(c.QueryParam("success")); value != "" {
		parsed, parseErr := strconv.ParseBool(value)
		if parseErr != nil {
			return repositories.AuditTrailFilter{}, customerror.NewBadRequestError("parameter success harus true atau false")
		}
		success = &parsed
	}

	from, err := parseAuditTrailTime(c.QueryParam("from"))
	if err != nil {
		return repositories.AuditTrailFilter{}, err
	}
	to, err := parseAuditTrailTime(c.QueryParam("to"))
	if err != nil {
		return repositories.AuditTrailFilter{}, err
	}

	return repositories.AuditTrailFilter{
		Search:          c.QueryParam("search"),
		ActorIdentifier: c.QueryParam("user"),
		Action:          c.QueryParam("action"),
		Resource:        c.QueryParam("resource"),
		Role:            c.QueryParam("role"),
		Method:          c.QueryParam("method"),
		Success:         success,
		From:            from,
		To:              to,
		Page:            page,
		Limit:           limit,
	}, nil
}

func parsePositiveInt(raw string, fallback int) (int, error) {
	raw = strings.TrimSpace(raw)
	if raw == "" {
		return fallback, nil
	}

	value, err := strconv.Atoi(raw)
	if err != nil || value <= 0 {
		return 0, customerror.NewBadRequestError("parameter pagination tidak valid")
	}

	return value, nil
}

func parseAuditTrailTime(raw string) (*time.Time, error) {
	raw = strings.TrimSpace(raw)
	if raw == "" {
		return nil, nil
	}

	layouts := []string{time.RFC3339, "2006-01-02"}
	for _, layout := range layouts {
		if parsed, err := time.Parse(layout, raw); err == nil {
			return &parsed, nil
		}
	}

	return nil, customerror.NewBadRequestError("format tanggal audit trail tidak valid")
}
