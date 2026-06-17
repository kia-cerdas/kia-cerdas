package controllers

import (
	"net/http"
	"strconv"

	"monitoring-service/app/constants"
	"monitoring-service/app/helpers"
	"monitoring-service/app/usecases"
	"monitoring-service/pkg/customerror"

	"github.com/labstack/echo/v4"
)

func (m *Main) ListUsers(c echo.Context) error {
	search := c.QueryParam("search")
	role := c.QueryParam("role")
	desa := c.QueryParam("desa")

	data, err := m.usecases.SuperadminUser.ListUsers(search, role, desa)
	if err != nil {
		return helpers.Response(c, customerror.GetStatusCode(err), []string{err.Error()})
	}

	return helpers.StandardResponse(c, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, data, nil)
}

func (m *Main) ListPenduduk(c echo.Context) error {
	search := c.QueryParam("search")

	data, err := m.usecases.SuperadminUser.ListPenduduk(search)
	if err != nil {
		return helpers.Response(c, customerror.GetStatusCode(err), []string{err.Error()})
	}

	return helpers.StandardResponse(c, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, data, nil)
}

func (m *Main) GetUser(c echo.Context) error {
	idRaw, err := strconv.ParseInt(c.Param("id"), 10, 32)
	if err != nil {
		return helpers.Response(c, http.StatusBadRequest, []string{"id user tidak valid"})
	}

	data, getErr := m.usecases.SuperadminUser.GetUser(int32(idRaw))
	if getErr != nil {
		return helpers.Response(c, customerror.GetStatusCode(getErr), []string{getErr.Error()})
	}

	return helpers.StandardResponse(c, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, data, nil)
}

func (m *Main) CreateBidanUser(c echo.Context) error {
	var req usecases.SuperadminCreateBidanUserRequest
	if err := c.Bind(&req); err != nil {
		return helpers.Response(c, http.StatusBadRequest, []string{"format request tidak valid"})
	}

	data, createErr := m.usecases.SuperadminUser.CreateBidanUser(&req)
	if createErr != nil {
		return helpers.Response(c, customerror.GetStatusCode(createErr), []string{createErr.Error()})
	}

	return helpers.StandardResponse(c, http.StatusCreated, []string{constants.SUCCESS_RESPONSE_MESSAGE}, data, nil)
}

func (m *Main) CreateAdminDesaUser(c echo.Context) error {
	var req usecases.SuperadminCreateAdminDesaUserRequest
	if err := c.Bind(&req); err != nil {
		return helpers.Response(c, http.StatusBadRequest, []string{"format request tidak valid"})
	}

	data, createErr := m.usecases.SuperadminUser.CreateAdminDesaUser(&req)
	if createErr != nil {
		return helpers.Response(c, customerror.GetStatusCode(createErr), []string{createErr.Error()})
	}

	return helpers.StandardResponse(c, http.StatusCreated, []string{constants.SUCCESS_RESPONSE_MESSAGE}, data, nil)
}

func (m *Main) CreateKaderUser(c echo.Context) error {
	var req usecases.SuperadminCreateKaderUserRequest
	if err := c.Bind(&req); err != nil {
		return helpers.Response(c, http.StatusBadRequest, []string{"format request tidak valid"})
	}

	data, createErr := m.usecases.SuperadminUser.CreateKaderUser(&req)
	if createErr != nil {
		return helpers.Response(c, customerror.GetStatusCode(createErr), []string{createErr.Error()})
	}

	return helpers.StandardResponse(c, http.StatusCreated, []string{constants.SUCCESS_RESPONSE_MESSAGE}, data, nil)
}

func (m *Main) CreateUser(c echo.Context) error {
	var req usecases.SuperadminCreateUserRequest
	if err := c.Bind(&req); err != nil {
		return helpers.Response(c, http.StatusBadRequest, []string{"format request tidak valid"})
	}

	data, createErr := m.usecases.SuperadminUser.CreateUser(&req)
	if createErr != nil {
		return helpers.Response(c, customerror.GetStatusCode(createErr), []string{createErr.Error()})
	}

	return helpers.StandardResponse(c, http.StatusCreated, []string{constants.SUCCESS_RESPONSE_MESSAGE}, data, nil)
}

func (m *Main) ResetPassword(c echo.Context) error {
	idRaw, err := strconv.ParseInt(c.Param("id"), 10, 32)
	if err != nil {
		return helpers.Response(c, http.StatusBadRequest, []string{"id user tidak valid"})
	}

	var req usecases.SuperadminResetPasswordRequest
	if err := c.Bind(&req); err != nil {
		return helpers.Response(c, http.StatusBadRequest, []string{"format request tidak valid"})
	}

	data, resetErr := m.usecases.SuperadminUser.ResetPassword(int32(idRaw), &req)
	if resetErr != nil {
		return helpers.Response(c, customerror.GetStatusCode(resetErr), []string{resetErr.Error()})
	}

	return helpers.StandardResponse(c, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, data, nil)
}

func (m *Main) UpdateUserRole(c echo.Context) error {
	idRaw, err := strconv.ParseInt(c.Param("id"), 10, 32)
	if err != nil {
		return helpers.Response(c, http.StatusBadRequest, []string{"id user tidak valid"})
	}

	var req usecases.SuperadminUpdateUserRoleRequest
	if err := c.Bind(&req); err != nil {
		return helpers.Response(c, http.StatusBadRequest, []string{"format request tidak valid"})
	}

	data, updateErr := m.usecases.SuperadminUser.UpdateUserRole(int32(idRaw), &req)
	if updateErr != nil {
		return helpers.Response(c, customerror.GetStatusCode(updateErr), []string{updateErr.Error()})
	}

	return helpers.StandardResponse(c, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, data, nil)
}

func (m *Main) DeactivateUser(c echo.Context) error {
	idRaw, err := strconv.ParseInt(c.Param("id"), 10, 32)
	if err != nil {
		return helpers.Response(c, http.StatusBadRequest, []string{"id user tidak valid"})
	}

	data, deactivateErr := m.usecases.SuperadminUser.DeactivateUser(int32(idRaw))
	if deactivateErr != nil {
		return helpers.Response(c, customerror.GetStatusCode(deactivateErr), []string{deactivateErr.Error()})
	}

	return helpers.StandardResponse(c, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, data, nil)
}

func (m *Main) SuperadminListPosyandu(c echo.Context) error {
	search := c.QueryParam("search")

	// Superadmin can see all posyandu (no desa filter)
	data, err := m.usecases.AdminTenagaKesehatan.ListPosyandu(search, nil)
	if err != nil {
		return helpers.Response(c, customerror.GetStatusCode(err), []string{err.Error()})
	}

	return helpers.StandardResponse(c, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, data, nil)
}

func (m *Main) ActivateUser(c echo.Context) error {
	idRaw, err := strconv.ParseInt(c.Param("id"), 10, 32)
	if err != nil {
		return helpers.Response(c, http.StatusBadRequest, []string{"id user tidak valid"})
	}

	data, activateErr := m.usecases.SuperadminUser.ActivateUser(int32(idRaw))
	if activateErr != nil {
		return helpers.Response(c, customerror.GetStatusCode(activateErr), []string{activateErr.Error()})
	}

	return helpers.StandardResponse(c, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, data, nil)
}
func (m *Main) CreateIbuUser(c echo.Context) error {
	var req usecases.SuperadminCreateUserRequest
	if err := c.Bind(&req); err != nil {
		return helpers.Response(c, http.StatusBadRequest, []string{"format request tidak valid: " + err.Error()})
	}
	
	// Panggil usecase CreateIbuUser (role akan dipaksa menjadi "IBU" di dalam usecase)
	data, createErr := m.usecases.SuperadminUser.CreateIbuUser(&req)
	if createErr != nil {
		return helpers.Response(c, customerror.GetStatusCode(createErr), []string{createErr.Error()})
	}
	
	return helpers.StandardResponse(c, http.StatusCreated, []string{"Akun Ibu berhasil dibuat"}, data, nil)
}