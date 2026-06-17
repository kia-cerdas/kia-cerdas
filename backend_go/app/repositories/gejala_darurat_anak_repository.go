package repositories

import (
	"monitoring-service/app/models"

	"gorm.io/gorm"
)

type GejalaDaruratAnakRepository interface {
	Create(riwayat *models.RiwayatDeteksi) error
	GetByAnakID(anakID uint) ([]models.RiwayatDeteksi, error)
}

type gejalaDaruratAnakRepository struct {
	db *gorm.DB
}

func NewGejalaDaruratAnakRepository(db *gorm.DB) GejalaDaruratAnakRepository {
	return &gejalaDaruratAnakRepository{db: db}
}

func (r *gejalaDaruratAnakRepository) Create(riwayat *models.RiwayatDeteksi) error {
	return r.db.Create(riwayat).Error
}

func (r *gejalaDaruratAnakRepository) GetByAnakID(anakID uint) ([]models.RiwayatDeteksi, error) {
	var riwayat []models.RiwayatDeteksi
	err := r.db.Preload("DetailJawaban").
		Where("anak_id = ?", anakID).
		Order("tanggal_periksa DESC, id DESC").
		Find(&riwayat).Error
	return riwayat, err
}
