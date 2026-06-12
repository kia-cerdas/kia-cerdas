package models

import "time"

type PendudukWithPemeriksaan struct {
    IDKependudukan      int32       `json:"id_kependudukan"`
    NIK                 *string     `json:"nik,omitempty"`
    NamaLengkap         string      `json:"nama_lengkap"`
    JenisKelamin        string      `json:"jenis_kelamin"`
    TanggalLahir        time.Time   `json:"tanggal_lahir"`
    TempatLahir         string      `json:"tempat_lahir"`
    Dusun               string      `json:"dusun"`
    DesaID              *int32      `json:"desa_id,omitempty"`
    Desa                *Desa       `json:"desa,omitempty"`
    UmurSekarang        int         `json:"umur_sekarang"`
    PemeriksaanTerakhir interface{} `json:"pemeriksaan_terakhir,omitempty"`
    DapatDitambahkan    bool        `json:"dapat_ditambahkan"`
    AlasanTidakBisa     string      `json:"alasan_tidak_bisa,omitempty"`
}