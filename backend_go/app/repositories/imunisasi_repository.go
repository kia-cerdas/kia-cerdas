package repositories

import (
	"errors"
	"monitoring-service/app/models"
	"time"

	"gorm.io/gorm"
)

type RiwayatImunisasiResult struct {
	TanggalDiberikan time.Time
}

func (m *Main) GetAnakByUserID(userID int32) ([]models.ImunisasiAnak, error) {
	var anaks []models.ImunisasiAnak

	err := m.postgres.
		Table("anak a").
		Select(`
		a.*,
		p_anak.tanggal_lahir
	`).
		Joins(`
		JOIN kehamilan k ON k.id = a.kehamilan_id
	`).
		Joins(`
		JOIN ibu i ON i.id = k.ibu_id
	`).
		Joins(`
		JOIN pengguna p ON p.penduduk_id = i.penduduk_id
	`).
		Joins(`
		JOIN penduduk p_anak ON p_anak.id = a.penduduk_id
	`).
		Where("p.id = ?", userID).
		Find(&anaks).Error

	if err != nil {
		return nil, err
	}

	return anaks, nil
}

func (m *Main) GetAturanVaksinAnak() ([]models.AturanVaksinAnak, error) {
	var aturan []models.AturanVaksinAnak

	err := m.postgres.
		Where("deleted_at IS NULL").
		Order("id ASC").
		Find(&aturan).Error

	if err != nil {
		return nil, err
	}

	return aturan, nil
}

func (m *Main) IsJadwalExist(
	anakID int32,
	dosisID int64,
) (bool, error) {

	var count int64

	err := m.postgres.
		Model(&models.JadwalImunisasiAnak{}).
		Where("id_anak = ?", anakID).
		Where("id_dosis_vaksin = ?", dosisID).
		Count(&count).Error

	if err != nil {
		return false, err
	}

	return count > 0, nil
}

func (m *Main) GetRiwayatImunisasi(
	anakID int32,
	dosisID int64,
) (*RiwayatImunisasiResult, error) {

	var result RiwayatImunisasiResult

	err := m.postgres.
		Table("catatan_imunisasi_anak cia").
		Select("cia.tanggal_diberikan").
		Joins("JOIN jadwal_imunisasi_anak jia ON jia.id = cia.jadwal_imunisasi_anak_id").
		Where("jia.anak_id = ?", anakID).
		Where("jia.id_dosis_vaksin = ?", dosisID).
		Order("cia.tanggal_diberikan DESC").
		First(&result).Error

	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, gorm.ErrRecordNotFound
		}
		return nil, err
	}

	return &result, nil
}

func (m *Main) CreateJadwalImunisasiAnak(
	jadwal *models.JadwalImunisasiAnak,
) error {

	return m.postgres.Create(jadwal).Error
}

func (m *Main) UpdateJadwalStatus() error {
	type JadwalWithTanggalLahir struct {
		ID                 uint
		TanggalEstimasi    *time.Time
		TanggalLahir       time.Time
		StatusJadwalID     uint
	}

	var jadwals []JadwalWithTanggalLahir

	err := m.postgres.
		Table("jadwal_imunisasi_anak jia").
		Select("jia.id, jia.tanggal_estimasi, p.tanggal_lahir, jia.id_status_jadwal").
		Joins("JOIN anak a ON a.id = jia.anak_id").
		Joins("JOIN penduduk p ON p.id = a.penduduk_id").
		Find(&jadwals).Error

	if err != nil {
		return err
	}

	for _, jadwal := range jadwals {
		if jadwal.TanggalEstimasi == nil {
			continue
		}

		// Hitung diff antara TanggalEstimasi dengan TanggalLahir
		diff := int(jadwal.TanggalEstimasi.Sub(jadwal.TanggalLahir).Hours() / 24)

		var statusID int32

		switch {
		case diff >= 1:
			statusID = 1 // lebih 1 hari dari tanggal lahir
		case diff == 0:
			statusID = 2 // 0 hari dari tanggal lahir
		case diff >= -6 && diff < 0:
			statusID = 3 // kurang 1-6 hari
		case diff >= -14 && diff < -6:
			statusID = 4 // kurang 7-14 hari
		default:
			statusID = 5 // lebih dari 14 hari
		}

		_ = m.postgres.
			Model(&models.JadwalImunisasiAnak{}).
			Where("id = ?", jadwal.ID).
			Update("id_status_jadwal", statusID).Error
	}

	return nil
}

// func (m *Main) CountAnakImunisasiTerlambat() (int64, error) {
// 	var count int64

// 	err := m.postgres.
// 		Table("jadwal_imunisasi_anak jia").
// 		Where("jia.tanggal_estimasi IS NOT NULL").
// 		Where("jia.tanggal_estimasi < ?", time.Now()).
// 		Where("jia.id_status_jadwal != ?", 3).
// 		Distinct("jia.id_anak").
// 		Count(&count).Error

// 	if err != nil {
// 		return 0, err
// 	}

// 	return count, nil
// }
