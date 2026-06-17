package controllers

import (
	"monitoring-service/app/models"
	"net/http"
	"strconv"

	"github.com/labstack/echo/v4"
)

type PosyanduController struct {
	*Main
}

// GetAll - List semua posyandu dengan relasi puskesmas
func (ctrl *PosyanduController) GetAll(c echo.Context) error {
	var posyandus []models.Posyandu
	
	query := ctrl.DB().Order("id DESC")
	
	// Filter by puskesmas_id if provided
	if puskesmasID := c.QueryParam("puskesmas_id"); puskesmasID != "" {
		query = query.Where("id_puskesmas = ?", puskesmasID)
	}
	
	if err := query.Find(&posyandus).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]interface{}{
			"status":  "error",
			"message": "Gagal mengambil data posyandu",
			"error":   err.Error(),
		})
	}

	// Preload puskesmas data
	type PosyanduWithPuskesmas struct {
		models.Posyandu
		NamaPuskesmas string `json:"nama_puskesmas,omitempty"`
	}

	var result []PosyanduWithPuskesmas
	for _, p := range posyandus {
		var puskesmas models.Puskesmas
		ctrl.DB().First(&puskesmas, p.IDPuskesmas)
		
		result = append(result, PosyanduWithPuskesmas{
			Posyandu:      p,
			NamaPuskesmas: puskesmas.Nama,
		})
	}

	return c.JSON(http.StatusOK, map[string]interface{}{
		"status":  "success",
		"message": "Data posyandu berhasil diambil",
		"data":    result,
	})
}

// GetByID - Detail posyandu berdasarkan ID
func (ctrl *PosyanduController) GetByID(c echo.Context) error {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]interface{}{
			"status":  "error",
			"message": "ID tidak valid",
		})
	}

	var posyandu models.Posyandu
	if err := ctrl.DB().First(&posyandu, id).Error; err != nil {
		return c.JSON(http.StatusNotFound, map[string]interface{}{
			"status":  "error",
			"message": "Posyandu tidak ditemukan",
		})
	}

	// Get puskesmas data
	var puskesmas models.Puskesmas
	ctrl.DB().First(&puskesmas, posyandu.IDPuskesmas)

	result := struct {
		models.Posyandu
		NamaPuskesmas string `json:"nama_puskesmas"`
	}{
		Posyandu:      posyandu,
		NamaPuskesmas: puskesmas.Nama,
	}

	return c.JSON(http.StatusOK, map[string]interface{}{
		"status":  "success",
		"message": "Detail posyandu berhasil diambil",
		"data":    result,
	})
}

// Create - Tambah posyandu baru
func (ctrl *PosyanduController) Create(c echo.Context) error {
	var req struct {
		IDPuskesmas int32  `json:"id_puskesmas" validate:"required"`
		Nama        string `json:"nama" validate:"required"`
		Alamat      string `json:"alamat"`
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
			"message": "Nama posyandu wajib diisi",
		})
	}

	if req.IDPuskesmas == 0 {
		return c.JSON(http.StatusBadRequest, map[string]interface{}{
			"status":  "error",
			"message": "Puskesmas wajib dipilih",
		})
	}

	// Verify puskesmas exists
	var puskesmas models.Puskesmas
	if err := ctrl.DB().First(&puskesmas, req.IDPuskesmas).Error; err != nil {
		return c.JSON(http.StatusBadRequest, map[string]interface{}{
			"status":  "error",
			"message": "Puskesmas tidak ditemukan",
		})
	}

	posyandu := models.Posyandu{
		IDPuskesmas: req.IDPuskesmas,
		Nama:        req.Nama,
		Alamat:      req.Alamat,
	}

	if err := ctrl.DB().Create(&posyandu).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]interface{}{
			"status":  "error",
			"message": "Gagal menyimpan posyandu",
			"error":   err.Error(),
		})
	}

	return c.JSON(http.StatusCreated, map[string]interface{}{
		"status":  "success",
		"message": "Posyandu berhasil ditambahkan",
		"data":    posyandu,
	})
}

// Update - Update data posyandu
func (ctrl *PosyanduController) Update(c echo.Context) error {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]interface{}{
			"status":  "error",
			"message": "ID tidak valid",
		})
	}

	var posyandu models.Posyandu
	if err := ctrl.DB().First(&posyandu, id).Error; err != nil {
		return c.JSON(http.StatusNotFound, map[string]interface{}{
			"status":  "error",
			"message": "Posyandu tidak ditemukan",
		})
	}

	var req struct {
		IDPuskesmas int32  `json:"id_puskesmas"`
		Nama        string `json:"nama"`
		Alamat      string `json:"alamat"`
	}

	if err := c.Bind(&req); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]interface{}{
			"status":  "error",
			"message": "Data tidak valid",
			"error":   err.Error(),
		})
	}

	if req.IDPuskesmas != 0 {
		// Verify puskesmas exists
		var puskesmas models.Puskesmas
		if err := ctrl.DB().First(&puskesmas, req.IDPuskesmas).Error; err != nil {
			return c.JSON(http.StatusBadRequest, map[string]interface{}{
				"status":  "error",
				"message": "Puskesmas tidak ditemukan",
			})
		}
		posyandu.IDPuskesmas = req.IDPuskesmas
	}

	if req.Nama != "" {
		posyandu.Nama = req.Nama
	}
	posyandu.Alamat = req.Alamat

	if err := ctrl.DB().Save(&posyandu).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]interface{}{
			"status":  "error",
			"message": "Gagal mengupdate posyandu",
			"error":   err.Error(),
		})
	}

	return c.JSON(http.StatusOK, map[string]interface{}{
		"status":  "success",
		"message": "Posyandu berhasil diupdate",
		"data":    posyandu,
	})
}

// Delete - Hapus posyandu (soft delete)
func (ctrl *PosyanduController) Delete(c echo.Context) error {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]interface{}{
			"status":  "error",
			"message": "ID tidak valid",
		})
	}

	var posyandu models.Posyandu
	if err := ctrl.DB().First(&posyandu, id).Error; err != nil {
		return c.JSON(http.StatusNotFound, map[string]interface{}{
			"status":  "error",
			"message": "Posyandu tidak ditemukan",
		})
	}

	if err := ctrl.DB().Delete(&posyandu).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]interface{}{
			"status":  "error",
			"message": "Gagal menghapus posyandu",
			"error":   err.Error(),
		})
	}

	return c.JSON(http.StatusOK, map[string]interface{}{
		"status":  "success",
		"message": "Posyandu berhasil dihapus",
	})
}
