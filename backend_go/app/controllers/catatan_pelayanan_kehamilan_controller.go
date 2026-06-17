package controllers

import (
	"net/http"
	"strconv"

	"monitoring-service/app/models"
	"monitoring-service/app/usecases"

	"github.com/labstack/echo/v4"
)

type CatatanPelayananKehamilanController struct {
	usecase usecases.CatatanPelayananKehamilanUsecase
}

func NewCatatanPelayananKehamilanController(u usecases.CatatanPelayananKehamilanUsecase) *CatatanPelayananKehamilanController {
	return &CatatanPelayananKehamilanController{usecase: u}
}

// GetMine → GET /modul-ibu/catatan-pelayanan-kehamilan/me
// Query param opsional: ?trimester=1 (1/2/3). Kosong = semua trimester.
func (c *CatatanPelayananKehamilanController) GetMine(ctx echo.Context) error {
	claims, ok := ctx.Get("auth_claims").(*models.AuthClaims)
	if !ok || claims == nil {
		return ctx.JSON(http.StatusUnauthorized, models.Response{
			StatusCode: http.StatusUnauthorized,
			Message:    "Unauthorized",
		})
	}

	var trimester int8
	if t := ctx.QueryParam("trimester"); t != "" {
		parsed, err := strconv.ParseInt(t, 10, 8)
		if err != nil || parsed < 1 || parsed > 3 {
			return ctx.JSON(http.StatusBadRequest, models.Response{
				StatusCode: http.StatusBadRequest,
				Message:    "trimester harus bernilai 1, 2, atau 3",
			})
		}
		trimester = int8(parsed)
	}

	data, err := c.usecase.GetMine(ctx.Request().Context(), claims.UserID, trimester)
	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, models.Response{
			StatusCode: http.StatusInternalServerError,
			Message:    err.Error(),
		})
	}

	return ctx.JSON(http.StatusOK, models.Response{StatusCode: http.StatusOK, Data: data})
}
