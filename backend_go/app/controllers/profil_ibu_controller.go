// controllers/profil_ibu_controller.go
// Tambahkan file ini di folder: app/controllers/
package controllers

import (
	"net/http"

	"monitoring-service/app/models"
	"monitoring-service/app/usecases"

	"github.com/labstack/echo/v4"
)

type ProfilIbuController struct {
	usecase usecases.ProfilIbuUsecase
}

func NewProfilIbuController(u usecases.ProfilIbuUsecase) *ProfilIbuController {
	return &ProfilIbuController{usecase: u}
}

// GetProfilSaya godoc
// @Summary Ambil profil ibu yang sedang login
// @Tags Modul Ibu
// @Security BearerAuth
// @Success 200 {object} models.Response
// @Router /modul-ibu/profil [get]
func (c *ProfilIbuController) GetProfilSaya(ctx echo.Context) error {
	claims, ok := ctx.Get("auth_claims").(*models.AuthClaims)
	if !ok || claims == nil {
		return ctx.JSON(http.StatusUnauthorized, models.Response{
			StatusCode: http.StatusUnauthorized,
			Message:    "Unauthorized",
		})
	}

	data, err := c.usecase.GetProfilSaya(claims.UserID)
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