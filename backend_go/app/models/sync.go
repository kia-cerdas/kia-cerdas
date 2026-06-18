package models

// SyncPushRequest menampung semua data dinamis/transaksional dari Flutter
type SyncPushRequest struct {
	Desa                      []map[string]interface{} `json:"desa"`
	Puskesmas                 []map[string]interface{} `json:"puskesmas"`
	Posyandu                  []map[string]interface{} `json:"posyandu"`
	KartuKeluarga             []map[string]interface{} `json:"kartu_keluarga"`
	Penduduk                  []map[string]interface{} `json:"penduduk"`
	Pengguna                  []map[string]interface{} `json:"pengguna"`
	Bidan                     []map[string]interface{} `json:"bidan"`
	Kader                     []map[string]interface{} `json:"kader"`
	Ibu                       []map[string]interface{} `json:"ibu"`
	Kehamilan                 []map[string]interface{} `json:"kehamilan"`
	PemeriksaanKehamilan      []map[string]interface{} `json:"pemeriksaan_kehamilan"`
	EvaluasiKesehatanIbu      []map[string]interface{} `json:"evaluasi_kesehatan_ibu"`
	PemeriksaanDokterTri1     []map[string]interface{} `json:"pemeriksaan_dokter_trimester_1"`
	PemeriksaanDokterTri3     []map[string]interface{} `json:"pemeriksaan_dokter_trimester_3"`
	PemeriksaanLanjutanTri3   []map[string]interface{} `json:"pemeriksaan_lanjutan_trimester_3"`
	CatatanPelayananTri1      []map[string]interface{} `json:"catatan_pelayanan_trimester_1"`
	CatatanPelayananTri2      []map[string]interface{} `json:"catatan_pelayanan_trimester_2"`
	CatatanPelayananTri3      []map[string]interface{} `json:"catatan_pelayanan_trimester_3"`
	SkriningPreeklampsia      []map[string]interface{} `json:"skrining_preeklampsia"`
	GrafikEvaluasiKehamilan   []map[string]interface{} `json:"grafik_evaluasi_kehamilan"`
	GrafikPeningkatanBB       []map[string]interface{} `json:"grafik_peningkatan_bb"`
	PenjelasanHasilGrafik     []map[string]interface{} `json:"penjelasan_hasil_grafik"`
	RencanaPersalinan         []map[string]interface{} `json:"rencana_persalinan"`
	RingkasanPelayananPersal  []map[string]interface{} `json:"ringkasan_pelayanan_persalinan"`
	RiwayatProsesMelahirkan   []map[string]interface{} `json:"riwayat_proses_melahirkan"`
	KeteranganLahir           []map[string]interface{} `json:"keterangan_lahir"`
	PelayananIbuNifas         []map[string]interface{} `json:"pelayanan_ibu_nifas"`
	CatatanPelayananNifas     []map[string]interface{} `json:"catatan_pelayanan_nifas"`
	ChecklistPemantauanNifas  []map[string]interface{} `json:"checklist_pemantauan_ibu_nifas"`
	RiwayatKehamilanLalu      []map[string]interface{} `json:"riwayat_kehamilan_lalu"`
	Rujukan                   []map[string]interface{} `json:"rujukan"`
	LogTtdMms                 []map[string]interface{} `json:"log_ttd_mms"`
	Anak                      []map[string]interface{} `json:"anak"`
	KeluhanAnak               []map[string]interface{} `json:"keluhan_anak"`
	PeriksaGigi               []map[string]interface{} `json:"periksa_gigi"`
	PengukuranLila            []map[string]interface{} `json:"pengukuran_lila"`
	CatatanPertumbuhan        []map[string]interface{} `json:"catatan_pertumbuhan"`
	JadwalLayanan             []map[string]interface{} `json:"jadwal_layanan"`
	JadwalImunisasiAnak       []map[string]interface{} `json:"jadwal_imunisasi_anak"`
	RequestPerubahanImunisasi []map[string]interface{} `json:"request_perubahan_imunisasi"`
}
