package usecases

import (
	"testing"
	"time"
)

// truncateToDay menghapus komponen jam/menit/detik agar perhitungan
// selisih hari konsisten dengan yang dilakukan calculateStatusID.
func truncateToDay(t time.Time) time.Time {
	return time.Date(t.Year(), t.Month(), t.Day(), 0, 0, 0, 0, t.Location())
}

// addDays adalah helper untuk membentuk tanggal estimasi berdasarkan
// selisih hari (diff) dari hari ini, sesuai skenario boundary value.
func addDays(diff int) time.Time {
	return truncateToDay(time.Now()).AddDate(0, 0, diff)
}

func TestCalculateStatusID(t *testing.T) {
	tests := []struct {
		name           string
		diff           int
		expectedStatus int32
	}{
		{"jadwal masih jauh di masa depan", 30, 1},
		{"baru masuk kategori belum (H-1)", 1, 1},
		{"tepat hari ini", 0, 2},
		{"baru mulai terlewat (H+1)", -1, 3},
		{"batas atas kategori terlewat <7 hari", -6, 3},
		{"baru masuk terlambat 7-14 hari", -7, 4},
		{"batas atas terlambat 7-14 hari", -14, 4},
		{"baru masuk krisis", -15, 5},
		{"sangat lama terlambat", -100, 5},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := calculateStatusID(addDays(tt.diff))

			if got != tt.expectedStatus {
				t.Errorf(
					"diff=%d hari: got statusID=%d, want=%d",
					tt.diff, got, tt.expectedStatus,
				)
			}
		})
	}
}
