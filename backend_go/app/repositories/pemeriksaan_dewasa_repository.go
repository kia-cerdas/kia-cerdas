package repositories

import (
	"monitoring-service/app/models"
	"monitoring-service/app/utils"

	"gorm.io/gorm"
)

type PemeriksaanDewasaRepository interface {
	Create(data *models.PemeriksaanDewasa) error
	GetAll() ([]models.PemeriksaanDewasa, error)
	GetByID(id int32) (*models.PemeriksaanDewasa, error)
	Update(data *models.PemeriksaanDewasa) error
	Delete(id int32) error
	GetLatestRiskCountByPendudukIDs(pendudukIDs []int32) (map[string]int, error)
	CountPendudukWithExamination(pendudukIDs []int32) (int64, error)
	GetAllLatestExamination(risikoFilter string) ([]models.PemeriksaanDewasa, error)
	GetAllByPendudukID(pendudukID int32) ([]models.PemeriksaanDewasa, error)
	GetLatestByPendudukID(pendudukID int32) (*models.PemeriksaanDewasa, error)
}

type pemeriksaanDewasaRepository struct {
	db *gorm.DB
}

func NewPemeriksaanDewasaRepository(db *gorm.DB) PemeriksaanDewasaRepository {
	return &pemeriksaanDewasaRepository{
		db: db,
	}
}

func (r *pemeriksaanDewasaRepository) Create(data *models.PemeriksaanDewasa) error {
	return r.db.Create(data).Error
}

func (r *pemeriksaanDewasaRepository) GetAll() ([]models.PemeriksaanDewasa, error) {

	var data []models.PemeriksaanDewasa

	err := r.db.
		// Preload("Penduduk").
		// Preload("Pemeriksa").
		Find(&data).Error

	return data, err
}

func (r *pemeriksaanDewasaRepository) GetByID(id int32) (*models.PemeriksaanDewasa, error) {

	var data models.PemeriksaanDewasa

	err := r.db.
		// Preload("Penduduk").
		// Preload("Pemeriksa").
		First(&data, id).Error

	if err != nil {
		return nil, err
	}

	return &data, nil
}

func (r *pemeriksaanDewasaRepository) Update(data *models.PemeriksaanDewasa) error {
	return r.db.Save(data).Error
}

func (r *pemeriksaanDewasaRepository) Delete(id int32) error {
	return r.db.Delete(&models.PemeriksaanDewasa{}, id).Error
}
func (r *pemeriksaanDewasaRepository) GetLatestRiskCountByPendudukIDs(pendudukIDs []int32) (map[string]int, error) {
	if len(pendudukIDs) == 0 {
		return map[string]int{"Normal": 0, "Sedang": 0, "Tinggi": 0}, nil
	}

	subQuery := r.db.Model(&models.PemeriksaanDewasa{}).
		Select("penduduk_id, MAX(tanggal_pemeriksaan) as max_tanggal").
		Where("penduduk_id IN (?)", pendudukIDs).
		Group("penduduk_id")

	var results []struct {
		KategoriRisiko string
		Count          int
	}
	err := r.db.Table("pemeriksaan_dewasa as pd").
		Select("pd.kategori_risiko, COUNT(*) as count").
		Joins("INNER JOIN (?) as latest ON latest.penduduk_id = pd.penduduk_id AND latest.max_tanggal = pd.tanggal_pemeriksaan", subQuery).
		Group("pd.kategori_risiko").
		Scan(&results).Error
	if err != nil {
		return nil, err
	}

	riskMap := map[string]int{"Normal": 0, "Sedang": 0, "Tinggi": 0}
	for _, res := range results {
		normalized := utils.NormalizeRisk(res.KategoriRisiko)
		riskMap[normalized] += res.Count
	}
	return riskMap, nil
}

// CountPendudukWithExamination mengembalikan jumlah penduduk dalam daftar ID yang memiliki setidaknya satu catatan pemeriksaan
func (r *pemeriksaanDewasaRepository) CountPendudukWithExamination(pendudukIDs []int32) (int64, error) {
	if len(pendudukIDs) == 0 {
		return 0, nil
	}
	var count int64
	err := r.db.Model(&models.PemeriksaanDewasa{}).
		Where("penduduk_id IN (?)", pendudukIDs).
		Distinct("penduduk_id").
		Count(&count).Error
	return count, err
}

// GetAllLatestExamination mengambil pemeriksaan terbaru setiap anak, opsional filter risiko
func (r *pemeriksaanDewasaRepository) GetAllLatestExamination(risikoFilter string) ([]models.PemeriksaanDewasa, error) {
	// Subquery: tanggal pemeriksaan terbaru per penduduk
	subQuery := r.db.Model(&models.PemeriksaanDewasa{}).
		Select("penduduk_id, MAX(tanggal_pemeriksaan) as max_tanggal").
		Where("deleted_at IS NULL").
		Group("penduduk_id")

	query := r.db.Table("pemeriksaan_dewasa as pd").
		Select("pd.*").
		Joins("INNER JOIN (?) as latest ON latest.penduduk_id = pd.penduduk_id AND latest.max_tanggal = pd.tanggal_pemeriksaan", subQuery).
		Preload("Penduduk"). // pastikan relasi Penduduk ada di model
		Where("pd.deleted_at IS NULL")

	if risikoFilter != "" {
		normalized := utils.NormalizeRisk(risikoFilter)
		query = query.Where("pd.kategori_risiko = ?", normalized)
	}

	var results []models.PemeriksaanDewasa
	err := query.Find(&results).Error
	return results, err
}

func (r *pemeriksaanDewasaRepository) GetAllByPendudukID(pendudukID int32) ([]models.PemeriksaanDewasa, error) {
    var data []models.PemeriksaanDewasa
    err := r.db.
        Where("penduduk_id = ? AND deleted_at IS NULL", pendudukID).
        Order("tanggal_pemeriksaan DESC").
        Find(&data).Error
    return data, err
}

func (r *pemeriksaanDewasaRepository) GetLatestByPendudukID(pendudukID int32) (*models.PemeriksaanDewasa, error) {
    var exam models.PemeriksaanDewasa
    err := r.db.Where("penduduk_id = ? AND deleted_at IS NULL", pendudukID).
        Order("tanggal_pemeriksaan DESC, id DESC").
        First(&exam).Error
    if err == gorm.ErrRecordNotFound {
        return nil, nil
    }
    return &exam, err
}