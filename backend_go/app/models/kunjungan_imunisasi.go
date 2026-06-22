package models

import (
	"time"
)

type KunjunganImunisasi struct {
	ID                uint                 `gorm:"primaryKey" json:"id"`
	StatusID          uint                 `gorm:"column:status;"json:"status"`
	TanggalKunjungan  *time.Time           `gorm:"column:tanggal_kunjungan;" json:"tanggal_kunjungan"`
	JadwalImunisasiID uint                 `gorm:"column:id_jadwal_imunisasi;" json:"id_jadwal_imunisasi"`
	KaderID           uint                 `gorm:"column:kader_id;" json:"kader_id"`
	Kader             *Kader               `json:"kader,omitempty" gorm:"foreignKey:KaderID;constraint:OnDelete:CASCADE"`
	JadwalImunisasi   *JadwalImunisasiAnak `json:"jadwal_imunisasi,omitempty" gorm:"foreignKey:JadwalImunisasiID;constraint:OnDelete:CASCADE"`
	StatusKunjungan   *StatusKunjungan     `json:"status_kunjungan,omitempty" gorm:"foreignKey:StatusID"`
	CreatedAt         time.Time
	UpdatedAt         time.Time
}

func (KunjunganImunisasi) TableName() string {
	return "kunjungan_imunisasi"
}

type KunjunganImunisasiDetailResponse struct {
	KunjunganID      uint       `json:"kunjungan_id"`
	TanggalKunjungan *time.Time `json:"tanggal_kunjungan,omitempty"`
	StatusKunjungan  string     `json:"status_kunjungan"`

	NamaAnak     string     `json:"nama_anak"`
	TanggalLahir *time.Time `json:"tanggal_lahir,omitempty"`

	NamaIbu         string `json:"nama_ibu"`
	NomorTeleponIbu string `json:"nomor_telepon_ibu"`

	NamaAyah         string `json:"nama_ayah"`
	NomorTeleponAyah string `json:"nomor_telepon_ayah"`
	Dusun            string `json:"dusun"`

	NamaVaksin      string     `json:"nama_vaksin"`
	NamaDosis       string     `json:"nama_dosis"`
	JadwalImunisasi *time.Time `json:"jadwal_imunisasi,omitempty"`
}

type KunjunganImunisasiResponse struct {
	KunjunganID      uint       `json:"kunjungan_id"`
	TanggalKunjungan *time.Time `json:"tanggal_kunjungan,omitempty"`
	StatusKunjungan  string     `json:"status_kunjungan"`
	NamaAnak         string     `json:"nama_anak"`
}

type UpdateStatusKunjunganRequest struct {
	StatusKunjunganID uint `json:"status_kunjungan_id"`
}

type UpdateTanggalKunjunganRequest struct {
	TanggalKunjungan string `json:"tanggal_kunjungan"`
}

type PostKunjunganImunisasiRequest struct {
	IDStatusKunjungan uint   `json:"id_status_kunjungan" binding:"required"`
	TanggalKunjungan  string `json:"tanggal_kunjungan" binding:"required"`
	IDJadwalImunisasi uint   `json:"id_jadwal_imunisasi" binding:"required"`
	// KaderID diisi otomatis dari JWT, tidak perlu dikirim client
	KaderID uint `json:"-"`
}
