package controllers

import (
	"net/http"
	"strconv"

	"monitoring-service/app/models"
	"monitoring-service/app/usecases"

	"github.com/labstack/echo/v4"
)

type DosisVaksinController struct {
	usecase       usecases.DosisVaksinUsecase
	vaksinUsecase usecases.VaksinUsecase
}

func NewDosisVaksinController(u usecases.DosisVaksinUsecase, vu usecases.VaksinUsecase) *DosisVaksinController {
	return &DosisVaksinController{usecase: u, vaksinUsecase: vu}
}

func (ctrl *DosisVaksinController) GetAll(ctx echo.Context) error {
	data, err := ctrl.usecase.GetAll()
	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, echo.Map{"error": err.Error()})
	}

	return ctx.JSON(http.StatusOK, echo.Map{"data": data})
}

func (ctrl *DosisVaksinController) GetByVaksinID(ctx echo.Context) error {
	vaksinID, err := strconv.ParseUint(ctx.Param("vaksin_id"), 10, 64)
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, echo.Map{"error": "ID tidak valid"})
	}

	data, err := ctrl.usecase.GetByVaksinID(uint(vaksinID))
	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, echo.Map{"error": err.Error()})
	}

	return ctx.JSON(http.StatusOK, echo.Map{"data": data})
}

func (ctrl *DosisVaksinController) Create(ctx echo.Context) error {
	var req struct {
		NamaDosis string `json:"nama_dosis" validate:"required"`
		VaksinID  uint   `json:"vaksin_id" validate:"required"`
	}

	if err := ctx.Bind(&req); err != nil {
		return ctx.JSON(http.StatusBadRequest, echo.Map{"error": "Data tidak valid"})
	}

	if req.NamaDosis == "" {
		return ctx.JSON(http.StatusBadRequest, echo.Map{"error": "Nama dosis wajib diisi"})
	}

	if req.VaksinID == 0 {
		return ctx.JSON(http.StatusBadRequest, echo.Map{"error": "Vaksin wajib dipilih"})
	}

	// Verify vaksin exists
	if _, err := ctrl.vaksinUsecase.GetByID(req.VaksinID); err != nil {
		return ctx.JSON(http.StatusBadRequest, echo.Map{"error": "Vaksin tidak ditemukan"})
	}

	dosis := models.DosisVaksin{
		NamaDosis: req.NamaDosis,
		VaksinID:  req.VaksinID,
	}

	if err := ctrl.usecase.Create(&dosis); err != nil {
		return ctx.JSON(http.StatusInternalServerError, echo.Map{
			"error":   "Gagal menyimpan dosis vaksin",
			"details": err.Error(),
		})
	}

	return ctx.JSON(http.StatusCreated, echo.Map{
		"status":  "success",
		"message": "Dosis vaksin berhasil ditambahkan",
		"data":    dosis,
	})
}

func (ctrl *DosisVaksinController) Update(ctx echo.Context) error {
	id, err := strconv.ParseUint(ctx.Param("id"), 10, 64)
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, echo.Map{"error": "ID tidak valid"})
	}

	dosis, err := ctrl.usecase.GetByID(uint(id))
	if err != nil {
		return ctx.JSON(http.StatusNotFound, echo.Map{"error": "Dosis vaksin tidak ditemukan"})
	}

	var req struct {
		NamaDosis string `json:"nama_dosis"`
		VaksinID  uint   `json:"vaksin_id"`
	}

	if err := ctx.Bind(&req); err != nil {
		return ctx.JSON(http.StatusBadRequest, echo.Map{"error": "Data tidak valid"})
	}

	if req.NamaDosis != "" {
		dosis.NamaDosis = req.NamaDosis
	}
	if req.VaksinID != 0 {
		dosis.VaksinID = req.VaksinID
	}

	if err := ctrl.usecase.Update(dosis); err != nil {
		return ctx.JSON(http.StatusInternalServerError, echo.Map{
			"error":   "Gagal mengupdate dosis vaksin",
			"details": err.Error(),
		})
	}

	return ctx.JSON(http.StatusOK, echo.Map{
		"status":  "success",
		"message": "Dosis vaksin berhasil diupdate",
		"data":    dosis,
	})
}

func (ctrl *DosisVaksinController) Delete(ctx echo.Context) error {
	id, err := strconv.ParseUint(ctx.Param("id"), 10, 64)
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, echo.Map{"error": "ID tidak valid"})
	}

	if _, err := ctrl.usecase.GetByID(uint(id)); err != nil {
		return ctx.JSON(http.StatusNotFound, echo.Map{"error": "Dosis vaksin tidak ditemukan"})
	}

	if err := ctrl.usecase.Delete(uint(id)); err != nil {
		return ctx.JSON(http.StatusInternalServerError, echo.Map{
			"error":   "Gagal menghapus dosis vaksin",
			"details": err.Error(),
		})
	}

	return ctx.JSON(http.StatusOK, echo.Map{
		"status":  "success",
		"message": "Dosis vaksin berhasil dihapus",
	})
}
