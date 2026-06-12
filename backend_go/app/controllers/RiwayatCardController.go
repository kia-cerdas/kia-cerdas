// controllers/riwayat_card_controller.go
package controllers

import (
	"monitoring-service/app/usecases"
	"net/http"
	"strconv"

	"github.com/labstack/echo/v4"
)

type RiwayatCardController struct {
	usecase usecases.RiwayatCardUsecase
}

func NewRiwayatCardController(uc usecases.RiwayatCardUsecase) *RiwayatCardController {
	return &RiwayatCardController{usecase: uc}
}
// GetRiwayatCard handles GET /tenaga-kesehatan/penduduk/:id/riwayat-card
func (ctrl *RiwayatCardController) GetRiwayatCard(c echo.Context) error {
    idParam := c.Param("id")
    pendudukID, err := strconv.ParseInt(idParam, 10, 32)
    if err != nil {
        return c.JSON(http.StatusBadRequest, map[string]string{"error": "ID tidak valid"})
    }

    result, err := ctrl.usecase.GetRiwayatCard(c.Request().Context(), int32(pendudukID))
    if err != nil {
        return c.JSON(http.StatusNotFound, map[string]string{"error": err.Error()})
    }

    return c.JSON(http.StatusOK, map[string]interface{}{
        "status_code": http.StatusOK,
        "data":        result,
    })
}