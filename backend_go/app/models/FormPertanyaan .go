package models

import (
	"time"
	"gorm.io/datatypes"
)
type FormPertanyaan struct {
    ID             uint           `gorm:"primaryKey"`
  FormVersiID    uint           `gorm:"not null;index"`
	FormVersi      FormVersi      `gorm:"foreignKey:FormVersiID;references:ID"`
    Key            string         `gorm:"size:100;not null"`        // unique per versi
    Label          string         `gorm:"size:255"`
    Tipe           string         `gorm:"size:20"`                  // angka, teks, boolean, pilihan, tanggal
    Opsi           datatypes.JSON `gorm:"type:jsonb"`               // untuk tipe pilihan
    Satuan         string         `gorm:"size:50"`
    Wajib          bool           `gorm:"default:false"`
    AturanValidasi datatypes.JSON `gorm:"type:jsonb"`               // {"min":0,"max":200}
    Urutan         int            `gorm:"default:0"`
    CreatedAt      time.Time
}

type QuestionResponse struct {
    ID             uint                   `json:"id"`
    FormVersiID    uint                   `json:"form_versi_id"`
    Key            string                 `json:"key"`
    Label          string                 `json:"label"`
    Tipe           string                 `json:"tipe"`
    Opsi           []string               `json:"opsi"`
    Satuan         string                 `json:"satuan"`
    Wajib          bool                   `json:"wajib"`
    AturanValidasi map[string]interface{} `json:"aturan_validasi"`
    Urutan         int                    `json:"urutan"`
}
type AddRiskRuleRequest struct {
    NamaAturan     string                 `json:"nama_aturan" validate:"required"`
    Kondisi        map[string]interface{} `json:"kondisi" validate:"required"`
    KategoriRisiko string                 `json:"kategori_risiko" validate:"required"`
    Prioritas      int                    `json:"prioritas"`
    Rekomendasi     string                 `json:"rekomendasi"`
}

type UpdateRiskRuleRequest struct {
    NamaAturan     string                 `json:"nama_aturan"`
    Kondisi        map[string]interface{} `json:"kondisi"`
    KategoriRisiko string                 `json:"kategori_risiko"`
    Prioritas      int                    `json:"prioritas"`
    Rekomendasi     string                 `json:"rekomendasi"`
}

    type CreateFormVersionRequest struct {
        Kelompok   string `json:"kelompok" validate:"required,oneof=balita anak remaja dewasa lansia"`
        Tahun      int    `json:"tahun" validate:"required,min=2000,max=2099"`
        Nama       string `json:"nama"`
        Keterangan string `json:"keterangan"`
    }

type DuplicateFormVersionRequest struct {
    TahunBaru  int    `json:"tahun_baru" validate:"required"`
    NamaBaru   string `json:"nama_baru"`
    Keterangan string `json:"keterangan"`
}

type AddQuestionRequest struct {
    Key      string                 `json:"key" validate:"required"`
    Label    string                 `json:"label" validate:"required"`
    Tipe     string                 `json:"tipe" validate:"required,oneof=angka teks boolean pilihan tanggal"`
    Opsi     []string               `json:"opsi"`
    Satuan   string                 `json:"satuan"`
    Wajib    bool                   `json:"wajib"`
    Validasi map[string]interface{} `json:"validasi"`
    Urutan   int                    `json:"urutan"`
}

type UpdateQuestionRequest struct {
    Label    string                 `json:"label"`
    Tipe     string                 `json:"tipe"`
    Opsi     []string               `json:"opsi"`
    Satuan   string                 `json:"satuan"`
    Wajib    *bool                  `json:"wajib"`
    Validasi map[string]interface{} `json:"validasi"`
    Urutan   int                    `json:"urutan"`
}