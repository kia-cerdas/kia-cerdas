package usecases

import (
	"monitoring-service/app/models"
	"monitoring-service/app/repositories"
)

type PemeriksaanAnakUsecase interface {
	Create(data *models.PemeriksaanAnak) error
	GetAll() ([]models.PemeriksaanAnak, error)
	GetByID(id int32) (*models.PemeriksaanAnak, error)
	Update(data *models.PemeriksaanAnak) error
	Delete(id int32) error
	GetLatestRiskCountByPendudukIDs(pendudukIDs []int32) (map[string]int, error)
	CountPendudukWithExamination(pendudukIDs []int32) (int64, error)
}

type pemeriksaanAnakUsecase struct {
	repo repositories.PemeriksaanAnakRepository
}

func NewPemeriksaanAnakUsecase(
	repo repositories.PemeriksaanAnakRepository,
) PemeriksaanAnakUsecase {
	return &pemeriksaanAnakUsecase{
		repo: repo,
	}
}

func (u *pemeriksaanAnakUsecase) Create(data *models.PemeriksaanAnak) error {
	return u.repo.Create(data)
}

func (u *pemeriksaanAnakUsecase) GetAll() ([]models.PemeriksaanAnak, error) {
	return u.repo.GetAll()
}

func (u *pemeriksaanAnakUsecase) GetByID(id int32) (*models.PemeriksaanAnak, error) {
	return u.repo.GetByID(id)
}

func (u *pemeriksaanAnakUsecase) Update(data *models.PemeriksaanAnak) error {
	return u.repo.Update(data)
}

func (u *pemeriksaanAnakUsecase) Delete(id int32) error {
	return u.repo.Delete(id)
}
func (u *pemeriksaanAnakUsecase) GetLatestRiskCountByPendudukIDs(pendudukIDs []int32) (map[string]int, error) {
	return u.repo.GetLatestRiskCountByPendudukIDs(pendudukIDs)
}

func (u *pemeriksaanAnakUsecase) CountPendudukWithExamination(pendudukIDs []int32) (int64, error) {
    return u.repo.CountPendudukWithExamination(pendudukIDs)
}