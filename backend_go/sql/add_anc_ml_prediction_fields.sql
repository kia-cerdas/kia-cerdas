-- Migration: Add ML prediction fields to pemeriksaan_kehamilan table
-- Date: 2025-06-20
-- Description: Add fields to store detailed ML prediction results from the new ANC model
-- Database: PostgreSQL (Supabase)

-- Add new columns for ML prediction results
ALTER TABLE pemeriksaan_kehamilan
ADD COLUMN IF NOT EXISTS overall_prediction INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS overall_label VARCHAR(20) DEFAULT 'NORMAL',
ADD COLUMN IF NOT EXISTS active_risk_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS alasan_klinis TEXT,
ADD COLUMN IF NOT EXISTS rekomendasi_utama TEXT,
ADD COLUMN IF NOT EXISTS risk_types TEXT;

-- Add comments for documentation (PostgreSQL specific)
COMMENT ON COLUMN pemeriksaan_kehamilan.overall_prediction IS 'Overall prediction from ML model: 0=NORMAL, 1=PERLU TINDAKAN, 2=PERLU RUJUKAN';
COMMENT ON COLUMN pemeriksaan_kehamilan.overall_label IS 'Human-readable label: NORMAL, PERLU TINDAKAN, or PERLU RUJUKAN';
COMMENT ON COLUMN pemeriksaan_kehamilan.active_risk_count IS 'Number of active risk types detected';
COMMENT ON COLUMN pemeriksaan_kehamilan.alasan_klinis IS 'JSON array of clinical reasons for risk prediction';
COMMENT ON COLUMN pemeriksaan_kehamilan.rekomendasi_utama IS 'Main recommendation from ML model';
COMMENT ON COLUMN pemeriksaan_kehamilan.risk_types IS 'JSON array of detailed risk type information (name, detected, probability, tindakan, referensi)';

-- Update existing records to have default values
UPDATE pemeriksaan_kehamilan
SET overall_prediction = 0,
    overall_label = 'NORMAL',
    active_risk_count = 0
WHERE overall_prediction IS NULL;
