package usecases

import (
	"fmt"
	"time"

	"monitoring-service/app/models"
	"monitoring-service/app/repositories"

	"github.com/xuri/excelize/v2"
)

type LaporanIbuUsecase interface {
	GetLaporanIbu(bulan, tahun int, PosyanduID *int32, role string) ([]models.LaporanIbu, error)
	ExportExcelLaporanIbu(bulan, tahun int, PosyanduID *int32, role string) (string, error)
}

type laporanIbuUsecase struct {
	repo repositories.LaporanIbuRepository
}

func NewLaporanIbuUsecase(repo repositories.LaporanIbuRepository) LaporanIbuUsecase {
	return &laporanIbuUsecase{repo}
}

func (u *laporanIbuUsecase) GetLaporanIbu(bulan, tahun int, PosyanduID *int32, role string) ([]models.LaporanIbu, error) {
	return u.repo.GetLaporanIbu(bulan, tahun, PosyanduID, role)
}
// usecases/laporan_ibu_usecase.go

func (u *laporanIbuUsecase) ExportExcelLaporanIbu(bulan, tahun int, posyanduID *int32, role string) (string, error) {
	data, err := u.repo.GetLaporanIbu(bulan, tahun, posyanduID, role)
	if err != nil {
		return "", err
	}

	f := excelize.NewFile()
	sheet := "Laporan Ibu"
	f.SetSheetName("Sheet1", sheet)

	//  Headers dengan field baru
	headers := []string{
		"NIK",
		"Nama Ibu",
		"Tanggal Lahir",
		"Dusun",
		"RT",
		"RW",
		"Desa",
		"Nama Suami",
		"HPHT",
		"HPL",
		"Usia Kehamilan (Minggu)",
		"Trimester",
		"Gravida",
		"Paritas",
		"Abortus",
		"BB Awal (kg)",
		"Tinggi Badan (cm)",
		"IMT",
		"LILA (cm)",
		"Tekanan Darah",
		"Sistole",
		"Diastole",
		"Tinggi Fundus (cm)",
		"Hb (g/dL)",
		"Golongan Darah",
		"Status Imunisasi Tetanus",
		"Tripel Eliminasi",
		"Kunjungan ANC",
		"Tindakan",
	}

	// Set header dengan style bold
	headerStyle, _ := f.NewStyle(&excelize.Style{
		Font: &excelize.Font{Bold: true},
	})

	for i, h := range headers {
		cell := fmt.Sprintf("%c1", 65+i)
		f.SetCellValue(sheet, cell, h)
		f.SetCellStyle(sheet, cell, cell, headerStyle)
	}

	// Isi data
	for i, d := range data {
		row := i + 2
		f.SetCellValue(sheet, fmt.Sprintf("A%d", row), d.NIK)
		f.SetCellValue(sheet, fmt.Sprintf("B%d", row), d.NamaIbu)
		f.SetCellValue(sheet, fmt.Sprintf("C%d", row), d.TanggalLahir.Format("2006-01-02"))
		f.SetCellValue(sheet, fmt.Sprintf("D%d", row), d.Dusun)
		f.SetCellValue(sheet, fmt.Sprintf("E%d", row), d.RT)
		f.SetCellValue(sheet, fmt.Sprintf("F%d", row), d.RW)
		f.SetCellValue(sheet, fmt.Sprintf("G%d", row), d.Desa)
		f.SetCellValue(sheet, fmt.Sprintf("H%d", row), d.NamaSuami)
		f.SetCellValue(sheet, fmt.Sprintf("I%d", row), d.HPHT.Format("2006-01-02"))
		f.SetCellValue(sheet, fmt.Sprintf("J%d", row), d.HPL.Format("2006-01-02"))
		f.SetCellValue(sheet, fmt.Sprintf("K%d", row), d.UsiaKehamilan)
		f.SetCellValue(sheet, fmt.Sprintf("L%d", row), d.Trimester)
		f.SetCellValue(sheet, fmt.Sprintf("M%d", row), d.Gravida)
		f.SetCellValue(sheet, fmt.Sprintf("N%d", row), d.Paritas)
		f.SetCellValue(sheet, fmt.Sprintf("O%d", row), d.Abortus)
		f.SetCellValue(sheet, fmt.Sprintf("P%d", row), d.BBAwal)
		f.SetCellValue(sheet, fmt.Sprintf("Q%d", row), d.TinggiBadan)
		f.SetCellValue(sheet, fmt.Sprintf("R%d", row), d.IMT)
		f.SetCellValue(sheet, fmt.Sprintf("S%d", row), d.LILA)
		f.SetCellValue(sheet, fmt.Sprintf("T%d", row), d.TekananDarah)
		f.SetCellValue(sheet, fmt.Sprintf("U%d", row), d.Sistole)
		f.SetCellValue(sheet, fmt.Sprintf("V%d", row), d.Diastole)
		f.SetCellValue(sheet, fmt.Sprintf("W%d", row), d.TinggiFundus)
		f.SetCellValue(sheet, fmt.Sprintf("X%d", row), d.Hb)
		f.SetCellValue(sheet, fmt.Sprintf("Y%d", row), d.GolonganDarah)
		f.SetCellValue(sheet, fmt.Sprintf("Z%d", row), d.StatusImunisasi)
		f.SetCellValue(sheet, fmt.Sprintf("AA%d", row), d.TripelEliminasi)
		f.SetCellValue(sheet, fmt.Sprintf("AB%d", row), d.KunjunganANC)
		f.SetCellValue(sheet, fmt.Sprintf("AC%d", row), d.Tindakan)
	}

	// Auto adjust column width
	for i := 0; i < len(headers); i++ {
		col := fmt.Sprintf("%c", 65+i)
		f.SetColWidth(sheet, col, col, 20)
	}

	filename := fmt.Sprintf("laporan_ibu_%s.xlsx", time.Now().Format("20060102_150405"))
	if err := f.SaveAs(filename); err != nil {
		return "", err
	}
	return filename, nil
}