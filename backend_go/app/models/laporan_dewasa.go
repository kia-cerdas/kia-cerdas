package models

import "time"

// LaporanDewasa adalah DTO untuk export laporan data dewasa ke Excel.
type LaporanDewasa struct {
	NIK                 string    `gorm:"column:nik" json:"nik"`
	NamaLengkap         string    `gorm:"column:nama_lengkap" json:"nama_lengkap"`
	TanggalLahir        time.Time `gorm:"column:tanggal_lahir" json:"tanggal_lahir"`
	Umur                int32     `gorm:"column:umur" json:"umur"`
	JenisKelamin        string    `gorm:"column:jenis_kelamin" json:"jenis_kelamin"`
	TanggalPemeriksaan  time.Time `gorm:"column:tanggal_pemeriksaan" json:"tanggal_pemeriksaan"`
	BeratBadan          *float64  `gorm:"column:berat_badan" json:"berat_badan,omitempty"`
	TinggiBadan         *float64  `gorm:"column:tinggi_badan" json:"tinggi_badan,omitempty"`
	IMT                 *float64  `gorm:"column:imt" json:"imt,omitempty"`
	TekananDarah        string    `gorm:"column:tekanan_darah" json:"tekanan_darah"`
	GulaDarah           *float64  `gorm:"column:gula_darah" json:"gula_darah,omitempty"`
	Kolesterol          *float64  `gorm:"column:kolesterol" json:"kolesterol,omitempty"`
	KategoriRisiko      string    `gorm:"column:kategori_risiko" json:"kategori_risiko"`
	StatusPemantauan    string    `gorm:"column:status_pemantauan" json:"status_pemantauan"`
	RiwayatPenyakit     string    `gorm:"column:riwayat_penyakit" json:"riwayat_penyakit"`
	PenyakitKronis      string    `gorm:"column:penyakit_kronis" json:"penyakit_kronis"`
	CatatanKhusus       string    `gorm:"column:catatan_khusus" json:"catatan_khusus"`
	Kecamatan           string    `gorm:"column:kecamatan" json:"kecamatan"`
	Desa                string    `gorm:"column:desa" json:"desa"`
}
