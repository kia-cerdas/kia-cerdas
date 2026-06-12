package usecases

import (
	"fmt"
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

func (m *Main) GetAllKunjunganImunisasi() ([]models.KunjunganImunisasiResponse, error) {

	rows, err :=
		m.repository.
			GetAllKunjunganImunisasi()

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
) (
	[]models.KunjunganImunisasiResponse,
	error,
) {

	rows, err :=
		m.repository.
			GetKunjunganImunisasiByStatus(
				statusID,
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
