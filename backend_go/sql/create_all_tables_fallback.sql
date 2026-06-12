-- SQL Fallback: Jalankan query ini di Supabase SQL Editor Anda
-- Cara: Masuk ke dashboard Supabase -> SQL Editor -> New Query -> Paste query ini -> Klik RUN.

BEGIN;

-- ==========================================
-- 1. TABEL-TABEL EDUKASI
-- ==========================================

CREATE TABLE IF NOT EXISTS edukasi_imd (
    id SERIAL PRIMARY KEY,
    judul VARCHAR(255) NOT NULL,
    isi TEXT,
    manfaat TEXT,
    langkah TEXT,
    gambar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS edukasi_informasi_umum (
    id SERIAL PRIMARY KEY,
    tipe VARCHAR(20) NOT NULL,
    judul VARCHAR(255) NOT NULL,
    umur_target VARCHAR(50),
    durasi_baca VARCHAR(30),
    ringkasan TEXT,
    konten TEXT NOT NULL,
    yang_perlu_diingat TEXT,
    thumbnail_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS edukasi_kesehatan_mental (
    id SERIAL PRIMARY KEY,
    judul VARCHAR(255) NOT NULL,
    isi TEXT,
    tanda_gejala TEXT,
    solusi TEXT,
    gambar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS edukasi_menyusui_asi (
    id SERIAL PRIMARY KEY,
    judul VARCHAR(255) NOT NULL,
    isi TEXT,
    manfaat_asi TEXT,
    cara TEXT,
    masalah TEXT,
    solusi TEXT,
    gambar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS materi_mpasi (
    id SERIAL PRIMARY KEY,
    judul VARCHAR(255) NOT NULL,
    konten TEXT NOT NULL,
    gambar_url TEXT,
    bulan_min INTEGER,
    bulan_max INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS aturan_porsi_mpasi (
    id SERIAL PRIMARY KEY,
    bulan_min INTEGER NOT NULL,
    bulan_max INTEGER NOT NULL,
    tekstur TEXT NOT NULL,
    frekuensi TEXT NOT NULL,
    porsi TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS jadwal_harian_mpasi (
    id SERIAL PRIMARY KEY,
    bulan_min INTEGER NOT NULL,
    bulan_max INTEGER NOT NULL,
    waktu VARCHAR(10) NOT NULL,
    aktivitas VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS resep_mpasi (
    id SERIAL PRIMARY KEY,
    bulan_min INTEGER NOT NULL,
    bulan_max INTEGER NOT NULL,
    judul VARCHAR(255) NOT NULL,
    tipe VARCHAR(50) NOT NULL,
    gambar_url TEXT,
    waktu_persiapan INTEGER NOT NULL,
    kalori INTEGER NOT NULL,
    porsi VARCHAR(50) NOT NULL,
    bahan_bahan TEXT[] NOT NULL,
    cara_membuat TEXT[] NOT NULL,
    manfaat TEXT,
    tips TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS edukasi_nifas (
    id SERIAL PRIMARY KEY,
    judul VARCHAR(255) NOT NULL,
    isi TEXT,
    perawatan TEXT,
    tanda_bahaya TEXT,
    gambar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS edukasi_perawatan_anak (
    id SERIAL PRIMARY KEY,
    judul VARCHAR(255) NOT NULL,
    gambar_url TEXT,
    isi_konten TEXT,
    rentang_usia VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS edukasi_pola_asuh (
    id SERIAL PRIMARY KEY,
    judul VARCHAR(255) NOT NULL,
    gambar_url TEXT,
    isi TEXT,
    rentang_usia VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS edukasi_setelah_melahirkan (
    id SERIAL PRIMARY KEY,
    judul VARCHAR(255) NOT NULL,
    gambar_url TEXT,
    isi TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS edukasi_tanda_melahirkan (
    id SERIAL PRIMARY KEY,
    judul VARCHAR(255) NOT NULL,
    isi TEXT,
    tanda TEXT,
    tindakan TEXT,
    gambar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS edukasi_trimester (
    id SERIAL PRIMARY KEY,
    judul VARCHAR(255) NOT NULL,
    gambar_url TEXT,
    isi TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================
-- 2. TABEL-TABEL KESEHATAN ANAK & METADATA
-- ==========================================

CREATE TABLE IF NOT EXISTS "Kategori_umur" (
    id SERIAL PRIMARY KEY,
    kategori_umur VARCHAR(255) NOT NULL UNIQUE,
    min_value INTEGER NOT NULL,
    max_value INTEGER NOT NULL,
    unit VARCHAR(10) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS periode_kunjungan (
    id SERIAL PRIMARY KEY,
    nama VARCHAR(255) NOT NULL,
    kategori_umur_id INTEGER NOT NULL,
    min_value INTEGER NOT NULL,
    max_value INTEGER NOT NULL,
    unit VARCHAR(10) NOT NULL,
    urutan INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS jenis_pelayanan (
    id SERIAL PRIMARY KEY,
    nama VARCHAR(255) NOT NULL,
    tipe_input VARCHAR(20) NOT NULL,
    group_name VARCHAR(100),
    section VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS jenis_pelayanan_kategori (
    id SERIAL PRIMARY KEY,
    jenis_pelayanan_id INTEGER NOT NULL,
    kategori_umur_id INTEGER NOT NULL,
    periode_id INTEGER,
    urutan INTEGER NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS aturan_pelayanans (
    id SERIAL PRIMARY KEY,
    jenis_pelayanan_id INTEGER NOT NULL,
    umur_min_bulan INTEGER NOT NULL,
    umur_max_bulan INTEGER NOT NULL,
    bulan INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS "Neonatus" (
    id SERIAL PRIMARY KEY,
    anak_id INTEGER NOT NULL,
    tanggal TIMESTAMP WITH TIME ZONE NOT NULL,
    kategori_umur_id INTEGER NOT NULL,
    periode_id INTEGER NOT NULL,
    tenaga_kesehatan_id INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS detail_pelayanan_neonatus (
    id SERIAL PRIMARY KEY,
    neonatus_id INTEGER NOT NULL,
    jenis_pelayanan_id INTEGER NOT NULL,
    nilai VARCHAR(255) NOT NULL,
    keterangan VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS periksa_gigi (
    id SERIAL PRIMARY KEY,
    anak_id INTEGER NOT NULL,
    bulanke INTEGER NOT NULL,
    tanggal TIMESTAMP WITH TIME ZONE NOT NULL,
    jumlahgigi INTEGER NOT NULL DEFAULT 0,
    gigi_berlubang INTEGER NOT NULL,
    status_plak VARCHAR(10) NOT NULL,
    resiko_gigi_berlubang VARCHAR(10) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS pengukuran_lila (
    id SERIAL PRIMARY KEY,
    anak_id INTEGER NOT NULL,
    bulanke INTEGER NOT NULL,
    tanggal TIMESTAMP WITH TIME ZONE NOT NULL,
    hasil_lila DECIMAL(5,2) NOT NULL,
    kategori_risiko VARCHAR(20) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS keluhan_anak (
    id SERIAL PRIMARY KEY,
    anak_id INTEGER NOT NULL,
    tanggal DATE NOT NULL,
    keluhan TEXT NOT NULL,
    tindakan TEXT,
    pemeriksa VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

COMMIT;
