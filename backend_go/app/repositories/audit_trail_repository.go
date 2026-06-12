package repositories

import (
	"strings"
	"time"

	"monitoring-service/app/models"

	"gorm.io/gorm"
)

type AuditTrailFilter struct {
	Search          string
	ActorIdentifier string
	Action          string
	Resource        string
	Role            string
	Method          string
	Success         *bool
	From            *time.Time
	To              *time.Time
	Page            int
	Limit           int
}

type AuditTrailPage struct {
	Items []models.AuditTrail `json:"items"`
	Total int64               `json:"total"`
	Page  int                 `json:"page"`
	Limit int                 `json:"limit"`
}

type AuditTrailSummary struct {
	Total       int64 `json:"total"`
	Success     int64 `json:"success"`
	Failed      int64 `json:"failed"`
	Today       int64 `json:"today"`
	Last24Hours int64 `json:"last_24_hours"`
}

type AuditTrailRepository struct {
	db *gorm.DB
}

func NewAuditTrailRepository(db *gorm.DB) *AuditTrailRepository {
	return &AuditTrailRepository{db: db}
}

func (r *AuditTrailRepository) Create(entry *models.AuditTrail) error {
	return r.db.Create(entry).Error
}

func (r *AuditTrailRepository) List(filter AuditTrailFilter) (*AuditTrailPage, error) {
	page := filter.Page
	limit := filter.Limit
	if page <= 0 {
		page = 1
	}
	if limit <= 0 {
		limit = 20
	}
	if limit > 100 {
		limit = 100
	}

	query := r.baseQuery(filter)

	var total int64
	if err := query.Count(&total).Error; err != nil {
		return nil, err
	}

	var items []models.AuditTrail
	if err := query.Order("created_at DESC").Offset((page - 1) * limit).Limit(limit).Find(&items).Error; err != nil {
		return nil, err
	}

	return &AuditTrailPage{Items: items, Total: total, Page: page, Limit: limit}, nil
}

func (r *AuditTrailRepository) Summary(filter AuditTrailFilter) (*AuditTrailSummary, error) {
	base := r.baseQuery(filter)

	var total, success, failed, today, last24Hours int64
	if err := base.Count(&total).Error; err != nil {
		return nil, err
	}
	if err := base.Where("success = ?", true).Count(&success).Error; err != nil {
		return nil, err
	}
	if err := base.Where("success = ?", false).Count(&failed).Error; err != nil {
		return nil, err
	}

	now := time.Now()
	startOfDay := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, now.Location())
	if err := base.Where("created_at >= ?", startOfDay).Count(&today).Error; err != nil {
		return nil, err
	}
	if err := base.Where("created_at >= ?", now.Add(-24*time.Hour)).Count(&last24Hours).Error; err != nil {
		return nil, err
	}

	return &AuditTrailSummary{
		Total:       total,
		Success:     success,
		Failed:      failed,
		Today:       today,
		Last24Hours: last24Hours,
	}, nil
}

func (r *AuditTrailRepository) baseQuery(filter AuditTrailFilter) *gorm.DB {
	query := r.db.Model(&models.AuditTrail{})

	if search := strings.TrimSpace(filter.Search); search != "" {
		pattern := "%" + search + "%"
		query = query.Where(
			"actor_identifier ILIKE ? OR actor_role ILIKE ? OR action ILIKE ? OR resource ILIKE ? OR path ILIKE ? OR details ILIKE ?",
			pattern, pattern, pattern, pattern, pattern, pattern,
		)
	}
	if value := strings.TrimSpace(filter.ActorIdentifier); value != "" {
		query = query.Where("actor_identifier ILIKE ?", "%"+value+"%")
	}
	if value := strings.TrimSpace(filter.Action); value != "" {
		query = query.Where("LOWER(action) = LOWER(?)", value)
	}
	if value := strings.TrimSpace(filter.Resource); value != "" {
		query = query.Where("LOWER(resource) = LOWER(?)", value)
	}
	if value := strings.TrimSpace(filter.Role); value != "" {
		query = query.Where("LOWER(actor_role) = LOWER(?)", value)
	}
	if value := strings.TrimSpace(filter.Method); value != "" {
		query = query.Where("LOWER(method) = LOWER(?)", value)
	}
	if filter.Success != nil {
		query = query.Where("success = ?", *filter.Success)
	}
	if filter.From != nil {
		query = query.Where("created_at >= ?", *filter.From)
	}
	if filter.To != nil {
		query = query.Where("created_at <= ?", *filter.To)
	}

	return query
}
