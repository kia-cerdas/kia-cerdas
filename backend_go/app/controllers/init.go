package controllers

import (
	"monitoring-service/app/usecases"
	"monitoring-service/pkg/config"

	"gorm.io/gorm"
)

type Main struct {
	usecases *usecases.Main
	config   *config.Config
	db       *gorm.DB

	// Controller yang sudah ada (untuk modul lain)
	KategoriTandaBahaya       *KategoriTandaBahayaController
	PemeriksaanDokterCombined *PemeriksaanDokterCombinedController
	Anak                      *AnakController
	PelayananKesehatanAnak    *PelayananKesehatanAnakController
	Neonatus                  *NeonatusController
	PelayananGiziAnak         *kunjunganGiziController
	KunjunganVitamin          *KunjunganVitaminController
	KunjunganImunisasi        *KunjunganImunisasiController
	PemeriksaanGigi           *PemeriksaanGigiController
	PemantauanPertumbuhan     *PemantauanPertumbuhanController
	PengukuranLilA            *PengukuranLilAController
	CatatanPelayanan          *CatatanPelayananController
	InformasiUmum             *InformasiUmumController

	// Controller baru untuk struktur kehamilan
	Ibu                           *IbuController
	Kehamilan                     *KehamilanController
	PemeriksaanKehamilan          *PemeriksaanKehamilanController
	EvaluasiKesehatanIbu          *EvaluasiKesehatanIbuController
	PemeriksaanDokterTrimester1   *PemeriksaanDokterTrimester1Controller
	PemeriksaanDokterTrimester3   *PemeriksaanDokterTrimester3Controller
	PemeriksaanLaboratoriumJiwa   *PemeriksaanLaboratoriumJiwaController
	PemeriksaanLanjutanTrimester3 *PemeriksaanLanjutanTrimester3Controller
	CatatanPelayananTrimester1    *CatatanPelayananTrimester1Controller
	CatatanPelayananTrimester2    *CatatanPelayananTrimester2Controller
	CatatanPelayananTrimester3    *CatatanPelayananTrimester3Controller
	CatatanPelayananNifas         *CatatanPelayananNifasController
	CatatanPelayananKehamilan     *CatatanPelayananKehamilanController
	GrafikPeningkatanBB           *GrafikPeningkatanBBController
	PenjelasanHasilGrafik         *PenjelasanHasilGrafikController
	RencanaPersalinan             *RencanaPersalinanController
	RingkasanPelayananPersalinan  *RingkasanPelayananPersalinanController
	RiwayatProsesMelahirkan       *RiwayatProsesMelahirkanController
	Rujukan                       *RujukanController
	SkriningDMGestasional         *SkriningDMGestasionalController
	SkriningPreeklampsia          *SkriningPreeklampsiaController
	SkriningPemantauan            *SkriningPemantauanController
	PelayananIbuNifas             *PelayananIbuNifasController
	RiwayatKehamilanLalu          *RiwayatKehamilanLaluController
	KeteranganLahir               *KeteranganLahirController
	Desa                          *DesaController
	Kependudukan                  *KependudukanController
	JenisPelayanan                *JenisPelayananController
	KategoriUmur                  *KategoriUmurController
	Kader                         *KaderController
	AuditTrail                    *AuditTrailController
	GejalaDaruratAnak             *GejalaDaruratAnakController

	// Controller tambahan
	PemantauanAnak      *PemantauanAnakController
	PemantauanIndikator *PemantauanIndikatorController
	LembarPemantauan    *LembarPemantauanController

	Bbl BblController

	// MODUL IBU
	PemantauanIbuHamil          *PemantauanIbuHamilController
	LogTTDMMS                   *LogTTDMMSController
	PersiapanMelahirkan         *PersiapanMelahirkanController
	ProsesMelahirkan            *ProsesMelahirkanController
	AbsensiKelasIbuHamil        *AbsensiKelasIbuHamilController
	AbsensiKelasIbuBalita       *AbsensiKelasIbuBalitaController
	ChecklistPemantauanIbuNifas *ChecklistPemantauanIbuNifasController
	WarnaTinja                  *WarnaTinjaController
	KeluhanAnak                 *KeluhanAnakController
	EdukasiIMD                  *EdukasiIMDController
	EdukasiMenyusuiASI          *EdukasiMenyusuiASIController
	GrafikEvaluasiKehamilan     *GrafikEvaluasiKehamilanController
	EdukasiInformasiUmum        *EdukasiInformasiUmumController
	EdukasiTrimester            *EdukasiTrimesterController
	EdukasiTandaMelahirkan      *EdukasiTandaMelahirkanController

	// Penambahan
	EdukasiImd               *EdukasiIMDController
	EdukasiSetelahMelahirkan *EdukasiSetelahMelahirkanController
	EdukasiPolaAsuh          *EdukasiPolaAsuhController
	EdukasiKesehatanMental   *EdukasiKesehatanMentalController
	EdukasiPerawatanAnak     *EdukasiPerawatanAnakController
	EdukasiMPASI             *EdukasiMPASIController
	EdukasiAturanPorsiMPASI  *AturanPorsiMPASIController
	EdukasiJadwalHarianMPASI *JadwalHarianMPASIController
	EdukasiResepMPASI        *ResepMPASIController
	LaporanIbu               *LaporanIbuController
	JadwalLayanan            *JadwalLayananController
	Vaksin                   *VaksinController      // ← TAMBAHKAN INI
	DosisVaksin              *DosisVaksinController // ← TAMBAHKAN
	Puskesmas                *PuskesmasController   // Kelola Puskesmas
	Posyandu                 *PosyanduController    // Kelola Posyandu
	LaporanAnak              *LaporanAnakController
	LaporanRemaja            *LaporanRemajaController
	LaporanDewasa            *LaporanDewasaController
	LaporanLansia            *LaporanLansiaController
	PemeriksaanAnak          *PemeriksaanAnakController
	PemeriksaanRemaja        *PemeriksaanRemajaController
	PemeriksaanDewasa        *PemeriksaanDewasaController
	PemeriksaanLansia        *PemeriksaanLansiaController
	Dashboard                *DashboardController
	PuskesmasDashboard       *PuskesmasDashboardController
	PendudukRisk             *PendudukRiskController
	RiwayatCard              *RiwayatCardController
	Pencatatan               *PencatatanController
	PrediksiStunting         *PrediksiStuntingController
	FormController           *FormController
	Pemeriksaan              *PemeriksaanController

	ProfilIbu *ProfilIbuController
	DetailKehamilanIbu *DetailKehamilanIbuController

	// Pencatatan Imunisasi (Web)
	PencatatanImunisasi *PencatatanImunisasiController
}

type Options struct {
	Config   *config.Config
	UseCases *usecases.Main
	DB       *gorm.DB
}

func Init(opts Options) *Main {
	m := &Main{
		usecases: opts.UseCases,
		config:   opts.Config,
		db:       opts.DB,
	}

	// Controller yang sudah ada (tidak diubah)
	m.Anak = NewAnakController(opts.UseCases.Anak)
	m.PelayananKesehatanAnak = NewPelayananKesehatanAnakController(opts.UseCases.PelayananKesehatanAnak)
	m.Neonatus = NewPelayananNeonatusController(opts.UseCases.Neonatus, opts.DB)
	m.PelayananGiziAnak = NewKunjunganGiziController(opts.UseCases.KunjunganGizi)
	m.KunjunganVitamin = NewKunjunganVitaminController(opts.UseCases.KunjunganVitamin)
	m.KunjunganImunisasi = NewKunjunganImunisasiController(opts.UseCases.KunjunganImunisasi)
	m.PemeriksaanGigi = NewPemeriksaanGigiController(opts.UseCases.PemeriksaanGigi)
	m.PemantauanPertumbuhan = NewPemantauanPertumbuhanController(opts.UseCases.PemantauanPertumbuhan)
	m.PengukuranLilA = NewPengukuranLilAController(opts.UseCases.PengukuranLilA)
	m.CatatanPelayanan = NewCatatanPelayananController(opts.UseCases.CatatanPelayanan)
	m.KategoriTandaBahaya = NewKategoriTandaBahayaController(opts.UseCases.KategoriTandaBahaya)
	m.PemeriksaanDokterTrimester1 = NewPemeriksaanDokterTrimester1Controller(opts.UseCases.PemeriksaanDokterTrimester1)
	m.PemeriksaanDokterTrimester3 = NewPemeriksaanDokterTrimester3Controller(opts.UseCases.PemeriksaanDokterTrimester3)

	m.InformasiUmum = NewInformasiUmumController(opts.UseCases.InformasiUmum)
	m.EdukasiMPASI = NewEdukasiMPASIController(opts.UseCases.EdukasiMPASI)

	// Controller baru
	m.Ibu = NewIbuController(opts.UseCases.Ibu)
	m.Kehamilan = NewKehamilanController(opts.UseCases.Kehamilan)
	m.PemeriksaanKehamilan = NewPemeriksaanKehamilanController(opts.UseCases.PemeriksaanKehamilan)
	m.EvaluasiKesehatanIbu = NewEvaluasiKesehatanIbuController(opts.UseCases.EvaluasiKesehatanIbu)
	m.PemeriksaanDokterTrimester1 = NewPemeriksaanDokterTrimester1Controller(opts.UseCases.PemeriksaanDokterTrimester1)
	m.PemeriksaanDokterTrimester3 = NewPemeriksaanDokterTrimester3Controller(opts.UseCases.PemeriksaanDokterTrimester3)
	m.PemeriksaanLaboratoriumJiwa = NewPemeriksaanLaboratoriumJiwaController(opts.UseCases.PemeriksaanLaboratoriumJiwa)
	m.PemeriksaanLanjutanTrimester3 = NewPemeriksaanLanjutanTrimester3Controller(opts.UseCases.PemeriksaanLanjutanTrimester3)
	m.CatatanPelayananTrimester1 = NewCatatanPelayananTrimester1Controller(opts.UseCases.CatatanPelayananTrimester1)
	m.CatatanPelayananTrimester2 = NewCatatanPelayananTrimester2Controller(opts.UseCases.CatatanPelayananTrimester2)
	m.CatatanPelayananTrimester3 = NewCatatanPelayananTrimester3Controller(opts.UseCases.CatatanPelayananTrimester3)
	m.CatatanPelayananNifas = NewCatatanPelayananNifasController(opts.UseCases.CatatanPelayananNifas)
	m.CatatanPelayananKehamilan = NewCatatanPelayananKehamilanController(opts.UseCases.CatatanPelayananKehamilan)
	m.GrafikEvaluasiKehamilan = NewGrafikEvaluasiKehamilanController(opts.UseCases.GrafikEvaluasiKehamilan)
	m.GrafikPeningkatanBB = NewGrafikPeningkatanBBController(opts.UseCases.GrafikPeningkatanBB)
	m.PenjelasanHasilGrafik = NewPenjelasanHasilGrafikController(opts.UseCases.PenjelasanHasilGrafik)
	m.RencanaPersalinan = NewRencanaPersalinanController(opts.UseCases.RencanaPersalinan)

	// *** PERBAIKAN: Tambahkan parameter usecase RiwayatProsesMelahirkan ***
	m.RingkasanPelayananPersalinan = NewRingkasanPelayananPersalinanController(
		opts.UseCases.RingkasanPelayananPersalinan,
		opts.UseCases.RiwayatProsesMelahirkan,
		opts.UseCases.Kehamilan,
	)

	m.RiwayatProsesMelahirkan = NewRiwayatProsesMelahirkanController(opts.UseCases.RiwayatProsesMelahirkan)
	m.Rujukan = NewRujukanController(opts.UseCases.Rujukan)
	m.SkriningDMGestasional = NewSkriningDMGestasionalController(opts.UseCases.SkriningDMGestasional)
	m.SkriningPreeklampsia = NewSkriningPreeklampsiaController(opts.UseCases.SkriningPreeklampsia)
	m.PelayananIbuNifas = NewPelayananIbuNifasController(opts.UseCases.PelayananIbuNifas)
	m.RiwayatKehamilanLalu = NewRiwayatKehamilanLaluController(opts.UseCases.RiwayatKehamilanLalu)
	m.KeteranganLahir = NewKeteranganLahirController(opts.UseCases.KeteranganLahir)
	m.Desa = NewDesaController(opts.UseCases.Desa)
	m.Kependudukan = NewKependudukanController(opts.UseCases.Kependudukan)
	m.JenisPelayanan = NewJenisPelayananController(opts.UseCases.JenisPelayanan)
	m.KategoriUmur = NewKategoriUmurController(opts.UseCases.KategoriUmur)
	m.Kader = NewKaderController(opts.UseCases.Kader)
	m.AuditTrail = NewAuditTrailController(opts.UseCases.AuditTrail)
	m.PemeriksaanDokterCombined = NewPemeriksaanDokterCombinedController(
		opts.UseCases.PemeriksaanDokterTrimester1,
		opts.UseCases.PemeriksaanDokterTrimester3,
	)
	m.GejalaDaruratAnak = NewGejalaDaruratAnakController(opts.UseCases.GejalaDaruratAnak)

	// Controller tambahan
	m.KeluhanAnak = NewKeluhanAnakController(opts.UseCases.KeluhanAnak)
	m.PemantauanAnak = NewPemantauanAnakController(opts.UseCases.PemantauanAnak)
	m.PemantauanIndikator = NewPemantauanIndikatorController(opts.UseCases.PemantauanIndikator)

	// Edukasi Digital
	m.EdukasiInformasiUmum = NewEdukasiInformasiUmumController(opts.UseCases.EdukasiInformasiUmum)
	m.EdukasiTrimester = NewEdukasiTrimesterController(opts.UseCases.EdukasiTrimester)
	m.EdukasiTandaMelahirkan = NewEdukasiTandaMelahirkanController(opts.UseCases.EdukasiTandaMelahirkan)
	m.EdukasiImd = NewEdukasiIMDController(opts.UseCases.EdukasiImd)
	m.EdukasiSetelahMelahirkan = NewEdukasiSetelahMelahirkanController(opts.UseCases.EdukasiSetelahMelahirkan)
	m.EdukasiMenyusuiASI = NewEdukasiMenyusuiASIController(opts.UseCases.EdukasiMenyusuiASI)
	m.EdukasiPolaAsuh = NewEdukasiPolaAsuhController(opts.UseCases.EdukasiPolaAsuh)
	m.EdukasiPerawatanAnak = NewEdukasiPerawatanAnakController(opts.UseCases.EdukasiPerawatanAnak)
	m.LembarPemantauan = NewLembarPemantauanController(opts.UseCases.LembarPemantauan)
	m.KeteranganLahir = NewKeteranganLahirController(opts.UseCases.KeteranganLahir)
	m.Bbl = NewBblController(opts.UseCases.Bbl)
	m.Kependudukan = NewKependudukanController(opts.UseCases.Kependudukan)
	m.JenisPelayanan = NewJenisPelayananController(opts.UseCases.JenisPelayanan)
	m.KeluhanAnak = NewKeluhanAnakController(opts.UseCases.KeluhanAnak)
	m.EdukasiAturanPorsiMPASI = NewAturanPorsiMPASIController(opts.UseCases.EdukasiAturanPorsiMPASI)
	m.EdukasiJadwalHarianMPASI = NewJadwalHarianMPASIController(opts.UseCases.EdukasiJadwalHarianMPASI)
	m.EdukasiResepMPASI = NewResepMPASIController(opts.UseCases.EdukasiResepMPASI)
	m.LaporanIbu = NewLaporanIbuController(opts.UseCases.LaporanIbu)
	m.LaporanAnak = NewLaporanAnakController(opts.UseCases.LaporanAnak)
	m.LaporanRemaja = NewLaporanRemajaController(opts.UseCases.LaporanRemaja)
	m.LaporanDewasa = NewLaporanDewasaController(opts.UseCases.LaporanDewasa)
	m.LaporanLansia = NewLaporanLansiaController(opts.UseCases.LaporanLansia)

	m.JadwalLayanan = NewJadwalLayananController(opts.UseCases.JadwalLayanan, opts.DB)
	m.Vaksin = NewVaksinController(opts.UseCases.Vaksin)
	m.DosisVaksin = NewDosisVaksinController(opts.UseCases.DosisVaksin, opts.UseCases.Vaksin)
	m.Puskesmas = &PuskesmasController{Main: m}
	m.Posyandu = &PosyanduController{Main: m}
	m.PemeriksaanAnak = NewPemeriksaanAnakController(opts.UseCases.PemeriksaanAnak, opts.UseCases.Kependudukan)
	m.PemeriksaanRemaja = NewPemeriksaanRemajaController(opts.UseCases.PemeriksaanRemaja, opts.UseCases.Kependudukan)
	m.PemeriksaanDewasa = NewPemeriksaanDewasaController(opts.UseCases.PemeriksaanDewasa, opts.UseCases.Kependudukan)
	m.PemeriksaanLansia = NewPemeriksaanLansiaController(opts.UseCases.PemeriksaanLansia, opts.UseCases.Kependudukan)

	dashboardUsecase := usecases.NewDashboardUsecase(
		opts.UseCases.Kependudukan,
		opts.UseCases.Pemeriksaan,
		opts.UseCases.Anak,
	)
	m.Dashboard = NewDashboardController(dashboardUsecase)

	// Puskesmas Dashboard Controller (multi-desa recap)
	m.PuskesmasDashboard = NewPuskesmasDashboardController(opts.UseCases.PuskesmasDashboard)

	m.PendudukRisk = NewPendudukRiskController(opts.UseCases.PendudukRisk)
	m.RiwayatCard = NewRiwayatCardController(opts.UseCases.RiwayatCard)
	m.Pencatatan = NewPencatatanController(opts.UseCases.Pencatatan)
	m.PrediksiStunting = NewPrediksiStuntingController(opts.UseCases.PrediksiStunting)
	m.FormController = NewFormController(opts.UseCases.Form)
	m.Pemeriksaan = NewPemeriksaanController(opts.UseCases.Pemeriksaan)

	// MODUL IBU
	m.LogTTDMMS = NewLogTTDMMSController(opts.UseCases.LogTTDMMS)
	m.PemantauanIbuHamil = NewPemantauanIbuHamilController(opts.UseCases.PemantauanIbuHamil)
	m.PersiapanMelahirkan = NewPersiapanMelahirkanController(opts.UseCases.PersiapanMelahirkan)
	m.ProsesMelahirkan = NewProsesMelahirkanController(opts.UseCases.ProsesMelahirkan)
	m.AbsensiKelasIbuHamil = NewAbsensiKelasIbuHamilController(opts.UseCases.AbsensiKelasIbuHamil)
	m.AbsensiKelasIbuBalita = NewAbsensiKelasIbuBalitaController(opts.UseCases.AbsensiKelasIbuBalita)
	m.ChecklistPemantauanIbuNifas = NewChecklistPemantauanIbuNifasController(opts.UseCases.ChecklistPemantauanIbuNifas)
	m.WarnaTinja = NewWarnaTinjaController(opts.UseCases.WarnaTinja)

	m.EdukasiIMD = NewEdukasiIMDController(opts.UseCases.EdukasiIMD)
	m.EdukasiKesehatanMental = NewEdukasiKesehatanMentalController(opts.UseCases.EdukasiKesehatanMental)
	m.EdukasiMenyusuiASI = NewEdukasiMenyusuiASIController(opts.UseCases.EdukasiMenyusuiASI)
	m.EdukasiTandaMelahirkan = NewEdukasiTandaMelahirkanController(opts.UseCases.EdukasiTandaMelahirkan)
	m.EdukasiTrimester = NewEdukasiTrimesterController(opts.UseCases.EdukasiTrimester)
	m.ProfilIbu = NewProfilIbuController(opts.UseCases.ProfilIbu)
	m.GrafikEvaluasiKehamilan = NewGrafikEvaluasiKehamilanController(opts.UseCases.GrafikEvaluasiKehamilan)

	// Riwayat kehamilan ibu 
	m.DetailKehamilanIbu = NewDetailKehamilanIbuController(opts.UseCases.DetailKehamilanIbu)
	// Pencatatan Imunisasi (Web)
	m.PencatatanImunisasi = NewPencatatanImunisasiController(opts.UseCases.PencatatanImunisasi)

	return m
}

func (m *Main) JWTSecret() string {
	return m.config.JWTSecret
}

func (m *Main) GetUseCases() *usecases.Main {
	return m.usecases
}

func (m *Main) DB() *gorm.DB {
	return m.db
}
