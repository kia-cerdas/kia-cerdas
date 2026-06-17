package usecases

import (
	"errors"
	"time"

	"monitoring-service/app/models"
	"monitoring-service/app/repositories"
)

type PemantauanIbuHamilUsecase interface {
	GetMine(userID int32) ([]models.PemantauanIbuHamil, error)
	SaveMine(userID int32, req models.PemantauanIbuHamil) (*models.PemantauanIbuHamil, error)
	// Kader
	GetAll() ([]models.PemantauanIbuHamil, error)
	Verify(id int32, namaKader string, tanggalVerifikasi *time.Time) error
	// Untuk profil pemantauan ibu
	GetByKehamilanID(userID int32, kehamilanID int32) ([]models.PemantauanIbuHamil, error)
}

type pemantauanIbuHamilUsecase struct {
	repo *repositories.PemantauanIbuHamilRepository
}

func NewPemantauanIbuHamilUsecase(repo *repositories.PemantauanIbuHamilRepository) PemantauanIbuHamilUsecase {
	return &pemantauanIbuHamilUsecase{repo: repo}
}

func (u *pemantauanIbuHamilUsecase) GetMine(userID int32) ([]models.PemantauanIbuHamil, error) {
	if userID == 0 {
		return nil, errors.New("user_id tidak valid")
	}

	kehamilan, err := u.repo.FindActiveKehamilanByUserID(userID)
	if err != nil {
		return nil, errors.New("kehamilan aktif tidak ditemukan")
	}

	return u.repo.FindByKehamilanID(kehamilan.ID)
}

// isAllowedToFill memeriksa apakah record boleh diisi:
// - Belum pernah diisi (created_at nil / record baru) → selalu boleh jika hari ini atau kemarin
// - Sudah pernah diisi → hanya boleh update jika created_at-nya hari ini atau kemarin
func isAllowedToFill(createdAt *time.Time) bool {
	loc := time.Local
	now := time.Now().In(loc)
	today := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, loc)
	yesterday := today.AddDate(0, 0, -1)

	if createdAt == nil {
		return true // data baru, diperbolehkan
	}

	recordDate := time.Date(
		createdAt.Year(), createdAt.Month(), createdAt.Day(),
		0, 0, 0, 0, loc,
	)

	return !recordDate.Before(yesterday)
}

func (u *pemantauanIbuHamilUsecase) SaveMine(
	userID int32,
	req models.PemantauanIbuHamil,
) (*models.PemantauanIbuHamil, error) {
	if userID == 0 {
		return nil, errors.New("user_id tidak valid")
	}

	if req.MingguKehamilan < 4 || req.MingguKehamilan > 42 {
		return nil, errors.New("minggu_kehamilan harus antara 4 sampai 42")
	}

	kehamilan, err := u.repo.FindActiveKehamilanByUserID(userID)
	if err != nil {
		return nil, errors.New("kehamilan aktif tidak ditemukan")
	}

	// Cek apakah sudah ada data untuk minggu ini
	existing, errFind := u.repo.FindByKehamilanIDAndMinggu(kehamilan.ID, req.MingguKehamilan)
	if errFind == nil && existing != nil {
		// Data sudah ada — validasi: hanya boleh ubah jika hari ini atau kemarin
		if !isAllowedToFill(&existing.CreatedAt) {
			return nil, errors.New("data pemantauan minggu ini hanya dapat diisi pada hari yang sama atau sehari setelahnya")
		}
	}
	// Jika belum ada (record baru), langsung lanjut — tidak ada batasan

	data := &models.PemantauanIbuHamil{
		KehamilanID:       kehamilan.ID,
		MingguKehamilan:   req.MingguKehamilan,
		DemamLebih2Hari:   req.DemamLebih2Hari,
		SakitKepala:       req.SakitKepala,
		CemasBerlebih:     req.CemasBerlebih,
		ResikoTB:          req.ResikoTB,
		GerakanBayiKurang: req.GerakanBayiKurang,
		NyeriPerut:        req.NyeriPerut,
		CairanJalanLahir:  req.CairanJalanLahir,
		MasalahKemaluan:   req.MasalahKemaluan,
		DiareBerulang:     req.DiareBerulang,
	}

	if err := u.repo.Upsert(data); err != nil {
		return nil, err
	}

	return data, nil
}

func (u *pemantauanIbuHamilUsecase) GetByKehamilanID(userID int32, kehamilanID int32) ([]models.PemantauanIbuHamil, error) {
	if userID == 0 {
		return nil, errors.New("user_id tidak valid")
	}
	if kehamilanID == 0 {
		return nil, errors.New("kehamilan_id tidak valid")
	}

	// Validasi: pastikan kehamilan ini milik user yang login
	if err := u.repo.ValidateKehamilanOwner(userID, kehamilanID); err != nil {
		return nil, errors.New("kehamilan tidak ditemukan atau bukan milik user ini")
	}

	return u.repo.FindByKehamilanID(kehamilanID)
}

// ─── BAGIAN KADER ────────────────────────────────────────────────────────────

func (u *pemantauanIbuHamilUsecase) GetAll() ([]models.PemantauanIbuHamil, error) {
	return u.repo.FindAllWithKehamilan()
}

func (u *pemantauanIbuHamilUsecase) Verify(id int32, namaKader string, tanggalVerifikasi *time.Time) error {
	data, err := u.repo.FindByID(id)
	if err != nil {
		return errors.New("data pemantauan tidak ditemukan")
	}

	data.NamaKader = namaKader
	data.TanggalVerifikasi = tanggalVerifikasi

	return u.repo.UpdateVerifikasi(data)
}