package controllers

import (
	"monitoring-service/app/helpers"
	"monitoring-service/app/models"
	"net/http"
	"strconv"

	"github.com/labstack/echo/v4"
)

type PosyanduController struct {
	*Main
}

// GetAll - List semua posyandu dengan relasi puskesmas
// Filtered by desa_id for bidan_desa/kader, all for admin/puskesmas
func (ctrl *PosyanduController) GetAll(c echo.Context) error {
	var posyandus []models.Posyandu
	
	query := ctrl.DB().Order("id DESC")
	
	// Filter by puskesmas_id if provided
	if puskesmasID := c.QueryParam("puskesmas_id"); puskesmasID != "" {
		query = query.Where("id_puskesmas = ?", puskesmasID)
	}
	
	// ✅ FILTER BY DESA (Role-based)
	desaID, err := helpers.GetUserDesaID(c, ctrl.DB())
	if err != nil {
		// Return error with proper message instead of generic unauthorized
		return c.JSON(http.StatusForbidden, map[string]interface{}{
			"status":  "error",
			"message": err.Error(),
		})
	}
	
	// If desaID is not nil, apply filter (user can only see their desa)
	if desaID != nil {
		query = query.Where("desa_id = ?", *desaID)
	}
	// If desaID is nil, user can see all desa (admin/puskesmas role)
	
	if err := query.Find(&posyandus).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]interface{}{
			"status":  "error",
			"message": "Gagal mengambil data posyandu",
			"error":   err.Error(),
		})
	}

	// Preload puskesmas and desa data
	type PosyanduWithRelations struct {
		models.Posyandu
		NamaPuskesmas string `json:"nama_puskesmas,omitempty"`
		NamaDesa      string `json:"nama_desa,omitempty"`
	}

	// Initialize with empty slice to ensure JSON returns [] instead of null
	result := make([]PosyanduWithRelations, 0)
	for _, p := range posyandus {
		var puskesmas models.Puskesmas
		ctrl.DB().First(&puskesmas, p.IDPuskesmas)
		
		var desa models.Desa
		var namaDesa string
		if p.DesaID != nil {
			if err := ctrl.DB().First(&desa, *p.DesaID).Error; err == nil {
				namaDesa = desa.NamaDesa
			}
		}
		
		result = append(result, PosyanduWithRelations{
			Posyandu:      p,
			NamaPuskesmas: puskesmas.Nama,
			NamaDesa:      namaDesa,
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

	// Get puskesmas and desa data
	var puskesmas models.Puskesmas
	ctrl.DB().First(&puskesmas, posyandu.IDPuskesmas)

	var desa models.Desa
	var namaDesa string
	if posyandu.DesaID != nil {
		if err := ctrl.DB().First(&desa, *posyandu.DesaID).Error; err == nil {
			namaDesa = desa.NamaDesa
		}
	}

	result := struct {
		models.Posyandu
		NamaPuskesmas string `json:"nama_puskesmas"`
		NamaDesa      string `json:"nama_desa,omitempty"`
	}{
		Posyandu:      posyandu,
		NamaPuskesmas: puskesmas.Nama,
		NamaDesa:      namaDesa,
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
		DesaID      *int32 `json:"desa_id"`
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

	// Verify desa exists if provided
	if req.DesaID != nil {
		var desa models.Desa
		if err := ctrl.DB().First(&desa, *req.DesaID).Error; err != nil {
			return c.JSON(http.StatusBadRequest, map[string]interface{}{
				"status":  "error",
				"message": "Desa tidak ditemukan",
			})
		}
	}

	posyandu := models.Posyandu{
		IDPuskesmas: req.IDPuskesmas,
		DesaID:      req.DesaID,
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
		IDPuskesmas *int32 `json:"id_puskesmas"`
		DesaID      *int32 `json:"desa_id"`
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

	if req.IDPuskesmas != nil && *req.IDPuskesmas != 0 {
		// Verify puskesmas exists
		var puskesmas models.Puskesmas
		if err := ctrl.DB().First(&puskesmas, *req.IDPuskesmas).Error; err != nil {
			return c.JSON(http.StatusBadRequest, map[string]interface{}{
				"status":  "error",
				"message": "Puskesmas tidak ditemukan",
			})
		}
		posyandu.IDPuskesmas = *req.IDPuskesmas
	}

	if req.DesaID != nil {
		// Verify desa exists if provided and not zero
		if *req.DesaID != 0 {
			var desa models.Desa
			if err := ctrl.DB().First(&desa, *req.DesaID).Error; err != nil {
				return c.JSON(http.StatusBadRequest, map[string]interface{}{
					"status":  "error",
					"message": "Desa tidak ditemukan",
				})
			}
		}
		posyandu.DesaID = req.DesaID
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
