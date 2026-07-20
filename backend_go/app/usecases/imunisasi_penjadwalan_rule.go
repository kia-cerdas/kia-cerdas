package usecases

import "time"

// AturanJadwalInput merepresentasikan satu baris aturan vaksin (aturan_vaksin_anak)
// dalam bentuk data murni, tanpa bergantung pada model GORM/repository.
type AturanJadwalInput struct {
	DosisVaksinID uint
	MinUsiaHari   uint
}

// JadwalTergenerate adalah hasil keputusan rule: satu jadwal yang seharusnya dibuat.
type JadwalTergenerate struct {
	DosisVaksinID   uint
	TanggalEstimasi time.Time
	StatusID        int32
}

// TentukanJadwalImunisasi adalah usecase murni (pure, tanpa akses database) yang
// merepresentasikan rule penjadwalan otomatis imunisasi: untuk seorang anak,
// tentukan daftar jadwal baru yang seharusnya digenerate berdasarkan tanggal lahir,
// daftar aturan vaksin, dan dosis yang sudah punya jadwal.
//
// Logika di sini sengaja dibuat identik dengan rule yang dipakai
// GenerateJadwalImunisasiByAnakID di imunisasi_usecase.go, tapi diekstrak ke fungsi
// murni terpisah (tanpa memanggil repository) supaya bisa diuji dengan skenario
// tabel tanpa perlu koneksi database, dan tanpa mengubah implementasi produksi
// yang sudah berjalan.
func TentukanJadwalImunisasi(
	tanggalLahir time.Time,
	aturanList []AturanJadwalInput,
	dosisSudahAdaJadwal map[uint]bool,
) []JadwalTergenerate {

	hasil := []JadwalTergenerate{}

	for _, rule := range aturanList {

		// RULE 1: skip jika dosis ini sudah pernah dibuatkan jadwal (cegah duplikasi)
		if dosisSudahAdaJadwal[rule.DosisVaksinID] {
			continue
		}

		// RULE 2: tanggal estimasi = tanggal lahir + usia minimal (hari)
		tanggalEstimasi := tanggalLahir.AddDate(0, 0, int(rule.MinUsiaHari))

		hasil = append(hasil, JadwalTergenerate{
			DosisVaksinID:   rule.DosisVaksinID,
			TanggalEstimasi: tanggalEstimasi,
			StatusID:        calculateStatusID(tanggalEstimasi),
		})
	}

	return hasil
}
