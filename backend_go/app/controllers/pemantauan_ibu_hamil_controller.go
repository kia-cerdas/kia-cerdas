package controllers

import (
	"net/http"
	"strconv"

	"monitoring-service/app/models"
	"monitoring-service/app/usecases"

	"github.com/labstack/echo/v4"
)

type PemantauanIbuHamilController struct {
	usecase usecases.PemantauanIbuHamilUsecase
}

func NewPemantauanIbuHamilController(u usecases.PemantauanIbuHamilUsecase) *PemantauanIbuHamilController {
	return &PemantauanIbuHamilController{usecase: u}
}

type savePemantauanIbuHamilRequest struct {
	MingguKehamilan   int32 `json:"minggu_kehamilan"`
	DemamLebih2Hari   bool  `json:"demam_lebih_2_hari"`
	SakitKepala       bool  `json:"sakit_kepala"`
	CemasBerlebih     bool  `json:"cemas_berlebih"`
	ResikoTB          bool  `json:"resiko_tb"`
	GerakanBayiKurang bool  `json:"gerakan_bayi_kurang"`
	NyeriPerut        bool  `json:"nyeri_perut"`
	CairanJalanLahir  bool  `json:"cairan_jalan_lahir"`
	MasalahKemaluan   bool  `json:"masalah_kemaluan"`
	DiareBerulang     bool  `json:"diare_berulang"`
}

func (c *PemantauanIbuHamilController) GetMine(ctx echo.Context) error {
	claims, ok := ctx.Get("auth_claims").(*models.AuthClaims)
	if !ok || claims == nil {
		return ctx.JSON(http.StatusUnauthorized, models.Response{
			StatusCode: http.StatusUnauthorized,
			Message:    "token tidak valid",
		})
	}

	data, err := c.usecase.GetMine(claims.UserID)
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

func (c *PemantauanIbuHamilController) SaveMine(ctx echo.Context) error {
	claims, ok := ctx.Get("auth_claims").(*models.AuthClaims)
	if !ok || claims == nil {
		return ctx.JSON(http.StatusUnauthorized, models.Response{
			StatusCode: http.StatusUnauthorized,
			Message:    "token tidak valid",
		})
	}

	var req savePemantauanIbuHamilRequest
	if err := ctx.Bind(&req); err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{
			StatusCode: http.StatusBadRequest,
			Message:    "format request tidak valid",
		})
	}

	data, err := c.usecase.SaveMine(
		claims.UserID,
		models.PemantauanIbuHamil{
			MingguKehamilan:   req.MingguKehamilan,
			DemamLebih2Hari:   req.DemamLebih2Hari,
			SakitKepala:       req.SakitKepala,
			CemasBerlebih:     req.CemasBerlebih,
			ResikoTB:          req.ResikoTB,
			GerakanBayiKurang: req.GerakanBayiKurang,
			NyeriPerut:        req.NyeriPerut,
			CairanJalanLahir:  req.CairanJalanLahir,
			MasalahKemaluan:   req.MasalahKemaluan,
			DiareBerulang:     req.DiareBerulang,
		},
	)

	if err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{
			StatusCode: http.StatusBadRequest,
			Message:    err.Error(),
		})
	}

	return ctx.JSON(http.StatusOK, models.Response{
		StatusCode: http.StatusOK,
		Data:       data,
	})
}



func (c *PemantauanIbuHamilController) GetByKehamilanID(ctx echo.Context) error {
	claims, ok := ctx.Get("auth_claims").(*models.AuthClaims)
	if !ok || claims == nil {
		return ctx.JSON(http.StatusUnauthorized, models.Response{
			StatusCode: http.StatusUnauthorized,
			Message:    "token tidak valid",
		})
	}
 
	idParam := ctx.Param("kehamilan_id")
	kehamilanID, err := strconv.Atoi(idParam)
	if err != nil || kehamilanID <= 0 {
		return ctx.JSON(http.StatusBadRequest, models.Response{
			StatusCode: http.StatusBadRequest,
			Message:    "kehamilan_id tidak valid",
		})
	}
 
	data, err := c.usecase.GetByKehamilanID(claims.UserID, int32(kehamilanID))
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



// ─── BAGIAN KADER ────────────────────────────────────────────────────────────

// GetAll mengambil semua data pemantauan ibu hamil untuk ditampilkan ke kader.
func (c *PemantauanIbuHamilController) GetAll(ctx echo.Context) error {
	data, err := c.usecase.GetAll()
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

type verifyPemantauanIbuHamilRequest struct {
	NamaKader         string `json:"nama_kader"`
	TanggalVerifikasi string `json:"tanggal_verifikasi"`
}

// Verify digunakan kader untuk menandai bahwa data pemantauan sudah ditinjau.
func (c *PemantauanIbuHamilController) Verify(ctx echo.Context) error {
	idParam := ctx.Param("id")

	var req verifyPemantauanIbuHamilRequest
	if err := ctx.Bind(&req); err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{
			StatusCode: http.StatusBadRequest,
			Message:    "format request tidak valid",
		})
	}

	if req.NamaKader == "" {
		return ctx.JSON(http.StatusBadRequest, models.Response{
			StatusCode: http.StatusBadRequest,
			Message:    "nama_kader tidak boleh kosong",
		})
	}

	tanggalVerifikasi, err := parseOptionalDate(req.TanggalVerifikasi)
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{
			StatusCode: http.StatusBadRequest,
			Message:    "format tanggal_verifikasi harus YYYY-MM-DD",
		})
	}

	id, err := strconv.Atoi(idParam)
	if err != nil || id <= 0 {
		return ctx.JSON(http.StatusBadRequest, models.Response{
			StatusCode: http.StatusBadRequest,
			Message:    "id tidak valid",
		})
	}

	err = c.usecase.Verify(int32(id), req.NamaKader, tanggalVerifikasi)
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{
			StatusCode: http.StatusBadRequest,
			Message:    err.Error(),
		})
	}

	return ctx.JSON(http.StatusOK, models.Response{
		StatusCode: http.StatusOK,
		Message:    "Berhasil memverifikasi pemantauan ibu hamil",
	})
}
