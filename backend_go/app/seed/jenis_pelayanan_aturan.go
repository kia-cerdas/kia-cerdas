package seed

import (
	"log"
	"monitoring-service/app/models"

	"gorm.io/gorm"
)

func SeederAturanPelayanan(db *gorm.DB, pelayanan map[string]int32) (map[string]int32, error) {
	log.Println("🌱 Seed: aturan pelayanan...")

	result := make(map[string]int32)

	type tempAturan struct {
		PelayananNama string
		UmurMinBulan  int
		UmurMaxBulan  int
		Bulan         int
	}

	dataRaw := []tempAturan{
		// =========================
		// VITAMIN A BIRU (6–11 bulan)
		// =========================
		{PelayananNama: "VIT A KAPSUL BIRU(100.000 IU)", UmurMinBulan: 6, UmurMaxBulan: 11, Bulan: 2},
		{PelayananNama: "VIT A KAPSUL BIRU(100.000 IU)", UmurMinBulan: 6, UmurMaxBulan: 11, Bulan: 8},

		// =========================
		// VITAMIN A MERAH (12–59 bulan)
		// =========================
		{PelayananNama: "VIT A KAPSUL MERAH(200.000 IU)", UmurMinBulan: 12, UmurMaxBulan: 59, Bulan: 2},
		{PelayananNama: "VIT A KAPSUL MERAH(200.000 IU)", UmurMinBulan: 12, UmurMaxBulan: 59, Bulan: 8},

		// =========================
		// OBAT CACING (12–59 bulan)
		// =========================
		{PelayananNama: "Obat Cacing", UmurMinBulan: 12, UmurMaxBulan: 59, Bulan: 0},

		// imunisasi
		{PelayananNama: "Hepatitis B (<24 Jam)", UmurMinBulan: 0, UmurMaxBulan: 1, Bulan: 0},
		{PelayananNama: "BCG", UmurMinBulan: 0, UmurMaxBulan: 11, Bulan: 1},
		{PelayananNama: "Polio tetes 1", UmurMinBulan: 0, UmurMaxBulan: 11, Bulan: 1},
		{PelayananNama: "DPT-HB-Hib 1", UmurMinBulan: 2, UmurMaxBulan: 11, Bulan: 2},
		{PelayananNama: "Polio tetes 2", UmurMinBulan: 2, UmurMaxBulan: 11, Bulan: 2},
		{PelayananNama: "Rotavirus (RV)1", UmurMinBulan: 2, UmurMaxBulan: 6, Bulan: 2},
		{PelayananNama: "PCV 1", UmurMinBulan: 2, UmurMaxBulan: 11, Bulan: 2},
		{PelayananNama: "DPT-HB-Hib 2", UmurMinBulan: 3, UmurMaxBulan: 11, Bulan: 3},
		{PelayananNama: "Polio tetes 3", UmurMinBulan: 3, UmurMaxBulan: 11, Bulan: 3},
		{PelayananNama: "Rotavirus (RV)2", UmurMinBulan: 3, UmurMaxBulan: 6, Bulan: 3},
		{PelayananNama: "PCV 2", UmurMinBulan: 3, UmurMaxBulan: 11, Bulan: 3},
		{PelayananNama: "DPT-HB-Hib 3", UmurMinBulan: 4, UmurMaxBulan: 11, Bulan: 4},
		{PelayananNama: "Polio tetes 4", UmurMinBulan: 4, UmurMaxBulan: 11, Bulan: 4},
		{PelayananNama: "Polio Suntik (IPV) 1", UmurMinBulan: 4, UmurMaxBulan: 11, Bulan: 4},
		{PelayananNama: "Rotavirus (RV) 3", UmurMinBulan: 4, UmurMaxBulan: 6, Bulan: 4},
		{PelayananNama: "Campak -Rubella (MR)", UmurMinBulan: 9, UmurMaxBulan: 11, Bulan: 9},
		{PelayananNama: "Polio Suntik (IPV) 2", UmurMinBulan: 9, UmurMaxBulan: 11, Bulan: 9},
		{PelayananNama: "Japanese Encephalitis (JE)", UmurMinBulan: 10, UmurMaxBulan: 10, Bulan: 10},
		{PelayananNama: "PCV3", UmurMinBulan: 12, UmurMaxBulan: 10, Bulan: 12},
		{PelayananNama: "DPT-HB-Hib Lanjutan", UmurMinBulan: 18, UmurMaxBulan: 23, Bulan: 18},
		{PelayananNama: "Campak Rubella (MR) Lanjutan", UmurMinBulan: 18, UmurMaxBulan: 23, Bulan: 18},
	}

	for _, item := range dataRaw {
		pID, ok := pelayanan[item.PelayananNama]
		if !ok {
			log.Printf("⚠️ Pelayanan '%s' tidak ditemukan untuk aturan pelayanan", item.PelayananNama)
			continue
		}

		aturan := models.AturanPelayanan{
			JenisPelayananID: pID,
			UmurMinBulan:     item.UmurMinBulan,
			UmurMaxBulan:     item.UmurMaxBulan,
			Bulan:            item.Bulan,
		}

		err := db.Where(
			"jenis_pelayanan_id = ? AND umur_min_bulan = ? AND umur_max_bulan = ? AND bulan = ?",
			aturan.JenisPelayananID,
			aturan.UmurMinBulan,
			aturan.UmurMaxBulan,
			aturan.Bulan,
		).FirstOrCreate(&aturan).Error

		if err != nil {
			return nil, err
		}
	}

	log.Println("✅ Seeder Aturan Pelayanan selesai")
	return result, nil
}