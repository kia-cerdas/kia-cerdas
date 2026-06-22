package usecases

import (
	"encoding/json"
	"errors"
	"fmt"
	"sort"
	"strings"

	"monitoring-service/app/models"
	"monitoring-service/app/repositories"

	"github.com/xuri/excelize/v2"
)

type LaporanDewasaUsecase interface {
	GetLaporanDewasa(startDate, endDate string, posyanduID *int32, role string) ([]models.LaporanDewasa, error)
	ExportExcelLaporanDewasa(startDate, endDate string, posyanduID *int32, role string) (*excelize.File, error)
	GetDynamicHeaders(data []models.LaporanDewasa) []string
}

type laporanDewasaUsecase struct {
	repo repositories.LaporanDewasaRepository
}

func NewLaporanDewasaUsecase(repo repositories.LaporanDewasaRepository) LaporanDewasaUsecase {
	return &laporanDewasaUsecase{repo}
}

func (u *laporanDewasaUsecase) GetLaporanDewasa(startDate, endDate string, posyanduID *int32, role string) ([]models.LaporanDewasa, error) {
	data, err := u.repo.GetLaporanDewasa(startDate, endDate, posyanduID, role)
	if err != nil {
		return nil, err
	}

	// Parse jawaban untuk setiap data
	for i := range data {
		if data[i].JawabanRaw != "" {
			var jawaban map[string]interface{}
			if err := json.Unmarshal([]byte(data[i].JawabanRaw), &jawaban); err == nil {
				data[i].DynamicFields = jawaban
			}
		}
	}

	return data, nil
}

func (u *laporanDewasaUsecase) GetDynamicHeaders(data []models.LaporanDewasa) []string {
	var allKeys []string
	keySet := make(map[string]bool)

	for _, d := range data {
		if d.DynamicFields != nil {
			for key := range d.DynamicFields {
				keySet[key] = true
			}
		}
	}

	for key := range keySet {
		allKeys = append(allKeys, key)
	}
	sort.Strings(allKeys)

	// Format headers
	var headers []string
	for _, key := range allKeys {
		header := strings.ReplaceAll(key, "_", " ")
		header = strings.Title(header)
		headers = append(headers, header)
	}

	return headers
}

func (u *laporanDewasaUsecase) ExportExcelLaporanDewasa(startDate, endDate string, posyanduID *int32, role string) (*excelize.File, error) {
	data, err := u.GetLaporanDewasa(startDate, endDate, posyanduID, role)
	if err != nil {
		return nil, err
	}

	if len(data) == 0 {
		return nil, errors.New("tidak ada data untuk diekspor")
	}

	f := excelize.NewFile()
	sheet := "Data Dewasa"
	f.SetSheetName("Sheet1", sheet)

	// ========== BUILD DYNAMIC HEADERS ==========

	// 1. Fixed headers
	fixedHeaders := []string{
		"No", "NIK", "Nama Lengkap", "Tanggal Lahir", "Umur", "Jenis Kelamin",
		"Dusun", "RT", "RW", "Desa", "Tanggal Pemeriksaan",
		"Kategori Risiko", "Rekomendasi",
	}

	// 2. Dynamic headers dari jawaban JSON
	dynamicHeaders := u.GetDynamicHeaders(data)

	// 3. Gabungkan semua headers
	allHeaders := append(fixedHeaders, dynamicHeaders...)

	// ========== STYLES ==========
	// Header dengan warna BIRU (#185FA5) untuk Dewasa (sama dengan remaja)
	headerStyle, _ := f.NewStyle(&excelize.Style{
		Font:      &excelize.Font{Bold: true, Color: "FFFFFF", Size: 11},
		Fill:      excelize.Fill{Type: "pattern", Color: []string{"185FA5"}, Pattern: 1},
		Alignment: &excelize.Alignment{Horizontal: "center", Vertical: "center"},
		Border: []excelize.Border{
			{Type: "left", Color: "D9D9D9", Style: 1},
			{Type: "right", Color: "D9D9D9", Style: 1},
			{Type: "top", Color: "D9D9D9", Style: 1},
			{Type: "bottom", Color: "D9D9D9", Style: 1},
		},
	})

	dataStyle, _ := f.NewStyle(&excelize.Style{
		Border: []excelize.Border{
			{Type: "left", Color: "E0E0E0", Style: 1},
			{Type: "right", Color: "E0E0E0", Style: 1},
			{Type: "top", Color: "E0E0E0", Style: 1},
			{Type: "bottom", Color: "E0E0E0", Style: 1},
		},
		Alignment: &excelize.Alignment{Vertical: "center"},
	})

	// ========== SET HEADERS ==========
	for colIdx, header := range allHeaders {
		cell, _ := excelize.CoordinatesToCellName(colIdx+1, 1)
		f.SetCellValue(sheet, cell, header)
		f.SetCellStyle(sheet, cell, cell, headerStyle)
	}
	f.SetRowHeight(sheet, 1, 26)

	// ========== FILL DATA ==========
	for rowIdx, d := range data {
		rowNum := rowIdx + 2
		colIdx := 1

		// Fixed data
		fixedData := []interface{}{
			rowIdx + 1,
			d.NIK,
			d.NamaLengkap,
			d.TanggalLahir.Format("2006-01-02"),
			d.Umur,
			d.JenisKelamin,
			d.Dusun,
			d.RT,
			d.RW,
			d.Desa,
			d.TanggalPemeriksaan.Format("2006-01-02"),
			d.KategoriRisiko,
			d.Rekomendasi,
		}

		for _, val := range fixedData {
			cell, _ := excelize.CoordinatesToCellName(colIdx, rowNum)
			f.SetCellValue(sheet, cell, val)
			f.SetCellStyle(sheet, cell, cell, dataStyle)
			colIdx++
		}

		// Dynamic data dari jawaban JSON
		// Get sorted keys
		var keys []string
		if d.DynamicFields != nil {
			for key := range d.DynamicFields {
				keys = append(keys, key)
			}
			sort.Strings(keys)
		}

		for _, key := range keys {
			cell, _ := excelize.CoordinatesToCellName(colIdx, rowNum)
			val := ""
			if d.DynamicFields != nil {
				if v, ok := d.DynamicFields[key]; ok && v != nil {
					val = formatValueDewasa(v)
				}
			}
			f.SetCellValue(sheet, cell, val)
			f.SetCellStyle(sheet, cell, cell, dataStyle)
			colIdx++
		}

		f.SetRowHeight(sheet, rowNum, 20)
	}

	// Auto adjust column width
	for colIdx := range allHeaders {
		colName, _ := excelize.ColumnNumberToName(colIdx + 1)
		f.SetColWidth(sheet, colName, colName, 18)
	}

	return f, nil
}

// formatValueDewasa - Format value untuk Excel Dewasa
func formatValueDewasa(v interface{}) string {
	if v == nil {
		return ""
	}
	switch val := v.(type) {
	case bool:
		if val {
			return "Ya"
		}
		return "Tidak"
	case float64:
		if val == float64(int(val)) {
			return fmt.Sprintf("%d", int(val))
		}
		return fmt.Sprintf("%.2f", val)
	case string:
		return val
	default:
		return fmt.Sprintf("%v", val)
	}
}