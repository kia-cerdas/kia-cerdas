package controllers

import (
	"net/http"

	"monitoring-service/app/models"

	"github.com/labstack/echo/v4"
	"gorm.io/gorm"
)

type DosisVaksinController struct {
	db *gorm.DB
}

func NewDosisVaksinController(db *gorm.DB) *DosisVaksinController {
	if db == nil {
		panic("DosisVaksinController: db cannot be nil")
	}
	return &DosisVaksinController{db: db}
}

func (c *DosisVaksinController) GetAll(ctx echo.Context) error {
	var dosisVaksins []models.DosisVaksin

	// Ambil semua dosis vaksin beserta relasi vaksinnya
	if err := c.db.Preload("Vaksin").Where("deleted_at IS NULL").Find(&dosisVaksins).Error; err != nil {
		return ctx.JSON(http.StatusInternalServerError, echo.Map{
			"error": err.Error(),
		})
	}

	return ctx.JSON(http.StatusOK, echo.Map{
		"data": dosisVaksins,
	})
}

func (c *DosisVaksinController) GetByVaksinID(ctx echo.Context) error {
	vaksinID := ctx.Param("vaksin_id")

	var dosisVaksins []models.DosisVaksin
	if err := c.db.Preload("Vaksin").
		Where("id_vaksin = ? AND deleted_at IS NULL", vaksinID).
		Find(&dosisVaksins).Error; err != nil {
		return ctx.JSON(http.StatusInternalServerError, echo.Map{
			"error": err.Error(),
		})
	}

	return ctx.JSON(http.StatusOK, echo.Map{
		"data": dosisVaksins,
	})
}
