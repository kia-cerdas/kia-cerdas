package controllers

import (
	"fmt"
	"monitoring-service/app/models"
	"monitoring-service/app/usecases"
	"monitoring-service/app/utils"
	"net/http"
	"strconv"
	"time"

	"github.com/labstack/echo/v4"
)

type PemeriksaanDewasaController struct {
	usecase         usecases.PemeriksaanDewasaUsecase
	pendudukUsecase usecases.KependudukanUsecase
}

func NewPemeriksaanDewasaController(
	usecase usecases.PemeriksaanDewasaUsecase,
	pendudukUsecase usecases.KependudukanUsecase,
) *PemeriksaanDewasaController {
	return &PemeriksaanDewasaController{
		usecase: usecase,
		pendudukUsecase: pendudukUsecase,
	}
}

type createPemeriksaanDewasaRequest struct {
	PendudukID int32 `json:"penduduk_id"`

	TanggalPemeriksaan string `json:"tanggal_pemeriksaan"`

	BeratBadan *float64 `json:"berat_badan"`

	TinggiBadan *float64 `json:"tinggi_badan"`

	TekananDarah string `json:"tekanan_darah"`

	GulaDarah *float64 `json:"gula_darah"`

	Kolesterol *float64 `json:"kolesterol"`

	KategoriRisiko string `json:"kategori_risiko"`

	StatusPemantauan string `json:"status_pemantauan"`

	RiwayatPenyakit string `json:"riwayat_penyakit"`

	PenyakitKronis string `json:"penyakit_kronis"`

	CatatanKhusus string `json:"catatan_khusus"`

	PemeriksaID *int32 `json:"pemeriksa_id"`
}

func (c *PemeriksaanDewasaController) Create(ctx echo.Context) error {

	var req createPemeriksaanDewasaRequest

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

	if umur < 20 {
		return ctx.JSON(http.StatusBadRequest, models.Response{
			StatusCode: http.StatusBadRequest,
			Message: "penduduk bukan kategori dewasa",
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

	data := &models.PemeriksaanDewasa{
		PendudukID: req.PendudukID,

		TanggalPemeriksaan: tanggal,

		Umur: int32(umur),

		BeratBadan: req.BeratBadan,

		TinggiBadan: req.TinggiBadan,

		IMT: imt,

		TekananDarah: req.TekananDarah,

		GulaDarah: req.GulaDarah,

		Kolesterol: req.Kolesterol,

		KategoriRisiko: req.KategoriRisiko,

		StatusPemantauan: req.StatusPemantauan,

		RiwayatPenyakit: req.RiwayatPenyakit,

		PenyakitKronis: req.PenyakitKronis,

		CatatanKhusus: req.CatatanKhusus,

		PemeriksaID: req.PemeriksaID,
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
		Message: "berhasil membuat pemeriksaan dewasa",
		Data: data,
	})
}

func (c *PemeriksaanDewasaController) GetAll(ctx echo.Context) error {

	data, err := c.usecase.GetAll()

	if err != nil {

		fmt.Println("ERROR GET ALL PEMERIKSAAN DEWASA :", err)

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

func (c *PemeriksaanDewasaController) GetByID(ctx echo.Context) error {

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

func (c *PemeriksaanDewasaController) Delete(ctx echo.Context) error {

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