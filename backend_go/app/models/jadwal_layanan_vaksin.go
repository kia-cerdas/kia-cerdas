package models

// JadwalLayananVaksin adalah pivot table untuk relasi many-to-many
// antara JadwalLayanan dan Vaksin
type JadwalLayananVaksin struct {
	JadwalLayananID int32 `json:"jadwal_layanan_id" gorm:"primaryKey;column:jadwal_layanan_id;index"`
	VaksinID        uint  `json:"vaksin_id" gorm:"primaryKey;column:vaksin_id;index"`
}

func (JadwalLayananVaksin) TableName() string {
	return "jadwal_layanan_vaksin"
}
