package usecases

import (
	"strings"
	"time"

	"monitoring-service/app/models"
	"monitoring-service/app/repositories"
	"monitoring-service/pkg/customerror"
)

type DesaUsecase interface {
	GetAll() ([]models.Desa, error)
	GetByID(id int32) (*models.Desa, error)
	Create(req *models.Desa) error
	Update(id int32, req *models.Desa) error
	Deactivate(id int32) error
}

type desaUsecase struct {
	repo *repositories.DesaRepository
}

func NewDesaUsecase(repo *repositories.DesaRepository) DesaUsecase {
	return &desaUsecase{repo: repo}
}

func trimDesaInput(value string) string {
	return strings.TrimSpace(value)
}

func (u *desaUsecase) GetAll() ([]models.Desa, error) {
	return u.repo.GetAll()
}

func (u *desaUsecase) GetByID(id int32) (*models.Desa, error) {
	return u.repo.GetByID(id)
}

func (u *desaUsecase) Create(req *models.Desa) error {
	if req == nil {
		return customerror.NewBadRequestError("request tidak valid")
	}

	req.Kecamatan = trimDesaInput(req.Kecamatan)
	req.Kabupaten = trimDesaInput(req.Kabupaten)
	req.Provinsi = trimDesaInput(req.Provinsi)
	req.NamaDesa = trimDesaInput(req.NamaDesa)
	req.KodeDesa = trimDesaInput(req.KodeDesa)
	req.Keterangan = trimDesaInput(req.Keterangan)
	req.IsActive = true
	req.DeletedAt = nil

	if req.Kecamatan == "" || req.Kabupaten == "" || req.Provinsi == "" || req.NamaDesa == "" || req.KodeDesa == "" {
		return customerror.NewBadRequestError("kecamatan, kabupaten, provinsi, nama_desa, dan kode_desa wajib diisi")
	}

	return u.repo.Create(req)
}

func (u *desaUsecase) Update(id int32, req *models.Desa) error {
	if req == nil {
		return customerror.NewBadRequestError("request tidak valid")
	}

	existing, err := u.repo.GetByID(id)
	if err != nil {
		return err
	}

	existing.Kecamatan = trimDesaInput(req.Kecamatan)
	existing.Kabupaten = trimDesaInput(req.Kabupaten)
	existing.Provinsi = trimDesaInput(req.Provinsi)
	existing.NamaDesa = trimDesaInput(req.NamaDesa)
	existing.KodeDesa = trimDesaInput(req.KodeDesa)
	existing.Keterangan = trimDesaInput(req.Keterangan)
	existing.UpdatedAt = time.Now()
	existing.DeletedAt = nil

	if existing.Kecamatan == "" || existing.Kabupaten == "" || existing.Provinsi == "" || existing.NamaDesa == "" || existing.KodeDesa == "" {
		return customerror.NewBadRequestError("kecamatan, kabupaten, provinsi, nama_desa, dan kode_desa wajib diisi")
	}

	return u.repo.Save(existing)
}

func (u *desaUsecase) Deactivate(id int32) error {
	return u.repo.Deactivate(id)
}
