package models

import (
	"time"

	"gorm.io/gorm"
)

type PemeriksaanLansia struct {
	ID int32 `gorm:"primaryKey;column:id;autoIncrement" json:"id"`

	// Relasi ke penduduk
	PendudukID int32 `gorm:"column:penduduk_id;not null;index" json:"penduduk_id"`

	Penduduk *Kependudukan `gorm:"foreignKey:PendudukID;references:IDKependudukan" json:"penduduk,omitempty"`

	// Tanggal pemeriksaan
	TanggalPemeriksaan time.Time `gorm:"column:tanggal_pemeriksaan;not null" json:"tanggal_pemeriksaan"`

	// Umur saat pemeriksaan
	Umur int32 `gorm:"column:umur" json:"umur"`

	// Antropometri
	BeratBadan *float64 `gorm:"column:berat_badan" json:"berat_badan,omitempty"`

	TinggiBadan *float64 `gorm:"column:tinggi_badan" json:"tinggi_badan,omitempty"`

	IMT *float64 `gorm:"column:imt" json:"imt,omitempty"`

	// Tanda vital
	TekananDarah string `gorm:"column:tekanan_darah;type:varchar(20)" json:"tekanan_darah"`

	// Pemeriksaan gula darah
	GulaDarah *float64 `gorm:"column:gula_darah" json:"gula_darah,omitempty"`

	// Status kesehatan
	KategoriRisiko string `gorm:"column:kategori_risiko;type:varchar(50)" json:"kategori_risiko"`

	StatusPemantauan string `gorm:"column:status_pemantauan;type:varchar(50)" json:"status_pemantauan"`

	// Penyakit kronis
	PenyakitKronis string `gorm:"column:penyakit_kronis;type:text" json:"penyakit_kronis"`

	// Status lansia
	StatusKemandirian string `gorm:"column:status_kemandirian;type:varchar(50)" json:"status_kemandirian"`

	RiwayatJatuh bool `gorm:"column:riwayat_jatuh;default:false" json:"riwayat_jatuh"`

	CatatanKhusus string `gorm:"column:catatan_khusus;type:text" json:"catatan_khusus"`

	// Pemeriksa
	PemeriksaID *int32 `gorm:"column:pemeriksa_id;index" json:"pemeriksa_id,omitempty"`

	Pemeriksa *User `gorm:"foreignKey:PemeriksaID;references:ID" json:"pemeriksa,omitempty"`

	// Metadata
	CreatedAt time.Time `gorm:"column:created_at;autoCreateTime" json:"created_at"`

	UpdatedAt time.Time `gorm:"column:updated_at;autoUpdateTime" json:"updated_at"`

	DeletedAt gorm.DeletedAt `gorm:"column:deleted_at;index" json:"-"`
}

func (PemeriksaanLansia) TableName() string {
	return "pemeriksaan_lansia"
}