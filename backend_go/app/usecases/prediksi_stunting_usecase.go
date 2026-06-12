package usecases

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"monitoring-service/app/models"
	"monitoring-service/app/repositories"
	"monitoring-service/pkg/customerror"
	"net/http"
	"time"
)

type PrediksiStuntingUsecase interface {
	GetMeasurementDataByAnakID(ctx context.Context, anakID int32) (*models.MeasurementDataForPrediction, error)
	PredictStunting(ctx context.Context, req *models.PrediksiStuntingRequest) (*models.PrediksiStunting, error)
	GetPredictionHistory(ctx context.Context, anakID int32) ([]models.PrediksiStunting, error)
	GetLatestPrediction(ctx context.Context, anakID int32) (*models.PrediksiStunting, error)
}

type prediksiStuntingUsecase struct {
	repo                repositories.PrediksiStuntingRepository
	pythonServiceURL    string
}

func NewPrediksiStuntingUsecase(
	repo repositories.PrediksiStuntingRepository,
	pythonServiceURL string,
) PrediksiStuntingUsecase {
	return &prediksiStuntingUsecase{
		repo:             repo,
		pythonServiceURL: pythonServiceURL,
	}
}

// GetMeasurementDataByAnakID - ambil data pengukuran terakhir anak
func (u *prediksiStuntingUsecase) GetMeasurementDataByAnakID(ctx context.Context, anakID int32) (*models.MeasurementDataForPrediction, error) {
	data, err := u.repo.GetMeasurementDataByAnakID(anakID)
	if err != nil {
		return nil, customerror.NewInternalServiceError("gagal mengambil data pengukuran")
	}
	return data, nil
}

// PredictStunting - prediksi stunting dengan memanggil Python service
func (u *prediksiStuntingUsecase) PredictStunting(ctx context.Context, req *models.PrediksiStuntingRequest) (*models.PrediksiStunting, error) {
	// Ambil data lahir anak dari database jika belum di-set
	if req.BeratLahirKg == 0 || req.TinggiLahirCm == 0 {
		measurementData, errMeas := u.repo.GetLatestMeasurementByAnakID(req.AnakID)
		if errMeas == nil && measurementData != nil {
			if req.BeratLahirKg == 0 {
				req.BeratLahirKg = measurementData.BeratLahirKg
			}
			if req.TinggiLahirCm == 0 {
				req.TinggiLahirCm = measurementData.TinggiLahirCm
			}
		}
		// Fallbacks jika masih 0
		if req.BeratLahirKg == 0 {
			req.BeratLahirKg = 3.0
		}
		if req.TinggiLahirCm == 0 {
			req.TinggiLahirCm = 49.0
		}
	}

	// Panggil Python service untuk prediksi
	prediksi, err := u.callPythonPredictionService(ctx, req)
	if err != nil {
		return nil, err
	}

	// Map classification to status_prediksi
	var statusPrediksi string
	switch prediksi.Classification {
	case "STUNTING":
		statusPrediksi = "Stunting"
	case "AT_RISK":
		statusPrediksi = "Risiko Stunting"
	default:
		statusPrediksi = "Normal"
	}

	// Simpan hasil prediksi ke database
	result := &models.PrediksiStunting{
		AnakID:          req.AnakID,
		BeratBadan:      req.BeratBadan,
		TinggiBadan:     req.TinggiBadan,
		LingkarKepala:   req.LingkarKepala,
		HasilLila:       req.HasilLila,
		UsiaUkurBulan:   req.UsiaUkurBulan,
		RiskPercentage:  prediksi.StuntingRisk,
		Classification:  prediksi.Classification,
		Confidence:      prediksi.Confidence,
		ZScoreTBU:       prediksi.ZScoreTBU,
		StatusTBU:       prediksi.StatusTBU,
		Rekomendasi:     prediksi.Rekomendasi,
		StatusPrediksi:  statusPrediksi,
	}

	if err := u.repo.SavePrediction(result); err != nil {
		return nil, customerror.NewInternalServiceError("gagal menyimpan hasil prediksi")
	}

	return result, nil
}

// callPythonPredictionService - panggil Python ML service
func (u *prediksiStuntingUsecase) callPythonPredictionService(ctx context.Context, req *models.PrediksiStuntingRequest) (*models.PrediksiResponse, error) {
	// Siapkan payload
	payload := map[string]interface{}{
		"bb_lahir":      req.BeratLahirKg,
		"tb_lahir":      req.TinggiLahirCm,
		"bb":            req.BeratBadan,
		"tb":            req.TinggiBadan,
		"lila":          req.HasilLila,
		"umur":          req.UsiaUkurBulan,
		"jenis_kelamin": req.JenisKelamin,
	}

	// Convert ke JSON
	payloadBytes, err := json.Marshal(payload)
	if err != nil {
		return nil, customerror.NewInternalServiceError("gagal serialize payload")
	}

	fmt.Printf("[DEBUG] Payload to ML Model: %s\n", string(payloadBytes))

	// Request ke Python service
	httpReq, err := http.NewRequestWithContext(ctx, "POST", 
		fmt.Sprintf("%s/predict", u.pythonServiceURL), 
		io.NopCloser(io.Reader(bytes.NewBuffer(payloadBytes))))
	if err != nil {
		return nil, customerror.NewInternalServiceError("gagal membuat request ke Python service")
	}
	httpReq.Header.Set("Content-Type", "application/json")

	client := &http.Client{
		Timeout: 5 * time.Second,
	}
	resp, err := client.Do(httpReq)
	if err != nil {
		return nil, customerror.NewInternalServiceError("gagal koneksi ke Python service")
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, customerror.NewInternalServiceError("Python service error")
	}

	// Parse response
	var prediction models.PrediksiResponse
	if err := json.NewDecoder(resp.Body).Decode(&prediction); err != nil {
		return nil, customerror.NewInternalServiceError("gagal parse response dari Python service")
	}

	return &prediction, nil
}

// GetPredictionHistory - ambil riwayat prediksi
func (u *prediksiStuntingUsecase) GetPredictionHistory(ctx context.Context, anakID int32) ([]models.PrediksiStunting, error) {
	predictions, err := u.repo.GetPredictionByAnakID(anakID)
	if err != nil {
		return nil, customerror.NewInternalServiceError("gagal mengambil riwayat prediksi")
	}
	return predictions, nil
}

// GetLatestPrediction - ambil prediksi terbaru
func (u *prediksiStuntingUsecase) GetLatestPrediction(ctx context.Context, anakID int32) (*models.PrediksiStunting, error) {
	prediction, err := u.repo.GetLatestPredictionByAnakID(anakID)
	if err != nil {
		return nil, customerror.NewInternalServiceError("gagal mengambil prediksi terbaru")
	}
	return prediction, nil
}
