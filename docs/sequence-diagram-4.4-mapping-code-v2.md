# Mapping Code Sequence Diagram 4.4 (LENGKAP)
## Penjadwalan Imunisasi Otomatis Berbasis Rule (13 Vaksin IDL)

Dokumen ini memetakan setiap komponen dan function call dalam sequence diagram ke lokasi kode actual. **Semua nama function dalam diagram ini dapat dicari di code dengan Ctrl+F**.

---

## ✅ KOMPONEN LENGKAP (Actor → View → Routes → Controller → Usecase → Repository → Database)

| Komponen dalam Diagram | File Path di Code | Keterangan |
|------------------------|-------------------|------------|
| **Bidan** | - | Actor/User yang melakukan input |
| **View (AkunKeluargaCreate.jsx)** | `web/src/pages/Admin/AkunKeluargaCreate.jsx` | Form UI untuk tambah data anak |
| **Routes (routes.go)** | `backend_go/app/routes/routes.go` | Routing endpoint API |
| **AnakController (anak.go)** | `backend_go/app/controllers/anak.go` | **Controller** untuk handle HTTP request |
| **AnakUseCase (anak.go)** | `backend_go/app/usecases/anak.go` | **Usecase** business logic untuk data anak |
| **AnakRepository (anak_repository.go)** | `backend_go/app/repositories/anak_repository.go` | **Repository** data access layer untuk tabel anak |
| **ImunisasiUsecase (imunisasi_usecase.go)** | `backend_go/app/usecases/imunisasi_usecase.go` | **Usecase** business logic untuk auto-generate jadwal imunisasi |
| **ImunisasiRepository (imunisasi_repository.go)** | `backend_go/app/repositories/imunisasi_repository.go` | **Repository** data access layer untuk tabel imunisasi |
| **Database (PostgreSQL)** | - | Database server |

---

## 🔗 FUNCTION CALLS MAPPING (Searchable dengan Ctrl+F)

### 1️⃣ View → Routes
**Sequence Diagram:**
```
POST /tenaga-kesehatan/anak/dengan-penduduk
Body: CreateAnakDenganPendudukRequest
```

**File:** `backend_go/app/routes/routes.go`  
**Line:** ~277  
**Code:**
```go
tenaga.POST("/anak/dengan-penduduk", controller.Anak.CreateDenganPenduduk)
```

**Cara Cari:** Buka `routes.go`, tekan Ctrl+F, ketik `CreateDenganPenduduk`

---

### 2️⃣ Routes → AnakController
**Sequence Diagram:**
```
CreateDenganPenduduk(c)
```

**File:** `backend_go/app/controllers/anak.go`  
**Line:** 81  
**Code:**
```go
func (h *AnakController) CreateDenganPenduduk(c echo.Context) error {
	var req models.CreateAnakDenganPendudukRequest
	if err := c.Bind(&req); err != nil {
		return helpers.StandardResponse(c, http.StatusBadRequest, "request tidak valid: "+err.Error(), nil, nil)
	}

	anak, err := h.anakUC.CreateAnakDenganPenduduk(req)
	if err != nil {
		return helpers.StandardResponse(c, http.StatusBadRequest, err.Error(), nil, nil)
	}

	return helpers.StandardResponse(c, http.StatusCreated, "data anak berhasil ditambahkan", anak, nil)
}
```

**Cara Cari:** Buka `backend_go/app/controllers/anak.go`, tekan Ctrl+F, ketik `CreateDenganPenduduk`

---

### 3️⃣ AnakController → AnakUseCase
**Sequence Diagram:**
```
CreateAnakDenganPenduduk(req)
```

**File:** `backend_go/app/usecases/anak.go`  
**Line:** 161  
**Code:**
```go
func (u *AnakUseCase) CreateAnakDenganPenduduk(req models.CreateAnakDenganPendudukRequest) (*models.AnakResponse, error) {
	// Validasi input
	if req.KehamilanID == 0 {
		return nil, errors.New("kehamilan_id wajib diisi")
	}
	// ... validasi lainnya ...
	
	// 1. Create kependudukan (penduduk) dulu
	newPenduduk := &models.Kependudukan{
		NIK: &nikSementara,
		NamaAnggotaKeluarga: req.Nama,
		// ...
	}
	if err := u.kependudukanRepo.Create(newPenduduk); err != nil {
		return nil, fmt.Errorf("gagal membuat data penduduk anak: %w", err)
	}

	// 2. Create anak dengan penduduk_id yang baru dibuat
	anak := &models.Anak{
		KehamilanID: req.KehamilanID,
		PendudukID: newPenduduk.IDKependudukan,
		// ...
	}
	if err := u.anakRepo.Create(anak); err != nil {
		return nil, fmt.Errorf("gagal membuat data anak: %w", err)
	}

	// 3. ✅ Auto-generate jadwal imunisasi (non-blocking)
	if u.onAnakCreated != nil {
		anakID := anak.ID
		go u.onAnakCreated(anakID) // ← GOROUTINE TRIGGER
	}

	return &resp, nil
}
```

**Cara Cari:** Buka `backend_go/app/usecases/anak.go`, tekan Ctrl+F, ketik `CreateAnakDenganPenduduk`

---

### 4️⃣ AnakUseCase → AnakRepository
**Sequence Diagram:**
```
Create(anak)
```

**File:** `backend_go/app/repositories/anak_repository.go`  
**Code:**
```go
func (r *AnakRepository) Create(anak *models.Anak) error {
	return r.db.Create(anak).Error
}
```

**SQL yang dieksekusi:**
```sql
INSERT INTO anak (
    kehamilan_id, penduduk_id, berat_lahir_kg,
    tinggi_lahir_cm, anak_ke, ibu_id
) VALUES (?, ?, ?, ?, ?, ?)
```

**Cara Cari:** Buka `backend_go/app/repositories/anak_repository.go`, tekan Ctrl+F, ketik `func (r *AnakRepository) Create`

---

### 5️⃣ AnakUseCase → ImunisasiUsecase (Background Process)
**Sequence Diagram:**
```
go onAnakCreated(anakID) [Goroutine - Background Process]
```

**Callback Registration File:** `backend_go/app/usecases/init.go`  
**Line:** ~199-204  
**Code:**
```go
m.Anak.SetOnAnakCreated(func(anakID int32) {
	m.GenerateJadwalImunisasiByAnakID(anakID)
})
```

**Cara Cari:** Buka `backend_go/app/usecases/init.go`, tekan Ctrl+F, ketik `SetOnAnakCreated`

---

### 6️⃣ ImunisasiUsecase - Main Function
**Sequence Diagram:**
```
GenerateJadwalImunisasiByAnakID(anakID)
```

**File:** `backend_go/app/usecases/imunisasi_usecase.go`  
**Line:** 170-266  
**Code:**
```go
func (m *Main) GenerateJadwalImunisasiByAnakID(anakID int32) error {
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
	
	// 3. Loop untuk setiap vaksin (13 kali iterasi)
	for _, rule := range aturanList {
		// Cek apakah jadwal sudah ada
		alreadyExist, err := m.repository.IsJadwalExist(
			anak.ID,
			int64(rule.DosisVaksinID),
		)
		if err != nil || alreadyExist {
			continue
		}
		
		// Hitung tanggal estimasi
		tanggalEstimasi := tanggalLahir.AddDate(0, 0, int(rule.MinUsiaHari))
		
		// Hitung status
		statusID := calculateStatusID(tanggalEstimasi)
		
		// Insert jadwal
		jadwal := &models.JadwalImunisasiAnak{
			AnakID:          uint(anak.ID),
			DosisVaksinID:   rule.DosisVaksinID,
			TanggalEstimasi: &tanggalEstimasi,
			StatusJadwalID:  uint(statusID),
		}
		
		if err := m.repository.CreateJadwalImunisasiAnak(jadwal); err != nil {
			return err
		}
	}
	
	// 4. Update status jadwal
	m.repository.UpdateJadwalStatus()
	
	return nil
}
```

**Cara Cari:** Buka `backend_go/app/usecases/imunisasi_usecase.go`, tekan Ctrl+F, ketik `GenerateJadwalImunisasiByAnakID`

---

### 7️⃣ ImunisasiUsecase → ImunisasiRepository
**Sequence Diagram:**
```
GetAnakByID(anakID)
GetAturanVaksinAnak()
IsJadwalExist(anakID, dosisVaksinID)
CreateJadwalImunisasiAnak(jadwal)
UpdateJadwalStatus()
```

**File:** `backend_go/app/repositories/imunisasi_repository.go`  

#### a. GetAnakByID
```go
func (r *ImunisasiRepository) GetAnakByID(anakID uint) (*models.Anak, error) {
	var anak models.Anak
	err := r.db.Preload("Penduduk").First(&anak, anakID).Error
	return &anak, err
}
```

#### b. GetAturanVaksinAnak
```go
func (r *ImunisasiRepository) GetAturanVaksinAnak() ([]models.AturanVaksinAnak, error) {
	var rules []models.AturanVaksinAnak
	err := r.db.Order("urutan ASC").Find(&rules).Error
	return rules, err
}
```

#### c. IsJadwalExist
```go
func (r *ImunisasiRepository) IsJadwalExist(anakID int64, dosisVaksinID int64) (bool, error) {
	var count int64
	err := r.db.Model(&models.JadwalImunisasiAnak{}).
		Where("anak_id = ? AND dosis_vaksin_id = ?", anakID, dosisVaksinID).
		Count(&count).Error
	return count > 0, err
}
```

#### d. CreateJadwalImunisasiAnak
```go
func (r *ImunisasiRepository) CreateJadwalImunisasiAnak(jadwal *models.JadwalImunisasiAnak) error {
	return r.db.Create(jadwal).Error
}
```

**SQL yang dieksekusi:**
```sql
INSERT INTO jadwal_imunisasi_anak (
    anak_id, dosis_vaksin_id,
    tanggal_estimasi, status_jadwal_id
) VALUES (?, ?, ?, ?)
```

#### e. UpdateJadwalStatus
```go
func (r *ImunisasiRepository) UpdateJadwalStatus() error {
	// Update status berdasarkan tanggal hari ini
	return r.db.Exec(`
		UPDATE jadwal_imunisasi_anak
		SET status_jadwal_id = 
		CASE 
			WHEN DATEDIFF(tanggal_estimasi, NOW()) >= 1 THEN 1
			WHEN DATEDIFF(tanggal_estimasi, NOW()) = 0 THEN 2
			WHEN DATEDIFF(tanggal_estimasi, NOW()) >= -6 THEN 3
			WHEN DATEDIFF(tanggal_estimasi, NOW()) >= -14 THEN 4
			ELSE 5
		END
	`).Error
}
```

**Cara Cari:** Buka `backend_go/app/repositories/imunisasi_repository.go`, tekan Ctrl+F, ketik nama function (contoh: `GetAnakByID`, `GetAturanVaksinAnak`)

---

### 8️⃣ Calculate Status Function
**Sequence Diagram:**
```
calculateStatusID(tanggalEstimasi)
```

**File:** `backend_go/app/usecases/imunisasi_usecase.go`  
**Line:** 268-297  
**Code:**
```go
func calculateStatusID(tanggalEstimasi time.Time) int {
	today := time.Now()
	diff := int(tanggalEstimasi.Sub(today).Hours() / 24)

	if diff >= 1 {
		return 1 // Belum
	} else if diff == 0 {
		return 2 // Hari Ini
	} else if diff >= -6 {
		return 3 // Terlambat <7 hari
	} else if diff >= -14 {
		return 4 // Terlambat 7-14 hari
	} else {
		return 5 // Terlewat
	}
}
```

**Cara Cari:** Buka `backend_go/app/usecases/imunisasi_usecase.go`, tekan Ctrl+F, ketik `calculateStatusID`

---

## 📊 13 Vaksin IDL (Imunisasi Dasar Lengkap)

| No | Nama Vaksin | Min Usia Hari | Dosis Vaksin ID |
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

## ✅ VALIDASI KELENGKAPAN SEQUENCE DIAGRAM

| Komponen | Ada di Diagram? | Ada di Code? | File Lokasi |
|----------|----------------|--------------|-------------|
| ✅ **Actor (Bidan)** | Ya | - | - |
| ✅ **View** | Ya | Ya | `AkunKeluargaCreate.jsx` |
| ✅ **Routes** | Ya | Ya | `routes.go` (line ~277) |
| ✅ **Controller** | Ya | Ya | `anak.go` (line 81) |
| ✅ **Usecase** | Ya | Ya | `anak.go` (line 161) |
| ✅ **Repository** | Ya | Ya | `anak_repository.go`, `imunisasi_repository.go` |
| ✅ **Database** | Ya | Ya | PostgreSQL |

**Kesimpulan:** ✅ **Sequence Diagram LENGKAP dengan 7 komponen (Actor → View → Routes → Controller → Usecase → Repository → Database)**

---

## 🔍 Cara Verifikasi untuk Dosen

### **Step 1: Cek Controller**
```bash
1. Buka file: backend_go/app/controllers/anak.go
2. Tekan Ctrl+F
3. Ketik: CreateDenganPenduduk
4. Hasil: Akan ketemu function di line 81
```

### **Step 2: Cek Usecase**
```bash
1. Buka file: backend_go/app/usecases/anak.go
2. Tekan Ctrl+F
3. Ketik: CreateAnakDenganPenduduk
4. Hasil: Akan ketemu function di line 161
```

### **Step 3: Cek Auto-Generate**
```bash
1. Buka file: backend_go/app/usecases/imunisasi_usecase.go
2. Tekan Ctrl+F
3. Ketik: GenerateJadwalImunisasiByAnakID
4. Hasil: Akan ketemu function di line 170
```

### **Step 4: Cek Repository**
```bash
1. Buka file: backend_go/app/repositories/imunisasi_repository.go
2. Tekan Ctrl+F
3. Ketik: CreateJadwalImunisasiAnak
4. Hasil: Akan ketemu function
```

---

## 📝 Catatan Penting

1. **Routes → Controller → Usecase:**
   - Alur sudah benar mengikuti Clean Architecture
   - Ada layer Controller eksplisit di `backend_go/app/controllers/anak.go`

2. **Goroutine (Asynchronous):**
   - Auto-generate berjalan di background
   - Tidak memblokir response HTTP ke user
   - Keyword: `go u.onAnakCreated(anakID)`

3. **Loop 13 Vaksin:**
   - Loop ada di line 210-256 di `imunisasi_usecase.go`
   - Data vaksin diambil dari tabel `aturan_vaksin_anak`

4. **Nama File dengan Extension:**
   - Semua komponen sudah include filename dengan extension
   - Contoh: `AnakController\n(anak.go)`, bukan hanya "Controller"

---

Dibuat oleh: KIA Cerdas Team  
Tanggal: 24 Juni 2026  
Project: Sistem Informasi Kesehatan Ibu & Anak

