package controllers

import (
	"monitoring-service/app/helpers"
	"monitoring-service/app/models"
	"monitoring-service/app/usecases"
	"net/http"
	"strconv"

	"github.com/labstack/echo/v4"
)

type BblController interface {
	GetByAnakID(c echo.Context) error
	Upsert(c echo.Context) error
	Verify(c echo.Context) error
	GetAll(c echo.Context) error
}

type bblController struct {
	bblUsecase usecases.BblUsecase
}

func NewBblController(bblUsecase usecases.BblUsecase) BblController {
	return &bblController{
		bblUsecase: bblUsecase,
	}
}

func (ctrl *bblController) GetByAnakID(c echo.Context) error {
	anakIDStr := c.Param("anak_id")
	anakID, err := strconv.Atoi(anakIDStr)
	if err != nil {
		return helpers.StandardResponse(c, http.StatusBadRequest, "Invalid Anak ID", nil, nil)
	}

	bbl, err := ctrl.bblUsecase.GetByAnakID(uint(anakID))
	if err != nil {
		return helpers.StandardResponse(c, http.StatusNotFound, "BBL data not found", nil, nil)
	}

	return helpers.StandardResponse(c, http.StatusOK, "BBL data fetched successfully", bbl, nil)
}

func (ctrl *bblController) Upsert(c echo.Context) error {
	anakIDStr := c.Param("anak_id")
	anakID, err := strconv.Atoi(anakIDStr)
	if err != nil {
		return helpers.StandardResponse(c, http.StatusBadRequest, "Invalid Anak ID", nil, nil)
	}

	var req models.Bbl
	if err := c.Bind(&req); err != nil {
		return helpers.StandardResponse(c, http.StatusBadRequest, "Invalid request payload: "+err.Error(), nil, nil)
	}
	req.AnakID = uint(anakID)

	err = ctrl.bblUsecase.Upsert(&req)
	if err != nil {
		return helpers.StandardResponse(c, http.StatusInternalServerError, "Failed to upsert BBL data: "+err.Error(), nil, nil)
	}

	return helpers.StandardResponse(c, http.StatusOK, "BBL data updated successfully", req, nil)
}

func (ctrl *bblController) Verify(c echo.Context) error {
	anakIDStr := c.Param("anak_id")
	anakID, err := strconv.Atoi(anakIDStr)
	if err != nil {
		return helpers.StandardResponse(c, http.StatusBadRequest, "Invalid Anak ID", nil, nil)
	}

	// Ambil kader_id dan periode_waktu dari request body
	var body struct {
		KaderID      uint   `json:"kader_id"`
		PeriodeWaktu string `json:"periode_waktu"`
		Status       string `json:"status"`
	}
	if err := c.Bind(&body); err != nil {
		return helpers.StandardResponse(c, http.StatusBadRequest, "Invalid request payload", nil, nil)
	}
	if body.KaderID == 0 {
		return helpers.StandardResponse(c, http.StatusBadRequest, "kader_id is required", nil, nil)
	}
	if body.PeriodeWaktu == "" {
		return helpers.StandardResponse(c, http.StatusBadRequest, "periode_waktu is required", nil, nil)
	}

	// Cari BBL berdasarkan anak_id
	bbl, err := ctrl.bblUsecase.GetByAnakID(uint(anakID))
	if err != nil {
		return helpers.StandardResponse(c, http.StatusNotFound, "BBL data not found", nil, nil)
	}

	if body.Status == "" {
		body.Status = "Diterima"
	}

	// Verifikasi
	result, err := ctrl.bblUsecase.Verify(bbl.ID, body.KaderID, body.PeriodeWaktu, body.Status)
	if err != nil {
		return helpers.StandardResponse(c, http.StatusInternalServerError, "Failed to verify BBL: "+err.Error(), nil, nil)
	}

	return helpers.StandardResponse(c, http.StatusOK, "BBL verified successfully", result, nil)
}

func (ctrl *bblController) GetAll(c echo.Context) error {
	bbls, err := ctrl.bblUsecase.GetAll()
	if err != nil {
		return helpers.StandardResponse(c, http.StatusInternalServerError, "Failed to fetch BBL records", nil, nil)
	}

	return helpers.StandardResponse(c, http.StatusOK, "BBL records fetched successfully", bbls, nil)
}

