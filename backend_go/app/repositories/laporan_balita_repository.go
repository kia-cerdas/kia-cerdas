package repositories

import (
	"time"

	"monitoring-service/app/middlewares"
	"monitoring-service/app/models"

	"gorm.io/gorm"
)

type LaporanBalitaRepository interface {
	GetLaporanBalita(startDate, endDate string, posyanduID *int32, role string) ([]models.LaporanBalita, error)
	GetLaporanPertumbuhan(startDate, endDate string, posyanduID *int32, role string) ([]models.LaporanPertumbuhan, error)
	GetLaporanImunisasi(startDate, endDate string, posyanduID *int32, role string) ([]models.LaporanImunisasi, error)
}

type laporanBalitaRepository struct {
	db *gorm.DB
}

func NewLaporanBalitaRepository(db *gorm.DB) LaporanBalitaRepository {
	return &laporanBalitaRepository{db}
}

// GetLaporanBalita mengambil data balita untuk export laporan.
// Menggunakan model Kependudukan dengan field yang benar:
// - NamaAnggotaKeluarga (bukan nama_lengkap)
// - KodeKeluarga sebagai No KK
func (r *laporanBalitaRepository) GetLaporanBalita(startDate, endDate string, posyanduID *int32, role string) ([]models.LaporanBalita, error) {
	var result []models.LaporanBalita

	query := r.db.Table("anak a").
		Select(`
			COALESCE(pa.kode_keluarga, '') AS no_kk,
			COALESCE(pa.nik, '') AS nik,
			COALESCE(pa.nama_anggota_keluarga, '') AS nama_anak,
			COALESCE(pi.nama_anggota_keluarga, '') AS nama_ibu,
			COALESCE(ps.nama_anggota_keluarga, '') AS nama_ayah,
			pa.tanggal_lahir,
			COALESCE(a.berat_lahir_kg, 0) AS berat_lahir_kg,
			COALESCE(a.tinggi_lahir_cm, 0) AS tinggi_lahir_cm,
			COALESCE((SELECT cp.hasil_lila FROM catatan_pertumbuhan cp WHERE cp.anak_id = a.id AND cp.deleted_at IS NULL ORDER BY cp.tgl_ukur DESC LIMIT 1), 0) AS lila,
			COALESCE(pa.golongan_darah, '') AS golongan_darah,
			COALESCE(d.nama_desa, '') AS desa
		`).
		// JOIN ke penduduk anak (pa)
		Joins("JOIN penduduk pa ON pa.id = a.penduduk_id AND pa.deleted_at IS NULL").
		// JOIN ke kehamilan → ibu → penduduk ibu
		Joins("LEFT JOIN kehamilan k ON k.id = a.kehamilan_id AND k.deleted_at IS NULL").
		Joins("LEFT JOIN ibu i ON i.id = k.ibu_id AND i.is_deleted IS NULL").
		Joins("LEFT JOIN penduduk pi ON pi.id = i.penduduk_id AND pi.deleted_at IS NULL").
		// JOIN ke suami (ayah) melalui ibu.suami_id
		Joins("LEFT JOIN penduduk ps ON ps.id = i.suami_id AND ps.deleted_at IS NULL").
		// JOIN ke desa
		Joins("LEFT JOIN desa d ON d.id = pa.desa_id").
		// Soft delete pada tabel anak
		Where("a.deleted_at IS NULL")

	// Filter tanggal lahir
	if startDate != "" && endDate != "" {
		tStart, errStart := time.Parse("2006-01-02", startDate)
		tEnd, errEnd := time.Parse("2006-01-02", endDate)
		if errStart == nil && errEnd == nil {
			tEnd = tEnd.Add(24*time.Hour - time.Second)
			query = query.Where("pa.tanggal_lahir >= ? AND pa.tanggal_lahir <= ?", tStart, tEnd)
		}
	}

	// Filter posyandu berdasarkan role
	if !middlewares.HasFullAccess(role) && posyanduID != nil {
		query = query.Where("pa.posyandu_id = ?", *posyanduID)
	}

	query = query.Order("pa.nama_anggota_keluarga ASC")

	err := query.Scan(&result).Error
	return result, err
}

// GetLaporanPertumbuhan mengambil data riwayat pertumbuhan balita.
func (r *laporanBalitaRepository) GetLaporanPertumbuhan(startDate, endDate string, posyanduID *int32, role string) ([]models.LaporanPertumbuhan, error) {
	var result []models.LaporanPertumbuhan

	query := r.db.Table("catatan_pertumbuhan cp").
		Select(`
			COALESCE(pa.nik, '') AS nik,
			COALESCE(pa.nama_anggota_keluarga, '') AS nama_anak,
			cp.tgl_ukur,
			cp.usia_ukur_bulan,
			COALESCE(cp.berat_badan, 0) AS berat_badan,
			COALESCE(cp.tinggi_badan, 0) AS tinggi_badan,
			COALESCE(cp.hasil_lila, 0) AS hasil_lila,
			COALESCE(cp.lingkar_kepala, 0) AS lingkar_kepala,
			COALESCE(cp.imt, 0) AS imt,
			COALESCE(cp.status_bb_u, '') AS status_bb_u,
			COALESCE(cp.status_tb_u, '') AS status_tb_u,
			COALESCE(cp.status_bb_tb, '') AS status_bb_tb,
			COALESCE(cp.status_imt_u, '') AS status_imt_u,
			COALESCE(cp.catatan_nakes, '') AS catatan_nakes
		`).
		Joins("JOIN anak a ON a.id = cp.anak_id AND a.deleted_at IS NULL").
		Joins("JOIN penduduk pa ON pa.id = a.penduduk_id AND pa.deleted_at IS NULL").
		Joins("LEFT JOIN ibu i ON i.id = a.ibu_id").
		Joins("LEFT JOIN penduduk pi ON pi.id = i.penduduk_id AND pi.deleted_at IS NULL").
		Where("cp.deleted_at IS NULL")

	// Filter tanggal pengukuran
	if startDate != "" && endDate != "" {
		tStart, errStart := time.Parse("2006-01-02", startDate)
		tEnd, errEnd := time.Parse("2006-01-02", endDate)
		if errStart == nil && errEnd == nil {
			tEnd = tEnd.Add(24*time.Hour - time.Second)
			query = query.Where("cp.tgl_ukur >= ? AND cp.tgl_ukur <= ?", tStart, tEnd)
		}
	}

	// Filter posyandu berdasarkan role
	if !middlewares.HasFullAccess(role) && posyanduID != nil {
		query = query.Where("pa.posyandu_id = ?", *posyanduID)
	}

	query = query.Order("pa.nama_anggota_keluarga ASC, cp.tgl_ukur ASC")

	err := query.Scan(&result).Error
	return result, err
}

// GetLaporanImunisasi mengambil data riwayat imunisasi balita.
func (r *laporanBalitaRepository) GetLaporanImunisasi(startDate, endDate string, posyanduID *int32, role string) ([]models.LaporanImunisasi, error) {
	var result []models.LaporanImunisasi

	query := r.db.Table("detail_pelayanan_imunisasi dpi").
		Select(`
			COALESCE(pa.nik, '') AS nik,
			COALESCE(pa.nama_anggota_keluarga, '') AS nama_anak,
			COALESCE(jp.nama, '') AS nama_vaksin,
			ki.created_at AS tgl_pemberian,
			'Sudah' AS status,
			'' AS lokasi,
			'' AS petugas
		`).
		Joins("JOIN kehadiran_imunisasi ki ON ki.id = dpi.kunjungan_imunisasi_id AND ki.deleted_at IS NULL").
		Joins("JOIN anak a ON a.id = ki.anak_id AND a.deleted_at IS NULL").
		Joins("JOIN penduduk pa ON pa.id = a.penduduk_id AND pa.deleted_at IS NULL").
		Joins("LEFT JOIN ibu i ON i.id = a.ibu_id").
		Joins("LEFT JOIN penduduk pi ON pi.id = i.penduduk_id AND pi.deleted_at IS NULL").
		Joins("LEFT JOIN jenis_pelayanan jp ON jp.id = dpi.jenis_pelayanan_id AND jp.deleted_at IS NULL").
		Where("dpi.deleted_at IS NULL")

	// Filter tanggal pemberian
	if startDate != "" && endDate != "" {
		tStart, errStart := time.Parse("2006-01-02", startDate)
		tEnd, errEnd := time.Parse("2006-01-02", endDate)
		if errStart == nil && errEnd == nil {
			tEnd = tEnd.Add(24*time.Hour - time.Second)
			query = query.Where("ki.created_at >= ? AND ki.created_at <= ?", tStart, tEnd)
		}
	}

	// Filter posyandu berdasarkan role
	if !middlewares.HasFullAccess(role) && posyanduID != nil {
		query = query.Where("pa.posyandu_id = ?", *posyanduID)
	}

	query = query.Order("pa.nama_anggota_keluarga ASC, ki.created_at ASC")

	err := query.Scan(&result).Error
	if err != nil {
		println("Warning: GetLaporanImunisasi failed (table or column missing):", err.Error())
		return []models.LaporanImunisasi{}, nil
	}

	return result, nil
}
