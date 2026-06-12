package main

// import (
// 	"fmt"
// 	"log"
// 	"time"

// 	"gorm.io/driver/postgres"
// 	"gorm.io/gorm"
// )

// type Neonatus struct {
// 	ID                int32     `gorm:"primaryKey;autoIncrement"`
// 	AnakID            int32     `gorm:"not null;index"`
// 	Tanggal           time.Time `gorm:"not null"`
// 	KategoriUmurID    int32     `gorm:"not null;index"`
// 	PeriodeID         int32     `gorm:"not null;index"`
// 	TenagaKesehatanID int32     `gorm:"not null;index"`
// 	CreatedAt         time.Time
// 	UpdatedAt         time.Time
// }

// func (Neonatus) TableName() string {
// 	return "Neonatus"
// }

// func main() {
// 	dsn := "postgresql://postgres.tkjglvmcdgtbsdnksbfe:v8oCdSJaydG949GG@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres"
// 	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
// 	if err != nil {
// 		log.Fatalf("Failed to connect database: %v", err)
// 	}
// 	fmt.Println("Connected to database!")

// 	// 1. Check if Neonatus table exists and get its columns
// 	var exists bool
// 	err = db.Raw("SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'Neonatus')").Scan(&exists).Error
// 	if err != nil {
// 		log.Fatalf("Error checking table: %v", err)
// 	}
// 	fmt.Printf("Table Neonatus exists: %t\n", exists)

// 	// 2. Try inserting a mock row and print the exact GORM/DB error
// 	neo := Neonatus{
// 		AnakID:            1,
// 		Tanggal:           time.Now(),
// 		KategoriUmurID:    1,
// 		PeriodeID:         1,
// 		TenagaKesehatanID: 1,
// 		CreatedAt:         time.Now(),
// 		UpdatedAt:         time.Now(),
// 	}
// 	err = db.Create(&neo).Error
// 	if err != nil {
// 		fmt.Printf("DB CREATE ERROR: %v\n", err)
// 	} else {
// 		fmt.Printf("DB CREATE SUCCESS! ID: %d\n", neo.ID)
// 		// Delete it immediately
// 		db.Delete(&neo)
// 	}
// }
