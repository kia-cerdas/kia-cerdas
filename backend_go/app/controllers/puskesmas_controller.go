package controllers

import (
	"monitoring-service/app/models"
	"net/http"
	"strconv"

	"github.com/labstack/echo/v4"
)

type PuskesmasController struct {
	*Main
}

// GetAll - List semua puskesmas
func (ctrl *PuskesmasController) GetAll(c echo.Context) error {
	var puskesmas []models.Puskesmas

	if err := ctrl.DB().Preload("Kecamatan").Preload("Kecamatan.Kabupaten").Preload("Kecamatan.Kabupaten.Provinsi").Order("id DESC").Find(&puskesmas).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]interface{}{
			"status":  "error",
			"message": "Gagal mengambil data puskesmas",
			"error":   err.Error(),
		})
	}

	return c.JSON(http.StatusOK, map[string]interface{}{
		"status":  "success",
		"message": "Data puskesmas berhasil diambil",
		"data":    puskesmas,
	})
}

// GetByID - Detail puskesmas berdasarkan ID
func (ctrl *PuskesmasController) GetByID(c echo.Context) error {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]interface{}{
			"status":  "error",
			"message": "ID tidak valid",
		})
	}

	var puskesmas models.Puskesmas
	if err := ctrl.DB().Preload("Kecamatan").Preload("Kecamatan.Kabupaten").Preload("Kecamatan.Kabupaten.Provinsi").First(&puskesmas, id).Error; err != nil {
		return c.JSON(http.StatusNotFound, map[string]interface{}{
			"status":  "error",
			"message": "Puskesmas tidak ditemukan",
		})
	}

	return c.JSON(http.StatusOK, map[string]interface{}{
		"status":  "success",
		"message": "Detail puskesmas berhasil diambil",
		"data":    puskesmas,
	})
}

// Create - Tambah puskesmas baru
func (ctrl *PuskesmasController) Create(c echo.Context) error {
	var req struct {
		Nama        string `json:"nama" validate:"required"`
		Alamat      string `json:"alamat"`
		NoTelepon   string `json:"no_telepon"`
		KecamatanID *int32 `json:"kecamatan_id"`
	}

	if err := c.Bind(&req); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]interface{}{
			"status":  "error",
			"message": "Data tidak valid",
			"error":   err.Error(),
		})
	}

	if req.Nama == "" {
		return c.JSON(http.StatusBadRequest, map[string]interface{}{
			"status":  "error",
			"message": "Nama puskesmas wajib diisi",
		})
	}

	puskesmas := models.Puskesmas{
		Nama:        req.Nama,
		Alamat:      req.Alamat,
		NoTelepon:   req.NoTelepon,
		KecamatanID: req.KecamatanID,
	}

	if err := ctrl.DB().Create(&puskesmas).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]interface{}{
			"status":  "error",
			"message": "Gagal menyimpan puskesmas",
			"error":   err.Error(),
		})
	}

	return c.JSON(http.StatusCreated, map[string]interface{}{
		"status":  "success",
		"message": "Puskesmas berhasil ditambahkan",
		"data":    puskesmas,
	})
}

// Update - Update data puskesmas
func (ctrl *PuskesmasController) Update(c echo.Context) error {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]interface{}{
			"status":  "error",
			"message": "ID tidak valid",
		})
	}

	var puskesmas models.Puskesmas
	if err := ctrl.DB().First(&puskesmas, id).Error; err != nil {
		return c.JSON(http.StatusNotFound, map[string]interface{}{
			"status":  "error",
			"message": "Puskesmas tidak ditemukan",
		})
	}

	var req struct {
		Nama        string `json:"nama"`
		Alamat      string `json:"alamat"`
		NoTelepon   string `json:"no_telepon"`
		KecamatanID *int32 `json:"kecamatan_id"`
	}

	if err := c.Bind(&req); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]interface{}{
			"status":  "error",
			"message": "Data tidak valid",
			"error":   err.Error(),
		})
	}

	if req.Nama != "" {
		puskesmas.Nama = req.Nama
	}
	puskesmas.Alamat = req.Alamat
	puskesmas.NoTelepon = req.NoTelepon
	puskesmas.KecamatanID = req.KecamatanID

	if err := ctrl.DB().Save(&puskesmas).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]interface{}{
			"status":  "error",
			"message": "Gagal mengupdate puskesmas",
			"error":   err.Error(),
		})
	}

	return c.JSON(http.StatusOK, map[string]interface{}{
		"status":  "success",
		"message": "Puskesmas berhasil diupdate",
		"data":    puskesmas,
	})
}

// Delete - Hapus puskesmas (soft delete)
func (ctrl *PuskesmasController) Delete(c echo.Context) error {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]interface{}{
			"status":  "error",
			"message": "ID tidak valid",
		})
	}

	var puskesmas models.Puskesmas
	if err := ctrl.DB().First(&puskesmas, id).Error; err != nil {
		return c.JSON(http.StatusNotFound, map[string]interface{}{
			"status":  "error",
			"message": "Puskesmas tidak ditemukan",
		})
	}

	// Cek apakah ada posyandu yang terkait
	var count int64
	ctrl.DB().Model(&models.Posyandu{}).Where("id_puskesmas = ?", id).Count(&count)
	if count > 0 {
		return c.JSON(http.StatusBadRequest, map[string]interface{}{
			"status":  "error",
			"message": "Puskesmas tidak dapat dihapus karena masih memiliki posyandu terkait",
		})
	}

	if err := ctrl.DB().Delete(&puskesmas).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]interface{}{
			"status":  "error",
			"message": "Gagal menghapus puskesmas",
			"error":   err.Error(),
		})
	}

	return c.JSON(http.StatusOK, map[string]interface{}{
		"status":  "success",
		"message": "Puskesmas berhasil dihapus",
	})
}
