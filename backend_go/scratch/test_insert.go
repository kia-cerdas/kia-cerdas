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
// 	testData := &models.KategoriCapaian{
// 		RentangUsia:        "TEST RENTANG",
// 		PertanyaaanCeklist: "Test Pertanyaan Ceklist",
// 		Aspek:              "Test Aspek",
// 	}
// 	err = db.Create(testData).Error
// 	if err != nil {
// 		fmt.Printf("INSERT ERROR: %v\n", err)
// 	} else {
// 		fmt.Printf("INSERT SUCCESS: created record with ID %d\n", testData.ID)
// 		// clean it up
// 		db.Delete(testData)
// 	}
// }
