package controllers

import (
	"net/http"
	"strings"
	"time"

	"monitoring-service/app/constants"
	"monitoring-service/app/helpers"
	"monitoring-service/app/models"

	"github.com/labstack/echo/v4"
	"golang.org/x/crypto/bcrypt"
)

type MeFullResponse struct {
	UserID int32  `json:"user_id"`
	Name   string `json:"name"`
	Email  string `json:"email"`
	Role   string `json:"role"`
}

// Me - GET /auth/me
func (m *Main) Me(c echo.Context) error {
	claims, ok := c.Get("auth_claims").(*models.AuthClaims)
	if !ok || claims == nil {
		return helpers.Response(c, http.StatusUnauthorized, []string{"token tidak valid"})
	}

	var user models.User
	if err := m.db.First(&user, claims.UserID).Error; err != nil {
		return helpers.StandardResponse(c, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, MeFullResponse{
			UserID: claims.UserID,
			Email:  claims.Email,
			Role:   claims.Role,
		}, nil)
	}

	return helpers.StandardResponse(c, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, MeFullResponse{
		UserID: user.ID,
		Name:   user.Username,
		Email:  user.Email,
		Role:   claims.Role,
	}, nil)
}

// UpdateMe - PUT /auth/me
func (m *Main) UpdateMe(c echo.Context) error {
	claims, ok := c.Get("auth_claims").(*models.AuthClaims)
	if !ok || claims == nil {
		return helpers.Response(c, http.StatusUnauthorized, []string{"token tidak valid"})
	}

	var req struct {
		Name string `json:"name"`
	}
	if err := c.Bind(&req); err != nil {
		return helpers.Response(c, http.StatusBadRequest, []string{"format request tidak valid"})
	}

	name := strings.TrimSpace(req.Name)
	if name == "" {
		return helpers.Response(c, http.StatusBadRequest, []string{"nama tidak boleh kosong"})
	}

	if err := m.db.Model(&models.User{}).
		Where("id = ?", claims.UserID).
		Updates(map[string]interface{}{
			"nama":       name,
			"updated_at": time.Now(),
		}).Error; err != nil {
		return helpers.Response(c, http.StatusInternalServerError, []string{"gagal memperbarui profil"})
	}

	return helpers.StandardResponse(c, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, MeFullResponse{
		UserID: claims.UserID,
		Name:   name,
		Email:  claims.Email,
		Role:   claims.Role,
	}, nil)
}

// UpdateMePassword - PUT /auth/me/password
func (m *Main) UpdateMePassword(c echo.Context) error {
	claims, ok := c.Get("auth_claims").(*models.AuthClaims)
	if !ok || claims == nil {
		return helpers.Response(c, http.StatusUnauthorized, []string{"token tidak valid"})
	}

	var req struct {
		OldPassword string `json:"old_password"`
		NewPassword string `json:"new_password"`
	}
	if err := c.Bind(&req); err != nil {
		return helpers.Response(c, http.StatusBadRequest, []string{"format request tidak valid"})
	}

	if strings.TrimSpace(req.OldPassword) == "" || strings.TrimSpace(req.NewPassword) == "" {
		return helpers.Response(c, http.StatusBadRequest, []string{"old_password dan new_password wajib diisi"})
	}
	if len(req.NewPassword) < 6 {
		return helpers.Response(c, http.StatusBadRequest, []string{"password baru minimal 6 karakter"})
	}

	var user models.User
	if err := m.db.First(&user, claims.UserID).Error; err != nil {
		return helpers.Response(c, http.StatusNotFound, []string{"user tidak ditemukan"})
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.OldPassword)); err != nil {
		return helpers.Response(c, http.StatusBadRequest, []string{"password lama tidak sesuai"})
	}

	hashed, err := bcrypt.GenerateFromPassword([]byte(req.NewPassword), bcrypt.DefaultCost)
	if err != nil {
		return helpers.Response(c, http.StatusInternalServerError, []string{"gagal memproses password"})
	}

	if err := m.db.Model(&models.User{}).
		Where("id = ?", claims.UserID).
		Updates(map[string]interface{}{
			"kata_sandi": string(hashed),
			"updated_at": time.Now(),
		}).Error; err != nil {
		return helpers.Response(c, http.StatusInternalServerError, []string{"gagal memperbarui password"})
	}

	return helpers.StandardResponse(c, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, map[string]string{
		"message": "password berhasil diperbarui",
	}, nil)
}
