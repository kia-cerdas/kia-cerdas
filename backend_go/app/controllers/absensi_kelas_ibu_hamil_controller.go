// package controllers

// import (
// 	"net/http"
// 	"time"

// 	"monitoring-service/app/middlewares"
// 	"monitoring-service/app/models"
// 	"monitoring-service/app/usecases"

// 	"github.com/labstack/echo/v4"

// 	"strconv"
// )

// type AbsensiKelasIbuHamilController struct {
// 	usecase usecases.AbsensiKelasIbuHamilUsecase
// }

// func NewAbsensiKelasIbuHamilController(
// 	u usecases.AbsensiKelasIbuHamilUsecase,
// ) *AbsensiKelasIbuHamilController {
// 	return &AbsensiKelasIbuHamilController{usecase: u}
// }

// type saveAbsensiKelasIbuHamilRequest struct {
// 	PertemuanKe  int32  `json:"pertemuan_ke"`
// 	Tanggal      string `json:"tanggal"`
// 	NamaKader    string `json:"nama_kader"`
// 	TanggalParaf string `json:"tanggal_paraf"`
// }

// func parseOptionalDate(value string) (*time.Time, error) {
// 	if value == "" {
// 		return nil, nil
// 	}

// 	parsed, err := time.Parse("2006-01-02", value)
// 	if err != nil {
// 		return nil, err
// 	}

// 	return &parsed, nil
// }

// func (c *AbsensiKelasIbuHamilController) GetMine(ctx echo.Context) error {
// 	claims, ok := ctx.Get("auth_claims").(*models.AuthClaims)
// 	if !ok || claims == nil {
// 		return ctx.JSON(http.StatusUnauthorized, models.Response{
// 			StatusCode: http.StatusUnauthorized,
// 			Message:    "token tidak valid",
// 		})
// 	}

// 	data, err := c.usecase.GetMine(claims.UserID)
// 	if err != nil {
// 		return ctx.JSON(http.StatusNotFound, models.Response{
// 			StatusCode: http.StatusNotFound,
// 			Message:    err.Error(),
// 		})
// 	}

// 	return ctx.JSON(http.StatusOK, models.Response{
// 		StatusCode: http.StatusOK,
// 		Data:       data,
// 	})
// }

// func (c *AbsensiKelasIbuHamilController) SaveMine(ctx echo.Context) error {
// 	claims, ok := ctx.Get("auth_claims").(*models.AuthClaims)
// 	if !ok || claims == nil {
// 		return ctx.JSON(http.StatusUnauthorized, models.Response{
// 			StatusCode: http.StatusUnauthorized,
// 			Message:    "token tidak valid",
// 		})
// 	}

// 	var req saveAbsensiKelasIbuHamilRequest
// 	if err := ctx.Bind(&req); err != nil {
// 		return ctx.JSON(http.StatusBadRequest, models.Response{
// 			StatusCode: http.StatusBadRequest,
// 			Message:    "format request tidak valid",
// 		})
// 	}

// 	tanggal, err := parseOptionalDate(req.Tanggal)
// 	if err != nil {
// 		return ctx.JSON(http.StatusBadRequest, models.Response{
// 			StatusCode: http.StatusBadRequest,
// 			Message:    "format tanggal harus YYYY-MM-DD",
// 		})
// 	}

// 	tanggalParaf, err := parseOptionalDate(req.TanggalParaf)
// 	if err != nil {
// 		return ctx.JSON(http.StatusBadRequest, models.Response{
// 			StatusCode: http.StatusBadRequest,
// 			Message:    "format tanggal_paraf harus YYYY-MM-DD",
// 		})
// 	}

// 	data, err := c.usecase.SaveMine(
// 		claims.UserID,
// 		models.AbsensiKelasIbuHamil{
// 			PertemuanKe:  req.PertemuanKe,
// 			Tanggal:      tanggal,
// 			NamaKader:    req.NamaKader,
// 			TanggalParaf: tanggalParaf,
// 		},
// 	)

// 	if err != nil {
// 		return ctx.JSON(http.StatusBadRequest, models.Response{
// 			StatusCode: http.StatusBadRequest,
// 			Message:    err.Error(),
// 		})
// 	}

// 	return ctx.JSON(http.StatusOK, models.Response{
// 		StatusCode: http.StatusOK,
// 		Data:       data,
// 	})
// }


// // BAGIAN KADER
// func (c *AbsensiKelasIbuHamilController) GetAll(ctx echo.Context) error {
// 	posyanduID := middlewares.GetPosyanduID(ctx)

// 	data, err := c.usecase.GetAll(posyanduID)
// 	if err != nil {
// 		return ctx.JSON(http.StatusInternalServerError, models.Response{
// 			StatusCode: http.StatusInternalServerError,
// 			Message:    err.Error(),
// 		})
// 	}
 
// 	return ctx.JSON(http.StatusOK, models.Response{
// 		StatusCode: http.StatusOK,
// 		Data:       data,
// 	})
// }
 
// type verifyAbsensiKelasIbuHamilRequest struct {
// 	NamaKader    string `json:"nama_kader"`
// 	TanggalParaf string `json:"tanggal_paraf"`
// }
 
// // Verify - Kader memverifikasi kehadiran ibu hamil
// func (c *AbsensiKelasIbuHamilController) Verify(ctx echo.Context) error {
// 	idParam := ctx.Param("id")
 
// 	var req verifyAbsensiKelasIbuHamilRequest
// 	if err := ctx.Bind(&req); err != nil {
// 		return ctx.JSON(http.StatusBadRequest, models.Response{
// 			StatusCode: http.StatusBadRequest,
// 			Message:    "format request tidak valid",
// 		})
// 	}
 
// 	if req.NamaKader == "" {
// 		return ctx.JSON(http.StatusBadRequest, models.Response{
// 			StatusCode: http.StatusBadRequest,
// 			Message:    "nama_kader tidak boleh kosong",
// 		})
// 	}
 
// 	tanggalParaf, err := parseOptionalDate(req.TanggalParaf)
// 	if err != nil {
// 		return ctx.JSON(http.StatusBadRequest, models.Response{
// 			StatusCode: http.StatusBadRequest,
// 			Message:    "format tanggal_paraf harus YYYY-MM-DD",
// 		})
// 	}
 
// 	id, err := strconv.Atoi(idParam)
// 	if err != nil || id <= 0 {
// 		return ctx.JSON(http.StatusBadRequest, models.Response{
// 			StatusCode: http.StatusBadRequest,
// 			Message:    "id tidak valid",
// 		})
// 	}
 
// 	err = c.usecase.Verify(int32(id), req.NamaKader, tanggalParaf)
// 	if err != nil {
// 		return ctx.JSON(http.StatusBadRequest, models.Response{
// 			StatusCode: http.StatusBadRequest,
// 			Message:    err.Error(),
// 		})
// 	}
 
// 	return ctx.JSON(http.StatusOK, models.Response{
// 		StatusCode: http.StatusOK,
// 		Message:    "Berhasil verifikasi absensi kelas ibu hamil",
// 	})
// }

package controllers

import (
	"net/http"
	"time"

	"monitoring-service/app/models"
	"monitoring-service/app/usecases"

	"github.com/labstack/echo/v4"

	"strconv"
)

type AbsensiKelasIbuHamilController struct {
	usecase usecases.AbsensiKelasIbuHamilUsecase
}

func NewAbsensiKelasIbuHamilController(
	u usecases.AbsensiKelasIbuHamilUsecase,
) *AbsensiKelasIbuHamilController {
	return &AbsensiKelasIbuHamilController{usecase: u}
}

type saveAbsensiKelasIbuHamilRequest struct {
	PertemuanKe  int32  `json:"pertemuan_ke"`
	Tanggal      string `json:"tanggal"`
	NamaKader    string `json:"nama_kader"`
	TanggalParaf string `json:"tanggal_paraf"`
}

func parseOptionalDate(value string) (*time.Time, error) {
	if value == "" {
		return nil, nil
	}

	parsed, err := time.Parse("2006-01-02", value)
	if err != nil {
		return nil, err
	}

	return &parsed, nil
}

func (c *AbsensiKelasIbuHamilController) GetMine(ctx echo.Context) error {
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

func (c *AbsensiKelasIbuHamilController) SaveMine(ctx echo.Context) error {
	claims, ok := ctx.Get("auth_claims").(*models.AuthClaims)
	if !ok || claims == nil {
		return ctx.JSON(http.StatusUnauthorized, models.Response{
			StatusCode: http.StatusUnauthorized,
			Message:    "token tidak valid",
		})
	}

	var req saveAbsensiKelasIbuHamilRequest
	if err := ctx.Bind(&req); err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{
			StatusCode: http.StatusBadRequest,
			Message:    "format request tidak valid",
		})
	}

	tanggal, err := parseOptionalDate(req.Tanggal)
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{
			StatusCode: http.StatusBadRequest,
			Message:    "format tanggal harus YYYY-MM-DD",
		})
	}

	tanggalParaf, err := parseOptionalDate(req.TanggalParaf)
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{
			StatusCode: http.StatusBadRequest,
			Message:    "format tanggal_paraf harus YYYY-MM-DD",
		})
	}

	data, err := c.usecase.SaveMine(
		claims.UserID,
		models.AbsensiKelasIbuHamil{
			PertemuanKe:  req.PertemuanKe,
			Tanggal:      tanggal,
			NamaKader:    req.NamaKader,
			TanggalParaf: tanggalParaf,
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


// BAGIAN KADER
func (c *AbsensiKelasIbuHamilController) GetAll(ctx echo.Context) error {
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
 
type verifyAbsensiKelasIbuHamilRequest struct {
	NamaKader    string `json:"nama_kader"`
	TanggalParaf string `json:"tanggal_paraf"`
}
 
// Verify - Kader memverifikasi kehadiran ibu hamil
func (c *AbsensiKelasIbuHamilController) Verify(ctx echo.Context) error {
	idParam := ctx.Param("id")
 
	var req verifyAbsensiKelasIbuHamilRequest
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
 
	tanggalParaf, err := parseOptionalDate(req.TanggalParaf)
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{
			StatusCode: http.StatusBadRequest,
			Message:    "format tanggal_paraf harus YYYY-MM-DD",
		})
	}
 
	id, err := strconv.Atoi(idParam)
	if err != nil || id <= 0 {
		return ctx.JSON(http.StatusBadRequest, models.Response{
			StatusCode: http.StatusBadRequest,
			Message:    "id tidak valid",
		})
	}
 
	err = c.usecase.Verify(int32(id), req.NamaKader, tanggalParaf)
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{
			StatusCode: http.StatusBadRequest,
			Message:    err.Error(),
		})
	}
 
	return ctx.JSON(http.StatusOK, models.Response{
		StatusCode: http.StatusOK,
		Message:    "Berhasil verifikasi absensi kelas ibu hamil",
	})
}



// Absensi kelas ibu hamil
func (c *AbsensiKelasIbuHamilController) Reject(ctx echo.Context) error {
    idParam := ctx.Param("id")

    id, err := strconv.Atoi(idParam)
    if err != nil || id <= 0 {
        return ctx.JSON(http.StatusBadRequest, models.Response{
            StatusCode: http.StatusBadRequest,
            Message:    "id tidak valid",
        })
    }

    err = c.usecase.Reject(int32(id))
    if err != nil {
        return ctx.JSON(http.StatusBadRequest, models.Response{
            StatusCode: http.StatusBadRequest,
            Message:    err.Error(),
        })
    }

    return ctx.JSON(http.StatusOK, models.Response{
        StatusCode: http.StatusOK,
        Message:    "Berhasil menolak absensi kelas ibu hamil",
    })
}