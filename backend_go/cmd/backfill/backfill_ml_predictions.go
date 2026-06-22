package main

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"strings"

	"github.com/joho/godotenv"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"

	"monitoring-service/app/models"
	"monitoring-service/pkg/config/database"
	"monitoring-service/pkg/services/prediksi_risiko"
)

func main() {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Println("⚠️  Warning: .env file not found, using system environment variables")
	}

	// Setup database connection
	dbConfig := database.Config{
		Host:         os.Getenv("DB_HOST"),
		Port:         os.Getenv("DB_PORT"),
		User:         os.Getenv("DB_USER"),
		Password:     os.Getenv("DB_PASSWORD"),
		Name:         os.Getenv("DB_NAME"),
		Schema:       os.Getenv("DB_SCHEMA"),
		MaxOpenConns: 25,
		MaxIdleConns: 25,
		MaxLifetime:  300,
	}

	dsn := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s search_path=%s sslmode=disable",
		dbConfig.Host, dbConfig.Port, dbConfig.User, dbConfig.Password, dbConfig.Name, dbConfig.Schema)

	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	})
	if err != nil {
		log.Fatalf("❌ Gagal koneksi ke database: %v", err)
	}

	log.Println("✅ Berhasil koneksi ke database")

	// Initialize ML prediction service
	mlService := prediksi_risiko.NewPrediksiRisikoService()

	// Fetch records that don't have risk_types data
	var records []models.PemeriksaanKehamilan
	if err := db.Where("risk_types IS NULL OR risk_types = ''").Find(&records).Error; err != nil {
		log.Fatalf("❌ Gagal mengambil data pemeriksaan: %v", err)
	}

	if len(records) == 0 {
		log.Println("✅ Tidak ada data yang perlu di-backfill. Semua data sudah memiliki risk_types.")
		return
	}

	log.Printf("📊 Ditemukan %d record yang perlu di-backfill dengan prediksi ML\n", len(records))

	// Process each record
	successCount := 0
	failCount := 0

	for i, record := range records {
		log.Printf("🔄 Memproses record %d/%d (ID: %d)...", i+1, len(records), record.IDPeriksa)

		// Build prediction request
		req := buildPredictionRequest(&record)

		// Call ML API
		resp, err := mlService.Predict(req)
		if err != nil {
			log.Printf("❌ Gagal memprediksi record ID %d: %v", record.IDPeriksa, err)
			failCount++
			continue
		}

		// Update record with ML prediction results
		record.SkorRisiko = int32(resp.RiskScore)
		record.StatusRisiko = resp.OverallLabel
		record.OverallPrediction = int32(resp.OverallPrediction)
		record.OverallLabel = resp.OverallLabel
		record.ActiveRiskCount = int32(resp.ActiveRiskCount)

		// Convert alasan_klinis array to JSON string
		if len(resp.AlasanKlinis) > 0 {
			alasanJSON, _ := json.Marshal(resp.AlasanKlinis)
			record.AlasanKlinis = string(alasanJSON)
		}

		// Store rekomendasi utama
		record.RekomendasiUtama = resp.RekomendasiUtama

		// Store risk_types as JSON
		if len(resp.RiskTypes) > 0 {
			riskTypesJSON, _ := json.Marshal(resp.RiskTypes)
			record.RiskTypes = string(riskTypesJSON)
		}

		// Generate detailed risk summary from risk types
		record.DetailRisiko = generateRiskSummaryFromTypes(resp.RiskTypes)

		// Save to database
		if err := db.Save(&record).Error; err != nil {
			log.Printf("❌ Gagal menyimpan record ID %d: %v", record.IDPeriksa, err)
			failCount++
			continue
		}

		log.Printf("✅ Berhasil mengupdate record ID %d - Status: %s, Risiko Aktif: %d",
			record.IDPeriksa, record.OverallLabel, record.ActiveRiskCount)
		successCount++
	}

	// Summary
	log.Println("\n" + strings.Repeat("=", 50))
	log.Printf("🎉 Backfill selesai!")
	log.Printf("✅ Berhasil: %d record", successCount)
	log.Printf("❌ Gagal: %d record", failCount)
	log.Printf("📊 Total: %d record", len(records))
	log.Println(strings.Repeat("=", 50))
}

func buildPredictionRequest(p *models.PemeriksaanKehamilan) models.PrediksiRisikoRequest {
	// Calculate IMT if height and weight are available
	var imt float64
	if p.TinggiBadan != nil && *p.TinggiBadan > 0 && p.BeratBadan != nil && *p.BeratBadan > 0 {
		heightInMeters := *p.TinggiBadan / 100.0
		imt = *p.BeratBadan / (heightInMeters * heightInMeters)
	}

	// Default values for missing fields
	usiaIbu := 25.0 // Default age if not available
	gravida := 1
	para := 0
	abortus := 0
	imunisasiEnc := 3
	riwayatEnc := 0
	riwayatBerat := 0
	hivRek := 0
	sifRek := 0
	hepbRek := 0

	return models.PrediksiRisikoRequest{
		UsiaIbu:           usiaIbu,
		UsiaKehamilan:     int(p.MingguKehamilan),
		TrimesterNum:      getTrimesterNumber(p.Trimester),
		Gravida:           gravida,
		Para:              para,
		Abortus:           abortus,
		KunjunganANCKe:    int(p.KunjunganKe),
		IMT:               imt,
		LiLA:              getFloatValue(p.LingkarLenganAtas),
		TinggiFundusUteri: getFloatValue(p.TinggiRahim),
		TDSistolik:        float64(p.Sistole),
		TDDiastolik:       float64(p.Diastole),
		Hemoglobin:        getFloatValue(p.TesLabHb),
		ImunisasiEnc:      imunisasiEnc,
		RiwayatEnc:        riwayatEnc,
		RiwayatBerat:      riwayatBerat,
		HIVRek:            hivRek,
		SifRek:            sifRek,
		HepBRek:           hepbRek,
	}
}

func getTrimesterNumber(trimester string) int {
	switch trimester {
	case "I", "1":
		return 1
	case "II", "2":
		return 2
	case "III", "3":
		return 3
	default:
		return 1
	}
}

func getFloatValue(ptr *float64) float64 {
	if ptr == nil {
		return 0.0
	}
	return *ptr
}

func generateRiskSummaryFromTypes(riskTypes []models.RiskTypeDetail) string {
	var detectedRisks []string
	var recommendations []string

	for _, risk := range riskTypes {
		if risk.Detected {
			detectedRisks = append(detectedRisks, risk.Name)
			if len(risk.Tindakan) > 0 {
				recommendations = append(recommendations, fmt.Sprintf("%s: %s", risk.Name, risk.Tindakan[0]))
			}
		}
	}

	if len(detectedRisks) == 0 {
		return "Tidak ada risiko terdeteksi. Lanjutkan ANC rutin."
	}

	summary := fmt.Sprintf("Risiko terdeteksi: %s. ", joinStrings(detectedRisks, ", "))
	if len(recommendations) > 0 {
		summary += fmt.Sprintf("Tindakan: %s", joinStrings(recommendations, "; "))
	}
	return summary
}

func joinStrings(strs []string, separator string) string {
	if len(strs) == 0 {
		return ""
	}
	result := strs[0]
	for i := 1; i < len(strs); i++ {
		result += separator + strs[i]
	}
	return result
}
