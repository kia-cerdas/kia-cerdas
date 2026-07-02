package models

import (
	"time"

	"gorm.io/gorm"
)

type JadwalImunisasiAnak struct {
	ID              uint           `gorm:"column:id;primaryKey" json:"id"`
	DosisVaksinID   uint           `gorm:"column:id_dosis_vaksin;" json:"id_dosis_vaksin"`
	TanggalEstimasi *time.Time     `json:"tanggal_estimasi,omitempty" gorm:"column:tanggal_estimasi;type:date"`
	AnakID          uint           `gorm:"column:id_anak;" json:"anak_id"`
	StatusJadwalID  uint           `gorm:"column:id_status_jadwal;" json:"status_jadwal_id"`
	Anak            *Anak          `json:"anak,omitempty" gorm:"foreignKey:AnakID;constraint:OnDelete:CASCADE"`
	StatusJadwal    *StatusJadwal  `json:"status_jadwal,omitempty" gorm:"foreignKey:StatusJadwalID;constraint:OnDelete:SET NULL"`
	DosisVaksin     *DosisVaksin   `json:"dosis_vaksin,omitempty" gorm:"foreignKey:DosisVaksinID;constraint:OnDelete:CASCADE"`
	CreatedAt       time.Time      `gorm:"column:created_at" json:"created_at"`
	UpdatedAt       time.Time      `gorm:"column:updated_at" json:"updated_at"`
	DeletedAt       gorm.DeletedAt `gorm:"column:deleted_at;index" json:"deleted_at"`

	IsSentH7 bool `gorm:"column:is_sent_h7" json:"is_sent_h7"`
	IsSentH3 bool `gorm:"column:is_sent_h3" json:"is_sent_h3"`
	IsSentH  bool `gorm:"column:is_sent_h" json:"is_sent_h"`
	IsSentAfter3 bool `gorm:"column:is_sent_after3" json:"is_sent_after3"`
	IsSentAfter7 bool `gorm:"column:is_sent_after7" json:"is_sent_after7"`
}

func (JadwalImunisasiAnak) TableName() string {
	return "jadwal_imunisasi_anak"
}

// TanggalLahir  *time.Time     `json:"tanggal_lahir,omitempty" gorm:"column:tanggal_lahir;type:date"`

type JadwalImunisasiResponse struct {
	AnakID         int32                 `json:"anak_id"`
	NamaAnak       string                `json:"nama_anak"`
	TanggalLahir   *time.Time            `json:"tanggal_lahir,omitempty"`
	JumlahTerlewat int                   `json:"jumlah_terlewat"`
	Jadwal         []JadwalImunisasiItem `json:"jadwal"`
}

type JadwalImunisasiItem struct {
	JadwalID        uint       `json:"jadwal_id"`
	DosisVaksinID   uint       `json:"dosis_vaksin_id"`
	NamaDosis       string     `json:"nama_dosis"`
	TanggalEstimasi *time.Time `json:"tanggal_estimasi,omitempty"`
	Deskripsi       string     `json:"deskripsi"`
	EfekSamping     string     `json:"efek_samping"`
	StatusID        uint       `json:"status_id"`
	Status          string     `json:"status"`
}

type UpdateTanggalEstimasiRequest struct {
	TanggalEstimasi string `json:"tanggal_estimasi"`
}

type JadwalImunisasiJoin struct {
	AnakID       uint
	NamaAnak     string
	TanggalLahir *time.Time

	JadwalID        uint
	DosisVaksinID   uint `gorm:"column:dosis_vaksin_id"`
	NamaDosis       string
	TanggalEstimasi *time.Time

	StatusID uint `gorm:"column:id_status"`
	Status   string

	Deskripsi   string
	EfekSamping string
	IsSentH7     bool
	IsSentH3     bool
	IsSentH      bool
	IsSentAfter3 bool `gorm:"column:is_sent_after3"`
	IsSentAfter7 bool `gorm:"column:is_sent_after7"`
}

type JadwalImunisasiTerlewatResponse struct {
	JadwalID     uint
	NamaAnak     string
	TanggalLahir *time.Time
	Dusun        string

	NamaIbu         string
	NomorTeleponIbu string

	NamaAyah         string
	NomorTeleponAyah string

	NamaDosis       string
	JadwalImunisasi *time.Time

	NamaStatus string
	Prioritas  string
	JumlahHariTerlambat int 
}

type JadwalImunisasiTerlewatJoin struct {
	JadwalID        uint
	AnakID          uint
	NamaAnak        string
	TanggalLahir    *time.Time
	Dusun           string
	TanggalEstimasi *time.Time
	NamaIbu         string
	NomorTeleponIbu string

	NamaAyah         string
	NomorTeleponAyah string

	NamaDosis       string
	JadwalImunisasi *time.Time

	NamaStatus string
}
type DetailJadwalImunisasiTerlewatResponse struct {
	JadwalID uint `json:"jadwal_id"`
	AnakID   uint `json:"anak_id"`

	NamaAnak     string     `json:"nama_anak"`
	TanggalLahir *time.Time `json:"tanggal_lahir,omitempty"`
	Dusun        string     `json:"dusun"`

	NamaIbu         string `json:"nama_ibu"`
	NomorTeleponIbu string `json:"nomor_telepon_ibu"`

	NamaAyah         string `json:"nama_ayah"`
	NomorTeleponAyah string `json:"nomor_telepon_ayah"`

	NamaDosis string `json:"nama_dosis"`

	JadwalImunisasi *time.Time `json:"jadwal_imunisasi,omitempty"`
	NamaStatus      string     `json:"nama_status"`
	Prioritas       string     `json:"prioritas"`
	JumlahHariTerlambat int `json:"jumlah_hari_terlambat"`
}
