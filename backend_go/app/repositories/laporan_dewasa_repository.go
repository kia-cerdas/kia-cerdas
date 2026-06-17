package repositories

import (
	"time"

	"monitoring-service/app/middlewares"
	"monitoring-service/app/models"

	"gorm.io/gorm"
)

type LaporanDewasaRepository interface {
	GetLaporanDewasa(startDate, endDate string, desaID *int32, role string) ([]models.LaporanDewasa, error)
}

type laporanDewasaRepository struct {
	db *gorm.DB
}

func NewLaporanDewasaRepository(db *gorm.DB) LaporanDewasaRepository {
	return &laporanDewasaRepository{db}
}

// GetLaporanDewasa mengambil data dewasa untuk export laporan.
func (r *laporanDewasaRepository) GetLaporanDewasa(startDate, endDate string, desaID *int32, role string) ([]models.LaporanDewasa, error) {
	var result []models.LaporanDewasa

	query := r.db.Table("pemeriksaans pd").
		Select(`
			COALESCE(p.nik, '') AS nik,
			COALESCE(p.nama_lengkap, '') AS nama_lengkap,
			p.tanggal_lahir,
			EXTRACT(YEAR FROM AGE(pd.tanggal_pemeriksaan, p.tanggal_lahir))::int AS umur,
			COALESCE(p.jenis_kelamin, '') AS jenis_kelamin,
			pd.tanggal_pemeriksaan,
			(pd.jawaban->>'berat_badan')::float AS berat_badan,
			(pd.jawaban->>'tinggi_badan')::float AS tinggi_badan,
			(pd.jawaban->>'imt')::float AS imt,
			COALESCE((pd.jawaban->>'sistole')::text || '/' || (pd.jawaban->>'diastole')::text, '') AS tekanan_darah,
			(pd.jawaban->>'gula_darah')::float AS gula_darah,
			(pd.jawaban->>'kolesterol')::float AS kolesterol,
			COALESCE(pd.kategori_risiko, '') AS kategori_risiko,
			COALESCE(pd.jawaban->>'status_pemantauan', '') AS status_pemantauan,
			COALESCE(pd.jawaban->>'riwayat_penyakit', '') AS riwayat_penyakit,
			COALESCE(pd.jawaban->>'penyakit_kronis', '') AS penyakit_kronis,
			COALESCE(pd.jawaban->>'catatan_khusus', '') AS catatan_khusus,
			COALESCE(p.kecamatan, '') AS kecamatan,
			COALESCE(d.nama_desa, '') AS desa
		`).
		Joins("JOIN penduduk p ON p.id = pd.penduduk_id AND p.deleted_at IS NULL").
		Joins("LEFT JOIN desa d ON d.id = p.desa_id").
		Where("pd.deleted_at IS NULL AND pd.kelompok = 'dewasa'")

	// Filter tanggal pemeriksaan
	if startDate != "" && endDate != "" {
		tStart, errStart := time.Parse("2006-01-02", startDate)
		tEnd, errEnd := time.Parse("2006-01-02", endDate)
		if errStart == nil && errEnd == nil {
			tEnd = tEnd.Add(24*time.Hour - time.Second) // 23:59:59
			query = query.Where("pd.tanggal_pemeriksaan >= ? AND pd.tanggal_pemeriksaan <= ?", tStart, tEnd)
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
