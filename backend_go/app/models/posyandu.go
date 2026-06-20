package models

import (
	"time"

	"gorm.io/gorm"
)

type Posyandu struct {
	ID          int32          `gorm:"column:id;primaryKey;autoIncrement" json:"id"`
	IDPuskesmas int32          `gorm:"column:id_puskesmas;not null" json:"id_puskesmas"`
	DesaID      *int32         `gorm:"column:desa_id" json:"desa_id,omitempty"`
	Nama        string         `gorm:"column:nama;type:varchar(255);not null" json:"nama"`
	Alamat      string         `gorm:"column:alamat;type:text" json:"alamat,omitempty"`
	Desa        *Desa          `gorm:"foreignKey:DesaID;references:ID" json:"desa,omitempty"`

	Bidan []Bidan `gorm:"foreignKey:PosyanduID;references:ID" json:"bidan,omitempty"`
	Kader []Kader `gorm:"foreignKey:PosyanduID;references:ID" json:"kader,omitempty"`

	CreatedAt   time.Time      `gorm:"column:created_at;autoCreateTime" json:"created_at"`
	UpdatedAt   time.Time      `gorm:"column:updated_at;autoUpdateTime" json:"updated_at"`
	DeletedAt   gorm.DeletedAt `gorm:"column:deleted_at;index" json:"deleted_at,omitempty"`
}

func (Posyandu) TableName() string { return "posyandu" }
