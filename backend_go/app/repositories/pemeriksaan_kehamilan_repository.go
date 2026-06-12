package repositories

import (
	"errors"
	"monitoring-service/app/models"

	"gorm.io/gorm"
)

type PemeriksaanKehamilanRepository struct {
	db *gorm.DB
}

func NewPemeriksaanKehamilanRepository(db *gorm.DB) *PemeriksaanKehamilanRepository {
	return &PemeriksaanKehamilanRepository{db: db}
}

// ================= CREATE ==================== //

func (r *PemeriksaanKehamilanRepository) Create(p *models.PemeriksaanKehamilan) error {
	return r.db.Create(p).Error
}

// ================= READ ====================== //

func (r *PemeriksaanKehamilanRepository) FindByID(id int32) (*models.PemeriksaanKehamilan, error) {
	var p models.PemeriksaanKehamilan

	err := r.db.
		Preload("Kehamilan").
		Preload("Kehamilan.Ibu").
		Preload("Kehamilan.Ibu.Kependudukan").
		First(&p, id).Error

	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("data pemeriksaan tidak ditemukan")
		}
		return nil, err
	}

	return &p, nil
}

func (r *PemeriksaanKehamilanRepository) FindByKehamilanID(kehamilanID int32) ([]models.PemeriksaanKehamilan, error) {
	var list []models.PemeriksaanKehamilan

	err := r.db.
		Where("kehamilan_id = ?", kehamilanID).
		Order("tanggal_periksa ASC").
		Find(&list).Error

	if err != nil {
		return nil, err
	}

	return list, nil
}

// ================= UPDATE ==================== //

func (r *PemeriksaanKehamilanRepository) Update(p *models.PemeriksaanKehamilan) error {
	// Gunakan map eksplisit agar GORM hanya update kolom di tabel
	// pemeriksaan_kehamilan saja, tanpa menyentuh tabel relasi (Kehamilan, Ibu, dll)
	result := r.db.Model(&models.PemeriksaanKehamilan{}).
		Where("id_periksa = ?", p.IDPeriksa).
		Updates(map[string]interface{}{
			"trimester":                 p.Trimester,
			"kunjungan_ke":              p.KunjunganKe,
			"minggu_kehamilan":          p.MingguKehamilan,
			"tanggal_periksa":           p.TanggalPeriksa,
			"tempat_periksa":            p.TempatPeriksa,
			"berat_badan":               p.BeratBadan,
			"tinggi_badan":              p.TinggiBadan,
			"lingkar_lengan_atas":       p.LingkarLenganAtas,
			"sistole":                   p.Sistole,
			"diastole":                  p.Diastole,
			"tinggi_rahim":              p.TinggiRahim,
			"letak_denyut_jantung_bayi": p.LetakDenyutJantungBayi,
			"denyut_jantung_janin":      p.DenyutJantungJanin,
			"status_imunisasi_tetanus":  p.StatusImunisasiTetanus,
			"konseling":                 p.Konseling,
			"skrining_dokter":           p.SkriningDokter,
			"tablet_tambah_darah":       p.TabletTambahDarah,
			"tes_lab_hb":                p.TesLabHb,
			"tes_golongan_darah":        p.TesGolonganDarah,
			"tes_lab_protein_urine":     p.TesLabProteinUrine,
			"tes_lab_gula_darah":        p.TesLabGulaDarah,
			"usg":                       p.USG,
			"tripel_eliminasi":          p.TripelEliminasi,
			"tata_laksana_kasus":        p.TataLaksanaKasus,
			"skor_risiko":               p.SkorRisiko,
			"status_risiko":             p.StatusRisiko,
			"detail_risiko":             p.DetailRisiko,
		})

	if result.Error != nil {
		return result.Error
	}

	if result.RowsAffected == 0 {
		return errors.New("gagal update, data tidak ditemukan")
	}

	return nil
}

// ================= DELETE ==================== //

func (r *PemeriksaanKehamilanRepository) Delete(id int32) error {
	result := r.db.Delete(&models.PemeriksaanKehamilan{}, id)

	if result.Error != nil {
		return result.Error
	}

	if result.RowsAffected == 0 {
		return errors.New("data pemeriksaan kehamilan tidak ditemukan")
	}

	return nil
}

// ============ OPTIONAL (ADVANCED) ============ //

func (r *PemeriksaanKehamilanRepository) FindLatestByKehamilanID(kehamilanID int32) (*models.PemeriksaanKehamilan, error) {
	var p models.PemeriksaanKehamilan

	err := r.db.
		Where("kehamilan_id = ?", kehamilanID).
		Order("tanggal_periksa DESC").
		First(&p).Error

	if err != nil {
		return nil, err
	}

	return &p, nil
}

// MODUL IBU
func (r *PemeriksaanKehamilanRepository) IsOwnedByUser(periksaID int32, userID int32) (bool, error) {
	var count int64

	err := r.db.
		Table("pemeriksaan_kehamilan p").
		Joins("JOIN kehamilan k ON k.id = p.kehamilan_id").
		Joins("JOIN ibu i ON i.id = k.ibu_id").
		Joins("JOIN penduduk pd ON pd.id = i.penduduk_id").
		Joins("JOIN pengguna u ON u.penduduk_id = pd.id").
		Where("p.id = ? AND u.id = ?", periksaID, userID).
		Count(&count).Error

	return count > 0, err
}

// MODUL IBU
func (r *PemeriksaanKehamilanRepository) FindMineByUserID(userID int32) ([]models.PemeriksaanKehamilan, error) {
	var list []models.PemeriksaanKehamilan

	err := r.db.
		Table("pemeriksaan_kehamilan p").
		Joins("JOIN kehamilan k ON k.id = p.kehamilan_id").
		Joins("JOIN ibu i ON i.id = k.ibu_id").
		Joins("JOIN penduduk pd ON pd.id = i.penduduk_id").
		// Joins("JOIN pengguna u ON u.id = pd.id").
		Joins("JOIN pengguna u ON u.penduduk_id = pd.id").
		Where("u.id = ?", userID).
		Order("p.tanggal_periksa DESC").
		Find(&list).Error

	return list, err
}
