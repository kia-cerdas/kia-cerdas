package repositories

import (
	"time"

	"monitoring-service/app/models"

	"gorm.io/gorm"
)

type JadwalLayananRepository interface {
	Create(data *models.JadwalLayanan, dosisVaksinIDs []uint) error
	GetAll(desaID *int32) ([]models.JadwalLayanan, error)
	GetByID(id int32) (*models.JadwalLayanan, error)
	GetByPosyandu(posyanduID int32) ([]models.JadwalLayanan, error)
	GetByDateRange(posyanduID *int32, from, to *time.Time, desaID *int32) ([]models.JadwalLayanan, error)
	GetUpcoming(limit int, desaID *int32) ([]models.JadwalLayanan, error)
	Update(id int32, data *models.JadwalLayanan, dosisVaksinIDs []uint) error
	Delete(id int32) error
	CheckExistsByDate(tanggal time.Time, excludeID *int32) (bool, error)
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

func (r *jadwalLayananRepository) GetAll(desaID *int32) ([]models.JadwalLayanan, error) {
	var data []models.JadwalLayanan
	query := r.db.
		Preload("DosisVaksins").
		Preload("DosisVaksins.Vaksin").
		Preload("Posyandu")
	
	// Filter by desa_id if provided (for bidan_desa/kader)
	if desaID != nil {
		// Use subquery to check if desa_id column exists first
		query = query.Where("posyandu_id IN (?)", 
			r.db.Table("posyandu").Select("id").Where("desa_id = ?", *desaID))
	}
	
	err := query.Order("tanggal asc, waktu_mulai asc").Find(&data).Error
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

func (r *jadwalLayananRepository) GetByDateRange(posyanduID *int32, from, to *time.Time, desaID *int32) ([]models.JadwalLayanan, error) {
	var data []models.JadwalLayanan
	q := r.db.Model(&models.JadwalLayanan{}).
		Preload("DosisVaksins").
		Preload("DosisVaksins.Vaksin").
		Preload("Posyandu")

	if posyanduID != nil {
		q = q.Where("posyandu_id = ?", *posyanduID)
	}
	
	// Filter by desa_id if provided (for bidan_desa/kader)
	if desaID != nil {
		q = q.Where("posyandu_id IN (?)", 
			r.db.Table("posyandu").Select("id").Where("desa_id = ?", *desaID))
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

func (r *jadwalLayananRepository) GetUpcoming(limit int, desaID *int32) ([]models.JadwalLayanan, error) {
	var data []models.JadwalLayanan
	now := time.Now()
	today := now.Format("2006-01-02")
	nowTime := now.Format("15:04:05")

	query := r.db.
		Preload("DosisVaksins").
		Preload("DosisVaksins.Vaksin").
		Preload("Posyandu").
		Where("tanggal > ? OR (tanggal = ? AND (waktu_selesai IS NULL OR waktu_selesai >= ?))", today, today, nowTime)
	
	// Filter by desa_id if provided (for bidan_desa/kader)
	if desaID != nil {
		query = query.Where("posyandu_id IN (?)", 
			r.db.Table("posyandu").Select("id").Where("desa_id = ?", *desaID))
	}
	
	err := query.Order("tanggal asc, waktu_mulai asc").
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

// CheckExistsByDate checks if a schedule already exists for the given date
// excludeID is used for update operations to exclude the current record
func (r *jadwalLayananRepository) CheckExistsByDate(tanggal time.Time, excludeID *int32) (bool, error) {
	var count int64
	dateStr := tanggal.Format("2006-01-02")
	
	query := r.db.Model(&models.JadwalLayanan{}).
		Where("DATE(tanggal) = ?", dateStr)
	
	// Exclude specific ID when updating
	if excludeID != nil {
		query = query.Where("id != ?", *excludeID)
	}
	
	err := query.Count(&count).Error
	return count > 0, err
}
