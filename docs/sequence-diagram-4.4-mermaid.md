# Sequence Diagram 4.4 (Mermaid Format)

```mermaid
sequenceDiagram
    actor Bidan as Bidan/Admin
    participant Web as Frontend<br/>(Web)
    participant Routes as Routes<br/>(Echo)
    participant JWT as JWT<br/>Middleware
    participant Controller as Anak<br/>Controller
    participant AnakUC as Anak<br/>Usecase
    participant AnakRepo as Anak<br/>Repository
    participant DB as Database<br/>(PostgreSQL)
    
    box Background Process
    participant Callback as onAnakCreated<br/>Callback
    participant ImunisasiUC as Imunisasi<br/>Usecase
    participant ImunisasiRepo as Imunisasi<br/>Repository
    end

    Note over Bidan,DB: 1. Bidan Menambahkan Data Anak Baru
    
    Bidan->>Web: Isi form data anak<br/>(nama, tgl lahir, ibu_id, dll)
    activate Bidan
    activate Web
    
    Web->>Routes: POST /admin/anak<br/>CreateAnakDenganPenduduk
    activate Routes
    
    Routes->>JWT: Validasi JWT Token
    activate JWT
    JWT-->>Routes: Token Valid<br/>(user_id, role)
    deactivate JWT
    
    Routes->>Controller: CreateAnakDenganPenduduk(request)
    activate Controller
    
    Note over Controller,AnakRepo: 2. Simpan Data Anak
    
    Controller->>AnakUC: CreateAnakDenganPenduduk(req)
    activate AnakUC
    
    Note right of AnakUC: Validasi:<br/>- kehamilan_id wajib<br/>- ibu_id wajib<br/>- nama, tgl lahir
    
    AnakUC->>AnakRepo: Create(kependudukan)<br/>Simpan data penduduk anak
    activate AnakRepo
    AnakRepo->>DB: INSERT INTO kependudukan
    activate DB
    DB-->>AnakRepo: ID Penduduk
    deactivate DB
    deactivate AnakRepo
    
    AnakUC->>AnakRepo: Create(anak)<br/>Simpan data anak
    activate AnakRepo
    AnakRepo->>DB: INSERT INTO anak
    activate DB
    DB-->>AnakRepo: Anak ID
    deactivate DB
    deactivate AnakRepo
    
    Note over AnakUC,Callback: 3. Trigger Auto-Generate (Asynchronous)
    
    AnakUC->>Callback: go onAnakCreated(anakID)<br/>**[Non-blocking, goroutine]**
    activate Callback
    
    Note right of Callback: Callback dipanggil secara<br/>asynchronous (goroutine)<br/>agar tidak memblokir response
    
    Note over AnakUC,Web: 7. Response ke Frontend (Tanpa Menunggu)
    
    AnakUC-->>Controller: AnakResponse<br/>(data anak berhasil dibuat)
    deactivate AnakUC
    
    Controller-->>Routes: HTTP 201 Created<br/>(data anak + status_prediksi)
    deactivate Controller
    
    Routes-->>Web: JSON Response<br/>{"message": "success", "data": {...}}
    deactivate Routes
    
    Web-->>Bidan: Tampilkan notifikasi:<br/>"Data anak berhasil ditambahkan"
    deactivate Web
    deactivate Bidan
    
    Note over Callback,ImunisasiRepo: Background Process Continues...
    
    Callback->>ImunisasiUC: GenerateJadwalImunisasiByAnakID(anakID)
    activate ImunisasiUC
    
    Note over ImunisasiUC,DB: 4. Ambil Data Anak & Aturan Vaksin
    
    ImunisasiUC->>ImunisasiRepo: GetAnakByID(anakID)
    activate ImunisasiRepo
    ImunisasiRepo->>DB: SELECT * FROM anak<br/>JOIN kependudukan
    activate DB
    DB-->>ImunisasiRepo: Data Anak + Tanggal Lahir
    deactivate DB
    deactivate ImunisasiRepo
    
    ImunisasiUC->>ImunisasiRepo: GetAturanVaksinAnak()
    activate ImunisasiRepo
    ImunisasiRepo->>DB: SELECT * FROM aturan_vaksin_anak<br/>ORDER BY urutan
    activate DB
    DB-->>ImunisasiRepo: **13 Rule Vaksin IDL**
    deactivate DB
    deactivate ImunisasiRepo
    
    Note right of ImunisasiUC: 13 Vaksin IDL:<br/>1. HB-0 (0 hari)<br/>2. BCG (1 bulan)<br/>3. Polio 1 (1 bulan)<br/>4. DPT-HB-Hib 1 (2 bulan)<br/>5-13. ... (hingga MR 2)
    
    Note over ImunisasiUC,DB: 5. Loop: Generate Jadwal untuk Setiap Rule
    
    loop For each rule (13 vaksin)
        ImunisasiUC->>ImunisasiRepo: IsJadwalExist(anakID, dosisVaksinID)
        activate ImunisasiRepo
        ImunisasiRepo->>DB: SELECT COUNT(*)<br/>FROM jadwal_imunisasi_anak<br/>WHERE anak_id=? AND dosis_vaksin_id=?
        activate DB
        DB-->>ImunisasiRepo: false (belum ada)
        deactivate DB
        deactivate ImunisasiRepo
        
        Note right of ImunisasiUC: Hitung tanggal estimasi:<br/>tanggal_lahir + min_usia_hari<br/><br/>Hitung status jadwal:<br/>- Status 1: Belum (diff >= 1)<br/>- Status 2: Hari Ini (diff == 0)<br/>- Status 3: Terlambat < 7 hari<br/>- Status 4: Terlambat 7-14 hari<br/>- Status 5: Terlewat (> 14 hari)
        
        ImunisasiUC->>ImunisasiRepo: CreateJadwalImunisasiAnak(jadwal)
        activate ImunisasiRepo
        ImunisasiRepo->>DB: INSERT INTO jadwal_imunisasi_anak<br/>(anak_id, dosis_vaksin_id,<br/>tanggal_estimasi, status_jadwal_id)
        activate DB
        DB-->>ImunisasiRepo: Success
        deactivate DB
        deactivate ImunisasiRepo
    end
    
    Note over ImunisasiUC,DB: 6. Update Status Jadwal
    
    ImunisasiUC->>ImunisasiRepo: UpdateJadwalStatus()
    activate ImunisasiRepo
    ImunisasiRepo->>DB: UPDATE jadwal_imunisasi_anak<br/>SET status_jadwal_id = ...<br/>BASED ON tanggal_estimasi
    activate DB
    DB-->>ImunisasiRepo: Updated
    deactivate DB
    deactivate ImunisasiRepo
    
    ImunisasiUC-->>Callback: Generation Complete
    deactivate ImunisasiUC
    deactivate Callback
    
    Note over Bidan,ImunisasiRepo: **Auto-generate jadwal imunisasi**<br/>berjalan di background tanpa<br/>menunggu response selesai.<br/><br/>Total 13 jadwal imunisasi<br/>berhasil dibuat otomatis.
```

---

## Cara Melihat Diagram

### 1. **Menggunakan PlantUML**
- Install PlantUML extension di VS Code
- Buka file `sequence-diagram-4.4-penjadwalan-imunisasi-otomatis.puml`
- Klik kanan → Preview PlantUML Diagram

### 2. **Menggunakan Online Tool**
- PlantUML Online: https://www.plantuml.com/plantuml/uml/
- Copy isi file `.puml` dan paste di sana

### 3. **Menggunakan Mermaid (di Markdown)**
- GitHub, GitLab, Notion support Mermaid
- Copy kode Mermaid di atas ke Markdown file
- Akan otomatis ter-render

### 4. **Menggunakan Draw.io / Lucidchart**
- Import sequence diagram secara manual
- Menggunakan referensi alur di file penjelasan

---

## File yang Sudah Dibuat

1. ✅ **sequence-diagram-4.4-penjadwalan-imunisasi-otomatis.puml**
   - Format PlantUML (untuk rendering diagram)
   
2. ✅ **sequence-diagram-4.4-penjelasan.md**
   - Penjelasan lengkap step-by-step
   - Tabel 13 vaksin IDL
   - Status jadwal
   - Error handling
   
3. ✅ **sequence-diagram-4.4-mermaid.md** (file ini)
   - Format Mermaid (bisa di-render di GitHub/GitLab)

---

## Next Steps

Apakah Anda ingin:
1. ✅ Membuat diagram untuk **4.5 Notifikasi Pengingat Imunisasi**?
2. ✅ Membuat diagram untuk **4.6 Pencatatan Imunisasi**?
3. ✅ Membuat diagram untuk **4.7 Permintaan Perubahan Jadwal**?
4. 🖼️ Export diagram ke format **PNG/SVG**?
