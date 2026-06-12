package models

type SkriningPreeklampsia struct {
	ID          int32      `gorm:"primaryKey" json:"id"`
	KehamilanID int32      `gorm:"not null;index" json:"kehamilan_id"`
	Kehamilan   *Kehamilan `gorm:"foreignKey:KehamilanID;references:ID" json:"kehamilan,omitempty"`

	AnamnesisMultiparaPasanganBaruSedang       bool `gorm:"column:anamnesis_multipara_pasangan_baru_sedang" json:"anamnesis_multipara_pasangan_baru_sedang"`
	AnamnesisTeknologiReproduksiBerbantuSedang bool `gorm:"column:anamnesis_teknologi_reproduksi_berbantu_sedang" json:"anamnesis_teknologi_reproduksi_berbantu_sedang"`
	AnamnesisUmurDiatas35TahunSedang           bool `gorm:"column:anamnesis_umur_diatas35_tahun_sedang" json:"anamnesis_umur_diatas_35_tahun_sedang"`
	AnamnesisNuliparaSedang                    bool `gorm:"column:anamnesis_nulipara_sedang" json:"anamnesis_nulipara_sedang"`
	AnamnesisJarakKehamilanDiatas10TahunSedang bool `gorm:"column:anamnesis_jarak_kehamilan_diatas10_tahun_sedang" json:"anamnesis_jarak_kehamilan_diatas_10_tahun_sedang"`
	AnamnesisRiwayatPreeklampsiaKeluargaSedang bool `gorm:"column:anamnesis_riwayat_preeklampsia_keluarga_sedang" json:"anamnesis_riwayat_preeklampsia_keluarga_sedang"`
	AnamnesisObesitasIMTDiatas30Sedang         bool `gorm:"column:anamnesis_obesitas_imt_diatas30_sedang" json:"anamnesis_obesitas_imt_diatas_30_sedang"`

	AnamnesisRiwayatPreeklampsiaSebelumnyaTinggi bool `gorm:"column:anamnesis_riwayat_preeklampsia_sebelumnya_tinggi" json:"anamnesis_riwayat_preeklampsia_sebelumnya_tinggi"`
	AnamnesisKehamilanMultipelTinggi             bool `gorm:"column:anamnesis_kehamilan_multipel_tinggi" json:"anamnesis_kehamilan_multipel_tinggi"`
	AnamnesisDiabetesDalamKehamilanTinggi        bool `gorm:"column:anamnesis_diabetes_dalam_kehamilan_tinggi" json:"anamnesis_diabetes_dalam_kehamilan_tinggi"`
	AnamnesisHipertensiKronikTinggi              bool `gorm:"column:anamnesis_hipertensi_kronik_tinggi" json:"anamnesis_hipertensi_kronik_tinggi"`
	AnamnesisPenyakitGinjalTinggi                bool `gorm:"column:anamnesis_penyakit_ginjal_tinggi" json:"anamnesis_penyakit_ginjal_tinggi"`
	AnamnesisPenyakitAutoimunSLETinggi           bool `gorm:"column:anamnesis_penyakit_autoimun_sle_tinggi" json:"anamnesis_penyakit_autoimun_sle_tinggi"`
	AnamnesisAntiPhospholipidSyndromeTinggi      bool `gorm:"column:anamnesis_anti_phospholipid_syndrome_tinggi" json:"anamnesis_anti_phospholipid_syndrome_tinggi"`

	FisikMAPDiatas90mmHg           bool   `gorm:"column:fisik_map_diatas90mm_hg" json:"fisik_map_diatas_90_mmhg"`
	FisikProteinuriaUrinCelup      bool   `gorm:"column:fisik_proteinuria_urin_celup" json:"fisik_proteinuria_urin_celup"`
	KesimpulanSkriningPreeklampsia string `gorm:"column:kesimpulan_skrining_preeklampsia" json:"kesimpulan_skrining_preeklampsia"`
}

func (SkriningPreeklampsia) TableName() string {
	return "skrining_preeklampsia"
}
