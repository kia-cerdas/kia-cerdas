// app/repositories/posyandu.go
package repositories

import (
	"gorm.io/gorm"
	"monitoring-service/app/models"
	"monitoring-service/pkg/customerror"
)

type PosyanduRepository struct {
	db *gorm.DB
}

func NewPosyanduRepository(db *gorm.DB) *PosyanduRepository {
	return &PosyanduRepository{db: db}
}

// FindByID mencari posyandu berdasarkan ID
func (r *PosyanduRepository) FindByID(id int32) (*models.Posyandu, error) {
	var posyandu models.Posyandu
	err := r.db.Preload("Desa").
		First(&posyandu, id).Error
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, customerror.NewNotFoundError("posyandu tidak ditemukan")
		}
		return nil, err
	}
	return &posyandu, nil
}

// FindByDesaID mencari semua posyandu di desa tertentu
func (r *PosyanduRepository) FindByDesaID(desaID int32) ([]models.Posyandu, error) {
	var posyanduList []models.Posyandu
	err := r.db.Preload("Desa").
		Where("desa_id = ?", desaID).
		Find(&posyanduList).Error
	return posyanduList, err
}

// FindAll mencari semua posyandu
func (r *PosyanduRepository) FindAll() ([]models.Posyandu, error) {
	var posyanduList []models.Posyandu
	err := r.db.Preload("Desa").
		Find(&posyanduList).Error
	return posyanduList, err
}

// FindAllWithPagination mencari semua posyandu dengan pagination
func (r *PosyanduRepository) FindAllWithPagination(page, limit int) ([]models.Posyandu, int64, error) {
	var posyanduList []models.Posyandu
	var total int64
	
	offset := (page - 1) * limit
	
	// Hitung total
	r.db.Model(&models.Posyandu{}).Count(&total)
	
	// Ambil data
	err := r.db.Preload("Desa").
		Offset(offset).
		Limit(limit).
		Order("id DESC").
		Find(&posyanduList).Error
	
	return posyanduList, total, err
}

// Create membuat posyandu baru
func (r *PosyanduRepository) Create(posyandu *models.Posyandu) error {
	return r.db.Create(posyandu).Error
}

// Update mengupdate posyandu
func (r *PosyanduRepository) Update(posyandu *models.Posyandu) error {
	return r.db.Save(posyandu).Error
}

// Delete menghapus posyandu (soft delete)
func (r *PosyanduRepository) Delete(id int32) error {
	return r.db.Delete(&models.Posyandu{}, id).Error
}

// GetBidanByPosyandu mendapatkan semua bidan di posyandu
func (r *PosyanduRepository) GetBidanByPosyandu(posyanduID int32) ([]models.Bidan, error) {
	var bidanList []models.Bidan
	err := r.db.Preload("Penduduk").
		Where("posyandu_id = ? AND status = ?", posyanduID, "aktif").
		Find(&bidanList).Error
	return bidanList, err
}

// GetPendudukByPosyandu mendapatkan semua penduduk di posyandu
func (r *PosyanduRepository) GetPendudukByPosyandu(posyanduID int32) ([]models.Kependudukan, error) {
	var pendudukList []models.Kependudukan
	err := r.db.Where("posyandu_id = ?", posyanduID).
		Find(&pendudukList).Error
	return pendudukList, err
}

// CountPendudukByPosyandu menghitung jumlah penduduk di posyandu
func (r *PosyanduRepository) CountPendudukByPosyandu(posyanduID int32) (int64, error) {
	var count int64
	err := r.db.Model(&models.Kependudukan{}).
		Where("posyandu_id = ?", posyanduID).
		Count(&count).Error
	return count, err
}

// CountBidanByPosyandu menghitung jumlah bidan aktif di posyandu
func (r *PosyanduRepository) CountBidanByPosyandu(posyanduID int32) (int64, error) {
	var count int64
	err := r.db.Model(&models.Bidan{}).
		Where("posyandu_id = ? AND status = ?", posyanduID, "aktif").
		Count(&count).Error
	return count, err
}