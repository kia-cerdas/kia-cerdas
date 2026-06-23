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
	// "monitoring-service/app/usecases"
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

// ==================== CRUD KEPENDUDUKAN ====================

// AdminCreateKependudukan - Create new penduduk record
func (m *Main) AdminCreateKependudukan(c echo.Context) error {
	var req models.Kependudukan
	if err := c.Bind(&req); err != nil {
		return helpers.Response(c, http.StatusBadRequest, []string{"format request tidak valid"})
	}

	// Validasi required fields
	if req.NIK == nil || *req.NIK == "" {
		return helpers.Response(c, http.StatusBadRequest, []string{"NIK wajib diisi"})
	}
	if req.NamaAnggotaKeluarga == "" {
		return helpers.Response(c, http.StatusBadRequest, []string{"nama_anggota_keluarga wajib diisi"})
	}
	if req.TanggalLahir.IsZero() {
		return helpers.Response(c, http.StatusBadRequest, []string{"tanggal_lahir wajib diisi"})
	}

	data, err := m.usecases.Kependudukan.Create(&req)
	if err != nil {
		statusCode := customerror.GetStatusCode(err)
		return helpers.Response(c, statusCode, []string{err.Error()})
	}

	return helpers.StandardResponse(c, http.StatusCreated, []string{constants.SUCCESS_RESPONSE_MESSAGE}, data, nil)
}

/// A// controllers/kependudukan_controller.go

// AdminListKependudukan - Get list of penduduk with pagination and filters
func (m *Main) AdminListKependudukan(c echo.Context) error {
	// Query parameters
	search := c.QueryParam("search")
	page, _ := strconv.Atoi(c.QueryParam("page"))
	limit, _ := strconv.Atoi(c.QueryParam("limit"))
	
	// Set default pagination
	if page <= 0 {
		page = 1
	}
	if limit <= 0 {
		limit = 10
	}
	if limit > 100 {
		limit = 100
	}
	
	// Additional filters
	filters := make(map[string]interface{})
	if rw := c.QueryParam("rw"); rw != "" {
		filters["rw"] = rw
	}
	if rt := c.QueryParam("rt"); rt != "" {
		filters["rt"] = rt
	}
	if dusun := c.QueryParam("dusun"); dusun != "" {
		filters["dusun"] = dusun
	}
	if kodeKeluarga := c.QueryParam("kode_keluarga"); kodeKeluarga != "" {
		filters["kode_keluarga"] = kodeKeluarga
	}
	if status := c.QueryParam("status"); status != "" {
		filters["status"] = status
	}
	if hubungan := c.QueryParam("hubungan"); hubungan != "" {
		filters["hubungan"] = hubungan
	}
	if posyanduID := c.QueryParam("posyandu_id"); posyanduID != "" {
		if id, err := strconv.Atoi(posyanduID); err == nil {
			filters["posyandu_id"] = id
		}
	}
	if desaID := c.QueryParam("desa_id"); desaID != "" {
		if id, err := strconv.Atoi(desaID); err == nil {
			filters["desa_id"] = id
		}
	}

	// Gunakan FindAllWithFilters untuk data lengkap dengan pagination
	penduduks, total, err := m.usecases.Kependudukan.FindAllWithFilters(search, page, limit, filters)
	if err != nil {
		statusCode := customerror.GetStatusCode(err)
		return helpers.Response(c, statusCode, []string{err.Error()})
	}

	// Prepare response with pagination
	response := map[string]interface{}{
		"items": penduduks,
		"pagination": map[string]interface{}{
			"page":        page,
			"limit":       limit,
			"total":       total,
			"total_pages": (total + limit - 1) / limit,
		},
	}

	return helpers.StandardResponse(c, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, response, nil)
}

// AdminDetailKependudukan - Get detail of a specific penduduk
func (m *Main) AdminDetailKependudukan(c echo.Context) error {
	id, err := strconv.ParseInt(c.Param("penduduk_id"), 10, 32)
	if err != nil {
		return helpers.Response(c, http.StatusBadRequest, []string{"penduduk_id tidak valid"})
	}

	data, detailErr := m.usecases.Kependudukan.GetByID(int32(id))
	if detailErr != nil {
		statusCode := customerror.GetStatusCode(detailErr)
		return helpers.Response(c, statusCode, []string{detailErr.Error()})
	}
	if data == nil {
		return helpers.Response(c, http.StatusNotFound, []string{"data penduduk tidak ditemukan"})
	}

	return helpers.StandardResponse(c, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, data, nil)
}

func (m *Main) AdminUpdateKependudukan(c echo.Context) error {
	id, err := strconv.ParseInt(c.Param("penduduk_id"), 10, 32)
	if err != nil {
		return helpers.Response(c, http.StatusBadRequest, []string{"penduduk_id tidak valid"})
	}

	// Get existing data
	existing, err := m.usecases.Kependudukan.GetByID(int32(id))
	if err != nil {
		statusCode := customerror.GetStatusCode(err)
		return helpers.Response(c, statusCode, []string{err.Error()})
	}
	if existing == nil {
		return helpers.Response(c, http.StatusNotFound, []string{"data penduduk tidak ditemukan"})
	}

	// Gunakan JSON Decoder langsung
	var req models.Kependudukan
	if err := json.NewDecoder(c.Request().Body).Decode(&req); err != nil {
		return helpers.Response(c, http.StatusBadRequest, []string{"format request tidak valid: " + err.Error()})
	}

	// Update fields dari req
	if req.RW != "" {
		existing.RW = req.RW
	}
	if req.RT != "" {
		existing.RT = req.RT
	}
	if req.Dusun != "" {
		existing.Dusun = req.Dusun
	}
	if req.Alamat != "" {
		existing.Alamat = req.Alamat
	}
	if req.KodeKeluarga != "" {
		existing.KodeKeluarga = req.KodeKeluarga
	}
	if req.NamaKepalaKeluarga != "" {
		existing.NamaKepalaKeluarga = req.NamaKepalaKeluarga
	}
	if req.NIK != nil && *req.NIK != "" {
		existing.NIK = req.NIK
	}
	if req.NamaAnggotaKeluarga != "" {
		existing.NamaAnggotaKeluarga = req.NamaAnggotaKeluarga
	}
	if req.JenisKelamin != "" {
		existing.JenisKelamin = req.JenisKelamin
	}
	if req.Hubungan != "" {
		existing.Hubungan = req.Hubungan
	}
	if req.TempatLahir != "" {
		existing.TempatLahir = req.TempatLahir
	}
	if !req.TanggalLahir.IsZero() {
		existing.TanggalLahir = req.TanggalLahir
	}
	if req.Status != "" {
		existing.Status = req.Status
	}
	if req.Agama != "" {
		existing.Agama = req.Agama
	}
	if req.GolonganDarah != "" {
		existing.GolonganDarah = req.GolonganDarah
	}
	if req.Kewarganegaraan != "" {
		existing.Kewarganegaraan = req.Kewarganegaraan
	}
	if req.EtnisSuku != "" {
		existing.EtnisSuku = req.EtnisSuku
	}
	if req.Pendidikan != "" {
		existing.Pendidikan = req.Pendidikan
	}
	if req.Pekerjaan != "" {
		existing.Pekerjaan = req.Pekerjaan
	}
	if req.Telepon != "" {
		existing.Telepon = req.Telepon
	}
	if req.DesaID != nil {
		existing.DesaID = req.DesaID
	}
	if req.PosyanduID != nil {
		existing.PosyanduID = req.PosyanduID
	}

	if updateErr := m.usecases.Kependudukan.Update(existing); updateErr != nil {
		statusCode := customerror.GetStatusCode(updateErr)
		return helpers.Response(c, statusCode, []string{updateErr.Error()})
	}

	return helpers.StandardResponse(c, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, existing, nil)
}

// AdminDeleteKependudukan - Soft delete penduduk record
func (m *Main) AdminDeleteKependudukan(c echo.Context) error {
	id, err := strconv.ParseInt(c.Param("penduduk_id"), 10, 32)
	if err != nil {
		return helpers.Response(c, http.StatusBadRequest, []string{"penduduk_id tidak valid"})
	}

	if deleteErr := m.usecases.Kependudukan.Delete(int32(id)); deleteErr != nil {
		statusCode := customerror.GetStatusCode(deleteErr)
		return helpers.Response(c, statusCode, []string{deleteErr.Error()})
	}

	return helpers.StandardResponse(c, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, map[string]bool{"deleted": true}, nil)
}

// AdminGetAnggotaByKodeKeluarga - Get all family members by KK code
func (m *Main) AdminGetAnggotaByKodeKeluarga(c echo.Context) error {
	kodeKeluarga := c.Param("kode_keluarga")
	if kodeKeluarga == "" {
		return helpers.Response(c, http.StatusBadRequest, []string{"kode_keluarga tidak boleh kosong"})
	}

	// Get all active penduduk
	penduduks, err := m.usecases.Kependudukan.GetAllActive()
	if err != nil {
		statusCode := customerror.GetStatusCode(err)
		return helpers.Response(c, statusCode, []string{err.Error()})
	}

	// Filter by kode keluarga
	var anggota []models.Kependudukan
	for _, p := range penduduks {
		if p.KodeKeluarga == kodeKeluarga {
			anggota = append(anggota, p)
		}
	}

	if len(anggota) == 0 {
		return helpers.Response(c, http.StatusNotFound, []string{"keluarga tidak ditemukan"})
	}

	// Cari kepala keluarga
	var namaKepala string
	for _, a := range anggota {
		if a.Hubungan == "Kepala Keluarga" {
			namaKepala = a.NamaAnggotaKeluarga
			break
		}
	}
	if namaKepala == "" && len(anggota) > 0 {
		namaKepala = anggota[0].NamaAnggotaKeluarga
	}

	result := map[string]interface{}{
		"kode_keluarga":        kodeKeluarga,
		"nama_kepala_keluarga": namaKepala,
		"jumlah_anggota":       len(anggota),
		"anggota":              anggota,
	}

	return helpers.StandardResponse(c, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, result, nil)
}

// AdminGetKepalaKeluarga - Get kepala keluarga by kode keluarga
func (m *Main) AdminGetKepalaKeluarga(c echo.Context) error {
	kodeKeluarga := c.Param("kode_keluarga")
	if kodeKeluarga == "" {
		return helpers.Response(c, http.StatusBadRequest, []string{"kode_keluarga tidak boleh kosong"})
	}

	penduduks, err := m.usecases.Kependudukan.GetAllActive()
	if err != nil {
		statusCode := customerror.GetStatusCode(err)
		return helpers.Response(c, statusCode, []string{err.Error()})
	}

	var kepala *models.Kependudukan
	for _, p := range penduduks {
		if p.KodeKeluarga == kodeKeluarga && p.Hubungan == "Kepala Keluarga" {
			kepala = &p
			break
		}
	}

	if kepala == nil {
		return helpers.Response(c, http.StatusNotFound, []string{"kepala keluarga tidak ditemukan"})
	}

	return helpers.StandardResponse(c, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, kepala, nil)
}

// AdminGetStatistikKependudukan - Get statistics for penduduk
func (m *Main) AdminGetStatistikKependudukan(c echo.Context) error {
	penduduks, err := m.usecases.Kependudukan.GetAllActive()
	if err != nil {
		statusCode := customerror.GetStatusCode(err)
		return helpers.Response(c, statusCode, []string{err.Error()})
	}

	// Filter by desa_id jika ada
	if desaID := c.QueryParam("desa_id"); desaID != "" {
		if id, err := strconv.Atoi(desaID); err == nil {
			filtered := []models.Kependudukan{}
			for _, p := range penduduks {
				if p.DesaID != nil && *p.DesaID == int32(id) {
					filtered = append(filtered, p)
				}
			}
			penduduks = filtered
		}
	}

	// Filter by posyandu_id jika ada
	if posyanduID := c.QueryParam("posyandu_id"); posyanduID != "" {
		if id, err := strconv.Atoi(posyanduID); err == nil {
			filtered := []models.Kependudukan{}
			for _, p := range penduduks {
				if p.PosyanduID != nil && *p.PosyanduID == int32(id) {
					filtered = append(filtered, p)
				}
			}
			penduduks = filtered
		}
	}

	// Hitung statistik
	stats := map[string]interface{}{
		"total_penduduk": len(penduduks),
		"jenis_kelamin": map[string]int{
			"laki":      0,
			"perempuan": 0,
		},
		"status":         map[string]int{},
		"hubungan":       map[string]int{},
		"agama":          map[string]int{},
		"pendidikan":     map[string]int{},
		"pekerjaan":      map[string]int{},
		"golongan_darah": map[string]int{},
	}

	for _, p := range penduduks {
		// Jenis kelamin
		if p.JenisKelamin == "Laki-laki" || p.JenisKelamin == "laki-laki" || p.JenisKelamin == "Laki" || p.JenisKelamin == "laki" {
			stats["jenis_kelamin"].(map[string]int)["laki"]++
		} else if p.JenisKelamin == "Perempuan" || p.JenisKelamin == "perempuan" {
			stats["jenis_kelamin"].(map[string]int)["perempuan"]++
		}

		// Status
		if p.Status != "" {
			stats["status"].(map[string]int)[p.Status]++
		}

		// Hubungan
		if p.Hubungan != "" {
			stats["hubungan"].(map[string]int)[p.Hubungan]++
		}

		// Agama
		if p.Agama != "" {
			stats["agama"].(map[string]int)[p.Agama]++
		}

		// Pendidikan
		if p.Pendidikan != "" {
			stats["pendidikan"].(map[string]int)[p.Pendidikan]++
		}

		// Pekerjaan
		if p.Pekerjaan != "" {
			stats["pekerjaan"].(map[string]int)[p.Pekerjaan]++
		}

		// Golongan Darah
		if p.GolonganDarah != "" {
			stats["golongan_darah"].(map[string]int)[p.GolonganDarah]++
		}
	}

	return helpers.StandardResponse(c, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, stats, nil)
}

// Helper function untuk filter penduduk
func filterPenduduk(penduduks []models.Kependudukan, filters map[string]interface{}, search string) []models.Kependudukan {
	result := []models.Kependudukan{}
	
	for _, p := range penduduks {
		match := true
		
		// Filter by search
		if search != "" {
			found := false
			if p.NamaAnggotaKeluarga != "" && strings.Contains(strings.ToLower(p.NamaAnggotaKeluarga), strings.ToLower(search)) {
				found = true
			}
			if p.NIK != nil && strings.Contains(*p.NIK, search) {
				found = true
			}
			if p.KodeKeluarga != "" && strings.Contains(p.KodeKeluarga, search) {
				found = true
			}
			if !found {
				match = false
			}
		}
		
		// Filter by RW
		if match && filters["rw"] != nil && filters["rw"] != "" {
			if p.RW != filters["rw"] {
				match = false
			}
		}
		
		// Filter by RT
		if match && filters["rt"] != nil && filters["rt"] != "" {
			if p.RT != filters["rt"] {
				match = false
			}
		}
		
		// Filter by Dusun
		if match && filters["dusun"] != nil && filters["dusun"] != "" {
			if p.Dusun != filters["dusun"] {
				match = false
			}
		}
		
		// Filter by Kode Keluarga
		if match && filters["kode_keluarga"] != nil && filters["kode_keluarga"] != "" {
			if p.KodeKeluarga != filters["kode_keluarga"] {
				match = false
			}
		}
		
		// Filter by Status
		if match && filters["status"] != nil && filters["status"] != "" {
			if p.Status != filters["status"] {
				match = false
			}
		}
		
		// Filter by Hubungan
		if match && filters["hubungan"] != nil && filters["hubungan"] != "" {
			if p.Hubungan != filters["hubungan"] {
				match = false
			}
		}
		
		if match {
			result = append(result, p)
		}
	}
	
	return result
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
		select a.id as anak_id, a.penduduk_id as pend_id, p.desa_id, p.nama_anggota_keluarga as name
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
// AdminListAllKependudukan - Get all penduduk without pagination
func (m *Main) AdminListAllKependudukan(c echo.Context) error {
    // Ambil semua data penduduk
    penduduks, err := m.usecases.Kependudukan.FindAll()
    if err != nil {
        statusCode := customerror.GetStatusCode(err)
        return helpers.Response(c, statusCode, []string{err.Error()})
    }

    // Response tanpa pagination
    return helpers.StandardResponse(c, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, penduduks, nil)
}

func (m *Main) DebugAnaksFull(c echo.Context) error {
	type DebugAnak struct {
		AnakID              int32  `json:"anak_id"`
		PendID              int32  `json:"pend_id"`
		Name                string `json:"name"`
		TanggalLahir        string `json:"tanggal_lahir"`
		ChildPosyanduID     *int32 `json:"child_posyandu_id"`
		ChildDesaID         *int32 `json:"child_desa_id"`
		MotherName          string `json:"mother_name"`
		MotherPosyanduID    *int32 `json:"mother_posyandu_id"`
		MotherDesaID        *int32 `json:"mother_desa_id"`
	}

	var results []DebugAnak
	err := m.db.Raw(`
		SELECT 
			a.id AS anak_id,
			p.id AS pend_id,
			p.nama_anggota_keluarga AS name,
			p.tanggal_lahir::text AS tanggal_lahir,
			p.posyandu_id AS child_posyandu_id,
			p.desa_id AS child_desa_id,
			pi.nama_anggota_keluarga AS mother_name,
			pi.posyandu_id AS mother_posyandu_id,
			pi.desa_id AS mother_desa_id
		FROM anak a
		LEFT JOIN penduduk p ON p.id = a.penduduk_id
		LEFT JOIN ibu i ON i.id = a.ibu_id
		LEFT JOIN penduduk pi ON pi.id = i.penduduk_id
	`).Scan(&results).Error

	if err != nil {
		return c.JSON(500, map[string]interface{}{"error": err.Error()})
	}

	return c.JSON(200, map[string]interface{}{
		"total":   len(results),
		"results": results,
	})
}