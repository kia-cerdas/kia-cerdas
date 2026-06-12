package repositories

import (
	"time"

	"monitoring-service/app/models"

	"gorm.io/gorm"
)

type DesaRepository struct {
	db *gorm.DB
}

func NewDesaRepository(db *gorm.DB) *DesaRepository {
	return &DesaRepository{db: db}
}

func (r *DesaRepository) GetAll() ([]models.Desa, error) {
	var list []models.Desa
	err := r.db.Where("deleted_at IS NULL").Order("id DESC").Find(&list).Error
	return list, err
}

func (r *DesaRepository) GetByID(id int32) (*models.Desa, error) {
	var desa models.Desa
	err := r.db.Where("id = ? AND deleted_at IS NULL", id).First(&desa).Error
	return &desa, err
}

func (r *DesaRepository) Create(desa *models.Desa) error {
	return r.db.Create(desa).Error
}

func (r *DesaRepository) Save(desa *models.Desa) error {
	return r.db.Save(desa).Error
}

func (r *DesaRepository) Deactivate(id int32) error {
	desa, err := r.GetByID(id)
	if err != nil {
		return err
	}

	now := time.Now()
	desa.IsActive = false
	desa.DeletedAt = &now
	desa.UpdatedAt = now
	return r.db.Save(desa).Error
}

func (r *DesaRepository) FindByID(id int32) (*models.Desa, error) {
    var desa models.Desa
    err := r.db.Where("id = ? AND deleted_at IS NULL", id).First(&desa).Error
    if err != nil {
        return nil, err
    }
    return &desa, nil
}