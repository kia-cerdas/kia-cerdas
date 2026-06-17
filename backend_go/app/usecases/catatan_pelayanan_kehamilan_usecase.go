package usecases

import (
	"context"
	"monitoring-service/app/models"
	"monitoring-service/app/repositories"
)

type CatatanPelayananKehamilanUsecase interface {
	GetMine(ctx context.Context, userID int32, trimester int8) ([]models.CatatanPelayananKehamilan, error)
}

type catatanPelayananKehamilanUsecase struct {
	repo *repositories.CatatanPelayananKehamilanRepository
}

func NewCatatanPelayananKehamilanUsecase(repo *repositories.CatatanPelayananKehamilanRepository) CatatanPelayananKehamilanUsecase {
	return &catatanPelayananKehamilanUsecase{repo: repo}
}

func (u *catatanPelayananKehamilanUsecase) GetMine(ctx context.Context, userID int32, trimester int8) ([]models.CatatanPelayananKehamilan, error) {
	return u.repo.FindMineByUserID(userID, trimester)
}
