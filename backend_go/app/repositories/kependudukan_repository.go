package repositories

import (
	"errors"
	"monitoring-service/app/middlewares"
	"monitoring-service/app/models"
	"strings"
	"time"

	"gorm.io/gorm"
)

// Interface KependudukanRepository
type kependudukanRepository interface {
	Create(k *models.Kependudukan) error
	FindByID(id int32) (*models.Kependudukan, error)
	FindByNIK(nik *string) (*models.Kependudukan, error)
	FindByKartuKeluargaID(kkID int32) ([]models.Kependudukan, error)
	GetAll() ([]models.Kependudukan, error)
	Update(k *models.Kependudukan) error
	Delete(id int32) error
	ListByKartuKeluargaID(kartuKeluargaID int64) ([]models.Kependudukan, error)
	FindByIDAndKartuKeluargaID(id int32, kartuKeluargaID int64) (*models.Kependudukan, error)
	FindByNIKExceptID(nik string, exceptID int32) (*models.Kependudukan, error)
	ListEligibleForRole(role, search, kecamatan, desa string) ([]EligiblePendudukItem, error)
	CreatePosyandu(posyandu *models.Posyandu) error
	ListPosyandu(search string) ([]PosyanduItem, error)
	FindPosyanduByID(id int32) (*models.Posyandu, error)
	UpdatePosyandu(posyandu *models.Posyandu) error
	SoftDeleteByID(id int32) error
	SoftDeleteByKartuKeluargaID(kartuKeluargaID int64) error
	GetRekapPerDusun(kecamatan, desa string) ([]RekapDusun, error)
	GetAllActive() ([]models.Kependudukan, error)
	FindByAgeRange(minAge, maxAge int) ([]models.Kependudukan, error)
	GetAllActiveByDesaID(desaID int32) ([]models.Kependudukan, error)
 	GetPendudukByDesaAndJenisKelamin(desaID *int32, role string, jenisKelamin string) ([]models.Kependudukan, error)
}

// Implementasi privat
type KependudukanRepository struct {
	db *gorm.DB
}

type EligiblePendudukItem struct {
	ID                int32  `json:"id"`
	KartuKeluargaID   *int64 `json:"kartu_keluarga_id,omitempty"`
	NIK               string `json:"nik"`
	NamaLengkap       string `json:"nama_lengkap"`
	JenisKelamin      string `json:"jenis_kelamin"`
	Kecamatan         string `json:"kecamatan"`
	Desa              string `json:"desa"`
	KedudukanKeluarga string `json:"kedudukan_keluarga"`
}

type PosyanduItem struct {
	ID          int64  `json:"id"`
	IDPuskesmas int64  `json:"id_puskesmas"`
	Nama        string `json:"nama"`
	Alamat      string `json:"alamat,omitempty"`
	CreatedAt   string `json:"created_at"`
}
type RekapDusun struct {
	Kecamatan string `json:"kecamatan"`
	Desa      string `json:"desa"`
	Dusun     string `json:"dusun"`
	Total     int64  `json:"total"`
}

func NewKependudukanRepository(db *gorm.DB) *KependudukanRepository {
	return &KependudukanRepository{db: db}
}

func (r *KependudukanRepository) Create(k *models.Kependudukan) error {
	return r.db.Create(k).Error
}

func (r *KependudukanRepository) FindByID(id int32) (*models.Kependudukan, error) {
	var k models.Kependudukan
	err := r.db.Where("id = ? AND deleted_at IS NULL", id).First(&k).Error
	return &k, err
}

func (r *KependudukanRepository) FindByNIK(nik *string) (*models.Kependudukan, error) {
	if nik == nil || *nik == "" {
		return nil, errors.New("nik tidak boleh kosong")
	}
	var k models.Kependudukan
	err := r.db.Where("nik = ? AND deleted_at IS NULL", *nik).First(&k).Error
	return &k, err
}

func (r *KependudukanRepository) FindByKartuKeluargaID(kkID int32) ([]models.Kependudukan, error) {
	var list []models.Kependudukan
	err := r.db.Preload("KartuKeluarga").Where("kartu_keluarga_id = ?", kkID).Find(&list).Error
	return list, err
}

func (r *KependudukanRepository) GetAll() ([]models.Kependudukan, error) {
	var list []models.Kependudukan
	err := r.db.Where("deleted_at IS NULL").Find(&list).Error
	return list, err
}

func (r *KependudukanRepository) Update(k *models.Kependudukan) error {
	return r.db.Save(k).Error
}

func (r *KependudukanRepository) Delete(id int32) error {
	result := r.db.Delete(&models.Kependudukan{}, id)
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return errors.New("data kependudukan tidak ditemukan")
	}
	return nil
}

func (r *KependudukanRepository) ListByKartuKeluargaID(kartuKeluargaID int64) ([]models.Kependudukan, error) {
	var list []models.Kependudukan
	err := r.db.
		Where("kartu_keluarga_id = ? AND deleted_at IS NULL", kartuKeluargaID).
		Order("id ASC").
		Find(&list).Error
	return list, err
}

func (r *KependudukanRepository) FindByIDAndKartuKeluargaID(id int32, kartuKeluargaID int64) (*models.Kependudukan, error) {
	var k models.Kependudukan
	err := r.db.
		Where("id = ? AND kartu_keluarga_id = ? AND deleted_at IS NULL", id, kartuKeluargaID).
		First(&k).Error
	return &k, err
}

func (r *KependudukanRepository) FindByNIKExceptID(nik string, exceptID int32) (*models.Kependudukan, error) {
	if nik == "" {
		return nil, errors.New("nik tidak boleh kosong")
	}
	var k models.Kependudukan
	err := r.db.Where("nik = ? AND id <> ? AND deleted_at IS NULL", nik, exceptID).First(&k).Error
	return &k, err
}

func (r *KependudukanRepository) ListEligibleForRole(role, search, kecamatan, desa string) ([]EligiblePendudukItem, error) {
	role = strings.ToLower(strings.TrimSpace(role))
	search = strings.TrimSpace(search)
	kecamatan = strings.TrimSpace(kecamatan)
	desa = strings.TrimSpace(desa)

	if role != "bidan" && role != "kader" {
		return nil, errors.New("role harus bidan atau kader")
	}

	var list []EligiblePendudukItem
	q := r.db.Table("penduduk p").
		Select("p.id, p.kartu_keluarga_id, p.nik, p.nama_lengkap, p.jenis_kelamin, p.kecamatan, p.kedudukan_keluarga").
		Where("p.deleted_at IS NULL")

	if search != "" {
		pattern := "%" + search + "%"
		q = q.Where("(p.nik ILIKE ? OR p.nama_lengkap ILIKE ?)", pattern, pattern)
	}
	if kecamatan != "" {
		q = q.Where("COALESCE(p.kecamatan, '') = ?", kecamatan)
	}

	switch role {
	case "bidan":
		q = q.Where("NOT EXISTS (SELECT 1 FROM bidan b WHERE b.penduduk_id = p.id AND b.deleted_at IS NULL)")
		q = q.Where("NOT EXISTS (SELECT 1 FROM kader k WHERE k.id_penduduk = p.id AND k.deleted_at IS NULL)")
	case "kader":
		q = q.Where("NOT EXISTS (SELECT 1 FROM kader k WHERE k.id_penduduk = p.id AND k.deleted_at IS NULL)")
		q = q.Where("NOT EXISTS (SELECT 1 FROM bidan b WHERE b.penduduk_id = p.id AND b.deleted_at IS NULL)")
	}

	err := q.Order("p.nama_lengkap ASC").Scan(&list).Error
	return list, err
}

func (r *KependudukanRepository) ListAvailableForSuperadmin(search string) ([]EligiblePendudukItem, error) {
	search = strings.TrimSpace(search)

	var list []EligiblePendudukItem
	q := r.db.Table("penduduk p").
		Select("p.id, p.kartu_keluarga_id, p.nik, p.nama_lengkap, p.jenis_kelamin, p.kecamatan, p.kedudukan_keluarga").
		Where("p.deleted_at IS NULL").
		Where("NOT EXISTS (SELECT 1 FROM bidan b WHERE b.penduduk_id = p.id AND b.deleted_at IS NULL)").
		Where("NOT EXISTS (SELECT 1 FROM kader k WHERE k.id_penduduk = p.id AND k.deleted_at IS NULL)").
		Where("NOT EXISTS (SELECT 1 FROM pengguna u WHERE u.penduduk_id = p.id)").
		Order("p.nama_lengkap ASC")

	if search != "" {
		pattern := "%" + search + "%"
		q = q.Where("(p.nik ILIKE ? OR p.nama_lengkap ILIKE ?)", pattern, pattern)
	}

	if err := q.Scan(&list).Error; err != nil {
		return nil, err
	}

	return list, nil
}

func detectPosyanduNameColumn(db *gorm.DB) (string, map[string]bool, error) {
	type columnInfo struct {
		ColumnName string `gorm:"column:column_name"`
	}

	var columns []columnInfo
	if err := db.Raw(`
		SELECT column_name
		FROM information_schema.columns
		WHERE table_schema = current_schema()
		  AND table_name = 'posyandu'
	`).Scan(&columns).Error; err != nil {
		return "", nil, err
	}
	if len(columns) == 0 {
		return "", nil, errors.New("tabel posyandu tidak ditemukan")
	}

	hasColumn := map[string]bool{}
	for _, c := range columns {
		hasColumn[c.ColumnName] = true
	}

	for _, candidate := range []string{"nama", "nama_posyandu", "name"} {
		if hasColumn[candidate] {
			return candidate, hasColumn, nil
		}
	}

	return "", nil, errors.New("kolom nama posyandu tidak ditemukan")
}

func (r *KependudukanRepository) CreatePosyandu(posyandu *models.Posyandu) error {
	if posyandu == nil {
		return errors.New("data posyandu tidak valid")
	}
	if posyandu.IDPuskesmas == 0 {
		return errors.New("id_puskesmas wajib diisi")
	}
	if strings.TrimSpace(posyandu.Nama) == "" {
		return errors.New("nama posyandu wajib diisi")
	}

	posyandu.Nama = strings.TrimSpace(posyandu.Nama)
	posyandu.Alamat = strings.TrimSpace(posyandu.Alamat)

	return r.db.Create(posyandu).Error
}

func (r *KependudukanRepository) ListPosyandu(search string) ([]PosyanduItem, error) {
	search = strings.TrimSpace(search)

	var list []PosyanduItem
	q := r.db.Table("posyandu p").
		Select("p.id, p.id_puskesmas, p.nama, p.alamat, p.created_at").
		Where("p.deleted_at IS NULL").
		Order("p.nama ASC")

	if search != "" {
		q = q.Where("p.nama ILIKE ? OR p.alamat ILIKE ?", "%"+search+"%", "%"+search+"%")
	}

	if err := q.Scan(&list).Error; err != nil {
		return nil, err
	}
	return list, nil
}

func (r *KependudukanRepository) FindPosyanduByID(id int32) (*models.Posyandu, error) {
	var posyandu models.Posyandu
	err := r.db.Where("id = ? AND deleted_at IS NULL", id).First(&posyandu).Error
	return &posyandu, err
}

func (r *KependudukanRepository) UpdatePosyandu(posyandu *models.Posyandu) error {
	if posyandu == nil {
		return errors.New("data posyandu tidak valid")
	}
	return r.db.Save(posyandu).Error
}

func (r *KependudukanRepository) SoftDeleteByID(id int32) error {
	now := time.Now()
	return r.db.Model(&models.Kependudukan{}).
		Where("id = ? AND deleted_at IS NULL", id).
		Updates(map[string]interface{}{
			"deleted_at": now,
			"updated_at": now,
		}).Error
}

func (r *KependudukanRepository) SoftDeleteByKartuKeluargaID(kartuKeluargaID int64) error {
	now := time.Now()
	return r.db.Model(&models.Kependudukan{}).
		Where("kartu_keluarga_id = ? AND deleted_at IS NULL", kartuKeluargaID).
		Updates(map[string]interface{}{
			"deleted_at": now,
			"updated_at": now,
		}).Error
}
func (r *KependudukanRepository) GetRekapPerDusun(kecamatan, desa string) ([]RekapDusun, error) {
	var result []RekapDusun

	query := r.db.
		Model(&models.Kependudukan{}).
		Select("kecamatan, desa, dusun, COUNT(*) as total").
		Where("deleted_at IS NULL")

	// filter opsional
	if kecamatan != "" {
		query = query.Where("LOWER(TRIM(kecamatan)) = LOWER(TRIM(?))", kecamatan)
	}

	if desa != "" {
		query = query.Where("LOWER(TRIM(desa)) = LOWER(TRIM(?))", desa)
	}

	err := query.
		Group("kecamatan, desa, dusun").
		Order("total DESC").
		Scan(&result).Error

	return result, err
}

// GetAllActive mengambil semua penduduk yang tidak dihapus (deleted_at IS NULL)
func (r *KependudukanRepository) GetAllActive() ([]models.Kependudukan, error) {
	var penduduks []models.Kependudukan
	err := r.db.Where("deleted_at IS NULL").Find(&penduduks).Error
	return penduduks, err
}

func (r *KependudukanRepository) FindByAgeRange(minAge, maxAge int, desaID *int32, role string) ([]models.Kependudukan, error) {
	var list []models.Kependudukan
	query := r.db.Where("deleted_at IS NULL").
		Where("tanggal_pengurangan IS NULL OR tanggal_pengurangan > NOW()")

	if minAge == 0 && maxAge == 5 { // balita
		query = query.Where("AGE(NOW(), tanggal_lahir) <= INTERVAL '5 years'")
	} else if minAge == 5 && maxAge == 9 { // anak (5-9 tahun)
		query = query.Where("AGE(NOW(), tanggal_lahir) > INTERVAL '5 years' AND AGE(NOW(), tanggal_lahir) < INTERVAL '10 years'")
	} else if minAge == 10 && maxAge == 18 { // remaja
		query = query.Where("AGE(NOW(), tanggal_lahir) >= INTERVAL '10 years' AND AGE(NOW(), tanggal_lahir) < INTERVAL '19 years'")
	} else if minAge == 19 && maxAge == 59 { // dewasa
		query = query.Where("AGE(NOW(), tanggal_lahir) >= INTERVAL '19 years' AND AGE(NOW(), tanggal_lahir) < INTERVAL '60 years'")
	} else { // lansia
		query = query.Where("AGE(NOW(), tanggal_lahir) >= INTERVAL '60 years'")
	}

	// Filter desa hanya jika role tidak memiliki akses penuh
	if !middlewares.HasFullAccess(role) && desaID != nil {
		query = query.Where("desa_id = ?", *desaID)
	}

	err := query.Find(&list).Error
	return list, err
}

// GetAllActiveByDesaID mengambil semua penduduk aktif (deleted_at IS NULL) berdasarkan desa_id
func (r *KependudukanRepository) GetAllActiveByDesaID(desaID int32) ([]models.Kependudukan, error) {
	var list []models.Kependudukan
	err := r.db.Where("desa_id = ? AND deleted_at IS NULL", desaID).Find(&list).Error
	return list, err
}

// repositories/kependudukan_repository.go

// GetPendudukList mengambil daftar penduduk dengan filter desa dan jenis kelamin
func (r *KependudukanRepository) GetPendudukList(desaID *int32, role string, jenisKelamin string) ([]models.Kependudukan, error) {
    var penduduk []models.Kependudukan
    
    query := r.db.Where("deleted_at IS NULL")
    
    // Filter desa hanya jika role TIDAK memiliki akses penuh
    if !middlewares.HasFullAccess(role) && desaID != nil {
        query = query.Where("desa_id = ?", *desaID)
    }
    
    // Filter jenis kelamin jika diberikan
    if jenisKelamin != "" {
        if jenisKelamin == "perempuan" {
            query = query.Where("jenis_kelamin IN (?)", []string{"Perempuan", "P"})
        } else if jenisKelamin == "laki" {
            query = query.Where("jenis_kelamin IN (?)", []string{"Laki-laki", "L"})
        }
    }
    
    // Urutkan berdasarkan nama
    query = query.Order("nama_lengkap ASC")
    
    err := query.Find(&penduduk).Error
    return penduduk, err
}