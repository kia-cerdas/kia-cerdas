package usecases

import (
	"fmt"
	"monitoring-service/app/models"
)

func (m *Main) GetAllRequestPerubahanJadwal() (
	[]models.RequestPerubahanJadwalResponse,
	error,
) {

	rows, err :=
		m.repository.
			GetAllRequestPerubahanJadwal()

	if err != nil {
		return nil, err
	}

	response :=
		[]models.RequestPerubahanJadwalResponse{}

	for _, row := range rows {

		response =
			append(
				response,
				models.RequestPerubahanJadwalResponse{
					RequestID:      row.RequestID,
					StatusRequest:  row.StatusRequest,
					TanggalSebelum: row.TanggalSebelum,
					TanggalBaru:    row.TanggalBaru,
					NamaDosis:      row.NamaDosis,
					NamaLengkap:    row.NamaLengkap,
					Alasan:         row.Alasan,
				},
			)
	}

	return response, nil
}

func (m *Main) RequestPerubahanJadwal(
	userID int32,
	jadwalID uint,
	tanggalBaru string,
	alasan string,
) error {

	jadwal, err :=
		m.repository.GetJadwalByID(jadwalID)

	if err != nil {
		return err
	}

	request := models.RequestPerubahanImunisasi{
		IDJadwalImunisasi: int32(jadwalID),
		IDStatusRequest:   2, // pending
		TanggalSebelum: jadwal.TanggalEstimasi.
			Format("2006-01-02"),
		TanggalBaru: tanggalBaru,
		Alasan:      alasan,
	}

	return m.repository.
		CreateRequestPerubahanJadwal(
			&request,
		)
}

func (m *Main) ApproveRequestPerubahanJadwal(
	requestID int32,
) error {

	requestData, err :=
		m.repository.GetRequestPerubahanByID(
			requestID,
		)

	if err != nil {
		return err
	}

	if requestData == nil {
		return fmt.Errorf("request tidak ditemukan")
	}

	if requestData.StatusRequestID != 2 {
		return fmt.Errorf("request sudah diproses")
	}

	err =
		m.repository.UpdateStatusRequestPerubahan(
			requestID,
			1,
		)

	if err != nil {
		return err
	}

	return m.repository.UpdateTanggalJadwalImunisasi(
		requestData.JadwalImunisasiID,
		requestData.TanggalBaru,
	)
}

func (m *Main) RejectRequestPerubahanJadwal(
	requestID int32,
) error {

	requestData, err :=
		m.repository.GetRequestPerubahanByID(
			requestID,
		)

	if err != nil {
		return err
	}

	if requestData == nil {
		return fmt.Errorf("request tidak ditemukan")
	}

	if requestData.StatusRequestID != 2 {
		return fmt.Errorf("request sudah diproses")
	}

	return m.repository.
		UpdateStatusRequestPerubahan(
			requestID,
			3,
		)
}
