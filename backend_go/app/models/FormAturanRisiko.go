package models
import (
	"time"
	"gorm.io/datatypes"
)
type FormAturanRisiko struct {
    ID              uint           `gorm:"primaryKey"`
   FormVersiID    uint           `gorm:"not null;index"`
	FormVersi      FormVersi      `gorm:"foreignKey:FormVersiID;references:ID"`
    NamaAturan      string         `gorm:"size:100"`
    Kondisi         datatypes.JSON `gorm:"type:jsonb;not null"`    // JSON logic
    KategoriRisiko  string         `gorm:"size:50;not null"`
    Rekomendasi     string         `gorm:"size:250"` // tambahkan field ini
    Prioritas       int            `gorm:"default:0"`              // besar = didahulukan
    CreatedAt       time.Time
}

