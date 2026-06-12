package controllers

import (
	"net/http"

	"monitoring-service/app/middlewares"
	"monitoring-service/app/usecases"

	"github.com/labstack/echo/v4"
)

type LaporanAnakController struct {
	usecase usecases.LaporanAnakUsecase
}

func NewLaporanAnakController(usecase usecases.LaporanAnakUsecase) *LaporanAnakController {
	return &LaporanAnakController{usecase}
}

// Preview godoc
// @Summary      Preview data laporan anak (JSON)
// @Tags         laporan-anak
// @Security     BearerAuth
// @Produce      json
// @Param        start_date  query  string  false  "Tanggal Lahir/Ukur Awal (YYYY-MM-DD)"
// @Param        end_date    query  string  false  "Tanggal Lahir/Ukur Akhir (YYYY-MM-DD)"
// @Success      200  {object}  models.Response
// @Failure      500  {object}  models.Response
// @Router       /tenaga-kesehatan/laporan/anak/preview [get]
func (c *LaporanAnakController) Preview(ctx echo.Context) error {
	desaID := middlewares.GetDesaID(ctx)
	role := middlewares.GetRole(ctx)
	startDate := ctx.QueryParam("start_date")
	endDate := ctx.QueryParam("end_date")

	data, err := c.usecase.GetLaporanAnak(startDate, endDate, desaID, role)
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
// @Summary      Export laporan data anak ke file Excel (.xlsx)
// @Tags         laporan-anak
// @Security     BearerAuth
// @Produce      application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
// @Param        start_date  query  string  false  "Tanggal Lahir/Ukur Awal (YYYY-MM-DD)"
// @Param        end_date    query  string  false  "Tanggal Lahir/Ukur Akhir (YYYY-MM-DD)"
// @Success      200  {file}    file
// @Failure      500  {object}  models.Response
// @Router       /tenaga-kesehatan/laporan/anak/export/excel [get]
func (c *LaporanAnakController) ExportExcel(ctx echo.Context) error {
	desaID := middlewares.GetDesaID(ctx)
	role := middlewares.GetRole(ctx)
	startDate := ctx.QueryParam("start_date")
	endDate := ctx.QueryParam("end_date")

	f, err := c.usecase.ExportExcelLaporanAnak(startDate, endDate, desaID, role)
	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, map[string]interface{}{
			"message": err.Error(),
		})
	}
	defer f.Close()

	// Stream file to response writer
	ctx.Response().Header().Set(echo.HeaderContentType, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
	ctx.Response().Header().Set(echo.HeaderContentDisposition, `attachment; filename="laporan_anak.xlsx"`)
	ctx.Response().WriteHeader(http.StatusOK)

	return f.Write(ctx.Response().Writer)
}
