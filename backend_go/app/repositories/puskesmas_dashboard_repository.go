package repositories

import (
	"fmt"
	"time"

	"gorm.io/gorm"
)

type PuskesmasDashboardRepository struct {
	db *gorm.DB
}

func NewPuskesmasDashboardRepository(db *gorm.DB) *PuskesmasDashboardRepository {
	return &PuskesmasDashboardRepository{db: db}
}

// GetTargetDesaIDs returns the IDs of all active desa (dynamically monitored)
func (r *PuskesmasDashboardRepository) GetTargetDesaIDs() ([]int32, error) {
	var desaIDs []int32
	err := r.db.Table("desa").
		Where("deleted_at IS NULL AND is_active = true").
		Pluck("id", &desaIDs).Error
	return desaIDs, err
}

// CountPendudukByDesa counts active penduduk in a desa
func (r *PuskesmasDashboardRepository) CountPendudukByDesa(desaID int32) (int64, error) {
	var count int64
	err := r.db.Table("penduduk").
		Where("desa_id = ? AND deleted_at IS NULL", desaID).
		Count(&count).Error
	return count, err
}

// CountIbuByDesa counts ibu whose penduduk is in a desa
func (r *PuskesmasDashboardRepository) CountIbuByDesa(desaID int32) (int64, error) {
	var count int64
	err := r.db.Table("ibu").
		Joins("JOIN penduduk ON penduduk.id = ibu.penduduk_id").
		Where("penduduk.desa_id = ? AND penduduk.deleted_at IS NULL AND ibu.is_deleted IS NULL", desaID).
		Count(&count).Error
	return count, err
}

// CountKehamilanAktifByDesa counts active pregnancies in a desa
func (r *PuskesmasDashboardRepository) CountKehamilanAktifByDesa(desaID int32) (int64, error) {
	var count int64
	err := r.db.Table("kehamilan").
		Joins("JOIN ibu ON ibu.id = kehamilan.ibu_id").
		Joins("JOIN penduduk ON penduduk.id = ibu.penduduk_id").
		Where("penduduk.desa_id = ? AND penduduk.deleted_at IS NULL AND kehamilan.deleted_at IS NULL AND kehamilan.status_kehamilan != ?", desaID, "selesai").
		Count(&count).Error
	return count, err
}

// CountAnakByDesa counts children whose penduduk is in a desa
func (r *PuskesmasDashboardRepository) CountAnakByDesa(desaID int32) (int64, error) {
	var count int64
	err := r.db.Table("anak").
		Joins("JOIN penduduk ON penduduk.id = anak.penduduk_id").
		Where("penduduk.desa_id = ? AND penduduk.deleted_at IS NULL AND anak.deleted_at IS NULL", desaID).
		Count(&count).Error
	return count, err
}

// CountBalitaByDesa counts children age 0-5 in a desa
func (r *PuskesmasDashboardRepository) CountBalitaByDesa(desaID int32) (int64, error) {
	fiveYearsAgo := time.Now().AddDate(-5, 0, 0)
	var count int64
	err := r.db.Table("anak").
		Joins("JOIN penduduk ON penduduk.id = anak.penduduk_id").
		Where("penduduk.desa_id = ? AND penduduk.deleted_at IS NULL AND anak.deleted_at IS NULL AND penduduk.tanggal_lahir >= ?", desaID, fiveYearsAgo).
		Count(&count).Error
	return count, err
}

// CountBidanByDesa counts bidan in a desa
func (r *PuskesmasDashboardRepository) CountBidanByDesa(desaID int32) (int64, error) {
	var count int64
	err := r.db.Table("bidan").
		Joins("JOIN penduduk ON penduduk.id = bidan.penduduk_id").
		Where("penduduk.desa_id = ? AND penduduk.deleted_at IS NULL AND bidan.deleted_at IS NULL AND bidan.status = 'aktif'", desaID).
		Count(&count).Error
	return count, err
}

// CountRujukanByDesa counts referrals linked to ibu in a desa
func (r *PuskesmasDashboardRepository) CountRujukanByDesa(desaID int32) (int64, error) {
	var count int64
	err := r.db.Table("rujukan").
		Joins("JOIN kehamilan ON kehamilan.id = rujukan.kehamilan_id").
		Joins("JOIN ibu ON ibu.id = kehamilan.ibu_id").
		Joins("JOIN penduduk ON penduduk.id = ibu.penduduk_id").
		Where("penduduk.desa_id = ? AND penduduk.deleted_at IS NULL", desaID).
		Count(&count).Error
	return count, err
}

// CountStuntingByDesa counts stunting predictions per classification in a desa
func (r *PuskesmasDashboardRepository) CountStuntingByDesa(desaID int32) (risk int64, normal int64, err error) {
	err = r.db.Table("prediksi_stunting").
		Joins("JOIN anak ON anak.id = prediksi_stunting.anak_id").
		Joins("JOIN penduduk ON penduduk.id = anak.penduduk_id").
		Where("penduduk.desa_id = ? AND penduduk.deleted_at IS NULL AND prediksi_stunting.deleted_at IS NULL AND prediksi_stunting.classification IN ('STUNTING','AT_RISK')", desaID).
		Count(&risk).Error
	if err != nil {
		return 0, 0, err
	}

	err = r.db.Table("prediksi_stunting").
		Joins("JOIN anak ON anak.id = prediksi_stunting.anak_id").
		Joins("JOIN penduduk ON penduduk.id = anak.penduduk_id").
		Where("penduduk.desa_id = ? AND penduduk.deleted_at IS NULL AND prediksi_stunting.deleted_at IS NULL AND prediksi_stunting.classification = 'NORMAL'", desaID).
		Count(&normal).Error
	return risk, normal, err
}

// CountPemeriksaanByDesa counts pemeriksaan records for penduduk in a desa
func (r *PuskesmasDashboardRepository) CountPemeriksaanByDesa(desaID int32) (int64, error) {
	var count int64
	err := r.db.Table("pemeriksaans").
		Joins("JOIN penduduk ON penduduk.id = pemeriksaans.penduduk_id").
		Where("penduduk.desa_id = ? AND penduduk.deleted_at IS NULL AND pemeriksaans.deleted_at IS NULL", desaID).
		Count(&count).Error
	return count, err
}

// CountPemeriksaanByDesaFiltered counts distinct penduduk with at least one pemeriksaan
func (r *PuskesmasDashboardRepository) CountPemeriksaanByDesaFiltered(desaID int32) (int64, error) {
	var count int64
	err := r.db.Table("pemeriksaans").
		Distinct("pemeriksaans.penduduk_id").
		Joins("JOIN penduduk ON penduduk.id = pemeriksaans.penduduk_id").
		Where("penduduk.desa_id = ? AND penduduk.deleted_at IS NULL AND pemeriksaans.deleted_at IS NULL", desaID).
		Count(&count).Error
	return count, err
}

// GetMonthlyTrendData retrieves monthly aggregated data for the last 6 months
func (r *PuskesmasDashboardRepository) GetMonthlyTrendData(desaIDs []int32, months int) ([]map[string]interface{}, error) {
	since := time.Now().AddDate(0, -months, 0)

	type monthlyRow struct {
		YearMonth string `gorm:"column:ym"`
		Count     int64  `gorm:"column:cnt"`
	}

	// New penduduk registrations per month
	var pendudukRows []monthlyRow
	if err := r.db.Table("penduduk").
		Select("TO_CHAR(created_at, 'YYYY-MM') as ym, COUNT(*) as cnt").
		Where("desa_id IN ? AND deleted_at IS NULL AND created_at >= ?", desaIDs, since).
		Group("TO_CHAR(created_at, 'YYYY-MM')").
		Order("ym ASC").
		Scan(&pendudukRows).Error; err != nil {
		return nil, fmt.Errorf("gagal query trend penduduk bulanan: %w", err)
	}

	// Rujukan per month
	var rujukanRows []monthlyRow
	if err := r.db.Table("rujukan").
		Select("TO_CHAR(rujukan.created_at, 'YYYY-MM') as ym, COUNT(*) as cnt").
		Joins("JOIN kehamilan ON kehamilan.id = rujukan.kehamilan_id").
		Joins("JOIN ibu ON ibu.id = kehamilan.ibu_id").
		Joins("JOIN penduduk ON penduduk.id = ibu.penduduk_id").
		Where("penduduk.desa_id IN ? AND penduduk.deleted_at IS NULL AND rujukan.created_at >= ?", desaIDs, since).
		Group("TO_CHAR(rujukan.created_at, 'YYYY-MM')").
		Order("ym ASC").
		Scan(&rujukanRows).Error; err != nil {
		return nil, fmt.Errorf("gagal query trend rujukan bulanan: %w", err)
	}

	// Build month map
	monthMap := make(map[string]map[string]int64)
	for _, row := range pendudukRows {
		if monthMap[row.YearMonth] == nil {
			monthMap[row.YearMonth] = make(map[string]int64)
		}
		monthMap[row.YearMonth]["kasus_baru"] = row.Count
	}
	for _, row := range rujukanRows {
		if monthMap[row.YearMonth] == nil {
			monthMap[row.YearMonth] = make(map[string]int64)
		}
		monthMap[row.YearMonth]["rujukan"] = row.Count
	}

	// Convert to result
	var results []map[string]interface{}
	for ym, data := range monthMap {
		results = append(results, map[string]interface{}{
			"ym":             ym,
			"kasus_baru":     data["kasus_baru"],
			"rujukan":        data["rujukan"],
		})
	}

	return results, nil
}

// GetPriorityKehamilan gets high-risk pregnancies across target desa
func (r *PuskesmasDashboardRepository) GetPriorityKehamilan(desaIDs []int32, limit int) ([]map[string]interface{}, error) {
	var results []map[string]interface{}
	err := r.db.Table("kehamilan").
		Select(`
			kehamilan.id as id,
			penduduk.nama_lengkap as nama,
			desa.nama_desa as desa,
			kehamilan.status_kehamilan as status,
			kehamilan.uk_kehamilan_saat_ini as uk
		`).
		Joins("JOIN ibu ON ibu.id = kehamilan.ibu_id").
		Joins("JOIN penduduk ON penduduk.id = ibu.penduduk_id").
		Joins("JOIN desa ON desa.id = penduduk.desa_id").
		Where("penduduk.desa_id IN ? AND penduduk.deleted_at IS NULL AND kehamilan.deleted_at IS NULL AND kehamilan.status_kehamilan != 'selesai'", desaIDs).
		Order("kehamilan.uk_kehamilan_saat_ini DESC").
		Limit(limit).
		Scan(&results).Error
	return results, err
}

// GetPriorityStunting gets children with stunting risk across target desa
func (r *PuskesmasDashboardRepository) GetPriorityStunting(desaIDs []int32, limit int) ([]map[string]interface{}, error) {
	var results []map[string]interface{}
	err := r.db.Table("prediksi_stunting").
		Select(`
			prediksi_stunting.id as id,
			penduduk.nama_lengkap as nama,
			desa.nama_desa as desa,
			prediksi_stunting.classification as klasifikasi,
			prediksi_stunting.risk_percentage as risiko
		`).
		Joins("JOIN anak ON anak.id = prediksi_stunting.anak_id").
		Joins("JOIN penduduk ON penduduk.id = anak.penduduk_id").
		Joins("JOIN desa ON desa.id = penduduk.desa_id").
		Where("penduduk.desa_id IN ? AND penduduk.deleted_at IS NULL AND prediksi_stunting.deleted_at IS NULL AND prediksi_stunting.classification IN ('STUNTING','AT_RISK')", desaIDs).
		Order("prediksi_stunting.risk_percentage DESC").
		Limit(limit).
		Scan(&results).Error
	return results, err
}

// GetPriorityRujukan gets recent referrals across target desa
func (r *PuskesmasDashboardRepository) GetPriorityRujukan(desaIDs []int32, limit int) ([]map[string]interface{}, error) {
	var results []map[string]interface{}
	err := r.db.Table("rujukan").
		Select(`
			rujukan.id as id,
			penduduk.nama_lengkap as nama,
			desa.nama_desa as desa,
			rujukan.rujukan_diagnosis_akhir as diagnosis,
			rujukan.created_at as created_at
		`).
		Joins("JOIN kehamilan ON kehamilan.id = rujukan.kehamilan_id").
		Joins("JOIN ibu ON ibu.id = kehamilan.ibu_id").
		Joins("JOIN penduduk ON penduduk.id = ibu.penduduk_id").
		Joins("JOIN desa ON desa.id = penduduk.desa_id").
		Where("penduduk.desa_id IN ? AND penduduk.deleted_at IS NULL", desaIDs).
		Order("rujukan.created_at DESC").
		Limit(limit).
		Scan(&results).Error
	return results, err
}

// GetDesaName returns the nama_desa for a given desa_id
func (r *PuskesmasDashboardRepository) GetDesaName(desaID int32) (string, error) {
	var nama string
	err := r.db.Table("desa").
		Select("nama_desa").
		Where("id = ? AND deleted_at IS NULL", desaID).
		Scan(&nama).Error
	return nama, err
}

// GetKecamatanName returns the distinct kecamatan names for the target desa (joined with " & ")
func (r *PuskesmasDashboardRepository) GetKecamatanName(desaIDs []int32) (string, error) {
	var kecamatans []string
	err := r.db.Table("desa").
		Select("DISTINCT kecamatan").
		Where("id IN ? AND deleted_at IS NULL AND kecamatan != ''", desaIDs).
		Pluck("kecamatan", &kecamatans).Error
	if err != nil {
		return "", err
	}
	if len(kecamatans) == 0 {
		return "Semua Kecamatan", nil
	}
	// Join multiple kecamatan with " & "
	result := kecamatans[0]
	for i := 1; i < len(kecamatans); i++ {
		result += " & " + kecamatans[i]
	}
	return result, nil
}

// GetDesaNames returns map of desaID -> nama_desa
func (r *PuskesmasDashboardRepository) GetDesaNames(desaIDs []int32) (map[int32]string, error) {
	type row struct {
		ID       int32  `gorm:"column:id"`
		NamaDesa string `gorm:"column:nama_desa"`
	}
	var rows []row
	err := r.db.Table("desa").
		Select("id, nama_desa").
		Where("id IN ? AND deleted_at IS NULL", desaIDs).
		Find(&rows).Error
	if err != nil {
		return nil, err
	}
	result := make(map[int32]string)
	for _, r := range rows {
		result[r.ID] = r.NamaDesa
	}
	return result, nil
}

// Helper to format year-month
func FormatBulan(ym string) string {
	if len(ym) < 7 {
		return ym
	}
	months := map[string]string{
		"01": "Jan", "02": "Feb", "03": "Mar", "04": "Apr",
		"05": "Mei", "06": "Jun", "07": "Jul", "08": "Agu",
		"09": "Sep", "10": "Okt", "11": "Nov", "12": "Des",
	}
	m := ym[5:7]
	if name, ok := months[m]; ok {
		return fmt.Sprintf("%s %s", name, ym[:4])
	}
	return ym
}
