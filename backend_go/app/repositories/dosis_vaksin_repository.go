package repositories

import (
	"monitoring-service/app/models"

	"gorm.io/gorm"
)

type DosisVaksinRepository interface {
	GetAll() ([]models.DosisVaksin, error)
	GetByID(id uint) (*models.DosisVaksin, error)
	GetByVaksinID(vaksinID uint) ([]models.DosisVaksin, error)
	Create(data *models.DosisVaksin) error
	Update(data *models.DosisVaksin) error
	Delete(id uint) error
}

type dosisVaksinRepository struct {
	db *gorm.DB
}

func NewDosisVaksinRepository(db *gorm.DB) DosisVaksinRepository {
	return &dosisVaksinRepository{db: db}
}

func (r *dosisVaksinRepository) GetAll() ([]models.DosisVaksin, error) {
	var data []models.DosisVaksin
	err := r.db.
		Preload("Vaksin").
		Order("id ASC").
		Find(&data).Error
	return data, err
}

func (r *dosisVaksinRepository) GetByID(id uint) (*models.DosisVaksin, error) {
	var data models.DosisVaksin
	err := r.db.
		Preload("Vaksin").
		First(&data, id).Error
	return &data, err
}

func (r *dosisVaksinRepository) GetByVaksinID(vaksinID uint) ([]models.DosisVaksin, error) {
	var data []models.DosisVaksin
	err := r.db.
		Preload("Vaksin").
		Where("id_vaksin = ?", vaksinID).
		Order("id ASC").
		Find(&data).Error
	return data, err
}

func (r *dosisVaksinRepository) Create(data *models.DosisVaksin) error {
	return r.db.Create(data).Error
}

func (r *dosisVaksinRepository) Update(data *models.DosisVaksin) error {
	return r.db.Save(data).Error
}

func (r *dosisVaksinRepository) Delete(id uint) error {
	return r.db.Delete(&models.DosisVaksin{}, id).Error
}
