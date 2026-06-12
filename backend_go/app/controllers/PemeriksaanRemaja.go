package controllers

import (
	"net/http"
	"strconv"
	"time"

	"monitoring-service/app/models"
	"monitoring-service/app/usecases"
	"monitoring-service/app/utils"

	"github.com/labstack/echo/v4"
)

type PemeriksaanRemajaController struct {
	usecase usecases.PemeriksaanRemajaUsecase
	pendudukUsecase usecases.KependudukanUsecase
}

func NewPemeriksaanRemajaController(
	usecase usecases.PemeriksaanRemajaUsecase,
	pendudukUsecase usecases.KependudukanUsecase,
) *PemeriksaanRemajaController {
	return &PemeriksaanRemajaController{
		usecase: usecase,
		pendudukUsecase: pendudukUsecase,
	}
}

type createPemeriksaanRemajaRequest struct {
	PendudukID int32 `json:"penduduk_id"`

	TanggalPemeriksaan string `json:"tanggal_pemeriksaan"`

	BeratBadan   *float64 `json:"berat_badan"`
	TinggiBadan  *float64 `json:"tinggi_badan"`

	TekananDarah string `json:"tekanan_darah"`

	KategoriRisiko   string `json:"kategori_risiko"`
	StatusPemantauan string `json:"status_pemantauan"`

	RiwayatPenyakit string `json:"riwayat_penyakit"`
	CatatanKhusus   string `json:"catatan_khusus"`

	PemeriksaID *int32 `json:"pemeriksa_id"`
}

func (c *PemeriksaanRemajaController) Create(ctx echo.Context) error {

	var req createPemeriksaanRemajaRequest

	if err := ctx.Bind(&req); err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{
			StatusCode: http.StatusBadRequest,
			Message: err.Error(),
		})
	}

	// cek penduduk
	penduduk, err := c.pendudukUsecase.GetByID(req.PendudukID)
	if err != nil {
		return ctx.JSON(http.StatusNotFound, models.Response{
			Message: "penduduk tidak ditemukan",
		})
	}

	umur := utils.HitungUmur(penduduk.TanggalLahir)

	// remaja biasanya 13-18
	if umur < 13 || umur > 18 {
		return ctx.JSON(http.StatusBadRequest, models.Response{
			Message: "penduduk bukan kategori remaja",
		})
	}

	// parse tanggal (INI SAMA SEPERTI KASUS KAMU SEBELUMNYA)
	tanggal, err := time.Parse("2006-01-02", req.TanggalPemeriksaan)
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{
			Message: "format tanggal salah (pakai YYYY-MM-DD)",
		})
	}

	// IMT
	var imt *float64
	if req.BeratBadan != nil && req.TinggiBadan != nil {
		tinggiM := *req.TinggiBadan / 100
		if tinggiM > 0 {
			val := *req.BeratBadan / (tinggiM * tinggiM)
			imt = &val
		}
	}

	data := &models.PemeriksaanRemaja{
		PendudukID: req.PendudukID,

		TanggalPemeriksaan: tanggal,
		Umur: int32(umur),

		BeratBadan:  req.BeratBadan,
		TinggiBadan: req.TinggiBadan,
		IMT:         imt,

		TekananDarah: req.TekananDarah,

		KategoriRisiko:   req.KategoriRisiko,
		StatusPemantauan: req.StatusPemantauan,

		RiwayatPenyakit: req.RiwayatPenyakit,
		CatatanKhusus:   req.CatatanKhusus,

		PemeriksaID: req.PemeriksaID,
	}

	if err := c.usecase.Create(data); err != nil {
		return ctx.JSON(http.StatusInternalServerError, models.Response{
			Message: err.Error(),
		})
	}

	return ctx.JSON(http.StatusCreated, models.Response{
		Message: "berhasil membuat pemeriksaan remaja",
		Data:    data,
	})
}

func (c *PemeriksaanRemajaController) GetAll(ctx echo.Context) error {
	data, err := c.usecase.GetAll()
	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, models.Response{
			Message: err.Error(),
		})
	}

	return ctx.JSON(http.StatusOK, models.Response{
		Data: data,
	})
}

func (c *PemeriksaanRemajaController) GetByID(ctx echo.Context) error {
	id, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{
			Message: "invalid id",
		})
	}

	data, err := c.usecase.GetByID(int32(id))
	if err != nil {
		return ctx.JSON(http.StatusNotFound, models.Response{
			Message: "data tidak ditemukan",
		})
	}

	return ctx.JSON(http.StatusOK, models.Response{
		Data: data,
	})
}

func (c *PemeriksaanRemajaController) Delete(ctx echo.Context) error {
	id, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{
			Message: "invalid id",
		})
	}

	if err := c.usecase.Delete(int32(id)); err != nil {
		return ctx.JSON(http.StatusInternalServerError, models.Response{
			Message: err.Error(),
		})
	}

	return ctx.JSON(http.StatusOK, models.Response{
		Message: "berhasil menghapus data",
	})
}