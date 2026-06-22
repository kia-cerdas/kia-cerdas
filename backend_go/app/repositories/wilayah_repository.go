package repositories

import (
	"monitoring-service/app/models"

	"gorm.io/gorm"
)

// WilayahRepository menangani master wilayah berjenjang:
// Provinsi -> Kabupaten -> Kecamatan.
type WilayahRepository struct {
	db *gorm.DB
}

func NewWilayahRepository(db *gorm.DB) *WilayahRepository {
	return &WilayahRepository{db: db}
}

// ===================== PROVINSI =====================

func (r *WilayahRepository) ListProvinsi() ([]models.Provinsi, error) {
	var list []models.Provinsi
	err := r.db.Order("nama ASC").Find(&list).Error
	return list, err
}

func (r *WilayahRepository) GetProvinsi(id int32) (*models.Provinsi, error) {
	var p models.Provinsi
	err := r.db.First(&p, id).Error
	return &p, err
}

func (r *WilayahRepository) CreateProvinsi(p *models.Provinsi) error {
	return r.db.Create(p).Error
}

func (r *WilayahRepository) SaveProvinsi(p *models.Provinsi) error {
	return r.db.Save(p).Error
}

func (r *WilayahRepository) DeleteProvinsi(id int32) error {
	return r.db.Delete(&models.Provinsi{}, id).Error
}

func (r *WilayahRepository) CountKabupatenByProvinsi(provinsiID int32) (int64, error) {
	var count int64
	err := r.db.Model(&models.Kabupaten{}).Where("provinsi_id = ?", provinsiID).Count(&count).Error
	return count, err
}

// ===================== KABUPATEN =====================

// ListKabupaten mengembalikan kabupaten, opsional difilter per provinsi.
func (r *WilayahRepository) ListKabupaten(provinsiID *int32) ([]models.Kabupaten, error) {
	var list []models.Kabupaten
	q := r.db.Preload("Provinsi").Order("nama ASC")
	if provinsiID != nil {
		q = q.Where("provinsi_id = ?", *provinsiID)
	}
	err := q.Find(&list).Error
	return list, err
}

func (r *WilayahRepository) GetKabupaten(id int32) (*models.Kabupaten, error) {
	var k models.Kabupaten
	err := r.db.Preload("Provinsi").First(&k, id).Error
	return &k, err
}

func (r *WilayahRepository) CreateKabupaten(k *models.Kabupaten) error {
	return r.db.Create(k).Error
}

func (r *WilayahRepository) SaveKabupaten(k *models.Kabupaten) error {
	return r.db.Save(k).Error
}

func (r *WilayahRepository) DeleteKabupaten(id int32) error {
	return r.db.Delete(&models.Kabupaten{}, id).Error
}

func (r *WilayahRepository) CountKecamatanByKabupaten(kabupatenID int32) (int64, error) {
	var count int64
	err := r.db.Model(&models.Kecamatan{}).Where("kabupaten_id = ?", kabupatenID).Count(&count).Error
	return count, err
}

// ===================== KECAMATAN =====================

// ListKecamatan mengembalikan kecamatan, opsional difilter per kabupaten.
func (r *WilayahRepository) ListKecamatan(kabupatenID *int32) ([]models.Kecamatan, error) {
	var list []models.Kecamatan
	q := r.db.Preload("Kabupaten").Preload("Kabupaten.Provinsi").Order("nama ASC")
	if kabupatenID != nil {
		q = q.Where("kabupaten_id = ?", *kabupatenID)
	}
	err := q.Find(&list).Error
	return list, err
}

func (r *WilayahRepository) GetKecamatan(id int32) (*models.Kecamatan, error) {
	var k models.Kecamatan
	err := r.db.Preload("Kabupaten").Preload("Kabupaten.Provinsi").First(&k, id).Error
	return &k, err
}

func (r *WilayahRepository) CreateKecamatan(k *models.Kecamatan) error {
	return r.db.Create(k).Error
}

func (r *WilayahRepository) SaveKecamatan(k *models.Kecamatan) error {
	return r.db.Save(k).Error
}

func (r *WilayahRepository) DeleteKecamatan(id int32) error {
	return r.db.Delete(&models.Kecamatan{}, id).Error
}

func (r *WilayahRepository) CountDesaByKecamatan(kecamatanID int32) (int64, error) {
	var count int64
	err := r.db.Model(&models.Desa{}).Where("kecamatan_id = ?", kecamatanID).Count(&count).Error
	return count, err
}
