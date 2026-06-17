package repositories

import (
	"monitoring-service/app/models"

	"gorm.io/gorm"
)

// FilledDayStatus menyimpan info hari nifas beserta status verifikasi kader.
type FilledDayStatus struct {
	HariNifas         int32  `json:"hari_nifas"`
	Terverifikasi     bool   `json:"terverifikasi"`
	NamaKader         string `json:"nama_kader,omitempty"`
	TanggalVerifikasi string `json:"tanggal_verifikasi,omitempty"`
}

type ChecklistPemantauanIbuNifasRepository interface {
	GetByKehamilanIDAndHariNifas(kehamilanID int32, hariNifas int32) (*models.ChecklistPemantauanIbuNifas, error)
	GetFilledDaysByKehamilanID(kehamilanID int32) ([]int32, error)
	GetFilledDaysWithStatusByKehamilanID(kehamilanID int32) ([]FilledDayStatus, error)
	Create(data *models.ChecklistPemantauanIbuNifas) error
	Update(data *models.ChecklistPemantauanIbuNifas) error
	// Kader
	FindAllWithKehamilan() ([]models.ChecklistPemantauanIbuNifas, error)
	FindByID(id int32) (*models.ChecklistPemantauanIbuNifas, error)
	UpdateVerifikasi(data *models.ChecklistPemantauanIbuNifas) error
}

type checklistPemantauanIbuNifasRepository struct {
	db *gorm.DB
}

func NewChecklistPemantauanIbuNifasRepository(db *gorm.DB) ChecklistPemantauanIbuNifasRepository {
	return &checklistPemantauanIbuNifasRepository{
		db: db,
	}
}

func (r *checklistPemantauanIbuNifasRepository) GetByKehamilanIDAndHariNifas(
	kehamilanID int32,
	hariNifas int32,
) (*models.ChecklistPemantauanIbuNifas, error) {
	var data models.ChecklistPemantauanIbuNifas

	err := r.db.
		Where("kehamilan_id = ? AND hari_nifas = ? AND deleted_at IS NULL", kehamilanID, hariNifas).
		First(&data).Error

	if err != nil {
		return nil, err
	}

	return &data, nil
}

func (r *checklistPemantauanIbuNifasRepository) GetFilledDaysByKehamilanID(kehamilanID int32) ([]int32, error) {
	var days []int32

	err := r.db.
		Model(&models.ChecklistPemantauanIbuNifas{}).
		Where("kehamilan_id = ? AND deleted_at IS NULL", kehamilanID).
		Order("hari_nifas ASC").
		Pluck("hari_nifas", &days).Error

	if err != nil {
		return nil, err
	}

	return days, nil
}

func (r *checklistPemantauanIbuNifasRepository) GetFilledDaysWithStatusByKehamilanID(kehamilanID int32) ([]FilledDayStatus, error) {
	var list []models.ChecklistPemantauanIbuNifas

	err := r.db.
		Model(&models.ChecklistPemantauanIbuNifas{}).
		Select("hari_nifas, nama_kader, tanggal_verifikasi").
		Where("kehamilan_id = ? AND deleted_at IS NULL", kehamilanID).
		Order("hari_nifas ASC").
		Find(&list).Error

	if err != nil {
		return nil, err
	}

	result := make([]FilledDayStatus, 0, len(list))
	for _, item := range list {
		status := FilledDayStatus{
			HariNifas:     item.HariNifas,
			Terverifikasi: item.TanggalVerifikasi != nil,
			NamaKader:     item.NamaKader,
		}
		if item.TanggalVerifikasi != nil {
			status.TanggalVerifikasi = item.TanggalVerifikasi.Format("2006-01-02")
		}
		result = append(result, status)
	}
	return result, nil
}

func (r *checklistPemantauanIbuNifasRepository) Create(data *models.ChecklistPemantauanIbuNifas) error {
	return r.db.Create(data).Error
}

func (r *checklistPemantauanIbuNifasRepository) Update(data *models.ChecklistPemantauanIbuNifas) error {
	return r.db.Save(data).Error
}



// BAGIAN KADER 

// FindAllWithKehamilan mengambil semua checklist nifas beserta info ibu,
// digunakan oleh kader untuk melihat dan memverifikasi.
func (r *checklistPemantauanIbuNifasRepository) FindAllWithKehamilan() ([]models.ChecklistPemantauanIbuNifas, error) {
	var list []models.ChecklistPemantauanIbuNifas
	err := r.db.
		Preload("Kehamilan").
		Preload("Kehamilan.Ibu").
		Preload("Kehamilan.Ibu.Kependudukan").
		Where("deleted_at IS NULL").
		Order("created_at DESC").
		Find(&list).Error
	return list, err
}
 
// FindByID mengambil satu checklist nifas berdasarkan ID.
func (r *checklistPemantauanIbuNifasRepository) FindByID(id int32) (*models.ChecklistPemantauanIbuNifas, error) {
	var data models.ChecklistPemantauanIbuNifas
	err := r.db.First(&data, id).Error
	if err != nil {
		return nil, err
	}
	return &data, nil
}
 
// UpdateVerifikasi menyimpan nama kader dan tanggal verifikasi.
func (r *checklistPemantauanIbuNifasRepository) UpdateVerifikasi(data *models.ChecklistPemantauanIbuNifas) error {
	return r.db.Save(data).Error
}



