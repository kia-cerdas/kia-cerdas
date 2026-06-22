// repositories/laporan_remaja_repository.go

package repositories

import (
	"time"

	"monitoring-service/app/middlewares"
	"monitoring-service/app/models"

	"gorm.io/gorm"
)

type LaporanRemajaRepository interface {
	GetLaporanRemaja(startDate, endDate string, posyanduID *int32, role string) ([]models.LaporanRemaja, error)
}

type laporanRemajaRepository struct {
	db *gorm.DB
}

func NewLaporanRemajaRepository(db *gorm.DB) LaporanRemajaRepository {
	return &laporanRemajaRepository{db}
}

// repositories/laporan_remaja_repository.go

func (r *laporanRemajaRepository) GetLaporanRemaja(startDate, endDate string, posyanduID *int32, role string) ([]models.LaporanRemaja, error) {
	var result []models.LaporanRemaja

	query := r.db.Table("pemeriksaans pr").
		Select(`
			COALESCE(p.nik, '') AS nik,
			COALESCE(p.nama_anggota_keluarga, '') AS nama_lengkap,
			p.tanggal_lahir,
			EXTRACT(YEAR FROM AGE(pr.tanggal_pemeriksaan, p.tanggal_lahir))::int AS umur,
			COALESCE(p.jenis_kelamin, '') AS jenis_kelamin,
			COALESCE(p.dusun, '') AS dusun,
			COALESCE(p.rt, '') AS rt,
			COALESCE(p.rw, '') AS rw,
			COALESCE(d.nama_desa, '') AS desa,
			pr.tanggal_pemeriksaan,
			COALESCE(pr.kategori_risiko, '') AS kategori_risiko,
			COALESCE(pr.rekomendasi, '') AS rekomendasi,
			pr.jawaban::text AS jawaban_raw
		`).
		Joins("JOIN penduduk p ON p.id = pr.penduduk_id AND p.deleted_at IS NULL").
		Joins("LEFT JOIN desa d ON d.id = p.desa_id").
		Where("pr.deleted_at IS NULL AND pr.kelompok = 'remaja'")

	// Filter tanggal
	if startDate != "" && endDate != "" {
		tStart, errStart := time.Parse("2006-01-02", startDate)
		tEnd, errEnd := time.Parse("2006-01-02", endDate)
		if errStart == nil && errEnd == nil {
			tEnd = tEnd.Add(24*time.Hour - time.Second)
			query = query.Where("pr.tanggal_pemeriksaan >= ? AND pr.tanggal_pemeriksaan <= ?", tStart, tEnd)
		}
	}

	// Filter posyandu
	if posyanduID != nil && *posyanduID > 0 && !middlewares.HasFullAccess(role) {
		query = query.Where("p.posyandu_id = ?", *posyanduID)
	}

	query = query.Order("p.nama_anggota_keluarga ASC")

	err := query.Scan(&result).Error
	return result, err
}