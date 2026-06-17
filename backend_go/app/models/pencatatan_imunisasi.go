package models

import (
	"time"

	"gorm.io/gorm"
)

type PencatatanImunisasi struct {
	ID                    uint                  `gorm:"column:id;primaryKey" json:"id"`
	IdJadwalImunisasiAnak uint                  `gorm:"column:id_jadwal_imunisasi_anak;not null" json:"id_jadwal_imunisasi_anak"`
	TanggalPemberian      *time.Time            `gorm:"column:tanggal_pemberian;type:date" json:"tanggal_pemberian"`
	NomorBatch            string                `gorm:"column:nomor_batch;type:varchar(255)" json:"nomor_batch"`
	Catatan               string                `gorm:"column:catatan;type:text" json:"catatan"`
	IsSelesai             bool                  `gorm:"column:is_selesai;default:false" json:"is_selesai"`
	IdBidanPetugas        *int32                `gorm:"column:id_bidan_petugas" json:"id_bidan_petugas"`
	JadwalImunisasiAnak   *JadwalImunisasiAnak  `json:"jadwal_imunisasi_anak,omitempty" gorm:"foreignKey:IdJadwalImunisasiAnak;constraint:OnDelete:CASCADE"`
	BidanPetugas          *User                 `json:"bidan_petugas" gorm:"foreignKey:IdBidanPetugas;constraint:OnDelete:SET NULL"`
	CreatedAt             time.Time             `gorm:"column:created_at" json:"created_at"`
	UpdatedAt             time.Time             `gorm:"column:updated_at" json:"updated_at"`
	DeletedAt             gorm.DeletedAt        `gorm:"column:deleted_at;index" json:"deleted_at"`
}

func (PencatatanImunisasi) TableName() string {
	return "pencatatan_imunisasi"
}
