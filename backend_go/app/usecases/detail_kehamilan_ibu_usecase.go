// app/usecases/detail_kehamilan_ibu_usecase.go
// [SCOPE: modul-ibu / profil / riwayat-kehamilan]
// Usecase baru — HANYA TAMBAH, tidak mengubah usecase lain.
// Mengagregasi data dari berbagai tabel berdasarkan kehamilan_id
// untuk ditampilkan di halaman detail riwayat kehamilan ibu.
package usecases

import (
	"errors"
	"monitoring-service/app/models"
	"monitoring-service/app/repositories"
)

// ─── Response DTO ─────────────────────────────────────────────────────────────

// DetailKehamilanResponse adalah agregasi lengkap satu kehamilan.
type DetailKehamilanResponse struct {
	// Info dasar kehamilan
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

	// Skrining preeklampsia (bisa nil jika belum diisi)
	SkriningPreeklampsia *models.SkriningPreeklampsia `json:"skrining_preeklampsia"`

	// Grafik evaluasi kehamilan (BB, DJJ, TFU, tekanan darah, dll)
	GrafikEvaluasi []models.GrafikEvaluasiKehamilan `json:"grafik_evaluasi"`

	// Grafik peningkatan BB
	GrafikBB []models.GrafikPeningkatanBB `json:"grafik_bb"`

	// Ringkasan persalinan (bisa kosong jika belum melahirkan)
	RingkasanPersalinan *models.RingkasanPelayananPersalinan `json:"ringkasan_persalinan"`
}

// ─── Interface ────────────────────────────────────────────────────────────────

type DetailKehamilanIbuUsecase interface {
	// GetDetail mengambil detail lengkap satu kehamilan berdasarkan kehamilanID.
	// Memverifikasi bahwa kehamilan tersebut memang milik userID yang login.
	GetDetail(kehamilanID int32, userID int32) (*DetailKehamilanResponse, error)
}

// ─── Implementasi ─────────────────────────────────────────────────────────────

type detailKehamilanIbuUsecase struct {
	kehamilanRepo    *repositories.KehamilanRepository
	skriningRepo     *repositories.SkriningPreeklampsiaRepository
	grafikRepo       *repositories.GrafikEvaluasiKehamilanRepository
	grafikBBRepo     *repositories.GrafikPeningkatanBBRepository
	persalinanRepo   *repositories.RingkasanPelayananPersalinanRepository
	ibuRepo          *repositories.IbuRepository
	userRepo         *repositories.UserRepository
}

func NewDetailKehamilanIbuUsecase(
	kehamilanRepo *repositories.KehamilanRepository,
	skriningRepo *repositories.SkriningPreeklampsiaRepository,
	grafikRepo *repositories.GrafikEvaluasiKehamilanRepository,
	grafikBBRepo *repositories.GrafikPeningkatanBBRepository,
	persalinanRepo *repositories.RingkasanPelayananPersalinanRepository,
	ibuRepo *repositories.IbuRepository,
	userRepo *repositories.UserRepository,
) DetailKehamilanIbuUsecase {
	return &detailKehamilanIbuUsecase{
		kehamilanRepo:  kehamilanRepo,
		skriningRepo:   skriningRepo,
		grafikRepo:     grafikRepo,
		grafikBBRepo:   grafikBBRepo,
		persalinanRepo: persalinanRepo,
		ibuRepo:        ibuRepo,
		userRepo:       userRepo,
	}
}

func (u *detailKehamilanIbuUsecase) GetDetail(kehamilanID int32, userID int32) (*DetailKehamilanResponse, error) {
	// 1. Ambil kehamilan
	kehamilan, err := u.kehamilanRepo.FindByID(kehamilanID)
	if err != nil {
		return nil, errors.New("data kehamilan tidak ditemukan")
	}

	// 2. Verifikasi kepemilikan: pastikan kehamilan ini milik user yang login
	user, err := u.userRepo.FindByID(userID)
	if err != nil || user.PendudukID == nil {
		return nil, errors.New("data pengguna tidak ditemukan")
	}
	ibu, err := u.ibuRepo.FindByPendudukID(int32(*user.PendudukID))
	if err != nil {
		return nil, errors.New("data ibu tidak ditemukan")
	}
	if kehamilan.IbuID != ibu.IDIbu {
		return nil, errors.New("akses ditolak: kehamilan bukan milik pengguna ini")
	}

	// 3. Susun response dasar dari kehamilan
	resp := &DetailKehamilanResponse{
		ID:                       kehamilan.ID,
		Gravida:                  kehamilan.Gravida,
		Paritas:                  kehamilan.Paritas,
		Abortus:                  kehamilan.Abortus,
		StatusKehamilan:          kehamilan.StatusKehamilan,
		BBawal:                   kehamilan.BB_Awal,
		TB:                       kehamilan.TB,
		IMTAwal:                  kehamilan.IMT_Awal,
		JarakKehamilanSebelumnya: kehamilan.JarakKehamilanSebelumnya,
	}
	if !kehamilan.HPHT.IsZero() {
		resp.HPHT = kehamilan.HPHT.Format("2006-01-02")
	}
	if !kehamilan.TaksiranPersalinan.IsZero() {
		resp.TaksiranPersalinan = kehamilan.TaksiranPersalinan.Format("2006-01-02")
	}

	// 4. Skrining preeklampsia (ambil pertama jika ada banyak)
	skriningList, err := u.skriningRepo.FindByKehamilanID(kehamilanID)
	if err == nil && len(skriningList) > 0 {
		resp.SkriningPreeklampsia = &skriningList[0]
	}

	// 5. Grafik evaluasi kehamilan (BB/DJJ/TFU/tekanan darah)
	grafik, err := u.grafikRepo.FindByKehamilanID(kehamilanID)
	if err == nil {
		resp.GrafikEvaluasi = grafik
	} else {
		resp.GrafikEvaluasi = []models.GrafikEvaluasiKehamilan{}
	}

	// 6. Grafik peningkatan BB
	grafikBB, err := u.grafikBBRepo.FindByKehamilanID(kehamilanID)
	if err == nil {
		resp.GrafikBB = grafikBB
	} else {
		resp.GrafikBB = []models.GrafikPeningkatanBB{}
	}

	// 7. Ringkasan persalinan
	persalinanList, err := u.persalinanRepo.FindByKehamilanID(kehamilanID)
	if err == nil && len(persalinanList) > 0 {
		resp.RingkasanPersalinan = &persalinanList[0]
	}

	return resp, nil
}