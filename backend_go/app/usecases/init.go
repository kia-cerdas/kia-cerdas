package usecases

//AbsensiKelasIbuBalita//
import (
	"context"
	"fmt"
	"log"
	"os"

	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/messaging"
	"google.golang.org/api/option"

	"monitoring-service/app/repositories"
	"monitoring-service/pkg/config"
)

type Main struct {
	repository *repositories.Main
	config     *config.Config

	fcmClient *messaging.Client
	// Usecase yang sudah ada
	Anak                   *AnakUseCase
	PelayananKesehatanAnak PelayananKesehatanAnakUseCase
	Neonatus               NeonatusUsecase
	KunjunganGizi          KunjunganGiziUseCase
	KunjunganVitamin       KunjunganVitaminUseCase
	KunjunganImunisasi     KunjunganImunisasiUseCase
	PemeriksaanGigi        PemeriksaanGigiUseCase
	PemantauanPertumbuhan  PemantauanPertumbuhanAnakUseCase
	PengukuranLilA         PengukuranLilAUseCase
	CatatanPelayanan       CatatanPelayananUseCase
	InformasiUmum          InformasiUmumUsecase
	Kependudukan           KependudukanUsecase
	Kader                  KaderUsecase
	AuditTrail             *AuditTrailUsecase

	// Usecase baru terkait kehamilan
	// Usecase baru (terkait kehamilan)
	// KartuKeluarga
	Kehamilan                     KehamilanUsecase
	PemeriksaanKehamilan          PemeriksaanKehamilanUsecase
	EvaluasiKesehatanIbu          EvaluasiKesehatanIbuUsecase
	PemeriksaanDokterTrimester1   PemeriksaanDokterTrimester1Usecase
	PemeriksaanDokterTrimester3   PemeriksaanDokterTrimester3Usecase
	PemeriksaanLaboratoriumJiwa   PemeriksaanLaboratoriumJiwaUsecase
	PemeriksaanLanjutanTrimester3 PemeriksaanLanjutanTrimester3Usecase
	CatatanPelayananTrimester2    CatatanPelayananTrimester2Usecase
	CatatanPelayananNifas         CatatanPelayananNifasUsecase
	CatatanPelayananKehamilan     CatatanPelayananKehamilanUsecase
	// GrafikEvaluasiKehamilan       GrafikEvaluasiKehamilanUsecase
	GrafikPeningkatanBB          GrafikPeningkatanBBUsecase
	PenjelasanHasilGrafik        PenjelasanHasilGrafikUsecase
	RencanaPersalinan            RencanaPersalinanUsecase
	RingkasanPelayananPersalinan RingkasanPelayananPersalinanUsecase
	RiwayatProsesMelahirkan      RiwayatProsesMelahirkanUsecase
	Rujukan                      RujukanUsecase
	SkriningDMGestasional        SkriningDMGestasionalUsecase
	SkriningPreeklampsia         SkriningPreeklampsiaUsecase
	PelayananIbuNifas            PelayananIbuNifasUsecase
	Ibu                          IbuUsecase
	RiwayatKehamilanLalu         RiwayatKehamilanLaluUsecase
	// RegisterOrangTua              *RegisterOrangTuaUsecase
	AdminAkunKeluarga    *AdminAkunKeluargaUsecase
	AdminTenagaKesehatan *AdminTenagaKesehatanUsecase
	SuperadminUser       *SuperadminUserUsecase
	Desa                 DesaUsecase
	Wilayah              WilayahUsecase
	KeteranganLahir      KeteranganLahirUsecase
	Bbl                  BblUsecase
	JenisPelayanan       JenisPelayananUsecase
	KategoriUmur         KategoriUmurUsecase
	GejalaDaruratAnak    GejalaDaruratAnakUsecase

	// Usecase tambahan
	KeluhanAnak KeluhanAnakUseCase
	// KesehatanLingkungan KesehatanLingkunganUsecase
	// KesehatanLingkunganDanCatatanKader KesehatanLingkunganDanCatatanKaderUsecase
	PemantauanAnak      PemantauanAnakUseCase
	PemantauanIndikator PemantauanIndikatorUsecase

	// Perawatan Anak (Lembar Capaian)
	// KategoriCapaian KategoriCapaianUsecase

	// Edukasi Digital
	// EdukasiTandaBahayaTrimester EdukasiTandaBahayaTrimesterUsecase
	GrafikEvaluasiKehamilan GrafikEvaluasiKehamilanUsecase
	SkriningPemantauan      SkriningPemantauanUsecase
	KategoriTandaBahaya     KategoriTandaBahayaUsecase
	Perawatan               PerawatanUsecase

	// MODUL IBU
	LogTTDMMS                   LogTTDMMSUsecase
	PemantauanIbuHamil          PemantauanIbuHamilUsecase
	PersiapanMelahirkan         PersiapanMelahirkanUsecase
	ProsesMelahirkan            ProsesMelahirkanUsecase
	AbsensiKelasIbuHamil        AbsensiKelasIbuHamilUsecase
	AbsensiKelasIbuBalita       AbsensiKelasIbuBalitaUsecase
	ChecklistPemantauanIbuNifas *ChecklistPemantauanIbuNifasUsecase
	WarnaTinja                  WarnaTinjaUsecase
	EdukasiIMD                  EdukasiIMDUsecase
	EdukasiMenyusuiASI          EdukasiMenyusuiASIUsecase

	LembarPemantauan LembarPemantauanUsecase
	// RegisterOrangTua              *RegisterOrangTuaUsecase
	// AdminAkunKeluarga    *AdminAkunKeluargaUsecase
	// AdminTenagaKesehatan *AdminTenagaKesehatanUsecase
	// KeteranganLahir      KeteranganLahirUsecase // <-- TAMBAHKAN INI
	// JenisPelayanan       JenisPelayananUsecase
	EdukasiInformasiUmum     EdukasiInformasiUmumUsecase
	EdukasiTrimester         EdukasiTrimesterUsecase
	EdukasiTandaMelahirkan   EdukasiTandaMelahirkanUsecase
	EdukasiImd               EdukasiIMDUsecase
	EdukasiSetelahMelahirkan EdukasiSetelahMelahirkanUsecase
	EdukasiMenyusuiAsi       EdukasiMenyusuiASIUsecase
	EdukasiPolaAsuh          EdukasiPolaAsuhUsecase
	EdukasiKesehatanMental   EdukasiKesehatanMentalUsecase
	EdukasiPerawatanAnak     EdukasiPerawatanAnakUseCase
	EdukasiAturanPorsiMPASI  AturanPorsiMPASIUsecase
	EdukasiJadwalHarianMPASI JadwalHarianMPASIUsecase
	JadwalLayanan            JadwalLayananUsecase

	// Vaksin & Dosis Vaksin
	Vaksin      VaksinUsecase
	DosisVaksin DosisVaksinUsecase
	EdukasiResepMPASI        ResepMPASIUsecase
	// EdukasiTandaBahayaTrimester EdukasiTandaBahayaTrimesterUsecase
	LaporanIbu        LaporanIbuUsecase
	LaporanAnak       LaporanAnakUsecase
	LaporanBalita     LaporanBalitaUsecase 
	LaporanRemaja     LaporanRemajaUsecase
	LaporanDewasa     LaporanDewasaUsecase
	LaporanLansia     LaporanLansiaUsecase
	PrediksiStunting  PrediksiStuntingUsecase
	PendudukRisk      PendudukRiskUsecase
	RiwayatCard       RiwayatCardUsecase
	Pencatatan        PencatatanUsecase
	Form              FormUsecase
	Pemeriksaan       PemeriksaanUsecase
	EdukasiMPASI      EdukasiMPASIUsecase
	// Profile Ibu
	ProfilIbu ProfilIbuUsecase
	DetailKehamilanIbu DetailKehamilanIbuUsecase

	// Pencatatan Imunisasi (Web)
	PencatatanImunisasi *PencatatanImunisasiUsecase

	// Puskesmas Dashboard (multi-desa recap)
	PuskesmasDashboard PuskesmasDashboardUsecase

	// Ringkasan Desa (dashboard kader)
	RingkasanDesa RingkasanDesaUsecase
}

type Options struct {
	Repository *repositories.Main
	Config     *config.Config
}

func Init(opts Options) *Main {
	m := &Main{
		repository: opts.Repository,
		config:     opts.Config,
	}

	if _, err := os.Stat("firebase-service-account.json"); err == nil {
		opt := option.WithCredentialsFile("firebase-service-account.json")
		app, err := firebase.NewApp(
			context.Background(),
			nil,
			opt,
		)
		if err != nil {
			log.Printf("[FCM INIT] Firebase NewApp gagal: %v", err)
		} else {
			client, err := app.Messaging(
				context.Background(),
			)
			if err != nil {
				log.Printf("[FCM INIT] Messaging client gagal: %v", err)
			} else {
				log.Printf("[FCM INIT] Firebase berhasil diinisialisasi")
				m.fcmClient = client
			}
		}
	} else {
		log.Println("[FCM INIT] firebase-service-account.json tidak ditemukan, FCM dinonaktifkan")
	}

	//  BUAT PREDIKSI USECASE (panggil service Python)
	mlURL := "http://localhost:8001"
	if opts.Config != nil && opts.Config.MLServiceURL != "" {
		mlURL = opts.Config.MLServiceURL
	}
	prediksiUc := NewPrediksiRisikoUsecase(mlURL)
	// Inisialisasi usecase yang sudah ada
	m.Anak = NewAnakUseCase(opts.Repository.Anak, opts.Repository.Kependudukan, opts.Repository.PrediksiStunting, opts.Repository.Ibu)
	m.Anak.SetOnAnakCreated(func(anakID int32) {
		if err := m.GenerateJadwalImunisasiByAnakID(anakID); err != nil {
			fmt.Println("[AUTO JADWAL] ERROR:", err)
		}
	})
	m.Anak.SetOnAnakCreatedSync(func(anakID int32) error {
		return m.EnsurePrediksiForAnak(anakID)
	})
	m.PelayananKesehatanAnak = NewPelayananKesehatanAnakUseCase(opts.Repository.PelayananKesehatanAnak)
	m.Neonatus = NewPelayananNeonatusUseCase(opts.Repository.Neonatus)
	m.KunjunganGizi = NewKunjunganGiziUseCase(opts.Repository.KunjunganGizi)
	m.KunjunganVitamin = NewKunjunganVitaminUseCase(opts.Repository.KunjunganVitamin)
	m.KunjunganImunisasi = NewKunjunganImunisasiUseCase(opts.Repository.KunjunganImunisasi)
	m.PemeriksaanGigi = NewPemeriksaanGigiUseCase(opts.Repository.PemeriksaanGigi)
	m.PemantauanPertumbuhan = NewPemantauanPertumbuhanUseCase(opts.Repository.PemantauanPertumbuhan)
	m.PengukuranLilA = NewPengukuranLilAUseCase(opts.Repository.PengukuranLilA)
	m.CatatanPelayanan = NewCatatanPelayananUseCase(opts.Repository.CatatanPelayanan)
	m.InformasiUmum = NewInformasiUmumUsecase(opts.Repository.InformasiUmum)
	m.KategoriTandaBahaya = NewKategoriTandaBahayaUsecase(opts.Repository.KategoriTandaBahaya)

	// Inisialisasi usecase terkait kehamilan
	// Inisialisasi usecase baru
	// m.KartuKeluarga = NewKartuKeluargaUsecase(opts.Repository.KartuKeluarga)
	m.Kehamilan = NewKehamilanUsecase(opts.Repository.Kehamilan)
	m.PemeriksaanKehamilan = NewPemeriksaanKehamilanUsecase(opts.Repository.PemeriksaanKehamilan, opts.Repository.Kehamilan, prediksiUc)
	m.EvaluasiKesehatanIbu = NewEvaluasiKesehatanIbuUsecase(opts.Repository.EvaluasiKesehatanIbu)
	// di dalam func Init(opts Options) *Main
	// ...
	// ... setelah repository diinisialisasi
	m.PemeriksaanDokterTrimester1 = NewPemeriksaanDokterTrimester1Usecase(
		opts.Repository.PemeriksaanDokterTrimester1,
		opts.Repository.PemeriksaanLaboratoriumJiwa,
	)
	m.PemeriksaanDokterTrimester3 = NewPemeriksaanDokterTrimester3Usecase(
		opts.Repository.PemeriksaanDokterTrimester3,
		opts.Repository.PemeriksaanLaboratoriumJiwa,
	)
	m.PemeriksaanLaboratoriumJiwa = NewPemeriksaanLaboratoriumJiwaUsecase(opts.Repository.PemeriksaanLaboratoriumJiwa)
	m.PemeriksaanLanjutanTrimester3 = NewPemeriksaanLanjutanTrimester3Usecase(opts.Repository.PemeriksaanLanjutanTrimester3)
	m.CatatanPelayananTrimester2 = NewCatatanPelayananTrimester2Usecase(opts.Repository.CatatanPelayananTrimester2)
	m.CatatanPelayananNifas = NewCatatanPelayananNifasUsecase(opts.Repository.CatatanPelayananNifas)
	m.CatatanPelayananKehamilan = NewCatatanPelayananKehamilanUsecase(opts.Repository.CatatanPelayananKehamilan)
	m.GrafikEvaluasiKehamilan = NewGrafikEvaluasiKehamilanUsecase(opts.Repository.GrafikEvaluasiKehamilan, opts.Repository.Kehamilan)
	m.GrafikPeningkatanBB = NewGrafikPeningkatanBBUsecase(opts.Repository.GrafikPeningkatanBB, opts.Repository.Kehamilan)
	m.PenjelasanHasilGrafik = NewPenjelasanHasilGrafikUsecase(opts.Repository.PenjelasanHasilGrafik)
	m.RencanaPersalinan = NewRencanaPersalinanUsecase(opts.Repository.RencanaPersalinan)
	m.RingkasanPelayananPersalinan = NewRingkasanPelayananPersalinanUsecase(opts.Repository.RingkasanPelayananPersalinan)
	m.RiwayatProsesMelahirkan = NewRiwayatProsesMelahirkanUsecase(opts.Repository.RiwayatProsesMelahirkan)
	m.Rujukan = NewRujukanUsecase(opts.Repository.Rujukan)
	m.SkriningDMGestasional = NewSkriningDMGestasionalUsecase(opts.Repository.SkriningDMGestasional)
	m.SkriningPreeklampsia = NewSkriningPreeklampsiaUsecase(opts.Repository.SkriningPreeklampsia)
	// m.SkriningPemantauan = NewSkriningPemantauanUsecase(opts.Repository.SkriningPemantauan)
	m.PelayananIbuNifas = NewPelayananIbuNifasUsecase(opts.Repository.PelayananIbuNifas)
	m.Ibu = NewIbuUsecase(opts.Repository.Ibu, opts.Repository.Kependudukan)
	m.RiwayatKehamilanLalu = NewRiwayatKehamilanLaluUsecase(opts.Repository.RiwayatKehamilanLalu)
	m.LembarPemantauan = NewLembarPemantauanUsecase(opts.Repository.LembarPemantauan)
	m.Kependudukan = NewKependudukanUsecase(opts.Repository.Kependudukan)
	m.Kader = NewKaderUsecase(opts.Repository.Kader, opts.Repository.Kependudukan)
	m.KeteranganLahir = NewKeteranganLahirUsecase(opts.Repository.KeteranganLahir)
	m.Bbl = NewBblUsecase(opts.Repository.Bbl)
	m.Perawatan = NewPerawatanUsecase(opts.Repository)
	// m.RegisterOrangTua = NewRegisterOrangTuaUsecase(
	// 	opts.Repository.User,
	// 	opts.Repository.Role,
	// 	opts.Repository.KartuKeluarga,
	// 	opts.Repository.Kependudukan,
	// 	opts.Repository.Ibu,
	// )
	m.AdminAkunKeluarga = NewAdminAkunKeluargaUsecase(
		opts.Repository.Kependudukan,
	)
	m.AdminTenagaKesehatan = NewAdminTenagaKesehatanUsecase(
		opts.Repository.Bidan,
		opts.Repository.Kader,
		opts.Repository.Kependudukan,
		opts.Repository.User,
		opts.Repository.Role,
	)
	m.SuperadminUser = NewSuperadminUserUsecase(opts.Repository)
	m.Desa = NewDesaUsecase(opts.Repository.Desa, opts.Repository.Wilayah)
	m.Wilayah = NewWilayahUsecase(opts.Repository.Wilayah)
	m.KeteranganLahir = NewKeteranganLahirUsecase(opts.Repository.KeteranganLahir)
	m.JenisPelayanan = NewJenisPelayananUsecase(opts.Repository.JenisPelayanan)
	m.KeluhanAnak = NewKeluhanAnakUseCase(opts.Repository.KeluhanAnak)
	m.KategoriUmur = NewKategoriUmurUsecase(opts.Repository.KategoriUmur)
	m.GejalaDaruratAnak = NewGejalaDaruratAnakUsecase(opts.Repository.GejalaDaruratAnak)

	// Usecase tambahan
	m.KeluhanAnak = NewKeluhanAnakUseCase(opts.Repository.KeluhanAnak)
	// m.KesehatanLingkungan = NewKesehatanLingkunganUsecase(opts.Repository.KesehatanLingkungan)
	// m.KesehatanLingkunganDanCatatanKader = NewKesehatanLingkunganDanCatatanKaderUsecase(opts.Repository.KesehatanLingkunganDanCatatanKader)
	m.PemantauanAnak = NewPemantauanAnakUseCase(opts.Repository.PemantauanAnak)
	m.PemantauanIndikator = NewPemantauanIndikatorUsecase(opts.Repository.PemantauanIndikator)
	m.AuditTrail = NewAuditTrailUsecase(opts.Repository.AuditTrail)

	// Perawatan Anak (Lembar Capaian)
	// m.KategoriCapaian = NewKategoriCapaianUsecase(opts.Repository.KategoriCapaian)
	// m.Perawatan = NewPerawatanUsecase(opts.Repository.Perawatan, opts.Repository.KategoriCapaian)

	// Edukasi Digital
	m.EdukasiInformasiUmum = NewEdukasiInformasiUmumUsecase(opts.Repository.EdukasiInformasiUmum)
	m.EdukasiTrimester = NewEdukasiTrimesterUsecase(opts.Repository.EdukasiTrimester)
	// m.EdukasiNifas = NewEdukasiNifasUsecase(opts.Repository.EdukasiNifas)
	// m.EdukasiTandaBahayaTrimester = NewEdukasiTandaBahayaTrimesterUsecase(opts.Repository.EdukasiTandaBahayaTrimester)
	m.EdukasiTandaMelahirkan = NewEdukasiTandaMelahirkanUsecase(opts.Repository.EdukasiTandaMelahirkan)
	m.EdukasiImd = NewEdukasiIMDUsecase(opts.Repository.EdukasiImd)
	m.EdukasiSetelahMelahirkan = NewEdukasiSetelahMelahirkanUsecase(opts.Repository.EdukasiSetelahMelahirkan)
	m.EdukasiMenyusuiAsi = NewEdukasiMenyusuiASIUsecase(opts.Repository.EdukasiMenyusuiAsi)
	m.EdukasiPolaAsuh = NewEdukasiPolaAsuhUsecase(opts.Repository.EdukasiPolaAsuh)
	m.EdukasiKesehatanMental = NewEdukasiKesehatanMentalUsecase(opts.Repository.EdukasiKesehatanMental)
	m.EdukasiPerawatanAnak = NewEdukasiPerawatanAnakUseCase(opts.Repository.EdukasiPerawatanAnak)
	m.EdukasiAturanPorsiMPASI = NewAturanPorsiMPASIUsecase(opts.Repository.EdukasiAturanPorsiMPASI)
	m.EdukasiJadwalHarianMPASI = NewJadwalHarianMPASIUsecase(opts.Repository.EdukasiJadwalHarianMPASI)
	m.EdukasiResepMPASI = NewResepMPASIUsecase(opts.Repository.EdukasiResepMPASI)
	m.EdukasiMPASI = NewEdukasiMPASIUsecase(opts.Repository.EdukasiMPASI)
	m.LaporanIbu = NewLaporanIbuUsecase(opts.Repository.LaporanIbu)
	m.LaporanBalita = NewLaporanBalitaUsecase(opts.Repository.LaporanBalita)
	m.LaporanAnak = NewLaporanAnakUsecase(opts.Repository.LaporanAnak)
	m.LaporanRemaja = NewLaporanRemajaUsecase(opts.Repository.LaporanRemaja)
	m.LaporanDewasa = NewLaporanDewasaUsecase(opts.Repository.LaporanDewasa)
	m.LaporanLansia = NewLaporanLansiaUsecase(opts.Repository.LaporanLansia)

	stuntingMLURL := "http://localhost:8000"
	if opts.Config != nil && opts.Config.MLServiceURL != "" {
		stuntingMLURL = opts.Config.MLServiceURL
	}
	m.PrediksiStunting = NewPrediksiStuntingUsecase(opts.Repository.PrediksiStunting, stuntingMLURL)

	// Jadwal Layanan (imunisasi) usecase
	m.JadwalLayanan = NewJadwalLayananUsecase(opts.Repository.JadwalLayanan)

	// Vaksin & Dosis Vaksin usecase
	m.Vaksin = NewVaksinUsecase(opts.Repository.Vaksin)
	m.DosisVaksin = NewDosisVaksinUsecase(opts.Repository.DosisVaksin)
	m.PendudukRisk = NewPendudukRiskUsecase(opts.Repository.Pemeriksaan, m.Anak)
	m.RiwayatCard = NewRiwayatCardUsecase(
		opts.Repository.Kependudukan,
		opts.Repository.Pemeriksaan,
		opts.Repository,
	)
	m.Pencatatan = NewPencatatanUsecase(
		opts.Repository.Kependudukan,
		opts.Repository.Pemeriksaan, //
		//
	)
	m.Form = NewFormUsecase(opts.Repository.Form) // Inisialisasi FormUsecase dengan repository yang sesuai
	m.Pemeriksaan = NewPemeriksaanUsecase(opts.Repository.Form, opts.Repository.Pemeriksaan, opts.Repository)

	// m.AdminAkunKeluarga = NewAdminAkunKeluargaUsecase(
	// 	opts.Repository.User,
	// 	opts.Repository.Role,
	// 	opts.Repository.KartuKeluarga,
	// 	opts.Repository.Kependudukan,
	// )

	m.AdminTenagaKesehatan = NewAdminTenagaKesehatanUsecase(
		opts.Repository.Bidan,
		opts.Repository.Kader,
		opts.Repository.Kependudukan,
		opts.Repository.User,
		opts.Repository.Role,
	)

	// MODUL IBU
	m.LogTTDMMS = NewLogTTDMMSUsecase(opts.Repository.LogTTDMMS)
	m.PemantauanIbuHamil = NewPemantauanIbuHamilUsecase(opts.Repository.PemantauanIbuHamil)
	m.PersiapanMelahirkan = NewPersiapanMelahirkanUsecase(opts.Repository.PersiapanMelahirkan)
	m.ProsesMelahirkan = NewProsesMelahirkanUsecase(opts.Repository.ProsesMelahirkan)
	m.AbsensiKelasIbuHamil = NewAbsensiKelasIbuHamilUsecase(opts.Repository.AbsensiKelasIbuHamil)
	m.AbsensiKelasIbuBalita = NewAbsensiKelasIbuBalitaUsecase(opts.Repository.AbsensiKelasIbuBalita)
	m.ChecklistPemantauanIbuNifas = NewChecklistPemantauanIbuNifasUsecase(
		opts.Repository.ChecklistPemantauanIbuNifas,
		opts.Repository.Kehamilan,
	)
	m.WarnaTinja = NewWarnaTinjaUsecase(opts.Repository.WarnaTinja)
	m.EdukasiIMD = NewEdukasiIMDUsecase(opts.Repository.EdukasiIMD)
	m.EdukasiKesehatanMental = NewEdukasiKesehatanMentalUsecase(opts.Repository.EdukasiKesehatanMental)
	m.EdukasiMenyusuiASI = NewEdukasiMenyusuiASIUsecase(opts.Repository.EdukasiMenyusuiASI)
	// m.EdukasiNifas = NewEdukasiNifasUsecase(opts.Repository.EdukasiNifas)
	m.EdukasiTandaMelahirkan = NewEdukasiTandaMelahirkanUsecase(opts.Repository.EdukasiTandaMelahirkan)
	// m.EdukasiTrimester = NewEdukasiTrimesterUseCase(opts.Repository.EdukasiTrimester)
	// m.EdukasiTrimester = NewEdukasiTrimesterUseCase(opts.Repository.EdukasiTrimester)
	// Profile Ibu
	m.ProfilIbu = NewProfilIbuUsecase(
		opts.Repository.User,
		opts.Repository.Ibu,
		opts.Repository.Kehamilan,
		opts.Repository.EvaluasiKesehatanIbu,
		opts.Repository.RiwayatKehamilanLalu,
		opts.Repository.Desa,
		// Profil keluargaa
		opts.Repository.Kependudukan,
	)
	// Riwayat Kehamilan Ibu 
	m.DetailKehamilanIbu = NewDetailKehamilanIbuUsecase(
		opts.Repository.Kehamilan,
		opts.Repository.SkriningPreeklampsia,
		opts.Repository.GrafikEvaluasiKehamilan,
		opts.Repository.GrafikPeningkatanBB,
		opts.Repository.RingkasanPelayananPersalinan,
		opts.Repository.Ibu,
		opts.Repository.User,
	)

	// Pencatatan Imunisasi (Web)
	m.PencatatanImunisasi = NewPencatatanImunisasiUsecase(opts.Repository.PencatatanImunisasi)

	// Puskesmas Dashboard (multi-desa recap)
	m.PuskesmasDashboard = NewPuskesmasDashboardUsecase(opts.Repository.PuskesmasDashboard)

	// Ringkasan Desa (dashboard kader)
	m.RingkasanDesa = NewRingkasanDesaUsecase(opts.Repository.RingkasanDesa)

	return m
}
