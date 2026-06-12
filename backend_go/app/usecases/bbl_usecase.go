package usecases

import (
	"monitoring-service/app/models"
	"monitoring-service/app/repositories"
)

type BblUsecase interface {
	GetByAnakID(anakID uint) (*models.Bbl, error)
	Upsert(bbl *models.Bbl) error
	Verify(bblID uint, kaderID uint, periodeWaktu string, status string) (*models.Bbl, error)
	GetAll() ([]models.Bbl, error)
}

type bblUsecase struct {
	bblRepo repositories.BblRepository
}

func NewBblUsecase(bblRepo repositories.BblRepository) BblUsecase {
	return &bblUsecase{
		bblRepo: bblRepo,
	}
}

func (u *bblUsecase) GetByAnakID(anakID uint) (*models.Bbl, error) {
	return u.bblRepo.GetByAnakID(anakID)
}

func (u *bblUsecase) Upsert(bbl *models.Bbl) error {
	return u.bblRepo.Upsert(bbl)
}

func (u *bblUsecase) Verify(bblID uint, kaderID uint, periodeWaktu string, status string) (*models.Bbl, error) {
	if err := u.bblRepo.Verify(bblID, kaderID, periodeWaktu, status); err != nil {
		return nil, err
	}
	return u.bblRepo.GetByID(bblID)
}

func (u *bblUsecase) GetAll() ([]models.Bbl, error) {
	return u.bblRepo.GetAll()
}

