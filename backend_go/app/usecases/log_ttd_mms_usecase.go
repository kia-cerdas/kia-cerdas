package usecases

import (
	"errors"
	"monitoring-service/app/models"
	"monitoring-service/app/repositories"
	"time"
)

type LogTTDMMSUsecase interface {
	GetMine(userID int32) ([]models.LogTTDMMS, error)
	SaveMine(userID int32, bulanKe int32, hariKe int32, sudahDiminum bool) (*models.LogTTDMMS, error)
	// Untuk kader 
	GetRekapKader(posyanduID *int32) ([]repositories.RekapIbuTTDMMS, error)
	GetDetailLogKader(posyanduID *int32, kehamilanID int32) ([]models.LogTTDMMS, error) 
}

type logTTDMMSUsecase struct {
	repo *repositories.LogTTDMMSRepository
}

func NewLogTTDMMSUsecase(repo *repositories.LogTTDMMSRepository) LogTTDMMSUsecase {
	return &logTTDMMSUsecase{repo: repo}
}

func (u *logTTDMMSUsecase) GetMine(userID int32) ([]models.LogTTDMMS, error) {
	if userID == 0 {
		return nil, errors.New("user_id tidak valid")
	}

	kehamilan, err := u.repo.FindActiveKehamilanByUserID(userID)
	if err != nil {
		return nil, errors.New("kehamilan aktif tidak ditemukan")
	}

	return u.repo.FindByKehamilanID(kehamilan.ID)
}

// func (u *logTTDMMSUsecase) SaveMine(
// 	userID int32,
// 	bulanKe int32,
// 	hariKe int32,
// 	sudahDiminum bool,
// ) (*models.LogTTDMMS, error) {
// 	if userID == 0 {
// 		return nil, errors.New("user_id tidak valid")
// 	}
// 	if bulanKe < 1 || bulanKe > 10 {
// 		return nil, errors.New("bulan_ke harus antara 1 sampai 10")
// 	}
// 	if hariKe < 1 || hariKe > 31 {
// 		return nil, errors.New("hari_ke harus antara 1 sampai 31")
// 	}

// 	kehamilan, err := u.repo.FindActiveKehamilanByUserID(userID)
// 	if err != nil {
// 		return nil, errors.New("kehamilan aktif tidak ditemukan")
// 	}

// 	log := &models.LogTTDMMS{
// 		KehamilanID:   kehamilan.ID,
// 		BulanKe:       bulanKe,
// 		HariKe:        hariKe,
// 		SudahDiminum:  sudahDiminum,
// 	}

// 	if err := u.repo.Upsert(log); err != nil {
// 		return nil, err
// 	}

// 	return log, nil
// }

func (u *logTTDMMSUsecase) SaveMine(
	userID int32,
	bulanKe int32,
	hariKe int32,
	sudahDiminum bool,
) (*models.LogTTDMMS, error) {
	if userID == 0 {
		return nil, errors.New("user_id tidak valid")
	}
	if bulanKe < 1 || bulanKe > 10 {
		return nil, errors.New("bulan_ke harus antara 1 sampai 10")
	}
	if hariKe < 1 || hariKe > 31 {
		return nil, errors.New("hari_ke harus antara 1 sampai 31")
	}
 
	kehamilan, err := u.repo.FindActiveKehamilanByUserID(userID)
	if err != nil {
		return nil, errors.New("kehamilan aktif tidak ditemukan")
	}
 
	// Hitung tanggal kalender dari bulan_ke dan hari_ke berdasarkan HPHT
	// Rumus: tanggal = HPHT + ((bulan_ke - 1) * 30) + (hari_ke - 1) hari
	hpht := kehamilan.HPHT
	offsetHari := int((bulanKe-1)*30 + (hariKe - 1))
	tanggalLog := hpht.AddDate(0, 0, offsetHari)
	tanggalLog = time.Date(tanggalLog.Year(), tanggalLog.Month(), tanggalLog.Day(), 0, 0, 0, 0, time.Local)
 
	// Ambil tanggal hari ini dan kemarin (tanpa jam)
	now := time.Now()
	hariIni := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, time.Local)
	kemarin := hariIni.AddDate(0, 0, -1)
 
	// Validasi: hanya hari ini dan kemarin yang boleh diisi
	if tanggalLog.After(hariIni) {
		return nil, errors.New("tidak dapat mengisi log untuk hari yang akan datang")
	}
	if tanggalLog.Before(kemarin) {
		return nil, errors.New("tidak dapat mengisi log untuk lebih dari 1 hari yang lalu, hanya hari ini dan kemarin yang diperbolehkan")
	}
 
	log := &models.LogTTDMMS{
		KehamilanID:  kehamilan.ID,
		BulanKe:      bulanKe,
		HariKe:       hariKe,
		SudahDiminum: sudahDiminum,
	}
 
	if err := u.repo.Upsert(log); err != nil {
		return nil, err
	}
 
	return log, nil
}
 


// BAGIAN KADER
 
const hariPerBulan = 30
 
// GetRekapKader mengembalikan rekap kepatuhan TTD/MMS semua ibu hamil
// yang berada di posyandu yang sama dengan kader.
func (u *logTTDMMSUsecase) GetRekapKader(posyanduID *int32) ([]repositories.RekapIbuTTDMMS, error) {
	if posyanduID == nil {
		return nil, errors.New("posyandu_id tidak valid")
	}
 
	kehamilanList, err := u.repo.FindAllActiveKehamilanByPosyanduID(*posyanduID)
	if err != nil {
		return nil, errors.New("gagal mengambil data kehamilan")
	}
	if len(kehamilanList) == 0 {
		return []repositories.RekapIbuTTDMMS{}, nil
	}
 
	kehamilanIDs := make([]int32, 0, len(kehamilanList))
	kehamilanMap := make(map[int32]models.Kehamilan)
	for _, k := range kehamilanList {
		kehamilanIDs = append(kehamilanIDs, k.ID)
		kehamilanMap[k.ID] = k
	}
 
	logs, err := u.repo.FindLogByKehamilanIDs(kehamilanIDs)
	if err != nil {
		return nil, errors.New("gagal mengambil log TTD/MMS")
	}
 
	logMap := make(map[int32][]models.LogTTDMMS)
	for _, l := range logs {
		logMap[l.KehamilanID] = append(logMap[l.KehamilanID], l)
	}
 
	now := time.Now()
	result := make([]repositories.RekapIbuTTDMMS, 0, len(kehamilanList))
 
	for _, kehamilan := range kehamilanList {
		namaIbu := ""
		if kehamilan.Ibu != nil && kehamilan.Ibu.Kependudukan != nil {
			namaIbu = kehamilan.Ibu.Kependudukan.NamaAnggotaKeluarga
		}
 
		selisihHari := int(now.Sub(kehamilan.HPHT).Hours() / 24)
		bulanKeSaatIni := int32(selisihHari/hariPerBulan) + 1
		if bulanKeSaatIni < 1 {
			bulanKeSaatIni = 1
		}
		if bulanKeSaatIni > 10 {
			bulanKeSaatIni = 10
		}
 
		totalHariSeharusnya := int32(selisihHari + 1)
		if totalHariSeharusnya < 0 {
			totalHariSeharusnya = 0
		}
		if totalHariSeharusnya > 300 {
			totalHariSeharusnya = 300
		}
 
		ibuLogs := logMap[kehamilan.ID]
		var totalDiminum int32
		for _, l := range ibuLogs {
			if l.SudahDiminum {
				totalDiminum++
			}
		}
 
		totalTerlewat := totalHariSeharusnya - totalDiminum
		if totalTerlewat < 0 {
			totalTerlewat = 0
		}
 
		result = append(result, repositories.RekapIbuTTDMMS{
			HPHT:          kehamilan.HPHT.Format("2006-01-02"),
			IbuID:         kehamilan.IbuID,
			KehamilanID:   kehamilan.ID,
			NamaIbu:       namaIbu,
			BulanKe:       bulanKeSaatIni,
			TotalHari:     totalHariSeharusnya,
			TotalDiminum:  totalDiminum,
			TotalTerlewat: totalTerlewat,
		})
	}
 
	return result, nil
}
 
// GetDetailLogKader mengembalikan seluruh log harian TTD/MMS milik satu ibu
// berdasarkan kehamilan_id. Kader hanya boleh melihat ibu di posyandunya sendiri.
func (u *logTTDMMSUsecase) GetDetailLogKader(posyanduID *int32, kehamilanID int32) ([]models.LogTTDMMS, error) {
	if posyanduID == nil {
		return nil, errors.New("posyandu_id tidak valid")
	}
	if kehamilanID == 0 {
		return nil, errors.New("kehamilan_id tidak valid")
	}
 
	// Verifikasi kehamilan ini memang ada di posyandu kader (keamanan)
	belongs, err := u.repo.IsKehamilanInPosyandu(kehamilanID, *posyanduID)
	if err != nil || !belongs {
		return nil, errors.New("data tidak ditemukan atau tidak dalam wilayah kader")
	}
 
	return u.repo.FindByKehamilanID(kehamilanID)
}