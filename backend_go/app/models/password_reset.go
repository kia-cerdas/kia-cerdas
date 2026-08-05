package models

import "time"

type PasswordReset struct {
	ID        uint      `gorm:"column:id;primaryKey" json:"id"`
	Email     string    `gorm:"index;not null;column:email" json:"email"`
	OTP       string    `gorm:"not null;column:otp" json:"otp"`
	ExpiredAt time.Time `gorm:"not null;column:expired_at" json:"expired_at"`
	IsUsed    bool      `gorm:"default:false;column:is_used" json:"is_used"`
	CreatedAt time.Time `gorm:"column:created_at" json:"created_at"`
}

func (PasswordReset) TableName() string {
	return "password_resets"
}
