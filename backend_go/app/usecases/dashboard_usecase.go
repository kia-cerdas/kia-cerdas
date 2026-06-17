package usecases

import (
	"fmt"
	"log"
	"monitoring-service/app/middlewares"
	"monitoring-service/app/models"
	"os"
	"time"
)

type DashboardUsecase interface {
	GetJumlahPerKelompokUsia(desaID *int32, role string) (*models.JumlahKelompokUsia, error)
	GetKesehatanPerKelompok(desaID *int32, role string) (models.KesehatanKelompokResponse, error)
	GetCakupanPemeriksaan(desaID *int32, role string) ([]models.CakupanPemeriksaan, error)
}

type dashboardUsecase struct {
	kependudukanUsecase KependudukanUsecase
	pemeriksaanUsecase  PemeriksaanUsecase
	anakUseCase         *AnakUseCase
}

// KONSTANTA BATAS USIA YANG KONSISTEN UNTUK SEMUA FUNGSI
const (
	BALITA_MAX = 5  // 0-5 tahun
	ANAK_MIN   = 6  // 6 tahun
	ANAK_MAX   = 9  // 6-9 tahun
	REMAJA_MIN = 10 // 10 tahun
	REMAJA_MAX = 18 // 10-18 tahun
	DEWASA_MAX = 59 // 19-59 tahun
	// Lansia: 60+ tahun
)

func NewDashboardUsecase(
	kependudukanUsecase KependudukanUsecase,
	pemeriksaanUsecase PemeriksaanUsecase,
	anakUseCase *AnakUseCase,
) DashboardUsecase {
	return &dashboardUsecase{
		kependudukanUsecase: kependudukanUsecase,
		pemeriksaanUsecase:  pemeriksaanUsecase,
		anakUseCase:         anakUseCase,
	}
}

func safePercent(done, total int64) float64 {
	if total == 0 {
		return 0
	}
	return float64(done) / float64(total) * 100
}

// Helper untuk menentukan kelompok usia
func getKelompokUsia(umur int) string {
	switch {
	case umur <= BALITA_MAX:
		return "balita"
	case umur >= ANAK_MIN && umur <= ANAK_MAX:
		return "anak"
	case umur >= REMAJA_MIN && umur <= REMAJA_MAX:
		return "remaja"
	case umur <= DEWASA_MAX:
		return "dewasa"
	default:
		return "lansia"
	}
}

// Helper untuk menentukan apakah umur termasuk anak (6-9 tahun)
func isAnak(umur int) bool {
	return umur >= ANAK_MIN && umur <= ANAK_MAX
}

// Helper untuk menentukan apakah umur termasuk remaja (10-18 tahun)
func isRemaja(umur int) bool {
	return umur >= REMAJA_MIN && umur <= REMAJA_MAX
}

// getFilteredPenduduk mengembalikan daftar penduduk aktif dengan filter desa jika diperlukan
func (u *dashboardUsecase) getFilteredPenduduk(desaID *int32, role string) ([]models.Kependudukan, error) {
	if middlewares.HasFullAccess(role) {
		return u.kependudukanUsecase.GetAllActive()
	}
	if desaID != nil {
		return u.kependudukanUsecase.GetAllActiveByDesaID(*desaID)
	}
	return []models.Kependudukan{}, nil
}

// getFilteredAnak mengembalikan daftar anak dengan filter desa jika diperlukan
func (u *dashboardUsecase) getFilteredAnak(desaID *int32, role string) ([]models.AnakResponse, error) {
	var targetDesaID *int32
	if !middlewares.HasFullAccess(role) {
		targetDesaID = desaID
	}
	return u.anakUseCase.ListAnakByDesa(targetDesaID, 0)
}

// ==================== GET JUMLAH PER KELOMPOK USIA ====================
func (u *dashboardUsecase) GetJumlahPerKelompokUsia(desaID *int32, role string) (*models.JumlahKelompokUsia, error) {
	penduduks, err := u.getFilteredPenduduk(desaID, role)
	if err != nil {
		return nil, err
	}

	result := &models.JumlahKelompokUsia{}

	// Proses penduduk (usia >= 10 tahun dari tabel penduduk)
	for _, p := range penduduks {
		fiveYearsLater := p.TanggalLahir.AddDate(5, 0, 0)
		tenYearsLater := p.TanggalLahir.AddDate(10, 0, 0)
		nineteenYearsLater := p.TanggalLahir.AddDate(19, 0, 0)
		sixtyYearsLater := p.TanggalLahir.AddDate(60, 0, 0)

		now := time.Now()

		switch {
		case !p.TanggalLahir.After(now) && !now.After(fiveYearsLater):
			// Balita dari tabel anak, diabaikan di sini
		case now.After(fiveYearsLater) && !now.After(tenYearsLater):
			// Anak dari tabel anak, diabaikan di sini
		case now.After(tenYearsLater) && !now.After(nineteenYearsLater):
			result.Remaja++
		case now.After(nineteenYearsLater) && !now.After(sixtyYearsLater):
			result.Dewasa++
		default:
			result.Lansia++
		}
	}

	// Proses anak dari tabel anak (usia 0-9 tahun)
	anaks, err := u.getFilteredAnak(desaID, role)
	if err != nil {
		return nil, err
	}

	for _, a := range anaks {
		tglLahir, parseErr := time.Parse("2006-01-02", a.TanggalLahir)
		if parseErr != nil {
			continue
		}
		
		fiveYearsLater := tglLahir.AddDate(5, 0, 0)
		tenYearsLater := tglLahir.AddDate(10, 0, 0)
		
		now := time.Now()
		if !tglLahir.After(now) && !now.After(fiveYearsLater) {
			result.Balita++
		} else if now.After(fiveYearsLater) && !now.After(tenYearsLater) {
			result.Anak++
		}
	}

	return result, nil
}

// ==================== GET KESEHATAN PER KELOMPOK ====================
func (u *dashboardUsecase) GetKesehatanPerKelompok(desaID *int32, role string) (models.KesehatanKelompokResponse, error) {
	penduduks, err := u.getFilteredPenduduk(desaID, role)
	if err != nil {
		return nil, err
	}

	// Gunakan map untuk ID unik (menghindari duplikasi)
	kelompokIDMap := map[string]map[int32]bool{
		"balita": {},
		"anak":   {},
		"remaja": {},
		"dewasa": {},
		"lansia": {},
	}

	// PROSES PENDUDUK (usia >= 10 tahun dari tabel penduduk)
	for _, p := range penduduks {
		fiveYearsLater := p.TanggalLahir.AddDate(5, 0, 0)
		tenYearsLater := p.TanggalLahir.AddDate(10, 0, 0)
		nineteenYearsLater := p.TanggalLahir.AddDate(19, 0, 0)
		sixtyYearsLater := p.TanggalLahir.AddDate(60, 0, 0)

		now := time.Now()
		id := p.IDKependudukan

		switch {
		case !p.TanggalLahir.After(now) && !now.After(fiveYearsLater):
			// Balita dari tabel anak, abaikan di sini
		case now.After(fiveYearsLater) && !now.After(tenYearsLater):
			// Anak (5-9 tahun) dari penduduk - dimasukkan
			kelompokIDMap["anak"][id] = true
		case now.After(tenYearsLater) && !now.After(nineteenYearsLater):
			kelompokIDMap["remaja"][id] = true
		case now.After(nineteenYearsLater) && !now.After(sixtyYearsLater):
			kelompokIDMap["dewasa"][id] = true
		default:
			kelompokIDMap["lansia"][id] = true
		}
	}

	// PROSES ANAK DARI TABEL ANAK (usia 0-9 tahun)
	anaks, err := u.getFilteredAnak(desaID, role)
	if err != nil {
		return nil, err
	}

	// Debug logging
	logContent := fmt.Sprintf("=== DEBUG KESEHATAN PER KELOMPOK %s ===\n", time.Now().Format("2006-01-02 15:04:05"))
	logContent += fmt.Sprintf("Total anak dari getFilteredAnak: %d\n", len(anaks))

	for _, a := range anaks {
		tglLahir, parseErr := time.Parse("2006-01-02", a.TanggalLahir)
		if parseErr != nil {
			continue
		}
		
		fiveYearsLater := tglLahir.AddDate(5, 0, 0)
		tenYearsLater := tglLahir.AddDate(10, 0, 0)
		
		now := time.Now()

		logContent += fmt.Sprintf("Anak: Nama=%s, TglLahir=%s, PendudukID=%d, StatusPrediksi='%s'\n",
			a.Nama, a.TanggalLahir, a.PendudukID, a.StatusPrediksi)

		if !tglLahir.After(now) && !now.After(fiveYearsLater) {
			kelompokIDMap["balita"][a.PendudukID] = true
		} else if now.After(fiveYearsLater) && !now.After(tenYearsLater) {
			kelompokIDMap["anak"][a.PendudukID] = true
		}
	}

	// Log jumlah ID per kelompok
	for kelompok, idMap := range kelompokIDMap {
		logContent += fmt.Sprintf("Kelompok %s: %d IDs\n", kelompok, len(idMap))
	}

	result := make(models.KesehatanKelompokResponse)

	// LOOP UNTUK SEMUA KELOMPOK
	for _, kelompok := range []string{"balita", "anak", "remaja", "dewasa", "lansia"} {
		// Konversi map ke slice
		ids := make([]int32, 0, len(kelompokIDMap[kelompok]))
		for id := range kelompokIDMap[kelompok] {
			ids = append(ids, id)
		}

		if kelompok == "balita" {
			// BALITA: tetap pakai StatusPrediksi dari tabel anak
			balitaRisk := models.RiskCount{"Rendah": 0, "Sedang": 0, "Tinggi": 0}
			for _, a := range anaks {
				tglLahir, parseErr := time.Parse("2006-01-02", a.TanggalLahir)
				if parseErr != nil {
					continue
				}
				
				fiveYearsLater := tglLahir.AddDate(5, 0, 0)
				
				if !time.Now().After(fiveYearsLater) {
					switch a.StatusPrediksi {
					case "Stunting":
						balitaRisk["Tinggi"]++
					case "Risiko Stunting":
						balitaRisk["Sedang"]++
					case "Normal":
						balitaRisk["Rendah"]++
					}
				}
			}
			logContent += fmt.Sprintf("Balita Risk: Rendah=%d, Sedang=%d, Tinggi=%d\n",
				balitaRisk["Rendah"], balitaRisk["Sedang"], balitaRisk["Tinggi"])
			result[kelompok] = balitaRisk
		} else {
			// ANAK, REMAJA, DEWASA, LANSIA: pakai dari tabel pemeriksaan
			logContent += fmt.Sprintf("Memproses kelompok %s dengan %d IDs\n", kelompok, len(ids))

			if len(ids) > 0 {
				riskCount, err := u.pemeriksaanUsecase.GetLatestRiskCountByPendudukIDs(kelompok, ids)
				if err != nil {
					log.Printf("Error GetLatestRiskCountByPendudukIDs untuk %s: %v", kelompok, err)
					logContent += fmt.Sprintf("ERROR untuk %s: %v\n", kelompok, err)
					result[kelompok] = models.RiskCount{"Rendah": 0, "Sedang": 0, "Tinggi": 0}
				} else {
					result[kelompok] = riskCount
					logContent += fmt.Sprintf("%s Risk: Rendah=%d, Sedang=%d, Tinggi=%d\n",
						kelompok, riskCount["Rendah"], riskCount["Sedang"], riskCount["Tinggi"])
				}
			} else {
				logContent += fmt.Sprintf("Kelompok %s: tidak ada IDs\n", kelompok)
				result[kelompok] = models.RiskCount{"Rendah": 0, "Sedang": 0, "Tinggi": 0}
			}
		}
	}

	// Write log file
	_ = os.WriteFile("debug_kesehatan_kelompok.log", []byte(logContent), 0644)

	return result, nil
}

// ==================== GET CAKUPAN PEMERIKSAAN ====================
func (u *dashboardUsecase) GetCakupanPemeriksaan(desaID *int32, role string) ([]models.CakupanPemeriksaan, error) {
	log.Println(">>> GetCakupanPemeriksaan called")
	penduduks, err := u.getFilteredPenduduk(desaID, role)
	if err != nil {
		return nil, err
	}

	// Gunakan map untuk ID unik per kelompok
	kelompokIDMap := map[string]map[int32]bool{
		"balita": {},
		"anak":   {},
		"remaja": {},
		"dewasa": {},
		"lansia": {},
	}

	// PROSES PENDUDUK (usia >= 10 tahun dari tabel penduduk)
	for _, p := range penduduks {
		fiveYearsLater := p.TanggalLahir.AddDate(5, 0, 0)
		tenYearsLater := p.TanggalLahir.AddDate(10, 0, 0)
		nineteenYearsLater := p.TanggalLahir.AddDate(19, 0, 0)
		sixtyYearsLater := p.TanggalLahir.AddDate(60, 0, 0)

		now := time.Now()
		id := p.IDKependudukan

		switch {
		case !p.TanggalLahir.After(now) && !now.After(fiveYearsLater):
			// Balita dari tabel anak, abaikan di sini
		case now.After(fiveYearsLater) && !now.After(tenYearsLater):
			// Anak (5-9 tahun) dari penduduk - dimasukkan
			kelompokIDMap["anak"][id] = true
		case now.After(tenYearsLater) && !now.After(nineteenYearsLater):
			kelompokIDMap["remaja"][id] = true
		case now.After(nineteenYearsLater) && !now.After(sixtyYearsLater):
			kelompokIDMap["dewasa"][id] = true
		default:
			kelompokIDMap["lansia"][id] = true
		}
	}

	// PROSES ANAK DARI TABEL ANAK (usia 0-9 tahun)
	anaks, err := u.getFilteredAnak(desaID, role)
	if err != nil {
		return nil, err
	}

	for _, a := range anaks {
		tglLahir, parseErr := time.Parse("2006-01-02", a.TanggalLahir)
		if parseErr != nil {
			continue
		}
		
		fiveYearsLater := tglLahir.AddDate(5, 0, 0)
		tenYearsLater := tglLahir.AddDate(10, 0, 0)
		
		now := time.Now()

		if !tglLahir.After(now) && !now.After(fiveYearsLater) {
			kelompokIDMap["balita"][a.PendudukID] = true
		} else if now.After(fiveYearsLater) && !now.After(tenYearsLater) {
			kelompokIDMap["anak"][a.PendudukID] = true
		}
	}

	var result []models.CakupanPemeriksaan

	// HITUNG CAKUPAN PER KELOMPOK
	for _, kelompok := range []string{"balita", "anak", "remaja", "dewasa", "lansia"} {
		// Konversi map ke slice
		ids := make([]int32, 0, len(kelompokIDMap[kelompok]))
		for id := range kelompokIDMap[kelompok] {
			ids = append(ids, id)
		}
		total := int64(len(ids))
		var sudah int64 = 0

		if kelompok == "balita" {
			// BALITA: hitung dari StatusPrediksi tabel anak
			for _, a := range anaks {
				if kelompokIDMap["balita"][a.PendudukID] && a.StatusPrediksi != "" {
					sudah++
				}
			}
		} else {
			// ANAK, REMAJA, DEWASA, LANSIA: hitung dari tabel pemeriksaan
			if total > 0 {
				count, err := u.pemeriksaanUsecase.CountPendudukWithExamination(kelompok, ids)
				if err != nil {
					return nil, fmt.Errorf("gagal hitung pemeriksaan %s: %w", kelompok, err)
				}
				sudah = count
			}
		}

		result = append(result, models.CakupanPemeriksaan{
			Kelompok:       kelompok,
			TotalSasaran:   total,
			SudahDiperiksa: sudah,
			BelumDiperiksa: total - sudah,
			Persentase:     safePercent(sudah, total),
		})
	}

	return result, nil
}