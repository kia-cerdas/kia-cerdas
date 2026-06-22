package controllers

import (
	"net/http"
	"strconv"

	"monitoring-service/app/middlewares"
	"monitoring-service/app/models"
	"monitoring-service/app/usecases"

	"github.com/labstack/echo/v4"
)

type LogTTDMMSController struct {
	usecase usecases.LogTTDMMSUsecase
}

func NewLogTTDMMSController(u usecases.LogTTDMMSUsecase) *LogTTDMMSController {
	return &LogTTDMMSController{usecase: u}
}

type saveLogTTDMMSRequest struct {
	BulanKe      int32 `json:"bulan_ke"`
	HariKe       int32 `json:"hari_ke"`
	SudahDiminum bool  `json:"sudah_diminum"`
}

func (c *LogTTDMMSController) GetMine(ctx echo.Context) error {
	claims, ok := ctx.Get("auth_claims").(*models.AuthClaims)
	if !ok || claims == nil {
		return ctx.JSON(http.StatusUnauthorized, models.Response{
			StatusCode: http.StatusUnauthorized,
			Message:    "token tidak valid",
		})
	}

	data, err := c.usecase.GetMine(claims.UserID)
	if err != nil {
		return ctx.JSON(http.StatusNotFound, models.Response{
			StatusCode: http.StatusNotFound,
			Message:    err.Error(),
		})
	}

	return ctx.JSON(http.StatusOK, models.Response{
		StatusCode: http.StatusOK,
		Data:       data,
	})
}

func (c *LogTTDMMSController) SaveMine(ctx echo.Context) error {
	claims, ok := ctx.Get("auth_claims").(*models.AuthClaims)
	if !ok || claims == nil {
		return ctx.JSON(http.StatusUnauthorized, models.Response{
			StatusCode: http.StatusUnauthorized,
			Message:    "token tidak valid",
		})
	}

	var req saveLogTTDMMSRequest
	if err := ctx.Bind(&req); err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{
			StatusCode: http.StatusBadRequest,
			Message:    "format request tidak valid",
		})
	}

	data, err := c.usecase.SaveMine(
		claims.UserID,
		req.BulanKe,
		req.HariKe,
		req.SudahDiminum,
	)
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{
			StatusCode: http.StatusBadRequest,
			Message:    err.Error(),
		})
	}

	return ctx.JSON(http.StatusOK, models.Response{
		StatusCode: http.StatusOK,
		Data:       data,
	})
}



// BAGIAN KADER
 
// GetRekapKader mengembalikan rekap kepatuhan TTD/MMS semua ibu hamil
// di wilayah kader yang sedang login.
// Route: GET /kader/log-ttd-mms/rekap
func (c *LogTTDMMSController) GetRekapKader(ctx echo.Context) error {
	claims, ok := ctx.Get("auth_claims").(*models.AuthClaims)
	if !ok || claims == nil {
		return ctx.JSON(http.StatusUnauthorized, models.Response{
			StatusCode: http.StatusUnauthorized,
			Message:    "token tidak valid",
		})
	}
 
	posyanduID := middlewares.GetPosyanduID(ctx)
	data, err := c.usecase.GetRekapKader(posyanduID)
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
 
// GetDetailLogKader mengembalikan seluruh log TTD/MMS harian milik satu ibu,
// untuk ditampilkan oleh kader (read-only).
// Route: GET /kader/log-ttd-mms/:kehamilan_id
func (c *LogTTDMMSController) GetDetailLogKader(ctx echo.Context) error {
	claims, ok := ctx.Get("auth_claims").(*models.AuthClaims)
	if !ok || claims == nil {
		return ctx.JSON(http.StatusUnauthorized, models.Response{
			StatusCode: http.StatusUnauthorized,
			Message:    "token tidak valid",
		})
	}
 
	kehamilanIDStr := ctx.Param("kehamilan_id")
	kehamilanID, err := strconv.ParseInt(kehamilanIDStr, 10, 32)
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{
			StatusCode: http.StatusBadRequest,
			Message:    "kehamilan_id tidak valid",
		})
	}
 
	posyanduID := middlewares.GetPosyanduID(ctx)
	data, err := c.usecase.GetDetailLogKader(posyanduID, int32(kehamilanID))
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