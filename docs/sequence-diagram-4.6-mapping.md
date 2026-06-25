# Mapping Sequence Diagram 4.6: Pencatatan Imunisasi oleh Bidan Desa

## Overview
Diagram ini menunjukkan alur **PARAF imunisasi** yang dilakukan oleh Bidan Desa melalui halaman **Pelayanan Imunisasi Anak** di Web UI.

**Alur Proses:**
1. Bidan membuka halaman pelayanan imunisasi anak
2. Klik tombol "PARAF IMUNISASI"
3. Pilih vaksin dari modal (bisa pilih multiple)
4. Isi tanggal pemberian, nomor batch, dan catatan
5. Submit → untuk setiap vaksin:
   - Create pencatatan imunisasi
   - Set pencatatan selesai
   - Update jadwal status menjadi selesai

---

## Mapping Function ke Code

### 1. **Web UI: Halaman Pelayanan Imunisasi**
**File:** `web/src/pages/Pelayanan-Imunisasi-Anak/index.jsx`  
**Line:** 461-502 (handleSubmit function)

**Proses di Frontend:**
```javascript
const handleSubmit = async (e) => {
  e.preventDefault();
  
  for (const jadwalId of formData.selectedJadwalIds) {
    // 1. Create pencatatan imunisasi record
    const result = await createPelayananImunisasi({
      id_jadwal_imunisasi_anak: jadwalId,
      tanggal_pemberian: formData.tanggal,
      nomor_batch: formData.batches[jadwalId] || '',
      catatan: formData.catatan || '',
    });
    
    pencatatanId = result?.id;
    
    // 2. Mark pencatatan as selesai
    await setPencatatanSelesai(pencatatanId);
    
    // 3. Mark jadwal as selesai
    await setJadwalSelesai(jadwalId);
  }
}
```

---

### 2. **Service: imunisasiBidanService.js**
**File:** `web/src/services/imunisasiBidanService.js`  
**Line:** 49-58 (createPelayananImunisasi)  
**Line:** 35-44 (setPencatatanSelesai)  
**Line:** 21-29 (setJadwalSelesai)

**Endpoint yang dipanggil:**
```javascript
// Create pencatatan
POST /bidan/pencatatan-imunisasi

// Set pencatatan selesai
PUT /bidan/pencatatan-imunisasi/:id/selesai

// Set jadwal selesai  
PUT /bidan/imunisasi/:jadwal_id/selesai
```

---

### 3. **Controller: Create Pencatatan**
**File:** `backend_go/app/controllers/pencatatan_imunisasi_controller.go`  
**Line:** 24-83  
**Function:** `Create(ctx echo.Context)`

**Proses:**
```go
func (c *PencatatanImunisasiController) Create(ctx echo.Context) error {
    var req struct {
        IdJadwalImunisasiAnak uint   `json:"id_jadwal_imunisasi_anak"`
        TanggalPemberian      string `json:"tanggal_pemberian"`
        NomorBatch            string `json:"nomor_batch"`
        Catatan               string `json:"catatan"`
    }
    
    ctx.Bind(&req)
    
    // Ambil ID bidan dari JWT token
    var idBidanPetugas *int32
    if userID := ctx.Get("user_id"); userID != nil {
        // Convert user_id ke int32
        idBidanPetugas = &idu
    }
    
    data := &models.PencatatanImunisasi{
        IdJadwalImunisasiAnak: req.IdJadwalImunisasiAnak,
        TanggalPemberian:      tanggalPemberian,
        NomorBatch:            req.NomorBatch,
        Catatan:               req.Catatan,
        IsSelesai:             false,
        IdBidanPetugas:        idBidanPetugas,
    }
    
    c.usecase.Create(data)
    ...
}
```

---

### 4. **Usecase: Create Pencatatan**
**File:** `backend_go/app/usecases/pencatatan_imunisasi_usecase.go`  
**Line:** 17-19  
**Function:** `Create(data *models.PencatatanImunisasi)`

**Proses:**
```go
func (u *PencatatanImunisasiUsecase) Create(data *models.PencatatanImunisasi) error {
    return u.repo.Create(data)
}
```

---

### 5. **Repository: Create Pencatatan**
**File:** `backend_go/app/repositories/pencatatan_imunisasi_repository.go`  
**Line:** 18-20  
**Function:** `Create(data *models.PencatatanImunisasi)`

**Proses:**
```go
func (r *PencatatanImunisasiRepository) Create(data *models.PencatatanImunisasi) error {
    return r.postgres.Create(data).Error
}
```

**SQL Query (dari GORM):**
```sql
INSERT INTO pencatatan_imunisasi
(id_jadwal_imunisasi_anak, tanggal_pemberian, nomor_batch, 
 catatan, is_selesai, id_bidan_petugas, created_at, updated_at)
VALUES (?, ?, ?, ?, false, ?, NOW(), NOW())
```

---

### 6. **Controller: Set Pencatatan Selesai**
**File:** `backend_go/app/controllers/pencatatan_imunisasi_controller.go`  
**Line:** 109-122  
**Function:** `SetSelesai(ctx echo.Context)`

**Proses:**
```go
func (c *PencatatanImunisasiController) SetSelesai(ctx echo.Context) error {
    id, err := strconv.Atoi(ctx.Param("id"))
    
    if err := c.usecase.SetSelesai(uint(id)); err != nil {
        return helpers.Response(ctx, http.StatusInternalServerError, ...)
    }
    
    return helpers.StandardResponse(ctx, http.StatusOK, ...)
}
```

---

### 7. **Repository: Set Pencatatan Selesai**
**File:** `backend_go/app/repositories/pencatatan_imunisasi_repository.go`  
**Line:** 56-61  
**Function:** `SetSelesai(id uint)`

**SQL Query:**
```sql
UPDATE pencatatan_imunisasi
SET is_selesai = true
WHERE id = ?
```

---

### 8. **Jadwal Controller: Set Jadwal Selesai**
**File:** `backend_go/app/controllers/jadwal_imunisasi_bidan_controller.go`  
**Line:** (endpoint PUT /bidan/imunisasi/:id/selesai)

**SQL Query:**
```sql
UPDATE jadwal_imunisasi_anak
SET id_status_jadwal = 6
WHERE id = ?
```
*Note: Status 6 = Selesai/Done*

---

## SQL Query dalam Diagram

### Query 1: Insert Pencatatan Imunisasi
```sql
INSERT INTO pencatatan_imunisasi
(id_jadwal_imunisasi_anak, tanggal_pemberian, nomor_batch, 
 catatan, is_selesai, id_bidan_petugas)
VALUES (?, ?, ?, ?, false, ?)
```
**Lokasi:** `pencatatan_imunisasi_repository.go` line 19  
**Fungsi:** Menyimpan record pencatatan imunisasi dengan is_selesai = false

### Query 2: Update Pencatatan Selesai
```sql
UPDATE pencatatan_imunisasi
SET is_selesai = true
WHERE id = ?
```
**Lokasi:** `pencatatan_imunisasi_repository.go` line 58  
**Fungsi:** Menandai pencatatan sudah diselesaikan (paraf final)

### Query 3: Update Jadwal Selesai
```sql
UPDATE jadwal_imunisasi_anak
SET id_status_jadwal = 6
WHERE id = ?
```
**Lokasi:** `jadwal_imunisasi_bidan_controller.go`  
**Fungsi:** Update status jadwal menjadi selesai (vaksin sudah diberikan)

---

## Request/Response Format

### Request: Create Pencatatan
**Method:** POST  
**URL:** `/bidan/pencatatan-imunisasi`  
**Body:**
```json
{
  "id_jadwal_imunisasi_anak": 123,
  "tanggal_pemberian": "2026-06-24",
  "nomor_batch": "ABC12345",
  "catatan": "Tidak ada keluhan"
}
```

### Request: Set Pencatatan Selesai
**Method:** PUT  
**URL:** `/bidan/pencatatan-imunisasi/:id/selesai`  
**Body:** (empty)

### Request: Set Jadwal Selesai
**Method:** PUT  
**URL:** `/bidan/imunisasi/:jadwal_id/selesai`  
**Body:** (empty)

---

## Data Model

**Table: pencatatan_imunisasi**
```
- id (PK)
- id_jadwal_imunisasi_anak (FK → jadwal_imunisasi_anak)
- tanggal_pemberian (date)
- nomor_batch (string)
- catatan (text)
- is_selesai (boolean)
- id_bidan_petugas (FK → users) - diambil dari JWT token
- created_at
- updated_at
- deleted_at
```

---

## Verification Checklist

✅ **Function Names dapat dicari dengan Ctrl+F:**
- `Create` ✓ (controller & usecase)
- `SetSelesai` ✓ (controller & usecase)
- `createPelayananImunisasi` ✓ (frontend service)
- `setPencatatanSelesai` ✓ (frontend service)
- `setJadwalSelesai` ✓ (frontend service)

✅ **SQL Query mudah dipahami:**
- Query INSERT, UPDATE menggunakan format SQL standar
- Semua kolom dijelaskan dengan jelas

✅ **Alur sesuai code actual:**
- Frontend → Controller → Usecase → Repository → Database ✓
- Loop untuk multiple vaksin sesuai dengan kode ✓
- 3 step process: Create → Set Selesai → Update Jadwal ✓

---

## Catatan Penting

1. **Multiple Vaksin:** Bidan dapat memilih beberapa vaksin sekaligus untuk diparaf
2. **ID Bidan Petugas:** Diambil otomatis dari JWT token (user yang login)
3. **3-Step Process:** 
   - Create pencatatan (is_selesai = false)
   - Set pencatatan selesai (is_selesai = true)
   - Update jadwal status (id_status_jadwal = 6)
4. **Tanggal Pemberian:** Bisa berbeda dengan tanggal estimasi (untuk kasus terlambat)
5. **Nomor Batch:** Opsional, untuk tracking batch vaksin
6. **Riwayat:** Data tersimpan di tabel `pencatatan_imunisasi` untuk audit trail
