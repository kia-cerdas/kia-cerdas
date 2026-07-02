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

	// Kirim satu notifikasi per anak per kader
	for _, row := range rows {
		if row.KaderID == 0 {
			continue
		}

		var title, body string

		switch label {
		case "hari-H":
			title = "Pengingat Kunjungan Imunisasi"
			body = "Kunjungi anak " + row.NamaAnak + " hari ini, jadwal " + row.NamaDosis + " nya terlewat"
		case "H-3":
			title = "Pengingat Kunjungan Imunisasi"
			body = "Kunjungi anak " + row.NamaAnak + " minggu ini, jadwal " + row.NamaDosis + " nya terlewat"
		}

		tokens, err := u.repository.GetFCMTokensByKaderID(row.KaderID)
		if err != nil {
			log.Printf("[KUNJUNGAN REMINDER %s] gagal ambil token kader_id=%d: %v", label, row.KaderID, err)
			continue
		}

		if len(tokens) == 0 {
			log.Printf("[KUNJUNGAN REMINDER %s] tidak ada token untuk kader_id=%d", label, row.KaderID)
			continue
		}

		fcmData := map[string]string{
			"type":          "kunjungan_imunisasi_reminder",
			"kunjungan_id":  itoa(int(row.KunjunganID)),
			"anak_nama":     row.NamaAnak,
			"nama_dosis":    row.NamaDosis,
			"reminder_type": label, // hari-H atau H-3
		}

		for _, token := range tokens {
			if token == "" {
				continue
			}

			if err := u.sendFCMWithData(token, title, body, fcmData); err != nil {
				log.Printf("[KUNJUNGAN REMINDER %s] FCM error kader_id=%d kunjungan_id=%d: %v",
					label, row.KaderID, row.KunjunganID, err)
			}
		}

		log.Printf("[KUNJUNGAN REMINDER %s] notifikasi terkirim ke kader_id=%d kunjungan_id=%d anak=%s",
			label, row.KaderID, row.KunjunganID, row.NamaAnak)
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
