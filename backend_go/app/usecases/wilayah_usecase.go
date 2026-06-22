package usecases

import (
	"strings"

	"monitoring-service/app/models"
	"monitoring-service/app/repositories"
	"monitoring-service/pkg/customerror"
)

type WilayahUsecase interface {
	// Provinsi
	ListProvinsi() ([]models.Provinsi, error)
	CreateProvinsi(req *models.Provinsi) error
	UpdateProvinsi(id int32, req *models.Provinsi) error
	DeleteProvinsi(id int32) error
	// Kabupaten
	ListKabupaten(provinsiID *int32) ([]models.Kabupaten, error)
	CreateKabupaten(req *models.Kabupaten) error
	UpdateKabupaten(id int32, req *models.Kabupaten) error
	DeleteKabupaten(id int32) error
	// Kecamatan
	ListKecamatan(kabupatenID *int32) ([]models.Kecamatan, error)
	CreateKecamatan(req *models.Kecamatan) error
	UpdateKecamatan(id int32, req *models.Kecamatan) error
	DeleteKecamatan(id int32) error
}

type wilayahUsecase struct {
	repo *repositories.WilayahRepository
}

func NewWilayahUsecase(repo *repositories.WilayahRepository) WilayahUsecase {
	return &wilayahUsecase{repo: repo}
}

// ===================== PROVINSI =====================

func (u *wilayahUsecase) ListProvinsi() ([]models.Provinsi, error) {
	return u.repo.ListProvinsi()
}

func (u *wilayahUsecase) CreateProvinsi(req *models.Provinsi) error {
	if req == nil {
		return customerror.NewBadRequestError("request tidak valid")
	}
	req.Nama = strings.TrimSpace(req.Nama)
	if req.Nama == "" {
		return customerror.NewBadRequestError("nama provinsi wajib diisi")
	}
	return u.repo.CreateProvinsi(req)
}

func (u *wilayahUsecase) UpdateProvinsi(id int32, req *models.Provinsi) error {
	if req == nil {
		return customerror.NewBadRequestError("request tidak valid")
	}
	existing, err := u.repo.GetProvinsi(id)
	if err != nil {
		return err
	}
	existing.Nama = strings.TrimSpace(req.Nama)
	if existing.Nama == "" {
		return customerror.NewBadRequestError("nama provinsi wajib diisi")
	}
	return u.repo.SaveProvinsi(existing)
}

func (u *wilayahUsecase) DeleteProvinsi(id int32) error {
	count, err := u.repo.CountKabupatenByProvinsi(id)
	if err != nil {
		return err
	}
	if count > 0 {
		return customerror.NewBadRequestError("provinsi tidak dapat dihapus karena masih memiliki kabupaten")
	}
	return u.repo.DeleteProvinsi(id)
}

// ===================== KABUPATEN =====================

func (u *wilayahUsecase) ListKabupaten(provinsiID *int32) ([]models.Kabupaten, error) {
	return u.repo.ListKabupaten(provinsiID)
}

func (u *wilayahUsecase) CreateKabupaten(req *models.Kabupaten) error {
	if req == nil {
		return customerror.NewBadRequestError("request tidak valid")
	}
	req.Nama = strings.TrimSpace(req.Nama)
	if req.ProvinsiID == 0 || req.Nama == "" {
		return customerror.NewBadRequestError("provinsi_id dan nama kabupaten wajib diisi")
	}
	if _, err := u.repo.GetProvinsi(req.ProvinsiID); err != nil {
		return customerror.NewBadRequestError("provinsi tidak ditemukan")
	}
	return u.repo.CreateKabupaten(req)
}

func (u *wilayahUsecase) UpdateKabupaten(id int32, req *models.Kabupaten) error {
	if req == nil {
		return customerror.NewBadRequestError("request tidak valid")
	}
	existing, err := u.repo.GetKabupaten(id)
	if err != nil {
		return err
	}
	existing.Nama = strings.TrimSpace(req.Nama)
	if req.ProvinsiID != 0 {
		existing.ProvinsiID = req.ProvinsiID
	}
	if existing.ProvinsiID == 0 || existing.Nama == "" {
		return customerror.NewBadRequestError("provinsi_id dan nama kabupaten wajib diisi")
	}
	existing.Provinsi = nil
	return u.repo.SaveKabupaten(existing)
}

func (u *wilayahUsecase) DeleteKabupaten(id int32) error {
	count, err := u.repo.CountKecamatanByKabupaten(id)
	if err != nil {
		return err
	}
	if count > 0 {
		return customerror.NewBadRequestError("kabupaten tidak dapat dihapus karena masih memiliki kecamatan")
	}
	return u.repo.DeleteKabupaten(id)
}

// ===================== KECAMATAN =====================

func (u *wilayahUsecase) ListKecamatan(kabupatenID *int32) ([]models.Kecamatan, error) {
	return u.repo.ListKecamatan(kabupatenID)
}

func (u *wilayahUsecase) CreateKecamatan(req *models.Kecamatan) error {
	if req == nil {
		return customerror.NewBadRequestError("request tidak valid")
	}
	req.Nama = strings.TrimSpace(req.Nama)
	if req.KabupatenID == 0 || req.Nama == "" {
		return customerror.NewBadRequestError("kabupaten_id dan nama kecamatan wajib diisi")
	}
	if _, err := u.repo.GetKabupaten(req.KabupatenID); err != nil {
		return customerror.NewBadRequestError("kabupaten tidak ditemukan")
	}
	return u.repo.CreateKecamatan(req)
}

func (u *wilayahUsecase) UpdateKecamatan(id int32, req *models.Kecamatan) error {
	if req == nil {
		return customerror.NewBadRequestError("request tidak valid")
	}
	existing, err := u.repo.GetKecamatan(id)
	if err != nil {
		return err
	}
	existing.Nama = strings.TrimSpace(req.Nama)
	if req.KabupatenID != 0 {
		existing.KabupatenID = req.KabupatenID
	}
	if existing.KabupatenID == 0 || existing.Nama == "" {
		return customerror.NewBadRequestError("kabupaten_id dan nama kecamatan wajib diisi")
	}
	existing.Kabupaten = nil
	return u.repo.SaveKecamatan(existing)
}

func (u *wilayahUsecase) DeleteKecamatan(id int32) error {
	count, err := u.repo.CountDesaByKecamatan(id)
	if err != nil {
		return err
	}
	if count > 0 {
		return customerror.NewBadRequestError("kecamatan tidak dapat dihapus karena masih digunakan oleh desa")
	}
	return u.repo.DeleteKecamatan(id)
}
