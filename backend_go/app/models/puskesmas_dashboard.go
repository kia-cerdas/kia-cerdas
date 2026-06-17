package models

// ── Response structs for Puskesmas Dashboard (multi-desa recap) ──

// DesaSummary holds per-village summary statistics
type DesaSummary struct {
	DesaID          int32   `json:"desa_id"`
	NamaDesa        string  `json:"nama_desa"`
	TotalPenduduk   int64   `json:"total_penduduk"`
	TotalIbu        int64   `json:"total_ibu"`
	TotalIbuHamil   int64   `json:"total_ibu_hamil"`
	TotalAnak       int64   `json:"total_anak"`
	TotalBalita     int64   `json:"total_balita"`
	TotalRujukan    int64   `json:"total_rujukan"`
	CakupanLayanan  float64 `json:"cakupan_layanan"`  // percentage
	StatusCakupan   string  `json:"status_cakupan"`    // Baik / Perlu Ditingkatkan / Intervensi
	TotalBidan      int64   `json:"total_bidan"`
	StuntingRisk    int64   `json:"stunting_risk"`     // children at risk
	StuntingNormal  int64   `json:"stunting_normal"`   // children normal
}

// OverallStats holds aggregate statistics across all target desa
type OverallStats struct {
	TotalSasaranAktif     int64   `json:"total_sasaran_aktif"`      // ibu + anak total
	CakupanLayananRataRata float64 `json:"cakupan_layanan_rata_rata"` // average coverage
	DesaPerluIntervensi   int64   `json:"desa_perlu_intervensi"`    // desa with coverage < 60%
	KasusRujukanAktif     int64   `json:"kasus_rujukan_aktif"`      // active referrals
	TotalPenduduk         int64   `json:"total_penduduk"`
	TotalIbu              int64   `json:"total_ibu"`
	TotalIbuHamil         int64   `json:"total_ibu_hamil"`
	TotalAnak             int64   `json:"total_anak"`
	TotalBalita           int64   `json:"total_balita"`
}

// MonthlyTrend holds monthly data for trend chart
type MonthlyTrend struct {
	Bulan            string `json:"bulan"`              // e.g. "Jan", "Feb"
	Tahun            int    `json:"tahun"`
	KasusBaruMasuk   int64  `json:"kasus_baru_masuk"`   // new penduduk registrations
	RujukanDitangani int64  `json:"rujukan_ditangani"`  // referrals handled
	PemeriksaanCount int64  `json:"pemeriksaan_count"`  // examinations done
}

// PriorityCase represents a priority case needing attention
type PriorityCase struct {
	ID          int32  `json:"id"`
	Tipe        string `json:"tipe"`         // "kehamilan_risiko", "stunting", "rujukan"
	Nama        string `json:"nama"`
	Desa        string `json:"desa"`
	Deskripsi   string `json:"deskripsi"`
	Status      string `json:"status"`       // "Perlu Penanganan", "Rujukan Aktif", etc.
	Prioritas   string `json:"prioritas"`    // "Tinggi", "Sedang"
}

// PuskesmasDashboardResponse is the main response for the dashboard
type PuskesmasDashboardResponse struct {
	Kecamatan      string         `json:"kecamatan"`
	Periode        string         `json:"periode"`
	DesaList       []DesaSummary  `json:"desa_list"`
	Overall        OverallStats   `json:"overall"`
	TrenBulanan    []MonthlyTrend `json:"tren_bulanan"`
	KasusPrioritas []PriorityCase `json:"kasus_prioritas"`
}
