package controllers

import (
	"monitoring-service/app/middlewares"
	"monitoring-service/app/usecases"
	"net/http"

	"github.com/labstack/echo/v4"
)

type PendudukRiskController struct {
	usecase usecases.PendudukRiskUsecase
}

func NewPendudukRiskController(uc usecases.PendudukRiskUsecase) *PendudukRiskController {
	return &PendudukRiskController{usecase: uc}
}

// GetPendudukByRisk handles GET /api/penduduk/risk
// Parameter yang digunakan: kelompok (anak, remaja, dewasa, lansia) dan risiko (Tinggi, Sedang, Normal)
func (ctrl *PendudukRiskController) GetPendudukByRisk(c echo.Context) error {
    // Terima parameter 'kelompok' (primary) atau 'kategori' (fallback)
    kelompok := c.QueryParam("kelompok")
    if kelompok == "" {
        kelompok = c.QueryParam("kategori")
    }
    risiko := c.QueryParam("risiko")
    desaID := middlewares.GetDesaID(c)
    role := middlewares.GetRole(c)

    if kelompok == "" {
        return c.JSON(http.StatusBadRequest, map[string]string{
            "error": "Parameter 'kelompok' (atau 'kategori') wajib diisi (anak, remaja, dewasa, lansia)",
        })
    }

    result, err := ctrl.usecase.GetPendudukByRisk(kelompok, risiko, desaID, role)
    if err != nil {
        return c.JSON(http.StatusInternalServerError, map[string]string{
            "error": err.Error(),
        })
    }
    return c.JSON(http.StatusOK, result)
}