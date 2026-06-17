package usecases

import (
	"monitoring-service/app/models"
	"monitoring-service/app/repositories"
)

type DosisVaksinUsecase interface {
	GetAll() ([]models.DosisVaksin, error)
	GetByID(id uint) (*models.DosisVaksin, error)
	GetByVaksinID(vaksinID uint) ([]models.DosisVaksin, error)
	Create(data *models.DosisVaksin) error
	Update(data *models.DosisVaksin) error
	Delete(id uint) error
}

type dosisVaksinUsecase struct {
	repo repositories.DosisVaksinRepository
}

func NewDosisVaksinUsecase(r repositories.DosisVaksinRepository) DosisVaksinUsecase {
	return &dosisVaksinUsecase{repo: r}
}

func (u *dosisVaksinUsecase) GetAll() ([]models.DosisVaksin, error) {
	return u.repo.GetAll()
}

func (u *dosisVaksinUsecase) GetByID(id uint) (*models.DosisVaksin, error) {
	return u.repo.GetByID(id)
}

func (u *dosisVaksinUsecase) GetByVaksinID(vaksinID uint) ([]models.DosisVaksin, error) {
	return u.repo.GetByVaksinID(vaksinID)
}

func (u *dosisVaksinUsecase) Create(data *models.DosisVaksin) error {
	return u.repo.Create(data)
}

func (u *dosisVaksinUsecase) Update(data *models.DosisVaksin) error {
	return u.repo.Update(data)
}

func (u *dosisVaksinUsecase) Delete(id uint) error {
	return u.repo.Delete(id)
}
