package usecases

import (
	"fmt"
	"log"
	"monitoring-service/app/models"
	"strings"
	"time"

	"context"

	"firebase.google.com/go/v4/messaging"
)

var bulanID = [...]string{
	"", "Januari", "Februari", "Maret", "April", "Mei", "Juni",
	"Juli", "Agustus", "September", "Oktober", "November", "Desember",
}

func formatTanggalID(t time.Time) string {
	return fmt.Sprintf("%02d %s %d", t.Day(), bulanID[t.Month()], t.Year())
}
func (u *Main) sendFCM(
	token,
	title,
	message string,
) error {
	return u.sendFCMWithData(token, title, message, nil)
}

func (u *Main) sendFCMWithData(
	token,
	title,
	message string,
	data map[string]string,
) error {

	if u.fcmClient == nil {
		return fmt.Errorf(
			"fcm client belum diinisialisasi",
		)
	}

	msg := &messaging.Message{
		Token: token,
		Notification: &messaging.Notification{
			Title: title,
			Body:  message,
		},
		Data: data,
	}

	response, err := u.fcmClient.Send(
		context.Background(),
		msg,
	)

	if err != nil {
		return err
	}

	log.Printf(
		"[FCM] MessageID=%s",
		response,
	)

	return nil
}

func (u *Main) ProcessReminder() error {

	jadwals, err := u.repository.GetJadwalForReminder()
	if err != nil {
		return err
	}

	nowDate := time.Now().Truncate(24 * time.Hour)

	for _, j := range jadwals {

		log.Printf("[REMINDER] anak=%s dosis=%s status=%d",
			j.NamaAnak,
			j.NamaDosis,
			j.StatusID,
		)

		if j.TanggalEstimasi == nil {
			continue
		}

		tglDate := j.TanggalEstimasi.Truncate(24 * time.Hour)

		diff := int(tglDate.YearDay() - nowDate.YearDay() +
			(tglDate.Year()-nowDate.Year())*365)

		log.Printf(
			"[DEBUG] anak=%s dosis=%s diff=%d",
			j.NamaAnak,
			j.NamaDosis,
			diff,
		)

		var (
			title    string
			body     string
			needSend bool
		)

		switch diff {

		case 7:
			if j.StatusID == 1 && !j.IsSentH7 {
				title = "Imunisasi 7 Hari Lagi"
				body = "Halo Ibu " + j.NamaAnak + ", jadwal imunisasi " + j.NamaDosis + " akan berlangsung 7 hari lagi. Imunisasi tepat waktu membantu menjaga perlindungan anak dari risiko penyakit. Silakan lakukan di Posyandu atau Puskesmas terdekat."
				needSend = true
				u.repository.MarkSent(j.JadwalID, "h7")
			}

		case 3:
			if j.StatusID == 1 && !j.IsSentH3 {
				title = "Imunisasi 3 Hari Lagi"
				body = "Halo Ibu " + j.NamaAnak + ", jadwal imunisasi " + j.NamaDosis + " 3 hari lagi. Ketepatan waktu membantu menjaga perlindungan anak tetap optimal. Silakan kunjungi Posyandu atau Puskesmas terdekat."
				needSend = true
				u.repository.MarkSent(j.JadwalID, "h3")
			}

		case 0:
			if j.StatusID == 2 && !j.IsSentH {
				title = "Hari Imunisasi"
				body = "Halo Ibu " + j.NamaAnak + ", hari ini jadwal imunisasi " + j.NamaDosis + ". Imunisasi tepat waktu membantu mencegah risiko penyakit dan menjaga kekebalan anak. Silakan lakukan di Posyandu atau Puskesmas terdekat."
				needSend = true
				u.repository.MarkSent(j.JadwalID, "h")
			}
		}

		// ================= SEND NOTIFICATION =================
		if needSend {

			tokens, err := u.repository.GetFCMTokensByAnakID(j.AnakID)
			if err != nil {
				log.Println("[REMINDER] gagal ambil token:", err)
				continue
			}

			for _, t := range tokens {
				if t == "" {
					continue
				}

				log.Println("[REMINDER] sending FCM to anak:", j.AnakID)

				fcmData := map[string]string{
					"type":      "reminder_imunisasi",
					"jadwal_id": fmt.Sprintf("%d", j.JadwalID),
					"anak_id":   fmt.Sprintf("%d", j.AnakID),
				}

				if err := u.sendFCMWithData(t, title, body, fcmData); err != nil {
					log.Println("[REMINDER] FCM error:", err)
				}
			}

			log.Println("[REMINDER] sent OK")

			if err := u.repository.InsertNotifikasi(
				j.AnakID,
				title,
				body,
			); err != nil {
				log.Println("[REMINDER] gagal simpan notifikasi:", err)
			}
		}
	}

	return nil
}

func (u *Main) send(
	j models.JadwalImunisasiAnak,
	title, message string,
) error {

	// 1. ambil user dari anak
	userID, err := u.repository.GetUserIDByAnakID(j.AnakID)
	if err != nil {
		return err
	}

	// 2. ambil token FCM
	tokens, err := u.repository.GetFCMTokensByUserID(userID)
	if err != nil {
		return err
	}

	// 3. ambil data anak
	anak, err := u.repository.GetAnakByID(j.AnakID)

	namaAnak := "Anak"

	if err == nil && anak != nil && anak.Penduduk != nil {
		namaAnak = anak.Penduduk.NamaAnggotaKeluarga
	}

	// 4. ambil nama imunisasi (dosis vaksin)
	jadwal, err := u.repository.GetJadwalImunisasiByJadwalID(int32(userID), j.ID)
	if err != nil || jadwal == nil {
		// fallback aman
		jadwal = &models.JadwalImunisasiJoin{
			NamaDosis: "Imunisasi",
		}
	}

	// 5. compose message
	finalTitle := title
	finalBody := namaAnak + " - " + jadwal.NamaDosis + " | " + message

	// 6. loop token
	for _, token := range tokens {

		if token == "" {
			continue
		}

		// kirim FCM (jangan block error)
		_ = u.sendFCM(token, finalTitle, finalBody)

		// simpan notifikasi ke DB
		_ = u.repository.CreateNotifikasi(models.Notifikasi{
			PenggunaID:            userID,
			Judul:                 finalTitle,
			Pesan:                 finalBody,
			TipeNotifikasiID:      1,
		})
	}

	return nil
}
func (u *Main) SendTestFCM(
	userID uint,
) error {

	log.Printf(
		"[TEST FCM] user_id=%d",
		userID,
	)

	tokens, err :=
		u.repository.
			GetFCMTokensByUserID(
				userID,
			)

	if err != nil {
		return err
	}

	log.Printf(
		"[TEST FCM] jumlah token=%d",
		len(tokens),
	)

	for _, token := range tokens {

		if token == "" {

			log.Printf(
				"[TEST FCM] token kosong",
			)

			continue
		}

		log.Printf(
			"[TEST FCM] mengirim notifikasi",
		)

		err := u.sendFCM(
			token,
			"TEST 14:30",
			"Jika ini muncul berarti FCM sukses",
		)

		if err != nil {

			log.Printf(
				"[TEST FCM] gagal=%v",
				err,
			)

			return err
		}

		log.Printf(
			"[TEST FCM] berhasil",
		)
	}

	return nil
}

func (u *Main) UpdateStatusJadwal() error {

	jadwals, err :=
		u.repository.GetJadwalForReminder()

	if err != nil {
		return err
	}

	nowDate := time.Now().Truncate(24 * time.Hour)

	for _, j := range jadwals {

		if j.TanggalEstimasi == nil {
			continue
		}

		if j.StatusID == 6 {
			continue
		}

		tgl :=
			j.TanggalEstimasi.
				Truncate(24 * time.Hour)

		diff :=
			int(
				tgl.Sub(nowDate).Hours() / 24,
			)

		var newStatus uint

		switch {

		case diff >= 1:
			newStatus = 1

		case diff == 0:
			newStatus = 2

		case diff >= -6:
			newStatus = 3

		case diff >= -14:
			newStatus = 4

		default:
			newStatus = 5
		}

		if newStatus != j.StatusID {

			err :=
				u.repository.UpdateStatusJadwal(
					j.JadwalID,
					newStatus,
				)

			if err != nil {
				return err
			}
		}
	}

	return nil
}

// ProcessPosyanduReminder mengirim notifikasi kepada semua ibu
// bila ada jadwal layanan posyandu yang akan berlangsung H-3.
// Logic:
//   - ambil jadwal dengan tanggal = today + 3
//   - komposisi pesan mencantumkan nama posyandu, layanan, tanggal, dan daftar dosis
//   - ambil seluruh list ibu (repository.Ibu.FindAll())
//   - untuk setiap ibu, temukan user via repository.User.FindByPendudukID
//   - ambil token FCM dan kirim
//   - simpan notifikasi ke tabel notifikasi
func (u *Main) ProcessPosyanduReminder() error {

	target := time.Now().AddDate(0, 0, 3)
	// normalisasi hanya tanggal
	t := time.Date(target.Year(), target.Month(), target.Day(), 0, 0, 0, 0, time.Local)

	// Notifications should see all jadwal (no desa filter)
	jadwals, err := u.repository.JadwalLayanan.GetByDateRange(nil, &t, &t, nil)
	if err != nil {
		return err
	}

	if len(jadwals) == 0 {
		return nil
	}

	// susun pesan per jadwal
	for _, j := range jadwals {

		posyanduName := ""
		if j.Posyandu != nil {
			posyanduName = j.Posyandu.Nama
		}

		// daftar nama dosis
		dosisList := []string{}
		for _, d := range j.DosisVaksins {
			dosisList = append(dosisList, d.NamaDosis)
		}

		tglStr := "-"
		if j.Tanggal != nil {
			tglStr = formatTanggalID(*j.Tanggal)
		}

		title := "Pelayanan Posyandu dalam 3 Hari"
		body := "Halo Ibu, akan ada layanan " + j.Layanan + " di " + posyanduName + " pada " + tglStr + "."
		if len(dosisList) > 0 {
			body += " Tersedia: " + strings.Join(dosisList, ", ") + "."
		}

		// ambil semua ibu
		ibus, err := u.repository.Ibu.FindAll()
		if err != nil {
			log.Printf("[POSYANDU REMINDER] gagal ambil list ibu: %v", err)
			continue
		}

		for _, ibu := range ibus {
			// cari pengguna berdasarkan penduduk id
			var pendudukID int64 = int64(ibu.IDKependudukan)
			user, err := u.repository.User.FindByPendudukID(pendudukID)
			if err != nil || user == nil {
				continue
			}

			tokens, err := u.repository.GetFCMTokensByUserID(uint(user.ID))
			if err != nil {
				log.Printf("[POSYANDU REMINDER] gagal ambil token user_id=%d: %v", user.ID, err)
				continue
			}

			sentAny := false
			for _, token := range tokens {
				if token == "" {
					continue
				}
				if err := u.sendFCM(token, title, body); err != nil {
					log.Printf("[POSYANDU REMINDER] FCM error user_id=%d: %v", user.ID, err)
					continue
				}
				sentAny = true
			}

			if sentAny || len(tokens) == 0 {
				// simpan notifikasi
				_ = u.repository.CreateNotifikasi(models.Notifikasi{
					PenggunaID:       uint(user.ID),
					Judul:            title,
					Pesan:            body,
					TipeNotifikasiID: 4, // 4 = Reminder Posyandu (asumsi)
				})
			}
		}
	}

	return nil
}
