package usecases

import (
	"context"
	"monitoring-service/app/models"
	"monitoring-service/app/repositories"
	"monitoring-service/app/utils"
	"sort"
	"time"
)

type RiwayatCardUsecase interface {
	GetRiwayatCard(ctx context.Context, pendudukID int32) (*models.PendudukRiwayatCardResponse, error)
}

type riwayatCardUsecase struct {
	kependudukanRepo *repositories.KependudukanRepository
	pemeriksaanRepo  repositories.PemeriksaanRepository
	mainRepo         *repositories.Main
}

func NewRiwayatCardUsecase(
	kependudukanRepo *repositories.KependudukanRepository,
	pemeriksaanRepo repositories.PemeriksaanRepository,
	mainRepo *repositories.Main,
) RiwayatCardUsecase {
	return &riwayatCardUsecase{
		kependudukanRepo: kependudukanRepo,
		pemeriksaanRepo:  pemeriksaanRepo,
		mainRepo:         mainRepo,
	}
}
func (u *riwayatCardUsecase) GetRiwayatCard(ctx context.Context, pendudukID int32) (*models.PendudukRiwayatCardResponse, error) {
    // 1. Ambil data penduduk
    penduduk, err := u.kependudukanRepo.FindByID(pendudukID)
    if err != nil {
        return nil, err
    }
    usia := utils.HitungUmur(penduduk.TanggalLahir)

    dataDiri := models.DataDiriResponse{
        ID:           penduduk.IDKependudukan,
        NIK:          getStringValue(penduduk.NIK),
        NamaLengkap:  penduduk.NamaAnggotaKeluarga,
        Dusun:        penduduk.Dusun,
        TanggalLahir: penduduk.TanggalLahir,
        Usia:         usia,
        JenisKelamin: penduduk.JenisKelamin,
        Agama:        penduduk.Agama,
        Pekerjaan:    penduduk.Pekerjaan,
    }

    var allRiwayat []models.RiwayatCard

    // Check if there is a child/toddler record associated with this resident
    db := u.mainRepo.DB()
    var anak models.Anak
    isAnak := false
    if err := db.Where("penduduk_id = ? AND deleted_at IS NULL", pendudukID).First(&anak).Error; err == nil {
        isAnak = true
    }

    if isAnak {
        // Query child tables for latest recordings
        var cp models.CatatanPertumbuhan
        hasCp := false
        if err := db.Where("anak_id = ? AND deleted_at IS NULL", anak.ID).Order("tgl_ukur DESC").First(&cp).Error; err == nil {
            hasCp = true
        }

        var pg models.PeriksaGigi
        hasPg := false
        if err := db.Where("anak_id = ? AND deleted_at IS NULL", anak.ID).Order("tanggal DESC").First(&pg).Error; err == nil {
            hasPg = true
        }

        var kg models.KunjunganGizi
        hasKg := false
        if err := db.Where("anak_id = ? AND deleted_at IS NULL", anak.ID).Order("tanggal DESC").First(&kg).Error; err == nil {
            hasKg = true
        }

        var ki models.KehadiranImunisasi
        hasKi := false
        if err := db.Where("anak_id = ? AND deleted_at IS NULL", anak.ID).Order("id DESC").First(&ki).Error; err == nil {
            hasKi = true
        }

        var latestPred models.PrediksiStunting
        hasPred := false
        if err := db.Where("anak_id = ? AND deleted_at IS NULL", anak.ID).Order("created_at DESC").First(&latestPred).Error; err == nil {
            hasPred = true
        }

        // Determine latest date
        var latestDate time.Time
        hasAnyRecord := false

        if hasCp && cp.TglUkur.After(latestDate) {
            latestDate = cp.TglUkur
            hasAnyRecord = true
        }
        if hasPg && pg.Tanggal.After(latestDate) {
            latestDate = pg.Tanggal
            hasAnyRecord = true
        }
        if hasKg && kg.Tanggal.After(latestDate) {
            latestDate = kg.Tanggal
            hasAnyRecord = true
        }
        if hasKi && ki.CreatedAt.After(latestDate) {
            latestDate = ki.CreatedAt
            hasAnyRecord = true
        }
        if hasPred && latestPred.CreatedAt.After(latestDate) {
            latestDate = latestPred.CreatedAt
            hasAnyRecord = true
        }

        if hasAnyRecord {
            ris := "Normal"
            if hasPred {
                if latestPred.StatusPrediksi == "Stunting" {
                    ris = "Tinggi"
                } else if latestPred.StatusPrediksi == "Risiko Stunting Sedang" {
                    ris = "Sedang"
                } else if latestPred.StatusPrediksi == "Risiko Stunting Ringan" {
                    ris = "Rendah"
                }
            }

            virtualCard := models.RiwayatCard{
                ID:                 uint(1000000 + pendudukID),
                Kategori:           "Balita",
                TanggalPemeriksaan: latestDate,
                KategoriRisiko:     ris,
            }
            if hasCp {
                virtualCard.BeratBadan = &cp.BeratBadan
                virtualCard.TinggiBadan = &cp.TinggiBadan
                virtualCard.IMT = &cp.IMT
                virtualCard.StatusGizi = cp.StatusTBU
            } else if hasPred {
                virtualCard.BeratBadan = &latestPred.BeratBadan
                virtualCard.TinggiBadan = &latestPred.TinggiBadan
                virtualCard.StatusGizi = latestPred.StatusTBU
            }
            allRiwayat = append(allRiwayat, virtualCard)
        }
    }

    // 2. Ambil riwayat dari tabel pemeriksaans
    pemeriksaanList, err := u.pemeriksaanRepo.GetRiwayatByPendudukID(ctx, uint(pendudukID))
    if err == nil {
        // 3. Konversi ke RiwayatCard
        for _, ex := range pemeriksaanList {
            riwayatCard := models.RiwayatCard{
                ID:                 ex.ID,
                Kategori:           mapKelompokToKategori(ex.Kelompok),
                TanggalPemeriksaan: ex.TanggalPemeriksaan,
                KategoriRisiko:     utils.NormalizeRisk(ex.KategoriRisiko),
                Rekomendasi:        ex.Rekomendasi,
            }
            allRiwayat = append(allRiwayat, riwayatCard)
        }
    }

    // 4. Urutkan berdasarkan tanggal terbaru
    sort.Slice(allRiwayat, func(i, j int) bool {
        return allRiwayat[i].TanggalPemeriksaan.After(allRiwayat[j].TanggalPemeriksaan)
    })

    return &models.PendudukRiwayatCardResponse{
        DataDiri: dataDiri,
        Riwayat:  allRiwayat,
    }, nil
}

func mapKelompokToKategori(kelompok string) string {
    switch kelompok {
    case "anak":
        return "Anak"
    case "remaja":
        return "Remaja"
    case "dewasa":
        return "Dewasa"
    case "lansia":
        return "Lansia"
    default:
        return kelompok
    }
}

func getStringValue(s *string) string {
    if s == nil {
        return ""
    }
    return *s
}