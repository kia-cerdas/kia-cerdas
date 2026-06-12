package models

import "time"

type AuditTrail struct {
	ID              int64     `gorm:"column:id;primaryKey" json:"id"`
	ActorUserID     *int32    `gorm:"column:actor_user_id;index" json:"actor_user_id,omitempty"`
	ActorIdentifier string    `gorm:"column:actor_identifier;type:varchar(150);not null;index" json:"actor_identifier"`
	ActorRole       string    `gorm:"column:actor_role;type:varchar(80);index" json:"actor_role"`
	Action          string    `gorm:"column:action;type:varchar(40);not null;index" json:"action"`
	Resource        string    `gorm:"column:resource;type:varchar(120);not null;index" json:"resource"`
	Method          string    `gorm:"column:method;type:varchar(10);not null;index" json:"method"`
	Path            string    `gorm:"column:path;type:varchar(255);not null" json:"path"`
	StatusCode      int       `gorm:"column:status_code;not null;index" json:"status_code"`
	Success         bool      `gorm:"column:success;not null;default:false;index" json:"success"`
	IPAddress       string    `gorm:"column:ip_address;type:varchar(64)" json:"ip_address,omitempty"`
	UserAgent       string    `gorm:"column:user_agent;type:text" json:"user_agent,omitempty"`
	RequestID       string    `gorm:"column:request_id;type:varchar(120);index" json:"request_id,omitempty"`
	Details         string    `gorm:"column:details;type:text" json:"details,omitempty"`
	CreatedAt       time.Time `gorm:"column:created_at;autoCreateTime" json:"created_at"`
	UpdatedAt       time.Time `gorm:"column:updated_at;autoUpdateTime" json:"updated_at"`
}

func (AuditTrail) TableName() string {
	return "audit_trails"
}
