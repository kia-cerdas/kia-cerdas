package repositories

import (
	"monitoring-service/app/models"

	"gorm.io/gorm"
)

type PencatatanImunisasiRepository struct {
	postgres *gorm.DB
}

func NewPencatatanImunisasiRepository(postgres *gorm.DB) *PencatatanImunisasiRepository {
	return &PencatatanImunisasiRepository{postgres: postgres}
}

// CreatePencatatanImunisasi inserts a new pencatatan record
func (r *PencatatanImunisasiRepository) Create(data *models.PencatatanImunisasi) error {
	return r.postgres.Create(data).Error
}

// GetPencatatanImunisasiByAnakID retrieves all pencatatan records for a given anak
// by joining through jadwal_imunisasi_anak
func (r *PencatatanImunisasiRepository) GetByAnakID(anakID uint) ([]models.PencatatanImunisasi, error) {
	var records []models.PencatatanImunisasi

	// First, get the jadwal IDs for this anak
	var jadwalIDs []uint
	err := r.postgres.
		Table("jadwal_imunisasi_anak").
		Where("id_anak = ?", anakID).
		Pluck("id", &jadwalIDs).Error
	if err != nil {
		return nil, err
	}

	if len(jadwalIDs) == 0 {
		return records, nil
	}

	// Then fetch pencatatan records matching those jadwal IDs
	err = r.postgres.
		Preload("JadwalImunisasiAnak").
		Preload("JadwalImunisasiAnak.DosisVaksin").
		Preload("BidanPetugas").
		Where("id_jadwal_imunisasi_anak IN ?", jadwalIDs).
		Order("id ASC").
		Find(&records).Error

	if err != nil {
		return nil, err
	}

	return records, nil
}

// SetSelesai marks a pencatatan record as completed
func (r *PencatatanImunisasiRepository) SetSelesai(id uint) error {
	return r.postgres.
		Model(&models.PencatatanImunisasi{}).
		Where("id = ?", id).
		Update("is_selesai", true).Error
}

// Cancel deletes (soft-delete) a pencatatan record by jadwal_imunisasi_anak ID
func (r *PencatatanImunisasiRepository) CancelByJadwalID(jadwalID uint) error {
	return r.postgres.
		Where("id_jadwal_imunisasi_anak = ?", jadwalID).
		Delete(&models.PencatatanImunisasi{}).Error
}

// GetByID retrieves a single pencatatan record by ID
func (r *PencatatanImunisasiRepository) GetByID(id uint) (*models.PencatatanImunisasi, error) {
	var record models.PencatatanImunisasi

	err := r.postgres.
		Preload("JadwalImunisasiAnak").
		Preload("JadwalImunisasiAnak.DosisVaksin").
		First(&record, id).Error

	if err != nil {
		return nil, err
	}

	return &record, nil
}

// GetJadwalByID retrieves jadwal imunisasi anak with complete nested data
func (r *PencatatanImunisasiRepository) GetJadwalByID(jadwalID uint) (*models.JadwalImunisasiAnak, error) {
	var jadwal models.JadwalImunisasiAnak

	err := r.postgres.
		Preload("Anak").
		Preload("Anak.Penduduk").
		Preload("DosisVaksin").
		First(&jadwal, jadwalID).Error

	if err != nil {
		return nil, err
	}

	return &jadwal, nil
}
