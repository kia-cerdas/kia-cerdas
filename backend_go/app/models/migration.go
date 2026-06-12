package models

import "gorm.io/gorm"

func AutoMigrate(db *gorm.DB) error {
	// Semua model database dalam satu slice
	models := []interface{}{
		// ==================== MASTER DATA ====================
		&Role{},
		&User{},
		&Desa{},
		&KartuKeluarga{},
		&Kependudukan{},
		&Bidan{},
		&Kader{},
		&KaderPosyandu{},
		&Posyandu{},

		// ==================== ANAK & PERTUMBUHAN ====================
		&Anak{},
		&Pertumbuhan{},
		&CatatanPertumbuhan{},
		&RentangUsia{},
		&KategoriUmur{},
		&KategoriTandaBahaya{},
		&KategoriTandaSakit{},
		&SkriningPemantauan{},

		// ==================== PELAYANAN ANAK ====================
		&JenisPelayanan{},
		&JenisPelayananKategori{},
		&AturanPelayanan{},
		&KunjunganAnak{},
		&CatatanPelayanan{},

		// ==================== PELAYANAN KESEHATAN SPESIFIK ANAK ====================
		&Neonatus{},
		&DetailPelayananNeonatus{},
		&PeriodeKunjungan{},
		&KunjunganGizi{},
		&KunjunganVitamin{},
		&DetailPelayananVitamin{},
		&KunjunganImunisasi{},
		&DetailPelayananImunisasi{},
		&KehadiranImunisasi{},
		&PeriksaGigi{},
		&ASI{},
		&MPASI{},

		// ==================== PEMANTAUAN & DETEKSI DINI ANAK ====================
		&DeteksiDiniPenyimpangan{},
		&PengukuranLila{},
		&LembarPemantauan{},
		&DetailPemantauan{},
		&Pemeriksaan{},
		&FormPertanyaan{},
		&FormAturanRisiko{},
		&PrediksiStunting{},

		// ==================== PERAWATAN ANAK ====================
		&KategoriCapaian{},
		&Perawatan{},
		&PemantauanIndikator{},

		// ==================== EDUKASI DIGITAL ====================
		&InformasiUmum{},
		&EdukasiInformasiUmum{},
		&EdukasiTrimester{},
		&EdukasiTandaMelahirkan{},
		&EdukasiIMD{},
		&EdukasiMenyusuiASI{},
		&EdukasiSetelahMelahirkan{},
		&EdukasiPolaAsuh{},
		&EdukasiKesehatanMental{},
		&EdukasiPerawatanAnak{},
		&MateriMPASI{},
		&AturanPorsiMPASI{},
		&JadwalHarianMPASI{},
		&ResepMPASI{},

		// ==================== PEMERIKSAAN UMUM (LINTAS USIA) ====================
		// &PemeriksaanAnak{},
		// &PemeriksaanRemaja{},
		// &PemeriksaanDewasa{},
		// &PemeriksaanLansia{},
		&Perangkat{},

		// ==================== IBU & KEHAMILAN ====================
		&Ibu{},
		&Kehamilan{},
		&PemeriksaanKehamilan{},
		&EvaluasiKesehatanIbu{},
		&PemeriksaanDokterTrimester1{},
		&PemeriksaanDokterTrimester3{},
		&PemeriksaanLaboratoriumJiwa{},
		&PemeriksaanLanjutanTrimester3{},
		&CatatanPelayananTrimester1{},
		&CatatanPelayananTrimester2{},
		&CatatanPelayananTrimester3{},

		// ==================== SKRINING IBU HAMIL ====================
		&SkriningPreeklampsia{},
		&SkriningDMGestasional{},

		// ==================== GRAFIK EVALUASI KEHAMILAN ====================
		&GrafikEvaluasiKehamilan{},
		&GrafikPeningkatanBB{},
		&PenjelasanHasilGrafik{},

		// ==================== RENCANA & PROSES PERSALINAN ====================
		&RencanaPersalinan{},
		&RingkasanPelayananPersalinan{},
		&RiwayatProsesMelahirkan{},
		&ProsesMelahirkan{},
		&KeteranganLahir{},

		// ==================== PELAYANAN IBU NIFAS ====================
		&PelayananIbuNifas{},
		&CatatanPelayananNifas{},
		&ChecklistPemantauanIbuNifas{},
		&WarnaTinjaAnak{},

		// ==================== RIWAYAT KEHAMILAN & RUJUKAN ====================
		&RiwayatKehamilanLalu{},
		&Rujukan{},

		// ==================== BBL (BAYI BARU LAHIR) ====================
		&Bbl{},
		&BblCheck{},

		// ==================== LAPORAN ====================
		&LaporanIbu{},
		&LaporanAnak{},

		// ==================== MODUL IBU ====================
		&LogTTDMMS{},
		&PemantauanIbuHamil{},
		&PersiapanMelahirkan{},
		&AbsensiKelasIbuHamil{},
		&AbsensiKelasIbuBalita{},

		// ==================== PEMANTAUAN IBU ====================
		&KategoriPemantauanIbu{},
		&LembarPemantauanIbu{},
		&DetailPemantauanIbu{},

		// ==================== IMUNISASI ====================
		&Vaksin{},
		&DosisVaksin{},
		&AturanVaksinAnak{},
		&JadwalImunisasiAnak{},
		&MasterImunisasi{},
		&RequestPerubahanImunisasi{},

		// ==================== JADWAL LAYANAN ====================
		&JadwalLayanan{},

		// ==================== STANDAR ANTROPOMETRI ====================
		&MasterStandarAntropometri{},

		// ==================== AUDIT TRAIL ====================
		&AuditTrail{},
	}

	// Jalankan automigrate
	if err := db.AutoMigrate(models...); err != nil {
		return err
	}

	return nil
}
