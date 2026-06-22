package repositories

import (
	"time"
)

type KunjunganReminderRow struct {
	KunjunganID      uint
	TanggalKunjungan *time.Time
	NamaAnak         string
	NamaDosis        string
	KaderID          uint
}

// GetKunjunganForReminder mengambil kunjungan yang tanggalnya = targetDate
// beserta kader_id yang bertanggung jawab untuk keperluan notifikasi.
func (m *Main) GetKunjunganForReminder(targetDate time.Time) ([]KunjunganReminderRow, error) {

	var result []KunjunganReminderRow

	dateStr := targetDate.Format("2006-01-02")

	err := m.postgres.
		Table("kunjungan_imunisasi ki").
		Select(`
			ki.id              AS kunjungan_id,
			ki.tanggal_kunjungan,
			p_anak.nama_anggota_keluarga AS nama_anak,
			dv.nama_dosis,
			ki.kader_id
		`).
		Joins("INNER JOIN jadwal_imunisasi_anak jia ON jia.id = ki.id_jadwal_imunisasi").
		Joins("INNER JOIN anak a ON a.id = jia.id_anak").
		Joins("INNER JOIN penduduk p_anak ON p_anak.id = a.penduduk_id").
		Joins("LEFT JOIN dosis_vaksin dv ON dv.id = jia.id_dosis_vaksin").
		Where("DATE(ki.tanggal_kunjungan) = ?", dateStr).
		Where("ki.id_status_kunjungan = 1").
		Scan(&result).Error

	return result, err
}

// GetFCMTokensByKaderID mengambil FCM token milik kader tertentu.
func (m *Main) GetFCMTokensByKaderID(kaderID uint) ([]string, error) {

	var tokens []string

	err := m.postgres.
		Table("kader k").
		Select("d.fcm_token").
		Joins("INNER JOIN penduduk pd ON pd.id = k.penduduk_id").
		Joins("INNER JOIN pengguna u ON u.penduduk_id = pd.id").
		Joins("INNER JOIN perangkat d ON d.id_pengguna = u.id").
		Where("k.id = ?", kaderID).
		Where("k.deleted_at IS NULL").
		Where("d.fcm_token IS NOT NULL AND d.fcm_token != ''").
		Where("d.deleted_at IS NULL").
		Scan(&tokens).Error

	return tokens, err
}

// GetFCMTokensByPosyanduKader mengambil FCM token semua kader aktif di posyandu tertentu.
func (m *Main) GetFCMTokensByPosyanduKader(posyanduID int32) ([]string, error) {

	var tokens []string

	err := m.postgres.
		Table("kader k").
		Select("d.fcm_token").
		Joins("INNER JOIN penduduk pd ON pd.id = k.penduduk_id").
		Joins("INNER JOIN pengguna u ON u.penduduk_id = pd.id").
		Joins("INNER JOIN perangkat d ON d.id_pengguna = u.id").
		Where("k.posyandu_id = ?", posyanduID).
		Where("k.deleted_at IS NULL").
		Where("k.status = 'aktif'").
		Where("d.fcm_token IS NOT NULL AND d.fcm_token != ''").
		Where("d.deleted_at IS NULL").
		Scan(&tokens).Error

	return tokens, err
}

type KunjunganImunisasiDetailJoin struct {
	KunjunganID      uint
	TanggalKunjungan *time.Time
	StatusKunjungan  string

	NamaAnak     string
	TanggalLahir *time.Time

	NamaIbu          string
	NomorTeleponIbu  string
	NamaAyah         string
	NomorTeleponAyah string
	Dusun            string

	NamaVaksin      string
	NamaDosis       string
	JadwalImunisasi *time.Time
}

type KunjunganImunisasiJoin struct {
	KunjunganID      uint
	TanggalKunjungan *time.Time
	StatusKunjungan  string
	NamaAnak         string
}

func (m *Main) GetKunjunganImunisasiByID(
	kunjunganID uint,
) (*KunjunganImunisasiDetailJoin, error) {

	var result KunjunganImunisasiDetailJoin

	err := m.postgres.
		Table("kunjungan_imunisasi ki").
		Select(`
		ki.id AS kunjungan_id,
		ki.tanggal_kunjungan,
		sk.status_kunjungan,

		p_anak.nama_lengkap AS nama_anak,
		p_anak.tanggal_lahir,
		p_anak.dusun AS dusun,

		p_ibu.nama_lengkap AS nama_ibu,
		p_ibu.telepon AS nomor_telepon_ibu,

		p_ayah.nama_lengkap AS nama_ayah,
		p_ayah.telepon AS nomor_telepon_ayah,

		v.nama AS nama_vaksin,
		dv.nama_dosis,
		jia.tanggal_estimasi AS jadwal_imunisasi
	`).
		Joins(`
		INNER JOIN status_kunjungan sk
		ON sk.id = ki.id_status_kunjungan
	`).
		Joins(`
		INNER JOIN jadwal_imunisasi_anak jia
		ON jia.id = ki.id_jadwal_imunisasi
	`).
		Joins(`
		INNER JOIN anak a
		ON a.id = jia.id_anak
	`).
		Joins(`
		INNER JOIN penduduk p_anak
		ON p_anak.id = a.penduduk_id
	`).
		Joins(`
		INNER JOIN kehamilan kh
		ON kh.id = a.kehamilan_id
	`).
		Joins(`
		INNER JOIN ibu i
		ON i.id = kh.ibu_id
	`).
		Joins(`
		INNER JOIN penduduk p_ibu
		ON p_ibu.id = i.penduduk_id
	`).
		Joins(`
		LEFT JOIN penduduk p_ayah
		ON p_ayah.id = i.suami_id
	`).
		Joins(`
		LEFT JOIN dosis_vaksin dv
		ON dv.id = jia.id_dosis_vaksin
	`).
		Joins(`
		LEFT JOIN vaksin v
		ON v.id = dv.id_vaksin
	`).
		Where("ki.id = ?", kunjunganID).
		Scan(&result).Error

	if err != nil {
		return nil, err
	}

	return &result, nil
}

func (m *Main) GetAllKunjunganImunisasi() ([]KunjunganImunisasiJoin, error) {

	var result []KunjunganImunisasiJoin

	err := m.postgres.
		Table("kunjungan_imunisasi ki").
		Select(`
			ki.id AS kunjungan_id,
			ki.tanggal_kunjungan,
			sk.status_kunjungan,

			p_anak.nama_lengkap AS nama_anak
		`).
		Joins(`
			INNER JOIN status_kunjungan sk
			ON sk.id = ki.id_status_kunjungan
		`).
		Joins(`
			INNER JOIN jadwal_imunisasi_anak jia
			ON jia.id = ki.id_jadwal_imunisasi
		`).
		Joins(`
			INNER JOIN anak a
			ON a.id = jia.id_anak
		`).
		Joins(`
			INNER JOIN penduduk p_anak
			ON p_anak.id = a.penduduk_id
		`).
		Order("ki.tanggal_kunjungan DESC").
		Scan(&result).Error

	if err != nil {
		return nil, err
	}

	return result, nil
}

func (m *Main) UpdateStatusKunjungan(
	kunjunganID uint,
	statusID uint,
) error {

	return m.postgres.
		Table("kunjungan_imunisasi").
		Where("id = ?", kunjunganID).
		Update(
			"id_status_kunjungan",
			statusID,
		).Error
}

func (m *Main) UpdateTanggalKunjungan(
	kunjunganID uint,
	tanggalKunjungan string,
) error {

	return m.postgres.
		Table("kunjungan_imunisasi").
		Where("id = ?", kunjunganID).
		Update(
			"tanggal_kunjungan",
			tanggalKunjungan,
		).Error
}

func (m *Main) MarkOverdueKunjunganImunisasi() (int64, error) {
	result := m.postgres.
		Table("kunjungan_imunisasi").
		Where("tanggal_kunjungan IS NOT NULL").
		Where("DATE(tanggal_kunjungan) < CURRENT_DATE").
		Where("id_status_kunjungan = ?", 1).
		Update("id_status_kunjungan", 2)

	return result.RowsAffected, result.Error
}

func (m *Main) GetKunjunganImunisasiByStatus(
	statusID uint,
) (
	[]KunjunganImunisasiJoin,
	error,
) {

	var result []KunjunganImunisasiJoin

	err := m.postgres.
		Table("kunjungan_imunisasi ki").
		Select(`
			ki.id AS kunjungan_id,
			ki.tanggal_kunjungan,
			sk.status_kunjungan,

			p_anak.nama_lengkap AS nama_anak
		`).
		Joins(`
			INNER JOIN status_kunjungan sk
			ON sk.id = ki.id_status_kunjungan
		`).
		Joins(`
			INNER JOIN jadwal_imunisasi_anak jia
			ON jia.id = ki.id_jadwal_imunisasi
		`).
		Joins(`
			INNER JOIN anak a
			ON a.id = jia.id_anak
		`).
		Joins(`
			INNER JOIN penduduk p_anak
			ON p_anak.id = a.penduduk_id
		`).
		Where(
			"ki.id_status_kunjungan = ?",
			statusID,
		).
		Order("ki.tanggal_kunjungan DESC").
		Scan(&result).Error

	if err != nil {
		return nil, err
	}

	return result, nil
}

func (m *Main) GetKaderIDByUserID(userID int32) (uint, error) {

	var kaderID uint

	err := m.postgres.
		Table("kader k").
		Select("k.id").
		Joins("INNER JOIN penduduk pd ON pd.id = k.penduduk_id").
		Joins("INNER JOIN pengguna u ON u.penduduk_id = pd.id").
		Where("u.id = ?", userID).
		Where("k.deleted_at IS NULL").
		Scan(&kaderID).Error

	return kaderID, err
}

func (m *Main) CreateKunjunganImunisasi(
	statusID uint,
	tanggalKunjungan string,
	jadwalImunisasiID uint,
	kaderID uint,
) (uint, error) {

	var kunjunganImunisasi struct {
		ID uint
	}

	err := m.postgres.
		Table("kunjungan_imunisasi").
		Create(map[string]interface{}{
			"id_status_kunjungan": statusID,
			"tanggal_kunjungan":   tanggalKunjungan,
			"id_jadwal_imunisasi": jadwalImunisasiID,
			"kader_id":            kaderID,
		}).
		Scan(&kunjunganImunisasi).Error

	if err != nil {
		return 0, err
	}

	return kunjunganImunisasi.ID, nil
}
