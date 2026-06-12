package repositories

import (
	"monitoring-service/app/models"
	"strings"
	"time"

	"gorm.io/gorm"
)

type UserListItem struct {
	ID          int32     `json:"id"`
	Name        string    `json:"name"`
	Email       string    `json:"email"`
	PhoneNumber string    `json:"phone_number"`
	DesaID      *int32    `json:"desa_id,omitempty"`
	DesaName    string    `json:"desa_name,omitempty"`
	Role        string    `json:"role"`
	IsActive    bool      `json:"is_active"`
	PendudukID  *int64    `json:"penduduk_id,omitempty"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

type UserRepository struct {
	db *gorm.DB
}

func NewUserRepository(db *gorm.DB) *UserRepository {
	return &UserRepository{db: db}
}

func (r *UserRepository) Create(user *models.User) error {
	return r.db.Create(user).Error
}

func (r *UserRepository) FindByEmail(email string) (*models.User, error) {
	var user models.User
	err := r.db.Preload("Role").Where("email = ?", email).First(&user).Error
	return &user, err
}

func (r *UserRepository) FindByUsername(username string) (*models.User, error) {
	var user models.User
	err := r.db.Preload("Role").Where("nama = ?", username).First(&user).Error
	return &user, err
}

func (r *UserRepository) FindByPhoneNumber(phone string) (*models.User, error) {
	var user models.User
	err := r.db.Preload("Role").
		Joins("JOIN penduduk p ON p.id = pengguna.penduduk_id").
		Where("p.telepon = ? AND p.deleted_at IS NULL", phone).
		First(&user).Error
	return &user, err
}

func (r *UserRepository) FindByID(id int32) (*models.User, error) {
	var user models.User
	err := r.db.Preload("Role").First(&user, id).Error
	return &user, err
}

func (r *UserRepository) FindByIDExceptEmail(email string, exceptID int32) (*models.User, error) {
	var user models.User
	err := r.db.Preload("Role").Where("email = ? AND id <> ?", email, exceptID).First(&user).Error
	return &user, err
}

func (r *UserRepository) FindByPhoneNumberExceptID(phone string, exceptID int32) (*models.User, error) {
	var user models.User
	err := r.db.Preload("Role").
		Joins("JOIN penduduk p ON p.id = pengguna.penduduk_id").
		Where("p.telepon = ? AND p.deleted_at IS NULL AND pengguna.id <> ?", phone, exceptID).
		First(&user).Error
	return &user, err
}

func (r *UserRepository) FindByPendudukID(pendudukID int64) (*models.User, error) {
	var user models.User
	err := r.db.Preload("Role").Where("penduduk_id = ?", pendudukID).First(&user).Error
	return &user, err
}

func (r *UserRepository) FindByKartuKeluargaID(kartuKeluargaID int64) (*models.User, error) {
	var user models.User
	err := r.db.Preload("Role").
		Joins("JOIN penduduk p ON p.id = pengguna.penduduk_id").
		Where("p.kartu_keluarga_id = ? AND p.deleted_at IS NULL", kartuKeluargaID).
		Order("pengguna.id ASC").
		First(&user).Error
	return &user, err
}

func (r *UserRepository) Update(user *models.User) error {
	return r.db.Save(user).Error
}

func (r *UserRepository) SetPassword(id int32, hashedPassword string) error {
	return r.db.Model(&models.User{}).
		Where("id = ?", id).
		Updates(map[string]interface{}{
			"kata_sandi": hashedPassword,
			"updated_at": time.Now(),
		}).Error
}

func (r *UserRepository) SetActive(id int32, active bool) error {
	return r.db.Model(&models.User{}).
		Where("id = ?", id).
		Updates(map[string]interface{}{
			"is_active":  active,
			"updated_at": time.Now(),
		}).Error
}

func (r *UserRepository) List(search, role, desa string) ([]UserListItem, error) {
	var rows []UserListItem

	q := r.db.Table("pengguna u").
		Select("u.id, u.nama, u.email, p.telepon AS phone_number, p.desa_id AS desa_id, COALESCE(d.nama_desa, '') AS desa_name, r.name AS role, u.is_active, u.penduduk_id, u.created_at, u.updated_at").
		Joins("JOIN roles r ON r.id = u.role_id").
		Joins("LEFT JOIN penduduk p ON p.id = u.penduduk_id AND p.deleted_at IS NULL").
		Joins("LEFT JOIN desa d ON d.id = p.desa_id AND d.deleted_at IS NULL").
		Order("u.id DESC")

	search = strings.TrimSpace(search)
	role = strings.TrimSpace(role)
	desa = strings.TrimSpace(desa)

	if search != "" {
		pattern := "%" + search + "%"
		q = q.Where("u.nama ILIKE ? OR u.email ILIKE ? OR p.telepon ILIKE ?", pattern, pattern, pattern)
	}
	if role != "" {
		q = q.Where("LOWER(r.name) = LOWER(?)", role)
	}
	if desa != "" {
		q = q.Where("CAST(p.desa_id AS TEXT) = ? OR LOWER(COALESCE(d.nama_desa, '')) = LOWER(?)", desa, desa)
	}

	if err := q.Scan(&rows).Error; err != nil {
		return nil, err
	}

	return rows, nil
}
