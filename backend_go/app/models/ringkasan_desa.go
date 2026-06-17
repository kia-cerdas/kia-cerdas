package models

// RingkasanIbuHamil merangkum jumlah ibu hamil aktif per trimester di sebuah desa,
// dihitung dari kolom kehamilan.status_kehamilan ('TRIMESTER 1' / 'TRIMESTER 2' / 'TRIMESTER 3').
type RingkasanIbuHamil struct {
	Total      int64 `json:"total"`
	Trimester1 int64 `json:"trimester_1"`
	Trimester2 int64 `json:"trimester_2"`
	Trimester3 int64 `json:"trimester_3"`
}

// RingkasanVerifikasiItem merangkum status verifikasi kader untuk satu jenis menu
// (mis. Kelas Ibu Balita, Kelas Ibu Hamil, Pemantauan Ibu Hamil, Pemantauan Ibu Nifas).
type RingkasanVerifikasiItem struct {
	Key             string `json:"key"`
	Label           string `json:"label"`
	Total           int64  `json:"total"`
	SudahVerifikasi int64  `json:"sudah_verifikasi"`
	BelumVerifikasi int64  `json:"belum_verifikasi"`
}

// RingkasanDesaResponse adalah ringkasan dinamis kondisi desa binaan kader,
// digunakan oleh dashboard kader (kartu "Ringkasan Desa" & menu layanan).
type RingkasanDesaResponse struct {
	DesaID            *int32                     `json:"desa_id,omitempty"`
	NamaDesa          string                     `json:"nama_desa,omitempty"`
	IbuHamil          RingkasanIbuHamil          `json:"ibu_hamil"`
	JumlahAnak        int64                      `json:"jumlah_anak"`
	PerluTindakLanjut int64                       `json:"perlu_tindak_lanjut"`
	Verifikasi        []RingkasanVerifikasiItem `json:"verifikasi"`
}
