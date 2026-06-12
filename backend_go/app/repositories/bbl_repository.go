package repositories

import (
	"monitoring-service/app/models"

	"gorm.io/gorm"
)

type BblRepository interface {
	GetByAnakID(anakID uint) (*models.Bbl, error)
	GetByID(id uint) (*models.Bbl, error)
	Upsert(bbl *models.Bbl) error
	Verify(bblID uint, kaderID uint, periodeWaktu string, status string) error
	GetAll() ([]models.Bbl, error)
}

type bblRepository struct {
	db *gorm.DB
}

func NewBblRepository(db *gorm.DB) BblRepository {
	return &bblRepository{db: db}
}

func (r *bblRepository) GetByAnakID(anakID uint) (*models.Bbl, error) {
	var bbl models.Bbl
	err := r.db.
		Where("anak_id = ?", anakID).
		Preload("Checklist").
		Preload("Checklist.VerifiedByKader").
		Preload("Checklist.VerifiedByKader.Penduduk").
		First(&bbl).Error
	if err != nil {
		return nil, err
	}
	return &bbl, nil
}

func (r *bblRepository) GetByID(id uint) (*models.Bbl, error) {
	var bbl models.Bbl
	err := r.db.
		Where("id = ?", id).
		Preload("Checklist").
		Preload("Checklist.VerifiedByKader").
		Preload("Checklist.VerifiedByKader.Penduduk").
		First(&bbl).Error
	if err != nil {
		return nil, err
	}
	return &bbl, nil
}

func (r *bblRepository) Upsert(bbl *models.Bbl) error {
	var existing models.Bbl
	err := r.db.Where("anak_id = ?", bbl.AnakID).Preload("Checklist").First(&existing).Error
	if err == nil {
		// Record exists - update
		bbl.ID = existing.ID

		// Untuk setiap checklist yang dikirim, cek apakah periode sudah ada
		for i, newCheck := range bbl.Checklist {
			found := false
			for _, existCheck := range existing.Checklist {
				if existCheck.PeriodeWaktu == newCheck.PeriodeWaktu {
					found = true
					bbl.Checklist[i].ID = existCheck.ID
					bbl.Checklist[i].BblID = existing.ID

					// Jika sudah true di DB, tidak bisa di-revert ke false
					if existCheck.StatusPemeriksaan {
						bbl.Checklist[i].StatusPemeriksaan = true
						bbl.Checklist[i].TanggalSubmit = existCheck.TanggalSubmit
					}
					break
				}
			}
			if !found {
				bbl.Checklist[i].BblID = existing.ID
			}
		}

		// Save the parent Bbl (tanpa mengubah field verifikasi dari sisi ibu)
		if err := r.db.Model(&existing).Updates(map[string]interface{}{
			"updated_at": gorm.Expr("NOW()"),
		}).Error; err != nil {
			return err
		}

		// Upsert each checklist item
		for _, check := range bbl.Checklist {
			check.BblID = existing.ID
			if check.ID > 0 {
				if err := r.db.Save(&check).Error; err != nil {
					return err
				}
			} else {
				if err := r.db.Create(&check).Error; err != nil {
					return err
				}
			}
		}

		// Reload untuk return
		return r.db.Where("anak_id = ?", bbl.AnakID).Preload("Checklist").Preload("Checklist.VerifiedByKader").Preload("Checklist.VerifiedByKader.Penduduk").First(bbl).Error
	}

	// Record baru - create
	if err := r.db.Create(bbl).Error; err != nil {
		return err
	}
	return r.db.Where("id = ?", bbl.ID).Preload("Checklist").Preload("Checklist.VerifiedByKader").Preload("Checklist.VerifiedByKader.Penduduk").First(bbl).Error
}

func (r *bblRepository) Verify(bblID uint, kaderID uint, periodeWaktu string, status string) error {
	now := gorm.Expr("NOW()")
	
	isVerified := false
	if status == "Diterima" {
		isVerified = true
	}

	return r.db.Model(&models.BblCheck{}).Where("bbl_id = ? AND periode_waktu = ?", bblID, periodeWaktu).Updates(map[string]interface{}{
		"status":               status,
		"is_verified":          isVerified,
		"verified_at":          now,
		"verified_by_kader_id": kaderID,
	}).Error
}

func (r *bblRepository) GetAll() ([]models.Bbl, error) {
	var bbls []models.Bbl
	err := r.db.
		Preload("Checklist").
		Preload("Checklist.VerifiedByKader").
		Preload("Checklist.VerifiedByKader.Penduduk").
		Preload("Anak").
		Preload("Anak.Penduduk").
		Find(&bbls).Error
	if err != nil {
		return nil, err
	}
	return bbls, nil
}

