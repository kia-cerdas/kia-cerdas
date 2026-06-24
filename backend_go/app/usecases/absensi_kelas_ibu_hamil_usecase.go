package usecases

import (
	"errors"
	"monitoring-service/app/models"
	"monitoring-service/app/repositories"
	"time"
)

type AbsensiKelasIbuHamilUsecase interface {
	GetMine(userID int32) ([]models.AbsensiKelasIbuHamil, error)
	SaveMine(userID int32, req models.AbsensiKelasIbuHamil) (*models.AbsensiKelasIbuHamil, error)
	// Kaader
	GetAll() ([]models.AbsensiKelasIbuHamil, error) 
	Verify(id int32, namaKader string, tanggalParaf *time.Time) error
	// FIX: Reject WAJIB dideklarasikan di interface juga,
	// karena controller memanggil c.usecase.Reject(...) lewat tipe interface ini.
	Reject(id int32) error
}

type absensiKelasIbuHamilUsecase struct {
	repo *repositories.AbsensiKelasIbuHamilRepository
}

func NewAbsensiKelasIbuHamilUsecase(
	repo *repositories.AbsensiKelasIbuHamilRepository,
) AbsensiKelasIbuHamilUsecase {
	return &absensiKelasIbuHamilUsecase{repo: repo}
}

func (u *absensiKelasIbuHamilUsecase) GetMine(
	userID int32,
) ([]models.AbsensiKelasIbuHamil, error) {
	if userID == 0 {
		return nil, errors.New("user_id tidak valid")
	}

	kehamilan, err := u.repo.FindActiveKehamilanByUserID(userID)
	if err != nil {
		return nil, errors.New("kehamilan aktif tidak ditemukan")
	}

	return u.repo.FindByKehamilanID(kehamilan.ID)
}

func (u *absensiKelasIbuHamilUsecase) SaveMine(
	userID int32,
	req models.AbsensiKelasIbuHamil,
) (*models.AbsensiKelasIbuHamil, error) {
	if userID == 0 {
		return nil, errors.New("user_id tidak valid")
	}

	// if req.PertemuanKe < 1 || req.PertemuanKe > 9 {
	// 	return nil, errors.New("pertemuan_ke harus antara 1 sampai 9")
	// }

	// kehamilan, err := u.repo.FindActiveKehamilanByUserID(userID)
	// if err != nil {
	// 	return nil, errors.New("kehamilan aktif tidak ditemukan")
	// }

	// existing, err := u.repo.FindByKehamilanIDAndPertemuanKe(kehamilan.ID, req.PertemuanKe)
	// if err == nil && existing != nil {
	// 	if existing.Status == "Terverifikasi" {
	// 		return nil, errors.New("sesi ini sudah terverifikasi dan tidak dapat diubah kembali")
	// 	}
	// }

	// data := &models.AbsensiKelasIbuHamil{
	// 	KehamilanID:  kehamilan.ID,
	// 	PertemuanKe:  req.PertemuanKe,
	// 	Tanggal:      req.Tanggal,
	// 	NamaKader:    req.NamaKader,
	// 	TanggalParaf: req.TanggalParaf,
	// }

	// if err := u.repo.Upsert(data); err != nil {
	// 	return nil, err
	// }

	// return data, nil

	// Cari kehamilan aktif milik ibu (tidak diubah)
	kehamilan, err := u.repo.FindActiveKehamilanByUserID(userID)
	if err != nil {
		return nil, errors.New("kehamilan aktif tidak ditemukan")
	}

	// Ambil semua absensi yang sudah ada untuk kehamilan ini
	existingList, err := u.repo.FindByKehamilanID(kehamilan.ID)
	if err != nil {
		return nil, err
	}

	// Aturan "buku tamu": tidak boleh kirim baru kalau masih ada
	// yang menunggu verifikasi kader. Sama seperti pola Balita.
	for _, a := range existingList {
		if a.Status == "Menunggu Verifikasi" {
			return nil, errors.New("masih ada absensi yang belum diverifikasi kader, silakan tunggu verifikasi terlebih dahulu")
		}
	}

	// Untuk atur duplikasi tanggal di absensi kelas ibu hamil
	if req.Tanggal != nil {
		reqDateStr := req.Tanggal.Format("2006-01-02")
		for _, a := range existingList {
			if a.Tanggal != nil && a.Tanggal.Format("2006-01-02") == reqDateStr {
				return nil, errors.New("absensi untuk tanggal ini sudah pernah dicatat")
			}
		}
	}

	// Nomor pertemuan dihitung otomatis dari jumlah data yang sudah ada.
	// Tidak ada lagi batas maksimal 9.
	data := &models.AbsensiKelasIbuHamil{
		KehamilanID:  kehamilan.ID,
		PertemuanKe:  int32(len(existingList) + 1),
		Tanggal:      req.Tanggal,
		NamaKader:    req.NamaKader,
		TanggalParaf: req.TanggalParaf,
	}

	// Pakai Create (data selalu baru, bukan menimpa slot lama)
	if err := u.repo.Create(data); err != nil {
		return nil, err
	}

	return data, nil
}


// BAGIAN KADER

func (u *absensiKelasIbuHamilUsecase) GetAll() ([]models.AbsensiKelasIbuHamil, error) {
	return u.repo.FindAllWithIbu()
}
 
func (u *absensiKelasIbuHamilUsecase) Verify(id int32, namaKader string, tanggalParaf *time.Time) error {
	data, err := u.repo.FindByID(id)
	if err != nil {
		return errors.New("data absensi tidak ditemukan")
	}

	if data.Status == "Terverifikasi" {
		return errors.New("absensi ini sudah terverifikasi dan tidak dapat diubah kembali")
	}
 
	data.NamaKader = namaKader
	data.TanggalParaf = tanggalParaf
	data.Status = "Terverifikasi"
 
	return u.repo.Update(data)
}

// Untuk absensi kelas ibu hamil
func (u *absensiKelasIbuHamilUsecase) Reject(id int32) error {
    data, err := u.repo.FindByID(id)
    if err != nil {
        return errors.New("data absensi tidak ditemukan")
    }

    if data.Status == "Terverifikasi" {
        return errors.New("absensi ini sudah terverifikasi dan tidak dapat diubah kembali")
    }

    data.Status = "Ditolak"

    return u.repo.Update(data)
}