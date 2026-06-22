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
	repo        *repositories.DesaRepository
	wilayahRepo *repositories.WilayahRepository
}

func NewDesaUsecase(repo *repositories.DesaRepository, wilayahRepo *repositories.WilayahRepository) DesaUsecase {
	return &desaUsecase{repo: repo, wilayahRepo: wilayahRepo}
}

func trimDesaInput(value string) string {
	return strings.TrimSpace(value)
}

// applyKecamatanMaster mengisi string Kecamatan/Kabupaten/Provinsi dari master
// ketika KecamatanID diberikan, supaya tetap sinkron & kompatibel dengan modul lain.
// Return error bila kecamatan_id tidak ditemukan.
func (u *desaUsecase) applyKecamatanMaster(d *models.Desa) error {
	if d.KecamatanID == nil {
		return nil
	}
	kec, err := u.wilayahRepo.GetKecamatan(*d.KecamatanID)
	if err != nil {
		return customerror.NewBadRequestError("kecamatan tidak ditemukan")
	}
	d.Kecamatan = kec.Nama
	if kec.Kabupaten != nil {
		d.Kabupaten = kec.Kabupaten.Nama
		if kec.Kabupaten.Provinsi != nil {
			d.Provinsi = kec.Kabupaten.Provinsi.Nama
		}
	}
	return nil
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

	// Bila kecamatan_id dikirim, isi string dari master (sinkron).
	if err := u.applyKecamatanMaster(req); err != nil {
		return err
	}

	if req.NamaDesa == "" || req.KodeDesa == "" {
		return customerror.NewBadRequestError("nama_desa dan kode_desa wajib diisi")
	}
	if req.Kecamatan == "" || req.Kabupaten == "" || req.Provinsi == "" {
		return customerror.NewBadRequestError("wilayah (kecamatan) wajib dipilih")
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
	existing.KecamatanID = req.KecamatanID
	existing.UpdatedAt = time.Now()
	existing.DeletedAt = nil

	// Bila kecamatan_id dikirim, isi string dari master (sinkron).
	if err := u.applyKecamatanMaster(existing); err != nil {
		return err
	}

	if existing.NamaDesa == "" || existing.KodeDesa == "" {
		return customerror.NewBadRequestError("nama_desa dan kode_desa wajib diisi")
	}
	if existing.Kecamatan == "" || existing.Kabupaten == "" || existing.Provinsi == "" {
		return customerror.NewBadRequestError("wilayah (kecamatan) wajib dipilih")
	}

	return u.repo.Save(existing)
}

func (u *desaUsecase) Deactivate(id int32) error {
	return u.repo.Deactivate(id)
}
