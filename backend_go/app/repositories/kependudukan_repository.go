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
type KependudukanRepositoryInterface interface {
	Create(k *models.Kependudukan) error
	FindByID(id int32) (*models.Kependudukan, error)
	FindByNIK(nik *string) (*models.Kependudukan, error)
	GetAll() ([]models.Kependudukan, error)
	Update(k *models.Kependudukan) error
	Delete(id int32) error
	FindByNIKExceptID(nik string, exceptID int32) (*models.Kependudukan, error)
	ListEligibleForRole(role, search, dusun, desa string) ([]EligiblePendudukItem, error)
	ListAvailableForSuperadmin(search string) ([]EligiblePendudukItem, error)
	CreatePosyandu(posyandu *models.Posyandu) error
	ListPosyandu(search string, desaID *int32) ([]PosyanduItem, error)
	FindPosyanduByID(id int32) (*models.Posyandu, error)
	UpdatePosyandu(posyandu *models.Posyandu) error
	SoftDeleteByID(id int32) error
	SoftDeleteByKodeKeluarga(kodeKeluarga string) error
	GetRekapPerDusun(dusun, desa string) ([]RekapDusun, error)
	GetAllActive() ([]models.Kependudukan, error)
	FindByAgeRange(minAge, maxAge int, posyanduID *int32, role string) ([]models.Kependudukan, error)
	GetAllActiveByDesaID(desaID int32) ([]models.Kependudukan, error)
	GetAllActiveByPosyanduID(posyanduID int32) ([]models.Kependudukan, error)
	GetPendudukByDesaAndJenisKelamin(desaID *int32, role string, jenisKelamin string) ([]models.Kependudukan, error)
	FindAllWithFilters(search string, page int, limit int, filters map[string]interface{}) ([]models.Kependudukan, int, error)
	FindByKodeKeluarga(kodeKeluarga string) ([]models.Kependudukan, error)
	FindAllWithKodeKeluarga() ([]models.Kependudukan, error)
	GetPendudukList(desaID *int32, role string, jenisKelamin string) ([]models.Kependudukan, error)
}

// Implementasi privat
type KependudukanRepository struct {
	db *gorm.DB
}

type EligiblePendudukItem struct {
	ID                int32  `json:"id"`
	NIK               string `json:"nik"`
	NamaLengkap       string `json:"nama_lengkap"`
	JenisKelamin      string `json:"jenis_kelamin"`
	Dusun             string `json:"dusun"`
	Alamat            string `json:"alamat"`
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
	Dusun     string `json:"dusun"`
	Total     int64  `json:"total"`
	Laki      int64  `json:"laki"`
	Perempuan int64  `json:"perempuan"`
}

func NewKependudukanRepository(db *gorm.DB) *KependudukanRepository {
	return &KependudukanRepository{db: db}
}

// ============================================
// CRUD DASAR
// ============================================

func (r *KependudukanRepository) Create(k *models.Kependudukan) error {
	return r.db.Create(k).Error
}

func (r *KependudukanRepository) FindByID(id int32) (*models.Kependudukan, error) {
	var k models.Kependudukan
	err := r.db.
		Where("id = ? AND deleted_at IS NULL", id).
		Preload("Desa").
		Preload("Posyandu").
		First(&k).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("record not found")
		}
		return nil, err
	}
	return &k, nil
}

func (r *KependudukanRepository) FindByNIK(nik *string) (*models.Kependudukan, error) {
	if nik == nil || *nik == "" {
		return nil, nil
	}
	var k models.Kependudukan
	err := r.db.
		Where("nik = ? AND deleted_at IS NULL", *nik).
		Preload("Desa").
		Preload("Posyandu").
		First(&k).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, err
	}
	return &k, nil
}

func (r *KependudukanRepository) GetAll() ([]models.Kependudukan, error) {
	var list []models.Kependudukan
	err := r.db.
		Where("deleted_at IS NULL").
		Preload("Desa").
		Preload("Posyandu").
		Find(&list).Error
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

func (r *KependudukanRepository) FindByNIKExceptID(nik string, exceptID int32) (*models.Kependudukan, error) {
	if nik == "" {
		return nil, nil
	}
	var k models.Kependudukan
	err := r.db.
		Where("nik = ? AND id <> ? AND deleted_at IS NULL", nik, exceptID).
		First(&k).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, err
	}
	return &k, nil
}

// ============================================
// SOFT DELETE
// ============================================

func (r *KependudukanRepository) SoftDeleteByID(id int32) error {
	now := time.Now()
	return r.db.Model(&models.Kependudukan{}).
		Where("id = ? AND deleted_at IS NULL", id).
		Updates(map[string]interface{}{
			"deleted_at": now,
			"updated_at": now,
		}).Error
}

func (r *KependudukanRepository) SoftDeleteByKodeKeluarga(kodeKeluarga string) error {
	now := time.Now()
	return r.db.Model(&models.Kependudukan{}).
		Where("kode_keluarga = ? AND deleted_at IS NULL", kodeKeluarga).
		Updates(map[string]interface{}{
			"deleted_at": now,
			"updated_at": now,
		}).Error
}

// ============================================
// GET ALL ACTIVE
// ============================================

func (r *KependudukanRepository) GetAllActive() ([]models.Kependudukan, error) {
	var penduduks []models.Kependudukan
	err := r.db.
		Where("deleted_at IS NULL").
		Preload("Desa").
		Preload("Posyandu").
		Order("nama_anggota_keluarga ASC").
		Find(&penduduks).Error
	return penduduks, err
}

func (r *KependudukanRepository) GetAllActiveByDesaID(desaID int32) ([]models.Kependudukan, error) {
	var list []models.Kependudukan
	err := r.db.
		Where("desa_id = ? AND deleted_at IS NULL", desaID).
		Preload("Desa").
		Preload("Posyandu").
		Order("nama_anggota_keluarga ASC").
		Find(&list).Error
	return list, err
}

func (r *KependudukanRepository) GetAllActiveByPosyanduID(posyanduID int32) ([]models.Kependudukan, error) {
	var penduduks []models.Kependudukan
	err := r.db.
		Where("deleted_at IS NULL AND posyandu_id = ?", posyanduID).
		Preload("Desa").
		Preload("Posyandu").
		Order("nama_anggota_keluarga ASC").
		Find(&penduduks).Error
	return penduduks, err
}

// ============================================
// FIND BY KODE KELUARGA
// ============================================

func (r *KependudukanRepository) FindByKodeKeluarga(kodeKeluarga string) ([]models.Kependudukan, error) {
	var list []models.Kependudukan
	err := r.db.
		Where("kode_keluarga = ? AND deleted_at IS NULL", kodeKeluarga).
		Preload("Desa").
		Preload("Posyandu").
		Order("id ASC").
		Find(&list).Error
	return list, err
}

func (r *KependudukanRepository) FindAllWithKodeKeluarga() ([]models.Kependudukan, error) {
	var list []models.Kependudukan
	err := r.db.
		Where("kode_keluarga IS NOT NULL AND kode_keluarga != '' AND deleted_at IS NULL").
		Preload("Desa").
		Preload("Posyandu").
		Order("kode_keluarga ASC, id ASC").
		Find(&list).Error
	return list, err
}

// ============================================
// FIND WITH FILTERS
// ============================================

func (r *KependudukanRepository) FindAllWithFilters(search string, page int, limit int, filters map[string]interface{}) ([]models.Kependudukan, int, error) {
	query := r.db.Model(&models.Kependudukan{}).Where("deleted_at IS NULL")

	// Apply search
	if search != "" {
		searchPattern := "%" + search + "%"
		query = query.Where(
			"nama_anggota_keluarga ILIKE ? OR nik ILIKE ? OR kode_keluarga ILIKE ? OR rw ILIKE ? OR rt ILIKE ?",
			searchPattern, searchPattern, searchPattern, searchPattern, searchPattern,
		)
	}

	// Apply filters
	if rw, ok := filters["rw"]; ok && rw != "" {
		query = query.Where("rw = ?", rw)
	}
	if rt, ok := filters["rt"]; ok && rt != "" {
		query = query.Where("rt = ?", rt)
	}
	if dusun, ok := filters["dusun"]; ok && dusun != "" {
		query = query.Where("dusun = ?", dusun)
	}
	if kodeKeluarga, ok := filters["kode_keluarga"]; ok && kodeKeluarga != "" {
		query = query.Where("kode_keluarga = ?", kodeKeluarga)
	}
	if status, ok := filters["status"]; ok && status != "" {
		query = query.Where("status = ?", status)
	}
	if hubungan, ok := filters["hubungan"]; ok && hubungan != "" {
		query = query.Where("hubungan = ?", hubungan)
	}
	if desaID, ok := filters["desa_id"]; ok && desaID != nil {
		query = query.Where("desa_id = ?", desaID)
	}
	if posyanduID, ok := filters["posyandu_id"]; ok && posyanduID != nil {
		query = query.Where("posyandu_id = ?", posyanduID)
	}

	// Count total
	var total int64
	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// Apply pagination
	offset := (page - 1) * limit
	query = query.
		Preload("Desa").
		Preload("Posyandu").
		Order("created_at DESC").
		Offset(offset).
		Limit(limit)

	var penduduks []models.Kependudukan
	if err := query.Find(&penduduks).Error; err != nil {
		return nil, 0, err
	}

	return penduduks, int(total), nil
}

// ============================================
// LIST ELIGIBLE FOR ROLE
// ============================================

func (r *KependudukanRepository) ListEligibleForRole(role, search, dusun, desa string) ([]EligiblePendudukItem, error) {
	role = strings.ToLower(strings.TrimSpace(role))
	search = strings.TrimSpace(search)
	dusun = strings.TrimSpace(dusun)
	desa = strings.TrimSpace(desa)

	if role != "bidan" && role != "kader" {
		return nil, errors.New("role harus bidan atau kader")
	}

	var list []EligiblePendudukItem

	q := r.db.Table("penduduk p").
		Select(`
			p.id, 
			p.nik, 
			p.nama_anggota_keluarga as nama_lengkap, 
			p.jenis_kelamin, 
			p.dusun, 
			p.alamat, 
			p.hubungan as kedudukan_keluarga
		`).
		Where("p.deleted_at IS NULL")

	if search != "" {
		pattern := "%" + search + "%"
		q = q.Where("(p.nik ILIKE ? OR p.nama_anggota_keluarga ILIKE ?)", pattern, pattern)
	}

	if dusun != "" {
		q = q.Where("p.dusun = ?", dusun)
	}

	if desa != "" {
		q = q.Where("p.alamat ILIKE ?", "%"+desa+"%")
	}

	switch role {
	case "bidan":
		q = q.Where("NOT EXISTS (SELECT 1 FROM bidan b WHERE b.penduduk_id = p.id AND b.deleted_at IS NULL)")
		q = q.Where("NOT EXISTS (SELECT 1 FROM kader k WHERE k.penduduk_id = p.id AND k.deleted_at IS NULL)")
	case "kader":
		q = q.Where("NOT EXISTS (SELECT 1 FROM kader k WHERE k.penduduk_id = p.id AND k.deleted_at IS NULL)")
		q = q.Where("NOT EXISTS (SELECT 1 FROM bidan b WHERE b.penduduk_id = p.id AND b.deleted_at IS NULL)")
	}

	err := q.Order("p.nama_anggota_keluarga ASC").Scan(&list).Error
	return list, err
}

// ============================================
// LIST AVAILABLE FOR SUPERADMIN
// ============================================

func (r *KependudukanRepository) ListAvailableForSuperadmin(search string) ([]EligiblePendudukItem, error) {
	search = strings.TrimSpace(search)

	var list []EligiblePendudukItem
	q := r.db.Table("penduduk p").
		Select(`
			p.id, 
			p.nik, 
			p.nama_anggota_keluarga as nama_lengkap, 
			p.jenis_kelamin, 
			p.dusun, 
			p.alamat, 
			p.hubungan as kedudukan_keluarga
		`).
		Where("p.deleted_at IS NULL").
		Where("NOT EXISTS (SELECT 1 FROM bidan b WHERE b.penduduk_id = p.id AND b.deleted_at IS NULL)").
		Where("NOT EXISTS (SELECT 1 FROM kader k WHERE k.penduduk_id = p.id AND k.deleted_at IS NULL)").
		Where("NOT EXISTS (SELECT 1 FROM pengguna u WHERE u.penduduk_id = p.id)").
		Order("p.nama_anggota_keluarga ASC")

	if search != "" {
		pattern := "%" + search + "%"
		q = q.Where("(p.nik ILIKE ? OR p.nama_anggota_keluarga ILIKE ?)", pattern, pattern)
	}

	if err := q.Scan(&list).Error; err != nil {
		return nil, err
	}

	return list, nil
}

// ============================================
// GET REKAP PER DUSUN
// ============================================

func (r *KependudukanRepository) GetRekapPerDusun(dusun, desa string) ([]RekapDusun, error) {
	var result []RekapDusun

	query := r.db.
		Model(&models.Kependudukan{}).
		Select(`
			dusun, 
			COUNT(*) as total,
			COUNT(CASE WHEN LOWER(jenis_kelamin) IN ('laki-laki', 'l', 'lakilaki') THEN 1 END) as laki,
			COUNT(CASE WHEN LOWER(jenis_kelamin) IN ('perempuan', 'p') THEN 1 END) as perempuan
		`).
		Where("deleted_at IS NULL")

	if dusun != "" {
		query = query.Where("LOWER(TRIM(dusun)) = LOWER(TRIM(?))", dusun)
	}

	if desa != "" {
		query = query.Where("alamat ILIKE ?", "%"+desa+"%")
	}

	err := query.
		Group("dusun").
		Order("total DESC").
		Scan(&result).Error

	return result, err
}

// ============================================
// FIND BY AGE RANGE
// ============================================

func (r *KependudukanRepository) FindByAgeRange(minAge, maxAge int, posyanduID *int32, role string) ([]models.Kependudukan, error) {
	var list []models.Kependudukan
	query := r.db.Where("deleted_at IS NULL")

	// Filter berdasarkan rentang usia menggunakan EXTRACT YEAR
	if minAge == 0 && maxAge == 5 {
		query = query.Where("EXTRACT(YEAR FROM AGE(NOW(), tanggal_lahir)) <= 5")
	} else if minAge == 5 && maxAge == 9 {
		query = query.Where("EXTRACT(YEAR FROM AGE(NOW(), tanggal_lahir)) > 5 AND EXTRACT(YEAR FROM AGE(NOW(), tanggal_lahir)) < 10")
	} else if minAge == 10 && maxAge == 18 {
		query = query.Where("EXTRACT(YEAR FROM AGE(NOW(), tanggal_lahir)) >= 10 AND EXTRACT(YEAR FROM AGE(NOW(), tanggal_lahir)) < 19")
	} else if minAge == 19 && maxAge == 59 {
		query = query.Where("EXTRACT(YEAR FROM AGE(NOW(), tanggal_lahir)) >= 19 AND EXTRACT(YEAR FROM AGE(NOW(), tanggal_lahir)) < 60")
	} else if minAge >= 60 {
		query = query.Where("EXTRACT(YEAR FROM AGE(NOW(), tanggal_lahir)) >= 60")
	}

	// Filter berdasarkan role dan posyandu
	if !middlewares.HasFullAccess(role) && posyanduID != nil {
		query = query.Where("posyandu_id = ?", *posyanduID)
	}

	err := query.
		Preload("Desa").
		Preload("Posyandu").
		Order("tanggal_lahir DESC").
		Find(&list).Error
	return list, err
}

// ============================================
// GET PENDUDUK BY DESA AND JENIS KELAMIN
// ============================================

func (r *KependudukanRepository) GetPendudukByDesaAndJenisKelamin(desaID *int32, role string, jenisKelamin string) ([]models.Kependudukan, error) {
	var penduduk []models.Kependudukan

	query := r.db.Where("deleted_at IS NULL")

	if !middlewares.HasFullAccess(role) && desaID != nil {
		query = query.Where("desa_id = ?", *desaID)
	}

	if jenisKelamin != "" {
		if jenisKelamin == "perempuan" {
			query = query.Where("LOWER(jenis_kelamin) IN (?)", []string{"perempuan", "p"})
		} else if jenisKelamin == "laki" {
			query = query.Where("LOWER(jenis_kelamin) IN (?)", []string{"laki-laki", "l", "lakilaki"})
		}
	}

	err := query.
		Preload("Desa").
		Preload("Posyandu").
		Order("nama_anggota_keluarga ASC").
		Find(&penduduk).Error
	return penduduk, err
}

// ============================================
// GET PENDUDUK LIST (untuk usecase)
// ============================================

func (r *KependudukanRepository) GetPendudukList(desaID *int32, role string, jenisKelamin string) ([]models.Kependudukan, error) {
	var penduduk []models.Kependudukan

	query := r.db.Where("deleted_at IS NULL")

	if !middlewares.HasFullAccess(role) && desaID != nil {
		query = query.Where("desa_id = ?", *desaID)
	}

	if jenisKelamin != "" {
		if jenisKelamin == "perempuan" {
			query = query.Where("LOWER(jenis_kelamin) IN (?)", []string{"perempuan", "p"})
		} else if jenisKelamin == "laki" {
			query = query.Where("LOWER(jenis_kelamin) IN (?)", []string{"laki-laki", "l", "lakilaki"})
		}
	}

	err := query.
		Preload("Desa").
		Preload("Posyandu").
		Order("nama_anggota_keluarga ASC").
		Find(&penduduk).Error
	return penduduk, err
}

// ============================================
// POSYANDU CRUD
// ============================================

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

func (r *KependudukanRepository) ListPosyandu(search string, desaID *int32) ([]PosyanduItem, error) {
	search = strings.TrimSpace(search)

	var list []PosyanduItem
	q := r.db.Table("posyandu p").
		Select("p.id, p.id_puskesmas, p.nama, p.alamat, p.created_at").
		Where("p.deleted_at IS NULL").
		Order("p.nama ASC")

	if desaID != nil {
		q = q.Where("p.desa_id = ?", *desaID)
	}

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
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("posyandu tidak ditemukan")
		}
		return nil, err
	}
	return &posyandu, nil
}

func (r *KependudukanRepository) UpdatePosyandu(posyandu *models.Posyandu) error {
	if posyandu == nil {
		return errors.New("data posyandu tidak valid")
	}
	return r.db.Save(posyandu).Error
}