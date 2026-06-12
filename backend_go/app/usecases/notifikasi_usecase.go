package usecases

import (
	"fmt"
	"log"
	"monitoring-service/app/models"
	"time"

	"context"

	"firebase.google.com/go/v4/messaging"
)

func (u *Main) sendFCM(
	token,
	title,
	message string,
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
				body = "Halo Ibu " + j.NamaAnak + ", jadwal imunisasi " + j.NamaDosis + " semakin dekat (3 hari lagi). Ketepatan waktu membantu menjaga perlindungan anak tetap optimal. Silakan kunjungi Posyandu atau Puskesmas terdekat."
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

				if err := u.sendFCM(t, title, body); err != nil {
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
		namaAnak = anak.Penduduk.NamaLengkap
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
			JadwalImunisasiAnakId: j.ID,
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
				nowDate.Sub(tgl).Hours() / 24,
			)

		var newStatus uint

		switch {

		case diff < 0:
			newStatus = 1

		case diff <= 3:
			newStatus = 2

		case diff <= 6:
			newStatus = 3

		case diff <= 13:
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
