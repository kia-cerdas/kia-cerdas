package controllers

import (
	"monitoring-service/app/middlewares"
	"monitoring-service/app/models"
	"monitoring-service/app/usecases"
	"net/http"
	"strconv"

	"github.com/labstack/echo/v4"
)

type PencatatanController struct {
    usecase usecases.PencatatanUsecase
}

func NewPencatatanController(usecase usecases.PencatatanUsecase) *PencatatanController {
    return &PencatatanController{usecase: usecase}
}

// GET /api/pencatatan/:kategori
func (ctrl *PencatatanController) GetDaftarPenduduk(c echo.Context) error {
    kategori := c.Param("kategori")
    if kategori == "" {
        return c.JSON(http.StatusBadRequest, map[string]string{"error": "kategori tidak boleh kosong"})
    }
    desaID := middlewares.GetDesaID(c)
    role := middlewares.GetRole(c)

    data, err := ctrl.usecase.GetPendudukByKategori(kategori, desaID, role)
    if err != nil {
        return c.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
    }
    return c.JSON(http.StatusOK, map[string]interface{}{
        "kategori": kategori,
        "data":     data,
    })
}

type PemeriksaanController struct {
    pemeriksaanUsecase usecases.PemeriksaanUsecase
}

func NewPemeriksaanController(pu usecases.PemeriksaanUsecase) *PemeriksaanController {
    return &PemeriksaanController{pemeriksaanUsecase: pu}
}

// GetActiveForm godoc
// @Summary      Get active form questions for a kelompok (used by bidan)
// @Tags         Bidan
// @Param        kelompok query string true "anak, remaja, dewasa, lansia"
// @Success      200 {object} models.ActiveFormResponse
// @Router       /api/forms/active [get]
func (c *PemeriksaanController) GetActiveForm(ctx echo.Context) error {
    kelompok := ctx.QueryParam("kelompok")
    if kelompok == "" {
        return ctx.JSON(http.StatusBadRequest, map[string]string{"error": "kelompok required"})
    }
    resp, err := c.pemeriksaanUsecase.GetActiveForm(ctx.Request().Context(), kelompok)
    if err != nil {
        return ctx.JSON(http.StatusNotFound, map[string]string{"error": err.Error()})
    }
    return ctx.JSON(http.StatusOK, resp)
}

// SavePemeriksaan godoc
// @Summary      Save a new pemeriksaan (health record)
// @Tags         Bidan
// @Accept       json
// @Produce      json
// @Param        request body models.SavePemeriksaanRequest true "Request body"
// @Success      201 {object} models.PemeriksaanResponse
// @Router       /api/pemeriksaan [post]
func (c *PemeriksaanController) SavePemeriksaan(ctx echo.Context) error {
    var req models.SavePemeriksaanRequest
    if err := ctx.Bind(&req); err != nil {
        return ctx.JSON(http.StatusBadRequest, map[string]string{"error": err.Error()})
    }
    // Get petugas ID from JWT context (set by middleware)
    var petugasID *uint
    if uid, ok := ctx.Get("user_id").(uint); ok {
        petugasID = &uid
    }
    resp, err := c.pemeriksaanUsecase.SavePemeriksaan(ctx.Request().Context(), &req, petugasID)
    if err != nil {
        return ctx.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
    }
    return ctx.JSON(http.StatusCreated, resp)
}

// GetRiwayatPenduduk godoc
// @Summary      Get pemeriksaan history for a penduduk
// @Tags         Bidan
// @Param        id path int true "Penduduk ID"
// @Param        kelompok query string false "Filter by kelompok (anak, remaja, dewasa, lansia)"
// @Success      200 {array} models.RiwayatPemeriksaanResponse
// @Router       /api/penduduk/{id}/riwayat [get]
func (c *PemeriksaanController) GetRiwayatPenduduk(ctx echo.Context) error {
    id, err := strconv.ParseUint(ctx.Param("id"), 10, 32)
    if err != nil {
        return ctx.JSON(http.StatusBadRequest, map[string]string{"error": "invalid penduduk id"})
    }
    kelompok := ctx.QueryParam("kelompok")
    list, err := c.pemeriksaanUsecase.GetRiwayatPenduduk(ctx.Request().Context(), uint(id), kelompok)
    if err != nil {
        return ctx.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
    }
    return ctx.JSON(http.StatusOK, list)
}

// GetDetailPemeriksaan godoc
// @Summary      Get detailed pemeriksaan by ID (with labels from version)
// @Tags         Bidan
// @Param        id path int true "Pemeriksaan ID"
// @Success      200 {object} models.DetailPemeriksaanResponse
// @Router       /api/pemeriksaan/{id} [get]
func (c *PemeriksaanController) GetDetailPemeriksaan(ctx echo.Context) error {
    id, err := strconv.ParseUint(ctx.Param("id"), 10, 32)
    if err != nil {
        return ctx.JSON(http.StatusBadRequest, map[string]string{"error": "invalid id"})
    }
    detail, err := c.pemeriksaanUsecase.GetDetailPemeriksaan(ctx.Request().Context(), uint(id))
    if err != nil {
        return ctx.JSON(http.StatusNotFound, map[string]string{"error": err.Error()})
    }
    return ctx.JSON(http.StatusOK, detail)
}