package models

import "time"

type CatatanPelayananKehamilan struct {
	IDCatatan                       int32      `gorm:"primaryKey;autoIncrement" json:"id_catatan"`
	KehamilanID                     int32      `gorm:"not null;index" json:"kehamilan_id"`
	Kehamilan                       *Kehamilan `gorm:"foreignKey:KehamilanID;references:ID;onDelete:CASCADE" json:"kehamilan,omitempty"`
	Trimester                       int8       `gorm:"not null" json:"trimester"` // 1, 2, atau 3
	TanggalPeriksaStampParaf        *time.Time `gorm:"type:date" json:"tanggal_periksa_stamp_paraf"`
	KeluhanPemeriksaanTindakanSaran string     `json:"keluhan_pemeriksaan_tindakan_saran"`
	TanggalKembali                  *time.Time `gorm:"type:date" json:"tanggal_kembali"`
}

func (CatatanPelayananKehamilan) TableName() string {
	return "catatan_pelayanan_kehamilan"
}
