package models

import "time"

type Desa struct {
	ID         int32      `gorm:"column:id;primaryKey;autoIncrement" json:"id"`
	Kecamatan  string     `gorm:"column:kecamatan;type:varchar(120)" json:"kecamatan"`
	Kabupaten  string     `gorm:"column:kabupaten;type:varchar(120)" json:"kabupaten"`
	Provinsi   string     `gorm:"column:provinsi;type:varchar(120)" json:"provinsi"`
	NamaDesa   string     `gorm:"column:nama_desa;type:varchar(120);not null" json:"nama_desa"`
	KodeDesa   string     `gorm:"column:kode_desa;type:varchar(50);not null;uniqueIndex" json:"kode_desa"`
	// KecamatanID menghubungkan desa ke master kecamatan (nullable).
	// Kolom string Kecamatan/Kabupaten/Provinsi di atas tetap diisi (sinkron dari master)
	// demi kompatibilitas modul laporan/dashboard yang masih membacanya sebagai string.
	KecamatanID  *int32     `gorm:"column:kecamatan_id" json:"kecamatan_id,omitempty"`
	KecamatanRef *Kecamatan `gorm:"foreignKey:KecamatanID;references:ID" json:"kecamatan_ref,omitempty"`
	IsActive   bool       `gorm:"column:is_active;not null;default:true" json:"is_active"`
	Keterangan string     `gorm:"column:keterangan;type:text" json:"keterangan,omitempty"`
	CreatedAt  time.Time  `gorm:"column:created_at" json:"created_at"`
	UpdatedAt  time.Time  `gorm:"column:updated_at" json:"updated_at"`
	DeletedAt  *time.Time `gorm:"column:deleted_at" json:"deleted_at,omitempty"`
}

func (Desa) TableName() string {
	return "desa"
}
