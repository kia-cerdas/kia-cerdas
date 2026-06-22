package main

// import (
// 	"fmt"
// 	"log"
// 	"monitoring-service/pkg/config"
// 	"monitoring-service/pkg/database"

// 	"gorm.io/gorm"
// )

// func main() {
// 	// Load configuration
// 	cfg := config.NewConfig()

// 	// Get PostgreSQL write connection config
// 	postgresConfig := cfg.Database.Postgres.Write

// 	// Convert to database args
// 	dbArgs := &database.Args{
// 		DSN:             postgresConfig.DSN,
// 		Username:        postgresConfig.Username,
// 		Password:        postgresConfig.Password,
// 		Host:            postgresConfig.URL,
// 		Port:            postgresConfig.Port,
// 		Database:        postgresConfig.Name,
// 		Schema:          postgresConfig.Schema,
// 		Flavor:          postgresConfig.Flavor,
// 		MaxIdleConns:    postgresConfig.MaxIdleConns,
// 		MaxOpenConns:    postgresConfig.MaxOpenConns,
// 		ConnMaxLifetime: postgresConfig.MaxLifetime,
// 		Location:        postgresConfig.Location,
// 		Timeout:         postgresConfig.Timeout,
// 		DBType:          database.Postgres,
// 		ConnType:        database.WriteConn,
// 	}

// 	// Initialize database connection
// 	db, err := database.GetConnection(dbArgs)
// 	if err != nil {
// 		log.Fatalf("Failed to connect to database: %v", err)
// 	}

// 	// Run migration
// 	if err := migrateRujukanSource(db); err != nil {
// 		log.Fatalf("Migration failed: %v", err)
// 	}

// 	// Run catatan trimester migration
// 	if err := migrateCatatanTrimester(db); err != nil {
// 		log.Fatalf("Catatan trimester migration failed: %v", err)
// 	}

// 	fmt.Println("Migration completed successfully!")
// }

// func migrateRujukanSource(db *gorm.DB) error {
// 	// Check if column exists
// 	var columnExists bool
// 	err := db.Raw(`
// 		SELECT EXISTS (
// 			SELECT 1
// 			FROM information_schema.columns
// 			WHERE table_name = 'rujukan'
// 			AND column_name = 'source'
// 		)
// 	`).Scan(&columnExists).Error

// 	if err != nil {
// 		return fmt.Errorf("failed to check column existence: %w", err)
// 	}

// 	if columnExists {
// 		fmt.Println("Column 'source' already exists in rujukan table")
// 		return nil
// 	}

// 	// Add the column
// 	err = db.Exec(`
// 		ALTER TABLE rujukan
// 		ADD COLUMN source VARCHAR(50) DEFAULT 'anc'
// 	`).Error

// 	if err != nil {
// 		return fmt.Errorf("failed to add source column: %w", err)
// 	}

// 	// Update existing records
// 	err = db.Exec(`
// 		UPDATE rujukan SET source = 'anc' WHERE source IS NULL OR source = ''
// 	`).Error

// 	if err != nil {
// 		return fmt.Errorf("failed to update existing records: %w", err)
// 	}

// 	// Create index for better filtering performance
// 	err = db.Exec(`
// 		CREATE INDEX IF NOT EXISTS idx_rujukan_source ON rujukan(source)
// 	`).Error

// 	if err != nil {
// 		return fmt.Errorf("failed to create index: %w", err)
// 	}

// 	fmt.Println("Successfully added 'source' column to rujukan table")
// 	return nil
// }

// func migrateCatatanTrimester(db *gorm.DB) error {
// 	// Add catatan fields to pemeriksaan_dokter_trimester_1
// 	err := db.Exec(`
// 		ALTER TABLE pemeriksaan_dokter_trimester_1
// 		ADD COLUMN IF NOT EXISTS tanggal_periksa_stamp_paraf DATE NULL,
// 		ADD COLUMN IF NOT EXISTS keluhan_pemeriksaan_tindakan_saran TEXT NULL,
// 		ADD COLUMN IF NOT EXISTS tanggal_kembali DATE NULL
// 	`).Error
// 	if err != nil {
// 		return fmt.Errorf("failed to add catatan fields to trimester 1: %w", err)
// 	}
// 	fmt.Println("Successfully added catatan fields to pemeriksaan_dokter_trimester_1")

// 	// Add catatan fields to pemeriksaan_dokter_trimester_3
// 	err = db.Exec(`
// 		ALTER TABLE pemeriksaan_dokter_trimester_3
// 		ADD COLUMN IF NOT EXISTS tanggal_periksa_stamp_paraf DATE NULL,
// 		ADD COLUMN IF NOT EXISTS keluhan_pemeriksaan_tindakan_saran TEXT NULL,
// 		ADD COLUMN IF NOT EXISTS tanggal_kembali DATE NULL
// 	`).Error
// 	if err != nil {
// 		return fmt.Errorf("failed to add catatan fields to trimester 3: %w", err)
// 	}
// 	fmt.Println("Successfully added catatan fields to pemeriksaan_dokter_trimester_3")

// 	// Migrate data from catatan_pelayanan_trimester_1 to pemeriksaan_dokter_trimester_1
// 	err = db.Exec(`
// 		UPDATE pemeriksaan_dokter_trimester_1 t1
// 		SET
// 			tanggal_periksa_stamp_paraf = c1.tanggal_periksa_stamp_paraf,
// 			keluhan_pemeriksaan_tindakan_saran = c1.keluhan_pemeriksaan_tindakan_saran,
// 			tanggal_kembali = c1.tanggal_kembali
// 		FROM catatan_pelayanan_trimester_1 c1
// 		WHERE t1.kehamilan_id = c1.kehamilan_id
// 	`).Error
// 	if err != nil {
// 		return fmt.Errorf("failed to migrate data from catatan_trimester_1: %w", err)
// 	}
// 	fmt.Println("Successfully migrated data from catatan_pelayanan_trimester_1")

// 	// Migrate data from catatan_pelayanan_trimester_3 to pemeriksaan_dokter_trimester_3
// 	err = db.Exec(`
// 		UPDATE pemeriksaan_dokter_trimester_3 t3
// 		SET
// 			tanggal_periksa_stamp_paraf = c3.tanggal_periksa_stamp_paraf,
// 			keluhan_pemeriksaan_tindakan_saran = c3.keluhan_pemeriksaan_tindakan_saran,
// 			tanggal_kembali = c3.tanggal_kembali
// 		FROM catatan_pelayanan_trimester_3 c3
// 		WHERE t3.kehamilan_id = c3.kehamilan_id
// 	`).Error
// 	if err != nil {
// 		return fmt.Errorf("failed to migrate data from catatan_trimester_3: %w", err)
// 	}
// 	fmt.Println("Successfully migrated data from catatan_pelayanan_trimester_3")

// 	return nil
// }
