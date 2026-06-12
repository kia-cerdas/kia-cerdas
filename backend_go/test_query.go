package main

import (
	"fmt"
	"log"
	"monitoring-service/app/models"
	"monitoring-service/pkg/config"
	"monitoring-service/pkg/database"

	"github.com/spf13/viper"
)

func main() {
	viper.SetConfigFile(".env")
	if err := viper.ReadInConfig(); err != nil {
		log.Fatalf("failed read config: %v", err)
	}

	cfg := config.NewConfig()

	db, err := database.GetConnection(cfg.Postgres().Read.ToArgs(database.Postgres, database.ReadConn, nil))
	if err != nil {
		log.Fatalf("failed connect db: %v", err)
	}

	var count int64
	if err := db.Model(&models.MasterStandarAntropometri{}).Count(&count).Error; err != nil {
		log.Fatalf("query count failed: %v", err)
	}
	fmt.Printf("Total Master Standar Antropometri: %d\n", count)

	var samples []models.MasterStandarAntropometri
	if err := db.Limit(5).Find(&samples).Error; err != nil {
		log.Fatalf("query samples failed: %v", err)
	}
	for i, s := range samples {
		fmt.Printf("Sample %d: Param: %s, Gender: %s, SumbuX: %f, Median: %f, SD2Neg: %f, SD2Pos: %f\n",
			i+1, s.Parameter, s.JenisKelamin, s.NilaiSumbuX, s.Median, s.SD2Neg, s.SD2Pos)
	}

	// check an child (anak) gender representation in database
	var child models.Anak
	if err := db.Preload("Penduduk").First(&child).Error; err == nil {
		fmt.Printf("First Child: ID=%d, Nama=%s, Gender=%s\n", child.ID, child.Penduduk.NamaLengkap, child.Penduduk.JenisKelamin)
	} else {
		fmt.Printf("Error getting child: %v\n", err)
	}
}
