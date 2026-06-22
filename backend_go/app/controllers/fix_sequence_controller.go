package controllers

import (
	"fmt"
	"net/http"

	"github.com/labstack/echo/v4"
)

type FixSequenceController struct {
	*Main
}

// FixPuskesmasSequence - Memperbaiki sequence puskesmas yang tidak sinkron
// TEMPORARY ENDPOINT - Hanya untuk debugging/maintenance
func (ctrl *FixSequenceController) FixPuskesmasSequence(c echo.Context) error {
	var maxID int64
	ctrl.DB().Raw("SELECT COALESCE(MAX(id), 0) FROM puskesmas").Scan(&maxID)
	
	nextID := maxID + 1
	
	// Try Method 1: Using IDENTITY column (PostgreSQL 10+)
	query1 := "ALTER TABLE puskesmas ALTER COLUMN id RESTART WITH " + fmt.Sprintf("%d", nextID)
	err1 := ctrl.DB().Exec(query1).Error
	
	if err1 == nil {
		return c.JSON(http.StatusOK, map[string]interface{}{
			"status":            "success",
			"message":           "Sequence puskesmas berhasil diperbaiki menggunakan IDENTITY column",
			"method":            "IDENTITY",
			"max_puskesmas_id":  maxID,
			"next_id":           nextID,
		})
	}
	
	// Try Method 2: Using traditional sequence
	// Check if sequence exists
	var seqExists bool
	ctrl.DB().Raw("SELECT EXISTS(SELECT 1 FROM pg_sequences WHERE sequencename = 'puskesmas_id_seq')").Scan(&seqExists)
	
	if !seqExists {
		// Create sequence if not exists
		if err := ctrl.DB().Exec("CREATE SEQUENCE IF NOT EXISTS puskesmas_id_seq").Error; err != nil {
			return c.JSON(http.StatusInternalServerError, map[string]interface{}{
				"status":  "error",
				"message": "Gagal membuat sequence puskesmas",
				"error":   err.Error(),
			})
		}
		
		// Set default
		if err := ctrl.DB().Exec("ALTER TABLE puskesmas ALTER COLUMN id SET DEFAULT nextval('puskesmas_id_seq')").Error; err != nil {
			return c.JSON(http.StatusInternalServerError, map[string]interface{}{
				"status":  "error",
				"message": "Gagal set default sequence",
				"error":   err.Error(),
			})
		}
		
		// Set ownership
		ctrl.DB().Exec("ALTER SEQUENCE puskesmas_id_seq OWNED BY puskesmas.id")
	}
	
	// Reset sequence value
	query2 := fmt.Sprintf("SELECT setval('puskesmas_id_seq', %d, false)", nextID)
	if err := ctrl.DB().Exec(query2).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]interface{}{
			"status":  "error",
			"message": "Gagal memperbaiki sequence puskesmas",
			"error":   err.Error(),
		})
	}

	var currentSeq int64
	ctrl.DB().Raw("SELECT last_value FROM puskesmas_id_seq").Scan(&currentSeq)

	return c.JSON(http.StatusOK, map[string]interface{}{
		"status":               "success",
		"message":              "Sequence puskesmas berhasil diperbaiki",
		"method":               "SEQUENCE",
		"current_sequence":     currentSeq,
		"max_puskesmas_id":     maxID,
		"next_id":              nextID,
	})
}

// FixPosyanduSequence - Memperbaiki sequence posyandu yang tidak sinkron
func (ctrl *FixSequenceController) FixPosyanduSequence(c echo.Context) error {
	// Fix sequence posyandu
	query := "SELECT setval('posyandu_id_seq', (SELECT COALESCE(MAX(id), 1) FROM posyandu), true)"
	
	if err := ctrl.DB().Exec(query).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]interface{}{
			"status":  "error",
			"message": "Gagal memperbaiki sequence posyandu",
			"error":   err.Error(),
		})
	}

	// Get current sequence value untuk verifikasi
	var currentSeq int64
	ctrl.DB().Raw("SELECT currval('posyandu_id_seq')").Scan(&currentSeq)

	var maxID int64
	ctrl.DB().Raw("SELECT COALESCE(MAX(id), 0) FROM posyandu").Scan(&maxID)

	return c.JSON(http.StatusOK, map[string]interface{}{
		"status":               "success",
		"message":              "Sequence posyandu berhasil diperbaiki",
		"current_sequence":     currentSeq,
		"max_posyandu_id":      maxID,
		"is_sequence_valid":    currentSeq >= maxID,
	})
}

// FixAllSequences - Memperbaiki semua sequence yang tidak sinkron
func (ctrl *FixSequenceController) FixAllSequences(c echo.Context) error {
	results := make(map[string]interface{})
	
	// List of tables to fix
	tables := []struct {
		name     string
		sequence string
	}{
		{"puskesmas", "puskesmas_id_seq"},
		{"posyandu", "posyandu_id_seq"},
		{"desa", "desa_id_seq"},
		{"kependudukan", "kependudukan_id_seq"},
		{"users", "users_id_seq"},
	}

	for _, table := range tables {
		query := "SELECT setval('" + table.sequence + "', (SELECT COALESCE(MAX(id), 1) FROM " + table.name + "), true)"
		
		if err := ctrl.DB().Exec(query).Error; err != nil {
			results[table.name] = map[string]interface{}{
				"status": "error",
				"error":  err.Error(),
			}
			continue
		}

		var currentSeq int64
		ctrl.DB().Raw("SELECT currval('" + table.sequence + "')").Scan(&currentSeq)

		var maxID int64
		ctrl.DB().Raw("SELECT COALESCE(MAX(id), 0) FROM " + table.name).Scan(&maxID)

		results[table.name] = map[string]interface{}{
			"status":            "success",
			"current_sequence":  currentSeq,
			"max_id":            maxID,
			"is_valid":          currentSeq >= maxID,
		}
	}

	return c.JSON(http.StatusOK, map[string]interface{}{
		"status":  "success",
		"message": "Proses perbaikan sequence selesai",
		"results": results,
	})
}
