# ✅ VERIFIED: Mapping Code Sequence Diagram 4.5
## Pengiriman Notifikasi Pengingat Imunisasi (H-7, H-3, H-0)

**STATUS:** ✅ Semua function dalam diagram ini **SUDAH DIVERIFIKASI** ada di code actual!

---

## 🎯 FOKUS DIAGRAM INI:

Diagram ini menjelaskan bagaimana sistem **otomatis mengirim notifikasi pengingat imunisasi** kepada orang tua melalui **mobile app** pada:
- **H-7**: 7 hari sebelum tanggal imunisasi
- **H-3**: 3 hari sebelum tanggal imunisasi  
- **H-0**: Hari H (tanggal imunisasi)

Proses ini berjalan **otomatis** setiap hari menggunakan **Cron Job**.

---

## 📋 KOMPONEN DALAM DIAGRAM

| Komponen | File Path | Keterangan |
|----------|-----------|------------|
| **Cron Job** | `backend_go/app/app.go` | Scheduler yang berjalan setiap hari jam 08:00 WIB |
| **NotifikasiUsecase** | `backend_go/app/usecases/notifikasi_usecase.go` | Business logic pengiriman notifikasi |
| **NotifikasiRepository** | `backend_go/app/repositories/notifikasi_repository.go` | Data access untuk notifikasi |
| **Database (PostgreSQL)** | - | Database server |
| **Firebase Cloud Messaging (FCM)** | - | Service push notification |
| **Mobile App** | - | Aplikasi mobile orang tua |

---

## 🔍 FUNCTION MAPPING (VERIFIED - Bisa dicari dengan Ctrl+F)

### 1️⃣ Cron Job Setup
**File:** `backend_go/app/app.go`  
**Line:** ~68-72  
**Search keyword:** `ProcessReminder`

**Code:**
```go
// 3. reminder imunisasi
if err := m.usecase.ProcessReminder(); err != nil {
	log.Printf("[CRON] reminder error: %v", err)
}
```

**Cara Verifikasi:**
```
1. Buka file: backend_go/app/app.go
2. Tekan Ctrl+F
3. Ketik: ProcessReminder
4. ✅ Akan ketemu di line ~70
```

---

### 2️⃣ ProcessReminder (Main Function)
**File:** `backend_go/app/usecases/notifikasi_usecase.go`  
**Line:** 65  
**Search keyword:** `func (u *Main) ProcessReminder`

**Code:**
```go
func (u *Main) ProcessReminder() error {

	jadwals, err := u.repository.GetJadwalForReminder()
	if err != nil {
		return err
	}

	nowDate := time.Now().Truncate(24 * time.Hour)

	for _, j := range jadwals {
		
		// Hitung selisih hari
		tglDate := j.TanggalEstimasi.Truncate(24 * time.Hour)
		diff := int(tglDate.YearDay() - nowDate.YearDay() +
			(tglDate.Year()-nowDate.Year())*365)

		var (
			title    string
			body     string
			needSend bool
		)

		switch diff {

		case 7:
			if j.StatusID == 1 && !j.IsSentH7 {
				title = "Imunisasi 7 Hari Lagi"
				body = "Halo Ibu " + j.NamaAnak + ", jadwal imunisasi " + j.NamaDosis + " akan berlangsung 7 hari lagi..."
				needSend = true
				u.repository.MarkSent(j.JadwalID, "h7")
			}

		case 3:
			if j.StatusID == 1 && !j.IsSentH3 {
				title = "Imunisasi 3 Hari Lagi"
				body = "Halo Ibu " + j.NamaAnak + ", jadwal imunisasi " + j.NamaDosis + " 3 hari lagi..."
				needSend = true
				u.repository.MarkSent(j.JadwalID, "h3")
			}

		case 0:
			if j.StatusID == 2 && !j.IsSentH {
				title = "Hari Imunisasi"
				body = "Halo Ibu " + j.NamaAnak + ", hari ini jadwal imunisasi " + j.NamaDosis + "..."
				needSend = true
				u.repository.MarkSent(j.JadwalID, "h")
			}
		}

		// Kirim notifikasi
		if needSend {
			tokens, err := u.repository.GetFCMTokensByAnakID(j.AnakID)
			// ... kirim FCM ...
		}
	}

	return nil
}
```

**Cara Verifikasi:**
```
1. Buka file: backend_go/app/usecases/notifikasi_usecase.go
2. Tekan Ctrl+F
3. Ketik: ProcessReminder
4. ✅ Akan ketemu di line 65
```

---

### 3️⃣ GetJadwalForReminder
**File:** `backend_go/app/repositories/notifikasi_repository.go`  
**Line:** ~8  
**Search keyword:** `GetJadwalForReminder`

**Code:**
```go
func (r *Main) GetJadwalForReminder() ([]models.JadwalImunisasiJoin, error) {

	var data []models.JadwalImunisasiJoin

	err := r.postgres.
		Table("jadwal_imunisasi_anak jia").
		Select(`
			jia.id as jadwal_id,
			jia.tanggal_estimasi,
			jia.id_status_jadwal as status_id,
			jia.is_sent_h7,
			jia.is_sent_h3,
			jia.is_sent_h,
			a.id as anak_id,
			p.nama_anggota_keluarga as nama_anak,
			dv.nama_dosis
		`).
		Joins("JOIN anak a ON a.id = jia.anak_id").
		Joins("JOIN penduduk p ON p.id = a.penduduk_id").
		Joins("JOIN dosis_vaksin dv ON dv.id = jia.id_dosis_vaksin").
		Where("jia.tanggal_estimasi IS NOT NULL").
		Where("jia.id_status_jadwal IN (?)", []int{1, 2}).
		Find(&data).Error

	if err != nil {
		return nil, err
	}

	return data, nil
}
```

**SQL yang dieksekusi:**
```sql
SELECT jia.id, jia.tanggal_estimasi, jia.id_status_jadwal,
       jia.is_sent_h7, jia.is_sent_h3, jia.is_sent_h,
       a.id as anak_id, p.nama_anggota_keluarga, dv.nama_dosis
FROM jadwal_imunisasi_anak jia
JOIN anak a ON a.id = jia.anak_id
JOIN penduduk p ON p.id = a.penduduk_id
JOIN dosis_vaksin dv ON dv.id = jia.id_dosis_vaksin
WHERE jia.tanggal_estimasi IS NOT NULL
AND jia.id_status_jadwal IN (1, 2)
```

**Cara Verifikasi:**
```
1. Buka file: backend_go/app/repositories/notifikasi_repository.go
2. Tekan Ctrl+F
3. Ketik: GetJadwalForReminder
4. ✅ Akan ketemu function ini
```

---

### 4️⃣ MarkSent (Update Flag Notifikasi)
**File:** `backend_go/app/repositories/notifikasi_repository.go`  
**Search keyword:** `MarkSent`

**Code:**
```go
func (r *Main) MarkSent(jadwalID int32, tipe string) error {
	field := "is_sent_h"
	
	switch tipe {
	case "h7":
		field = "is_sent_h7"
	case "h3":
		field = "is_sent_h3"
	case "h":
		field = "is_sent_h"
	}

	return r.postgres.
		Model(&models.JadwalImunisasiAnak{}).
		Where("id = ?", jadwalID).
		Update(field, true).Error
}
```

**SQL yang dieksekusi:**
```sql
UPDATE jadwal_imunisasi_anak
SET is_sent_h7 = true  -- atau is_sent_h3, is_sent_h
WHERE id = ?
```

---

### 5️⃣ GetFCMTokensByAnakID
**File:** `backend_go/app/repositories/notifikasi_repository.go`  
**Search keyword:** `GetFCMTokensByAnakID`

**Code:**
```go
func (r *Main) GetFCMTokensByAnakID(anakID int32) ([]string, error) {
	var tokens []string

	err := r.postgres.
		Table("pengguna p").
		Select("p.fcm_token").
		Joins("JOIN ibu i ON i.penduduk_id = p.penduduk_id").
		Joins("JOIN kehamilan k ON k.ibu_id = i.id").
		Joins("JOIN anak a ON a.kehamilan_id = k.id").
		Where("a.id = ?", anakID).
		Where("p.fcm_token IS NOT NULL").
		Where("p.fcm_token != ''").
		Pluck("p.fcm_token", &tokens).Error

	if err != nil {
		return nil, err
	}

	return tokens, nil
}
```

**SQL yang dieksekusi:**
```sql
SELECT p.fcm_token
FROM pengguna p
JOIN ibu i ON i.penduduk_id = p.penduduk_id
JOIN kehamilan k ON k.ibu_id = i.id
JOIN anak a ON a.kehamilan_id = k.id
WHERE a.id = ? AND p.fcm_token IS NOT NULL
```

---

### 6️⃣ sendFCMWithData (Kirim Push Notification)
**File:** `backend_go/app/usecases/notifikasi_usecase.go`  
**Line:** ~31  
**Search keyword:** `sendFCMWithData`

**Code:**
```go
func (u *Main) sendFCMWithData(
	token,
	title,
	message string,
	data map[string]string,
) error {

	if u.fcmClient == nil {
		return fmt.Errorf("fcm client belum diinisialisasi")
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

	log.Printf("[FCM] MessageID=%s", response)

	return nil
}
```

**FCM Payload:**
```json
{
  "notification": {
    "title": "Imunisasi 7 Hari Lagi",
    "body": "Halo Ibu Ahmad, jadwal imunisasi BCG akan berlangsung 7 hari lagi..."
  },
  "data": {
    "type": "reminder_imunisasi",
    "jadwal_id": "123",
    "anak_id": "45"
  }
}
```

---

### 7️⃣ InsertNotifikasi (Simpan Log)
**File:** `backend_go/app/repositories/notifikasi_repository.go`  
**Search keyword:** `InsertNotifikasi`

**Code:**
```go
func (r *Main) InsertNotifikasi(
	anakID int32,
	title string,
	body string,
) error {
	notif := &models.Notifikasi{
		AnakID:    anakID,
		Title:     title,
		Body:      body,
		CreatedAt: time.Now(),
	}

	return r.postgres.Create(notif).Error
}
```

**SQL yang dieksekusi:**
```sql
INSERT INTO notifikasi (anak_id, title, body, created_at)
VALUES (?, ?, ?, NOW())
```

---

## 📊 TIMING NOTIFIKASI

| Timing | Kondisi | Title | Body (Contoh) |
|--------|---------|-------|---------------|
| **H-7** | diff == 7 hari, status == 1, NOT is_sent_h7 | "Imunisasi 7 Hari Lagi" | "Halo Ibu Ahmad, jadwal imunisasi BCG akan berlangsung 7 hari lagi. Imunisasi tepat waktu membantu menjaga perlindungan anak dari risiko penyakit." |
| **H-3** | diff == 3 hari, status == 1, NOT is_sent_h3 | "Imunisasi 3 Hari Lagi" | "Halo Ibu Ahmad, jadwal imunisasi BCG 3 hari lagi. Ketepatan waktu membantu menjaga perlindungan anak tetap optimal." |
| **H-0** | diff == 0 hari, status == 2, NOT is_sent_h | "Hari Imunisasi" | "Halo Ibu Ahmad, hari ini jadwal imunisasi BCG. Imunisasi tepat waktu membantu mencegah risiko penyakit dan menjaga kekebalan anak." |

---

## ✅ CHECKLIST VERIFIKASI

| Function Name | File | Line | Status |
|---------------|------|------|--------|
| ProcessReminder | notifikasi_usecase.go | 65 | ✅ VERIFIED |
| GetJadwalForReminder | notifikasi_repository.go | ~8 | ✅ VERIFIED |
| MarkSent | notifikasi_repository.go | - | ✅ VERIFIED |
| GetFCMTokensByAnakID | notifikasi_repository.go | - | ✅ VERIFIED |
| sendFCMWithData | notifikasi_usecase.go | ~31 | ✅ VERIFIED |
| InsertNotifikasi | notifikasi_repository.go | - | ✅ VERIFIED |

**KESIMPULAN:** ✅ **SEMUA FUNCTION DALAM DIAGRAM ADA DI CODE!**

---

## 🎓 CATATAN UNTUK PRESENTASI KE DOSEN

### **1. Kenapa pakai Cron Job?**
**Jawaban:**  
Karena notifikasi harus dikirim secara **otomatis** setiap hari tanpa intervensi manual. Cron Job adalah scheduler yang berjalan di background server.

### **2. Kenapa ada flag is_sent_h7, is_sent_h3, is_sent_h?**
**Jawaban:**  
Agar notifikasi **hanya dikirim sekali**. Kalau tidak ada flag, orang tua bisa dapat notifikasi yang sama berkali-kali setiap cron job jalan.

### **3. Bagaimana kalau orang tua tidak punya app mobile?**
**Jawaban:**  
Notifikasi tidak akan terkirim kalau FCM token kosong. Tapi data jadwal imunisasi tetap ada di sistem dan bisa dilihat oleh bidan di web dashboard.

### **4. Kenapa timing H-7, H-3, H-0?**
**Jawaban:**  
Berdasarkan **best practice** reminder system:
- **H-7**: Kasih waktu cukup untuk persiapan
- **H-3**: Pengingat ulang
- **H-0**: Reminder di hari H

---

## 🔄 ALUR LENGKAP (Simplified)

```
1. Cron Job jalan setiap hari jam 08:00
   ↓
2. Ambil semua jadwal imunisasi aktif (status 1 atau 2)
   ↓
3. Loop setiap jadwal:
   - Hitung selisih hari (diff)
   - diff == 7 → Kirim notifikasi H-7
   - diff == 3 → Kirim notifikasi H-3
   - diff == 0 → Kirim notifikasi H-0
   ↓
4. Update flag is_sent_hX = true
   ↓
5. Ambil FCM token orang tua dari database
   ↓
6. Kirim push notification via Firebase
   ↓
7. Simpan log notifikasi ke database
   ↓
8. Orang tua terima notifikasi di mobile app
```

---

Dibuat oleh: KIA Cerdas Team  
Tanggal: 24 Juni 2026  
**Status:** ✅ VERIFIED - Semua function ada di code actual!
