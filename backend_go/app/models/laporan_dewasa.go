package models

import "time"

type LaporanDewasa struct {
	// ========== FIXED FIELDS (dari model Kependudukan) ==========
	NIK                string    `json:"nik"`
	NamaLengkap        string    `json:"nama_lengkap"`
	TanggalLahir       time.Time `json:"tanggal_lahir"`
	Umur               int32     `json:"umur"`
	JenisKelamin       string    `json:"jenis_kelamin"`
	Dusun              string    `json:"dusun"`
	RT                 string    `json:"rt"`
	RW                 string    `json:"rw"`
	Desa               string    `json:"desa"`
	TanggalPemeriksaan time.Time `json:"tanggal_pemeriksaan"`
	KategoriRisiko     string    `json:"kategori_risiko"`
	Rekomendasi        string    `json:"rekomendasi"`
	
	// ========== DYNAMIC FIELDS (dari JSON jawaban) ==========
	JawabanRaw         string    `json:"jawaban_raw"`
	DynamicFields      map[string]interface{} `json:"dynamic_fields,omitempty" gorm:"-"`
}