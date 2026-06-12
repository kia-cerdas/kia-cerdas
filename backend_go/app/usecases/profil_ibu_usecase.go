// // app/usecases/profil_ibu_usecase.go
// package usecases

// import (
// 	"errors"
// 	"monitoring-service/app/models"
// 	"monitoring-service/app/repositories"
// )

// // ─── Response DTO ─────────────────────────────────────────────────────────────

// type ProfilIbuResponse struct {
// 	UserID           int32                     `json:"user_id"`
// 	Email            string                    `json:"email"`
// 	NomorTelepon     string                    `json:"nomor_telepon"`
// 	NIK              string                    `json:"nik"`
// 	NamaLengkap      string                    `json:"nama_lengkap"`
// 	TempatLahir      string                    `json:"tempat_lahir"`
// 	TanggalLahir     string                    `json:"tanggal_lahir"`
// 	GolonganDarah    string                    `json:"golongan_darah"`
// 	Agama            string                    `json:"agama"`
// 	Pendidikan       string                    `json:"pendidikan_terakhir"`
// 	Pekerjaan        string                    `json:"pekerjaan"`
// 	StatusPerkawinan string                    `json:"status_perkawinan"`
// 	Dusun            string                    `json:"dusun"`
// 	Desa             string                    `json:"desa"`
// 	Kecamatan        string                    `json:"kecamatan"`
// 	IbuID            int32                     `json:"ibu_id"`
// 	StatusKehamilan  string                    `json:"status_kehamilan"`
// 	RiwayatKehamilan []RiwayatKehamilanSingkat `json:"riwayat_kehamilan"`
// }

// // RiwayatPersalinanSebelumnya merepresentasikan satu entri persalinan lalu
// // yang diambil dari tabel riwayat_kehamilan_lalu (via evaluasi_kesehatan_ibu).
// type RiwayatPersalinanSebelumnya struct {
// 	NoUrut                   int    `json:"no_urut"`
// 	Tahun                    int    `json:"tahun"`
// 	ProsesMelahirkan         string `json:"proses_melahirkan"`          // normal / caesar / keguguran / dll
// 	PenolongProsesMelahirkan string `json:"penolong_proses_melahirkan"` // bidan / dokter / dll
// 	Masalah                  string `json:"masalah"`
// 	BBGram                   int    `json:"bb_gram"`
// }

// type RiwayatKehamilanSingkat struct {
// 	ID                       int32   `json:"id"`
// 	Gravida                  int32   `json:"gravida"`
// 	Paritas                  int32   `json:"paritas"`
// 	Abortus                  int32   `json:"abortus"`
// 	HPHT                     string  `json:"hpht"`
// 	TaksiranPersalinan       string  `json:"taksiran_persalinan"`
// 	StatusKehamilan          string  `json:"status_kehamilan"`
// 	BBawal                   float64 `json:"bb_awal"`
// 	TB                       float64 `json:"tb"`
// 	IMTAwal                  float64 `json:"imt_awal"`
// 	JarakKehamilanSebelumnya int32   `json:"jarak_kehamilan_sebelumnya"`

// 	// Riwayat persalinan sebelumnya (dari tabel riwayat_kehamilan_lalu via evaluasi)
// 	RiwayatPersalinanSebelumnya []RiwayatPersalinanSebelumnya `json:"riwayat_persalinan_sebelumnya"`
// }

// // ─── Interface & Implementasi ──────────────────────────────────────────────────

// type ProfilIbuUsecase interface {
// 	GetProfilSaya(userID int32) (*ProfilIbuResponse, error)
// }

// type profilIbuUsecase struct {
// 	userRepo             *repositories.UserRepository
// 	ibuRepo              *repositories.IbuRepository
// 	kehamilanRepo        *repositories.KehamilanRepository
// 	evaluasiRepo         *repositories.EvaluasiKesehatanIbuRepository
// 	riwayatKehamilanRepo *repositories.RiwayatKehamilanLaluRepository
// }

// func NewProfilIbuUsecase(
// 	userRepo *repositories.UserRepository,
// 	ibuRepo *repositories.IbuRepository,
// 	kehamilanRepo *repositories.KehamilanRepository,
// 	evaluasiRepo *repositories.EvaluasiKesehatanIbuRepository,
// 	riwayatKehamilanRepo *repositories.RiwayatKehamilanLaluRepository,
// ) ProfilIbuUsecase {
// 	return &profilIbuUsecase{
// 		userRepo:             userRepo,
// 		ibuRepo:              ibuRepo,
// 		kehamilanRepo:        kehamilanRepo,
// 		evaluasiRepo:         evaluasiRepo,
// 		riwayatKehamilanRepo: riwayatKehamilanRepo,
// 	}
// }

// func (u *profilIbuUsecase) GetProfilSaya(userID int32) (*ProfilIbuResponse, error) {
// 	// 1. Ambil data user
// 	user, err := u.userRepo.FindByID(userID)
// 	if err != nil {
// 		return nil, errors.New("data pengguna tidak ditemukan")
// 	}

// 	if user.PendudukID == nil {
// 		return nil, errors.New("akun belum terhubung dengan data kependudukan")
// 	}

// 	// 2. Ambil data ibu by penduduk_id (sudah Preload Kependudukan)
// 	ibu, err := u.ibuRepo.FindByPendudukID(int32(*user.PendudukID))
// 	if err != nil {
// 		return nil, errors.New("data ibu tidak ditemukan")
// 	}

// 	// 3. Ambil riwayat kehamilan
// 	kehamilanList, err := u.kehamilanRepo.FindByIbuID(ibu.IDIbu)
// 	if err != nil {
// 		kehamilanList = []models.Kehamilan{}
// 	}

// 	// 4. Susun response dasar
// 	resp := &ProfilIbuResponse{
// 		UserID:       user.ID,
// 		Email:        user.Email,
// 		NomorTelepon: "",
// 		IbuID:        ibu.IDIbu,
// 	}

// 	// 5. Isi dari Kependudukan
// 	if ibu.Kependudukan != nil {
// 		k := ibu.Kependudukan
// 		resp.NomorTelepon = k.Telepon
// 		if k.NIK != nil {
// 			resp.NIK = *k.NIK
// 		}
// 		resp.NamaLengkap = k.NamaLengkap
// 		resp.TempatLahir = k.TempatLahir
// 		if !k.TanggalLahir.IsZero() {
// 			resp.TanggalLahir = k.TanggalLahir.Format("2006-01-02")
// 		}
// 		resp.GolonganDarah = k.GolonganDarah
// 		resp.Agama = k.Agama
// 		resp.Pendidikan = k.PendidikanTerakhir
// 		resp.Pekerjaan = k.Pekerjaan
// 		resp.StatusPerkawinan = k.StatusPerkawinan
// 		resp.Dusun = k.Dusun
// 		// resp.Desa = k.Desa
// 		resp.Kecamatan = k.Kecamatan
// 	}

// 	// 6. Susun riwayat kehamilan beserta riwayat persalinan sebelumnya
// 	riwayat := make([]RiwayatKehamilanSingkat, 0, len(kehamilanList))
// 	for _, kh := range kehamilanList {
// 		item := RiwayatKehamilanSingkat{
// 			ID:                          kh.ID,
// 			Gravida:                     kh.Gravida,
// 			Paritas:                     kh.Paritas,
// 			Abortus:                     kh.Abortus,
// 			StatusKehamilan:             kh.StatusKehamilan,
// 			BBawal:                      kh.BB_Awal,
// 			TB:                          kh.TB,
// 			IMTAwal:                     kh.IMT_Awal,
// 			JarakKehamilanSebelumnya:    kh.JarakKehamilanSebelumnya,
// 			RiwayatPersalinanSebelumnya: []RiwayatPersalinanSebelumnya{},
// 		}
// 		if !kh.HPHT.IsZero() {
// 			item.HPHT = kh.HPHT.Format("2006-01-02")
// 		}
// 		if !kh.TaksiranPersalinan.IsZero() {
// 			item.TaksiranPersalinan = kh.TaksiranPersalinan.Format("2006-01-02")
// 		}

// 		// 6a. Ambil evaluasi kesehatan ibu milik kehamilan ini
// 		//     lalu tarik riwayat_kehamilan_lalu dari setiap evaluasi
// 		evaluasiList, errEval := u.evaluasiRepo.FindByKehamilanID(kh.ID)
// 		if errEval == nil && len(evaluasiList) > 0 {
// 			for _, eval := range evaluasiList {
// 				rkList, errRk := u.riwayatKehamilanRepo.FindByEvaluasiID(eval.ID)
// 				if errRk != nil || len(rkList) == 0 {
// 					continue
// 				}
// 				for _, rk := range rkList {
// 					item.RiwayatPersalinanSebelumnya = append(
// 						item.RiwayatPersalinanSebelumnya,
// 						RiwayatPersalinanSebelumnya{
// 							NoUrut:                   rk.NoUrut,
// 							Tahun:                    rk.Tahun,
// 							ProsesMelahirkan:         rk.ProsesMelahirkan,
// 							PenolongProsesMelahirkan: rk.PenolongProsesMelahirkan,
// 							Masalah:                  rk.Masalah,
// 							BBGram:                   rk.BGGram,
// 						},
// 					)
// 				}
// 			}
// 		}

// 		// Update status kehamilan aktif terakhir untuk header profil
// 		if kh.StatusKehamilan != "" && kh.StatusKehamilan != "NON-AKTIF" {
// 			resp.StatusKehamilan = kh.StatusKehamilan
// 		}

// 		riwayat = append(riwayat, item)
// 	}
// 	resp.RiwayatKehamilan = riwayat

// 	return resp, nil
// }


// app/usecases/profil_ibu_usecase.go
package usecases

import (
	"errors"
	"monitoring-service/app/models"
	"monitoring-service/app/repositories"
)

// ─── Response DTO ─────────────────────────────────────────────────────────────

type ProfilIbuResponse struct {
	UserID           int32                     `json:"user_id"`
	Email            string                    `json:"email"`
	NomorTelepon     string                    `json:"nomor_telepon"`
	NIK              string                    `json:"nik"`
	NamaLengkap      string                    `json:"nama_lengkap"`
	TempatLahir      string                    `json:"tempat_lahir"`
	TanggalLahir     string                    `json:"tanggal_lahir"`
	GolonganDarah    string                    `json:"golongan_darah"`
	Agama            string                    `json:"agama"`
	Pendidikan       string                    `json:"pendidikan_terakhir"`
	Pekerjaan        string                    `json:"pekerjaan"`
	StatusPerkawinan string                    `json:"status_perkawinan"`
	Dusun            string                    `json:"dusun"`
	Desa             string                    `json:"desa"`
	Kecamatan        string                    `json:"kecamatan"`
	IbuID            int32                     `json:"ibu_id"`
	StatusKehamilan  string                    `json:"status_kehamilan"`
	RiwayatKehamilan []RiwayatKehamilanSingkat `json:"riwayat_kehamilan"`
}

// RiwayatPersalinanSebelumnya merepresentasikan satu entri persalinan lalu
// yang diambil dari tabel riwayat_kehamilan_lalu (via evaluasi_kesehatan_ibu).
type RiwayatPersalinanSebelumnya struct {
	NoUrut                   int    `json:"no_urut"`
	Tahun                    int    `json:"tahun"`
	ProsesMelahirkan         string `json:"proses_melahirkan"`          // normal / caesar / keguguran / dll
	PenolongProsesMelahirkan string `json:"penolong_proses_melahirkan"` // bidan / dokter / dll
	Masalah                  string `json:"masalah"`
	BBGram                   int    `json:"bb_gram"`
}

type RiwayatKehamilanSingkat struct {
	ID                       int32   `json:"id"`
	Gravida                  int32   `json:"gravida"`
	Paritas                  int32   `json:"paritas"`
	Abortus                  int32   `json:"abortus"`
	HPHT                     string  `json:"hpht"`
	TaksiranPersalinan       string  `json:"taksiran_persalinan"`
	StatusKehamilan          string  `json:"status_kehamilan"`
	BBawal                   float64 `json:"bb_awal"`
	TB                       float64 `json:"tb"`
	IMTAwal                  float64 `json:"imt_awal"`
	JarakKehamilanSebelumnya int32   `json:"jarak_kehamilan_sebelumnya"`

	// Riwayat persalinan sebelumnya (dari tabel riwayat_kehamilan_lalu via evaluasi)
	RiwayatPersalinanSebelumnya []RiwayatPersalinanSebelumnya `json:"riwayat_persalinan_sebelumnya"`
}

// ─── Interface & Implementasi ──────────────────────────────────────────────────

type ProfilIbuUsecase interface {
	GetProfilSaya(userID int32) (*ProfilIbuResponse, error)
}

type profilIbuUsecase struct {
	userRepo             *repositories.UserRepository
	ibuRepo              *repositories.IbuRepository
	kehamilanRepo        *repositories.KehamilanRepository
	evaluasiRepo         *repositories.EvaluasiKesehatanIbuRepository
	riwayatKehamilanRepo *repositories.RiwayatKehamilanLaluRepository
	desaRepo             *repositories.DesaRepository
}

func NewProfilIbuUsecase(
	userRepo *repositories.UserRepository,
	ibuRepo *repositories.IbuRepository,
	kehamilanRepo *repositories.KehamilanRepository,
	evaluasiRepo *repositories.EvaluasiKesehatanIbuRepository,
	riwayatKehamilanRepo *repositories.RiwayatKehamilanLaluRepository,
	desaRepo *repositories.DesaRepository,
) ProfilIbuUsecase {
	return &profilIbuUsecase{
		userRepo:             userRepo,
		ibuRepo:              ibuRepo,
		kehamilanRepo:        kehamilanRepo,
		evaluasiRepo:         evaluasiRepo,
		riwayatKehamilanRepo: riwayatKehamilanRepo,
		desaRepo:             desaRepo,
	}
}

func (u *profilIbuUsecase) GetProfilSaya(userID int32) (*ProfilIbuResponse, error) {
	// 1. Ambil data user
	user, err := u.userRepo.FindByID(userID)
	if err != nil {
		return nil, errors.New("data pengguna tidak ditemukan")
	}

	if user.PendudukID == nil {
		return nil, errors.New("akun belum terhubung dengan data kependudukan")
	}

	// 2. Ambil data ibu by penduduk_id (sudah Preload Kependudukan)
	ibu, err := u.ibuRepo.FindByPendudukID(int32(*user.PendudukID))
	if err != nil {
		return nil, errors.New("data ibu tidak ditemukan")
	}

	// 3. Ambil riwayat kehamilan
	kehamilanList, err := u.kehamilanRepo.FindByIbuID(ibu.IDIbu)
	if err != nil {
		kehamilanList = []models.Kehamilan{}
	}

	// 4. Susun response dasar
	resp := &ProfilIbuResponse{
		UserID:       user.ID,
		Email:        user.Email,
		NomorTelepon: "",
		IbuID:        ibu.IDIbu,
	}

	// 5. Isi dari Kependudukan
	if ibu.Kependudukan != nil {
		k := ibu.Kependudukan
		resp.NomorTelepon = k.Telepon
		if k.NIK != nil {
			resp.NIK = *k.NIK
		}
		resp.NamaLengkap = k.NamaLengkap
		resp.TempatLahir = k.TempatLahir
		if !k.TanggalLahir.IsZero() {
			resp.TanggalLahir = k.TanggalLahir.Format("2006-01-02")
		}
		resp.GolonganDarah = k.GolonganDarah
		resp.Agama = k.Agama
		resp.Pendidikan = k.PendidikanTerakhir
		resp.Pekerjaan = k.Pekerjaan
		resp.StatusPerkawinan = k.StatusPerkawinan
		resp.Dusun = k.Dusun
		if k.DesaID != nil {
			if desa, err := u.desaRepo.FindByID(*k.DesaID); err == nil && desa != nil {
				resp.Desa = desa.NamaDesa
			}
		}
		resp.Kecamatan = k.Kecamatan
	}

	// 6. Susun riwayat kehamilan beserta riwayat persalinan sebelumnya
	riwayat := make([]RiwayatKehamilanSingkat, 0, len(kehamilanList))
	for _, kh := range kehamilanList {
		item := RiwayatKehamilanSingkat{
			ID:                          kh.ID,
			Gravida:                     kh.Gravida,
			Paritas:                     kh.Paritas,
			Abortus:                     kh.Abortus,
			StatusKehamilan:             kh.StatusKehamilan,
			BBawal:                      kh.BB_Awal,
			TB:                          kh.TB,
			IMTAwal:                     kh.IMT_Awal,
			JarakKehamilanSebelumnya:    kh.JarakKehamilanSebelumnya,
			RiwayatPersalinanSebelumnya: []RiwayatPersalinanSebelumnya{},
		}
		if !kh.HPHT.IsZero() {
			item.HPHT = kh.HPHT.Format("2006-01-02")
		}
		if !kh.TaksiranPersalinan.IsZero() {
			item.TaksiranPersalinan = kh.TaksiranPersalinan.Format("2006-01-02")
		}

		// 6a. Ambil evaluasi kesehatan ibu milik kehamilan ini
		//     lalu tarik riwayat_kehamilan_lalu dari setiap evaluasi
		evaluasiList, errEval := u.evaluasiRepo.FindByKehamilanID(kh.ID)
		if errEval == nil && len(evaluasiList) > 0 {
			for _, eval := range evaluasiList {
				rkList, errRk := u.riwayatKehamilanRepo.FindByEvaluasiID(eval.ID)
				if errRk != nil || len(rkList) == 0 {
					continue
				}
				for _, rk := range rkList {
					item.RiwayatPersalinanSebelumnya = append(
						item.RiwayatPersalinanSebelumnya,
						RiwayatPersalinanSebelumnya{
							NoUrut:                   rk.NoUrut,
							Tahun:                    rk.Tahun,
							ProsesMelahirkan:         rk.ProsesMelahirkan,
							PenolongProsesMelahirkan: rk.PenolongProsesMelahirkan,
							Masalah:                  rk.Masalah,
							BBGram:                   rk.BGGram,
						},
					)
				}
			}
		}

		// Update status kehamilan aktif terakhir untuk header profil
		if kh.StatusKehamilan != "" && kh.StatusKehamilan != "NON-AKTIF" {
			resp.StatusKehamilan = kh.StatusKehamilan
		}

		riwayat = append(riwayat, item)
	}
	resp.RiwayatKehamilan = riwayat

	return resp, nil
}