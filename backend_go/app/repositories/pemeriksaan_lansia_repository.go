package repositories

import (
	"monitoring-service/app/models"
	"monitoring-service/app/utils"

	"gorm.io/gorm"
)

type PemeriksaanLansiaRepository interface {
	Create(data *models.PemeriksaanLansia) error
	GetAll() ([]models.PemeriksaanLansia, error)
	GetByID(id int32) (*models.PemeriksaanLansia, error)
	Update(data *models.PemeriksaanLansia) error
	Delete(id int32) error
	GetLatestRiskCountByPendudukIDs(pendudukIDs []int32) (map[string]int, error)
	CountPendudukWithExamination(pendudukIDs []int32) (int64, error)
	 GetAllLatestExamination(risikoFilter string) ([]models.PemeriksaanLansia, error)
	 GetAllByPendudukID(pendudukID int32) ([]models.PemeriksaanLansia, error)
	 GetLatestByPendudukID(pendudukID int32) (*models.PemeriksaanLansia, error)
}

type pemeriksaanLansiaRepository struct {
	db *gorm.DB
}

func NewPemeriksaanLansiaRepository(db *gorm.DB) PemeriksaanLansiaRepository {
	return &pemeriksaanLansiaRepository{
		db: db,
	}
}

func (r *pemeriksaanLansiaRepository) Create(data *models.PemeriksaanLansia) error {
	return r.db.Create(data).Error
}

func (r *pemeriksaanLansiaRepository) GetAll() ([]models.PemeriksaanLansia, error) {

	var data []models.PemeriksaanLansia

	err := r.db.
		Preload("Penduduk").
		Preload("Pemeriksa").
		Find(&data).Error

	return data, err
}

func (r *pemeriksaanLansiaRepository) GetByID(id int32) (*models.PemeriksaanLansia, error) {

	var data models.PemeriksaanLansia

	err := r.db.
		Preload("Penduduk").
		Preload("Pemeriksa").
		First(&data, id).Error

	if err != nil {
		return nil, err
	}

	return &data, nil
}

func (r *pemeriksaanLansiaRepository) Update(data *models.PemeriksaanLansia) error {
	return r.db.Save(data).Error
}

func (r *pemeriksaanLansiaRepository) Delete(id int32) error {
	return r.db.Delete(&models.PemeriksaanLansia{}, id).Error
}
func (r *pemeriksaanLansiaRepository) GetLatestRiskCountByPendudukIDs(pendudukIDs []int32) (map[string]int, error) {
	if len(pendudukIDs) == 0 {
		return map[string]int{"Normal": 0, "Sedang": 0, "Tinggi": 0}, nil
	}

	subQuery := r.db.Model(&models.PemeriksaanLansia{}).
		Select("penduduk_id, MAX(tanggal_pemeriksaan) as max_tanggal").
		Where("penduduk_id IN (?)", pendudukIDs).
		Group("penduduk_id")

	var results []struct {
		KategoriRisiko string
		Count          int
	}
	err := r.db.Table("pemeriksaan_lansia as pl").
		Select("pl.kategori_risiko, COUNT(*) as count").
		Joins("INNER JOIN (?) as latest ON latest.penduduk_id = pl.penduduk_id AND latest.max_tanggal = pl.tanggal_pemeriksaan", subQuery).
		Group("pl.kategori_risiko").
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
func (r *pemeriksaanLansiaRepository) CountPendudukWithExamination(pendudukIDs []int32) (int64, error) {
	if len(pendudukIDs) == 0 {
		return 0, nil
	}
	var count int64
	err := r.db.Model(&models.PemeriksaanLansia{}).
		Where("penduduk_id IN (?)", pendudukIDs).
		Distinct("penduduk_id").
		Count(&count).Error
	return count, err
}

// GetAllLatestExamination mengambil pemeriksaan terbaru setiap lansia, opsional filter risiko
func (r *pemeriksaanLansiaRepository) GetAllLatestExamination(risikoFilter string) ([]models.PemeriksaanLansia, error) {
	// Subquery: tanggal pemeriksaan terbaru per penduduk
	subQuery := r.db.Model(&models.PemeriksaanLansia{}).
		Select("penduduk_id, MAX(tanggal_pemeriksaan) as max_tanggal").
		Where("deleted_at IS NULL").
		Group("penduduk_id")

	query := r.db.Table("pemeriksaan_lansia as pl").
		Select("pl.*").
		Joins("INNER JOIN (?) as latest ON latest.penduduk_id = pl.penduduk_id AND latest.max_tanggal = pl.tanggal_pemeriksaan", subQuery).
		Preload("Penduduk"). // pastikan relasi Penduduk ada di model
		Where("pl.deleted_at IS NULL")

	if risikoFilter != "" {
		normalized := utils.NormalizeRisk(risikoFilter)
		query = query.Where("pl.kategori_risiko = ?", normalized)
	}

	var results []models.PemeriksaanLansia
	err := query.Find(&results).Error
	return results, err
}

func (r *pemeriksaanLansiaRepository) GetAllByPendudukID(pendudukID int32) ([]models.PemeriksaanLansia, error) {
    var data []models.PemeriksaanLansia
    err := r.db.
        Where("penduduk_id = ? AND deleted_at IS NULL", pendudukID).
        Order("tanggal_pemeriksaan DESC").
        Find(&data).Error
    return data, err
}
func (r *pemeriksaanLansiaRepository) GetLatestByPendudukID(pendudukID int32) (*models.PemeriksaanLansia, error) {
    var exam models.PemeriksaanLansia
    err := r.db.Where("penduduk_id = ? AND deleted_at IS NULL", pendudukID).
        Order("tanggal_pemeriksaan DESC, id DESC").
        First(&exam).Error
    if err == gorm.ErrRecordNotFound {
        return nil, nil
    }
    return &exam, err
}