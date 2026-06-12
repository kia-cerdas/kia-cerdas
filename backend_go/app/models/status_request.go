package models

type StatusRequest struct {
	ID         uint   `gorm:"column:id;primaryKey" json:"id"`
	StatusRequest string `gorm:"column:status_request;type:text" json:"status_request"`
}

func (StatusRequest) TableName() string {
	return "status_request"
}
