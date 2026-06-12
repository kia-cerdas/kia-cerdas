package repositories

import (
	// "time"
	"monitoring-service/app/models"
	// "gorm.io/gorm"
)

type RequestPerubahanJadwalJoin struct {
	RequestID      int32
	StatusRequest  string
	TanggalSebelum string
	TanggalBaru    string
	NamaDosis      string
	NamaLengkap    string
	Alasan         string
	JadwalID       uint
}

type RequestPerubahanJadwalDetail struct {
	RequestID         int32
	JadwalImunisasiID int32
	TanggalBaru       string
	StatusRequestID   int32
}

func (m *Main) GetJadwalByID(
	jadwalID uint,
) (*models.JadwalImunisasiAnak, error) {

	var result models.JadwalImunisasiAnak

	err := m.postgres.
		Table("jadwal_imunisasi_anak").
		Where("id = ?", jadwalID).
		First(&result).
		Error

	if err != nil {
		return nil, err
	}

	return &result, nil
}

func (m *Main) GetAllRequestPerubahanJadwal() (
	[]RequestPerubahanJadwalJoin,
	error,
) {

	var result []RequestPerubahanJadwalJoin

	err := m.postgres.
		Table("request_perubahan_imunisasi").
		Select(`
			request_perubahan_imunisasi.id as request_id,
			status_request.status_request,
			request_perubahan_imunisasi.tanggal_sebelum,
			request_perubahan_imunisasi.tanggal_baru,
			dosis_vaksin.nama_dosis,
			penduduk.nama_lengkap,
			request_perubahan_imunisasi.alasan
		`).
		Joins(`
			INNER JOIN jadwal_imunisasi_anak
			ON request_perubahan_imunisasi.id_jadwal_imunisasi = jadwal_imunisasi_anak.id
		`).
		Joins(`
			INNER JOIN status_request
			ON request_perubahan_imunisasi.id_status_request = status_request.id
		`).
		Joins(`
			INNER JOIN dosis_vaksin
			ON jadwal_imunisasi_anak.id_dosis_vaksin = dosis_vaksin.id
		`).
		Joins(`
			INNER JOIN anak
			ON jadwal_imunisasi_anak.id_anak = anak.id
		`).
		Joins(`
			INNER JOIN penduduk
			ON anak.penduduk_id = penduduk.id
		`).
		Order("request_perubahan_imunisasi.created_at DESC").
		Scan(&result).
		Error

	if err != nil {
		return nil, err
	}

	return result, nil
}

func (m *Main) CreateRequestPerubahanJadwal(
	request *models.RequestPerubahanImunisasi,
) error {

	return m.postgres.
		Create(request).
		Error
}

// func (m *Main) ApproveRequestPerubahanJadwal(
// 	requestID int32,
// ) error {

// 	var request models.RequestPerubahanImunisasi

// 	if err :=
// 		m.postgres.
// 			First(
// 				&request,
// 				requestID,
// 			).Error; err != nil {

// 		return err
// 	}

// 	return m.postgres.Transaction(
// 		func(tx *gorm.DB) error {

// 			if err := tx.
// 				Table("request_perubahan_imunisasi").
// 				Where(
// 					"id = ?",
// 					requestID,
// 				).
// 				Update(
// 					"id_status_request",
// 					1,
// 				).Error; err != nil {

// 				return err
// 			}

// 			if err := tx.
// 				Table(
// 					"jadwal_imunisasi_anak",
// 				).
// 				Where(
// 					"id = ?",
// 					request.IDJadwalImunisasi,
// 				).
// 				Update(
// 					"tanggal_estimasi",
// 					request.TanggalBaru,
// 				).Error; err != nil {

// 				return err
// 			}

// 			return nil
// 		},
// 	)
// }

func (m *Main) UpdateStatusRequestPerubahan(
	requestID int32,
	statusID int32,
) error {

	return m.postgres.
		Table("request_perubahan_imunisasi").
		Where("id = ?", requestID).
		Update("id_status_request", statusID).
		Error
}

func (m *Main) GetRequestPerubahanByID(
	requestID int32,
) (*RequestPerubahanJadwalDetail, error) {

	var result RequestPerubahanJadwalDetail

	err := m.postgres.
		Table("request_perubahan_imunisasi").
		Select(`
			id as request_id,
			id_jadwal_imunisasi as jadwal_imunisasi_id,
			tanggal_baru,
			id_status_request as status_request_id
		`).
		Where("id = ?", requestID).
		Scan(&result).
		Error

	if err != nil {
		return nil, err
	}

	return &result, nil
}

func (m *Main) UpdateTanggalJadwalImunisasi(
	jadwalID int32,
	tanggalBaru string,
) error {

	return m.postgres.
		Table("jadwal_imunisasi_anak").
		Where("id = ?", jadwalID).
		Updates(map[string]interface{}{
			"tanggal_estimasi": tanggalBaru,
			"id_status_jadwal": 1,
		}).Error
}
