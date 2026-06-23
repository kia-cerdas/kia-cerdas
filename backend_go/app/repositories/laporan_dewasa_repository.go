package repositories

import (
	"time"

	"monitoring-service/app/middlewares"
	"monitoring-service/app/models"

	"gorm.io/gorm"
)

type LaporanDewasaRepository interface {
	GetLaporanDewasa(startDate, endDate string, posyanduID *int32, role string) ([]models.LaporanDewasa, error)
}

type laporanDewasaRepository struct {
	db *gorm.DB
}

func NewLaporanDewasaRepository(db *gorm.DB) LaporanDewasaRepository {
	return &laporanDewasaRepository{db}
}

func (r *laporanDewasaRepository) GetLaporanDewasa(startDate, endDate string, posyanduID *int32, role string) ([]models.LaporanDewasa, error) {
	var result []models.LaporanDewasa

	query := r.db.Table("pemeriksaans pd").
		Select(`
			COALESCE(p.nik, '') AS nik,
			COALESCE(p.nama_anggota_keluarga, '') AS nama_lengkap,
			p.tanggal_lahir,
			EXTRACT(YEAR FROM AGE(pd.tanggal_pemeriksaan, p.tanggal_lahir))::int AS umur,
			COALESCE(p.jenis_kelamin, '') AS jenis_kelamin,
			COALESCE(p.dusun, '') AS dusun,
			COALESCE(p.rt, '') AS rt,
			COALESCE(p.rw, '') AS rw,
			COALESCE(d.nama_desa, '') AS desa,
			pd.tanggal_pemeriksaan,
			COALESCE(pd.kategori_risiko, '') AS kategori_risiko,
			COALESCE(pd.rekomendasi, '') AS rekomendasi,
			pd.jawaban::text AS jawaban_raw
		`).
		Joins("JOIN penduduk p ON p.id = pd.penduduk_id AND p.deleted_at IS NULL").
		Joins("LEFT JOIN desa d ON d.id = p.desa_id").
		Where("pd.deleted_at IS NULL AND pd.kelompok = 'dewasa'")

	if startDate != "" && endDate != "" {
		tStart, _ := time.Parse("2006-01-02", startDate)
		tEnd, _ := time.Parse("2006-01-02", endDate)
		if !tStart.IsZero() && !tEnd.IsZero() {
			tEnd = tEnd.Add(24*time.Hour - time.Second)
			query = query.Where("pd.tanggal_pemeriksaan >= ? AND pd.tanggal_pemeriksaan <= ?", tStart, tEnd)
		}
	}

	if posyanduID != nil && *posyanduID > 0 && !middlewares.HasFullAccess(role) {
		query = query.Where("p.posyandu_id = ?", *posyanduID)
	}

	query = query.Order("p.nama_anggota_keluarga ASC")

	err := query.Scan(&result).Error
	return result, err
}