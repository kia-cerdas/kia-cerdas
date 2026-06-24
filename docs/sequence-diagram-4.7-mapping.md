# Mapping Sequence Diagram 4.7: Permintaan dan Persetujuan Perubahan Jadwal Imunisasi

## Overview
Diagram ini menunjukkan alur **persetujuan atau penolakan** permintaan perubahan jadwal imunisasi yang dilakukan oleh **Bidan Desa** melalui halaman Web UI.

**Alur Proses:**
1. Bidan membuka halaman permintaan perubahan jadwal imunisasi
2. Sistem menampilkan daftar permintaan dengan 2 tab: Menunggu & Riwayat
3. Bidan mereview permintaan dari orang tua
4. **Alt Flow:**
   - **Approve:** Bidan klik "Terima" → Status diupdate → Jadwal imunisasi diubah
   - **Reject:** Bidan klik "Tolak" → Status diupdate (jadwal tidak berubah)

---

## Mapping Function ke Code

### 1. **Web UI: Halaman Permintaan Perubahan Jadwal**
**File:** `web/src/pages/RequestPerubahanImunisasi/index.jsx`  
**Line:** 38-46 (fetchRequests)  
**Line:** 48-89 (handleApprove)  
**Line:** 91-121 (handleReject)

**Proses di Frontend:**
```javascript
// Fetch all requests
const fetchRequests = async () => {
    const res = await getAllRequestPerubahanImunisasi();
    setRequests(res.data || []);
};

// Approve request
const handleApprove = async (id) => {
    const confirm = await Swal.fire({
        title: "Terima Permintaan?",
        text: "Jadwal imunisasi akan diubah sesuai tanggal baru yang diajukan.",
        ...
    });
    
    if (!confirm.isConfirmed) return;
    
    await approveRequestPerubahanImunisasi(id);
    await fetchRequests(); // Refresh data
};

// Reject request
const handleReject = async (id) => {
    const confirm = await Swal.fire({
        title: "Tolak Permintaan?",
        ...
    });
    
    if (!confirm.isConfirmed) return;
    
    await rejectRequestPerubahanImunisasi(id);
    await fetchRequests(); // Refresh data
};
```

---

### 2. **Service: RequestPerubahanImunisasi.js**
**File:** `web/src/services/RequestPerubahanImunisasi.js`  

**Endpoint yang dipanggil:**
```javascript
// Get all requests
GET /bidan/request-perubahan-jadwal-imunisasi

// Approve request
PUT /bidan/request-perubahan-jadwal-imunisasi/:id/approve

// Reject request
PUT /bidan/request-perubahan-jadwal-imunisasi/:id/reject
```

---

### 3. **Controller: GetAllRequestPerubahanJadwal**
**File:** `backend_go/app/controllers/request_perubahan_imunisasi_controller.go`  
**Line:** 13-51  
**Function:** `GetAllRequestPerubahanJadwal(c echo.Context)`

**Proses:**
```go
func (m *Main) GetAllRequestPerubahanJadwal(c echo.Context) error {
    claims := c.Get("auth_claims").(*models.AuthClaims)
    
    if claims.PosyanduID == nil {
        return helpers.Response(c, http.StatusForbidden,
            []string{"bidan tidak terdaftar di posyandu manapun"})
    }
    
    data, err := m.usecases.GetAllRequestPerubahanJadwal(*claims.PosyanduID)
    
    if err != nil {
        return helpers.Response(c, http.StatusInternalServerError, ...)
    }
    
    return helpers.StandardResponse(c, http.StatusOK, ..., data, nil)
}
```

---

### 4. **Controller: ApproveRequestPerubahanJadwal**
**File:** `backend_go/app/controllers/request_perubahan_imunisasi_controller.go`  
**Line:** 112-159  
**Function:** `ApproveRequestPerubahanJadwal(c echo.Context)`

**Proses:**
```go
func (m *Main) ApproveRequestPerubahanJadwal(c echo.Context) error {
    requestID, err := strconv.Atoi(c.Param("id"))
    
    if err != nil {
        return helpers.Response(c, http.StatusBadRequest, 
            []string{"id request tidak valid"})
    }
    
    err = m.usecases.ApproveRequestPerubahanJadwal(int32(requestID))
    
    if err != nil {
        return helpers.Response(c, http.StatusInternalServerError, ...)
    }
    
    return helpers.StandardResponse(c, http.StatusOK,
        []string{"request berhasil disetujui"}, nil, nil)
}
```

---

### 5. **Controller: RejectRequestPerubahanJadwal**
**File:** `backend_go/app/controllers/request_perubahan_imunisasi_controller.go`  
**Line:** 160-207  
**Function:** `RejectRequestPerubahanJadwal(c echo.Context)`

**Proses:**
```go
func (m *Main) RejectRequestPerubahanJadwal(c echo.Context) error {
    requestID, err := strconv.Atoi(c.Param("id"))
    
    if err != nil {
        return helpers.Response(c, http.StatusBadRequest,
            []string{"id request tidak valid"})
    }
    
    err = m.usecases.RejectRequestPerubahanJadwal(int32(requestID))
    
    if err != nil {
        return helpers.Response(c, http.StatusInternalServerError, ...)
    }
    
    return helpers.StandardResponse(c, http.StatusOK,
        []string{"request berhasil ditolak"}, nil, nil)
}
```

---

### 6. **Usecase: ApproveRequestPerubahanJadwal**
**File:** `backend_go/app/usecases/request_perubahan_imunisasi_usecase.go`  
**Line:** 74-110  
**Function:** `ApproveRequestPerubahanJadwal(requestID int32)`

**Proses:**
```go
func (m *Main) ApproveRequestPerubahanJadwal(requestID int32) error {
    // 1. Get request data
    requestData, err := m.repository.GetRequestPerubahanByID(requestID)
    if err != nil {
        return err
    }
    
    if requestData == nil {
        return fmt.Errorf("request tidak ditemukan")
    }
    
    // 2. Validate status (must be 2 = Menunggu)
    if requestData.StatusRequestID != 2 {
        return fmt.Errorf("request sudah diproses")
    }
    
    // 3. Update status to 1 (Terima)
    err = m.repository.UpdateStatusRequestPerubahan(requestID, 1)
    if err != nil {
        return err
    }
    
    // 4. Update tanggal jadwal imunisasi
    return m.repository.UpdateTanggalJadwalImunisasi(
        requestData.JadwalImunisasiID,
        requestData.TanggalBaru,
    )
}
```

---

### 7. **Usecase: RejectRequestPerubahanJadwal**
**File:** `backend_go/app/usecases/request_perubahan_imunisasi_usecase.go`  
**Line:** 111-142  
**Function:** `RejectRequestPerubahanJadwal(requestID int32)`

**Proses:**
```go
func (m *Main) RejectRequestPerubahanJadwal(requestID int32) error {
    // 1. Get request data
    requestData, err := m.repository.GetRequestPerubahanByID(requestID)
    if err != nil {
        return err
    }
    
    if requestData == nil {
        return fmt.Errorf("request tidak ditemukan")
    }
    
    // 2. Validate status (must be 2 = Menunggu)
    if requestData.StatusRequestID != 2 {
        return fmt.Errorf("request sudah diproses")
    }
    
    // 3. Update status to 3 (Tolak)
    return m.repository.UpdateStatusRequestPerubahan(requestID, 3)
}
```

---

## SQL Query dalam Diagram

### Query 1: Get All Requests
```sql
SELECT r.id, r.id_status_request,
       r.tanggal_sebelum, r.tanggal_baru,
       r.alasan, d.nama_dosis,
       p.nama_anggota_keluarga
FROM request_perubahan_imunisasi r
JOIN jadwal_imunisasi_anak j ON j.id = r.id_jadwal_imunisasi
JOIN dosis_vaksin d ON d.id = j.id_dosis_vaksin
JOIN anak a ON a.id = j.id_anak
JOIN penduduk p ON p.id = a.penduduk_id
WHERE posyandu_id = ?
```
**Fungsi:** Mengambil semua permintaan perubahan jadwal untuk posyandu tertentu

### Query 2: Get Request By ID
```sql
SELECT * FROM request_perubahan_imunisasi
WHERE id = ?
```
**Fungsi:** Mengambil detail permintaan untuk validasi

### Query 3: Update Status Request (Approve)
```sql
UPDATE request_perubahan_imunisasi
SET id_status_request = 1
WHERE id = ?
```
**Fungsi:** Menandai permintaan sebagai "Terima" (status 1)

### Query 4: Update Status Request (Reject)
```sql
UPDATE request_perubahan_imunisasi
SET id_status_request = 3
WHERE id = ?
```
**Fungsi:** Menandai permintaan sebagai "Tolak" (status 3)

### Query 5: Update Tanggal Jadwal Imunisasi
```sql
UPDATE jadwal_imunisasi_anak
SET tanggal_estimasi = ?
WHERE id = ?
```
**Fungsi:** Mengubah tanggal jadwal imunisasi sesuai permintaan (hanya saat approve)

---

## Status Request

**Tabel: status_request_perubahan_imunisasi**
- **ID 1:** Terima (Approved)
- **ID 2:** Menunggu (Pending)
- **ID 3:** Tolak (Rejected)

---

## Request/Response Format

### Request: Get All Requests
**Method:** GET  
**URL:** `/bidan/request-perubahan-jadwal-imunisasi`  
**Headers:** Authorization: Bearer {token}

### Response: Get All Requests
```json
{
  "status": "success",
  "message": ["Success"],
  "data": [
    {
      "request_id": 1,
      "status_request": "Menunggu",
      "tanggal_sebelum": "2026-07-01",
      "tanggal_baru": "2026-07-15",
      "nama_dosis": "BCG",
      "nama_lengkap": "Anak Contoh",
      "alasan": "Anak sedang sakit"
    }
  ]
}
```

### Request: Approve
**Method:** PUT  
**URL:** `/bidan/request-perubahan-jadwal-imunisasi/:id/approve`  
**Body:** (empty)

### Request: Reject
**Method:** PUT  
**URL:** `/bidan/request-perubahan-jadwal-imunisasi/:id/reject`  
**Body:** (empty)

---

## Data Model

**Table: request_perubahan_imunisasi**
```
- id (PK)
- id_jadwal_imunisasi (FK → jadwal_imunisasi_anak)
- id_status_request (FK → status_request_perubahan_imunisasi)
- tanggal_sebelum (date)
- tanggal_baru (date)
- alasan (text)
- created_at
- updated_at
- deleted_at
```

---

## Verification Checklist

✅ **Function Names dapat dicari dengan Ctrl+F:**
- `GetAllRequestPerubahanJadwal` ✓
- `ApproveRequestPerubahanJadwal` ✓
- `RejectRequestPerubahanJadwal` ✓
- `GetRequestPerubahanByID` ✓
- `UpdateStatusRequestPerubahan` ✓
- `UpdateTanggalJadwalImunisasi` ✓

✅ **SQL Query mudah dipahami:**
- Query SELECT dengan JOIN untuk get requests ✓
- Query UPDATE untuk status dan tanggal ✓

✅ **Alur sesuai code actual:**
- Alt flow (Approve vs Reject) ✓
- Validasi status before update ✓
- Update jadwal hanya saat approve ✓

---

## Catatan Penting

1. **Alt Flow:** Diagram menunjukkan 2 kemungkinan (Approve/Reject) menggunakan `alt`
2. **Validasi Status:** Hanya permintaan dengan status "Menunggu" (ID 2) yang bisa diproses
3. **Update Jadwal:** Tanggal jadwal imunisasi **hanya diubah saat Approve**, tidak saat Reject
4. **Posyandu Filter:** Bidan hanya bisa melihat permintaan dari posyandu tempat mereka bekerja
5. **Double Confirmation:** UI menampilkan konfirmasi SweetAlert2 sebelum approve/reject
6. **Refresh Data:** Setelah approve/reject, data di-refresh untuk menampilkan status terbaru
