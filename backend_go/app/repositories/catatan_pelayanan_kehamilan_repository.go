package repositories

import (
	"monitoring-service/app/models"

	"gorm.io/gorm"
)

type CatatanPelayananKehamilanRepository struct {
	db *gorm.DB
}

func NewCatatanPelayananKehamilanRepository(db *gorm.DB) *CatatanPelayananKehamilanRepository {
	return &CatatanPelayananKehamilanRepository{db: db}
}

// FindMineByUserID mengambil semua catatan milik ibu yang sedang login.
// Jika trimester > 0, difilter per trimester. Jika 0, ambil semua.
func (r *CatatanPelayananKehamilanRepository) FindMineByUserID(userID int32, trimester int8) ([]models.CatatanPelayananKehamilan, error) {
	var list []models.CatatanPelayananKehamilan
	q := r.db.
		Table("catatan_pelayanan_kehamilan").
		Joins("JOIN kehamilan k ON k.id = catatan_pelayanan_kehamilan.kehamilan_id").
		Joins("JOIN ibu i ON i.id = k.ibu_id").
		Joins("JOIN penduduk pd ON pd.id = i.penduduk_id").
		Joins("JOIN pengguna u ON u.penduduk_id = pd.id").
		Where("u.id = ?", userID)
	if trimester > 0 {
		q = q.Where("catatan_pelayanan_kehamilan.trimester = ?", trimester)
	}
	err := q.Order("catatan_pelayanan_kehamilan.tanggal_periksa_stamp_paraf DESC").Find(&list).Error
	return list, err
}
