package models

import "time"

type User struct {
	ID          int32          `gorm:"column:id;primaryKey" json:"id"`
	// Username menyimpan nama login pengguna (kolom DB tetap `nama`).
	// JSON key dibiarkan `name` agar konsumen web/mobile yang sudah ada tetap kompatibel.
	Username    string         `gorm:"column:nama;type:varchar(120);not null" json:"name"`
	Email       string         `gorm:"column:email;type:varchar(120);not null;uniqueIndex" json:"email"`
	IsActive    bool           `gorm:"column:is_active;not null;default:true" json:"is_active"`
	Password    string         `gorm:"column:kata_sandi;type:text;not null" json:"-"`
	RoleID      int32          `gorm:"not null;index" json:"role_id"`
	PendudukID  *int64         `gorm:"column:penduduk_id" json:"penduduk_id,omitempty"`
	Role        Role           `gorm:"foreignKey:RoleID;references:ID" json:"role"`
	Penduduk    *Kependudukan  `gorm:"foreignKey:PendudukID;references:IDKependudukan" json:"penduduk,omitempty"`
	CreatedAt   time.Time      `gorm:"column:created_at" json:"created_at"`
	UpdatedAt   time.Time      `gorm:"column:updated_at" json:"updated_at"`
}

func (User) TableName() string {
	return "pengguna"
}
