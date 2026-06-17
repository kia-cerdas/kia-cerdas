package controllers

import (
	"net/http"
	"strconv"
	"time"

	"monitoring-service/app/constants"
	"monitoring-service/app/helpers"
	"monitoring-service/app/models"
	"monitoring-service/app/usecases"

	"github.com/labstack/echo/v4"
)

type PencatatanImunisasiController struct {
	usecase *usecases.PencatatanImunisasiUsecase
}

func NewPencatatanImunisasiController(usecase *usecases.PencatatanImunisasiUsecase) *PencatatanImunisasiController {
	return &PencatatanImunisasiController{usecase: usecase}
}

// Create handles POST /bidan/pencatatan-imunisasi
func (c *PencatatanImunisasiController) Create(ctx echo.Context) error {
	var req struct {
		IdJadwalImunisasiAnak uint   `json:"id_jadwal_imunisasi_anak"`
		TanggalPemberian      string `json:"tanggal_pemberian"`
		NomorBatch            string `json:"nomor_batch"`
		Catatan               string `json:"catatan"`
	}

	if err := ctx.Bind(&req); err != nil {
		return helpers.Response(ctx, http.StatusBadRequest, []string{"format request tidak valid"})
	}

	if req.IdJadwalImunisasiAnak == 0 {
		return helpers.Response(ctx, http.StatusBadRequest, []string{"id_jadwal_imunisasi_anak wajib diisi"})
	}

	var tanggalPemberian *time.Time
	if req.TanggalPemberian != "" {
		t, err := time.Parse("2006-01-02", req.TanggalPemberian)
		if err != nil {
			return helpers.Response(ctx, http.StatusBadRequest, []string{"format tanggal_pemberian tidak valid"})
		}
		tanggalPemberian = &t
	}

	// Ambil ID bidan/petugas yang sedang login dari JWT token
	var idBidanPetugas *int32
	if userID := ctx.Get("user_id"); userID != nil {
		// Middleware menyimpan sebagai int64
		if id, ok := userID.(int64); ok {
			idu := int32(id)
			idBidanPetugas = &idu
		} else if id, ok := userID.(int32); ok {
			idBidanPetugas = &id
		} else if id, ok := userID.(uint); ok {
			idu := int32(id)
			idBidanPetugas = &idu
		} else if id, ok := userID.(float64); ok {
			idu := int32(id)
			idBidanPetugas = &idu
		}
	}

	data := &models.PencatatanImunisasi{
		IdJadwalImunisasiAnak: req.IdJadwalImunisasiAnak,
		TanggalPemberian:      tanggalPemberian,
		NomorBatch:            req.NomorBatch,
		Catatan:               req.Catatan,
		IsSelesai:             false,
		IdBidanPetugas:        idBidanPetugas,
	}

	if err := c.usecase.Create(data); err != nil {
		return helpers.Response(ctx, http.StatusInternalServerError, []string{err.Error()})
	}

	return helpers.StandardResponse(ctx, http.StatusCreated, []string{constants.SUCCESS_RESPONSE_MESSAGE}, data, nil)
}

// GetByAnakID handles GET /bidan/pencatatan-imunisasi/anak/:anak_id
func (c *PencatatanImunisasiController) GetByAnakID(ctx echo.Context) error {
	anakID, err := strconv.Atoi(ctx.Param("anak_id"))
	if err != nil || anakID <= 0 {
		return helpers.Response(ctx, http.StatusBadRequest, []string{"anak_id tidak valid"})
	}

	data, err := c.usecase.GetByAnakID(uint(anakID))
	if err != nil {
		return helpers.Response(ctx, http.StatusInternalServerError, []string{err.Error()})
	}

	// DEBUG: Log untuk melihat data bidan_petugas
	for i, record := range data {
		if record.BidanPetugas != nil {
			ctx.Logger().Info("Record ", i, " - id_bidan_petugas: ", *record.IdBidanPetugas, " - BidanPetugas loaded: ", record.BidanPetugas.Name)
		} else {
			ctx.Logger().Info("Record ", i, " - id_bidan_petugas: ", record.IdBidanPetugas, " - BidanPetugas is nil")
		}
	}

	return helpers.StandardResponse(ctx, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, data, nil)
}

// SetSelesai handles PUT /bidan/pencatatan-imunisasi/:id/selesai
func (c *PencatatanImunisasiController) SetSelesai(ctx echo.Context) error {
	id, err := strconv.Atoi(ctx.Param("id"))
	if err != nil || id <= 0 {
		return helpers.Response(ctx, http.StatusBadRequest, []string{"id tidak valid"})
	}

	if err := c.usecase.SetSelesai(uint(id)); err != nil {
		return helpers.Response(ctx, http.StatusInternalServerError, []string{err.Error()})
	}

	return helpers.StandardResponse(ctx, http.StatusOK, []string{"pencatatan berhasil diselesaikan"}, nil, nil)
}

// GetAturanVaksinAnak handles GET /bidan/aturan-vaksin-anak
func (m *Main) GetAturanVaksinAnak(c echo.Context) error {
	data, err := m.usecases.GetAturanVaksinAnak()
	if err != nil {
		return helpers.Response(c, http.StatusInternalServerError, []string{err.Error()})
	}

	return helpers.StandardResponse(c, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, data, nil)
}
