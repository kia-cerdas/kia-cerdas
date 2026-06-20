package usecases

import (
	"math"
	"strings"
	"time"

	"monitoring-service/app/models"
	"monitoring-service/app/repositories"
	"monitoring-service/pkg/customerror"

	"gorm.io/gorm"
)

// =============================================
// REQUEST STRUCTS
// =============================================

type AdminAnggotaKeluargaRequest struct {
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
	TanggalLahir        string `json:"tanggal_lahir"`
	Status              string `json:"status"`
	Agama               string `json:"agama"`
	GolonganDarah       string `json:"golongan_darah"`
	Kewarganegaraan     string `json:"kewarganegaraan"`
	EtnisSuku           string `json:"etnis_suku"`
	Pendidikan          string `json:"pendidikan"`
	Pekerjaan           string `json:"pekerjaan"`
	Telepon             string `json:"telepon"`
	DesaID              *int32 `json:"desa_id"`
	PosyanduID          *int32 `json:"posyandu_id"`
	IsNonKTP            bool   `json:"is_non_ktp"`
}

// AdminCreateKartuKeluargaRequest - Membuat data penduduk (tanpa kartu keluarga)
type AdminCreateKartuKeluargaRequest struct {
	AnggotaKeluarga []AdminAnggotaKeluargaRequest `json:"anggota_keluarga"`
}

// Response structs
type AdminListKartuKeluargaPagination struct {
	Page       int `json:"page"`
	Limit      int `json:"limit"`
	Total      int `json:"total"`
	TotalPages int `json:"total_pages"`
}

type AdminListKartuKeluargaItem struct {
	KodeKeluarga    string      `json:"kode_keluarga"`
	KepalaKeluarga  interface{} `json:"kepala_keluarga"`
	JumlahAnggota   int         `json:"jumlah_anggota"`
	CreatedAt       time.Time   `json:"created_at"`
	UpdatedAt       time.Time   `json:"updated_at"`
}

type AdminKepalaKeluarga struct {
	PendudukID          int32  `json:"penduduk_id"`
	NIK                 string `json:"nik"`
	NamaAnggotaKeluarga string `json:"nama_anggota_keluarga"`
}

type AdminDetailKartuKeluargaAnggota struct {
	PendudukID          int32  `json:"penduduk_id"`
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
	TanggalLahir        string `json:"tanggal_lahir"`
	Status              string `json:"status"`
	Agama               string `json:"agama"`
	GolonganDarah       string `json:"golongan_darah"`
	Kewarganegaraan     string `json:"kewarganegaraan"`
	EtnisSuku           string `json:"etnis_suku"`
	Pendidikan          string `json:"pendidikan"`
	Pekerjaan           string `json:"pekerjaan"`
	Telepon             string `json:"telepon"`
	DesaID              *int32 `json:"desa_id"`
	PosyanduID          *int32 `json:"posyandu_id"`
	IsNonKTP            bool   `json:"is_non_ktp"`
}

type AdminDetailKartuKeluargaResponse struct {
	KodeKeluarga       string                             `json:"kode_keluarga"`
	NamaKepalaKeluarga string                             `json:"nama_kepala_keluarga"`
	AnggotaKeluarga    []AdminDetailKartuKeluargaAnggota `json:"anggota_keluarga"`
}

type AdminUpdateKartuKeluargaRequest struct {
	KodeKeluarga string `json:"kode_keluarga"`
}

// =============================================
// USECASE
// =============================================

type AdminAkunKeluargaUsecase struct {
	kependudukanRepo *repositories.KependudukanRepository
}

func NewAdminAkunKeluargaUsecase(
	kependudukanRepo *repositories.KependudukanRepository,
) *AdminAkunKeluargaUsecase {
	return &AdminAkunKeluargaUsecase{
		kependudukanRepo: kependudukanRepo,
	}
}

// =============================================
// CREATE - Membuat anggota keluarga
// =============================================
func (u *AdminAkunKeluargaUsecase) CreateKartuKeluarga(req *AdminCreateKartuKeluargaRequest) (map[string]interface{}, error) {
	if req == nil {
		return nil, customerror.NewBadRequestError("request tidak valid")
	}

	if len(req.AnggotaKeluarga) == 0 {
		return nil, customerror.NewBadRequestError("anggota_keluarga wajib diisi minimal 1 orang")
	}

	// Trim semua field
	for i := range req.AnggotaKeluarga {
		req.AnggotaKeluarga[i].RW = strings.TrimSpace(req.AnggotaKeluarga[i].RW)
		req.AnggotaKeluarga[i].RT = strings.TrimSpace(req.AnggotaKeluarga[i].RT)
		req.AnggotaKeluarga[i].Dusun = strings.TrimSpace(req.AnggotaKeluarga[i].Dusun)
		req.AnggotaKeluarga[i].Alamat = strings.TrimSpace(req.AnggotaKeluarga[i].Alamat)
		req.AnggotaKeluarga[i].KodeKeluarga = strings.TrimSpace(req.AnggotaKeluarga[i].KodeKeluarga)
		req.AnggotaKeluarga[i].NamaKepalaKeluarga = strings.TrimSpace(req.AnggotaKeluarga[i].NamaKepalaKeluarga)
		req.AnggotaKeluarga[i].NIK = strings.TrimSpace(req.AnggotaKeluarga[i].NIK)
		req.AnggotaKeluarga[i].NamaAnggotaKeluarga = strings.TrimSpace(req.AnggotaKeluarga[i].NamaAnggotaKeluarga)
		req.AnggotaKeluarga[i].JenisKelamin = strings.TrimSpace(req.AnggotaKeluarga[i].JenisKelamin)
		req.AnggotaKeluarga[i].Hubungan = strings.TrimSpace(req.AnggotaKeluarga[i].Hubungan)
		req.AnggotaKeluarga[i].TempatLahir = strings.TrimSpace(req.AnggotaKeluarga[i].TempatLahir)
		req.AnggotaKeluarga[i].TanggalLahir = strings.TrimSpace(req.AnggotaKeluarga[i].TanggalLahir)
		req.AnggotaKeluarga[i].Status = strings.TrimSpace(req.AnggotaKeluarga[i].Status)
		req.AnggotaKeluarga[i].Agama = strings.TrimSpace(req.AnggotaKeluarga[i].Agama)
		req.AnggotaKeluarga[i].GolonganDarah = strings.TrimSpace(req.AnggotaKeluarga[i].GolonganDarah)
		req.AnggotaKeluarga[i].Kewarganegaraan = strings.TrimSpace(req.AnggotaKeluarga[i].Kewarganegaraan)
		req.AnggotaKeluarga[i].EtnisSuku = strings.TrimSpace(req.AnggotaKeluarga[i].EtnisSuku)
		req.AnggotaKeluarga[i].Pendidikan = strings.TrimSpace(req.AnggotaKeluarga[i].Pendidikan)
		req.AnggotaKeluarga[i].Pekerjaan = strings.TrimSpace(req.AnggotaKeluarga[i].Pekerjaan)
		req.AnggotaKeluarga[i].Telepon = strings.TrimSpace(req.AnggotaKeluarga[i].Telepon)
	}

	// Validasi NIK unik
	nikSeen := map[string]struct{}{}
	for _, anggota := range req.AnggotaKeluarga {
		if anggota.NIK == "" || anggota.NamaAnggotaKeluarga == "" || anggota.TanggalLahir == "" {
			return nil, customerror.NewBadRequestError("setiap anggota wajib mengisi nik, nama_anggota_keluarga, dan tanggal_lahir")
		}

		if _, exists := nikSeen[anggota.NIK]; exists {
			return nil, customerror.NewBadRequestError("terdapat NIK duplikat pada anggota_keluarga")
		}
		nikSeen[anggota.NIK] = struct{}{}

		nikPtr := &anggota.NIK
		if _, err := u.kependudukanRepo.FindByNIK(nikPtr); err == nil {
			return nil, customerror.NewBadRequestError("NIK sudah terdaftar: " + anggota.NIK)
		}
	}

	createdPenduduk := make([]*models.Kependudukan, 0, len(req.AnggotaKeluarga))
	for _, anggota := range req.AnggotaKeluarga {
		tanggalLahir, err := time.Parse("2006-01-02", anggota.TanggalLahir)
		if err != nil {
			return nil, customerror.NewBadRequestError("format tanggal_lahir harus YYYY-MM-DD")
		}

		nikPtr := &anggota.NIK
		penduduk := &models.Kependudukan{
			RW:                  anggota.RW,
			RT:                  anggota.RT,
			Dusun:               anggota.Dusun,
			Alamat:              anggota.Alamat,
			KodeKeluarga:        anggota.KodeKeluarga,
			NamaKepalaKeluarga:  anggota.NamaKepalaKeluarga,
			NIK:                 nikPtr,
			NamaAnggotaKeluarga: anggota.NamaAnggotaKeluarga,
			JenisKelamin:        anggota.JenisKelamin,
			Hubungan:            anggota.Hubungan,
			TempatLahir:         anggota.TempatLahir,
			TanggalLahir:        tanggalLahir,
			Status:              anggota.Status,
			Agama:               anggota.Agama,
			GolonganDarah:       anggota.GolonganDarah,
			Kewarganegaraan:     anggota.Kewarganegaraan,
			EtnisSuku:           anggota.EtnisSuku,
			Pendidikan:          anggota.Pendidikan,
			Pekerjaan:           anggota.Pekerjaan,
			DesaID:              anggota.DesaID,
			PosyanduID:          anggota.PosyanduID,
			CreatedAt:           time.Now(),
			UpdatedAt:           time.Now(),
		}

		if err := u.kependudukanRepo.Create(penduduk); err != nil {
			return nil, err
		}
		createdPenduduk = append(createdPenduduk, penduduk)
	}

	// Mapping anggota untuk response
	resAnggota := make([]map[string]interface{}, 0, len(createdPenduduk))
	for _, p := range createdPenduduk {
		nik := ""
		if p.NIK != nil {
			nik = *p.NIK
		}
		resAnggota = append(resAnggota, map[string]interface{}{
			"penduduk_id":          p.IDKependudukan,
			"nik":                  nik,
			"nama_anggota_keluarga": p.NamaAnggotaKeluarga,
			"jenis_kelamin":        p.JenisKelamin,
			"tanggal_lahir":        p.TanggalLahir.Format("2006-01-02"),
			"hubungan":             p.Hubungan,
		})
	}

	// Ambil kode_keluarga dari anggota pertama
	kodeKeluarga := ""
	if len(createdPenduduk) > 0 {
		kodeKeluarga = createdPenduduk[0].KodeKeluarga
	}

	return map[string]interface{}{
		"kode_keluarga":    kodeKeluarga,
		"total_anggota":    len(createdPenduduk),
		"anggota_keluarga": resAnggota,
	}, nil
}

// =============================================
// LIST - Mendapatkan semua keluarga
// =============================================
func (u *AdminAkunKeluargaUsecase) ListKartuKeluarga(search string, page int, limit int, sortBy string, sortDir string) (map[string]interface{}, error) {
	if page <= 0 {
		page = 1
	}
	if limit <= 0 {
		limit = 10
	}
	if limit > 100 {
		limit = 100
	}

	// Ambil semua penduduk yang memiliki KodeKeluarga
	penduduks, err := u.kependudukanRepo.FindAllWithKodeKeluarga()
	if err != nil {
		return nil, customerror.NewInternalServiceError("gagal mengambil data keluarga")
	}

	// Group by KodeKeluarga
	keluargaMap := make(map[string][]models.Kependudukan)
	for _, p := range penduduks {
		if p.KodeKeluarga != "" {
			keluargaMap[p.KodeKeluarga] = append(keluargaMap[p.KodeKeluarga], p)
		}
	}

	items := make([]AdminListKartuKeluargaItem, 0, len(keluargaMap))
	for kode, anggota := range keluargaMap {
		var kepala interface{}
		for _, a := range anggota {
			if strings.EqualFold(strings.TrimSpace(a.Hubungan), "Kepala Keluarga") {
				nik := ""
				if a.NIK != nil {
					nik = *a.NIK
				}
				kepala = AdminKepalaKeluarga{
					PendudukID:          a.IDKependudukan,
					NIK:                 nik,
					NamaAnggotaKeluarga: a.NamaAnggotaKeluarga,
				}
				break
			}
		}
		if kepala == nil && len(anggota) > 0 {
			nik := ""
			if anggota[0].NIK != nil {
				nik = *anggota[0].NIK
			}
			kepala = AdminKepalaKeluarga{
				PendudukID:          anggota[0].IDKependudukan,
				NIK:                 nik,
				NamaAnggotaKeluarga: anggota[0].NamaAnggotaKeluarga,
			}
		}

		items = append(items, AdminListKartuKeluargaItem{
			KodeKeluarga:  kode,
			KepalaKeluarga: kepala,
			JumlahAnggota:  len(anggota),
			CreatedAt:     anggota[0].CreatedAt,
			UpdatedAt:     anggota[0].UpdatedAt,
		})
	}

	total := len(items)

	// Pagination manual
	start := (page - 1) * limit
	end := start + limit
	if start > total {
		start = total
	}
	if end > total {
		end = total
	}
	paginatedItems := items[start:end]

	totalPages := int(math.Ceil(float64(total) / float64(limit)))
	if total == 0 {
		totalPages = 0
	}

	return map[string]interface{}{
		"items": paginatedItems,
		"pagination": AdminListKartuKeluargaPagination{
			Page:       page,
			Limit:      limit,
			Total:      total,
			TotalPages: totalPages,
		},
	}, nil
}

// =============================================
// DETAIL - Mendapatkan detail keluarga
// =============================================
func (u *AdminAkunKeluargaUsecase) DetailKartuKeluarga(kodeKeluarga string) (*AdminDetailKartuKeluargaResponse, error) {
	if kodeKeluarga == "" {
		return nil, customerror.NewBadRequestError("kode_keluarga wajib diisi")
	}

	anggota, err := u.kependudukanRepo.FindByKodeKeluarga(kodeKeluarga)
	if err != nil {
		return nil, customerror.NewInternalServiceError("gagal mengambil data anggota keluarga")
	}

	if len(anggota) == 0 {
		return nil, customerror.NewNotFoundError("keluarga tidak ditemukan")
	}

	// Cari kepala keluarga
	var namaKepala string
	for _, a := range anggota {
		if strings.EqualFold(strings.TrimSpace(a.Hubungan), "Kepala Keluarga") {
			namaKepala = a.NamaAnggotaKeluarga
			break
		}
	}
	if namaKepala == "" {
		namaKepala = anggota[0].NamaAnggotaKeluarga
	}

	resAnggota := make([]AdminDetailKartuKeluargaAnggota, 0, len(anggota))
	for _, a := range anggota {
		resAnggota = append(resAnggota, mapPendudukToAnggota(a))
	}

	return &AdminDetailKartuKeluargaResponse{
		KodeKeluarga:       kodeKeluarga,
		NamaKepalaKeluarga: namaKepala,
		AnggotaKeluarga:    resAnggota,
	}, nil
}

// =============================================
// UPDATE KELUARGA - Update kode keluarga
// =============================================
func (u *AdminAkunKeluargaUsecase) UpdateKartuKeluarga(kodeKeluargaLama string, req *AdminUpdateKartuKeluargaRequest) (*AdminDetailKartuKeluargaResponse, error) {
	if req == nil {
		return nil, customerror.NewBadRequestError("request tidak valid")
	}

	req.KodeKeluarga = strings.TrimSpace(req.KodeKeluarga)
	if req.KodeKeluarga == "" {
		return nil, customerror.NewBadRequestError("kode_keluarga wajib diisi")
	}

	// Cek apakah keluarga ada
	anggota, err := u.kependudukanRepo.FindByKodeKeluarga(kodeKeluargaLama)
	if err != nil {
		return nil, customerror.NewInternalServiceError("gagal mengambil data anggota keluarga")
	}
	if len(anggota) == 0 {
		return nil, customerror.NewNotFoundError("keluarga tidak ditemukan")
	}

	// Cek apakah kode baru sudah dipakai
	existing, _ := u.kependudukanRepo.FindByKodeKeluarga(req.KodeKeluarga)
	if len(existing) > 0 && kodeKeluargaLama != req.KodeKeluarga {
		return nil, customerror.NewConflictError("kode_keluarga sudah dipakai")
	}

	// Update semua anggota dengan kode keluarga baru
	for _, a := range anggota {
		a.KodeKeluarga = req.KodeKeluarga
		a.UpdatedAt = time.Now()
		if err := u.kependudukanRepo.Update(&a); err != nil {
			return nil, customerror.NewInternalServiceError("gagal memperbarui anggota keluarga")
		}
	}

	return u.DetailKartuKeluarga(req.KodeKeluarga)
}

// =============================================
// UPDATE ANGGOTA KELUARGA
// =============================================
func (u *AdminAkunKeluargaUsecase) UpdateAnggotaKeluarga(pendudukID int32, req *AdminAnggotaKeluargaRequest) (*AdminDetailKartuKeluargaAnggota, error) {
	if req == nil {
		return nil, customerror.NewBadRequestError("request tidak valid")
	}

	anggota, err := u.kependudukanRepo.FindByID(pendudukID)
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, customerror.NewNotFoundError("anggota keluarga tidak ditemukan")
		}
		return nil, customerror.NewInternalServiceError("gagal mengambil data anggota keluarga")
	}

	// Trim semua field
	req.NIK = strings.TrimSpace(req.NIK)
	req.NamaAnggotaKeluarga = strings.TrimSpace(req.NamaAnggotaKeluarga)

	if req.NIK == "" || req.NamaAnggotaKeluarga == "" {
		return nil, customerror.NewBadRequestError("nik dan nama_anggota_keluarga wajib diisi")
	}

	if _, err := u.kependudukanRepo.FindByNIKExceptID(req.NIK, pendudukID); err == nil {
		return nil, customerror.NewConflictError("nik sudah dipakai")
	} else if err != gorm.ErrRecordNotFound {
		return nil, customerror.NewInternalServiceError("gagal validasi nik")
	}

	// Update tanggal lahir
	if req.TanggalLahir != "" {
		parsedTanggalLahir, err := time.Parse("2006-01-02", req.TanggalLahir)
		if err != nil {
			return nil, customerror.NewBadRequestError("format tanggal_lahir harus YYYY-MM-DD")
		}
		anggota.TanggalLahir = parsedTanggalLahir
	}

	// Update semua field
	nikPtr := &req.NIK
	anggota.NIK = nikPtr
	anggota.RW = req.RW
	anggota.RT = req.RT
	anggota.Dusun = req.Dusun
	anggota.Alamat = req.Alamat
	anggota.KodeKeluarga = req.KodeKeluarga
	anggota.NamaKepalaKeluarga = req.NamaKepalaKeluarga
	anggota.NamaAnggotaKeluarga = req.NamaAnggotaKeluarga
	anggota.JenisKelamin = req.JenisKelamin
	anggota.Hubungan = req.Hubungan
	anggota.TempatLahir = req.TempatLahir
	anggota.Status = req.Status
	anggota.Agama = req.Agama
	anggota.GolonganDarah = req.GolonganDarah
	anggota.Kewarganegaraan = req.Kewarganegaraan
	anggota.EtnisSuku = req.EtnisSuku
	anggota.Pendidikan = req.Pendidikan
	anggota.Pekerjaan = req.Pekerjaan
	anggota.DesaID = req.DesaID
	anggota.PosyanduID = req.PosyanduID
	anggota.UpdatedAt = time.Now()

	if err := u.kependudukanRepo.Update(anggota); err != nil {
		return nil, customerror.NewInternalServiceError("gagal memperbarui anggota keluarga")
	}

	res := mapPendudukToAnggota(*anggota)
	return &res, nil
}

// =============================================
// ADD ANGGOTA KELUARGA
// =============================================
func (u *AdminAkunKeluargaUsecase) AddAnggotaKeluarga(req *AdminAnggotaKeluargaRequest) (*AdminDetailKartuKeluargaAnggota, error) {
	if req == nil {
		return nil, customerror.NewBadRequestError("request tidak valid")
	}

	req.NIK = strings.TrimSpace(req.NIK)
	req.NamaAnggotaKeluarga = strings.TrimSpace(req.NamaAnggotaKeluarga)
	req.TanggalLahir = strings.TrimSpace(req.TanggalLahir)

	if req.NIK == "" || req.NamaAnggotaKeluarga == "" || req.TanggalLahir == "" {
		return nil, customerror.NewBadRequestError("nik, nama_anggota_keluarga, dan tanggal_lahir wajib diisi")
	}

	reqNIKPtr := &req.NIK
	if _, err := u.kependudukanRepo.FindByNIK(reqNIKPtr); err == nil {
		return nil, customerror.NewConflictError("nik sudah dipakai")
	} else if err != gorm.ErrRecordNotFound {
		return nil, customerror.NewInternalServiceError("gagal validasi nik")
	}

	tanggalLahir, err := time.Parse("2006-01-02", req.TanggalLahir)
	if err != nil {
		return nil, customerror.NewBadRequestError("format tanggal_lahir harus YYYY-MM-DD")
	}

	anggota := &models.Kependudukan{
		RW:                  req.RW,
		RT:                  req.RT,
		Dusun:               req.Dusun,
		Alamat:              req.Alamat,
		KodeKeluarga:        req.KodeKeluarga,
		NamaKepalaKeluarga:  req.NamaKepalaKeluarga,
		NIK:                 reqNIKPtr,
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
		Telepon:             req.Telepon,
		DesaID:              req.DesaID,
		PosyanduID:          req.PosyanduID,
		CreatedAt:           time.Now(),
		UpdatedAt:           time.Now(),
	}

	if err := u.kependudukanRepo.Create(anggota); err != nil {
		return nil, customerror.NewInternalServiceError("gagal menambahkan anggota keluarga")
	}

	res := mapPendudukToAnggota(*anggota)
	return &res, nil
}

// =============================================
// DELETE ANGGOTA KELUARGA
// =============================================
func (u *AdminAkunKeluargaUsecase) DeleteAnggotaKeluarga(pendudukID int32) error {
	anggota, err := u.kependudukanRepo.FindByID(pendudukID)
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			return customerror.NewNotFoundError("anggota keluarga tidak ditemukan")
		}
		return customerror.NewInternalServiceError("gagal mengambil data anggota keluarga")
	}

	if err := u.kependudukanRepo.SoftDeleteByID(anggota.IDKependudukan); err != nil {
		return customerror.NewInternalServiceError("gagal menghapus anggota keluarga")
	}

	return nil
}

// =============================================
// DELETE KELUARGA (Soft Delete semua anggota)
// =============================================
func (u *AdminAkunKeluargaUsecase) DeleteKartuKeluarga(kodeKeluarga string) error {
	if kodeKeluarga == "" {
		return customerror.NewBadRequestError("kode_keluarga wajib diisi")
	}

	anggota, err := u.kependudukanRepo.FindByKodeKeluarga(kodeKeluarga)
	if err != nil {
		return customerror.NewInternalServiceError("gagal mengambil data anggota keluarga")
	}
	if len(anggota) == 0 {
		return customerror.NewNotFoundError("keluarga tidak ditemukan")
	}

	// Soft delete semua anggota
	for _, a := range anggota {
		if err := u.kependudukanRepo.SoftDeleteByID(a.IDKependudukan); err != nil {
			return customerror.NewInternalServiceError("gagal menghapus anggota keluarga")
		}
	}

	return nil
}

// =============================================
// MAPPER
// =============================================
func mapPendudukToAnggota(a models.Kependudukan) AdminDetailKartuKeluargaAnggota {
	nik := ""
	if a.NIK != nil {
		nik = *a.NIK
	}
	tglLahir := ""
	if !a.TanggalLahir.IsZero() {
		tglLahir = a.TanggalLahir.Format("2006-01-02")
	}

	return AdminDetailKartuKeluargaAnggota{
		PendudukID:          a.IDKependudukan,
		RW:                  a.RW,
		RT:                  a.RT,
		Dusun:               a.Dusun,
		Alamat:              a.Alamat,
		KodeKeluarga:        a.KodeKeluarga,
		NamaKepalaKeluarga:  a.NamaKepalaKeluarga,
		NIK:                 nik,
		NamaAnggotaKeluarga: a.NamaAnggotaKeluarga,
		JenisKelamin:        a.JenisKelamin,
		Hubungan:            a.Hubungan,
		TempatLahir:         a.TempatLahir,
		TanggalLahir:        tglLahir,
		Status:              a.Status,
		Agama:               a.Agama,
		GolonganDarah:       a.GolonganDarah,
		Kewarganegaraan:     a.Kewarganegaraan,
		EtnisSuku:           a.EtnisSuku,
		Pendidikan:          a.Pendidikan,
		Pekerjaan:           a.Pekerjaan,
		DesaID:              a.DesaID,
		PosyanduID:          a.PosyanduID,
		
	}
}