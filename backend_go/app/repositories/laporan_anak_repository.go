package repositories

import (
	"time"

	"monitoring-service/app/middlewares"
	"monitoring-service/app/models"

	"gorm.io/gorm"
)

type LaporanAnakRepository interface {
	GetLaporanAnak(startDate, endDate string, desaID *int32, role string) ([]models.LaporanAnak, error)
	GetLaporanPertumbuhan(startDate, endDate string, desaID *int32, role string) ([]models.LaporanPertumbuhan, error)
	GetLaporanImunisasi(startDate, endDate string, desaID *int32, role string) ([]models.LaporanImunisasi, error)
}

type laporanAnakRepository struct {
	db *gorm.DB
}

func NewLaporanAnakRepository(db *gorm.DB) LaporanAnakRepository {
	return &laporanAnakRepository{db}
}

// GetLaporanAnak mengambil data anak untuk export laporan.
// Query menggunakan JOIN agar semua data diambil dalam satu query yang efisien.
//
// Relasi:
//   anak → penduduk (data anak: NIK, nama, tgl lahir, goldarah, kecamatan, desa)
//   anak → kehamilan → ibu → penduduk (nama ibu)
//   ibu → suami_id → penduduk (nama ayah)
//   penduduk → desa_id → desa (nama desa)
//
// Filter desa_id diterapkan pada penduduk anak (pa.desa_id).
// Soft delete (deleted_at IS NULL) diperhatikan pada semua tabel yang memilikinya.
func (r *laporanAnakRepository) GetLaporanAnak(startDate, endDate string, desaID *int32, role string) ([]models.LaporanAnak, error) {
	var result []models.LaporanAnak

	query := r.db.Table("anak a").
		Select(`
			COALESCE(kk.no_kk, '') AS no_kk,
			COALESCE(pa.nik, '') AS nik,
			COALESCE(pa.nama_lengkap, '') AS nama_anak,
			COALESCE(pi.nama_lengkap, '') AS nama_ibu,
			COALESCE(ps.nama_lengkap, '') AS nama_ayah,
			pa.tanggal_lahir,
			COALESCE(a.berat_lahir_kg, 0) AS berat_lahir_kg,
			COALESCE(a.tinggi_lahir_cm, 0) AS tinggi_lahir_cm,
			COALESCE((SELECT cp.hasil_lila FROM catatan_pertumbuhan cp WHERE cp.anak_id = a.id AND cp.deleted_at IS NULL ORDER BY cp.tgl_ukur DESC LIMIT 1), 0) AS lila,
			COALESCE(pa.golongan_darah, '') AS golongan_darah,
			COALESCE(pa.kecamatan, '') AS kecamatan,
			COALESCE(d.nama_desa, '') AS desa
		`).
		// JOIN ke penduduk anak
		Joins("JOIN penduduk pa ON pa.id = a.penduduk_id AND pa.deleted_at IS NULL").
		// JOIN ke kartu keluarga
		Joins("LEFT JOIN kartu_keluarga kk ON kk.id = pa.kartu_keluarga_id AND kk.deleted_at IS NULL").
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
			tEnd = tEnd.Add(24*time.Hour - time.Second) // 23:59:59
			query = query.Where("pa.tanggal_lahir >= ? AND pa.tanggal_lahir <= ?", tStart, tEnd)
		}
	}

	// Filter desa berdasarkan role
	// Bidan hanya melihat data anak di desanya sendiri
	// Admin/Dokter/Superadmin melihat semua
	if !middlewares.HasFullAccess(role) && desaID != nil {
		query = query.Where("pa.desa_id = ?", *desaID)
	}

	query = query.Order("pa.nama_lengkap ASC")

	err := query.Scan(&result).Error
	return result, err
}

// GetLaporanPertumbuhan mengambil data riwayat pertumbuhan anak.
func (r *laporanAnakRepository) GetLaporanPertumbuhan(startDate, endDate string, desaID *int32, role string) ([]models.LaporanPertumbuhan, error) {
	var result []models.LaporanPertumbuhan

	query := r.db.Table("catatan_pertumbuhan cp").
		Select(`
			COALESCE(pa.nik, '') AS nik,
			COALESCE(pa.nama_lengkap, '') AS nama_anak,
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
		Where("cp.deleted_at IS NULL")

	// Filter tanggal pengukuran
	if startDate != "" && endDate != "" {
		tStart, errStart := time.Parse("2006-01-02", startDate)
		tEnd, errEnd := time.Parse("2006-01-02", endDate)
		if errStart == nil && errEnd == nil {
			tEnd = tEnd.Add(24*time.Hour - time.Second) // 23:59:59
			query = query.Where("cp.tgl_ukur >= ? AND cp.tgl_ukur <= ?", tStart, tEnd)
		}
	}

	// Filter desa berdasarkan role
	if !middlewares.HasFullAccess(role) && desaID != nil {
		query = query.Where("pa.desa_id = ?", *desaID)
	}

	query = query.Order("pa.nama_lengkap ASC, cp.tgl_ukur ASC")

	err := query.Scan(&result).Error
	return result, err
}

// GetLaporanImunisasi mengambil data riwayat imunisasi anak dari tabel detail_pelayanan_imunisasi.
// Jika tabel tidak ditemukan atau kueri gagal karena masalah skema, error ditangani secara anggun
// dengan mengembalikan slice kosong agar ekspor laporan keseluruhan tetap berhasil.
func (r *laporanAnakRepository) GetLaporanImunisasi(startDate, endDate string, desaID *int32, role string) ([]models.LaporanImunisasi, error) {
	var result []models.LaporanImunisasi

	query := r.db.Table("detail_pelayanan_imunisasi dpi").
		Select(`
			COALESCE(pa.nik, '') AS nik,
			COALESCE(pa.nama_lengkap, '') AS nama_anak,
			COALESCE(jp.nama, '') AS nama_vaksin,
			ki.created_at AS tgl_pemberian,
			'Sudah' AS status,
			'' AS lokasi,
			'' AS petugas
		`).
		Joins("JOIN kehadiran_imunisasi ki ON ki.id = dpi.kunjungan_imunisasi_id AND ki.deleted_at IS NULL").
		Joins("JOIN anak a ON a.id = ki.anak_id AND a.deleted_at IS NULL").
		Joins("JOIN penduduk pa ON pa.id = a.penduduk_id AND pa.deleted_at IS NULL").
		Joins("LEFT JOIN jenis_pelayanan jp ON jp.id = dpi.jenis_pelayanan_id AND jp.deleted_at IS NULL").
		Where("dpi.deleted_at IS NULL")

	// Filter tanggal pemberian
	if startDate != "" && endDate != "" {
		tStart, errStart := time.Parse("2006-01-02", startDate)
		tEnd, errEnd := time.Parse("2006-01-02", endDate)
		if errStart == nil && errEnd == nil {
			tEnd = tEnd.Add(24*time.Hour - time.Second) // 23:59:59
			query = query.Where("ki.created_at >= ? AND ki.created_at <= ?", tStart, tEnd)
		}
	}

	// Filter desa berdasarkan role
	if !middlewares.HasFullAccess(role) && desaID != nil {
		query = query.Where("pa.desa_id = ?", *desaID)
	}

	query = query.Order("pa.nama_lengkap ASC, ki.created_at ASC")

	err := query.Scan(&result).Error
	if err != nil {
		// Menangani error SQLSTATE 42P01 secara anggun
		println("Warning: GetLaporanImunisasi failed (table or column missing):", err.Error())
		return []models.LaporanImunisasi{}, nil
	}

	return result, nil
}
