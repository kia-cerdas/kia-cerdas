package repositories

import (
	"time"

	"monitoring-service/app/middlewares"
	"monitoring-service/app/models"

	"gorm.io/gorm"
)

type LaporanLansiaRepository interface {
	GetLaporanLansia(startDate, endDate string, desaID *int32, role string) ([]models.LaporanLansia, error)
}

type laporanLansiaRepository struct {
	db *gorm.DB
}

func NewLaporanLansiaRepository(db *gorm.DB) LaporanLansiaRepository {
	return &laporanLansiaRepository{db}
}

// GetLaporanLansia mengambil data lansia untuk export laporan.
func (r *laporanLansiaRepository) GetLaporanLansia(startDate, endDate string, desaID *int32, role string) ([]models.LaporanLansia, error) {
	var result []models.LaporanLansia

	query := r.db.Table("pemeriksaans pl").
		Select(`
			COALESCE(p.nik, '') AS nik,
			COALESCE(p.nama_lengkap, '') AS nama_lengkap,
			p.tanggal_lahir,
			EXTRACT(YEAR FROM AGE(pl.tanggal_pemeriksaan, p.tanggal_lahir))::int AS umur,
			COALESCE(p.jenis_kelamin, '') AS jenis_kelamin,
			pl.tanggal_pemeriksaan,
			(pl.jawaban->>'berat_badan')::float AS berat_badan,
			(pl.jawaban->>'tinggi_badan')::float AS tinggi_badan,
			(pl.jawaban->>'imt')::float AS imt,
			COALESCE((pl.jawaban->>'sistole')::text || '/' || (pl.jawaban->>'diastole')::text, '') AS tekanan_darah,
			(pl.jawaban->>'gula_darah')::float AS gula_darah,
			COALESCE(pl.kategori_risiko, '') AS kategori_risiko,
			COALESCE(pl.jawaban->>'status_pemantauan', '') AS status_pemantauan,
			COALESCE(pl.jawaban->>'penyakit_kronis', '') AS penyakit_kronis,
			COALESCE(pl.jawaban->>'status_kemandirian', '') AS status_kemandirian,
			(pl.jawaban->>'riwayat_jatuh')::boolean AS riwayat_jatuh,
			COALESCE(pl.jawaban->>'catatan_khusus', '') AS catatan_khusus,
			COALESCE(p.kecamatan, '') AS kecamatan,
			COALESCE(d.nama_desa, '') AS desa
		`).
		Joins("JOIN penduduk p ON p.id = pl.penduduk_id AND p.deleted_at IS NULL").
		Joins("LEFT JOIN desa d ON d.id = p.desa_id").
		Where("pl.deleted_at IS NULL AND pl.kelompok = 'lansia'")

	// Filter tanggal pemeriksaan
	if startDate != "" && endDate != "" {
		tStart, errStart := time.Parse("2006-01-02", startDate)
		tEnd, errEnd := time.Parse("2006-01-02", endDate)
		if errStart == nil && errEnd == nil {
			tEnd = tEnd.Add(24*time.Hour - time.Second) // 23:59:59
			query = query.Where("pl.tanggal_pemeriksaan >= ? AND pl.tanggal_pemeriksaan <= ?", tStart, tEnd)
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
