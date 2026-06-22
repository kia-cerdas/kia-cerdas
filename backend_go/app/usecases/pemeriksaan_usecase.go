package usecases

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"monitoring-service/app/models"
	"monitoring-service/app/repositories"
	"strings"
	"time"

	"github.com/diegoholiveira/jsonlogic/v3"
)

type pemeriksaanUsecase struct {
	formRepo    repositories.FormRepository
	periksaRepo repositories.PemeriksaanRepository
	mainRepo    *repositories.Main
}

type PemeriksaanUsecase interface {
    GetActiveForm(ctx context.Context, kelompok string) (*models.ActiveFormResponse, error)
    SavePemeriksaan(ctx context.Context, req *models.SavePemeriksaanRequest, petugasID *uint) (*models.PemeriksaanResponse, error)
    GetRiwayatPenduduk(ctx context.Context, pendudukID uint, kelompok string) ([]models.RiwayatPemeriksaanResponse, error)
    GetDetailPemeriksaan(ctx context.Context, id uint) (*models.DetailPemeriksaanResponse, error)
	CountPendudukWithExamination(kelompok string, pendudukIDs []int32) (int64, error)
	GetLatestRiskCountByPendudukIDs(kelompok string, pendudukIDs []int32) (map[string]int, error)
}
func NewPemeriksaanUsecase(formRepo repositories.FormRepository, periksaRepo repositories.PemeriksaanRepository, mainRepo *repositories.Main) PemeriksaanUsecase {
	return &pemeriksaanUsecase{
		formRepo:    formRepo,
		periksaRepo: periksaRepo,
		mainRepo:    mainRepo,
	}
}
// Helper untuk truthiness
func isTruthy(val interface{}) bool {
    switch v := val.(type) {
    case bool:
        return v
    case string:
        return v != ""
    case float64:
        return v != 0
    case []interface{}:
        return len(v) > 0
    case map[string]interface{}:
        return len(v) > 0
    default:
        return false
    }
}

type RiskResult struct {
    KategoriRisiko string
    Rekomendasi    string
}

// evaluateRisk mengevaluasi aturan risiko berdasarkan jawaban
func (u *pemeriksaanUsecase) evaluateRisk(rules []models.FormAturanRisiko, jawaban map[string]interface{}) (RiskResult, error) {
    if len(rules) == 0 {
        return RiskResult{KategoriRisiko: "Normal", Rekomendasi: "Tidak ada tindakan"}, nil
    }

    dataJSON, err := json.Marshal(jawaban)
    if err != nil {
        return RiskResult{KategoriRisiko: "Normal", Rekomendasi: "Tidak ada tindakan"}, err
    }

    for _, rule := range rules {
        logicReader := bytes.NewReader(rule.Kondisi)
        dataReader := bytes.NewReader(dataJSON)
        var resultBuffer bytes.Buffer

        err := jsonlogic.Apply(logicReader, dataReader, &resultBuffer)
        if err != nil {
            continue
        }

        var result bool
        if err := json.Unmarshal(resultBuffer.Bytes(), &result); err != nil {
            var val interface{}
            if err2 := json.Unmarshal(resultBuffer.Bytes(), &val); err2 == nil {
                result = isTruthy(val)
            } else {
                continue
            }
        }

        if result {
            return RiskResult{
                KategoriRisiko: rule.KategoriRisiko,
                Rekomendasi:    rule.Rekomendasi,
            }, nil
        }
    }

    return RiskResult{KategoriRisiko: "Normal", Rekomendasi: "Tidak ada tindakan"}, nil
}

// GetActiveForm mengambil form aktif beserta pertanyaannya
func (u *pemeriksaanUsecase) GetActiveForm(ctx context.Context, kelompok string) (*models.ActiveFormResponse, error) {
    versi, err := u.formRepo.GetActiveFormVersion(ctx, kelompok)
    if err != nil || versi == nil {
        return nil, errors.New("no active form for this kelompok")
    }

    questions, err := u.formRepo.GetQuestionsByVersion(ctx, versi.ID)
    if err != nil {
        return nil, err
    }

    qResp := make([]models.QuestionResponse, len(questions))
    for i, q := range questions {
        var opsi []string
        json.Unmarshal(q.Opsi, &opsi)
        var validasi map[string]interface{}
        json.Unmarshal(q.AturanValidasi, &validasi)

        qResp[i] = models.QuestionResponse{
            ID:             q.ID,
            FormVersiID:    q.FormVersiID,
            Key:            q.Key,
            Label:          q.Label,
            Tipe:           q.Tipe,
            Opsi:           opsi,
            Satuan:         q.Satuan,
            Wajib:          q.Wajib,
            AturanValidasi: validasi,
            Urutan:         q.Urutan,
        }
    }

    return &models.ActiveFormResponse{
        Versi: models.FormVersionResponse{
            ID:         versi.ID,
            Kelompok:   versi.Kelompok,
            Tahun:      versi.Tahun,
            Nama:       versi.Nama,
            Aktif:      versi.Aktif,
            Keterangan: versi.Keterangan,
        },
        Pertanyaan: qResp,
    }, nil
}
// SavePemeriksaan menyimpan data pemeriksaan dan mengevaluasi risiko
func (u *pemeriksaanUsecase) SavePemeriksaan(ctx context.Context, req *models.SavePemeriksaanRequest, petugasID *uint) (*models.PemeriksaanResponse, error) {
    // 1. Get active version
    versi, err := u.formRepo.GetActiveFormVersion(ctx, req.Kelompok)
    if err != nil || versi == nil {
        return nil, errors.New("no active form for kelompok " + req.Kelompok)
    }

    // 2. Parse date
    tgl, err := time.Parse("2006-01-02", req.Tanggal)
    if err != nil {
        return nil, errors.New("invalid date format, use YYYY-MM-DD")
    }

    // 3. Validate required fields and types
    questions, err := u.formRepo.GetQuestionsByVersion(ctx, versi.ID)
    if err != nil {
        return nil, err
    }

    for _, q := range questions {
        val, exists := req.Data[q.Key]
        if q.Wajib && !exists {
            return nil, fmt.Errorf("field '%s' wajib diisi", q.Label)
        }
        if exists {
            switch q.Tipe {
            case "angka":
                if _, ok := val.(float64); !ok {
                    return nil, fmt.Errorf("field '%s' harus angka", q.Label)
                }
            case "boolean":
                if _, ok := val.(bool); !ok {
                    return nil, fmt.Errorf("field '%s' harus boolean", q.Label)
                }
            case "pilihan":
                var opsiList []string
                json.Unmarshal(q.Opsi, &opsiList)
                found := false
                for _, opt := range opsiList {
                    if fmt.Sprintf("%v", val) == opt {
                        found = true
                        break
                    }
                }
                if !found {
                    return nil, fmt.Errorf("nilai '%s' tidak valid untuk field '%s'", val, q.Label)
                }
            }
        }
    }

    // 4. Hitung derived values (IMT)
    jawaban := req.Data
    if berat, ok := jawaban["berat_badan"].(float64); ok {
        if tinggi, ok := jawaban["tinggi_badan"].(float64); ok && tinggi > 0 {
            imt := berat / ((tinggi / 100) * (tinggi / 100))
            jawaban["imt"] = imt
        }
    }

    // 5. Evaluasi risiko
    riskResult := RiskResult{KategoriRisiko: "Normal", Rekomendasi: "Tidak ada tindakan"}
    rules, err := u.formRepo.GetRiskRulesByVersion(ctx, versi.ID)
    if err == nil && len(rules) > 0 {
        riskResult, err = u.evaluateRisk(rules, jawaban)
        if err != nil {
            riskResult = RiskResult{KategoriRisiko: "Normal", Rekomendasi: "Tidak ada tindakan"}
        }
    }

    // 6. Simpan ke database
    jawabanJSON, err := json.Marshal(jawaban)
    if err != nil {
        return nil, err
    }

    pemeriksaan := &models.Pemeriksaan{
        PendudukID:         req.PendudukID,
        Kelompok:           req.Kelompok,
        TanggalPemeriksaan: tgl,
        FormVersiID:        versi.ID,
        Jawaban:            jawabanJSON,
        KategoriRisiko:     riskResult.KategoriRisiko,
        Rekomendasi:        riskResult.Rekomendasi,
        PetugasID:          petugasID,
    }

    if err := u.periksaRepo.CreatePemeriksaan(ctx, pemeriksaan); err != nil {
        return nil, err
    }

    return &models.PemeriksaanResponse{
        ID:                 pemeriksaan.ID,
        PendudukID:         pemeriksaan.PendudukID,
        Kelompok:           pemeriksaan.Kelompok,
        TanggalPemeriksaan: pemeriksaan.TanggalPemeriksaan,
        FormVersiID:        pemeriksaan.FormVersiID,
        KategoriRisiko:     pemeriksaan.KategoriRisiko,
        Rekomendasi:        pemeriksaan.Rekomendasi,
        PetugasID:          pemeriksaan.PetugasID,
        CreatedAt:          pemeriksaan.CreatedAt,
    }, nil
}

// GetRiwayatPenduduk mengambil riwayat pemeriksaan
func (u *pemeriksaanUsecase) GetRiwayatPenduduk(ctx context.Context, pendudukID uint, kelompok string) ([]models.RiwayatPemeriksaanResponse, error) {
    list, err := u.periksaRepo.GetRiwayatByPenduduk(ctx, pendudukID, kelompok)
    if err != nil {
        return nil, err
    }
    res := make([]models.RiwayatPemeriksaanResponse, len(list))
    for i, p := range list {
        res[i] = models.RiwayatPemeriksaanResponse{
            ID:                 p.ID,
            TanggalPemeriksaan: p.TanggalPemeriksaan,
            Kelompok:           p.Kelompok,
            KategoriRisiko:     p.KategoriRisiko,
            Rekomendasi:        p.Rekomendasi,
        }
    }
    return res, nil
}

// GetDetailPemeriksaan mengambil detail pemeriksaan
func (u *pemeriksaanUsecase) GetDetailPemeriksaan(ctx context.Context, id uint) (*models.DetailPemeriksaanResponse, error) {
	if id >= 1000000 {
		pendudukID := int32(id - 1000000)
		db := u.mainRepo.DB()

		// 1. Get penduduk
		var kependudukan models.Kependudukan
		if err := db.Where("id = ? AND deleted_at IS NULL", pendudukID).First(&kependudukan).Error; err != nil {
			return nil, errors.New("penduduk not found")
		}

		// 2. Get anak
		var anak models.Anak
		if err := db.Where("penduduk_id = ? AND deleted_at IS NULL", pendudukID).First(&anak).Error; err != nil {
			return nil, errors.New("anak record not found")
		}

		jawabanMap := make(map[string]interface{})

		// 3. Get growth
		var cp models.CatatanPertumbuhan
		var latestDate time.Time
		hasCp := false
		if err := db.Where("anak_id = ? AND deleted_at IS NULL", anak.ID).Order("tgl_ukur DESC").First(&cp).Error; err == nil {
			hasCp = true
			latestDate = cp.TglUkur

			jawabanMap["berat_badan"] = cp.BeratBadan
			jawabanMap["tinggi_badan"] = cp.TinggiBadan
			jawabanMap["lingkar_kepala"] = cp.LingkarKepala
			jawabanMap["hasil_lila"] = cp.HasilLila
			jawabanMap["imt"] = cp.IMT
			jawabanMap["status_bb_u"] = cp.StatusBBU
			jawabanMap["status_tb_u"] = cp.StatusTBU
			jawabanMap["status_imt_u"] = cp.StatusIMTU
			jawabanMap["status_bb_tb"] = cp.StatusBBTB
			jawabanMap["status_lk_u"] = cp.StatusLKU

			var statusGiziParts []string
			if cp.StatusTBU != "" {
				statusGiziParts = append(statusGiziParts, "TB/U: "+cp.StatusTBU)
			}
			if cp.StatusBBU != "" {
				statusGiziParts = append(statusGiziParts, "BB/U: "+cp.StatusBBU)
			}
			if cp.StatusBBTB != "" {
				statusGiziParts = append(statusGiziParts, "BB/TB: "+cp.StatusBBTB)
			}
			if len(statusGiziParts) > 0 {
				jawabanMap["status_gizi"] = strings.Join(statusGiziParts, ", ")
			}
		}

		var latestPred models.PrediksiStunting
		hasPred := false
		if err := db.Where("anak_id = ? AND deleted_at IS NULL", anak.ID).Order("created_at DESC").First(&latestPred).Error; err == nil {
			hasPred = true
			if latestPred.CreatedAt.After(latestDate) {
				latestDate = latestPred.CreatedAt
			}
		}

		if !hasCp && hasPred {
			jawabanMap["berat_badan"] = latestPred.BeratBadan
			jawabanMap["tinggi_badan"] = latestPred.TinggiBadan
			jawabanMap["lingkar_kepala"] = latestPred.LingkarKepala
			jawabanMap["hasil_lila"] = latestPred.HasilLila
			jawabanMap["status_tb_u"] = latestPred.StatusTBU

			var statusGiziParts []string
			if latestPred.StatusTBU != "" {
				statusGiziParts = append(statusGiziParts, "TB/U: "+latestPred.StatusTBU)
			}
			if len(statusGiziParts) > 0 {
				jawabanMap["status_gizi"] = strings.Join(statusGiziParts, ", ")
			}
		}

		// 4. Get dental
		var pg models.PeriksaGigi
		if err := db.Where("anak_id = ? AND deleted_at IS NULL", anak.ID).Order("tanggal DESC").First(&pg).Error; err == nil {
			if pg.Tanggal.After(latestDate) {
				latestDate = pg.Tanggal
			}
			jawabanMap["jumlah_gigi"] = pg.Jumlahgigi
			jawabanMap["gigi_berlubang"] = pg.GigiBerlubang
			jawabanMap["status_plak"] = pg.StatusPlak
			jawabanMap["resiko_gigi_berlubang"] = pg.ResikoGigiBerlubang
		}

		// 5. Get gizi
		var kg models.KunjunganGizi
		if err := db.Preload("ASI").Preload("MPASI").Where("anak_id = ? AND deleted_at IS NULL", anak.ID).Order("tanggal DESC").First(&kg).Error; err == nil {
			if kg.Tanggal.After(latestDate) {
				latestDate = kg.Tanggal
			}

			if kg.MasihMenyusui != nil {
				jawabanMap["masih_menyusui"] = *kg.MasihMenyusui
			}
			if kg.JenisPemberianSusu != "" {
				jawabanMap["jenis_pemberian_susu"] = kg.JenisPemberianSusu
			}
			if kg.MenggunakanFormula != nil {
				jawabanMap["menggunakan_formula"] = *kg.MenggunakanFormula
			}
			if kg.AlasanFormula != "" {
				jawabanMap["alasan_formula"] = kg.AlasanFormula
			}
			if kg.ObatCacing != nil {
				jawabanMap["obat_cacing"] = *kg.ObatCacing
			}
			if kg.UsiaMulaiMpasi != nil {
				jawabanMap["usia_mulai_mpasi"] = *kg.UsiaMulaiMpasi
			}

			if kg.ASI != nil {
				jawabanMap["frekuensi_menyusui"] = kg.ASI.FrekuensiMenyusui
				jawabanMap["asi_perah"] = kg.ASI.ASIPerah
			}
			if kg.MPASI != nil {
				jawabanMap["diberikan_mpasi"] = kg.MPASI.DiberikanMPASI
				jawabanMap["jumlah_makan_perporsi"] = kg.MPASI.JumlahmakanPerporsi
				jawabanMap["frekuensi_makan_perhari"] = kg.MPASI.FrekuensiMakan
			}
		}

		// 6. Get imunisasi
		var ki models.KehadiranImunisasi
		if err := db.Preload("Detail.JenisPelayanan").Where("anak_id = ? AND deleted_at IS NULL", anak.ID).Order("id DESC").First(&ki).Error; err == nil {
			if ki.CreatedAt.After(latestDate) {
				latestDate = ki.CreatedAt
			}

			var vaksinList []string
			for _, det := range ki.Detail {
				if det.JenisPelayanan != nil {
					vaksinList = append(vaksinList, det.JenisPelayanan.Nama)
				}
			}
			if len(vaksinList) > 0 {
				jawabanMap["imunisasi_diberikan"] = strings.Join(vaksinList, ", ")
			}
		}

		if latestDate.IsZero() {
			latestDate = time.Now()
		}

		ris := "Normal"
		if hasPred {
			if latestPred.StatusPrediksi == "Stunting" {
				ris = "Tinggi"
			} else if latestPred.StatusPrediksi == "Risiko Stunting" {
				ris = "Sedang"
			}
		}

		return &models.DetailPemeriksaanResponse{
			ID:                 id,
			PendudukID:         uint(pendudukID),
			NamaPenduduk:       kependudukan.NamaAnggotaKeluarga,
			Kelompok:           "balita",
			TanggalPemeriksaan: latestDate,
			VersiForm:          "Pemeriksaan Balita Terintegrasi",
			KategoriRisiko:     ris,
			Jawaban:            jawabanMap,
		}, nil
	}

	p, err := u.periksaRepo.GetPemeriksaanByID(ctx, id)
	if err != nil || p == nil {
		return nil, errors.New("pemeriksaan not found")
	}

	penduduk, _ := u.periksaRepo.GetPendudukByID(ctx, p.PendudukID)
	var namaPenduduk string
	if penduduk != nil {
		namaPenduduk = penduduk.NamaAnggotaKeluarga
	}

	versi, _ := u.formRepo.GetFormVersionByID(ctx, p.FormVersiID)
	namaVersi := ""
	if versi != nil {
		namaVersi = versi.Nama
	}

	var jawabanMap map[string]interface{}
	json.Unmarshal(p.Jawaban, &jawabanMap)

	return &models.DetailPemeriksaanResponse{
		ID:                 p.ID,
		PendudukID:         p.PendudukID,
		NamaPenduduk:       namaPenduduk,
		Kelompok:           p.Kelompok,
		TanggalPemeriksaan: p.TanggalPemeriksaan,
		VersiForm:          namaVersi,
		KategoriRisiko:     p.KategoriRisiko,
		Rekomendasi:        p.Rekomendasi,
		Jawaban:            jawabanMap,
	}, nil
}


func (u *pemeriksaanUsecase) CountPendudukWithExamination(kelompok string, pendudukIDs []int32) (int64, error) {
	return u.periksaRepo.CountDistinctPendudukByKelompokAndIDs(kelompok, pendudukIDs)
}

func (u *pemeriksaanUsecase) GetLatestRiskCountByPendudukIDs(kelompok string, pendudukIDs []int32) (map[string]int, error) {
	return u.periksaRepo.GetLatestRiskCountByPendudukIDs(kelompok, pendudukIDs)
}