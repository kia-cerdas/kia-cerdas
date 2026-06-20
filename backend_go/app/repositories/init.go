package repositories

//AbsensiKelasIbuBalita//
import (
	"monitoring-service/pkg/config"

	// Coba dulu

	"gorm.io/gorm"
)

type Main struct {
	postgres *gorm.DB
	config   *config.Config

	// Existing
	ChecklistPemantauanIbuNifas ChecklistPemantauanIbuNifasRepository
	InformasiUmum               *InformasiUmumRepository
	Anak                        *AnakRepository
	PelayananKesehatanAnak      PelayananKesehatanAnakRepository
	Neonatus                    PelayananNeonatusRepository
	KunjunganGizi               KunjunganGiziRepository
	KunjunganVitamin            KunjunganVitaminRepository
	KunjunganImunisasi          KunjunganImunisasiRepository
	PemeriksaanGigi             PemeriksaanGigiRepository
	PemantauanPertumbuhan       PemantauanPertumbuhanRepository
	PengukuranLilA              PengukuranLilaRepository
	CatatanPelayanan            CatatanPelayananRepository
	KategoriTandaBahaya         *KategoriTandaBahayaRepository
	SkriningPemantauan          *SkriningPemantauanRepository

	// New repositories (semua pointer, mengikuti pola Anak)
	User                          *UserRepository
	Role                          *RoleRepository
	Desa                          *DesaRepository
	KartuKeluarga                 *KartuKeluargaRepository
	Kependudukan                  *KependudukanRepository
	Bidan                         *BidanRepository
	Kader                         *KaderRepository
	Ibu                           *IbuRepository
	Kehamilan                     *KehamilanRepository
	PemeriksaanKehamilan          *PemeriksaanKehamilanRepository
	EvaluasiKesehatanIbu          *EvaluasiKesehatanIbuRepository
	RiwayatKehamilanLalu          *RiwayatKehamilanLaluRepository
	PemeriksaanDokterTrimester1   *PemeriksaanDokterTrimester1Repository
	PemeriksaanLaboratoriumJiwa   *PemeriksaanLaboratoriumJiwaRepository
	SkriningPreeklampsia          *SkriningPreeklampsiaRepository
	SkriningDMGestasional         *SkriningDMGestasionalRepository
	CatatanPelayananTrimester2    *CatatanPelayananTrimester2Repository
	PemeriksaanDokterTrimester3   *PemeriksaanDokterTrimester3Repository
	PemeriksaanLanjutanTrimester3 *PemeriksaanLanjutanTrimester3Repository
	GrafikEvaluasiKehamilan       *GrafikEvaluasiKehamilanRepository
	GrafikPeningkatanBB           *GrafikPeningkatanBBRepository
	PenjelasanHasilGrafik         *PenjelasanHasilGrafikRepository
	RencanaPersalinan             *RencanaPersalinanRepository
	RingkasanPelayananPersalinan  *RingkasanPelayananPersalinanRepository
	KeteranganLahir               *KeteranganLahirRepository // <-- TAMBAHKAN INI
	Bbl                           BblRepository
	LembarPemantauan              LembarPemantauanRepository
	RiwayatProsesMelahirkan       *RiwayatProsesMelahirkanRepository
	PelayananIbuNifas             *PelayananIbuNifasRepository
	CatatanPelayananNifas         *CatatanPelayananNifasRepository
	CatatanPelayananKehamilan     *CatatanPelayananKehamilanRepository
	Rujukan                       *RujukanRepository
	JenisPelayanan                JenisPelayananRepository
	KategoriUmur                  KategoriUmurRepository
	GejalaDaruratAnak             GejalaDaruratAnakRepository

	// Repository tambahan
	// KesehatanLingkunganDanCatatanKader *KesehatanLingkunganDanCatatanKaderRepository
	// PerkembanganAnak                   PerkembanganAnakRepository

	// Edukasi Digital
	// EdukasiTandaBahayaTrimester EdukasiTandaBahayaTrimesterRepository
	// MODUL IBU
	LogTTDMMS             *LogTTDMMSRepository
	PemantauanIbuHamil    *PemantauanIbuHamilRepository
	PersiapanMelahirkan   *PersiapanMelahirkanRepository
	ProsesMelahirkan      *ProsesMelahirkanRepository
	AbsensiKelasIbuHamil  *AbsensiKelasIbuHamilRepository
	AbsensiKelasIbuBalita *AbsensiKelasIbuBalitaRepository
	WarnaTinja            WarnaTinjaRepository
	EdukasiIMD            EdukasiIMDRepository
	EdukasiMenyusuiASI    EdukasiMenyusuiASIRepository
	KeluhanAnak           KeluhanAnakRepository
	// KesehatanLingkungan   KesehatanLingkunganRepository
	// KesehatanLingkunganDanCatatanKader *KesehatanLingkunganDanCatatanKaderRepository
	PemantauanAnak      PemantauanAnakRepository
	PemantauanIndikator *PemantauanIndikatorRepository
	AuditTrail          *AuditTrailRepository

	// Perawatan Anak (Lembar Capaian)
	// KategoriCapaian KategoriCapaianRepository
	Perawatan PerawatanRepository

	// Edukasi Digital
	EdukasiInformasiUmum     EdukasiInformasiUmumRepository
	EdukasiTrimester         EdukasiTrimesterRepository
	EdukasiTandaMelahirkan   EdukasiTandaMelahirkanRepository
	EdukasiImd               EdukasiIMDRepository
	EdukasiSetelahMelahirkan EdukasiSetelahMelahirkanRepository
	EdukasiMenyusuiAsi       EdukasiMenyusuiASIRepository
	EdukasiPolaAsuh          EdukasiPolaAsuhRepository
	EdukasiKesehatanMental   EdukasiKesehatanMentalRepository
	EdukasiPerawatanAnak     EdukasiPerawatanAnakRepository
	EdukasiMPASI             EdukasiMPASIRepository
	EdukasiAturanPorsiMPASI  AturanPorsiMPASIRepository
	EdukasiJadwalHarianMPASI JadwalHarianMPASIRepository
	JadwalLayanan            JadwalLayananRepository
	EdukasiResepMPASI        ResepMPASIRepository

	// Vaksin & Dosis Vaksin
	Vaksin      VaksinRepository
	DosisVaksin DosisVaksinRepository
	LaporanIbu               LaporanIbuRepository
	LaporanAnak              LaporanAnakRepository
	LaporanRemaja            LaporanRemajaRepository
	LaporanDewasa            LaporanDewasaRepository
	LaporanLansia            LaporanLansiaRepository
	PrediksiStunting         PrediksiStuntingRepository
	Form                     FormRepository
	Pemeriksaan              PemeriksaanRepository
	PencatatanImunisasi      *PencatatanImunisasiRepository
	PuskesmasDashboard       *PuskesmasDashboardRepository
	RingkasanDesa            *RingkasanDesaRepository
}

// DB returns the underlying *gorm.DB instance for direct queries and transactions.
func (m *Main) DB() *gorm.DB {
	return m.postgres
}

type Options struct {
	Postgres *gorm.DB
	Config   *config.Config
}

func Init(opts Options) *Main {
	m := &Main{
		postgres: opts.Postgres,
		config:   opts.Config,
	}

	// Existing
	m.Anak = NewAnakRepository(opts.Postgres)
	m.PelayananKesehatanAnak = NewPelayananKesehatanAnakRepository(opts.Postgres)

	// New repositories
	m.User = NewUserRepository(opts.Postgres)
	m.Ibu = NewIbuRepository(opts.Postgres)
	m.ChecklistPemantauanIbuNifas = NewChecklistPemantauanIbuNifasRepository(opts.Postgres)
	m.Role = NewRoleRepository(opts.Postgres)
	m.Desa = NewDesaRepository(opts.Postgres)
	m.KartuKeluarga = NewKartuKeluargaRepository(opts.Postgres)
	m.Kependudukan = NewKependudukanRepository(opts.Postgres)
	m.Bidan = NewBidanRepository(opts.Postgres)
	m.Kader = NewKaderRepository(opts.Postgres)
	m.Kehamilan = NewKehamilanRepository(opts.Postgres)
	m.PemeriksaanKehamilan = NewPemeriksaanKehamilanRepository(opts.Postgres)
	m.EvaluasiKesehatanIbu = NewEvaluasiKesehatanIbuRepository(opts.Postgres)
	m.RiwayatKehamilanLalu = NewRiwayatKehamilanLaluRepository(opts.Postgres)
	m.PemeriksaanDokterTrimester1 = NewPemeriksaanDokterTrimester1Repository(opts.Postgres)
	m.PemeriksaanLaboratoriumJiwa = NewPemeriksaanLaboratoriumJiwaRepository(opts.Postgres)
	m.SkriningPreeklampsia = NewSkriningPreeklampsiaRepository(opts.Postgres)
	m.SkriningDMGestasional = NewSkriningDMGestasionalRepository(opts.Postgres)
	m.CatatanPelayananTrimester2 = NewCatatanPelayananTrimester2Repository(opts.Postgres)
	m.PemeriksaanDokterTrimester3 = NewPemeriksaanDokterTrimester3Repository(opts.Postgres)
	m.PemeriksaanLanjutanTrimester3 = NewPemeriksaanLanjutanTrimester3Repository(opts.Postgres)
	m.GrafikEvaluasiKehamilan = NewGrafikEvaluasiKehamilanRepository(opts.Postgres)
	m.GrafikPeningkatanBB = NewGrafikPeningkatanBBRepository(opts.Postgres)
	m.PenjelasanHasilGrafik = NewPenjelasanHasilGrafikRepository(opts.Postgres)
	m.RencanaPersalinan = NewRencanaPersalinanRepository(opts.Postgres)
	m.RingkasanPelayananPersalinan = NewRingkasanPelayananPersalinanRepository(opts.Postgres)
	m.KeteranganLahir = NewKeteranganLahirRepository(opts.Postgres) // <-- TAMBAHKAN INI
	m.Bbl = NewBblRepository(opts.Postgres)
	m.LembarPemantauan = NewLembarPemantauanRepository(opts.Postgres)
	m.RiwayatProsesMelahirkan = NewRiwayatProsesMelahirkanRepository(opts.Postgres)
	m.PelayananIbuNifas = NewPelayananIbuNifasRepository(opts.Postgres)
	m.CatatanPelayananNifas = NewCatatanPelayananNifasRepository(opts.Postgres)
	m.CatatanPelayananKehamilan = NewCatatanPelayananKehamilanRepository(opts.Postgres)
	m.Rujukan = NewRujukanRepository(opts.Postgres)

	m.Neonatus = NewPelayananNeonatusRepository(opts.Postgres)
	m.KunjunganGizi = NewKunjunganGiziRepository(opts.Postgres)
	m.KunjunganVitamin = NewKunjunganVitaminRepository(opts.Postgres)
	m.KunjunganImunisasi = NewKunjunganImunisasiRepository(opts.Postgres)
	m.PemeriksaanGigi = NewPemeriksaanGigiRepository(opts.Postgres)
	m.PemantauanPertumbuhan = NewPemantauanPertumbuhanRepository(opts.Postgres)
	m.PengukuranLilA = NewPengukuranLilaRepository(opts.Postgres)
	m.CatatanPelayanan = NewCatatanPelayananRepository(opts.Postgres)
	m.InformasiUmum = NewInformasiUmumRepository(opts.Postgres)
	m.EdukasiMPASI = NewEdukasiMPASIRepository(opts.Postgres)
	m.JenisPelayanan = NewJenisPelayananRepository(opts.Postgres)
	m.Perawatan = NewPerawatanRepository(opts.Postgres)
	m.KeluhanAnak = NewKeluhanAnakRepository(opts.Postgres)
	m.KategoriTandaBahaya = NewKategoriTandaBahayaRepository(opts.Postgres)
	// m.SkriningPemantauan = NewSkriningPemantauanRepository(opts.Postgres)
	m.JenisPelayanan = NewJenisPelayananRepository(opts.Postgres)
	m.KategoriUmur = NewKategoriUmurRepository(opts.Postgres)
	m.GejalaDaruratAnak = NewGejalaDaruratAnakRepository(opts.Postgres)

	// Repository tambahan
	m.KeluhanAnak = NewKeluhanAnakRepository(opts.Postgres)
	// m.KesehatanLingkungan = NewKesehatanLingkunganRepository(opts.Postgres)
	// m.KesehatanLingkunganDanCatatanKader = NewKesehatanLingkunganDanCatatanKaderRepository(opts.Postgres)
	m.PemantauanAnak = NewPemantauanAnakRepository(opts.Postgres)
	m.PemantauanIndikator = NewPemantauanIndikatorRepository(opts.Postgres)
	m.AuditTrail = NewAuditTrailRepository(opts.Postgres)

	// Perawatan Anak (Lembar Capaian)
	// m.KategoriCapaian = NewKategoriCapaianRepository(opts.Postgres)
	m.Perawatan = NewPerawatanRepository(opts.Postgres)

	// Edukasi Digital
	m.EdukasiInformasiUmum = NewEdukasiInformasiUmumRepository(opts.Postgres)
	m.EdukasiTrimester = NewEdukasiTrimesterRepository(opts.Postgres)
	m.EdukasiTandaMelahirkan = NewEdukasiTandaMelahirkanRepository(opts.Postgres)
	m.EdukasiImd = NewEdukasiIMDRepository(opts.Postgres)
	m.EdukasiSetelahMelahirkan = NewEdukasiSetelahMelahirkanRepository(opts.Postgres)
	m.EdukasiMenyusuiAsi = NewEdukasiMenyusuiASIRepository(opts.Postgres)
	m.EdukasiPolaAsuh = NewEdukasiPolaAsuhRepository(opts.Postgres)
	m.EdukasiKesehatanMental = NewEdukasiKesehatanMentalRepository(opts.Postgres)
	m.EdukasiPerawatanAnak = NewEdukasiPerawatanAnakRepository(opts.Postgres)
	m.EdukasiMPASI = NewEdukasiMPASIRepository(opts.Postgres)
	m.EdukasiAturanPorsiMPASI = NewAturanPorsiMPASIRepository(opts.Postgres)
	m.EdukasiJadwalHarianMPASI = NewJadwalHarianMPASIRepository(opts.Postgres)
	m.JadwalLayanan = NewJadwalLayananRepository(opts.Postgres)
	m.EdukasiResepMPASI = NewResepMPASIRepository(opts.Postgres)

	// Vaksin & Dosis Vaksin
	m.Vaksin = NewVaksinRepository(opts.Postgres)
	m.DosisVaksin = NewDosisVaksinRepository(opts.Postgres)
	m.LaporanIbu = NewLaporanIbuRepository(opts.Postgres)
	m.LaporanAnak = NewLaporanAnakRepository(opts.Postgres)
	m.LaporanRemaja = NewLaporanRemajaRepository(opts.Postgres)
	m.LaporanDewasa = NewLaporanDewasaRepository(opts.Postgres)
	m.LaporanLansia = NewLaporanLansiaRepository(opts.Postgres)
	m.PrediksiStunting = NewPrediksiStuntingRepository(opts.Postgres)
	m.Form = NewFormRepository(opts.Postgres) // Inisialisasi FormRepository dengan database yang sesuai
	m.Pemeriksaan = NewPemeriksaanRepository(opts.Postgres)
	m.PencatatanImunisasi = NewPencatatanImunisasiRepository(opts.Postgres)
	m.PuskesmasDashboard = NewPuskesmasDashboardRepository(opts.Postgres)
	m.RingkasanDesa = NewRingkasanDesaRepository(opts.Postgres)
	// return m

	// MODUL IBU
	m.LogTTDMMS = NewLogTTDMMSRepository(opts.Postgres)
	m.PemantauanIbuHamil = NewPemantauanIbuHamilRepository(opts.Postgres)
	m.PersiapanMelahirkan = NewPersiapanMelahirkanRepository(opts.Postgres)
	m.ProsesMelahirkan = NewProsesMelahirkanRepository(opts.Postgres)
	m.AbsensiKelasIbuHamil = NewAbsensiKelasIbuHamilRepository(opts.Postgres)
	m.AbsensiKelasIbuBalita = NewAbsensiKelasIbuBalitaRepository(opts.Postgres)
	m.WarnaTinja = NewWarnaTinjaRepository(opts.Postgres)

	m.EdukasiIMD = NewEdukasiIMDRepository(opts.Postgres)
	m.EdukasiKesehatanMental = NewEdukasiKesehatanMentalRepository(opts.Postgres)
	m.EdukasiMenyusuiASI = NewEdukasiMenyusuiASIRepository(opts.Postgres)
	// m.EdukasiNifas = NewEdukasiNifasRepository(opts.Postgres)
	m.EdukasiTandaMelahirkan = NewEdukasiTandaMelahirkanRepository(opts.Postgres)
	m.EdukasiTrimester = NewEdukasiTrimesterRepository(opts.Postgres)
	return m
}

// func (m *Main) GetStandarAntropometri(gender int, usia string, indikator string) (*models.MasterStandarAntropometri, error) {
//     return nil, nil
// }

// func (m *Main) GetMasterStandarByFilter(jenisKelamin string, usiaBulan int, indikator string) (*models.MasterStandarAntropometri, error) {
//     return nil, nil
// }

// func (m *Main) GetStandarAntropometri(indikator string, jenisKelamin string, nilaiPengukuran float64) (*models.MasterStandarAntropometri, error) {
// 	return nil, nil
// }

// func (m *Main) GetMasterStandarByFilter(indikator string, jenisKelamin string) ([]models.MasterStandarAntropometri, error) {
// 	return nil, nil
// }
