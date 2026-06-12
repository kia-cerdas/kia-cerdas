package repositories

import (
	"time"
	"monitoring-service/app/models"

	"gorm.io/gorm"
)

type PrediksiStuntingRepository interface {
	GetMeasurementDataByAnakID(anakID int32) (*models.MeasurementDataForPrediction, error)
	GetLatestMeasurementByAnakID(anakID int32) (*models.MeasurementDataForPrediction, error)
	SavePrediction(prediction *models.PrediksiStunting) error
	GetPredictionByAnakID(anakID int32) ([]models.PrediksiStunting, error)
	GetLatestPredictionByAnakID(anakID int32) (*models.PrediksiStunting, error)
	UpdateAnakStatusPrediksi(anakID int32, status string) error
	GetLatestPredictionsByAnakIDs(anakIDs []int32) (map[int32]string, error)
}

type prediksiStuntingRepository struct {
	db *gorm.DB
}

func NewPrediksiStuntingRepository(db *gorm.DB) PrediksiStuntingRepository {
	return &prediksiStuntingRepository{db: db}
}

// GetLatestMeasurementByAnakID - ambil semua data pengukuran anak (latest) dengan join penduduk
func (r *prediksiStuntingRepository) GetLatestMeasurementByAnakID(anakID int32) (*models.MeasurementDataForPrediction, error) {
	var measurement models.MeasurementDataForPrediction

	err := r.db.
		Table("anak a").
		Select(`
			a.id as anak_id,
			p.nama_lengkap as nama,
			p.jenis_kelamin,
			p.tanggal_lahir,
			COALESCE(a.berat_lahir_kg, 3.0) as berat_lahir_kg,
			COALESCE(a.tinggi_lahir_cm, 49.0) as tinggi_lahir_cm,
			COALESCE(cp.berat_badan, 0) as berat_badan,
			COALESCE(cp.tinggi_badan, 0) as tinggi_badan,
			COALESCE(cp.lingkar_kepala, 0) as lingkar_kepala,
			COALESCE(cp.hasil_lila, 0) as hasil_lila,
			COALESCE(cp.usia_ukur_bulan, 0) as usia_ukur_bulan,
			cp.tgl_ukur,
			COALESCE(cp.status_tb_u, '') as status_tb_u,
			COALESCE(cp.z_score_tb_u, 0) as z_score_tb_u
		`).
		Joins("JOIN penduduk p ON a.penduduk_id = p.id").
		Joins("LEFT JOIN catatan_pertumbuhan cp ON a.id = cp.anak_id AND cp.deleted_at IS NULL").
		Where("a.id = ? AND a.deleted_at IS NULL", anakID).
		Order("cp.tgl_ukur DESC").
		Limit(1).
		Scan(&measurement).Error

	if err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, nil
		}
		return nil, err
	}

	// Hitung umur anak dalam bulan dari tanggal lahir jika belum pernah diukur atau usia_ukur_bulan masih 0
	if measurement.UsiaUkurBulan == 0 && !measurement.TanggalLahir.IsZero() {
		now := time.Now()
		years := now.Year() - measurement.TanggalLahir.Year()
		months := int(now.Month() - measurement.TanggalLahir.Month())
		if months < 0 {
			years--
			months += 12
		}
		measurement.UsiaUkurBulan = years*12 + months
	}

	return &measurement, nil
}

// GetMeasurementDataByAnakID - ambil riwayat lengkap data pengukuran (untuk training/analisis)
func (r *prediksiStuntingRepository) GetMeasurementDataByAnakID(anakID int32) (*models.MeasurementDataForPrediction, error) {
	return r.GetLatestMeasurementByAnakID(anakID)
}

// SavePrediction - simpan hasil prediksi ke database
func (r *prediksiStuntingRepository) SavePrediction(prediction *models.PrediksiStunting) error {
	return r.db.Create(prediction).Error
}

// GetPredictionByAnakID - ambil riwayat prediksi stunting
func (r *prediksiStuntingRepository) GetPredictionByAnakID(anakID int32) ([]models.PrediksiStunting, error) {
	var predictions []models.PrediksiStunting

	err := r.db.
		Where("anak_id = ? AND deleted_at IS NULL", anakID).
		Order("created_at DESC").
		Find(&predictions).Error

	return predictions, err
}

// GetLatestPredictionByAnakID - ambil prediksi terbaru
func (r *prediksiStuntingRepository) GetLatestPredictionByAnakID(anakID int32) (*models.PrediksiStunting, error) {
	var prediction models.PrediksiStunting

	err := r.db.
		Where("anak_id = ? AND deleted_at IS NULL", anakID).
		Order("created_at DESC").
		Limit(1).
		First(&prediction).Error

	if err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, nil
		}
		return nil, err
	}

	return &prediction, nil
}

// UpdateAnakStatusPrediksi - do nothing, as status is virtual and pulled dynamically from prediksi_stunting table
func (r *prediksiStuntingRepository) UpdateAnakStatusPrediksi(anakID int32, status string) error {
	return nil
}

// GetLatestPredictionsByAnakIDs mempermudah pengambilan status prediksi terbaru untuk sekelompok ID anak
func (r *prediksiStuntingRepository) GetLatestPredictionsByAnakIDs(anakIDs []int32) (map[int32]string, error) {
	if len(anakIDs) == 0 {
		return make(map[int32]string), nil
	}

	type LatestPrediction struct {
		AnakID         int32  `gorm:"column:anak_id"`
		StatusPrediksi string `gorm:"column:status_prediksi"`
	}
	var predictions []LatestPrediction

	// Query data stunting dengan ID terbesar (terbaru) untuk masing-masing anak ID
	err := r.db.Table("prediksi_stunting").
		Select("anak_id, status_prediksi").
		Where("anak_id IN ? AND deleted_at IS NULL", anakIDs).
		Where("id IN (SELECT MAX(id) FROM prediksi_stunting WHERE deleted_at IS NULL GROUP BY anak_id)").
		Scan(&predictions).Error

	if err != nil {
		return nil, err
	}

	predMap := make(map[int32]string)
	for _, p := range predictions {
		predMap[p.AnakID] = p.StatusPrediksi
	}

	return predMap, nil
}

