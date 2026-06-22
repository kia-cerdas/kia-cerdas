package controllers

import (
	"net/http"
	"strconv"
	"strings"

	"monitoring-service/app/constants"
	"monitoring-service/app/helpers"
	"monitoring-service/app/models"
	"monitoring-service/app/usecases"
	"monitoring-service/pkg/customerror"

	"github.com/labstack/echo/v4"
)

type WilayahController struct {
	usecase usecases.WilayahUsecase
}

func NewWilayahController(usecase usecases.WilayahUsecase) *WilayahController {
	return &WilayahController{usecase: usecase}
}

// parseOptionalInt32 mengembalikan pointer int32 dari query param, atau nil bila kosong/invalid.
func parseOptionalInt32(value string) *int32 {
	value = strings.TrimSpace(value)
	if value == "" {
		return nil
	}
	parsed, err := strconv.ParseInt(value, 10, 32)
	if err != nil {
		return nil
	}
	v := int32(parsed)
	return &v
}

// ===================== PROVINSI =====================

func (c *WilayahController) ListProvinsi(ctx echo.Context) error {
	data, err := c.usecase.ListProvinsi()
	if err != nil {
		return helpers.Response(ctx, customerror.GetStatusCode(err), []string{err.Error()})
	}
	return helpers.StandardResponse(ctx, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, data, nil)
}

func (c *WilayahController) CreateProvinsi(ctx echo.Context) error {
	var req models.Provinsi
	if err := ctx.Bind(&req); err != nil {
		return helpers.Response(ctx, http.StatusBadRequest, []string{"format request tidak valid"})
	}
	if err := c.usecase.CreateProvinsi(&req); err != nil {
		return helpers.Response(ctx, customerror.GetStatusCode(err), []string{err.Error()})
	}
	return helpers.StandardResponse(ctx, http.StatusCreated, []string{constants.SUCCESS_RESPONSE_MESSAGE}, req, nil)
}

func (c *WilayahController) UpdateProvinsi(ctx echo.Context) error {
	id, err := parseIDParam(ctx)
	if err != nil {
		return helpers.Response(ctx, http.StatusBadRequest, []string{"id tidak valid"})
	}
	var req models.Provinsi
	if err := ctx.Bind(&req); err != nil {
		return helpers.Response(ctx, http.StatusBadRequest, []string{"format request tidak valid"})
	}
	if err := c.usecase.UpdateProvinsi(id, &req); err != nil {
		return helpers.Response(ctx, customerror.GetStatusCode(err), []string{err.Error()})
	}
	return helpers.StandardResponse(ctx, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, map[string]string{"message": "provinsi berhasil diperbarui"}, nil)
}

func (c *WilayahController) DeleteProvinsi(ctx echo.Context) error {
	id, err := parseIDParam(ctx)
	if err != nil {
		return helpers.Response(ctx, http.StatusBadRequest, []string{"id tidak valid"})
	}
	if err := c.usecase.DeleteProvinsi(id); err != nil {
		return helpers.Response(ctx, customerror.GetStatusCode(err), []string{err.Error()})
	}
	return helpers.StandardResponse(ctx, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, map[string]bool{"deleted": true}, nil)
}

// ===================== KABUPATEN =====================

func (c *WilayahController) ListKabupaten(ctx echo.Context) error {
	provinsiID := parseOptionalInt32(ctx.QueryParam("provinsi_id"))
	data, err := c.usecase.ListKabupaten(provinsiID)
	if err != nil {
		return helpers.Response(ctx, customerror.GetStatusCode(err), []string{err.Error()})
	}
	return helpers.StandardResponse(ctx, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, data, nil)
}

func (c *WilayahController) CreateKabupaten(ctx echo.Context) error {
	var req models.Kabupaten
	if err := ctx.Bind(&req); err != nil {
		return helpers.Response(ctx, http.StatusBadRequest, []string{"format request tidak valid"})
	}
	if err := c.usecase.CreateKabupaten(&req); err != nil {
		return helpers.Response(ctx, customerror.GetStatusCode(err), []string{err.Error()})
	}
	return helpers.StandardResponse(ctx, http.StatusCreated, []string{constants.SUCCESS_RESPONSE_MESSAGE}, req, nil)
}

func (c *WilayahController) UpdateKabupaten(ctx echo.Context) error {
	id, err := parseIDParam(ctx)
	if err != nil {
		return helpers.Response(ctx, http.StatusBadRequest, []string{"id tidak valid"})
	}
	var req models.Kabupaten
	if err := ctx.Bind(&req); err != nil {
		return helpers.Response(ctx, http.StatusBadRequest, []string{"format request tidak valid"})
	}
	if err := c.usecase.UpdateKabupaten(id, &req); err != nil {
		return helpers.Response(ctx, customerror.GetStatusCode(err), []string{err.Error()})
	}
	return helpers.StandardResponse(ctx, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, map[string]string{"message": "kabupaten berhasil diperbarui"}, nil)
}

func (c *WilayahController) DeleteKabupaten(ctx echo.Context) error {
	id, err := parseIDParam(ctx)
	if err != nil {
		return helpers.Response(ctx, http.StatusBadRequest, []string{"id tidak valid"})
	}
	if err := c.usecase.DeleteKabupaten(id); err != nil {
		return helpers.Response(ctx, customerror.GetStatusCode(err), []string{err.Error()})
	}
	return helpers.StandardResponse(ctx, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, map[string]bool{"deleted": true}, nil)
}

// ===================== KECAMATAN =====================

func (c *WilayahController) ListKecamatan(ctx echo.Context) error {
	kabupatenID := parseOptionalInt32(ctx.QueryParam("kabupaten_id"))
	data, err := c.usecase.ListKecamatan(kabupatenID)
	if err != nil {
		return helpers.Response(ctx, customerror.GetStatusCode(err), []string{err.Error()})
	}
	return helpers.StandardResponse(ctx, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, data, nil)
}

func (c *WilayahController) CreateKecamatan(ctx echo.Context) error {
	var req models.Kecamatan
	if err := ctx.Bind(&req); err != nil {
		return helpers.Response(ctx, http.StatusBadRequest, []string{"format request tidak valid"})
	}
	if err := c.usecase.CreateKecamatan(&req); err != nil {
		return helpers.Response(ctx, customerror.GetStatusCode(err), []string{err.Error()})
	}
	return helpers.StandardResponse(ctx, http.StatusCreated, []string{constants.SUCCESS_RESPONSE_MESSAGE}, req, nil)
}

func (c *WilayahController) UpdateKecamatan(ctx echo.Context) error {
	id, err := parseIDParam(ctx)
	if err != nil {
		return helpers.Response(ctx, http.StatusBadRequest, []string{"id tidak valid"})
	}
	var req models.Kecamatan
	if err := ctx.Bind(&req); err != nil {
		return helpers.Response(ctx, http.StatusBadRequest, []string{"format request tidak valid"})
	}
	if err := c.usecase.UpdateKecamatan(id, &req); err != nil {
		return helpers.Response(ctx, customerror.GetStatusCode(err), []string{err.Error()})
	}
	return helpers.StandardResponse(ctx, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, map[string]string{"message": "kecamatan berhasil diperbarui"}, nil)
}

func (c *WilayahController) DeleteKecamatan(ctx echo.Context) error {
	id, err := parseIDParam(ctx)
	if err != nil {
		return helpers.Response(ctx, http.StatusBadRequest, []string{"id tidak valid"})
	}
	if err := c.usecase.DeleteKecamatan(id); err != nil {
		return helpers.Response(ctx, customerror.GetStatusCode(err), []string{err.Error()})
	}
	return helpers.StandardResponse(ctx, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, map[string]bool{"deleted": true}, nil)
}

// parseIDParam membaca param :id sebagai int32.
func parseIDParam(ctx echo.Context) (int32, error) {
	id64, err := strconv.ParseInt(ctx.Param("id"), 10, 32)
	if err != nil {
		return 0, err
	}
	return int32(id64), nil
}
