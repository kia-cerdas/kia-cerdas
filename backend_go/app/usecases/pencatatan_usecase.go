package usecases

import (
	"context"
	"errors"
	"monitoring-service/app/middlewares"
	"monitoring-service/app/models"
	"monitoring-service/app/repositories"
	"monitoring-service/app/utils"
	"time"
)

type PencatatanUsecase interface {
    GetPendudukByKategori(kategori string, PosyanduID *int32, role string) ([]models.PendudukWithPemeriksaan, error)
    ValidasiUmurKategori(pendudukID int32, kategori string) (bool, error)
    GetRiwayatPemeriksaanByPendudukID(pendudukID int32, kategori string, PosyanduID *int32, role string) (interface{}, error)
}

type pencatatanUsecase struct {
    pendudukRepo    *repositories.KependudukanRepository
    pemeriksaanRepo repositories.PemeriksaanRepository
}

func NewPencatatanUsecase(
    pendudukRepo *repositories.KependudukanRepository,
    pemeriksaanRepo repositories.PemeriksaanRepository,
) PencatatanUsecase {
    return &pencatatanUsecase{
        pendudukRepo:    pendudukRepo,
        pemeriksaanRepo: pemeriksaanRepo,
    }
}

// helper hitung umur pada tanggal tertentu (karena utils.HitungUmur hanya untuk sekarang)
func hitungUmurPadaTanggal(tglLahir, tglReferensi time.Time) int {
    years := tglReferensi.Year() - tglLahir.Year()
    if tglReferensi.YearDay() < tglLahir.YearDay() {
        years--
    }
    return years
}

func (u *pencatatanUsecase) GetPendudukByKategori(kategori string, PosyanduID *int32, role string) ([]models.PendudukWithPemeriksaan, error) {
    var minAge, maxAge int
    switch kategori {
    case "balita":
        minAge, maxAge = 0, 5
    case "anak":
        minAge, maxAge = 5, 9
    case "remaja":
        minAge, maxAge = 10, 18
    case "dewasa":
        minAge, maxAge = 19, 59
    case "lansia":
        minAge, maxAge = 60, 150
    default:
        return nil, errors.New("kategori tidak valid")
    }

    pendudukList, err := u.pendudukRepo.FindByAgeRange(minAge, maxAge, PosyanduID, role)
    if err != nil {
        return nil, err
    }

    // Kumpulkan semua ID penduduk (int32)
    pendudukIDs := make([]int32, len(pendudukList))
    for i, p := range pendudukList {
        pendudukIDs[i] = p.IDKependudukan
    }

    // 🔧 Konversi ke []uint untuk repository
    uintIDs := make([]uint, len(pendudukIDs))
    for i, id := range pendudukIDs {
        uintIDs[i] = uint(id)
    }

    // Ambil semua pemeriksaan terbaru
    latestExamsMap, err := u.pemeriksaanRepo.GetLatestByPendudukIDs(context.Background(), kategori, uintIDs)
    if err != nil {
        latestExamsMap = make(map[uint]*models.Pemeriksaan)
    }

    result := []models.PendudukWithPemeriksaan{}
    for _, p := range pendudukList {
        umur := utils.HitungUmur(p.TanggalLahir)

        var pemeriksaanTerakhir interface{}
        // 🔧 Konversi p.IDKependudukan (int32) ke uint untuk lookup
        if exam, ok := latestExamsMap[uint(p.IDKependudukan)]; ok {
            pemeriksaanTerakhir = exam
        }

        var masihDalamRentang bool
        fiveYearsLater := p.TanggalLahir.AddDate(5, 0, 0)
        tenYearsLater := p.TanggalLahir.AddDate(10, 0, 0)
        nineteenYearsLater := p.TanggalLahir.AddDate(19, 0, 0)
        sixtyYearsLater := p.TanggalLahir.AddDate(60, 0, 0)

        now := time.Now()
        switch kategori {
        case "balita":
            masihDalamRentang = !p.TanggalLahir.After(now) && !now.After(fiveYearsLater)
        case "anak":
            masihDalamRentang = now.After(fiveYearsLater) && !now.After(tenYearsLater)
        case "remaja":
            masihDalamRentang = now.After(tenYearsLater) && !now.After(nineteenYearsLater)
        case "dewasa":
            masihDalamRentang = now.After(nineteenYearsLater) && !now.After(sixtyYearsLater)
        case "lansia":
            masihDalamRentang = now.After(sixtyYearsLater)
        }

        wrapper := models.PendudukWithPemeriksaan{
            IDKependudukan:      p.IDKependudukan,
            NIK:                 p.NIK,
            NamaLengkap:         p.NamaAnggotaKeluarga,
            JenisKelamin:        p.JenisKelamin,
            TanggalLahir:        p.TanggalLahir,
            TempatLahir:         p.TempatLahir,
            Dusun:               p.Dusun,
            DesaID:              p.DesaID,
            Desa:                p.Desa,
            UmurSekarang:        umur,
            PemeriksaanTerakhir: pemeriksaanTerakhir,
            DapatDitambahkan:    masihDalamRentang,
        }
        if !masihDalamRentang {
            wrapper.AlasanTidakBisa = "Umur sudah melebihi batas kategori ini"
        }
        result = append(result, wrapper)
    }
    return result, nil
}
func (u *pencatatanUsecase) ValidasiUmurKategori(pendudukID int32, kategori string) (bool, error) {
    penduduk, err := u.pendudukRepo.FindByID(pendudukID)
    if err != nil {
        return false, err
    }

    now := time.Now()
    tglLahir := penduduk.TanggalLahir

    fiveYearsLater := tglLahir.AddDate(5, 0, 0)
    tenYearsLater := tglLahir.AddDate(10, 0, 0)
    nineteenYearsLater := tglLahir.AddDate(19, 0, 0)
    sixtyYearsLater := tglLahir.AddDate(60, 0, 0)

    switch kategori {
    case "balita":
        return !tglLahir.After(now) && !now.After(fiveYearsLater), nil
    case "anak":
        return now.After(fiveYearsLater) && !now.After(tenYearsLater), nil
    case "remaja":
        return now.After(tenYearsLater) && !now.After(nineteenYearsLater), nil
    case "dewasa":
        return now.After(nineteenYearsLater) && !now.After(sixtyYearsLater), nil
    case "lansia":
        return now.After(sixtyYearsLater), nil
    default:
        return false, nil
    }
}
func (u *pencatatanUsecase) GetRiwayatPemeriksaanByPendudukID(pendudukID int32, kategori string, PosyanduID *int32, role string) (interface{}, error) {
    // Validasi desa: pastikan penduduk yang diakses berada di desa yang sesuai
    penduduk, err := u.pendudukRepo.FindByID(pendudukID)
    if err != nil {
        return nil, err
    }
    if !middlewares.HasFullAccess(role) && PosyanduID != nil {
        if penduduk.PosyanduID == nil || *penduduk.PosyanduID != *PosyanduID {
            return nil, errors.New("akses ditolak: data bukan untuk desa Anda")
        }
    }

    // Ambil semua riwayat pemeriksaan untuk penduduk ini dengan filter kategori
    return u.pemeriksaanRepo.GetRiwayatByPenduduk(context.Background(), uint(pendudukID), kategori)
}