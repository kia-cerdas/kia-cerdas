# KIA Cerdas

## Deskripsi Proyek

KIA Cerdas adalah aplikasi yang mendukung layanan kesehatan ibu dan anak.

---

# Arsitektur Sistem

KIA Cerdas terdiri dari tiga komponen utama:

* **Backend:** Golang
* **Web:** React.js
* **Mobile:** Flutter

Backend menyediakan API yang digunakan oleh aplikasi web dan mobile untuk mengakses serta mengelola data secara terpusat.

## Dokumentasi Arsitektur Backend (Clean Architecture)

Backend KIA Cerdas mengadopsi pola **Clean Architecture** untuk memisahkan *concern* dan memastikan aplikasi mudah diskalakan serta dikelola.

![Arsitektur Layer](architecture%20layer.jpeg)

**Alur Layer Sistem:**
`Router` → `Controller` → `Usecase` → `Repository` → `DB`

* **Router**: Mendefinisikan endpoint API dan meneruskan permintaan ke Controller yang sesuai.
* **Controller**: Menerima HTTP request, melakukan validasi dasar, dan meneruskannya ke Usecase.
* **Usecase**: Menyimpan inti dari aturan bisnis (business logic) aplikasi tanpa bergantung pada antarmuka luar.
* **Repository**: Berfungsi sebagai jembatan antara aplikasi dan database (akses data, operasi CRUD).
* **DB**: Sistem manajemen basis data tempat menyimpan data persisten.

> Diagram arsitektur secara komprehensif terdapat di dalam dokumen laporan Bab 2/3. Pola interaksi antar layer (`Controller` - `Usecase` - `Repository`) juga telah digambarkan di dalam **Sequence Diagram**.
> Penjelasan detail tiap layer beserta contoh kode dapat Anda pelajari lebih lanjut di sini:
> 👉 [Dokumentasi Arsitektur Backend Lengkap](docs/architecture/backend-architecture.md)

---

# Struktur Repository

```text
backend/
web/
mobile/
docs/
```

---

# Backend Setup (Golang)

## Instalasi

### 1. Install Dependencies

```bash
go mod tidy
```

### 2. Menjalankan Aplikasi

```bash
go run cmd/main.go
```

---

# Web Setup (React.js)

## Instalasi

### 1. Install Dependencies

```bash
npm install
```

### 2. Menjalankan Aplikasi

```bash
npm run dev
```

---

# Mobile Setup (Flutter)

## Instalasi

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Menjalankan Aplikasi

```bash
flutter run
```



# Git Workflow

## Branch Strategy

| Branch   | Deskripsi                                                                                                                                        |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| `main`   | Production-ready code only. Tidak diperbolehkan melakukan direct push.                                                                           |
| `dev`    | Branch integrasi dan staging. Seluruh fitur yang selesai dikembangkan akan digabungkan ke branch ini.                                            |
| `feat/*` | Branch untuk pengembangan satu fitur tertentu. Contoh: `feat/auth-user-management`, `feat/immunization-schedule`, dan `feat/grafik-pertumbuhan`. |

## Development Workflow

1. Checkout ke branch `dev`.
2. Buat branch fitur dari `dev` dengan format `feat/[nama-fitur]`.
3. Lakukan pengembangan pada branch fitur.
4. Commit dan push perubahan ke branch fitur masing-masing.
5. Buat Pull Request (PR) dari branch `feat/*` ke `dev`.
6. Pull Request wajib mendapatkan persetujuan minimal 1 anggota tim lain sebelum di-merge.
7. Setelah disetujui, branch fitur dapat di-merge ke `dev`.

## Commit Convention

Gunakan format commit berikut:

```text
[type] deskripsi singkat
```

### Tipe Commit

| Tipe   | Deskripsi                              |
| ------ | -------------------------------------- |
| `feat` | Menambahkan fitur baru                 |
| `fix`  | Memperbaiki bug atau kesalahan         |
| `docs` | Perubahan dokumentasi                  |
| `test` | Menambahkan atau memperbarui pengujian |

### Contoh

```bash
git commit -m "[feat] add authentication feature"

git commit -m "[fix] resolve login validation issue"

git commit -m "[docs] update README"

git commit -m "[test] add user service unit test"
```


## Struktur Branch

```text
main
│
└── dev
    ├── feat/auth-user-management
    ├── feat/immunization-schedule
    ├── feat/grafik-pertumbuhan
    └── feat/notification
```

