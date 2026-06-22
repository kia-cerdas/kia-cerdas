package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"strings"

	"github.com/joho/godotenv"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

type PemeriksaanKehamilan struct {
	IDPeriksa          int32    `gorm:"primaryKey" json:"id_periksa"`
	KehamilanID        int32    `json:"kehamilan_id"`
	Trimester          string   `json:"trimester"`
	KunjunganKe        int32    `json:"kunjungan_ke"`
	MingguKehamilan    int32    `json:"minggu_kehamilan"`
	BeratBadan         *float64 `json:"berat_badan"`
	TinggiBadan        *float64 `json:"tinggi_badan"`
	LingkarLenganAtas  *float64 `json:"lingkar_lengan_atas"`
	Sistole            int32    `json:"sistole"`
	Diastole           int32    `json:"diastole"`
	TinggiRahim        *float64 `json:"tinggi_rahim"`
	DenyutJantungJanin int32    `json:"denyut_jantung_janin"`
	TesLabHb           *float64 `json:"tes_lab_hb"`
	SkorRisiko         int32    `json:"skor_risiko"`
	StatusRisiko       string   `json:"status_risiko"`
	DetailRisiko       string   `json:"detail_risiko"`
	OverallPrediction  int32    `json:"overall_prediction"`
	OverallLabel       string   `json:"overall_label"`
	ActiveRiskCount    int32    `json:"active_risk_count"`
	AlasanKlinis       string   `json:"alasan_klinis"`
	RekomendasiUtama   string   `json:"rekomendasi_utama"`
	RiskTypes          string   `json:"risk_types"`
}

type MLPredictionRequest struct {
	UsiaIbu           float64 `json:"usia_ibu"`
	UsiaKehamilan     int     `json:"usia_kehamilan"`
	TrimesterNum      int     `json:"trimester_num"`
	Gravida           int     `json:"gravida"`
	Para              int     `json:"para"`
	Abortus           int     `json:"abortus"`
	KunjunganANCKe    int     `json:"kunjungan_anc_ke"`
	IMT               float64 `json:"imt"`
	LiLA              float64 `json:"lila"`
	TinggiFundusUteri float64 `json:"tinggi_fundus_uteri"`
	TDSistolik        float64 `json:"td_sistolik"`
	TDDiastolik       float64 `json:"td_diastolik"`
	Hemoglobin        float64 `json:"hemoglobin"`
	ImunisasiEnc      int     `json:"imunisasi_enc"`
	RiwayatEnc        int     `json:"riwayat_enc"`
	RiwayatBerat      int     `json:"riwayat_berat"`
	HIVRek            int     `json:"hiv_rek"`
	SifRek            int     `json:"sif_rek"`
	HepBRek           int     `json:"hepb_rek"`
}

type MLPredictionResponse struct {
	OverallPrediction int              `json:"overall_prediction"`
	OverallLabel      string           `json:"overall_label"`
	RiskScore         float64          `json:"risk_score"`
	RiskTypes         []RiskTypeDetail `json:"risk_types"`
	ActiveRiskCount   int              `json:"active_risk_count"`
	AlasanKlinis      []string         `json:"alasan_klinis"`
	RekomendasiUtama  string           `json:"rekomendasi_utama"`
}

type RiskTypeDetail struct {
	Name        string   `json:"name"`
	Detected    bool     `json:"detected"`
	Probability float64  `json:"probability"`
	Tindakan    []string `json:"tindakan"`
	Referensi   string   `json:"referensi"`
}

func (PemeriksaanKehamilan) TableName() string {
	return "pemeriksaan_kehamilan"
}

func main() {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Println("⚠️  Warning: .env file not found, using system environment variables")
	}

	// Setup database connection
	dbDSN := os.Getenv("DB_POSTGRES_DSN")
	dbSchema := os.Getenv("DB_POSTGRES_SCHEMA")

	if dbDSN == "" {
		log.Fatal("❌ DB_POSTGRES_DSN environment variable is not set")
	}

	// Add schema to DSN if not already present
	dsn := dbDSN
	if dbSchema != "" {
		dsn += "?search_path=" + dbSchema
	}

	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	})
	if err != nil {
		log.Fatalf("❌ Gagal koneksi ke database: %v", err)
	}

	log.Println("✅ Berhasil koneksi ke database")

	// ML API URL
	mlAPIURL := "http://localhost:8001/predict"

	// Fetch records that don't have risk_types data
	var records []PemeriksaanKehamilan
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
		resp, err := callMLAPI(mlAPIURL, req)
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

func buildPredictionRequest(p *PemeriksaanKehamilan) MLPredictionRequest {
	// Calculate IMT if height and weight are available
	var imt float64
	if p.TinggiBadan != nil && *p.TinggiBadan > 0 && p.BeratBadan != nil && *p.BeratBadan > 0 {
		heightInMeters := *p.TinggiBadan / 100.0
		imt = *p.BeratBadan / (heightInMeters * heightInMeters)
	}

	return MLPredictionRequest{
		UsiaIbu:           25.0, // Default age
		UsiaKehamilan:     int(p.MingguKehamilan),
		TrimesterNum:      getTrimesterNumber(p.Trimester),
		Gravida:           1,
		Para:              0,
		Abortus:           0,
		KunjunganANCKe:    int(p.KunjunganKe),
		IMT:               imt,
		LiLA:              getFloatValue(p.LingkarLenganAtas),
		TinggiFundusUteri: getFloatValue(p.TinggiRahim),
		TDSistolik:        float64(p.Sistole),
		TDDiastolik:       float64(p.Diastole),
		Hemoglobin:        getFloatValue(p.TesLabHb),
		ImunisasiEnc:      3,
		RiwayatEnc:        0,
		RiwayatBerat:      0,
		HIVRek:            0,
		SifRek:            0,
		HepBRek:           0,
	}
}

func callMLAPI(url string, req MLPredictionRequest) (*MLPredictionResponse, error) {
	jsonData, err := json.Marshal(req)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal request: %w", err)
	}

	resp, err := http.Post(url, "application/json", bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, fmt.Errorf("failed to call ML API: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("ML API returned status %d", resp.StatusCode)
	}

	var result MLPredictionResponse
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, fmt.Errorf("failed to decode response: %w", err)
	}

	return &result, nil
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

func generateRiskSummaryFromTypes(riskTypes []RiskTypeDetail) string {
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
