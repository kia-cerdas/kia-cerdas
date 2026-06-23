package repositories

import (
	"monitoring-service/app/models"
	"time"
)

type JadwalImunisasiJoin struct {
	AnakID          int32
	NamaAnak        string
	TanggalLahir    *time.Time
	JadwalID        uint
	DosisVaksinID   uint `gorm:"column:dosis_vaksin_id"`
	NamaDosis       string
	TanggalEstimasi *time.Time
	Deskripsi       string
	EfekSamping     string
	StatusID        uint
	Status          string
}

func (m *Main) GetJadwalImunisasiByUserID(
	userID int32,
) ([]JadwalImunisasiJoin, error) {

	var result []JadwalImunisasiJoin

	err := m.postgres.
		Table("pengguna p").
		Select(`
		a.id as anak_id,
		pd_anak.nama_anggota_keluarga as nama_anak,
		pd_anak.tanggal_lahir,

		j.id as jadwal_id,
		j.id_dosis_vaksin as dosis_vaksin_id,
		dv.nama_dosis,
		j.tanggal_estimasi,

		sj.id as status_id,
		sj.nama_status as status,

		v.deskripsi,
		v.efek_samping
	`).
		Joins(`
		JOIN penduduk pd_ibu
		ON pd_ibu.id = p.penduduk_id
	`).
		Joins(`
		JOIN ibu i
		ON i.penduduk_id = pd_ibu.id
	`).
		Joins(`
		JOIN kehamilan k
		ON k.ibu_id = i.id
	`).
		Joins(`
		JOIN anak a
		ON a.kehamilan_id = k.id
	`).
		Joins(`
		JOIN penduduk pd_anak
		ON pd_anak.id = a.penduduk_id
	`).
		Joins(`
		LEFT JOIN jadwal_imunisasi_anak j
		ON j.id_anak = a.id
	`).
		Joins(`
		LEFT JOIN dosis_vaksin dv
		ON dv.id = j.id_dosis_vaksin
	`).
		Joins(`
		LEFT JOIN status_jadwal sj
		ON sj.id = j.id_status_jadwal
	`).
		Joins(`
		INNER JOIN vaksin v
		ON dv.id_vaksin = v.id
	`).
		Where("p.id = ?", userID).
		Order("a.id ASC, j.tanggal_estimasi ASC").
		Scan(&result).Error

	if err != nil {
		return nil, err
	}

	return result, nil
}

func (m *Main) GetJadwalImunisasiByAnakID(
	userID int32,
	anakID int32,
) ([]JadwalImunisasiJoin, error) {

	var result []JadwalImunisasiJoin

	err := m.postgres.
		Table("pengguna p").
		Select(`
			a.id as anak_id,
			pd_anak.nama_anggota_keluarga as nama_anak,
			pd_anak.tanggal_lahir,

			j.id as jadwal_id,
			dv.nama_dosis,
			j.tanggal_estimasi,

			sj.id as status_id,
			sj.nama_status as status,

			v.deskripsi,
			v.efek_samping
		`).
		Joins(`
			JOIN penduduk pd_ibu
			ON pd_ibu.id = p.penduduk_id
		`).
		Joins(`
			JOIN ibu i
			ON i.penduduk_id = pd_ibu.id
		`).
		Joins(`
			JOIN kehamilan k
			ON k.ibu_id = i.id
		`).
		Joins(`
			JOIN anak a
			ON a.kehamilan_id = k.id
		`).
		Joins(`
			JOIN penduduk pd_anak
			ON pd_anak.id = a.penduduk_id
		`).
		Joins(`
			LEFT JOIN jadwal_imunisasi_anak j
			ON j.id_anak = a.id
		`).
		Joins(`
			LEFT JOIN dosis_vaksin dv
			ON dv.id = j.id_dosis_vaksin
		`).
		Joins(`
			LEFT JOIN status_jadwal sj
			ON sj.id = j.id_status_jadwal
		`).
		Joins(`
			LEFT JOIN vaksin v
			ON v.id = dv.id_vaksin
		`).
		Where("p.id = ?", int(userID)).
		Where("a.id = ?", int(anakID)).
		Order("j.tanggal_estimasi ASC").
		Scan(&result).Error

	if err != nil {
		return nil, err
	}

	return result, nil
}

func (m *Main) UpdateTanggalEstimasi(
	jadwalID uint,
	newDate time.Time,
) error {

	return m.postgres.
		Table("jadwal_imunisasi_anak").
		Where("id = ?", jadwalID).
		Update("tanggal_estimasi", newDate).Error
}

func (m *Main) GetJadwalImunisasiByJadwalID(
	userID int32,
	jadwalID uint,
) (*models.JadwalImunisasiJoin, error) {

	var result models.JadwalImunisasiJoin

	err := m.postgres.
		Table("pengguna p").
		Select(`
			a.id as anak_id,
			pd_anak.nama_anggota_keluarga as nama_anak,
			pd_anak.tanggal_lahir,

			j.id as jadwal_id,
			dv.nama_dosis,
			j.tanggal_estimasi,

			sj.id as status_id,
			sj.nama_status as status,

			v.deskripsi,
			v.efek_samping
		`).
		Joins(`
			JOIN penduduk pd_ibu
			ON pd_ibu.id = p.penduduk_id
		`).
		Joins(`
			JOIN ibu i
			ON i.penduduk_id = pd_ibu.id
		`).
		Joins(`
			JOIN kehamilan k
			ON k.ibu_id = i.id
		`).
		Joins(`
			JOIN anak a
			ON a.kehamilan_id = k.id
		`).
		Joins(`
			JOIN penduduk pd_anak
			ON pd_anak.id = a.penduduk_id
		`).
		Joins(`
			LEFT JOIN jadwal_imunisasi_anak j
			ON j.id_anak = a.id
		`).
		Joins(`
			LEFT JOIN dosis_vaksin dv
			ON dv.id = j.id_dosis_vaksin
		`).
		Joins(`
			LEFT JOIN status_jadwal sj
			ON sj.id = j.id_status_jadwal
		`).
		Joins(`
			LEFT JOIN vaksin v
			ON v.id = dv.id_vaksin
		`).
		Where("p.id = ?", userID).
		Where("j.id = ?", jadwalID). // 🔥 ini kuncinya
		Scan(&result).Error

	if err != nil {
		return nil, err
	}

	return &result, nil
}

func (m *Main) UpdateStatusJadwalImunisasi(
	jadwalID uint,
	statusID uint,
) error {

	return m.postgres.
		Table("jadwal_imunisasi_anak").
		Where("id = ?", jadwalID).
		Updates(map[string]interface{}{
			"id_status_jadwal": statusID,
			"updated_at":       time.Now(),
		}).Error
}

// ==================== KHUSUS BIDAN (tanpa join ke user) ====================

func (m *Main) GetJadwalImunisasiByAnakIDBidan(anakID int32) ([]JadwalImunisasiJoin, error) {

	var result []JadwalImunisasiJoin

	err := m.postgres.
		Table("anak a").
		Select(`
			a.id as anak_id,
			pd_anak.nama_anggota_keluarga as nama_anak,
			pd_anak.tanggal_lahir,

			j.id as jadwal_id,
			j.id_dosis_vaksin as dosis_vaksin_id,
			dv.nama_dosis,
			j.tanggal_estimasi,

			sj.id as status_id,
			sj.nama_status as status,

			v.deskripsi,
			v.efek_samping
		`).
		Joins(`JOIN penduduk pd_anak ON pd_anak.id = a.penduduk_id`).
		Joins(`LEFT JOIN jadwal_imunisasi_anak j ON j.id_anak = a.id`).
		Joins(`LEFT JOIN dosis_vaksin dv ON dv.id = j.id_dosis_vaksin`).
		Joins(`LEFT JOIN status_jadwal sj ON sj.id = j.id_status_jadwal`).
		Joins(`LEFT JOIN vaksin v ON v.id = dv.id_vaksin`).
		Where("a.id = ?", int(anakID)).
		Order("j.tanggal_estimasi ASC").
		Scan(&result).Error

	if err != nil {
		return nil, err
	}

	return result, nil
}

func (m *Main) GetJadwalImunisasiByJadwalIDBidan(jadwalID uint) (*models.JadwalImunisasiJoin, error) {

	var result models.JadwalImunisasiJoin

	err := m.postgres.
		Table("anak a").
		Select(`
			a.id as anak_id,
			pd_anak.nama_anggota_keluarga as nama_anak,
			pd_anak.tanggal_lahir,

			j.id as jadwal_id,
			j.id_dosis_vaksin as dosis_vaksin_id,
			dv.nama_dosis,
			j.tanggal_estimasi,

			sj.id as status_id,
			sj.nama_status as status,

			v.deskripsi,
			v.efek_samping
		`).
		Joins(`JOIN penduduk pd_anak ON pd_anak.id = a.penduduk_id`).
		Joins(`LEFT JOIN jadwal_imunisasi_anak j ON j.id_anak = a.id`).
		Joins(`LEFT JOIN dosis_vaksin dv ON dv.id = j.id_dosis_vaksin`).
		Joins(`LEFT JOIN status_jadwal sj ON sj.id = j.id_status_jadwal`).
		Joins(`LEFT JOIN vaksin v ON v.id = dv.id_vaksin`).
		Where("j.id = ?", jadwalID).
		Scan(&result).Error

	if err != nil {
		return nil, err
	}

	return &result, nil
}

func (m *Main) GetJadwalImunisasiTerlewatByKaderID(
	userID int32,
) ([]models.JadwalImunisasiTerlewatJoin, error) {

	var result []models.JadwalImunisasiTerlewatJoin

	err := m.postgres.
		Table("jadwal_imunisasi_anak jia").
		Select(`
		jia.id AS jadwal_id,
		a.id AS anak_id,
		p_anak.nama_anggota_keluarga AS nama_anak,
		p_anak.tanggal_lahir,
		p_anak.dusun,

		p_ibu.nama_anggota_keluarga AS nama_ibu,
		p_ibu.telepon AS nomor_telepon_ibu,

		p_ayah.nama_anggota_keluarga AS nama_ayah,
		p_ayah.telepon AS nomor_telepon_ayah,

		dv.nama_dosis,
		jia.tanggal_estimasi AS jadwal_imunisasi,

		status_jadwal.nama_status
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
		INNER JOIN status_jadwal
		ON status_jadwal.id = jia.id_status_jadwal
	`).
		Joins(`
		INNER JOIN pengguna u
		ON u.id = ?
	`, userID).
		Joins(`
		INNER JOIN penduduk p_kader
		ON p_kader.id = u.penduduk_id
	`).
		Joins(`
		INNER JOIN kader k
		ON k.penduduk_id = p_kader.id
	`).
		Where("status_jadwal.id IN ?", []int{3, 4, 5}).
		Where("p_anak.posyandu_id = k.posyandu_id").
		Where("jia.tanggal_estimasi < CURRENT_DATE").
		Where(`
    NOT EXISTS (
        SELECT 1
        FROM kunjungan_imunisasi ki
        WHERE ki.id_jadwal_imunisasi = jia.id
        AND ki.id_status_kunjungan = 4
    )
`).
		Order("jia.tanggal_estimasi ASC").
		Scan(&result).Error

	if err != nil {
		return nil, err
	}

	return result, nil
}

func (m *Main) GetJadwalImunisasiTerlewatByID(
	userID int32,
	jadwalID uint,
) (*models.JadwalImunisasiTerlewatJoin, error) {

	var result models.JadwalImunisasiTerlewatJoin

	err := m.postgres.
		Table("jadwal_imunisasi_anak jia").
		Select(`
			jia.id AS jadwal_id,
			a.id AS anak_id,

			p_anak.nama_anggota_keluarga AS nama_anak,
			p_anak.tanggal_lahir,
			p_anak.dusun,

			p_ibu.nama_anggota_keluarga AS nama_ibu,
			p_ibu.telepon AS nomor_telepon_ibu,

			p_ayah.nama_anggota_keluarga AS nama_ayah,
			p_ayah.telepon AS nomor_telepon_ayah,

			dv.nama_dosis,

			jia.tanggal_estimasi AS jadwal_imunisasi,
			sj.nama_status
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
			INNER JOIN status_jadwal sj
			ON sj.id = jia.id_status_jadwal
		`).
		Joins(`
			INNER JOIN pengguna u
			ON u.id = ?
		`, userID).
		Joins(`
			INNER JOIN penduduk p_kader
			ON p_kader.id = u.penduduk_id
		`).
		Joins(`
			INNER JOIN kader k
			ON k.penduduk_id = p_kader.id
		`).
		Where("jia.id = ?", jadwalID).
		Where("p_anak.posyandu_id = k.posyandu_id").
		Scan(&result).Error

	if err != nil {
		return nil, err
	}

	return &result, nil
}
