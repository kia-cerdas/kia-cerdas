package controllers

import (
	"monitoring-service/app/utils"
	"monitoring-service/app/models"
	"monitoring-service/app/usecases"
	"net/http"
	"strconv"
	"time"

	"github.com/labstack/echo/v4"
)

type PemeriksaanAnakController struct {
	usecase          usecases.PemeriksaanAnakUsecase
	pendudukUsecase  usecases.KependudukanUsecase
}

func NewPemeriksaanAnakController(
	usecase usecases.PemeriksaanAnakUsecase,
	pendudukUsecase usecases.KependudukanUsecase,
) *PemeriksaanAnakController {
	return &PemeriksaanAnakController{
		usecase: usecase,
		pendudukUsecase: pendudukUsecase,
	}
}

type createPemeriksaanAnakRequest struct {
	PendudukID int32 `json:"penduduk_id"`

	TanggalPemeriksaan string `json:"tanggal_pemeriksaan"`

	BeratBadan *float64 `json:"berat_badan"`

	TinggiBadan *float64 `json:"tinggi_badan"`

	StatusGizi string `json:"status_gizi"`

	KategoriRisiko string `json:"kategori_risiko"`

	StatusPemantauan string `json:"status_pemantauan"`

	RiwayatPenyakit string `json:"riwayat_penyakit"`

	CatatanKhusus string `json:"catatan_khusus"`
}
func (c *PemeriksaanAnakController) Create(ctx echo.Context) error {

	var req createPemeriksaanAnakRequest

	if err := ctx.Bind(&req); err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{
			StatusCode: http.StatusBadRequest,
			Message: err.Error(),
		})
	}

	penduduk, err := c.pendudukUsecase.GetByID(req.PendudukID)

	if err != nil {
		return ctx.JSON(http.StatusNotFound, models.Response{
			StatusCode: http.StatusNotFound,
			Message: "penduduk tidak ditemukan",
		})
	}

	umur := utils.HitungUmur(penduduk.TanggalLahir)

	// Validasi umur anak 6-12
	if umur < 6 || umur > 12 {
		return ctx.JSON(http.StatusBadRequest, models.Response{
			StatusCode: http.StatusBadRequest,
			Message: "penduduk bukan kategori anak",
		})
	}

	tanggal, err := time.Parse("2006-01-02", req.TanggalPemeriksaan)

	if err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{
			StatusCode: http.StatusBadRequest,
			Message: "format tanggal salah",
		})
	}

	var imt *float64

	if req.BeratBadan != nil && req.TinggiBadan != nil {

		tinggiMeter := *req.TinggiBadan / 100

		if tinggiMeter > 0 {

			result := *req.BeratBadan / (tinggiMeter * tinggiMeter)

			imt = &result
		}
	}

	data := &models.PemeriksaanAnak{
		PendudukID: req.PendudukID,

		TanggalPemeriksaan: tanggal,

		Umur: int32(umur),

		BeratBadan: req.BeratBadan,

		TinggiBadan: req.TinggiBadan,

		IMT: imt,

		StatusGizi: req.StatusGizi,

		KategoriRisiko: req.KategoriRisiko,

		StatusPemantauan: req.StatusPemantauan,

		RiwayatPenyakit: req.RiwayatPenyakit,

		CatatanKhusus: req.CatatanKhusus,
	}

	err = c.usecase.Create(data)

	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, models.Response{
			StatusCode: http.StatusInternalServerError,
			Message: err.Error(),
		})
	}

	return ctx.JSON(http.StatusCreated, models.Response{
		StatusCode: http.StatusCreated,
		Message: "berhasil membuat pemeriksaan anak",
		Data: data,
	})
}
func (c *PemeriksaanAnakController) GetAll(ctx echo.Context) error {

	data, err := c.usecase.GetAll()

	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, models.Response{
			StatusCode: http.StatusInternalServerError,
			Message: err.Error(),
		})
	}

	return ctx.JSON(http.StatusOK, models.Response{
		StatusCode: http.StatusOK,
		Data: data,
	})
}
func (c *PemeriksaanAnakController) GetByID(ctx echo.Context) error {

	id, err := strconv.ParseInt(ctx.Param("id"), 10, 32)

	if err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{
			StatusCode: http.StatusBadRequest,
			Message: "invalid id",
		})
	}

	data, err := c.usecase.GetByID(int32(id))

	if err != nil {
		return ctx.JSON(http.StatusNotFound, models.Response{
			StatusCode: http.StatusNotFound,
			Message: "data tidak ditemukan",
		})
	}

	return ctx.JSON(http.StatusOK, models.Response{
		StatusCode: http.StatusOK,
		Data: data,
	})
}
func (c *PemeriksaanAnakController) Delete(ctx echo.Context) error {

	id, err := strconv.ParseInt(ctx.Param("id"), 10, 32)

	if err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{
			StatusCode: http.StatusBadRequest,
			Message: "invalid id",
		})
	}

	err = c.usecase.Delete(int32(id))

	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, models.Response{
			StatusCode: http.StatusInternalServerError,
			Message: err.Error(),
		})
	}

	return ctx.JSON(http.StatusOK, models.Response{
		StatusCode: http.StatusOK,
		Message: "berhasil menghapus data",
	})
}