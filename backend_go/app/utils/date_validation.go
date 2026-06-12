package utils

import (
	"fmt"
	"time"
)

// ValidateTimeNotFuture memeriksa apakah tanggal yang diberikan melebihi hari ini
func ValidateTimeNotFuture(t time.Time) error {
	today := time.Now().Truncate(24 * time.Hour)
	parsedDate := t.Truncate(24 * time.Hour)
	if parsedDate.After(today) {
		return fmt.Errorf("Data tidak dapat diinput untuk tanggal yang melebihi tanggal hari ini.")
	}
	return nil
}

// ValidateDateStrNotFuture memvalidasi string tanggal (format YYYY-MM-DD) agar tidak di masa depan
func ValidateDateStrNotFuture(dateStr string) error {
	if dateStr == "" {
		return nil
	}
	t, err := time.Parse("2006-01-02", dateStr)
	if err != nil {
		return fmt.Errorf("format tanggal tidak valid, gunakan YYYY-MM-DD")
	}
	return ValidateTimeNotFuture(t)
}
