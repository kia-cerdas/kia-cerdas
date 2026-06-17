// app/controllers/detail_kehamilan_ibu_controller.go
// [SCOPE: modul-ibu / profil / riwayat-kehamilan]
// Controller baru — HANYA TAMBAH, tidak mengubah controller lain.
package controllers

import (
	"net/http"
	"strconv"

	"monitoring-service/app/models"
	"monitoring-service/app/usecases"

	"github.com/labstack/echo/v4"
)

type DetailKehamilanIbuController struct {
	usecase usecases.DetailKehamilanIbuUsecase
}

func NewDetailKehamilanIbuController(u usecases.DetailKehamilanIbuUsecase) *DetailKehamilanIbuController {
	return &DetailKehamilanIbuController{usecase: u}
}

// GetDetail godoc
// GET /modul-ibu/kehamilan/:id/detail
// Mengambil detail lengkap satu kehamilan (grafik, skrining, persalinan).
// Hanya bisa diakses oleh ibu pemilik kehamilan tersebut.
func (c *DetailKehamilanIbuController) GetDetail(ctx echo.Context) error {
	claims, ok := ctx.Get("auth_claims").(*models.AuthClaims)
	if !ok || claims == nil {
		return ctx.JSON(http.StatusUnauthorized, map[string]interface{}{
			"message": "Unauthorized",
		})
	}

	idParam := ctx.Param("id")
	kehamilanID, err := strconv.ParseInt(idParam, 10, 32)
	if err != nil || kehamilanID <= 0 {
		return ctx.JSON(http.StatusBadRequest, map[string]interface{}{
			"message": "id kehamilan tidak valid",
		})
	}

	data, err := c.usecase.GetDetail(int32(kehamilanID), claims.UserID)
	if err != nil {
		status := http.StatusInternalServerError
		if err.Error() == "data kehamilan tidak ditemukan" {
			status = http.StatusNotFound
		} else if err.Error() == "akses ditolak: kehamilan bukan milik pengguna ini" {
			status = http.StatusForbidden
		}
		return ctx.JSON(status, map[string]interface{}{
			"message": err.Error(),
		})
	}

	return ctx.JSON(http.StatusOK, map[string]interface{}{
		"message": "Detail kehamilan berhasil diambil",
		"data":    data,
	})
}