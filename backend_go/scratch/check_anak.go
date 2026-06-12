package main

// import (
// 	"fmt"
// 	"log"
// 	"time"

// 	"gorm.io/driver/postgres"
// 	"gorm.io/gorm"
// )

// type Anak struct {
// 	ID           int32     `gorm:"primaryKey"`
// 	PendudukID   int32     `gorm:"column:penduduk_id"`
// 	TanggalLahir time.Time `gorm:"column:tanggal_lahir"`
// 	// We'll also read the relationship if needed, or query separately
// }

// func (Anak) TableName() string {
// 	return "anak"
// }

// type PrediksiStunting struct {
// 	ID             int32     `gorm:"primaryKey"`
// 	AnakID         int32     `gorm:"column:anak_id"`
// 	StatusPrediksi string    `gorm:"column:status_prediksi"`
// 	CreatedAt      time.Time `gorm:"column:created_at"`
// }

// func (PrediksiStunting) TableName() string {
// 	return "prediksi_stunting"
// }

// func main() {
// 	dsn := "postgresql://postgres.vnwpsqadeavtsesrvuii:L*j9BcYkRXE4rq@@aws-1-ap-south-1.pooler.supabase.com:6543/postgres"
// 	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
// 	if err != nil {
// 		log.Fatalf("Failed to connect database: %v", err)
// 	}
// 	fmt.Println("Connected to database!")

// 	var anaks []Anak
// 	if err := db.Find(&anaks).Error; err != nil {
// 		log.Fatalf("Error finding anaks: %v", err)
// 	}
// 	fmt.Printf("Total anaks in db: %d\n", len(anaks))
// 	for _, a := range anaks {
// 		fmt.Printf("Anak ID: %d, Penduduk ID: %d, Tanggal Lahir: %s\n", a.ID, a.PendudukID, a.TanggalLahir.Format("2006-01-02"))
// 	}

// 	var preds []PrediksiStunting
// 	if err := db.Find(&preds).Error; err != nil {
// 		log.Fatalf("Error finding predictions: %v", err)
// 	}
// 	fmt.Printf("Total predictions in db: %d\n", len(preds))
// 	for _, p := range preds {
// 		fmt.Printf("Prediction ID: %d, Anak ID: %d, Status: %s, Created: %s\n", p.ID, p.AnakID, p.StatusPrediksi, p.CreatedAt.Format("2006-01-02 15:04:05"))
// 	}
// }
