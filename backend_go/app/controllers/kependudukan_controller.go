package controllers

import (
	"net/http"
	"strconv"
	"time"

	"monitoring-service/app/middlewares"
	"monitoring-service/app/models"
	"monitoring-service/app/usecases"

	"github.com/labstack/echo/v4"
)

type KependudukanController struct {
	usecase usecases.KependudukanUsecase
}

func NewKependudukanController(u usecases.KependudukanUsecase) *KependudukanController {
	return &KependudukanController{usecase: u}
}

type createKependudukanRequest struct {
	RW                  string `json:"rw"`
	RT                  string `json:"rt"`
	Dusun               string `json:"dusun"`
	Alamat              string `json:"alamat"`
	KodeKeluarga        string `json:"kode_keluarga"`
	NamaKepalaKeluarga  string `json:"nama_kepala_keluarga"`
	NIK                 string `json:"nik"`
	NamaAnggotaKeluarga string `json:"nama_anggota_keluarga"`
	JenisKelamin        string `json:"jenis_kelamin"`
	Hubungan            string `json:"hubungan"`
	TempatLahir         string `json:"tempat_lahir"`
	TanggalLahir        string `json:"tanggal_lahir"` // Format: YYYY-MM-DD
	Status              string `json:"status"`        // Kawin/Belum Kawin/Cerai
	Agama               string `json:"agama"`
	GolonganDarah       string `json:"golongan_darah"`
	Kewarganegaraan     string `json:"kewarganegaraan"`
	EtnisSuku           string `json:"etnis_suku"`
	Pendidikan          string `json:"pendidikan"`
	Pekerjaan           string `json:"pekerjaan"`
	DesaID     *int32 `json:"desa_id,omitempty"`
	PosyanduID *int32 `json:"posyandu_id,omitempty"`
}

func (c *KependudukanController) Create(ctx echo.Context) error {
	claims, _ := ctx.Get("auth_claims").(*models.AuthClaims)
	if claims == nil {
		return ctx.JSON(http.StatusUnauthorized, models.Response{StatusCode: http.StatusUnauthorized, Message: "Unauthorized"})
	}
	var req createKependudukanRequest
	if err := ctx.Bind(&req); err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{StatusCode: http.StatusBadRequest, Message: err.Error()})
	}

	// Validasi field wajib
	if req.NamaAnggotaKeluarga == "" {
		return ctx.JSON(http.StatusBadRequest, models.Response{
			StatusCode: http.StatusBadRequest,
			Message:    "nama_anggota_keluarga wajib diisi",
		})
	}
	if req.TanggalLahir == "" {
		return ctx.JSON(http.StatusBadRequest, models.Response{
			StatusCode: http.StatusBadRequest,
			Message:    "tanggal_lahir wajib diisi",
		})
	}
	// Parse tanggal lahir
	tanggalLahir, err := time.Parse("2006-01-02", req.TanggalLahir)
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{
			StatusCode: http.StatusBadRequest,
			Message:    "format tanggal_lahir harus YYYY-MM-DD",
		})
	}

	// Convert NIK string to *string (nil jika kosong)
	var nikPtr *string
	if req.NIK != "" {
		nikPtr = &req.NIK
	}

	k := &models.Kependudukan{
		RW:                  req.RW,
		RT:                  req.RT,
		Dusun:               req.Dusun,
		Alamat:              req.Alamat,
		KodeKeluarga:        req.KodeKeluarga,
		NamaKepalaKeluarga:  req.NamaKepalaKeluarga,
		NIK:                 nikPtr,
		NamaAnggotaKeluarga: req.NamaAnggotaKeluarga,
		JenisKelamin:        req.JenisKelamin,
		Hubungan:            req.Hubungan,
		TempatLahir:         req.TempatLahir,
		TanggalLahir:        tanggalLahir,
		Status:              req.Status,
		Agama:               req.Agama,
		GolonganDarah:       req.GolonganDarah,
		Kewarganegaraan:     req.Kewarganegaraan,
		EtnisSuku:           req.EtnisSuku,
		Pendidikan:          req.Pendidikan,
		Pekerjaan:           req.Pekerjaan,

	}

	data, err := c.usecase.Create(k)
	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, models.Response{StatusCode: http.StatusInternalServerError, Message: err.Error()})
	}
	return ctx.JSON(http.StatusCreated, models.Response{StatusCode: http.StatusCreated, Data: data})
}

func (c *KependudukanController) GetAll(ctx echo.Context) error {
	list, err := c.usecase.GetAll()
	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, models.Response{StatusCode: http.StatusInternalServerError, Message: err.Error()})
	}
	return ctx.JSON(http.StatusOK, models.Response{StatusCode: http.StatusOK, Data: list})
}

func (c *KependudukanController) GetByID(ctx echo.Context) error {
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

func (c *KependudukanController) Update(ctx echo.Context) error {
	id, err := strconv.ParseInt(ctx.Param("id"), 10, 32)
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{StatusCode: http.StatusBadRequest, Message: "invalid id"})
	}
	var req createKependudukanRequest
	if err := ctx.Bind(&req); err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{StatusCode: http.StatusBadRequest, Message: err.Error()})
	}
	existing, err := c.usecase.GetByID(int32(id))
	if err != nil {
		return ctx.JSON(http.StatusNotFound, models.Response{StatusCode: http.StatusNotFound, Message: "Data tidak ditemukan"})
	}

	
	if req.RW != "" {
		existing.RW = req.RW
	}
	if req.RT != "" {
		existing.RT = req.RT
	}
	if req.Dusun != "" {
		existing.Dusun = req.Dusun
	}
	if req.Alamat != "" {
		existing.Alamat = req.Alamat
	}
	if req.KodeKeluarga != "" {
		existing.KodeKeluarga = req.KodeKeluarga
	}
	if req.NamaKepalaKeluarga != "" {
		existing.NamaKepalaKeluarga = req.NamaKepalaKeluarga
	}
	if req.NamaAnggotaKeluarga != "" {
		existing.NamaAnggotaKeluarga = req.NamaAnggotaKeluarga
	}
	if req.NIK != "" {
		existing.NIK = &req.NIK
	} else if req.NIK == "" && existing.NIK != nil {
		// Jika NIK dikosongkan, set ke nil
		existing.NIK = nil
	}
	if req.JenisKelamin != "" {
		existing.JenisKelamin = req.JenisKelamin
	}
	if req.Hubungan != "" {
		existing.Hubungan = req.Hubungan
	}
	if req.TempatLahir != "" {
		existing.TempatLahir = req.TempatLahir
	}
	if req.TanggalLahir != "" {
		if t, err := time.Parse("2006-01-02", req.TanggalLahir); err == nil {
			existing.TanggalLahir = t
		}
	}
	if req.Status != "" {
		existing.Status = req.Status
	}
	if req.Agama != "" {
		existing.Agama = req.Agama
	}
	if req.GolonganDarah != "" {
		existing.GolonganDarah = req.GolonganDarah
	}
	if req.Kewarganegaraan != "" {
		existing.Kewarganegaraan = req.Kewarganegaraan
	}
	if req.EtnisSuku != "" {
		existing.EtnisSuku = req.EtnisSuku
	}
	if req.Pendidikan != "" {
		existing.Pendidikan = req.Pendidikan
	}
	if req.Pekerjaan != "" {
		existing.Pekerjaan = req.Pekerjaan
	}
	if err := c.usecase.Update(existing); err != nil {
		return ctx.JSON(http.StatusInternalServerError, models.Response{StatusCode: http.StatusInternalServerError, Message: err.Error()})
	}
	return ctx.JSON(http.StatusOK, models.Response{StatusCode: http.StatusOK, Data: existing})
}

func (c *KependudukanController) Delete(ctx echo.Context) error {
	id, err := strconv.ParseInt(ctx.Param("id"), 10, 32)
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, models.Response{StatusCode: http.StatusBadRequest, Message: "invalid id"})
	}
	if err := c.usecase.Delete(int32(id)); err != nil {
		return ctx.JSON(http.StatusInternalServerError, models.Response{StatusCode: http.StatusInternalServerError, Message: err.Error()})
	}
	return ctx.JSON(http.StatusOK, models.Response{StatusCode: http.StatusOK, Message: "deleted"})
}

func (c *KependudukanController) GetRekapPerDusun(ctx echo.Context) error {
	kecamatan := ctx.QueryParam("kecamatan")
	desa := ctx.QueryParam("desa")

	data, err := c.usecase.GetRekapPerDusun(kecamatan, desa)
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

// controllers/kependudukan_controller.go

// GetPendudukList mengambil daftar penduduk dengan filter desa dan jenis kelamin
// GET /tenaga-kesehatan/kependudukan?jenis_kelamin=perempuan
// GET /tenaga-kesehatan/kependudukan?jenis_kelamin=laki
// GET /tenaga-kesehatan/kependudukan (semua)
func (c *KependudukanController) GetPendudukList(ctx echo.Context) error {
    // Ambil desa_id dan role dari context (sudah diset middleware)
    posyanduID := middlewares.GetPosyanduID(ctx)
    role := middlewares.GetRole(ctx)
    jenisKelamin := ctx.QueryParam("jenis_kelamin") // optional: "perempuan", "laki"
    
    list, err := c.usecase.GetPendudukList(posyanduID, role, jenisKelamin)
    if err != nil {
        return ctx.JSON(http.StatusInternalServerError, models.Response{
            StatusCode: http.StatusInternalServerError,
            Message:    err.Error(),
        })
    }
    
    return ctx.JSON(http.StatusOK, models.Response{
        StatusCode: http.StatusOK,
        Message:    "success",
        Data:       list,
    })
}