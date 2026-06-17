package usecases

import (
	"monitoring-service/app/models"
	"monitoring-service/app/repositories"

	"github.com/xuri/excelize/v2"
)

type LaporanLansiaUsecase interface {
	GetLaporanLansia(startDate, endDate string, desaID *int32, role string) ([]models.LaporanLansia, error)
	ExportExcelLaporanLansia(startDate, endDate string, desaID *int32, role string) (*excelize.File, error)
}

type laporanLansiaUsecase struct {
	repo repositories.LaporanLansiaRepository
}

func NewLaporanLansiaUsecase(repo repositories.LaporanLansiaRepository) LaporanLansiaUsecase {
	return &laporanLansiaUsecase{repo}
}

func (u *laporanLansiaUsecase) GetLaporanLansia(startDate, endDate string, desaID *int32, role string) ([]models.LaporanLansia, error) {
	return u.repo.GetLaporanLansia(startDate, endDate, desaID, role)
}

func (u *laporanLansiaUsecase) ExportExcelLaporanLansia(startDate, endDate string, desaID *int32, role string) (*excelize.File, error) {
	data, err := u.repo.GetLaporanLansia(startDate, endDate, desaID, role)
	if err != nil {
		return nil, err
	}

	f := excelize.NewFile()

	headerStyle, _ := f.NewStyle(&excelize.Style{
		Font:      &excelize.Font{Bold: true, Color: "FFFFFF", Size: 11},
		Fill:      excelize.Fill{Type: "pattern", Color: []string{"EA580C"}, Pattern: 1},
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

	centerStyle, _ := f.NewStyle(&excelize.Style{
		Border: []excelize.Border{
			{Type: "left", Color: "E0E0E0", Style: 1},
			{Type: "right", Color: "E0E0E0", Style: 1},
			{Type: "top", Color: "E0E0E0", Style: 1},
			{Type: "bottom", Color: "E0E0E0", Style: 1},
		},
		Alignment: &excelize.Alignment{Horizontal: "center", Vertical: "center"},
	})

	sheet := "Data Lansia"
	f.SetSheetName("Sheet1", sheet)

	headers := []string{
		"No", "NIK", "Nama Lengkap", "Tanggal Lahir", "Umur", "Jenis Kelamin",
		"Tanggal Pemeriksaan", "Berat Badan (Kg)", "Tinggi Badan (Cm)", "IMT",
		"Tekanan Darah", "Gula Darah", "Kategori Risiko", "Status Pemantauan",
		"Penyakit Kronis", "Status Kemandirian", "Riwayat Jatuh", "Catatan Khusus",
		"Kecamatan", "Desa",
	}

	for colIdx, h := range headers {
		cell, _ := excelize.CoordinatesToCellName(colIdx+1, 1)
		f.SetCellValue(sheet, cell, h)
		f.SetCellStyle(sheet, cell, cell, headerStyle)
	}
	f.SetRowHeight(sheet, 1, 26)

	for rowIdx, d := range data {
		rowNum := rowIdx + 2
		tglLahirStr := ""
		if !d.TanggalLahir.IsZero() && d.TanggalLahir.Year() >= 1900 {
			tglLahirStr = d.TanggalLahir.Format("2006-01-02")
		}
		tglPeriksaStr := ""
		if !d.TanggalPemeriksaan.IsZero() && d.TanggalPemeriksaan.Year() >= 1900 {
			tglPeriksaStr = d.TanggalPemeriksaan.Format("2006-01-02")
		}

		rowData := []interface{}{
			rowIdx + 1,
			d.NIK,
			d.NamaLengkap,
			tglLahirStr,
			d.Umur,
			d.JenisKelamin,
			tglPeriksaStr,
			d.BeratBadan,
			d.TinggiBadan,
			d.IMT,
			d.TekananDarah,
			d.GulaDarah,
			d.KategoriRisiko,
			d.StatusPemantauan,
			d.PenyakitKronis,
			d.StatusKemandirian,
			d.RiwayatJatuh,
			d.CatatanKhusus,
			d.Kecamatan,
			d.Desa,
		}

		for colIdx, val := range rowData {
			cell, _ := excelize.CoordinatesToCellName(colIdx+1, rowNum)
			f.SetCellValue(sheet, cell, val)
			if colIdx == 0 || colIdx == 1 || colIdx == 4 || colIdx == 5 || colIdx == 6 || colIdx == 12 || colIdx == 13 || colIdx == 16 {
				f.SetCellStyle(sheet, cell, cell, centerStyle)
			} else {
				f.SetCellStyle(sheet, cell, cell, dataStyle)
			}
		}
		f.SetRowHeight(sheet, rowNum, 20)
	}

	colWidths := map[int]float64{
		1: 6, 2: 20, 3: 25, 4: 15, 5: 8, 6: 15,
		7: 18, 8: 16, 9: 18, 10: 10, 11: 16, 12: 14,
		13: 18, 14: 18, 15: 20, 16: 16, 17: 25, 18: 18, 19: 18,
	}
	for col, width := range colWidths {
		colName, _ := excelize.ColumnNumberToName(col)
		f.SetColWidth(sheet, colName, colName, width)
	}

	return f, nil
}
