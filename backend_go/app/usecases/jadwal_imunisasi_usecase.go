package usecases

import (
	"fmt"
	"monitoring-service/app/models"
	"monitoring-service/app/repositories"
	"sort"
	"time"
)

func (m *Main) GetImunisasiSyncData(userID int32) (*repositories.ImunisasiSyncData, error) {
	return m.repository.GetImunisasiSyncData(userID)
}

func (m *Main) GetJadwalImunisasi(
	userID int32,
) ([]models.JadwalImunisasiResponse, error) {

	// Update status jadwal langsung saat fetch, agar tidak bergantung cron job
	_ = m.UpdateStatusJadwal()

	rows, err :=
		m.repository.
			GetJadwalImunisasiByUserID(
				userID,
			)

	if err != nil {
		return nil, err
	}

	anakMap :=
		make(
			map[int32]*models.JadwalImunisasiResponse,
		)

	for _, row := range rows {

		if _, exists :=
			anakMap[row.AnakID]; !exists {

			anakMap[row.AnakID] =
				&models.JadwalImunisasiResponse{
					AnakID:         row.AnakID,
					NamaAnak:       row.NamaAnak,
					TanggalLahir:   row.TanggalLahir,
					JumlahTerlewat: 0,
					Jadwal:         []models.JadwalImunisasiItem{},
				}
		}

		if row.JadwalID != 0 {

			// Count imunisasi terlewat
			switch row.StatusID {

			// Terlewat
			case 3:
				anakMap[row.AnakID].
					JumlahTerlewat++

			// Terlambat & Krisis ikut dihitung
			case 4, 5:
				anakMap[row.AnakID].
					JumlahTerlewat++
			}

			anakMap[row.AnakID].
				Jadwal =
				append(
					anakMap[row.AnakID].Jadwal,
					models.JadwalImunisasiItem{
						JadwalID:        row.JadwalID,
						NamaDosis:       row.NamaDosis,
						TanggalEstimasi: row.TanggalEstimasi,
						Deskripsi:       row.Deskripsi,
						EfekSamping:     row.EfekSamping,
						StatusID:        row.StatusID,
						Status:          row.Status,
					},
				)
		}
	}

	response :=
		[]models.JadwalImunisasiResponse{}

	for _, anak := range anakMap {
		response =
			append(
				response,
				*anak,
			)
	}

	return response, nil
}

func (m *Main) GetJadwalImunisasiByAnakID(
	userID int32,
	anakID int32,
) ([]models.JadwalImunisasiResponse, error) {

	rows, err :=
		m.repository.GetJadwalImunisasiByAnakID(userID, anakID)

	if err != nil {
		return nil, err
	}

	anakMap :=
		make(map[int32]*models.JadwalImunisasiResponse)

	for _, row := range rows {

		if _, exists := anakMap[row.AnakID]; !exists {
			anakMap[row.AnakID] = &models.JadwalImunisasiResponse{
				AnakID:         row.AnakID,
				NamaAnak:       row.NamaAnak,
				TanggalLahir:   row.TanggalLahir,
				JumlahTerlewat: 0,
				Jadwal:         []models.JadwalImunisasiItem{},
			}
		}

		if row.JadwalID != 0 {

			switch row.StatusID {
			case 3, 4, 5:
				anakMap[row.AnakID].JumlahTerlewat++
			}

			anakMap[row.AnakID].Jadwal = append(
				anakMap[row.AnakID].Jadwal,
				models.JadwalImunisasiItem{
					JadwalID:        row.JadwalID,
					NamaDosis:       row.NamaDosis,
					TanggalEstimasi: row.TanggalEstimasi,
					Deskripsi:       row.Deskripsi,
					EfekSamping:     row.EfekSamping,
					StatusID:        row.StatusID,
					Status:          row.Status,
				},
			)
		}
	}

	response := []models.JadwalImunisasiResponse{}
	for _, anak := range anakMap {
		response = append(response, *anak)
	}

	return response, nil
}

func (m *Main) UpdateTanggalEstimasi(
	userID int32,
	jadwalID uint,
	newDate time.Time,
) error {

	// cek data exist (harus pakai userID juga)
	data, err := m.repository.GetJadwalImunisasiByJadwalID(userID, jadwalID)
	if err != nil {
		return err
	}

	// kalau tidak ditemukan
	if data == nil || data.JadwalID == 0 {
		return fmt.Errorf("jadwal tidak ditemukan")
	}

	// update langsung
	return m.repository.UpdateTanggalEstimasi(jadwalID, newDate)
}

func (m *Main) GetJadwalImunisasiByJadwalID(
	userID int32,
	jadwalID uint,
) (*models.JadwalImunisasiResponse, error) {

	row, err := m.repository.GetJadwalImunisasiByJadwalID(userID, jadwalID)
	if err != nil {
		return nil, err
	}

	if row == nil || row.JadwalID == 0 {
		return nil, nil
	}

	result := &models.JadwalImunisasiResponse{
		AnakID:         int32(row.AnakID),
		NamaAnak:       row.NamaAnak,
		TanggalLahir:   row.TanggalLahir,
		JumlahTerlewat: 0,
		Jadwal: []models.JadwalImunisasiItem{
			{
				JadwalID:        row.JadwalID,
				NamaDosis:       row.NamaDosis,
				TanggalEstimasi: row.TanggalEstimasi,
				Deskripsi:       row.Deskripsi,
				EfekSamping:     row.EfekSamping,
				StatusID:        row.StatusID,
				Status:          row.Status,
			},
		},
	}

	// hitung terlewat
	switch row.StatusID {
	case 3, 4, 5:
		result.JumlahTerlewat = 1
	}

	return result, nil
}

func (m *Main) SetJadwalSelesai(userID int32, jadwalID uint) error {
	// optional: cek apakah data ada
	data, err := m.repository.GetJadwalImunisasiByJadwalID(userID, jadwalID)
	if err != nil {
		return err
	}

	if data == nil || data.JadwalID == 0 {
		return fmt.Errorf("jadwal tidak ditemukan")
	}

	// update status jadi 6 (SELESAI)
	return m.repository.UpdateStatusJadwalImunisasi(jadwalID, 6)
}

// ==================== KHUSUS BIDAN ====================

func (m *Main) GetJadwalImunisasiByAnakIDBidan(anakID int32) ([]models.JadwalImunisasiResponse, error) {

	rows, err := m.repository.GetJadwalImunisasiByAnakIDBidan(anakID)
	if err != nil {
		return nil, err
	}

	anakMap := make(map[int32]*models.JadwalImunisasiResponse)

	for _, row := range rows {
		if _, exists := anakMap[row.AnakID]; !exists {
			anakMap[row.AnakID] = &models.JadwalImunisasiResponse{
				AnakID:         row.AnakID,
				NamaAnak:       row.NamaAnak,
				TanggalLahir:   row.TanggalLahir,
				JumlahTerlewat: 0,
				Jadwal:         []models.JadwalImunisasiItem{},
			}
		}

		if row.JadwalID != 0 {
			switch row.StatusID {
			case 3, 4, 5:
				anakMap[row.AnakID].JumlahTerlewat++
			}

			anakMap[row.AnakID].Jadwal = append(anakMap[row.AnakID].Jadwal, models.JadwalImunisasiItem{
				JadwalID:        row.JadwalID,
				DosisVaksinID:   row.DosisVaksinID,
				NamaDosis:       row.NamaDosis,
				TanggalEstimasi: row.TanggalEstimasi,
				Deskripsi:       row.Deskripsi,
				EfekSamping:     row.EfekSamping,
				StatusID:        row.StatusID,
				Status:          row.Status,
			})
		}
	}

	response := []models.JadwalImunisasiResponse{}
	for _, anak := range anakMap {
		response = append(response, *anak)
	}

	return response, nil
}

func (m *Main) SetJadwalSelesaiBidan(jadwalID uint) error {
	return m.repository.UpdateStatusJadwalImunisasi(jadwalID, 6)
}

// SetJadwalSelesaiBidanReset resets a completed jadwal back to status 1 (belum)
func (m *Main) SetJadwalSelesaiBidanReset(jadwalID uint) error {
	return m.repository.UpdateStatusJadwalImunisasi(jadwalID, 1)
}

func (m *Main) GetJadwalImunisasiByJadwalIDBidan(jadwalID uint) (*models.JadwalImunisasiResponse, error) {

	row, err := m.repository.GetJadwalImunisasiByJadwalIDBidan(jadwalID)
	if err != nil {
		return nil, err
	}

	if row == nil || row.JadwalID == 0 {
		return nil, nil
	}

	return &models.JadwalImunisasiResponse{
		AnakID:         int32(row.AnakID),
		NamaAnak:       row.NamaAnak,
		TanggalLahir:   row.TanggalLahir,
		JumlahTerlewat: 0,
		Jadwal: []models.JadwalImunisasiItem{
			{
				JadwalID:        row.JadwalID,
				DosisVaksinID:   row.DosisVaksinID,
				NamaDosis:       row.NamaDosis,
				TanggalEstimasi: row.TanggalEstimasi,
				Deskripsi:       row.Deskripsi,
				EfekSamping:     row.EfekSamping,
				StatusID:        row.StatusID,
				Status:          row.Status,
			},
		},
	}, nil
}

func (m *Main) GetJadwalImunisasiTerlewatByKaderID(
	userID int32,
) (
	[]models.JadwalImunisasiTerlewatResponse,
	error,
) {

	rows, err :=
		m.repository.
			GetJadwalImunisasiTerlewatByKaderID(
				userID,
			)

	if err != nil {
		return nil, err
	}

	response :=
		[]models.JadwalImunisasiTerlewatResponse{}

	for _, row := range rows {
		jumlahHariTerlambat := 0

		if row.JadwalImunisasi != nil {
			jumlahHariTerlambat =
				int(
					time.Since(*row.JadwalImunisasi).
						Hours() / 24,
				)
		}
		response =
			append(
				response,
				models.JadwalImunisasiTerlewatResponse{
					JadwalID: row.JadwalID,

					NamaAnak:     row.NamaAnak,
					TanggalLahir: row.TanggalLahir,
					Dusun:        row.Dusun,

					NamaIbu:         row.NamaIbu,
					NomorTeleponIbu: row.NomorTeleponIbu,

					NamaAyah:         row.NamaAyah,
					NomorTeleponAyah: row.NomorTeleponAyah,

					NamaDosis: row.NamaDosis,

					JadwalImunisasi: row.JadwalImunisasi,

					NamaStatus: row.NamaStatus,

					Prioritas: getPrioritasImunisasi(
						row.JadwalImunisasi,
					),
					JumlahHariTerlambat: jumlahHariTerlambat,
				},
			)
	}
	sort.Slice(
		response,
		func(i, j int) bool {

			order := map[string]int{
				"P1": 1,
				"P2": 2,
				"P3": 3,
				"P4": 4,
			}

			return order[response[i].Prioritas] <
				order[response[j].Prioritas]
		},
	)

	return response, nil
}

func (m *Main) GetJadwalImunisasiTerlewatByID(
	userID int32,
	jadwalID uint,
) (
	*models.DetailJadwalImunisasiTerlewatResponse,
	error,
) {

	row, err :=
		m.repository.
			GetJadwalImunisasiTerlewatByID(
				userID,
				jadwalID,
			)

	if err != nil {
		return nil, err
	}

	if row == nil || row.JadwalID == 0 {
		return nil, nil
	}

	jumlahHariTerlambat := 0

	if row.JadwalImunisasi != nil {
		jumlahHariTerlambat =
			int(
				time.Since(*row.JadwalImunisasi).
					Hours() / 24,
			)
	}

	return &models.DetailJadwalImunisasiTerlewatResponse{
		JadwalID: row.JadwalID,
		AnakID:   row.AnakID,

		NamaAnak:     row.NamaAnak,
		TanggalLahir: row.TanggalLahir,
		Dusun:        row.Dusun,

		NamaIbu:         row.NamaIbu,
		NomorTeleponIbu: row.NomorTeleponIbu,

		NamaAyah:         row.NamaAyah,
		NomorTeleponAyah: row.NomorTeleponAyah,

		NamaDosis: row.NamaDosis,

		JadwalImunisasi: row.JadwalImunisasi,

		NamaStatus: row.NamaStatus,

		Prioritas: getPrioritasImunisasi(
			row.JadwalImunisasi,
		),
		JumlahHariTerlambat: jumlahHariTerlambat,
	}, nil
}

func getPrioritasImunisasi(
	tanggal *time.Time,
) string {

	if tanggal == nil {
		return "P4"
	}

	delta :=
		int(time.Since(*tanggal).Hours() / 24)

	switch {

	case delta > 14:
		return "P1"

	case delta >= 7:
		return "P2"

	case delta >= 1:
		return "P3"

	default:
		return "P4"
	}
}
