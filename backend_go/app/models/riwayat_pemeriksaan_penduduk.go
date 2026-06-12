package models

import "time"

// Response untuk data diri
type DataDiriResponse struct {
    ID           int32     `json:"id"`
    NIK          string    `json:"nik"`
    NamaLengkap  string    `json:"nama_lengkap"`
    Dusun        string    `json:"dusun"`
    TanggalLahir time.Time `json:"tanggal_lahir"`
    Usia         int       `json:"usia"`
    JenisKelamin string    `json:"jenis_kelamin"`
    Agama        string    `json:"agama,omitempty"`
    Pekerjaan    string    `json:"pekerjaan,omitempty"`
}

// Card riwayat pemeriksaan
type RiwayatCard struct {
    ID                 uint      `json:"id"`
    Kategori           string    `json:"kategori"`
    TanggalPemeriksaan time.Time `json:"tanggal_pemeriksaan"`
    IMT                *float64  `json:"imt,omitempty"`
    StatusGizi         string    `json:"status_gizi,omitempty"`
    KategoriRisiko     string    `json:"kategori_risiko"`
    CatatanKhusus      string    `json:"catatan_khusus,omitempty"`
    BeratBadan         *float64  `json:"berat_badan,omitempty"`
    TinggiBadan        *float64  `json:"tinggi_badan,omitempty"`
    TekananDarah       string    `json:"tekanan_darah,omitempty"`
    GulaDarah          float64   `json:"gula_darah,omitempty"`
    Kolesterol         float64   `json:"kolesterol,omitempty"`
    PenyakitKronis     string    `json:"penyakit_kronis,omitempty"`
    StatusKemandirian  string    `json:"status_kemandirian,omitempty"`
    Rekomendasi        string    `json:"rekomendasi,omitempty"` // field ini penting
}

// Response lengkap
type PendudukRiwayatCardResponse struct {
    DataDiri DataDiriResponse `json:"data_diri"`
    Riwayat  []RiwayatCard    `json:"riwayat"`
}