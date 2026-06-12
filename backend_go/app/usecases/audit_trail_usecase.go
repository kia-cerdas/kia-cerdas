package usecases

import (
	"net/http"
	"strings"

	"monitoring-service/app/models"
	"monitoring-service/app/repositories"
	"monitoring-service/pkg/customerror"
)

type AuditTrailUsecase struct {
	repository *repositories.AuditTrailRepository
}

func NewAuditTrailUsecase(repository *repositories.AuditTrailRepository) *AuditTrailUsecase {
	return &AuditTrailUsecase{repository: repository}
}

func (u *AuditTrailUsecase) Record(entry *models.AuditTrail) error {
	if u == nil || u.repository == nil {
		return customerror.NewInternalServiceError("audit trail repository tidak tersedia")
	}
	if entry == nil {
		return customerror.NewBadRequestError("audit trail tidak valid")
	}

	entry.Action = strings.ToUpper(strings.TrimSpace(entry.Action))
	entry.Resource = strings.TrimSpace(entry.Resource)
	entry.Method = strings.ToUpper(strings.TrimSpace(entry.Method))
	entry.ActorIdentifier = strings.TrimSpace(entry.ActorIdentifier)
	entry.ActorRole = strings.TrimSpace(entry.ActorRole)
	entry.Path = strings.TrimSpace(entry.Path)
	if entry.StatusCode == 0 {
		if entry.Success {
			entry.StatusCode = http.StatusOK
		} else {
			entry.StatusCode = http.StatusInternalServerError
		}
	}

	if entry.Action == "" {
		return customerror.NewBadRequestError("aksi audit trail wajib diisi")
	}
	if entry.Resource == "" {
		entry.Resource = "system"
	}
	if entry.Method == "" {
		entry.Method = "UNKNOWN"
	}
	if entry.Path == "" {
		entry.Path = "/"
	}
	if entry.ActorIdentifier == "" {
		entry.ActorIdentifier = "anonymous"
	}

	return u.repository.Create(entry)
}

func (u *AuditTrailUsecase) List(filter repositories.AuditTrailFilter) (*repositories.AuditTrailPage, error) {
	if u == nil || u.repository == nil {
		return nil, customerror.NewInternalServiceError("audit trail repository tidak tersedia")
	}

	return u.repository.List(filter)
}

func (u *AuditTrailUsecase) Summary(filter repositories.AuditTrailFilter) (*repositories.AuditTrailSummary, error) {
	if u == nil || u.repository == nil {
		return nil, customerror.NewInternalServiceError("audit trail repository tidak tersedia")
	}

	return u.repository.Summary(filter)
}
