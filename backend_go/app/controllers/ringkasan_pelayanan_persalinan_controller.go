package controllers

import (
	"fmt"
	"net/http"
	"strconv"
	"strings"
	"time"

	"monitoring-service/app/models"
	"monitoring-service/app/usecases"

	"github.com/labstack/echo/v4"
)

type RingkasanPelayananPersalinanController struct {
	usecase          usecases.RingkasanPelayananPersalinanUsecase
	riwayatUsecase   usecases.RiwayatProsesMelahirkanUsecase
	kehamilanUsecase usecases.KehamilanUsecase
}

// NewRingkasanPelayananPersalinanController sekarang menerima RiwayatProsesMelahirkanUsecase
func NewRingkasanPelayananPersalinanController(
	u usecases.RingkasanPelayananPersalinanUsecase,
	ru usecases.RiwayatProsesMelahirkanUsecase,
	ku usecases.KehamilanUsecase,
) *RingkasanPelayananPersalinanController {
	return &RingkasanPelayananPersalinanController{usecase: u, riwayatUsecase: ru, kehamilanUsecase: ku}
}

type createRingkasanRequest struct {
	KehamilanID                      int32    `json:"kehamilan_id"`
	TanggalMelahirkan                string   `json:"tanggal_melahirkan"`
	PukulMelahirkan                  string   `json:"pukul_melahirkan"`
	UmurKehamilanMinggu              int      `json:"umur_kehamilan_minggu"`
	PenolongProsesMelahirkan         string   `json:"penolong_proses_melahirkan"`
	CaraMelahirkan                   string   `json:"cara_melahirkan"`
	KeadaanIbu                       string   `json:"keadaan_ibu"`
	KeadaanIbuDetailSakit            string   `json:"keadaan_ibu_detail_sakit"`
	KBPascaMelahirkan                string   `json:"kb_pasca_melahirkan"`
	KeteranganTambahanIbu            string   `json:"keterangan_tambahan_ibu"`
	BayiAnakKe                       int      `json:"bayi_anak_ke"`
	BayiBeratLahirGram               *float64 `json:"bayi_berat_lahir_gram"`
	BayiPanjangBadanCm               *float64 `json:"bayi_panjang_badan_cm"`
	BayiLingkarKepalaCm              *float64 `json:"bayi_lingkar_kepala_cm"`
	BayiJenisKelamin                 string   `json:"bayi_jenis_kelamin"`
	KondisiBayiSegeraMenangis        bool     `json:"kondisi_bayi_segera_menangis"`
	KondisiBayiMenangisBeberapaSaat  bool     `json:"kondisi_bayi_menangis_beberapa_saat"`
	KondisiBayiTidakMenangis         bool     `json:"kondisi_bayi_tidak_menangis"`
	KondisiBayiSeluruhTubuhKemerahan bool     `json:"kondisi_bayi_seluruh_tubuh_kemerahan"`
	KondisiBayiAnggotaGerakKebiruan  bool     `json:"kondisi_bayi_anggota_gerak_kebiruan"`
	KondisiBayiSeluruhTubuhBiru      bool     `json:"kondisi_bayi_seluruh_tubuh_biru"`
	KondisiBayiKelainanBawaan        bool     `json:"kondisi_bayi_kelainan_bawaan"`
	KondisiBayiKelainanBawaanDetail  string   `json:"kondisi_bayi_kelainan_bawaan_detail"`
	KondisiBayiMeninggal             bool     `json:"kondisi_bayi_meninggal"`
	AsuhanIMD1JamPertama             bool     `json:"asuhan_imd_1_jam_pertama"`
	AsuhanSuntikanVitaminK1          bool     `json:"asuhan_suntikan_vitamin_k1"`
	AsuhanSalepMataAntibiotika       bool     `json:"asuhan_salep_mata_antibiotika"`
	AsuhanImunisasiHB0               bool     `json:"asuhan_imunisasi_hb0"`
	KeteranganTambahanBayi           string   `json:"keterangan_tambahan_bayi"`
}

// sinkronisasiRiwayat menyamakan data Ringkasan ke RiwayatProsesMelahirkan
func (c *RingkasanPelayananPersalinanController) sinkronisasiRiwayat(ringkasan *models.RingkasanPelayananPersalinan) error {
	// Cari riwayat existing untuk kehamilan ini
	riwayatList, err := c.riwayatUsecase.GetByKehamilanID(ringkasan.KehamilanID)
	if err != nil || len(riwayatList) == 0 {
		// Buat baru
		riwayatBaru := &models.RiwayatProsesMelahirkan{
			KehamilanID: ringkasan.KehamilanID,
			// // GGravida:    ringkasan.Gravida,
			// PPartus:     ringkasan.Paritas,
			// AAbortus:    ringkasan.Abortus,
		}
		if ringkasan.TanggalMelahirkan != nil {
			riwayatBaru.TanggalMelahirkan = ringkasan.TanggalMelahirkan
		}
		// mapping cara melahirkan ke bool
		if strings.Contains(strings.ToLower(ringkasan.CaraMelahirkan), "spontan") || strings.Contains(strings.ToLower(ringkasan.CaraMelahirkan), "normal") {
			riwayatBaru.CaraMelahirkanSpontan = true
		} else if strings.Contains(strings.ToLower(ringkasan.CaraMelahirkan), "sc") || strings.Contains(strings.ToLower(ringkasan.CaraMelahirkan), "caesar") {
			riwayatBaru.TindakanSC = true
		} else if strings.Contains(strings.ToLower(ringkasan.CaraMelahirkan), "vakum") {
			riwayatBaru.TindakanEkstraksiVakum = true
		}
		// penolong
		if strings.Contains(strings.ToLower(ringkasan.PenolongProsesMelahirkan), "bidan") {
			riwayatBaru.PenolongBidan = true
		} else if strings.Contains(strings.ToLower(ringkasan.PenolongProsesMelahirkan), "dokter spesialis") {
			riwayatBaru.PenolongDokterSpesialis = true
		} else if strings.Contains(strings.ToLower(ringkasan.PenolongProsesMelahirkan), "dokter") {
			riwayatBaru.PenolongDokter = true
		}
		return c.riwayatUsecase.Create(riwayatBaru)
	} else {
		// Update yang sudah ada (ambil record pertama)
		riwayat := &riwayatList[0]
		// if ringkasan.Gravida > 0 {
		// 	riwayat.GGravida = ringkasan.Gravida
		// }
		// if ringkasan.Paritas > 0 {
		// 	riwayat.PPartus = ringkasan.Paritas
		// }
		// if ringkasan.Abortus > 0 {
		// 	riwayat.AAbortus = ringkasan.Abortus
		// }
		if ringkasan.TanggalMelahirkan != nil {
			riwayat.TanggalMelahirkan = ringkasan.TanggalMelahirkan
		}
		// reset bool dulu lalu set sesuai cara melahirkan terbaru
		riwayat.CaraMelahirkanSpontan = false
		riwayat.CaraMelahirkanSungsang = false
		riwayat.TindakanEkstraksiVakum = false
		riwayat.TindakanSC = false
		if strings.Contains(strings.ToLower(ringkasan.CaraMelahirkan), "spontan") || strings.Contains(strings.ToLower(ringkasan.CaraMelahirkan), "normal") {
			riwayat.CaraMelahirkanSpontan = true
		} else if strings.Contains(strings.ToLower(ringkasan.CaraMelahirkan), "sc") || strings.Contains(strings.ToLower(ringkasan.CaraMelahirkan), "caesar") {
			riwayat.TindakanSC = true
		} else if strings.Contains(strings.ToLower(ringkasan.CaraMelahirkan), "vakum") {
			riwayat.TindakanEkstraksiVakum = true
		}
		// penolong
		riwayat.PenolongDokterSpesialis = false
		riwayat.PenolongDokter = false
		riwayat.PenolongBidan = false
		if strings.Contains(strings.ToLower(ringkasan.PenolongProsesMelahirkan), "bidan") {
			riwayat.PenolongBidan = true
		} else if strings.Contains(strings.ToLower(ringkasan.PenolongProsesMelahirkan), "dokter spesialis") {
			riwayat.PenolongDokterSpesialis = true
		} else if strings.Contains(strings.ToLower(ringkasan.PenolongProsesMelahirkan), "dokter") {
			riwayat.PenolongDokter = true
		}
		return c.riwayatUsecase.Update(riwayat)
	}
}

func (c *RingkasanPelayananPersalinanController) Create(ctx echo.Context) error {
	claims, _ := ctx.Get("auth_claims").(*models.AuthClaims)
	if claims == nil {
		return ctx.JSON(http.StatusUnauthorized, models.Response{StatusCode: http.StatusUnauthorized, Message: "Unauthorized"})
	}
	var req createRingkasanRequest
	if err := ctx.Bind(&req); err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{StatusCode: http.StatusBadRequest, Message: err.Error()})
	}
	r := &models.RingkasanPelayananPersalinan{
		KehamilanID:                      req.KehamilanID,
		UmurKehamilanMinggu:              &req.UmurKehamilanMinggu,
		PenolongProsesMelahirkan:         req.PenolongProsesMelahirkan,
		CaraMelahirkan:                   req.CaraMelahirkan,
		KeadaanIbu:                       req.KeadaanIbu,
		KeadaanIbuDetailSakit:            req.KeadaanIbuDetailSakit,
		KBPascaMelahirkan:                req.KBPascaMelahirkan,
		KeteranganTambahanIbu:            req.KeteranganTambahanIbu,
		BayiAnakKe:                       req.BayiAnakKe,
		BayiBeratLahirGram:               req.BayiBeratLahirGram,
		BayiPanjangBadanCm:               req.BayiPanjangBadanCm,
		BayiLingkarKepalaCm:              req.BayiLingkarKepalaCm,
		BayiJenisKelamin:                 req.BayiJenisKelamin,
		KondisiBayiSegeraMenangis:        req.KondisiBayiSegeraMenangis,
		KondisiBayiMenangisBeberapaSaat:  req.KondisiBayiMenangisBeberapaSaat,
		KondisiBayiTidakMenangis:         req.KondisiBayiTidakMenangis,
		KondisiBayiSeluruhTubuhKemerahan: req.KondisiBayiSeluruhTubuhKemerahan,
		KondisiBayiAnggotaGerakKebiruan:  req.KondisiBayiAnggotaGerakKebiruan,
		KondisiBayiSeluruhTubuhBiru:      req.KondisiBayiSeluruhTubuhBiru,
		KondisiBayiKelainanBawaan:        req.KondisiBayiKelainanBawaan,
		KondisiBayiKelainanBawaanDetail:  req.KondisiBayiKelainanBawaanDetail,
		KondisiBayiMeninggal:             req.KondisiBayiMeninggal,
		AsuhanIMD1JamPertama:             req.AsuhanIMD1JamPertama,
		AsuhanSuntikanVitaminK1:          req.AsuhanSuntikanVitaminK1,
		AsuhanSalepMataAntibiotika:       req.AsuhanSalepMataAntibiotika,
		AsuhanImunisasiHB0:               req.AsuhanImunisasiHB0,
		KeteranganTambahanBayi:           req.KeteranganTambahanBayi,
		// Gravida:                          req.Gravida,
		// Paritas:                          req.Paritas,
		// Abortus:                          req.Abortus,
	}
	if req.TanggalMelahirkan != "" {
		if t, err := time.Parse("2006-01-02", req.TanggalMelahirkan); err == nil {
			r.TanggalMelahirkan = &t
		}
	}
	if req.PukulMelahirkan != "" {
		if t, err := time.Parse("15:04:05", req.PukulMelahirkan); err == nil {
			r.PukulMelahirkan = &t
		}
	}
	if err := c.usecase.Create(r); err != nil {
		return ctx.JSON(http.StatusInternalServerError, models.Response{StatusCode: http.StatusInternalServerError, Message: err.Error()})
	}
	if err := c.kehamilanUsecase.UpdateStatusKehamilan(req.KehamilanID, "NIFAS"); err != nil {
		// Log error tapi jangan batalkan response (atau bisa juga return error)
		// Sesuaikan dengan kebutuhan bisnis
		fmt.Printf("Warning: gagal update status kehamilan ID %d: %v\n", req.KehamilanID, err)
		// Jika ingin response gagal, uncomment baris di bawah:
		// return ctx.JSON(http.StatusInternalServerError, models.Response{StatusCode: http.StatusInternalServerError, Message: "Berhasil create ringkasan tapi gagal update status kehamilan"})
	}
	// Sinkronisasi ke Riwayat
	if err := c.sinkronisasiRiwayat(r); err != nil {
		// Log error, tapi tidak perlu gagalkan response
	}
	return ctx.JSON(http.StatusCreated, models.Response{StatusCode: http.StatusCreated, Data: r})
}

func (c *RingkasanPelayananPersalinanController) GetByID(ctx echo.Context) error {
	id, err := strconv.ParseInt(ctx.Param("id"), 10, 32)
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{StatusCode: http.StatusBadRequest, Message: "invalid id"})
	}
	data, err := c.usecase.GetByID(int32(id))
	if err != nil {
		return ctx.JSON(http.StatusNotFound, models.Response{StatusCode: http.StatusNotFound, Message: err.Error()})
	}
	return ctx.JSON(http.StatusOK, models.Response{StatusCode: http.StatusOK, Data: data})
}

func (c *RingkasanPelayananPersalinanController) GetByKehamilanID(ctx echo.Context) error {
	kehamilanID, err := strconv.ParseInt(ctx.QueryParam("kehamilan_id"), 10, 32)
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{StatusCode: http.StatusBadRequest, Message: "kehamilan_id required"})
	}
	list, err := c.usecase.GetByKehamilanID(int32(kehamilanID))
	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, models.Response{StatusCode: http.StatusInternalServerError, Message: err.Error()})
	}
	return ctx.JSON(http.StatusOK, models.Response{StatusCode: http.StatusOK, Data: list})
}

func (c *RingkasanPelayananPersalinanController) Update(ctx echo.Context) error {
	id, err := strconv.ParseInt(ctx.Param("id"), 10, 32)
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{StatusCode: http.StatusBadRequest, Message: "invalid id"})
	}
	var req createRingkasanRequest
	if err := ctx.Bind(&req); err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{StatusCode: http.StatusBadRequest, Message: err.Error()})
	}
	existing, err := c.usecase.GetByID(int32(id))
	if err != nil {
		return ctx.JSON(http.StatusNotFound, models.Response{StatusCode: http.StatusNotFound, Message: "Data tidak ditemukan"})
	}
	// Update semua field yang diisi
	if req.TanggalMelahirkan != "" {
		if t, err := time.Parse("2006-01-02", req.TanggalMelahirkan); err == nil {
			existing.TanggalMelahirkan = &t
		}
	}
	if req.PukulMelahirkan != "" {
		if t, err := time.Parse("15:04:05", req.PukulMelahirkan); err == nil {
			existing.PukulMelahirkan = &t
		}
	}
	if req.UmurKehamilanMinggu != 0 {
		existing.UmurKehamilanMinggu = &req.UmurKehamilanMinggu
	}
	if req.PenolongProsesMelahirkan != "" {
		existing.PenolongProsesMelahirkan = req.PenolongProsesMelahirkan
	}
	if req.CaraMelahirkan != "" {
		existing.CaraMelahirkan = req.CaraMelahirkan
	}
	if req.KeadaanIbu != "" {
		existing.KeadaanIbu = req.KeadaanIbu
	}
	if req.KeadaanIbuDetailSakit != "" {
		existing.KeadaanIbuDetailSakit = req.KeadaanIbuDetailSakit
	}
	if req.KBPascaMelahirkan != "" {
		existing.KBPascaMelahirkan = req.KBPascaMelahirkan
	}
	if req.KeteranganTambahanIbu != "" {
		existing.KeteranganTambahanIbu = req.KeteranganTambahanIbu
	}
	if req.BayiAnakKe != 0 {
		existing.BayiAnakKe = req.BayiAnakKe
	}
	if req.BayiBeratLahirGram != nil {
		existing.BayiBeratLahirGram = req.BayiBeratLahirGram
	}
	if req.BayiPanjangBadanCm != nil {
		existing.BayiPanjangBadanCm = req.BayiPanjangBadanCm
	}
	if req.BayiLingkarKepalaCm != nil {
		existing.BayiLingkarKepalaCm = req.BayiLingkarKepalaCm
	}
	if req.BayiJenisKelamin != "" {
		existing.BayiJenisKelamin = req.BayiJenisKelamin
	}
	existing.KondisiBayiSegeraMenangis = req.KondisiBayiSegeraMenangis
	existing.KondisiBayiMenangisBeberapaSaat = req.KondisiBayiMenangisBeberapaSaat
	existing.KondisiBayiTidakMenangis = req.KondisiBayiTidakMenangis
	existing.KondisiBayiSeluruhTubuhKemerahan = req.KondisiBayiSeluruhTubuhKemerahan
	existing.KondisiBayiAnggotaGerakKebiruan = req.KondisiBayiAnggotaGerakKebiruan
	existing.KondisiBayiSeluruhTubuhBiru = req.KondisiBayiSeluruhTubuhBiru
	existing.KondisiBayiKelainanBawaan = req.KondisiBayiKelainanBawaan
	if req.KondisiBayiKelainanBawaanDetail != "" {
		existing.KondisiBayiKelainanBawaanDetail = req.KondisiBayiKelainanBawaanDetail
	}
	existing.KondisiBayiMeninggal = req.KondisiBayiMeninggal
	existing.AsuhanIMD1JamPertama = req.AsuhanIMD1JamPertama
	existing.AsuhanSuntikanVitaminK1 = req.AsuhanSuntikanVitaminK1
	existing.AsuhanSalepMataAntibiotika = req.AsuhanSalepMataAntibiotika
	existing.AsuhanImunisasiHB0 = req.AsuhanImunisasiHB0
	if req.KeteranganTambahanBayi != "" {
		existing.KeteranganTambahanBayi = req.KeteranganTambahanBayi
	}
	// existing.Gravida = req.Gravida
	// existing.Paritas = req.Paritas
	// existing.Abortus = req.Abortus

	if err := c.usecase.Update(existing); err != nil {
		return ctx.JSON(http.StatusInternalServerError, models.Response{StatusCode: http.StatusInternalServerError, Message: err.Error()})
	}
	// Sinkronisasi ke Riwayat
	if err := c.sinkronisasiRiwayat(existing); err != nil {
		// optional error log
	}
	return ctx.JSON(http.StatusOK, models.Response{StatusCode: http.StatusOK, Data: existing})
}

// GetMine tetap seperti semula
func (c *RingkasanPelayananPersalinanController) GetMine(ctx echo.Context) error {
	claims, ok := ctx.Get("auth_claims").(*models.AuthClaims)
	if !ok || claims == nil {
		return ctx.JSON(http.StatusUnauthorized, models.Response{
			StatusCode: http.StatusUnauthorized,
			Message:    "Unauthorized",
		})
	}
	userID := claims.UserID
	data, err := c.usecase.GetMine(ctx.Request().Context(), userID)
	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, models.Response{
			StatusCode: http.StatusInternalServerError,
			Message:    err.Error(),
		})
	}
	return ctx.JSON(http.StatusOK, models.Response{
		StatusCode: http.StatusOK,
		Data:       data,
	})
}

func (c *RingkasanPelayananPersalinanController) Delete(ctx echo.Context) error {
	id, err := strconv.ParseInt(ctx.Param("id"), 10, 32)
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{StatusCode: http.StatusBadRequest, Message: "invalid id"})
	}
	if err := c.usecase.Delete(int32(id)); err != nil {
		return ctx.JSON(http.StatusInternalServerError, models.Response{StatusCode: http.StatusInternalServerError, Message: err.Error()})
	}
	return ctx.JSON(http.StatusOK, models.Response{StatusCode: http.StatusOK, Message: "deleted"})
}
