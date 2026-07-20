package usecases

import (
	"sort"
	"testing"
	"time"

	"monitoring-service/app/models"
)

func TestGetPrioritasImunisasi(t *testing.T) {
	tests := []struct {
		name         string
		tanggal      *time.Time
		expectedPrio string
	}{
		{"tidak ada tanggal jadwal", nil, "P4"},
		{"belum jatuh tempo / hari ini", ptrTime(addDays(0)), "P4"},
		{"baru mulai terlambat", ptrTime(addDays(-1)), "P3"},
		{"batas atas kategori P3", ptrTime(addDays(-6)), "P3"},
		{"baru masuk P2", ptrTime(addDays(-7)), "P2"},
		{"batas atas kategori P2", ptrTime(addDays(-14)), "P2"},
		{"baru masuk P1", ptrTime(addDays(-15)), "P1"},
		{"sangat terlambat", ptrTime(addDays(-100)), "P1"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := getPrioritasImunisasi(tt.tanggal)

			if got != tt.expectedPrio {
				t.Errorf(
					"tanggal=%v: got prioritas=%s, want=%s",
					tt.tanggal, got, tt.expectedPrio,
				)
			}
		})
	}
}

// TestUrutanPrioritasImunisasiTerlewat menguji rule pengurutan hasil
// (P1 -> P2 -> P3 -> P4) yang dipakai di GetJadwalImunisasiTerlewatByKaderID.
func TestUrutanPrioritasImunisasiTerlewat(t *testing.T) {
	data := []models.JadwalImunisasiTerlewatResponse{
		{JadwalID: 1, Prioritas: getPrioritasImunisasi(ptrTime(addDays(-3)))},   // P3
		{JadwalID: 2, Prioritas: getPrioritasImunisasi(ptrTime(addDays(-20)))},  // P1
		{JadwalID: 3, Prioritas: getPrioritasImunisasi(nil)},                   // P4
		{JadwalID: 4, Prioritas: getPrioritasImunisasi(ptrTime(addDays(-10)))}, // P2
	}

	sort.Slice(data, func(i, j int) bool {
		order := map[string]int{"P1": 1, "P2": 2, "P3": 3, "P4": 4}
		return order[data[i].Prioritas] < order[data[j].Prioritas]
	})

	expectedOrder := []uint{2, 4, 1, 3} // P1, P2, P3, P4

	for i, jadwalID := range expectedOrder {
		if data[i].JadwalID != jadwalID {
			t.Errorf(
				"urutan ke-%d: got JadwalID=%d (prioritas=%s), want JadwalID=%d",
				i, data[i].JadwalID, data[i].Prioritas, jadwalID,
			)
		}
	}
}

func ptrTime(t time.Time) *time.Time {
	return &t
}
