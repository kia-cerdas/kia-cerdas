package repositories

import (
	"time"

	"monitoring-service/app/middlewares"
	"monitoring-service/app/models"

	"gorm.io/gorm"
)

type LaporanRemajaRepository interface {
	GetLaporanRemaja(startDate, endDate string, desaID *int32, role string) ([]models.LaporanRemaja, error)
}

type laporanRemajaRepository struct {
	db *gorm.DB
}

func NewLaporanRemajaRepository(db *gorm.DB) LaporanRemajaRepository {
	return &laporanRemajaRepository{db}
}

// GetLaporanRemaja mengambil data remaja untuk export laporan.
func (r *laporanRemajaRepository) GetLaporanRemaja(startDate, endDate string, desaID *int32, role string) ([]models.LaporanRemaja, error) {
	var result []models.LaporanRemaja

	query := r.db.Table("pemeriksaans pr").
		Select(`
			COALESCE(p.nik, '') AS nik,
			COALESCE(p.nama_lengkap, '') AS nama_lengkap,
			p.tanggal_lahir,
			EXTRACT(YEAR FROM AGE(pr.tanggal_pemeriksaan, p.tanggal_lahir))::int AS umur,
			COALESCE(p.jenis_kelamin, '') AS jenis_kelamin,
			pr.tanggal_pemeriksaan,
			(pr.jawaban->>'berat_badan')::float AS berat_badan,
			(pr.jawaban->>'tinggi_badan')::float AS tinggi_badan,
			(pr.jawaban->>'imt')::float AS imt,
			COALESCE((pr.jawaban->>'sistole')::text || '/' || (pr.jawaban->>'diastole')::text, '') AS tekanan_darah,
			COALESCE(pr.kategori_risiko, '') AS kategori_risiko,
			COALESCE(pr.jawaban->>'status_pemantauan', '') AS status_pemantauan,
			COALESCE(pr.jawaban->>'riwayat_penyakit', '') AS riwayat_penyakit,
			COALESCE(pr.jawaban->>'catatan_khusus', '') AS catatan_khusus,
			COALESCE(p.kecamatan, '') AS kecamatan,
			COALESCE(d.nama_desa, '') AS desa
		`).
		Joins("JOIN penduduk p ON p.id = pr.penduduk_id AND p.deleted_at IS NULL").
		Joins("LEFT JOIN desa d ON d.id = p.desa_id").
		Where("pr.deleted_at IS NULL AND pr.kelompok = 'remaja'")

	// Filter tanggal pemeriksaan
	if startDate != "" && endDate != "" {
		tStart, errStart := time.Parse("2006-01-02", startDate)
		tEnd, errEnd := time.Parse("2006-01-02", endDate)
		if errStart == nil && errEnd == nil {
			tEnd = tEnd.Add(24*time.Hour - time.Second) // 23:59:59
			query = query.Where("pr.tanggal_pemeriksaan >= ? AND pr.tanggal_pemeriksaan <= ?", tStart, tEnd)
		}
	}

	// Filter desa berdasarkan role
	if desaID != nil && *desaID > 0 && !middlewares.HasFullAccess(role) {
		query = query.Where("p.desa_id = ?", *desaID)
	}

	query = query.Order("p.nama_lengkap ASC")

	err := query.Scan(&result).Error
	return result, err
}
