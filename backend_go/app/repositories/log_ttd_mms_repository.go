package repositories

import (
	"monitoring-service/app/models"

	"gorm.io/gorm"
)

type LogTTDMMSRepository struct {
	db *gorm.DB
}

func NewLogTTDMMSRepository(db *gorm.DB) *LogTTDMMSRepository {
	return &LogTTDMMSRepository{db: db}
}

func (r *LogTTDMMSRepository) FindActiveKehamilanByUserID(userID int32) (*models.Kehamilan, error) {
	var kehamilan models.Kehamilan

	err := r.db.
		Table("kehamilan k").
		Select("k.*").
		Joins("JOIN ibu i ON i.id = k.ibu_id").
		Joins("JOIN penduduk p ON p.id = i.penduduk_id").
		Joins("JOIN pengguna u ON u.penduduk_id = p.id").
		Where("u.id = ?", userID).
		Where("k.status_kehamilan IN ?", []string{"aktif", "TRIMESTER 1", "TRIMESTER 2", "TRIMESTER 3"}).
		Order("k.created_at DESC").
		First(&kehamilan).Error

	return &kehamilan, err
}

func (r *LogTTDMMSRepository) FindByKehamilanID(kehamilanID int32) ([]models.LogTTDMMS, error) {
	var list []models.LogTTDMMS

	err := r.db.
		Where("kehamilan_id = ?", kehamilanID).
		Order("bulan_ke ASC, hari_ke ASC").
		Find(&list).Error

	return list, err
}

func (r *LogTTDMMSRepository) Upsert(log *models.LogTTDMMS) error {
	var existing models.LogTTDMMS

	err := r.db.
		Where("kehamilan_id = ? AND bulan_ke = ? AND hari_ke = ?",
			log.KehamilanID,
			log.BulanKe,
			log.HariKe,
		).
		First(&existing).Error

	if err == nil {
		existing.SudahDiminum = log.SudahDiminum
		return r.db.Save(&existing).Error
	}

	if err == gorm.ErrRecordNotFound {
		return r.db.Create(log).Error
	}

	return err
}


// BAGIAN KADER
 
// RekapIbuTTDMMS adalah struct hasil rekap per ibu hamil untuk kader.
type RekapIbuTTDMMS struct {
	HPHT            string `json:"hpht"`
	IbuID           int32  `json:"ibu_id"`
	KehamilanID     int32  `json:"kehamilan_id"`
	NamaIbu         string `json:"nama_ibu"`
	BulanKe         int32  `json:"bulan_ke"`
	TotalHari       int32  `json:"total_hari"`
	TotalDiminum    int32  `json:"total_diminum"`
	TotalTerlewat   int32  `json:"total_terlewat"`
	StatusKehamilan string `json:"status_kehamilan"`
}
 
// (Dihapus FindKaderByUserID karena sudah tidak dipakai)
 
// kehamilanWithNama adalah struct bantu untuk hasil query JOIN dengan nama ibu.
type kehamilanWithNama struct {
	models.Kehamilan
	NamaIbu string `gorm:"column:nama_ibu"`
}
 
// FindAllActiveKehamilanByPosyanduID mengambil semua kehamilan aktif (TRIMESTER 1/2/3)
// dan NIFAS ibu di posyandu yang sama dengan kader. Nama ibu diambil langsung via JOIN.
func (r *LogTTDMMSRepository) FindAllActiveKehamilanByPosyanduID(posyanduID int32) ([]models.Kehamilan, error) {
	var rows []kehamilanWithNama

	err := r.db.
		Table("kehamilan k").
		Select("k.*, kpd.nama_anggota_keluarga AS nama_ibu").
		Joins("JOIN ibu i ON i.id = k.ibu_id").
		Joins("JOIN penduduk kpd ON kpd.id = i.penduduk_id").
		Where("kpd.posyandu_id = ?", posyanduID).
		Where("k.status_kehamilan IN ?", []string{"aktif", "TRIMESTER 1", "TRIMESTER 2", "TRIMESTER 3", "NIFAS"}).
		Where("k.deleted_at IS NULL").
		Scan(&rows).Error
 
	if err != nil {
		return nil, err
	}
 
	list := make([]models.Kehamilan, 0, len(rows))
	for _, row := range rows {
		k := row.Kehamilan
		if k.Ibu == nil {
			k.Ibu = &models.Ibu{}
		}
		if k.Ibu.Kependudukan == nil {
			k.Ibu.Kependudukan = &models.Kependudukan{}
		}
		k.Ibu.Kependudukan.NamaAnggotaKeluarga = row.NamaIbu
		list = append(list, k)
	}
 
	return list, nil
}
 
// FindLogByKehamilanIDs mengambil semua log TTD/MMS dari daftar kehamilan_id sekaligus.
func (r *LogTTDMMSRepository) FindLogByKehamilanIDs(kehamilanIDs []int32) ([]models.LogTTDMMS, error) {
	var list []models.LogTTDMMS
	if len(kehamilanIDs) == 0 {
		return list, nil
	}
	err := r.db.
		Where("kehamilan_id IN ?", kehamilanIDs).
		Order("kehamilan_id ASC, bulan_ke ASC, hari_ke ASC").
		Find(&list).Error
	return list, err
}
 
// IsKehamilanInPosyandu memverifikasi bahwa kehamilan tertentu memang milik ibu
// yang terdaftar di posyandu yang sama dengan kader (security check).
func (r *LogTTDMMSRepository) IsKehamilanInPosyandu(kehamilanID int32, posyanduID int32) (bool, error) {
	var count int64
	err := r.db.
		Table("kehamilan k").
		Joins("JOIN ibu i ON i.id = k.ibu_id").
		Joins("JOIN penduduk p ON p.id = i.penduduk_id").
		Joins("JOIN pengguna u ON u.penduduk_id = p.id").
		Joins("JOIN roles rl ON rl.id = u.role_id").
		Where("k.id = ?", kehamilanID).
		Where("p.posyandu_id = ?", posyanduID).
		Where("rl.name = ?", "Ibu").
		Where("k.deleted_at IS NULL").
		Count(&count).Error
	return count > 0, err
}