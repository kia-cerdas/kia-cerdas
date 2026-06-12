package repositories

import (
	"monitoring-service/app/models"
	"monitoring-service/app/utils"
	"gorm.io/gorm"
)

type PemeriksaanAnakRepository interface {
	Create(data *models.PemeriksaanAnak) error
	GetAll() ([]models.PemeriksaanAnak, error)
	GetByID(id int32) (*models.PemeriksaanAnak, error)
	Update(data *models.PemeriksaanAnak) error
	Delete(id int32) error
	GetLatestRiskCountByPendudukIDs(pendudukIDs []int32) (map[string]int, error) 
	CountPendudukWithExamination(pendudukIDs []int32) (int64, error)
    GetAllLatestExamination(risikoFilter string) ([]models.PemeriksaanAnak, error)
    GetAllByPendudukID(pendudukID int32) ([]models.PemeriksaanAnak, error)
    GetLatestByPendudukID(pendudukID int32) (*models.PemeriksaanAnak, error)
}

type pemeriksaanAnakRepository struct {
	db *gorm.DB
}

func NewPemeriksaanAnakRepository(db *gorm.DB) PemeriksaanAnakRepository {
	return &pemeriksaanAnakRepository{
		db: db,
	}
}

func (r *pemeriksaanAnakRepository) Create(data *models.PemeriksaanAnak) error {
	return r.db.Create(data).Error
}

func (r *pemeriksaanAnakRepository) GetAll() ([]models.PemeriksaanAnak, error) {

	var data []models.PemeriksaanAnak

	err := r.db.
		Preload("Penduduk").
		Preload("Pemeriksa").
		Find(&data).Error

	return data, err
}

func (r *pemeriksaanAnakRepository) GetByID(id int32) (*models.PemeriksaanAnak, error) {

	var data models.PemeriksaanAnak

	err := r.db.
		Preload("Penduduk").
		Preload("Pemeriksa").
		First(&data, id).Error

	if err != nil {
		return nil, err
	}

	return &data, nil
}

func (r *pemeriksaanAnakRepository) Update(data *models.PemeriksaanAnak) error {
	return r.db.Save(data).Error
}

func (r *pemeriksaanAnakRepository) Delete(id int32) error {
	return r.db.Delete(&models.PemeriksaanAnak{}, id).Error
}
// dari pemeriksaan TERBARU setiap penduduk dalam daftar ID.
func (r *pemeriksaanAnakRepository) GetLatestRiskCountByPendudukIDs(pendudukIDs []int32) (map[string]int, error) {
    if len(pendudukIDs) == 0 {
        return map[string]int{"Normal": 0, "Sedang": 0, "Tinggi": 0}, nil
    }

    // Subquery: tanggal pemeriksaan terbaru per penduduk
    subQuery := r.db.Model(&models.PemeriksaanAnak{}).
        Select("penduduk_id, MAX(tanggal_pemeriksaan) as max_tanggal").
        Where("penduduk_id IN (?)", pendudukIDs).
        Group("penduduk_id")

    var results []struct {
        KategoriRisiko string
        Count          int
    }
    err := r.db.Table("pemeriksaan_anak as pa").
        Select("pa.kategori_risiko, COUNT(*) as count").
        Joins("INNER JOIN (?) as latest ON latest.penduduk_id = pa.penduduk_id AND latest.max_tanggal = pa.tanggal_pemeriksaan", subQuery).
        Group("pa.kategori_risiko").
        Scan(&results).Error
    if err != nil {
        return nil, err
    }

    riskMap := map[string]int{"Normal": 0, "Sedang": 0, "Tinggi": 0}
    for _, r := range results {
        normalized := utils.NormalizeRisk(r.KategoriRisiko)
        riskMap[normalized] += r.Count
    }
    return riskMap, nil
}

// CountPendudukWithExamination mengembalikan jumlah penduduk dalam daftar ID yang memiliki setidaknya satu catatan pemeriksaan
func (r *pemeriksaanAnakRepository) CountPendudukWithExamination(pendudukIDs []int32) (int64, error) {
    if len(pendudukIDs) == 0 {
        return 0, nil
    }
    var count int64
    err := r.db.Model(&models.PemeriksaanAnak{}).
        Where("penduduk_id IN (?)", pendudukIDs).
        Distinct("penduduk_id").
        Count(&count).Error
    return count, err
}

// GetAllLatestExamination mengambil pemeriksaan terbaru setiap anak, opsional filter risiko
func (r *pemeriksaanAnakRepository) GetAllLatestExamination(risikoFilter string) ([]models.PemeriksaanAnak, error) {
    // Subquery: tanggal pemeriksaan terbaru per penduduk
    subQuery := r.db.Model(&models.PemeriksaanAnak{}).
        Select("penduduk_id, MAX(tanggal_pemeriksaan) as max_tanggal").
        Where("deleted_at IS NULL").
        Group("penduduk_id")

    query := r.db.Table("pemeriksaan_anak as pa").
        Select("pa.*").
        Joins("INNER JOIN (?) as latest ON latest.penduduk_id = pa.penduduk_id AND latest.max_tanggal = pa.tanggal_pemeriksaan", subQuery).
        Preload("Penduduk"). // pastikan relasi Penduduk ada di model
        Where("pa.deleted_at IS NULL")

    if risikoFilter != "" {
        normalized := utils.NormalizeRisk(risikoFilter)
        query = query.Where("pa.kategori_risiko = ?", normalized)
    }

    var results []models.PemeriksaanAnak
    err := query.Find(&results).Error
    return results, err
}

func (r *pemeriksaanAnakRepository) GetAllByPendudukID(pendudukID int32) ([]models.PemeriksaanAnak, error) {
    var data []models.PemeriksaanAnak
    err := r.db.
        Where("penduduk_id = ? AND deleted_at IS NULL", pendudukID).
        Order("tanggal_pemeriksaan DESC").
        Find(&data).Error
    return data, err
}

func (r *pemeriksaanAnakRepository) GetLatestByPendudukID(pendudukID int32) (*models.PemeriksaanAnak, error) {
    var exam models.PemeriksaanAnak
    err := r.db.Where("penduduk_id = ? AND deleted_at IS NULL", pendudukID).
        Order("tanggal_pemeriksaan DESC, id DESC").
        First(&exam).Error
    if err == gorm.ErrRecordNotFound {
        return nil, nil
    }
    return &exam, err
}