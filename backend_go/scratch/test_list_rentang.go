package main

// import (
// 	"fmt"
// 	"log"
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

// 	type RentangUsia struct {
// 		ID          uint
// 		NamaRentang string
// 		SatuanWaktu string
// 		MaxPeriode  int
// 	}

// 	var rentangs []RentangUsia
// 	if err := db.Table("rentang_usia").Find(&rentangs).Error; err != nil {
// 		log.Fatalf("query rentang_usia failed: %v", err)
// 	}

// 	fmt.Println("=== rentang_usia table ===")
// 	for _, r := range rentangs {
// 		fmt.Printf("ID: %d | NamaRentang: %s | SatuanWaktu: %s | MaxPeriode: %d\n", r.ID, r.NamaRentang, r.SatuanWaktu, r.MaxPeriode)
// 	}

// 	// Also check if there's other tables like 'rentang_perkembangan' or similar
// 	var tableNames []string
// 	db.Raw("SELECT table_name FROM information_schema.tables WHERE table_schema='public'").Scan(&tableNames)
// 	fmt.Println("\n=== public tables ===")
// 	for _, t := range tableNames {
// 		fmt.Println(t)
// 	}
// }
