package models

import (
    "time"
)

type LaporanDinamis struct {
    // Data dasar (selalu ada)
    ID                 uint                   `json:"id"`
    NIK                string                 `json:"nik"`
    NamaLengkap        string                 `json:"nama_lengkap"`
    JenisKelamin       string                 `json:"jenis_kelamin"`
    TanggalLahir       time.Time              `json:"tanggal_lahir"`
    Umur               int                    `json:"umur"`
    Kelompok           string                 `json:"kelompok"` // anak, remaja, dewasa, lansia
    TanggalPemeriksaan time.Time              `json:"tanggal_pemeriksaan"`
    KategoriRisiko     string                 `json:"kategori_risiko"`
    Rekomendasi        string                 `json:"rekomendasi"`
    Petugas            string                 `json:"petugas"`
    Kecamatan          string                 `json:"kecamatan"`
    Desa               string                 `json:"desa"`
    Jawaban            map[string]interface{} `json:"jawaban"` // SEMUA field dinamis
}