-- SQL Migration: Create all missing Edukasi / MPASI tables
-- Run this in your Supabase SQL Editor if AutoMigrate does not run or encounters PgBouncer pooler errors.

BEGIN;

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

-- CREATE TABLE IF NOT EXISTS edukasi_nifas (
--     id SERIAL PRIMARY KEY,
--     judul VARCHAR(255) NOT NULL,
--     isi TEXT,
--     perawatan TEXT,
--     tanda_bahaya TEXT,
--     gambar_url TEXT,
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
--     updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
-- );

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

COMMIT;
