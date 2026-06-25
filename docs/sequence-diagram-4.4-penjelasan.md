# Sequence Diagram 4.4: Penjadwalan Imunisasi Otomatis Berbasis Rule (13 Vaksin IDL)

## 📋 Deskripsi
Diagram ini menggambarkan proses **otomatis** pembuatan 13 jadwal imunisasi anak berdasarkan aturan IDL (Imunisasi Dasar Lengkap) ketika data anak baru ditambahkan ke sistem.

## 🎯 Tujuan
- Mengurangi beban manual bidan untuk membuat jadwal imunisasi
- Memastikan tidak ada vaksin yang terlewat
- Otomatis menghitung tanggal estimasi berdasarkan usia anak
- Update status jadwal secara dinamis (belum, hari ini, terlambat, terlewat)

## 👥 Aktor & Komponen

### Actor
- **Bidan/Admin**: Petugas yang menambahkan data anak baru

### Frontend
- **Web Application** (React/JavaScript)

### Backend Components
1. **Routes (Echo)**: HTTP router
2. **JWT Middleware**: Validasi autentikasi
3. **Anak Controller**: Menangani request data anak
4. **Anak Usecase**: Business logic untuk data anak
5. **Anak Repository**: Data access layer untuk tabel `anak` dan `kependudukan`
6. **onAnakCreated Callback**: Hook/trigger untuk auto-generate
7. **Imunisasi Usecase**: Business logic untuk jadwal imunisasi
8. **Imunisasi Repository**: Data access layer untuk tabel `jadwal_imunisasi_anak`
9. **Database (PostgreSQL)**: Penyimpanan data

---

## 🔄 Alur Proses

### **Fase 1: Input Data Anak (Synchronous)**

```
1. Bidan mengisi form data anak baru di Web
   - Nama anak
   - Tanggal lahir
   - Jenis kelamin
   - ID Ibu
   - Berat lahir
   - Tinggi lahir
   - dll

2. Frontend → POST /admin/anak
   Body: {
     "nama": "Baby Ahmad",
     "tanggal_lahir": "2026-01-15",
     "jenis_kelamin": "L",
     "ibu_id": 123,
     "kehamilan_id": 456,
     ...
   }

3. Routes → JWT Middleware
   Validasi token JWT
   Extract: user_id, role

4. Controller → Anak Usecase
   CreateAnakDenganPenduduk(request)
```

---

### **Fase 2: Simpan Data Anak (Synchronous)**

```
5. Anak Usecase → Validasi input
   - kehamilan_id wajib diisi
   - ibu_id wajib diisi
   - nama, tanggal_lahir, jenis_kelamin wajib

6. Anak Usecase → Anak Repository
   Create(kependudukan)
   
   INSERT INTO kependudukan (
     nik, nama_anggota_keluarga, jenis_kelamin,
     tanggal_lahir, desa_id, posyandu_id
   )
   VALUES (...)
   
   → Return: ID Penduduk

7. Anak Usecase → Anak Repository
   Create(anak)
   
   INSERT INTO anak (
     kehamilan_id, penduduk_id, berat_lahir_kg,
     tinggi_lahir_cm, anak_ke, ibu_id
   )
   VALUES (...)
   
   → Return: Anak ID
```

---

### **Fase 3: Trigger Auto-Generate (Asynchronous) ⚡**

```
8. Anak Usecase → onAnakCreated Callback
   
   go onAnakCreated(anakID)  // ← GOROUTINE (non-blocking)
   
   ⚠️ PENTING: Proses ini berjalan di background
   Response HTTP TIDAK MENUNGGU proses ini selesai
```

---

### **Fase 4: Response ke Frontend (Synchronous)**

```
9. Anak Usecase → Controller
   Return: AnakResponse {
     "id": 789,
     "nama": "Baby Ahmad",
     "tanggal_lahir": "2026-01-15",
     ...
   }

10. Controller → Routes
    HTTP 201 Created

11. Routes → Frontend
    JSON Response: {
      "message": "success",
      "data": { ... }
    }

12. Frontend → Bidan
    Tampilkan notifikasi:
    "✅ Data anak berhasil ditambahkan"
```

---

### **Fase 5: Auto-Generate Jadwal Imunisasi (Background Process)**

```
13. onAnakCreated Callback → Imunisasi Usecase
    GenerateJadwalImunisasiByAnakID(anakID)

14. Imunisasi Usecase → Imunisasi Repository
    GetAnakByID(anakID)
    
    SELECT a.*, k.tanggal_lahir
    FROM anak a
    JOIN kependudukan k ON a.penduduk_id = k.id_kependudukan
    WHERE a.id = 789
    
    → Return: Data Anak + Tanggal Lahir

15. Imunisasi Usecase → Imunisasi Repository
    GetAturanVaksinAnak()
    
    SELECT * FROM aturan_vaksin_anak
    ORDER BY urutan
    
    → Return: 13 Rule Vaksin IDL
```

---

### **Fase 6: Loop untuk 13 Vaksin IDL**

```
16. LOOP: Untuk setiap rule (13 kali iterasi)
    
    a. Cek apakah jadwal sudah ada
       IsJadwalExist(anakID, dosisVaksinID)
       
       SELECT COUNT(*) FROM jadwal_imunisasi_anak
       WHERE anak_id = 789 AND dosis_vaksin_id = ?
       
       → If exist: SKIP (continue)
    
    b. Hitung tanggal estimasi
       tanggal_estimasi = tanggal_lahir + min_usia_hari
       
       Contoh:
       - HB-0: 2026-01-15 + 0 hari = 2026-01-15
       - BCG: 2026-01-15 + 30 hari = 2026-02-14
       - Polio 1: 2026-01-15 + 30 hari = 2026-02-14
       - DPT-HB-Hib 1: 2026-01-15 + 60 hari = 2026-03-16
       - ... (dan seterusnya hingga 13 vaksin)
    
    c. Hitung status jadwal
       calculateStatusID(tanggal_estimasi)
       
       Logika:
       - diff >= 1 hari        → Status 1 (Belum)
       - diff == 0             → Status 2 (Hari Ini)
       - diff >= -6 && diff < 0 → Status 3 (Terlambat <7 hari)
       - diff >= -14 && diff < -6 → Status 4 (Terlambat 7-14 hari)
       - diff < -14            → Status 5 (Terlewat)
    
    d. Insert jadwal ke database
       CreateJadwalImunisasiAnak(jadwal)
       
       INSERT INTO jadwal_imunisasi_anak (
         anak_id, dosis_vaksin_id,
         tanggal_estimasi, status_jadwal_id
       )
       VALUES (789, ?, '2026-02-14', 1)
       
       → Success

END LOOP
```

---

### **Fase 7: Update Status Jadwal**

```
17. Imunisasi Usecase → Imunisasi Repository
    UpdateJadwalStatus()
    
    UPDATE jadwal_imunisasi_anak
    SET status_jadwal_id = 
      CASE
        WHEN DATEDIFF(tanggal_estimasi, NOW()) >= 1 THEN 1
        WHEN DATEDIFF(tanggal_estimasi, NOW()) = 0 THEN 2
        WHEN DATEDIFF(tanggal_estimasi, NOW()) BETWEEN -6 AND -1 THEN 3
        WHEN DATEDIFF(tanggal_estimasi, NOW()) BETWEEN -14 AND -7 THEN 4
        ELSE 5
      END
    WHERE anak_id = 789
    
    → Updated

18. Imunisasi Usecase → Callback
    Return: Generation Complete

19. Background process SELESAI ✅
```

---

## 📊 13 Vaksin IDL (Imunisasi Dasar Lengkap)

| No | Nama Vaksin | Usia Pemberian | Min Usia Hari | Keterangan |
|----|-------------|----------------|---------------|------------|
| 1  | HB-0        | 0 hari         | 0             | Hepatitis B dosis lahir |
| 2  | BCG         | 1 bulan        | 30            | Tuberculosis |
| 3  | Polio 1     | 1 bulan        | 30            | Polio tetes |
| 4  | DPT-HB-Hib 1| 2 bulan        | 60            | Difteri, Pertusis, Tetanus, Hepatitis B, Hib |
| 5  | Polio 2     | 2 bulan        | 60            | Polio tetes |
| 6  | DPT-HB-Hib 2| 3 bulan        | 90            | Dosis kedua |
| 7  | Polio 3     | 3 bulan        | 90            | Polio tetes |
| 8  | DPT-HB-Hib 3| 4 bulan        | 120           | Dosis ketiga |
| 9  | Polio 4     | 4 bulan        | 120           | Polio tetes |
| 10 | IPV         | 4 bulan        | 120           | Inactivated Polio Vaccine |
| 11 | Campak      | 9 bulan        | 270           | Campak |
| 12 | MR 1        | 9 bulan        | 270           | Measles Rubella |
| 13 | MR 2        | 18 bulan       | 540           | Measles Rubella booster |

---

## 🎨 Status Jadwal Imunisasi

| Status ID | Nama Status | Kondisi | Warna UI | Deskripsi |
|-----------|-------------|---------|----------|-----------|
| 1 | Belum | diff >= 1 hari | 🟢 Hijau | Jadwal masih akan datang |
| 2 | Hari Ini | diff == 0 | 🟡 Kuning | Jadwal hari ini |
| 3 | Terlambat | -6 <= diff < 0 | 🟠 Orange | Terlambat kurang dari 7 hari |
| 4 | Terlambat | -14 <= diff < -7 | 🟠 Orange | Terlambat 7-14 hari |
| 5 | Terlewat | diff < -14 | 🔴 Merah | Terlewat lebih dari 14 hari |
| 6 | Selesai | Manual | ✅ Hijau | Sudah diimunisasi |

---

## 💡 Keunggulan Desain

### 1. **Asynchronous Processing**
- Auto-generate tidak memblokir HTTP response
- User experience lebih cepat
- Proses berat di background

### 2. **Separation of Concerns**
- Controller: HTTP handling
- Usecase: Business logic
- Repository: Database access
- Callback: Trigger mechanism

### 3. **Idempotent**
- Cek `IsJadwalExist()` sebelum insert
- Tidak duplikasi data jika dipanggil berkali-kali

### 4. **Auto Status Update**
- Status jadwal di-update otomatis berdasarkan tanggal
- Tidak perlu manual update

### 5. **Rule-Based**
- Mengikuti aturan IDL dari `aturan_vaksin_anak`
- Mudah diubah tanpa mengubah kode

---

## 🚨 Error Handling

### Skenario Error:
1. **Tanggal lahir tidak ada**: Skip auto-generate
2. **Jadwal sudah ada**: Skip (tidak duplikat)
3. **Database error**: Log error, continue loop
4. **Rule tidak ditemukan**: Log warning

### Logging:
```go
fmt.Println("[AUTO JADWAL] ERROR:", err)
fmt.Println("[AUTO JADWAL] SUCCESS: 13 jadwal dibuat untuk anak ID", anakID)
```

---

## 📝 Catatan Implementasi

### File Terkait:
- **Usecase**: `backend_go/app/usecases/anak.go` (line 150-156, 246-252)
- **Usecase**: `backend_go/app/usecases/imunisasi_usecase.go`
- **Controller**: `backend_go/app/controllers/anak_controller.go`
- **Repository**: `backend_go/app/repositories/anak_repository.go`
- **Repository**: `backend_go/app/repositories/imunisasi_repository.go`

### Inisialisasi Callback:
```go
// Di init.go
m.Anak = NewAnakUseCase(...)
m.Anak.SetOnAnakCreated(func(anakID int32) {
    if err := m.GenerateJadwalImunisasiByAnakID(anakID); err != nil {
        fmt.Println("[AUTO JADWAL] ERROR:", err)
    }
})
```

---

## 🔍 Testing Checklist

- [ ] Data anak berhasil dibuat
- [ ] 13 jadwal imunisasi ter-generate otomatis
- [ ] Tanggal estimasi sesuai dengan aturan IDL
- [ ] Status jadwal sesuai dengan kondisi
- [ ] Tidak ada duplikasi jadwal
- [ ] Background process tidak memblokir response
- [ ] Error handling berjalan dengan baik

---

## 📚 Referensi
- Peraturan Menteri Kesehatan RI tentang Imunisasi Dasar Lengkap
- Jadwal Imunisasi Anak IDAI (Ikatan Dokter Anak Indonesia)
