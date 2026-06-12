package usecases

import (
	"encoding/json"
	"errors"
	"fmt"
	"monitoring-service/app/models"
	"monitoring-service/app/repositories"
	"time"

	"gorm.io/datatypes"
)

type KunjunganGiziUseCase interface {
	Create(req models.CreatePelayananGiziRequest) error
	GetByAnakID(anakID int32) ([]models.KunjunganGizi, error)
	GetByID(id int32) (*models.KunjunganGizi, error)
	GetAll() ([]models.KunjunganGizi, error)
	Update(id int32, req models.UpdatePelayananGiziRequest) error
	Delete(id int32) error
}
type kunjunganGiziUsecase struct {
	PelayananGiziRepo repositories.KunjunganGiziRepository
}

func NewKunjunganGiziUseCase(repo repositories.KunjunganGiziRepository) KunjunganGiziUseCase {
	return &kunjunganGiziUsecase{PelayananGiziRepo: repo}
}

func (uc *kunjunganGiziUsecase) Create(req models.CreatePelayananGiziRequest) error {

	fmt.Printf("[Gizi UC] Create called: AnakID=%d, Bulanke=%d, Tanggal=%s, ObatCacing=%v, ASI=%v, MPASI=%v\n",
		req.AnakID, req.Bulanke, req.Tanggal, req.ObatCacing, req.ASI != nil, req.MPASI != nil)

	if req.AnakID == 0 {
		return errors.New("anak_id wajib di isi")
	}
	if req.TenagaKesehatanID == 0 {
		return errors.New("Tenaga Kesehtan wajib diisi")
	}
	if req.Tanggal == "" {
		return errors.New("tanggal wajib diisi")
	}
	if req.Lokasi == "" {
		return errors.New("lokasi wajib diisi")
	}
	if req.Bulanke < 6 && req.MPASI != nil && req.MPASI.DiberikanMPASI {
		return errors.New("makanan tambahan (MPASI) tidak boleh diberikan sebelum usia 6 bulan")
	}

	tanggal, err := time.Parse("2006-01-02", req.Tanggal)
	if err != nil {
		return fmt.Errorf("format tanggal harus YYYY-MM-DD")
	}

	existing, err := uc.PelayananGiziRepo.GetByAnakID(req.AnakID)
	if err == nil {
		for _, record := range existing {
			if record.Tanggal.Year() == tanggal.Year() && record.Tanggal.Month() == tanggal.Month() {
				return errors.New("pelayanan gizi untuk anak ini sudah diinput pada bulan ini")
			}
		}
	}

	now := time.Now()

	kunjungan := models.KunjunganGizi{
		AnakID:             req.AnakID,
		Bulanke:            req.Bulanke,
		TenagaKesehatanID:  req.TenagaKesehatanID,
		Tanggal:            tanggal,
		Lokasi:             req.Lokasi,
		ObatCacing:         req.ObatCacing,
		JenisPemberianSusu: req.JenisPemberianSusu,
		MasihMenyusui:      req.MasihMenyusui,
		MenggunakanFormula: req.MenggunakanFormula,
		AlasanFormula:      req.AlasanFormula,
		UsiaMulaiMpasi:     req.UsiaMulaiMpasi,
		CreatedAt:          now,
		UpdatedAt:          now,
	}

	if req.ASI != nil {
		kunjungan.ASI = &models.ASI{
			FrekuensiMenyusui: req.ASI.FrekuensiMenyusui,
			PosisiMenyusui:    req.ASI.PosisiMenyusui,
			ASIPerah:          req.ASI.ASIPerah,
			CreatedAt:         now,
			UpdatedAt:         now,
		}
	}

	if req.MPASI != nil {
		variasiJSON, err := json.Marshal(req.MPASI.VariasiMPASI)
		if err != nil {
			return errors.New("gagal encode variasi MPASI")
		}
		kunjungan.MPASI = &models.MPASI{
			DiberikanMPASI:      req.MPASI.DiberikanMPASI,
			VariasiMPASI:        datatypes.JSON(variasiJSON),
			JumlahmakanPerporsi: req.MPASI.JumlahMakanPerporsi,
			FrekuensiMakan:      req.MPASI.FrekuensiMakan,
			CreatedAt:           now,
			UpdatedAt:           now,
		}
	}

	fmt.Printf("[Gizi UC] Calling repo.Create...\n")
	return uc.PelayananGiziRepo.Create(&kunjungan)
}

func (uc *kunjunganGiziUsecase) GetByAnakID(anakID int32) ([]models.KunjunganGizi, error) {
	if anakID == 0 {
		return nil, errors.New("anak_id wajib diisi")
	}

	return uc.PelayananGiziRepo.GetByAnakID(anakID)
}

func (uc *kunjunganGiziUsecase) GetByID(id int32) (*models.KunjunganGizi, error) {
	if id == 0 {
		return nil, errors.New("id wajib diisi")
	}

	return uc.PelayananGiziRepo.GetByID(id)
}


func (uc *kunjunganGiziUsecase) GetAll() ([]models.KunjunganGizi, error) {
	return uc.PelayananGiziRepo.GetAll()
}

func (uc *kunjunganGiziUsecase) Update(id int32, req models.UpdatePelayananGiziRequest) error {

	tanggal, err := time.Parse("2006-01-02", req.Tanggal)
	if err != nil && req.Tanggal != "" {
		return fmt.Errorf("format tanggal harus YYYY-MM-DD")
	}

	now := time.Now()

	return uc.PelayananGiziRepo.Update(id, req, tanggal, now)
}


func (uc *kunjunganGiziUsecase) Delete(id int32) error {
	if id == 0 {
		return errors.New("id wajib di isi")
	}
	return uc.PelayananGiziRepo.Delete(id)

}
