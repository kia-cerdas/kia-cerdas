package usecases

import (
	"log"
	"time"
)

// ProcessKunjunganImunisasiCron menjalankan dua tugas setiap hari:
//  1. Update id_status_kunjungan = 2 untuk kunjungan yang tanggalnya = hari ini
//  2. Kirim notifikasi FCM ke kader:
//     - H-3 sebelum tanggal kunjungan
//     - Hari-H tanggal kunjungan
func (u *Main) ProcessKunjunganImunisasiCron() error {

	// ── 1. Update status kunjungan yang jatuh hari ini ─────────────────────
	affected, err := u.repository.MarkOverdueKunjunganImunisasi()
	if err != nil {
		log.Printf("[KUNJUNGAN CRON] gagal update status: %v", err)
	} else {
		log.Printf("[KUNJUNGAN CRON] update status selesai, %d baris diubah", affected)
	}

	// ── 2. Kirim notifikasi ke kader ────────────────────────────────────────
	today := time.Now().Truncate(24 * time.Hour)

	targets := []struct {
		date  time.Time
		label string
	}{
		{today, "hari-H"},
		{today.AddDate(0, 0, 3), "H-3"},
	}

	for _, t := range targets {
		if err := u.sendKunjunganReminderToKader(t.date, t.label); err != nil {
			log.Printf("[KUNJUNGAN CRON] gagal kirim notifikasi %s: %v", t.label, err)
		}
	}

	return nil
}

func (u *Main) sendKunjunganReminderToKader(targetDate time.Time, label string) error {

	rows, err := u.repository.GetKunjunganForReminder(targetDate)
	if err != nil {
		return err
	}

	if len(rows) == 0 {
		log.Printf("[KUNJUNGAN REMINDER %s] tidak ada kunjungan pada %s",
			label, targetDate.Format("2006-01-02"))
		return nil
	}

	// Kelompokkan per kader agar satu notifikasi = ringkasan semua kunjungan kader itu
	type kaderInfo struct {
		namaAnak  []string
		namaDosis []string
	}

	kaderMap := map[uint]*kaderInfo{}

	for _, row := range rows {
		if row.KaderID == 0 {
			continue
		}

		if _, ok := kaderMap[row.KaderID]; !ok {
			kaderMap[row.KaderID] = &kaderInfo{}
		}

		kaderMap[row.KaderID].namaAnak = append(kaderMap[row.KaderID].namaAnak, row.NamaAnak)
		kaderMap[row.KaderID].namaDosis = append(kaderMap[row.KaderID].namaDosis, row.NamaDosis)
	}

	tglStr := targetDate.Format("02 January 2006")

	for kaderID, info := range kaderMap {

		jumlah := len(info.namaAnak)

		var title, body string

		switch label {
		case "hari-H":
			title = "Kunjungan Pengingat Imunisasi Hari Ini"
			body = "Ada " + itoa(jumlah) + " jadwal kunjungan pengingat imunisasi hari ini (" + tglStr + "). " +
				"Kunjungi keluarga dan ingatkan mereka untuk segera membawa anak ke posyandu."

		case "H-3":
			title = "Pengingat: Jadwal Kunjungan 3 Hari Lagi"
			body = "Ada " + itoa(jumlah) + " jadwal kunjungan pengingat imunisasi pada " + tglStr + ". " +
				"Persiapkan daftar keluarga yang akan dikunjungi."
		}

		tokens, err := u.repository.GetFCMTokensByKaderID(kaderID)
		if err != nil {
			log.Printf("[KUNJUNGAN REMINDER %s] gagal ambil token kader_id=%d: %v", label, kaderID, err)
			continue
		}

		if len(tokens) == 0 {
			log.Printf("[KUNJUNGAN REMINDER %s] tidak ada token untuk kader_id=%d", label, kaderID)
			continue
		}

		fcmData := map[string]string{
			"type": "kunjungan_imunisasi_reminder",
		}

		for _, token := range tokens {
			if token == "" {
				continue
			}

			if err := u.sendFCMWithData(token, title, body, fcmData); err != nil {
				log.Printf("[KUNJUNGAN REMINDER %s] FCM error kader_id=%d: %v", label, kaderID, err)
			}
		}

		log.Printf("[KUNJUNGAN REMINDER %s] notifikasi terkirim ke kader_id=%d (%d kunjungan)",
			label, kaderID, jumlah)
	}

	return nil
}

// itoa konversi int ke string tanpa import strconv agar tidak polusi import.
func itoa(n int) string {
	if n == 0 {
		return "0"
	}
	buf := [20]byte{}
	pos := len(buf)
	for n > 0 {
		pos--
		buf[pos] = byte(n%10) + '0'
		n /= 10
	}
	return string(buf[pos:])
}
