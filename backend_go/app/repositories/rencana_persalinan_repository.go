package repositories

import (
	"errors"
	"monitoring-service/app/models"

	"gorm.io/gorm"
)

type RencanaPersalinanRepository struct {
	db *gorm.DB
}

func NewRencanaPersalinanRepository(db *gorm.DB) *RencanaPersalinanRepository {
	return &RencanaPersalinanRepository{db: db}
}

func (r *RencanaPersalinanRepository) Create(rp *models.RencanaPersalinan) error {
	return r.db.Create(rp).Error
}

func (r *RencanaPersalinanRepository) FindByID(id int32) (*models.RencanaPersalinan, error) {
	var rp models.RencanaPersalinan
	err := r.db.Preload("Kehamilan.Ibu.Kependudukan").
		First(&rp, "id_rencana_persalinan = ?", id).Error
	return &rp, err
}

// FindByIDWithoutPreload — untuk operasi update (tanpa preload relasi)
func (r *RencanaPersalinanRepository) FindByIDWithoutPreload(id int32) (*models.RencanaPersalinan, error) {
	var rp models.RencanaPersalinan
	err := r.db.First(&rp, "id_rencana_persalinan = ?", id).Error
	return &rp, err
}

func (r *RencanaPersalinanRepository) FindByKehamilanID(kehamilanID int32) ([]models.RencanaPersalinan, error) {
	var list []models.RencanaPersalinan
	err := r.db.Where("kehamilan_id = ?", kehamilanID).Find(&list).Error
	return list, err
}

// Update — menyimpan SEMUA field menggunakan map agar nilai kosong (string "") pun tersimpan.
// Menggunakan map[string]interface{} karena GORM.Updates() dengan struct mengabaikan zero-value.
func (r *RencanaPersalinanRepository) Update(rp *models.RencanaPersalinan) error {
	updates := map[string]interface{}{
		"nama_ibu_pernyataan":        rp.NamaIbuPernyataan,
		"alamat_ibu_pernyataan":      rp.AlamatIbuPernyataan,
		"perkiraan_bulan_persalinan": rp.PerkiraanBulanPersalinan,
		"perkiraan_tahun_persalinan": rp.PerkiraanTahunPersalinan,
		"fasyankes1_nama_tenaga":     rp.Fasyankes1NamaTenaga,
		"fasyankes1_nama_fasilitas":  rp.Fasyankes1NamaFasilitas,
		"fasyankes2_nama_tenaga":     rp.Fasyankes2NamaTenaga,
		"fasyankes2_nama_fasilitas":  rp.Fasyankes2NamaFasilitas,
		"sumber_dana_persalinan":     rp.SumberDanaPersalinan,
		"kendaraan1_nama":            rp.Kendaraan1Nama,
		"kendaraan1_hp":              rp.Kendaraan1HP,
		"kendaraan2_nama":            rp.Kendaraan2Nama,
		"kendaraan2_hp":              rp.Kendaraan2HP,
		"kendaraan3_nama":            rp.Kendaraan3Nama,
		"kendaraan3_hp":              rp.Kendaraan3HP,
		"metode_kontrasepsi_pilihan": rp.MetodeKontrasepsiPilihan,
		"donor_golongan_darah":       rp.DonorGolonganDarah,
		"donor_rhesus":               rp.DonorRhesus,
		"donor1_nama":                rp.Donor1Nama,
		"donor1_hp":                  rp.Donor1HP,
		"donor2_nama":                rp.Donor2Nama,
		"donor2_hp":                  rp.Donor2HP,
		"donor3_nama":                rp.Donor3Nama,
		"donor3_hp":                  rp.Donor3HP,
		"donor4_nama":                rp.Donor4Nama,
		"donor4_hp":                  rp.Donor4HP,
		"tanggal_pernyataan":         rp.TanggalPernyataan,
		"nama_suami_keluarga_ttd":    rp.NamaSuamiKeluargaTTD,
		"nama_ibu_hamil_ttd":         rp.NamaibuTTD,
		"nama_bidan_dokter_ttd":      rp.NamaBidanDokterTTD,
	}

	return r.db.Model(&models.RencanaPersalinan{}).
		Where("id_rencana_persalinan = ?", rp.IDRencanaPersalinan).
		Updates(updates).Error
}

func (r *RencanaPersalinanRepository) Delete(id int32) error {
	result := r.db.Delete(&models.RencanaPersalinan{}, "id_rencana_persalinan = ?", id)
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return errors.New("data rencana persalinan tidak ditemukan")
	}
	return nil
}
