package controllers

import (
	"errors"
	"fmt"
	"monitoring-service/app/helpers"
	"monitoring-service/app/models"
	"monitoring-service/app/usecases"
	"net/http"
	"strconv"

	"github.com/labstack/echo/v4"
	"gorm.io/gorm"
)

type NeonatusController struct {
	usecase usecases.NeonatusUsecase
	db      *gorm.DB
}

func NewPelayananNeonatusController(uc usecases.NeonatusUsecase, db *gorm.DB) *NeonatusController {
	return &NeonatusController{usecase: uc, db: db}
}

// Create
func (c *NeonatusController) CreatePelayananHandler(ctx echo.Context) error {
	var req models.CreatePelayananNeonatusRequest

	if err := ctx.Bind(&req); err != nil {
		return ctx.JSON(http.StatusBadRequest, map[string]string{
			"error": "Invalid request format",
		})
	}

	//  DEBUG (hapus nanti kalau sudah aman)
	fmt.Println("DEBUG REQUEST:", req)

	//  VALIDASI WAJIB (INI KUNCI)
	if req.AnakID == 0 ||
		req.PeriodeID == 0 ||
		req.KategoriUmurID == 0 ||
		req.Tanggal == "" {
		return ctx.JSON(http.StatusBadRequest, map[string]string{
			"error": "field wajib tidak boleh kosong atau 0",
		})
	}

	if len(req.DetailPelayanan) == 0 {
		return ctx.JSON(http.StatusBadRequest, map[string]string{
			"error": "detail_pelayanan wajib diisi",
		})
	}

	if err := c.usecase.Create(req); err != nil {
		return ctx.JSON(http.StatusInternalServerError, map[string]string{
			"error": err.Error(),
		})
	}

	return ctx.JSON(http.StatusOK, map[string]string{
		"message": "Pelayanan kesehatan anak berhasil dibuat",
	})
}

// GetByAnakID
func (c *NeonatusController) GetByAnakID(ctx echo.Context) error {
	anakIDStr := ctx.QueryParam("anak_id")

	if anakIDStr == "" {
		data, err := c.usecase.GetAll()
		if err != nil {
			return ctx.JSON(http.StatusInternalServerError, map[string]string{
				"error": err.Error(),
			})
		}
		return helpers.StandardResponse(ctx, http.StatusOK, "berhasil", data, nil)
	}

	anakID, err := ParseInt(anakIDStr, "anak_id")
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, map[string]string{
			"error": err.Error(),
		})
	}

	data, err := c.usecase.GetByAnakID(anakID)
	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, map[string]string{
			"error": err.Error(),
		})
	}

	return helpers.StandardResponse(ctx, http.StatusOK, "berhasil", data, nil)
}

// // get by id kunjungan
func (c *NeonatusController) GetByID(ctx echo.Context) error {
	id, err := ParseInt(ctx.Param("id"), "id")
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, map[string]string{
			"error": err.Error(),
		})
	}

	data, err := c.usecase.GetByID(id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return ctx.JSON(http.StatusNotFound, map[string]string{
				"error": "Data tidak ditemukan",
			})
		}

		return ctx.JSON(http.StatusInternalServerError, map[string]string{
			"error": err.Error(),
		})
	}

	return ctx.JSON(http.StatusOK, data)
}

// Update
func (c *NeonatusController) Update(ctx echo.Context) error {
	id, err := ParseInt(ctx.Param("id"), "id")

	if err != nil {
		return ctx.JSON(http.StatusBadRequest, map[string]string{
			"error": err.Error(),
		})
	}

	var req models.UpdatePelayananNeonatusRequest
	if err := ctx.Bind(&req); err != nil {
		return ctx.JSON(http.StatusBadRequest, map[string]string{
			"error": "Request tidak valid",
		})
	}

	if err := c.usecase.Update(id, req); err != nil {
		return ctx.JSON(http.StatusInternalServerError, map[string]string{
			"error": err.Error(),
		})
	}

	return ctx.JSON(http.StatusOK, map[string]string{
		"message": "Berhasil update data",
	})
}

func (c *NeonatusController) Delete(ctx echo.Context) error {
	id, err := ParseInt(ctx.Param("id"), "id")

	if err != nil {
		return ctx.JSON(http.StatusBadRequest, map[string]string{
			"error": err.Error(),
		})
	}

	if err := c.usecase.Delete(id); err != nil {
		return ctx.JSON(http.StatusInternalServerError, map[string]string{
			"error": err.Error(),
		})
	}

	return ctx.JSON(http.StatusOK, map[string]string{
		"message": "Berhasil hapus data",
	})
}

// GetPeriodeByKategori - returns periode_kunjungan rows for a kategori_umur_id or kategori_umur name
func (c *NeonatusController) GetPeriodeByKategori(ctx echo.Context) error {
	kategoriIDStr := ctx.QueryParam("kategori_umur_id")
	kategoriNama := ctx.QueryParam("kategori_umur")

	var kategoriID int64

	if kategoriIDStr != "" {
		var err error
		kategoriID, err = strconv.ParseInt(kategoriIDStr, 10, 32)
		if err != nil {
			return ctx.JSON(http.StatusBadRequest, map[string]string{"error": "kategori_umur_id tidak valid"})
		}
	} else if kategoriNama != "" {
		// lookup by nama
		var ku models.KategoriUmur
		if err := c.db.Where("kategori_umur = ?", kategoriNama).First(&ku).Error; err != nil {
			return ctx.JSON(http.StatusNotFound, map[string]string{"error": "kategori tidak ditemukan"})
		}
		kategoriID = int64(ku.ID)
	} else {
		// default: bayi_0_28_hari
		var ku models.KategoriUmur
		if err := c.db.Where("kategori_umur = ?", "bayi_0_28_hari").First(&ku).Error; err == nil {
			kategoriID = int64(ku.ID)
		} else {
			kategoriID = 1
		}
	}

	var periode []models.PeriodeKunjungan
	if err := c.db.Where("kategori_umur_id = ?", kategoriID).Order("urutan asc").Find(&periode).Error; err != nil {
		return ctx.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
	}

	return ctx.JSON(http.StatusOK, map[string]interface{}{
		"kategori_umur_id": kategoriID,
		"data":             periode,
	})
}

// GetByAnakIDForIbu
func (c *NeonatusController) GetByAnakIDForIbu(ctx echo.Context) error {
	anakID, err := ParseInt(ctx.Param("anak_id"), "anak_id")
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, map[string]string{
			"error": err.Error(),
		})
	}

	data, err := c.usecase.GetByAnakID(anakID)
	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, map[string]string{
			"error": err.Error(),
		})
	}

	return ctx.JSON(http.StatusOK, data)
}

func (c *NeonatusController) GetByIDForIbu(ctx echo.Context) error {
	id, err := ParseInt(ctx.Param("id"), "id")
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, map[string]string{
			"error": err.Error(),
		})
	}

	data, err := c.usecase.GetByID(id)
	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, map[string]string{
			"error": err.Error(),
		})
	}

	return ctx.JSON(http.StatusOK, data)
}

