package controllers

import (
	"net/http"
	"strconv"
	"time"

	"monitoring-service/app/models"
	"monitoring-service/app/usecases"

	"github.com/labstack/echo/v4"
)

type RencanaPersalinanController struct {
	usecase usecases.RencanaPersalinanUsecase
}

func NewRencanaPersalinanController(u usecases.RencanaPersalinanUsecase) *RencanaPersalinanController {
	return &RencanaPersalinanController{usecase: u}
}

// createRencanaPersalinanRequest — field name disesuaikan dengan JSON tag di model
type createRencanaPersalinanRequest struct {
	KehamilanID              int32  `json:"kehamilan_id"`
	NamaIbuPernyataan        string `json:"nama_ibu_pernyataan"`
	AlamatIbuPernyataan      string `json:"alamat_ibu_pernyataan"`
	PerkiraanBulanPersalinan string `json:"perkiraan_bulan_persalinan"`
	PerkiraanTahunPersalinan *int   `json:"perkiraan_tahun_persalinan"`

	Fasyankes1NamaTenaga    string `json:"fasyankes_1_nama_tenaga"`
	Fasyankes1NamaFasilitas string `json:"fasyankes_1_nama_fasilitas"`
	Fasyankes2NamaTenaga    string `json:"fasyankes_2_nama_tenaga"`
	Fasyankes2NamaFasilitas string `json:"fasyankes_2_nama_fasilitas"`

	SumberDanaPersalinan string `json:"sumber_dana_persalinan"`

	Kendaraan1Nama string `json:"kendaraan_1_nama"`
	Kendaraan1HP   string `json:"kendaraan_1_hp"`
	Kendaraan2Nama string `json:"kendaraan_2_nama"`
	Kendaraan2HP   string `json:"kendaraan_2_hp"`
	Kendaraan3Nama string `json:"kendaraan_3_nama"`
	Kendaraan3HP   string `json:"kendaraan_3_hp"`

	MetodeKontrasepsiPilihan string `json:"metode_kontrasepsi_pilihan"`

	DonorGolonganDarah string `json:"donor_golongan_darah"`
	DonorRhesus        string `json:"donor_rhesus"`
	Donor1Nama         string `json:"donor_1_nama"`
	Donor1HP           string `json:"donor_1_hp"`
	Donor2Nama         string `json:"donor_2_nama"`
	Donor2HP           string `json:"donor_2_hp"`
	Donor3Nama         string `json:"donor_3_nama"`
	Donor3HP           string `json:"donor_3_hp"`
	Donor4Nama         string `json:"donor_4_nama"`
	Donor4HP           string `json:"donor_4_hp"`

	// Disesuaikan dengan model: tanggal_pernyataan, nama_suami_keluarga_ttd, dst.
	TanggalPernyataan    string `json:"tanggal_pernyataan"`
	NamaSuamiKeluargaTTD string `json:"nama_suami_keluarga_ttd"`
	NamaibuTTD           string `json:"nama_ibu_hamil_ttd"`
	NamaBidanDokterTTD   string `json:"nama_bidan_dokter_ttd"`
}

func (c *RencanaPersalinanController) Create(ctx echo.Context) error {
	claims, _ := ctx.Get("auth_claims").(*models.AuthClaims)
	if claims == nil {
		return ctx.JSON(http.StatusUnauthorized, models.Response{
			StatusCode: http.StatusUnauthorized,
			Message:    "Unauthorized",
		})
	}

	var req createRencanaPersalinanRequest
	if err := ctx.Bind(&req); err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{
			StatusCode: http.StatusBadRequest,
			Message:    "Binding request gagal: " + err.Error(),
		})
	}

	if req.KehamilanID == 0 {
		return ctx.JSON(http.StatusBadRequest, models.Response{
			StatusCode: http.StatusBadRequest,
			Message:    "kehamilan_id wajib diisi",
		})
	}

	rp := &models.RencanaPersalinan{
		KehamilanID:              req.KehamilanID,
		NamaIbuPernyataan:        req.NamaIbuPernyataan,
		AlamatIbuPernyataan:      req.AlamatIbuPernyataan,
		PerkiraanBulanPersalinan: req.PerkiraanBulanPersalinan,
		PerkiraanTahunPersalinan: req.PerkiraanTahunPersalinan,
		Fasyankes1NamaTenaga:     req.Fasyankes1NamaTenaga,
		Fasyankes1NamaFasilitas:  req.Fasyankes1NamaFasilitas,
		Fasyankes2NamaTenaga:     req.Fasyankes2NamaTenaga,
		Fasyankes2NamaFasilitas:  req.Fasyankes2NamaFasilitas,
		SumberDanaPersalinan:     req.SumberDanaPersalinan,
		Kendaraan1Nama:           req.Kendaraan1Nama,
		Kendaraan1HP:             req.Kendaraan1HP,
		Kendaraan2Nama:           req.Kendaraan2Nama,
		Kendaraan2HP:             req.Kendaraan2HP,
		Kendaraan3Nama:           req.Kendaraan3Nama,
		Kendaraan3HP:             req.Kendaraan3HP,
		MetodeKontrasepsiPilihan: req.MetodeKontrasepsiPilihan,
		DonorGolonganDarah:       req.DonorGolonganDarah,
		DonorRhesus:              req.DonorRhesus,
		Donor1Nama:               req.Donor1Nama,
		Donor1HP:                 req.Donor1HP,
		Donor2Nama:               req.Donor2Nama,
		Donor2HP:                 req.Donor2HP,
		Donor3Nama:               req.Donor3Nama,
		Donor3HP:                 req.Donor3HP,
		Donor4Nama:               req.Donor4Nama,
		Donor4HP:                 req.Donor4HP,
		NamaSuamiKeluargaTTD:     req.NamaSuamiKeluargaTTD,
		NamaibuTTD:               req.NamaibuTTD,
		NamaBidanDokterTTD:       req.NamaBidanDokterTTD,
	}

	if req.TanggalPernyataan != "" {
		if t, err := time.Parse("2006-01-02", req.TanggalPernyataan); err == nil {
			rp.TanggalPernyataan = &t
		}
	}

	if err := c.usecase.Create(rp); err != nil {
		return ctx.JSON(http.StatusInternalServerError, models.Response{
			StatusCode: http.StatusInternalServerError,
			Message:    err.Error(),
		})
	}

	return ctx.JSON(http.StatusCreated, models.Response{
		StatusCode: http.StatusCreated,
		Data:       rp,
	})
}

func (c *RencanaPersalinanController) GetByID(ctx echo.Context) error {
	id, err := strconv.ParseInt(ctx.Param("id"), 10, 32)
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{
			StatusCode: http.StatusBadRequest,
			Message:    "invalid id",
		})
	}

	data, err := c.usecase.GetByID(int32(id))
	if err != nil {
		return ctx.JSON(http.StatusNotFound, models.Response{
			StatusCode: http.StatusNotFound,
			Message:    err.Error(),
		})
	}

	return ctx.JSON(http.StatusOK, models.Response{
		StatusCode: http.StatusOK,
		Data:       data,
	})
}

func (c *RencanaPersalinanController) GetByKehamilanID(ctx echo.Context) error {
	kehamilanID, err := strconv.ParseInt(ctx.QueryParam("kehamilan_id"), 10, 32)
	if err != nil || kehamilanID == 0 {
		return ctx.JSON(http.StatusBadRequest, models.Response{
			StatusCode: http.StatusBadRequest,
			Message:    "kehamilan_id required",
		})
	}

	list, err := c.usecase.GetByKehamilanID(int32(kehamilanID))
	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, models.Response{
			StatusCode: http.StatusInternalServerError,
			Message:    err.Error(),
		})
	}

	return ctx.JSON(http.StatusOK, models.Response{
		StatusCode: http.StatusOK,
		Data:       list,
	})
}

// Update — mengupdate SEMUA field (patch semantik dengan nilai kosong tetap disimpan)
func (c *RencanaPersalinanController) Update(ctx echo.Context) error {
	id, err := strconv.ParseInt(ctx.Param("id"), 10, 32)
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{
			StatusCode: http.StatusBadRequest,
			Message:    "invalid id",
		})
	}

	var req createRencanaPersalinanRequest
	if err := ctx.Bind(&req); err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{
			StatusCode: http.StatusBadRequest,
			Message:    err.Error(),
		})
	}

	existing, err := c.usecase.FindByIDWithoutPreload(int32(id))
	if err != nil {
		return ctx.JSON(http.StatusNotFound, models.Response{
			StatusCode: http.StatusNotFound,
			Message:    "Data tidak ditemukan",
		})
	}

	// Update semua field dari request
	existing.NamaIbuPernyataan = req.NamaIbuPernyataan
	existing.AlamatIbuPernyataan = req.AlamatIbuPernyataan
	existing.PerkiraanBulanPersalinan = req.PerkiraanBulanPersalinan
	existing.PerkiraanTahunPersalinan = req.PerkiraanTahunPersalinan
	existing.Fasyankes1NamaTenaga = req.Fasyankes1NamaTenaga
	existing.Fasyankes1NamaFasilitas = req.Fasyankes1NamaFasilitas
	existing.Fasyankes2NamaTenaga = req.Fasyankes2NamaTenaga
	existing.Fasyankes2NamaFasilitas = req.Fasyankes2NamaFasilitas
	existing.SumberDanaPersalinan = req.SumberDanaPersalinan
	existing.Kendaraan1Nama = req.Kendaraan1Nama
	existing.Kendaraan1HP = req.Kendaraan1HP
	existing.Kendaraan2Nama = req.Kendaraan2Nama
	existing.Kendaraan2HP = req.Kendaraan2HP
	existing.Kendaraan3Nama = req.Kendaraan3Nama
	existing.Kendaraan3HP = req.Kendaraan3HP
	existing.MetodeKontrasepsiPilihan = req.MetodeKontrasepsiPilihan
	existing.DonorGolonganDarah = req.DonorGolonganDarah
	existing.DonorRhesus = req.DonorRhesus
	existing.Donor1Nama = req.Donor1Nama
	existing.Donor1HP = req.Donor1HP
	existing.Donor2Nama = req.Donor2Nama
	existing.Donor2HP = req.Donor2HP
	existing.Donor3Nama = req.Donor3Nama
	existing.Donor3HP = req.Donor3HP
	existing.Donor4Nama = req.Donor4Nama
	existing.Donor4HP = req.Donor4HP
	existing.NamaSuamiKeluargaTTD = req.NamaSuamiKeluargaTTD
	existing.NamaibuTTD = req.NamaibuTTD
	existing.NamaBidanDokterTTD = req.NamaBidanDokterTTD

	// Parse tanggal — set nil jika kosong
	if req.TanggalPernyataan != "" {
		if t, err := time.Parse("2006-01-02", req.TanggalPernyataan); err == nil {
			existing.TanggalPernyataan = &t
		}
	} else {
		existing.TanggalPernyataan = nil
	}

	if err := c.usecase.Update(existing); err != nil {
		return ctx.JSON(http.StatusInternalServerError, models.Response{
			StatusCode: http.StatusInternalServerError,
			Message:    err.Error(),
		})
	}

	return ctx.JSON(http.StatusOK, models.Response{
		StatusCode: http.StatusOK,
		Data:       existing,
	})
}

func (c *RencanaPersalinanController) Delete(ctx echo.Context) error {
	id, err := strconv.ParseInt(ctx.Param("id"), 10, 32)
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{
			StatusCode: http.StatusBadRequest,
			Message:    "invalid id",
		})
	}

	if err := c.usecase.Delete(int32(id)); err != nil {
		return ctx.JSON(http.StatusInternalServerError, models.Response{
			StatusCode: http.StatusInternalServerError,
			Message:    err.Error(),
		})
	}

	return ctx.JSON(http.StatusOK, models.Response{
		StatusCode: http.StatusOK,
		Message:    "Rencana persalinan berhasil dihapus",
	})
}
