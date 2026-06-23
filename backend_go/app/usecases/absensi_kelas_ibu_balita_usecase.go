package usecases

import (
	"errors"
	"time"
	"monitoring-service/app/models"
	"monitoring-service/app/repositories"
)

type AbsensiKelasIbuBalitaUsecase interface {
	GetMine(userID int32) ([]models.AbsensiKelasIbuBalita, error)
	SaveMine(userID int32, req models.AbsensiKelasIbuBalita) (*models.AbsensiKelasIbuBalita, error)
	GetAll(posyanduID *int32) ([]models.AbsensiKelasIbuBalita, error)
	Verify(id int32, namaKader string, tanggalParaf *time.Time, status string) error
}

type absensiKelasIbuBalitaUsecase struct {
	repo *repositories.AbsensiKelasIbuBalitaRepository
}

func NewAbsensiKelasIbuBalitaUsecase(
	repo *repositories.AbsensiKelasIbuBalitaRepository,
) AbsensiKelasIbuBalitaUsecase {
	return &absensiKelasIbuBalitaUsecase{repo: repo}
}

func (u *absensiKelasIbuBalitaUsecase) GetMine(userID int32) ([]models.AbsensiKelasIbuBalita, error) {
	if userID == 0 {
		return nil, errors.New("user_id tidak valid")
	}

	ibuID, err := u.repo.FindIbuIDByUserID(userID)
	if err != nil {
		return nil, errors.New("data ibu tidak ditemukan")
	}

	return u.repo.FindByIbuID(ibuID)
}

func (u *absensiKelasIbuBalitaUsecase) SaveMine(
	userID int32,
	req models.AbsensiKelasIbuBalita,
) (*models.AbsensiKelasIbuBalita, error) {
	if userID == 0 {
		return nil, errors.New("user_id tidak valid")
	}

	ibuID, err := u.repo.FindIbuIDByUserID(userID)
	if err != nil {
		return nil, errors.New("data ibu tidak ditemukan")
	}

	// Hitung nomor pertemuan otomatis dari jumlah data yang sudah ada
	existing, err := u.repo.FindByIbuID(ibuID)
	if err != nil {
		return nil, err
	}

	//
	for _, a := range existing {
    if a.Status == "Menunggu Verifikasi" {
        return nil, errors.New("masih ada absensi yang belum diverifikasi kader, silakan tunggu verifikasi terlebih dahulu")
    }
}

	data := &models.AbsensiKelasIbuBalita{
		IbuID:        ibuID,
		PertemuanKe:  int32(len(existing) + 1),
		Tanggal:      req.Tanggal,
		NamaKader:    req.NamaKader,
		TanggalParaf: req.TanggalParaf,
	}

	if err := u.repo.Create(data); err != nil {
		return nil, err
	}

	return data, nil
}

func (u *absensiKelasIbuBalitaUsecase) GetAll(posyanduID *int32) ([]models.AbsensiKelasIbuBalita, error) {
	return u.repo.FindAllWithIbu(posyanduID)
}

func (u *absensiKelasIbuBalitaUsecase) Verify(id int32, namaKader string, tanggalParaf *time.Time, status string) error {
	data, err := u.repo.FindByID(id)
	if err != nil {
		return errors.New("data absensi tidak ditemukan")
	}

	// Status terminal yang sebenarnya dipakai kader adalah "Diterima"/"Ditolak"
	// (lihat VerifikasiAbsensiKelasIbuBalitaScreen di mobile), bukan "Terverifikasi" --
	// jadi guard ini harus memeriksa status apa pun selain "Menunggu Verifikasi".
	if data.Status != "" && data.Status != "Menunggu Verifikasi" {
		return errors.New("absensi ini sudah diverifikasi dan tidak dapat diubah kembali")
	}

	data.NamaKader = namaKader
	data.TanggalParaf = tanggalParaf
	data.Status = status

	return u.repo.Update(data)
}
