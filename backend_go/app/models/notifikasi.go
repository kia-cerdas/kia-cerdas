package models

import (
	"time"

	"gorm.io/gorm"
)

type Notifikasi struct {
	ID                    uint                 `gorm:"column:id;primaryKey" json:"id"`
	PenggunaID            uint               `gorm:"column:id_pengguna;type:text" json:"pengguna_id"`
	Judul                 string               `gorm:"column:judul;type:text;not null" json:"judul"`
	Pesan                 string               `gorm:"column:pesan;type:text;not null" json:"pesan"`
	JadwalImunisasiAnakId uint                 `gorm:"column:id_jadwal_imunisasi_anak;" json:"id_jadwal_imunisasi_anak"`
	TipeNotifikasiID      uint                 `gorm:"column:id_tipe_notifikasi;" json:"id_tipe_notifikasi"`
	JadwalImunisasiAnak   *JadwalImunisasiAnak `json:"jadwal_imunisasi_anak,omitempty" gorm:"foreignKey:JadwalImunisasiAnakId;constraint:OnDelete:CASCADE"`
	Pengguna              *User                `json:"pengguna,omitempty" gorm:"foreignKey:PenggunaID;constraint:OnDelete:CASCADE"`
	TipeNotifikasi        *TipeNotifikasi      `json:"tipe_notifikasi,omitempty" gorm:"foreignKey:TipeNotifikasiID;constraint:OnDelete:SET NULL"`
	CreatedAt             time.Time            `gorm:"column:created_at" json:"created_at"`
	UpdatedAt             time.Time            `gorm:"column:updated_at" json:"updated_at"`
	DeletedAt             gorm.DeletedAt       `gorm:"column:deleted_at;index" json:"deleted_at"`
}

func (Notifikasi) TableName() string {
	return "notifikasi"
}

type FCMService interface {
	Send(token string, title string, message string) error
}
