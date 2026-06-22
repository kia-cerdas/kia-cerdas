package repositories

import (
	"time"

	"monitoring-service/app/middlewares"
	"monitoring-service/app/models"

	"gorm.io/gorm"
)

type LaporanAnakRepository interface {
	GetLaporanAnak(startDate, endDate string, posyanduID *int32, role string) ([]models.LaporanAnak, error)
}

type laporanAnakRepository struct {
	db *gorm.DB
}

func NewLaporanAnakRepository(db *gorm.DB) LaporanAnakRepository {
	return &laporanAnakRepository{db}
}

func (r *laporanAnakRepository) GetLaporanAnak(startDate, endDate string, posyanduID *int32, role string) ([]models.LaporanAnak, error) {
	var result []models.LaporanAnak

	query := r.db.Table("pemeriksaans pa").
		Select(`
			COALESCE(p.nik, '') AS nik,
			COALESCE(p.nama_anggota_keluarga, '') AS nama_lengkap,
			p.tanggal_lahir,
			EXTRACT(YEAR FROM AGE(pa.tanggal_pemeriksaan, p.tanggal_lahir))::int AS umur,
			COALESCE(p.jenis_kelamin, '') AS jenis_kelamin,
			COALESCE(p.dusun, '') AS dusun,
			COALESCE(p.rt, '') AS rt,
			COALESCE(p.rw, '') AS rw,
			COALESCE(d.nama_desa, '') AS desa,
			pa.tanggal_pemeriksaan,
			COALESCE(pa.kategori_risiko, '') AS kategori_risiko,
			COALESCE(pa.rekomendasi, '') AS rekomendasi,
			pa.jawaban::text AS jawaban_raw
		`).
		Joins("JOIN penduduk p ON p.id = pa.penduduk_id AND p.deleted_at IS NULL").
		Joins("LEFT JOIN desa d ON d.id = p.desa_id").
		Where("pa.deleted_at IS NULL AND pa.kelompok = 'anak'")

	if startDate != "" && endDate != "" {
		tStart, _ := time.Parse("2006-01-02", startDate)
		tEnd, _ := time.Parse("2006-01-02", endDate)
		if !tStart.IsZero() && !tEnd.IsZero() {
			tEnd = tEnd.Add(24*time.Hour - time.Second)
			query = query.Where("pa.tanggal_pemeriksaan >= ? AND pa.tanggal_pemeriksaan <= ?", tStart, tEnd)
		}
	}

	if posyanduID != nil && *posyanduID > 0 && !middlewares.HasFullAccess(role) {
		query = query.Where("p.posyandu_id = ?", *posyanduID)
	}

	query = query.Order("p.nama_anggota_keluarga ASC")

	err := query.Scan(&result).Error
	return result, err
}