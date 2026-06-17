package models

import "time"

// LaporanLansia adalah DTO untuk export laporan data lansia ke Excel.
type LaporanLansia struct {
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
	KategoriRisiko      string    `gorm:"column:kategori_risiko" json:"kategori_risiko"`
	StatusPemantauan    string    `gorm:"column:status_pemantauan" json:"status_pemantauan"`
	PenyakitKronis      string    `gorm:"column:penyakit_kronis" json:"penyakit_kronis"`
	StatusKemandirian    string    `gorm:"column:status_kemandirian" json:"status_kemandirian"`
	RiwayatJatuh        bool      `gorm:"column:riwayat_jatuh" json:"riwayat_jatuh"`
	CatatanKhusus       string    `gorm:"column:catatan_khusus" json:"catatan_khusus"`
	Kecamatan           string    `gorm:"column:kecamatan" json:"kecamatan"`
	Desa                string    `gorm:"column:desa" json:"desa"`
}
