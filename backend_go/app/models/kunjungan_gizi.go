package models

import (
	"time"

	"gorm.io/gorm"
)

type KunjunganGizi struct {
	ID                int32          `json:"id" gorm:"primaryKey;autoIncrement"`
	AnakID            int32          `json:"anak_id" gorm:"not null;index"`
	Anak              *Anak          `json:"anak,omitempty" gorm:"foreignKey:AnakID"`
	Bulanke           int            `json:"bulan" gorm:"not null"`
	Tanggal           time.Time      `json:"tanggal" gorm:"not null"`
	TenagaKesehatanID int32          `json:"tenaga_kesehatan_id" gorm:"not null;index"`
	TenagaKesehatan   *User          `json:"tenaga_kesehatan,omitempty" gorm:"foreignKey:TenagaKesehatanID"`
	Lokasi            string         `json:"lokasi" gorm:"not null"`
	ASI               *ASI            `gorm:"foreignKey:KunjunganGiziID;constraint:OnDelete:CASCADE"`
	MPASI             *MPASI          `gorm:"foreignKey:KunjunganGiziID;constraint:OnDelete:CASCADE"`
	ObatCacing        *bool           `json:"obat_cacing,omitempty" gorm:"column:obat_cacing;type:bool"`
	JenisPemberianSusu string         `json:"jenis_pemberian_susu,omitempty" gorm:"column:jenis_pemberian_susu;type:varchar(30)"`
	MasihMenyusui     *bool           `json:"masih_menyusui,omitempty" gorm:"column:masih_menyusui;type:bool"`
	MenggunakanFormula *bool           `json:"menggunakan_formula,omitempty" gorm:"column:menggunakan_formula;type:bool"`
	AlasanFormula     string         `json:"alasan_formula,omitempty" gorm:"column:alasan_formula;type:text"`
	UsiaMulaiMpasi     *int            `json:"usia_mulai_mpasi,omitempty" gorm:"column:usia_mulai_mpasi;type:integer"`
	CreatedAt         time.Time      `json:"created_at"`
	UpdatedAt         time.Time      `json:"updated_at"`
	DeletedAt         gorm.DeletedAt `json:"-" gorm:"index"`
}

func (KunjunganGizi) TableName() string {
	return "kunjungan_gizi"
}

// func (k *KunjunganGizi) BeforeCreate(tx *gorm.DB) error {
// 	if k.ID == "" {
// 		k.ID = uuid.New().String()
// 	}
// 	return nil
// }
