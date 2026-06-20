package repositories

import (
	"context"
	"errors"
	"log"
	"monitoring-service/app/models"

	"github.com/lib/pq"
	"gorm.io/gorm"
)

type PemeriksaanRepository interface {
    CreatePemeriksaan(ctx context.Context, p *models.Pemeriksaan) error
    GetRiwayatByPenduduk(ctx context.Context, pendudukID uint, kelompok string) ([]models.Pemeriksaan, error)
    GetPemeriksaanByID(ctx context.Context, id uint) (*models.Pemeriksaan, error)
    GetPendudukByID(ctx context.Context, id uint) (*models.Kependudukan, error)
    GetUserByID(ctx context.Context, id uint) (*models.User, error)
	CountDistinctPendudukByKelompokAndIDs(kelompok string, pendudukIDs []int32) (int64, error)
	GetLatestRiskCountByPendudukIDs(kelompok string, pendudukIDs []int32) (map[string]int, error)
	GetPendudukByRisk(kelompok string, risiko string, PosyanduID *int32, role string) ([]models.PendudukRiskResponse, error)
	GetRiwayatByPendudukID(ctx context.Context, pendudukID uint) ([]models.Pemeriksaan, error)
	GetLatestPemeriksaanByPenduduk(ctx context.Context, pendudukID uint, kelompok string) (*models.Pemeriksaan, error)
    GetLatestByPendudukIDs(ctx context.Context, kelompok string, pendudukIDs []uint) (map[uint]*models.Pemeriksaan, error)
}

type pemeriksaanRepository struct {
	db *gorm.DB
}

func NewPemeriksaanRepository(db *gorm.DB) PemeriksaanRepository {
	return &pemeriksaanRepository{db: db}
}

func (r *pemeriksaanRepository) CreatePemeriksaan(ctx context.Context, p *models.Pemeriksaan) error {
	return r.db.WithContext(ctx).Create(p).Error
}

// GetCakupanAktual menghitung jumlah penduduk unik dan total pemeriksaan per kelompok
// berdasarkan data di tabel pemeriksaans, dengan filter desa (opsional) dan status penduduk aktif.
func (r *pemeriksaanRepository) GetRiwayatByPenduduk(ctx context.Context, pendudukID uint, kelompok string) ([]models.Pemeriksaan, error) {
	var list []models.Pemeriksaan
	query := r.db.WithContext(ctx).Where("penduduk_id = ?", pendudukID)
	if kelompok != "" {
		query = query.Where("kelompok = ?", kelompok)
	}
	err := query.Order("tanggal_pemeriksaan desc").Find(&list).Error
	return list, err
}

func (r *pemeriksaanRepository) GetPemeriksaanByID(ctx context.Context, id uint) (*models.Pemeriksaan, error) {
	var p models.Pemeriksaan
	err := r.db.WithContext(ctx).Preload("Penduduk").First(&p, id).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}
	return &p, err
}

func (r *pemeriksaanRepository) GetPendudukByID(ctx context.Context, id uint) (*models.Kependudukan, error) {
	var penduduk models.Kependudukan
	err := r.db.WithContext(ctx).First(&penduduk, id).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}
	return &penduduk, err
}

func (r *pemeriksaanRepository) GetUserByID(ctx context.Context, id uint) (*models.User, error) {
	var user models.User
	err := r.db.WithContext(ctx).First(&user, id).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}
	return &user, err
}

func (r *pemeriksaanRepository) CountDistinctPendudukByKelompokAndIDs(kelompok string, pendudukIDs []int32) (int64, error) {
    if len(pendudukIDs) == 0 {
        return 0, nil
    }
    
    var count int64
    err := r.db.Model(&models.Pemeriksaan{}).
        Where("kelompok = ? AND penduduk_id IN ?", kelompok, pendudukIDs).
        Where("deleted_at IS NULL").
        Distinct("penduduk_id").
        Count(&count).Error
    
    return count, err
}
func (r *pemeriksaanRepository) GetLatestRiskCountByPendudukIDs(kelompok string, pendudukIDs []int32) (map[string]int, error) {
    riskMap := map[string]int{"Rendah": 0, "Sedang": 0, "Tinggi": 0}
    
    if len(pendudukIDs) == 0 {
        return riskMap, nil
    }
    
    // 🔧 PERBAIKAN: Gunakan DISTINCT ON untuk mengambil 1 pemeriksaan terbaru per penduduk
    query := `
        WITH latest_exam AS (
            SELECT DISTINCT ON (penduduk_id) 
                penduduk_id,
                kategori_risiko
            FROM pemeriksaans
            WHERE kelompok = $1 
                AND penduduk_id = ANY($2::int[])
                AND tanggal_pemeriksaan IS NOT NULL
                AND deleted_at IS NULL
            ORDER BY penduduk_id, tanggal_pemeriksaan DESC
        )
        SELECT 
            COALESCE(SUM(CASE WHEN kategori_risiko = 'Tinggi' THEN 1 ELSE 0 END), 0) AS tinggi,
            COALESCE(SUM(CASE WHEN kategori_risiko = 'Sedang' THEN 1 ELSE 0 END), 0) AS sedang,
            COALESCE(SUM(CASE WHEN kategori_risiko IN ('Rendah', 'Normal') THEN 1 ELSE 0 END), 0) AS rendah
        FROM latest_exam
    `
    
    // 🔧 Gunakan struct untuk menampung hasil
    type Result struct {
        Tinggi int
        Sedang int
        Rendah int
    }
    
    var result Result
    err := r.db.Raw(query, kelompok, pq.Array(pendudukIDs)).Scan(&result).Error
    if err != nil {
        return riskMap, err
    }
    
    riskMap["Tinggi"] = result.Tinggi
    riskMap["Sedang"] = result.Sedang
    riskMap["Rendah"] = result.Rendah
    
    return riskMap, nil
}

func (r *pemeriksaanRepository) GetPendudukByRisk(kategori string, risiko string, PosyanduID *int32, role string) ([]models.PendudukRiskResponse, error) {
    // 🔧 PERBAIKAN: Gunakan raw query dengan DISTINCT ON terlebih dahulu, baru filter risiko
    var query string
    var args []interface{}
    
    // Filter desa jika bukan superadmin
    hasFullAccess := role == "superadmin"
    
    if risiko == "Normal" || risiko == "Rendah" {
        query = `
            WITH latest_exam AS (
                SELECT DISTINCT ON (p.penduduk_id) 
                    p.penduduk_id,
                    p.kategori_risiko
                FROM pemeriksaans p
                WHERE p.kelompok = $1 
                    AND p.tanggal_pemeriksaan IS NOT NULL
                    AND p.deleted_at IS NULL
                ORDER BY p.penduduk_id, p.tanggal_pemeriksaan DESC
            )
            SELECT 
                k.id,
                k.nama_lengkap,
                k.nik,
                k.dusun,
                EXTRACT(YEAR FROM AGE(CURRENT_DATE, k.tanggal_lahir)) as usia,
                le.kategori_risiko as risiko
            FROM latest_exam le
            JOIN penduduk k ON le.penduduk_id = k.id
            WHERE le.kategori_risiko IN ('Rendah', 'Normal')
                AND k.deleted_at IS NULL
        `
        args = []interface{}{kategori}
        if !hasFullAccess && PosyanduID != nil {
            query += " AND k.desa_id = $2"
            args = append(args, *PosyanduID)
        }
    } else {
        query = `
            WITH latest_exam AS (
                SELECT DISTINCT ON (p.penduduk_id) 
                    p.penduduk_id,
                    p.kategori_risiko
                FROM pemeriksaans p
                WHERE p.kelompok = $1 
                    AND p.tanggal_pemeriksaan IS NOT NULL
                    AND p.deleted_at IS NULL
                ORDER BY p.penduduk_id, p.tanggal_pemeriksaan DESC
            )
            SELECT 
                k.id,
                k.nama_lengkap,
                k.nik,
                k.dusun,
                EXTRACT(YEAR FROM AGE(CURRENT_DATE, k.tanggal_lahir)) as usia,
                le.kategori_risiko as risiko
            FROM latest_exam le
            JOIN penduduk k ON le.penduduk_id = k.id
            WHERE le.kategori_risiko = $2
                AND k.deleted_at IS NULL
        `
        args = []interface{}{kategori, risiko}
        if !hasFullAccess && PosyanduID != nil {
            query += " AND k.desa_id = $3"
            args = append(args, *PosyanduID)
        }
    }
    
    var results []models.PendudukRiskResponse
    err := r.db.Raw(query, args...).Scan(&results).Error
    if err != nil {
        return nil, err
    }
    
    return results, nil
}

func (r *pemeriksaanRepository) GetRiwayatByPendudukID(ctx context.Context, pendudukID uint) ([]models.Pemeriksaan, error) {
    var riwayat []models.Pemeriksaan
    err := r.db.WithContext(ctx).
        Where("penduduk_id = ?", pendudukID).
        Order("tanggal_pemeriksaan DESC").
        Find(&riwayat).Error
    return riwayat, err
}

// repositories/pemeriksaan_repository.go
func (r *pemeriksaanRepository) GetLatestPemeriksaanByPenduduk(ctx context.Context, pendudukID uint, kelompok string) (*models.Pemeriksaan, error) {
    var pemeriksaan models.Pemeriksaan
    err := r.db.WithContext(ctx).
        Where("penduduk_id = ? AND kelompok = ?", pendudukID, kelompok).
        Order("tanggal_pemeriksaan DESC").
        First(&pemeriksaan).Error
    if errors.Is(err, gorm.ErrRecordNotFound) {
        return nil, nil
    }
    return &pemeriksaan, err
}
func (r *pemeriksaanRepository) GetLatestByPendudukIDs(ctx context.Context, kelompok string, pendudukIDs []uint) (map[uint]*models.Pemeriksaan, error) {
    result := make(map[uint]*models.Pemeriksaan)
    
    log.Printf("GetLatestByPendudukIDs: kelompok=%s, pendudukIDs=%v", kelompok, pendudukIDs)
    
    if len(pendudukIDs) == 0 {
        return result, nil
    }
    
    var exams []models.Pemeriksaan
    
    // 🔧 PERBAIKAN: Gunakan parameter pendudukIDs, jangan hardcode
    query := `
        SELECT DISTINCT ON (penduduk_id) 
            id,
            penduduk_id,
            kelompok,
            kategori_risiko,
            tanggal_pemeriksaan,
            rekomendasi
        FROM pemeriksaans
        WHERE kelompok = $1 
            AND penduduk_id = ANY($2::int[])
            AND deleted_at IS NULL
            AND tanggal_pemeriksaan IS NOT NULL
        ORDER BY penduduk_id, tanggal_pemeriksaan DESC
    `
    
    err := r.db.WithContext(ctx).Raw(query, kelompok, pq.Array(pendudukIDs)).Scan(&exams).Error
    if err != nil {
        log.Printf("Query error: %v", err)
        return result, err
    }
    
    log.Printf("Found %d exams", len(exams))
    
    for i := range exams {
        result[exams[i].PendudukID] = &exams[i]
        log.Printf("Added exam for penduduk %d: risiko=%s", exams[i].PendudukID, exams[i].KategoriRisiko)
    }
    
    return result, nil
}