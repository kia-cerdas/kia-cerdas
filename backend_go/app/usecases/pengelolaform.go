package usecases

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"monitoring-service/app/models"
	"monitoring-service/app/repositories"
)

// ----------------------------------------------------------------------------
// FormUsecase interface dan implementasi (tidak berubah, hanya disalin)
// ----------------------------------------------------------------------------

type FormUsecase interface {
    // Form Versi
    CreateFormVersion(ctx context.Context, req *models.CreateFormVersionRequest) (*models.FormVersionResponse, error)
    ActivateFormVersion(ctx context.Context, id uint) error
    DeactivateFormVersion(ctx context.Context, id uint) error
    DuplicateFormVersion(ctx context.Context, sourceID uint, req *models.DuplicateFormVersionRequest) (*models.FormVersionResponse, error)
    GetFormVersionsByKelompok(ctx context.Context, kelompok string) ([]models.FormVersionResponse, error)
    GetVersionDetail(ctx context.Context, id uint) (*models.FormVersionResponse, []models.QuestionResponse, []models.RiskRuleResponse, error)

    // Pertanyaan
    AddQuestion(ctx context.Context, versiID uint, req *models.AddQuestionRequest) (*models.QuestionResponse, error)
    UpdateQuestion(ctx context.Context, id uint, req *models.UpdateQuestionRequest) error
    DeleteQuestion(ctx context.Context, id uint) error

    // Aturan Risiko
    AddRiskRule(ctx context.Context, versiID uint, req *models.AddRiskRuleRequest) (*models.RiskRuleResponse, error)
    UpdateRiskRule(ctx context.Context, id uint, req *models.UpdateRiskRuleRequest) error
    DeleteRiskRule(ctx context.Context, id uint) error
}



type formUsecase struct {
    repo repositories.FormRepository
}

func NewFormUsecase(repo repositories.FormRepository) FormUsecase {
    return &formUsecase{repo: repo}
}

func (u *formUsecase) CreateFormVersion(ctx context.Context, req *models.CreateFormVersionRequest) (*models.FormVersionResponse, error) {
    versi := &models.FormVersi{
        Kelompok:   req.Kelompok,
        Tahun:      req.Tahun,
        Nama:       req.Nama,
        Keterangan: req.Keterangan,
        Aktif:      false,
    }
    if err := u.repo.CreateFormVersion(ctx, versi); err != nil {
        return nil, err
    }
    return &models.FormVersionResponse{
        ID:         versi.ID,
        Kelompok:   versi.Kelompok,
        Tahun:      versi.Tahun,
        Nama:       versi.Nama,
        Aktif:      versi.Aktif,
        Keterangan: versi.Keterangan,
    }, nil
}

func (u *formUsecase) ActivateFormVersion(ctx context.Context, id uint) error {
    versi, err := u.repo.GetFormVersionByID(ctx, id)
    if err != nil || versi == nil {
        return errors.New("version not found")
    }
    if err := u.repo.DeactivateAllVersionsInKelompok(ctx, versi.Kelompok); err != nil {
        return err
    }
    versi.Aktif = true
    return u.repo.UpdateFormVersion(ctx, versi)
}

func (u *formUsecase) DeactivateFormVersion(ctx context.Context, id uint) error {
    versi, err := u.repo.GetFormVersionByID(ctx, id)
    if err != nil || versi == nil {
        return errors.New("version not found")
    }
    active, _ := u.repo.GetActiveFormVersion(ctx, versi.Kelompok)
    if active != nil && active.ID == versi.ID {
        return errors.New("cannot deactivate the only active version")
    }
    versi.Aktif = false
    return u.repo.UpdateFormVersion(ctx, versi)
}

func (u *formUsecase) DuplicateFormVersion(ctx context.Context, sourceID uint, req *models.DuplicateFormVersionRequest) (*models.FormVersionResponse, error) {
    source, err := u.repo.GetFormVersionByID(ctx, sourceID)
    if err != nil || source == nil {
        return nil, errors.New("source version not found")
    }
    newVersi := &models.FormVersi{
        Kelompok:   source.Kelompok,
        Tahun:      req.TahunBaru,
        Nama:       req.NamaBaru,
        Keterangan: req.Keterangan,
        Aktif:      false,
    }
    if err := u.repo.CreateFormVersion(ctx, newVersi); err != nil {
        return nil, err
    }
    // Copy questions
    questions, _ := u.repo.GetQuestionsByVersion(ctx, sourceID)
    for _, q := range questions {
        newQ := models.FormPertanyaan{
            FormVersiID:    newVersi.ID,
            Key:            q.Key,
            Label:          q.Label,
            Tipe:           q.Tipe,
            Opsi:           q.Opsi,
            Satuan:         q.Satuan,
            Wajib:          q.Wajib,
            AturanValidasi: q.AturanValidasi,
            Urutan:         q.Urutan,
        }
        if err := u.repo.CreateQuestion(ctx, &newQ); err != nil {
            return nil, err
        }
    }
    // Copy risk rules
    rules, _ := u.repo.GetRiskRulesByVersion(ctx, sourceID)
    for _, r := range rules {
        newRule := models.FormAturanRisiko{
            FormVersiID:    newVersi.ID,
            NamaAturan:     r.NamaAturan,
            Kondisi:        r.Kondisi,
            KategoriRisiko: r.KategoriRisiko,
             Rekomendasi:    r.Rekomendasi,
            Prioritas:      r.Prioritas,
        }
        if err := u.repo.CreateRiskRule(ctx, &newRule); err != nil {
            return nil, err
        }
    }
    return &models.FormVersionResponse{
        ID:         newVersi.ID,
        Kelompok:   newVersi.Kelompok,
        Tahun:      newVersi.Tahun,
        Nama:       newVersi.Nama,
        Aktif:      newVersi.Aktif,
        Keterangan: newVersi.Keterangan,
    }, nil
}

func (u *formUsecase) GetFormVersionsByKelompok(ctx context.Context, kelompok string) ([]models.FormVersionResponse, error) {
    list, err := u.repo.GetFormVersionsByKelompok(ctx, kelompok)
    if err != nil {
        return nil, err
    }
    res := make([]models.FormVersionResponse, len(list))
    for i, v := range list {
        res[i] = models.FormVersionResponse{
            ID:         v.ID,
            Kelompok:   v.Kelompok,
            Tahun:      v.Tahun,
            Nama:       v.Nama,
            Aktif:      v.Aktif,
            Keterangan: v.Keterangan,
        }
    }
    return res, nil
}

func (u *formUsecase) GetVersionDetail(ctx context.Context, id uint) (*models.FormVersionResponse, []models.QuestionResponse, []models.RiskRuleResponse, error) {
    versi, err := u.repo.GetFormVersionByID(ctx, id)
    if err != nil || versi == nil {
        return nil, nil, nil, errors.New("version not found")
    }
    questions, _ := u.repo.GetQuestionsByVersion(ctx, id)
    rules, _ := u.repo.GetRiskRulesByVersion(ctx, id)
    versiResp := &models.FormVersionResponse{
        ID:         versi.ID,
        Kelompok:   versi.Kelompok,
        Tahun:      versi.Tahun,
        Nama:       versi.Nama,
        Aktif:      versi.Aktif,
        Keterangan: versi.Keterangan,
    }
    qResp := make([]models.QuestionResponse, len(questions))
    for i, q := range questions {
        var opsi []string
        json.Unmarshal(q.Opsi, &opsi)
        var validasi map[string]interface{}
        json.Unmarshal(q.AturanValidasi, &validasi)
        qResp[i] = models.QuestionResponse{
            ID:             q.ID,
            FormVersiID:    q.FormVersiID,
            Key:            q.Key,
            Label:          q.Label,
            Tipe:           q.Tipe,
            Opsi:           opsi,
            Satuan:         q.Satuan,
            Wajib:          q.Wajib,
            AturanValidasi: validasi,
            Urutan:         q.Urutan,
        }
    }
    rResp := make([]models.RiskRuleResponse, len(rules))
    for i, r := range rules {
        var kondisi map[string]interface{}
        json.Unmarshal(r.Kondisi, &kondisi)
        rResp[i] = models.RiskRuleResponse{
            ID:              r.ID,
            FormVersiID:     r.FormVersiID,
            NamaAturan:      r.NamaAturan,
            Kondisi:         kondisi,
            KategoriRisiko:  r.KategoriRisiko,
            Prioritas:       r.Prioritas,
        }
    }
    return versiResp, qResp, rResp, nil
}

func (u *formUsecase) AddQuestion(ctx context.Context, versiID uint, req *models.AddQuestionRequest) (*models.QuestionResponse, error) {
    exists, err := u.repo.CheckQuestionKeyExists(ctx, versiID, req.Key)
    if err != nil {
        return nil, err
    }
    if exists {
        return nil, fmt.Errorf("question key '%s' already exists", req.Key)
    }
    opsiJSON, _ := json.Marshal(req.Opsi)
    validasiJSON, _ := json.Marshal(req.Validasi)
    q := &models.FormPertanyaan{
        FormVersiID:    versiID,
        Key:            req.Key,
        Label:          req.Label,
        Tipe:           req.Tipe,
        Opsi:           opsiJSON,
        Satuan:         req.Satuan,
        Wajib:          req.Wajib,
        AturanValidasi: validasiJSON,
        Urutan:         req.Urutan,
    }
    if err := u.repo.CreateQuestion(ctx, q); err != nil {
        return nil, err
    }
    return &models.QuestionResponse{
        ID:             q.ID,
        FormVersiID:    q.FormVersiID,
        Key:            q.Key,
        Label:          q.Label,
        Tipe:           q.Tipe,
        Opsi:           req.Opsi,
        Satuan:         q.Satuan,
        Wajib:          q.Wajib,
        AturanValidasi: req.Validasi,
        Urutan:         q.Urutan,
    }, nil
}

func (u *formUsecase) UpdateQuestion(ctx context.Context, id uint, req *models.UpdateQuestionRequest) error {
    q, err := u.repo.GetQuestionByID(ctx, id)
    if err != nil || q == nil {
        return errors.New("question not found")
    }
    if req.Label != "" {
        q.Label = req.Label
    }
    if req.Tipe != "" {
        q.Tipe = req.Tipe
    }
    if req.Opsi != nil {
        opsiJSON, _ := json.Marshal(req.Opsi)
        q.Opsi = opsiJSON
    }
    if req.Satuan != "" {
        q.Satuan = req.Satuan
    }
    if req.Wajib != nil {
        q.Wajib = *req.Wajib
    }
    if req.Validasi != nil {
        valJSON, _ := json.Marshal(req.Validasi)
        q.AturanValidasi = valJSON
    }
    if req.Urutan != 0 {
        q.Urutan = req.Urutan
    }
    return u.repo.UpdateQuestion(ctx, q)
}

func (u *formUsecase) DeleteQuestion(ctx context.Context, id uint) error {
    return u.repo.DeleteQuestion(ctx, id)
}

func (u *formUsecase) AddRiskRule(ctx context.Context, versiID uint, req *models.AddRiskRuleRequest) (*models.RiskRuleResponse, error) {
    kondisiJSON, _ := json.Marshal(req.Kondisi)
    rule := &models.FormAturanRisiko{
        FormVersiID:    versiID,
        NamaAturan:     req.NamaAturan,
        Kondisi:        kondisiJSON,
        KategoriRisiko: req.KategoriRisiko,
        Prioritas:      req.Prioritas,
        Rekomendasi:    req.Rekomendasi,
    }
    if err := u.repo.CreateRiskRule(ctx, rule); err != nil {
        return nil, err
    }
    return &models.RiskRuleResponse{
        ID:              rule.ID,
        FormVersiID:     rule.FormVersiID,
        NamaAturan:      rule.NamaAturan,
        Kondisi:         req.Kondisi,
        KategoriRisiko:  rule.KategoriRisiko,
        Prioritas:       rule.Prioritas,
    }, nil
}

func (u *formUsecase) UpdateRiskRule(ctx context.Context, id uint, req *models.UpdateRiskRuleRequest) error {
    rule, err := u.repo.GetRiskRuleByID(ctx, id)
    if err != nil || rule == nil {
        return errors.New("rule not found")
    }
    if req.NamaAturan != "" {
        rule.NamaAturan = req.NamaAturan
    }
    if req.Kondisi != nil {
        kondisiJSON, _ := json.Marshal(req.Kondisi)
        rule.Kondisi = kondisiJSON
    }
    if req.KategoriRisiko != "" {
        rule.KategoriRisiko = req.KategoriRisiko
    }
    if req.Rekomendasi != "" {                 // tambahkan
        rule.Rekomendasi = req.Rekomendasi
    }
    if req.Prioritas != 0 {
        rule.Prioritas = req.Prioritas
    }
    return u.repo.UpdateRiskRule(ctx, rule)
}

func (u *formUsecase) DeleteRiskRule(ctx context.Context, id uint) error {
    return u.repo.DeleteRiskRule(ctx, id)
}

// ----------------------------------------------------------------------------
// PemeriksaanUsecase (implementasi yang diperbaiki)
// ----------------------------------------------------------------------------
