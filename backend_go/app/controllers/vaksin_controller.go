package controllers

import (
	"net/http"

	"monitoring-service/app/models"

	"github.com/labstack/echo/v4"
	"gorm.io/gorm"
)

type VaksinController struct {
	db *gorm.DB
}

func NewVaksinController(db *gorm.DB) *VaksinController {
	// Tambahkan log untuk debugging
	if db == nil {
		panic("VaksinController: db cannot be nil")
	}
	return &VaksinController{db: db}
}

func (c *VaksinController) GetAll(ctx echo.Context) error {
	// Safety check - cek apakah db nil
	if c.db == nil {
		return ctx.JSON(http.StatusInternalServerError, echo.Map{
			"error": "Database connection is nil",
		})
	}

	var vaksins []models.Vaksin

	// Ambil semua vaksin yang tidak dihapus
	if err := c.db.Where("deleted_at IS NULL").Find(&vaksins).Error; err != nil {
		return ctx.JSON(http.StatusInternalServerError, echo.Map{
			"error": err.Error(),
		})
	}

	return ctx.JSON(http.StatusOK, echo.Map{
		"data": vaksins,
	})
}

func (c *VaksinController) GetByID(ctx echo.Context) error {
	// Safety check - cek apakah db nil
	if c.db == nil {
		return ctx.JSON(http.StatusInternalServerError, echo.Map{
			"error": "Database connection is nil",
		})
	}

	id := ctx.Param("id")

	var vaksin models.Vaksin
	if err := c.db.Where("id = ? AND deleted_at IS NULL", id).First(&vaksin).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			return ctx.JSON(http.StatusNotFound, echo.Map{
				"error": "Vaksin not found",
			})
		}
		return ctx.JSON(http.StatusInternalServerError, echo.Map{
			"error": err.Error(),
		})
	}

	return ctx.JSON(http.StatusOK, echo.Map{
		"data": vaksin,
	})
}
