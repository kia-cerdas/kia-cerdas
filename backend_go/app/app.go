package app

import (
	"fmt"
	"log"
	"monitoring-service/app/controllers"

	// "strings"

	"time"

	// "monitoring-service/app/models"
	"monitoring-service/app/repositories"
	"monitoring-service/app/routes"

	// "monitoring-service/app/seed"
	// "monitoring-service/app/seeders"
	"monitoring-service/app/usecases"
	"monitoring-service/pkg/config"
	"monitoring-service/pkg/database"

	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	"github.com/robfig/cron/v3"
	"github.com/spf13/viper"
	"gorm.io/gorm"
)

type Main struct {
	cfg        *config.Config
	database   Database
	repo       *repositories.Main
	usecase    *usecases.Main
	controller *controllers.Main
	router     *echo.Echo
	cron       *cron.Cron
}

type Database struct {
	MySQL    *gorm.DB
	Postgres *gorm.DB
}

func New() *Main {
	return new(Main)
}
func (m *Main) startCronJob() {
	// Asumsikan usecase.KehamilanUsecase memiliki method UpdateAllActiveGestationalAge()
	kehamilanUC := m.usecase.Kehamilan // atau m.usecase.KehUsecase, sesuaikan dengan field di usecases.Main

	c := cron.New(cron.WithLocation(time.Local))
	// Jadwalkan setiap hari jam 01:00
	_, err := c.AddFunc("0 1 * * *", func() {

		log.Println("[CRON] Start daily jobs...")

		// 1. update kehamilan
		if err := kehamilanUC.UpdateAllActiveGestationalAge(); err != nil {
			log.Printf("[CRON] kehamilan error: %v", err)
		}
		// 42 Update status jadwal imunisasi
		if err := m.usecase.UpdateStatusJadwal(); err != nil {
			log.Printf("[CRON] update status jadwal imunisasi error: %v", err)
		} else {
			log.Println("[CRON] update status jadwal imunisasi selesai")
		}

		// 3. reminder imunisasi
		if err := m.usecase.ProcessReminder(); err != nil {
			log.Printf("[CRON] reminder error: %v", err)
		} else {
			log.Println("[CRON] reminder selesai")
		}

		// 4. Reminder kontrol pemeriksaan kehamilan
		if err := m.usecase.ProcessKontrolReminder(); err != nil {
			log.Printf("[CRON] reminder kontrol error: %v", err)
		} else {
			log.Println("[CRON] reminder kontrol selesai")
		}

		// 5. Update status & kirim notifikasi kunjungan imunisasi
		if err := m.usecase.ProcessKunjunganImunisasiCron(); err != nil {
			log.Printf("[CRON] kunjungan imunisasi cron error: %v", err)
		} else {
			log.Println("[CRON] kunjungan imunisasi cron selesai")
		}

		// 6. Reminder jadwal posyandu H-3
		if err := m.usecase.ProcessPosyanduReminder(); err != nil {
			log.Printf("[CRON] posyandu reminder error: %v", err)
		} else {
			log.Println("[CRON] posyandu reminder selesai")
		}
	})
	if err != nil {
		log.Fatalf("[CRON] Gagal menjadwalkan job: %v", err)
	}

	c.Start()
	m.cron = c
	log.Println("[CRON] Scheduler berjalan (setiap hari pukul 01:00).")
}

func (m *Main) Init() (err error) {
	viper.SetConfigFile(".env")
	err = viper.ReadInConfig()
	if err != nil {
		return
	}
	m.cfg = config.NewConfig()

	e := echo.New()

	// Middleware
	e.Use(middleware.Logger())
	e.Use(middleware.Recover())
	e.Use(middleware.CORS())

	m.database.Postgres, err = database.GetConnection(m.cfg.Postgres().Read.ToArgs(database.Postgres, database.ReadConn, nil))

	if err != nil {
		panic("❌ Gagal konek ke database: " + err.Error())
	}
	fmt.Println("✅ BERHASIL KONEK KE DATABASE")

	// Patch kolom yang terlalu pendek (one-time idempotent fix)
	fixQueries := []string{
		`ALTER TABLE prediksi_stunting ALTER COLUMN status_tbu TYPE varchar(100)`,
		`ALTER TABLE prediksi_stunting ALTER COLUMN status_prediksi TYPE varchar(50)`,
		`ALTER TABLE prediksi_stunting ALTER COLUMN classification TYPE varchar(30)`,
		`ALTER TABLE aturan_porsi_mpasi ADD COLUMN IF NOT EXISTS gambar_url text`,
		`ALTER TABLE jadwal_harian_mpasi ADD COLUMN IF NOT EXISTS gambar_url text`,
	}
	for _, q := range fixQueries {
		if execErr := m.database.Postgres.Exec(q).Error; execErr != nil {
			// Abaikan error jika kolom tidak ada atau sudah sesuai
			fmt.Printf("[MIGRATION] Skipped: %v\n", execErr)
		} else {
			fmt.Printf("[MIGRATION] OK: %s\n", q)
		}
	}

	// // Migrate only the specific tables needed to ensure rentang_usia_id exists
	// _ = m.database.Postgres.AutoMigrate(&models.RentangUsia{}, &models.KategoriCapaian{})

	// // Sync sequences and map rentang_usia text to rentang_usia_id
	// fixKategoriCapaianData(m.database.Postgres)

	// // Migrate Tabel
	// err = models.AutoMigrate(m.database.Postgres)
	// if err != nil {
	// 	return
	// }
	// // Seeder
	// err = seed.RunAllSeed(m.database.Postgres)
	// if err != nil {
	// 	return
	// }

	// SEEDER setelah migrate
	// seeder kependudukan + anak
	// kependudukanSeeder := seeders.NewKependudukanSeeder(m.database.Postgres)
	// if err := kependudukanSeeder.Seed(); err != nil {
	// 	return err
	// }

	// // seeder master standar TBU
	// masterTBUSeeder := seeders.NewMasterStandarTBUSeeder(m.database.Postgres)
	// if err := masterTBUSeeder.Seed(); err != nil {
	// 	return err
	// }
	// masterBBTBSeeder := seeders.NewMasterStandarBBTBSeeder(m.database.Postgres)
	// if err := masterBBTBSeeder.Seed(); err != nil {
	// 	return err
	// }
	// masterBBUSeeder := seeders.NewMasterStandarBBUSeeder(m.database.Postgres)
	// if err := masterBBUSeeder.Seed(); err != nil {
	// 	return err
	// }
	// masterIMTUSeeder := seeders.NewMasterStandarIMTUSeeder(m.database.Postgres)
	// if err := masterIMTUSeeder.Seed(); err != nil {
	// 	return err
	// }
	// masterLKUSeeder := seeders.NewMasterStandarLKUSeeder(m.database.Postgres)
	// if err := masterLKUSeeder.Seed(); err != nil {
	// 	return err
	// }
	// kategoriCapaianSeeder := seeders.NewKategoriCapaianSeeder(m.database.Postgres)
	// if err := kategoriCapaianSeeder.Seed(); err != nil {
	// 	return err
	// }
	// kategoriCapaianSeeder := seeders.NewKategoriCapaianSeeder(m.database.Postgres)
	// if err := kategoriCapaianSeeder.Seed(); err != nil {
	// 	return err
	// }

	m.repo = repositories.Init(repositories.Options{
		Config:   m.cfg,
		Postgres: m.database.Postgres,
	})
	m.usecase = usecases.Init(usecases.Options{
		Config:     m.cfg,
		Repository: m.repo,
	})
	m.controller = controllers.Init(controllers.Options{
		Config:   m.cfg,
		UseCases: m.usecase,
		DB:       m.database.Postgres,
	})

	m.router = e
	go m.startCronJob()

	routes.ConfigureRouter(e, m.controller)
	return err
}

func (m *Main) Run() (err error) {
	defer m.close()

	fmt.Println("PORT:", m.cfg.ServicePort)

	addr := ":" + m.cfg.ServicePort
	fmt.Println("Starting server on", addr)

	err = m.router.Start(addr)
	return
}

func (m *Main) close() {
	if m.database.MySQL != nil {
		if db, err := m.database.MySQL.DB(); err == nil {
			db.Close()
		}
	}

	if m.database.Postgres != nil {
		if db, err := m.database.Postgres.DB(); err == nil {
			db.Close()
		}
	}
}

// func fixKategoriCapaianData(db *gorm.DB) {
// 	log.Println("[MIGRATION] Memulai sinkronisasi data rentang_usia_id di kategori_capaian...")

// 	// 1. Sinkronkan sequence kategori_capaian_id_seq agar tidak terjadi duplicate key error
// 	if err := db.Exec("SELECT setval('kategori_capaian_id_seq', COALESCE((SELECT MAX(id) FROM kategori_capaian), 1))").Error; err != nil {
// 		log.Println("[MIGRATION] Gagal sinkronisasi sequence ID:", err)
// 	} else {
// 		log.Println("[MIGRATION] Sukses sinkronisasi sequence kategori_capaian_id_seq.")
// 	}

// 	// 2. Hubungkan data string rentang_usia di kategori_capaian ke rentang_usia_id
// 	type KategoriCapaianTmp struct {
// 		ID            uint
// 		RentangUsia   string // kolom string rentang_usia bawaan DB
// 		RentangUsiaID uint   // kolom integer rentang_usia_id
// 	}

// 	var list []KategoriCapaianTmp
// 	if err := db.Table("kategori_capaian").Find(&list).Error; err != nil {
// 		log.Println("[MIGRATION] Gagal membaca data kategori_capaian:", err)
// 		return
// 	}

// 	var rentangs []models.RentangUsia
// 	if err := db.Find(&rentangs).Error; err != nil {
// 		log.Println("[MIGRATION] Gagal mengambil data rentang_usia:", err)
// 		return
// 	}

// 	importHelper := func(capaianUsia, rentangNama string) bool {
// 		c := strings.ToLower(strings.TrimSpace(capaianUsia))
// 		r := strings.ToLower(strings.TrimSpace(rentangNama))
// 		if strings.Contains(r, c) {
// 			return true
// 		}
// 		// Konversi khusus bulan ke tahun
// 		if c == "24-36" && (strings.Contains(r, "2-3") || strings.Contains(r, "2 - 3")) {
// 			return true
// 		}
// 		if c == "36-48" && (strings.Contains(r, "3-4") || strings.Contains(r, "3 - 4")) {
// 			return true
// 		}
// 		if c == "48-60" && (strings.Contains(r, "4-5") || strings.Contains(r, "4 - 5")) {
// 			return true
// 		}
// 		if c == "60-72" && (strings.Contains(r, "5-6") || strings.Contains(r, "5 - 6")) {
// 			return true
// 		}
// 		return false
// 	}

// 	updated := 0
// 	for _, item := range list {
// 		// Cari matching rentang_usia
// 		var matchedID uint = 0
// 		for _, r := range rentangs {
// 			if importHelper(item.RentangUsia, r.NamaRentang) {
// 				matchedID = r.ID
// 				break
// 			}
// 		}

// 		if matchedID > 0 {
// 			err := db.Table("kategori_capaian").Where("id = ?", item.ID).Update("rentang_usia_id", matchedID).Error
// 			if err != nil {
// 				log.Printf("[MIGRATION] Gagal update rentang_usia_id untuk ID %d: %v\n", item.ID, err)
// 			} else {
// 				updated++
// 			}
// 		}
// 	}
// 	log.Printf("[MIGRATION] Berhasil mengupdate %d/%d data rentang_usia_id di kategori_capaian.\n", updated, len(list))
// }
