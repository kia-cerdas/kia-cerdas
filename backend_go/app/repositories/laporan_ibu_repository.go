// repositories/laporan_ibu_repository.go

package repositories

import (
	"monitoring-service/app/middlewares"
	"monitoring-service/app/models"

	"gorm.io/gorm"
)

type LaporanIbuRepository interface {
	GetLaporanIbu(bulan, tahun int, posyanduID *int32, role string) ([]models.LaporanIbu, error)
}

type laporanIbuRepository struct {
	db *gorm.DB
}

func NewLaporanIbuRepository(db *gorm.DB) LaporanIbuRepository {
	return &laporanIbuRepository{db}
}

func (r *laporanIbuRepository) GetLaporanIbu(bulan, tahun int, posyanduID *int32, role string) ([]models.LaporanIbu, error) {
	var result []models.LaporanIbu

	//  Query dengan field yang sesuai dengan model Kependudukan
	query := r.db.Table("pemeriksaan_kehamilan pk").
		Select(`
			COALESCE(p.nik, '') as nik,
			COALESCE(p.nama_anggota_keluarga, '') as nama_ibu,
			COALESCE(s.nama_anggota_keluarga, '') as nama_suami,
			p.tanggal_lahir,
			k.hpht,
			k.taksiran_persalinan as hpl,
			COALESCE(k.uk_kehamilan_saat_ini, 0) as usia_kehamilan,
			COALESCE(pk.trimester, '') as trimester,
			COALESCE(i.gravida, 0) as gravida,
			COALESCE(i.paritas, 0) as paritas,
			COALESCE(i.abortus, 0) as abortus,
			COALESCE(k.bb_awal, 0) as bb_awal,
			COALESCE(k.tb, 0) as tinggi_badan,
			COALESCE(k.imt_awal, 0) as imt,
			COALESCE(pk.lingkar_lengan_atas, 0) as lila,
			CONCAT(COALESCE(pk.sistole, 0), '/', COALESCE(pk.diastole, 0)) as tekanan_darah,
			COALESCE(pk.sistole, 0) as sistole,
			COALESCE(pk.diastole, 0) as diastole,
			COALESCE(pk.tinggi_rahim, 0) as tinggi_fundus,
			COALESCE(pk.tes_lab_hb, 0) as hb,
			COALESCE(pk.tes_golongan_darah, '') as golongan_darah,
			COALESCE(pk.status_imunisasi_tetanus, '') as status_imunisasi,
			COALESCE(pk.tripel_eliminasi, '') as tripel_eliminasi,
			COALESCE(pk.kunjungan_ke, 0) as kunjungan_anc,
			COALESCE(pk.tata_laksana_kasus, '') as tindakan,
			COALESCE(d.nama_desa, '') as desa,
			COALESCE(p.dusun, '') as dusun,
			COALESCE(p.rt, '') as rt,
			COALESCE(p.rw, '') as rw
		`).
		Joins("INNER JOIN kehamilan k ON pk.kehamilan_id = k.id AND k.deleted_at IS NULL").
		Joins("INNER JOIN ibu i ON k.ibu_id = i.id AND i.is_deleted IS NULL").
		Joins("INNER JOIN penduduk p ON i.penduduk_id = p.id AND p.deleted_at IS NULL").
		Joins("LEFT JOIN penduduk s ON i.suami_id = s.id AND s.deleted_at IS NULL").
		Joins("LEFT JOIN desa d ON p.desa_id = d.id")
		// Where("pk.deleted_at IS NULL")

	// Filter berdasarkan bulan dan tahun
	if bulan > 0 && tahun > 0 {
		query = query.Where("EXTRACT(MONTH FROM pk.tanggal_periksa) = ? AND EXTRACT(YEAR FROM pk.tanggal_periksa) = ?", bulan, tahun)
	}

	// Filter berdasarkan role dan posyandu
	if !middlewares.HasFullAccess(role) && posyanduID != nil {
		query = query.Where("p.posyandu_id = ?", *posyanduID)
	}

	// Order by nama ibu
	query = query.Order("p.nama_anggota_keluarga ASC")

	err := query.Scan(&result).Error
	return result, err
}