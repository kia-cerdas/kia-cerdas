package controllers

import (
	"net/http"
	"regexp"
	"strconv"
	"time"

	"monitoring-service/app/helpers"
	"monitoring-service/app/models"
	"monitoring-service/app/usecases"

	"github.com/labstack/echo/v4"
	"gorm.io/gorm"
)

type JadwalLayananController struct {
	usecase usecases.JadwalLayananUsecase
	db      *gorm.DB
}

func NewJadwalLayananController(u usecases.JadwalLayananUsecase, db *gorm.DB) *JadwalLayananController {
	return &JadwalLayananController{u, db}
}

func timePtrToDBString(t *time.Time) *string {
	if t == nil {
		return nil
	}
	v := t.Format("15:04:05")
	return &v
}

func (c *JadwalLayananController) Create(ctx echo.Context) error {
	// Bind to intermediate struct
	var in struct {
		PosyanduID     *int32 `json:"posyandu_id"`
		Layanan        string `json:"layanan"`
		Tanggal        string `json:"tanggal"`
		WaktuMulai     string `json:"waktu_mulai"`
		WaktuSelesai   string `json:"waktu_selesai"`
		Keterangan     string `json:"keterangan"`
		DosisVaksinIDs []uint `json:"dosis_vaksin_ids"` // ← GANTI dari VaksinIDs
	}

	if err := ctx.Bind(&in); err != nil {
		return ctx.JSON(http.StatusBadRequest, echo.Map{"error": "invalid_request", "details": err.Error()})
	}

	// validation
	var fieldErrors []map[string]string
	if in.Layanan == "" {
		fieldErrors = append(fieldErrors, map[string]string{"field": "layanan", "message": "is required"})
	}

	var tanggalPtr *time.Time
	if in.Tanggal == "" {
		fieldErrors = append(fieldErrors, map[string]string{"field": "tanggal", "message": "is required, format YYYY-MM-DD"})
	} else {
		if t, err := time.Parse("2006-01-02", in.Tanggal); err != nil {
			fieldErrors = append(fieldErrors, map[string]string{"field": "tanggal", "message": "invalid format, use YYYY-MM-DD"})
		} else {
			tanggalPtr = &t
		}
	}

	// waktu validation
	if in.WaktuMulai == "" {
		fieldErrors = append(fieldErrors, map[string]string{"field": "waktu_mulai", "message": "is required, format HH:MM"})
	} else {
		re := regexp.MustCompile(`^([01]\d|2[0-3]):[0-5]\d$`)
		if !re.MatchString(in.WaktuMulai) {
			fieldErrors = append(fieldErrors, map[string]string{"field": "waktu_mulai", "message": "invalid format, use HH:MM"})
		}
	}
	if in.WaktuSelesai != "" {
		re := regexp.MustCompile(`^([01]\d|2[0-3]):[0-5]\d$`)
		if !re.MatchString(in.WaktuSelesai) {
			fieldErrors = append(fieldErrors, map[string]string{"field": "waktu_selesai", "message": "invalid format, use HH:MM"})
		}
	}

	var waktuMulaiParsed *time.Time
	if in.WaktuMulai != "" {
		if t, err := time.Parse("15:04", in.WaktuMulai); err != nil {
			fieldErrors = append(fieldErrors, map[string]string{"field": "waktu_mulai", "message": "invalid format, use HH:MM"})
		} else {
			waktuMulaiParsed = &t
		}
	}

	var waktuSelesaiParsed *time.Time
	if in.WaktuSelesai != "" {
		if t, err := time.Parse("15:04", in.WaktuSelesai); err != nil {
			fieldErrors = append(fieldErrors, map[string]string{"field": "waktu_selesai", "message": "invalid format, use HH:MM"})
		} else {
			waktuSelesaiParsed = &t
		}
	}

	if waktuMulaiParsed != nil && waktuSelesaiParsed != nil && !waktuSelesaiParsed.After(*waktuMulaiParsed) {
		fieldErrors = append(fieldErrors, map[string]string{"field": "waktu_selesai", "message": "must be later than waktu_mulai"})
	}

	if len(fieldErrors) > 0 {
		return ctx.JSON(http.StatusBadRequest, echo.Map{"error": "validation", "fields": fieldErrors})
	}

	// ✅ VALIDATE: Posyandu must belong to user's desa (for Create)
	if in.PosyanduID != nil {
		if err := helpers.ValidatePosyanduAccess(ctx, c.db, *in.PosyanduID); err != nil {
			return ctx.JSON(http.StatusForbidden, echo.Map{
				"error":   "access_denied",
				"message": err.Error(),
			})
		}
	}

	// Check if schedule already exists for this date
	if exists, err := c.usecase.CheckExistsByDate(*tanggalPtr, nil); err != nil {
		return ctx.JSON(http.StatusInternalServerError, echo.Map{"error": "database_error", "details": err.Error()})
	} else if exists {
		return ctx.JSON(http.StatusConflict, echo.Map{
			"error":   "duplicate_schedule",
			"message": "Jadwal layanan untuk tanggal ini sudah ada. Silakan pilih tanggal lain atau edit jadwal yang sudah ada.",
		})
	}

	// build model
	model := models.JadwalLayanan{
		PosyanduID: in.PosyanduID,
		Layanan:    in.Layanan,
		Tanggal:    tanggalPtr,
		Keterangan: in.Keterangan,
	}

	model.WaktuMulai = timePtrToDBString(waktuMulaiParsed)
	model.WaktuSelesai = timePtrToDBString(waktuSelesaiParsed)

	// Log untuk debugging
	println("Creating jadwal with dosis_vaksin_ids:", len(in.DosisVaksinIDs))
	for i, id := range in.DosisVaksinIDs {
		println("  Dosis Vaksin ID", i, ":", id)
	}

	// Panggil usecase dengan DosisVaksinIDs
	if err := c.usecase.Create(&model, in.DosisVaksinIDs); err != nil {
		// Log error detail
		println("ERROR creating jadwal:", err.Error())
		return ctx.JSON(http.StatusInternalServerError, echo.Map{"error": "create_failed", "details": err.Error()})
	}

	// Load data yang sudah dibuat
	result, _ := c.usecase.GetByID(model.ID)
	return ctx.JSON(http.StatusCreated, result)
}

func (c *JadwalLayananController) GetAll(ctx echo.Context) error {
	posyanduParam := ctx.QueryParam("posyandu_id")
	fromParam := ctx.QueryParam("from")
	toParam := ctx.QueryParam("to")
	upcomingParam := ctx.QueryParam("upcoming")
	limitParam := ctx.QueryParam("limit")

	// ✅ GET USER DESA for filtering
	desaID, err := helpers.GetUserDesaID(ctx, c.db)
	if err != nil {
		// Return error with proper message instead of generic unauthorized
		return ctx.JSON(http.StatusForbidden, echo.Map{
			"error":   "access_denied",
			"message": err.Error(),
		})
	}
	// If desaID is nil, user can see all desa (admin/puskesmas)
	// If desaID is not nil, user sees only their desa (bidan_desa/kader)

	if upcomingParam == "true" {
		limit := 5
		if limitParam != "" {
			if v, err := strconv.Atoi(limitParam); err == nil && v > 0 {
				limit = v
			}
		}
		data, err := c.usecase.GetUpcoming(limit, desaID)
		if err != nil {
			return ctx.JSON(http.StatusInternalServerError, echo.Map{"error": err.Error()})
		}
		return ctx.JSON(http.StatusOK, data)
	}

	var posyanduID *int32
	if posyanduParam != "" {
		if v, err := strconv.Atoi(posyanduParam); err == nil {
			tmp := int32(v)
			posyanduID = &tmp
		}
	}

	var fromTime *time.Time
	var toTime *time.Time
	if fromParam != "" {
		if t, err := time.Parse("2006-01-02", fromParam); err == nil {
			fromTime = &t
		}
	}
	if toParam != "" {
		if t, err := time.Parse("2006-01-02", toParam); err == nil {
			toTime = &t
		}
	}

	if posyanduID != nil || fromTime != nil || toTime != nil {
		data, err := c.usecase.GetByDateRange(posyanduID, fromTime, toTime, desaID)
		if err != nil {
			return ctx.JSON(http.StatusInternalServerError, echo.Map{"error": err.Error()})
		}
		return ctx.JSON(http.StatusOK, data)
	}

	data, err := c.usecase.GetAll(desaID)
	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, echo.Map{"error": err.Error()})
	}
	return ctx.JSON(http.StatusOK, data)
}

func (c *JadwalLayananController) GetByID(ctx echo.Context) error {
	id, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, echo.Map{"error": "invalid id"})
	}

	data, err := c.usecase.GetByID(int32(id))
	if err != nil {
		return ctx.JSON(http.StatusNotFound, echo.Map{"error": "Data not found"})
	}

	return ctx.JSON(http.StatusOK, data)
}

func (c *JadwalLayananController) Update(ctx echo.Context) error {
	id, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, echo.Map{"error": "invalid id"})
	}

	var in struct {
		PosyanduID     *int32 `json:"posyandu_id"`
		Layanan        string `json:"layanan"`
		Tanggal        string `json:"tanggal"`
		WaktuMulai     string `json:"waktu_mulai"`
		WaktuSelesai   string `json:"waktu_selesai"`
		Keterangan     string `json:"keterangan"`
		DosisVaksinIDs []uint `json:"dosis_vaksin_ids"` // ← GANTI dari VaksinIDs
	}

	if err := ctx.Bind(&in); err != nil {
		return ctx.JSON(http.StatusBadRequest, echo.Map{"error": "invalid_request", "details": err.Error()})
	}

	var fieldErrors []map[string]string
	var tanggalPtr *time.Time
	if in.Tanggal != "" {
		if t, err := time.Parse("2006-01-02", in.Tanggal); err != nil {
			fieldErrors = append(fieldErrors, map[string]string{"field": "tanggal", "message": "invalid format, use YYYY-MM-DD"})
		} else {
			tanggalPtr = &t
		}
	}

	if in.WaktuMulai != "" {
		re := regexp.MustCompile(`^([01]\d|2[0-3]):[0-5]\d$`)
		if !re.MatchString(in.WaktuMulai) {
			fieldErrors = append(fieldErrors, map[string]string{"field": "waktu_mulai", "message": "invalid format, use HH:MM"})
		}
	}
	if in.WaktuSelesai != "" {
		re := regexp.MustCompile(`^([01]\d|2[0-3]):[0-5]\d$`)
		if !re.MatchString(in.WaktuSelesai) {
			fieldErrors = append(fieldErrors, map[string]string{"field": "waktu_selesai", "message": "invalid format, use HH:MM"})
		}
	}

	var waktuMulaiParsed *time.Time
	if in.WaktuMulai != "" {
		if t, err := time.Parse("15:04", in.WaktuMulai); err != nil {
			fieldErrors = append(fieldErrors, map[string]string{"field": "waktu_mulai", "message": "invalid format, use HH:MM"})
		} else {
			waktuMulaiParsed = &t
		}
	}

	var waktuSelesaiParsed *time.Time
	if in.WaktuSelesai != "" {
		if t, err := time.Parse("15:04", in.WaktuSelesai); err != nil {
			fieldErrors = append(fieldErrors, map[string]string{"field": "waktu_selesai", "message": "invalid format, use HH:MM"})
		} else {
			waktuSelesaiParsed = &t
		}
	}

	if waktuMulaiParsed != nil && waktuSelesaiParsed != nil && !waktuSelesaiParsed.After(*waktuMulaiParsed) {
		fieldErrors = append(fieldErrors, map[string]string{"field": "waktu_selesai", "message": "must be later than waktu_mulai"})
	}

	if len(fieldErrors) > 0 {
		return ctx.JSON(http.StatusBadRequest, echo.Map{"error": "validation", "fields": fieldErrors})
	}

	// ✅ VALIDATE: Posyandu must belong to user's desa (for Update)
	if in.PosyanduID != nil {
		if err := helpers.ValidatePosyanduAccess(ctx, c.db, *in.PosyanduID); err != nil {
			return ctx.JSON(http.StatusForbidden, echo.Map{
				"error":   "access_denied",
				"message": err.Error(),
			})
		}
	}

	// Check if schedule already exists for this date (excluding current record)
	if tanggalPtr != nil {
		excludeID := int32(id)
		if exists, err := c.usecase.CheckExistsByDate(*tanggalPtr, &excludeID); err != nil {
			return ctx.JSON(http.StatusInternalServerError, echo.Map{"error": "database_error", "details": err.Error()})
		} else if exists {
			return ctx.JSON(http.StatusConflict, echo.Map{
				"error":   "duplicate_schedule",
				"message": "Jadwal layanan untuk tanggal ini sudah ada. Silakan pilih tanggal lain.",
			})
		}
	}

	// build partial model for update
	model := models.JadwalLayanan{}
	if in.PosyanduID != nil {
		model.PosyanduID = in.PosyanduID
	}
	if in.Layanan != "" {
		model.Layanan = in.Layanan
	}
	if tanggalPtr != nil {
		model.Tanggal = tanggalPtr
	}
	if waktuMulaiParsed != nil {
		model.WaktuMulai = timePtrToDBString(waktuMulaiParsed)
	}
	if waktuSelesaiParsed != nil {
		model.WaktuSelesai = timePtrToDBString(waktuSelesaiParsed)
	}
	if in.Keterangan != "" {
		model.Keterangan = in.Keterangan
	}

	// Panggil usecase dengan DosisVaksinIDs
	if err := c.usecase.Update(int32(id), &model, in.DosisVaksinIDs); err != nil {
		return ctx.JSON(http.StatusNotFound, echo.Map{"error": err.Error()})
	}

	return ctx.JSON(http.StatusOK, echo.Map{"message": "updated successfully"})
}

func (c *JadwalLayananController) Delete(ctx echo.Context) error {
	id, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, echo.Map{"error": "invalid id"})
	}

	if err := c.usecase.Delete(int32(id)); err != nil {
		return ctx.JSON(http.StatusInternalServerError, echo.Map{"error": err.Error()})
	}

	return ctx.JSON(http.StatusOK, echo.Map{"message": "deleted successfully"})
}
