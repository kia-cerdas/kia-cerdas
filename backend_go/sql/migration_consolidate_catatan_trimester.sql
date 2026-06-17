-- Migration: Consolidate catatan_pelayanan_trimester into pemeriksaan_dokter_trimester tables
-- Database: PostgreSQL
-- Date: 2026-06-13
-- Description:
--   1. Add catatan fields to pemeriksaan_dokter_trimester_1
--   2. Add catatan fields to pemeriksaan_dokter_trimester_3
--   3. Migrate data from catatan_pelayanan_trimester tables to respective trimester tables
--   4. Drop old catatan_pelayanan_trimester tables

-- =============== TRIMESTER 1 ===============

-- 1. Add catatan fields to pemeriksaan_dokter_trimester_1
ALTER TABLE pemeriksaan_dokter_trimester_1
ADD COLUMN IF NOT EXISTS tanggal_periksa_stamp_paraf DATE NULL,
ADD COLUMN IF NOT EXISTS keluhan_pemeriksaan_tindakan_saran TEXT NULL,
ADD COLUMN IF NOT EXISTS tanggal_kembali DATE NULL;

-- =============== TRIMESTER 3 ===============

-- 2. Add catatan fields to pemeriksaan_dokter_trimester_3
ALTER TABLE pemeriksaan_dokter_trimester_3
ADD COLUMN IF NOT EXISTS tanggal_periksa_stamp_paraf DATE NULL,
ADD COLUMN IF NOT EXISTS keluhan_pemeriksaan_tindakan_saran TEXT NULL,
ADD COLUMN IF NOT EXISTS tanggal_kembali DATE NULL;

-- =============== DATA MIGRATION ===============

-- 3. Migrate data from catatan_pelayanan_trimester_1 to pemeriksaan_dokter_trimester_1
-- This updates existing records in pemeriksaan_dokter_trimester_1 with catatan data
UPDATE pemeriksaan_dokter_trimester_1 t1
SET
    tanggal_periksa_stamp_paraf = c1.tanggal_periksa_stamp_paraf,
    keluhan_pemeriksaan_tindakan_saran = c1.keluhan_pemeriksaan_tindakan_saran,
    tanggal_kembali = c1.tanggal_kembali
FROM catatan_pelayanan_trimester_1 c1
WHERE t1.kehamilan_id = c1.kehamilan_id;

-- 4. Migrate data from catatan_pelayanan_trimester_3 to pemeriksaan_dokter_trimester_3
UPDATE pemeriksaan_dokter_trimester_3 t3
SET
    tanggal_periksa_stamp_paraf = c3.tanggal_periksa_stamp_paraf,
    keluhan_pemeriksaan_tindakan_saran = c3.keluhan_pemeriksaan_tindakan_saran,
    tanggal_kembali = c3.tanggal_kembali
FROM catatan_pelayanan_trimester_3 c3
WHERE t3.kehamilan_id = c3.kehamilan_id;

-- =============== DROP OLD TABLES ===============

-- 5. Drop old catatan_pelayanan_trimester tables
-- Uncomment these after verifying data migration is successful

-- DROP TABLE IF EXISTS catatan_pelayanan_trimester_1 CASCADE;
-- DROP TABLE IF EXISTS catatan_pelayanan_trimester_2 CASCADE;
-- DROP TABLE IF EXISTS catatan_pelayanan_trimester_3 CASCADE;

-- =============== VERIFICATION ===============

-- Verify the columns were added
SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN ('pemeriksaan_dokter_trimester_1', 'pemeriksaan_dokter_trimester_3')
  AND column_name IN ('tanggal_periksa_stamp_paraf', 'keluhan_pemeriksaan_tindakan_saran', 'tanggal_kembali')
ORDER BY table_name, column_name;

-- Verify data migration for trimester 1
SELECT
    COUNT(*) as total_trimester1,
    COUNT(tanggal_periksa_stamp_paraf) as with_catatan
FROM pemeriksaan_dokter_trimester_1;

-- Verify data migration for trimester 3
SELECT
    COUNT(*) as total_trimester3,
    COUNT(tanggal_periksa_stamp_paraf) as with_catatan
FROM pemeriksaan_dokter_trimester_3;
