package controllers

import (
	"net/http"

	"monitoring-service/app/middlewares"
	"monitoring-service/app/usecases"

	"github.com/labstack/echo/v4"
)

type LaporanBalitaController struct {
	usecase usecases.LaporanBalitaUsecase
}

func NewLaporanBalitaController(usecase usecases.LaporanBalitaUsecase) *LaporanBalitaController {
	return &LaporanBalitaController{usecase}
}

// Preview godoc
// @Summary      Preview data laporan balita (JSON)
// @Tags         laporan-balita
// @Security     BearerAuth
// @Produce      json
// @Param        start_date  query  string  false  "Tanggal Lahir/Ukur Awal (YYYY-MM-DD)"
// @Param        end_date    query  string  false  "Tanggal Lahir/Ukur Akhir (YYYY-MM-DD)"
// @Success      200  {object}  models.Response
// @Failure      500  {object}  models.Response
// @Router       /tenaga-kesehatan/laporan/balita/preview [get]
func (c *LaporanBalitaController) Preview(ctx echo.Context) error {
	posyanduID := middlewares.GetPosyanduID(ctx)
	role := middlewares.GetRole(ctx)
	startDate := ctx.QueryParam("start_date")
	endDate := ctx.QueryParam("end_date")

	data, err := c.usecase.GetLaporanBalita(startDate, endDate, posyanduID, role)
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
// @Summary      Export laporan data balita ke file Excel (.xlsx)
// @Tags         laporan-balita
// @Security     BearerAuth
// @Produce      application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
// @Param        start_date  query  string  false  "Tanggal Lahir/Ukur Awal (YYYY-MM-DD)"
// @Param        end_date    query  string  false  "Tanggal Lahir/Ukur Akhir (YYYY-MM-DD)"
// @Success      200  {file}    file
// @Failure      500  {object}  models.Response
// @Router       /tenaga-kesehatan/laporan/balita/export/excel [get]
func (c *LaporanBalitaController) ExportExcel(ctx echo.Context) error {
	posyanduID := middlewares.GetPosyanduID(ctx)
	role := middlewares.GetRole(ctx)
	startDate := ctx.QueryParam("start_date")
	endDate := ctx.QueryParam("end_date")

	f, err := c.usecase.ExportExcelLaporanBalita(startDate, endDate, posyanduID, role)
	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, map[string]interface{}{
			"message": err.Error(),
		})
	}
	defer f.Close()

	// Stream file to response writer
	ctx.Response().Header().Set(echo.HeaderContentType, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
	ctx.Response().Header().Set(echo.HeaderContentDisposition, `attachment; filename="laporan_balita.xlsx"`)
	ctx.Response().WriteHeader(http.StatusOK)

	return f.Write(ctx.Response().Writer)
}