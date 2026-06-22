package main

import (
	"fmt"
	"log"
	"os"

	"github.com/joho/godotenv"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func main() {
	// Load file .env
	err := godotenv.Load()
	if err != nil {
		log.Println("⚠️ Peringatan: tidak dapat memuat .env, gunakan variabel environment sistem")
	}

	// Ambil DSN dari environment
	dsn := os.Getenv("DB_POSTGRES_DSN")
	if dsn == "" {
		log.Fatal("❌ DB_POSTGRES_DSN tidak ditemukan di .env")
	}
	log.Println("🔌 Mencoba koneksi ke database...")

	// Koneksi ke database
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatalf("❌ Gagal koneksi database: %v", err)
	}
	log.Println("✅ Koneksi database berhasil")

	// Fix the sequence for pemeriksaan_kehamilan table
	log.Println("🔄 Memperbaiki sequence untuk pemeriksaan_kehamilan table...")

	// Get the maximum ID from the table
	var maxID int
	db.Raw("SELECT COALESCE(MAX(id_periksa), 0) FROM pemeriksaan_kehamilan").Scan(&maxID)
	log.Printf("📊 Current max ID: %d", maxID)

	// Set the sequence to the max ID + 1
	newSequenceValue := maxID + 1
	sql := fmt.Sprintf("SELECT setval('pemeriksaan_kehamilan_id_periksa_seq', %d, false)", newSequenceValue)
	
	if err := db.Exec(sql).Error; err != nil {
		log.Printf("⚠️ Gagal memperbaiki sequence (mungkin sequence tidak ada): %v", err)
		log.Println("🔄 Mencoba membuat sequence baru...")
		
		// Try to create the sequence if it doesn't exist
		createSeqSQL := fmt.Sprintf("CREATE SEQUENCE IF NOT EXISTS pemeriksaan_kehamilan_id_periksa_seq START %d", newSequenceValue)
		if err := db.Exec(createSeqSQL).Error; err != nil {
			log.Printf("⚠️ Gagal membuat sequence: %v", err)
		} else {
			log.Println("✅ Sequence baru berhasil dibuat")
		}
	} else {
		log.Printf("✅ Sequence berhasil diperbaiki ke nilai: %d", newSequenceValue)
	}

	// Verify the sequence
	var currentSequenceValue int
	db.Raw("SELECT nextval('pemeriksaan_kehamilan_id_periksa_seq')").Scan(&currentSequenceValue)
	log.Printf("📊 Current sequence value: %d", currentSequenceValue)

	// Reset the sequence to the correct value (since nextval increments it)
	resetSQL := fmt.Sprintf("SELECT setval('pemeriksaan_kehamilan_id_periksa_seq', %d, false)", newSequenceValue)
	db.Exec(resetSQL)

	log.Println("🎉 Perbaikan sequence selesai")
}
