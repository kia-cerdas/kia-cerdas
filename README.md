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

---

# Struktur Repository

```text
backend/
web/
mobile/
docs/
```

---

# Backend Setup

## Instalasi

### 1. Install Dependencies

```bash
# TODO
```

### 2. Konfigurasi Environment

```bash
# TODO
```

### 3. Menjalankan Aplikasi

```bash
# TODO
```

---

# Web Setup


## Instalasi


### 1. Install Dependencies

```bash
# TODO
```

### 2. Konfigurasi Environment

```bash
# TODO
```

### 3. Menjalankan Aplikasi

```bash
# TODO
```

---

# Mobile Setup

## Instalasi

### 1. Install Dependencies

```bash
# TODO
```

### 2. Konfigurasi Environment

```bash
# TODO
```

### 3. Menjalankan Aplikasi

```bash
# TODO
```

---

# Environment Variables

## Backend

```env
# TODO
```

## Web

```env
# TODO
```

## Mobile

```env
# TODO
```

---

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

## Contoh

```bash
git checkout dev
git pull origin dev

git checkout -b feat/auth-user-management

# melakukan pengembangan

git add .
git commit -m "Add authentication feature"
git push -u origin feat/auth-user-management
```

Kemudian buat Pull Request:

```text
feat/auth-user-management → dev
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

