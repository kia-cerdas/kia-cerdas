    -- Migration: Hierarki Wilayah (Provinsi -> Kabupaten -> Kecamatan -> Desa)
    -- Database: PostgreSQL
    -- Date: 2026-06-21
    -- Description:
    --   Membuat master wilayah berjenjang dan menghubungkan desa & puskesmas ke kecamatan.
    --   Kolom string lama di tabel `desa` (kecamatan/kabupaten/provinsi) DIPERTAHANKAN demi
    --   kompatibilitas modul laporan/dashboard yang masih membacanya sebagai string.
    --   Migrasi melakukan backfill master + desa.kecamatan_id dari data string desa yang sudah ada.
    -- Safe to run multiple times (idempotent).

    BEGIN;

    -- =====================================================================
    -- 1) Tabel master wilayah
    -- =====================================================================
    CREATE TABLE IF NOT EXISTS provinsi (
      id         SERIAL PRIMARY KEY,
      nama       VARCHAR(120) NOT NULL,
      created_at TIMESTAMPTZ DEFAULT NOW(),
      updated_at TIMESTAMPTZ DEFAULT NOW(),
      deleted_at TIMESTAMPTZ
    );

    CREATE TABLE IF NOT EXISTS kabupaten (
      id          SERIAL PRIMARY KEY,
      provinsi_id INTEGER NOT NULL,
      nama        VARCHAR(120) NOT NULL,
      created_at  TIMESTAMPTZ DEFAULT NOW(),
      updated_at  TIMESTAMPTZ DEFAULT NOW(),
      deleted_at  TIMESTAMPTZ
    );

    CREATE TABLE IF NOT EXISTS kecamatan (
      id           SERIAL PRIMARY KEY,
      kabupaten_id INTEGER NOT NULL,
      nama         VARCHAR(120) NOT NULL,
      created_at   TIMESTAMPTZ DEFAULT NOW(),
      updated_at   TIMESTAMPTZ DEFAULT NOW(),
      deleted_at   TIMESTAMPTZ
    );

    -- FK kabupaten -> provinsi
    DO $$
    BEGIN
      IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_kabupaten_provinsi') THEN
        ALTER TABLE kabupaten
          ADD CONSTRAINT fk_kabupaten_provinsi
          FOREIGN KEY (provinsi_id) REFERENCES provinsi(id)
          ON UPDATE CASCADE ON DELETE RESTRICT;
      END IF;
    END $$;

    -- FK kecamatan -> kabupaten
    DO $$
    BEGIN
      IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_kecamatan_kabupaten') THEN
        ALTER TABLE kecamatan
          ADD CONSTRAINT fk_kecamatan_kabupaten
          FOREIGN KEY (kabupaten_id) REFERENCES kabupaten(id)
          ON UPDATE CASCADE ON DELETE RESTRICT;
      END IF;
    END $$;

    -- Unik per-jenjang (mengabaikan baris terhapus). Pakai partial unique index agar
    -- nama yang sama di parent berbeda tetap diizinkan.
    CREATE UNIQUE INDEX IF NOT EXISTS uq_provinsi_nama
      ON provinsi (nama) WHERE deleted_at IS NULL;
    CREATE UNIQUE INDEX IF NOT EXISTS uq_kabupaten_prov_nama
      ON kabupaten (provinsi_id, nama) WHERE deleted_at IS NULL;
    CREATE UNIQUE INDEX IF NOT EXISTS uq_kecamatan_kab_nama
      ON kecamatan (kabupaten_id, nama) WHERE deleted_at IS NULL;

    CREATE INDEX IF NOT EXISTS ix_kabupaten_provinsi_id ON kabupaten(provinsi_id);
    CREATE INDEX IF NOT EXISTS ix_kecamatan_kabupaten_id ON kecamatan(kabupaten_id);

    -- =====================================================================
    -- 2) Kolom FK baru (nullable) di desa & puskesmas
    -- =====================================================================
    ALTER TABLE desa      ADD COLUMN IF NOT EXISTS kecamatan_id INTEGER;
    ALTER TABLE puskesmas ADD COLUMN IF NOT EXISTS kecamatan_id INTEGER;

    DO $$
    BEGIN
      IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_desa_kecamatan') THEN
        ALTER TABLE desa
          ADD CONSTRAINT fk_desa_kecamatan
          FOREIGN KEY (kecamatan_id) REFERENCES kecamatan(id)
          ON UPDATE CASCADE ON DELETE SET NULL;
      END IF;
    END $$;

    DO $$
    BEGIN
      IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_puskesmas_kecamatan') THEN
        ALTER TABLE puskesmas
          ADD CONSTRAINT fk_puskesmas_kecamatan
          FOREIGN KEY (kecamatan_id) REFERENCES kecamatan(id)
          ON UPDATE CASCADE ON DELETE SET NULL;
      END IF;
    END $$;

    CREATE INDEX IF NOT EXISTS ix_desa_kecamatan_id ON desa(kecamatan_id);
    CREATE INDEX IF NOT EXISTS ix_puskesmas_kecamatan_id ON puskesmas(kecamatan_id);

    -- =====================================================================
    -- 3) Backfill master dari string desa lama (hanya nilai non-kosong)
    -- =====================================================================

    -- 3a) Provinsi unik
    INSERT INTO provinsi (nama)
    SELECT DISTINCT TRIM(provinsi)
    FROM desa
    WHERE provinsi IS NOT NULL AND TRIM(provinsi) <> ''
    ON CONFLICT DO NOTHING;

    -- 3b) Kabupaten unik per provinsi
    INSERT INTO kabupaten (provinsi_id, nama)
    SELECT DISTINCT p.id, TRIM(d.kabupaten)
    FROM desa d
    JOIN provinsi p ON p.nama = TRIM(d.provinsi) AND p.deleted_at IS NULL
    WHERE d.kabupaten IS NOT NULL AND TRIM(d.kabupaten) <> ''
    ON CONFLICT DO NOTHING;

    -- 3c) Kecamatan unik per kabupaten
    INSERT INTO kecamatan (kabupaten_id, nama)
    SELECT DISTINCT k.id, TRIM(d.kecamatan)
    FROM desa d
    JOIN provinsi p  ON p.nama = TRIM(d.provinsi) AND p.deleted_at IS NULL
    JOIN kabupaten k ON k.nama = TRIM(d.kabupaten) AND k.provinsi_id = p.id AND k.deleted_at IS NULL
    WHERE d.kecamatan IS NOT NULL AND TRIM(d.kecamatan) <> ''
    ON CONFLICT DO NOTHING;

    -- 3d) Set desa.kecamatan_id dari hasil match string lengkap
    UPDATE desa d
    SET kecamatan_id = kec.id
    FROM provinsi p
    JOIN kabupaten kab ON kab.provinsi_id = p.id AND kab.deleted_at IS NULL
    JOIN kecamatan kec ON kec.kabupaten_id = kab.id AND kec.deleted_at IS NULL
    WHERE d.kecamatan_id IS NULL
      AND p.deleted_at IS NULL
      AND p.nama   = TRIM(d.provinsi)
      AND kab.nama = TRIM(d.kabupaten)
      AND kec.nama = TRIM(d.kecamatan);

    COMMIT;
