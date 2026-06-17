package repositories

import (
	"monitoring-service/app/models"
	"time"

	"gorm.io/gorm"
)

type KaderListItem struct {
	ID          int32     `json:"id"`
	PendudukID  int32     `json:"penduduk_id"`
	NamaLengkap string    `json:"nama_lengkap"`
	NIK         string    `json:"nik"`
	Kecamatan   string    `json:"kecamatan"`
	Desa        string    `json:"desa"`
	PosyanduID  *int64    `json:"posyandu_id,omitempty"`
	Status      string    `json:"status"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

type KaderRepository struct {
	db *gorm.DB
}

func NewKaderRepository(db *gorm.DB) *KaderRepository {
	return &KaderRepository{db: db}
}

func (r *KaderRepository) Create(data *models.Kader) error {
	return r.db.Create(data).Error
}

func (r *KaderRepository) FindByID(id int32) (*models.Kader, error) {
	var data models.Kader
	err := r.db.Where("id = ? AND deleted_at IS NULL", id).First(&data).Error
	return &data, err
}

func (r *KaderRepository) FindByPendudukID(pendudukID int32) (*models.Kader, error) {
	var data models.Kader
	err := r.db.Where("id_penduduk = ? AND deleted_at IS NULL", pendudukID).First(&data).Error
	return &data, err
}

func (r *KaderRepository) FindAnyByPendudukID(pendudukID int32) (*models.Kader, error) {
	var data models.Kader
	err := r.db.Unscoped().Where("id_penduduk = ?", pendudukID).First(&data).Error
	return &data, err
}

func (r *KaderRepository) Update(data *models.Kader) error {
	return r.db.Save(data).Error
}

func (r *KaderRepository) SetStatus(id int32, status string) error {
	now := time.Now()
	return r.db.Model(&models.Kader{}).
		Where("id = ? AND deleted_at IS NULL", id).
		Updates(map[string]interface{}{
			"status":     status,
			"updated_at": now,
		}).Error
}

func (r *KaderRepository) List(desa string) ([]KaderListItem, error) {
	var rows []KaderListItem

	q := r.db.Table("kader k").
		Select("k.id, k.id_penduduk, p.nama_lengkap, p.nik, p.kecamatan, p.desa, k.id_posyandu, k.status, k.created_at, k.updated_at").
		Joins("JOIN penduduk p ON p.id = k.id_penduduk").
		Where("k.deleted_at IS NULL AND p.deleted_at IS NULL").
		Order("k.id DESC")

	if desa != "" {
		q = q.Where("COALESCE(p.desa, '') = ?", desa)
	}

	err := q.Scan(&rows).Error
	return rows, err
}

// ListByPosyanduID - Mendapatkan list kader berdasarkan posyandu_id
func (r *KaderRepository) ListByPosyanduID(posyanduID int64) ([]KaderListItem, error) {
	var rows []KaderListItem

	err := r.db.Table("kader k").
		Select("k.id, k.id_penduduk AS penduduk_id, p.nama_lengkap, p.nik, p.kecamatan, p.desa, k.id_posyandu AS posyandu_id, k.status, k.created_at, k.updated_at").
		Joins("JOIN penduduk p ON p.id = k.id_penduduk").
		Where("k.deleted_at IS NULL AND p.deleted_at IS NULL AND k.id_posyandu = ?", posyanduID).
		Order("k.id DESC").
		Scan(&rows).Error

	return rows, err
}

// Search - Mencari kader berdasarkan keyword
func (r *KaderRepository) Search(keyword string, desa string) ([]KaderListItem, error) {
	var rows []KaderListItem

	q := r.db.Table("kader k").
		Select("k.id, k.id_penduduk AS penduduk_id, p.nama_lengkap, p.nik, p.kecamatan, p.desa, k.id_posyandu AS posyandu_id, k.status, k.created_at, k.updated_at").
		Joins("JOIN penduduk p ON p.id = k.id_penduduk").
		Where("k.deleted_at IS NULL AND p.deleted_at IS NULL").
		Order("k.id DESC")

	if keyword != "" {
		q = q.Where("LOWER(p.nama_lengkap) LIKE LOWER(?) OR LOWER(p.nik) LIKE LOWER(?)", "%"+keyword+"%", "%"+keyword+"%")
	}

	if desa != "" {
		q = q.Where("COALESCE(p.desa, '') = ?", desa)
	}

	err := q.Scan(&rows).Error
	return rows, err
}

// CountKaderByPosyandu - Menghitung jumlah kader aktif di posyandu
func (r *KaderRepository) CountKaderByPosyandu(posyanduID int64) (int64, error) {
	var count int64
	err := r.db.Model(&models.Kader{}).
		Where("id_posyandu = ? AND status = ? AND deleted_at IS NULL", posyanduID, "aktif").
		Count(&count).Error
	return count, err
}


// Untuk Profil ============================================================= 

// KaderProfileItem - Representasi profil kader untuk endpoint "profil saya"
type KaderProfileItem struct {
    ID                 int32      `json:"id"`
    PendudukID         int32      `json:"penduduk_id"`
    NamaLengkap        string     `json:"nama_lengkap"`
    NIK                string     `json:"nik"`
    Telepon            string     `json:"telepon"`
    JenisKelamin       string     `json:"jenis_kelamin"`
    TempatLahir        string     `json:"tempat_lahir"`
    TanggalLahir       *time.Time `json:"tanggal_lahir"`
    GolonganDarah      string     `json:"golongan_darah"`
    Agama              string     `json:"agama"`
    PendidikanTerakhir string     `json:"pendidikan_terakhir"`
    Pekerjaan          string     `json:"pekerjaan"`
    Dusun              string     `json:"dusun"`
    Kecamatan          string     `json:"kecamatan"`
    Desa               string     `json:"desa"`
    PosyanduID         *int64     `json:"posyandu_id,omitempty"`
    PosyanduNama       string     `json:"posyandu_nama,omitempty"`
    Status             string     `json:"status"`
    CreatedAt          time.Time  `json:"created_at"`
}

// FindProfileByUserID - Mendapatkan profil kader berdasarkan user_id (untuk endpoint "profil saya")
func (r *KaderRepository) FindProfileByUserID(userID int32) (*KaderProfileItem, error) {
    var row KaderProfileItem

    err := r.db.Table("kader k").
        Select(`k.id, k.id_penduduk AS penduduk_id, p.nama_lengkap, p.nik, p.telepon, 
            p.jenis_kelamin, p.tempat_lahir, p.tanggal_lahir, p.golongan_darah, p.agama, 
            p.pendidikan_terakhir, p.pekerjaan, 
            p.dusun, p.kecamatan, COALESCE(d.nama_desa, '') AS desa, 
            k.id_posyandu AS posyandu_id,
            COALESCE(pos.nama, '') AS posyandu_nama, k.status, k.created_at`).
        Joins("JOIN pengguna u ON u.penduduk_id = k.id_penduduk").
        Joins("JOIN penduduk p ON p.id = k.id_penduduk").
        Joins("LEFT JOIN desa d ON d.id = p.desa_id").
        Joins("LEFT JOIN posyandu pos ON pos.id = k.id_posyandu").
        Where("u.id = ? AND k.deleted_at IS NULL AND p.deleted_at IS NULL", userID).
        Scan(&row).Error

    return &row, err
}


// // FindProfileByUserID - Mendapatkan profil kader berdasarkan user_id (untuk endpoint "profil saya")
// func (r *KaderRepository) FindProfileByUserID(userID int32) (*KaderProfileItem, error) {
//     var row KaderProfileItem

//     err := r.db.Table("kader k").
//         Select(`k.id, k.id_penduduk AS penduduk_id, p.nama_lengkap, p.nik, p.telepon,
//             p.dusun, p.kecamatan, COALESCE(d.nama_desa, '') AS desa, 
//             k.id_posyandu AS posyandu_id,
//             COALESCE(pos.nama, '') AS posyandu_nama, k.status, k.created_at`).
//         Joins("JOIN pengguna u ON u.penduduk_id = k.id_penduduk").
//         Joins("JOIN penduduk p ON p.id = k.id_penduduk").
//         Joins("LEFT JOIN desa d ON d.id = p.desa_id").
//         Joins("LEFT JOIN posyandu pos ON pos.id = k.id_posyandu").
//         Where("u.id = ? AND k.deleted_at IS NULL AND p.deleted_at IS NULL", userID).
//         Scan(&row).Error

//     return &row, err
// }