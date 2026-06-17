package controllers

import (
	"monitoring-service/app/models"
	"monitoring-service/app/usecases"
	"net/http"

	"github.com/labstack/echo/v4"
)

type PuskesmasDashboardController struct {
	usecase usecases.PuskesmasDashboardUsecase
}

func NewPuskesmasDashboardController(usecase usecases.PuskesmasDashboardUsecase) *PuskesmasDashboardController {
	return &PuskesmasDashboardController{usecase: usecase}
}

// GetDashboard returns the full puskesmas dashboard data (multi-desa recap)
func (c *PuskesmasDashboardController) GetDashboard(ctx echo.Context) error {
	data, err := c.usecase.GetDashboardData()
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
