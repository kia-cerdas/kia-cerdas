package controllers

import (
	"monitoring-service/app/middlewares"
	"monitoring-service/app/models"
	"monitoring-service/app/usecases"
	"net/http"

	"github.com/labstack/echo/v4"
)

type DashboardController struct {
	dashboardUsecase usecases.DashboardUsecase
}

func NewDashboardController(dashboardUsecase usecases.DashboardUsecase) *DashboardController {
	return &DashboardController{dashboardUsecase: dashboardUsecase}
}

func (c *DashboardController) GetJumlahPerKelompokUsia(ctx echo.Context) error {
	desaID := middlewares.GetDesaID(ctx)
	role := middlewares.GetRole(ctx)

	data, err := c.dashboardUsecase.GetJumlahPerKelompokUsia(desaID, role)
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

func (c *DashboardController) GetKesehatanPerKelompok(ctx echo.Context) error {
	desaID := middlewares.GetDesaID(ctx)
	role := middlewares.GetRole(ctx)

	data, err := c.dashboardUsecase.GetKesehatanPerKelompok(desaID, role)
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

func (c *DashboardController) GetCakupanPemeriksaan(ctx echo.Context) error {
	desaID := middlewares.GetDesaID(ctx)
	role := middlewares.GetRole(ctx)

	data, err := c.dashboardUsecase.GetCakupanPemeriksaan(desaID, role)
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