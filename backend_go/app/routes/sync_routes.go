package routes

import (
	"monitoring-service/app/controllers"
	"monitoring-service/app/repositories"
	"monitoring-service/app/usecases"

	"github.com/labstack/echo/v4"
	"gorm.io/gorm"
)

// SetupSyncIbuRoutes mendaftarkan endpoint sinkronisasi eksklusif untuk aplikasi Ibu
func SetupSyncIbuRoutes(ibuGroup *echo.Group, db *gorm.DB) {
	syncRepo := repositories.NewSyncRepository(db)
	syncUsecase := usecases.NewSyncUsecase(syncRepo)
	syncController := controllers.NewSyncController(syncUsecase)

	// URL akhir di Flutter: /ibu/sync/bulk
	ibuGroup.POST("/sync/bulk", syncController.HandleBulkPush)

	// URL akhir di Flutter: /ibu/sync/pull
	ibuGroup.GET("/sync/pull", syncController.HandleBulkPull)
}