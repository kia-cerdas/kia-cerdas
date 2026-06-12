package usecases

import (
	"monitoring-service/app/models"
	"monitoring-service/app/repositories"
)

type PemeriksaanDewasaUsecase interface {
	Create(data *models.PemeriksaanDewasa) error
	GetAll() ([]models.PemeriksaanDewasa, error)
	GetByID(id int32) (*models.PemeriksaanDewasa, error)
	Update(data *models.PemeriksaanDewasa) error
	Delete(id int32) error
	GetLatestRiskCountByPendudukIDs(pendudukIDs []int32) (map[string]int, error)
	CountPendudukWithExamination(pendudukIDs []int32) (int64, error)
}

type pemeriksaanDewasaUsecase struct {
	repo repositories.PemeriksaanDewasaRepository
}

func NewPemeriksaanDewasaUsecase(
	repo repositories.PemeriksaanDewasaRepository,
) PemeriksaanDewasaUsecase {
	return &pemeriksaanDewasaUsecase{
		repo: repo,
	}
}

func (u *pemeriksaanDewasaUsecase) Create(data *models.PemeriksaanDewasa) error {
	return u.repo.Create(data)
}

func (u *pemeriksaanDewasaUsecase) GetAll() ([]models.PemeriksaanDewasa, error) {
	return u.repo.GetAll()
}

func (u *pemeriksaanDewasaUsecase) GetByID(id int32) (*models.PemeriksaanDewasa, error) {
	return u.repo.GetByID(id)
}

func (u *pemeriksaanDewasaUsecase) Update(data *models.PemeriksaanDewasa) error {
	return u.repo.Update(data)
}

func (u *pemeriksaanDewasaUsecase) Delete(id int32) error {
	return u.repo.Delete(id)
}
func (u *pemeriksaanDewasaUsecase) GetLatestRiskCountByPendudukIDs(pendudukIDs []int32) (map[string]int, error) {
    return u.repo.GetLatestRiskCountByPendudukIDs(pendudukIDs)
}
func (u *pemeriksaanDewasaUsecase) CountPendudukWithExamination(pendudukIDs []int32) (int64, error) {
    return u.repo.CountPendudukWithExamination(pendudukIDs)
}