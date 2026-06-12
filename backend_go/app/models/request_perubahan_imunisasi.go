package models

import "time"

type RequestPerubahanImunisasi struct {
	ID                  int32                `gorm:"column:id;primaryKey;autoIncrement" json:"id"`
	IDJadwalImunisasi   int32                `gorm:"column:id_jadwal_imunisasi;not null;index;constraint:OnDelete:CASCADE" json:"id_jadwal_imunisasi"`
	IDStatusRequest     int32                `gorm:"column:id_status_request;not null;index;constraint:OnDelete:CASCADE" json:"id_status_request"`
	Alasan              string               `gorm:"column:alasan;type:varchar(255);not null" json:"alasan"`
	TanggalSebelum      string               `gorm:"column:tanggal_sebelum;type:varchar(255);not null" json:"tanggal_sebelum"`
	JadwalImunisasiAnak *JadwalImunisasiAnak `json:"jadwal_imunisasi_anak,omitempty" gorm:"foreignKey:IDJadwalImunisasi;constraint:OnDelete:CASCADE"`
	StatusRequest       *StatusRequest       `json:"status_request,omitempty" gorm:"foreignKey:IDStatusRequest;constraint:OnDelete:CASCADE"`
	TanggalBaru         string               `gorm:"column:tanggal_baru;type:varchar(255);not null" json:"tanggal_baru"`
	CreatedAt           time.Time            `gorm:"column:created_at" json:"created_at"`
	UpdatedAt           time.Time            `gorm:"column:updated_at" json:"updated_at"`
	DeletedAt           *time.Time           `gorm:"column:deleted_at" json:"deleted_at,omitempty"`
}

func (RequestPerubahanImunisasi) TableName() string { return "request_perubahan_imunisasi" }

type RequestPerubahanJadwalRequest struct {
	TanggalBaru string `json:"tanggal_baru"`
	Alasan      string `json:"alasan"`
}

type RequestPerubahanJadwalResponse struct {
	RequestID      int32  `json:"request_id"`
	StatusRequest  string `json:"status_request"`
	TanggalSebelum string `json:"tanggal_sebelum"`
	TanggalBaru    string `json:"tanggal_baru"`
	NamaDosis      string `json:"nama_dosis"`
	NamaLengkap    string `json:"nama_lengkap"`
	Alasan         string `json:"alasan"`
}

type RequestPerubahanJadwalJoin struct {
	RequestID      int32
	StatusRequest  string
	TanggalSebelum string
	TanggalBaru    string
	NamaDosis      string
	NamaLengkap    string
	Alasan         string
	JadwalID       uint
}
