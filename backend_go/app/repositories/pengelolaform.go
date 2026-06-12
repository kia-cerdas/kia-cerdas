package repositories

import (
	"context"
	"errors"
	"monitoring-service/app/models"

	"gorm.io/gorm"
)

type FormRepository interface {
    // FormVersi
    CreateFormVersion(ctx context.Context, versi *models.FormVersi) error
    GetFormVersionByID(ctx context.Context, id uint) (*models.FormVersi, error)
    GetFormVersionsByKelompok(ctx context.Context, kelompok string) ([]models.FormVersi, error)
    UpdateFormVersion(ctx context.Context, versi *models.FormVersi) error
    DeleteFormVersion(ctx context.Context, id uint) error
    GetActiveFormVersion(ctx context.Context, kelompok string) (*models.FormVersi, error)
    DeactivateAllVersionsInKelompok(ctx context.Context, kelompok string) error

    // FormPertanyaan
    CreateQuestion(ctx context.Context, q *models.FormPertanyaan) error
    GetQuestionByID(ctx context.Context, id uint) (*models.FormPertanyaan, error)
    GetQuestionsByVersion(ctx context.Context, versiID uint) ([]models.FormPertanyaan, error)
    UpdateQuestion(ctx context.Context, q *models.FormPertanyaan) error
    DeleteQuestion(ctx context.Context, id uint) error
    CheckQuestionKeyExists(ctx context.Context, versiID uint, key string) (bool, error)

    // FormAturanRisiko
    CreateRiskRule(ctx context.Context, rule *models.FormAturanRisiko) error
    GetRiskRuleByID(ctx context.Context, id uint) (*models.FormAturanRisiko, error)
    GetRiskRulesByVersion(ctx context.Context, versiID uint) ([]models.FormAturanRisiko, error)
    UpdateRiskRule(ctx context.Context, rule *models.FormAturanRisiko) error
    DeleteRiskRule(ctx context.Context, id uint) error
}




type formRepository struct {
    db *gorm.DB
}

func NewFormRepository(db *gorm.DB) FormRepository {
    return &formRepository{db: db}
}

// di repositories/pemeriksaan.go

// GetLatestRiskCountByPendudukIDs menghitung jumlah penduduk dengan kategori risiko terbaru per kelompok
// Asumsi: untuk setiap penduduk, ambil pemeriksaan terbaru, lalu hitung berdasarkan kategori_risiko
// GetLatestRiskCountByPendudukIDs menghitung jumlah penduduk dengan kategori risiko terbaru per kelompok


// ---- FormVersi ----
func (r *formRepository) CreateFormVersion(ctx context.Context, versi *models.FormVersi) error {
    return r.db.WithContext(ctx).Create(versi).Error
}

func (r *formRepository) GetFormVersionByID(ctx context.Context, id uint) (*models.FormVersi, error) {
    var versi models.FormVersi
    err := r.db.WithContext(ctx).First(&versi, id).Error
    if errors.Is(err, gorm.ErrRecordNotFound) {
        return nil, nil
    }
    return &versi, err
}

func (r *formRepository) GetFormVersionsByKelompok(ctx context.Context, kelompok string) ([]models.FormVersi, error) {
    var list []models.FormVersi
    err := r.db.WithContext(ctx).Where("kelompok = ?", kelompok).Order("tahun desc").Find(&list).Error
    return list, err
}

func (r *formRepository) UpdateFormVersion(ctx context.Context, versi *models.FormVersi) error {
    return r.db.WithContext(ctx).Save(versi).Error
}

func (r *formRepository) DeleteFormVersion(ctx context.Context, id uint) error {
    return r.db.WithContext(ctx).Delete(&models.FormVersi{}, id).Error
}

func (r *formRepository) GetActiveFormVersion(ctx context.Context, kelompok string) (*models.FormVersi, error) {
    var versi models.FormVersi
    err := r.db.WithContext(ctx).Where("kelompok = ? AND aktif = true", kelompok).First(&versi).Error
    if errors.Is(err, gorm.ErrRecordNotFound) {
        return nil, nil
    }
    return &versi, err
}

func (r *formRepository) DeactivateAllVersionsInKelompok(ctx context.Context, kelompok string) error {
    return r.db.WithContext(ctx).Model(&models.FormVersi{}).
        Where("kelompok = ? AND aktif = true", kelompok).
        Update("aktif", false).Error
}

// ---- FormPertanyaan ----
func (r *formRepository) CreateQuestion(ctx context.Context, q *models.FormPertanyaan) error {
    return r.db.WithContext(ctx).Create(q).Error
}

func (r *formRepository) GetQuestionByID(ctx context.Context, id uint) (*models.FormPertanyaan, error) {
    var q models.FormPertanyaan
    err := r.db.WithContext(ctx).First(&q, id).Error
    if errors.Is(err, gorm.ErrRecordNotFound) {
        return nil, nil
    }
    return &q, err
}

func (r *formRepository) GetQuestionsByVersion(ctx context.Context, versiID uint) ([]models.FormPertanyaan, error) {
    var list []models.FormPertanyaan
    err := r.db.WithContext(ctx).Where("form_versi_id = ?", versiID).Order("urutan").Find(&list).Error
    return list, err
}

func (r *formRepository) UpdateQuestion(ctx context.Context, q *models.FormPertanyaan) error {
    return r.db.WithContext(ctx).Save(q).Error
}

func (r *formRepository) DeleteQuestion(ctx context.Context, id uint) error {
    return r.db.WithContext(ctx).Delete(&models.FormPertanyaan{}, id).Error
}

func (r *formRepository) CheckQuestionKeyExists(ctx context.Context, versiID uint, key string) (bool, error) {
    var count int64
    err := r.db.WithContext(ctx).Model(&models.FormPertanyaan{}).
        Where("form_versi_id = ? AND key = ?", versiID, key).
        Count(&count).Error
    return count > 0, err
}

// ---- FormAturanRisiko ----
func (r *formRepository) CreateRiskRule(ctx context.Context, rule *models.FormAturanRisiko) error {
    return r.db.WithContext(ctx).Create(rule).Error
}

func (r *formRepository) GetRiskRuleByID(ctx context.Context, id uint) (*models.FormAturanRisiko, error) {
    var rule models.FormAturanRisiko
    err := r.db.WithContext(ctx).First(&rule, id).Error
    if errors.Is(err, gorm.ErrRecordNotFound) {
        return nil, nil
    }
    return &rule, err
}

func (r *formRepository) GetRiskRulesByVersion(ctx context.Context, versiID uint) ([]models.FormAturanRisiko, error) {
    var list []models.FormAturanRisiko
    err := r.db.WithContext(ctx).Where("form_versi_id = ?", versiID).Order("prioritas desc").Find(&list).Error
    return list, err
}

func (r *formRepository) UpdateRiskRule(ctx context.Context, rule *models.FormAturanRisiko) error {
    return r.db.WithContext(ctx).Save(rule).Error
}

func (r *formRepository) DeleteRiskRule(ctx context.Context, id uint) error {
    return r.db.WithContext(ctx).Delete(&models.FormAturanRisiko{}, id).Error
}
