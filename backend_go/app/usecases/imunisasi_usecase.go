package usecases

import (
	"fmt"
	"monitoring-service/app/models"
	"time"
)

func (m *Main) GenerateJadwalImunisasi(
	userID int32,
) error {

	fmt.Println("========== START GENERATE ==========")
	fmt.Println("USER ID:", userID)

	anaks, err := m.repository.GetAnakByUserID(userID)
	if err != nil {
		return err
	}
	fmt.Println("TOTAL ANAK:", len(anaks))

	for _, a := range anaks {
		fmt.Println(
			"ANAK:",
			a.ID,
			"TanggalLahir:",
			a.TanggalLahir,
		)
	}

	aturanList, err := m.repository.GetAturanVaksinAnak()
	if err != nil {
		return err
	}
	fmt.Println(
		"TOTAL RULE:",
		len(aturanList),
	)

	for _, r := range aturanList {
		fmt.Println(
			"RULE:",
			r.ID,
			r.DosisVaksinID,
			r.MinUsiaHari,
			r.MaxUsiaHari,
		)
	}

	today := time.Now()

	for _, anak := range anaks {

		if anak.TanggalLahir == nil {
			continue
		}

		umurHari := int(
			today.Sub(*anak.TanggalLahir).Hours() / 24,
		)

		fmt.Println(
			"ANAK ID:",
			anak.ID,
			"UMUR:",
			umurHari,
		)

		for _, rule := range aturanList {

			alreadyExist, err :=
				m.repository.IsJadwalExist(
					anak.ID,
					int64(rule.DosisVaksinID),
				)

			if err != nil {
				return err
			}

			if alreadyExist {
				fmt.Println(
					"SKIP: jadwal sudah ada",
				)
				continue
			}

			var tanggalEstimasi time.Time

			if rule.DosisSebelumID != nil {
				riwayat, err :=
					m.repository.GetRiwayatImunisasi(
						anak.ID,
						int64(*rule.DosisSebelumID),
					)

				if err != nil {
					continue
				}
				if rule.MinIntervalHari == 0 {
					continue
				}

				selisihHari := int(
					today.Sub(
						riwayat.TanggalDiberikan,
					).Hours() / 24,
				)
				if selisihHari < int(rule.MinIntervalHari) {
					continue
				}
				tanggalEstimasi =
					riwayat.TanggalDiberikan.AddDate(
						0,
						0,
						int(rule.MinIntervalHari),
					)
			} else {

				tanggalEstimasi =
					anak.TanggalLahir.AddDate(
						0,
						0,
						int(rule.MinUsiaHari),
					)
			}
			statusID := calculateStatusID(
				tanggalEstimasi,
			)

			fmt.Println(
				"CREATE JADWAL",
				"Anak:", anak.ID,
				"Dosis:", rule.DosisVaksinID,
				"Tanggal:", tanggalEstimasi,
				"Status:", statusID,
			)

			jadwal := &models.JadwalImunisasiAnak{
				AnakID:          uint(anak.ID),
				DosisVaksinID:   rule.DosisVaksinID,
				TanggalEstimasi: &tanggalEstimasi,
				StatusJadwalID:  uint(statusID),
			}
			err =
				m.repository.
					CreateJadwalImunisasiAnak(
						jadwal,
					)

			if err != nil {
				fmt.Println(
					"ERROR INSERT:",
					err,
				)

				return err
			}
			fmt.Println(
				"SUCCESS INSERT",
			)
		}
	}

	_ = m.repository.UpdateJadwalStatus()

	return nil
}

func (m *Main) GenerateJadwalImunisasiByAnakID(anakID int32) error {

	fmt.Println("========== GENERATE BY ANAK ID ==========")
	fmt.Println("ANAK ID:", anakID)

	// RULE 1: Ambil data anak berdasarkan ID
	anak, err := m.repository.GetAnakByID(uint(anakID))
	if err != nil {
		fmt.Println("ERROR GetAnakByID:", err)
		return err
	}

	// RULE 2: Validasi data wajib — skip generate jika tanggal lahir/penduduk tidak tersedia
	if anak.Penduduk == nil || anak.Penduduk.TanggalLahir.IsZero() {
		fmt.Println("SKIP: TanggalLahir nil atau Penduduk tidak ditemukan")
		return nil
	}

	tanggalLahir := anak.Penduduk.TanggalLahir

	// RULE 3: Ambil seluruh aturan vaksin (master rule) yang berlaku untuk anak
	aturanList, err := m.repository.GetAturanVaksinAnak()
	if err != nil {
		fmt.Println("ERROR GetAturanVaksinAnak:", err)
		return err
	}

	for _, rule := range aturanList {

		// RULE 4: Cek duplikasi — skip jika jadwal untuk dosis vaksin ini sudah pernah dibuat
		alreadyExist, err := m.repository.IsJadwalExist(
			anak.ID,
			int64(rule.DosisVaksinID),
		)
		if err != nil {
			fmt.Println("ERROR IsJadwalExist:", err)
			return err
		}

		if alreadyExist {
			fmt.Println(
				"SKIP: jadwal sudah ada",
				"Anak:", anak.ID,
				"Dosis:", rule.DosisVaksinID,
			)
			continue
		}

		// RULE 5: Hitung tanggal estimasi imunisasi = tanggal lahir + minimal usia (hari) sesuai aturan
		tanggalEstimasi := tanggalLahir.AddDate(
			0,
			0,
			int(rule.MinUsiaHari),
		)

		// RULE 6: Tentukan status jadwal berdasarkan tanggal estimasi (mis. akan datang/terlewat)
		statusID := calculateStatusID(
			tanggalEstimasi,
		)

		fmt.Println(
			"CREATE JADWAL",
			"Anak:", anak.ID,
			"Dosis:", rule.DosisVaksinID,
			"Tanggal:", tanggalEstimasi,
			"Status:", statusID,
		)

		// RULE 7: Bentuk entitas jadwal imunisasi baru berdasarkan hasil rule 5 & 6
		jadwal := &models.JadwalImunisasiAnak{
			AnakID:          uint(anak.ID),
			DosisVaksinID:   rule.DosisVaksinID,
			TanggalEstimasi: &tanggalEstimasi,
			StatusJadwalID:  uint(statusID),
		}

		// RULE 8: Simpan jadwal baru ke database
		if err := m.repository.CreateJadwalImunisasiAnak(jadwal); err != nil {
			fmt.Println(
				"ERROR INSERT:",
				err,
			)
			return err
		}

		fmt.Println(
			"SUCCESS INSERT jadwal, dosis:",
			rule.DosisVaksinID,
		)
	}

	// RULE 9: Setelah semua jadwal dibuat, refresh/update status seluruh jadwal (mis. jadwal yang jadi terlambat/selesai)
	if err := m.repository.UpdateJadwalStatus(); err != nil {
		fmt.Println(
			"ERROR UpdateJadwalStatus:",
			err,
		)
	}

	fmt.Println("========== GENERATE SELESAI ==========")

	return nil
}

func calculateStatusID(
	tanggalEstimasi time.Time,
) int32 {

	today := time.Now()

	today = time.Date(
		today.Year(),
		today.Month(),
		today.Day(),
		0, 0, 0, 0,
		today.Location(),
	)

	tanggalEstimasi = time.Date(
		tanggalEstimasi.Year(),
		tanggalEstimasi.Month(),
		tanggalEstimasi.Day(),
		0, 0, 0, 0,
		tanggalEstimasi.Location(),
	)

	diff := int(
		tanggalEstimasi.Sub(today).
			Hours() / 24,
	)

	switch {

	case diff >= 1:
		return 1

	case diff == 0:
		return 2

	case diff >= -6 && diff < 0:
		return 3

	case diff >= -14 && diff < -6:
		return 4

	default:
		return 5
	}
}

// GetAturanVaksinAnak returns all aturan vaksin anak (for color coding in frontend)
func (m *Main) GetAturanVaksinAnak() ([]models.AturanVaksinAnak, error) {
	return m.repository.GetAturanVaksinAnak()
}
