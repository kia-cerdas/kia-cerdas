# ✅ VERIFIED: Mapping Code Sequence Diagram 4.4
## Penjadwalan Imunisasi Otomatis Berbasis Rule (13 Vaksin IDL)

**STATUS:** ✅ Semua function dalam diagram ini **SUDAH DIVERIFIKASI** ada di code actual!

---

## 🎯 FOKUS DIAGRAM INI:

Diagram ini **FOKUS** ke proses **AUTO-GENERATE jadwal imunisasi 13 vaksin IDL**, BUKAN proses tambah anak. Oleh karena itu:
- ✅ Dimulai dari **Trigger/Callback** (bukan View/Controller)
- ✅ Fokus ke **Business Logic** penjadwalan imunisasi
- ✅ Semua function bisa dicari dengan **Ctrl+F** di code

---

## 📋 KOMPONEN DALAM DIAGRAM

| Komponen | File Path | Keterangan |
|----------|-----------|------------|
| **Trigger (onAnakCreated callback)** | `backend_go/app/usecases/init.go` | Callback yang dipanggil saat anak baru dibuat |
| **ImunisasiUsecase** | `backend_go/app/usecases/imunisasi_usecase.go` | Business logic auto-generate jadwal |
| **ImunisasiRepository** | `backend_go/app/repositories/imunisasi_repository.go` | Data access untuk tabel imunisasi |
| **AnakRepository** | `backend_go/app/repositories/anak_repository.go` | Data access untuk tabel anak |
| **Database (PostgreSQL)** | - | Database server |

---

## 🔍 FUNCTION MAPPING (VERIFIED - Bisa dicari dengan Ctrl+F)

### 1️⃣ Trigger/Callback Registration
**File:** `backend_go/app/usecases/init.go`  
**Line:** ~199-204  
**Search keyword:** `SetOnAnakCreated`

**Code:**
```go
m.Anak.SetOnAnakCreated(func(anakID int32) {
	if err := m.GenerateJadwalImunisasiByAnakID(anakID); err != nil {
		fmt.Println("[AUTO JADWAL] ERROR:", err)
	}
})
```

**Cara Verifikasi:**
```
1. Buka file: backend_go/app/usecases/init.go
2. Tekan Ctrl+F
3. Ketik: SetOnAnakCreated
4. ✅ Akan ketemu di line ~199-204
```

---

### 2️⃣ GenerateJadwalImunisasiByAnakID
**File:** `backend_go/app/usecases/imunisasi_usecase.go`  
**Line:** 170  
**Search keyword:** `GenerateJadwalImunisasiByAnakID`

**Code:**
```go
func (m *Main) GenerateJadwalImunisasiByAnakID(anakID int32) error {
	
	fmt.Println("========== GENERATE BY ANAK ID ==========")
	
	// 1. Get anak data
	anak, err := m.repository.GetAnakByID(uint(anakID))
	if err != nil {
		return err
	}
	
	tanggalLahir := anak.Penduduk.TanggalLahir
	
	// 2. Get aturan vaksin (13 vaksin IDL)
	aturanList, err := m.repository.GetAturanVaksinAnak()
	if err != nil {
		return err
	}
	
	// 3. Loop untuk setiap vaksin (13 kali)
	for _, rule := range aturanList {
		// ... generate jadwal ...
	}
	
	// 4. Update status
	m.repository.UpdateJadwalStatus()
	
	return nil
}
```

**Cara Verifikasi:**
```
1. Buka file: backend_go/app/usecases/imunisasi_usecase.go
2. Tekan Ctrl+F
3. Ketik: GenerateJadwalImunisasiByAnakID
4. ✅ Akan ketemu di line 170
```

---

### 3️⃣ GetAnakByID (dari AnakRepository)
**File:** `backend_go/app/repositories/anak_repository.go`  
**Line:** ~70  
**Search keyword:** `GetAnakByID`

**Code:**
```go
func (m *Main) GetAnakByID(anakID uint) (*models.Anak, error) {
	var data models.Anak
	err := m.postgres.
		Preload("Penduduk").
		Preload("Kehamilan").
		Preload("Kehamilan.Ibu").
		Preload("Kehamilan.Ibu.Kependudukan").
		Where("id = ?", anakID).
		First(&data).Error
	if err != nil {
		if err.Error() == constants.GORM_ERR_NOT_FOUND {
			return nil, customerror.NewNotFoundError("data anak tidak ditemukan")
		}
		// Fallback
		var simpleData models.Anak
		simpleErr := m.postgres.
			Preload("Penduduk").
			Where("id = ?", anakID).
			First(&simpleData).Error
		if simpleErr != nil {
			return nil, customerror.NewNotFoundError("data anak tidak ditemukan")
		}
		return &simpleData, nil
	}
	return &data, nil
}
```

**Cara Verifikasi:**
```
1. Buka file: backend_go/app/repositories/anak_repository.go
2. Tekan Ctrl+F
3. Ketik: GetAnakByID
4. ✅ Akan ketemu di line ~70
```

---

### 4️⃣ GetAturanVaksinAnak
**File:** `backend_go/app/repositories/imunisasi_repository.go`  
**Line:** ~45  
**Search keyword:** `GetAturanVaksinAnak`

**Code:**
```go
func (m *Main) GetAturanVaksinAnak() ([]models.AturanVaksinAnak, error) {
	var aturan []models.AturanVaksinAnak

	err := m.postgres.
		Preload("DosisVaksin").
		Preload("DosisSebelumRel").
		Where("deleted_at IS NULL").
		Order("id ASC").
		Find(&aturan).Error

	if err != nil {
		return nil, err
	}

	return aturan, nil
}
```

**SQL yang dieksekusi:**
```sql
SELECT * FROM aturan_vaksin_anak
WHERE deleted_at IS NULL
ORDER BY id ASC
```

**Cara Verifikasi:**
```
1. Buka file: backend_go/app/repositories/imunisasi_repository.go
2. Tekan Ctrl+F
3. Ketik: GetAturanVaksinAnak
4. ✅ Akan ketemu di line ~45
```

---

### 5️⃣ IsJadwalExist
**File:** `backend_go/app/repositories/imunisasi_repository.go`  
**Line:** ~65  
**Search keyword:** `IsJadwalExist`

**Code:**
```go
func (m *Main) IsJadwalExist(
	anakID int32,
	dosisID int64,
) (bool, error) {

	var count int64

	err := m.postgres.
		Model(&models.JadwalImunisasiAnak{}).
		Where("id_anak = ?", anakID).
		Where("id_dosis_vaksin = ?", dosisID).
		Count(&count).Error

	if err != nil {
		return false, err
	}

	return count > 0, nil
}
```

**SQL yang dieksekusi:**
```sql
SELECT COUNT(*) FROM jadwal_imunisasi_anak
WHERE id_anak = ? AND id_dosis_vaksin = ?
```

**Cara Verifikasi:**
```
1. Buka file: backend_go/app/repositories/imunisasi_repository.go
2. Tekan Ctrl+F
3. Ketik: IsJadwalExist
4. ✅ Akan ketemu di line ~65
```

---

### 6️⃣ CreateJadwalImunisasiAnak
**File:** `backend_go/app/repositories/imunisasi_repository.go`  
**Line:** ~115  
**Search keyword:** `CreateJadwalImunisasiAnak`

**Code:**
```go
func (m *Main) CreateJadwalImunisasiAnak(
	jadwal *models.JadwalImunisasiAnak,
) error {

	return m.postgres.Create(jadwal).Error
}
```

**SQL yang dieksekusi:**
```sql
INSERT INTO jadwal_imunisasi_anak (
    id_anak, id_dosis_vaksin,
    tanggal_estimasi, id_status_jadwal
) VALUES (?, ?, ?, ?)
```

**Cara Verifikasi:**
```
1. Buka file: backend_go/app/repositories/imunisasi_repository.go
2. Tekan Ctrl+F
3. Ketik: CreateJadwalImunisasiAnak
4. ✅ Akan ketemu di line ~115
```

---

### 7️⃣ UpdateJadwalStatus
**File:** `backend_go/app/repositories/imunisasi_repository.go`  
**Line:** ~122  
**Search keyword:** `UpdateJadwalStatus`

**Code:**
```go
func (m *Main) UpdateJadwalStatus() error {
	type JadwalWithTanggalLahir struct {
		ID                 uint
		TanggalEstimasi    *time.Time
		TanggalLahir       time.Time
		StatusJadwalID     uint
	}

	var jadwals []JadwalWithTanggalLahir

	err := m.postgres.
		Table("jadwal_imunisasi_anak jia").
		Select("jia.id, jia.tanggal_estimasi, p.tanggal_lahir, jia.id_status_jadwal").
		Joins("JOIN anak a ON a.id = jia.anak_id").
		Joins("JOIN penduduk p ON p.id = a.penduduk_id").
		Find(&jadwals).Error

	if err != nil {
		return err
	}

	for _, jadwal := range jadwals {
		if jadwal.TanggalEstimasi == nil {
			continue
		}

		// Hitung diff antara TanggalEstimasi dengan TanggalLahir
		diff := int(jadwal.TanggalEstimasi.Sub(jadwal.TanggalLahir).Hours() / 24)

		var statusID int32

		switch {
		case diff >= 1:
			statusID = 1 // lebih 1 hari dari tanggal lahir
		case diff == 0:
			statusID = 2 // 0 hari dari tanggal lahir
		case diff >= -6 && diff < 0:
			statusID = 3 // kurang 1-6 hari
		case diff >= -14 && diff < -6:
			statusID = 4 // kurang 7-14 hari
		default:
			statusID = 5 // lebih dari 14 hari
		}

		_ = m.postgres.
			Model(&models.JadwalImunisasiAnak{}).
			Where("id = ?", jadwal.ID).
			Update("id_status_jadwal", statusID).Error
	}

	return nil
}
```

**Cara Verifikasi:**
```
1. Buka file: backend_go/app/repositories/imunisasi_repository.go
2. Tekan Ctrl+F
3. Ketik: UpdateJadwalStatus
4. ✅ Akan ketemu di line ~122
```

---

## 📊 13 VAKSIN IDL (Data dari Database)

Tabel: `aturan_vaksin_anak`

| No | Nama Vaksin | Min Usia Hari | ID Dosis Vaksin |
|----|-------------|---------------|-----------------|
| 1  | HB-0        | 0             | 1               |
| 2  | BCG         | 30            | 2               |
| 3  | Polio 1     | 30            | 3               |
| 4  | DPT-HB-Hib 1| 60            | 4               |
| 5  | Polio 2     | 60            | 5               |
| 6  | DPT-HB-Hib 2| 90            | 6               |
| 7  | Polio 3     | 90            | 7               |
| 8  | DPT-HB-Hib 3| 120           | 8               |
| 9  | Polio 4     | 120           | 9               |
| 10 | IPV         | 120           | 10              |
| 11 | Campak      | 270           | 11              |
| 12 | MR 1        | 270           | 12              |
| 13 | MR 2        | 540           | 13              |

---

## ✅ CHECKLIST VERIFIKASI

| Function Name | File | Line | Status |
|---------------|------|------|--------|
| SetOnAnakCreated | init.go | ~199 | ✅ VERIFIED |
| GenerateJadwalImunisasiByAnakID | imunisasi_usecase.go | 170 | ✅ VERIFIED |
| GetAnakByID | anak_repository.go | ~70 | ✅ VERIFIED |
| GetAturanVaksinAnak | imunisasi_repository.go | ~45 | ✅ VERIFIED |
| IsJadwalExist | imunisasi_repository.go | ~65 | ✅ VERIFIED |
| CreateJadwalImunisasiAnak | imunisasi_repository.go | ~115 | ✅ VERIFIED |
| UpdateJadwalStatus | imunisasi_repository.go | ~122 | ✅ VERIFIED |

**KESIMPULAN:** ✅ **SEMUA FUNCTION DALAM DIAGRAM ADA DI CODE!**

---

## 🎓 CATATAN UNTUK PRESENTASI KE DOSEN

### **1. Kenapa tidak ada View/Controller?**
**Jawaban:**  
Judul diagram adalah "Penjadwalan Imunisasi Otomatis Berbasis Rule", bukan "Proses Tambah Data Anak". Diagram ini fokus ke **proses AUTO-GENERATE** yang berjalan di **background** (goroutine), sehingga tidak melibatkan View/Controller.

### **2. Dimulai dari mana prosesnya?**
**Jawaban:**  
Proses dimulai dari **callback onAnakCreated** yang didaftarkan di `init.go`. Callback ini dipanggil secara **asynchronous** (goroutine) dari function `CreateAnakDenganPenduduk()` di `anak.go`.

### **3. Bagaimana cara verifikasi function ada di code?**
**Jawaban:**  
Semua function bisa dicari dengan **Ctrl+F**:
- Buka file yang disebutkan di diagram
- Tekan Ctrl+F
- Ketik nama function (contoh: `GenerateJadwalImunisasiByAnakID`)
- Function akan ketemu di line yang disebutkan

### **4. Apa output dari proses ini?**
**Jawaban:**  
Output dari proses ini adalah **13 record baru** di tabel `jadwal_imunisasi_anak` untuk setiap anak baru yang ditambahkan, dengan tanggal estimasi dan status yang dihitung berdasarkan **aturan vaksin IDL**.

---

## 🔄 ALUR LENGKAP (Simplified)

```
1. Anak baru dibuat di sistem
   ↓
2. Callback onAnakCreated dipanggil (goroutine)
   ↓
3. GenerateJadwalImunisasiByAnakID(anakID)
   ↓
4. Ambil data anak + tanggal lahir
   ↓
5. Ambil 13 aturan vaksin IDL dari database
   ↓
6. Loop 13x:
   - Cek apakah jadwal sudah ada
   - Hitung tanggal estimasi (tanggal_lahir + min_usia_hari)
   - Hitung status jadwal
   - Insert ke tabel jadwal_imunisasi_anak
   ↓
7. Update status semua jadwal
   ↓
8. Selesai (13 jadwal imunisasi ter-generate)
```

---

Dibuat oleh: KIA Cerdas Team  
Tanggal: 24 Juni 2026  
**Status:** ✅ VERIFIED - Semua function ada di code actual!

