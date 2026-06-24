package usecases

import (
	"errors"
	"time"
	"monitoring-service/app/models"
	"monitoring-service/app/repositories"

	"gorm.io/gorm"
)

type ChecklistPemantauanIbuNifasUsecase struct {
	repo          repositories.ChecklistPemantauanIbuNifasRepository
	kehamilanRepo *repositories.KehamilanRepository
}

func NewChecklistPemantauanIbuNifasUsecase(
	repo repositories.ChecklistPemantauanIbuNifasRepository,
	kehamilanRepo *repositories.KehamilanRepository,
) *ChecklistPemantauanIbuNifasUsecase {
	return &ChecklistPemantauanIbuNifasUsecase{
		repo:          repo,
		kehamilanRepo: kehamilanRepo,
	}
}

func (u *ChecklistPemantauanIbuNifasUsecase) Save(data *models.ChecklistPemantauanIbuNifas) error {
	existing, err := u.repo.GetByKehamilanIDAndHariNifas(
		data.KehamilanID,
		data.HariNifas,
	)

	if err == nil && existing != nil {
		data.ID = existing.ID
		return u.repo.Update(data)
	}

	if err != nil && err != gorm.ErrRecordNotFound {
		return err
	}

	return u.repo.Create(data)
}

func (u *ChecklistPemantauanIbuNifasUsecase) GetByKehamilanIDAndHariNifas(
	kehamilanID int32,
	hariNifas int32,
) (*models.ChecklistPemantauanIbuNifas, error) {
	return u.repo.GetByKehamilanIDAndHariNifas(kehamilanID, hariNifas)
}

func (u *ChecklistPemantauanIbuNifasUsecase) findKehamilanByUserID(userID int32) (*models.Kehamilan, error) {
	kehamilan, err := u.kehamilanRepo.FindAktifByUserID(userID)
	if err == nil {
		return kehamilan, nil
	}
	// Aktif tidak ditemukan → coba NIFAS
	return u.kehamilanRepo.FindNifasByUserID(userID)
}

func (u *ChecklistPemantauanIbuNifasUsecase) GetByUserIDAndHariNifas(
	userID int32,
	hariNifas int32,
) (*models.ChecklistPemantauanIbuNifas, error) {
	// [SCOPE: modul-ibu / nifas] gunakan findKehamilanByUserID agar support NIFAS
	kehamilan, err := u.findKehamilanByUserID(userID)
	if err != nil {
		return nil, err
	}

	return u.repo.GetByKehamilanIDAndHariNifas(kehamilan.ID, hariNifas)
}

func (u *ChecklistPemantauanIbuNifasUsecase) GetFilledDaysByUserID(userID int32) ([]int32, error) {
	// [SCOPE: modul-ibu / nifas] gunakan findKehamilanByUserID agar support NIFAS
	kehamilan, err := u.findKehamilanByUserID(userID)
	if err != nil {
		return nil, err
	}

	return u.repo.GetFilledDaysByKehamilanID(kehamilan.ID)
}

func (u *ChecklistPemantauanIbuNifasUsecase) GetFilledDaysWithStatusByUserID(userID int32) ([]repositories.FilledDayStatus, error) {
	// [SCOPE: modul-ibu / nifas] gunakan findKehamilanByUserID agar support NIFAS
	kehamilan, err := u.findKehamilanByUserID(userID)
	if err != nil {
		return nil, err
	}

	return u.repo.GetFilledDaysWithStatusByKehamilanID(kehamilan.ID)
}







// BAGIAN KADER
// GetAll mengambil semua checklist pemantauan ibu nifas untuk ditampilkan ke kader.
func (u *ChecklistPemantauanIbuNifasUsecase) GetAll(posyanduID *int32) ([]models.ChecklistPemantauanIbuNifas, error) {
	return u.repo.FindAllWithKehamilan(posyanduID)
}
 
// Verify digunakan kader untuk menandai bahwa data sudah ditinjau.
func (u *ChecklistPemantauanIbuNifasUsecase) Verify(id int32, namaKader string, tanggalVerifikasi *time.Time) error {
	data, err := u.repo.FindByID(id)
	if err != nil {
		return errors.New("data checklist pemantauan ibu nifas tidak ditemukan")
	}
 
	data.NamaKader = namaKader
	data.TanggalVerifikasi = tanggalVerifikasi
 
	return u.repo.UpdateVerifikasi(data)
}

func (u *ChecklistPemantauanIbuNifasUsecase) GetByKehamilanID(kehamilanID int32) ([]models.ChecklistPemantauanIbuNifas, error) {
    return u.repo.FindByKehamilanID(kehamilanID)
}

func (u *ChecklistPemantauanIbuNifasUsecase) GetAllBidan() ([]models.ChecklistPemantauanIbuNifas, error) {
    return u.repo.FindAllBidan()
}