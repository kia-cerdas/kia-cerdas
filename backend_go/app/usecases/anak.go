package usecases

import (
	"errors"
	"fmt"
	"time"

	"monitoring-service/app/models"
	"monitoring-service/app/repositories"

	"gorm.io/gorm"
)

type AnakUseCase struct {
	anakRepo             *repositories.AnakRepository
	kependudukanRepo     *repositories.KependudukanRepository
	prediksiStuntingRepo repositories.PrediksiStuntingRepository
	ibuRepo              *repositories.IbuRepository
	onAnakCreated        func(anakID int32) // ← callback untuk auto-generate jadwal
	onAnakCreatedSync    func(anakID int32) error // ← callback untuk auto-generate pertumbuhan pertama
}

func NewAnakUseCase(
	anakRepo *repositories.AnakRepository,
	kependudukanRepo *repositories.KependudukanRepository,
	prediksiStuntingRepo repositories.PrediksiStuntingRepository,
	ibuRepo *repositories.IbuRepository,
) *AnakUseCase {
	return &AnakUseCase{
		anakRepo:             anakRepo,
		kependudukanRepo:     kependudukanRepo,
		prediksiStuntingRepo: prediksiStuntingRepo,
		ibuRepo:              ibuRepo,
	}
}

// SetOnAnakCreated mendaftarkan callback yang dipanggil setelah anak berhasil dibuat
func (u *AnakUseCase) SetOnAnakCreated(fn func(anakID int32)) {
	u.onAnakCreated = fn
}

// SetOnAnakCreatedSync mendaftarkan callback sinkron yang dipanggil setelah anak berhasil dibuat
func (u *AnakUseCase) SetOnAnakCreatedSync(fn func(anakID int32) error) {
	u.onAnakCreatedSync = fn
}

// ====================== GET ======================
func (u *AnakUseCase) GetAnak(id int32) (*models.AnakResponse, error) {
	anak, err := u.anakRepo.FindByID(id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("data anak tidak ditemukan")
		}
		return nil, err
	}

	resp := u.toAnakResponse(anak)
	pred, predErr := u.prediksiStuntingRepo.GetLatestPredictionByAnakID(id)
	if predErr == nil && pred != nil {
		resp.StatusPrediksi = pred.StatusPrediksi
	} else if u.onAnakCreatedSync != nil {
		// Secara retroaktif buat data pertumbuhan awal jika belum ada
		if err := u.onAnakCreatedSync(id); err == nil {
			if latestPred, errPred := u.prediksiStuntingRepo.GetLatestPredictionByAnakID(id); errPred == nil && latestPred != nil {
				resp.StatusPrediksi = latestPred.StatusPrediksi
			}
		}
	}

	return &resp, nil
}

// ====================== CREATE ======================
func (u *AnakUseCase) CreateAnak(req models.CreateAnakRequest) (*models.AnakResponse, error) {
	// Validasi input
	if req.KehamilanID == 0 {
		return nil, errors.New("kehamilan_id wajib diisi")
	}

	pendudukID := req.PendudukID
	if pendudukID == 0 {
		// Jika penduduk_id tidak ada, buat penduduk baru dari data yang dikirim
		if req.Nama == "" {
			return nil, errors.New("nama anak wajib diisi jika penduduk_id tidak ada")
		}

		tglLahir, _ := time.Parse("2006-01-02", req.TanggalLahir)
		// Generate NIK sementara jika tidak ada (karena NOT NULL di DB)
		nik := fmt.Sprintf("A%d", time.Now().UnixNano())

		var desaID *int32
		if req.IbuID > 0 {
			ibuRecord, errIbuTable := u.ibuRepo.FindByID(req.IbuID)
			if errIbuTable == nil && ibuRecord != nil && ibuRecord.Kependudukan != nil {
				desaID = ibuRecord.Kependudukan.DesaID
			}
		}

		newPenduduk := &models.Kependudukan{
			NIK:          &nik,
			NamaLengkap:  req.Nama,
			JenisKelamin: req.JenisKelamin,
			TanggalLahir: tglLahir,
			DesaID:       desaID,
		}

		if err := u.kependudukanRepo.Create(newPenduduk); err != nil {
			return nil, fmt.Errorf("gagal membuat data penduduk: %v", err)
		}
		pendudukID = newPenduduk.IDKependudukan
	}

	anak := &models.Anak{
		KehamilanID:     req.KehamilanID,
		PendudukID:      pendudukID,
		BeratLahirKg:    req.BeratLahirKg,
		TinggiLahirCm:   req.TinggiLahirCm,
		AnakKe:          req.AnakKe,
		LingkarKepalaCm: req.LingkarKepalaCm,
		NamaIbu:         req.NamaIbu,
		NamaAyah:        req.NamaAyah,
		IbuID:           req.IbuID,
	}

	if err := u.anakRepo.Create(anak); err != nil {
		return nil, err
	}

	// ✅ Auto-generate catatan pertumbuhan pertama dan prediksi stunting (sinkron)
	if u.onAnakCreatedSync != nil {
		if err := u.onAnakCreatedSync(anak.ID); err != nil {
			fmt.Printf("Warning: gagal membuat catatan pertumbuhan awal: %v\n", err)
		}
	}

	// Fetch complete data with relations
	createdAnak, err := u.anakRepo.FindByID(anak.ID)
	if err != nil {
		return nil, err
	}

	resp := u.toAnakResponse(createdAnak)
	pred, predErr := u.prediksiStuntingRepo.GetLatestPredictionByAnakID(anak.ID)
	if predErr == nil && pred != nil {
		resp.StatusPrediksi = pred.StatusPrediksi
	}

	// ✅ Auto-generate jadwal imunisasi (non-blocking, tidak memblokir response)
	if u.onAnakCreated != nil {
		anakID := anak.ID
		go u.onAnakCreated(anakID)
	}

	return &resp, nil
}

// CreateAnakDenganPenduduk: create anak + auto-create kependudukan jika diperlukan
func (u *AnakUseCase) CreateAnakDenganPenduduk(req models.CreateAnakDenganPendudukRequest) (*models.AnakResponse, error) {
	// Validasi input
	if req.KehamilanID == 0 {
		return nil, errors.New("kehamilan_id wajib diisi")
	}
	if req.IbuID == 0 {
		return nil, errors.New("ibu_id wajib diisi")
	}
	if req.Nama == "" {
		return nil, errors.New("nama anak wajib diisi")
	}
	if req.TanggalLahir == "" {
		return nil, errors.New("tanggal_lahir anak wajib diisi")
	}
	if req.JenisKelamin == "" {
		return nil, errors.New("jenis_kelamin wajib diisi")
	}

	// Parse tanggal lahir
	tanggalLahir, err := time.Parse("2006-01-02", req.TanggalLahir)
	if err != nil {
		return nil, errors.New("format tanggal_lahir harus YYYY-MM-DD")
	}

	var desaID *int32
	ibuRecord, errIbuTable := u.ibuRepo.FindByID(req.IbuID)
	if errIbuTable == nil && ibuRecord != nil && ibuRecord.Kependudukan != nil {
		desaID = ibuRecord.Kependudukan.DesaID
	}

	nikSementara := fmt.Sprintf("A%d", time.Now().UnixNano())

	newPenduduk := &models.Kependudukan{
		NIK:           &nikSementara,
		NamaLengkap:   req.Nama,
		JenisKelamin:  req.JenisKelamin,
		TanggalLahir:  tanggalLahir,
		TempatLahir:   req.TempatLahir,
		GolonganDarah: req.GolonganDarah,
		DesaID:        desaID, // ✅ otomatis dari ibu
	}

	if err := u.kependudukanRepo.Create(newPenduduk); err != nil {
		return nil, fmt.Errorf("gagal membuat data penduduk anak: %w", err)
	}

	// Buat anak dengan penduduk_id dari kependudukan yang baru dibuat
	anak := &models.Anak{
		KehamilanID:     req.KehamilanID,
		PendudukID:      newPenduduk.IDKependudukan,
		BeratLahirKg:    req.BeratLahirKg,
		TinggiLahirCm:   req.TinggiLahirCm,
		AnakKe:          req.AnakKe,
		LingkarKepalaCm: req.LingkarKepalaCm,
		NamaIbu:         req.NamaIbu,
		NamaAyah:        req.NamaAyah,
		IbuID:           req.IbuID,
	}

	if err := u.anakRepo.Create(anak); err != nil {
		return nil, fmt.Errorf("gagal membuat data anak: %w", err)
	}

	// ✅ Auto-generate catatan pertumbuhan pertama dan prediksi stunting (sinkron)
	if u.onAnakCreatedSync != nil {
		if err := u.onAnakCreatedSync(anak.ID); err != nil {
			fmt.Printf("Warning: gagal membuat catatan pertumbuhan awal: %v\n", err)
		}
	}

	// Fetch complete data with relations
	createdAnak, err := u.anakRepo.FindByID(anak.ID)
	if err != nil {
		return nil, err
	}

	resp := u.toAnakResponse(createdAnak)
	pred, predErr := u.prediksiStuntingRepo.GetLatestPredictionByAnakID(anak.ID)
	if predErr == nil && pred != nil {
		resp.StatusPrediksi = pred.StatusPrediksi
	}

	// ✅ Auto-generate jadwal imunisasi (non-blocking, tidak memblokir response)
	if u.onAnakCreated != nil {
		anakID := anak.ID
		go u.onAnakCreated(anakID)
	}

	return &resp, nil
}

// ====================== UPDATE ======================
func (u *AnakUseCase) UpdateAnak(id int32, req models.UpdateAnakRequest) (*models.AnakResponse, error) {
	anak, err := u.anakRepo.FindByID(id)
	if err != nil {
		return nil, errors.New("data anak tidak ditemukan")
	}

	if req.BeratLahirKg != nil {
		anak.BeratLahirKg = req.BeratLahirKg
	}

	if req.TinggiLahirCm != nil {
		anak.TinggiLahirCm = req.TinggiLahirCm
	}

	if req.AnakKe != nil {
		anak.AnakKe = *req.AnakKe
	}

	if req.LingkarKepalaCm != nil {
		anak.LingkarKepalaCm = req.LingkarKepalaCm
	}

	if req.NamaIbu != nil {
		anak.NamaIbu = *req.NamaIbu
	}

	if req.NamaAyah != nil {
		anak.NamaAyah = *req.NamaAyah
	}

	if err := u.anakRepo.Update(anak); err != nil {
		return nil, err
	}

	// ── Perbarui data Kependudukan (Penduduk) jika ada perubahan ──
	if anak.PendudukID > 0 && (req.Nama != "" || req.JenisKelamin != "" || req.TanggalLahir != "") {
		penduduk, pendudukErr := u.kependudukanRepo.FindByID(anak.PendudukID)
		if pendudukErr == nil && penduduk != nil {
			changed := false
			if req.Nama != "" && req.Nama != penduduk.NamaLengkap {
				penduduk.NamaLengkap = req.Nama
				changed = true
			}
			if req.JenisKelamin != "" && req.JenisKelamin != penduduk.JenisKelamin {
				penduduk.JenisKelamin = req.JenisKelamin
				changed = true
			}
			if req.TanggalLahir != "" {
				tgl, parseErr := time.Parse("2006-01-02", req.TanggalLahir)
				if parseErr == nil && !tgl.IsZero() {
					currentTgl := penduduk.TanggalLahir.Format("2006-01-02")
					if currentTgl != req.TanggalLahir {
						penduduk.TanggalLahir = tgl
						changed = true
					}
				}
			}
			if changed {
				_ = u.kependudukanRepo.Update(penduduk)
			}
		}
	}

	// Re-fetch untuk mendapatkan data Penduduk terbaru
	updatedAnak, err := u.anakRepo.FindByID(id)
	if err != nil {
		resp := u.toAnakResponse(anak)
		pred, predErr := u.prediksiStuntingRepo.GetLatestPredictionByAnakID(id)
		if predErr == nil && pred != nil {
			resp.StatusPrediksi = pred.StatusPrediksi
		}
		return &resp, nil
	}
	resp := u.toAnakResponse(updatedAnak)
	pred, predErr := u.prediksiStuntingRepo.GetLatestPredictionByAnakID(id)
	if predErr == nil && pred != nil {
		resp.StatusPrediksi = pred.StatusPrediksi
	}
	return &resp, nil
}

// ====================== DELETE ======================
func (u *AnakUseCase) DeleteAnak(id int32) error {
	return u.anakRepo.Delete(id)
}

// ====================== LIST ======================
func (u *AnakUseCase) AdminListAnak(kehamilanID int32) ([]models.AnakResponse, error) {
	var (
		list []models.Anak
		err  error
	)

	if kehamilanID != 0 {
		list, err = u.anakRepo.FindByKehamilanID(kehamilanID)
	} else {
		list, err = u.anakRepo.FindAll()
	}

	if err != nil {
		return nil, err
	}

	result := make([]models.AnakResponse, 0, len(list))
	if len(list) == 0 {
		return result, nil
	}

	var ids []int32
	for _, k := range list {
		ids = append(ids, k.ID)
	}
	predMap, _ := u.prediksiStuntingRepo.GetLatestPredictionsByAnakIDs(ids)

	// Kumpulkan anak yang belum punya prediksi untuk di-sync secara sinkron
	var missingIDs []int32
	for _, k := range list {
		if predMap == nil {
			missingIDs = append(missingIDs, k.ID)
		} else if _, ok := predMap[k.ID]; !ok {
			missingIDs = append(missingIDs, k.ID)
		}
	}

	// Jalankan retroaktif sync sinkron untuk anak yang belum punya prediksi
	if u.onAnakCreatedSync != nil && len(missingIDs) > 0 {
		for _, anakID := range missingIDs {
			if err := u.onAnakCreatedSync(anakID); err != nil {
				fmt.Printf("[AUTO SYNC] Gagal retroaktif sync anak ID %d: %v\n", anakID, err)
			}
		}
		// Re-fetch predMap setelah sync
		predMap, _ = u.prediksiStuntingRepo.GetLatestPredictionsByAnakIDs(ids)
	}

	for _, k := range list {
		resp := u.toAnakResponse(&k)
		if predMap != nil {
			if status, ok := predMap[k.ID]; ok {
				resp.StatusPrediksi = status
			}
		}
		result = append(result, resp)
	}

	return result, nil
}

func (u *AnakUseCase) ListAnakByDesa(desaID *int32, kehamilanID int32) ([]models.AnakResponse, error) {
	var (
		list []models.Anak
		err  error
	)

	if kehamilanID != 0 {
		list, err = u.anakRepo.FindByKehamilanID(kehamilanID)
	} else if desaID != nil && *desaID > 0 {
		list, err = u.anakRepo.FindAllByDesaID(*desaID)
	} else {
		list, err = u.anakRepo.FindAll()
	}

	if err != nil {
		return nil, err
	}

	result := make([]models.AnakResponse, 0, len(list))
	if len(list) == 0 {
		return result, nil
	}

	var ids []int32
	for _, k := range list {
		ids = append(ids, k.ID)
	}
	predMap, _ := u.prediksiStuntingRepo.GetLatestPredictionsByAnakIDs(ids)

	// Kumpulkan anak yang belum punya prediksi untuk di-sync secara sinkron
	var missingIDs []int32
	for _, k := range list {
		if predMap == nil {
			missingIDs = append(missingIDs, k.ID)
		} else if _, ok := predMap[k.ID]; !ok {
			missingIDs = append(missingIDs, k.ID)
		}
	}

	// Jalankan retroaktif sync sinkron untuk anak yang belum punya prediksi
	if u.onAnakCreatedSync != nil && len(missingIDs) > 0 {
		for _, anakID := range missingIDs {
			if err := u.onAnakCreatedSync(anakID); err != nil {
				fmt.Printf("[AUTO SYNC] Gagal retroaktif sync anak ID %d: %v\n", anakID, err)
			}
		}
		// Re-fetch predMap setelah sync
		predMap, _ = u.prediksiStuntingRepo.GetLatestPredictionsByAnakIDs(ids)
	}

	for _, k := range list {
		resp := u.toAnakResponse(&k)
		if predMap != nil {
			if status, ok := predMap[k.ID]; ok {
				resp.StatusPrediksi = status
			}
		}
		result = append(result, resp)
	}

	return result, nil
}

// ====================== UTIL ======================
func HitungUsiaBulan(tanggalLahir time.Time) int {
	now := time.Now()

	if tanggalLahir.IsZero() || tanggalLahir.Year() < 1900 || tanggalLahir.After(now) {
		return 0
	}

	years := now.Year() - tanggalLahir.Year()
	months := int(now.Month()) - int(tanggalLahir.Month())
	total := years*12 + months

	if now.Day() < tanggalLahir.Day() {
		total--
	}

	if total < 0 {
		return 0
	}

	return total
}

func FormatUsiaTeks(tanggalLahir time.Time) string {
	now := time.Now()

	if tanggalLahir.IsZero() || tanggalLahir.Year() < 1900 || tanggalLahir.After(now) {
		return "0 Hari"
	}

	// Hitung beda tahun, bulan, hari secara bertahap
	years := now.Year() - tanggalLahir.Year()
	months := int(now.Month()) - int(tanggalLahir.Month())
	days := now.Day() - tanggalLahir.Day()

	if days < 0 {
		months--
		// Dapatkan jumlah hari pada bulan sebelum 'now'
		t := time.Date(now.Year(), now.Month(), 0, 0, 0, 0, 0, time.UTC)
		days += t.Day()
	}

	if months < 0 {
		years--
		months += 12
	}

	// Susun teks usia
	if years > 0 {
		if months > 0 {
			if days > 0 {
				return fmt.Sprintf("%d Tahun %d Bulan %d Hari", years, months, days)
			}
			return fmt.Sprintf("%d Tahun %d Bulan", years, months)
		}
		if days > 0 {
			return fmt.Sprintf("%d Tahun %d Hari", years, days)
		}
		return fmt.Sprintf("%d Tahun", years)
	}

	if months > 0 {
		if days > 0 {
			return fmt.Sprintf("%d Bulan %d Hari", months, days)
		}
		return fmt.Sprintf("%d Bulan", months)
	}

	return fmt.Sprintf("%d Hari", days)
}

func FormatLabelUsia(bulan int) string {
	if bulan == 0 {
		return "Baru Lahir (0 Bulan)"
	}
	if bulan < 12 {
		return fmt.Sprintf("%d Bulan", bulan)
	}

	tahun := bulan / 12
	sisa := bulan % 12

	if sisa == 0 {
		return fmt.Sprintf("%d Tahun", tahun)
	}

	return fmt.Sprintf("%d Tahun %d Bulan", tahun, sisa)
}

// ====================== MAPPER ======================
func (u *AnakUseCase) toAnakResponse(anak *models.Anak) models.AnakResponse {
	resp := models.AnakResponse{
		ID:              anak.ID,
		KehamilanID:     anak.KehamilanID,
		PendudukID:      anak.PendudukID,
		BeratLahirKg:    anak.BeratLahirKg,
		TinggiLahirCm:   anak.TinggiLahirCm,
		AnakKe:          anak.AnakKe,
		LingkarKepalaCm: anak.LingkarKepalaCm,
		NamaIbu:         anak.NamaIbu,
		NamaAyah:        anak.NamaAyah,
		IbuID:           anak.IbuID,
	}

	if anak.Penduduk != nil {
		resp.Nama = anak.Penduduk.NamaLengkap
		if !anak.Penduduk.TanggalLahir.IsZero() && anak.Penduduk.TanggalLahir.Year() >= 1900 {
			resp.TanggalLahir = anak.Penduduk.TanggalLahir.Format("2006-01-02")
			usiaBulan := HitungUsiaBulan(anak.Penduduk.TanggalLahir)
			resp.UsiaBulan = usiaBulan
			resp.UsiaTeks = FormatUsiaTeks(anak.Penduduk.TanggalLahir)
		} else {
			resp.TanggalLahir = ""
			resp.UsiaBulan = 0
			resp.UsiaTeks = "-"
		}
		resp.JenisKelamin = anak.Penduduk.JenisKelamin
		resp.GolonganDarah = anak.Penduduk.GolonganDarah
		if anak.Penduduk.NIK != nil {
			resp.NIK = *anak.Penduduk.NIK
		}
		resp.Dusun = anak.Penduduk.Dusun
	}

	if anak.Kehamilan != nil {
		resp.Kehamilan = &models.KehamilanSimple{
			ID: anak.Kehamilan.ID,
		}

		if anak.Kehamilan.Ibu != nil && anak.Kehamilan.Ibu.Kependudukan != nil {
			resp.Kehamilan.Ibu.NamaIbu = anak.Kehamilan.Ibu.Kependudukan.NamaLengkap
		}
	}

	return resp
}
