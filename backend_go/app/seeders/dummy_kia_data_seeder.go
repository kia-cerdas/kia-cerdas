package seeders

// import (
// 	"log"
// 	"time"

// 	"monitoring-service/app/models"

// 	"gorm.io/gorm"
// )

// type DummyKIADataSeeder struct {
// 	db *gorm.DB
// }

// func NewDummyKIADataSeeder(db *gorm.DB) *DummyKIADataSeeder {
// 	return &DummyKIADataSeeder{db: db}
// }

// func (s *DummyKIADataSeeder) Seed() error {
// 	log.Println("Starting dummy KIA data seeding...")

// 	now := time.Now().UTC().Truncate(time.Second)

// 	if err := s.seedPenduduk(now); err != nil {
// 		return err
// 	}
// 	if err := s.seedBidan(now); err != nil {
// 		return err
// 	}
// 	if err := s.seedIbu(now); err != nil {
// 		return err
// 	}
// 	if err := s.seedKehamilan(now); err != nil {
// 		return err
// 	}
// 	if err := s.seedAnak(now); err != nil {
// 		return err
// 	}
// 	if err := s.seedPemeriksaanKehamilan(now); err != nil {
// 		return err
// 	}
// 	if err := s.seedCatatanPertumbuhan(now); err != nil {
// 		return err
// 	}

// 	log.Println("Dummy KIA data seeding completed!")
// 	return nil
// }

// func (s *DummyKIADataSeeder) seedPenduduk(now time.Time) error {
// 	type row struct {
// 		ID                 int32
// 		NIK                string
// 		NamaLengkap        string
// 		JenisKelamin       string
// 		TanggalLahir       string
// 		TempatLahir        string
// 		GolonganDarah      string
// 		Agama              string
// 		StatusPerkawinan   string
// 		PendidikanTerakhir string
// 		Pekerjaan          string
// 		BacaHuruf          string
// 		KedudukanKeluarga  string
// 		Dusun              string
// 		Kecamatan          string
// 		Desa               string
// 		AsalPenduduk       string
// 		TujuanPindah       string
// 		TempatMeninggal    string
// 		Keterangan         string
// 	}

// 	rows := []row{
// 		{1001, "3173010101010001", "Siti Aminah", "Perempuan", "1994-02-14", "Bandung", "A", "Islam", "Kawin", "SMA", "Ibu Rumah Tangga", "Bisa", "Istri", "Dusun Melati", "Cimahi Selatan", "Cimahi", "Lahir di wilayah", "", "", "Data dummy ibu 1"},
// 		{1002, "3173010101010002", "Budi Santoso", "Laki-laki", "1992-11-07", "Bandung", "O", "Islam", "Kawin", "D3", "Wiraswasta", "Bisa", "Kepala Keluarga", "Dusun Melati", "Cimahi Selatan", "Cimahi", "Lahir di wilayah", "", "", "Data dummy suami ibu 1"},
// 		{1003, "3173010101010003", "Aisyah Putri", "Perempuan", "2024-11-12", "Cimahi", "A", "Islam", "Belum Kawin", "Belum Sekolah", "-", "Belum", "Anak", "Dusun Melati", "Cimahi Selatan", "Cimahi", "Lahir di wilayah", "", "", "Data dummy anak 1"},
// 		{1004, "3173010101010004", "Naufal Putra", "Laki-laki", "2025-08-03", "Cimahi", "B", "Islam", "Belum Kawin", "Belum Sekolah", "-", "Belum", "Anak", "Dusun Melati", "Cimahi Selatan", "Cimahi", "Lahir di wilayah", "", "", "Data dummy anak 2"},
// 		{1005, "3173010101010005", "Rina Kartika", "Perempuan", "1996-05-22", "Sukabumi", "AB", "Islam", "Kawin", "S1", "Bidan", "Bisa", "Istri", "Dusun Mawar", "Cimahi Utara", "Cimahi", "Lahir di wilayah", "", "", "Data dummy ibu 2"},
// 		{1006, "3173010101010006", "Andi Saputra", "Laki-laki", "1991-09-18", "Sukabumi", "O", "Islam", "Kawin", "SMA", "Karyawan", "Bisa", "Kepala Keluarga", "Dusun Mawar", "Cimahi Utara", "Cimahi", "Lahir di wilayah", "", "", "Data dummy suami ibu 2"},
// 		{1007, "3173010101010007", "Zahra Alifa", "Perempuan", "2024-12-30", "Cimahi", "O", "Islam", "Belum Kawin", "Belum Sekolah", "-", "Belum", "Anak", "Dusun Mawar", "Cimahi Utara", "Cimahi", "Lahir di wilayah", "", "", "Data dummy anak 3"},
// 		{1008, "3173010101010008", "Lestari Wulan", "Perempuan", "1993-01-10", "Garut", "B", "Islam", "Kawin", "S1", "Guru", "Bisa", "Istri", "Dusun Kenanga", "Cimahi Tengah", "Cimahi", "Lahir di wilayah", "", "", "Data dummy ibu 3"},
// 		{1009, "3173010101010009", "Arif Pratama", "Laki-laki", "1990-03-05", "Garut", "A", "Islam", "Kawin", "SMA", "Pedagang", "Bisa", "Kepala Keluarga", "Dusun Kenanga", "Cimahi Tengah", "Cimahi", "Lahir di wilayah", "", "", "Data dummy suami ibu 3"},
// 		{1010, "3173010101010010", "Kevin Aditya", "Laki-laki", "2025-03-18", "Cimahi", "A", "Islam", "Belum Kawin", "Belum Sekolah", "-", "Belum", "Anak", "Dusun Kenanga", "Cimahi Tengah", "Cimahi", "Lahir di wilayah", "", "", "Data dummy anak 4"},
// 	}

// 	for _, item := range rows {
// 		tanggalLahir, err := time.Parse("2006-01-02", item.TanggalLahir)
// 		if err != nil {
// 			return err
// 		}

// 		nik := item.NIK
// 		penduduk := models.Kependudukan{
// 			IDKependudukan:     item.ID,
// 			NIK:                &nik,
// 			NamaLengkap:        item.NamaLengkap,
// 			JenisKelamin:       item.JenisKelamin,
// 			TanggalLahir:       tanggalLahir,
// 			TempatLahir:        item.TempatLahir,
// 			GolonganDarah:      item.GolonganDarah,
// 			Agama:              item.Agama,
// 			StatusPerkawinan:   item.StatusPerkawinan,
// 			PendidikanTerakhir: item.PendidikanTerakhir,
// 			Pekerjaan:          item.Pekerjaan,
// 			BacaHuruf:          item.BacaHuruf,
// 			KedudukanKeluarga:  item.KedudukanKeluarga,
// 			Dusun:              item.Dusun,
// 			Kecamatan:          item.Kecamatan,
// 			Desa:               item.Desa,
// 			AsalPenduduk:       item.AsalPenduduk,
// 			TujuanPindah:       item.TujuanPindah,
// 			TempatMeninggal:    item.TempatMeninggal,
// 			Keterangan:         item.Keterangan,
// 			CreatedAt:          now,
// 			UpdatedAt:          now,
// 		}

// 		if err := s.db.Where("id = ?", penduduk.IDKependudukan).FirstOrCreate(&penduduk).Error; err != nil {
// 			return err
// 		}
// 	}

// 	return nil
// }

// func (s *DummyKIADataSeeder) seedBidan(now time.Time) error {
// 	bidan := models.Bidan{
// 		ID:         3001,
// 		PendudukID: 1005,
// 		NoSTR:      "STR-DUMMY-2026-0001",
// 		NoSIPB:     "SIPB-DUMMY-2026-0001",
// 		Status:     "aktif",
// 		CreatedAt:  now,
// 		UpdatedAt:  now,
// 	}

// 	return s.db.Where("id = ?", bidan.ID).FirstOrCreate(&bidan).Error
// }

// func (s *DummyKIADataSeeder) seedIbu(now time.Time) error {
// 	rows := []models.Ibu{
// 		{IDIbu: 2001, IDKependudukan: 1001, IDSuami: int32Ptr(1002), Gravida: 2, Paritas: 1, Abortus: 0, CreatedAt: now, UpdatedAt: now},
// 		{IDIbu: 2002, IDKependudukan: 1005, IDSuami: int32Ptr(1006), Gravida: 3, Paritas: 2, Abortus: 0, CreatedAt: now, UpdatedAt: now},
// 		{IDIbu: 2003, IDKependudukan: 1008, IDSuami: int32Ptr(1009), Gravida: 1, Paritas: 0, Abortus: 0, CreatedAt: now, UpdatedAt: now},
// 	}

// 	for _, item := range rows {
// 		if err := s.db.Where("id = ?", item.IDIbu).FirstOrCreate(&item).Error; err != nil {
// 			return err
// 		}
// 	}

// 	return nil
// }

// func (s *DummyKIADataSeeder) seedKehamilan(now time.Time) error {
// 	rows := []struct {
// 		ID                       int32
// 		IbuID                    int32
// 		Gravida                  int32
// 		Paritas                  int32
// 		Abortus                  int32
// 		HPHT                     string
// 		TaksiranPersalinan       string
// 		UKKehamilanSaatIni       int32
// 		JarakKehamilanSebelumnya int32
// 		StatusKehamilan          string
// 		BBAwal                   float64
// 		TB                       float64
// 		IMTAwal                  float64
// 	}{
// 		{4001, 2001, 2, 1, 0, "2026-01-15", "2026-10-22", 18, 36, "TRIMESTER 2", 52.3, 158.0, 21.0},
// 		{4002, 2001, 3, 1, 0, "2026-03-11", "2026-12-18", 10, 22, "TRIMESTER 1", 53.1, 158.0, 21.3},
// 		{4003, 2002, 3, 2, 0, "2025-12-10", "2026-09-16", 22, 40, "TRIMESTER 3", 54.8, 160.0, 21.4},
// 		{4004, 2003, 1, 0, 0, "2026-02-20", "2026-11-27", 16, 0, "TRIMESTER 2", 50.5, 157.0, 20.4},
// 	}

// 	for _, item := range rows {
// 		hpht, err := time.Parse("2006-01-02", item.HPHT)
// 		if err != nil {
// 			return err
// 		}
// 		taksiran, err := time.Parse("2006-01-02", item.TaksiranPersalinan)
// 		if err != nil {
// 			return err
// 		}

// 		kehamilan := models.Kehamilan{
// 			ID:                       item.ID,
// 			IbuID:                    item.IbuID,
// 			Gravida:                  item.Gravida,
// 			Paritas:                  item.Paritas,
// 			Abortus:                  item.Abortus,
// 			HPHT:                     hpht,
// 			TaksiranPersalinan:       taksiran,
// 			UKKehamilanSaatIni:       item.UKKehamilanSaatIni,
// 			JarakKehamilanSebelumnya: item.JarakKehamilanSebelumnya,
// 			StatusKehamilan:          item.StatusKehamilan,
// 			BB_Awal:                  item.BBAwal,
// 			TB:                       item.TB,
// 			IMT_Awal:                 item.IMTAwal,
// 			CreatedAt:                now,
// 			UpdatedAt:                now,
// 		}

// 		if err := s.db.Where("id = ?", kehamilan.ID).FirstOrCreate(&kehamilan).Error; err != nil {
// 			return err
// 		}
// 	}

// 	return nil
// }

// func (s *DummyKIADataSeeder) seedAnak(now time.Time) error {
// 	rows := []struct {
// 		ID              int32
// 		KehamilanID     int32
// 		PendudukID      int32
// 		BeratLahirKg    float64
// 		TinggiLahirCm   float64
// 		AnakKe          int32
// 		LingkarKepalaCm float64
// 		NamaIbu         string
// 		NamaAyah        string
// 		IbuID           int32
// 		TanggalLahir    string
// 	}{
// 		{5001, 4001, 1003, 3.1, 49.0, 1, 34.0, "Siti Aminah", "Budi Santoso", 2001, "2024-11-12"},
// 		{5002, 4002, 1004, 2.9, 48.0, 2, 33.5, "Siti Aminah", "Budi Santoso", 2001, "2025-08-03"},
// 		{5003, 4003, 1007, 3.0, 49.5, 1, 34.2, "Rina Kartika", "Andi Saputra", 2002, "2024-12-30"},
// 		{5004, 4004, 1010, 3.2, 50.0, 1, 34.8, "Lestari Wulan", "Arif Pratama", 2003, "2025-03-18"},
// 	}

// 	for _, item := range rows {
// 		tanggalLahir, err := time.Parse("2006-01-02", item.TanggalLahir)
// 		if err != nil {
// 			return err
// 		}

// 		berat := item.BeratLahirKg
// 		tinggi := item.TinggiLahirCm
// 		lingkar := item.LingkarKepalaCm

// 		anak := models.Anak{
// 			ID:              item.ID,
// 			KehamilanID:     item.KehamilanID,
// 			PendudukID:      item.PendudukID,
// 			BeratLahirKg:    &berat,
// 			TinggiLahirCm:   &tinggi,
// 			AnakKe:          item.AnakKe,
// 			LingkarKepalaCm: &lingkar,
// 			NamaIbu:         item.NamaIbu,
// 			NamaAyah:        item.NamaAyah,
// 			IbuID:           item.IbuID,
// 			TanggalLahir:    &tanggalLahir,
// 			CreatedAt:       now,
// 			UpdatedAt:       now,
// 		}

// 		if err := s.db.Where("id = ?", anak.ID).FirstOrCreate(&anak).Error; err != nil {
// 			return err
// 		}
// 	}

// 	return nil
// }

// func (s *DummyKIADataSeeder) seedPemeriksaanKehamilan(now time.Time) error {
// 	rows := []struct {
// 		ID           int32
// 		KehamilanID  int32
// 		Trimester    string
// 		KunjunganKe  int32
// 		MingguKe     int32
// 		Tanggal      string
// 		Tempat       string
// 		Sistole      int32
// 		Diastole     int32
// 		StatusRisiko string
// 		SkorRisiko   int32
// 		DetailRisiko string
// 	}{
// 		{6001, 4001, "TRIMESTER 2", 3, 18, "2026-05-02", "Puskesmas Melati", 118, 76, "PERLU RUJUKAN", 18, "Riwayat anemia dan tekanan darah cenderung tinggi"},
// 		{6002, 4002, "TRIMESTER 1", 1, 10, "2026-04-15", "Puskesmas Melati", 112, 72, "NORMAL", 4, "ANC awal normal"},
// 		{6003, 4003, "TRIMESTER 3", 4, 34, "2026-05-06", "Puskesmas Melati", 126, 84, "PERLU TINDAKAN", 14, "Perlu pemantauan tekanan darah dan nutrisi"},
// 		{6004, 4004, "TRIMESTER 2", 2, 16, "2026-05-08", "Posyandu Kenanga", 116, 74, "NORMAL", 6, "Kondisi ibu stabil"},
// 	}

// 	for _, item := range rows {
// 		tanggal, err := time.Parse("2006-01-02", item.Tanggal)
// 		if err != nil {
// 			return err
// 		}

// 		pemeriksaan := models.PemeriksaanKehamilan{
// 			IDPeriksa:              item.ID,
// 			KehamilanID:            item.KehamilanID,
// 			Trimester:              item.Trimester,
// 			KunjunganKe:            item.KunjunganKe,
// 			MingguKehamilan:        item.MingguKe,
// 			TanggalPeriksa:         &tanggal,
// 			TempatPeriksa:          item.Tempat,
// 			Sistole:                item.Sistole,
// 			Diastole:               item.Diastole,
// 			StatusImunisasiTetanus: "Lengkap",
// 			Konseling:              "Konseling gizi, tanda bahaya, dan rencana persalinan",
// 			SkriningDokter:         "Tidak ada keluhan gawat",
// 			TesLabHb:               float64Ptr(10.8),
// 			TesGolonganDarah:       "A",
// 			TesLabProteinUrine:     "Negatif",
// 			USG:                    "Janin tunggal, aktif",
// 			TripelEliminasi:        "Negatif",
// 			TataLaksanaKasus:       "Lanjut kontrol rutin",
// 			SkorRisiko:             item.SkorRisiko,
// 			StatusRisiko:           item.StatusRisiko,
// 			DetailRisiko:           item.DetailRisiko,
// 			CreatedAt:              now,
// 		}

// 		if err := s.db.Where("id_periksa = ?", pemeriksaan.IDPeriksa).FirstOrCreate(&pemeriksaan).Error; err != nil {
// 			return err
// 		}
// 	}

// 	return nil
// }

// func (s *DummyKIADataSeeder) seedCatatanPertumbuhan(now time.Time) error {
// 	rows := []struct {
// 		ID            int32
// 		AnakID        int32
// 		TglUkur       string
// 		BeratBadan    float64
// 		TinggiBadan   float64
// 		LingkarKepala float64
// 		HasilLila     float64
// 		IMT           float64
// 		StatusBBU     string
// 		StatusTBU     string
// 		StatusIMTU    string
// 		StatusBBTB    string
// 		StatusLKU     string
// 		ZScoreBBU     float64
// 		ZScoreTBU     float64
// 		ZScoreIMTU    float64
// 		ZScoreBBTB    float64
// 		ZScoreLKU     float64
// 		UsiaUkurBulan int
// 		CatatanNakes  string
// 	}{
// 		{7001, 5001, "2026-03-01", 8.0, 71.0, 44.0, 13.4, 15.87, "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL", 0.2, 0.1, 0.0, 0.2, 0.1, 16, "Pertumbuhan sesuai usia"},
// 		{7002, 5001, "2026-05-01", 8.6, 73.0, 45.0, 13.8, 16.14, "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL", 0.1, 0.0, 0.0, 0.1, 0.0, 18, "Meningkat baik"},
// 		{7003, 5002, "2026-03-05", 7.4, 69.0, 43.5, 12.9, 15.54, "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL", -0.2, -0.1, 0.0, -0.2, -0.1, 7, "Pemantauan rutin"},
// 		{7004, 5002, "2026-05-05", 7.9, 71.0, 44.0, 13.1, 15.68, "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL", -0.1, 0.0, 0.0, -0.1, 0.0, 9, "Kondisi stabil"},
// 		{7005, 5003, "2026-03-20", 7.8, 70.0, 43.8, 13.0, 15.92, "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL", 0.0, 0.0, 0.0, 0.0, 0.0, 14, "Perkembangan baik"},
// 		{7006, 5003, "2026-05-20", 8.2, 72.0, 44.2, 13.4, 15.82, "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL", 0.1, 0.0, 0.0, 0.1, 0.0, 16, "LILA dan BB naik"},
// 		{7007, 5004, "2026-04-01", 8.1, 70.5, 44.1, 13.2, 16.31, "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL", 0.0, 0.0, 0.0, 0.0, 0.0, 12, "Kontrol awal"},
// 		{7008, 5004, "2026-05-12", 8.7, 72.2, 44.6, 13.7, 16.69, "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL", 0.2, 0.1, 0.0, 0.2, 0.1, 14, "Naik baik"},
// 	}

// 	for _, item := range rows {
// 		tglUkur, err := time.Parse("2006-01-02", item.TglUkur)
// 		if err != nil {
// 			return err
// 		}

// 		catatan := models.CatatanPertumbuhan{
// 			ID:            item.ID,
// 			AnakID:        item.AnakID,
// 			TglUkur:       tglUkur,
// 			BeratBadan:    item.BeratBadan,
// 			TinggiBadan:   item.TinggiBadan,
// 			LingkarKepala: item.LingkarKepala,
// 			HasilLila:     item.HasilLila,
// 			IMT:           item.IMT,
// 			StatusBBU:     item.StatusBBU,
// 			StatusTBU:     item.StatusTBU,
// 			StatusIMTU:    item.StatusIMTU,
// 			StatusBBTB:    item.StatusBBTB,
// 			StatusLKU:     item.StatusLKU,
// 			ZScoreBBU:     item.ZScoreBBU,
// 			ZScoreTBU:     item.ZScoreTBU,
// 			ZScoreIMTU:    item.ZScoreIMTU,
// 			ZScoreBBTB:    item.ZScoreBBTB,
// 			ZScoreLKU:     item.ZScoreLKU,
// 			UsiaUkurBulan: item.UsiaUkurBulan,
// 			CatatanNakes:  item.CatatanNakes,
// 			CreatedAt:     now,
// 			UpdatedAt:     now,
// 		}

// 		if err := s.db.Where("id = ?", catatan.ID).FirstOrCreate(&catatan).Error; err != nil {
// 			return err
// 		}
// 	}

// 	return nil
// }

// func int32Ptr(value int32) *int32 { return &value }

// func float64Ptr(value float64) *float64 { return &value }
