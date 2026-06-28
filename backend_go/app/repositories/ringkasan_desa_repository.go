package repositories

import "gorm.io/gorm"

type RingkasanDesaRepository struct {
	db *gorm.DB
}

func NewRingkasanDesaRepository(db *gorm.DB) *RingkasanDesaRepository {
	return &RingkasanDesaRepository{db: db}
}

// CountIbuHamilByTrimester menghitung jumlah ibu hamil aktif per trimester (kehamilan.status_kehamilan
// berisi 'TRIMESTER 1' / 'TRIMESTER 2' / 'TRIMESTER 3'), disaring berdasarkan desa_id penduduk
// (kehamilan -> ibu -> penduduk). desaID nil berarti tanpa filter desa (untuk akses penuh seperti dokter).
func (r *RingkasanDesaRepository) CountIbuHamilByTrimester(posyanduID *int32) (t1, t2, t3 int64, err error) {
	type row struct {
		Status string
		Jumlah int64
	}
	var rows []row

	q := r.db.Table("kehamilan k").
		Select("UPPER(TRIM(k.status_kehamilan)) AS status, COUNT(*) AS jumlah").
		Joins("JOIN ibu i ON i.id = k.ibu_id AND i.is_deleted IS NULL").
		Joins("JOIN penduduk p ON p.id = i.penduduk_id AND p.deleted_at IS NULL").
		Where("k.deleted_at IS NULL").
		Group("UPPER(TRIM(k.status_kehamilan))")

	if posyanduID != nil {
		q = q.Where("p.posyandu_id = ?", *posyanduID)
	}

	if err = q.Scan(&rows).Error; err != nil {
		return 0, 0, 0, err
	}

	for _, rw := range rows {
		switch rw.Status {
		case "TRIMESTER 1":
			t1 = rw.Jumlah
		case "TRIMESTER 2":
			t2 = rw.Jumlah
		case "TRIMESTER 3":
			t3 = rw.Jumlah
		}
	}

	return t1, t2, t3, nil
}

// CountAnak menghitung jumlah anak yang penduduknya berada di sebuah desa.
func (r *RingkasanDesaRepository) CountAnak(posyanduID *int32) (int64, error) {
	var count int64

	q := r.db.Table("anak a").
		Joins("JOIN penduduk p ON p.id = a.penduduk_id AND p.deleted_at IS NULL").
		Where("a.deleted_at IS NULL")

	if posyanduID != nil {
		q = q.Where("p.posyandu_id = ?", *posyanduID)
	}

	err := q.Count(&count).Error
	return count, err
}

// CountPerluTindakLanjut menghitung jumlah kunjungan imunisasi dengan id_status_kunjungan = 2
// (terlewat / perlu tindak lanjut) untuk anak-anak di posyandu kader.
func (r *RingkasanDesaRepository) CountPerluTindakLanjut(posyanduID *int32) (int64, error) {
	var count int64

	q := r.db.Table("kunjungan_imunisasi ki").
		Joins("JOIN jadwal_imunisasi_anak jia ON jia.id = ki.id_jadwal_imunisasi").
		Joins("JOIN anak a ON a.id = jia.id_anak AND a.deleted_at IS NULL").
		Joins("JOIN penduduk p ON p.id = a.penduduk_id AND p.deleted_at IS NULL").
		Where("ki.id_status_kunjungan = ?", 2)

	if posyanduID != nil {
		q = q.Where("p.posyandu_id = ?", *posyanduID)
	}

	err := q.Count(&count).Error
	return count, err
}

// GetDesaName mengambil nama desa berdasarkan id.
func (r *RingkasanDesaRepository) GetDesaName(desaID int32) (string, error) {
	var nama string
	err := r.db.Table("desa").
		Select("nama_desa").
		Where("id = ? AND deleted_at IS NULL", desaID).
		Scan(&nama).Error
	return nama, err
}

func (r *RingkasanDesaRepository) baseKelasIbuBalita(posyanduID *int32) *gorm.DB {
	q := r.db.Table("absensi_kelas_ibu_balita akb").
		Joins("JOIN ibu i ON i.id = akb.ibu_id AND i.is_deleted IS NULL").
		Joins("JOIN penduduk p ON p.id = i.penduduk_id AND p.deleted_at IS NULL")

	if posyanduID != nil {
		q = q.Where("p.posyandu_id = ?", *posyanduID)
	}
	return q
}

// CountVerifikasiKelasIbuBalita menghitung total absensi kelas ibu balita dan berapa yang
// sudah diproses kader di sebuah desa. Kader memproses absensi balita menjadi "Diterima"
// atau "Ditolak" (lihat VerifikasiAbsensiKelasIbuBalitaScreen di mobile); "Terverifikasi"
// disertakan juga untuk berjaga-jaga karena merupakan nilai default lama di backend.
func (r *RingkasanDesaRepository) CountVerifikasiKelasIbuBalita(posyanduID *int32) (total, sudah int64, err error) {
	if err = r.baseKelasIbuBalita(posyanduID).Count(&total).Error; err != nil {
		return 0, 0, err
	}
	if err = r.baseKelasIbuBalita(posyanduID).
		Where("akb.status IN (?)", []string{"Diterima", "Ditolak", "Terverifikasi"}).
		Count(&sudah).Error; err != nil {
		return 0, 0, err
	}
	return total, sudah, nil
}

func (r *RingkasanDesaRepository) baseKelasIbuHamil(posyanduID *int32) *gorm.DB {
	q := r.db.Table("absensi_kelas_ibu_hamil akh").
		Joins("JOIN kehamilan k ON k.id = akh.kehamilan_id AND k.deleted_at IS NULL").
		Joins("JOIN ibu i ON i.id = k.ibu_id AND i.is_deleted IS NULL").
		Joins("JOIN penduduk p ON p.id = i.penduduk_id AND p.deleted_at IS NULL")

	if posyanduID != nil {
		q = q.Where("p.posyandu_id = ?", *posyanduID)
	}
	return q
}

// CountVerifikasiKelasIbuHamil menghitung total absensi kelas ibu hamil dan berapa yang
// sudah diverifikasi kader (status = 'Terverifikasi') di sebuah desa.
func (r *RingkasanDesaRepository) CountVerifikasiKelasIbuHamil(posyanduID *int32) (total, sudah int64, err error) {
	if err = r.baseKelasIbuHamil(posyanduID).Count(&total).Error; err != nil {
		return 0, 0, err
	}
	if err = r.baseKelasIbuHamil(posyanduID).Where("akh.status = ?", "Terverifikasi").Count(&sudah).Error; err != nil {
		return 0, 0, err
	}
	return total, sudah, nil
}

func (r *RingkasanDesaRepository) basePemantauanIbuHamil(posyanduID *int32) *gorm.DB {
	q := r.db.Table("pemantauan_ibu_hamil pih").
		Joins("JOIN kehamilan k ON k.id = pih.kehamilan_id AND k.deleted_at IS NULL").
		Joins("JOIN ibu i ON i.id = k.ibu_id AND i.is_deleted IS NULL").
		Joins("JOIN penduduk p ON p.id = i.penduduk_id AND p.deleted_at IS NULL").
		Where("pih.deleted_at IS NULL")

	if posyanduID != nil {
		q = q.Where("p.posyandu_id = ?", *posyanduID)
	}
	return q
}

// CountVerifikasiPemantauanIbuHamil menghitung total laporan pemantauan ibu hamil dan berapa yang
// sudah diverifikasi kader (tanggal_verifikasi terisi) di sebuah desa.
func (r *RingkasanDesaRepository) CountVerifikasiPemantauanIbuHamil(posyanduID *int32) (total, sudah int64, err error) {
	if err = r.basePemantauanIbuHamil(posyanduID).Count(&total).Error; err != nil {
		return 0, 0, err
	}
	if err = r.basePemantauanIbuHamil(posyanduID).Where("pih.tanggal_verifikasi IS NOT NULL").Count(&sudah).Error; err != nil {
		return 0, 0, err
	}
	return total, sudah, nil
}

func (r *RingkasanDesaRepository) basePemantauanIbuNifas(posyanduID *int32) *gorm.DB {
	q := r.db.Table("checklist_pemantauan_ibu_nifas cpn").
		Joins("JOIN kehamilan k ON k.id = cpn.kehamilan_id AND k.deleted_at IS NULL").
		Joins("JOIN ibu i ON i.id = k.ibu_id AND i.is_deleted IS NULL").
		Joins("JOIN penduduk p ON p.id = i.penduduk_id AND p.deleted_at IS NULL").
		Where("cpn.deleted_at IS NULL")

	if posyanduID != nil {
		q = q.Where("p.posyandu_id = ?", *posyanduID)
	}
	return q
}

// CountVerifikasiPemantauanIbuNifas menghitung total checklist pemantauan ibu nifas dan berapa yang
// sudah diverifikasi kader (tanggal_verifikasi terisi) di sebuah desa.
func (r *RingkasanDesaRepository) CountVerifikasiPemantauanIbuNifas(posyanduID *int32) (total, sudah int64, err error) {
	if err = r.basePemantauanIbuNifas(posyanduID).Count(&total).Error; err != nil {
		return 0, 0, err
	}
	if err = r.basePemantauanIbuNifas(posyanduID).Where("cpn.tanggal_verifikasi IS NOT NULL").Count(&sudah).Error; err != nil {
		return 0, 0, err
	}
	return total, sudah, nil
}
