package models

type JumlahKelompokUsia struct {
	Balita int64 `json:"balita"` // 0-5 tahun
	Anak   int64 `json:"anak"`   // 6-12 tahun
	Remaja int64 `json:"remaja"` // 13-18 tahun
	Dewasa int64 `json:"dewasa"` // 19-59 tahun
	Lansia int64 `json:"lansia"` // 60+ tahun
}

// RiskCount map untuk jumlah per kategori risiko
type RiskCount map[string]int // contoh: {"Rendah":10, "Sedang":5, "Tinggi":2}

// KesehatanKelompokResponse key = nama kelompok ("balita","anak","remaja","dewasa","lansia")
type KesehatanKelompokResponse map[string]RiskCount

type CakupanPemeriksaan struct {
	Kelompok       string  `json:"kelompok"`
	TotalSasaran   int64   `json:"total_sasaran"`
	SudahDiperiksa int64   `json:"sudah_diperiksa"`
	BelumDiperiksa int64   `json:"belum_diperiksa"`
	Persentase     float64 `json:"persentase"` // (sudah_diperiksa / total_sasaran) * 100
}

type CakupanResponse struct {
	Data []CakupanPemeriksaan `json:"data"`
}

type PendudukRiskResponse struct {
	ID          int32  `json:"id"`
	NIK         string `json:"nik"`
	NamaLengkap string `json:"nama_lengkap"`
	Dusun       string `json:"dusun"`
	Usia        int    `json:"usia"`
	Risiko      string `json:"risiko"`
}
