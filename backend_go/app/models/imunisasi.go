package models

import (
	"time"

	"gorm.io/gorm"
)

type ImunisasiRequest struct {
	AnakID       int        `json:"anak_id"`
	ImunisasiID  int        `json:"imunisasi_id"`
	TglRencana   *time.Time `json:"tgl_rencana"`
	TglPemberian *time.Time `json:"tgl_pemberian"`
	Status       string     `json:"status"` // contoh: "Belum", "Sudah"
	Lokasi       string     `json:"lokasi"`
	Petugas      string     `json:"petugas"`
}

type Imunisasi struct {
	ID           uint       `gorm:"primaryKey;column:id" db:"id" json:"id"`
	AnakID       int        `gorm:"column:anak_id" db:"anak_id" json:"anak_id"`
	ImunisasiID  int        `gorm:"column:imunisasi_id" db:"imunisasi_id" json:"imunisasi_id"`
	TglRencana   *time.Time `gorm:"column:tgl_rencana" db:"tgl_rencana" json:"tgl_rencana,omitempty"`
	TglPemberian *time.Time `gorm:"column:tgl_pemberian" db:"tgl_pemberian" json:"tgl_pemberian,omitempty"`
	Status       string     `gorm:"column:status" db:"status" json:"status"`
	Lokasi       string     `gorm:"column:lokasi" db:"lokasi" json:"lokasi,omitempty"`
	Petugas      string     `gorm:"column:petugas" db:"petugas" json:"petugas,omitempty"`
	CreatedAt    time.Time  `gorm:"column:created_at" db:"created_at" json:"created_at"`
	UpdatedAt    time.Time  `gorm:"column:updated_at" db:"updated_at" json:"updated_at"`
	Isdeleted    time.Time  `gorm:"column:is_deleted" db:"is_deleted" json:"is_deleted,omitempty"`

	// Foreign key constraints
	Anak      *Anak            `gorm:"foreignKey:AnakID;references:ID;constraint:OnUpdate:CASCADE,OnDelete:RESTRICT" json:"-"`
	Imunisasi *MasterImunisasi `gorm:"foreignKey:ImunisasiID;references:ID;constraint:OnUpdate:CASCADE,OnDelete:RESTRICT" json:"-"`
}

type ImunisasiAnak struct {
	ID            int32          `gorm:"primaryKey;autoIncrement" json:"id"`
	KehamilanID   int32          `json:"kehamilan_id" gorm:"not null;index;constraint:OnDelete:CASCADE"`
	Kehamilan     *Kehamilan     `json:"kehamilan,omitempty" gorm:"foreignKey:KehamilanID;constraint:OnDelete:CASCADE"`
	PendudukID    int32          `json:"penduduk_id" gorm:"not null;index;constraint:OnDelete:CASCADE"`
	Penduduk      *Kependudukan  `json:"penduduk,omitempty" gorm:"foreignKey:PendudukID;constraint:OnDelete:CASCADE"`
	BeratLahirKg  *float64       `json:"berat_lahir_kg,omitempty"`
	TinggiLahirCm *float64       `json:"tinggi_lahir_cm,omitempty"`
	TanggalLahir  *time.Time     `json:"tanggal_lahir,omitempty" gorm:"column:tanggal_lahir;type:date"`
	AnakKe        int32          `json:"anak_ke"`
	LingkarKepalaCm *float64     `json:"lingkar_kepala_cm,omitempty"`
	NamaIbu       string         `json:"nama_ibu"`
	NamaAyah      string         `json:"nama_ayah"`
	IbuID         int32          `json:"ibu_id"`
	StatusPrediksi string        `gorm:"column:status_prediksi;type:varchar(30)" json:"status_prediksi"`
	CreatedAt     time.Time      `json:"created_at"`
	UpdatedAt     time.Time      `json:"updated_at"`
	DeletedAt     gorm.DeletedAt `json:"-" gorm:"index"`
}


func (Imunisasi) TableName() string {
	return "imunisasi"
}
