package repositories

import (
	"errors"
	"monitoring-service/app/models"

	"gorm.io/gorm"
)

// AnakRepository menangani operasi database untuk entitas Anak.
type AnakRepository struct {
	db *gorm.DB
}

func NewAnakRepository(db *gorm.DB) *AnakRepository {
	return &AnakRepository{db: db}
}

func (r *AnakRepository) Create(anak *models.Anak) error {
	return r.db.Create(anak).Error
}

func (r *AnakRepository) FindByKehamilanID(kehamilanID int32) ([]models.Anak, error) {
	var list []models.Anak
	err := r.db.
		Preload("Penduduk").
		Preload("Kehamilan.Ibu.Kependudukan").
		Where("kehamilan_id = ?", kehamilanID).
		Order("created_at ASC").
		Find(&list).Error
	return list, err
}
func (r *AnakRepository) FindAll() ([]models.Anak, error) {
	var list []models.Anak

	err := r.db.
		Preload("Penduduk").
		Preload("Kehamilan.Ibu.Kependudukan").
		Find(&list).Error
	if err != nil {
		return nil, err
	}
	return list, nil
}

// FindAllByDesaID mengambil data anak yang penduduknya berada di desa tertentu.
// Menggunakan JOIN ke tabel penduduk agar query efisien (filter di level DB, bukan di Go).
func (r *AnakRepository) FindAllByDesaID(desaID int32) ([]models.Anak, error) {
	var list []models.Anak

	err := r.db.
		Joins("JOIN penduduk ON penduduk.id = anak.penduduk_id").
		Where("penduduk.desa_id = ?", desaID).
		Preload("Penduduk").
		Preload("Kehamilan.Ibu.Kependudukan").
		Find(&list).Error
	if err != nil {
		return nil, err
	}
	return list, nil
}

func (r *AnakRepository) FindByID(id int32) (*models.Anak, error) {
	var anak models.Anak
	err := r.db.
		Preload("Penduduk").
		Preload("Kehamilan.Ibu.Kependudukan").
		Where("id = ?", id).
		First(&anak).Error
	if err != nil {
		return nil, err
	}
	return &anak, nil
}

func (r *AnakRepository) FindByIDAndPenggunaID(id, penggunaID int32) (*models.Anak, error) {
	var anak models.Anak
	err := r.db.
		Preload("Penduduk").
		Preload("Kehamilan.Ibu.Kependudukan").
		Where("id = ? AND pengguna_id = ?", id, penggunaID).
		First(&anak).Error
	if err != nil {
		return nil, err
	}
	return &anak, nil
}

func (r *AnakRepository) Update(anak *models.Anak) error {
	return r.db.Save(anak).Error
}

func (r *AnakRepository) Delete(id int32) error {
	result := r.db.Where("id = ?", id).Delete(&models.Anak{})

	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return errors.New("Data Anak tidak ditemukan ")
	}
	return nil
}

func (r *AnakRepository) FindAllByPosyanduID(posyanduID int32) ([]models.Anak, error) {
	var anaks []models.Anak

	// Coba dulu: filter lewat kehamilan → ibu → kependudukan ibu (posyandu_id di sisi ibu)
	err := r.db.
		Preload("Penduduk").
		Preload("Kehamilan").
		Preload("Kehamilan.Ibu").
		Preload("Kehamilan.Ibu.Kependudukan").
		Joins("LEFT JOIN kehamilan ON kehamilan.id = anak.kehamilan_id AND kehamilan.deleted_at IS NULL").
		Joins("LEFT JOIN ibu ON ibu.id = kehamilan.ibu_id AND ibu.is_deleted IS NULL").
		Joins("LEFT JOIN penduduk pi ON pi.id = ibu.penduduk_id AND pi.deleted_at IS NULL").
		Joins("LEFT JOIN penduduk pa ON pa.id = anak.penduduk_id AND pa.deleted_at IS NULL").
		Where("(pi.posyandu_id = ? OR pa.posyandu_id = ?)", posyanduID, posyanduID).
		Where("anak.deleted_at IS NULL").
		Find(&anaks).Error

	if err != nil {
		return nil, err
	}

	// Jika tidak ada hasil, coba filter lewat desa yang sama dengan posyandu tersebut
	if len(anaks) == 0 {
		err = r.db.
			Preload("Penduduk").
			Preload("Kehamilan").
			Preload("Kehamilan.Ibu").
			Preload("Kehamilan.Ibu.Kependudukan").
			Joins("LEFT JOIN penduduk pa ON pa.id = anak.penduduk_id AND pa.deleted_at IS NULL").
			Joins("LEFT JOIN posyandu pos ON pos.id = ?", posyanduID).
			Where("pa.desa_id = pos.desa_id").
			Where("anak.deleted_at IS NULL").
			Find(&anaks).Error
		if err != nil {
			return nil, err
		}
	}

	// Jika masih kosong, kembalikan semua anak tanpa filter (fallback untuk debugging)
	// agar bidan bisa melihat data
	if len(anaks) == 0 {
		err = r.db.
			Preload("Penduduk").
			Preload("Kehamilan").
			Preload("Kehamilan.Ibu").
			Preload("Kehamilan.Ibu.Kependudukan").
			Where("anak.deleted_at IS NULL").
			Find(&anaks).Error
	}

	return anaks, err
}

// // FindAllByDesaID mendapatkan semua anak berdasarkan desa_id
// func (r *AnakRepository) FindAllByDesaID(desaID int32) ([]models.Anak, error) {
// 	var anaks []models.Anak
	
// 	err := r.db.
// 		Preload("Penduduk").
// 		Preload("Kehamilan").
// 		Preload("Kehamilan.Ibu").
// 		Preload("Kehamilan.Ibu.Kependudukan").
// 		Joins("JOIN penduduk ON penduduk.id = anak.penduduk_id").
// 		Where("penduduk.desa_id = ?", desaID).
// 		Where("anak.deleted_at IS NULL").
// 		Find(&anaks).Error
	
// 	return anaks, err
// }