package usecases

import (
	"monitoring-service/app/models"
	"monitoring-service/app/repositories"

	"github.com/xuri/excelize/v2"
)

type LaporanRemajaUsecase interface {
	GetLaporanRemaja(startDate, endDate string, desaID *int32, role string) ([]models.LaporanRemaja, error)
	ExportExcelLaporanRemaja(startDate, endDate string, desaID *int32, role string) (*excelize.File, error)
}

type laporanRemajaUsecase struct {
	repo repositories.LaporanRemajaRepository
}

func NewLaporanRemajaUsecase(repo repositories.LaporanRemajaRepository) LaporanRemajaUsecase {
	return &laporanRemajaUsecase{repo}
}

func (u *laporanRemajaUsecase) GetLaporanRemaja(startDate, endDate string, desaID *int32, role string) ([]models.LaporanRemaja, error) {
	return u.repo.GetLaporanRemaja(startDate, endDate, desaID, role)
}

func (u *laporanRemajaUsecase) ExportExcelLaporanRemaja(startDate, endDate string, desaID *int32, role string) (*excelize.File, error) {
	data, err := u.repo.GetLaporanRemaja(startDate, endDate, desaID, role)
	if err != nil {
		return nil, err
	}

	f := excelize.NewFile()

	headerStyle, _ := f.NewStyle(&excelize.Style{
		Font:      &excelize.Font{Bold: true, Color: "FFFFFF", Size: 11},
		Fill:      excelize.Fill{Type: "pattern", Color: []string{"2563EB"}, Pattern: 1},
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

	sheet := "Data Remaja"
	f.SetSheetName("Sheet1", sheet)

	headers := []string{
		"No", "NIK", "Nama Lengkap", "Tanggal Lahir", "Umur", "Jenis Kelamin",
		"Tanggal Pemeriksaan", "Berat Badan (Kg)", "Tinggi Badan (Cm)", "IMT",
		"Tekanan Darah", "Kategori Risiko", "Status Pemantauan", "Riwayat Penyakit",
		"Catatan Khusus", "Kecamatan", "Desa",
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
			d.KategoriRisiko,
			d.StatusPemantauan,
			d.RiwayatPenyakit,
			d.CatatanKhusus,
			d.Kecamatan,
			d.Desa,
		}

		for colIdx, val := range rowData {
			cell, _ := excelize.CoordinatesToCellName(colIdx+1, rowNum)
			f.SetCellValue(sheet, cell, val)
			if colIdx == 0 || colIdx == 1 || colIdx == 4 || colIdx == 5 || colIdx == 6 || colIdx == 11 || colIdx == 12 {
				f.SetCellStyle(sheet, cell, cell, centerStyle)
			} else {
				f.SetCellStyle(sheet, cell, cell, dataStyle)
			}
		}
		f.SetRowHeight(sheet, rowNum, 20)
	}

	colWidths := map[int]float64{
		1: 6, 2: 20, 3: 25, 4: 15, 5: 8, 6: 15,
		7: 18, 8: 16, 9: 18, 10: 10, 11: 16, 12: 18,
		13: 18, 14: 25, 15: 25, 16: 18, 17: 18,
	}
	for col, width := range colWidths {
		colName, _ := excelize.ColumnNumberToName(col)
		f.SetColWidth(sheet, colName, colName, width)
	}

	return f, nil
}
