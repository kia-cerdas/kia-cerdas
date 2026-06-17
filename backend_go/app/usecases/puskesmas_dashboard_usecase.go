package usecases

import (
	"fmt"
	"log"
	"sort"
	"time"

	"monitoring-service/app/models"
	"monitoring-service/app/repositories"
)

type PuskesmasDashboardUsecase interface {
	GetDashboardData() (*models.PuskesmasDashboardResponse, error)
}

type puskesmasDashboardUsecase struct {
	repo *repositories.PuskesmasDashboardRepository
}

func NewPuskesmasDashboardUsecase(repo *repositories.PuskesmasDashboardRepository) PuskesmasDashboardUsecase {
	return &puskesmasDashboardUsecase{repo: repo}
}

func (u *puskesmasDashboardUsecase) GetDashboardData() (*models.PuskesmasDashboardResponse, error) {
	// 1. Get target desa IDs (Sitoluama & Hutabulu Mejan)
	desaIDs, err := u.repo.GetTargetDesaIDs()
	if err != nil {
		return nil, fmt.Errorf("gagal mengambil daftar desa target: %w", err)
	}
	if len(desaIDs) == 0 {
		log.Println("[PuskesmasDashboard] Tidak ada desa target ditemukan, menggunakan data kosong")
		return u.emptyResponse(), nil
	}

	// 2. Get desa names
	desaNames, err := u.repo.GetDesaNames(desaIDs)
	if err != nil {
		log.Printf("[PuskesmasDashboard] Error getting desa names: %v", err)
	}

	// 3. Get kecamatan
	kecamatan, _ := u.repo.GetKecamatanName(desaIDs)

	// 4. Build per-desa summaries
	var desaList []models.DesaSummary
	var totalSasaran, totalPenduduk, totalIbu, totalIbuHamil, totalAnak, totalBalita, totalRujukan int64
	var cakupanSum float64
	var desaIntervensi int64

	for _, desaID := range desaIDs {
		summary, err := u.buildDesaSummary(desaID, desaNames[desaID])
		if err != nil {
			log.Printf("[PuskesmasDashboard] Error building summary for desa %d: %v", desaID, err)
			continue
		}
		desaList = append(desaList, *summary)

		totalPenduduk += summary.TotalPenduduk
		totalIbu += summary.TotalIbu
		totalIbuHamil += summary.TotalIbuHamil
		totalAnak += summary.TotalAnak
		totalBalita += summary.TotalBalita
		totalRujukan += summary.TotalRujukan
		totalSasaran += summary.TotalIbu + summary.TotalAnak
		cakupanSum += summary.CakupanLayanan

		if summary.CakupanLayanan < 60 {
			desaIntervensi++
		}
	}

	// 5. Calculate overall stats
	var cakupanRataRata float64
	if len(desaList) > 0 {
		cakupanRataRata = cakupanSum / float64(len(desaList))
	}

	overall := models.OverallStats{
		TotalSasaranAktif:      totalSasaran,
		CakupanLayananRataRata: cakupanRataRata,
		DesaPerluIntervensi:    desaIntervensi,
		KasusRujukanAktif:      totalRujukan,
		TotalPenduduk:          totalPenduduk,
		TotalIbu:               totalIbu,
		TotalIbuHamil:          totalIbuHamil,
		TotalAnak:              totalAnak,
		TotalBalita:            totalBalita,
	}

	// 6. Build monthly trend data
	trenBulanan := u.buildMonthlyTrend(desaIDs)

	// 7. Build priority cases
	kasusPrioritas := u.buildPriorityCases(desaIDs)

	// 8. Format period
	now := time.Now()
	periode := fmt.Sprintf("%s – %s %d",
		monthName(now.AddDate(0, -2, 0).Month()),
		monthName(now.Month()), now.Year())

	return &models.PuskesmasDashboardResponse{
		Kecamatan:      kecamatan,
		Periode:        periode,
		DesaList:       desaList,
		Overall:        overall,
		TrenBulanan:    trenBulanan,
		KasusPrioritas: kasusPrioritas,
	}, nil
}

func (u *puskesmasDashboardUsecase) buildDesaSummary(desaID int32, namaDesa string) (*models.DesaSummary, error) {
	penduduk, _ := u.repo.CountPendudukByDesa(desaID)
	ibu, _ := u.repo.CountIbuByDesa(desaID)
	ibuHamil, _ := u.repo.CountKehamilanAktifByDesa(desaID)
	anak, _ := u.repo.CountAnakByDesa(desaID)
	balita, _ := u.repo.CountBalitaByDesa(desaID)
	bidan, _ := u.repo.CountBidanByDesa(desaID)
	rujukan, _ := u.repo.CountRujukanByDesa(desaID)
	stuntingRisk, stuntingNormal, _ := u.repo.CountStuntingByDesa(desaID)
	pemeriksaanDone, _ := u.repo.CountPemeriksaanByDesaFiltered(desaID)

	// Coverage = (distinct penduduk with pemeriksaan) / total penduduk * 100
	var cakupan float64
	if penduduk > 0 {
		cakupan = float64(pemeriksaanDone) / float64(penduduk) * 100
	}
	if cakupan > 100 {
		cakupan = 100
	}

	status := "Baik"
	if cakupan < 60 {
		status = "Intervensi"
	} else if cakupan < 80 {
		status = "Perlu Ditingkatkan"
	}

	return &models.DesaSummary{
		DesaID:         desaID,
		NamaDesa:       namaDesa,
		TotalPenduduk:  penduduk,
		TotalIbu:       ibu,
		TotalIbuHamil:  ibuHamil,
		TotalAnak:      anak,
		TotalBalita:    balita,
		TotalRujukan:   rujukan,
		CakupanLayanan: cakupan,
		StatusCakupan:  status,
		TotalBidan:     bidan,
		StuntingRisk:   stuntingRisk,
		StuntingNormal: stuntingNormal,
	}, nil
}

func (u *puskesmasDashboardUsecase) buildMonthlyTrend(desaIDs []int32) []models.MonthlyTrend {
	rawData, err := u.repo.GetMonthlyTrendData(desaIDs, 6)
	if err != nil {
		log.Printf("[PuskesmasDashboard] Error getting monthly trend: %v", err)
		return u.generateEmptyTrend()
	}

	// If no data, generate empty trend with zero values
	if len(rawData) == 0 {
		return u.generateEmptyTrend()
	}

	// Sort rawData by YYYY-MM key (chronological order) BEFORE formatting
	sort.Slice(rawData, func(i, j int) bool {
		yi, _ := rawData[i]["ym"].(string)
		yj, _ := rawData[j]["ym"].(string)
		return yi < yj
	})

	var trends []models.MonthlyTrend
	for _, data := range rawData {
		ym, _ := data["ym"].(string)
		kasusBaru, _ := toInt64(data["kasus_baru"])
		rujukan, _ := toInt64(data["rujukan"])

		trends = append(trends, models.MonthlyTrend{
			Bulan:            repositories.FormatBulan(ym),
			Tahun:            parseYear(ym),
			KasusBaruMasuk:   kasusBaru,
			RujukanDitangani: rujukan,
		})
	}

	return trends
}

func (u *puskesmasDashboardUsecase) generateEmptyTrend() []models.MonthlyTrend {
	now := time.Now()
	var trends []models.MonthlyTrend
	for i := 5; i >= 0; i-- {
		d := now.AddDate(0, -i, 0)
		trends = append(trends, models.MonthlyTrend{
			Bulan:            fmt.Sprintf("%s %d", monthName(d.Month()), d.Year()),
			Tahun:            d.Year(),
			KasusBaruMasuk:   0,
			RujukanDitangani: 0,
		})
	}
	return trends
}

func (u *puskesmasDashboardUsecase) buildPriorityCases(desaIDs []int32) []models.PriorityCase {
	var cases []models.PriorityCase

	// High-risk pregnancies
	kehamilanData, _ := u.repo.GetPriorityKehamilan(desaIDs, 3)
	for _, k := range kehamilanData {
		id, _ := toInt32(k["id"])
		nama, _ := k["nama"].(string)
		desa, _ := k["desa"].(string)
		uk, _ := toInt64(k["uk"])

		cases = append(cases, models.PriorityCase{
			ID:        id,
			Tipe:      "kehamilan_risiko",
			Nama:      nama,
			Desa:      desa,
			Deskripsi: fmt.Sprintf("Kehamilan aktif, UK %d minggu", uk),
			Status:    "Perlu Pemantauan",
			Prioritas: "Tinggi",
		})
	}

	// Stunting risk children
	stuntingData, _ := u.repo.GetPriorityStunting(desaIDs, 3)
	for _, s := range stuntingData {
		id, _ := toInt32(s["id"])
		nama, _ := s["nama"].(string)
		desa, _ := s["desa"].(string)
		klasifikasi, _ := s["klasifikasi"].(string)

		prioritas := "Sedang"
		if klasifikasi == "STUNTING" {
			prioritas = "Tinggi"
		}

		cases = append(cases, models.PriorityCase{
			ID:        id,
			Tipe:      "stunting",
			Nama:      nama,
			Desa:      desa,
			Deskripsi: fmt.Sprintf("Status: %s", klasifikasi),
			Status:    "Perlu Intervensi Gizi",
			Prioritas: prioritas,
		})
	}

	// Recent referrals
	rujukanData, _ := u.repo.GetPriorityRujukan(desaIDs, 3)
	for _, r := range rujukanData {
		id, _ := toInt32(r["id"])
		nama, _ := r["nama"].(string)
		desa, _ := r["desa"].(string)
		diagnosis, _ := r["diagnosis"].(string)

		cases = append(cases, models.PriorityCase{
			ID:        id,
			Tipe:      "rujukan",
			Nama:      nama,
			Desa:      desa,
			Deskripsi: diagnosis,
			Status:    "Rujukan Aktif",
			Prioritas: "Tinggi",
		})
	}

	return cases
}

func (u *puskesmasDashboardUsecase) emptyResponse() *models.PuskesmasDashboardResponse {
	return &models.PuskesmasDashboardResponse{
		Kecamatan:      "Semua Kecamatan",
		Periode:        "Belum ada data",
		DesaList:       []models.DesaSummary{},
		Overall:        models.OverallStats{},
		TrenBulanan:    u.generateEmptyTrend(),
		KasusPrioritas: []models.PriorityCase{},
	}
}

// ── Helpers ──

func monthName(m time.Month) string {
	names := map[time.Month]string{
		time.January: "Januari", time.February: "Februari", time.March: "Maret",
		time.April: "April", time.May: "Mei", time.June: "Juni",
		time.July: "Juli", time.August: "Agustus", time.September: "September",
		time.October: "Oktober", time.November: "November", time.December: "Desember",
	}
	return names[m]
}

func toInt64(v interface{}) (int64, bool) {
	switch val := v.(type) {
	case int64:
		return val, true
	case float64:
		return int64(val), true
	case int:
		return int64(val), true
	case int32:
		return int64(val), true
	}
	return 0, false
}

func toInt32(v interface{}) (int32, bool) {
	switch val := v.(type) {
	case int32:
		return val, true
	case int64:
		return int32(val), true
	case float64:
		return int32(val), true
	case int:
		return int32(val), true
	}
	return 0, false
}

func parseYear(ym string) int {
	if len(ym) >= 4 {
		var y int
		fmt.Sscanf(ym[:4], "%d", &y)
		return y
	}
	return time.Now().Year()
}
