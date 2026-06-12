// package controllers

// import (
// 	"monitoring-service/app/usecases"
// 	"monitoring-service/pkg/customerror"
// 	"net/http"
// 	"strconv"

// 	"github.com/labstack/echo/v4"
// )

// type PemeriksaanDokterCombinedController struct {
// 	usecaseT1 usecases.PemeriksaanDokterTrimester1Usecase
// 	usecaseT3 usecases.PemeriksaanDokterTrimester3Usecase
// }

// func NewPemeriksaanDokterCombinedController(
// 	u1 usecases.PemeriksaanDokterTrimester1Usecase,
// 	u3 usecases.PemeriksaanDokterTrimester3Usecase,
// ) *PemeriksaanDokterCombinedController {
// 	return &PemeriksaanDokterCombinedController{
// 		usecaseT1: u1,
// 		usecaseT3: u3,
// 	}
// }

// // T1 Complete
// func (c *PemeriksaanDokterCombinedController) CreateT1(ctx echo.Context) error {
// 	var req usecases.PemeriksaanDokterTrimester1Request
// 	if err := ctx.Bind(&req); err != nil {
// 		return ctx.JSON(http.StatusBadRequest, map[string]string{"message": "format request tidak valid: " + err.Error()})
// 	}
// 	if err := c.usecaseT1.Create(&req); err != nil {
// 		statusCode := customerror.GetStatusCode(err)
// 		return ctx.JSON(statusCode, map[string]string{"message": err.Error()})
// 	}
// 	return ctx.JSON(http.StatusCreated, map[string]interface{}{
// 		"status_code": http.StatusCreated,
// 		"message":     "Data pemeriksaan dokter trimester 1 & lab jiwa berhasil disimpan",
// 	})
// }

// func (c *PemeriksaanDokterCombinedController) UpdateT1(ctx echo.Context) error {
// 	id, err := strconv.ParseInt(ctx.Param("id"), 10, 32)
// 	if err != nil {
// 		return ctx.JSON(http.StatusBadRequest, map[string]string{"message": "id tidak valid"})
// 	}
// 	var req usecases.PemeriksaanDokterTrimester1Request
// 	if err := ctx.Bind(&req); err != nil {
// 		return ctx.JSON(http.StatusBadRequest, map[string]string{"message": "format request tidak valid: " + err.Error()})
// 	}
// 	if err := c.usecaseT1.Update(int32(id), &req); err != nil {
// 		statusCode := customerror.GetStatusCode(err)
// 		return ctx.JSON(statusCode, map[string]string{"message": err.Error()})
// 	}
// 	return ctx.JSON(http.StatusOK, map[string]interface{}{
// 		"status_code": http.StatusOK,
// 		"message":     "Data berhasil diperbarui",
// 	})
// }

// func (c *PemeriksaanDokterCombinedController) GetT1ByID(ctx echo.Context) error {
// 	id, err := strconv.ParseInt(ctx.Param("id"), 10, 32)
// 	if err != nil {
// 		return ctx.JSON(http.StatusBadRequest, map[string]string{"message": "id tidak valid"})
// 	}
// 	data, err := c.usecaseT1.GetByID(int32(id))
// 	if err != nil {
// 		statusCode := customerror.GetStatusCode(err)
// 		return ctx.JSON(statusCode, map[string]string{"message": err.Error()})
// 	}
// 	return ctx.JSON(http.StatusOK, data)
// }

// func (c *PemeriksaanDokterCombinedController) GetT1ByKehamilan(ctx echo.Context) error {
// 	kehamilanID, err := strconv.ParseInt(ctx.QueryParam("kehamilan_id"), 10, 32)
// 	if err != nil {
// 		return ctx.JSON(http.StatusBadRequest, map[string]string{"message": "kehamilan_id required"})
// 	}
// 	list, err := c.usecaseT1.GetByKehamilanID(int32(kehamilanID))
// 	if err != nil {
// 		statusCode := customerror.GetStatusCode(err)
// 		return ctx.JSON(statusCode, map[string]string{"message": err.Error()})
// 	}

// 	// Jika tidak ada data, return dengan struktur kosong
// 	if len(list) == 0 {
// 		return ctx.JSON(http.StatusOK, map[string]interface{}{
// 			"dokter":   nil,
// 			"lab_jiwa": nil,
// 		})
// 	}

// 	// Return hanya data pertama dengan struktur yang sesuai frontend
// 	firstData := list[0]
// 	return ctx.JSON(http.StatusOK, map[string]interface{}{
// 		"dokter":   firstData.Dokter,
// 		"lab_jiwa": firstData.Lab,
// 	})
// }

// func (c *PemeriksaanDokterCombinedController) DeleteT1(ctx echo.Context) error {
// 	id, err := strconv.ParseInt(ctx.Param("id"), 10, 32)
// 	if err != nil {
// 		return ctx.JSON(http.StatusBadRequest, map[string]string{"message": "id tidak valid"})
// 	}
// 	if err := c.usecaseT1.Delete(int32(id)); err != nil {
// 		statusCode := customerror.GetStatusCode(err)
// 		return ctx.JSON(statusCode, map[string]string{"message": err.Error()})
// 	}
// 	return ctx.JSON(http.StatusOK, map[string]string{"message": "Data berhasil dihapus"})
// }

// // T3 Complete (opsional, analog)
// func (c *PemeriksaanDokterCombinedController) CreateT3(ctx echo.Context) error {
// 	var req usecases.PemeriksaanDokterTrimester3Request
// 	if err := ctx.Bind(&req); err != nil {
// 		return ctx.JSON(http.StatusBadRequest, map[string]string{"message": "format request tidak valid: " + err.Error()})
// 	}
// 	if err := c.usecaseT3.Create(&req); err != nil {
// 		statusCode := customerror.GetStatusCode(err)
// 		return ctx.JSON(statusCode, map[string]string{"message": err.Error()})
// 	}
// 	return ctx.JSON(http.StatusCreated, map[string]interface{}{
// 		"status_code": http.StatusCreated,
// 		"message":     "Data pemeriksaan dokter trimester 3 & lanjutan berhasil disimpan",
// 	})
// }

// func (c *PemeriksaanDokterCombinedController) UpdateT3(ctx echo.Context) error {
// 	id, err := strconv.ParseInt(ctx.Param("id"), 10, 32)
// 	if err != nil {
// 		return ctx.JSON(http.StatusBadRequest, map[string]string{"message": "id tidak valid"})
// 	}
// 	var req usecases.PemeriksaanDokterTrimester3Request
// 	if err := ctx.Bind(&req); err != nil {
// 		return ctx.JSON(http.StatusBadRequest, map[string]string{"message": "format request tidak valid: " + err.Error()})
// 	}
// 	if err := c.usecaseT3.Update(int32(id), &req); err != nil {
// 		statusCode := customerror.GetStatusCode(err)
// 		return ctx.JSON(statusCode, map[string]string{"message": err.Error()})
// 	}
// 	return ctx.JSON(http.StatusOK, map[string]interface{}{
// 		"status_code": http.StatusOK,
// 		"message":     "Data berhasil diperbarui",
// 	})
// }

// func (c *PemeriksaanDokterCombinedController) GetT3ByID(ctx echo.Context) error {
// 	id, err := strconv.ParseInt(ctx.Param("id"), 10, 32)
// 	if err != nil {
// 		return ctx.JSON(http.StatusBadRequest, map[string]string{"message": "id tidak valid"})
// 	}
// 	data, err := c.usecaseT3.GetByID(int32(id))
// 	if err != nil {
// 		statusCode := customerror.GetStatusCode(err)
// 		return ctx.JSON(statusCode, map[string]string{"message": err.Error()})
// 	}
// 	return ctx.JSON(http.StatusOK, data)
// }

// func (c *PemeriksaanDokterCombinedController) GetT3ByKehamilan(ctx echo.Context) error {
// 	kehamilanID, err := strconv.ParseInt(ctx.QueryParam("kehamilan_id"), 10, 32)
// 	if err != nil {
// 		return ctx.JSON(http.StatusBadRequest, map[string]string{"message": "kehamilan_id required"})
// 	}
// 	list, err := c.usecaseT3.GetByKehamilanID(int32(kehamilanID))
// 	if err != nil {
// 		statusCode := customerror.GetStatusCode(err)
// 		return ctx.JSON(statusCode, map[string]string{"message": err.Error()})
// 	}

// 	// Jika tidak ada data, return dengan struktur kosong
// 	if len(list) == 0 {
// 		return ctx.JSON(http.StatusOK, map[string]interface{}{
// 			"dokter":   nil,
// 			"lab_jiwa": nil,
// 		})
// 	}

// 	// Return hanya data pertama dengan struktur yang sesuai frontend
// 	firstData := list[0]
// 	return ctx.JSON(http.StatusOK, map[string]interface{}{
// 		"dokter":   firstData.Dokter,
// 		"lab_jiwa": firstData.Lab,
// 	})
// }

// func (c *PemeriksaanDokterCombinedController) DeleteT3(ctx echo.Context) error {
// 	id, err := strconv.ParseInt(ctx.Param("id"), 10, 32)
// 	if err != nil {
// 		return ctx.JSON(http.StatusBadRequest, map[string]string{"message": "id tidak valid"})
// 	}
// 	if err := c.usecaseT3.Delete(int32(id)); err != nil {
// 		statusCode := customerror.GetStatusCode(err)
// 		return ctx.JSON(statusCode, map[string]string{"message": err.Error()})
// 	}
// 	return ctx.JSON(http.StatusOK, map[string]string{"message": "Data berhasil dihapus"})
// }

package controllers

import (
	"monitoring-service/app/models" // Ditambahkan
	"monitoring-service/app/usecases"
	"monitoring-service/pkg/customerror"
	"net/http"
	"strconv"
	"time"

	"github.com/labstack/echo/v4"
)

// ── Request DTO untuk T1 (string tanggal + lab jiwa dalam satu payload) ──
type createT1Request struct {
	KehamilanID               int32  `json:"kehamilan_id"`
	NamaDokter                string `json:"nama_dokter"`
	TanggalPeriksa            string `json:"tanggal_periksa"`
	KonsepAnamnesaPemeriksaan string `json:"konsep_anamnesa_pemeriksaan"`
	GambarUSG                 string `json:"gambar_usg"`

	FisikKonjungtiva string `json:"fisik_konjungtiva"`
	FisikSklera      string `json:"fisik_sklera"`
	FisikKulit       string `json:"fisik_kulit"`
	FisikLeher       string `json:"fisik_leher"`
	FisikGigiMulut   string `json:"fisik_gigi_mulut"`
	FisikTHT         string `json:"fisik_tht"`
	FisikDadaJantung string `json:"fisik_dada_jantung"`
	FisikDadaParu    string `json:"fisik_dada_paru"`
	FisikPerut       string `json:"fisik_perut"`
	FisikTungkai     string `json:"fisik_tungkai"`

	HPHT                string `json:"hpht"`
	KeteraturanHaid     string `json:"keteraturan_haid"`
	UmurHamilHPHTMinggu *int   `json:"umur_hamil_hpht_minggu"`
	HPLBerdasarkanHPHT  string `json:"hpl_berdasarkan_hpht"`
	UmurHamilUSGMinggu  *int   `json:"umur_hamil_usg_minggu"`
	HPLBerdasarkanUSG   string `json:"hpl_berdasarkan_usg"`

	USGJumlahGS                 string   `json:"usg_jumlah_gs"`
	USGDiameterGS_cm            *float64 `json:"usg_diameter_gs_cm"`
	USGDiameterGSMinggu         *int     `json:"usg_diameter_gs_minggu"`
	USGDiameterGSHari           *int     `json:"usg_diameter_gs_hari"`
	USGJumlahBayi               string   `json:"usg_jumlah_bayi"`
	USGCRL_cm                   *float64 `json:"usg_crl_cm"`
	USGCRLMinggu                *int     `json:"usg_crl_minggu"`
	USGCRLHari                  *int     `json:"usg_crl_hari"`
	USGLetakProdukKehamilan     string   `json:"usg_letak_produk_kehamilan"`
	USGPulsasiJantung           string   `json:"usg_pulsasi_jantung"`
	USGKecurigaanTemuanAbnormal string   `json:"usg_kecurigaan_temuan_abnormal"`
	USGKeteranganTemuanAbnormal string   `json:"usg_keterangan_temuan_abnormal"`

	TanggalLab                            string   `json:"tanggal_lab"`
	LabHemoglobinHasil                    *float64 `json:"lab_hemoglobin_hasil"`
	LabHemoglobinRencanaTindakLanjut      string   `json:"lab_hemoglobin_rencana_tindak_lanjut"`
	LabGolonganDarahRhesusHasil           string   `json:"lab_golongan_darah_rhesus_hasil"`
	LabGolonganDarahRhesusRencana         string   `json:"lab_golongan_darah_rhesus_rencana_tindak_lanjut"`
	LabGulaDarahSewaktuHasil              *int     `json:"lab_gula_darah_sewaktu_hasil"`
	LabGulaDarahSewaktuRencana            string   `json:"lab_gula_darah_sewaktu_rencana_tindak_lanjut"`
	LabHIVHasil                           string   `json:"lab_hiv_hasil"`
	LabHIVRencana                         string   `json:"lab_hiv_rencana_tindak_lanjut"`
	LabSifilisHasil                       string   `json:"lab_sifilis_hasil"`
	LabSifilisRencana                     string   `json:"lab_sifilis_rencana_tindak_lanjut"`
	LabHepatitisBHasil                    string   `json:"lab_hepatitis_b_hasil"`
	LabHepatitisBRencana                  string   `json:"lab_hepatitis_b_rencana_tindak_lanjut"`
	TanggalSkriningJiwa                   string   `json:"tanggal_skrining_jiwa"`
	SkriningJiwaHasil                     string   `json:"skrining_jiwa_hasil"`
	SkriningJiwaTindakLanjut              string   `json:"skrining_jiwa_tindak_lanjut"`
	SkriningJiwaPerluRujukan              string   `json:"skrining_jiwa_perlu_rujukan"`
	Kesimpulan                            string   `json:"kesimpulan"`
	Rekomendasi                           string   `json:"rekomendasi"`
}

func computeHPLFromHPHT(hpht *time.Time) *time.Time {
	if hpht == nil {
		return nil
	}
	hpl := hpht.AddDate(0, 0, 280)
	return &hpl
}

func mapT1RequestToDokter(req *createT1Request) *models.PemeriksaanDokterTrimester1 {
	today := time.Now()
	tanggalPeriksa := parseDate(req.TanggalPeriksa)
	if tanggalPeriksa == nil {
		tanggalPeriksa = &today
	}

	hpht := parseDate(req.HPHT)
	hplHPHT := parseDate(req.HPLBerdasarkanHPHT)
	if hplHPHT == nil && hpht != nil {
		hplHPHT = computeHPLFromHPHT(hpht)
	}

	dokter := &models.PemeriksaanDokterTrimester1{
		KehamilanID:                 req.KehamilanID,
		NamaDokter:                  req.NamaDokter,
		TanggalPeriksa:              tanggalPeriksa,
		KonsepAnamnesaPemeriksaan:   req.KonsepAnamnesaPemeriksaan,
		GambarUSG:                   req.GambarUSG,
		FisikKonjungtiva:            req.FisikKonjungtiva,
		FisikSklera:                 req.FisikSklera,
		FisikKulit:                  req.FisikKulit,
		FisikLeher:                  req.FisikLeher,
		FisikGigiMulut:              req.FisikGigiMulut,
		FisikTHT:                    req.FisikTHT,
		FisikDadaJantung:            req.FisikDadaJantung,
		FisikDadaParu:               req.FisikDadaParu,
		FisikPerut:                  req.FisikPerut,
		FisikTungkai:                req.FisikTungkai,
		HPHT:                        hpht,
		KeteraturanHaid:             req.KeteraturanHaid,
		UmurHamilHPHTMinggu:         req.UmurHamilHPHTMinggu,
		HPLBerdasarkanHPHT:          hplHPHT,
		UmurHamilUSGMinggu:          req.UmurHamilUSGMinggu,
		HPLBerdasarkanUSG:           parseDate(req.HPLBerdasarkanUSG),
		USGJumlahGS:                 req.USGJumlahGS,
		USGDiameterGS_cm:            req.USGDiameterGS_cm,
		USGDiameterGSMinggu:         req.USGDiameterGSMinggu,
		USGDiameterGSHari:           req.USGDiameterGSHari,
		USGJumlahBayi:               req.USGJumlahBayi,
		USGCRL_cm:                   req.USGCRL_cm,
		USGCRLMinggu:                req.USGCRLMinggu,
		USGCRLHari:                  req.USGCRLHari,
		USGLetakProdukKehamilan:     req.USGLetakProdukKehamilan,
		USGPulsasiJantung:           req.USGPulsasiJantung,
		USGKecurigaanTemuanAbnormal: req.USGKecurigaanTemuanAbnormal,
		USGKeteranganTemuanAbnormal: req.USGKeteranganTemuanAbnormal,
	}
	return dokter
}

func mapT1RequestToLab(req *createT1Request) *models.PemeriksaanLaboratoriumJiwa {
	hasLab := req.LabHemoglobinHasil != nil ||
		req.LabGulaDarahSewaktuHasil != nil ||
		req.LabGolonganDarahRhesusHasil != "" ||
		req.LabHIVHasil != "" ||
		req.LabSifilisHasil != "" ||
		req.LabHepatitisBHasil != "" ||
		req.SkriningJiwaHasil != "" ||
		req.Kesimpulan != "" ||
		req.Rekomendasi != "" ||
		req.TanggalLab != "" ||
		req.TanggalSkriningJiwa != ""

	if !hasLab {
		return nil
	}

	today := time.Now()
	tanggalLab := parseDate(req.TanggalLab)
	if tanggalLab == nil {
		tanggalLab = &today
	}

	lab := &models.PemeriksaanLaboratoriumJiwa{
		Trimester:                        1,
		TanggalLab:                       tanggalLab,
		LabHemoglobinHasil:               req.LabHemoglobinHasil,
		LabHemoglobinRencanaTindakLanjut: req.LabHemoglobinRencanaTindakLanjut,
		LabGolonganDarahRhesusHasil:      req.LabGolonganDarahRhesusHasil,
		LabGolonganDarahRhesusRencana:    req.LabGolonganDarahRhesusRencana,
		LabGulaDarahSewaktuHasil:         req.LabGulaDarahSewaktuHasil,
		LabGulaDarahSewaktuRencana:       req.LabGulaDarahSewaktuRencana,
		LabHIVHasil:                      req.LabHIVHasil,
		LabHIVRencana:                    req.LabHIVRencana,
		LabSifilisHasil:                  req.LabSifilisHasil,
		LabSifilisRencana:                req.LabSifilisRencana,
		LabHepatitisBHasil:               req.LabHepatitisBHasil,
		LabHepatitisBRencana:             req.LabHepatitisBRencana,
		SkriningJiwaHasil:                req.SkriningJiwaHasil,
		SkriningJiwaTindakLanjut:         req.SkriningJiwaTindakLanjut,
		SkriningJiwaPerluRujukan:         req.SkriningJiwaPerluRujukan,
		Kesimpulan:                       req.Kesimpulan,
		Rekomendasi:                      req.Rekomendasi,
	}

	if req.TanggalSkriningJiwa != "" {
		lab.TanggalSkriningJiwa = parseDate(req.TanggalSkriningJiwa)
	} else if req.SkriningJiwaHasil != "" {
		lab.TanggalSkriningJiwa = &today
	}

	return lab
}

// ── Request DTO untuk T3 (menggunakan string untuk tanggal agar tidak error parse RFC3339) ──
type createT3Request struct {
	KehamilanID               int32  `json:"kehamilan_id"`
	NamaDokter                string `json:"nama_dokter"`
	TanggalPeriksa            string `json:"tanggal_periksa"`
	KonsepAnamnesaPemeriksaan string `json:"konsep_anamnesa_pemeriksaan"`
	GambarUSG                 string `json:"gambar_usg"`

	FisikKonjungtiva string `json:"fisik_konjungtiva"`
	FisikSklera      string `json:"fisik_sklera"`
	FisikKulit       string `json:"fisik_kulit"`
	FisikLeher       string `json:"fisik_leher"`
	FisikGigiMulut   string `json:"fisik_gigi_mulut"`
	FisikTHT         string `json:"fisik_tht"`
	FisikDadaJantung string `json:"fisik_dada_jantung"`
	FisikDadaParu    string `json:"fisik_dada_paru"`
	FisikPerut       string `json:"fisik_perut"`
	FisikTungkai     string `json:"fisik_tungkai"`

	USGTrimester3Dilakukan                   string   `json:"usg_trimester_3_dilakukan"`
	UKBerdasarkanUSGTrimester1Minggu         *int     `json:"uk_berdasarkan_usg_trimester_1_minggu"`
	UKBerdasarkanHPHTMinggu                  *int     `json:"uk_berdasarkan_hpht_minggu"`
	UKBerdasarkanBiometriUSGTrimester3Minggu *int     `json:"uk_berdasarkan_biometri_usg_trimester_3_minggu"`
	SelisihUK3MingguAtauLebih                string   `json:"selisih_uk_3_minggu_atau_lebih"`
	USGJumlahBayi                            string   `json:"usg_jumlah_bayi"`
	USGLetakBayi                             string   `json:"usg_letak_bayi"`
	USGPresentasiBayi                        string   `json:"usg_presentasi_bayi"`
	USGKeadaanBayi                           string   `json:"usg_keadaan_bayi"`
	USGDJNilai                               *int     `json:"usg_djj_nilai"`
	USGDJJStatus                             string   `json:"usg_djj_status"`
	USGLokasiPlasenta                        string   `json:"usg_lokasi_plasenta"`
	USGCairanKetubanSDPCm                    *float64 `json:"usg_cairan_ketuban_sdp_cm"`
	USGCairanKetubanStatus                   string   `json:"usg_cairan_ketuban_status"`

	BiometriBPDCm        *float64 `json:"biometri_bpd_cm"`
	BiometriBPDMinggu    *int     `json:"biometri_bpd_minggu"`
	BiometriHCCm         *float64 `json:"biometri_hc_cm"`
	BiometriHCMinggu     *int     `json:"biometri_hc_minggu"`
	BiometriACCm         *float64 `json:"biometri_ac_cm"`
	BiometriACMinggu     *int     `json:"biometri_ac_minggu"`
	BiometriFLCm         *float64 `json:"biometri_fl_cm"`
	BiometriFLMinggu     *int     `json:"biometri_fl_minggu"`
	BiometriEFWTBJGram   *int     `json:"biometri_efw_tbj_gram"`
	BiometriEFWTBJMinggu *int     `json:"biometri_efw_tbj_minggu"`

	USGKecurigaanTemuanAbnormal string `json:"usg_kecurigaan_temuan_abnormal"`
	USGKeteranganTemuanAbnormal string `json:"usg_keterangan_temuan_abnormal"`

	// Lanjutan T3
	HasilUSGCatatan                       string   `json:"hasil_usg_catatan"`
	TanggalLab                            string   `json:"tanggal_lab"`
	LabHemoglobinHasil                    *float64 `json:"lab_hemoglobin_hasil"`
	LabHemoglobinRencana                  string   `json:"lab_hemoglobin_rencana_tindak_lanjut"`
	LabProteinUrinHasil                   *int     `json:"lab_protein_urin_hasil"`
	LabProteinUrinRencana                 string   `json:"lab_protein_urin_rencana_tindak_lanjut"`
	LabUrinReduksiHasil                   string   `json:"lab_urin_reduksi_hasil"`
	LabUrinReduksiRencana                 string   `json:"lab_urin_reduksi_rencana_tindak_lanjut"`
	TanggalSkriningJiwa                   string   `json:"tanggal_skrining_jiwa"`
	SkriningJiwaHasil                     string   `json:"skrining_jiwa_hasil"`
	SkriningJiwaTindakLanjut              string   `json:"skrining_jiwa_tindak_lanjut"`
	SkriningJiwaPerluRujukan              string   `json:"skrining_jiwa_perlu_rujukan"`
	RencanaKonsultasiGizi                 bool     `json:"rencana_konsultasi_gizi"`
	RencanaKonsultasiKebidanan            bool     `json:"rencana_konsultasi_kebidanan"`
	RencanaKonsultasiAnak                 bool     `json:"rencana_konsultasi_anak"`
	RencanaKonsultasiPenyakitDalam        bool     `json:"rencana_konsultasi_penyakit_dalam"`
	RencanaKonsultasiNeurologi            bool     `json:"rencana_konsultasi_neurologi"`
	RencanaKonsultasiTHT                  bool     `json:"rencana_konsultasi_tht"`
	RencanaKonsultasiPsikiatri            bool     `json:"rencana_konsultasi_psikiatri"`
	RencanaKonsultasiLainLain             string   `json:"rencana_konsultasi_lain_lain"`
	RencanaProsesMelahirkan               string   `json:"rencana_proses_melahirkan"`
	RencanaKontrasepsiAKDR                bool     `json:"rencana_kontrasepsi_akdr"`
	RencanaKontrasepsiPil                 bool     `json:"rencana_kontrasepsi_pil"`
	RencanaKontrasepsiSuntik              bool     `json:"rencana_kontrasepsi_suntik"`
	RencanaKontrasepsiSteril              bool     `json:"rencana_kontrasepsi_steril"`
	RencanaKontrasepsiMAL                 bool     `json:"rencana_kontrasepsi_mal"`
	RencanaKontrasepsiImplan              bool     `json:"rencana_kontrasepsi_implan"`
	RencanaKontrasepsiBelumMemilih        bool     `json:"rencana_kontrasepsi_belum_memilih"`
	KebutuhanKonseling                    string   `json:"kebutuhan_konseling"`
	Penjelasan                            string   `json:"penjelasan"`
	KesimpulanRekomendasiTempatMelahirkan string   `json:"kesimpulan_rekomendasi_tempat_melahirkan"`
}

// parseDate mem-parse string "YYYY-MM-DD" (atau RFC3339) menjadi *time.Time
func parseDate(s string) *time.Time {
	if s == "" {
		return nil
	}
	// coba YYYY-MM-DD dulu
	if t, err := time.Parse("2006-01-02", s); err == nil {
		return &t
	}
	// fallback RFC3339
	if t, err := time.Parse(time.RFC3339, s); err == nil {
		return &t
	}
	return nil
}

// mapT3RequestToModel mengkonversi DTO ke model
func mapT3RequestToModel(req *createT3Request) *models.PemeriksaanDokterTrimester3 {
	return &models.PemeriksaanDokterTrimester3{
		KehamilanID:                              req.KehamilanID,
		NamaDokter:                               req.NamaDokter,
		TanggalPeriksa:                           parseDate(req.TanggalPeriksa),
		KonsepAnamnesaPemeriksaan:                req.KonsepAnamnesaPemeriksaan,
		GambarUSG:                                req.GambarUSG,
		FisikKonjungtiva:                         req.FisikKonjungtiva,
		FisikSklera:                              req.FisikSklera,
		FisikKulit:                               req.FisikKulit,
		FisikLeher:                               req.FisikLeher,
		FisikGigiMulut:                           req.FisikGigiMulut,
		FisikTHT:                                 req.FisikTHT,
		FisikDadaJantung:                         req.FisikDadaJantung,
		FisikDadaParu:                            req.FisikDadaParu,
		FisikPerut:                               req.FisikPerut,
		FisikTungkai:                             req.FisikTungkai,
		USGTrimester3Dilakukan:                   req.USGTrimester3Dilakukan,
		UKBerdasarkanUSGTrimester1Minggu:         req.UKBerdasarkanUSGTrimester1Minggu,
		UKBerdasarkanHPHTMinggu:                  req.UKBerdasarkanHPHTMinggu,
		UKBerdasarkanBiometriUSGTrimester3Minggu: req.UKBerdasarkanBiometriUSGTrimester3Minggu,
		SelisihUK3MingguAtauLebih:                req.SelisihUK3MingguAtauLebih,
		USGJumlahBayi:                            req.USGJumlahBayi,
		USGLetakBayi:                             req.USGLetakBayi,
		USGPresentasiBayi:                        req.USGPresentasiBayi,
		USGKeadaanBayi:                           req.USGKeadaanBayi,
		USGDJNilai:                               req.USGDJNilai,
		USGDJJStatus:                             req.USGDJJStatus,
		USGLokasiPlasenta:                        req.USGLokasiPlasenta,
		USGCairanKetubanSDPCm:                    req.USGCairanKetubanSDPCm,
		USGCairanKetubanStatus:                   req.USGCairanKetubanStatus,
		BiometriBPDCm:                            req.BiometriBPDCm,
		BiometriBPDMinggu:                        req.BiometriBPDMinggu,
		BiometriHCCm:                             req.BiometriHCCm,
		BiometriHCMinggu:                         req.BiometriHCMinggu,
		BiometriACCm:                             req.BiometriACCm,
		BiometriACMinggu:                         req.BiometriACMinggu,
		BiometriFLCm:                             req.BiometriFLCm,
		BiometriFLMinggu:                         req.BiometriFLMinggu,
		BiometriEFWTBJGram:                       req.BiometriEFWTBJGram,
		BiometriEFWTBJMinggu:                     req.BiometriEFWTBJMinggu,
		USGKecurigaanTemuanAbnormal:              req.USGKecurigaanTemuanAbnormal,
		USGKeteranganTemuanAbnormal:              req.USGKeteranganTemuanAbnormal,
		HasilUSGCatatan:                          req.HasilUSGCatatan,
		TanggalLab:                               parseDate(req.TanggalLab),
		LabHemoglobinHasil:                       req.LabHemoglobinHasil,
		LabHemoglobinRencana:                     req.LabHemoglobinRencana,
		LabProteinUrinHasil:                      req.LabProteinUrinHasil,
		LabProteinUrinRencana:                    req.LabProteinUrinRencana,
		LabUrinReduksiHasil:                      req.LabUrinReduksiHasil,
		LabUrinReduksiRencana:                    req.LabUrinReduksiRencana,
		TanggalSkriningJiwa:                      parseDate(req.TanggalSkriningJiwa),
		SkriningJiwaHasil:                        req.SkriningJiwaHasil,
		SkriningJiwaTindakLanjut:                 req.SkriningJiwaTindakLanjut,
		SkriningJiwaPerluRujukan:                 req.SkriningJiwaPerluRujukan,
		RencanaKonsultasiGizi:                    req.RencanaKonsultasiGizi,
		RencanaKonsultasiKebidanan:               req.RencanaKonsultasiKebidanan,
		RencanaKonsultasiAnak:                    req.RencanaKonsultasiAnak,
		RencanaKonsultasiPenyakitDalam:           req.RencanaKonsultasiPenyakitDalam,
		RencanaKonsultasiNeurologi:               req.RencanaKonsultasiNeurologi,
		RencanaKonsultasiTHT:                     req.RencanaKonsultasiTHT,
		RencanaKonsultasiPsikiatri:               req.RencanaKonsultasiPsikiatri,
		RencanaKonsultasiLainLain:                req.RencanaKonsultasiLainLain,
		RencanaProsesMelahirkan:                  req.RencanaProsesMelahirkan,
		RencanaKontrasepsiAKDR:                   req.RencanaKontrasepsiAKDR,
		RencanaKontrasepsiPil:                    req.RencanaKontrasepsiPil,
		RencanaKontrasepsiSuntik:                 req.RencanaKontrasepsiSuntik,
		RencanaKontrasepsiSteril:                 req.RencanaKontrasepsiSteril,
		RencanaKontrasepsiMAL:                    req.RencanaKontrasepsiMAL,
		RencanaKontrasepsiImplan:                 req.RencanaKontrasepsiImplan,
		RencanaKontrasepsiBelumMemilih:           req.RencanaKontrasepsiBelumMemilih,
		KebutuhanKonseling:                       req.KebutuhanKonseling,
		Penjelasan:                               req.Penjelasan,
		KesimpulanRekomendasiTempatMelahirkan:    req.KesimpulanRekomendasiTempatMelahirkan,
	}
}

type PemeriksaanDokterCombinedController struct {
	usecaseT1 usecases.PemeriksaanDokterTrimester1Usecase
	usecaseT3 usecases.PemeriksaanDokterTrimester3Usecase
}

func NewPemeriksaanDokterCombinedController(
	u1 usecases.PemeriksaanDokterTrimester1Usecase,
	u3 usecases.PemeriksaanDokterTrimester3Usecase,
) *PemeriksaanDokterCombinedController {
	return &PemeriksaanDokterCombinedController{
		usecaseT1: u1,
		usecaseT3: u3,
	}
}

// T1 Complete
func (c *PemeriksaanDokterCombinedController) CreateT1(ctx echo.Context) error {
	var req createT1Request
	if err := ctx.Bind(&req); err != nil {
		return ctx.JSON(http.StatusBadRequest, map[string]string{"message": "format request tidak valid: " + err.Error()})
	}
	dokter := mapT1RequestToDokter(&req)
	lab := mapT1RequestToLab(&req)
	if err := c.usecaseT1.CreateWithLab(dokter, lab); err != nil {
		statusCode := customerror.GetStatusCode(err)
		return ctx.JSON(statusCode, map[string]string{"message": err.Error()})
	}
	return ctx.JSON(http.StatusCreated, map[string]interface{}{
		"status_code": http.StatusCreated,
		"message":     "Data pemeriksaan dokter trimester 1 & lab jiwa berhasil disimpan",
		"dokter":      dokter,
		"lab_jiwa":    lab,
	})
}

func (c *PemeriksaanDokterCombinedController) UpdateT1(ctx echo.Context) error {
	id, err := strconv.ParseInt(ctx.Param("id"), 10, 32)
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, map[string]string{"message": "id tidak valid"})
	}
	var req createT1Request
	if err := ctx.Bind(&req); err != nil {
		return ctx.JSON(http.StatusBadRequest, map[string]string{"message": "format request tidak valid: " + err.Error()})
	}
	dokter := mapT1RequestToDokter(&req)
	lab := mapT1RequestToLab(&req)
	if err := c.usecaseT1.UpdateWithLab(int32(id), dokter, lab); err != nil {
		statusCode := customerror.GetStatusCode(err)
		return ctx.JSON(statusCode, map[string]string{"message": err.Error()})
	}
	return ctx.JSON(http.StatusOK, map[string]interface{}{
		"status_code": http.StatusOK,
		"message":     "Data berhasil diperbarui",
		"dokter":      dokter,
		"lab_jiwa":    lab,
	})
}

func (c *PemeriksaanDokterCombinedController) GetT1ByID(ctx echo.Context) error {
	id, err := strconv.ParseInt(ctx.Param("id"), 10, 32)
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, map[string]string{"message": "id tidak valid"})
	}
	data, err := c.usecaseT1.GetByID(int32(id))
	if err != nil {
		statusCode := customerror.GetStatusCode(err)
		return ctx.JSON(statusCode, map[string]string{"message": err.Error()})
	}
	lab, _ := c.usecaseT1.GetLabByKehamilanID(data.KehamilanID)
	return ctx.JSON(http.StatusOK, map[string]interface{}{
		"dokter":   data,
		"lab_jiwa": lab,
	})
}

func (c *PemeriksaanDokterCombinedController) GetT1ByKehamilan(ctx echo.Context) error {
	kehamilanID, err := strconv.ParseInt(ctx.QueryParam("kehamilan_id"), 10, 32)
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, map[string]string{"message": "kehamilan_id required"})
	}
	list, err := c.usecaseT1.GetByKehamilanID(int32(kehamilanID))
	if err != nil {
		statusCode := customerror.GetStatusCode(err)
		return ctx.JSON(statusCode, map[string]string{"message": err.Error()})
	}

	if len(list) == 0 {
		return ctx.JSON(http.StatusOK, map[string]interface{}{
			"dokter":   nil,
			"lab_jiwa": nil,
		})
	}

	firstData := list[0]
	lab, _ := c.usecaseT1.GetLabByKehamilanID(int32(kehamilanID))
	return ctx.JSON(http.StatusOK, map[string]interface{}{
		"dokter":   firstData,
		"lab_jiwa": lab,
	})
}

func (c *PemeriksaanDokterCombinedController) DeleteT1(ctx echo.Context) error {
	id, err := strconv.ParseInt(ctx.Param("id"), 10, 32)
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, map[string]string{"message": "id tidak valid"})
	}
	if err := c.usecaseT1.Delete(int32(id)); err != nil {
		statusCode := customerror.GetStatusCode(err)
		return ctx.JSON(statusCode, map[string]string{"message": err.Error()})
	}
	return ctx.JSON(http.StatusOK, map[string]string{"message": "Data berhasil dihapus"})
}

// T3 Complete
func (c *PemeriksaanDokterCombinedController) CreateT3(ctx echo.Context) error {
	var req createT3Request
	if err := ctx.Bind(&req); err != nil {
		return ctx.JSON(http.StatusBadRequest, map[string]string{"message": "format request tidak valid: " + err.Error()})
	}
	model := mapT3RequestToModel(&req)
	if err := c.usecaseT3.Create(model); err != nil {
		statusCode := customerror.GetStatusCode(err)
		return ctx.JSON(statusCode, map[string]string{"message": err.Error()})
	}
	return ctx.JSON(http.StatusCreated, map[string]interface{}{
		"status_code": http.StatusCreated,
		"message":     "Data pemeriksaan dokter trimester 3 & lanjutan berhasil disimpan",
	})
}

func (c *PemeriksaanDokterCombinedController) UpdateT3(ctx echo.Context) error {
	id, err := strconv.ParseInt(ctx.Param("id"), 10, 32)
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, map[string]string{"message": "id tidak valid"})
	}
	var req createT3Request
	if err := ctx.Bind(&req); err != nil {
		return ctx.JSON(http.StatusBadRequest, map[string]string{"message": "format request tidak valid: " + err.Error()})
	}
	model := mapT3RequestToModel(&req)
	if err := c.usecaseT3.Update(int32(id), model); err != nil {
		statusCode := customerror.GetStatusCode(err)
		return ctx.JSON(statusCode, map[string]string{"message": err.Error()})
	}
	return ctx.JSON(http.StatusOK, map[string]interface{}{
		"status_code": http.StatusOK,
		"message":     "Data berhasil diperbarui",
	})
}

func (c *PemeriksaanDokterCombinedController) GetT3ByID(ctx echo.Context) error {
	id, err := strconv.ParseInt(ctx.Param("id"), 10, 32)
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, map[string]string{"message": "id tidak valid"})
	}
	data, err := c.usecaseT3.GetByID(int32(id))
	if err != nil {
		statusCode := customerror.GetStatusCode(err)
		return ctx.JSON(statusCode, map[string]string{"message": err.Error()})
	}
	return ctx.JSON(http.StatusOK, data)
}

func (c *PemeriksaanDokterCombinedController) GetT3ByKehamilan(ctx echo.Context) error {
	kehamilanID, err := strconv.ParseInt(ctx.QueryParam("kehamilan_id"), 10, 32)
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, map[string]string{"message": "kehamilan_id required"})
	}
	list, err := c.usecaseT3.GetByKehamilanID(int32(kehamilanID))
	if err != nil {
		statusCode := customerror.GetStatusCode(err)
		return ctx.JSON(statusCode, map[string]string{"message": err.Error()})
	}

	if len(list) == 0 {
		return ctx.JSON(http.StatusOK, map[string]interface{}{
			"dokter":   nil,
			"lab_jiwa": nil,
		})
	}

	firstData := list[0]
	// DIUBAH: Sama seperti T1
	return ctx.JSON(http.StatusOK, map[string]interface{}{
		"dokter":   firstData,
		"lab_jiwa": nil,
	})
}

func (c *PemeriksaanDokterCombinedController) DeleteT3(ctx echo.Context) error {
	id, err := strconv.ParseInt(ctx.Param("id"), 10, 32)
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, map[string]string{"message": "id tidak valid"})
	}
	if err := c.usecaseT3.Delete(int32(id)); err != nil {
		statusCode := customerror.GetStatusCode(err)
		return ctx.JSON(statusCode, map[string]string{"message": err.Error()})
	}
	return ctx.JSON(http.StatusOK, map[string]string{"message": "Data berhasil dihapus"})
}
