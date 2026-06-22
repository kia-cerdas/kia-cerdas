package usecases

import (
	"errors"
	"time"

	"monitoring-service/app/models"
	"monitoring-service/app/repositories"
)

// Struktur data untuk aturan gejala
type RuleGejala struct {
	Bobot    int
	Tindakan string
}

// Daftar aturan berdasarkan Tabel 12.1
var AturanGejala = map[string]RuleGejala{
	// Kategori: Demam
	"suhu_c_lebih_39_5":   {Bobot: 3, Tindakan: "SEGERA ke IGD / hubungi 119"},
	"suhu_c_38_5_sd_39_4": {Bobot: 2, Tindakan: "Ke Puskesmas hari ini"},
	"demam_hari_lebih_3":  {Bobot: 2, Tindakan: "Periksa ke Puskesmas"},

	// Kategori: Diare
	"diare_berdarah":    {Bobot: 3, Tindakan: "SEGERA ke IGD"},
	"dehidrasi":         {Bobot: 3, Tindakan: "SEGERA ke IGD, berikan oralit sambil menuju"},
	"diare_kali_hari_5": {Bobot: 2, Tindakan: "Berikan oralit + ke Puskesmas"},

	// Kategori: Kejang & Kesadaran
	"kejang":            {Bobot: 3, Tindakan: "DARURAT — panggil kader + 119 sekarang"},
	"tidak_sadar_lemas": {Bobot: 3, Tindakan: "DARURAT — 119 / IGD terdekat"},

	// Kategori: Pernapasan
	"napas_cepat_sesak":   {Bobot: 2, Tindakan: "Ke Puskesmas hari ini"},
	"tidak_mau_minum_asi": {Bobot: 2, Tindakan: "Periksa ke Puskesmas"},

	// Kategori: Kulit
	"ruam_menyebar":       {Bobot: 2, Tindakan: "Periksa ke Puskesmas"},
	"kuning_sklera_kulit": {Bobot: 2, Tindakan: "Periksa ke Puskesmas hari ini"},
}

type GejalaDaruratAnakUsecase interface {
	ProsesDeteksi(req *models.DeteksiDaruratRequest) (*models.RiwayatDeteksi, error)
	GetRiwayatAnak(anakID uint) ([]models.RiwayatDeteksi, error)
}

type gejalaDaruratAnakUsecase struct {
	repo repositories.GejalaDaruratAnakRepository
}

func NewGejalaDaruratAnakUsecase(repo repositories.GejalaDaruratAnakRepository) GejalaDaruratAnakUsecase {
	return &gejalaDaruratAnakUsecase{repo: repo}
}

func (u *gejalaDaruratAnakUsecase) ProsesDeteksi(req *models.DeteksiDaruratRequest) (*models.RiwayatDeteksi, error) {
	if err := req.Validate(); err != nil {
		return nil, err
	}

	tanggalPeriksa, err := time.Parse("2006-01-02", req.TanggalPeriksa)
	if err != nil {
		return nil, errors.New("format tanggal tidak valid")
	}

	maxBobot := 0
	totalBobot := 0
	adaBobot3 := false

	var detailJawaban []models.DetailDeteksi

	for _, gejalaReq := range req.DaftarGejala {
		detail := models.DetailDeteksi{
			KodeGejala: gejalaReq.KodeGejala,
			IsTerjadi:  gejalaReq.IsTerjadi,
		}
		detailJawaban = append(detailJawaban, detail)

		if !gejalaReq.IsTerjadi {
			continue
		}

		rule, exists := AturanGejala[gejalaReq.KodeGejala]
		if !exists {
			continue
		}

		totalBobot += rule.Bobot

		if rule.Bobot > maxBobot {
			maxBobot = rule.Bobot
		}

		if rule.Bobot == 3 {
			adaBobot3 = true
		}
	}

	var tindakanGabungan string

	if adaBobot3 {
		tindakanGabungan = "DARURAT - Segera ke IGD / Hubungi 119"
	} else {
		tindakanGabungan = "Periksa ke Puskesmas"
	}

	riwayat := &models.RiwayatDeteksi{
		AnakID:         req.AnakID,
		TanggalPeriksa: &tanggalPeriksa,
		TotalBobotMax:  maxBobot,
		Tindakan:       tindakanGabungan,
		DetailJawaban:  detailJawaban,
	}

	if err := u.repo.Create(riwayat); err != nil {
		return nil, err
	}

	return riwayat, nil
}

func (u *gejalaDaruratAnakUsecase) GetRiwayatAnak(anakID uint) ([]models.RiwayatDeteksi, error) {
	return u.repo.GetByAnakID(anakID)
}
