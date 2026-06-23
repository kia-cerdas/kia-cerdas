package usecases

import (
	"errors"
	"monitoring-service/app/models"
	"monitoring-service/app/repositories"
	"monitoring-service/app/utils"
	"time"
)

type PendudukRiskUsecase interface {
	GetPendudukByRisk(kategori, risiko string, posyanduID *int32, role string) ([]models.PendudukRiskResponse, error)
}

type pendudukRiskUsecase struct {
	pemeriksaanRepo repositories.PemeriksaanRepository
	anakUseCase     *AnakUseCase
}

func NewPendudukRiskUsecase(pemeriksaanRepo repositories.PemeriksaanRepository, anakUseCase *AnakUseCase) PendudukRiskUsecase {
	return &pendudukRiskUsecase{
		pemeriksaanRepo: pemeriksaanRepo,
		anakUseCase:     anakUseCase,
	}
}

func (u *pendudukRiskUsecase) GetPendudukByRisk(kelompok, risiko string, posyanduID *int32, role string) ([]models.PendudukRiskResponse, error) {
	validKelompok := map[string]bool{"balita": true, "anak": true, "remaja": true, "dewasa": true, "lansia": true}
	if !validKelompok[kelompok] {
		return nil, errors.New("kelompok tidak valid. Gunakan: balita, anak, remaja, dewasa, lansia")
	}
	if risiko != "" {
		validRisk := map[string]bool{"Tinggi": true, "Sedang": true, "Normal": true}
		if !validRisk[risiko] {
			return nil, errors.New("risiko harus Tinggi, Sedang, atau Normal")
		}
	}

	if kelompok == "balita" {
		anaks, err := u.anakUseCase.ListAnakByDesa(posyanduID, 0)
		if err != nil {
			return nil, err
		}

		var result []models.PendudukRiskResponse
		for _, a := range anaks {
			tglLahir, parseErr := time.Parse("2006-01-02", a.TanggalLahir)
			if parseErr != nil {
				continue
			}
			umur := utils.HitungUmur(tglLahir)
			fiveYearsLater := tglLahir.AddDate(5, 0, 0)
			if !time.Now().After(fiveYearsLater) {
				var ris string
				switch a.StatusPrediksi {
				case "Stunting":
					ris = "Tinggi"
				case "Risiko Stunting":
					ris = "Sedang"
				default:
					ris = "Normal"
				}

				if risiko != "" && ris != risiko {
					continue
				}

				result = append(result, models.PendudukRiskResponse{
					ID:          a.PendudukID,
					NIK:         a.NIK,
					NamaLengkap: a.Nama,
					Dusun:       a.Dusun,
					Usia:        umur,
					Risiko:      ris,
				})
			}
		}
		return result, nil
	}

	return u.pemeriksaanRepo.GetPendudukByRisk(kelompok, risiko, posyanduID, role)
}