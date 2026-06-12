package repositories

import (
	"errors"
	"monitoring-service/app/models"

	"gorm.io/gorm"
)

type SkriningPreeklampsiaRepository struct {
	db *gorm.DB
}

func NewSkriningPreeklampsiaRepository(db *gorm.DB) *SkriningPreeklampsiaRepository {
	return &SkriningPreeklampsiaRepository{db: db}
}

func (r *SkriningPreeklampsiaRepository) Create(s *models.SkriningPreeklampsia) error {
	return r.db.Create(s).Error
}

func (r *SkriningPreeklampsiaRepository) FindByID(id int32) (*models.SkriningPreeklampsia, error) {
	var s models.SkriningPreeklampsia
	err := r.db.Preload("Kehamilan.Ibu.Kependudukan").First(&s, id).Error
	return &s, err
}

func (r *SkriningPreeklampsiaRepository) FindByKehamilanID(kehamilanID int32) ([]models.SkriningPreeklampsia, error) {
	var list []models.SkriningPreeklampsia
	err := r.db.Where("kehamilan_id = ?", kehamilanID).Find(&list).Error
	return list, err
}

func (r *SkriningPreeklampsiaRepository) Update(s *models.SkriningPreeklampsia) error {
	return r.db.Model(s).Updates(map[string]interface{}{
		"anamnesis_multipara_pasangan_baru_sedang":         s.AnamnesisMultiparaPasanganBaruSedang,
		"anamnesis_teknologi_reproduksi_berbantu_sedang":   s.AnamnesisTeknologiReproduksiBerbantuSedang,
		"anamnesis_umur_diatas35_tahun_sedang":             s.AnamnesisUmurDiatas35TahunSedang,
		"anamnesis_nulipara_sedang":                        s.AnamnesisNuliparaSedang,
		"anamnesis_jarak_kehamilan_diatas10_tahun_sedang":  s.AnamnesisJarakKehamilanDiatas10TahunSedang,
		"anamnesis_riwayat_preeklampsia_keluarga_sedang":   s.AnamnesisRiwayatPreeklampsiaKeluargaSedang,
		"anamnesis_obesitas_imt_diatas30_sedang":           s.AnamnesisObesitasIMTDiatas30Sedang,
		"anamnesis_riwayat_preeklampsia_sebelumnya_tinggi": s.AnamnesisRiwayatPreeklampsiaSebelumnyaTinggi,
		"anamnesis_kehamilan_multipel_tinggi":              s.AnamnesisKehamilanMultipelTinggi,
		"anamnesis_diabetes_dalam_kehamilan_tinggi":        s.AnamnesisDiabetesDalamKehamilanTinggi,
		"anamnesis_hipertensi_kronik_tinggi":               s.AnamnesisHipertensiKronikTinggi,
		"anamnesis_penyakit_ginjal_tinggi":                 s.AnamnesisPenyakitGinjalTinggi,
		"anamnesis_penyakit_autoimun_sle_tinggi":           s.AnamnesisPenyakitAutoimunSLETinggi,
		"anamnesis_anti_phospholipid_syndrome_tinggi":      s.AnamnesisAntiPhospholipidSyndromeTinggi,
		"fisik_map_diatas90mm_hg":                          s.FisikMAPDiatas90mmHg,
		"fisik_proteinuria_urin_celup":                     s.FisikProteinuriaUrinCelup,
		"kesimpulan_skrining_preeklampsia":                 s.KesimpulanSkriningPreeklampsia,
	}).Error
}

func (r *SkriningPreeklampsiaRepository) Delete(id int32) error {
	result := r.db.Delete(&models.SkriningPreeklampsia{}, id)
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return errors.New("data skrining preeklampsia tidak ditemukan")
	}
	return nil
}

// MODUL IBU
func (r *SkriningPreeklampsiaRepository) IsOwnedByUser(skriningID int32, userID int32) (bool, error) {
	var count int64

	err := r.db.
		Table("skrining_preeklampsia s").
		Joins("JOIN kehamilan k ON k.id = s.kehamilan_id").
		Joins("JOIN ibu i ON i.id = k.ibu_id").
		Joins("JOIN penduduk p ON p.id = i.penduduk_id").
		Joins("JOIN pengguna u ON u.penduduk_id = p.id").
		Where("s.id = ? AND u.id = ?", skriningID, userID).
		Count(&count).Error

	return count > 0, err
}

// // MODUL IBU (INTERNAL BACKUP ONLY)
// func (r *SkriningPreeklampsiaRepository) FindMineByUserID(userID int32) (*models.SkriningPreeklampsia, error) {
// 	var data models.SkriningPreeklampsia

// 	err := r.db.
// 		Table("skrining_preeklampsia s").
// 		Select("s.*").
// 		Joins("JOIN kehamilan k ON k.id = s.kehamilan_id").
// 		Joins("JOIN ibu i ON i.id = k.ibu_id").
// 		Joins("JOIN penduduk p ON p.id = i.penduduk_id").
// 		Joins("JOIN pengguna u ON u.id = p.id").
// 		Where("u.id = ?", userID).
// 		Order("s.id DESC").
// 		First(&data).Error

// 	return &data, err
// }

// MODUL IBU (SUPABASE UTAMA)
func (r *SkriningPreeklampsiaRepository) FindMineByUserID(userID int32) (*models.SkriningPreeklampsia, error) {
	var data models.SkriningPreeklampsia

	err := r.db.
		Table("skrining_preeklampsia s").
		Select("s.*").
		Joins("JOIN kehamilan k ON k.id = s.kehamilan_id").
		Joins("JOIN ibu i ON i.id = k.ibu_id").
		Joins("JOIN penduduk p ON p.id = i.penduduk_id").
		Joins("JOIN pengguna u ON u.penduduk_id = p.id").
		Where("u.id = ?", userID).
		Order("s.id DESC").
		First(&data).Error

	return &data, err
}
