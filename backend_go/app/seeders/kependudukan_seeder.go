package seeders

import (
	"log"
	"monitoring-service/app/models"
	"time"

	"gorm.io/gorm"
)

type KependudukanSeeder struct {
	db *gorm.DB
}

func NewKependudukanSeeder(db *gorm.DB) *KependudukanSeeder {
	return &KependudukanSeeder{db: db}
}

func (s *KependudukanSeeder) Seed() error {
	log.Println("Starting kependudukan and anak seeding...")

	if err := s.seedKartuKeluarga(); err != nil {
		return err
	}

	// Seed kependudukan data
	if err := s.seedKependudukan(); err != nil {
		return err
	}

	// Seed ibu data
	if err := s.seedIbu(); err != nil {
		return err
	}

	// Seed anak data
	if err := s.seedAnak(); err != nil {
		return err
	}

	log.Println("Kependudukan and anak seeding completed!")
	return nil
}

func (s *KependudukanSeeder) seedKartuKeluarga() error {
	now := time.Now()

	list := []models.KartuKeluarga{
		{
			NoKK:      "3171234567890101",
			CreatedAt: now,
		},
		{
			NoKK:      "3171234567890102",
			CreatedAt: now,
		},
	}

	for _, item := range list {
		if err := s.db.Where("no_kk = ?", item.NoKK).FirstOrCreate(&item).Error; err != nil {
			log.Printf("Error seeding KartuKeluarga (NoKK: %s): %v\n", item.NoKK, err)
			return err
		}
	}

	return nil
}

func (s *KependudukanSeeder) seedKependudukan() error {
	now := time.Now()

	var kartuKeluargaList []models.KartuKeluarga
	if err := s.db.Where("no_kk IN ?", []string{"3171234567890101", "3171234567890102"}).Find(&kartuKeluargaList).Error; err != nil {
		return err
	}

	kkIDByNo := map[string]int64{}
	for _, kk := range kartuKeluargaList {
		kkIDByNo[kk.NoKK] = kk.ID
	}

	kk01ID, ok := kkIDByNo["3171234567890101"]
	if !ok {
		return gorm.ErrRecordNotFound
	}
	kk02ID, ok := kkIDByNo["3171234567890102"]
	if !ok {
		return gorm.ErrRecordNotFound
	}

	// Data contoh kependudukan (2 keluarga)
	nik1 := "3171234567890001"
	nik2 := "3171234567890002"
	nik3 := "3171234567890003"
	nik4 := "3171234567890004"
	nik5 := "3171234567890005"
	nik6 := "3171234567890011"
	nik7 := "3171234567890012"
	nik8 := "3171234567890013"
	nik9 := "3171234567890014"

	tanggalLahir1, _ := time.Parse("2006-01-02", "1990-05-10")
	tanggalLahir2, _ := time.Parse("2006-01-02", "1992-08-20")
	tanggalLahir3, _ := time.Parse("2006-01-02", "2020-10-15")
	tanggalLahir4, _ := time.Parse("2006-01-02", "2023-01-25")
	tanggalLahir5, _ := time.Parse("2006-01-02", "2025-12-09")
	tanggalLahir6, _ := time.Parse("2006-01-02", "1989-01-17")
	tanggalLahir7, _ := time.Parse("2006-01-02", "1991-04-03")
	tanggalLahir8, _ := time.Parse("2006-01-02", "2022-07-19")
	tanggalLahir9, _ := time.Parse("2006-01-02", "2024-11-01")

	kependudukanList := []models.Kependudukan{
		// Keluarga 1
		{
			KartuKeluargaID:    &kk01ID,
			NIK:                &nik1,
			NamaLengkap:        "Budi Santoso",
			JenisKelamin:       "Laki-laki",
			TanggalLahir:       tanggalLahir1,
			TempatLahir:        "Jakarta",
			GolonganDarah:      "O",
			Dusun:              "Mawar",
			Pekerjaan:          "Karyawan Swasta",
			PendidikanTerakhir: "S1",
			CreatedAt:          now,
			UpdatedAt:          now,
		},
		{
			KartuKeluargaID:    &kk01ID,
			NIK:                &nik2,
			NamaLengkap:        "Siti Aminah",
			JenisKelamin:       "Perempuan",
			TanggalLahir:       tanggalLahir2,
			TempatLahir:        "Bandung",
			GolonganDarah:      "A",
			Dusun:              "Mawar",
			Pekerjaan:          "Ibu Rumah Tangga",
			PendidikanTerakhir: "SMA",
			CreatedAt:          now,
			UpdatedAt:          now,
		},
		{
			KartuKeluargaID: &kk01ID,
			NIK:             &nik3,
			NamaLengkap:     "Ahmad Santoso",
			JenisKelamin:    "Laki-laki",
			TanggalLahir:    tanggalLahir3,
			TempatLahir:     "Jakarta",
			GolonganDarah:   "O",
			Dusun:           "Mawar",
			CreatedAt:       now,
			UpdatedAt:       now,
		},
		{
			KartuKeluargaID: &kk01ID,
			NIK:             &nik4,
			NamaLengkap:     "Rina Santoso",
			JenisKelamin:    "Perempuan",
			TanggalLahir:    tanggalLahir4,
			TempatLahir:     "Jakarta",
			GolonganDarah:   "A",
			Dusun:           "Mawar",
			CreatedAt:       now,
			UpdatedAt:       now,
		},
		{
			KartuKeluargaID: &kk01ID,
			NIK:             &nik5,
			NamaLengkap:     "Nahes Purba",
			JenisKelamin:    "Laki-laki",
			TanggalLahir:    tanggalLahir5,
			TempatLahir:     "Jakarta",
			GolonganDarah:   "A",
			Dusun:           "Luman Batu",
			CreatedAt:       now,
			UpdatedAt:       now,
		},
		// Keluarga 2
		{
			KartuKeluargaID:    &kk02ID,
			NIK:                &nik6,
			NamaLengkap:        "Andi Pratama",
			JenisKelamin:       "Laki-laki",
			TanggalLahir:       tanggalLahir6,
			TempatLahir:        "Jakarta",
			GolonganDarah:      "B",
			Dusun:              "Melati",
			Pekerjaan:          "Wiraswasta",
			PendidikanTerakhir: "S1",
			CreatedAt:          now,
			UpdatedAt:          now,
		},
		{
			KartuKeluargaID:    &kk02ID,
			NIK:                &nik7,
			NamaLengkap:        "Dewi Lestari",
			JenisKelamin:       "Perempuan",
			TanggalLahir:       tanggalLahir7,
			TempatLahir:        "Bogor",
			GolonganDarah:      "AB",
			Dusun:              "Melati",
			Pekerjaan:          "Ibu Rumah Tangga",
			PendidikanTerakhir: "SMA",
			CreatedAt:          now,
			UpdatedAt:          now,
		},
		{
			KartuKeluargaID: &kk02ID,
			NIK:             &nik8,
			NamaLengkap:     "Kania Pratama",
			JenisKelamin:    "Perempuan",
			TanggalLahir:    tanggalLahir8,
			TempatLahir:     "Jakarta",
			GolonganDarah:   "AB",
			Dusun:           "Melati",
			CreatedAt:       now,
			UpdatedAt:       now,
		},
		{
			KartuKeluargaID: &kk02ID,
			NIK:             &nik9,
			NamaLengkap:     "Rafi Pratama",
			JenisKelamin:    "Laki-laki",
			TanggalLahir:    tanggalLahir9,
			TempatLahir:     "Jakarta",
			GolonganDarah:   "B",
			Dusun:           "Melati",
			CreatedAt:       now,
			UpdatedAt:       now,
		},
	}

	for _, k := range kependudukanList {
		if err := s.db.Where("nik = ?", k.NIK).FirstOrCreate(&k).Error; err != nil {
			log.Printf("Error seeding Kependudukan (NIK: %s): %v\n", *k.NIK, err)
			return err
		}
	}

	return nil
}

func (s *KependudukanSeeder) seedIbu() error {
	ibuNikList := []string{"3171234567890002", "3171234567890012"}

	for _, ibuNik := range ibuNikList {
		var kepIbu models.Kependudukan
		if err := s.db.Where("nik = ?", ibuNik).First(&kepIbu).Error; err != nil {
			if err == gorm.ErrRecordNotFound {
				log.Printf("Kependudukan ibu dengan NIK %s tidak ditemukan, melewati seed Ibu\n", ibuNik)
				continue
			}
			return err
		}

		ibu := models.Ibu{IDKependudukan: kepIbu.IDKependudukan}

		if err := s.db.Where("penduduk_id = ?", kepIbu.IDKependudukan).FirstOrCreate(&ibu).Error; err != nil {
			log.Printf("Error seeding Ibu (IDKependudukan: %d): %v\n", kepIbu.IDKependudukan, err)
			return err
		}
	}

	return nil
}

func (s *KependudukanSeeder) seedAnak() error {
	// Anak model is now linked to Kehamilan, not directly to Ibu/Kependudukan
	// This seeder needs to be updated to work with the new Kehamilan-based structure
	log.Println("Anak seeder skipped - requires Kehamilan data structure")
	return nil
}
