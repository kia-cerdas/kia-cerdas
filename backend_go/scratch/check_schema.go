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

// 	rows, err := db.Raw(`
// 		SELECT column_name, data_type, is_nullable
// 		FROM information_schema.columns
// 		WHERE table_name = 'kategori_capaian'
// 	`).Rows()
// 	if err != nil {
// 		log.Fatalf("failed query schema: %v", err)
// 	}
// 	defer rows.Close()

// 	fmt.Println("Table: kategori_capaian")
// 	for rows.Next() {
// 		var columnName, dataType, isNullable string
// 		if err := rows.Scan(&columnName, &dataType, &isNullable); err != nil {
// 			log.Fatal(err)
// 		}
// 		fmt.Printf("- %s: %s (Nullable: %s)\n", columnName, dataType, isNullable)
// 	}
// }
