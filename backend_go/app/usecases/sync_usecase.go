package usecases

import (
	"context"
	"monitoring-service/app/models"
	"monitoring-service/app/repositories"
)

type SyncUsecase interface {
	SyncDataOffline(ctx context.Context, req models.SyncPushRequest) error
	GetBulkPullData(ctx context.Context) (map[string]interface{}, error)
}

type syncUsecase struct {
	syncRepo repositories.SyncRepository
}

func NewSyncUsecase(repo repositories.SyncRepository) SyncUsecase {
	return &syncUsecase{syncRepo: repo}
}

// 1. Menangani Alur Bisnis untuk PUSH Data dari Flutter
func (u *syncUsecase) SyncDataOffline(ctx context.Context, req models.SyncPushRequest) error {
	return u.syncRepo.ProcessBulkSync(ctx, req)
}

// 2. Menangani Alur Bisnis untuk PULL Data ke Flutter
func (u *syncUsecase) GetBulkPullData(ctx context.Context) (map[string]interface{}, error) {
	return u.syncRepo.GetBulkPullData(ctx)
}