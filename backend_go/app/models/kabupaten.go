package models

import (
	"time"

	"gorm.io/gorm"
)

type Kabupaten struct {
	ID         int32          `gorm:"column:id;primaryKey;autoIncrement" json:"id"`
	ProvinsiID int32          `gorm:"column:provinsi_id;not null;index" json:"provinsi_id"`
	Nama       string         `gorm:"column:nama;type:varchar(120);not null" json:"nama"`
	Provinsi   *Provinsi      `gorm:"foreignKey:ProvinsiID;references:ID" json:"provinsi,omitempty"`
	CreatedAt  time.Time      `gorm:"column:created_at;autoCreateTime" json:"created_at"`
	UpdatedAt  time.Time      `gorm:"column:updated_at;autoUpdateTime" json:"updated_at"`
	DeletedAt  gorm.DeletedAt `gorm:"column:deleted_at;index" json:"deleted_at,omitempty"`
}

func (Kabupaten) TableName() string { return "kabupaten" }
