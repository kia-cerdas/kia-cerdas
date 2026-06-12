package controllers

import (
	"net/http"
	"strconv"

	"monitoring-service/app/models"
	"monitoring-service/app/usecases"

	"github.com/labstack/echo/v4"
)

type EdukasiPolaAsuhController struct {
	usecase usecases.EdukasiPolaAsuhUsecase
}

func NewEdukasiPolaAsuhController(u usecases.EdukasiPolaAsuhUsecase) *EdukasiPolaAsuhController {
	return &EdukasiPolaAsuhController{u}
}

func (c *EdukasiPolaAsuhController) Create(ctx echo.Context) error {
	var input models.EdukasiPolaAsuh

	if err := ctx.Bind(&input); err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{StatusCode: http.StatusBadRequest, Message: err.Error()})
	}

	if err := c.usecase.Create(&input); err != nil {
		return ctx.JSON(http.StatusInternalServerError, models.Response{StatusCode: http.StatusInternalServerError, Message: err.Error()})
	}

	return ctx.JSON(http.StatusCreated, models.Response{StatusCode: http.StatusCreated, Data: input})
}

func (c *EdukasiPolaAsuhController) GetAll(ctx echo.Context) error {
	rentangUsia := ctx.QueryParam("rentang_usia")
	
	var data interface{}
	var err error
	
	if rentangUsia != "" {
		data, err = c.usecase.GetByRentangUsia(rentangUsia)
	} else {
		data, err = c.usecase.GetAll()
	}
	
	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, models.Response{StatusCode: http.StatusInternalServerError, Message: err.Error()})
	}

	return ctx.JSON(http.StatusOK, models.Response{StatusCode: http.StatusOK, Data: data})
}

func (c *EdukasiPolaAsuhController) GetByID(ctx echo.Context) error {
	id, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{StatusCode: http.StatusBadRequest, Message: "invalid id"})
	}

	data, err := c.usecase.GetByID(int32(id))
	if err != nil {
		return ctx.JSON(http.StatusNotFound, models.Response{StatusCode: http.StatusNotFound, Message: "Data not found"})
	}

	return ctx.JSON(http.StatusOK, models.Response{StatusCode: http.StatusOK, Data: data})
}

func (c *EdukasiPolaAsuhController) Update(ctx echo.Context) error {
	id, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{StatusCode: http.StatusBadRequest, Message: "invalid id"})
	}

	var input models.EdukasiPolaAsuh
	if err := ctx.Bind(&input); err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{StatusCode: http.StatusBadRequest, Message: err.Error()})
	}

	if err := c.usecase.Update(int32(id), &input); err != nil {
		return ctx.JSON(http.StatusNotFound, models.Response{StatusCode: http.StatusNotFound, Message: err.Error()})
	}

	return ctx.JSON(http.StatusOK, models.Response{StatusCode: http.StatusOK, Message: "updated successfully"})
}

func (c *EdukasiPolaAsuhController) Delete(ctx echo.Context) error {
	id, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{StatusCode: http.StatusBadRequest, Message: "invalid id"})
	}

	if err := c.usecase.Delete(int32(id)); err != nil {
		return ctx.JSON(http.StatusInternalServerError, models.Response{StatusCode: http.StatusInternalServerError, Message: err.Error()})
	}

	return ctx.JSON(http.StatusOK, models.Response{StatusCode: http.StatusOK, Message: "deleted successfully"})
}
