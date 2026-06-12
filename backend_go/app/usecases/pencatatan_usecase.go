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
    GetPendudukByKategori(kategori string, desaID *int32, role string) ([]models.PendudukWithPemeriksaan, error)
    ValidasiUmurKategori(pendudukID int32, kategori string) (bool, error)
    GetRiwayatPemeriksaanByPendudukID(pendudukID int32, kategori string, desaID *int32, role string) (interface{}, error)
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

func (u *pencatatanUsecase) GetPendudukByKategori(kategori string, desaID *int32, role string) ([]models.PendudukWithPemeriksaan, error) {
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

    pendudukList, err := u.pendudukRepo.FindByAgeRange(minAge, maxAge, desaID, role)
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

        masihDalamRentang := umur >= minAge && umur <= maxAge
        wrapper := models.PendudukWithPemeriksaan{
            IDKependudukan:      p.IDKependudukan,
            NIK:                 p.NIK,
            NamaLengkap:         p.NamaLengkap,
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
    umur := utils.HitungUmur(penduduk.TanggalLahir)
    switch kategori {
    case "balita":
        return umur >= 0 && umur <= 5, nil
    case "anak":
        return umur >= 5 && umur <= 9, nil
    case "remaja":
        return umur >= 10 && umur <= 18, nil
    case "dewasa":
        return umur >= 19 && umur <= 59, nil
    case "lansia":
        return umur >= 60, nil
    default:
        return false, nil
    }
}
func (u *pencatatanUsecase) GetRiwayatPemeriksaanByPendudukID(pendudukID int32, kategori string, desaID *int32, role string) (interface{}, error) {
    // Validasi desa: pastikan penduduk yang diakses berada di desa yang sesuai
    penduduk, err := u.pendudukRepo.FindByID(pendudukID)
    if err != nil {
        return nil, err
    }
    if !middlewares.HasFullAccess(role) && desaID != nil {
        if penduduk.DesaID == nil || *penduduk.DesaID != *desaID {
            return nil, errors.New("akses ditolak: data bukan untuk desa Anda")
        }
    }

    // Ambil semua riwayat pemeriksaan untuk penduduk ini dengan filter kategori
    return u.pemeriksaanRepo.GetRiwayatByPenduduk(context.Background(), uint(pendudukID), kategori)
}