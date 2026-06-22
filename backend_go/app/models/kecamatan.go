package models

import (
	"time"

	"gorm.io/gorm"
)

type Kecamatan struct {
	ID          int32          `gorm:"column:id;primaryKey;autoIncrement" json:"id"`
	KabupatenID int32          `gorm:"column:kabupaten_id;not null;index" json:"kabupaten_id"`
	Nama        string         `gorm:"column:nama;type:varchar(120);not null" json:"nama"`
	Kabupaten   *Kabupaten     `gorm:"foreignKey:KabupatenID;references:ID" json:"kabupaten,omitempty"`
	CreatedAt   time.Time      `gorm:"column:created_at;autoCreateTime" json:"created_at"`
	UpdatedAt   time.Time      `gorm:"column:updated_at;autoUpdateTime" json:"updated_at"`
	DeletedAt   gorm.DeletedAt `gorm:"column:deleted_at;index" json:"deleted_at,omitempty"`
}

func (Kecamatan) TableName() string { return "kecamatan" }
