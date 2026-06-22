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

	// Run the migration SQL
	log.Println("🔄 Menjalankan migration ML prediction fields...")

	// Add new columns for ML prediction results
	sql := `
	ALTER TABLE pemeriksaan_kehamilan
	ADD COLUMN IF NOT EXISTS overall_prediction INTEGER DEFAULT 0,
	ADD COLUMN IF NOT EXISTS overall_label VARCHAR(20) DEFAULT 'NORMAL',
	ADD COLUMN IF NOT EXISTS active_risk_count INTEGER DEFAULT 0,
	ADD COLUMN IF NOT EXISTS alasan_klinis TEXT,
	ADD COLUMN IF NOT EXISTS rekomendasi_utama TEXT,
	ADD COLUMN IF NOT EXISTS risk_types TEXT;

	-- Update existing records to have default values
	UPDATE pemeriksaan_kehamilan
	SET overall_prediction = 0,
	    overall_label = 'NORMAL',
	    active_risk_count = 0
	WHERE overall_prediction IS NULL;
	`

	if err := db.Exec(sql).Error; err != nil {
		log.Fatalf("❌ Gagal menjalankan migration: %v", err)
	}

	log.Println("✅ Migration ML prediction fields berhasil ditambahkan")

	// Verify the columns were added
	log.Println("🔍 Verifikasi kolom...")
	var columnCount int
	db.Raw(`
		SELECT COUNT(*) 
		FROM information_schema.columns 
		WHERE table_name = 'pemeriksaan_kehamilan' 
		AND column_name IN ('overall_prediction', 'overall_label', 'active_risk_count', 'alasan_klinis', 'rekomendasi_utama', 'risk_types')
	`).Scan(&columnCount)

	if columnCount == 6 {
		log.Printf("✅ Semua 6 kolom baru berhasil ditambahkan dan terverifikasi")
	} else {
		log.Printf("⚠️ Hanya %d dari 6 kolom yang ditemukan", columnCount)
	}

	log.Println("🎉 Migration selesai. Database sudah siap untuk model ML baru.")
	fmt.Println("\n📊 Kolom yang ditambahkan:")
	fmt.Println("   - overall_prediction (INTEGER)")
	fmt.Println("   - overall_label (VARCHAR(20))")
	fmt.Println("   - active_risk_count (INTEGER)")
	fmt.Println("   - alasan_klinis (TEXT)")
	fmt.Println("   - rekomendasi_utama (TEXT)")
	fmt.Println("   - risk_types (TEXT)")
}
