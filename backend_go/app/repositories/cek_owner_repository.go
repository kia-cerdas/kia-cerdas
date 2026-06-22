package repositories

import "monitoring-service/pkg/customerror"

func (m *Main) IsAnakMilikOrangtua(userID, anakID uint) (bool, error) {
	var count int64
	err := m.postgres.Table("anak a").
		Joins("JOIN kehamilan k ON k.id = a.kehamilan_id").
		Joins("JOIN ibu i ON i.id = k.ibu_id").
		Joins("JOIN pengguna u ON u.penduduk_id = i.penduduk_id").
		Where("a.id = ? AND u.id = ? AND a.deleted_at IS NULL AND k.deleted_at IS NULL AND i.is_deleted IS NULL", anakID, userID).
		Count(&count).Error
	if err != nil {
		return false, customerror.NewInternalServiceError("gagal memverifikasi kepemilikan data anak")
	}

	return count > 0, nil
}

func (m *Main) IsCatatanMilikOrangtua(userID, catatanID uint) (bool, error) {
	var count int64
	err := m.postgres.Table("catatan_pertumbuhan cp").
		Joins("JOIN anak a ON a.id = cp.anak_id").
		Joins("JOIN kehamilan k ON k.id = a.kehamilan_id").
		Joins("JOIN ibu i ON i.id = k.ibu_id").
		Joins("JOIN pengguna u ON u.penduduk_id = i.penduduk_id").
		Where("cp.id = ? AND u.id = ? AND cp.deleted_at IS NULL AND a.deleted_at IS NULL AND k.deleted_at IS NULL AND i.is_deleted IS NULL", catatanID, userID).
		Count(&count).Error
	if err != nil {
		return false, customerror.NewInternalServiceError("gagal memverifikasi kepemilikan data catatan")
	}

	return count > 0, nil
}
