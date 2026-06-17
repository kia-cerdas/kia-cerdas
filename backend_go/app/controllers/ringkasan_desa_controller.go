package controllers

import (
	"net/http"

	"monitoring-service/app/constants"
	"monitoring-service/app/helpers"
	"monitoring-service/app/middlewares"
	"monitoring-service/app/usecases"

	"github.com/labstack/echo/v4"
)

type RingkasanDesaController struct {
	usecase usecases.RingkasanDesaUsecase
}

func NewRingkasanDesaController(usecase usecases.RingkasanDesaUsecase) *RingkasanDesaController {
	return &RingkasanDesaController{usecase: usecase}
}

// GetRingkasanDesaKader mengembalikan ringkasan dinamis desa binaan kader yang sedang login
// (jumlah ibu hamil per trimester, jumlah anak, dan jumlah kunjungan yang perlu ditindak lanjuti).
func (c *RingkasanDesaController) GetRingkasanDesaKader(ctx echo.Context) error {
	desaID := middlewares.GetDesaID(ctx)
	role := middlewares.GetRole(ctx)

	data, err := c.usecase.GetRingkasanDesaKader(desaID, role)
	if err != nil {
		return helpers.Response(ctx, http.StatusInternalServerError, []string{err.Error()})
	}

	return helpers.StandardResponse(
		ctx,
		http.StatusOK,
		[]string{constants.SUCCESS_RESPONSE_MESSAGE},
		data,
		nil,
	)
}
