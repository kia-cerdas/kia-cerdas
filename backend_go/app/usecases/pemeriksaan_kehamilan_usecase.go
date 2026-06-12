// package usecases

// import (
// 	"errors"
//
// 	"strings"
// 	"time"

// 	// "log"
// 	"monitoring-service/app/models"
// 	"monitoring-service/app/repositories"
// 	// "strings"
// )

// type PemeriksaanKehamilanUsecase interface {
// 	Create(p *models.PemeriksaanKehamilan) error
// 	GetByID(id int32) (*models.PemeriksaanKehamilan, error)
// 	GetMine(userID int32) ([]models.PemeriksaanKehamilan, error) // MODUL IBU
// 	GetByIDForOrangtua(id int32, userID int32) (*models.PemeriksaanKehamilan, error) // MODUL IBU
// 	GetByKehamilanID(kehamilanID int32) ([]models.PemeriksaanKehamilan, error)
// 	Update(p *models.PemeriksaanKehamilan) error
// 	Delete(id int32) error
// 	GetGrafikANC(kehamilanID int32) (*GrafikANCResponse, error)
// }

// func NewPemeriksaanKehamilanUsecase(repo *repositories.PemeriksaanKehamilanRepository, kehamilanrepo *repositories.KehamilanRepository, prediksiUc PrediksiRisikoUsecase) PemeriksaanKehamilanUsecase {
// 	return &pemeriksaanKehamilanUsecase{repo: repo, kehamilanrepo: kehamilanrepo, prediksiUc: prediksiUc}
// }

// // ================= BASIC CRUD =================

// func (u *pemeriksaanKehamilanUsecase) Create(p *models.PemeriksaanKehamilan) error {
// 	if err := u.validate(p); err != nil {
// 		return err
// 	}

// 	if err := u.fillPrediction(p); err != nil {
// 		// Tergantung kebutuhan: bisa return error atau lanjut dengan default. Saya sarankan return error.
// 		return fmt.Errorf("gagal memprediksi risiko: %w", err)
// 	}

// 	return u.repo.Create(p)
// }

// func (u *pemeriksaanKehamilanUsecase) GetByID(id int32) (*models.PemeriksaanKehamilan, error) {
// 	return u.repo.FindByID(id)
// }

// func (u *pemeriksaanKehamilanUsecase) GetByKehamilanID(kehamilanID int32) ([]models.PemeriksaanKehamilan, error) {
// 	return u.repo.FindByKehamilanID(kehamilanID)
// }

// func (u *pemeriksaanKehamilanUsecase) Update(p *models.PemeriksaanKehamilan) error {
// 	_, err := u.repo.FindByID(p.IDPeriksa)
// 	if err != nil {
// 		return errors.New("data pemeriksaan kehamilan tidak ditemukan")
// 	}

// 	if err := u.validate(p); err != nil {
// 		return err
// 	}

// 	if err := u.fillPrediction(p); err != nil {
// 		return fmt.Errorf("gagal memprediksi risiko: %w", err)
// 	}
// 	return u.repo.Update(p)
// }

// func (u *pemeriksaanKehamilanUsecase) Delete(id int32) error {
// 	return u.repo.Delete(id)
// }

// // MODUL IBU
// func (u *pemeriksaanKehamilanUsecase) GetByIDForOrangtua(id int32, userID int32) (*models.PemeriksaanKehamilan, error) {
// 	allowed, err := u.repo.IsOwnedByUser(id, userID)
// 	if err != nil {
// 		return nil, err
// 	}

// 	if !allowed {
// 		return nil, errors.New("Anda tidak dapat mengakses data ini")
// 	}

// 	return u.repo.FindByID(id)
// }

// // MODUL IBU
//
//	func (u *pemeriksaanKehamilanUsecase) GetMine(userID int32) ([]models.PemeriksaanKehamilan, error) {
//		return u.repo.FindMineByUserID(userID)
//	}
package usecases

import (
	"errors"
	"fmt"
	"monitoring-service/app/models"
	"monitoring-service/app/repositories"
	"strings"
	"time"
)

type PemeriksaanKehamilanUsecase interface {
	Create(p *models.PemeriksaanKehamilan) error
	GetByID(id int32) (*models.PemeriksaanKehamilan, error)
	GetMine(userID int32) ([]models.PemeriksaanKehamilan, error)
	GetByIDForOrangtua(id int32, userID int32) (*models.PemeriksaanKehamilan, error)
	GetByKehamilanID(kehamilanID int32) ([]models.PemeriksaanKehamilan, error)
	Update(p *models.PemeriksaanKehamilan) error
	Delete(id int32) error
	GetGrafikANC(kehamilanID int32) (*GrafikANCResponse, error)
}

type pemeriksaanKehamilanUsecase struct {
	repo          *repositories.PemeriksaanKehamilanRepository
	kehamilanrepo *repositories.KehamilanRepository
	prediksiUc    PrediksiRisikoUsecase
}

// DIUBAH: Sesuaikan dengan init.go
func NewPemeriksaanKehamilanUsecase(repo *repositories.PemeriksaanKehamilanRepository, kehamilanrepo *repositories.KehamilanRepository, prediksiUc PrediksiRisikoUsecase) PemeriksaanKehamilanUsecase {
	return &pemeriksaanKehamilanUsecase{repo: repo, kehamilanrepo: kehamilanrepo, prediksiUc: prediksiUc}
}

func (u *pemeriksaanKehamilanUsecase) Create(p *models.PemeriksaanKehamilan) error {
	if err := u.validate(p); err != nil {
		return err
	}

	// Prediction adalah optional - data tetap bisa disimpan meski prediksi gagal
	if err := u.fillPrediction(p); err != nil {
		// Log error tapi jangan return - lanjutkan menyimpan data
		fmt.Println("⚠️ Warning: Prediksi risiko gagal, tapi data akan tetap disimpan:", err)
	}

	return u.repo.Create(p)
}

func (u *pemeriksaanKehamilanUsecase) GetByID(id int32) (*models.PemeriksaanKehamilan, error) {
	return u.repo.FindByID(id)
}

func (u *pemeriksaanKehamilanUsecase) GetByKehamilanID(kehamilanID int32) ([]models.PemeriksaanKehamilan, error) {
	return u.repo.FindByKehamilanID(kehamilanID)
}

func (u *pemeriksaanKehamilanUsecase) Update(p *models.PemeriksaanKehamilan) error {
	_, err := u.repo.FindByID(p.IDPeriksa)
	if err != nil {
		return errors.New("data pemeriksaan kehamilan tidak ditemukan")
	}

	if err := u.validate(p); err != nil {
		return err
	}

	// Prediction adalah optional - data tetap bisa diupdate meski prediksi gagal
	if err := u.fillPrediction(p); err != nil {
		// Log error tapi jangan return - lanjutkan mengupdate data
		fmt.Println("⚠️ Warning: Prediksi risiko gagal saat update, tapi data akan tetap diupdate:", err)
	}
	return u.repo.Update(p)
}

func (u *pemeriksaanKehamilanUsecase) Delete(id int32) error {
	return u.repo.Delete(id)
}

// ================= ACCESS CONTROL =================

func (u *pemeriksaanKehamilanUsecase) GetByIDForOrangtua(id int32, userID int32) (*models.PemeriksaanKehamilan, error) {
	allowed, err := u.repo.IsOwnedByUser(id, userID)
	if err != nil {
		return nil, err
	}

	if !allowed {
		return nil, errors.New("Anda tidak dapat mengakses data ini")
	}

	return u.repo.FindByID(id)
}

// ================= VALIDASI =================

func (u *pemeriksaanKehamilanUsecase) validate(p *models.PemeriksaanKehamilan) error {
	if p.KehamilanID == 0 {
		return errors.New("kehamilan_id wajib diisi")
	}

	if p.MingguKehamilan <= 0 {
		return errors.New("minggu kehamilan tidak valid")
	}

	return nil
}

func (u *pemeriksaanKehamilanUsecase) fillPrediction(p *models.PemeriksaanKehamilan) error {
	req, err := u.buildPredictionRequest(p)
	if err != nil {
		return err
	}
	resp, err := u.prediksiUc.Predict(req)
	if err != nil {
		return err
	}
	p.SkorRisiko = int32(resp.Prediction)
	p.StatusRisiko = resp.Label
	p.DetailRisiko = generateProblemAndRecommendation(p)
	return nil
}
func generateProblemAndRecommendation(p *models.PemeriksaanKehamilan) string {
	var parts []string

	// Anemia
	if p.TesLabHb != nil && *p.TesLabHb < 11.0 {
		if *p.TesLabHb < 8.0 {
			parts = append(parts, "Anemia berat (Hb < 8 g/dL). Rujuk segera untuk transfusi darah.")
		} else {
			parts = append(parts, fmt.Sprintf("Anemia ringan (Hb %.1f g/dL). Minum tablet Fe 60 mg/hari minimal 90 tablet.", *p.TesLabHb))
		}
	}

	// Hipertensi
	if p.Sistole >= 140 || p.Diastole >= 90 {
		parts = append(parts, "Hipertensi (TD tinggi). Rujuk ke puskesmas/dokter untuk penanganan.")
	} else if p.Sistole >= 120 || p.Diastole >= 80 {
		parts = append(parts, "Pra-hipertensi. Pantau TD secara rutin dan edukasi gaya hidup sehat.")
	}

	// KEK
	if p.LingkarLenganAtas != nil && *p.LingkarLenganAtas < 23.5 {
		parts = append(parts, fmt.Sprintf("KEK (LiLA %.1f cm < 23,5). Berikan PMT dan konseling gizi.", *p.LingkarLenganAtas))
	}

	// Tripel eliminasi (case-insensitive)
	if p.TripelEliminasi != "" {
		lower := strings.ToLower(p.TripelEliminasi)
		if (strings.Contains(lower, "hiv") && strings.Contains(lower, "reaktif")) ||
			(strings.Contains(lower, "sifilis") && strings.Contains(lower, "reaktif")) {
			parts = append(parts, "Tripel eliminasi reaktif (HIV/Sifilis). Rujuk segera ke RSUD.")
		} else if strings.Contains(lower, "hepatitis b") && strings.Contains(lower, "reaktif") {
			parts = append(parts, "Hepatitis B reaktif. Rujuk untuk penanganan lebih lanjut.")
		}
	}

	// Riwayat penyakit
	if p.SkriningDokter != "" && !strings.EqualFold(p.SkriningDokter, "normal") && !strings.EqualFold(p.SkriningDokter, "tidak ada") {
		parts = append(parts, fmt.Sprintf("Riwayat penyakit: %s. Perlu pemantauan khusus.", p.SkriningDokter))
	}

	// Kunjungan ANC
	if p.KunjunganKe <= 1 {
		parts = append(parts, "Kunjungan ANC masih awal. Dorong kunjungan rutin minimal 6x selama kehamilan.")
	}

	if len(parts) == 0 {
		return "Kondisi baik. Lanjutkan ANC rutin."
	}
	return strings.Join(parts, "\n")
}
func (u *pemeriksaanKehamilanUsecase) buildPredictionRequest(p *models.PemeriksaanKehamilan) (*models.PrediksiRisikoRequest, error) {
	kehamilan, err := u.kehamilanrepo.FindByID(p.KehamilanID)
	if err != nil {
		return nil, fmt.Errorf("data kehamilan tidak ditemukan: %w", err)
	}
	if kehamilan.Ibu == nil {
		return nil, errors.New("data ibu tidak ditemukan pada kehamilan")
	}
	ibu := kehamilan.Ibu
	if ibu.Kependudukan == nil {
		return nil, errors.New("data kependudukan ibu tidak ditemukan")
	}

	// Usia ibu
	refDate := time.Now()
	if p.TanggalPeriksa != nil {
		refDate = *p.TanggalPeriksa
	}
	umur := calculateAge(ibu.Kependudukan.TanggalLahir, refDate)

	// Trimester dari minggu kehamilan
	trimesterNum := 1
	if p.MingguKehamilan >= 13 && p.MingguKehamilan <= 27 {
		trimesterNum = 2
	} else if p.MingguKehamilan >= 28 {
		trimesterNum = 3
	}

	// IMT: prioritaskan IMT awal dari kehamilan, fallback ke hitung dari input saat ini
	imt := kehamilan.IMT_Awal
	if imt == 0 && p.BeratBadan != nil && p.TinggiBadan != nil && *p.TinggiBadan > 0 {
		tinggiM := *p.TinggiBadan / 100
		imt = *p.BeratBadan / (tinggiM * tinggiM)
	}

	// Nilai default
	lila := 26.0
	if p.LingkarLenganAtas != nil {
		lila = *p.LingkarLenganAtas
	}
	hb := 12.0
	if p.TesLabHb != nil {
		hb = *p.TesLabHb
	}
	tfu := 0.0
	if p.TinggiRahim != nil {
		tfu = *p.TinggiRahim
	}

	// Riwayat penyakit dari SkriningDokter
	riwayatEnc := 0
	riwayatBerat := 0
	if p.SkriningDokter != "" {
		lower := strings.ToLower(p.SkriningDokter)
		if !strings.Contains(lower, "tidak ada") && !strings.Contains(lower, "normal") {
			riwayatEnc = 1
			if strings.Contains(lower, "hipertensi") ||
				strings.Contains(lower, "jantung") ||
				strings.Contains(lower, "diabetes") {
				riwayatBerat = 1
			}
		}
	}

	// Tripel eliminasi
	hivRek, sifRek, hepbRek := parseTripelEliminasi(p.TripelEliminasi)

	req := &models.PrediksiRisikoRequest{
		UsiaIbu:           float64(umur),
		UsiaKehamilan:     int(p.MingguKehamilan),
		TrimesterNum:      trimesterNum,
		Gravida:           int(ibu.Gravida),
		Para:              int(ibu.Paritas),
		Abortus:           int(ibu.Abortus),
		IMT:               imt,
		LiLA:              lila,
		TinggiFundusUteri: tfu,
		TDSistolik:        float64(p.Sistole),
		TDDiastolik:       float64(p.Diastole),
		Hemoglobin:        hb,
		KunjunganANCKe:    int(p.KunjunganKe),
		ImunisasiEnc:      mapImunisasiToEnc(p.StatusImunisasiTetanus),
		RiwayatEnc:        riwayatEnc,
		RiwayatBerat:      riwayatBerat,
		HIVRek:            hivRek,
		SifRek:            sifRek,
		HepBRek:           hepbRek,
	}
	return req, nil
}

// parseTripelEliminasi case-insensitive
func parseTripelEliminasi(tripel string) (hiv, sif, hepb int) {
	if tripel == "" {
		return
	}
	lower := strings.ToLower(tripel)
	if strings.Contains(lower, "hiv") && strings.Contains(lower, "reaktif") {
		hiv = 1
	}
	if strings.Contains(lower, "sifilis") && strings.Contains(lower, "reaktif") {
		sif = 1
	}
	if strings.Contains(lower, "hepatitis b") || strings.Contains(lower, "hbsag") && strings.Contains(lower, "reaktif") {
		hepb = 1
	}
	return
}

// helper menghitung usia dalam tahun berdasarkan tanggal lahir dan tanggal referensi
func calculateAge(birthDate, refDate time.Time) int {
	age := refDate.Year() - birthDate.Year()
	if refDate.YearDay() < birthDate.YearDay() {
		age--
	}
	if age < 0 {
		age = 0
	}
	return age
}

// helper cek substring
func containsAny(s string, substrs []string) bool {
	for _, sub := range substrs {
		if contains(s, sub) {
			return true
		}
	}
	return false
}

func contains(s, substr string) bool {
	return len(s) >= len(substr) && (s == substr || len(s) > len(substr) && (s[:len(substr)] == substr || s[len(s)-len(substr):] == substr || findSubstring(s, substr)))
}

func findSubstring(s, sub string) bool {
	for i := 0; i <= len(s)-len(sub); i++ {
		if s[i:i+len(sub)] == sub {
			return true
		}
	}
	return false
}

func mapImunisasiToEnc(status string) int {
	switch status {
	case "T1":
		return 1
	case "T2":
		return 2
	case "T3":
		return 3
	case "T4":
		return 4
	case "T5":
		return 5
	default:
		return 0
	}
}

// // ================= GRAFIK =================
type GrafikPoint struct {
	Minggu int32   `json:"minggu"`
	Value  float64 `json:"value"`
}

type GrafikTDPoint struct {
	Minggu   int32 `json:"minggu"`
	Sistole  int32 `json:"sistole"`
	Diastole int32 `json:"diastole"`
}

type DetailRisikoDTO struct {
	SkorRisiko   int32  `json:"skor_risiko"`
	StatusRisiko string `json:"status_risiko"`
	Ringkasan    string `json:"ringkasan"`
}

type GrafikBeratBadan struct {
	Minggu int32   `json:"minggu"`
	Berat  float64 `json:"berat"`
}
type GrafikANCResponse struct {
	KehamilanID  int32              `json:"kehamilan_id"`
	DetailRisiko DetailRisikoDTO    `json:"detail_risiko"`
	GrafikDJJ    []GrafikPoint      `json:"grafik_djj"`
	GrafikTFU    []GrafikPoint      `json:"grafik_tfu"`
	GrafikTD     []GrafikTDPoint    `json:"grafik_tekanan_darah"`
	GrafikIMT    []GrafikBeratBadan `json:"grafik_berat_badan"`

	IMT_Awal    float64 `json:"imt_awal"`
	KategoriIMT string  `json:"kategori_imt"`
}

// ================= GRAFIK FUNCTION =================
func KategoriIMT(imt float64) string {
	switch {
	case imt < 18.5:
		return "KEK (Kurang)"
	case imt < 25:
		return "Normal"
	case imt < 30:
		return "Overweight"
	default:
		return "Obesitas"
	}
}
func (u *pemeriksaanKehamilanUsecase) GetGrafikANC(kehamilanID int32) (*GrafikANCResponse, error) {

	// =====================
	// AMBIL KEHAMILAN
	// =====================
	kehamilan, err := u.kehamilanrepo.FindByID(kehamilanID)
	if err != nil {
		return nil, err
	}

	imt := kehamilan.IMT_Awal
	kategoriIMT := KategoriIMT(imt)

	// =====================
	// AMBIL DATA ANC
	// =====================
	data, err := u.repo.FindByKehamilanID(kehamilanID)
	if err != nil {
		return nil, err
	}

	resp := &GrafikANCResponse{
		KehamilanID: kehamilanID,
		IMT_Awal:    imt,
		KategoriIMT: kategoriIMT,
	}

	if len(data) == 0 {
		return resp, nil
	}

	var latest models.PemeriksaanKehamilan

	for _, d := range data {

		if d.MingguKehamilan >= latest.MingguKehamilan {
			latest = d
		}

		if d.DenyutJantungJanin > 0 {
			resp.GrafikDJJ = append(resp.GrafikDJJ, GrafikPoint{
				Minggu: d.MingguKehamilan,
				Value:  float64(d.DenyutJantungJanin),
			})
		}

		if d.TinggiRahim != nil {
			resp.GrafikTFU = append(resp.GrafikTFU, GrafikPoint{
				Minggu: d.MingguKehamilan,
				Value:  *d.TinggiRahim,
			})
		}

		resp.GrafikTD = append(resp.GrafikTD, GrafikTDPoint{
			Minggu:   d.MingguKehamilan,
			Sistole:  d.Sistole,
			Diastole: d.Diastole,
		})

		// =====================
		// WEIGHT GAIN (bukan IMT)
		// =====================
		if d.BeratBadan != nil {
			resp.GrafikIMT = append(resp.GrafikIMT, GrafikBeratBadan{
				Minggu: d.MingguKehamilan,
				Berat:  *d.BeratBadan - kehamilan.BB_Awal,
			})
		}
	}

	resp.DetailRisiko = DetailRisikoDTO{
		SkorRisiko:   latest.SkorRisiko,
		StatusRisiko: latest.StatusRisiko,
		Ringkasan:    latest.DetailRisiko,
	}

	return resp, nil
}

func (u *pemeriksaanKehamilanUsecase) GetMine(userID int32) ([]models.PemeriksaanKehamilan, error) {
	return u.repo.FindMineByUserID(userID)
}

// STUB BARU
