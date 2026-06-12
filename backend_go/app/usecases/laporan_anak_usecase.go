package usecases

import (
	"fmt"
	"time"

	"monitoring-service/app/models"
	"monitoring-service/app/repositories"

	"github.com/xuri/excelize/v2"
)

type LaporanAnakUsecase interface {
	GetLaporanAnak(startDate, endDate string, desaID *int32, role string) (models.LaporanAnakPreviewResponse, error)
	ExportExcelLaporanAnak(startDate, endDate string, desaID *int32, role string) (*excelize.File, error)
}

type laporanAnakUsecase struct {
	repo repositories.LaporanAnakRepository
}

func NewLaporanAnakUsecase(repo repositories.LaporanAnakRepository) LaporanAnakUsecase {
	return &laporanAnakUsecase{repo}
}

// GetLaporanAnak mengambil data laporan anak lengkap (preview JSON).
func (u *laporanAnakUsecase) GetLaporanAnak(startDate, endDate string, desaID *int32, role string) (models.LaporanAnakPreviewResponse, error) {
	var resp models.LaporanAnakPreviewResponse

	anakList, err := u.repo.GetLaporanAnak(startDate, endDate, desaID, role)
	if err != nil {
		return resp, err
	}
	// Hitung usia untuk setiap anak
	for i := range anakList {
		anakList[i].Usia = hitungUsia(anakList[i].TanggalLahir)
	}
	resp.Anak = anakList

	pertumbuhanList, err := u.repo.GetLaporanPertumbuhan(startDate, endDate, desaID, role)
	if err != nil {
		return resp, err
	}
	resp.Pertumbuhan = pertumbuhanList

	imunisasiList, err := u.repo.GetLaporanImunisasi(startDate, endDate, desaID, role)
	if err != nil {
		return resp, err
	}
	resp.Imunisasi = imunisasiList

	return resp, nil
}

// ExportExcelLaporanAnak membuat file Excel 3 Sheet.
func (u *laporanAnakUsecase) ExportExcelLaporanAnak(startDate, endDate string, desaID *int32, role string) (*excelize.File, error) {
	// Fetch all data
	anakList, err := u.repo.GetLaporanAnak(startDate, endDate, desaID, role)
	if err != nil {
		return nil, err
	}
	pertumbuhanList, err := u.repo.GetLaporanPertumbuhan(startDate, endDate, desaID, role)
	if err != nil {
		return nil, err
	}
	imunisasiList, err := u.repo.GetLaporanImunisasi(startDate, endDate, desaID, role)
	if err != nil {
		return nil, err
	}

	f := excelize.NewFile()

	// Define styles
	headerStyle, _ := f.NewStyle(&excelize.Style{
		Font:      &excelize.Font{Bold: true, Color: "FFFFFF", Size: 11},
		Fill:      excelize.Fill{Type: "pattern", Color: []string{"2F5597"}, Pattern: 1}, // Sleek Navy
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

	// ─────────────────────────────────────────────────────────
	// SHEET 1: Data Anak
	// ─────────────────────────────────────────────────────────
	sheet1 := "Data Anak"
	f.SetSheetName("Sheet1", sheet1)

	headers1 := []string{
		"No", "No KK", "NIK Anak", "Nama Anak", "Nama Ibu", "Nama Ayah",
		"Tanggal Lahir", "Usia", "Berat Lahir (Kg)", "Tinggi Lahir (Cm)",
		"LILA", "Golongan Darah", "Kecamatan", "Desa",
	}

	for colIdx, h := range headers1 {
		cell, _ := excelize.CoordinatesToCellName(colIdx+1, 1)
		f.SetCellValue(sheet1, cell, h)
		f.SetCellStyle(sheet1, cell, cell, headerStyle)
	}
	f.SetRowHeight(sheet1, 1, 26)

	for rowIdx, d := range anakList {
		rowNum := rowIdx + 2
		tglStr := ""
		if !d.TanggalLahir.IsZero() && d.TanggalLahir.Year() >= 1900 {
			tglStr = d.TanggalLahir.Format("2006-01-02")
		}

		rowData := []interface{}{
			rowIdx + 1,
			d.NoKK,
			d.NIK,
			d.NamaAnak,
			d.NamaIbu,
			d.NamaAyah,
			tglStr,
			hitungUsia(d.TanggalLahir),
			d.BeratLahirKg,
			d.TinggiLahirCm,
			d.LILA,
			d.GolonganDarah,
			d.Kecamatan,
			d.Desa,
		}

		for colIdx, val := range rowData {
			cell, _ := excelize.CoordinatesToCellName(colIdx+1, rowNum)
			f.SetCellValue(sheet1, cell, val)
			// Apply alignment style
			if colIdx == 0 || colIdx == 1 || colIdx == 2 || colIdx == 6 || colIdx == 7 || colIdx == 11 {
				f.SetCellStyle(sheet1, cell, cell, centerStyle)
			} else {
				f.SetCellStyle(sheet1, cell, cell, dataStyle)
			}
		}
		f.SetRowHeight(sheet1, rowNum, 20)
	}

	// Set widths Sheet 1
	colWidths1 := map[int]float64{
		1: 6, 2: 20, 3: 20, 4: 25, 5: 25, 6: 25,
		7: 15, 8: 18, 9: 16, 10: 17,
		11: 10, 12: 16, 13: 18, 14: 18,
	}
	for col, width := range colWidths1 {
		colName, _ := excelize.ColumnNumberToName(col)
		f.SetColWidth(sheet1, colName, colName, width)
	}

	// ─────────────────────────────────────────────────────────
	// SHEET 2: Riwayat Pertumbuhan
	// ─────────────────────────────────────────────────────────
	sheet2 := "Riwayat Pertumbuhan"
	f.NewSheet(sheet2)

	headers2 := []string{
		"No", "NIK Anak", "Nama Anak", "Tanggal Pengukuran", "Usia Saat Pengukuran (bulan)",
		"Berat Badan (Kg)", "Tinggi Badan (Cm)", "LILA", "Lingkar Kepala", "IMT",
		"Status BB/U", "Status TB/U", "Status BB/TB", "Status IMT/U", "Catatan Nakes",
	}

	for colIdx, h := range headers2 {
		cell, _ := excelize.CoordinatesToCellName(colIdx+1, 1)
		f.SetCellValue(sheet2, cell, h)
		f.SetCellStyle(sheet2, cell, cell, headerStyle)
	}
	f.SetRowHeight(sheet2, 1, 26)

	for rowIdx, cp := range pertumbuhanList {
		rowNum := rowIdx + 2
		tglStr := ""
		if !cp.TglUkur.IsZero() && cp.TglUkur.Year() >= 1900 {
			tglStr = cp.TglUkur.Format("2006-01-02")
		}

		rowData := []interface{}{
			rowIdx + 1,
			cp.NIK,
			cp.NamaAnak,
			tglStr,
			cp.UsiaUkurBulan,
			cp.BeratBadan,
			cp.TinggiBadan,
			cp.HasilLila,
			cp.LingkarKepala,
			cp.IMT,
			cp.StatusBBU,
			cp.StatusTBU,
			cp.StatusBBTB,
			cp.StatusIMTU,
			cp.CatatanNakes,
		}

		for colIdx, val := range rowData {
			cell, _ := excelize.CoordinatesToCellName(colIdx+1, rowNum)
			f.SetCellValue(sheet2, cell, val)
			if colIdx == 0 || colIdx == 1 || colIdx == 3 || colIdx == 4 || (colIdx >= 10 && colIdx <= 13) {
				f.SetCellStyle(sheet2, cell, cell, centerStyle)
			} else {
				f.SetCellStyle(sheet2, cell, cell, dataStyle)
			}
		}
		f.SetRowHeight(sheet2, rowNum, 20)
	}

	colWidths2 := map[int]float64{
		1: 6, 2: 20, 3: 25, 4: 20, 5: 28,
		6: 16, 7: 18, 8: 12, 9: 16, 10: 10,
		11: 18, 12: 18, 13: 18, 14: 18, 15: 30,
	}
	for col, width := range colWidths2 {
		colName, _ := excelize.ColumnNumberToName(col)
		f.SetColWidth(sheet2, colName, colName, width)
	}

	// ─────────────────────────────────────────────────────────
	// SHEET 3: Riwayat Imunisasi
	// ─────────────────────────────────────────────────────────
	sheet3 := "Riwayat Imunisasi"
	f.NewSheet(sheet3)

	headers3 := []string{
		"No", "NIK Anak", "Nama Anak", "Nama Vaksin", "Tanggal Pemberian", "Status", "Lokasi", "Petugas",
	}

	for colIdx, h := range headers3 {
		cell, _ := excelize.CoordinatesToCellName(colIdx+1, 1)
		f.SetCellValue(sheet3, cell, h)
		f.SetCellStyle(sheet3, cell, cell, headerStyle)
	}
	f.SetRowHeight(sheet3, 1, 26)

	for rowIdx, im := range imunisasiList {
		rowNum := rowIdx + 2
		tglStr := ""
		if im.TglPemberian != nil && !im.TglPemberian.IsZero() && im.TglPemberian.Year() >= 1900 {
			tglStr = im.TglPemberian.Format("2006-01-02")
		}

		rowData := []interface{}{
			rowIdx + 1,
			im.NIK,
			im.NamaAnak,
			im.NamaVaksin,
			tglStr,
			im.Status,
			im.Lokasi,
			im.Petugas,
		}

		for colIdx, val := range rowData {
			cell, _ := excelize.CoordinatesToCellName(colIdx+1, rowNum)
			f.SetCellValue(sheet3, cell, val)
			if colIdx == 0 || colIdx == 1 || colIdx == 4 || colIdx == 5 {
				f.SetCellStyle(sheet3, cell, cell, centerStyle)
			} else {
				f.SetCellStyle(sheet3, cell, cell, dataStyle)
			}
		}
		f.SetRowHeight(sheet3, rowNum, 20)
	}

	colWidths3 := map[int]float64{
		1: 6, 2: 20, 3: 25, 4: 20, 5: 20, 6: 15, 7: 20, 8: 25,
	}
	for col, width := range colWidths3 {
		colName, _ := excelize.ColumnNumberToName(col)
		f.SetColWidth(sheet3, colName, colName, width)
	}

	return f, nil
}

// hitungUsia menghitung usia dari tanggal lahir sampai hari ini.
// Format output: "X tahun Y bulan" atau "Y bulan" jika kurang dari 1 tahun.
func hitungUsia(tanggalLahir time.Time) string {
	if tanggalLahir.IsZero() || tanggalLahir.Year() < 1900 {
		return "-"
	}

	now := time.Now()
	if tanggalLahir.After(now) {
		return "-"
	}

	years := now.Year() - tanggalLahir.Year()
	months := int(now.Month()) - int(tanggalLahir.Month())

	if now.Day() < tanggalLahir.Day() {
		months--
	}
	if months < 0 {
		years--
		months += 12
	}

	if years <= 0 && months <= 0 {
		return "0 bulan"
	}
	if years <= 0 {
		return fmt.Sprintf("%d bulan", months)
	}
	if months == 0 {
		return fmt.Sprintf("%d tahun", years)
	}
	return fmt.Sprintf("%d tahun %d bulan", years, months)
}
