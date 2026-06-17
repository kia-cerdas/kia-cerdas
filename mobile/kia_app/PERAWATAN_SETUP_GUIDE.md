# Fitur Perawatan Anak - Panduan Setup & Testing

## 📋 Overview
Fitur Perawatan Anak memungkinkan ibu untuk melihat dan menjawab kuesioner perkembangan anak berdasarkan rentang usia. Materi disediakan dalam 6 kategori usia dan mencakup berbagai aspek perkembangan.

## 🏗️ Arsitektur

### Backend
```
Backend: Go + GORM
├── Models
│  ├── KategoriCapaian (pertanyaan perkembangan)
│  └── Perawatan (jawaban dari ibu)
├── Controllers
│  └── perawatan_controller.go
├── Usecases
│  └── perawatan_usecase.go
├── Repositories
│  └── perawatan_repository.go
└── Seeders
   └── kategori_capaian.go (64 soal)
```

### API Endpoints (Route: `/ibu`)
```
GET    /ibu/kategori-capaian
GET    /ibu/kategori-capaian/rentang-usia/:rentang_usia
GET    /ibu/perawatan/anak/:anak_id
GET    /ibu/perawatan/anak/:anak_id/rentang-usia/:rentang_usia
POST   /ibu/perawatan
PUT    /ibu/perawatan/:id
DELETE /ibu/perawatan/:id
```

### Flutter
```
Flutter: Dart + Flutter
├── Models
│  ├── KategoriCapaianModel
│  ├── PerawatanModel
│  ├── CreatePerawatanRequest
│  └── UpdatePerawatanRequest
├── Services
│  └── perawatan_api_service.dart
├── Screens
│  ├── perawatan_screen_integrated.dart (existing)
│  └── perawatan_screen_improved.dart (NEW - recommended)
└── Constants
   └── api_constants.dart (updated)
```

## 📊 Data Struktur

### KategoriCapaian (Database)
```
id (PK)
rentang_usia       (0-12 Bulan, 1-2 Tahun, 2-3 Tahun, 3-4 Tahun, 4-5 Tahun, 5-6 Tahun)
pertanyaan_ceklist (soal perkembangan)
aspek              (Motorik, Bahasa, Kognitif, Sosial Emosional, Motorik Halus)
created_at
updated_at
```

### Perawatan (Database)
```
id (PK)
anak_id             (FK → anak table)
kategori_capaian_id (FK → kategori_capaian table)
jawaban             (boolean: true=Ya, false=Tidak, null=tidak dijawab)
tanggal_periksa     (timestamp)
created_at
updated_at
```

## 🚀 Setup & Testing

### Prerequisites
- Backend running pada `http://localhost:8080` (Android) atau `http://127.0.0.1:8080` (iOS)
- User dengan role `ibu` dan sudah login
- Anak minimal 1 sudah dibuat
- Database sudah di-seed dengan kategori_capaian

### Step 1: Setup Backend

#### 1a. Update Database Schema
```bash
cd backend/monolith/go-template-main
# Ensure tables exist (migrate if needed)
go run main.go migrate
```

#### 1b. Seed Data
```bash
# Stop running backend
cd backend/monolith/go-template-main/cmd
go run main.go seed
```

Expected output:
```
🌱 Seed: kategori capaian perkembangan anak...
✅ Seeded 48 kategori capaian
```

#### 1c. Start Backend
```bash
go run main.go
# Should output: listening on :8080
```

### Step 2: Setup Flutter

#### 2a. Update API Constants
File: `TA-PA2/mobile/kia_app/lib/core/constants/api_constants.dart`

Added endpoints (sudah dilakukan):
```dart
static const String ibuKategoriCapaian = '/ibu/kategori-capaian';
static String ibuKategoriCapaianByRentangUsia(String rentangUsia) =>
    '/ibu/kategori-capaian/rentang-usia/${Uri.encodeComponent(rentangUsia)}';
static const String ibuPerawatan = '/ibu/perawatan';
// dll...
```

#### 2b. Run Flutter App
```bash
cd TA-PA2/mobile/kia_app

# Run dengan verbose untuk debug
flutter run -v

# Atau dengan perangkat spesifik
flutter run -d <device_id>
```

### Step 3: Manual Testing

1. **Login sebagai Ibu**
   - Email: ibu@example.com (atau user ibu yang ada)
   - Password: password

2. **Navigasi ke Perawatan**
   - Pilih Anak → Pemantauan Anak → Perawatan Perkembangan

3. **Lihat Pertanyaan**
   - Harusnya muncul tabs untuk 0-12 Bulan, 1-2 Tahun, dst
   - Setiap tab menampilkan 6-8 soal tentang perkembangan

4. **Isi Kuesioner**
   - Centang "Ya" atau "Tidak" untuk setiap pertanyaan
   - Tekan tombol "Simpan Perawatan"

5. **Verifikasi Data Tersimpan**
   - Refresh halaman (swipe down)
   - Data yang sudah dijawab harus muncul kembali dengan jawaban yang sebelumnya

### Step 4: Debug Console Output

Jika ada masalah, lihat console debug:

```
[Perawatan] Loading kategori capaian for: 0-12 Bulan
[Perawatan] Fetching: http://localhost:8080/ibu/kategori-capaian/rentang-usia/0-12%20Bulan
[Perawatan] Response status: 200
[Perawatan] ✓ Loaded 8 kategori for 0-12 Bulan
```

## 🐛 Troubleshooting

### Problem 1: "Tidak ada data untuk 0-12 Bulan"
**Penyebab**: kategori_capaian tidak di-seed atau API call gagal

**Solusi**:
1. Pastikan backend sudah di-seed: `go run main.go seed`
2. Cek database: `SELECT COUNT(*) FROM kategori_capaian;`
3. Lihat console debug untuk error message
4. Verifikasi token auth valid: `curl -H "Authorization: Bearer <token>" http://localhost:8080/ibu/kategori-capaian`

### Problem 2: Jawaban tidak tersimpan
**Penyebab**: API endpoint gagal atau database error

**Solusi**:
1. Check console untuk error message
2. Verifikasi anak_id valid
3. Lihat backend logs untuk error detail
4. Cek database connection

### Problem 3: "Gagal memuat data"
**Penyebab**: Backend tidak running atau network error

**Solusi**:
1. Verifikasi backend running: `curl http://localhost:8080/auth/me`
2. Cek baseUrl di ApiConstants (harus sesuai platform)
3. Cek network/firewall

## 📱 Screen Structure

### PerawatanScreenImproved (Recommended)
```
AppBar: "Perawatan [Nama Anak]"
  │
  └─ Tabs (6 rentang usia)
      │
      ├─ Header: "Perawatan Anak Umur [Rentang]"
      ├─ Instruction Card
      ├─ Checklist Table
      │   ├─ Header Row (No, Pertanyaan, Ya, Tidak)
      │   └─ Soal Rows (8 per rentang)
      ├─ Save Button
      └─ Material Info Card
```

### Features
✅ Load pertanyaan dari backend
✅ Load jawaban sebelumnya dari database
✅ Support create & update jawaban
✅ Material edukatif untuk setiap aspek
✅ Error handling & retry
✅ Pull-to-refresh
✅ Loading states
✅ Offline awareness

## 🔐 Authorization
Semua endpoint memerlukan:
- Valid JWT token dalam header: `Authorization: Bearer <token>`
- User role harus `ibu`
- User hanya bisa akses data anak mereka sendiri

## 📝 API Examples

### Get Kategori Capaian
```bash
curl -X GET \
  http://localhost:8080/ibu/kategori-capaian/rentang-usia/0-12%20Bulan \
  -H "Authorization: Bearer <TOKEN>"

# Response
{
  "status_code": 200,
  "message": "Success",
  "data": [
    {
      "id": 1,
      "rentang_usia": "0-12 Bulan",
      "pertanyaan_ceklist": "Bayi dapat mengikuti benda dengan matanya",
      "aspek": "Perkembangan Motorik",
      "created_at": "2024-01-15T10:00:00Z",
      "updated_at": "2024-01-15T10:00:00Z"
    }
  ]
}
```

### Create Perawatan
```bash
curl -X POST \
  http://localhost:8080/ibu/perawatan \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "anak_id": 5,
    "kategori_capaian_id": 1,
    "jawaban": true,
    "tanggal_periksa": "2024-05-04T10:00:00Z"
  }'

# Response
{
  "status_code": 201,
  "message": "Success",
  "data": {
    "id": 42,
    "anak_id": 5,
    "kategori_capaian_id": 1,
    "jawaban": true,
    "tanggal_periksa": "2024-05-04T10:00:00Z",
    "created_at": "2024-05-04T10:00:00Z",
    "updated_at": "2024-05-04T10:00:00Z"
  }
}
```

## 📖 Related Files
- Backend: `backend/monolith/go-template-main/app/` (controllers, usecases, repositories, models)
- Backend Docs: `backend/monolith/go-template-main/PERAWATAN_API_DOCS.md`
- Flutter: `TA-PA2/mobile/kia_app/lib/features/anak/tumbuh_kembang/`
- API Constants: `TA-PA2/mobile/kia_app/lib/core/constants/api_constants.dart`

## ✅ Checklist Implementasi

- [x] Backend endpoints ready
- [x] Database models & seeders ready
- [x] Flutter models & API service ready
- [x] API Constants updated
- [x] Screen Improved created
- [x] Material/materi added
- [ ] Integration testing dilakukan
- [ ] Deployed ke production

## 🎯 Next Steps

1. Run backend seed: `go run main.go seed`
2. Start backend: `go run main.go`
3. Update screen reference di navigasi (jika menggunakan improved version)
4. Run Flutter app dan test
5. Monitor console logs untuk debug
6. Test save/load jawaban
7. Deploy ke production

---

**Last Updated**: May 5, 2026
**Status**: Ready for Integration Testing
