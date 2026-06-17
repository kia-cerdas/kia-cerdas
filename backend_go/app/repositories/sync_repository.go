package repositories

import (
	"context"
	"errors"
	"monitoring-service/app/models"


	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type SyncRepository interface {
	ProcessBulkSync(ctx context.Context, req models.SyncPushRequest) error
	GetBulkPullData(ctx context.Context) (map[string]interface{}, error)
}

type syncRepository struct {
	db *gorm.DB
}

func NewSyncRepository(db *gorm.DB) SyncRepository {
	return &syncRepository{db: db}
}

func (r *syncRepository) ProcessBulkSync(ctx context.Context, req models.SyncPushRequest) error {
	// 1. Mulai transaksi database database (Atomic)
	return r.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {

		// Helper internal untuk melakukan UPSERT dinamis per baris data
		upsertTable := func(tableName string, targetRows []map[string]interface{}, idColumn string) error {
			for _, row := range targetRows {
				// Bersihkan/buang key is_synced dari map lokal Flutter jika ada, 
				// karena di server cloud data ini sudah pasti sinkron
				delete(row, "is_synced")

				// Eksekusi klausa INSERT ... ON CONFLICT (id) DO UPDATE
				err := tx.Table(tableName).
					Clauses(clause.OnConflict{
						Columns:   []clause.Column{{Name: idColumn}},
						DoUpdates: clause.AssignmentColumns(getMapKeys(row)),
					}).Create(&row).Error
				if err != nil {
					return errors.New("gagal upsert tabel " + tableName + ": " + err.Error())
				}
			}
			return nil
		}

		// ====================================================================
		// HIERARKI EKSEKUSI (Urutan insert agar tidak melanggar Foreign Key)
		// ====================================================================
		
		// Level 1: Master Wilayah / Faskes dasar
		if err := upsertTable("desa", req.Desa, "id"); err != nil { return err }
		if err := upsertTable("puskesmas", req.Puskesmas, "id"); err != nil { return err }
		if err := upsertTable("posyandu", req.Posyandu, "id"); err != nil { return err }

		// Level 2: Struktur Keluarga & Kependudukan Dasar
		if err := upsertTable("kartu_keluarga", req.KartuKeluarga, "id"); err != nil { return err }
		if err := upsertTable("penduduk", req.Penduduk, "id"); err != nil { return err }
		if err := upsertTable("pengguna", req.Pengguna, "id"); err != nil { return err }
		if err := upsertTable("bidan", req.Bidan, "id"); err != nil { return err }
		if err := upsertTable("kader", req.Kader, "id"); err != nil { return err }

		// Level 3: Layanan Medis Ibu Hamil
		if err := upsertTable("ibu", req.Ibu, "id"); err != nil { return err }
		if err := upsertTable("kehamilan", req.Kehamilan, "id"); err != nil { return err }
		if err := upsertTable("pemeriksaan_kehamilan", req.PemeriksaanKehamilan, "id_periksa"); err != nil { return err }
		if err := upsertTable("evaluasi_kesehatan_ibu", req.EvaluasiKesehatanIbu, "id"); err != nil { return err }
		if err := upsertTable("pemeriksaan_dokter_trimester_1", req.PemeriksaanDokterTri1, "id_trimester1"); err != nil { return err }
		if err := upsertTable("pemeriksaan_dokter_trimester_3", req.PemeriksaanDokterTri3, "id_trimester3"); err != nil { return err }
		if err := upsertTable("pemeriksaan_lanjutan_trimester_3", req.PemeriksaanLanjutanTri3, "id_lanjutan_t3"); err != nil { return err }
		if err := upsertTable("catatan_pelayanan_trimester_1", req.CatatanPelayananTri1, "id_catatan"); err != nil { return err }
		if err := upsertTable("catatan_pelayanan_trimester_2", req.CatatanPelayananTri2, "id_catatan_t2"); err != nil { return err }
		if err := upsertTable("catatan_pelayanan_trimester_3", req.CatatanPelayananTri3, "id_catatan_t3"); err != nil { return err }
		if err := upsertTable("skrining_preeklampsia", req.SkriningPreeklampsia, "id"); err != nil { return err }
		if err := upsertTable("grafik_evaluasi_kehamilan", req.GrafikEvaluasiKehamilan, "id"); err != nil { return err }
		if err := upsertTable("grafik_peningkatan_bb", req.GrafikPeningkatanBB, "id"); err != nil { return err }
		if err := upsertTable("penjelasan_hasil_grafik", req.PenjelasanHasilGrafik, "id_penjelasan"); err != nil { return err }
		if err := upsertTable("rencana_persalinan", req.RencanaPersalinan, "id_rencana_persalinan"); err != nil { return err }
		if err := upsertTable("ringkasan_pelayanan_persalinan", req.RingkasanPelayananPersal, "id"); err != nil { return err }
		if err := upsertTable("riwayat_proses_melahirkan", req.RiwayatProsesMelahirkan, "id"); err != nil { return err }
		if err := upsertTable("keterangan_lahir", req.KeteranganLahir, "id"); err != nil { return err }
		if err := upsertTable("pelayanan_ibu_nifas", req.PelayananIbuNifas, "id"); err != nil { return err }
		if err := upsertTable("catatan_pelayanan_nifas", req.CatatanPelayananNifas, "id_catatan_nifas"); err != nil { return err }
		if err := upsertTable("checklist_pemantauan_ibu_nifas", req.ChecklistPemantauanNifas, "id"); err != nil { return err }
		if err := upsertTable("riwayat_kehamilan_lalu", req.RiwayatKehamilanLalu, "id_riwayat"); err != nil { return err }
		if err := upsertTable("rujukan", req.Rujukan, "id"); err != nil { return err }
		if err := upsertTable("log_ttd_mms", req.LogTtdMms, "id"); err != nil { return err }

		// Level 4: Layanan Medis Bayi / Anak Tumbuh Kembang
		if err := upsertTable("anak", req.Anak, "id"); err != nil { return err }
		if err := upsertTable("keluhan_anak", req.KeluhanAnak, "id"); err != nil { return err }
		if err := upsertTable("periksa_gigi", req.PeriksaGigi, "id"); err != nil { return err }
		if err := upsertTable("pengukuran_lila", req.PengukuranLila, "id"); err != nil { return err }
		if err := upsertTable("catatan_pertumbuhan", req.CatatanPertumbuhan, "id"); err != nil { return err }
		if err := upsertTable("jadwal_layanan", req.JadwalLayanan, "id"); err != nil { return err }
		if err := upsertTable("jadwal_imunisasi_anak", req.JadwalImunisasiAnak, "id"); err != nil { return err }
		if err := upsertTable("request_perubahan_imunisasi", req.RequestPerubahanImunisasi, "id"); err != nil { return err }

		// Jika baris kode sampai di sini tanpa error, GORM otomatis mengeksekusi COMMIT.
		// Jika ada error di tengah jalan, GORM otomatis mengeksekusi ROLLBACK.
		return nil
	})
}

// Fungsi pembantu mengekstrak nama kolom dari map key
func getMapKeys(m map[string]interface{}) []string {
	keys := make([]string, 0, len(m))
	for k := range m {
		keys = append(keys, k)
	}
	return keys
}

// Implementasikan method-nya di bawah
func (r *syncRepository) GetBulkPullData(ctx context.Context) (map[string]interface{}, error) {
	result := make(map[string]interface{})

	// Daftar seluruh tabel dinamis yang perlu di-pull oleh Flutter
	tables := []string{
		"desa", "puskesmas", "posyandu", "kartu_keluarga", "penduduk",
		"pengguna", "bidan", "kader", "ibu", "kehamilan", "pemeriksaan_kehamilan",
		"evaluasi_kesehatan_ibu", "pemeriksaan_dokter_trimester_1", "pemeriksaan_dokter_trimester_3",
		"pemeriksaan_lanjutan_trimester_3", "catatan_pelayanan_trimester_1", "catatan_pelayanan_trimester_2",
		"catatan_pelayanan_trimester_3", "skrining_preeklampsia", "grafik_evaluasi_kehamilan",
		"grafik_peningkatan_bb", "penjelasan_hasil_grafik", "rencana_persalinan",
		"ringkasan_pelayanan_persalinan", "riwayat_proses_melahirkan", "keterangan_lahir",
		"pelayanan_ibu_nifas", "catatan_pelayanan_nifas", "checklist_pemantauan_ibu_nifas",
		"riwayat_kehamilan_lalu", "rujukan", "log_ttd_mms", "anak", "keluhan_anak",
		"periksa_gigi", "pengukuran_lila", "catatan_pertumbuhan", "jadwal_layanan",
		"jadwal_imunisasi_anak", "request_perubahan_imunisasi",
	}

	// Tarik semua data dari masing-masing tabel secara dinamis
	for _, table := range tables {
		var rows []map[string]interface{}
		if err := r.db.WithContext(ctx).Table(table).Find(&rows).Error; err != nil {
			return nil, err
		}
		result[table] = rows
	}

	return result, nil
}