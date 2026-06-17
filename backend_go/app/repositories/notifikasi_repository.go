package repositories

import (
	"monitoring-service/app/models"
	"time"
)

func (r *Main) GetJadwalForReminder() ([]models.JadwalImunisasiJoin, error) {

	var data []models.JadwalImunisasiJoin

	err := r.postgres.
		Table("jadwal_imunisasi_anak j").
		Select(`
			j.id as jadwal_id,
			j.id_anak,
			a.id as anak_id,
			p.nama_lengkap as nama_anak,
			j.tanggal_estimasi,
			j.id_status_jadwal as status_id,
			s.nama_status,
			dv.nama_dosis
		`).
		Joins("JOIN anak a ON a.id = j.id_anak").
		Joins("JOIN penduduk p ON p.id = a.penduduk_id").
		Joins("JOIN dosis_vaksin dv ON dv.id = j.id_dosis_vaksin").
		Joins("JOIN status_jadwal s ON s.id = j.id_status_jadwal").
		Where("j.tanggal_estimasi IS NOT NULL").
		Where("id_status_jadwal NOT IN ?", []int{6}).Error

	return data, err
}
func (r *Main) GetFCMTokensByUserID(userID uint) ([]string, error) {
	var tokens []string

	err := r.postgres.
		Table("pengguna").
		Select("perangkat.fcm_token").
		Joins("JOIN perangkat ON perangkat.id_pengguna = pengguna.id").
		Where("pengguna.id = ?", userID).
		Scan(&tokens).Error

	return tokens, err
}

func (r *Main) CreateNotifikasi(n models.Notifikasi) error {
	return r.postgres.Table("notifikasi").Create(&n).Error
}

func (r *Main) UpdateReminderFlag(jadwalID uint, field string) error {
	return r.postgres.
		Table("jadwal_imunisasi_anak").
		Where("id = ?", jadwalID).
		Update(field, true).Error
}

func (r *Main) GetUserIDByAnakID(anakID uint) (uint, error) {

	var userID uint

	err := r.postgres.
		Table("anak a").
		Select("p.id as user_id").
		Joins("JOIN kehamilan k ON k.id = a.kehamilan_id").
		Joins("JOIN ibu i ON i.id = k.ibu_id").
		Joins("JOIN penduduk pd ON pd.id = i.penduduk_id").
		Joins("JOIN pengguna p ON p.penduduk_id = pd.id").
		Where("a.id = ?", anakID).
		Scan(&userID).Error

	return userID, err
}

func (r *Main) UpdateStatusJadwal(
	jadwalID uint,
	statusID uint,
) error {

	return r.postgres.
		Table("jadwal_imunisasi_anak").
		Where("id = ?", jadwalID).
		Update(
			"id_status_jadwal",
			statusID,
		).Error
}

func (r *Main) MarkSent(jadwalID uint, tipe string) error {

	update := map[string]interface{}{}

	switch tipe {
	case "h7":
		update["is_sent_h7"] = true
	case "h3":
		update["is_sent_h3"] = true
	case "h":
		update["is_sent_h"] = true
	}

	return r.postgres.
		Table("jadwal_imunisasi_anak").
		Where("id = ?", jadwalID).
		Updates(update).Error
}

func (r *Main) InsertNotifikasi(
	anakID uint,
	title string,
	message string,
) error {

	return r.postgres.Exec(`
		INSERT INTO notifikasi (id_anak, judul, pesan, created_at)
		VALUES (?, ?, ?, NOW())
	`, anakID, title, message).Error
}

func (r *Main) GetFCMTokensByAnakID(anakID uint) ([]string, error) {

	var tokens []string

	err := r.postgres.
		Table("pengguna p").
		Select("d.fcm_token").
		Joins("JOIN anak a ON a.id = ?", anakID).
		Joins("JOIN pengguna u ON u.id = p.id").
		Joins("JOIN perangkat d ON d.id_pengguna = u.id").
		Scan(&tokens).Error

	return tokens, err
}

// Notifikasi Kontrol
func (r *Main) IsKontrolNotifAlreadySentToday(userID uint, date time.Time) (bool, error) {
	var count int64

	dateStr := date.Format("2006-01-02")

	err := r.postgres.
		Table("notifikasi").
		Where("id_pengguna = ?", userID).
		Where("id_tipe_notifikasi = ?", 3).
		Where("DATE(created_at) = ?", dateStr).
		Where("deleted_at IS NULL").
		Count(&count).Error

	if err != nil {
		return false, err
	}

	return count > 0, nil
}

// IbuReminderRow adalah struct hasil query ibu aktif untuk keperluan reminder.
// Berisi user_id, nama_ibu, kehamilan_id, dan HPHT dalam format string.
type IbuReminderRow struct {
	UserID      uint
	NamaIbu     string
	KehamilanID uint
	HPHTStr     string // format "2006-01-02"
}

// GetActiveIbuForTTDReminder mengambil semua ibu dengan kehamilan aktif
// (status TRIMESTER 1/2/3) yang memiliki HPHT, beserta user_id dan nama ibu.
// Digunakan bersama oleh TTD reminder maupun Kontrol reminder.
func (r *Main) GetActiveIbuForTTDReminder() ([]IbuReminderRow, error) {
	var rows []IbuReminderRow

	err := r.postgres.
		Table("kehamilan k").
		Select(`
			p.id          AS user_id,
			pd.nama_lengkap AS nama_ibu,
			k.id          AS kehamilan_id,
			TO_CHAR(k.hpht, 'YYYY-MM-DD') AS hpht_str
		`).
		Joins("JOIN ibu i ON i.id = k.ibu_id").
		Joins("JOIN penduduk pd ON pd.id = i.penduduk_id").
		Joins("JOIN pengguna p ON p.penduduk_id = pd.id").
		Where("k.status_kehamilan IN ?", []string{
			"TRIMESTER 1",
			"TRIMESTER 2",
			"TRIMESTER 3",
		}).
		Where("k.hpht IS NOT NULL").
		Where("k.deleted_at IS NULL").
		Scan(&rows).Error

	return rows, err
}
