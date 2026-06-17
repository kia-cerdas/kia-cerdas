package controllers

import (
	"net/http"
	"strconv"

	"monitoring-service/app/models"
	"monitoring-service/app/usecases"

	"github.com/labstack/echo/v4"
)

type VaksinController struct {
	usecase usecases.VaksinUsecase
}

func NewVaksinController(u usecases.VaksinUsecase) *VaksinController {
	return &VaksinController{usecase: u}
}

func (ctrl *VaksinController) GetAll(ctx echo.Context) error {
	data, err := ctrl.usecase.GetAll()
	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, echo.Map{"error": err.Error()})
	}

	return ctx.JSON(http.StatusOK, echo.Map{"data": data})
}

func (ctrl *VaksinController) GetByID(ctx echo.Context) error {
	id, err := strconv.ParseUint(ctx.Param("id"), 10, 64)
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, echo.Map{"error": "ID tidak valid"})
	}

	data, err := ctrl.usecase.GetByID(uint(id))
	if err != nil {
		return ctx.JSON(http.StatusNotFound, echo.Map{"error": "Vaksin tidak ditemukan"})
	}

	return ctx.JSON(http.StatusOK, echo.Map{"data": data})
}

func (ctrl *VaksinController) Create(ctx echo.Context) error {
	var req struct {
		Nama        string `json:"nama" validate:"required"`
		Deskripsi   string `json:"deskripsi"`
		EfekSamping string `json:"efek_samping"`
	}

	if err := ctx.Bind(&req); err != nil {
		return ctx.JSON(http.StatusBadRequest, echo.Map{"error": "Data tidak valid"})
	}

	if req.Nama == "" {
		return ctx.JSON(http.StatusBadRequest, echo.Map{"error": "Nama vaksin wajib diisi"})
	}

	vaksin := models.Vaksin{
		Name:        req.Nama,
		Deskripsi:   req.Deskripsi,
		EfekSamping: req.EfekSamping,
	}

	if err := ctrl.usecase.Create(&vaksin); err != nil {
		return ctx.JSON(http.StatusInternalServerError, echo.Map{
			"error":   "Gagal menyimpan vaksin",
			"details": err.Error(),
		})
	}

	return ctx.JSON(http.StatusCreated, echo.Map{
		"status":  "success",
		"message": "Vaksin berhasil ditambahkan",
		"data":    vaksin,
	})
}

func (ctrl *VaksinController) Update(ctx echo.Context) error {
	id, err := strconv.ParseUint(ctx.Param("id"), 10, 64)
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, echo.Map{"error": "ID tidak valid"})
	}

	vaksin, err := ctrl.usecase.GetByID(uint(id))
	if err != nil {
		return ctx.JSON(http.StatusNotFound, echo.Map{"error": "Vaksin tidak ditemukan"})
	}

	var req struct {
		Nama        string `json:"nama"`
		Deskripsi   string `json:"deskripsi"`
		EfekSamping string `json:"efek_samping"`
	}

	if err := ctx.Bind(&req); err != nil {
		return ctx.JSON(http.StatusBadRequest, echo.Map{"error": "Data tidak valid"})
	}

	if req.Nama != "" {
		vaksin.Name = req.Nama
	}
	vaksin.Deskripsi = req.Deskripsi
	vaksin.EfekSamping = req.EfekSamping

	if err := ctrl.usecase.Update(vaksin); err != nil {
		return ctx.JSON(http.StatusInternalServerError, echo.Map{
			"error":   "Gagal mengupdate vaksin",
			"details": err.Error(),
		})
	}

	return ctx.JSON(http.StatusOK, echo.Map{
		"status":  "success",
		"message": "Vaksin berhasil diupdate",
		"data":    vaksin,
	})
}

func (ctrl *VaksinController) Delete(ctx echo.Context) error {
	id, err := strconv.ParseUint(ctx.Param("id"), 10, 64)
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, echo.Map{"error": "ID tidak valid"})
	}

	// Verify exists first
	if _, err := ctrl.usecase.GetByID(uint(id)); err != nil {
		return ctx.JSON(http.StatusNotFound, echo.Map{"error": "Vaksin tidak ditemukan"})
	}

	if err := ctrl.usecase.Delete(uint(id)); err != nil {
		return ctx.JSON(http.StatusInternalServerError, echo.Map{
			"error":   "Gagal menghapus vaksin",
			"details": err.Error(),
		})
	}

	return ctx.JSON(http.StatusOK, echo.Map{
		"status":  "success",
		"message": "Vaksin berhasil dihapus",
	})
}
