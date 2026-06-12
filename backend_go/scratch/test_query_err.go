package main

// import (
// 	"fmt"
// 	"log"
// 	"monitoring-service/app/models"
// 	"monitoring-service/pkg/config"
// 	"monitoring-service/pkg/database"

// 	"github.com/spf13/viper"
// )

// func main() {
// 	viper.SetConfigFile(".env")
// 	if err := viper.ReadInConfig(); err != nil {
// 		log.Fatalf("failed read config: %v", err)
// 	}

// 	cfg := config.NewConfig()

// 	db, err := database.GetConnection(cfg.Postgres().Read.ToArgs(database.Postgres, database.ReadConn, nil))
// 	if err != nil {
// 		log.Fatalf("failed connect db: %v", err)
// 	}

// 	var data []models.KategoriCapaian
// 	rentang := "0-3 BULAN"
// 	err = db.
// 		Joins("JOIN rentang_usia ON rentang_usia.id = kategori_capaian.rentang_usia_id").
// 		Where("rentang_usia.nama_rentang = ? OR rentang_usia.id = ? OR CAST(kategori_capaian.rentang_usia_id AS VARCHAR) = ?", rentang, rentang, rentang).
// 		Preload("RentangUsia").
// 		Order("kategori_capaian.id").
// 		Find(&data).Error

// 	if err != nil {
// 		fmt.Printf("QUERY ERROR: %v\n", err)
// 	} else {
// 		fmt.Printf("QUERY SUCCESS: fetched %d rows\n", len(data))
// 	}
// }
