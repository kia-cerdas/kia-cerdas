package models

import (
	"time"

	"gorm.io/gorm"
)

// Tabel Induk BBL (Memegang kepemilikan dan status verifikasi keseluruhan)
type Bbl struct {
	ID                uint           `json:"id" gorm:"primaryKey;autoIncrement"`
	AnakID            uint           `json:"anak_id" gorm:"not null;uniqueIndex"`
	Anak              *Anak          `json:"anak,omitempty" gorm:"foreignKey:AnakID"`

	Checklist         []BblCheck     `json:"checklist" gorm:"foreignKey:BblID"`

	CreatedAt         time.Time      `json:"created_at"`
	UpdatedAt         time.Time      `json:"updated_at"`
	DeletedAt         gorm.DeletedAt `json:"-" gorm:"index"`
}

func (Bbl) TableName() string {
	return "bbl"
}

// Tabel Detail Pemeriksaan (Hanya fokus pada data per jadwal)
type BblCheck struct {
	ID                uint       `json:"id" gorm:"primaryKey;autoIncrement"`
	BblID             uint       `json:"bbl_id" gorm:"not null"`
	PeriodeWaktu      string     `json:"periode_waktu" gorm:"type:varchar(50);not null"`
	StatusPemeriksaan bool       `json:"status_pemeriksaan" gorm:"default:false"`
	TanggalSubmit     *time.Time `json:"tanggal_submit"`

	// Data Verifikasi oleh Kader per Periode
	Status            string     `json:"status" gorm:"type:varchar(50);default:'Menunggu verifikasi'"`
	IsVerified        bool       `json:"is_verified" gorm:"default:false"`
	VerifiedAt        *time.Time `json:"verified_at"`
	VerifiedByKaderID *uint      `json:"verified_by_kader_id"`
	VerifiedByKader   *Kader     `json:"verified_by_kader,omitempty" gorm:"foreignKey:VerifiedByKaderID"`
}

func (BblCheck) TableName() string {
	return "bbl_check"
}
