package controllers

import (
	"net/http"
	"strconv"

	"monitoring-service/app/middlewares" // import middleware helpers
	"monitoring-service/app/usecases"

	"github.com/labstack/echo/v4"
)

type LaporanIbuController struct {
	usecase usecases.LaporanIbuUsecase
}

func NewLaporanIbuController(usecase usecases.LaporanIbuUsecase) *LaporanIbuController {
	return &LaporanIbuController{usecase}
}

func (c *LaporanIbuController) Preview(ctx echo.Context) error {
	bulanStr := ctx.QueryParam("bulan")
	tahunStr := ctx.QueryParam("tahun")

	var bulan, tahun int
	var err error

	if bulanStr != "" && tahunStr != "" {
		bulan, err = strconv.Atoi(bulanStr)
		if err != nil || bulan < 1 || bulan > 12 {
			return ctx.JSON(http.StatusBadRequest, map[string]interface{}{
				"message": "Parameter bulan harus antara 1-12",
			})
		}
		tahun, err = strconv.Atoi(tahunStr)
		if err != nil || tahun < 2000 || tahun > 2100 {
			return ctx.JSON(http.StatusBadRequest, map[string]interface{}{
				"message": "Parameter tahun tidak valid",
			})
		}
	}

	// Ambil desa_id dan role dari context (sudah diset middleware JWT)
	desaID := middlewares.GetDesaID(ctx)
	role := middlewares.GetRole(ctx)

	data, err := c.usecase.GetLaporanIbu(bulan, tahun, desaID, role)
	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, map[string]interface{}{
			"message": err.Error(),
		})
	}

	return ctx.JSON(http.StatusOK, map[string]interface{}{
		"message": "success",
		"data":    data,
	})
}

func (c *LaporanIbuController) ExportExcel(ctx echo.Context) error {
	bulanStr := ctx.QueryParam("bulan")
	tahunStr := ctx.QueryParam("tahun")

	var bulan, tahun int
	var err error

	if bulanStr != "" && tahunStr != "" {
		bulan, err = strconv.Atoi(bulanStr)
		if err != nil || bulan < 1 || bulan > 12 {
			return ctx.JSON(http.StatusBadRequest, map[string]interface{}{
				"message": "Parameter bulan harus antara 1-12",
			})
		}
		tahun, err = strconv.Atoi(tahunStr)
		if err != nil || tahun < 2000 || tahun > 2100 {
			return ctx.JSON(http.StatusBadRequest, map[string]interface{}{
				"message": "Parameter tahun tidak valid",
			})
		}
	}

	desaID := middlewares.GetDesaID(ctx)
	role := middlewares.GetRole(ctx)

	file, err := c.usecase.ExportExcelLaporanIbu(bulan, tahun, desaID, role)
	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, map[string]interface{}{
			"message": err.Error(),
		})
	}

	return ctx.Attachment(file, file)
}