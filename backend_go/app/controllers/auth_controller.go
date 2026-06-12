package controllers

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"strconv"
	"strings"

	"monitoring-service/app/constants"
	"monitoring-service/app/helpers"
	"monitoring-service/app/models"
	"monitoring-service/app/usecases"
	"monitoring-service/pkg/customerror"

	"github.com/labstack/echo/v4"
)

// func (m *Main) RegisterOrangTua(c echo.Context) error {
// 	var req usecases.RegisterOrangTuaRequest
// 	if err := c.Bind(&req); err != nil {
// 		return helpers.Response(c, http.StatusBadRequest, []string{"format request tidak valid"})
// 	}
// 	if err := m.usecases.RegisterOrangTua.Register(&req); err != nil {
// 		statusCode := customerror.GetStatusCode(err)
// 		return helpers.Response(c, statusCode, []string{err.Error()})
// 	}
// 	return helpers.StandardResponse(c, http.StatusCreated, []string{constants.SUCCESS_RESPONSE_MESSAGE}, map[string]string{
// 		"message": "registrasi orang tua berhasil",
// 	}, nil)
// }

func (m *Main) Register(c echo.Context) error {
	var req models.RegisterRequest
	if err := c.Bind(&req); err != nil {
		return helpers.Response(c, http.StatusBadRequest, []string{"format request tidak valid"})
	}

	if err := m.usecases.Register(&req); err != nil {
		statusCode := customerror.GetStatusCode(err)
		return helpers.Response(c, statusCode, []string{err.Error()})
	}

	return helpers.StandardResponse(c, http.StatusCreated, []string{constants.SUCCESS_RESPONSE_MESSAGE}, map[string]string{
		"message": "registrasi berhasil",
	}, nil)
}

func (m *Main) Login(c echo.Context) error {
	var req models.LoginRequest
	if err := c.Bind(&req); err != nil {
		m.recordAuthAudit(c, "LOGIN_FAILED", false, "", "", nil, http.StatusBadRequest, "format request tidak valid")
		return helpers.Response(c, http.StatusBadRequest, []string{"format request tidak valid"})
	}
	identifier := strings.TrimSpace(req.Identifier)
	if identifier == "" {
		identifier = strings.TrimSpace(req.Email)
	}

	data, err := m.usecases.Login(&req)
	if err != nil {
		statusCode := customerror.GetStatusCode(err)
		m.recordAuthAudit(c, "LOGIN_FAILED", false, identifier, "", nil, statusCode, err.Error())
		return helpers.Response(c, statusCode, []string{err.Error()})
	}
	if req.FcmToken != "" {

		tokenReq := &models.TokenRequest{
			PenggunaID: uint(data.UserID),
			FcmToken:   req.FcmToken,
		}
		_ = m.usecases.SaveFCMToken(tokenReq)
	}

	userID := data.UserID
	actorIdentifier := data.Email
	if actorIdentifier == "" {
		actorIdentifier = data.PhoneNumber
	}
	m.recordAuthAudit(c, "LOGIN", true, actorIdentifier, data.Role, &userID, http.StatusOK, "login berhasil")

	return helpers.StandardResponse(c, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, data, nil)
}

func (m *Main) Logout(c echo.Context) error {
	return helpers.StandardResponse(c, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, map[string]string{"message": "logout berhasil"}, nil)
}

func (m *Main) recordAuthAudit(c echo.Context, action string, success bool, identifier string, role string, userID *int32, statusCode int, message string) {
	if m.usecases == nil || m.usecases.AuditTrail == nil {
		return
	}

	details := map[string]string{
		"message":    message,
		"ip":         c.RealIP(),
		"user_agent": c.Request().UserAgent(),
	}
	if payload, err := json.Marshal(details); err == nil {
		entry := &models.AuditTrail{
			ActorUserID:     userID,
			ActorIdentifier: strings.TrimSpace(identifier),
			ActorRole:       strings.TrimSpace(role),
			Action:          action,
			Resource:        "auth",
			Method:          c.Request().Method,
			Path:            c.Path(),
			StatusCode:      statusCode,
			Success:         success,
			IPAddress:       c.RealIP(),
			UserAgent:       c.Request().UserAgent(),
			RequestID:       c.Request().Header.Get("X-Request-ID"),
			Details:         string(payload),
		}
		if err := m.usecases.AuditTrail.Record(entry); err != nil {
			log.Printf("[AUDIT] gagal mencatat event auth: %v", err)
		}
	}
}

func (m *Main) AdminCreateKartuKeluarga(c echo.Context) error {
	var req usecases.AdminCreateKartuKeluargaRequest
	if err := c.Bind(&req); err != nil {
		return helpers.Response(c, http.StatusBadRequest, []string{"format request tidak valid"})
	}

	data, err := m.usecases.AdminAkunKeluarga.CreateKartuKeluarga(&req)
	if err != nil {
		statusCode := customerror.GetStatusCode(err)
		return helpers.Response(c, statusCode, []string{err.Error()})
	}

	return helpers.StandardResponse(c, http.StatusCreated, []string{constants.SUCCESS_RESPONSE_MESSAGE}, data, nil)
}

func (m *Main) AdminListKartuKeluarga(c echo.Context) error {
	search := c.QueryParam("search")
	page, _ := strconv.Atoi(c.QueryParam("page"))
	limit, _ := strconv.Atoi(c.QueryParam("limit"))
	sortBy := c.QueryParam("sort_by")
	sortDir := c.QueryParam("sort_dir")

	data, err := m.usecases.AdminAkunKeluarga.ListKartuKeluarga(search, page, limit, sortBy, sortDir)
	if err != nil {
		statusCode := customerror.GetStatusCode(err)
		return helpers.Response(c, statusCode, []string{err.Error()})
	}

	return helpers.StandardResponse(c, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, data, nil)
}

func (m *Main) AdminDetailKartuKeluarga(c echo.Context) error {
	id, err := strconv.ParseInt(c.Param("kartu_keluarga_id"), 10, 64)
	if err != nil {
		return helpers.Response(c, http.StatusBadRequest, []string{"kartu_keluarga_id tidak valid"})
	}

	data, detailErr := m.usecases.AdminAkunKeluarga.DetailKartuKeluarga(id)
	if detailErr != nil {
		statusCode := customerror.GetStatusCode(detailErr)
		return helpers.Response(c, statusCode, []string{detailErr.Error()})
	}

	return helpers.StandardResponse(c, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, data, nil)
}

func (m *Main) AdminUpdateKartuKeluarga(c echo.Context) error {
	id, err := strconv.ParseInt(c.Param("kartu_keluarga_id"), 10, 64)
	if err != nil {
		return helpers.Response(c, http.StatusBadRequest, []string{"kartu_keluarga_id tidak valid"})
	}

	var req usecases.AdminUpdateKartuKeluargaRequest
	if err := c.Bind(&req); err != nil {
		return helpers.Response(c, http.StatusBadRequest, []string{"format request tidak valid"})
	}

	data, updateErr := m.usecases.AdminAkunKeluarga.UpdateKartuKeluarga(id, &req)
	if updateErr != nil {
		statusCode := customerror.GetStatusCode(updateErr)
		return helpers.Response(c, statusCode, []string{updateErr.Error()})
	}

	return helpers.StandardResponse(c, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, data, nil)
}

func (m *Main) AdminUpdateAnggotaKeluarga(c echo.Context) error {
	kkID, err := strconv.ParseInt(c.Param("kartu_keluarga_id"), 10, 64)
	if err != nil {
		return helpers.Response(c, http.StatusBadRequest, []string{"kartu_keluarga_id tidak valid"})
	}

	pendudukID64, err := strconv.ParseInt(c.Param("penduduk_id"), 10, 32)
	if err != nil {
		return helpers.Response(c, http.StatusBadRequest, []string{"penduduk_id tidak valid"})
	}

	var req usecases.AdminAnggotaKeluargaRequest
	if err := c.Bind(&req); err != nil {
		return helpers.Response(c, http.StatusBadRequest, []string{"format request tidak valid"})
	}

	data, updateErr := m.usecases.AdminAkunKeluarga.UpdateAnggotaKeluarga(kkID, int32(pendudukID64), &req)
	if updateErr != nil {
		statusCode := customerror.GetStatusCode(updateErr)
		return helpers.Response(c, statusCode, []string{updateErr.Error()})
	}

	return helpers.StandardResponse(c, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, data, nil)
}

func (m *Main) AdminAddAnggotaKeluarga(c echo.Context) error {
	kkID, err := strconv.ParseInt(c.Param("kartu_keluarga_id"), 10, 64)
	if err != nil {
		return helpers.Response(c, http.StatusBadRequest, []string{"kartu_keluarga_id tidak valid"})
	}

	var req usecases.AdminAnggotaKeluargaRequest
	if err := c.Bind(&req); err != nil {
		return helpers.Response(c, http.StatusBadRequest, []string{"format request tidak valid"})
	}

	data, addErr := m.usecases.AdminAkunKeluarga.AddAnggotaKeluarga(kkID, &req)
	if addErr != nil {
		statusCode := customerror.GetStatusCode(addErr)
		return helpers.Response(c, statusCode, []string{addErr.Error()})
	}

	return helpers.StandardResponse(c, http.StatusCreated, []string{constants.SUCCESS_RESPONSE_MESSAGE}, data, nil)
}

func (m *Main) AdminDeleteAnggotaKeluarga(c echo.Context) error {
	kkID, err := strconv.ParseInt(c.Param("kartu_keluarga_id"), 10, 64)
	if err != nil {
		return helpers.Response(c, http.StatusBadRequest, []string{"kartu_keluarga_id tidak valid"})
	}

	pendudukID64, err := strconv.ParseInt(c.Param("penduduk_id"), 10, 32)
	if err != nil {
		return helpers.Response(c, http.StatusBadRequest, []string{"penduduk_id tidak valid"})
	}

	if deleteErr := m.usecases.AdminAkunKeluarga.DeleteAnggotaKeluarga(kkID, int32(pendudukID64)); deleteErr != nil {
		statusCode := customerror.GetStatusCode(deleteErr)
		return helpers.Response(c, statusCode, []string{deleteErr.Error()})
	}

	return helpers.StandardResponse(c, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, map[string]bool{"deleted": true}, nil)
}

func (m *Main) AdminDeleteKartuKeluarga(c echo.Context) error {
	id, err := strconv.ParseInt(c.Param("kartu_keluarga_id"), 10, 64)
	if err != nil {
		return helpers.Response(c, http.StatusBadRequest, []string{"kartu_keluarga_id tidak valid"})
	}

	if deleteErr := m.usecases.AdminAkunKeluarga.DeleteKartuKeluarga(id); deleteErr != nil {
		statusCode := customerror.GetStatusCode(deleteErr)
		return helpers.Response(c, statusCode, []string{deleteErr.Error()})
	}

	return helpers.StandardResponse(c, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, map[string]bool{"deleted": true}, nil)
}

func (m *Main) DebugAntropometri(c echo.Context) error {
	var results []string

	// 1. Check master_standar_antropometri count
	var count int64
	err := m.db.Table("master_standar_antropometri").Count(&count).Error
	if err != nil {
		results = append(results, fmt.Sprintf("master_standar_antropometri error: %v", err))
	} else {
		results = append(results, fmt.Sprintf("master_standar_antropometri count: %d", count))
	}

	// 2. Check Bidan user (id = 2) and their penduduk (id = 1) desa_id
	var bidanPend struct {
		ID     int32
		DesaID *int32
	}
	err = m.db.Table("penduduk").Select("id, desa_id").Where("id = 1").Scan(&bidanPend).Error
	if err != nil {
		results = append(results, fmt.Sprintf("bidan penduduk query error: %v", err))
	} else {
		desaIDStr := "nil"
		if bidanPend.DesaID != nil {
			desaIDStr = fmt.Sprintf("%d", *bidanPend.DesaID)
		}
		results = append(results, fmt.Sprintf("bidan penduduk ID=1, desa_id=%s", desaIDStr))
	}

	// 3. Check children in anak table and their associated penduduk records' desa_id
	type ChildInfo struct {
		AnakID int32
		PendID int32
		DesaID *int32
		Name   string
	}
	var children []ChildInfo
	err = m.db.Raw(`
		select a.id as anak_id, a.penduduk_id as pend_id, p.desa_id, p.nama_lengkap as name
		from anak a
		left join penduduk p on p.id = a.penduduk_id
	`).Scan(&children).Error
	if err != nil {
		results = append(results, fmt.Sprintf("children query error: %v", err))
	} else {
		results = append(results, fmt.Sprintf("children count in DB: %d", len(children)))
		for _, child := range children {
			desaIDStr := "nil"
			if child.DesaID != nil {
				desaIDStr = fmt.Sprintf("%d", *child.DesaID)
			}
			results = append(results, fmt.Sprintf("  Anak: ID=%d, Name=%s, PendID=%d, DesaID=%s", child.AnakID, child.Name, child.PendID, desaIDStr))
		}
	}

	// 4. Check kategori_capaian table count
	var katCount int64
	err = m.db.Table("kategori_capaian").Count(&katCount).Error
	if err != nil {
		results = append(results, fmt.Sprintf("kategori_capaian query error: %v", err))
	} else {
		results = append(results, fmt.Sprintf("kategori_capaian count in DB: %d", katCount))
	}

	// 5. Check master_standar_antropometri samples if count > 0
	if count > 0 {
		var samples []models.MasterStandarAntropometri
		m.db.Table("master_standar_antropometri").Limit(3).Find(&samples)
		for _, s := range samples {
			results = append(results, fmt.Sprintf("  Sample Standard: ID=%d, Param=%s, Gender=%s, X=%.2f, Median=%.2f", s.ID, s.Parameter, s.JenisKelamin, s.NilaiSumbuX, s.Median))
		}
	}

	outStr := strings.Join(results, "\n")
	_ = os.WriteFile("scratch/error_log.txt", []byte(outStr), 0644)

	return c.JSON(200, map[string]interface{}{
		"status":  "logged",
		"details": results,
	})
}

