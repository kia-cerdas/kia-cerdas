package repositories

import (
	"time"

	"monitoring-service/app/models"

	"gorm.io/gorm"
)

type JadwalLayananRepository interface {
	Create(data *models.JadwalLayanan, dosisVaksinIDs []uint) error
	GetAll() ([]models.JadwalLayanan, error)
	GetByID(id int32) (*models.JadwalLayanan, error)
	GetByPosyandu(posyanduID int32) ([]models.JadwalLayanan, error)
	GetByDateRange(posyanduID *int32, from, to *time.Time) ([]models.JadwalLayanan, error)
	GetUpcoming(limit int) ([]models.JadwalLayanan, error)
	Update(id int32, data *models.JadwalLayanan, dosisVaksinIDs []uint) error
	Delete(id int32) error
}

type jadwalLayananRepository struct {
	db *gorm.DB
}

func NewJadwalLayananRepository(db *gorm.DB) JadwalLayananRepository {
	return &jadwalLayananRepository{db: db}
}

func (r *jadwalLayananRepository) Create(data *models.JadwalLayanan, dosisVaksinIDs []uint) error {
	return r.db.Transaction(func(tx *gorm.DB) error {
		if err := tx.Create(data).Error; err != nil {
			return err
		}

		if len(dosisVaksinIDs) > 0 {
			for _, dosisVaksinID := range dosisVaksinIDs {
				pivot := models.JadwalLayananDosisVaksin{
					JadwalLayananID: data.ID,
					DosisVaksinID:   dosisVaksinID,
				}
				if err := tx.Create(&pivot).Error; err != nil {
					return err
				}
			}
		}
		return nil
	})
}

func (r *jadwalLayananRepository) GetAll() ([]models.JadwalLayanan, error) {
	var data []models.JadwalLayanan
	err := r.db.
		Preload("DosisVaksins").
		Preload("DosisVaksins.Vaksin").
		Preload("Posyandu").
		Order("tanggal asc, waktu_mulai asc").
		Find(&data).Error
	return data, err
}

func (r *jadwalLayananRepository) GetByID(id int32) (*models.JadwalLayanan, error) {
	var data models.JadwalLayanan
	err := r.db.
		Preload("DosisVaksins").
		Preload("DosisVaksins.Vaksin").
		Preload("Posyandu").
		First(&data, id).Error
	return &data, err
}

func (r *jadwalLayananRepository) GetByPosyandu(posyanduID int32) ([]models.JadwalLayanan, error) {
	var data []models.JadwalLayanan
	err := r.db.
		Preload("DosisVaksins").
		Preload("DosisVaksins.Vaksin").
		Preload("Posyandu").
		Where("posyandu_id = ?", posyanduID).
		Order("tanggal asc, waktu_mulai asc").
		Find(&data).Error
	return data, err
}

func (r *jadwalLayananRepository) GetByDateRange(posyanduID *int32, from, to *time.Time) ([]models.JadwalLayanan, error) {
	var data []models.JadwalLayanan
	q := r.db.Model(&models.JadwalLayanan{}).
		Preload("DosisVaksins").
		Preload("DosisVaksins.Vaksin").
		Preload("Posyandu")

	if posyanduID != nil {
		q = q.Where("posyandu_id = ?", *posyanduID)
	}
	if from != nil && to != nil {
		q = q.Where("tanggal BETWEEN ? AND ?", from.Format("2006-01-02"), to.Format("2006-01-02"))
	} else if from != nil {
		q = q.Where("tanggal >= ?", from.Format("2006-01-02"))
	} else if to != nil {
		q = q.Where("tanggal <= ?", to.Format("2006-01-02"))
	}

	err := q.Order("tanggal asc, waktu_mulai asc").Find(&data).Error
	return data, err
}

func (r *jadwalLayananRepository) GetUpcoming(limit int) ([]models.JadwalLayanan, error) {
	var data []models.JadwalLayanan
	now := time.Now()
	today := now.Format("2006-01-02")
	nowTime := now.Format("15:04:05")

	err := r.db.
		Preload("DosisVaksins").
		Preload("DosisVaksins.Vaksin").
		Preload("Posyandu").
		Where("tanggal > ? OR (tanggal = ? AND (waktu_selesai IS NULL OR waktu_selesai >= ?))", today, today, nowTime).
		Order("tanggal asc, waktu_mulai asc").
		Limit(limit).
		Find(&data).Error
	return data, err
}

func (r *jadwalLayananRepository) Update(id int32, data *models.JadwalLayanan, dosisVaksinIDs []uint) error {
	return r.db.Transaction(func(tx *gorm.DB) error {
		if err := tx.Model(&models.JadwalLayanan{}).Where("id = ?", id).Updates(data).Error; err != nil {
			return err
		}

		if err := tx.Where("jadwal_layanan_id = ?", id).Delete(&models.JadwalLayananDosisVaksin{}).Error; err != nil {
			return err
		}

		if len(dosisVaksinIDs) > 0 {
			for _, dosisVaksinID := range dosisVaksinIDs {
				pivot := models.JadwalLayananDosisVaksin{
					JadwalLayananID: id,
					DosisVaksinID:   dosisVaksinID,
				}
				if err := tx.Create(&pivot).Error; err != nil {
					return err
				}
			}
		}
		return nil
	})
}

func (r *jadwalLayananRepository) Delete(id int32) error {
	return r.db.Transaction(func(tx *gorm.DB) error {
		if err := tx.Where("jadwal_layanan_id = ?", id).Delete(&models.JadwalLayananDosisVaksin{}).Error; err != nil {
			return err
		}
		if err := tx.Delete(&models.JadwalLayanan{}, id).Error; err != nil {
			return err
		}
		return nil
	})
}
