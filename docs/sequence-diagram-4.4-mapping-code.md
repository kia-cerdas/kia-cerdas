# Sequence Diagram 4.4: Mapping ke Kode

## 📍 Pemetaan Komponen Diagram ke File Kode

Dokumen ini menjelaskan **lokasi exact** setiap komponen dalam Sequence Diagram 4.4 di kode project, sehingga dosen/reviewer bisa langsung memverifikasi bahwa diagram sesuai dengan implementasi actual.

---

## 🎯 Komponen Utama

### 1️⃣ **Actor: Bidan**
- **Deskripsi:** User yang mengisi form tambah anak baru
- **Role:** Admin/Bidan di sistem KIA Cerdas

---

### 2️⃣ **View (Frontend)**

| Komponen | Lokasi File | Deskripsi |
|----------|-------------|-----------|
| Form Anak | `web/src/pages/Admin/AkunKeluargaCreate.jsx` | Halaman form input data anak |
| API Call | `web/src/services/api.js` | HTTP client untuk call backend |

**Method yang dipanggil:**
```javascript
// File: web/src/pages/Admin/AkunKeluargaCreate.jsx
const handleSubmit = async (data) => {
  const response = await axios.post('/admin/anak', data);
}
```

---

### 3️⃣ **Routes (Backend)**

| Komponen | Lokasi File | Line | Deskripsi |
|----------|-------------|------|-----------|
| Router Definition | `backend_go/app/routes/routes.go` | ~150-170 | Definisi route POST /admin/anak |

**Kode Actual:**
```go
// File: backend_go/app/routes/routes.go
admin := r.Group("/admin")
admin.Use(middleware.JWTMiddleware())
{
    // ... routes lain
    admin.POST("/anak", controller.CreateAnakDenganPenduduk)
}
```

---

### 4️⃣ **AnakUseCase**

| Method | Lokasi File | Line | Deskripsi |
|--------|-------------|------|-----------|
| `CreateAnakDenganPenduduk()` | `backend_go/app/usecases/anak.go` | 217-285 | Main function untuk create anak + penduduk |
| `SetOnAnakCreated()` | `backend_go/app/usecases/anak.go` | 36-38 | Set callback untuk auto-generate jadwal |

**Kode Actual:**
```go
// File: backend_go/app/usecases/anak.go
// Line: 217-285

func (u *AnakUseCase) CreateAnakDenganPenduduk(
    req models.CreateAnakDenganPendudukRequest
) (*models.AnakResponse, error) {
    
    // Validasi input
    if req.KehamilanID == 0 {
        return nil, errors.New("kehamilan_id wajib diisi")
    }
    // ... validasi lainnya
    
    // 1. Create kependudukan (penduduk)
    newPenduduk := &models.Kependudukan{ ... }
    if err := u.kependudukanRepo.Create(newPenduduk); err != nil {
        return nil, fmt.Errorf("gagal membuat data penduduk: %w", err)
    }
    
    // 2. Create anak
    anak := &models.Anak{ ... }
    if err := u.anakRepo.Create(anak); err != nil {
        return nil, fmt.Errorf("gagal membuat data anak: %w", err)
    }
    
    // 3. Auto-generate jadwal imunisasi (asynchronous)
    if u.onAnakCreated != nil {
        anakID := anak.ID
        go u.onAnakCreated(anakID) // ← GOROUTINE
    }
    
    return &resp, nil
}
```

---

### 5️⃣ **KependudukanRepository**

| Method | Lokasi File | Deskripsi |
|--------|-------------|-----------|
| `Create()` | `backend_go/app/repositories/kependudukan_repository.go` | Insert data ke tabel `kependudukan` |

**Kode Actual:**
```go
// File: backend_go/app/repositories/kependudukan_repository.go

func (r *KependudukanRepository) Create(
    kependudukan *models.Kependudukan
) error {
    return r.db.Create(kependudukan).Error
}
```

**SQL yang dieksekusi:**
```sql
INSERT INTO kependudukan (
    nik, nama_anggota_keluarga, jenis_kelamin,
    tanggal_lahir, desa_id, posyandu_id
) VALUES (?, ?, ?, ?, ?, ?)
```

---

### 6️⃣ **AnakRepository**

| Method | Lokasi File | Deskripsi |
|--------|-------------|-----------|
| `Create()` | `backend_go/app/repositories/anak_repository.go` | Insert data ke tabel `anak` |

**Kode Actual:**
```go
// File: backend_go/app/repositories/anak_repository.go

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

---

## 🔄 Auto-Generate Jadwal Imunisasi (Background Process)

### 7️⃣ **Callback Registration**

| Komponen | Lokasi File | Line | Deskripsi |
|----------|-------------|------|-----------|
| Callback Setup | `backend_go/app/usecases/init.go` | 199-204 | Daftarkan callback saat init |

**Kode Actual:**
```go
// File: backend_go/app/usecases/init.go
// Line: 199-204

m.Anak = NewAnakUseCase(
    opts.Repository.Anak,
    opts.Repository.Kependudukan,
    opts.Repository.PrediksiStunting,
    opts.Repository.Ibu,
)

// ← CALLBACK DIDAFTARKAN DI SINI
m.Anak.SetOnAnakCreated(func(anakID int32) {
    if err := m.GenerateJadwalImunisasiByAnakID(anakID); err != nil {
        fmt.Println("[AUTO JADWAL] ERROR:", err)
    }
})
```

---

### 8️⃣ **Main Usecase (Imunisasi)**

| Method | Lokasi File | Line | Deskripsi |
|--------|-------------|------|-----------|
| `GenerateJadwalImunisasiByAnakID()` | `backend_go/app/usecases/imunisasi_usecase.go` | 170-266 | Generate 13 jadwal imunisasi |
| `calculateStatusID()` | `backend_go/app/usecases/imunisasi_usecase.go` | 268-297 | Hitung status jadwal |

**Kode Actual:**
```go
// File: backend_go/app/usecases/imunisasi_usecase.go
// Line: 170-266

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
    
    // 3. Loop untuk setiap vaksin
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
        tanggalEstimasi := tanggalLahir.AddDate(
            0, 0, int(rule.MinUsiaHari),
        )
        
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

---

### 9️⃣ **ImunisasiRepository**

| Method | Lokasi File | Deskripsi |
|--------|-------------|-----------|
| `GetAnakByID()` | `backend_go/app/repositories/imunisasi_repository.go` | Ambil data anak + tanggal lahir |
| `GetAturanVaksinAnak()` | `backend_go/app/repositories/imunisasi_repository.go` | Ambil 13 aturan vaksin IDL |
| `IsJadwalExist()` | `backend_go/app/repositories/imunisasi_repository.go` | Cek apakah jadwal sudah ada |
| `CreateJadwalImunisasiAnak()` | `backend_go/app/repositories/imunisasi_repository.go` | Insert jadwal baru |
| `UpdateJadwalStatus()` | `backend_go/app/repositories/imunisasi_repository.go` | Update status berdasarkan tanggal |

**Contoh Kode:**
```go
// File: backend_go/app/repositories/imunisasi_repository.go

func (r *ImunisasiRepository) CreateJadwalImunisasiAnak(
    jadwal *models.JadwalImunisasiAnak
) error {
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

---

## 🗄️ **Database Tables**

### Table: `kependudukan`
```sql
CREATE TABLE kependudukan (
    id_kependudukan INT PRIMARY KEY AUTO_INCREMENT,
    nik VARCHAR(20),
    nama_anggota_keluarga VARCHAR(255),
    jenis_kelamin ENUM('L', 'P'),
    tanggal_lahir DATE,
    desa_id INT,
    posyandu_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Table: `anak`
```sql
CREATE TABLE anak (
    id INT PRIMARY KEY AUTO_INCREMENT,
    kehamilan_id INT,
    penduduk_id INT,
    berat_lahir_kg DECIMAL(4,2),
    tinggi_lahir_cm DECIMAL(5,2),
    anak_ke INT,
    ibu_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Table: `jadwal_imunisasi_anak`
```sql
CREATE TABLE jadwal_imunisasi_anak (
    id INT PRIMARY KEY AUTO_INCREMENT,
    anak_id INT,
    dosis_vaksin_id INT,
    tanggal_estimasi DATE,
    status_jadwal_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Table: `aturan_vaksin_anak`
```sql
CREATE TABLE aturan_vaksin_anak (
    id INT PRIMARY KEY AUTO_INCREMENT,
    dosis_vaksin_id INT,
    min_usia_hari INT,
    max_usia_hari INT,
    urutan INT
);
```

---

## 📊 13 Vaksin IDL (Imunisasi Dasar Lengkap)

| No | Nama Vaksin | Min Usia Hari | Dosis Vaksin ID | Urutan |
|----|-------------|---------------|-----------------|--------|
| 1  | HB-0        | 0             | 1               | 1      |
| 2  | BCG         | 30            | 2               | 2      |
| 3  | Polio 1     | 30            | 3               | 3      |
| 4  | DPT-HB-Hib 1| 60            | 4               | 4      |
| 5  | Polio 2     | 60            | 5               | 5      |
| 6  | DPT-HB-Hib 2| 90            | 6               | 6      |
| 7  | Polio 3     | 90            | 7               | 7      |
| 8  | DPT-HB-Hib 3| 120           | 8               | 8      |
| 9  | Polio 4     | 120           | 9               | 9      |
| 10 | IPV         | 120           | 10              | 10     |
| 11 | Campak      | 270           | 11              | 11     |
| 12 | MR 1        | 270           | 12              | 12     |
| 13 | MR 2        | 540           | 13              | 13     |

---

## 🔍 Cara Verifikasi untuk Dosen

### **1. Cek Routes**
```bash
# Buka file
backend_go/app/routes/routes.go

# Cari line ~150-170
# Cari: admin.POST("/anak", ...)
```

### **2. Cek Usecase**
```bash
# Buka file
backend_go/app/usecases/anak.go

# Cari line ~217
# Cari function: CreateAnakDenganPenduduk
```

### **3. Cek Auto-Generate**
```bash
# Buka file
backend_go/app/usecases/imunisasi_usecase.go

# Cari line ~170
# Cari function: GenerateJadwalImunisasiByAnakID
```

### **4. Cek Callback Registration**
```bash
# Buka file
backend_go/app/usecases/init.go

# Cari line ~199-204
# Cari: m.Anak.SetOnAnakCreated
```

---

## ✅ Validasi Diagram vs Kode

| Komponen Diagram | Ada di Kode? | Lokasi File | Line |
|------------------|--------------|-------------|------|
| ✅ POST /admin/anak | Ya | routes.go | ~150-170 |
| ✅ CreateAnakDenganPenduduk() | Ya | anak.go | 217-285 |
| ✅ KependudukanRepo.Create() | Ya | kependudukan_repository.go | - |
| ✅ AnakRepo.Create() | Ya | anak_repository.go | - |
| ✅ go onAnakCreated() | Ya | anak.go | 246-252 |
| ✅ GenerateJadwalImunisasiByAnakID() | Ya | imunisasi_usecase.go | 170-266 |
| ✅ GetAturanVaksinAnak() | Ya | imunisasi_repository.go | - |
| ✅ CreateJadwalImunisasiAnak() | Ya | imunisasi_repository.go | - |
| ✅ Loop 13 vaksin | Ya | imunisasi_usecase.go | 210-256 |

**Kesimpulan:** ✅ **Semua komponen dalam diagram ADA di kode actual!**

---

## 📝 Catatan untuk Review

1. **Goroutine (Asynchronous):**
   - Line 246-252 di `anak.go`
   - Menggunakan keyword `go` untuk non-blocking execution

2. **13 Vaksin IDL:**
   - Data ada di database table `aturan_vaksin_anak`
   - Bisa di-seed menggunakan seeder (jika ada)

3. **Status Jadwal:**
   - Dihitung di function `calculateStatusID()`
   - Line 268-297 di `imunisasi_usecase.go`

---

## 🚀 Testing untuk Dosen

Jika dosen ingin test actual flow:

```bash
# 1. Run backend
cd backend_go
go run main.go

# 2. Test endpoint
curl -X POST http://localhost:8080/admin/anak \
  -H "Authorization: Bearer [token]" \
  -H "Content-Type: application/json" \
  -d '{
    "nama": "Baby Test",
    "tanggal_lahir": "2026-06-24",
    "jenis_kelamin": "L",
    "ibu_id": 1,
    "kehamilan_id": 1
  }'

# 3. Cek database
SELECT * FROM anak WHERE nama = 'Baby Test';
SELECT * FROM jadwal_imunisasi_anak WHERE anak_id = [new_anak_id];
# Seharusnya ada 13 record jadwal imunisasi
```

---

Dibuat oleh: [Nama Anda]
Tanggal: 24 Juni 2026
Project: KIA Cerdas - Sistem Informasi Kesehatan Ibu & Anak
