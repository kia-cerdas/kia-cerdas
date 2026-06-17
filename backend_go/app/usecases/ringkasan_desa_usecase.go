package usecases

import (
	"monitoring-service/app/middlewares"
	"monitoring-service/app/models"
	"monitoring-service/app/repositories"
)

type RingkasanDesaUsecase interface {
	GetRingkasanDesaKader(desaID *int32, role string) (*models.RingkasanDesaResponse, error)
}

type ringkasanDesaUsecase struct {
	repo *repositories.RingkasanDesaRepository
}

func NewRingkasanDesaUsecase(repo *repositories.RingkasanDesaRepository) RingkasanDesaUsecase {
	return &ringkasanDesaUsecase{repo: repo}
}

// verifikasiLabels mendefinisikan urutan & label menu verifikasi yang ditampilkan di dashboard kader.
var verifikasiLabels = []struct {
	Key   string
	Label string
}{
	{Key: "kelas_ibu_balita", Label: "Kelas Ibu Balita"},
	{Key: "kelas_ibu_hamil", Label: "Kelas Ibu Hamil"},
	{Key: "pemantauan_ibu_hamil", Label: "Pemantauan Ibu Hamil"},
	{Key: "pemantauan_ibu_nifas", Label: "Pemantauan Ibu Nifas"},
}

func emptyVerifikasiItems() []models.RingkasanVerifikasiItem {
	items := make([]models.RingkasanVerifikasiItem, 0, len(verifikasiLabels))
	for _, v := range verifikasiLabels {
		items = append(items, models.RingkasanVerifikasiItem{Key: v.Key, Label: v.Label})
	}
	return items
}

// GetRingkasanDesaKader mengambil ringkasan kondisi desa (ibu hamil per trimester, jumlah anak,
// jumlah kunjungan yang perlu ditindak lanjuti, dan status verifikasi tiap menu) yang relevan
// untuk kader yang login. Kader hanya melihat data desanya sendiri (desaID dari JWT, hasil dari
// penduduk.desa_id miliknya); role dengan akses penuh (dokter/admin/superadmin) melihat seluruh desa.
func (u *ringkasanDesaUsecase) GetRingkasanDesaKader(desaID *int32, role string) (*models.RingkasanDesaResponse, error) {
	result := &models.RingkasanDesaResponse{DesaID: desaID, Verifikasi: emptyVerifikasiItems()}

	var filterDesaID *int32
	if !middlewares.HasFullAccess(role) {
		filterDesaID = desaID
		if filterDesaID == nil {
			// Kader belum terhubung dengan desa manapun, tidak ada data yang bisa ditampilkan.
			return result, nil
		}
	}

	t1, t2, t3, err := u.repo.CountIbuHamilByTrimester(filterDesaID)
	if err != nil {
		return nil, err
	}
	result.IbuHamil = models.RingkasanIbuHamil{
		Total:      t1 + t2 + t3,
		Trimester1: t1,
		Trimester2: t2,
		Trimester3: t3,
	}

	jumlahAnak, err := u.repo.CountAnak(filterDesaID)
	if err != nil {
		return nil, err
	}
	result.JumlahAnak = jumlahAnak

	perluTindakLanjut, err := u.repo.CountPerluTindakLanjut(filterDesaID)
	if err != nil {
		return nil, err
	}
	result.PerluTindakLanjut = perluTindakLanjut

	verifikasi, err := u.buildVerifikasiItems(filterDesaID)
	if err != nil {
		return nil, err
	}
	result.Verifikasi = verifikasi

	if filterDesaID != nil {
		if nama, err := u.repo.GetDesaName(*filterDesaID); err == nil {
			result.NamaDesa = nama
		}
	}

	return result, nil
}

func (u *ringkasanDesaUsecase) buildVerifikasiItems(filterDesaID *int32) ([]models.RingkasanVerifikasiItem, error) {
	totalBalita, sudahBalita, err := u.repo.CountVerifikasiKelasIbuBalita(filterDesaID)
	if err != nil {
		return nil, err
	}

	totalKelasHamil, sudahKelasHamil, err := u.repo.CountVerifikasiKelasIbuHamil(filterDesaID)
	if err != nil {
		return nil, err
	}

	totalPemantauanHamil, sudahPemantauanHamil, err := u.repo.CountVerifikasiPemantauanIbuHamil(filterDesaID)
	if err != nil {
		return nil, err
	}

	totalNifas, sudahNifas, err := u.repo.CountVerifikasiPemantauanIbuNifas(filterDesaID)
	if err != nil {
		return nil, err
	}

	counts := map[string][2]int64{
		"kelas_ibu_balita":      {totalBalita, sudahBalita},
		"kelas_ibu_hamil":       {totalKelasHamil, sudahKelasHamil},
		"pemantauan_ibu_hamil":  {totalPemantauanHamil, sudahPemantauanHamil},
		"pemantauan_ibu_nifas":  {totalNifas, sudahNifas},
	}

	items := make([]models.RingkasanVerifikasiItem, 0, len(verifikasiLabels))
	for _, v := range verifikasiLabels {
		c := counts[v.Key]
		total, sudah := c[0], c[1]
		items = append(items, models.RingkasanVerifikasiItem{
			Key:             v.Key,
			Label:           v.Label,
			Total:           total,
			SudahVerifikasi: sudah,
			BelumVerifikasi: total - sudah,
		})
	}

	return items, nil
}
