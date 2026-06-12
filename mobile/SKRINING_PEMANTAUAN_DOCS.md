# Dokumentasi Skrining Pemantauan Anak - Standar KIA 2024

## 📋 Daftar Isi
1. [Kategori Usia Anak](#kategori-usia-anak)
2. [Catatan Kesehatan Anak](#catatan-kesehatan-anak)
3. [Catatan Kesehatan Gigi](#catatan-kesehatan-gigi)
4. [Indikator Pertumbuhan (Growth Indicators)](#indikator-pertumbuhan)
5. [Skrining Perkembangan](#skrining-perkembangan)
6. [Integrasi & Implementasi](#integrasi--implementasi)

---

## Kategori Usia Anak

Berdasarkan **Buku KIA 2024**, anak dikelompokkan berdasarkan usia untuk menentukan jenis pemeriksaan dan screening yang sesuai:

| Kategori | Rentang Usia | Frekuensi Kunjungan | Fokus Pemeriksaan |
|----------|-------------|-------------------|-------------------|
| **Neonatus (BBL)** | 0-28 hari | 3x (H1, H3, H7, H28) | Adaptasi, tanda bahaya, penyakit menular |
| **Bayi Muda** | 29 hari - 3 bulan | 1x per bulan | Pertumbuhan, vaksinasi, ASI ekslusif |
| **Bayi** | 3-6 bulan | 1x per bulan | BB, TB, vaksinasi, MPASI prep |
| **Bayi** | 6-12 bulan | 1x per bulan | Pertumbuhan, gigi susu, MPASI |
| **Balita Muda** | 1-2 tahun | 1x per 3 bulan | BB-TB, gigi, skrining perkembangan |
| **Anak Usia Dini** | 2-6 tahun | 1x per 6 bulan | Imunisasi catch-up, gigi, KPSP |

---

## Catatan Kesehatan Anak

### Field yang Harus Dicatat (Sesuai KIA 2024)

#### A. Informasi Dasar
```
✓ Tanggal Pemeriksaan (format: DD MMM YYYY)
✓ Kategori Usia (mis: 0-28 Hari, 1-3 Bulan, 3-6 Bulan, dst)
✓ Periode Kunjungan (kunjungan ke-1, ke-2, dst)
✓ Lokasi Pemeriksaan (Puskesmas, Posyandu, Rumah, Klinik)
✓ Tenaga Kesehatan (nama + role: Dokter, Bidan, Kader)
```

#### B. Pemeriksaan Fisik
```
✓ Berat Badan (kg) - Wajib untuk BB-U, BB-TB assessment
✓ Tinggi Badan (cm) - Wajib untuk TB-U assessment
✓ Lingkar Kepala (cm) - Untuk usia 0-12 bulan
✓ IMT (kg/m²) - Dihitung dari BB & TB (untuk usia 2-6 tahun)
```

#### C. Status Pertumbuhan (WHO Z-Score Based)
Semua field ini menggunakan standar WHO 2006:

| Indikator | Rentang Usia | Status | Deskripsi |
|-----------|-------------|--------|-----------|
| **BB-U** (BB menurut Usia) | 0-60 bulan | Normal / Gizi Kurang / Gizi Buruk | Underweight assessment |
| **TB-U** (TB menurut Usia) | 0-60 bulan | Normal / Pendek / Sangat Pendek | Stunting assessment |
| **IMT-U** (IMT menurut Usia) | 0-60 bulan | Normal / Kurus / Sangat Kurus | Wasting untuk usia 2+ |
| **BB-TB** (BB menurut TB) | 0-60 bulan | Normal / Kurus / Sangat Kurus | Acute malnutrition (wasting) |
| **LK-U** (Lingkar Kepala) | 0-36 bulan | Normal / Mikrosefali / Makrosefali | Neurodevelopment risk |

**Klasifikasi Status (berdasarkan Z-Score):**
```
Normal           : Z-Score ≥ -1 SD
Perhatian/Kurang : -3 SD ≤ Z-Score < -1 SD
Berat/Buruk      : Z-Score < -3 SD
```

#### D. Skrining Perkembangan (Developmental Screening)

| Tool | Usia | Fungsi | Status di App |
|------|------|--------|-----------|
| **KPSP** (Kuesioner Pra Skrining Perkembangan) | 3-72 bulan | General developmental assessment | ✓ Implemented |
| **M-CHAT Revised** (Modified Checklist for Autism Traits) | 16-30 bulan | Autism spectrum screening | ✓ Implemented |
| **PRAT** (Penilaian Risiko Awal Tumbuh Kembang) | 0-3 tahun | Early risk detection | ⚠️ Planned |
| **ACTRS** (Ages & Stages Questionnaire) | 1-66 bulan | Comprehensive development | ✓ Implemented |

**Status Hasil Skrining:**
- **Normal**: Tidak ada indikasi keterlambatan
- **Caution**: Ada tanda-tanda yang perlu diperhatikan
- **Delay**: Ada indikasi keterlambatan, perlu referral

#### E. Catatan Klinis & Rekomendasi
```
✓ Catatan Klinis: Temuan abnormal, keluhan, pengamatan khusus
✓ Tindakan yang Diberikan: Vaksinasi, edukasi, intervensi
✓ Rekomendasi Tindak Lanjut: Jadwal kunjungan berikutnya
```

---

## Catatan Kesehatan Gigi

### Field yang Harus Dicatat (Sesuai KIA 2024)

#### A. Informasi Dasar
```
✓ Tanggal Pemeriksaan
✓ Bulan Ke- (untuk tracking gigi susu vs permanen)
✓ Kategori Usia
```

#### B. Pemeriksaan Gigi (WHO/FDI Standard)
```
✓ Jumlah Gigi yang Telah Tumbuh (0-20 untuk gigi susu)
✓ Jumlah Gigi Berlubang/Karies (dmf index)
✓ Status Plak (Tidak ada / Minimal / Ada / Banyak)
✓ Status Gusi (Normal / Inflamasi Ringan / Inflamasi Berat)
✓ Kondisi Gigi (Sehat / Plak/Stain / Gingivitis / Karies Ringan / Karies Sedang / Karies Berat)
✓ Risiko Karies (Rendah / Sedang / Tinggi)
```

**Klasifikasi Karies (DMF/dmf Index):**
- **d** (decayed) - Gigi berlubang/karies
- **m** (missing) - Gigi tanggal/hilang
- **f** (filled) - Gigi tertambal
- **dmf = d+m+f** (untuk gigi susu), DMF (untuk gigi permanen)

**Risiko Karies Assessment:**
- **Rendah**: Tidak ada karies, plak minimal, dietary habits baik
- **Sedang**: Ada faktor risiko tapi terkontrol, edukasi diberikan
- **Tinggi**: Banyak karies, diet tinggi gula, oral hygiene buruk

#### C. Tindakan & Rekomendasi
```
✓ Tindakan yang Diberikan (edukasi, fluoride topical, tambal gigi, dll)
✓ Rekomendasi (kontrol ulang, diet counseling, referral ke gigi)
```

---

## Indikator Pertumbuhan

### WHO Growth Reference Curve (2006)

```
GROWTH PERCENTILE & Z-SCORE:

Z-Score Ranges:
> 1 SD     : Baik/Sehat
-1 sd sd   : Baik/Sehat (Normal)
-1 to -2   : Gizi Kurang (Moderately Malnourished)
-2 to -3   : Gizi Kurang (Malnourished)
< -3 SD    : Gizi Buruk (Severely Malnourished)

Color-Coded KMS Card:
- HIJAU (Green)    : Normal
- KUNING (Yellow)  : Gizi Kurang / Monitor
- MERAH (Red)      : Gizi Buruk / Urgent Action
```

### Indikator Komposit Status Gizi

| Indikator | Rumus | Interpretasi |
|-----------|-------|--------------|
| **Gizi Baik** | Semua indikator normal | Tidak ada masalah gizi |
| **Gizi Kurang** | Ada 1-2 indikator < -1 SD | Monitoring & edukasi intensif |
| **Gizi Buruk** | Ada indikator < -3 SD | Referral & intervensi |
| **Risiko Tinggi** | BB-U atau TB-U menurun | Intensif monitoring |

---

## Skrining Perkembangan

### KPSP (3-72 bulan)

**Tujuan**: Deteksi dini keterlambatan perkembangan

**Penilaian**: 9 pertanyaan per kelompok usia, score 0-9
- **Hasil Normal**: Score ≥ 8 (tidak ada tanda keterlambatan)
- **Hasil Caution**: Score 6-7 (ada tanda yang perlu diperhatikan)
- **Hasil Delay**: Score ≤ 5 (indikasi keterlambatan, referral)

**Area Perkembangan Dinilai**:
- Gerak Kasar (Gross Motor)
- Gerak Halus (Fine Motor)
- Bahasa (Language)
- Sosialisasi & Kemandirian (Social-Emotional)

### M-CHAT Revised (16-30 bulan)

**Tujuan**: Screening Autism Spectrum Disorder

**Penilaian**: 20 items
- **Score 0-2**: Low risk (typical development)
- **Score 3-7**: Medium risk (follow-up assessment recommended)
- **Score ≥ 8**: High risk (refer to autism specialist)

### ACTRS (Usia 1-66 bulan)

**Tujuan**: Comprehensive developmental screening

**Area Penilaian**:
- Communication
- Gross Motor
- Fine Motor
- Problem Solving
- Personal-Social

**Scoring**: 
- Normal, Caution, Concern

---

## Integrasi & Implementasi

### Data Flow di App

```
CatatanKesehatan
  ├─ Kesehatan Anak (General Health)
  │   ├─ Informasi Dasar
  │   ├─ Pemeriksaan Fisik
  │   ├─ Status Pertumbuhan (WHO Z-Score)
  │   ├─ Skrining Perkembangan (KPSP, M-CHAT, ACTRS)
  │   └─ Catatan & Rekomendasi
  │
  ├─ Kesehatan Gigi (Dental Health)
  │   ├─ Informasi Dasar
  │   ├─ Pemeriksaan Gigi (dmf/DMF index)
  │   └─ Tindakan & Rekomendasi
  │
  └─ Pertumbuhan (Growth Monitoring)
      ├─ Anthropometric Data
      ├─ Z-Score Calculation
      ├─ Status Gizi
      └─ Trend Analysis
```

### Backend API Endpoint (Yang Sudah Ada)

**Kesehatan Anak:**
- `POST /tenaga-kesehatan/pelayanan-kesehatan-anak` - Create
- `GET /pelayanan-kesehatan-anak?anak_id=X` - Read

**Kesehatan Gigi:**
- `POST /tenaga-kesehatan/pemeriksaan-gigi` - Create
- `GET /pemeriksaan-gigi?anak_id=X` - Read

**Pertumbuhan:**
- `POST /tenaga-kesehatan/pertumbuhan` - Create
- `GET /pertumbuhan?anak_id=X` - Read

### Frontend Implementation Status

| Feature | Status | Notes |
|---------|--------|-------|
| Catatan Kesehatan Anak | ✅ 70% | UI sesuai KIA, perlu API integration |
| Catatan Kesehatan Gigi | ✅ 70% | UI sesuai KIA, perlu API integration |
| Growth Indicators Display | ✅ 60% | Displayed but calculation needed |
| Developmental Screening | ✅ 40% | Models ada, UI belum full |
| Status Color-Coding | ✅ 100% | Implemented |
| Detail Screen | ✅ 80% | Komprehensif, perlu polish |

---

## Reference & Best Practices

### KIA 2024 Standar
- Buku KIA versi 2024 dari Kemenkes RI
- WHO Child Growth Standards 2006
- Panduan Pemeriksaan Gigi Anak dari RSGM

### Color-Coding Convention (Buku KIA)
```
🟢 HIJAU   : Normal / Sehat / Baik
🟡 KUNING  : Caution / Perhatian / Kurang
🔴 MERAH   : Alert / Urgent / Buruk
```

### Data Validation Rules
```
1. BB harus > 0
2. TB harus dalam range usia yang masuk akal
3. Kategori Usia harus match dengan umur anak
4. Screening scores harus valid sesuai tool
5. Status harus salah satu dari enum yang valid
```

---

## Next Steps

- [ ] Integrasi dengan API Backend untuk fetch data real
- [ ] Implementasi PRAT & DDEV 3 screening tools
- [ ] Auto-calculation Z-Score dari BB & TB
- [ ] Export PDF laporan catatan kesehatan
- [ ] Alert system untuk kasus urgent/gizi buruk
- [ ] Trend analysis & growth chart visualization

---

**Dokumentasi terakhir diupdate**: 6 Mei 2026
**Version**: 1.0 - KIA 2024 Compliance
**Status**: ✅ Implementasi Prioritas 1 Selesai
