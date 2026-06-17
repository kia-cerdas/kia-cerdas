package usecases

import (
	"monitoring-service/app/models"
	"monitoring-service/app/repositories"
)

type VaksinUsecase interface {
	GetAll() ([]models.Vaksin, error)
	GetByID(id uint) (*models.Vaksin, error)
	Create(data *models.Vaksin) error
	Update(data *models.Vaksin) error
	Delete(id uint) error
}

type vaksinUsecase struct {
	repo repositories.VaksinRepository
}

func NewVaksinUsecase(r repositories.VaksinRepository) VaksinUsecase {
	return &vaksinUsecase{repo: r}
}

func (u *vaksinUsecase) GetAll() ([]models.Vaksin, error) {
	return u.repo.GetAll()
}

func (u *vaksinUsecase) GetByID(id uint) (*models.Vaksin, error) {
	return u.repo.GetByID(id)
}

func (u *vaksinUsecase) Create(data *models.Vaksin) error {
	return u.repo.Create(data)
}

func (u *vaksinUsecase) Update(data *models.Vaksin) error {
	return u.repo.Update(data)
}

func (u *vaksinUsecase) Delete(id uint) error {
	return u.repo.Delete(id)
}
