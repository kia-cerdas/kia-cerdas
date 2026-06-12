package repositories

import (
	"monitoring-service/app/models"
	"monitoring-service/app/utils"

	"gorm.io/gorm"
)

type PemeriksaanRemajaRepository interface {
	Create(data *models.PemeriksaanRemaja) error
	GetAll() ([]models.PemeriksaanRemaja, error)
	GetByID(id int32) (*models.PemeriksaanRemaja, error)
	Update(data *models.PemeriksaanRemaja) error
	Delete(id int32) error
	GetLatestRiskCountByPendudukIDs(pendudukIDs []int32) (map[string]int, error)
	CountPendudukWithExamination(pendudukIDs []int32) (int64, error)
	GetAllLatestExamination(risikoFilter string) ([]models.PemeriksaanRemaja, error)
	GetAllByPendudukID(pendudukID int32) ([]models.PemeriksaanRemaja, error)
	GetLatestByPendudukID(pendudukID int32) (*models.PemeriksaanRemaja, error)
}

type pemeriksaanRemajaRepository struct {
	db *gorm.DB
}

func NewPemeriksaanRemajaRepository(db *gorm.DB) PemeriksaanRemajaRepository {
	return &pemeriksaanRemajaRepository{db: db}
}

func (r *pemeriksaanRemajaRepository) Create(data *models.PemeriksaanRemaja) error {
	return r.db.Create(data).Error
}

func (r *pemeriksaanRemajaRepository) GetAll() ([]models.PemeriksaanRemaja, error) {
	var data []models.PemeriksaanRemaja

	err := r.db.
		Preload("Penduduk").
		Preload("Pemeriksa").
		Find(&data).Error

	return data, err
}

func (r *pemeriksaanRemajaRepository) GetByID(id int32) (*models.PemeriksaanRemaja, error) {
	var data models.PemeriksaanRemaja

	err := r.db.
		Preload("Penduduk").
		Preload("Pemeriksa").
		First(&data, id).Error

	if err != nil {
		return nil, err
	}

	return &data, nil
}

func (r *pemeriksaanRemajaRepository) Update(data *models.PemeriksaanRemaja) error {
	return r.db.Save(data).Error
}

func (r *pemeriksaanRemajaRepository) Delete(id int32) error {
	return r.db.Delete(&models.PemeriksaanRemaja{}, id).Error
}

func (r *pemeriksaanRemajaRepository) GetLatestRiskCountByPendudukIDs(pendudukIDs []int32) (map[string]int, error) {
	if len(pendudukIDs) == 0 {
		return map[string]int{"Normal": 0, "Sedang": 0, "Tinggi": 0}, nil
	}

	// Subquery: tanggal pemeriksaan terbaru per penduduk
	subQuery := r.db.Model(&models.PemeriksaanRemaja{}).
		Select("penduduk_id, MAX(tanggal_pemeriksaan) as max_tanggal").
		Where("penduduk_id IN (?)", pendudukIDs).
		Group("penduduk_id")

	var results []struct {
		KategoriRisiko string
		Count          int
	}
	err := r.db.Table("pemeriksaan_remaja as pr").
		Select("pr.kategori_risiko, COUNT(*) as count").
		Joins("INNER JOIN (?) as latest ON latest.penduduk_id = pr.penduduk_id AND latest.max_tanggal = pr.tanggal_pemeriksaan", subQuery).
		Group("pr.kategori_risiko").
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
func (r *pemeriksaanRemajaRepository) CountPendudukWithExamination(pendudukIDs []int32) (int64, error) {
	if len(pendudukIDs) == 0 {
		return 0, nil
	}
	var count int64
	err := r.db.Model(&models.PemeriksaanRemaja{}).
		Where("penduduk_id IN (?)", pendudukIDs).
		Distinct("penduduk_id").
		Count(&count).Error
	return count, err
}


// GetAllLatestExamination mengambil pemeriksaan terbaru setiap anak, opsional filter risiko
func (r *pemeriksaanRemajaRepository) GetAllLatestExamination(risikoFilter string) ([]models.PemeriksaanRemaja, error) {
    // Subquery: tanggal pemeriksaan terbaru per penduduk
    subQuery := r.db.Model(&models.PemeriksaanRemaja{}).
        Select("penduduk_id, MAX(tanggal_pemeriksaan) as max_tanggal").
        Where("deleted_at IS NULL").
        Group("penduduk_id")

    query := r.db.Table("pemeriksaan_remaja as pr").
        Select("pr.*").
        Joins("INNER JOIN (?) as latest ON latest.penduduk_id = pr.penduduk_id AND latest.max_tanggal = pr.tanggal_pemeriksaan", subQuery).
        Preload("Penduduk"). // pastikan relasi Penduduk ada di model
        Where("pr.deleted_at IS NULL")

    if risikoFilter != "" {
        normalized := utils.NormalizeRisk(risikoFilter)
        query = query.Where("pr.kategori_risiko = ?", normalized)
    }

    var results []models.PemeriksaanRemaja
    err := query.Find(&results).Error
    return results, err
}

func (r *pemeriksaanRemajaRepository) GetAllByPendudukID(pendudukID int32) ([]models.PemeriksaanRemaja, error) {
    var data []models.PemeriksaanRemaja
    err := r.db.
        Where("penduduk_id = ? AND deleted_at IS NULL", pendudukID).
        Order("tanggal_pemeriksaan DESC").
        Find(&data).Error
    return data, err
}
func (r *pemeriksaanRemajaRepository) GetLatestByPendudukID(pendudukID int32) (*models.PemeriksaanRemaja, error) {
    var exam models.PemeriksaanRemaja
    err := r.db.Where("penduduk_id = ? AND deleted_at IS NULL", pendudukID).
        Order("tanggal_pemeriksaan DESC, id DESC").
        First(&exam).Error
    if err == gorm.ErrRecordNotFound {
        return nil, nil
    }
    return &exam, err
}