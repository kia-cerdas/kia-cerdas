package controllers

import (
	"net/http"

	"monitoring-service/app/middlewares"
	"monitoring-service/app/usecases"

	"github.com/labstack/echo/v4"
)

type LaporanLansiaController struct {
	usecase usecases.LaporanLansiaUsecase
}

func NewLaporanLansiaController(usecase usecases.LaporanLansiaUsecase) *LaporanLansiaController {
	return &LaporanLansiaController{usecase}
}

// Preview godoc
// @Summary      Preview data laporan lansia (JSON)
// @Tags         laporan-lansia
// @Security     BearerAuth
// @Produce      json
// @Param        start_date  query  string  false  "Tanggal Pemeriksaan Awal (YYYY-MM-DD)"
// @Param        end_date    query  string  false  "Tanggal Pemeriksaan Akhir (YYYY-MM-DD)"
// @Success      200  {object}  models.Response
// @Failure      500  {object}  models.Response
// @Router       /tenaga-kesehatan/laporan/lansia/preview [get]
func (c *LaporanLansiaController) Preview(ctx echo.Context) error {
	desaID := middlewares.GetDesaID(ctx)
	role := middlewares.GetRole(ctx)
	startDate := ctx.QueryParam("start_date")
	endDate := ctx.QueryParam("end_date")

	data, err := c.usecase.GetLaporanLansia(startDate, endDate, desaID, role)
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
// @Summary      Export laporan data lansia ke file Excel (.xlsx)
// @Tags         laporan-lansia
// @Security     BearerAuth
// @Produce      application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
// @Param        start_date  query  string  false  "Tanggal Pemeriksaan Awal (YYYY-MM-DD)"
// @Param        end_date    query  string  false  "Tanggal Pemeriksaan Akhir (YYYY-MM-DD)"
// @Success      200  {file}    file
// @Failure      500  {object}  models.Response
// @Router       /tenaga-kesehatan/laporan/lansia/export/excel [get]
func (c *LaporanLansiaController) ExportExcel(ctx echo.Context) error {
	desaID := middlewares.GetDesaID(ctx)
	role := middlewares.GetRole(ctx)
	startDate := ctx.QueryParam("start_date")
	endDate := ctx.QueryParam("end_date")

	f, err := c.usecase.ExportExcelLaporanLansia(startDate, endDate, desaID, role)
	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, map[string]interface{}{
			"message": err.Error(),
		})
	}
	defer f.Close()

	ctx.Response().Header().Set(echo.HeaderContentType, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
	ctx.Response().Header().Set(echo.HeaderContentDisposition, `attachment; filename="laporan_lansia.xlsx"`)
	ctx.Response().WriteHeader(http.StatusOK)

	return f.Write(ctx.Response().Writer)
}
