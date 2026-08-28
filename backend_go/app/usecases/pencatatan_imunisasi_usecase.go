package usecases

import (
	"monitoring-service/app/models"
	"monitoring-service/app/repositories"
)

type PencatatanImunisasiUsecase struct {
	repo *repositories.PencatatanImunisasiRepository
}

func NewPencatatanImunisasiUsecase(repo *repositories.PencatatanImunisasiRepository) *PencatatanImunisasiUsecase {
	return &PencatatanImunisasiUsecase{repo: repo}
}

// Create stores a new pencatatan imunisasi record
func (u *PencatatanImunisasiUsecase) Create(data *models.PencatatanImunisasi) error {
	return u.repo.Create(data)
}

// GetByAnakID retrieves all pencatatan records for a child
func (u *PencatatanImunisasiUsecase) GetByAnakID(anakID uint) ([]models.PencatatanImunisasi, error) {
	return u.repo.GetByAnakID(anakID)
}

// SetSelesai marks a pencatatan record as completed
func (u *PencatatanImunisasiUsecase) SetSelesai(id uint) error {
	return u.repo.SetSelesai(id)
}

// GetByID retrieves a single pencatatan record
func (u *PencatatanImunisasiUsecase) GetByID(id uint) (*models.PencatatanImunisasi, error) {
	return u.repo.GetByID(id)
}

// CancelByJadwalID soft-deletes pencatatan record(s) for a given jadwal
func (u *PencatatanImunisasiUsecase) CancelByJadwalID(jadwalID uint) error {
	return u.repo.CancelByJadwalID(jadwalID)
}

// GetByJadwalID retrieves jadwal imunisasi anak with complete data for calculating kategori
func (u *PencatatanImunisasiUsecase) GetByJadwalID(jadwalID uint) (*models.JadwalImunisasiAnak, error) {
	return u.repo.GetJadwalByID(jadwalID)
}
