package repositories

import (
	"errors"
	"monitoring-service/app/middlewares"
	"monitoring-service/app/models"

	"gorm.io/gorm"
)

type IbuRepository struct {
	db *gorm.DB
}

func NewIbuRepository(db *gorm.DB) *IbuRepository {
	return &IbuRepository{db: db}
}

func (r *IbuRepository) Create(ibu *models.Ibu) error {
	return r.db.Create(ibu).Error
}

func (r *IbuRepository) FindByID(id int32) (*models.Ibu, error) {
	var ibu models.Ibu
	err := r.db.Preload("Kependudukan").
		Preload("Suami").
		First(&ibu, id).Error
	return &ibu, err
}

func (r *IbuRepository) FindAll() ([]models.Ibu, error) {
	var list []models.Ibu
	err := r.db.Preload("Kependudukan").
		Preload("Suami").
		Find(&list).Error
	return list, err
}

func (r *IbuRepository) FindAnakByUserID(userID int32) ([]models.Anak, error) {
	var list []models.Anak
	err := r.db.
		Model(&models.Anak{}).
		Joins("JOIN kehamilan k ON k.id = anak.kehamilan_id").
		Joins("JOIN ibu i ON i.id = k.ibu_id").
		Joins("JOIN penduduk p_ibu ON p_ibu.id = i.penduduk_id").
		Joins("JOIN pengguna u ON u.penduduk_id = p_ibu.id").
		Where("u.id = ?", userID).
		Preload("Penduduk").
		Preload("Kehamilan").
		Order("anak.created_at DESC").
		Find(&list).Error
	return list, err
}

func (r *IbuRepository) Update(ibu *models.Ibu) error {
	return r.db.Model(ibu).Updates(ibu).Error
}

func (r *IbuRepository) Delete(id int32) error {
	result := r.db.Delete(&models.Ibu{}, id)
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return errors.New("data ibu tidak ditemukan")
	}
	return nil
}

// func (r *IbuRepository) FindByPendudukID(pendudukID int32) (*models.Ibu, error) {
// 	var ibu models.Ibu

// 	err := r.db.
// 		Where("penduduk_id = ?", pendudukID). // ✅ FIX
// 		First(&ibu).Error

// 	if errors.Is(err, gorm.ErrRecordNotFound) {
// 		return nil, nil
// 	}

// 	return &ibu, err
// }

func (r *IbuRepository) FindByPendudukID(pendudukID int32) (*models.Ibu, error) {
	var ibu models.Ibu
	err := r.db.
		Where("penduduk_id = ?", pendudukID).
		First(&ibu).Error

	// Jika tidak ditemukan, return nil, nil (bukan error)
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}

	if err != nil {
		return nil, err
	}

	// Load Kependudukan manual
	var kependudukan models.Kependudukan
	if err := r.db.Where("id = ?", pendudukID).First(&kependudukan).Error; err == nil {
		ibu.Kependudukan = &kependudukan
	}

	return &ibu, nil
}

// func (r *IbuRepository) GetDashboard() ([]models.IbuDashboardDTO, error) {
// 	var result []models.IbuDashboardDTO

// 	err := r.db.
// 	Table("ibu i").
// 	Select(`
// 		i.id as id_ibu,
// 		kp.nama_lengkap,
// 		kp.dusun,

// 		k.status_kehamilan,
// 		k.uk_kehamilan_saat_ini as usia_kehamilan,

// 		p.tanggal_periksa,
// 		p.tempat_periksa,
// 		p.trimester,
// 		p.kunjungan_ke,
// 		p.skor_risiko,
// 		p.status_risiko,
// 		p.sistole,
// 		p.diastole,
// 		p.tes_lab_hb as hb,

// 		k.id as kehamilan_id
// 	`).

// 	Joins("JOIN penduduk kp ON kp.id = i.penduduk_id").

// 	//  INNER JOIN → hanya ibu yang punya kehamilan aktif
// 	Joins(`
// 		JOIN kehamilan k ON k.id = (
// 			SELECT k2.id
// 			FROM kehamilan k2
// 			WHERE k2.ibu_id = i.id
// 			AND k2.status_kehamilan IS NOT NULL
// 			AND k2.status_kehamilan != ''

// 			ORDER BY k2.created_at DESC
// 			LIMIT 1
// 		)
// 	`).

// 	Joins(`
// 		LEFT JOIN pemeriksaan_kehamilan p ON p.id_periksa = (
// 			SELECT p2.id_periksa
// 			FROM pemeriksaan_kehamilan p2
// 			WHERE p2.kehamilan_id = k.id
// 			ORDER BY p2.tanggal_periksa DESC
// 			LIMIT 1
// 		)
// 	`).

// 	Scan(&result).Error

// return result, err
// }
func (r *IbuRepository) GetDashboard(posyanduID *int32, role string) ([]models.IbuDashboardDTO, error) {
	var result []models.IbuDashboardDTO

	query := r.db.
		Table("ibu i").
		Select(`
            i.id as id_ibu,
            kp.nama_anggota_keluarga,
            kp.dusun,
            k.status_kehamilan,
            k.hpht,
            k.uk_kehamilan_saat_ini as usia_kehamilan,
            p.tanggal_periksa,
            p.tempat_periksa,
            p.trimester,
            p.kunjungan_ke,
            p.skor_risiko,
            COALESCE(p.status_risiko, '') as status_risiko,
            p.sistole,
            p.diastole,
            p.tes_lab_hb as hb,
            k.id as kehamilan_id
        `).
		Joins(`JOIN penduduk kp ON kp.id = i.penduduk_id`).
		Joins(`INNER JOIN kehamilan k ON k.ibu_id = i.id AND k.deleted_at IS NULL`).
		Joins(`
            LEFT JOIN pemeriksaan_kehamilan p ON p.id_periksa = (
                SELECT p2.id_periksa
                FROM pemeriksaan_kehamilan p2
                WHERE p2.kehamilan_id = k.id
                AND p2.tanggal_periksa IS NOT NULL
                ORDER BY 
                    p2.tanggal_periksa DESC,
                    p2.created_at DESC,
                    p2.id_periksa DESC
                LIMIT 1
            )
        `).
		Order(`i.created_at DESC, i.id ASC, k.id ASC, p.tanggal_periksa DESC`)

	// Filter desa hanya jika role TIDAK memiliki akses penuh
	if !middlewares.HasFullAccess(role) && posyanduID != nil {
		query = query.Where("kp.posyandu_id = ?", *posyanduID)
	}

	err := query.Scan(&result).Error
	return result, err
}
