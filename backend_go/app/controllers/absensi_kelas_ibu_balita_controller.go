package controllers

import (
	"net/http"
	"strconv"

	"monitoring-service/app/models"
	"monitoring-service/app/usecases"

	"github.com/labstack/echo/v4"
)

type AbsensiKelasIbuBalitaController struct {
	usecase usecases.AbsensiKelasIbuBalitaUsecase
}

func NewAbsensiKelasIbuBalitaController(
	u usecases.AbsensiKelasIbuBalitaUsecase,
) *AbsensiKelasIbuBalitaController {
	return &AbsensiKelasIbuBalitaController{usecase: u}
}

type saveAbsensiKelasIbuBalitaRequest struct {
	Tanggal      string `json:"tanggal"`
	NamaKader    string `json:"nama_kader"`
	TanggalParaf string `json:"tanggal_paraf"`
}

func (c *AbsensiKelasIbuBalitaController) GetMine(ctx echo.Context) error {
	claims, ok := ctx.Get("auth_claims").(*models.AuthClaims)
	if !ok || claims == nil {
		return ctx.JSON(http.StatusUnauthorized, models.Response{
			StatusCode: http.StatusUnauthorized,
			Message:    "token tidak valid",
		})
	}

	data, err := c.usecase.GetMine(claims.UserID)
	if err != nil {
		return ctx.JSON(http.StatusNotFound, models.Response{
			StatusCode: http.StatusNotFound,
			Message:    err.Error(),
		})
	}

	return ctx.JSON(http.StatusOK, models.Response{
		StatusCode: http.StatusOK,
		Data:       data,
	})
}

func (c *AbsensiKelasIbuBalitaController) SaveMine(ctx echo.Context) error {
	claims, ok := ctx.Get("auth_claims").(*models.AuthClaims)
	if !ok || claims == nil {
		return ctx.JSON(http.StatusUnauthorized, models.Response{
			StatusCode: http.StatusUnauthorized,
			Message:    "token tidak valid",
		})
	}

	var req saveAbsensiKelasIbuBalitaRequest
	if err := ctx.Bind(&req); err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{
			StatusCode: http.StatusBadRequest,
			Message:    "format request tidak valid",
		})
	}

	tanggal, err := parseOptionalDate(req.Tanggal)
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{
			StatusCode: http.StatusBadRequest,
			Message:    "format tanggal harus YYYY-MM-DD",
		})
	}

	tanggalParaf, err := parseOptionalDate(req.TanggalParaf)
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{
			StatusCode: http.StatusBadRequest,
			Message:    "format tanggal_paraf harus YYYY-MM-DD",
		})
	}

	data, err := c.usecase.SaveMine(
		claims.UserID,
		models.AbsensiKelasIbuBalita{
			Tanggal:      tanggal,
			NamaKader:    req.NamaKader,
			TanggalParaf: tanggalParaf,
		},
	)

	if err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{
			StatusCode: http.StatusBadRequest,
			Message:    err.Error(),
		})
	}

	return ctx.JSON(http.StatusOK, models.Response{
		StatusCode: http.StatusOK,
		Data:       data,
	})
}

func (c *AbsensiKelasIbuBalitaController) GetAll(ctx echo.Context) error {
	data, err := c.usecase.GetAll()
	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, models.Response{
			StatusCode: http.StatusInternalServerError,
			Message:    err.Error(),
		})
	}

	return ctx.JSON(http.StatusOK, models.Response{
		StatusCode: http.StatusOK,
		Data:       data,
	})
}

type verifyAbsensiKelasIbuBalitaRequest struct {
	NamaKader    string `json:"nama_kader"`
	TanggalParaf string `json:"tanggal_paraf"`
	Status       string `json:"status"`
}

func (c *AbsensiKelasIbuBalitaController) Verify(ctx echo.Context) error {
	idParam := ctx.Param("id")
	
	// Convert id param to int32, assume parse as int first then cast
	// Wait, we can use strconv.Atoi
	var req verifyAbsensiKelasIbuBalitaRequest
	if err := ctx.Bind(&req); err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{
			StatusCode: http.StatusBadRequest,
			Message:    "format request tidak valid",
		})
	}

	tanggalParaf, err := parseOptionalDate(req.TanggalParaf)
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{
			StatusCode: http.StatusBadRequest,
			Message:    "format tanggal_paraf harus YYYY-MM-DD",
		})
	}
	
	if req.NamaKader == "" {
	    return ctx.JSON(http.StatusBadRequest, models.Response{
			StatusCode: http.StatusBadRequest,
			Message:    "nama_kader tidak boleh kosong",
		})
	}

	// We need to parse idParam
	id, err := strconv.Atoi(idParam)
	if err != nil || id <= 0 {
		return ctx.JSON(http.StatusBadRequest, models.Response{
			StatusCode: http.StatusBadRequest,
			Message:    "id tidak valid",
		})
	}

	status := req.Status
	if status == "" {
		status = "Diterima"
	}

	err = c.usecase.Verify(int32(id), req.NamaKader, tanggalParaf, status)
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{
			StatusCode: http.StatusBadRequest,
			Message:    err.Error(),
		})
	}

	return ctx.JSON(http.StatusOK, models.Response{
		StatusCode: http.StatusOK,
		Message:    "Berhasil verifikasi absensi",
	})
}
