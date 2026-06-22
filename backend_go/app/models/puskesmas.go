package models

import (
	"time"

	"gorm.io/gorm"
)

type Puskesmas struct {
	ID        int64          `gorm:"column:id;primaryKey;autoIncrement" json:"id"`
	Nama      string         `gorm:"column:nama;type:text;not null" json:"nama"`
	Alamat    string         `gorm:"column:alamat;type:text" json:"alamat,omitempty"`
	NoTelepon string         `gorm:"column:no_telepon;type:varchar(255)" json:"no_telepon,omitempty"`
	// KecamatanID mengikat puskesmas ke 1 kecamatan (nullable).
	KecamatanID *int32     `gorm:"column:kecamatan_id" json:"kecamatan_id,omitempty"`
	Kecamatan   *Kecamatan `gorm:"foreignKey:KecamatanID;references:ID" json:"kecamatan,omitempty"`
	CreatedAt time.Time      `gorm:"column:created_at" json:"created_at"`
	UpdatedAt time.Time      `gorm:"column:updated_at" json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"column:deleted_at;index" json:"deleted_at,omitempty"`
}

func (Puskesmas) TableName() string { return "puskesmas" }
