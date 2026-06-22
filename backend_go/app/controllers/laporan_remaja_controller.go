package controllers

import (
	"net/http"

	"monitoring-service/app/middlewares"
	"monitoring-service/app/usecases"

	"github.com/labstack/echo/v4"
)

type LaporanRemajaController struct {
	usecase usecases.LaporanRemajaUsecase
}

func NewLaporanRemajaController(usecase usecases.LaporanRemajaUsecase) *LaporanRemajaController {
	return &LaporanRemajaController{usecase}
}

// Preview godoc
// @Summary      Preview data laporan remaja (JSON)
// @Tags         laporan-remaja
// @Security     BearerAuth
// @Produce      json
// @Param        start_date  query  string  false  "Tanggal Pemeriksaan Awal (YYYY-MM-DD)"
// @Param        end_date    query  string  false  "Tanggal Pemeriksaan Akhir (YYYY-MM-DD)"
// @Success      200  {object}  models.Response
// @Failure      500  {object}  models.Response
// @Router       /tenaga-kesehatan/laporan/remaja/preview [get]
func (c *LaporanRemajaController) Preview(ctx echo.Context) error {
	posyanduID := middlewares.GetPosyanduID(ctx)
	role := middlewares.GetRole(ctx)
	startDate := ctx.QueryParam("start_date")
	endDate := ctx.QueryParam("end_date")

	data, err := c.usecase.GetLaporanRemaja(startDate, endDate, posyanduID, role)
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

// ExportExcel godoc
// @Summary      Export laporan data remaja ke file Excel (.xlsx)
// @Tags         laporan-remaja
// @Security     BearerAuth
// @Produce      application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
// @Param        start_date  query  string  false  "Tanggal Pemeriksaan Awal (YYYY-MM-DD)"
// @Param        end_date    query  string  false  "Tanggal Pemeriksaan Akhir (YYYY-MM-DD)"
// @Success      200  {file}    file
// @Failure      500  {object}  models.Response
// @Router       /tenaga-kesehatan/laporan/remaja/export/excel [get]
func (c *LaporanRemajaController) ExportExcel(ctx echo.Context) error {
	posyanduID := middlewares.GetPosyanduID(ctx)
	role := middlewares.GetRole(ctx)
	startDate := ctx.QueryParam("start_date")
	endDate := ctx.QueryParam("end_date")

	f, err := c.usecase.ExportExcelLaporanRemaja(startDate, endDate, posyanduID, role)
	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, map[string]interface{}{
			"message": err.Error(),
		})
	}
	defer f.Close()

	ctx.Response().Header().Set(echo.HeaderContentType, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
	ctx.Response().Header().Set(echo.HeaderContentDisposition, `attachment; filename="laporan_remaja.xlsx"`)
	ctx.Response().WriteHeader(http.StatusOK)

	return f.Write(ctx.Response().Writer)
}
