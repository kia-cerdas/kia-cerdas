package utils

import (
	"strings"
	"time"
)

func HitungUmur(tanggalLahir time.Time) int {

	now := time.Now()

	umur := now.Year() - tanggalLahir.Year()

	// cek apakah ulang tahun tahun ini sudah lewat
	if now.Month() < tanggalLahir.Month() ||
		(now.Month() == tanggalLahir.Month() &&
			now.Day() < tanggalLahir.Day()) {

		umur--
	}

	return umur
}

func NormalizeRisk(risk string) string {
    upper := strings.ToUpper(risk)
    if upper == "TINGGI" || upper == "PERLU RUJUKAN" {
        return "Tinggi"
    }
    if upper == "SEDANG" || upper == "PERLU TINDAKAN" {
        return "Sedang"
    }
    return "Normal"
}