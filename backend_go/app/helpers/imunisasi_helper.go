package helpers

import (
	"strings"
	"time"
)

// VaccineColorPattern represents the color pattern for each vaccine by month
type VaccineColorPattern map[int]string

// CalculateKategoriPemberian calculates vaccine category based on child's age
// Returns: "white" (tepat waktu), "orange" (terlambat tapi masih boleh), "pink" (imunisasi kejar), "gray" (tidak boleh)
func CalculateKategoriPemberian(tanggalLahir time.Time, tanggalPemberian time.Time, namaDosis string, minUsiaHari uint) string {
	// Calculate child's age in days
	usiaHari := int(tanggalPemberian.Sub(tanggalLahir).Hours() / 24)
	usiaBulan := usiaHari / 30

	// Get the appropriate month column for this age
	currentMonthCol := getMonthColumn(usiaBulan)

	// Get vaccine color pattern
	pattern := getVaccineColorPattern(namaDosis)

	// Get color for current age
	color, exists := pattern[currentMonthCol]
	if !exists {
		return "gray" // default to not allowed if not found
	}

	return color
}

// getMonthColumn maps age in months to the standard KIA month columns
// KIA columns: 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 18, 23, 24-59
func getMonthColumn(usiaBulan int) int {
	monthCols := []int{0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 18, 23}

	// For ages 24-59 months, use special marker
	if usiaBulan >= 24 && usiaBulan <= 59 {
		return 999 // special marker for range 24-59
	}

	// Find the closest month column
	closest := monthCols[len(monthCols)-1]
	for _, col := range monthCols {
		if col <= usiaBulan {
			closest = col
		}
	}

	return closest
}

// getVaccineColorPattern returns the color pattern for each vaccine
// Based on Buku KIA 2024 standard
func getVaccineColorPattern(namaDosis string) VaccineColorPattern {
	// Normalize vaccine name to lowercase for matching
	vaksinName := strings.ToLower(namaDosis)

	// Pattern structure:
	// white = tepat waktu (ideal timing)
	// orange = terlambat tapi masih boleh (late but still allowed for babies/toddlers)
	// pink = imunisasi kejar (catch-up immunization)
	// gray = tidak diperbolehkan (not allowed)

	// Default pattern - will be customized per vaccine
	pattern := VaccineColorPattern{
		0:  "gray",
		1:  "gray",
		2:  "gray",
		3:  "gray",
		4:  "gray",
		5:  "gray",
		6:  "gray",
		7:  "gray",
		8:  "gray",
		9:  "gray",
		10: "gray",
		11: "gray",
		12: "gray",
		18: "gray",
		23: "gray",
		999: "gray", // 24-59 months
	}

	// VAKSIN 1: Hepatitis B (<24 Jam) / HB-0
	if containsAny(vaksinName, []string{"hb-0", "hb 0", "hepatitis b 0", "hepatitis b (lahir)", "<24", "lahir"}) {
		pattern = VaccineColorPattern{
			0: "white",
			1: "gray", 2: "gray", 3: "gray", 4: "gray", 5: "gray",
			6: "gray", 7: "gray", 8: "gray", 9: "gray", 10: "gray",
			11: "gray", 12: "gray", 18: "gray", 23: "gray", 999: "gray",
		}
	}

	// VAKSIN 2: BCG
	if strings.Contains(vaksinName, "bcg") {
		pattern = VaccineColorPattern{
			0: "gray",
			1: "white",
			2: "orange", 3: "orange", 4: "orange", 5: "orange", 6: "orange",
			7: "orange", 8: "orange", 9: "orange", 10: "orange", 11: "orange",
			12: "gray", 18: "gray", 23: "gray", 999: "gray",
		}
	}

	// VAKSIN 3: Polio tetes OPV-1
	if containsAny(vaksinName, []string{"opv-1", "opv 1", "polio 1"}) && !strings.Contains(vaksinName, "ipv") {
		pattern = VaccineColorPattern{
			0: "gray",
			1: "white",
			2: "orange", 3: "orange", 4: "orange", 5: "orange", 6: "orange",
			7: "orange", 8: "orange", 9: "orange", 10: "orange", 11: "orange",
			12: "pink", 18: "pink", 23: "pink", 999: "pink",
		}
	}

	// VAKSIN 4: DPT-HB-Hib-1
	if containsAny(vaksinName, []string{"dpt-hb-hib 1", "dpt-hb-hib-1", "pentavalen 1", "pentavalent 1"}) {
		pattern = VaccineColorPattern{
			0: "gray", 1: "gray",
			2: "white",
			3: "orange", 4: "orange", 5: "orange", 6: "orange", 7: "orange",
			8: "orange", 9: "orange", 10: "orange", 11: "orange",
			12: "pink", 18: "pink", 23: "pink", 999: "pink",
		}
	}

	// VAKSIN 5: Polio Tetes OPV-2
	if containsAny(vaksinName, []string{"opv-2", "opv 2", "polio 2"}) && !strings.Contains(vaksinName, "ipv") {
		pattern = VaccineColorPattern{
			0: "gray", 1: "gray",
			2: "white",
			3: "orange", 4: "orange", 5: "orange", 6: "orange", 7: "orange",
			8: "orange", 9: "orange", 10: "orange", 11: "orange",
			12: "pink", 18: "pink", 23: "pink", 999: "pink",
		}
	}

	// VAKSIN 6: DPT-HB-Hib-2
	if containsAny(vaksinName, []string{"dpt-hb-hib 2", "dpt-hb-hib-2", "pentavalen 2", "pentavalent 2"}) {
		pattern = VaccineColorPattern{
			0: "gray", 1: "gray", 2: "gray",
			3: "white",
			4: "orange", 5: "orange", 6: "orange", 7: "orange", 8: "orange",
			9: "orange", 10: "orange", 11: "orange",
			12: "pink", 18: "pink", 23: "pink", 999: "pink",
		}
	}

	// VAKSIN 7: Polio Tetes OPV-3
	if containsAny(vaksinName, []string{"opv-3", "opv 3", "polio 3"}) && !strings.Contains(vaksinName, "ipv") {
		pattern = VaccineColorPattern{
			0: "gray", 1: "gray", 2: "gray",
			3: "white",
			4: "orange", 5: "orange", 6: "orange", 7: "orange", 8: "orange",
			9: "orange", 10: "orange", 11: "orange",
			12: "pink", 18: "pink", 23: "pink", 999: "pink",
		}
	}

	// VAKSIN 8: DPT-HB-Hib-3
	if containsAny(vaksinName, []string{"dpt-hb-hib 3", "dpt-hb-hib-3", "pentavalen 3", "pentavalent 3"}) {
		pattern = VaccineColorPattern{
			0: "gray", 1: "gray", 2: "gray", 3: "gray",
			4: "white",
			5: "orange", 6: "orange", 7: "orange", 8: "orange", 9: "orange",
			10: "orange", 11: "orange",
			12: "pink", 18: "pink", 23: "pink", 999: "pink",
		}
	}

	// VAKSIN 9: Polio Tetes OPV-4
	if containsAny(vaksinName, []string{"opv-4", "opv 4", "polio 4"}) && !strings.Contains(vaksinName, "ipv") {
		pattern = VaccineColorPattern{
			0: "gray", 1: "gray", 2: "gray", 3: "gray",
			4: "white",
			5: "orange", 6: "orange", 7: "orange", 8: "orange", 9: "orange",
			10: "orange", 11: "orange",
			12: "pink", 18: "pink", 23: "pink", 999: "pink",
		}
	}

	// VAKSIN 10: Polio Suntik (IPV)
	if strings.Contains(vaksinName, "ipv") || strings.Contains(vaksinName, "polio suntik") {
		pattern = VaccineColorPattern{
			0: "gray", 1: "gray", 2: "gray", 3: "gray",
			4: "white",
			5: "orange", 6: "orange", 7: "orange", 8: "orange", 9: "orange",
			10: "orange", 11: "orange",
			12: "pink", 18: "pink", 23: "pink", 999: "pink",
		}
	}

	// VAKSIN 11: MR / Campak-Rubella (first dose)
	if containsAny(vaksinName, []string{"mr", "campak", "rubella"}) && !containsAny(vaksinName, []string{"booster", "lanjutan", " 2"}) {
		pattern = VaccineColorPattern{
			0: "gray", 1: "gray", 2: "gray", 3: "gray", 4: "gray", 5: "gray",
			6: "gray", 7: "gray", 8: "gray",
			9: "white",
			10: "orange", 11: "orange",
			12: "pink", 18: "pink", 23: "pink", 999: "pink",
		}
	}

	// VAKSIN 12: DPT-HB-Hib Booster / Lanjutan
	if (containsAny(vaksinName, []string{"booster", "lanjutan"}) || containsAny(vaksinName, []string{"dpt-hb-hib 4", "pentavalen 4", "pentavalent 4"})) && 
	   containsAny(vaksinName, []string{"dpt", "hib", "pentavalen", "pentavalent"}) {
		pattern = VaccineColorPattern{
			0: "gray", 1: "gray", 2: "gray", 3: "gray", 4: "gray", 5: "gray",
			6: "gray", 7: "gray", 8: "gray", 9: "gray", 10: "gray", 11: "gray",
			12: "gray",
			18: "white",
			23: "orange", 999: "pink",
		}
	}

	// VAKSIN 13: Campak-Rubella (MR) Booster / Lanjutan
	if (containsAny(vaksinName, []string{"booster", "lanjutan"}) || containsAny(vaksinName, []string{"mr 2", "campak 2"})) && 
	   containsAny(vaksinName, []string{"mr", "campak", "rubella"}) {
		pattern = VaccineColorPattern{
			0: "gray", 1: "gray", 2: "gray", 3: "gray", 4: "gray", 5: "gray",
			6: "gray", 7: "gray", 8: "gray", 9: "gray", 10: "gray", 11: "gray",
			12: "gray",
			18: "white",
			23: "orange", 999: "pink",
		}
	}

	return pattern
}

// containsAny checks if the text contains any of the substrings (case-insensitive)
func containsAny(text string, substrings []string) bool {
	for _, substr := range substrings {
		if strings.Contains(text, substr) {
			return true
		}
	}
	return false
}
