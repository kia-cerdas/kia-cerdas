package repositories

import (
	"monitoring-service/app/models"

	"gorm.io/gorm"
)

type VaksinRepository interface {
	GetAll() ([]models.Vaksin, error)
	GetByID(id uint) (*models.Vaksin, error)
	Create(data *models.Vaksin) error
	Update(data *models.Vaksin) error
	Delete(id uint) error
}

type vaksinRepository struct {
	db *gorm.DB
}

func NewVaksinRepository(db *gorm.DB) VaksinRepository {
	return &vaksinRepository{db: db}
}

func (r *vaksinRepository) GetAll() ([]models.Vaksin, error) {
	var data []models.Vaksin
	err := r.db.
		Preload("DosisVaksins").
		Order("id ASC").
		Find(&data).Error
	return data, err
}

func (r *vaksinRepository) GetByID(id uint) (*models.Vaksin, error) {
	var data models.Vaksin
	err := r.db.
		Preload("DosisVaksins").
		First(&data, id).Error
	return &data, err
}

func (r *vaksinRepository) Create(data *models.Vaksin) error {
	return r.db.Create(data).Error
}

func (r *vaksinRepository) Update(data *models.Vaksin) error {
	return r.db.Save(data).Error
}

func (r *vaksinRepository) Delete(id uint) error {
	return r.db.Delete(&models.Vaksin{}, id).Error
}
