-- Migration: Add kategori_pemberian column to pencatatan_imunisasi table
-- Created: 2026-08-28
-- Purpose: Track vaccine administration category (white=tepat waktu, orange=terlambat, pink=imunisasi kejar, gray=tidak boleh)

-- Add column
ALTER TABLE pencatatan_imunisasi 
ADD COLUMN IF NOT EXISTS kategori_pemberian VARCHAR(50) DEFAULT 'white';

-- Add comment
COMMENT ON COLUMN pencatatan_imunisasi.kategori_pemberian IS 'Kategori pemberian imunisasi berdasarkan usia: white (tepat waktu), orange (terlambat tapi masih boleh), pink (imunisasi kejar), gray (tidak boleh)';

-- Update existing records to 'white' if NULL
UPDATE pencatatan_imunisasi 
SET kategori_pemberian = 'white' 
WHERE kategori_pemberian IS NULL;

-- Create index for better query performance
CREATE INDEX IF NOT EXISTS idx_pencatatan_imunisasi_kategori 
ON pencatatan_imunisasi(kategori_pemberian);
