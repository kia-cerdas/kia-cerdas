package repositories

import (
	"errors"
	"monitoring-service/app/models"

	"gorm.io/gorm"
)

type PemeriksaanDokterTrimester1Repository struct {
	db *gorm.DB
}

func NewPemeriksaanDokterTrimester1Repository(db *gorm.DB) *PemeriksaanDokterTrimester1Repository {
	return &PemeriksaanDokterTrimester1Repository{db: db}
}

// ── Create (single record) ─────────────────────────────────────────────
func (r *PemeriksaanDokterTrimester1Repository) Create(dokter *models.PemeriksaanDokterTrimester1) error {
	return r.db.Create(dokter).Error
}

// ── CreateWithLab (transaksi dokter + lab) ─────────────────────────────
func (r *PemeriksaanDokterTrimester1Repository) CreateWithLab(dokter *models.PemeriksaanDokterTrimester1, lab *models.PemeriksaanLaboratoriumJiwa) error {
	return r.db.Transaction(func(tx *gorm.DB) error {
		if err := tx.Create(dokter).Error; err != nil {
			return err
		}
		if lab != nil {
			lab.KehamilanID = dokter.KehamilanID
			lab.Trimester = 1
			if err := tx.Create(lab).Error; err != nil {
				return err
			}
		}
		return nil
	})
}

// ── UpdateWithLab (transaksi update dokter + lab) ─────────────────────
func (r *PemeriksaanDokterTrimester1Repository) UpdateWithLab(dokterID int32, dokter *models.PemeriksaanDokterTrimester1, lab *models.PemeriksaanLaboratoriumJiwa) error {
	return r.db.Transaction(func(tx *gorm.DB) error {
		// FIX: Gunakan Select("*") + Updates agar GORM tidak menjalankan SELECT * terlebih dahulu
		// yang memperlambat query karena membaca kolom besar seperti gambar_usg (base64).
		dokter.ID = dokterID
		if err := tx.Model(&models.PemeriksaanDokterTrimester1{}).Where("id_trimester1 = ?", dokterID).Select("*").Updates(dokter).Error; err != nil {
			return err
		}
		if lab != nil {
			var existingLab models.PemeriksaanLaboratoriumJiwa
			err := tx.Where("kehamilan_id = ? AND trimester = ?", dokter.KehamilanID, 1).First(&existingLab).Error
			if errors.Is(err, gorm.ErrRecordNotFound) {
				lab.KehamilanID = dokter.KehamilanID
				lab.Trimester = 1
				if err := tx.Create(lab).Error; err != nil {
					return err
				}
			} else if err != nil {
				return err
			} else {
				if err := tx.Model(&existingLab).Updates(lab).Error; err != nil {
					return err
				}
			}
		}
		return nil
	})
}

// ── FindByID (digunakan usecase) ─────────────────────────────────────
func (r *PemeriksaanDokterTrimester1Repository) FindByID(id int32) (*models.PemeriksaanDokterTrimester1, error) {
	var data models.PemeriksaanDokterTrimester1
	// kolom primary key adalah id_trimester1
	err := r.db.Where("id_trimester1 = ?", id).First(&data).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("data pemeriksaan dokter trimester 1 tidak ditemukan")
		}
		return nil, err
	}
	return &data, nil
}

// ── FindByKehamilanID (digunakan usecase) ────────────────────────────
func (r *PemeriksaanDokterTrimester1Repository) FindByKehamilanID(kehamilanID int32) ([]models.PemeriksaanDokterTrimester1, error) {
	var list []models.PemeriksaanDokterTrimester1
	err := r.db.Where("kehamilan_id = ?", kehamilanID).Order("tanggal_periksa DESC").Find(&list).Error
	return list, err
}

// ── Update biasa (single) ─────────────────────────────────────────────
func (r *PemeriksaanDokterTrimester1Repository) Update(dokter *models.PemeriksaanDokterTrimester1) error {
	// FIX: Gunakan Updates() alih-alih Save() untuk menghindari SELECT * sebelum UPDATE
	// yang lambat karena kolom gambar_usg bisa berisi Base64 besar.
	return r.db.Model(&models.PemeriksaanDokterTrimester1{}).Where("id_trimester1 = ?", dokter.ID).Select("*").Updates(dokter).Error
}

// ── Delete ─────────────────────────────────────────────────────────────
func (r *PemeriksaanDokterTrimester1Repository) Delete(id int32) error {
	result := r.db.Delete(&models.PemeriksaanDokterTrimester1{}, id)
	if result.RowsAffected == 0 {
		return errors.New("data pemeriksaan dokter trimester 1 tidak ditemukan")
	}
	return result.Error
}

// ── MODUL IBU ──────────────────────────────────────────────────────────
func (r *PemeriksaanDokterTrimester1Repository) FindMineByUserID(userID int32) (*models.PemeriksaanDokterTrimester1, error) {
	var data models.PemeriksaanDokterTrimester1
	err := r.db.
		Table("pemeriksaan_dokter_trimester_1 p").
		Joins("JOIN kehamilan k ON k.id = p.kehamilan_id").
		Joins("JOIN ibu i ON i.id = k.ibu_id").
		Joins("JOIN penduduk pd ON pd.id = i.penduduk_id").
		Joins("JOIN pengguna u ON u.penduduk_id = pd.id").
		Where("u.id = ?", userID).
		Order("p.tanggal_periksa DESC").
		First(&data).Error
	return &data, err
}

func (r *PemeriksaanDokterTrimester1Repository) FindAllMineByUserID(userID int32) ([]models.PemeriksaanDokterTrimester1, error) {
	var list []models.PemeriksaanDokterTrimester1
	err := r.db.
		Table("pemeriksaan_dokter_trimester_1 p").
		Joins("JOIN kehamilan k ON k.id = p.kehamilan_id").
		Joins("JOIN ibu i ON i.id = k.ibu_id").
		Joins("JOIN penduduk pd ON pd.id = i.penduduk_id").
		Joins("JOIN pengguna u ON u.penduduk_id = pd.id").
		Where("u.id = ?", userID).
		Order("p.tanggal_periksa DESC").
		Find(&list).Error
	return list, err
}
