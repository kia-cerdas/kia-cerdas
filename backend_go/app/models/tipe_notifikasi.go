package models

type TipeNotifikasi struct {
	ID        		uint      	`gorm:"column:id;primaryKey" json:"id"`
	Tipe      		string    	`gorm:"column:tipe;type:varchar(50);not null" json:"tipe"`
	DeltaHari    	string 		`gorm:"column:delta_hari;type:varchar(100);not null" json:"delta_hari"`
}

func (TipeNotifikasi) TableName() string {
	return "tipe_notifikasi"
}