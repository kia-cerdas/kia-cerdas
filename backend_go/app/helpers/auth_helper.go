package helpers

import (
	"errors"
	"fmt"
	"strings"
	"monitoring-service/app/models"

	"github.com/labstack/echo/v4"
	"gorm.io/gorm"
)

// GetUserFromContext extracts user from JWT token in echo context
func GetUserFromContext(c echo.Context, db *gorm.DB) (*models.User, error) {
	// Get user_id from context (set by JWT middleware)
	userID, ok := c.Get("user_id").(int64)
	if !ok {
		return nil, errors.New("user_id not found in context")
	}

	var user models.User
	err := db.Preload("Penduduk").Preload("Role").First(&user, uint(userID)).Error
	if err != nil {
		return nil, err
	}

	return &user, nil
}

// GetUserDesaID gets desa_id from logged-in user's penduduk
// Returns (nil, nil) if user should not be filtered (admin/superadmin)
// Returns (desaID, nil) if user should be filtered by desa
// Returns (nil, error) only on critical errors
func GetUserDesaID(c echo.Context, db *gorm.DB) (*int32, error) {
	user, err := GetUserFromContext(c, db)
	if err != nil {
		return nil, err
	}

	// Check if user should be filtered by desa
	if !ShouldFilterByDesa(user) {
		return nil, nil // No filter for admin/puskesmas - this is SUCCESS, not error
	}

	// For bidan_desa/kader, penduduk data is required
	if user.Penduduk == nil {
		// Return error with clear message
		return nil, fmt.Errorf("data penduduk tidak ditemukan untuk role %s, hubungi administrator", user.Role.Name)
	}

	if user.Penduduk.DesaID == nil {
		// Return error with clear message
		return nil, fmt.Errorf("desa_id tidak ditemukan untuk %s, hubungi administrator untuk konfigurasi akun", user.Role.Name)
	}

	return user.Penduduk.DesaID, nil
}

// ShouldFilterByDesa checks if user role requires desa filtering
// Returns false for admin/bidan_puskesmas (can see all desa)
// Returns true for bidan_desa/kader (filtered by their desa)
func ShouldFilterByDesa(user *models.User) bool {
	if user == nil {
		return true // Default: filter by desa for safety
	}

	// Roles that can see ALL desa (no filter)
	adminRoles := []string{
		"superadmin",
		"admin",
		"admin_puskesmas",
		"bidan_puskesmas",
		"Bidan_puskesmas", // Add uppercase variant
	}

	roleName := user.Role.Name
	// Normalize role name for comparison
	roleNameLower := strings.ToLower(roleName)
	
	for _, adminRole := range adminRoles {
		if roleName == adminRole || roleNameLower == strings.ToLower(adminRole) {
			return false // No filter
		}
	}

	// Roles that should be filtered by desa
	// bidan_desa, kader, etc.
	return true
}

// ValidatePosyanduAccess checks if user can access a specific posyandu
func ValidatePosyanduAccess(c echo.Context, db *gorm.DB, posyanduID int32) error {
	desaID, err := GetUserDesaID(c, db)
	if err != nil {
		return err
	}

	// No desa filter (admin/puskesmas) - allow access
	if desaID == nil {
		return nil
	}

	// Check if posyandu belongs to user's desa
	var posyandu models.Posyandu
	err = db.Where("id = ? AND desa_id = ?", posyanduID, *desaID).First(&posyandu).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("posyandu tidak ditemukan atau bukan milik desa Anda")
		}
		return err
	}

	return nil
}
