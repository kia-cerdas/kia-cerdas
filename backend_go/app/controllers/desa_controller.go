package controllers

import (
	"net/http"
	"strconv"

	"monitoring-service/app/constants"
	"monitoring-service/app/helpers"
	"monitoring-service/app/models"
	"monitoring-service/app/usecases"
	"monitoring-service/pkg/customerror"

	"github.com/labstack/echo/v4"
)

type DesaController struct {
	usecase usecases.DesaUsecase
}

func NewDesaController(usecase usecases.DesaUsecase) *DesaController {
	return &DesaController{usecase: usecase}
}

func (c *DesaController) GetAll(ctx echo.Context) error {
	data, err := c.usecase.GetAll()
	if err != nil {
		statusCode := customerror.GetStatusCode(err)
		return helpers.Response(ctx, statusCode, []string{err.Error()})
	}

	return helpers.StandardResponse(ctx, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, data, nil)
}

func (c *DesaController) GetByID(ctx echo.Context) error {
	id64, err := strconv.ParseInt(ctx.Param("id"), 10, 32)
	if err != nil {
		return helpers.Response(ctx, http.StatusBadRequest, []string{"id tidak valid"})
	}

	data, detailErr := c.usecase.GetByID(int32(id64))
	if detailErr != nil {
		statusCode := customerror.GetStatusCode(detailErr)
		return helpers.Response(ctx, statusCode, []string{detailErr.Error()})
	}

	return helpers.StandardResponse(ctx, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, data, nil)
}

func (c *DesaController) Create(ctx echo.Context) error {
	var req models.Desa
	if err := ctx.Bind(&req); err != nil {
		return helpers.Response(ctx, http.StatusBadRequest, []string{"format request tidak valid"})
	}

	if err := c.usecase.Create(&req); err != nil {
		statusCode := customerror.GetStatusCode(err)
		return helpers.Response(ctx, statusCode, []string{err.Error()})
	}

	return helpers.StandardResponse(ctx, http.StatusCreated, []string{constants.SUCCESS_RESPONSE_MESSAGE}, map[string]string{
		"message": "desa berhasil ditambahkan",
	}, nil)
}

func (c *DesaController) Update(ctx echo.Context) error {
	id64, err := strconv.ParseInt(ctx.Param("id"), 10, 32)
	if err != nil {
		return helpers.Response(ctx, http.StatusBadRequest, []string{"id tidak valid"})
	}

	var req models.Desa
	if err := ctx.Bind(&req); err != nil {
		return helpers.Response(ctx, http.StatusBadRequest, []string{"format request tidak valid"})
	}

	if err := c.usecase.Update(int32(id64), &req); err != nil {
		statusCode := customerror.GetStatusCode(err)
		return helpers.Response(ctx, statusCode, []string{err.Error()})
	}

	return helpers.StandardResponse(ctx, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, map[string]string{
		"message": "desa berhasil diperbarui",
	}, nil)
}

func (c *DesaController) Deactivate(ctx echo.Context) error {
	id64, err := strconv.ParseInt(ctx.Param("id"), 10, 32)
	if err != nil {
		return helpers.Response(ctx, http.StatusBadRequest, []string{"id tidak valid"})
	}

	if err := c.usecase.Deactivate(int32(id64)); err != nil {
		statusCode := customerror.GetStatusCode(err)
		return helpers.Response(ctx, statusCode, []string{err.Error()})
	}

	return helpers.StandardResponse(ctx, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, map[string]bool{"deactivated": true}, nil)
}
