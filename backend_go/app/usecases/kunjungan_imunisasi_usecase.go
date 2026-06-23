package usecases

import (
	"fmt"
	"log"
	"monitoring-service/app/models"
)

func (m *Main) GetKunjunganImunisasiByID(
	kunjunganID uint,
) (*models.KunjunganImunisasiDetailResponse, error) {

	row, err :=
		m.repository.
			GetKunjunganImunisasiByID(
				kunjunganID,
			)

	if err != nil {
		return nil, err
	}

	if row == nil || row.KunjunganID == 0 {
		return nil, nil
	}

	result :=
		&models.KunjunganImunisasiDetailResponse{
			KunjunganID:      row.KunjunganID,
			TanggalKunjungan: row.TanggalKunjungan,
			StatusKunjungan:  row.StatusKunjungan,

			NamaAnak:     row.NamaAnak,
			TanggalLahir: row.TanggalLahir,

			NamaIbu:          row.NamaIbu,
			NomorTeleponIbu:  row.NomorTeleponIbu,
			NamaAyah:         row.NamaAyah,
			NomorTeleponAyah: row.NomorTeleponAyah,
			Dusun:            row.Dusun,

			NamaVaksin:      row.NamaVaksin,
			NamaDosis:       row.NamaDosis,
			JadwalImunisasi: row.JadwalImunisasi,
		}

	return result, nil
}

func (m *Main) GetAllKunjunganImunisasi(kaderID uint) ([]models.KunjunganImunisasiResponse, error) {

	rows, err :=
		m.repository.
			GetAllKunjunganImunisasi(kaderID)

	if err != nil {
		return nil, err
	}

	response :=
		[]models.KunjunganImunisasiResponse{}

	for _, row := range rows {

		response =
			append(
				response,
				models.KunjunganImunisasiResponse{
					KunjunganID:      row.KunjunganID,
					TanggalKunjungan: row.TanggalKunjungan,
					StatusKunjungan:  row.StatusKunjungan,
					NamaAnak:         row.NamaAnak,
				},
			)
	}

	return response, nil
}

func (m *Main) UpdateStatusKunjungan(
	kunjunganID uint,
	statusID uint,
) error {

	// cek data exist
	data, err :=
		m.repository.
			GetKunjunganImunisasiByID(
				kunjunganID,
			)

	if err != nil {
		return err
	}

	// kalau tidak ditemukan
	if data == nil ||
		data.KunjunganID == 0 {

		return fmt.Errorf(
			"kunjungan tidak ditemukan",
		)
	}

	// update status
	return m.repository.
		UpdateStatusKunjungan(
			kunjunganID,
			statusID,
		)
}

func (m *Main) UpdateTanggalKunjungan(
	kunjunganID uint,
	tanggalKunjungan string,
) error {

	// cek data exist
	data, err :=
		m.repository.
			GetKunjunganImunisasiByID(
				kunjunganID,
			)

	if err != nil {
		return err
	}

	// kalau tidak ditemukan
	if data == nil ||
		data.KunjunganID == 0 {

		return fmt.Errorf(
			"kunjungan tidak ditemukan",
		)
	}

	// update tanggal kunjungan
	return m.repository.
		UpdateTanggalKunjungan(
			kunjunganID,
			tanggalKunjungan,
		)
}

func (m *Main) GetKunjunganImunisasiByStatus(
	statusID uint,
	kaderID uint,
) (
	[]models.KunjunganImunisasiResponse,
	error,
) {

	rows, err :=
		m.repository.
			GetKunjunganImunisasiByStatus(
				statusID,
				kaderID,
			)

	if err != nil {
		return nil, err
	}

	response :=
		[]models.KunjunganImunisasiResponse{}

	for _, row := range rows {

		response =
			append(
				response,
				models.KunjunganImunisasiResponse{
					KunjunganID:      row.KunjunganID,
					TanggalKunjungan: row.TanggalKunjungan,
					StatusKunjungan:  row.StatusKunjungan,
					NamaAnak:         row.NamaAnak,
				},
			)
	}

	return response, nil
}

func (m *Main) CreateKunjunganImunisasi(
	req *models.PostKunjunganImunisasiRequest,
) (uint, error) {

	if req.KaderID == 0 {
		return 0, fmt.Errorf("kader_id tidak ditemukan, pastikan akun terdaftar sebagai kader")
	}

	kunjunganID, err := m.repository.CreateKunjunganImunisasi(
		req.IDStatusKunjungan,
		req.TanggalKunjungan,
		req.IDJadwalImunisasi,
		req.KaderID,
	)

	if err != nil {
		return 0, fmt.Errorf("gagal membuat kunjungan imunisasi: %v", err)
	}

	return kunjunganID, nil
}

func (m *Main) GetKaderIDByUserID(userID int32) (uint, error) {
	return m.repository.GetKaderIDByUserID(userID)
}

func (m *Main) ProcessOverdueKunjunganImunisasi() error {
	updated, err := m.repository.MarkOverdueKunjunganImunisasi()
	if err != nil {
		return err
	}

	log.Printf("[CRON] overdue kunjungan imunisasi updated=%d", updated)
	return nil
}
