package usecases

// import (
// 	"errors"
// 	"fmt"
// 	"testing"
// 	"time"

// 	"monitoring-service/app/models"
// 	"monitoring-service/app/repositories"
// )

// // fakeJadwalRepo adalah implementasi palsu dari jadwalImunisasiRepository,
// // dipakai untuk menguji rule generate jadwal tanpa koneksi database asli.
// type fakeJadwalRepo struct {
// 	anakByID     map[int32]*models.Anak
// 	anakByUserID map[int32][]models.ImunisasiAnak
// 	aturanList   []models.AturanVaksinAnak
// 	existing     map[string]bool
// 	riwayat      map[string]*repositories.RiwayatImunisasiResult

// 	created                  []models.JadwalImunisasiAnak
// 	updateJadwalStatusCalled bool
// }

// func keyAnakDosis(anakID int32, dosisID int64) string {
// 	return fmt.Sprintf("%d_%d", anakID, dosisID)
// }

// func aturanByDosis(list []models.AturanVaksinAnak, dosisID uint) models.AturanVaksinAnak {
// 	for _, a := range list {
// 		if a.DosisVaksinID == dosisID {
// 			return a
// 		}
// 	}
// 	return models.AturanVaksinAnak{}
// }

// func (f *fakeJadwalRepo) GetAnakByUserID(userID int32) ([]models.ImunisasiAnak, error) {
// 	return f.anakByUserID[userID], nil
// }

// func (f *fakeJadwalRepo) GetAnakByID(anakID uint) (*models.Anak, error) {
// 	anak, ok := f.anakByID[int32(anakID)]
// 	if !ok {
// 		return nil, errors.New("anak tidak ditemukan")
// 	}
// 	return anak, nil
// }

// func (f *fakeJadwalRepo) GetAturanVaksinAnak() ([]models.AturanVaksinAnak, error) {
// 	return f.aturanList, nil
// }

// func (f *fakeJadwalRepo) IsJadwalExist(anakID int32, dosisID int64) (bool, error) {
// 	return f.existing[keyAnakDosis(anakID, dosisID)], nil
// }

// func (f *fakeJadwalRepo) GetRiwayatImunisasi(anakID int32, dosisID int64) (*repositories.RiwayatImunisasiResult, error) {
// 	r, ok := f.riwayat[keyAnakDosis(anakID, dosisID)]
// 	if !ok {
// 		return nil, errors.New("riwayat tidak ditemukan")
// 	}
// 	return r, nil
// }

// func (f *fakeJadwalRepo) CreateJadwalImunisasiAnak(jadwal *models.JadwalImunisasiAnak) error {
// 	f.created = append(f.created, *jadwal)
// 	return nil
// }

// func (f *fakeJadwalRepo) UpdateJadwalStatus() error {
// 	f.updateJadwalStatusCalled = true
// 	return nil
// }

// // TestGenerateJadwalImunisasiByAnakID_SemuaJadwalTergenerate memverifikasi bahwa
// // untuk seorang anak baru (belum punya jadwal sama sekali), SEMUA aturan vaksin
// // yang berlaku menghasilkan satu jadwal masing-masing (jumlah jadwal = jumlah aturan).
// func TestGenerateJadwalImunisasiByAnakID_SemuaJadwalTergenerate(t *testing.T) {
// 	lahir := time.Now().AddDate(0, -2, 0) // anak umur 2 bulan

// 	anak := &models.Anak{
// 		ID:       1,
// 		Penduduk: &models.Kependudukan{TanggalLahir: lahir},
// 	}

// 	aturan := []models.AturanVaksinAnak{
// 		{ID: 1, DosisVaksinID: 101, MinUsiaHari: 0},
// 		{ID: 2, DosisVaksinID: 102, MinUsiaHari: 30},
// 		{ID: 3, DosisVaksinID: 103, MinUsiaHari: 60},
// 	}

// 	repo := &fakeJadwalRepo{
// 		anakByID:   map[int32]*models.Anak{1: anak},
// 		aturanList: aturan,
// 		existing:   map[string]bool{},
// 	}

// 	if err := generateJadwalImunisasiByAnakID(repo, 1); err != nil {
// 		t.Fatalf("tidak boleh error, dapat: %v", err)
// 	}

// 	if len(repo.created) != len(aturan) {
// 		t.Fatalf(
// 			"jumlah jadwal tergenerate = %d, want %d (harus sama dengan jumlah aturan vaksin)",
// 			len(repo.created), len(aturan),
// 		)
// 	}

// 	dibuat := map[uint]bool{}
// 	for _, j := range repo.created {
// 		dibuat[j.DosisVaksinID] = true

// 		rule := aturanByDosis(aturan, j.DosisVaksinID)
// 		expectedTanggal := lahir.AddDate(0, 0, int(rule.MinUsiaHari))

// 		if !j.TanggalEstimasi.Equal(expectedTanggal) {
// 			t.Errorf(
// 				"dosis %d: tanggal estimasi = %v, want %v",
// 				j.DosisVaksinID, j.TanggalEstimasi, expectedTanggal,
// 			)
// 		}
// 	}

// 	for _, a := range aturan {
// 		if !dibuat[a.DosisVaksinID] {
// 			t.Errorf("dosis vaksin %d tidak tergenerate", a.DosisVaksinID)
// 		}
// 	}

// 	if !repo.updateJadwalStatusCalled {
// 		t.Error("UpdateJadwalStatus seharusnya dipanggil setelah proses generate selesai")
// 	}
// }

// // TestGenerateJadwalImunisasiByAnakID_SkipJikaSudahAda memverifikasi bahwa dosis
// // yang jadwalnya sudah ada tidak digenerate ulang (mencegah duplikasi).
// func TestGenerateJadwalImunisasiByAnakID_SkipJikaSudahAda(t *testing.T) {
// 	lahir := time.Now().AddDate(0, -2, 0)

// 	anak := &models.Anak{
// 		ID:       1,
// 		Penduduk: &models.Kependudukan{TanggalLahir: lahir},
// 	}

// 	aturan := []models.AturanVaksinAnak{
// 		{ID: 1, DosisVaksinID: 101, MinUsiaHari: 0},
// 		{ID: 2, DosisVaksinID: 102, MinUsiaHari: 30},
// 		{ID: 3, DosisVaksinID: 103, MinUsiaHari: 60},
// 	}

// 	repo := &fakeJadwalRepo{
// 		anakByID:   map[int32]*models.Anak{1: anak},
// 		aturanList: aturan,
// 		existing: map[string]bool{
// 			keyAnakDosis(1, 101): true, // dosis 101 sudah ada jadwalnya
// 		},
// 	}

// 	if err := generateJadwalImunisasiByAnakID(repo, 1); err != nil {
// 		t.Fatalf("tidak boleh error, dapat: %v", err)
// 	}

// 	if len(repo.created) != 2 {
// 		t.Fatalf(
// 			"jumlah jadwal baru = %d, want 2 (1 dari 3 dosis sudah ada dan harus di-skip)",
// 			len(repo.created),
// 		)
// 	}

// 	for _, j := range repo.created {
// 		if j.DosisVaksinID == 101 {
// 			t.Error("dosis 101 seharusnya di-skip karena sudah punya jadwal")
// 		}
// 	}
// }

// // TestGenerateJadwalImunisasiByAnakID_SkipJikaDataBelumLengkap memverifikasi
// // bahwa proses generate tidak membuat jadwal apa pun jika data kependudukan
// // anak (tanggal lahir) belum tersedia.
// func TestGenerateJadwalImunisasiByAnakID_SkipJikaDataBelumLengkap(t *testing.T) {
// 	anak := &models.Anak{ID: 1, Penduduk: nil}

// 	repo := &fakeJadwalRepo{
// 		anakByID:   map[int32]*models.Anak{1: anak},
// 		aturanList: []models.AturanVaksinAnak{{ID: 1, DosisVaksinID: 101, MinUsiaHari: 0}},
// 		existing:   map[string]bool{},
// 	}

// 	if err := generateJadwalImunisasiByAnakID(repo, 1); err != nil {
// 		t.Fatalf("tidak boleh error, dapat: %v", err)
// 	}

// 	if len(repo.created) != 0 {
// 		t.Fatalf(
// 			"jumlah jadwal = %d, want 0 (data penduduk/tanggal lahir belum lengkap)",
// 			len(repo.created),
// 		)
// 	}
// }

// // TestGenerateJadwalImunisasi_DosisLanjutanMenungguInterval memverifikasi rule
// // dosis lanjutan (DosisSebelumID + MinIntervalHari) pada generateJadwalImunisasi
// // (versi multi-anak berdasarkan userID): dosis lanjutan hanya tergenerate jika
// // interval minimal sejak dosis sebelumnya sudah terpenuhi.
// func TestGenerateJadwalImunisasi_DosisLanjutanMenungguInterval(t *testing.T) {
// 	lahir := time.Now().AddDate(-1, 0, 0) // anak umur 1 tahun

// 	dosisSebelum := uint(101)
// 	aturan := []models.AturanVaksinAnak{
// 		{ID: 1, DosisVaksinID: 101, MinUsiaHari: 0},
// 		{
// 			ID: 2, DosisVaksinID: 102, MinUsiaHari: 30,
// 			MinIntervalHari: 28, DosisSebelumID: &dosisSebelum,
// 		},
// 	}

// 	anak1 := models.ImunisasiAnak{ID: 1, TanggalLahir: &lahir}
// 	anak2 := models.ImunisasiAnak{ID: 2, TanggalLahir: &lahir}

// 	repo := &fakeJadwalRepo{
// 		anakByUserID: map[int32][]models.ImunisasiAnak{
// 			99: {anak1, anak2},
// 		},
// 		aturanList: aturan,
// 		existing: map[string]bool{
// 			keyAnakDosis(1, 101): true, // dosis pertama anak 1 sudah pernah diberikan
// 			keyAnakDosis(2, 101): true, // dosis pertama anak 2 sudah pernah diberikan
// 		},
// 		riwayat: map[string]*repositories.RiwayatImunisasiResult{
// 			keyAnakDosis(1, 101): {TanggalDiberikan: time.Now().AddDate(0, 0, -30)}, // 30 hari lalu -> interval 28 hari terpenuhi
// 			keyAnakDosis(2, 101): {TanggalDiberikan: time.Now().AddDate(0, 0, -10)}, // 10 hari lalu -> interval belum terpenuhi
// 		},
// 	}

// 	if err := generateJadwalImunisasi(repo, 99); err != nil {
// 		t.Fatalf("tidak boleh error, dapat: %v", err)
// 	}

// 	var anak1DapatDosisLanjutan, anak2DapatDosisLanjutan bool
// 	for _, j := range repo.created {
// 		if j.DosisVaksinID != 102 {
// 			continue
// 		}
// 		if j.AnakID == 1 {
// 			anak1DapatDosisLanjutan = true
// 		}
// 		if j.AnakID == 2 {
// 			anak2DapatDosisLanjutan = true
// 		}
// 	}

// 	if !anak1DapatDosisLanjutan {
// 		t.Error("anak 1: dosis lanjutan seharusnya tergenerate karena interval sudah cukup (30 >= 28 hari)")
// 	}
// 	if anak2DapatDosisLanjutan {
// 		t.Error("anak 2: dosis lanjutan seharusnya BELUM tergenerate karena interval belum cukup (10 < 28 hari)")
// 	}
// }
