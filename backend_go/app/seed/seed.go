package seed

import (
	"log"

	"monitoring-service/app/seeders"

	"gorm.io/gorm"
)

func RunAllSeed(db *gorm.DB) error {
	return db.Transaction(func(tx *gorm.DB) error {

		log.Println("🚀 Start seeding...")

		// 1. Role
		if err := SeederRole(tx); err != nil {
			log.Println("❌ SeederRole failed:", err)
			return err
		}

		// 2. Kategori Umur
		kategoriMap, err := SeederKategoriUmur(tx)
		if err != nil {
			log.Println("❌ SeederKategoriUmur failed:", err)
			return err
		}

		// 3. Periode
		periodeMap, err := SeederPeriode(tx, kategoriMap)
		if err != nil {
			log.Println("❌ SeederPeriode failed:", err)
			return err
		}

		// 4. Jenis Pelayanan
		pelayananMap, err := SeederJenisPelayanan(tx)
		if err != nil {
			log.Println("❌ SeederJenisPelayanan failed:", err)
			return err
		}

		// 5. Aturan Pelayanan (passing pelayananMap dynamically)
		aturanMap, err := SeederAturanPelayanan(tx, pelayananMap)
		if err != nil {
			log.Println("❌ SeederAturanPelayanan failed:", err)
			return err
		}

		// 6. Mapping
		if err := SeederMapping(tx, kategoriMap, pelayananMap, periodeMap, aturanMap); err != nil {
			log.Println("❌ SeederMapping failed:", err)
			return err
		}

		// 7. Kategori Capaian Perkembangan Anak
		if err := SeederKategoriCapaian(tx); err != nil {
			log.Println("❌ SeederKategoriCapaian failed:", err)
			return err
		}

		// 8. Standard Anthropometry (from seeders package)
		if err := seeders.NewMasterStandarBBUSeeder(tx).Seed(); err != nil {
			log.Println("❌ MasterStandarBBUSeeder failed:", err)
			return err
		}
		if err := seeders.NewMasterStandarTBUSeeder(tx).Seed(); err != nil {
			log.Println("❌ MasterStandarTBUSeeder failed:", err)
			return err
		}
		if err := seeders.NewMasterStandarIMTUSeeder(tx).Seed(); err != nil {
			log.Println("❌ MasterStandarIMTUSeeder failed:", err)
			return err
		}
		if err := seeders.NewMasterStandarBBTBSeeder(tx).Seed(); err != nil {
			log.Println("❌ MasterStandarBBTBSeeder failed:", err)
			return err
		}
		if err := seeders.NewMasterStandarLKUSeeder(tx).Seed(); err != nil {
			log.Println("❌ MasterStandarLKUSeeder failed:", err)
			return err
		}

		log.Println("✅ All seeding success")
		return nil
	})
}
