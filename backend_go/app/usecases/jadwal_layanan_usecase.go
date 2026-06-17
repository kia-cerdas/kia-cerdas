package usecases

import (
	"time"

	"monitoring-service/app/models"
	"monitoring-service/app/repositories"
)

type JadwalLayananUsecase interface {
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

type jadwalLayananUsecase struct {
	repo repositories.JadwalLayananRepository
}

func NewJadwalLayananUsecase(r repositories.JadwalLayananRepository) JadwalLayananUsecase {
	return &jadwalLayananUsecase{repo: r}
}

func (u *jadwalLayananUsecase) Create(data *models.JadwalLayanan, dosisVaksinIDs []uint) error {
	return u.repo.Create(data, dosisVaksinIDs)
}

func (u *jadwalLayananUsecase) GetAll(desaID *int32) ([]models.JadwalLayanan, error) {
	return u.repo.GetAll(desaID)
}

func (u *jadwalLayananUsecase) GetByID(id int32) (*models.JadwalLayanan, error) {
	return u.repo.GetByID(id)
}

func (u *jadwalLayananUsecase) GetByPosyandu(posyanduID int32) ([]models.JadwalLayanan, error) {
	return u.repo.GetByPosyandu(posyanduID)
}

func (u *jadwalLayananUsecase) GetByDateRange(posyanduID *int32, from, to *time.Time, desaID *int32) ([]models.JadwalLayanan, error) {
	return u.repo.GetByDateRange(posyanduID, from, to, desaID)
}

func (u *jadwalLayananUsecase) GetUpcoming(limit int, desaID *int32) ([]models.JadwalLayanan, error) {
	return u.repo.GetUpcoming(limit, desaID)
}

func (u *jadwalLayananUsecase) Update(id int32, data *models.JadwalLayanan, dosisVaksinIDs []uint) error {
	return u.repo.Update(id, data, dosisVaksinIDs)
}

func (u *jadwalLayananUsecase) Delete(id int32) error {
	return u.repo.Delete(id)
}

func (u *jadwalLayananUsecase) CheckExistsByDate(tanggal time.Time, excludeID *int32) (bool, error) {
	return u.repo.CheckExistsByDate(tanggal, excludeID)
}
