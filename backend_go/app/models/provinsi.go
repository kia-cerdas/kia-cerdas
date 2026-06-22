package models

import (
	"time"

	"gorm.io/gorm"
)

type Provinsi struct {
	ID        int32          `gorm:"column:id;primaryKey;autoIncrement" json:"id"`
	Nama      string         `gorm:"column:nama;type:varchar(120);not null" json:"nama"`
	CreatedAt time.Time      `gorm:"column:created_at;autoCreateTime" json:"created_at"`
	UpdatedAt time.Time      `gorm:"column:updated_at;autoUpdateTime" json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"column:deleted_at;index" json:"deleted_at,omitempty"`
}

func (Provinsi) TableName() string { return "provinsi" }
