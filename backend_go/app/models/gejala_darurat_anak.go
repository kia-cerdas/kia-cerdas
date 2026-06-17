package models

import (
	"errors"
	"time"

	"gorm.io/gorm"
)

// RiwayatDeteksi (Tabel 1: Header untuk menampung riwayat anak)
type RiwayatDeteksi struct {
	ID             uint       `gorm:"primaryKey;column:id" db:"id" json:"id"`
	AnakID         uint       `gorm:"column:anak_id;not null;index" db:"anak_id" json:"anak_id"`
	TanggalPeriksa *time.Time `gorm:"column:tanggal_periksa;type:date;not null" db:"tanggal_periksa" json:"tanggal_periksa"`

	// Hasil dari Rule Engine (Disimpan sebagai riwayat)
	TotalBobotMax int    `gorm:"column:total_bobot_max;not null" db:"total_bobot_max" json:"total_bobot_max"`
	Tindakan      string `gorm:"column:tindakan;type:varchar(255);not null" db:"tindakan" json:"tindakan"`

	CreatedAt time.Time      `gorm:"column:created_at" db:"created_at" json:"created_at"`
	UpdatedAt time.Time      `gorm:"column:updated_at" db:"updated_at" json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"column:deleted_at;index" json:"-"`

	Anak          *Anak           `gorm:"foreignKey:AnakID;references:ID;constraint:OnUpdate:CASCADE,OnDelete:RESTRICT" json:"anak,omitempty"`
	DetailJawaban []DetailDeteksi `gorm:"foreignKey:RiwayatDeteksiID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE" json:"detail_jawaban,omitempty"`
}

func (RiwayatDeteksi) TableName() string {
	return "riwayat_deteksi"
}

// DetailDeteksi (Tabel 2: Detail untuk menampung jawaban pertanyaan)
type DetailDeteksi struct {
	ID               uint `gorm:"primaryKey;column:id" db:"id" json:"id"`
	RiwayatDeteksiID uint `gorm:"column:riwayat_deteksi_id;not null;index" db:"riwayat_deteksi_id" json:"riwayat_deteksi_id"`

	// KodeGejala menggunakan string statis (contoh: "suhu_sangat_tinggi", "diare_berdarah")
	KodeGejala string `gorm:"column:kode_gejala;type:varchar(50);not null" db:"kode_gejala" json:"kode_gejala"`
	IsTerjadi  bool   `gorm:"column:is_terjadi;not null" db:"is_terjadi" json:"is_terjadi"`

	RiwayatDeteksi *RiwayatDeteksi `gorm:"foreignKey:RiwayatDeteksiID;references:ID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE" json:"-"`
}

func (DetailDeteksi) TableName() string {
	return "detail_deteksi"
}

// ==================== REQUEST MODELS ====================

type JawabanGejalaRequest struct {
	KodeGejala string `json:"kode_gejala" validate:"required"` // cth: "suhu_sangat_tinggi"
	IsTerjadi  bool   `json:"is_terjadi"`                      // true / false
}

type DeteksiDaruratRequest struct {
	AnakID         uint                   `json:"anak_id" validate:"required"`
	TanggalPeriksa string                 `json:"tanggal_periksa" validate:"required"`
	DaftarGejala   []JawabanGejalaRequest `json:"daftar_gejala" validate:"required,dive"`
}

func (r *DeteksiDaruratRequest) Validate() error {
	if r.AnakID <= 0 {
		return errors.New("anak_id harus lebih dari 0")
	}
	if _, err := time.Parse("2006-01-02", r.TanggalPeriksa); err != nil {
		return errors.New("format tanggal_periksa harus YYYY-MM-DD")
	}
	if len(r.DaftarGejala) == 0 {
		return errors.New("daftar_gejala wajib diisi minimal 1")
	}
	return nil
}
