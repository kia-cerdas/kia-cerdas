package usecases

import (
	"testing"
)

// TestTentukanJadwalImunisasi_SemuaJadwalTergenerate memverifikasi bahwa untuk
// anak baru (belum ada jadwal sama sekali), SEMUA aturan vaksin menghasilkan
// satu jadwal masing-masing (jumlah jadwal = jumlah aturan).
func TestTentukanJadwalImunisasi_SemuaJadwalTergenerate(t *testing.T) {
	lahir := addDays(-60) // anak umur 60 hari

	aturan := []AturanJadwalInput{
		{DosisVaksinID: 101, MinUsiaHari: 0},
		{DosisVaksinID: 102, MinUsiaHari: 30},
		{DosisVaksinID: 103, MinUsiaHari: 60},
	}

	hasil := TentukanJadwalImunisasi(lahir, aturan, map[uint]bool{})

	if len(hasil) != len(aturan) {
		t.Fatalf(
			"jumlah jadwal tergenerate = %d, want %d (harus sama dengan jumlah aturan vaksin)",
			len(hasil), len(aturan),
		)
	}

	dibuat := map[uint]bool{}
	for _, j := range hasil {
		dibuat[j.DosisVaksinID] = true
	}
	for _, a := range aturan {
		if !dibuat[a.DosisVaksinID] {
			t.Errorf("dosis vaksin %d tidak tergenerate", a.DosisVaksinID)
		}
	}
}

// TestTentukanJadwalImunisasi_TanggalEstimasiSesuaiMinUsiaHari memverifikasi
// bahwa tanggal estimasi = tanggal lahir + MinUsiaHari.
func TestTentukanJadwalImunisasi_TanggalEstimasiSesuaiMinUsiaHari(t *testing.T) {
	lahir := addDays(-60)

	aturan := []AturanJadwalInput{
		{DosisVaksinID: 102, MinUsiaHari: 30},
	}

	hasil := TentukanJadwalImunisasi(lahir, aturan, map[uint]bool{})

	if len(hasil) != 1 {
		t.Fatalf("jumlah jadwal = %d, want 1", len(hasil))
	}

	expected := lahir.AddDate(0, 0, 30)
	if !hasil[0].TanggalEstimasi.Equal(expected) {
		t.Errorf("tanggal estimasi = %v, want %v", hasil[0].TanggalEstimasi, expected)
	}
}

// TestTentukanJadwalImunisasi_SkipJikaSudahAdaJadwal memverifikasi bahwa dosis
// yang sudah punya jadwal tidak digenerate ulang (mencegah duplikasi).
func TestTentukanJadwalImunisasi_SkipJikaSudahAdaJadwal(t *testing.T) {
	lahir := addDays(-60)

	aturan := []AturanJadwalInput{
		{DosisVaksinID: 101, MinUsiaHari: 0},
		{DosisVaksinID: 102, MinUsiaHari: 30},
		{DosisVaksinID: 103, MinUsiaHari: 60},
	}

	hasil := TentukanJadwalImunisasi(
		lahir,
		aturan,
		map[uint]bool{101: true, 103: true}, // dosis 101 & 103 sudah ada jadwalnya
	)

	if len(hasil) != 1 {
		t.Fatalf("jumlah jadwal baru = %d, want 1 (dosis 101 & 103 harus di-skip)", len(hasil))
	}
	if hasil[0].DosisVaksinID != 102 {
		t.Errorf("dosis yang tergenerate = %d, want 102", hasil[0].DosisVaksinID)
	}
}

// TestTentukanJadwalImunisasi_TidakAdaAturan memverifikasi bahwa tanpa aturan
// vaksin sama sekali, tidak ada jadwal yang tergenerate (bukan nil/error).
func TestTentukanJadwalImunisasi_TidakAdaAturan(t *testing.T) {
	lahir := addDays(-60)

	hasil := TentukanJadwalImunisasi(lahir, []AturanJadwalInput{}, map[uint]bool{})

	if len(hasil) != 0 {
		t.Fatalf("jumlah jadwal = %d, want 0 (tidak ada aturan)", len(hasil))
	}
}
