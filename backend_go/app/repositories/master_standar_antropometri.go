package repositories

import (
	"fmt"
	"sync"

	"monitoring-service/app/models"
	"monitoring-service/pkg/customerror"
)

var (
	standarAntropometriCache sync.Map
	masterStandarFilterCache sync.Map
)

func (m *Main) GetStandarAntropometri(parameter, jenisKelamin string, nilaiSumbuX float64) (*models.MasterStandarAntropometri, error) {
	gender := normalizeGender(jenisKelamin)
	cacheKey := fmt.Sprintf("%s|%s|%f", parameter, gender, nilaiSumbuX)

	if val, ok := standarAntropometriCache.Load(cacheKey); ok {
		return val.(*models.MasterStandarAntropometri), nil
	}

	var exact models.MasterStandarAntropometri
	err := m.postgres.Where("parameter = ? AND jenis_kelamin = ? AND nilai_sumbu_x = ?", parameter, gender, nilaiSumbuX).First(&exact).Error
	if err == nil {
		standarAntropometriCache.Store(cacheKey, &exact)
		return &exact, nil
	}

	var lower models.MasterStandarAntropometri
	lowerErr := m.postgres.Where("parameter = ? AND jenis_kelamin = ? AND nilai_sumbu_x <= ?", parameter, gender, nilaiSumbuX).
		Order("nilai_sumbu_x DESC").First(&lower).Error

	var upper models.MasterStandarAntropometri
	upperErr := m.postgres.Where("parameter = ? AND jenis_kelamin = ? AND nilai_sumbu_x >= ?", parameter, gender, nilaiSumbuX).
		Order("nilai_sumbu_x ASC").First(&upper).Error

	if lowerErr != nil && upperErr != nil {
		// jika tidak ada data untuk kombinasi parameter+gender, coba tanpa filter gender
		var anyLower models.MasterStandarAntropometri
		anyLowerErr := m.postgres.Where("parameter = ? AND nilai_sumbu_x <= ?", parameter, nilaiSumbuX).
			Order("nilai_sumbu_x DESC").First(&anyLower).Error

		var anyUpper models.MasterStandarAntropometri
		anyUpperErr := m.postgres.Where("parameter = ? AND nilai_sumbu_x >= ?", parameter, nilaiSumbuX).
			Order("nilai_sumbu_x ASC").First(&anyUpper).Error

		if anyLowerErr != nil && anyUpperErr != nil {
			return nil, customerror.NewNotFoundError("master standar antropometri tidak ditemukan")
		}

		if anyLowerErr != nil {
			standarAntropometriCache.Store(cacheKey, &anyUpper)
			return &anyUpper, nil
		}
		if anyUpperErr != nil {
			standarAntropometriCache.Store(cacheKey, &anyLower)
			return &anyLower, nil
		}

		if anyUpper.NilaiSumbuX == anyLower.NilaiSumbuX {
			standarAntropometriCache.Store(cacheKey, &anyLower)
			return &anyLower, nil
		}

		ratio := (nilaiSumbuX - anyLower.NilaiSumbuX) / (anyUpper.NilaiSumbuX - anyLower.NilaiSumbuX)
		interpolate := func(a, b float64) float64 {
			return a + ratio*(b-a)
		}

		interpolated := models.MasterStandarAntropometri{
			Parameter:    parameter,
			JenisKelamin: anyLower.JenisKelamin,
			NilaiSumbuX:  nilaiSumbuX,
			SD3Neg:       interpolate(anyLower.SD3Neg, anyUpper.SD3Neg),
			SD2Neg:       interpolate(anyLower.SD2Neg, anyUpper.SD2Neg),
			SD1Neg:       interpolate(anyLower.SD1Neg, anyUpper.SD1Neg),
			Median:       interpolate(anyLower.Median, anyUpper.Median),
			SD1Pos:       interpolate(anyLower.SD1Pos, anyUpper.SD1Pos),
			SD2Pos:       interpolate(anyLower.SD2Pos, anyUpper.SD2Pos),
			SD3Pos:       interpolate(anyLower.SD3Pos, anyUpper.SD3Pos),
		}

		standarAntropometriCache.Store(cacheKey, &interpolated)
		return &interpolated, nil
	}

	if lowerErr != nil {
		standarAntropometriCache.Store(cacheKey, &upper)
		return &upper, nil
	}
	if upperErr != nil {
		standarAntropometriCache.Store(cacheKey, &lower)
		return &lower, nil
	}

	if upper.NilaiSumbuX == lower.NilaiSumbuX {
		standarAntropometriCache.Store(cacheKey, &lower)
		return &lower, nil
	}

	ratio := (nilaiSumbuX - lower.NilaiSumbuX) / (upper.NilaiSumbuX - lower.NilaiSumbuX)
	interpolate := func(a, b float64) float64 {
		return a + ratio*(b-a)
	}

	interpolated := models.MasterStandarAntropometri{
		Parameter:    parameter,
		JenisKelamin: lower.JenisKelamin,
		NilaiSumbuX:  nilaiSumbuX,
		SD3Neg:       interpolate(lower.SD3Neg, upper.SD3Neg),
		SD2Neg:       interpolate(lower.SD2Neg, upper.SD2Neg),
		SD1Neg:       interpolate(lower.SD1Neg, upper.SD1Neg),
		Median:       interpolate(lower.Median, upper.Median),
		SD1Pos:       interpolate(lower.SD1Pos, upper.SD1Pos),
		SD2Pos:       interpolate(lower.SD2Pos, upper.SD2Pos),
		SD3Pos:       interpolate(lower.SD3Pos, upper.SD3Pos),
	}

	standarAntropometriCache.Store(cacheKey, &interpolated)
	return &interpolated, nil
}

func (m *Main) GetMasterStandarByFilter(parameter, jenisKelamin string) ([]models.MasterStandarAntropometri, error) {
	gender := normalizeGender(jenisKelamin)
	cacheKey := fmt.Sprintf("%s|%s", parameter, gender)

	if val, ok := masterStandarFilterCache.Load(cacheKey); ok {
		return val.([]models.MasterStandarAntropometri), nil
	}

	var result []models.MasterStandarAntropometri
	q := m.postgres.Model(&models.MasterStandarAntropometri{})
	if parameter != "" {
		q = q.Where("parameter = ?", parameter)
	}
	if gender != "" {
		q = q.Where("jenis_kelamin = ?", gender)
	}

	if err := q.Order("parameter ASC, jenis_kelamin ASC, nilai_sumbu_x ASC").Find(&result).Error; err != nil {
		return nil, customerror.NewInternalServiceError("gagal mengambil master standar antropometri")
	}

	masterStandarFilterCache.Store(cacheKey, result)
	return result, nil
}

func (m *Main) CreateMasterStandar(data *models.MasterStandarAntropometri) error {
	if err := m.postgres.Create(data).Error; err != nil {
		return customerror.NewInternalServiceError("gagal membuat master standar antropometri")
	}
	return nil
}
