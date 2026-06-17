package controllers

import (
	"net/http"
	"strconv"

	"monitoring-service/app/helpers"
	"monitoring-service/app/models"
	"monitoring-service/app/usecases"

	"github.com/labstack/echo/v4"
)

type GejalaDaruratAnakController struct {
	usecase usecases.GejalaDaruratAnakUsecase
}

func NewGejalaDaruratAnakController(usecase usecases.GejalaDaruratAnakUsecase) *GejalaDaruratAnakController {
	return &GejalaDaruratAnakController{usecase: usecase}
}

// ProsesDeteksi godoc
// @Summary      Kirim data gejala darurat anak
// @Tags         gejala-darurat-anak
// @Security     BearerAuth
// @Accept       json
// @Produce      json
// @Param        body  body      models.DeteksiDaruratRequest  true  "Data deteksi gejala"
// @Success      201   {object}  models.Response
// @Failure      400   {object}  models.Response
// @Router       /gejala-darurat/deteksi [post]
func (c *GejalaDaruratAnakController) ProsesDeteksi(ctx echo.Context) error {
	var req models.DeteksiDaruratRequest
	if err := ctx.Bind(&req); err != nil {
		return helpers.StandardResponse(ctx, http.StatusBadRequest, "request tidak valid: "+err.Error(), nil, nil)
	}

	riwayat, err := c.usecase.ProsesDeteksi(&req)
	if err != nil {
		return helpers.StandardResponse(ctx, http.StatusBadRequest, err.Error(), nil, nil)
	}

	return helpers.StandardResponse(ctx, http.StatusCreated, "berhasil mendeteksi gejala", riwayat, nil)
}

// GetRiwayatAnak godoc
// @Summary      Ambil riwayat deteksi gejala darurat anak
// @Tags         gejala-darurat-anak
// @Security     BearerAuth
// @Produce      json
// @Param        anak_id   path      string  true  "ID Anak"
// @Success      200       {object}  models.Response
// @Failure      400       {object}  models.Response
// @Router       /gejala-darurat/riwayat/{anak_id} [get]
func (c *GejalaDaruratAnakController) GetRiwayatAnak(ctx echo.Context) error {
	anakIDParam := ctx.Param("anak_id")
	anakID, err := strconv.ParseUint(anakIDParam, 10, 32)
	if err != nil {
		return helpers.StandardResponse(ctx, http.StatusBadRequest, "id anak tidak valid", nil, nil)
	}

	riwayat, err := c.usecase.GetRiwayatAnak(uint(anakID))
	if err != nil {
		return helpers.StandardResponse(ctx, http.StatusInternalServerError, err.Error(), nil, nil)
	}

	return helpers.StandardResponse(ctx, http.StatusOK, "berhasil", riwayat, nil)
}
