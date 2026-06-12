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
		pd_anak.nama_lengkap as nama_anak,
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
			pd_anak.nama_lengkap as nama_anak,
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
		Where("a.id = ?", int(anakID)). // 🔥 filter anak spesifik
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
			pd_anak.nama_lengkap as nama_anak,
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
			pd_anak.nama_lengkap as nama_anak,
			pd_anak.tanggal_lahir,

			j.id as jadwal_id,
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
			pd_anak.nama_lengkap as nama_anak,
			pd_anak.tanggal_lahir,

			j.id as jadwal_id,
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
