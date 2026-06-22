package repositories

import (
	"time"

	"monitoring-service/app/middlewares"
	"monitoring-service/app/models"

	"gorm.io/gorm"
)

type LaporanLansiaRepository interface {
	GetLaporanLansia(startDate, endDate string, posyanduID *int32, role string) ([]models.LaporanLansia, error)
}

type laporanLansiaRepository struct {
	db *gorm.DB
}

func NewLaporanLansiaRepository(db *gorm.DB) LaporanLansiaRepository {
	return &laporanLansiaRepository{db}
}

func (r *laporanLansiaRepository) GetLaporanLansia(startDate, endDate string, posyanduID *int32, role string) ([]models.LaporanLansia, error) {
	var result []models.LaporanLansia

	query := r.db.Table("pemeriksaans pl").
		Select(`
			COALESCE(p.nik, '') AS nik,
			COALESCE(p.nama_anggota_keluarga, '') AS nama_lengkap,
			p.tanggal_lahir,
			EXTRACT(YEAR FROM AGE(pl.tanggal_pemeriksaan, p.tanggal_lahir))::int AS umur,
			COALESCE(p.jenis_kelamin, '') AS jenis_kelamin,
			COALESCE(p.dusun, '') AS dusun,
			COALESCE(p.rt, '') AS rt,
			COALESCE(p.rw, '') AS rw,
			COALESCE(d.nama_desa, '') AS desa,
			pl.tanggal_pemeriksaan,
			COALESCE(pl.kategori_risiko, '') AS kategori_risiko,
			COALESCE(pl.rekomendasi, '') AS rekomendasi,
			pl.jawaban::text AS jawaban_raw
		`).
		Joins("JOIN penduduk p ON p.id = pl.penduduk_id AND p.deleted_at IS NULL").
		Joins("LEFT JOIN desa d ON d.id = p.desa_id").
		Where("pl.deleted_at IS NULL AND pl.kelompok = 'lansia'")

	if startDate != "" && endDate != "" {
		tStart, _ := time.Parse("2006-01-02", startDate)
		tEnd, _ := time.Parse("2006-01-02", endDate)
		if !tStart.IsZero() && !tEnd.IsZero() {
			tEnd = tEnd.Add(24*time.Hour - time.Second)
			query = query.Where("pl.tanggal_pemeriksaan >= ? AND pl.tanggal_pemeriksaan <= ?", tStart, tEnd)
		}
	}

	if posyanduID != nil && *posyanduID > 0 && !middlewares.HasFullAccess(role) {
		query = query.Where("p.posyandu_id = ?", *posyanduID)
	}

	query = query.Order("p.nama_anggota_keluarga ASC")

	err := query.Scan(&result).Error
	return result, err
}