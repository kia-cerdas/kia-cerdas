package repositories

import (
	"errors"
	"monitoring-service/app/models"
	"monitoring-service/pkg/customerror"

	"gorm.io/gorm"
)

func (m *Main) GetRoleByName(roleName string) (*models.Role, error) {
	var role models.Role
	if err := m.postgres.Where("name = ?", roleName).First(&role).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, customerror.NewNotFoundError("role tidak ditemukan")
		}
		return nil, err
	}
	return &role, nil
}

func (m *Main) GetUserByEmail(email string) (*models.User, error) {
	var user models.User
	if err := m.postgres.Preload("Role").Preload("Penduduk").Where("email = ?", email).First(&user).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, customerror.NewNotFoundError("email belum terdaftar")
		}
		return nil, err
	}
	return &user, nil
}

func (m *Main) GetUserByUsername(username string) (*models.User, error) {
	var user models.User
	if err := m.postgres.Preload("Role").Where("nama = ?", username).First(&user).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, customerror.NewNotFoundError("username belum terdaftar")
		}
		return nil, err
	}
	return &user, nil
}

func (m *Main) GetUserByPhoneNumber(phoneNumber string) (*models.User, error) {
	var user models.User
	if err := m.postgres.Preload("Role").Preload("Penduduk").
		Joins("JOIN penduduk p ON p.id = pengguna.penduduk_id").
		Where("p.telepon = ? AND p.deleted_at IS NULL", phoneNumber).
		First(&user).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, customerror.NewNotFoundError("nomor hp belum terdaftar")
		}
		return nil, err
	}
	return &user, nil
}

func (m *Main) CreateUser(user *models.User) error {
	if err := m.postgres.Create(user).Error; err != nil {
		return err
	}
	return nil
}


// GetBidanByPendudukID - Mendapatkan bidan berdasarkan penduduk_id
func (m *Main) GetBidanByPendudukID(pendudukID int32) (*models.Bidan, error) {
    var bidan models.Bidan
    if err := m.postgres.
        Where("penduduk_id = ? AND deleted_at IS NULL", pendudukID).
        Preload("Penduduk").
        Preload("Posyandu").
        First(&bidan).Error; err != nil {
        if errors.Is(err, gorm.ErrRecordNotFound) {
            return nil, nil // Tidak ditemukan = nil, bukan error
        }
        return nil, err
    }
    return &bidan, nil
}

// GetBidanByPosyanduID - Mendapatkan semua bidan di posyandu
func (m *Main) GetBidanByPosyanduID(posyanduID int32) ([]models.Bidan, error) {
    var bidans []models.Bidan
    if err := m.postgres.
        Where("posyandu_id = ? AND deleted_at IS NULL", posyanduID).
        Preload("Penduduk").
        Find(&bidans).Error; err != nil {
        return nil, err
    }
    return bidans, nil
}

// ============================================
// KADER
// ============================================

// GetKaderByPendudukID - Mendapatkan kader berdasarkan penduduk_id
func (m *Main) GetKaderByPendudukID(pendudukID int32) (*models.Kader, error) {
    var kader models.Kader
    if err := m.postgres.
        Where("penduduk_id = ? AND deleted_at IS NULL", pendudukID).
        Preload("Penduduk").
        Preload("Posyandu").
        First(&kader).Error; err != nil {
        if errors.Is(err, gorm.ErrRecordNotFound) {
            return nil, nil // Tidak ditemukan = nil, bukan error
        }
        return nil, err
    }
    return &kader, nil
}

// GetKaderByPosyanduID - Mendapatkan semua kader di posyandu
func (m *Main) GetKaderByPosyanduID(posyanduID int32) ([]models.Kader, error) {
    var kaders []models.Kader
    if err := m.postgres.
        Where("posyandu_id = ? AND deleted_at IS NULL", posyanduID).
        Preload("Penduduk").
        Find(&kaders).Error; err != nil {
        return nil, err
    }
    return kaders, nil
}

func (m *Main) SavePasswordReset(data *models.PasswordReset) error {
	return m.postgres.Create(data).Error
}

func (m *Main) GetValidOTP(email, otp string) (*models.PasswordReset, error) {
	var resetData models.PasswordReset
	// Cari OTP yang cocok, belum kadaluarsa, dan belum digunakan
	err := m.postgres.Where("email = ? AND otp = ? AND is_used = ? AND expired_at > NOW()", email, otp, false).First(&resetData).Error
	if err != nil {
		return nil, customerror.NewNotFoundError("OTP tidak valid atau sudah kadaluarsa")
	}
	return &resetData, nil
}

func (m *Main) MarkOTPAsUsed(id uint) error {
	return m.postgres.Model(&models.PasswordReset{}).Where("id = ?", id).Update("is_used", true).Error
}

func (m *Main) UpdateUserPassword(email, hashedPassword string) error {
	return m.postgres.Model(&models.User{}).Where("email = ?", email).Update("kata_sandi", hashedPassword).Error
}