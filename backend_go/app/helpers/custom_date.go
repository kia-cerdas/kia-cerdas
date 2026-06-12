package helpers

import (
	"time"
)

// CustomDate adalah tipe khusus untuk parsing tanggal dalam format YYYY-MM-DD atau RFC3339
type CustomDate struct {
	Time *time.Time
}

// UnmarshalJSON menghandle parsing JSON untuk berbagai format tanggal
func (cd *CustomDate) UnmarshalJSON(b []byte) error {
	// Hapus quote dari JSON
	str := string(b)
	if len(str) >= 2 && str[0] == '"' && str[len(str)-1] == '"' {
		str = str[1 : len(str)-1]
	}

	if str == "null" || str == "" {
		cd.Time = nil
		return nil
	}

	// Coba parse format YYYY-MM-DD terlebih dahulu (format sederhana dari frontend)
	parsedTime, err := time.Parse("2006-01-02", str)
	if err == nil {
		cd.Time = &parsedTime
		return nil
	}

	// Jika gagal, coba parse format RFC3339
	parsedTime, err = time.Parse(time.RFC3339, str)
	if err == nil {
		cd.Time = &parsedTime
		return nil
	}

	// Jika kedua format gagal, return error
	return err
}

// MarshalJSON mengkonversi ke JSON
func (cd *CustomDate) MarshalJSON() ([]byte, error) {
	if cd.Time == nil {
		return []byte("null"), nil
	}
	// Return dalam format YYYY-MM-DD
	formatted := cd.Time.Format("2006-01-02")
	return []byte("\"" + formatted + "\""), nil
}
