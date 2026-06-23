package models

type JadwalLayananDosisVaksin struct {
	JadwalLayananID int32 `json:"jadwal_layanan_id" gorm:"primaryKey;column:jadwal_layanan_id;index"`
	DosisVaksinID   uint  `json:"dosis_vaksin_id" gorm:"primaryKey;column:dosis_vaksin_id;index;type:bigint"`
}

func (JadwalLayananDosisVaksin) TableName() string {
	return "jadwal_layanan_dosis_vaksin"
}
