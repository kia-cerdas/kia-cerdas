// =====================================================================
// FILE BARU: app/usecases/notifikasi_kontrol_usecase.go
// Letakkan di folder: app/usecases/
// =====================================================================

package usecases

import (
	"log"
	"monitoring-service/app/models"
	"time"
)

// ProcessKontrolReminder mengirim notifikasi FCM kepada ibu hamil
// sebagai reminder jadwal kontrol pemeriksaan kehamilan.
//
// Logika jadwal kontrol (dihitung otomatis dari HPHT):
//   - Trimester 1 (minggu 1–12)  : 1x per bulan → tiap awal bulan kehamilan
//   - Trimester 2 (minggu 13–27) : 2x per bulan → tiap awal & pertengahan bulan kehamilan
//   - Trimester 3 (minggu 28–40) : 3x per bulan → tiap awal bulan kehamilan
//     (disederhanakan: tiap awal bulan karena frekuensi sudah tinggi)
//
// "Awal bulan kehamilan" = hari ke-1 setiap 4 minggu dihitung dari HPHT.
// "Pertengahan bulan"    = hari ke-15 dari awal bulan tersebut.
//
// Reminder dikirim H-1 dari tanggal jadwal, agar ibu punya waktu persiapan.
// Anti-spam: cek tabel notifikasi apakah sudah pernah dikirim hari ini.
func (u *Main) ProcessKontrolReminder() error {

	ibusAktif, err := u.repository.GetActiveIbuForTTDReminder()
	// Kita reuse fungsi yang sama karena mengambil data yang sama:
	// user_id, nama_ibu, kehamilan_id, hpht_str
	if err != nil {
		return err
	}

	now := time.Now()
	hariIni := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, time.Local)

	for _, ibu := range ibusAktif {

		hpht, err := time.ParseInLocation("2006-01-02", ibu.HPHTStr, time.Local)
		if err != nil {
			log.Printf("[KONTROL REMINDER] gagal parse HPHT user_id=%d: %v", ibu.UserID, err)
			continue
		}

		// Hitung usia kehamilan hari ini dalam minggu
		offsetHariTotal := int(hariIni.Sub(
			time.Date(hpht.Year(), hpht.Month(), hpht.Day(), 0, 0, 0, 0, time.Local),
		).Hours() / 24)

		if offsetHariTotal < 0 {
			continue // Belum mulai kehamilan
		}

		mingguKehamilan := offsetHariTotal / 7

		if mingguKehamilan > 42 {
			continue // Lewat batas kehamilan normal
		}

		// Tentukan trimester & jadwal tanggal-tanggal kontrol yang relevan
		jadwalKontrol := hitungJadwalKontrol(hpht, mingguKehamilan)

		for _, jadwal := range jadwalKontrol {
			// Kirim reminder H-1 sebelum jadwal kontrol
			hMinus1 := jadwal.AddDate(0, 0, -1)

			if !hariIni.Equal(hMinus1) {
				continue // Bukan harinya
			}

			// Anti-spam: cek apakah sudah dikirim hari ini
			alreadySent, err := u.repository.IsKontrolNotifAlreadySentToday(ibu.UserID, hariIni)
			if err != nil {
				log.Printf("[KONTROL REMINDER] error cek notif user_id=%d: %v", ibu.UserID, err)
			}
			if alreadySent {
				break
			}

			// Susun pesan dengan konteks trimester
			tglStr := jadwal.Format("02 January 2006")
			trimesterLabel := trimesterDariMinggu(mingguKehamilan)
			title := "⏰ Jadwal Kontrol Kehamilan Besok!"
			body := "Halo Bunda " + ibu.NamaIbu + "! Besok (" + tglStr + ") adalah jadwal kontrol " +
				trimesterLabel + " kehamilanmu. " +
				pesanTrimester(mingguKehamilan) +
				" Buka aplikasi untuk melihat detail jadwal dan persiapanmu. 💪"

			// Kirim FCM
			tokens, err := u.repository.GetFCMTokensByUserID(ibu.UserID)
			if err != nil {
				log.Printf("[KONTROL REMINDER] gagal ambil token user_id=%d: %v", ibu.UserID, err)
				continue
			}

			notifSent := false
			for _, token := range tokens {
				if token == "" {
					continue
				}
				if err := u.sendFCM(token, title, body); err != nil {
					log.Printf("[KONTROL REMINDER] FCM error user_id=%d: %v", ibu.UserID, err)
					continue
				}
				notifSent = true
			}

			if notifSent || len(tokens) == 0 {
				_ = u.repository.CreateNotifikasi(models.Notifikasi{
					PenggunaID:       ibu.UserID,
					Judul:            title,
					Pesan:            body,
					TipeNotifikasiID: 3, // 3 = Reminder Kontrol Pemeriksaan
				})
				log.Printf("[KONTROL REMINDER] terkirim user_id=%d jadwal=%s", ibu.UserID, tglStr)
			}

			break // Satu notif per ibu per run sudah cukup
		}
	}

	return nil
}

// hitungJadwalKontrol mengembalikan daftar tanggal jadwal kontrol yang masih
// relevan (belum lewat) berdasarkan HPHT dan usia kehamilan saat ini.
//
// Aturan:
//   - Trimester 1 (minggu 1–12)  : 1x per bulan (hari ke-1 tiap 4 minggu dari HPHT)
//   - Trimester 2 (minggu 13–27) : 2x per bulan (hari ke-1 & ke-15 tiap 4 minggu)
//   - Trimester 3 (minggu 28–40) : 3x per bulan (hari ke-1 tiap 4 minggu, tapi 3 kali)
//     → disederhanakan: hari ke-1, ke-11, ke-21 tiap 4 minggu
// trimesterDariMinggu mengembalikan label trimester berdasarkan minggu kehamilan.
func trimesterDariMinggu(minggu int) string {
	switch {
	case minggu <= 12:
		return "Trimester 1"
	case minggu <= 27:
		return "Trimester 2"
	default:
		return "Trimester 3"
	}
}

// pesanTrimester mengembalikan kalimat pendek yang relevan sesuai trimester.
func pesanTrimester(minggu int) string {
	switch {
	case minggu <= 12:
		return "Kontrol di trimester awal penting untuk memastikan perkembangan janin berjalan baik."
	case minggu <= 27:
		return "Kontrol rutin di trimester 2 membantu memantau pertumbuhan dan posisi bayi."
	default:
		return "Di trimester akhir, kontrol lebih sering untuk mempersiapkan persalinan yang aman."
	}
}

func hitungJadwalKontrol(hpht time.Time, mingguSaatIni int) []time.Time {
	hphtOnly := time.Date(hpht.Year(), hpht.Month(), hpht.Day(), 0, 0, 0, 0, time.Local)
	hariIni := time.Now()
	hariIniOnly := time.Date(hariIni.Year(), hariIni.Month(), hariIni.Day(), 0, 0, 0, 0, time.Local)

	var jadwals []time.Time

	// Iterasi tiap "bulan kehamilan" (1 bulan = 4 minggu = 28 hari)
	// Trimester 1: bulan 1–3 (minggu 1–12)
	// Trimester 2: bulan 4–7 (minggu 13–27)
	// Trimester 3: bulan 8–10 (minggu 28–40)
	for bulan := 1; bulan <= 10; bulan++ {
		awalBulan := hphtOnly.AddDate(0, 0, (bulan-1)*28)

		var tanggalDalamBulan []time.Time

		switch {
		case bulan <= 3: // Trimester 1: 1x per bulan
			tanggalDalamBulan = []time.Time{
				awalBulan,
			}

		case bulan <= 6: // Trimester 2 (4 bulan): 2x per bulan (awal & pertengahan)
			tanggalDalamBulan = []time.Time{
				awalBulan,
				awalBulan.AddDate(0, 0, 14), // pertengahan bulan (hari ke-15)
			}

		default: // Trimester 3: 3x per bulan (awal, 10 hari, 20 hari)
			tanggalDalamBulan = []time.Time{
				awalBulan,
				awalBulan.AddDate(0, 0, 9),  // hari ke-10
				awalBulan.AddDate(0, 0, 19), // hari ke-20
			}
		}

		for _, tgl := range tanggalDalamBulan {
			// Hanya masukkan jadwal yang belum lewat (termasuk besok)
			if !tgl.Before(hariIniOnly) {
				jadwals = append(jadwals, tgl)
			}
		}
	}

	return jadwals
}