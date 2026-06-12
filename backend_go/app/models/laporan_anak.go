package models

import "time"

// LaporanAnak adalah DTO untuk export laporan data anak ke Excel.
// Semua field diisi langsung dari raw SQL query (bukan dari GORM Preload),
// sehingga tidak perlu relasi struct.
type LaporanAnak struct {
	NoKK          string    `gorm:"column:no_kk" json:"no_kk"`
	NIK           string    `gorm:"column:nik" json:"nik"`
	NamaAnak      string    `gorm:"column:nama_anak" json:"nama_anak"`
	NamaIbu       string    `gorm:"column:nama_ibu" json:"nama_ibu"`
	NamaAyah      string    `gorm:"column:nama_ayah" json:"nama_ayah"`
	TanggalLahir  time.Time `gorm:"column:tanggal_lahir" json:"tanggal_lahir"`
	Usia          string    `gorm:"column:usia" json:"usia"`
	BeratLahirKg  float64   `gorm:"column:berat_lahir_kg" json:"berat_lahir_kg"`
	TinggiLahirCm float64   `gorm:"column:tinggi_lahir_cm" json:"tinggi_lahir_cm"`
	LILA          float64   `gorm:"column:lila" json:"lila"`
	GolonganDarah string    `gorm:"column:golongan_darah" json:"golongan_darah"`
	Kecamatan     string    `gorm:"column:kecamatan" json:"kecamatan"`
	Desa          string    `gorm:"column:desa" json:"desa"`
}

// LaporanPertumbuhan adalah DTO untuk export data riwayat pertumbuhan anak.
type LaporanPertumbuhan struct {
	NIK            string    `gorm:"column:nik" json:"nik"`
	NamaAnak       string    `gorm:"column:nama_anak" json:"nama_anak"`
	TglUkur        time.Time `gorm:"column:tgl_ukur" json:"tgl_ukur"`
	UsiaUkurBulan  int       `gorm:"column:usia_ukur_bulan" json:"usia_ukur_bulan"`
	BeratBadan     float64   `gorm:"column:berat_badan" json:"berat_badan"`
	TinggiBadan    float64   `gorm:"column:tinggi_badan" json:"tinggi_badan"`
	HasilLila      float64   `gorm:"column:hasil_lila" json:"hasil_lila"`
	LingkarKepala  float64   `gorm:"column:lingkar_kepala" json:"lingkar_kepala"`
	IMT            float64   `gorm:"column:imt" json:"imt"`
	StatusBBU      string    `gorm:"column:status_bb_u" json:"status_bb_u"`
	StatusTBU      string    `gorm:"column:status_tb_u" json:"status_tb_u"`
	StatusBBTB     string    `gorm:"column:status_bb_tb" json:"status_bb_tb"`
	StatusIMTU     string    `gorm:"column:status_imt_u" json:"status_imt_u"`
	CatatanNakes   string    `gorm:"column:catatan_nakes" json:"catatan_nakes"`
}

// LaporanImunisasi adalah DTO untuk export data riwayat imunisasi anak.
type LaporanImunisasi struct {
	NIK          string     `gorm:"column:nik" json:"nik"`
	NamaAnak     string     `gorm:"column:nama_anak" json:"nama_anak"`
	NamaVaksin   string     `gorm:"column:nama_vaksin" json:"nama_vaksin"`
	TglPemberian *time.Time `gorm:"column:tgl_pemberian" json:"tgl_pemberian"`
	Status       string     `gorm:"column:status" json:"status"`
	Lokasi       string     `gorm:"column:lokasi" json:"lokasi"`
	Petugas      string     `gorm:"column:petugas" json:"petugas"`
}

// LaporanAnakPreviewResponse adalah pembungkus response preview laporan anak.
type LaporanAnakPreviewResponse struct {
	Anak        []LaporanAnak        `json:"anak"`
	Pertumbuhan []LaporanPertumbuhan `json:"pertumbuhan"`
	Imunisasi   []LaporanImunisasi   `json:"imunisasi"`
}
