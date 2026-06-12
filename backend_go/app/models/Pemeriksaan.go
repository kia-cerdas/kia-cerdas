package models

import (
	"time"

	"gorm.io/datatypes"
	"gorm.io/gorm"
)	
type Pemeriksaan struct {
    ID                 uint           `gorm:"primaryKey"`
    PendudukID         uint           `gorm:"not null;index"`
    Kelompok           string         `gorm:"size:20;not null;index"` // anak, remaja, dewasa, lansia
    TanggalPemeriksaan time.Time      `gorm:"not null"`
    FormVersiID        uint           `gorm:"not null;index"`
    Jawaban            datatypes.JSON `gorm:"type:jsonb;not null"`
   KategoriRisiko string `gorm:"size:50;not null"`
    Rekomendasi    string `gorm:"size:250"` 
    PetugasID          *uint          `gorm:"index"`
    CreatedAt          time.Time
    UpdatedAt          time.Time
    DeletedAt          gorm.DeletedAt `gorm:"index"`

    Penduduk *Kependudukan `gorm:"foreignKey:PendudukID"`
    FormVersi *FormVersi   `gorm:"foreignKey:FormVersiID"`
    Petugas   *User        `gorm:"foreignKey:PetugasID"`
}

func (Pemeriksaan) TableName() string {
    return "pemeriksaans"
}


type SavePemeriksaanRequest struct {
    PendudukID uint                   `json:"penduduk_id" validate:"required"`
    Kelompok   string                 `json:"kelompok" validate:"required,oneof=balita anak remaja dewasa lansia"`
    Tanggal    string                 `json:"tanggal" validate:"required"` // YYYY-MM-DD
    Data       map[string]interface{} `json:"data" validate:"required"`
}

type PemeriksaanResponse struct {
    ID                 uint      `json:"id"`
    PendudukID         uint      `json:"penduduk_id"`
    Kelompok           string    `json:"kelompok"`
    TanggalPemeriksaan time.Time `json:"tanggal_pemeriksaan"`
    FormVersiID        uint      `json:"form_versi_id"`
    KategoriRisiko     string    `json:"kategori_risiko"`
    Rekomendasi        string    `json:"rekomendasi,omitempty"`
    PetugasID          *uint     `json:"petugas_id"`
    CreatedAt          time.Time `json:"created_at"`
}

type RiskRuleResponse struct {
    ID              uint                   `json:"id"`
    FormVersiID     uint                   `json:"form_versi_id"`
    NamaAturan      string                 `json:"nama_aturan"`
    Kondisi         map[string]interface{} `json:"kondisi"`
    KategoriRisiko  string                 `json:"kategori_risiko"`
    Prioritas       int                    `json:"prioritas"`
}

type ActiveFormResponse struct {
    Versi      FormVersionResponse   `json:"versi"`
    Pertanyaan []QuestionResponse    `json:"pertanyaan"`
}

type RiwayatPemeriksaanResponse struct {
    ID                 uint      `json:"id"`
    TanggalPemeriksaan time.Time `json:"tanggal_pemeriksaan"`
    Kelompok           string    `json:"kelompok"`
     Rekomendasi        string    `json:"rekomendasi,omitempty"` 
    KategoriRisiko     string    `json:"kategori_risiko"`
}

type DetailPemeriksaanResponse struct {
    ID                 uint                   `json:"id"`
    PendudukID         uint                   `json:"penduduk_id"`
    NamaPenduduk       string                 `json:"nama_penduduk"`
    Kelompok           string                 `json:"kelompok"`
    TanggalPemeriksaan time.Time              `json:"tanggal_pemeriksaan"`
    VersiForm          string                 `json:"versi_form"`
    KategoriRisiko     string                 `json:"kategori_risiko"`
    Rekomendasi        string                 `json:"rekomendasi,omitempty"`
    Jawaban            map[string]interface{} `json:"jawaban"`
    PetugasNama        string                 `json:"petugas_nama,omitempty"`
}
type PasienPencatatanResponse struct {
    IDKependudukan      int32                         `json:"id_kependudukan"`
    NamaLengkap         string                        `json:"nama_lengkap"`
    NIK                 string                        `json:"nik"`
    UmurSekarang        int                           `json:"umur_sekarang"`
    Dusun               string                        `json:"dusun"`
    KategoriRisiko      string                        `json:"kategori_risiko"`
    DapatDitambahkan    bool                          `json:"dapat_ditambahkan"`
    PemeriksaanTerakhir *PemeriksaanTerakhirResponse  `json:"pemeriksaan_terakhir,omitempty"`
}

// models/pemeriksaan.go (tambahkan di bawah model yang sudah ada)

type PemeriksaanTerakhirResponse struct {
    TanggalPemeriksaan time.Time  `json:"tanggal_pemeriksaan"`
    TekananDarah       string     `json:"tekanan_darah,omitempty"`
    GulaDarah          *float64   `json:"gula_darah,omitempty"`
    Suhu               *float64   `json:"suhu,omitempty"`
    BeratBadan         *float64   `json:"berat_badan,omitempty"`
    TinggiBadan        *float64   `json:"tinggi_badan,omitempty"`
    IMT                *float64   `json:"imt,omitempty"`
    StatusGizi         string     `json:"status_gizi,omitempty"`
    KategoriRisiko     string     `json:"kategori_risiko"`
    StatusPemantauan   string     `json:"status_pemantauan,omitempty"`
    RiwayatPenyakit    string     `json:"riwayat_penyakit,omitempty"`
    CatatanKhusus      string     `json:"catatan_khusus,omitempty"`
}