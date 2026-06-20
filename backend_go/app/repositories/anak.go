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
	
	// Join dengan tabel penduduk untuk filter posyandu_id
	err := r.db.
		Preload("Penduduk").
		Preload("Kehamilan").
		Preload("Kehamilan.Ibu").
		Preload("Kehamilan.Ibu.Kependudukan").
		Joins("JOIN penduduk ON penduduk.id = anak.penduduk_id").
		Where("penduduk.posyandu_id = ?", posyanduID).
		Where("anak.deleted_at IS NULL").
		Find(&anaks).Error
	
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