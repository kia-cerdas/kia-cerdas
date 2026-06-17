package controllers

import (
	"net/http"
	"monitoring-service/app/models"
	"monitoring-service/app/usecases"


	"github.com/labstack/echo/v4"
)

type SyncController struct {
	syncUsecase usecases.SyncUsecase
}

func NewSyncController(u usecases.SyncUsecase) *SyncController {
	return &SyncController{syncUsecase: u}
}

// PERBAIKAN: Ubah ctx *gin.Context menjadi ctx echo.Context, dan return error
func (c *SyncController) HandleBulkPush(ctx echo.Context) error {
	var request models.SyncPushRequest

	// Di Echo, proses parsing JSON menggunakan ctx.Bind
	if err := ctx.Bind(&request); err != nil {
		return ctx.JSON(http.StatusBadRequest, map[string]string{
			"status":  "error",
			"message": "Format request payload tidak valid: " + err.Error(),
		})
	}

	// ctx.Request().Context() adalah cara Echo mengambil context bawaan Go
	err := c.syncUsecase.SyncDataOffline(ctx.Request().Context(), request)
	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, map[string]string{
			"status":  "error",
			"message": "Gagal memproses sinkronisasi data: " + err.Error(),
		})
	}

	// Kembalikan response HTTP 200 OK khas Echo
	return ctx.JSON(http.StatusOK, map[string]string{
		"status":  "success",
		"message": "Seluruh data offline berhasil disinkronisasi ke server.",
	})
}

// PERBAIKAN: Ubah ctx *gin.Context menjadi ctx echo.Context, dan return error
func (c *SyncController) HandleBulkPull(ctx echo.Context) error {
	
	// Panggil usecase untuk ambil data terfilter khusus ibu
	data, err := c.syncUsecase.GetBulkPullData(ctx.Request().Context())
	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, map[string]string{
			"status":  "error",
			"message": "Gagal menarik data dari server: " + err.Error(),
		})
	}

	// Kirim paket data massal kembali ke Flutter
	return ctx.JSON(http.StatusOK, map[string]interface{}{
		"status": "success",
		"data":   data,
	})
}