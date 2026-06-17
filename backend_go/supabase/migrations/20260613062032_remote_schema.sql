


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;




ALTER SCHEMA "public" OWNER TO "postgres";


CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE TYPE "public"."rentang_usia_enum" AS ENUM (
    '0-28 hari',
    '29 hari -3 bulan',
    '3-6 bulan',
    '6-9 bulan',
    '9-12 bulan',
    '12-18 bulan',
    '18-24 bulan',
    '2-3 tahun',
    '3-4 tahun',
    '4-5 tahun',
    '5-6 tahun'
);


ALTER TYPE "public"."rentang_usia_enum" OWNER TO "postgres";


CREATE TYPE "public"."rentang_usia_pola_asuh" AS ENUM (
    '0-18 Bulan',
    '1.5 Tahun - 3 Tahun',
    '3 tahun - 6 Tahun'
);


ALTER TYPE "public"."rentang_usia_pola_asuh" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_updated_at_column"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_updated_at_column"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."Kategori_umur" (
    "id" integer NOT NULL,
    "kategori_umur" "text" NOT NULL,
    "min_value" bigint NOT NULL,
    "max_value" bigint NOT NULL,
    "unit" character varying(10) NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."Kategori_umur" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."Kategori_umur_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."Kategori_umur_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."Kategori_umur_id_seq" OWNED BY "public"."Kategori_umur"."id";



CREATE TABLE IF NOT EXISTS "public"."Neonatus" (
    "id" integer NOT NULL,
    "anak_id" integer NOT NULL,
    "tanggal" timestamp with time zone NOT NULL,
    "kategori_umur_id" integer NOT NULL,
    "periode_id" integer NOT NULL,
    "tenaga_kesehatan_id" integer NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."Neonatus" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."Neonatus_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."Neonatus_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."Neonatus_id_seq" OWNED BY "public"."Neonatus"."id";



CREATE TABLE IF NOT EXISTS "public"."Pelayanan_Asi" (
    "id" integer NOT NULL,
    "kunjungan_gizi_id" integer NOT NULL,
    "frekuensi_menyusui" integer NOT NULL,
    "posisi_menyusui" "text",
    "asi_perah" "text" NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."Pelayanan_Asi" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."Pelayanan_Asi_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."Pelayanan_Asi_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."Pelayanan_Asi_id_seq" OWNED BY "public"."Pelayanan_Asi"."id";



CREATE TABLE IF NOT EXISTS "public"."absensi_kelas_ibu_balita" (
    "id" integer NOT NULL,
    "ibu_id" integer NOT NULL,
    "pertemuan_ke" integer NOT NULL,
    "tanggal" "date",
    "nama_kader" character varying(255),
    "tanggal_paraf" "date",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "status" character varying(50) DEFAULT 'Menunggu Verifikasi'::character varying
);


ALTER TABLE "public"."absensi_kelas_ibu_balita" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."absensi_kelas_ibu_balita_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."absensi_kelas_ibu_balita_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."absensi_kelas_ibu_balita_id_seq" OWNED BY "public"."absensi_kelas_ibu_balita"."id";



CREATE TABLE IF NOT EXISTS "public"."absensi_kelas_ibu_hamil" (
    "id" integer NOT NULL,
    "kehamilan_id" integer NOT NULL,
    "pertemuan_ke" integer NOT NULL,
    "tanggal" "date",
    "nama_kader" character varying(255),
    "tanggal_paraf" "date",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "status" character varying
);


ALTER TABLE "public"."absensi_kelas_ibu_hamil" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."absensi_kelas_ibu_hamil_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."absensi_kelas_ibu_hamil_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."absensi_kelas_ibu_hamil_id_seq" OWNED BY "public"."absensi_kelas_ibu_hamil"."id";



CREATE TABLE IF NOT EXISTS "public"."anak" (
    "id" integer NOT NULL,
    "kehamilan_id" integer NOT NULL,
    "penduduk_id" integer NOT NULL,
    "berat_lahir_kg" numeric,
    "tinggi_lahir_cm" numeric,
    "anak_ke" integer,
    "lingkar_kepala_cm" numeric,
    "nama_ibu" "text",
    "nama_ayah" "text",
    "ibu_id" integer,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."anak" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."anak_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."anak_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."anak_id_seq" OWNED BY "public"."anak"."id";



CREATE TABLE IF NOT EXISTS "public"."aturan_pelayanans" (
    "id" integer NOT NULL,
    "jenis_pelayanan_id" integer NOT NULL,
    "umur_min_bulan" bigint NOT NULL,
    "umur_max_bulan" bigint NOT NULL,
    "bulan" bigint NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."aturan_pelayanans" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."aturan_pelayanans_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."aturan_pelayanans_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."aturan_pelayanans_id_seq" OWNED BY "public"."aturan_pelayanans"."id";



CREATE TABLE IF NOT EXISTS "public"."aturan_porsi_mpasi" (
    "id" integer NOT NULL,
    "bulan_min" bigint NOT NULL,
    "bulan_max" bigint NOT NULL,
    "tekstur" "text" NOT NULL,
    "frekuensi" "text" NOT NULL,
    "porsi" "text" NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."aturan_porsi_mpasi" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."aturan_porsi_mpasi_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."aturan_porsi_mpasi_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."aturan_porsi_mpasi_id_seq" OWNED BY "public"."aturan_porsi_mpasi"."id";



CREATE TABLE IF NOT EXISTS "public"."aturan_vaksin_anak" (
    "id" bigint NOT NULL,
    "id_dosis_vaksin" bigint,
    "min_usia_hari" bigint,
    "max_usia_hari" bigint,
    "min_interval_hari" bigint,
    "id_dosis_sebelum" bigint,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone,
    "id_dosis_sebelumnya" bigint
);


ALTER TABLE "public"."aturan_vaksin_anak" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."aturan_vaksin_anak_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."aturan_vaksin_anak_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."aturan_vaksin_anak_id_seq" OWNED BY "public"."aturan_vaksin_anak"."id";



CREATE TABLE IF NOT EXISTS "public"."audit_trails" (
    "id" bigint NOT NULL,
    "actor_user_id" integer,
    "actor_identifier" character varying(150) NOT NULL,
    "actor_role" character varying(80),
    "action" character varying(40) NOT NULL,
    "resource" character varying(120) NOT NULL,
    "method" character varying(10) NOT NULL,
    "path" character varying(255) NOT NULL,
    "status_code" bigint NOT NULL,
    "success" boolean DEFAULT false NOT NULL,
    "ip_address" character varying(64),
    "user_agent" "text",
    "request_id" character varying(120),
    "details" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone
);


ALTER TABLE "public"."audit_trails" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."audit_trails_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."audit_trails_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."audit_trails_id_seq" OWNED BY "public"."audit_trails"."id";



CREATE TABLE IF NOT EXISTS "public"."bbl" (
    "id" bigint NOT NULL,
    "anak_id" bigint NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."bbl" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."bbl_check" (
    "id" bigint NOT NULL,
    "bbl_id" bigint NOT NULL,
    "periode_waktu" character varying(50) NOT NULL,
    "status_pemeriksaan" boolean DEFAULT false NOT NULL,
    "tanggal_submit" timestamp with time zone,
    "is_verified" boolean DEFAULT false NOT NULL,
    "verified_at" timestamp with time zone,
    "verified_by_kader_id" bigint,
    "status" character varying(50) DEFAULT 'Menunggu verifikasi'::character varying
);


ALTER TABLE "public"."bbl_check" OWNER TO "postgres";


ALTER TABLE "public"."bbl_check" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."bbl_check_id_seq1"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



ALTER TABLE "public"."bbl" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."bbl_id_seq2"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."bidan" (
    "id" integer NOT NULL,
    "penduduk_id" integer NOT NULL,
    "no_str" character varying(100),
    "no_sipb" character varying(100),
    "status" character varying(20) DEFAULT 'aktif'::character varying NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone,
    "desa_id" integer
);


ALTER TABLE "public"."bidan" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."bidan_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."bidan_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."bidan_id_seq" OWNED BY "public"."bidan"."id";



CREATE TABLE IF NOT EXISTS "public"."catatan_pelayanan" (
    "id" integer NOT NULL,
    "anak_id" integer NOT NULL,
    "tenaga_kesehatan_id" integer NOT NULL,
    "tanggal_periksa" timestamp with time zone NOT NULL,
    "tanggal_kembali" timestamp with time zone NOT NULL,
    "catatan_pelayanan" "text" NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."catatan_pelayanan" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."catatan_pelayanan_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."catatan_pelayanan_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."catatan_pelayanan_id_seq" OWNED BY "public"."catatan_pelayanan"."id";



CREATE TABLE IF NOT EXISTS "public"."catatan_pelayanan_kehamilan" (
    "id_catatan" integer NOT NULL,
    "kehamilan_id" integer NOT NULL,
    "trimester" smallint NOT NULL,
    "tanggal_periksa_stamp_paraf" "date",
    "keluhan_pemeriksaan_tindakan_saran" "text" DEFAULT ''::"text" NOT NULL,
    "tanggal_kembali" "date",
    CONSTRAINT "catatan_pelayanan_kehamilan_trimester_check" CHECK (("trimester" = ANY (ARRAY[1, 2, 3])))
);


ALTER TABLE "public"."catatan_pelayanan_kehamilan" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."catatan_pelayanan_kehamilan_id_catatan_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."catatan_pelayanan_kehamilan_id_catatan_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."catatan_pelayanan_kehamilan_id_catatan_seq" OWNED BY "public"."catatan_pelayanan_kehamilan"."id_catatan";



CREATE TABLE IF NOT EXISTS "public"."catatan_pelayanan_nifas" (
    "id_catatan_nifas" integer NOT NULL,
    "kehamilan_id" integer,
    "kunjungan_ke" "text",
    "tanggal_periksa_stamp_paraf" timestamp with time zone,
    "keluhan_pemeriksaan_tindakan_saran" "text",
    "tanggal_kembali" timestamp with time zone
);


ALTER TABLE "public"."catatan_pelayanan_nifas" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."catatan_pelayanan_nifas_id_catatan_nifas_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."catatan_pelayanan_nifas_id_catatan_nifas_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."catatan_pelayanan_nifas_id_catatan_nifas_seq" OWNED BY "public"."catatan_pelayanan_nifas"."id_catatan_nifas";



CREATE TABLE IF NOT EXISTS "public"."catatan_pelayanan_trimester" (
    "id" bigint NOT NULL,
    "kehamilan_id" integer,
    "tanggal_periksa_stamp_paraf" "date",
    "keluhan_pemeriksaan_tindakan_saran" "text",
    "tanggal_kembali" "date",
    "kategori_trimester_id" bigint
);


ALTER TABLE "public"."catatan_pelayanan_trimester" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."catatan_pelayanan_trimester_1" (
    "id_catatan" integer NOT NULL,
    "kehamilan_id" integer NOT NULL,
    "tanggal_periksa_stamp_paraf" "date",
    "keluhan_pemeriksaan_tindakan_saran" "text",
    "tanggal_kembali" "date"
);


ALTER TABLE "public"."catatan_pelayanan_trimester_1" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."catatan_pelayanan_trimester_1_id_catatan_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."catatan_pelayanan_trimester_1_id_catatan_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."catatan_pelayanan_trimester_1_id_catatan_seq" OWNED BY "public"."catatan_pelayanan_trimester_1"."id_catatan";



CREATE TABLE IF NOT EXISTS "public"."catatan_pelayanan_trimester_2" (
    "id_catatan_t2" integer NOT NULL,
    "kehamilan_id" integer NOT NULL,
    "tanggal_periksa_stamp_paraf" "date",
    "keluhan_pemeriksaan_tindakan_saran" "text",
    "tanggal_kembali" "date"
);


ALTER TABLE "public"."catatan_pelayanan_trimester_2" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."catatan_pelayanan_trimester_2_id_catatan_t2_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."catatan_pelayanan_trimester_2_id_catatan_t2_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."catatan_pelayanan_trimester_2_id_catatan_t2_seq" OWNED BY "public"."catatan_pelayanan_trimester_2"."id_catatan_t2";



CREATE TABLE IF NOT EXISTS "public"."catatan_pelayanan_trimester_3" (
    "id_catatan_t3" integer NOT NULL,
    "kehamilan_id" integer NOT NULL,
    "tanggal_periksa_stamp_paraf" "date",
    "keluhan_pemeriksaan_tindakan_saran" "text",
    "tanggal_kembali" "date"
);


ALTER TABLE "public"."catatan_pelayanan_trimester_3" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."catatan_pelayanan_trimester_3_id_catatan_t3_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."catatan_pelayanan_trimester_3_id_catatan_t3_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."catatan_pelayanan_trimester_3_id_catatan_t3_seq" OWNED BY "public"."catatan_pelayanan_trimester_3"."id_catatan_t3";



ALTER TABLE "public"."catatan_pelayanan_trimester" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."catatan_pelayanan_trimester_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."catatan_pertumbuhan" (
    "id" integer NOT NULL,
    "anak_id" integer NOT NULL,
    "tgl_ukur" "date" NOT NULL,
    "berat_badan" numeric(5,2),
    "tinggi_badan" numeric(5,2),
    "lingkar_kepala" numeric(5,2),
    "hasil_lila" numeric(5,2),
    "imt" numeric(5,2),
    "status_bb_u" character varying,
    "status_tb_u" character varying,
    "status_imt_u" character varying,
    "status_bb_tb" character varying,
    "status_lk_u" character varying,
    "z_score_bb_u" numeric(5,2),
    "z_score_tb_u" numeric(5,2),
    "z_score_imt_u" numeric(5,2),
    "z_score_bb_tb" numeric(5,2),
    "z_score_lk_u" numeric(5,2),
    "usia_ukur_bulan" bigint NOT NULL,
    "catatan_nakes" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."catatan_pertumbuhan" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."catatan_pertumbuhan_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."catatan_pertumbuhan_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."catatan_pertumbuhan_id_seq" OWNED BY "public"."catatan_pertumbuhan"."id";



CREATE TABLE IF NOT EXISTS "public"."checklist_pemantauan_ibu_nifas" (
    "id" integer NOT NULL,
    "kehamilan_id" integer NOT NULL,
    "hari_nifas" integer NOT NULL,
    "pemeriksaan_nifas" boolean DEFAULT false,
    "konsumsi_vitamin_a" boolean DEFAULT false,
    "pemenuhan_gizi" boolean DEFAULT false,
    "demam_lebih_38" boolean DEFAULT false,
    "sakit_kepala" boolean DEFAULT false,
    "pandangan_kabur" boolean DEFAULT false,
    "nyeri_ulu_hati" boolean DEFAULT false,
    "masalah_kesehatan_jiwa" boolean DEFAULT false,
    "jantung_berdebar" boolean DEFAULT false,
    "cairan_jalan_lahir" boolean DEFAULT false,
    "napas_pendek" boolean DEFAULT false,
    "payudara_bermasalah" boolean DEFAULT false,
    "gangguan_bak" boolean DEFAULT false,
    "kelamin_bermasalah" boolean DEFAULT false,
    "darah_nifas_berbau" boolean DEFAULT false,
    "pendarahan_berat" boolean DEFAULT false,
    "keputihan" boolean DEFAULT false,
    "keluhan" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone,
    "nama_kader" character varying(255) DEFAULT ''::character varying,
    "tanggal_verifikasi" "date"
);


ALTER TABLE "public"."checklist_pemantauan_ibu_nifas" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."checklist_pemantauan_ibu_nifas_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."checklist_pemantauan_ibu_nifas_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."checklist_pemantauan_ibu_nifas_id_seq" OWNED BY "public"."checklist_pemantauan_ibu_nifas"."id";



CREATE TABLE IF NOT EXISTS "public"."desa" (
    "id" integer NOT NULL,
    "kecamatan" character varying(120),
    "kabupaten" character varying(120),
    "provinsi" character varying(120),
    "nama_desa" character varying(120) NOT NULL,
    "kode_desa" character varying(50) NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "keterangan" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."desa" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."desa_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."desa_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."desa_id_seq" OWNED BY "public"."desa"."id";



CREATE TABLE IF NOT EXISTS "public"."detail_lingkungan" (
    "id" integer NOT NULL,
    "lembar_lingkungan_id" integer NOT NULL,
    "indikator_lingkungan_id" integer NOT NULL,
    "is_ok" boolean NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone
);


ALTER TABLE "public"."detail_lingkungan" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."detail_lingkungan_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."detail_lingkungan_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."detail_lingkungan_id_seq" OWNED BY "public"."detail_lingkungan"."id";



CREATE TABLE IF NOT EXISTS "public"."detail_pelayanan_imunisasi" (
    "id" integer NOT NULL,
    "kunjungan_imunisasi_id" integer NOT NULL,
    "jenis_pelayanan_id" integer NOT NULL,
    "keterangan" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."detail_pelayanan_imunisasi" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."detail_pelayanan_imunisasi_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."detail_pelayanan_imunisasi_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."detail_pelayanan_imunisasi_id_seq" OWNED BY "public"."detail_pelayanan_imunisasi"."id";



CREATE TABLE IF NOT EXISTS "public"."detail_pelayanan_neonatus" (
    "id" integer NOT NULL,
    "neonatus_id" integer NOT NULL,
    "jenis_pelayanan_id" integer NOT NULL,
    "nilai" "text" NOT NULL,
    "keterangan" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."detail_pelayanan_neonatus" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."detail_pelayanan_neonatus_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."detail_pelayanan_neonatus_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."detail_pelayanan_neonatus_id_seq" OWNED BY "public"."detail_pelayanan_neonatus"."id";



CREATE TABLE IF NOT EXISTS "public"."detail_pelayanan_vitamin" (
    "id" integer NOT NULL,
    "kunjungan_vitamin_id" integer NOT NULL,
    "jenis_pelayanan_id" integer NOT NULL,
    "keterangan" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."detail_pelayanan_vitamin" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."detail_pelayanan_vitamin_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."detail_pelayanan_vitamin_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."detail_pelayanan_vitamin_id_seq" OWNED BY "public"."detail_pelayanan_vitamin"."id";



CREATE TABLE IF NOT EXISTS "public"."detail_pemantauan" (
    "id" bigint NOT NULL,
    "lembar_pemantauan_id" bigint NOT NULL,
    "kategori_tanda_sakit_id" bigint NOT NULL,
    "is_terjadi" boolean NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."detail_pemantauan" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."detail_pemantauan_ibu" (
    "id" integer NOT NULL,
    "lembar_pemantauan_ibu_id" integer NOT NULL,
    "kategori_pemantauan_id" integer NOT NULL,
    "is_terjadi" boolean NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."detail_pemantauan_ibu" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."detail_pemantauan_ibu_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."detail_pemantauan_ibu_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."detail_pemantauan_ibu_id_seq" OWNED BY "public"."detail_pemantauan_ibu"."id";



CREATE SEQUENCE IF NOT EXISTS "public"."detail_pemantauan_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."detail_pemantauan_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."detail_pemantauan_id_seq" OWNED BY "public"."detail_pemantauan"."id";



CREATE TABLE IF NOT EXISTS "public"."deteksi_dini_penyimpangan" (
    "id" integer NOT NULL,
    "anak_id" integer NOT NULL,
    "tenaga_kesehatan_id" integer NOT NULL,
    "bulan_ke" bigint NOT NULL,
    "tanggal" timestamp with time zone NOT NULL,
    "b_bper_u" character varying(10) NOT NULL,
    "b_bper_tb" character varying(10) NOT NULL,
    "t_bper_u" character varying(10) NOT NULL,
    "l_kper_u" character varying(10) NOT NULL,
    "lila" character varying(10) NOT NULL,
    "kpsp" character varying(10) NOT NULL,
    "tdd" character varying(5) NOT NULL,
    "tdl" character varying(5) NOT NULL,
    "kmpe" character varying(5) NOT NULL,
    "mchat_revised" character varying(5) NOT NULL,
    "actrs" character varying(5) NOT NULL,
    "hasil_pkat" "text" NOT NULL,
    "tindakan" "text" NOT NULL,
    "kunjungan_ulang" timestamp with time zone NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."deteksi_dini_penyimpangan" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."deteksi_dini_penyimpangan_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."deteksi_dini_penyimpangan_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."deteksi_dini_penyimpangan_id_seq" OWNED BY "public"."deteksi_dini_penyimpangan"."id";



CREATE TABLE IF NOT EXISTS "public"."dosis_vaksin" (
    "id" bigint NOT NULL,
    "nama_dosis" "text",
    "id_vaksin" bigint,
    "jumlah_dosis" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."dosis_vaksin" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."dosis_vaksin_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."dosis_vaksin_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."dosis_vaksin_id_seq" OWNED BY "public"."dosis_vaksin"."id";



CREATE TABLE IF NOT EXISTS "public"."dusun" (
    "id" bigint NOT NULL,
    "nama_dusun" "text",
    "desa_id" bigint
);


ALTER TABLE "public"."dusun" OWNER TO "postgres";


ALTER TABLE "public"."dusun" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."dusun_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."edukasi_imd" (
    "id" integer NOT NULL,
    "judul" character varying(255) NOT NULL,
    "isi" "text",
    "manfaat" "text",
    "langkah" "text",
    "gambar_url" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone
);


ALTER TABLE "public"."edukasi_imd" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."edukasi_imd_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."edukasi_imd_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."edukasi_imd_id_seq" OWNED BY "public"."edukasi_imd"."id";



CREATE TABLE IF NOT EXISTS "public"."edukasi_informasi_umum" (
    "id" integer NOT NULL,
    "tipe" character varying(20) NOT NULL,
    "judul" character varying(255) NOT NULL,
    "umur_target" character varying(50),
    "durasi_baca" character varying(30),
    "ringkasan" "text",
    "konten" "text" NOT NULL,
    "yang_perlu_diingat" "text",
    "thumbnail_url" "text",
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."edukasi_informasi_umum" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."edukasi_informasi_umum_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."edukasi_informasi_umum_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."edukasi_informasi_umum_id_seq" OWNED BY "public"."edukasi_informasi_umum"."id";



CREATE TABLE IF NOT EXISTS "public"."edukasi_kesehatan_mental" (
    "id" integer NOT NULL,
    "judul" character varying(255) NOT NULL,
    "isi" "text",
    "tanda_gejala" "text",
    "solusi" "text",
    "gambar_url" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone
);


ALTER TABLE "public"."edukasi_kesehatan_mental" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."edukasi_kesehatan_mental_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."edukasi_kesehatan_mental_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."edukasi_kesehatan_mental_id_seq" OWNED BY "public"."edukasi_kesehatan_mental"."id";



CREATE TABLE IF NOT EXISTS "public"."edukasi_menyusui_asi" (
    "id" integer NOT NULL,
    "judul" character varying(255) NOT NULL,
    "isi" "text",
    "manfaat_asi" "text",
    "cara" "text",
    "masalah" "text",
    "solusi" "text",
    "gambar_url" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone
);


ALTER TABLE "public"."edukasi_menyusui_asi" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."edukasi_menyusui_asi_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."edukasi_menyusui_asi_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."edukasi_menyusui_asi_id_seq" OWNED BY "public"."edukasi_menyusui_asi"."id";



CREATE TABLE IF NOT EXISTS "public"."edukasi_perawatan_anak" (
    "id" integer NOT NULL,
    "judul" character varying(255) NOT NULL,
    "gambar_url" "text",
    "isi_konten" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone,
    "rentang_usia" character varying(50)
);


ALTER TABLE "public"."edukasi_perawatan_anak" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."edukasi_perawatan_anak_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."edukasi_perawatan_anak_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."edukasi_perawatan_anak_id_seq" OWNED BY "public"."edukasi_perawatan_anak"."id";



CREATE TABLE IF NOT EXISTS "public"."edukasi_pola_asuh" (
    "id" integer NOT NULL,
    "judul" character varying(255) NOT NULL,
    "gambar_url" "text",
    "isi" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "rentang_usia" character varying(50)
);


ALTER TABLE "public"."edukasi_pola_asuh" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."edukasi_pola_asuh_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."edukasi_pola_asuh_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."edukasi_pola_asuh_id_seq" OWNED BY "public"."edukasi_pola_asuh"."id";



CREATE TABLE IF NOT EXISTS "public"."edukasi_setelah_melahirkan" (
    "id" integer NOT NULL,
    "judul" character varying(255) NOT NULL,
    "gambar_url" "text",
    "isi" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone
);


ALTER TABLE "public"."edukasi_setelah_melahirkan" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."edukasi_setelah_melahirkan_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."edukasi_setelah_melahirkan_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."edukasi_setelah_melahirkan_id_seq" OWNED BY "public"."edukasi_setelah_melahirkan"."id";



CREATE TABLE IF NOT EXISTS "public"."edukasi_tanda_melahirkan" (
    "id" integer NOT NULL,
    "judul" character varying(255) NOT NULL,
    "isi" "text",
    "tanda" "text",
    "tindakan" "text",
    "gambar_url" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone
);


ALTER TABLE "public"."edukasi_tanda_melahirkan" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."edukasi_tanda_melahirkan_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."edukasi_tanda_melahirkan_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."edukasi_tanda_melahirkan_id_seq" OWNED BY "public"."edukasi_tanda_melahirkan"."id";



CREATE TABLE IF NOT EXISTS "public"."edukasi_trimester" (
    "id" integer NOT NULL,
    "trimester" character varying(50),
    "kategori" character varying(100),
    "judul" character varying(255),
    "isi" "text",
    "gambar_url" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone
);


ALTER TABLE "public"."edukasi_trimester" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."edukasi_trimester_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."edukasi_trimester_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."edukasi_trimester_id_seq" OWNED BY "public"."edukasi_trimester"."id";



CREATE TABLE IF NOT EXISTS "public"."evaluasi_kesehatan_ibu" (
    "id" integer NOT NULL,
    "kehamilan_id" integer NOT NULL,
    "nama_dokter" character varying(255),
    "tanggal_periksa" "date",
    "fasilitas_kesehatan" character varying(255),
    "tb_cm" numeric(5,2),
    "bb_kg" numeric(5,2),
    "imt_kategori" character varying(20),
    "lila_cm" numeric(5,2),
    "status_tt1" boolean,
    "status_tt2" boolean,
    "status_tt3" boolean,
    "status_tt4" boolean,
    "status_tt5" boolean,
    "imunisasi_lainnya_covid19" "text",
    "riwayat_alergi" boolean,
    "riwayat_asma" boolean,
    "riwayat_autoimun" boolean,
    "riwayat_diabetes" boolean,
    "riwayat_hepatitis_b" boolean,
    "riwayat_hipertensi" boolean,
    "riwayat_jantung" boolean,
    "riwayat_jiwa" boolean,
    "riwayat_sifilis" boolean,
    "riwayat_tb" boolean,
    "riwayat_kesehatan_lainnya" "text",
    "perilaku_aktivitas_fisik_kurang" boolean,
    "perilaku_alkohol" boolean,
    "perilaku_kosmetik_berbahaya" boolean,
    "perilaku_merokok" boolean,
    "perilaku_obat_teratogenik" boolean,
    "perilaku_pola_makan_berisiko" boolean,
    "perilaku_lainnya" "text",
    "keluarga_alergi" boolean,
    "keluarga_asma" boolean,
    "keluarga_autoimun" boolean,
    "keluarga_diabetes" boolean,
    "keluarga_hepatitis_b" boolean,
    "keluarga_hipertensi" boolean,
    "keluarga_jantung" boolean,
    "keluarga_jiwa" boolean,
    "keluarga_sifilis" boolean,
    "keluarga_tb" boolean,
    "keluarga_lainnya" "text",
    "inspeksi_porsio" character varying(20),
    "inspeksi_uretra" character varying(20),
    "inspeksi_vagina" character varying(20),
    "inspeksi_vulva" character varying(20),
    "inspeksi_fluksus" character varying(10),
    "inspeksi_fluor" character varying(10),
    "created_at" timestamp with time zone
);


ALTER TABLE "public"."evaluasi_kesehatan_ibu" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."evaluasi_kesehatan_ibu_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."evaluasi_kesehatan_ibu_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."evaluasi_kesehatan_ibu_id_seq" OWNED BY "public"."evaluasi_kesehatan_ibu"."id";



CREATE TABLE IF NOT EXISTS "public"."form_aturan_risikos" (
    "id" bigint NOT NULL,
    "form_versi_id" bigint NOT NULL,
    "nama_aturan" character varying(100),
    "kondisi" "jsonb" NOT NULL,
    "kategori_risiko" character varying(50) NOT NULL,
    "prioritas" bigint DEFAULT 0,
    "created_at" timestamp with time zone,
    "rekomendasi" character varying(250)
);


ALTER TABLE "public"."form_aturan_risikos" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."form_aturan_risikos_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."form_aturan_risikos_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."form_aturan_risikos_id_seq" OWNED BY "public"."form_aturan_risikos"."id";



CREATE TABLE IF NOT EXISTS "public"."form_pertanyaans" (
    "id" bigint NOT NULL,
    "form_versi_id" bigint NOT NULL,
    "key" character varying(100) NOT NULL,
    "label" character varying(255),
    "tipe" character varying(20),
    "opsi" "jsonb",
    "satuan" character varying(50),
    "wajib" boolean DEFAULT false,
    "aturan_validasi" "jsonb",
    "urutan" bigint DEFAULT 0,
    "created_at" timestamp with time zone
);


ALTER TABLE "public"."form_pertanyaans" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."form_pertanyaans_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."form_pertanyaans_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."form_pertanyaans_id_seq" OWNED BY "public"."form_pertanyaans"."id";



CREATE TABLE IF NOT EXISTS "public"."form_versis" (
    "id" bigint NOT NULL,
    "kelompok" character varying(20) NOT NULL,
    "tahun" bigint NOT NULL,
    "nama" character varying(100),
    "aktif" boolean DEFAULT false,
    "keterangan" "text",
    "created_at" timestamp with time zone
);


ALTER TABLE "public"."form_versis" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."form_versis_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."form_versis_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."form_versis_id_seq" OWNED BY "public"."form_versis"."id";



CREATE TABLE IF NOT EXISTS "public"."grafik_evaluasi_kehamilan" (
    "id" integer NOT NULL,
    "kehamilan_id" integer NOT NULL,
    "tanggal_bulan_tahun" "date",
    "usia_gestasi_minggu" bigint,
    "tinggi_fundus_uteri_cm" numeric(4,1),
    "denyut_jantung_bayi_x_menit" bigint,
    "tekanan_darah_sistole" bigint,
    "tekanan_darah_diastole" bigint,
    "nadi_per_menit" bigint,
    "gerakan_bayi" character varying(50),
    "urin_protein" character varying(50),
    "urin_reduksi" character varying(50),
    "hemoglobin" numeric(4,1),
    "tablet_tambah_darah" bigint,
    "kalsium" character varying(50),
    "aspirin" character varying(50),
    "penjelasan_hasil_grafik" "text",
    "kategori_risiko" character varying(20),
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone
);


ALTER TABLE "public"."grafik_evaluasi_kehamilan" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."grafik_evaluasi_kehamilan_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."grafik_evaluasi_kehamilan_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."grafik_evaluasi_kehamilan_id_seq" OWNED BY "public"."grafik_evaluasi_kehamilan"."id";



CREATE TABLE IF NOT EXISTS "public"."grafik_peningkatan_bb" (
    "id" integer NOT NULL,
    "kehamilan_id" integer NOT NULL,
    "berat_badan" numeric(4,1),
    "minggu_kehamilan" bigint,
    "penjelasan_hasil_grafik" "text",
    "deviasi" numeric,
    "status" "text"
);


ALTER TABLE "public"."grafik_peningkatan_bb" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."grafik_peningkatan_bb_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."grafik_peningkatan_bb_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."grafik_peningkatan_bb_id_seq" OWNED BY "public"."grafik_peningkatan_bb"."id";



CREATE TABLE IF NOT EXISTS "public"."ibu" (
    "id" integer NOT NULL,
    "penduduk_id" integer NOT NULL,
    "suami_id" integer,
    "gravida" integer,
    "paritas" integer,
    "abortus" integer,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "is_deleted" timestamp with time zone
);


ALTER TABLE "public"."ibu" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."ibu_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."ibu_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."ibu_id_seq" OWNED BY "public"."ibu"."id";



CREATE TABLE IF NOT EXISTS "public"."indikator_lingkungan" (
    "id" integer NOT NULL,
    "kategori_lingkungan_id" integer NOT NULL,
    "pertanyaan" "text" NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."indikator_lingkungan" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."indikator_lingkungan_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."indikator_lingkungan_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."indikator_lingkungan_id_seq" OWNED BY "public"."indikator_lingkungan"."id";



CREATE TABLE IF NOT EXISTS "public"."informasi_umum" (
    "id" integer NOT NULL,
    "tipe" character varying(20) NOT NULL,
    "judul" character varying(255) NOT NULL,
    "umur_target" character varying(50),
    "durasi_baca" character varying(30),
    "ringkasan" "text",
    "konten" "text" NOT NULL,
    "yang_perlu_diingat" "text",
    "thumbnail_url" "text",
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."informasi_umum" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."informasi_umum_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."informasi_umum_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."informasi_umum_id_seq" OWNED BY "public"."informasi_umum"."id";



CREATE TABLE IF NOT EXISTS "public"."jadwal_harian_mpasi" (
    "id" integer NOT NULL,
    "bulan_min" bigint NOT NULL,
    "bulan_max" bigint NOT NULL,
    "waktu" character varying(10) NOT NULL,
    "aktivitas" character varying(100) NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."jadwal_harian_mpasi" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."jadwal_harian_mpasi_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."jadwal_harian_mpasi_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."jadwal_harian_mpasi_id_seq" OWNED BY "public"."jadwal_harian_mpasi"."id";



CREATE TABLE IF NOT EXISTS "public"."jadwal_imunisasi_anak" (
    "id" bigint NOT NULL,
    "id_dosis_vaksin" bigint,
    "tanggal_estimasi" "date",
    "id_anak" bigint,
    "id_status_jadwal" bigint,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone,
    "is_sent_h7" boolean,
    "is_sent_h3" boolean,
    "is_sent_h" boolean
);


ALTER TABLE "public"."jadwal_imunisasi_anak" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."jadwal_imunisasi_anak_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."jadwal_imunisasi_anak_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."jadwal_imunisasi_anak_id_seq" OWNED BY "public"."jadwal_imunisasi_anak"."id";



CREATE TABLE IF NOT EXISTS "public"."jadwal_layanan" (
    "id" integer NOT NULL,
    "posyandu_id" integer,
    "layanan" character varying(255) NOT NULL,
    "tanggal" timestamp with time zone,
    "waktu_mulai" time without time zone,
    "waktu_selesai" time without time zone,
    "keterangan" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."jadwal_layanan" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."jadwal_layanan_dosis_vaksin" (
    "jadwal_layanan_id" integer NOT NULL,
    "dosis_vaksin_id" integer NOT NULL
);


ALTER TABLE "public"."jadwal_layanan_dosis_vaksin" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."jadwal_layanan_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."jadwal_layanan_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."jadwal_layanan_id_seq" OWNED BY "public"."jadwal_layanan"."id";



CREATE TABLE IF NOT EXISTS "public"."jadwal_layanan_vaksin" (
    "jadwal_layanan_id" integer NOT NULL,
    "vaksin_id" integer NOT NULL
);


ALTER TABLE "public"."jadwal_layanan_vaksin" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."jenis_pelayanan" (
    "id" integer NOT NULL,
    "nama" "text" NOT NULL,
    "tipe_input" character varying(20) NOT NULL,
    "group_name" character varying(100),
    "section" character varying(100),
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."jenis_pelayanan" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."jenis_pelayanan_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."jenis_pelayanan_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."jenis_pelayanan_id_seq" OWNED BY "public"."jenis_pelayanan"."id";



CREATE TABLE IF NOT EXISTS "public"."jenis_pelayanan_kategori" (
    "id" integer NOT NULL,
    "jenis_pelayanan_id" integer NOT NULL,
    "kategori_umur_id" integer NOT NULL,
    "periode_id" integer,
    "urutan" bigint NOT NULL,
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."jenis_pelayanan_kategori" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."jenis_pelayanan_kategori_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."jenis_pelayanan_kategori_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."jenis_pelayanan_kategori_id_seq" OWNED BY "public"."jenis_pelayanan_kategori"."id";



CREATE TABLE IF NOT EXISTS "public"."kader" (
    "id" integer NOT NULL,
    "id_penduduk" integer NOT NULL,
    "id_posyandu" bigint,
    "status" character varying(20) DEFAULT 'aktif'::character varying NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."kader" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."kader_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."kader_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."kader_id_seq" OWNED BY "public"."kader"."id";



CREATE TABLE IF NOT EXISTS "public"."kader_posyandu" (
    "id" bigint NOT NULL,
    "user_id" bigint NOT NULL,
    "no_sk" "text",
    "wilayah_binaan" "text" NOT NULL,
    "posyandu_nama" "text",
    "tahun_bergabung" bigint,
    "status_aktif" boolean DEFAULT true,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "is_deleted" timestamp with time zone
);


ALTER TABLE "public"."kader_posyandu" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."kader_posyandu_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."kader_posyandu_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."kader_posyandu_id_seq" OWNED BY "public"."kader_posyandu"."id";



CREATE TABLE IF NOT EXISTS "public"."kartu_keluarga" (
    "id" bigint NOT NULL,
    "no_kk" character varying(20) NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone,
    "tanggal_terbit" timestamp with time zone
);


ALTER TABLE "public"."kartu_keluarga" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."kartu_keluarga_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."kartu_keluarga_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."kartu_keluarga_id_seq" OWNED BY "public"."kartu_keluarga"."id";



CREATE TABLE IF NOT EXISTS "public"."kategori_capaian" (
    "id" bigint NOT NULL,
    "rentang_usia" character varying(50) NOT NULL,
    "pertanyaan_ceklist" "text",
    "aspek" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."kategori_capaian" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."kategori_capaian_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."kategori_capaian_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."kategori_capaian_id_seq" OWNED BY "public"."kategori_capaian"."id";



CREATE TABLE IF NOT EXISTS "public"."kategori_lingkungan" (
    "id" integer NOT NULL,
    "nama" character varying(100) NOT NULL,
    "deskripsi" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."kategori_lingkungan" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."kategori_lingkungan_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."kategori_lingkungan_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."kategori_lingkungan_id_seq" OWNED BY "public"."kategori_lingkungan"."id";



CREATE TABLE IF NOT EXISTS "public"."kategori_pemantauan_ibu" (
    "id" integer NOT NULL,
    "gejala" "text" NOT NULL,
    "deskripsi" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."kategori_pemantauan_ibu" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."kategori_pemantauan_ibu_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."kategori_pemantauan_ibu_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."kategori_pemantauan_ibu_id_seq" OWNED BY "public"."kategori_pemantauan_ibu"."id";



CREATE TABLE IF NOT EXISTS "public"."kategori_status" (
    "id" bigint NOT NULL,
    "nama_kategori" "text"
);


ALTER TABLE "public"."kategori_status" OWNER TO "postgres";


ALTER TABLE "public"."kategori_status" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."kategori_status_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."kategori_tanda_bahaya" (
    "id" integer NOT NULL,
    "tipe_lembar" character varying(10) NOT NULL,
    "gejala" "text" NOT NULL,
    "kategori_usia" character varying(50) NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone,
    CONSTRAINT "chk_kategori_tanda_bahaya_tipe_lembar" CHECK ((("tipe_lembar")::"text" = ANY ((ARRAY['A'::character varying, 'B'::character varying, 'Umum'::character varying])::"text"[])))
);


ALTER TABLE "public"."kategori_tanda_bahaya" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."kategori_tanda_bahaya_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."kategori_tanda_bahaya_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."kategori_tanda_bahaya_id_seq" OWNED BY "public"."kategori_tanda_bahaya"."id";



CREATE TABLE IF NOT EXISTS "public"."kategori_tanda_sakit" (
    "id" bigint NOT NULL,
    "rentang_usia_id" bigint NOT NULL,
    "gejala" "text" NOT NULL,
    "deskripsi" "text",
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."kategori_tanda_sakit" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."kategori_tanda_sakit_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."kategori_tanda_sakit_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."kategori_tanda_sakit_id_seq" OWNED BY "public"."kategori_tanda_sakit"."id";



CREATE TABLE IF NOT EXISTS "public"."kategori_trimester" (
    "id" bigint NOT NULL,
    "nama_trimester" "text"
);


ALTER TABLE "public"."kategori_trimester" OWNER TO "postgres";


ALTER TABLE "public"."kategori_trimester" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."kategori_trimester_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."kehadiran_imunisasi" (
    "id" integer NOT NULL,
    "anak_id" integer NOT NULL,
    "bulan_ke" bigint NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."kehadiran_imunisasi" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."kehadiran_imunisasi_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."kehadiran_imunisasi_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."kehadiran_imunisasi_id_seq" OWNED BY "public"."kehadiran_imunisasi"."id";



CREATE TABLE IF NOT EXISTS "public"."kehamilan" (
    "id" integer NOT NULL,
    "ibu_id" integer NOT NULL,
    "gravida" integer,
    "paritas" integer,
    "abortus" integer,
    "hpht" timestamp with time zone,
    "taksiran_persalinan" timestamp with time zone,
    "uk_kehamilan_saat_ini" integer,
    "jarak_kehamilan_sebelumnya" integer,
    "status_kehamilan" "text",
    "bb_awal" numeric,
    "tb" numeric,
    "imt_awal" numeric,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."kehamilan" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."kehamilan_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."kehamilan_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."kehamilan_id_seq" OWNED BY "public"."kehamilan"."id";



CREATE TABLE IF NOT EXISTS "public"."keluhan_anak" (
    "id" integer NOT NULL,
    "anak_id" integer NOT NULL,
    "tanggal" "date" NOT NULL,
    "tanggal_kembali" "date",
    "keluhan" "text" NOT NULL,
    "tindakan" "text",
    "pemeriksa" character varying(100),
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."keluhan_anak" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."keluhan_anak_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."keluhan_anak_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."keluhan_anak_id_seq" OWNED BY "public"."keluhan_anak"."id";



CREATE TABLE IF NOT EXISTS "public"."keterangan_lahir" (
    "id" integer NOT NULL,
    "id_ibu_relasi" integer NOT NULL,
    "nomor_surat" character varying(100),
    "hari_lahir" character varying(20),
    "tanggal_lahir" "date",
    "pukul_lahir" timestamp with time zone,
    "jenis_kelamin" character varying(50),
    "jenis_kelahiran" character varying(100),
    "anak_ke" bigint,
    "usia_gestasi_minggu" bigint,
    "berat_lahir_gram" bigint,
    "panjang_badan_cm" bigint,
    "lingkar_kepala_cm" bigint,
    "lokasi_persalinan" "text",
    "alamat_lokasi_persalinan" "text",
    "nama_bayi_diberi_nama" "text",
    "nama_ibu" character varying(255),
    "umur_ibu" bigint,
    "nik_ibu" character varying(20),
    "nama_ayah" character varying(255),
    "nik_ayah" character varying(20),
    "pekerjaan_orang_tua" character varying(255),
    "alamat_orang_tua" "text",
    "rwrt_orang_tua" character varying(20),
    "kecamatan_orang_tua" character varying(100),
    "kab_kota_orang_tua" character varying(100),
    "tanggal_surat" "date",
    "nama_saksi1" "text",
    "nama_saksi2" "text",
    "nama_penolong_kelahiran" "text",
    "created_at" timestamp with time zone,
    "ringkasan_pelayanan_persalinan_id" integer
);


ALTER TABLE "public"."keterangan_lahir" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."keterangan_lahir_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."keterangan_lahir_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."keterangan_lahir_id_seq" OWNED BY "public"."keterangan_lahir"."id";



CREATE TABLE IF NOT EXISTS "public"."kunjungan_anak" (
    "id" integer NOT NULL,
    "anak_id" integer NOT NULL,
    "tanggal" timestamp with time zone NOT NULL,
    "kategori_umur_id" integer NOT NULL,
    "periode_id" integer NOT NULL,
    "lokasi" "text" NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."kunjungan_anak" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."kunjungan_anak_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."kunjungan_anak_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."kunjungan_anak_id_seq" OWNED BY "public"."kunjungan_anak"."id";



CREATE TABLE IF NOT EXISTS "public"."kunjungan_gizi" (
    "id" integer NOT NULL,
    "anak_id" integer NOT NULL,
    "bulanke" bigint NOT NULL,
    "tanggal" timestamp with time zone NOT NULL,
    "tenaga_kesehatan_id" integer NOT NULL,
    "lokasi" "text" NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone,
    "obat_cacing" boolean,
    "jenis_pemberian_susu" character varying(30),
    "masih_menyusui" boolean,
    "menggunakan_formula" boolean,
    "alasan_formula" "text",
    "usia_mulai_mpasi" integer
);


ALTER TABLE "public"."kunjungan_gizi" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."kunjungan_gizi_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."kunjungan_gizi_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."kunjungan_gizi_id_seq" OWNED BY "public"."kunjungan_gizi"."id";



CREATE TABLE IF NOT EXISTS "public"."kunjungan_imunisasi" (
    "id" bigint NOT NULL,
    "id_status_kunjungan" bigint,
    "tanggal_kunjungan" timestamp with time zone,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "id_jadwal_imunisasi" bigint,
    "deleted_at" timestamp with time zone,
    "status" bigint
);


ALTER TABLE "public"."kunjungan_imunisasi" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."kunjungan_imunisasi_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."kunjungan_imunisasi_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."kunjungan_imunisasi_id_seq" OWNED BY "public"."kunjungan_imunisasi"."id";



CREATE TABLE IF NOT EXISTS "public"."kunjungan_vitamin" (
    "id" integer NOT NULL,
    "anak_id" integer NOT NULL,
    "tanggal" timestamp with time zone NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."kunjungan_vitamin" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."kunjungan_vitamin_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."kunjungan_vitamin_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."kunjungan_vitamin_id_seq" OWNED BY "public"."kunjungan_vitamin"."id";



CREATE TABLE IF NOT EXISTS "public"."laporan_anaks" (
    "nik" "text",
    "nama_anak" "text",
    "nama_ibu" "text",
    "nama_ayah" "text",
    "tanggal_lahir" timestamp with time zone,
    "usia" "text",
    "berat_lahir_kg" numeric,
    "tinggi_lahir_cm" numeric,
    "lila" numeric,
    "golongan_darah" "text",
    "kecamatan" "text",
    "desa" "text",
    "no_kk" "text"
);


ALTER TABLE "public"."laporan_anaks" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."laporan_ibus" (
    "nik" "text",
    "nama_ibu" "text",
    "nama_suami" "text",
    "tanggal_lahir" timestamp with time zone,
    "hpht" timestamp with time zone,
    "hpl" timestamp with time zone,
    "usia_kehamilan" integer,
    "trimester" "text",
    "gravida" integer,
    "paritas" integer,
    "abortus" integer,
    "bb_awal" numeric,
    "tinggi_badan" numeric,
    "imt" numeric,
    "lila" numeric,
    "tekanan_darah" "text",
    "sistole" integer,
    "diastole" integer,
    "tinggi_fundus" numeric,
    "hb" numeric,
    "golongan_darah" "text",
    "status_imunisasi" "text",
    "tripel_eliminasi" "text",
    "kunjungan_anc" integer,
    "tindakan" "text",
    "kecamatan" "text",
    "desa" "text"
);


ALTER TABLE "public"."laporan_ibus" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."lembar_lingkungan" (
    "id" integer NOT NULL,
    "ibu_id" integer NOT NULL,
    "tanggal_periksa" "date" NOT NULL,
    "pemeriksa" character varying(100),
    "catatan" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone
);


ALTER TABLE "public"."lembar_lingkungan" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."lembar_lingkungan_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."lembar_lingkungan_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."lembar_lingkungan_id_seq" OWNED BY "public"."lembar_lingkungan"."id";



CREATE TABLE IF NOT EXISTS "public"."lembar_pemantauan" (
    "id" bigint NOT NULL,
    "anak_id" bigint NOT NULL,
    "rentang_usia_id" bigint NOT NULL,
    "periode_waktu" bigint NOT NULL,
    "tanggal_periksa" "date" NOT NULL,
    "nama_pemeriksa" character varying(100),
    "status" character varying(50) NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."lembar_pemantauan" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."lembar_pemantauan_ibu" (
    "id" integer NOT NULL,
    "ibu_id" integer NOT NULL,
    "periode_waktu" bigint NOT NULL,
    "tanggal_periksa" "date" NOT NULL,
    "pemeriksa" character varying(100),
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."lembar_pemantauan_ibu" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."lembar_pemantauan_ibu_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."lembar_pemantauan_ibu_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."lembar_pemantauan_ibu_id_seq" OWNED BY "public"."lembar_pemantauan_ibu"."id";



CREATE SEQUENCE IF NOT EXISTS "public"."lembar_pemantauan_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."lembar_pemantauan_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."lembar_pemantauan_id_seq" OWNED BY "public"."lembar_pemantauan"."id";



CREATE TABLE IF NOT EXISTS "public"."log_ttd_mms" (
    "id" integer NOT NULL,
    "kehamilan_id" integer NOT NULL,
    "bulan_ke" integer NOT NULL,
    "hari_ke" integer NOT NULL,
    "sudah_diminum" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."log_ttd_mms" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."log_ttd_mms_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."log_ttd_mms_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."log_ttd_mms_id_seq" OWNED BY "public"."log_ttd_mms"."id";



CREATE TABLE IF NOT EXISTS "public"."master_imunisasi" (
    "id" bigint NOT NULL,
    "nama_vaksin" "text",
    "usia_rekomendasi_bulan" bigint,
    "deskripsi_manfaat" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "is_deleted" timestamp with time zone
);


ALTER TABLE "public"."master_imunisasi" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."master_imunisasi_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."master_imunisasi_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."master_imunisasi_id_seq" OWNED BY "public"."master_imunisasi"."id";



CREATE TABLE IF NOT EXISTS "public"."master_standar_antropometri" (
    "id" bigint NOT NULL,
    "parameter" character varying NOT NULL,
    "jenis_kelamin" character varying(15) NOT NULL,
    "nilai_sumbu_x" numeric(5,2) NOT NULL,
    "sd_3_neg" numeric(5,2),
    "sd_2_neg" numeric(5,2),
    "sd_1_neg" numeric(5,2),
    "median" numeric(5,2),
    "sd_1_pos" numeric(5,2),
    "sd_2_pos" numeric(5,2),
    "sd_3_pos" numeric(5,2),
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone,
    CONSTRAINT "chk_master_standar_antropometri_jenis_kelamin" CHECK ((("jenis_kelamin")::"text" = ANY ((ARRAY['Laki-laki'::character varying, 'Perempuan'::character varying])::"text"[])))
);


ALTER TABLE "public"."master_standar_antropometri" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."master_standar_antropometri_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."master_standar_antropometri_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."master_standar_antropometri_id_seq" OWNED BY "public"."master_standar_antropometri"."id";



CREATE TABLE IF NOT EXISTS "public"."materi_mpasi" (
    "id" integer NOT NULL,
    "judul" character varying(255) NOT NULL,
    "konten" "text" NOT NULL,
    "gambar_url" "text",
    "bulan_min" bigint,
    "bulan_max" bigint,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."materi_mpasi" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."materi_mpasi_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."materi_mpasi_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."materi_mpasi_id_seq" OWNED BY "public"."materi_mpasi"."id";



CREATE TABLE IF NOT EXISTS "public"."mp_asi" (
    "id" integer NOT NULL,
    "kunjungan_gizi_id" integer NOT NULL,
    "diberikan_mpasi" boolean NOT NULL,
    "variasi_mpasi" "jsonb",
    "jumlahmakan_perporsi" "text",
    "frekuensi_makan" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone,
    "diberikan_mp_asi" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."mp_asi" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."mp_asi_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."mp_asi_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."mp_asi_id_seq" OWNED BY "public"."mp_asi"."id";



CREATE TABLE IF NOT EXISTS "public"."pelayanan_ibu_nifas" (
    "id" integer NOT NULL,
    "kehamilan_id" integer NOT NULL,
    "kunjungan_ke" character varying(10),
    "tanggal_periksa" "date",
    "tanda_vital_tekanan_darah" character varying(20),
    "tanda_vital_suhu_tubuh" numeric(4,1),
    "pelayanan_involusi_uteri" "text",
    "pelayanan_cairan_pervaginam" "text",
    "pelayanan_periksa_jalan_lahir" "text",
    "pelayanan_periksa_payudara" "text",
    "pelayanan_asi_ekslusif" character varying(50),
    "pemberian_kapsul_vitamin_a" boolean,
    "pemberian_tablet_tambah_darah_jumlah" bigint,
    "pelayanan_skrining_depresi_nifas" "text",
    "pelayanan_kontrasepsi_pasca_persalinan" "text",
    "pelayanan_penanganan_risiko_malaria" "text",
    "komplikasi_nifas" "text",
    "tindakan_saran" "text",
    "nama_pemeriksa_paraf" character varying(255),
    "tanggal_kembali" "date",
    "created_at" timestamp with time zone
);


ALTER TABLE "public"."pelayanan_ibu_nifas" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."pelayanan_ibu_nifas_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."pelayanan_ibu_nifas_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."pelayanan_ibu_nifas_id_seq" OWNED BY "public"."pelayanan_ibu_nifas"."id";



CREATE TABLE IF NOT EXISTS "public"."pemantauan_ibu_hamil" (
    "id" integer NOT NULL,
    "kehamilan_id" integer NOT NULL,
    "minggu_kehamilan" integer NOT NULL,
    "demam_lebih2_hari" boolean DEFAULT false NOT NULL,
    "sakit_kepala" boolean DEFAULT false NOT NULL,
    "cemas_berlebih" boolean DEFAULT false NOT NULL,
    "resiko_tb" boolean DEFAULT false NOT NULL,
    "gerakan_bayi_kurang" boolean DEFAULT false NOT NULL,
    "nyeri_perut" boolean DEFAULT false NOT NULL,
    "cairan_jalan_lahir" boolean DEFAULT false NOT NULL,
    "masalah_kemaluan" boolean DEFAULT false NOT NULL,
    "diare_berulang" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone,
    "nama_kader" character varying(255) DEFAULT ''::character varying,
    "tanggal_verifikasi" "date"
);


ALTER TABLE "public"."pemantauan_ibu_hamil" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."pemantauan_ibu_hamil_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."pemantauan_ibu_hamil_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."pemantauan_ibu_hamil_id_seq" OWNED BY "public"."pemantauan_ibu_hamil"."id";



CREATE TABLE IF NOT EXISTS "public"."pemantauan_indikator" (
    "id" integer NOT NULL,
    "kategori_usia" character varying(50) NOT NULL,
    "deskripsi" "text" NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "is_deleted" timestamp with time zone
);


ALTER TABLE "public"."pemantauan_indikator" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."pemantauan_indikator_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."pemantauan_indikator_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."pemantauan_indikator_id_seq" OWNED BY "public"."pemantauan_indikator"."id";



CREATE TABLE IF NOT EXISTS "public"."pemeriksaan_anak" (
    "id" integer NOT NULL,
    "penduduk_id" integer NOT NULL,
    "tanggal_pemeriksaan" timestamp with time zone NOT NULL,
    "umur" integer,
    "berat_badan" numeric,
    "tinggi_badan" numeric,
    "imt" numeric,
    "status_gizi" character varying(50),
    "kategori_risiko" character varying(50),
    "status_pemantauan" character varying(50),
    "riwayat_penyakit" "text",
    "catatan_khusus" "text",
    "pemeriksa_id" integer,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."pemeriksaan_anak" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."pemeriksaan_anak_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."pemeriksaan_anak_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."pemeriksaan_anak_id_seq" OWNED BY "public"."pemeriksaan_anak"."id";



CREATE TABLE IF NOT EXISTS "public"."pemeriksaan_dewasa" (
    "id" integer NOT NULL,
    "penduduk_id" integer NOT NULL,
    "tanggal_pemeriksaan" timestamp with time zone NOT NULL,
    "umur" integer,
    "berat_badan" numeric,
    "tinggi_badan" numeric,
    "imt" numeric,
    "tekanan_darah" character varying(20),
    "gula_darah" numeric,
    "kolesterol" numeric,
    "kategori_risiko" character varying(50),
    "status_pemantauan" character varying(50),
    "riwayat_penyakit" "text",
    "penyakit_kronis" "text",
    "catatan_khusus" "text",
    "pemeriksa_id" integer,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."pemeriksaan_dewasa" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."pemeriksaan_dewasa_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."pemeriksaan_dewasa_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."pemeriksaan_dewasa_id_seq" OWNED BY "public"."pemeriksaan_dewasa"."id";



CREATE TABLE IF NOT EXISTS "public"."pemeriksaan_dokter_trimester_1" (
    "id_trimester1" integer NOT NULL,
    "kehamilan_id" integer NOT NULL,
    "nama_dokter" character varying(255),
    "tanggal_periksa" "date",
    "konsep_anamnesa_pemeriksaan" "text",
    "gambar_usg" "text",
    "fisik_konjungtiva" character varying(20),
    "fisik_sklera" character varying(20),
    "fisik_kulit" character varying(20),
    "fisik_leher" character varying(20),
    "fisik_gigi_mulut" character varying(20),
    "fisik_tht" character varying(20),
    "fisik_dada_jantung" character varying(20),
    "fisik_dada_paru" character varying(20),
    "fisik_perut" character varying(20),
    "fisik_tungkai" character varying(20),
    "hpht" "date",
    "keteraturan_haid" character varying(20),
    "umur_hamil_hpht_minggu" bigint,
    "hpl_berdasarkan_hpht" "date",
    "umur_hamil_usg_minggu" bigint,
    "hpl_berdasarkan_usg" "date",
    "usg_jumlah_gs" character varying(20),
    "usg_diameter_gs_cm" numeric(5,2),
    "usg_diameter_gs_minggu" bigint,
    "usg_diameter_gs_hari" bigint,
    "usg_jumlah_bayi" character varying(20),
    "usgcrl_cm" numeric(5,2),
    "usgcrl_minggu" bigint,
    "usgcrl_hari" bigint,
    "usg_letak_produk_kehamilan" character varying(50),
    "usg_pulsasi_jantung" character varying(20),
    "usg_kecurigaan_temuan_abnormal" character varying(10),
    "usg_keterangan_temuan_abnormal" "text",
    "created_at" timestamp with time zone
);


ALTER TABLE "public"."pemeriksaan_dokter_trimester_1" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."pemeriksaan_dokter_trimester_1_id_trimester1_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."pemeriksaan_dokter_trimester_1_id_trimester1_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."pemeriksaan_dokter_trimester_1_id_trimester1_seq" OWNED BY "public"."pemeriksaan_dokter_trimester_1"."id_trimester1";



CREATE TABLE IF NOT EXISTS "public"."pemeriksaan_dokter_trimester_3" (
    "id_trimester3" integer NOT NULL,
    "kehamilan_id" integer NOT NULL,
    "nama_dokter" character varying(255),
    "tanggal_periksa" "date",
    "konsep_anamnesa_pemeriksaan" "text",
    "gambar_usg" "text",
    "fisik_konjungtiva" character varying(20),
    "fisik_sklera" character varying(20),
    "fisik_kulit" character varying(20),
    "fisik_leher" character varying(20),
    "fisik_gigi_mulut" character varying(20),
    "fisik_tht" character varying(20),
    "fisik_dada_jantung" character varying(20),
    "fisik_dada_paru" character varying(20),
    "fisik_perut" character varying(20),
    "fisik_tungkai" character varying(20),
    "usg_trimester3_dilakukan" character varying(10),
    "uk_berdasarkan_usg_trimester1_minggu" bigint,
    "uk_berdasarkan_hpht_minggu" bigint,
    "uk_berdasarkan_biometri_usg_trimester3_minggu" bigint,
    "selisih_uk3_minggu_atau_lebih" character varying(10),
    "usg_jumlah_bayi" character varying(20),
    "usg_letak_bayi" character varying(50),
    "usg_presentasi_bayi" character varying(50),
    "usg_keadaan_bayi" character varying(20),
    "usgdj_nilai" bigint,
    "usgdjj_status" character varying(20),
    "usg_lokasi_plasenta" character varying(50),
    "usg_cairan_ketuban_sdp_cm" numeric(5,2),
    "usg_cairan_ketuban_status" character varying(20),
    "biometri_bpd_cm" numeric(5,2),
    "biometri_bpd_minggu" bigint,
    "biometri_hc_cm" numeric(5,2),
    "biometri_hc_minggu" bigint,
    "biometri_ac_cm" numeric(5,2),
    "biometri_ac_minggu" bigint,
    "biometri_fl_cm" numeric(5,2),
    "biometri_fl_minggu" bigint,
    "biometri_efwtbj_gram" bigint,
    "biometri_efwtbj_minggu" bigint,
    "usg_kecurigaan_temuan_abnormal" character varying(10),
    "usg_keterangan_temuan_abnormal" "text",
    "hasil_usg_catatan" "text",
    "tanggal_lab" "date",
    "lab_hemoglobin_hasil" numeric(4,1),
    "lab_hemoglobin_rencana" "text",
    "lab_protein_urin_hasil" bigint,
    "lab_protein_urin_rencana" "text",
    "lab_urin_reduksi_hasil" character varying(20),
    "lab_urin_reduksi_rencana" "text",
    "tanggal_skrining_jiwa" "date",
    "skrining_jiwa_hasil" character varying(10),
    "skrining_jiwa_tindak_lanjut" character varying(20),
    "skrining_jiwa_perlu_rujukan" character varying(10),
    "rencana_konsultasi_gizi" boolean,
    "rencana_konsultasi_kebidanan" boolean,
    "rencana_konsultasi_anak" boolean,
    "rencana_konsultasi_penyakit_dalam" boolean,
    "rencana_konsultasi_neurologi" boolean,
    "rencana_konsultasi_tht" boolean,
    "rencana_konsultasi_psikiatri" boolean,
    "rencana_konsultasi_lain_lain" "text",
    "rencana_proses_melahirkan" character varying(50),
    "rencana_kontrasepsi_akdr" boolean,
    "rencana_kontrasepsi_pil" boolean,
    "rencana_kontrasepsi_suntik" boolean,
    "rencana_kontrasepsi_steril" boolean,
    "rencana_kontrasepsi_mal" boolean,
    "rencana_kontrasepsi_implan" boolean,
    "rencana_kontrasepsi_belum_memilih" boolean,
    "kebutuhan_konseling" character varying(10),
    "penjelasan" "text",
    "kesimpulan_rekomendasi_tempat_melahirkan" character varying(20),
    "created_at" timestamp with time zone
);


ALTER TABLE "public"."pemeriksaan_dokter_trimester_3" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."pemeriksaan_dokter_trimester_3_id_trimester3_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."pemeriksaan_dokter_trimester_3_id_trimester3_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."pemeriksaan_dokter_trimester_3_id_trimester3_seq" OWNED BY "public"."pemeriksaan_dokter_trimester_3"."id_trimester3";



CREATE TABLE IF NOT EXISTS "public"."pemeriksaan_kehamilan" (
    "id_periksa" integer NOT NULL,
    "kehamilan_id" integer NOT NULL,
    "trimester" character varying(10),
    "kunjungan_ke" integer,
    "minggu_kehamilan" integer,
    "tanggal_periksa" "date",
    "tempat_periksa" character varying(255),
    "berat_badan" numeric(5,2),
    "tinggi_badan" numeric(5,2),
    "lingkar_lengan_atas" numeric(5,2),
    "sistole" integer,
    "diastole" integer,
    "tinggi_rahim" numeric(5,2),
    "letak_denyut_jantung_bayi" "text",
    "denyut_jantung_janin" integer,
    "status_imunisasi_tetanus" character varying(50),
    "konseling" "text",
    "skrining_dokter" "text",
    "tablet_tambah_darah" integer,
    "tes_lab_hb" numeric(4,1),
    "tes_golongan_darah" character varying(5),
    "tes_lab_protein_urine" character varying(50),
    "tes_lab_gula_darah" integer,
    "usg" "text",
    "tripel_eliminasi" character varying(100),
    "tata_laksana_kasus" "text",
    "skor_risiko" integer,
    "status_risiko" character varying(20),
    "detail_risiko" "text",
    "created_at" timestamp with time zone
);


ALTER TABLE "public"."pemeriksaan_kehamilan" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."pemeriksaan_kehamilan_id_periksa_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."pemeriksaan_kehamilan_id_periksa_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."pemeriksaan_kehamilan_id_periksa_seq" OWNED BY "public"."pemeriksaan_kehamilan"."id_periksa";



CREATE TABLE IF NOT EXISTS "public"."pemeriksaan_laboratorium_jiwa" (
    "id_lab_jiwa" integer NOT NULL,
    "kehamilan_id" integer NOT NULL,
    "trimester" integer DEFAULT 1 NOT NULL,
    "tanggal_lab" "date",
    "lab_hemoglobin_hasil" numeric(4,1),
    "lab_hemoglobin_rencana_tindak_lanjut" "text",
    "lab_golongan_darah_rhesus_hasil" character varying(20),
    "lab_golongan_darah_rhesus_rencana" "text",
    "lab_gula_darah_sewaktu_hasil" bigint,
    "lab_gula_darah_sewaktu_rencana" "text",
    "lab_hiv_hasil" character varying(20),
    "lab_hiv_rencana" "text",
    "lab_sifilis_hasil" character varying(20),
    "lab_sifilis_rencana" "text",
    "lab_hepatitis_b_hasil" character varying(20),
    "lab_hepatitis_b_rencana" "text",
    "tanggal_skrining_jiwa" "date",
    "skrining_jiwa_hasil" character varying(10),
    "skrining_jiwa_tindak_lanjut" character varying(20),
    "skrining_jiwa_perlu_rujukan" character varying(10),
    "kesimpulan" "text",
    "rekomendasi" "text",
    "created_at" timestamp with time zone
);


ALTER TABLE "public"."pemeriksaan_laboratorium_jiwa" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."pemeriksaan_laboratorium_jiwa_id_lab_jiwa_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."pemeriksaan_laboratorium_jiwa_id_lab_jiwa_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."pemeriksaan_laboratorium_jiwa_id_lab_jiwa_seq" OWNED BY "public"."pemeriksaan_laboratorium_jiwa"."id_lab_jiwa";



CREATE TABLE IF NOT EXISTS "public"."pemeriksaan_lanjutan_trimester_3" (
    "id_lanjutan_t3" integer NOT NULL,
    "kehamilan_id" integer NOT NULL,
    "hasil_usg_catatan" "text",
    "tanggal_lab" "date",
    "lab_hemoglobin_hasil" numeric(4,1),
    "lab_hemoglobin_rencana" "text",
    "lab_protein_urin_hasil" bigint,
    "lab_protein_urin_rencana" "text",
    "lab_urin_reduksi_hasil" character varying(20),
    "lab_urin_reduksi_rencana" "text",
    "tanggal_skrining_jiwa" "date",
    "skrining_jiwa_hasil" character varying(10),
    "skrining_jiwa_tindak_lanjut" character varying(20),
    "skrining_jiwa_perlu_rujukan" character varying(10),
    "rencana_konsultasi_gizi" boolean,
    "rencana_konsultasi_kebidanan" boolean,
    "rencana_konsultasi_anak" boolean,
    "rencana_konsultasi_penyakit_dalam" boolean,
    "rencana_konsultasi_neurologi" boolean,
    "rencana_konsultasi_tht" boolean,
    "rencana_konsultasi_psikiatri" boolean,
    "rencana_konsultasi_lain_lain" "text",
    "rencana_proses_melahirkan" character varying(50),
    "rencana_kontrasepsi_akdr" boolean,
    "rencana_kontrasepsi_pil" boolean,
    "rencana_kontrasepsi_suntik" boolean,
    "rencana_kontrasepsi_steril" boolean,
    "rencana_kontrasepsi_mal" boolean,
    "rencana_kontrasepsi_implan" boolean,
    "rencana_kontrasepsi_belum_memilih" boolean,
    "kebutuhan_konseling" character varying(10),
    "penjelasan" "text",
    "kesimpulan_rekomendasi_tempat_melahirkan" character varying(20),
    "created_at" timestamp with time zone
);


ALTER TABLE "public"."pemeriksaan_lanjutan_trimester_3" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."pemeriksaan_lanjutan_trimester_3_id_lanjutan_t3_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."pemeriksaan_lanjutan_trimester_3_id_lanjutan_t3_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."pemeriksaan_lanjutan_trimester_3_id_lanjutan_t3_seq" OWNED BY "public"."pemeriksaan_lanjutan_trimester_3"."id_lanjutan_t3";



CREATE TABLE IF NOT EXISTS "public"."pemeriksaan_lansia" (
    "id" integer NOT NULL,
    "penduduk_id" integer NOT NULL,
    "tanggal_pemeriksaan" timestamp with time zone NOT NULL,
    "umur" integer,
    "berat_badan" numeric,
    "tinggi_badan" numeric,
    "imt" numeric,
    "tekanan_darah" character varying(20),
    "gula_darah" numeric,
    "kategori_risiko" character varying(50),
    "status_pemantauan" character varying(50),
    "penyakit_kronis" "text",
    "status_kemandirian" character varying(50),
    "riwayat_jatuh" boolean DEFAULT false,
    "catatan_khusus" "text",
    "pemeriksa_id" integer,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."pemeriksaan_lansia" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."pemeriksaan_lansia_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."pemeriksaan_lansia_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."pemeriksaan_lansia_id_seq" OWNED BY "public"."pemeriksaan_lansia"."id";



CREATE TABLE IF NOT EXISTS "public"."pemeriksaan_remaja" (
    "id" integer NOT NULL,
    "penduduk_id" integer NOT NULL,
    "tanggal_pemeriksaan" timestamp with time zone NOT NULL,
    "umur" integer,
    "berat_badan" numeric,
    "tinggi_badan" numeric,
    "imt" numeric,
    "tekanan_darah" character varying(20),
    "kategori_risiko" character varying(50),
    "status_pemantauan" character varying(50),
    "riwayat_penyakit" "text",
    "catatan_khusus" "text",
    "pemeriksa_id" integer,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."pemeriksaan_remaja" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."pemeriksaan_remaja_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."pemeriksaan_remaja_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."pemeriksaan_remaja_id_seq" OWNED BY "public"."pemeriksaan_remaja"."id";



CREATE TABLE IF NOT EXISTS "public"."pemeriksaans" (
    "id" bigint NOT NULL,
    "penduduk_id" bigint NOT NULL,
    "kelompok" character varying(20) NOT NULL,
    "tanggal_pemeriksaan" timestamp with time zone NOT NULL,
    "form_versi_id" bigint NOT NULL,
    "jawaban" "jsonb" NOT NULL,
    "kategori_risiko" character varying(50) NOT NULL,
    "petugas_id" bigint,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone,
    "rekomendasi" character varying(250)
);


ALTER TABLE "public"."pemeriksaans" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."pemeriksaans_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."pemeriksaans_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."pemeriksaans_id_seq" OWNED BY "public"."pemeriksaans"."id";



CREATE TABLE IF NOT EXISTS "public"."penduduk" (
    "id" integer NOT NULL,
    "kartu_keluarga_id" bigint,
    "nik" character varying(30),
    "nama_lengkap" "text" NOT NULL,
    "jenis_kelamin" "text",
    "tanggal_lahir" timestamp with time zone,
    "tempat_lahir" "text",
    "golongan_darah" "text",
    "agama" "text",
    "status_perkawinan" "text",
    "pendidikan_terakhir" "text",
    "pekerjaan" "text",
    "baca_huruf" "text",
    "kedudukan_keluarga" "text",
    "dusun" "text",
    "kecamatan" "text",
    "desa_id" integer,
    "tanggal_penambahan" timestamp with time zone,
    "asal_penduduk" "text",
    "tanggal_pengurangan" timestamp with time zone,
    "tujuan_pindah" "text",
    "tempat_meninggal" "text",
    "keterangan" "text",
    "is_non_ktp" boolean DEFAULT false,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone,
    "telepon" character varying(20)
);


ALTER TABLE "public"."penduduk" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."penduduk_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."penduduk_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."penduduk_id_seq" OWNED BY "public"."penduduk"."id";



CREATE TABLE IF NOT EXISTS "public"."pengguna" (
    "id" integer NOT NULL,
    "nama" character varying(120) NOT NULL,
    "email" character varying(120) NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "kata_sandi" "text" NOT NULL,
    "role_id" integer NOT NULL,
    "penduduk_id" bigint,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "nomor_telepon" character varying(20)
);


ALTER TABLE "public"."pengguna" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."pengguna_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."pengguna_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."pengguna_id_seq" OWNED BY "public"."pengguna"."id";



CREATE TABLE IF NOT EXISTS "public"."pengukuran_lila" (
    "id" integer NOT NULL,
    "anak_id" integer NOT NULL,
    "bulanke" bigint NOT NULL,
    "tanggal" timestamp with time zone NOT NULL,
    "hasil_lila" numeric(5,2) NOT NULL,
    "kategori_risiko" character varying(20) NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."pengukuran_lila" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."pengukuran_lila_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."pengukuran_lila_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."pengukuran_lila_id_seq" OWNED BY "public"."pengukuran_lila"."id";



CREATE TABLE IF NOT EXISTS "public"."penjelasan_hasil_grafik" (
    "id_penjelasan" integer NOT NULL,
    "kehamilan_id" integer NOT NULL,
    "catatan_penjelasan_grafik" "text",
    "created_at" timestamp with time zone
);


ALTER TABLE "public"."penjelasan_hasil_grafik" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."penjelasan_hasil_grafik_id_penjelasan_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."penjelasan_hasil_grafik_id_penjelasan_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."penjelasan_hasil_grafik_id_penjelasan_seq" OWNED BY "public"."penjelasan_hasil_grafik"."id_penjelasan";



CREATE TABLE IF NOT EXISTS "public"."perangkat" (
    "id" bigint NOT NULL,
    "id_pengguna" bigint NOT NULL,
    "fcm_token" "text" NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."perangkat" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."perangkat_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."perangkat_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."perangkat_id_seq" OWNED BY "public"."perangkat"."id";



CREATE TABLE IF NOT EXISTS "public"."perawatan" (
    "id" bigint NOT NULL,
    "anak_id" integer,
    "kategori_capaian_id" bigint,
    "jawaban" boolean,
    "tanggal_periksa" timestamp with time zone,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."perawatan" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."perawatan_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."perawatan_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."perawatan_id_seq" OWNED BY "public"."perawatan"."id";



CREATE TABLE IF NOT EXISTS "public"."periksa_gigi" (
    "id" integer NOT NULL,
    "anak_id" integer NOT NULL,
    "bulanke" bigint NOT NULL,
    "tanggal" timestamp with time zone NOT NULL,
    "jumlahgigi" bigint DEFAULT 0 NOT NULL,
    "gigi_berlubang" bigint NOT NULL,
    "status_plak" character varying(10) NOT NULL,
    "resiko_gigi_berlubang" character varying(10) NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."periksa_gigi" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."periksa_gigi_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."periksa_gigi_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."periksa_gigi_id_seq" OWNED BY "public"."periksa_gigi"."id";



CREATE TABLE IF NOT EXISTS "public"."periode_kunjungan" (
    "id" integer NOT NULL,
    "nama" "text" NOT NULL,
    "kategori_umur_id" integer NOT NULL,
    "min_value" bigint NOT NULL,
    "max_value" bigint NOT NULL,
    "unit" character varying(10) NOT NULL,
    "urutan" bigint NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."periode_kunjungan" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."periode_kunjungan_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."periode_kunjungan_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."periode_kunjungan_id_seq" OWNED BY "public"."periode_kunjungan"."id";



CREATE TABLE IF NOT EXISTS "public"."persiapan_melahirkan" (
    "id" integer NOT NULL,
    "kehamilan_id" integer NOT NULL,
    "perkiraan_persalinan" boolean DEFAULT false NOT NULL,
    "pendamping_persalinan" boolean DEFAULT false NOT NULL,
    "dana_persalinan" boolean DEFAULT false NOT NULL,
    "status_jkn" boolean DEFAULT false NOT NULL,
    "faskes_persalinan" boolean DEFAULT false NOT NULL,
    "pendonor_darah" boolean DEFAULT false NOT NULL,
    "transportasi" boolean DEFAULT false NOT NULL,
    "metode_kb" boolean DEFAULT false NOT NULL,
    "program_p4_k" boolean DEFAULT false NOT NULL,
    "dokumen_penting" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."persiapan_melahirkan" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."persiapan_melahirkan_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."persiapan_melahirkan_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."persiapan_melahirkan_id_seq" OWNED BY "public"."persiapan_melahirkan"."id";



CREATE TABLE IF NOT EXISTS "public"."pertumbuhan_Anak" (
    "id" integer NOT NULL,
    "anak_id" integer NOT NULL,
    "bulanke" bigint NOT NULL,
    "beratbadan" numeric(5,2) NOT NULL,
    "panjangbadan" numeric(5,2) NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."pertumbuhan_Anak" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."pertumbuhan_Anak_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."pertumbuhan_Anak_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."pertumbuhan_Anak_id_seq" OWNED BY "public"."pertumbuhan_Anak"."id";



CREATE TABLE IF NOT EXISTS "public"."posyandu" (
    "id" integer NOT NULL,
    "id_puskesmas" integer NOT NULL,
    "nama" character varying(255) NOT NULL,
    "alamat" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."posyandu" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."posyandu_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."posyandu_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."posyandu_id_seq" OWNED BY "public"."posyandu"."id";



CREATE TABLE IF NOT EXISTS "public"."prediksi_stunting" (
    "id" bigint NOT NULL,
    "anak_id" integer NOT NULL,
    "berat_badan" numeric(5,2) NOT NULL,
    "tinggi_badan" numeric(5,2) NOT NULL,
    "lingkar_kepala" numeric(5,2) NOT NULL,
    "hasil_lila" numeric(5,2) NOT NULL,
    "usia_ukur_bulan" bigint NOT NULL,
    "risk_percentage" numeric(5,2) NOT NULL,
    "classification" character varying(20) NOT NULL,
    "confidence" numeric(5,2),
    "status_prediksi" character varying(30),
    "z_score_tbu" numeric(5,2),
    "status_tbu" character varying(20),
    "rekomendasi" "text",
    "catatan" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."prediksi_stunting" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."prediksi_stunting_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."prediksi_stunting_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."prediksi_stunting_id_seq" OWNED BY "public"."prediksi_stunting"."id";



CREATE TABLE IF NOT EXISTS "public"."proses_melahirkan" (
    "id" integer NOT NULL,
    "kehamilan_id" integer NOT NULL,
    "tanda_persalinan" boolean DEFAULT false NOT NULL,
    "proses_melahirkan" boolean DEFAULT false NOT NULL,
    "hak_ibu_pendamping" boolean DEFAULT false NOT NULL,
    "hak_ibu_posisi_melahirkan" boolean DEFAULT false NOT NULL,
    "mulas" boolean DEFAULT false NOT NULL,
    "teknik_mengurangi_nyeri" boolean DEFAULT false NOT NULL,
    "imd_kontak_kulit" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."proses_melahirkan" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."proses_melahirkan_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."proses_melahirkan_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."proses_melahirkan_id_seq" OWNED BY "public"."proses_melahirkan"."id";



CREATE TABLE IF NOT EXISTS "public"."puskesmas" (
    "id" bigint NOT NULL,
    "nama" "text",
    "alamat" "text",
    "no_telepon" character varying,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."puskesmas" OWNER TO "postgres";


ALTER TABLE "public"."puskesmas" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."puskesmas_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."rencana_persalinan" (
    "id_rencana_persalinan" integer NOT NULL,
    "kehamilan_id" integer NOT NULL,
    "nama_ibu_pernyataan" character varying(255),
    "alamat_ibu_pernyataan" "text",
    "perkiraan_bulan_persalinan" character varying(20),
    "perkiraan_tahun_persalinan" bigint,
    "fasyankes1_nama_tenaga" character varying(255),
    "fasyankes1_nama_fasilitas" character varying(255),
    "fasyankes2_nama_tenaga" character varying(255),
    "fasyankes2_nama_fasilitas" character varying(255),
    "sumber_dana_persalinan" character varying(255),
    "kendaraan1_nama" character varying(255),
    "kendaraan1_hp" character varying(20),
    "kendaraan2_nama" character varying(255),
    "kendaraan2_hp" character varying(20),
    "kendaraan3_nama" character varying(255),
    "kendaraan3_hp" character varying(20),
    "metode_kontrasepsi_pilihan" character varying(255),
    "donor_golongan_darah" character varying(5),
    "donor_rhesus" character varying(10),
    "donor1_nama" character varying(255),
    "donor1_hp" character varying(20),
    "donor2_nama" character varying(255),
    "donor2_hp" character varying(20),
    "donor3_nama" character varying(255),
    "donor3_hp" character varying(20),
    "donor4_nama" character varying(255),
    "donor4_hp" character varying(20),
    "tanggal_pernyataan" "date",
    "nama_suami_keluarga_ttd" "text",
    "namaibu_ttd" "text",
    "nama_bidan_dokter_ttd" "text",
    "created_at" timestamp with time zone
);


ALTER TABLE "public"."rencana_persalinan" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."rencana_persalinan_id_rencana_persalinan_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."rencana_persalinan_id_rencana_persalinan_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."rencana_persalinan_id_rencana_persalinan_seq" OWNED BY "public"."rencana_persalinan"."id_rencana_persalinan";



CREATE TABLE IF NOT EXISTS "public"."rentang_usia" (
    "id" bigint NOT NULL,
    "nama_rentang" character varying(50) NOT NULL,
    "satuan_waktu" character varying(20) NOT NULL,
    "max_periode" bigint NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone
);


ALTER TABLE "public"."rentang_usia" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."rentang_usia_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."rentang_usia_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."rentang_usia_id_seq" OWNED BY "public"."rentang_usia"."id";



CREATE TABLE IF NOT EXISTS "public"."request_perubahan_imunisasi" (
    "id" integer NOT NULL,
    "id_jadwal_imunisasi" bigint NOT NULL,
    "id_status_request" bigint NOT NULL,
    "alasan" character varying(255) NOT NULL,
    "tanggal_sebelum" character varying(255) NOT NULL,
    "tanggal_baru" character varying(255) NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."request_perubahan_imunisasi" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."request_perubahan_imunisasi_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."request_perubahan_imunisasi_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."request_perubahan_imunisasi_id_seq" OWNED BY "public"."request_perubahan_imunisasi"."id";



CREATE TABLE IF NOT EXISTS "public"."resep_mpasi" (
    "id" integer NOT NULL,
    "bulan_min" bigint NOT NULL,
    "bulan_max" bigint NOT NULL,
    "judul" character varying(255) NOT NULL,
    "tipe" character varying(50) NOT NULL,
    "gambar_url" "text",
    "waktu_persiapan" integer NOT NULL,
    "kalori" integer NOT NULL,
    "porsi" character varying(50) NOT NULL,
    "bahan_bahan" "text"[] NOT NULL,
    "cara_membuat" "text"[] NOT NULL,
    "manfaat" "text",
    "tips" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."resep_mpasi" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."resep_mpasi_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."resep_mpasi_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."resep_mpasi_id_seq" OWNED BY "public"."resep_mpasi"."id";



CREATE TABLE IF NOT EXISTS "public"."ringkasan_pelayanan_persalinan" (
    "id" integer NOT NULL,
    "kehamilan_id" integer NOT NULL,
    "tanggal_melahirkan" "date",
    "pukul_melahirkan" timestamp with time zone,
    "umur_kehamilan_minggu" bigint,
    "penolong_proses_melahirkan" character varying(100),
    "cara_melahirkan" character varying(50),
    "keadaan_ibu" character varying(100),
    "keadaan_ibu_detail_sakit" "text",
    "kb_pasca_melahirkan" character varying(100),
    "keterangan_tambahan_ibu" "text",
    "bayi_anak_ke" bigint,
    "bayi_berat_lahir_gram" numeric,
    "bayi_panjang_badan_cm" numeric,
    "bayi_lingkar_kepala_cm" numeric,
    "bayi_jenis_kelamin" character varying(50),
    "kondisi_bayi_segera_menangis" boolean,
    "kondisi_bayi_menangis_beberapa_saat" boolean,
    "kondisi_bayi_tidak_menangis" boolean,
    "kondisi_bayi_seluruh_tubuh_kemerahan" boolean,
    "kondisi_bayi_anggota_gerak_kebiruan" boolean,
    "kondisi_bayi_seluruh_tubuh_biru" boolean,
    "kondisi_bayi_kelainan_bawaan" boolean,
    "kondisi_bayi_kelainan_bawaan_detail" "text",
    "kondisi_bayi_meninggal" boolean,
    "asuhan_imd1_jam_pertama" boolean,
    "asuhan_suntikan_vitamin_k1" boolean,
    "asuhan_salep_mata_antibiotika" boolean,
    "asuhan_imunisasi_hb0" boolean,
    "keterangan_tambahan_bayi" "text",
    "created_at" timestamp with time zone
);


ALTER TABLE "public"."ringkasan_pelayanan_persalinan" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."ringkasan_pelayanan_persalinan_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."ringkasan_pelayanan_persalinan_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."ringkasan_pelayanan_persalinan_id_seq" OWNED BY "public"."ringkasan_pelayanan_persalinan"."id";



CREATE TABLE IF NOT EXISTS "public"."riwayat_kehamilan_lalu" (
    "id_riwayat" integer NOT NULL,
    "id_evaluasi" integer NOT NULL,
    "no_urut" bigint,
    "tahun" bigint,
    "bg_gram" bigint,
    "proses_melahirkan" "text",
    "penolong_proses_melahirkan" "text",
    "masalah" "text"
);


ALTER TABLE "public"."riwayat_kehamilan_lalu" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."riwayat_kehamilan_lalu_id_riwayat_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."riwayat_kehamilan_lalu_id_riwayat_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."riwayat_kehamilan_lalu_id_riwayat_seq" OWNED BY "public"."riwayat_kehamilan_lalu"."id_riwayat";



CREATE TABLE IF NOT EXISTS "public"."riwayat_proses_melahirkan" (
    "id" integer NOT NULL,
    "kehamilan_id" integer NOT NULL,
    "hari_melahirkan" character varying(20),
    "tanggal_melahirkan" "date",
    "pukul_melahirkan" timestamp with time zone,
    "cara_melahirkan_spontan" boolean,
    "cara_melahirkan_sungsang" boolean,
    "tindakan_ekstraksi_vakum" boolean,
    "tindakan_ekstraksi_forsep" boolean,
    "tindakan_sc" boolean,
    "penolong_dokter_spesialis" boolean,
    "penolong_dokter" boolean,
    "penolong_bidan" boolean,
    "taksiran_melahirkan" "text",
    "fasyankes_tempat_melahirkan" "text",
    "rujukan_keterangan" "text",
    "inisiasi_menyusu_dini_keterangan" "text",
    "cap_kaki_bayi_image_url" "bytea",
    "created_at" timestamp with time zone
);


ALTER TABLE "public"."riwayat_proses_melahirkan" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."riwayat_proses_melahirkan_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."riwayat_proses_melahirkan_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."riwayat_proses_melahirkan_id_seq" OWNED BY "public"."riwayat_proses_melahirkan"."id";



CREATE TABLE IF NOT EXISTS "public"."roles" (
    "id" integer NOT NULL,
    "name" character varying(50) NOT NULL,
    "description" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "is_deleted" timestamp with time zone
);


ALTER TABLE "public"."roles" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."roles_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."roles_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."roles_id_seq" OWNED BY "public"."roles"."id";



CREATE TABLE IF NOT EXISTS "public"."rujukan" (
    "id" integer NOT NULL,
    "kehamilan_id" integer NOT NULL,
    "rujukan_resume_pemeriksaan_tatalaksana" "text",
    "rujukan_diagnosis_akhir" "text",
    "rujukan_alasan_dirujuk_ke_fkrtl" "text",
    "rujukan_balik_tanggal" "date",
    "rujukan_balik_diagnosis_akhir" "text",
    "rujukan_balik_resume_pemeriksaan_tatalaksana" "text",
    "anjuran_rekomendasi_tempat_melahirkan" character varying(50),
    "created_at" timestamp with time zone,
    "source" character varying(50)
);


ALTER TABLE "public"."rujukan" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."rujukan_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."rujukan_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."rujukan_id_seq" OWNED BY "public"."rujukan"."id";



CREATE TABLE IF NOT EXISTS "public"."skrining_dm_gestasional" (
    "id_skrining_dm" integer NOT NULL,
    "kehamilan_id" integer NOT NULL,
    "gula_darah_puasa_hasil" "text",
    "gula_darah_puasa_rencana" "text",
    "gula_darah2_jam_post_prandial_hasil" "text",
    "gula_darah2_jam_post_prandial_rencana" "text"
);


ALTER TABLE "public"."skrining_dm_gestasional" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."skrining_dm_gestasional_id_skrining_dm_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."skrining_dm_gestasional_id_skrining_dm_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."skrining_dm_gestasional_id_skrining_dm_seq" OWNED BY "public"."skrining_dm_gestasional"."id_skrining_dm";



CREATE TABLE IF NOT EXISTS "public"."skrining_pemantauan" (
    "id" integer NOT NULL,
    "anak_id" integer NOT NULL,
    "kategori_tanda_bahaya_id" integer NOT NULL,
    "periode_waktu" bigint NOT NULL,
    "satuan_waktu" "text" NOT NULL,
    "ditemukan_gejala" boolean NOT NULL,
    "tgl_skrining" "date" NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."skrining_pemantauan" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."skrining_pemantauan_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."skrining_pemantauan_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."skrining_pemantauan_id_seq" OWNED BY "public"."skrining_pemantauan"."id";



CREATE TABLE IF NOT EXISTS "public"."skrining_preeklampsia" (
    "id" integer NOT NULL,
    "kehamilan_id" integer NOT NULL,
    "anamnesis_multipara_pasangan_baru_sedang" boolean,
    "anamnesis_teknologi_reproduksi_berbantu_sedang" boolean,
    "anamnesis_umur_diatas35_tahun_sedang" boolean,
    "anamnesis_nulipara_sedang" boolean,
    "anamnesis_jarak_kehamilan_diatas10_tahun_sedang" boolean,
    "anamnesis_riwayat_preeklampsia_keluarga_sedang" boolean,
    "anamnesis_obesitas_imt_diatas30_sedang" boolean,
    "anamnesis_riwayat_preeklampsia_sebelumnya_tinggi" boolean,
    "anamnesis_kehamilan_multipel_tinggi" boolean,
    "anamnesis_diabetes_dalam_kehamilan_tinggi" boolean,
    "anamnesis_hipertensi_kronik_tinggi" boolean,
    "anamnesis_penyakit_ginjal_tinggi" boolean,
    "anamnesis_penyakit_autoimun_sle_tinggi" boolean,
    "anamnesis_anti_phospholipid_syndrome_tinggi" boolean,
    "fisik_map_diatas90mm_hg" boolean,
    "fisik_proteinuria_urin_celup" boolean,
    "kesimpulan_skrining_preeklampsia" "text"
);


ALTER TABLE "public"."skrining_preeklampsia" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."skrining_preeklampsia_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."skrining_preeklampsia_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."skrining_preeklampsia_id_seq" OWNED BY "public"."skrining_preeklampsia"."id";



CREATE TABLE IF NOT EXISTS "public"."status" (
    "id" bigint NOT NULL,
    "nama_status" "text",
    "id_kategori_status" bigint
);


ALTER TABLE "public"."status" OWNER TO "postgres";


ALTER TABLE "public"."status" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."status_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."status_jadwal" (
    "id" bigint NOT NULL,
    "nama_status" "text"
);


ALTER TABLE "public"."status_jadwal" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."status_jadwal_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."status_jadwal_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."status_jadwal_id_seq" OWNED BY "public"."status_jadwal"."id";



CREATE TABLE IF NOT EXISTS "public"."status_kunjungan" (
    "id" bigint NOT NULL,
    "status_kunjungan" "text",
    "nama_status" "text"
);


ALTER TABLE "public"."status_kunjungan" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."status_kunjungan_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."status_kunjungan_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."status_kunjungan_id_seq" OWNED BY "public"."status_kunjungan"."id";



CREATE TABLE IF NOT EXISTS "public"."status_request" (
    "id" bigint NOT NULL,
    "status_request" "text"
);


ALTER TABLE "public"."status_request" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."status_request_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."status_request_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."status_request_id_seq" OWNED BY "public"."status_request"."id";



CREATE TABLE IF NOT EXISTS "public"."vaksin" (
    "id" bigint NOT NULL,
    "nama" character varying(50) NOT NULL,
    "deskripsi" "text" NOT NULL,
    "efek_samping" "text" NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."vaksin" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."vaksin_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."vaksin_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."vaksin_id_seq" OWNED BY "public"."vaksin"."id";



CREATE TABLE IF NOT EXISTS "public"."warna_tinja_anak" (
    "id" bigint NOT NULL,
    "anak_id" bigint NOT NULL,
    "periode_key" character varying(20) NOT NULL,
    "periode_label" character varying(30) NOT NULL,
    "tanggal_catat" "date" NOT NULL,
    "nomor_warna" bigint NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."warna_tinja_anak" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."warna_tinja_anak_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."warna_tinja_anak_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."warna_tinja_anak_id_seq" OWNED BY "public"."warna_tinja_anak"."id";



ALTER TABLE ONLY "public"."Kategori_umur" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."Kategori_umur_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."Neonatus" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."Neonatus_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."Pelayanan_Asi" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."Pelayanan_Asi_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."absensi_kelas_ibu_balita" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."absensi_kelas_ibu_balita_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."absensi_kelas_ibu_hamil" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."absensi_kelas_ibu_hamil_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."anak" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."anak_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."aturan_pelayanans" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."aturan_pelayanans_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."aturan_porsi_mpasi" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."aturan_porsi_mpasi_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."aturan_vaksin_anak" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."aturan_vaksin_anak_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."audit_trails" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."audit_trails_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."bidan" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."bidan_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."catatan_pelayanan" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."catatan_pelayanan_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."catatan_pelayanan_kehamilan" ALTER COLUMN "id_catatan" SET DEFAULT "nextval"('"public"."catatan_pelayanan_kehamilan_id_catatan_seq"'::"regclass");



ALTER TABLE ONLY "public"."catatan_pelayanan_nifas" ALTER COLUMN "id_catatan_nifas" SET DEFAULT "nextval"('"public"."catatan_pelayanan_nifas_id_catatan_nifas_seq"'::"regclass");



ALTER TABLE ONLY "public"."catatan_pelayanan_trimester_1" ALTER COLUMN "id_catatan" SET DEFAULT "nextval"('"public"."catatan_pelayanan_trimester_1_id_catatan_seq"'::"regclass");



ALTER TABLE ONLY "public"."catatan_pelayanan_trimester_2" ALTER COLUMN "id_catatan_t2" SET DEFAULT "nextval"('"public"."catatan_pelayanan_trimester_2_id_catatan_t2_seq"'::"regclass");



ALTER TABLE ONLY "public"."catatan_pelayanan_trimester_3" ALTER COLUMN "id_catatan_t3" SET DEFAULT "nextval"('"public"."catatan_pelayanan_trimester_3_id_catatan_t3_seq"'::"regclass");



ALTER TABLE ONLY "public"."catatan_pertumbuhan" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."catatan_pertumbuhan_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."checklist_pemantauan_ibu_nifas" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."checklist_pemantauan_ibu_nifas_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."desa" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."desa_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."detail_lingkungan" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."detail_lingkungan_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."detail_pelayanan_imunisasi" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."detail_pelayanan_imunisasi_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."detail_pelayanan_neonatus" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."detail_pelayanan_neonatus_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."detail_pelayanan_vitamin" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."detail_pelayanan_vitamin_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."detail_pemantauan" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."detail_pemantauan_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."detail_pemantauan_ibu" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."detail_pemantauan_ibu_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."deteksi_dini_penyimpangan" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."deteksi_dini_penyimpangan_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."dosis_vaksin" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."dosis_vaksin_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."edukasi_imd" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."edukasi_imd_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."edukasi_informasi_umum" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."edukasi_informasi_umum_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."edukasi_kesehatan_mental" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."edukasi_kesehatan_mental_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."edukasi_menyusui_asi" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."edukasi_menyusui_asi_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."edukasi_perawatan_anak" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."edukasi_perawatan_anak_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."edukasi_pola_asuh" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."edukasi_pola_asuh_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."edukasi_setelah_melahirkan" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."edukasi_setelah_melahirkan_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."edukasi_tanda_melahirkan" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."edukasi_tanda_melahirkan_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."edukasi_trimester" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."edukasi_trimester_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."evaluasi_kesehatan_ibu" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."evaluasi_kesehatan_ibu_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."form_aturan_risikos" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."form_aturan_risikos_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."form_pertanyaans" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."form_pertanyaans_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."form_versis" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."form_versis_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."grafik_evaluasi_kehamilan" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."grafik_evaluasi_kehamilan_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."grafik_peningkatan_bb" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."grafik_peningkatan_bb_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."ibu" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."ibu_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."indikator_lingkungan" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."indikator_lingkungan_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."informasi_umum" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."informasi_umum_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."jadwal_harian_mpasi" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."jadwal_harian_mpasi_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."jadwal_imunisasi_anak" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."jadwal_imunisasi_anak_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."jadwal_layanan" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."jadwal_layanan_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."jenis_pelayanan" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."jenis_pelayanan_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."jenis_pelayanan_kategori" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."jenis_pelayanan_kategori_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."kader" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."kader_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."kader_posyandu" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."kader_posyandu_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."kartu_keluarga" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."kartu_keluarga_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."kategori_capaian" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."kategori_capaian_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."kategori_lingkungan" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."kategori_lingkungan_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."kategori_pemantauan_ibu" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."kategori_pemantauan_ibu_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."kategori_tanda_bahaya" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."kategori_tanda_bahaya_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."kategori_tanda_sakit" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."kategori_tanda_sakit_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."kehadiran_imunisasi" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."kehadiran_imunisasi_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."kehamilan" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."kehamilan_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."keluhan_anak" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."keluhan_anak_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."keterangan_lahir" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."keterangan_lahir_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."kunjungan_anak" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."kunjungan_anak_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."kunjungan_gizi" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."kunjungan_gizi_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."kunjungan_imunisasi" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."kunjungan_imunisasi_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."kunjungan_vitamin" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."kunjungan_vitamin_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."lembar_lingkungan" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."lembar_lingkungan_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."lembar_pemantauan" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."lembar_pemantauan_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."lembar_pemantauan_ibu" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."lembar_pemantauan_ibu_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."log_ttd_mms" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."log_ttd_mms_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."master_imunisasi" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."master_imunisasi_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."master_standar_antropometri" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."master_standar_antropometri_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."materi_mpasi" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."materi_mpasi_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."mp_asi" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."mp_asi_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."pelayanan_ibu_nifas" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."pelayanan_ibu_nifas_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."pemantauan_ibu_hamil" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."pemantauan_ibu_hamil_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."pemantauan_indikator" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."pemantauan_indikator_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."pemeriksaan_anak" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."pemeriksaan_anak_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."pemeriksaan_dewasa" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."pemeriksaan_dewasa_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."pemeriksaan_dokter_trimester_1" ALTER COLUMN "id_trimester1" SET DEFAULT "nextval"('"public"."pemeriksaan_dokter_trimester_1_id_trimester1_seq"'::"regclass");



ALTER TABLE ONLY "public"."pemeriksaan_dokter_trimester_3" ALTER COLUMN "id_trimester3" SET DEFAULT "nextval"('"public"."pemeriksaan_dokter_trimester_3_id_trimester3_seq"'::"regclass");



ALTER TABLE ONLY "public"."pemeriksaan_kehamilan" ALTER COLUMN "id_periksa" SET DEFAULT "nextval"('"public"."pemeriksaan_kehamilan_id_periksa_seq"'::"regclass");



ALTER TABLE ONLY "public"."pemeriksaan_laboratorium_jiwa" ALTER COLUMN "id_lab_jiwa" SET DEFAULT "nextval"('"public"."pemeriksaan_laboratorium_jiwa_id_lab_jiwa_seq"'::"regclass");



ALTER TABLE ONLY "public"."pemeriksaan_lanjutan_trimester_3" ALTER COLUMN "id_lanjutan_t3" SET DEFAULT "nextval"('"public"."pemeriksaan_lanjutan_trimester_3_id_lanjutan_t3_seq"'::"regclass");



ALTER TABLE ONLY "public"."pemeriksaan_lansia" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."pemeriksaan_lansia_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."pemeriksaan_remaja" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."pemeriksaan_remaja_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."pemeriksaans" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."pemeriksaans_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."penduduk" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."penduduk_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."pengguna" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."pengguna_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."pengukuran_lila" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."pengukuran_lila_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."penjelasan_hasil_grafik" ALTER COLUMN "id_penjelasan" SET DEFAULT "nextval"('"public"."penjelasan_hasil_grafik_id_penjelasan_seq"'::"regclass");



ALTER TABLE ONLY "public"."perangkat" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."perangkat_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."perawatan" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."perawatan_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."periksa_gigi" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."periksa_gigi_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."periode_kunjungan" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."periode_kunjungan_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."persiapan_melahirkan" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."persiapan_melahirkan_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."pertumbuhan_Anak" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."pertumbuhan_Anak_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."posyandu" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."posyandu_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."prediksi_stunting" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."prediksi_stunting_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."proses_melahirkan" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."proses_melahirkan_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."rencana_persalinan" ALTER COLUMN "id_rencana_persalinan" SET DEFAULT "nextval"('"public"."rencana_persalinan_id_rencana_persalinan_seq"'::"regclass");



ALTER TABLE ONLY "public"."rentang_usia" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."rentang_usia_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."request_perubahan_imunisasi" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."request_perubahan_imunisasi_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."resep_mpasi" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."resep_mpasi_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."ringkasan_pelayanan_persalinan" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."ringkasan_pelayanan_persalinan_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."riwayat_kehamilan_lalu" ALTER COLUMN "id_riwayat" SET DEFAULT "nextval"('"public"."riwayat_kehamilan_lalu_id_riwayat_seq"'::"regclass");



ALTER TABLE ONLY "public"."riwayat_proses_melahirkan" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."riwayat_proses_melahirkan_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."roles" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."roles_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."rujukan" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."rujukan_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."skrining_dm_gestasional" ALTER COLUMN "id_skrining_dm" SET DEFAULT "nextval"('"public"."skrining_dm_gestasional_id_skrining_dm_seq"'::"regclass");



ALTER TABLE ONLY "public"."skrining_pemantauan" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."skrining_pemantauan_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."skrining_preeklampsia" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."skrining_preeklampsia_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."status_jadwal" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."status_jadwal_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."status_kunjungan" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."status_kunjungan_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."status_request" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."status_request_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."vaksin" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."vaksin_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."warna_tinja_anak" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."warna_tinja_anak_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."Kategori_umur"
    ADD CONSTRAINT "Kategori_umur_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."Neonatus"
    ADD CONSTRAINT "Neonatus_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."Pelayanan_Asi"
    ADD CONSTRAINT "Pelayanan_Asi_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."absensi_kelas_ibu_balita"
    ADD CONSTRAINT "absensi_kelas_ibu_balita_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."absensi_kelas_ibu_hamil"
    ADD CONSTRAINT "absensi_kelas_ibu_hamil_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."anak"
    ADD CONSTRAINT "anak_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."aturan_pelayanans"
    ADD CONSTRAINT "aturan_pelayanans_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."aturan_porsi_mpasi"
    ADD CONSTRAINT "aturan_porsi_mpasi_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."aturan_vaksin_anak"
    ADD CONSTRAINT "aturan_vaksin_anak_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."audit_trails"
    ADD CONSTRAINT "audit_trails_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."bbl_check"
    ADD CONSTRAINT "bbl_check_pkey1" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."bbl"
    ADD CONSTRAINT "bbl_pkey2" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."bidan"
    ADD CONSTRAINT "bidan_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."catatan_pelayanan_kehamilan"
    ADD CONSTRAINT "catatan_pelayanan_kehamilan_pkey" PRIMARY KEY ("id_catatan");



ALTER TABLE ONLY "public"."catatan_pelayanan_nifas"
    ADD CONSTRAINT "catatan_pelayanan_nifas_pkey" PRIMARY KEY ("id_catatan_nifas");



ALTER TABLE ONLY "public"."catatan_pelayanan"
    ADD CONSTRAINT "catatan_pelayanan_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."catatan_pelayanan_trimester_1"
    ADD CONSTRAINT "catatan_pelayanan_trimester_1_pkey" PRIMARY KEY ("id_catatan");



ALTER TABLE ONLY "public"."catatan_pelayanan_trimester_2"
    ADD CONSTRAINT "catatan_pelayanan_trimester_2_pkey" PRIMARY KEY ("id_catatan_t2");



ALTER TABLE ONLY "public"."catatan_pelayanan_trimester_3"
    ADD CONSTRAINT "catatan_pelayanan_trimester_3_pkey" PRIMARY KEY ("id_catatan_t3");



ALTER TABLE ONLY "public"."catatan_pelayanan_trimester"
    ADD CONSTRAINT "catatan_pelayanan_trimester_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."catatan_pertumbuhan"
    ADD CONSTRAINT "catatan_pertumbuhan_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."checklist_pemantauan_ibu_nifas"
    ADD CONSTRAINT "checklist_pemantauan_ibu_nifas_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."desa"
    ADD CONSTRAINT "desa_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."detail_lingkungan"
    ADD CONSTRAINT "detail_lingkungan_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."detail_pelayanan_imunisasi"
    ADD CONSTRAINT "detail_pelayanan_imunisasi_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."detail_pelayanan_neonatus"
    ADD CONSTRAINT "detail_pelayanan_neonatus_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."detail_pelayanan_vitamin"
    ADD CONSTRAINT "detail_pelayanan_vitamin_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."detail_pemantauan_ibu"
    ADD CONSTRAINT "detail_pemantauan_ibu_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."detail_pemantauan"
    ADD CONSTRAINT "detail_pemantauan_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."deteksi_dini_penyimpangan"
    ADD CONSTRAINT "deteksi_dini_penyimpangan_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."dosis_vaksin"
    ADD CONSTRAINT "dosis_vaksin_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."dusun"
    ADD CONSTRAINT "dusun_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."edukasi_imd"
    ADD CONSTRAINT "edukasi_imd_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."edukasi_informasi_umum"
    ADD CONSTRAINT "edukasi_informasi_umum_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."edukasi_kesehatan_mental"
    ADD CONSTRAINT "edukasi_kesehatan_mental_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."edukasi_menyusui_asi"
    ADD CONSTRAINT "edukasi_menyusui_asi_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."edukasi_perawatan_anak"
    ADD CONSTRAINT "edukasi_perawatan_anak_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."edukasi_pola_asuh"
    ADD CONSTRAINT "edukasi_pola_asuh_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."edukasi_setelah_melahirkan"
    ADD CONSTRAINT "edukasi_setelah_melahirkan_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."edukasi_tanda_melahirkan"
    ADD CONSTRAINT "edukasi_tanda_melahirkan_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."edukasi_trimester"
    ADD CONSTRAINT "edukasi_trimester_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."evaluasi_kesehatan_ibu"
    ADD CONSTRAINT "evaluasi_kesehatan_ibu_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."form_aturan_risikos"
    ADD CONSTRAINT "form_aturan_risikos_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."form_pertanyaans"
    ADD CONSTRAINT "form_pertanyaans_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."form_versis"
    ADD CONSTRAINT "form_versis_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."grafik_evaluasi_kehamilan"
    ADD CONSTRAINT "grafik_evaluasi_kehamilan_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."grafik_peningkatan_bb"
    ADD CONSTRAINT "grafik_peningkatan_bb_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."ibu"
    ADD CONSTRAINT "ibu_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."indikator_lingkungan"
    ADD CONSTRAINT "indikator_lingkungan_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."informasi_umum"
    ADD CONSTRAINT "informasi_umum_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."jadwal_harian_mpasi"
    ADD CONSTRAINT "jadwal_harian_mpasi_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."jadwal_imunisasi_anak"
    ADD CONSTRAINT "jadwal_imunisasi_anak_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."jadwal_layanan_dosis_vaksin"
    ADD CONSTRAINT "jadwal_layanan_dosis_vaksin_pkey" PRIMARY KEY ("jadwal_layanan_id", "dosis_vaksin_id");



ALTER TABLE ONLY "public"."jadwal_layanan"
    ADD CONSTRAINT "jadwal_layanan_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."jadwal_layanan_vaksin"
    ADD CONSTRAINT "jadwal_layanan_vaksin_pkey" PRIMARY KEY ("jadwal_layanan_id", "vaksin_id");



ALTER TABLE ONLY "public"."jenis_pelayanan_kategori"
    ADD CONSTRAINT "jenis_pelayanan_kategori_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."jenis_pelayanan"
    ADD CONSTRAINT "jenis_pelayanan_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."kader"
    ADD CONSTRAINT "kader_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."kader_posyandu"
    ADD CONSTRAINT "kader_posyandu_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."kartu_keluarga"
    ADD CONSTRAINT "kartu_keluarga_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."kategori_capaian"
    ADD CONSTRAINT "kategori_capaian_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."kategori_lingkungan"
    ADD CONSTRAINT "kategori_lingkungan_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."kategori_pemantauan_ibu"
    ADD CONSTRAINT "kategori_pemantauan_ibu_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."kategori_status"
    ADD CONSTRAINT "kategori_status_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."kategori_tanda_bahaya"
    ADD CONSTRAINT "kategori_tanda_bahaya_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."kategori_tanda_sakit"
    ADD CONSTRAINT "kategori_tanda_sakit_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."kategori_trimester"
    ADD CONSTRAINT "kategori_trimester_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."kehadiran_imunisasi"
    ADD CONSTRAINT "kehadiran_imunisasi_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."kehamilan"
    ADD CONSTRAINT "kehamilan_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."keluhan_anak"
    ADD CONSTRAINT "keluhan_anak_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."keterangan_lahir"
    ADD CONSTRAINT "keterangan_lahir_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."kunjungan_anak"
    ADD CONSTRAINT "kunjungan_anak_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."kunjungan_gizi"
    ADD CONSTRAINT "kunjungan_gizi_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."kunjungan_imunisasi"
    ADD CONSTRAINT "kunjungan_imunisasi_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."kunjungan_vitamin"
    ADD CONSTRAINT "kunjungan_vitamin_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."lembar_lingkungan"
    ADD CONSTRAINT "lembar_lingkungan_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."lembar_pemantauan_ibu"
    ADD CONSTRAINT "lembar_pemantauan_ibu_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."lembar_pemantauan"
    ADD CONSTRAINT "lembar_pemantauan_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."log_ttd_mms"
    ADD CONSTRAINT "log_ttd_mms_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."master_imunisasi"
    ADD CONSTRAINT "master_imunisasi_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."master_standar_antropometri"
    ADD CONSTRAINT "master_standar_antropometri_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."materi_mpasi"
    ADD CONSTRAINT "materi_mpasi_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."mp_asi"
    ADD CONSTRAINT "mp_asi_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."pelayanan_ibu_nifas"
    ADD CONSTRAINT "pelayanan_ibu_nifas_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."pemantauan_ibu_hamil"
    ADD CONSTRAINT "pemantauan_ibu_hamil_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."pemantauan_indikator"
    ADD CONSTRAINT "pemantauan_indikator_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."pemeriksaan_anak"
    ADD CONSTRAINT "pemeriksaan_anak_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."pemeriksaan_dewasa"
    ADD CONSTRAINT "pemeriksaan_dewasa_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."pemeriksaan_dokter_trimester_1"
    ADD CONSTRAINT "pemeriksaan_dokter_trimester_1_pkey" PRIMARY KEY ("id_trimester1");



ALTER TABLE ONLY "public"."pemeriksaan_dokter_trimester_3"
    ADD CONSTRAINT "pemeriksaan_dokter_trimester_3_pkey" PRIMARY KEY ("id_trimester3");



ALTER TABLE ONLY "public"."pemeriksaan_kehamilan"
    ADD CONSTRAINT "pemeriksaan_kehamilan_pkey" PRIMARY KEY ("id_periksa");



ALTER TABLE ONLY "public"."pemeriksaan_laboratorium_jiwa"
    ADD CONSTRAINT "pemeriksaan_laboratorium_jiwa_pkey" PRIMARY KEY ("id_lab_jiwa");



ALTER TABLE ONLY "public"."pemeriksaan_lanjutan_trimester_3"
    ADD CONSTRAINT "pemeriksaan_lanjutan_trimester_3_pkey" PRIMARY KEY ("id_lanjutan_t3");



ALTER TABLE ONLY "public"."pemeriksaan_lansia"
    ADD CONSTRAINT "pemeriksaan_lansia_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."pemeriksaan_remaja"
    ADD CONSTRAINT "pemeriksaan_remaja_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."pemeriksaans"
    ADD CONSTRAINT "pemeriksaans_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."penduduk"
    ADD CONSTRAINT "penduduk_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."pengguna"
    ADD CONSTRAINT "pengguna_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."pengukuran_lila"
    ADD CONSTRAINT "pengukuran_lila_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."penjelasan_hasil_grafik"
    ADD CONSTRAINT "penjelasan_hasil_grafik_pkey" PRIMARY KEY ("id_penjelasan");



ALTER TABLE ONLY "public"."perangkat"
    ADD CONSTRAINT "perangkat_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."perawatan"
    ADD CONSTRAINT "perawatan_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."periksa_gigi"
    ADD CONSTRAINT "periksa_gigi_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."periode_kunjungan"
    ADD CONSTRAINT "periode_kunjungan_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."persiapan_melahirkan"
    ADD CONSTRAINT "persiapan_melahirkan_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."pertumbuhan_Anak"
    ADD CONSTRAINT "pertumbuhan_Anak_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."posyandu"
    ADD CONSTRAINT "posyandu_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."prediksi_stunting"
    ADD CONSTRAINT "prediksi_stunting_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."proses_melahirkan"
    ADD CONSTRAINT "proses_melahirkan_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."puskesmas"
    ADD CONSTRAINT "puskesmas_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."rencana_persalinan"
    ADD CONSTRAINT "rencana_persalinan_pkey" PRIMARY KEY ("id_rencana_persalinan");



ALTER TABLE ONLY "public"."rentang_usia"
    ADD CONSTRAINT "rentang_usia_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."request_perubahan_imunisasi"
    ADD CONSTRAINT "request_perubahan_imunisasi_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."resep_mpasi"
    ADD CONSTRAINT "resep_mpasi_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."ringkasan_pelayanan_persalinan"
    ADD CONSTRAINT "ringkasan_pelayanan_persalinan_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."riwayat_kehamilan_lalu"
    ADD CONSTRAINT "riwayat_kehamilan_lalu_pkey" PRIMARY KEY ("id_riwayat");



ALTER TABLE ONLY "public"."riwayat_proses_melahirkan"
    ADD CONSTRAINT "riwayat_proses_melahirkan_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."roles"
    ADD CONSTRAINT "roles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."rujukan"
    ADD CONSTRAINT "rujukan_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."skrining_dm_gestasional"
    ADD CONSTRAINT "skrining_dm_gestasional_pkey" PRIMARY KEY ("id_skrining_dm");



ALTER TABLE ONLY "public"."skrining_pemantauan"
    ADD CONSTRAINT "skrining_pemantauan_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."skrining_preeklampsia"
    ADD CONSTRAINT "skrining_preeklampsia_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."status_jadwal"
    ADD CONSTRAINT "status_jadwal_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."status_kunjungan"
    ADD CONSTRAINT "status_kunjungan_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."status"
    ADD CONSTRAINT "status_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."status_request"
    ADD CONSTRAINT "status_request_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."Kategori_umur"
    ADD CONSTRAINT "uni_Kategori_umur_kategori_umur" UNIQUE ("kategori_umur");



ALTER TABLE ONLY "public"."vaksin"
    ADD CONSTRAINT "vaksin_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."warna_tinja_anak"
    ADD CONSTRAINT "warna_tinja_anak_pkey" PRIMARY KEY ("id");



CREATE INDEX "idx_Kategori_umur_deleted_at" ON "public"."Kategori_umur" USING "btree" ("deleted_at");



CREATE INDEX "idx_Neonatus_anak_id" ON "public"."Neonatus" USING "btree" ("anak_id");



CREATE INDEX "idx_Neonatus_deleted_at" ON "public"."Neonatus" USING "btree" ("deleted_at");



CREATE INDEX "idx_Neonatus_kategori_umur_id" ON "public"."Neonatus" USING "btree" ("kategori_umur_id");



CREATE INDEX "idx_Neonatus_periode_id" ON "public"."Neonatus" USING "btree" ("periode_id");



CREATE INDEX "idx_Neonatus_tenaga_kesehatan_id" ON "public"."Neonatus" USING "btree" ("tenaga_kesehatan_id");



CREATE INDEX "idx_Pelayanan_Asi_deleted_at" ON "public"."Pelayanan_Asi" USING "btree" ("deleted_at");



CREATE UNIQUE INDEX "idx_Pelayanan_Asi_kunjungan_gizi_id" ON "public"."Pelayanan_Asi" USING "btree" ("kunjungan_gizi_id", "kunjungan_gizi_id");



CREATE INDEX "idx_absensi_kelas_ibu_balita_ibu_id" ON "public"."absensi_kelas_ibu_balita" USING "btree" ("ibu_id");



CREATE INDEX "idx_absensi_kelas_ibu_hamil_kehamilan_id" ON "public"."absensi_kelas_ibu_hamil" USING "btree" ("kehamilan_id");



CREATE UNIQUE INDEX "idx_absensi_unique" ON "public"."absensi_kelas_ibu_hamil" USING "btree" ("kehamilan_id", "pertemuan_ke");



CREATE INDEX "idx_anak_deleted_at" ON "public"."anak" USING "btree" ("deleted_at");



CREATE INDEX "idx_anak_kehamilan_id" ON "public"."anak" USING "btree" ("kehamilan_id");



CREATE INDEX "idx_anak_penduduk_id" ON "public"."anak" USING "btree" ("penduduk_id");



CREATE UNIQUE INDEX "idx_anak_periode" ON "public"."lembar_pemantauan" USING "btree" ("anak_id", "rentang_usia_id", "periode_waktu");



CREATE INDEX "idx_aturan_pelayanans_deleted_at" ON "public"."aturan_pelayanans" USING "btree" ("deleted_at");



CREATE INDEX "idx_aturan_pelayanans_jenis_pelayanan_id" ON "public"."aturan_pelayanans" USING "btree" ("jenis_pelayanan_id");



CREATE INDEX "idx_aturan_porsi_mpasi_deleted_at" ON "public"."aturan_porsi_mpasi" USING "btree" ("deleted_at");



CREATE INDEX "idx_aturan_vaksin_anak_deleted_at" ON "public"."aturan_vaksin_anak" USING "btree" ("deleted_at");



CREATE INDEX "idx_audit_trails_action" ON "public"."audit_trails" USING "btree" ("action");



CREATE INDEX "idx_audit_trails_actor_identifier" ON "public"."audit_trails" USING "btree" ("actor_identifier");



CREATE INDEX "idx_audit_trails_actor_role" ON "public"."audit_trails" USING "btree" ("actor_role");



CREATE INDEX "idx_audit_trails_actor_user_id" ON "public"."audit_trails" USING "btree" ("actor_user_id");



CREATE INDEX "idx_audit_trails_method" ON "public"."audit_trails" USING "btree" ("method");



CREATE INDEX "idx_audit_trails_request_id" ON "public"."audit_trails" USING "btree" ("request_id");



CREATE INDEX "idx_audit_trails_resource" ON "public"."audit_trails" USING "btree" ("resource");



CREATE INDEX "idx_audit_trails_status_code" ON "public"."audit_trails" USING "btree" ("status_code");



CREATE INDEX "idx_audit_trails_success" ON "public"."audit_trails" USING "btree" ("success");



CREATE UNIQUE INDEX "idx_bbl_anak_id" ON "public"."bbl" USING "btree" ("anak_id");



CREATE INDEX "idx_bbl_deleted_at" ON "public"."bbl" USING "btree" ("deleted_at");



CREATE INDEX "idx_bidan_desa_id" ON "public"."bidan" USING "btree" ("desa_id");



CREATE UNIQUE INDEX "idx_bidan_penduduk_id" ON "public"."bidan" USING "btree" ("penduduk_id");



CREATE INDEX "idx_catatan_pelayanan_anak_id" ON "public"."catatan_pelayanan" USING "btree" ("anak_id");



CREATE INDEX "idx_catatan_pelayanan_deleted_at" ON "public"."catatan_pelayanan" USING "btree" ("deleted_at");



CREATE INDEX "idx_catatan_pelayanan_tenaga_kesehatan_id" ON "public"."catatan_pelayanan" USING "btree" ("tenaga_kesehatan_id");



CREATE INDEX "idx_catatan_pelayanan_trimester_1_kehamilan_id" ON "public"."catatan_pelayanan_trimester_1" USING "btree" ("kehamilan_id");



CREATE INDEX "idx_catatan_pelayanan_trimester_2_kehamilan_id" ON "public"."catatan_pelayanan_trimester_2" USING "btree" ("kehamilan_id");



CREATE INDEX "idx_catatan_pelayanan_trimester_3_kehamilan_id" ON "public"."catatan_pelayanan_trimester_3" USING "btree" ("kehamilan_id");



CREATE INDEX "idx_catatan_pertumbuhan_anak_id" ON "public"."catatan_pertumbuhan" USING "btree" ("anak_id");



CREATE INDEX "idx_catatan_pertumbuhan_deleted_at" ON "public"."catatan_pertumbuhan" USING "btree" ("deleted_at");



CREATE INDEX "idx_catatan_pertumbuhan_tgl_ukur" ON "public"."catatan_pertumbuhan" USING "btree" ("tgl_ukur");



CREATE INDEX "idx_catatan_pertumbuhan_usia_ukur_bulan" ON "public"."catatan_pertumbuhan" USING "btree" ("usia_ukur_bulan");



CREATE INDEX "idx_checklist_pemantauan_ibu_nifas_deleted_at" ON "public"."checklist_pemantauan_ibu_nifas" USING "btree" ("deleted_at");



CREATE UNIQUE INDEX "idx_desa_kode_desa" ON "public"."desa" USING "btree" ("kode_desa");



CREATE INDEX "idx_detail_lingkungan_indikator_lingkungan_id" ON "public"."detail_lingkungan" USING "btree" ("indikator_lingkungan_id");



CREATE INDEX "idx_detail_lingkungan_lembar_lingkungan_id" ON "public"."detail_lingkungan" USING "btree" ("lembar_lingkungan_id");



CREATE INDEX "idx_detail_pelayanan_imunisasi_deleted_at" ON "public"."detail_pelayanan_imunisasi" USING "btree" ("deleted_at");



CREATE INDEX "idx_detail_pelayanan_imunisasi_jenis_pelayanan_id" ON "public"."detail_pelayanan_imunisasi" USING "btree" ("jenis_pelayanan_id");



CREATE INDEX "idx_detail_pelayanan_imunisasi_kunjungan_imunisasi_id" ON "public"."detail_pelayanan_imunisasi" USING "btree" ("kunjungan_imunisasi_id");



CREATE INDEX "idx_detail_pelayanan_neonatus_deleted_at" ON "public"."detail_pelayanan_neonatus" USING "btree" ("deleted_at");



CREATE INDEX "idx_detail_pelayanan_neonatus_jenis_pelayanan_id" ON "public"."detail_pelayanan_neonatus" USING "btree" ("jenis_pelayanan_id");



CREATE INDEX "idx_detail_pelayanan_neonatus_neonatus_id" ON "public"."detail_pelayanan_neonatus" USING "btree" ("neonatus_id");



CREATE INDEX "idx_detail_pelayanan_vitamin_deleted_at" ON "public"."detail_pelayanan_vitamin" USING "btree" ("deleted_at");



CREATE INDEX "idx_detail_pelayanan_vitamin_jenis_pelayanan_id" ON "public"."detail_pelayanan_vitamin" USING "btree" ("jenis_pelayanan_id");



CREATE INDEX "idx_detail_pelayanan_vitamin_kunjungan_vitamin_id" ON "public"."detail_pelayanan_vitamin" USING "btree" ("kunjungan_vitamin_id");



CREATE INDEX "idx_detail_pemantauan_deleted_at" ON "public"."detail_pemantauan" USING "btree" ("deleted_at");



CREATE INDEX "idx_detail_pemantauan_ibu_deleted_at" ON "public"."detail_pemantauan_ibu" USING "btree" ("deleted_at");



CREATE INDEX "idx_detail_pemantauan_ibu_kategori_pemantauan_id" ON "public"."detail_pemantauan_ibu" USING "btree" ("kategori_pemantauan_id");



CREATE INDEX "idx_detail_pemantauan_ibu_lembar_pemantauan_ibu_id" ON "public"."detail_pemantauan_ibu" USING "btree" ("lembar_pemantauan_ibu_id");



CREATE INDEX "idx_detail_pemantauan_kategori_tanda_sakit_id" ON "public"."detail_pemantauan" USING "btree" ("kategori_tanda_sakit_id");



CREATE INDEX "idx_detail_pemantauan_lembar_pemantauan_id" ON "public"."detail_pemantauan" USING "btree" ("lembar_pemantauan_id");



CREATE INDEX "idx_deteksi_dini_penyimpangan_anak_id" ON "public"."deteksi_dini_penyimpangan" USING "btree" ("anak_id");



CREATE INDEX "idx_deteksi_dini_penyimpangan_deleted_at" ON "public"."deteksi_dini_penyimpangan" USING "btree" ("deleted_at");



CREATE INDEX "idx_deteksi_dini_penyimpangan_tenaga_kesehatan_id" ON "public"."deteksi_dini_penyimpangan" USING "btree" ("tenaga_kesehatan_id");



CREATE INDEX "idx_dosis_vaksin_deleted_at" ON "public"."dosis_vaksin" USING "btree" ("deleted_at");



CREATE INDEX "idx_edukasi_informasi_umum_deleted_at" ON "public"."edukasi_informasi_umum" USING "btree" ("deleted_at");



CREATE INDEX "idx_edukasi_perawatan_anak_deleted_at" ON "public"."edukasi_perawatan_anak" USING "btree" ("deleted_at");



CREATE INDEX "idx_evaluasi_kesehatan_ibu_kehamilan_id" ON "public"."evaluasi_kesehatan_ibu" USING "btree" ("kehamilan_id");



CREATE INDEX "idx_form_aturan_risikos_form_versi_id" ON "public"."form_aturan_risikos" USING "btree" ("form_versi_id");



CREATE INDEX "idx_form_pertanyaans_form_versi_id" ON "public"."form_pertanyaans" USING "btree" ("form_versi_id");



CREATE INDEX "idx_form_versis_aktif" ON "public"."form_versis" USING "btree" ("aktif");



CREATE INDEX "idx_form_versis_kelompok" ON "public"."form_versis" USING "btree" ("kelompok");



CREATE INDEX "idx_grafik_evaluasi_kehamilan_kehamilan_id" ON "public"."grafik_evaluasi_kehamilan" USING "btree" ("kehamilan_id");



CREATE INDEX "idx_grafik_peningkatan_bb_kehamilan_id" ON "public"."grafik_peningkatan_bb" USING "btree" ("kehamilan_id");



CREATE INDEX "idx_ibu_penduduk" ON "public"."ibu" USING "btree" ("penduduk_id");



CREATE INDEX "idx_indikator_lingkungan_deleted_at" ON "public"."indikator_lingkungan" USING "btree" ("deleted_at");



CREATE INDEX "idx_indikator_lingkungan_kategori_lingkungan_id" ON "public"."indikator_lingkungan" USING "btree" ("kategori_lingkungan_id");



CREATE INDEX "idx_informasi_umum_deleted_at" ON "public"."informasi_umum" USING "btree" ("deleted_at");



CREATE INDEX "idx_jadwal_harian_mpasi_deleted_at" ON "public"."jadwal_harian_mpasi" USING "btree" ("deleted_at");



CREATE INDEX "idx_jadwal_imunisasi_anak_deleted_at" ON "public"."jadwal_imunisasi_anak" USING "btree" ("deleted_at");



CREATE INDEX "idx_jadwal_layanan_deleted_at" ON "public"."jadwal_layanan" USING "btree" ("deleted_at");



CREATE INDEX "idx_jadwal_layanan_posyandu_id" ON "public"."jadwal_layanan" USING "btree" ("posyandu_id");



CREATE INDEX "idx_jenis_pelayanan_deleted_at" ON "public"."jenis_pelayanan" USING "btree" ("deleted_at");



CREATE INDEX "idx_jenis_pelayanan_kategori_deleted_at" ON "public"."jenis_pelayanan_kategori" USING "btree" ("deleted_at");



CREATE INDEX "idx_jenis_pelayanan_kategori_jenis_pelayanan_id" ON "public"."jenis_pelayanan_kategori" USING "btree" ("jenis_pelayanan_id");



CREATE INDEX "idx_jenis_pelayanan_kategori_kategori_umur_id" ON "public"."jenis_pelayanan_kategori" USING "btree" ("kategori_umur_id");



CREATE INDEX "idx_jenis_pelayanan_kategori_periode_id" ON "public"."jenis_pelayanan_kategori" USING "btree" ("periode_id");



CREATE INDEX "idx_jldv_dosis_vaksin" ON "public"."jadwal_layanan_dosis_vaksin" USING "btree" ("dosis_vaksin_id");



CREATE INDEX "idx_jldv_jadwal_layanan" ON "public"."jadwal_layanan_dosis_vaksin" USING "btree" ("jadwal_layanan_id");



CREATE INDEX "idx_jlv_jadwal_layanan" ON "public"."jadwal_layanan_vaksin" USING "btree" ("jadwal_layanan_id");



CREATE INDEX "idx_jlv_jadwal_layanan_id" ON "public"."jadwal_layanan_vaksin" USING "btree" ("jadwal_layanan_id");



CREATE INDEX "idx_jlv_vaksin" ON "public"."jadwal_layanan_vaksin" USING "btree" ("vaksin_id");



CREATE INDEX "idx_jlv_vaksin_id" ON "public"."jadwal_layanan_vaksin" USING "btree" ("vaksin_id");



CREATE UNIQUE INDEX "idx_kader_penduduk_id" ON "public"."kader" USING "btree" ("id_penduduk");



CREATE UNIQUE INDEX "idx_kader_posyandu_no_sk" ON "public"."kader_posyandu" USING "btree" ("no_sk");



CREATE UNIQUE INDEX "idx_kader_posyandu_user_id" ON "public"."kader_posyandu" USING "btree" ("user_id");



CREATE UNIQUE INDEX "idx_kartu_keluarga_no_kk" ON "public"."kartu_keluarga" USING "btree" ("no_kk");



CREATE INDEX "idx_kategori_capaian_deleted_at" ON "public"."kategori_capaian" USING "btree" ("deleted_at");



CREATE INDEX "idx_kategori_capaian_rentang_usia" ON "public"."kategori_capaian" USING "btree" ("rentang_usia");



CREATE INDEX "idx_kategori_lingkungan_deleted_at" ON "public"."kategori_lingkungan" USING "btree" ("deleted_at");



CREATE INDEX "idx_kategori_pemantauan_ibu_deleted_at" ON "public"."kategori_pemantauan_ibu" USING "btree" ("deleted_at");



CREATE INDEX "idx_kategori_tanda_bahaya_deleted_at" ON "public"."kategori_tanda_bahaya" USING "btree" ("deleted_at");



CREATE INDEX "idx_kategori_tanda_sakit_deleted_at" ON "public"."kategori_tanda_sakit" USING "btree" ("deleted_at");



CREATE INDEX "idx_kategori_tanda_sakit_rentang_usia_id" ON "public"."kategori_tanda_sakit" USING "btree" ("rentang_usia_id");



CREATE INDEX "idx_kehadiran_imunisasi_anak_id" ON "public"."kehadiran_imunisasi" USING "btree" ("anak_id");



CREATE INDEX "idx_kehadiran_imunisasi_deleted_at" ON "public"."kehadiran_imunisasi" USING "btree" ("deleted_at");



CREATE INDEX "idx_kehamilan_deleted_at" ON "public"."kehamilan" USING "btree" ("deleted_at");



CREATE INDEX "idx_kehamilan_ibu_id" ON "public"."kehamilan" USING "btree" ("ibu_id");



CREATE INDEX "idx_keluhan_anak_anak_id" ON "public"."keluhan_anak" USING "btree" ("anak_id");



CREATE INDEX "idx_keluhan_anak_deleted_at" ON "public"."keluhan_anak" USING "btree" ("deleted_at");



CREATE INDEX "idx_keterangan_lahir_id_ibu_relasi" ON "public"."keterangan_lahir" USING "btree" ("id_ibu_relasi");



CREATE INDEX "idx_kunjungan_anak_anak_id" ON "public"."kunjungan_anak" USING "btree" ("anak_id");



CREATE INDEX "idx_kunjungan_anak_deleted_at" ON "public"."kunjungan_anak" USING "btree" ("deleted_at");



CREATE INDEX "idx_kunjungan_anak_kategori_umur_id" ON "public"."kunjungan_anak" USING "btree" ("kategori_umur_id");



CREATE INDEX "idx_kunjungan_anak_periode_id" ON "public"."kunjungan_anak" USING "btree" ("periode_id");



CREATE INDEX "idx_kunjungan_gizi_anak_id" ON "public"."kunjungan_gizi" USING "btree" ("anak_id");



CREATE INDEX "idx_kunjungan_gizi_deleted_at" ON "public"."kunjungan_gizi" USING "btree" ("deleted_at");



CREATE INDEX "idx_kunjungan_gizi_tenaga_kesehatan_id" ON "public"."kunjungan_gizi" USING "btree" ("tenaga_kesehatan_id");



CREATE INDEX "idx_kunjungan_vitamin_anak_id" ON "public"."kunjungan_vitamin" USING "btree" ("anak_id");



CREATE INDEX "idx_kunjungan_vitamin_deleted_at" ON "public"."kunjungan_vitamin" USING "btree" ("deleted_at");



CREATE INDEX "idx_lembar_lingkungan_ibu_id" ON "public"."lembar_lingkungan" USING "btree" ("ibu_id");



CREATE INDEX "idx_lembar_pemantauan_deleted_at" ON "public"."lembar_pemantauan" USING "btree" ("deleted_at");



CREATE INDEX "idx_lembar_pemantauan_ibu_deleted_at" ON "public"."lembar_pemantauan_ibu" USING "btree" ("deleted_at");



CREATE INDEX "idx_lembar_pemantauan_ibu_ibu_id" ON "public"."lembar_pemantauan_ibu" USING "btree" ("ibu_id");



CREATE INDEX "idx_log_ttd_mms_deleted_at" ON "public"."log_ttd_mms" USING "btree" ("deleted_at");



CREATE UNIQUE INDEX "idx_log_ttd_unique" ON "public"."log_ttd_mms" USING "btree" ("kehamilan_id", "bulan_ke", "hari_ke");



CREATE INDEX "idx_master_standar_antropometri_deleted_at" ON "public"."master_standar_antropometri" USING "btree" ("deleted_at");



CREATE INDEX "idx_master_standar_antropometri_parameter" ON "public"."master_standar_antropometri" USING "btree" ("parameter");



CREATE INDEX "idx_materi_mpasi_deleted_at" ON "public"."materi_mpasi" USING "btree" ("deleted_at");



CREATE INDEX "idx_mp_asi_deleted_at" ON "public"."mp_asi" USING "btree" ("deleted_at");



CREATE UNIQUE INDEX "idx_mp_asi_kunjungan_gizi_id" ON "public"."mp_asi" USING "btree" ("kunjungan_gizi_id", "kunjungan_gizi_id");



CREATE UNIQUE INDEX "idx_nifas_unique" ON "public"."checklist_pemantauan_ibu_nifas" USING "btree" ("kehamilan_id", "hari_nifas");



CREATE INDEX "idx_pelayanan_ibu_nifas_kehamilan_id" ON "public"."pelayanan_ibu_nifas" USING "btree" ("kehamilan_id");



CREATE UNIQUE INDEX "idx_pemantauan_hamil_unique" ON "public"."pemantauan_ibu_hamil" USING "btree" ("kehamilan_id", "minggu_kehamilan");



CREATE INDEX "idx_pemantauan_ibu_hamil_deleted_at" ON "public"."pemantauan_ibu_hamil" USING "btree" ("deleted_at");



CREATE INDEX "idx_pemantauan_indikator_kategori_usia" ON "public"."pemantauan_indikator" USING "btree" ("kategori_usia");



CREATE INDEX "idx_pemeriksaan_anak_deleted_at" ON "public"."pemeriksaan_anak" USING "btree" ("deleted_at");



CREATE INDEX "idx_pemeriksaan_anak_pemeriksa_id" ON "public"."pemeriksaan_anak" USING "btree" ("pemeriksa_id");



CREATE INDEX "idx_pemeriksaan_anak_penduduk_id" ON "public"."pemeriksaan_anak" USING "btree" ("penduduk_id");



CREATE INDEX "idx_pemeriksaan_dewasa_deleted_at" ON "public"."pemeriksaan_dewasa" USING "btree" ("deleted_at");



CREATE INDEX "idx_pemeriksaan_dewasa_pemeriksa_id" ON "public"."pemeriksaan_dewasa" USING "btree" ("pemeriksa_id");



CREATE INDEX "idx_pemeriksaan_dewasa_penduduk_id" ON "public"."pemeriksaan_dewasa" USING "btree" ("penduduk_id");



CREATE INDEX "idx_pemeriksaan_dokter_trimester_1_kehamilan_id" ON "public"."pemeriksaan_dokter_trimester_1" USING "btree" ("kehamilan_id");



CREATE INDEX "idx_pemeriksaan_dokter_trimester_3_kehamilan_id" ON "public"."pemeriksaan_dokter_trimester_3" USING "btree" ("kehamilan_id");



CREATE INDEX "idx_pemeriksaan_kehamilan_kehamilan_id" ON "public"."pemeriksaan_kehamilan" USING "btree" ("kehamilan_id");



CREATE INDEX "idx_pemeriksaan_laboratorium_jiwa_kehamilan_id" ON "public"."pemeriksaan_laboratorium_jiwa" USING "btree" ("kehamilan_id");



CREATE INDEX "idx_pemeriksaan_lanjutan_trimester_3_kehamilan_id" ON "public"."pemeriksaan_lanjutan_trimester_3" USING "btree" ("kehamilan_id");



CREATE INDEX "idx_pemeriksaan_lansia_deleted_at" ON "public"."pemeriksaan_lansia" USING "btree" ("deleted_at");



CREATE INDEX "idx_pemeriksaan_lansia_pemeriksa_id" ON "public"."pemeriksaan_lansia" USING "btree" ("pemeriksa_id");



CREATE INDEX "idx_pemeriksaan_lansia_penduduk_id" ON "public"."pemeriksaan_lansia" USING "btree" ("penduduk_id");



CREATE INDEX "idx_pemeriksaan_remaja_deleted_at" ON "public"."pemeriksaan_remaja" USING "btree" ("deleted_at");



CREATE INDEX "idx_pemeriksaan_remaja_pemeriksa_id" ON "public"."pemeriksaan_remaja" USING "btree" ("pemeriksa_id");



CREATE INDEX "idx_pemeriksaan_remaja_penduduk_id" ON "public"."pemeriksaan_remaja" USING "btree" ("penduduk_id");



CREATE INDEX "idx_pemeriksaans_deleted_at" ON "public"."pemeriksaans" USING "btree" ("deleted_at");



CREATE INDEX "idx_pemeriksaans_form_versi_id" ON "public"."pemeriksaans" USING "btree" ("form_versi_id");



CREATE INDEX "idx_pemeriksaans_kelompok" ON "public"."pemeriksaans" USING "btree" ("kelompok");



CREATE INDEX "idx_pemeriksaans_penduduk_id" ON "public"."pemeriksaans" USING "btree" ("penduduk_id");



CREATE INDEX "idx_pemeriksaans_petugas_id" ON "public"."pemeriksaans" USING "btree" ("petugas_id");



CREATE UNIQUE INDEX "idx_penduduk_nik" ON "public"."penduduk" USING "btree" ("nik");



CREATE UNIQUE INDEX "idx_pengguna_email" ON "public"."pengguna" USING "btree" ("email");



CREATE UNIQUE INDEX "idx_pengguna_phone_number" ON "public"."pengguna" USING "btree" ("nomor_telepon");



CREATE INDEX "idx_pengguna_role_id" ON "public"."pengguna" USING "btree" ("role_id");



CREATE INDEX "idx_pengukuran_lila_anak_id" ON "public"."pengukuran_lila" USING "btree" ("anak_id");



CREATE INDEX "idx_pengukuran_lila_deleted_at" ON "public"."pengukuran_lila" USING "btree" ("deleted_at");



CREATE INDEX "idx_penjelasan_hasil_grafik_kehamilan_id" ON "public"."penjelasan_hasil_grafik" USING "btree" ("kehamilan_id");



CREATE INDEX "idx_perangkat_deleted_at" ON "public"."perangkat" USING "btree" ("deleted_at");



CREATE INDEX "idx_perangkat_pengguna_id" ON "public"."perangkat" USING "btree" ("id_pengguna");



CREATE INDEX "idx_perawatan_deleted_at" ON "public"."perawatan" USING "btree" ("deleted_at");



CREATE INDEX "idx_periksa_gigi_anak_id" ON "public"."periksa_gigi" USING "btree" ("anak_id");



CREATE INDEX "idx_periksa_gigi_deleted_at" ON "public"."periksa_gigi" USING "btree" ("deleted_at");



CREATE INDEX "idx_periode_kunjungan_deleted_at" ON "public"."periode_kunjungan" USING "btree" ("deleted_at");



CREATE INDEX "idx_periode_kunjungan_kategori_umur_id" ON "public"."periode_kunjungan" USING "btree" ("kategori_umur_id");



CREATE INDEX "idx_persiapan_melahirkan_deleted_at" ON "public"."persiapan_melahirkan" USING "btree" ("deleted_at");



CREATE UNIQUE INDEX "idx_persiapan_melahirkan_kehamilan_id" ON "public"."persiapan_melahirkan" USING "btree" ("kehamilan_id", "kehamilan_id");



CREATE INDEX "idx_pertumbuhan_Anak_anak_id" ON "public"."pertumbuhan_Anak" USING "btree" ("anak_id");



CREATE INDEX "idx_pertumbuhan_Anak_deleted_at" ON "public"."pertumbuhan_Anak" USING "btree" ("deleted_at");



CREATE INDEX "idx_prediksi_stunting_anak_id" ON "public"."prediksi_stunting" USING "btree" ("anak_id");



CREATE INDEX "idx_prediksi_stunting_deleted_at" ON "public"."prediksi_stunting" USING "btree" ("deleted_at");



CREATE INDEX "idx_proses_melahirkan_deleted_at" ON "public"."proses_melahirkan" USING "btree" ("deleted_at");



CREATE INDEX "idx_proses_melahirkan_kehamilan_id" ON "public"."proses_melahirkan" USING "btree" ("kehamilan_id");



CREATE INDEX "idx_rencana_persalinan_kehamilan_id" ON "public"."rencana_persalinan" USING "btree" ("kehamilan_id");



CREATE INDEX "idx_request_perubahan_imunisasi_id_jadwal_imunisasi" ON "public"."request_perubahan_imunisasi" USING "btree" ("id_jadwal_imunisasi");



CREATE INDEX "idx_request_perubahan_imunisasi_id_status_request" ON "public"."request_perubahan_imunisasi" USING "btree" ("id_status_request");



CREATE INDEX "idx_resep_mpasi_deleted_at" ON "public"."resep_mpasi" USING "btree" ("deleted_at");



CREATE INDEX "idx_ringkasan_pelayanan_persalinan_kehamilan_id" ON "public"."ringkasan_pelayanan_persalinan" USING "btree" ("kehamilan_id");



CREATE INDEX "idx_riwayat_kehamilan_lalu_id_evaluasi" ON "public"."riwayat_kehamilan_lalu" USING "btree" ("id_evaluasi");



CREATE INDEX "idx_riwayat_proses_melahirkan_kehamilan_id" ON "public"."riwayat_proses_melahirkan" USING "btree" ("kehamilan_id");



CREATE UNIQUE INDEX "idx_roles_name" ON "public"."roles" USING "btree" ("name");



CREATE INDEX "idx_rujukan_kehamilan_id" ON "public"."rujukan" USING "btree" ("kehamilan_id");



CREATE INDEX "idx_rujukan_source" ON "public"."rujukan" USING "btree" ("source");



CREATE INDEX "idx_skrining_dm_gestasional_kehamilan_id" ON "public"."skrining_dm_gestasional" USING "btree" ("kehamilan_id");



CREATE INDEX "idx_skrining_pemantauan_anak_id" ON "public"."skrining_pemantauan" USING "btree" ("anak_id");



CREATE INDEX "idx_skrining_pemantauan_deleted_at" ON "public"."skrining_pemantauan" USING "btree" ("deleted_at");



CREATE INDEX "idx_skrining_pemantauan_kategori_tanda_bahaya_id" ON "public"."skrining_pemantauan" USING "btree" ("kategori_tanda_bahaya_id");



CREATE INDEX "idx_skrining_preeklampsia_kehamilan_id" ON "public"."skrining_preeklampsia" USING "btree" ("kehamilan_id");



CREATE INDEX "idx_vaksin_deleted_at" ON "public"."vaksin" USING "btree" ("deleted_at");



CREATE INDEX "idx_warna_tinja_anak_deleted_at" ON "public"."warna_tinja_anak" USING "btree" ("deleted_at");



CREATE UNIQUE INDEX "idx_warna_tinja_anak_periode" ON "public"."warna_tinja_anak" USING "btree" ("anak_id", "periode_key");



CREATE INDEX "ix_puskesmas_deleted_at" ON "public"."puskesmas" USING "btree" ("deleted_at");



CREATE OR REPLACE TRIGGER "update_puskesmas_updated_at" BEFORE UPDATE ON "public"."puskesmas" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



ALTER TABLE ONLY "public"."aturan_vaksin_anak"
    ADD CONSTRAINT "aturan_vaksin_anak_id_dosis_sebelum_fkey" FOREIGN KEY ("id_dosis_sebelum") REFERENCES "public"."dosis_vaksin"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."catatan_pelayanan_trimester"
    ADD CONSTRAINT "catatan_pelayanan_trimester_kategori_trimester_id_fkey" FOREIGN KEY ("kategori_trimester_id") REFERENCES "public"."kategori_trimester"("id");



ALTER TABLE ONLY "public"."catatan_pelayanan_trimester"
    ADD CONSTRAINT "catatan_pelayanan_trimester_kehamilan_id_fkey" FOREIGN KEY ("kehamilan_id") REFERENCES "public"."kehamilan"("id");



ALTER TABLE ONLY "public"."dusun"
    ADD CONSTRAINT "dusun_desa_id_fkey" FOREIGN KEY ("desa_id") REFERENCES "public"."desa"("id");



ALTER TABLE ONLY "public"."Neonatus"
    ADD CONSTRAINT "fk_Neonatus_anak" FOREIGN KEY ("anak_id") REFERENCES "public"."anak"("id");



ALTER TABLE ONLY "public"."detail_pelayanan_neonatus"
    ADD CONSTRAINT "fk_Neonatus_detail_pelayanan" FOREIGN KEY ("neonatus_id") REFERENCES "public"."Neonatus"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."Neonatus"
    ADD CONSTRAINT "fk_Neonatus_kategori_umur" FOREIGN KEY ("kategori_umur_id") REFERENCES "public"."Kategori_umur"("id");



ALTER TABLE ONLY "public"."Neonatus"
    ADD CONSTRAINT "fk_Neonatus_periode" FOREIGN KEY ("periode_id") REFERENCES "public"."periode_kunjungan"("id");



ALTER TABLE ONLY "public"."Neonatus"
    ADD CONSTRAINT "fk_Neonatus_tenaga_kesehatan" FOREIGN KEY ("tenaga_kesehatan_id") REFERENCES "public"."pengguna"("id");



ALTER TABLE ONLY "public"."absensi_kelas_ibu_balita"
    ADD CONSTRAINT "fk_absensi_kelas_ibu_balita_ibu" FOREIGN KEY ("ibu_id") REFERENCES "public"."ibu"("id");



ALTER TABLE ONLY "public"."absensi_kelas_ibu_hamil"
    ADD CONSTRAINT "fk_absensi_kelas_ibu_hamil_kehamilan" FOREIGN KEY ("kehamilan_id") REFERENCES "public"."kehamilan"("id");



ALTER TABLE ONLY "public"."anak"
    ADD CONSTRAINT "fk_anak_penduduk" FOREIGN KEY ("penduduk_id") REFERENCES "public"."penduduk"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."aturan_pelayanans"
    ADD CONSTRAINT "fk_aturan_pelayanans_jenis_pelayanan" FOREIGN KEY ("jenis_pelayanan_id") REFERENCES "public"."jenis_pelayanan"("id");



ALTER TABLE ONLY "public"."aturan_vaksin_anak"
    ADD CONSTRAINT "fk_aturan_vaksin_anak_dosis_sebelumnya" FOREIGN KEY ("id_dosis_sebelumnya") REFERENCES "public"."dosis_vaksin"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."aturan_vaksin_anak"
    ADD CONSTRAINT "fk_aturan_vaksin_anak_dosis_vaksin" FOREIGN KEY ("id_dosis_vaksin") REFERENCES "public"."dosis_vaksin"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."bbl"
    ADD CONSTRAINT "fk_bbl_anak" FOREIGN KEY ("anak_id") REFERENCES "public"."anak"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."bbl_check"
    ADD CONSTRAINT "fk_bbl_check_bbl" FOREIGN KEY ("bbl_id") REFERENCES "public"."bbl"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."bbl_check"
    ADD CONSTRAINT "fk_bbl_check_kader" FOREIGN KEY ("verified_by_kader_id") REFERENCES "public"."kader"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."bbl_check"
    ADD CONSTRAINT "fk_bbl_check_verified_by_kader" FOREIGN KEY ("verified_by_kader_id") REFERENCES "public"."kader"("id");



ALTER TABLE ONLY "public"."bbl_check"
    ADD CONSTRAINT "fk_bbl_checklist" FOREIGN KEY ("bbl_id") REFERENCES "public"."bbl"("id");



ALTER TABLE ONLY "public"."bidan"
    ADD CONSTRAINT "fk_bidan_penduduk" FOREIGN KEY ("penduduk_id") REFERENCES "public"."penduduk"("id");



ALTER TABLE ONLY "public"."catatan_pelayanan_kehamilan"
    ADD CONSTRAINT "fk_catatan_kehamilan" FOREIGN KEY ("kehamilan_id") REFERENCES "public"."kehamilan"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."catatan_pelayanan"
    ADD CONSTRAINT "fk_catatan_pelayanan_anak" FOREIGN KEY ("anak_id") REFERENCES "public"."anak"("id");



ALTER TABLE ONLY "public"."catatan_pelayanan"
    ADD CONSTRAINT "fk_catatan_pelayanan_tenaga_kesehatan" FOREIGN KEY ("tenaga_kesehatan_id") REFERENCES "public"."pengguna"("id");



ALTER TABLE ONLY "public"."catatan_pelayanan_trimester_1"
    ADD CONSTRAINT "fk_catatan_pelayanan_trimester_1_kehamilan" FOREIGN KEY ("kehamilan_id") REFERENCES "public"."kehamilan"("id");



ALTER TABLE ONLY "public"."catatan_pelayanan_trimester_2"
    ADD CONSTRAINT "fk_catatan_pelayanan_trimester_2_kehamilan" FOREIGN KEY ("kehamilan_id") REFERENCES "public"."kehamilan"("id");



ALTER TABLE ONLY "public"."catatan_pelayanan_trimester_3"
    ADD CONSTRAINT "fk_catatan_pelayanan_trimester_3_kehamilan" FOREIGN KEY ("kehamilan_id") REFERENCES "public"."kehamilan"("id");



ALTER TABLE ONLY "public"."catatan_pertumbuhan"
    ADD CONSTRAINT "fk_catatan_pertumbuhan_anak" FOREIGN KEY ("anak_id") REFERENCES "public"."anak"("id") ON UPDATE CASCADE ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."checklist_pemantauan_ibu_nifas"
    ADD CONSTRAINT "fk_checklist_pemantauan_ibu_nifas_kehamilan" FOREIGN KEY ("kehamilan_id") REFERENCES "public"."kehamilan"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."detail_lingkungan"
    ADD CONSTRAINT "fk_detail_lingkungan_indikator" FOREIGN KEY ("indikator_lingkungan_id") REFERENCES "public"."indikator_lingkungan"("id");



ALTER TABLE ONLY "public"."detail_pelayanan_imunisasi"
    ADD CONSTRAINT "fk_detail_pelayanan_imunisasi_jenis_pelayanan" FOREIGN KEY ("jenis_pelayanan_id") REFERENCES "public"."jenis_pelayanan"("id");



ALTER TABLE ONLY "public"."detail_pelayanan_neonatus"
    ADD CONSTRAINT "fk_detail_pelayanan_neonatus_jenis_pelayanan" FOREIGN KEY ("jenis_pelayanan_id") REFERENCES "public"."jenis_pelayanan"("id");



ALTER TABLE ONLY "public"."detail_pelayanan_vitamin"
    ADD CONSTRAINT "fk_detail_pelayanan_vitamin_jenis_pelayanan" FOREIGN KEY ("jenis_pelayanan_id") REFERENCES "public"."jenis_pelayanan"("id");



ALTER TABLE ONLY "public"."detail_pemantauan_ibu"
    ADD CONSTRAINT "fk_detail_pemantauan_ibu_kategori_pemantauan" FOREIGN KEY ("kategori_pemantauan_id") REFERENCES "public"."kategori_pemantauan_ibu"("id");



ALTER TABLE ONLY "public"."detail_pemantauan"
    ADD CONSTRAINT "fk_detail_pemantauan_kategori_tanda_sakit" FOREIGN KEY ("kategori_tanda_sakit_id") REFERENCES "public"."kategori_tanda_sakit"("id") ON UPDATE CASCADE ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."deteksi_dini_penyimpangan"
    ADD CONSTRAINT "fk_deteksi_dini_penyimpangan_anak" FOREIGN KEY ("anak_id") REFERENCES "public"."anak"("id");



ALTER TABLE ONLY "public"."deteksi_dini_penyimpangan"
    ADD CONSTRAINT "fk_deteksi_dini_penyimpangan_tenaga_kesehatan" FOREIGN KEY ("tenaga_kesehatan_id") REFERENCES "public"."pengguna"("id");



ALTER TABLE ONLY "public"."dosis_vaksin"
    ADD CONSTRAINT "fk_dosis_vaksin_vaksin" FOREIGN KEY ("id_vaksin") REFERENCES "public"."vaksin"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."evaluasi_kesehatan_ibu"
    ADD CONSTRAINT "fk_evaluasi_kesehatan_ibu_kehamilan" FOREIGN KEY ("kehamilan_id") REFERENCES "public"."kehamilan"("id");



ALTER TABLE ONLY "public"."form_aturan_risikos"
    ADD CONSTRAINT "fk_form_versis_aturan_risiko" FOREIGN KEY ("form_versi_id") REFERENCES "public"."form_versis"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."form_pertanyaans"
    ADD CONSTRAINT "fk_form_versis_pertanyaan" FOREIGN KEY ("form_versi_id") REFERENCES "public"."form_versis"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."grafik_evaluasi_kehamilan"
    ADD CONSTRAINT "fk_grafik_evaluasi_kehamilan_kehamilan" FOREIGN KEY ("kehamilan_id") REFERENCES "public"."kehamilan"("id");



ALTER TABLE ONLY "public"."grafik_peningkatan_bb"
    ADD CONSTRAINT "fk_grafik_peningkatan_bb_kehamilan" FOREIGN KEY ("kehamilan_id") REFERENCES "public"."kehamilan"("id");



ALTER TABLE ONLY "public"."jadwal_imunisasi_anak"
    ADD CONSTRAINT "fk_jadwal_imunisasi_anak_anak" FOREIGN KEY ("id_anak") REFERENCES "public"."anak"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."jadwal_imunisasi_anak"
    ADD CONSTRAINT "fk_jadwal_imunisasi_anak_dosis_vaksin" FOREIGN KEY ("id_dosis_vaksin") REFERENCES "public"."dosis_vaksin"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."jadwal_imunisasi_anak"
    ADD CONSTRAINT "fk_jadwal_imunisasi_anak_status_jadwal" FOREIGN KEY ("id_status_jadwal") REFERENCES "public"."status_jadwal"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."jadwal_layanan_dosis_vaksin"
    ADD CONSTRAINT "fk_jadwal_layanan_dosis_vaksin_dosis_vaksin" FOREIGN KEY ("dosis_vaksin_id") REFERENCES "public"."dosis_vaksin"("id");



ALTER TABLE ONLY "public"."jadwal_layanan_dosis_vaksin"
    ADD CONSTRAINT "fk_jadwal_layanan_dosis_vaksin_jadwal_layanan" FOREIGN KEY ("jadwal_layanan_id") REFERENCES "public"."jadwal_layanan"("id");



ALTER TABLE ONLY "public"."jadwal_layanan"
    ADD CONSTRAINT "fk_jadwal_layanan_posyandu" FOREIGN KEY ("posyandu_id") REFERENCES "public"."posyandu"("id");



ALTER TABLE ONLY "public"."jenis_pelayanan_kategori"
    ADD CONSTRAINT "fk_jenis_pelayanan_kategori_jenis_pelayanan" FOREIGN KEY ("jenis_pelayanan_id") REFERENCES "public"."jenis_pelayanan"("id");



ALTER TABLE ONLY "public"."jenis_pelayanan_kategori"
    ADD CONSTRAINT "fk_jenis_pelayanan_kategori_kategori_umur" FOREIGN KEY ("kategori_umur_id") REFERENCES "public"."Kategori_umur"("id");



ALTER TABLE ONLY "public"."jenis_pelayanan_kategori"
    ADD CONSTRAINT "fk_jenis_pelayanan_kategori_periode" FOREIGN KEY ("periode_id") REFERENCES "public"."periode_kunjungan"("id");



ALTER TABLE ONLY "public"."jadwal_layanan_vaksin"
    ADD CONSTRAINT "fk_jlv_jadwal_layanan" FOREIGN KEY ("jadwal_layanan_id") REFERENCES "public"."jadwal_layanan"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."jadwal_layanan_vaksin"
    ADD CONSTRAINT "fk_jlv_vaksin" FOREIGN KEY ("vaksin_id") REFERENCES "public"."vaksin"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."kader"
    ADD CONSTRAINT "fk_kader_penduduk" FOREIGN KEY ("id_penduduk") REFERENCES "public"."penduduk"("id");



ALTER TABLE ONLY "public"."kader_posyandu"
    ADD CONSTRAINT "fk_kader_posyandu_user" FOREIGN KEY ("user_id") REFERENCES "public"."pengguna"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."indikator_lingkungan"
    ADD CONSTRAINT "fk_kategori_lingkungan_indikator" FOREIGN KEY ("kategori_lingkungan_id") REFERENCES "public"."kategori_lingkungan"("id");



ALTER TABLE ONLY "public"."kategori_tanda_sakit"
    ADD CONSTRAINT "fk_kategori_tanda_sakit_rentang_usia" FOREIGN KEY ("rentang_usia_id") REFERENCES "public"."rentang_usia"("id") ON UPDATE CASCADE ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."kehadiran_imunisasi"
    ADD CONSTRAINT "fk_kehadiran_imunisasi_anak" FOREIGN KEY ("anak_id") REFERENCES "public"."anak"("id");



ALTER TABLE ONLY "public"."detail_pelayanan_imunisasi"
    ADD CONSTRAINT "fk_kehadiran_imunisasi_detail" FOREIGN KEY ("kunjungan_imunisasi_id") REFERENCES "public"."kehadiran_imunisasi"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."anak"
    ADD CONSTRAINT "fk_kehamilan_anak" FOREIGN KEY ("kehamilan_id") REFERENCES "public"."kehamilan"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."kehamilan"
    ADD CONSTRAINT "fk_kehamilan_ibu" FOREIGN KEY ("ibu_id") REFERENCES "public"."ibu"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."keluhan_anak"
    ADD CONSTRAINT "fk_keluhan_anak_anak" FOREIGN KEY ("anak_id") REFERENCES "public"."anak"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."keterangan_lahir"
    ADD CONSTRAINT "fk_keterangan_lahir_ibu" FOREIGN KEY ("id_ibu_relasi") REFERENCES "public"."ibu"("id");



ALTER TABLE ONLY "public"."keterangan_lahir"
    ADD CONSTRAINT "fk_keterangan_lahir_ringkasan" FOREIGN KEY ("ringkasan_pelayanan_persalinan_id") REFERENCES "public"."ringkasan_pelayanan_persalinan"("id");



ALTER TABLE ONLY "public"."kunjungan_anak"
    ADD CONSTRAINT "fk_kunjungan_anak_anak" FOREIGN KEY ("anak_id") REFERENCES "public"."anak"("id");



ALTER TABLE ONLY "public"."kunjungan_anak"
    ADD CONSTRAINT "fk_kunjungan_anak_kategori_umur" FOREIGN KEY ("kategori_umur_id") REFERENCES "public"."Kategori_umur"("id");



ALTER TABLE ONLY "public"."kunjungan_anak"
    ADD CONSTRAINT "fk_kunjungan_anak_periode" FOREIGN KEY ("periode_id") REFERENCES "public"."periode_kunjungan"("id");



ALTER TABLE ONLY "public"."kunjungan_gizi"
    ADD CONSTRAINT "fk_kunjungan_gizi_anak" FOREIGN KEY ("anak_id") REFERENCES "public"."anak"("id");



ALTER TABLE ONLY "public"."Pelayanan_Asi"
    ADD CONSTRAINT "fk_kunjungan_gizi_asi" FOREIGN KEY ("kunjungan_gizi_id") REFERENCES "public"."kunjungan_gizi"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."mp_asi"
    ADD CONSTRAINT "fk_kunjungan_gizi_mpasi" FOREIGN KEY ("kunjungan_gizi_id") REFERENCES "public"."kunjungan_gizi"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."kunjungan_gizi"
    ADD CONSTRAINT "fk_kunjungan_gizi_tenaga_kesehatan" FOREIGN KEY ("tenaga_kesehatan_id") REFERENCES "public"."pengguna"("id");



ALTER TABLE ONLY "public"."kunjungan_imunisasi"
    ADD CONSTRAINT "fk_kunjungan_imunisasi_status_kunjungan" FOREIGN KEY ("status") REFERENCES "public"."status_kunjungan"("id");



ALTER TABLE ONLY "public"."kunjungan_vitamin"
    ADD CONSTRAINT "fk_kunjungan_vitamin_anak" FOREIGN KEY ("anak_id") REFERENCES "public"."anak"("id");



ALTER TABLE ONLY "public"."detail_pelayanan_vitamin"
    ADD CONSTRAINT "fk_kunjungan_vitamin_detail" FOREIGN KEY ("kunjungan_vitamin_id") REFERENCES "public"."kunjungan_vitamin"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."detail_lingkungan"
    ADD CONSTRAINT "fk_lembar_lingkungan_detail_jawaban" FOREIGN KEY ("lembar_lingkungan_id") REFERENCES "public"."lembar_lingkungan"("id");



ALTER TABLE ONLY "public"."lembar_lingkungan"
    ADD CONSTRAINT "fk_lembar_lingkungan_ibu" FOREIGN KEY ("ibu_id") REFERENCES "public"."ibu"("id");



ALTER TABLE ONLY "public"."lembar_pemantauan"
    ADD CONSTRAINT "fk_lembar_pemantauan_anak" FOREIGN KEY ("anak_id") REFERENCES "public"."anak"("id") ON UPDATE CASCADE ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."detail_pemantauan"
    ADD CONSTRAINT "fk_lembar_pemantauan_detail_gejala" FOREIGN KEY ("lembar_pemantauan_id") REFERENCES "public"."lembar_pemantauan"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."detail_pemantauan_ibu"
    ADD CONSTRAINT "fk_lembar_pemantauan_ibu_detail_gejala" FOREIGN KEY ("lembar_pemantauan_ibu_id") REFERENCES "public"."lembar_pemantauan_ibu"("id");



ALTER TABLE ONLY "public"."lembar_pemantauan_ibu"
    ADD CONSTRAINT "fk_lembar_pemantauan_ibu_ibu" FOREIGN KEY ("ibu_id") REFERENCES "public"."ibu"("id");



ALTER TABLE ONLY "public"."lembar_pemantauan"
    ADD CONSTRAINT "fk_lembar_pemantauan_rentang_usia" FOREIGN KEY ("rentang_usia_id") REFERENCES "public"."rentang_usia"("id") ON UPDATE CASCADE ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."log_ttd_mms"
    ADD CONSTRAINT "fk_log_ttd_mms_kehamilan" FOREIGN KEY ("kehamilan_id") REFERENCES "public"."kehamilan"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."pelayanan_ibu_nifas"
    ADD CONSTRAINT "fk_pelayanan_ibu_nifas_kehamilan" FOREIGN KEY ("kehamilan_id") REFERENCES "public"."kehamilan"("id");



ALTER TABLE ONLY "public"."pemantauan_ibu_hamil"
    ADD CONSTRAINT "fk_pemantauan_ibu_hamil_kehamilan" FOREIGN KEY ("kehamilan_id") REFERENCES "public"."kehamilan"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."pemeriksaan_anak"
    ADD CONSTRAINT "fk_pemeriksaan_anak_pemeriksa" FOREIGN KEY ("pemeriksa_id") REFERENCES "public"."pengguna"("id");



ALTER TABLE ONLY "public"."pemeriksaan_anak"
    ADD CONSTRAINT "fk_pemeriksaan_anak_penduduk" FOREIGN KEY ("penduduk_id") REFERENCES "public"."penduduk"("id");



ALTER TABLE ONLY "public"."pemeriksaan_dewasa"
    ADD CONSTRAINT "fk_pemeriksaan_dewasa_pemeriksa" FOREIGN KEY ("pemeriksa_id") REFERENCES "public"."pengguna"("id");



ALTER TABLE ONLY "public"."pemeriksaan_dewasa"
    ADD CONSTRAINT "fk_pemeriksaan_dewasa_penduduk" FOREIGN KEY ("penduduk_id") REFERENCES "public"."penduduk"("id");



ALTER TABLE ONLY "public"."pemeriksaan_dokter_trimester_1"
    ADD CONSTRAINT "fk_pemeriksaan_dokter_trimester_1_kehamilan" FOREIGN KEY ("kehamilan_id") REFERENCES "public"."kehamilan"("id");



ALTER TABLE ONLY "public"."pemeriksaan_dokter_trimester_3"
    ADD CONSTRAINT "fk_pemeriksaan_dokter_trimester_3_kehamilan" FOREIGN KEY ("kehamilan_id") REFERENCES "public"."kehamilan"("id");



ALTER TABLE ONLY "public"."pemeriksaan_kehamilan"
    ADD CONSTRAINT "fk_pemeriksaan_kehamilan_kehamilan" FOREIGN KEY ("kehamilan_id") REFERENCES "public"."kehamilan"("id");



ALTER TABLE ONLY "public"."pemeriksaan_laboratorium_jiwa"
    ADD CONSTRAINT "fk_pemeriksaan_laboratorium_jiwa_kehamilan" FOREIGN KEY ("kehamilan_id") REFERENCES "public"."kehamilan"("id");



ALTER TABLE ONLY "public"."pemeriksaan_lanjutan_trimester_3"
    ADD CONSTRAINT "fk_pemeriksaan_lanjutan_trimester_3_kehamilan" FOREIGN KEY ("kehamilan_id") REFERENCES "public"."kehamilan"("id");



ALTER TABLE ONLY "public"."pemeriksaan_lansia"
    ADD CONSTRAINT "fk_pemeriksaan_lansia_pemeriksa" FOREIGN KEY ("pemeriksa_id") REFERENCES "public"."pengguna"("id");



ALTER TABLE ONLY "public"."pemeriksaan_lansia"
    ADD CONSTRAINT "fk_pemeriksaan_lansia_penduduk" FOREIGN KEY ("penduduk_id") REFERENCES "public"."penduduk"("id");



ALTER TABLE ONLY "public"."pemeriksaan_remaja"
    ADD CONSTRAINT "fk_pemeriksaan_remaja_pemeriksa" FOREIGN KEY ("pemeriksa_id") REFERENCES "public"."pengguna"("id");



ALTER TABLE ONLY "public"."pemeriksaan_remaja"
    ADD CONSTRAINT "fk_pemeriksaan_remaja_penduduk" FOREIGN KEY ("penduduk_id") REFERENCES "public"."penduduk"("id");



ALTER TABLE ONLY "public"."pemeriksaans"
    ADD CONSTRAINT "fk_pemeriksaans_form_versi" FOREIGN KEY ("form_versi_id") REFERENCES "public"."form_versis"("id");



ALTER TABLE ONLY "public"."pemeriksaans"
    ADD CONSTRAINT "fk_pemeriksaans_penduduk" FOREIGN KEY ("penduduk_id") REFERENCES "public"."penduduk"("id");



ALTER TABLE ONLY "public"."pemeriksaans"
    ADD CONSTRAINT "fk_pemeriksaans_petugas" FOREIGN KEY ("petugas_id") REFERENCES "public"."pengguna"("id");



ALTER TABLE ONLY "public"."penduduk"
    ADD CONSTRAINT "fk_penduduk_desa" FOREIGN KEY ("desa_id") REFERENCES "public"."desa"("id");



ALTER TABLE ONLY "public"."pengguna"
    ADD CONSTRAINT "fk_pengguna_role" FOREIGN KEY ("role_id") REFERENCES "public"."roles"("id");



ALTER TABLE ONLY "public"."pengukuran_lila"
    ADD CONSTRAINT "fk_pengukuran_lila_anak" FOREIGN KEY ("anak_id") REFERENCES "public"."anak"("id");



ALTER TABLE ONLY "public"."penjelasan_hasil_grafik"
    ADD CONSTRAINT "fk_penjelasan_hasil_grafik_kehamilan" FOREIGN KEY ("kehamilan_id") REFERENCES "public"."kehamilan"("id");



ALTER TABLE ONLY "public"."perangkat"
    ADD CONSTRAINT "fk_perangkat_pengguna" FOREIGN KEY ("id_pengguna") REFERENCES "public"."pengguna"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."perawatan"
    ADD CONSTRAINT "fk_perawatan_anak" FOREIGN KEY ("anak_id") REFERENCES "public"."anak"("id") ON UPDATE CASCADE ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."perawatan"
    ADD CONSTRAINT "fk_perawatan_kategori_capaian" FOREIGN KEY ("kategori_capaian_id") REFERENCES "public"."kategori_capaian"("id") ON UPDATE CASCADE ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."periksa_gigi"
    ADD CONSTRAINT "fk_periksa_gigi_anak" FOREIGN KEY ("anak_id") REFERENCES "public"."anak"("id");



ALTER TABLE ONLY "public"."periode_kunjungan"
    ADD CONSTRAINT "fk_periode_kunjungan_kategori_umur" FOREIGN KEY ("kategori_umur_id") REFERENCES "public"."Kategori_umur"("id");



ALTER TABLE ONLY "public"."persiapan_melahirkan"
    ADD CONSTRAINT "fk_persiapan_melahirkan_kehamilan" FOREIGN KEY ("kehamilan_id") REFERENCES "public"."kehamilan"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."pertumbuhan_Anak"
    ADD CONSTRAINT "fk_pertumbuhan_Anak_anak" FOREIGN KEY ("anak_id") REFERENCES "public"."anak"("id");



ALTER TABLE ONLY "public"."prediksi_stunting"
    ADD CONSTRAINT "fk_prediksi_stunting_anak" FOREIGN KEY ("anak_id") REFERENCES "public"."anak"("id") ON UPDATE CASCADE ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."proses_melahirkan"
    ADD CONSTRAINT "fk_proses_melahirkan_kehamilan" FOREIGN KEY ("kehamilan_id") REFERENCES "public"."kehamilan"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."rencana_persalinan"
    ADD CONSTRAINT "fk_rencana_persalinan_kehamilan" FOREIGN KEY ("kehamilan_id") REFERENCES "public"."kehamilan"("id");



ALTER TABLE ONLY "public"."request_perubahan_imunisasi"
    ADD CONSTRAINT "fk_request_perubahan_imunisasi_jadwal_imunisasi_anak" FOREIGN KEY ("id_jadwal_imunisasi") REFERENCES "public"."jadwal_imunisasi_anak"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."request_perubahan_imunisasi"
    ADD CONSTRAINT "fk_request_perubahan_imunisasi_status_request" FOREIGN KEY ("id_status_request") REFERENCES "public"."status_request"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."ringkasan_pelayanan_persalinan"
    ADD CONSTRAINT "fk_ringkasan_pelayanan_persalinan_kehamilan" FOREIGN KEY ("kehamilan_id") REFERENCES "public"."kehamilan"("id");



ALTER TABLE ONLY "public"."riwayat_proses_melahirkan"
    ADD CONSTRAINT "fk_riwayat_proses_melahirkan_kehamilan" FOREIGN KEY ("kehamilan_id") REFERENCES "public"."kehamilan"("id");



ALTER TABLE ONLY "public"."rujukan"
    ADD CONSTRAINT "fk_rujukan_kehamilan" FOREIGN KEY ("kehamilan_id") REFERENCES "public"."kehamilan"("id");



ALTER TABLE ONLY "public"."skrining_dm_gestasional"
    ADD CONSTRAINT "fk_skrining_dm_gestasional_kehamilan" FOREIGN KEY ("kehamilan_id") REFERENCES "public"."kehamilan"("id");



ALTER TABLE ONLY "public"."skrining_pemantauan"
    ADD CONSTRAINT "fk_skrining_pemantauan_anak" FOREIGN KEY ("anak_id") REFERENCES "public"."anak"("id");



ALTER TABLE ONLY "public"."skrining_pemantauan"
    ADD CONSTRAINT "fk_skrining_pemantauan_kategori_tanda_bahaya" FOREIGN KEY ("kategori_tanda_bahaya_id") REFERENCES "public"."kategori_tanda_bahaya"("id");



ALTER TABLE ONLY "public"."skrining_preeklampsia"
    ADD CONSTRAINT "fk_skrining_preeklampsia_kehamilan" FOREIGN KEY ("kehamilan_id") REFERENCES "public"."kehamilan"("id");



ALTER TABLE ONLY "public"."dosis_vaksin"
    ADD CONSTRAINT "fk_vaksin_dosis_vaksins" FOREIGN KEY ("id_vaksin") REFERENCES "public"."vaksin"("id");



ALTER TABLE ONLY "public"."warna_tinja_anak"
    ADD CONSTRAINT "fk_warna_tinja_anak_anak" FOREIGN KEY ("anak_id") REFERENCES "public"."anak"("id") ON UPDATE CASCADE ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."ibu"
    ADD CONSTRAINT "ibu_penduduk_id_fkey" FOREIGN KEY ("penduduk_id") REFERENCES "public"."penduduk"("id");



ALTER TABLE ONLY "public"."ibu"
    ADD CONSTRAINT "ibu_suami_id_fkey" FOREIGN KEY ("suami_id") REFERENCES "public"."penduduk"("id");



ALTER TABLE ONLY "public"."jadwal_layanan_dosis_vaksin"
    ADD CONSTRAINT "jadwal_layanan_dosis_vaksin_dosis_vaksin_id_fkey" FOREIGN KEY ("dosis_vaksin_id") REFERENCES "public"."dosis_vaksin"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."jadwal_layanan_dosis_vaksin"
    ADD CONSTRAINT "jadwal_layanan_dosis_vaksin_jadwal_layanan_id_fkey" FOREIGN KEY ("jadwal_layanan_id") REFERENCES "public"."jadwal_layanan"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."kunjungan_imunisasi"
    ADD CONSTRAINT "kunjungan_imunisasi_id_jadwal_imunisasi_fkey" FOREIGN KEY ("id_jadwal_imunisasi") REFERENCES "public"."jadwal_imunisasi_anak"("id");



ALTER TABLE ONLY "public"."kunjungan_imunisasi"
    ADD CONSTRAINT "kunjungan_imunisasi_id_status_kunjungan_fkey" FOREIGN KEY ("id_status_kunjungan") REFERENCES "public"."status_kunjungan"("id");



ALTER TABLE ONLY "public"."penduduk"
    ADD CONSTRAINT "penduduk_kartu_keluarga_id_fkey" FOREIGN KEY ("kartu_keluarga_id") REFERENCES "public"."kartu_keluarga"("id");



ALTER TABLE ONLY "public"."pengguna"
    ADD CONSTRAINT "pengguna_penduduk_id_fkey" FOREIGN KEY ("penduduk_id") REFERENCES "public"."penduduk"("id");



ALTER TABLE ONLY "public"."status"
    ADD CONSTRAINT "status_id_kategori_status_fkey" FOREIGN KEY ("id_kategori_status") REFERENCES "public"."kategori_status"("id");



ALTER TABLE "public"."catatan_pelayanan_kehamilan" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."catatan_pelayanan_trimester" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."kategori_capaian" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."kategori_status" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."kategori_trimester" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."status" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


REVOKE USAGE ON SCHEMA "public" FROM PUBLIC;




































































































































































































drop extension if exists "pg_net";

revoke references on table "public"."Kategori_umur" from "anon";

revoke trigger on table "public"."Kategori_umur" from "anon";

revoke truncate on table "public"."Kategori_umur" from "anon";

revoke references on table "public"."Kategori_umur" from "authenticated";

revoke trigger on table "public"."Kategori_umur" from "authenticated";

revoke truncate on table "public"."Kategori_umur" from "authenticated";

revoke references on table "public"."Kategori_umur" from "service_role";

revoke trigger on table "public"."Kategori_umur" from "service_role";

revoke truncate on table "public"."Kategori_umur" from "service_role";

revoke references on table "public"."Neonatus" from "anon";

revoke trigger on table "public"."Neonatus" from "anon";

revoke truncate on table "public"."Neonatus" from "anon";

revoke references on table "public"."Neonatus" from "authenticated";

revoke trigger on table "public"."Neonatus" from "authenticated";

revoke truncate on table "public"."Neonatus" from "authenticated";

revoke references on table "public"."Neonatus" from "service_role";

revoke trigger on table "public"."Neonatus" from "service_role";

revoke truncate on table "public"."Neonatus" from "service_role";

revoke references on table "public"."Pelayanan_Asi" from "anon";

revoke trigger on table "public"."Pelayanan_Asi" from "anon";

revoke truncate on table "public"."Pelayanan_Asi" from "anon";

revoke references on table "public"."Pelayanan_Asi" from "authenticated";

revoke trigger on table "public"."Pelayanan_Asi" from "authenticated";

revoke truncate on table "public"."Pelayanan_Asi" from "authenticated";

revoke references on table "public"."Pelayanan_Asi" from "service_role";

revoke trigger on table "public"."Pelayanan_Asi" from "service_role";

revoke truncate on table "public"."Pelayanan_Asi" from "service_role";

revoke references on table "public"."absensi_kelas_ibu_balita" from "anon";

revoke trigger on table "public"."absensi_kelas_ibu_balita" from "anon";

revoke truncate on table "public"."absensi_kelas_ibu_balita" from "anon";

revoke references on table "public"."absensi_kelas_ibu_balita" from "authenticated";

revoke trigger on table "public"."absensi_kelas_ibu_balita" from "authenticated";

revoke truncate on table "public"."absensi_kelas_ibu_balita" from "authenticated";

revoke references on table "public"."absensi_kelas_ibu_balita" from "service_role";

revoke trigger on table "public"."absensi_kelas_ibu_balita" from "service_role";

revoke truncate on table "public"."absensi_kelas_ibu_balita" from "service_role";

revoke references on table "public"."absensi_kelas_ibu_hamil" from "anon";

revoke trigger on table "public"."absensi_kelas_ibu_hamil" from "anon";

revoke truncate on table "public"."absensi_kelas_ibu_hamil" from "anon";

revoke references on table "public"."absensi_kelas_ibu_hamil" from "authenticated";

revoke trigger on table "public"."absensi_kelas_ibu_hamil" from "authenticated";

revoke truncate on table "public"."absensi_kelas_ibu_hamil" from "authenticated";

revoke references on table "public"."absensi_kelas_ibu_hamil" from "service_role";

revoke trigger on table "public"."absensi_kelas_ibu_hamil" from "service_role";

revoke truncate on table "public"."absensi_kelas_ibu_hamil" from "service_role";

revoke references on table "public"."anak" from "anon";

revoke trigger on table "public"."anak" from "anon";

revoke truncate on table "public"."anak" from "anon";

revoke references on table "public"."anak" from "authenticated";

revoke trigger on table "public"."anak" from "authenticated";

revoke truncate on table "public"."anak" from "authenticated";

revoke references on table "public"."anak" from "service_role";

revoke trigger on table "public"."anak" from "service_role";

revoke truncate on table "public"."anak" from "service_role";

revoke references on table "public"."aturan_pelayanans" from "anon";

revoke trigger on table "public"."aturan_pelayanans" from "anon";

revoke truncate on table "public"."aturan_pelayanans" from "anon";

revoke references on table "public"."aturan_pelayanans" from "authenticated";

revoke trigger on table "public"."aturan_pelayanans" from "authenticated";

revoke truncate on table "public"."aturan_pelayanans" from "authenticated";

revoke references on table "public"."aturan_pelayanans" from "service_role";

revoke trigger on table "public"."aturan_pelayanans" from "service_role";

revoke truncate on table "public"."aturan_pelayanans" from "service_role";

revoke references on table "public"."aturan_porsi_mpasi" from "anon";

revoke trigger on table "public"."aturan_porsi_mpasi" from "anon";

revoke truncate on table "public"."aturan_porsi_mpasi" from "anon";

revoke references on table "public"."aturan_porsi_mpasi" from "authenticated";

revoke trigger on table "public"."aturan_porsi_mpasi" from "authenticated";

revoke truncate on table "public"."aturan_porsi_mpasi" from "authenticated";

revoke references on table "public"."aturan_porsi_mpasi" from "service_role";

revoke trigger on table "public"."aturan_porsi_mpasi" from "service_role";

revoke truncate on table "public"."aturan_porsi_mpasi" from "service_role";

revoke references on table "public"."aturan_vaksin_anak" from "anon";

revoke trigger on table "public"."aturan_vaksin_anak" from "anon";

revoke truncate on table "public"."aturan_vaksin_anak" from "anon";

revoke references on table "public"."aturan_vaksin_anak" from "authenticated";

revoke trigger on table "public"."aturan_vaksin_anak" from "authenticated";

revoke truncate on table "public"."aturan_vaksin_anak" from "authenticated";

revoke references on table "public"."aturan_vaksin_anak" from "service_role";

revoke trigger on table "public"."aturan_vaksin_anak" from "service_role";

revoke truncate on table "public"."aturan_vaksin_anak" from "service_role";

revoke references on table "public"."audit_trails" from "anon";

revoke trigger on table "public"."audit_trails" from "anon";

revoke truncate on table "public"."audit_trails" from "anon";

revoke references on table "public"."audit_trails" from "authenticated";

revoke trigger on table "public"."audit_trails" from "authenticated";

revoke truncate on table "public"."audit_trails" from "authenticated";

revoke references on table "public"."audit_trails" from "service_role";

revoke trigger on table "public"."audit_trails" from "service_role";

revoke truncate on table "public"."audit_trails" from "service_role";

revoke references on table "public"."bbl" from "anon";

revoke trigger on table "public"."bbl" from "anon";

revoke truncate on table "public"."bbl" from "anon";

revoke references on table "public"."bbl" from "authenticated";

revoke trigger on table "public"."bbl" from "authenticated";

revoke truncate on table "public"."bbl" from "authenticated";

revoke references on table "public"."bbl" from "service_role";

revoke trigger on table "public"."bbl" from "service_role";

revoke truncate on table "public"."bbl" from "service_role";

revoke references on table "public"."bbl_check" from "anon";

revoke trigger on table "public"."bbl_check" from "anon";

revoke truncate on table "public"."bbl_check" from "anon";

revoke references on table "public"."bbl_check" from "authenticated";

revoke trigger on table "public"."bbl_check" from "authenticated";

revoke truncate on table "public"."bbl_check" from "authenticated";

revoke references on table "public"."bbl_check" from "service_role";

revoke trigger on table "public"."bbl_check" from "service_role";

revoke truncate on table "public"."bbl_check" from "service_role";

revoke references on table "public"."bidan" from "anon";

revoke trigger on table "public"."bidan" from "anon";

revoke truncate on table "public"."bidan" from "anon";

revoke references on table "public"."bidan" from "authenticated";

revoke trigger on table "public"."bidan" from "authenticated";

revoke truncate on table "public"."bidan" from "authenticated";

revoke references on table "public"."bidan" from "service_role";

revoke trigger on table "public"."bidan" from "service_role";

revoke truncate on table "public"."bidan" from "service_role";

revoke references on table "public"."catatan_pelayanan" from "anon";

revoke trigger on table "public"."catatan_pelayanan" from "anon";

revoke truncate on table "public"."catatan_pelayanan" from "anon";

revoke references on table "public"."catatan_pelayanan" from "authenticated";

revoke trigger on table "public"."catatan_pelayanan" from "authenticated";

revoke truncate on table "public"."catatan_pelayanan" from "authenticated";

revoke references on table "public"."catatan_pelayanan" from "service_role";

revoke trigger on table "public"."catatan_pelayanan" from "service_role";

revoke truncate on table "public"."catatan_pelayanan" from "service_role";

revoke references on table "public"."catatan_pelayanan_kehamilan" from "anon";

revoke trigger on table "public"."catatan_pelayanan_kehamilan" from "anon";

revoke truncate on table "public"."catatan_pelayanan_kehamilan" from "anon";

revoke references on table "public"."catatan_pelayanan_kehamilan" from "authenticated";

revoke trigger on table "public"."catatan_pelayanan_kehamilan" from "authenticated";

revoke truncate on table "public"."catatan_pelayanan_kehamilan" from "authenticated";

revoke references on table "public"."catatan_pelayanan_kehamilan" from "service_role";

revoke trigger on table "public"."catatan_pelayanan_kehamilan" from "service_role";

revoke truncate on table "public"."catatan_pelayanan_kehamilan" from "service_role";

revoke references on table "public"."catatan_pelayanan_nifas" from "anon";

revoke trigger on table "public"."catatan_pelayanan_nifas" from "anon";

revoke truncate on table "public"."catatan_pelayanan_nifas" from "anon";

revoke references on table "public"."catatan_pelayanan_nifas" from "authenticated";

revoke trigger on table "public"."catatan_pelayanan_nifas" from "authenticated";

revoke truncate on table "public"."catatan_pelayanan_nifas" from "authenticated";

revoke references on table "public"."catatan_pelayanan_nifas" from "service_role";

revoke trigger on table "public"."catatan_pelayanan_nifas" from "service_role";

revoke truncate on table "public"."catatan_pelayanan_nifas" from "service_role";

revoke references on table "public"."catatan_pelayanan_trimester" from "anon";

revoke trigger on table "public"."catatan_pelayanan_trimester" from "anon";

revoke truncate on table "public"."catatan_pelayanan_trimester" from "anon";

revoke references on table "public"."catatan_pelayanan_trimester" from "authenticated";

revoke trigger on table "public"."catatan_pelayanan_trimester" from "authenticated";

revoke truncate on table "public"."catatan_pelayanan_trimester" from "authenticated";

revoke references on table "public"."catatan_pelayanan_trimester" from "service_role";

revoke trigger on table "public"."catatan_pelayanan_trimester" from "service_role";

revoke truncate on table "public"."catatan_pelayanan_trimester" from "service_role";

revoke references on table "public"."catatan_pelayanan_trimester_1" from "anon";

revoke trigger on table "public"."catatan_pelayanan_trimester_1" from "anon";

revoke truncate on table "public"."catatan_pelayanan_trimester_1" from "anon";

revoke references on table "public"."catatan_pelayanan_trimester_1" from "authenticated";

revoke trigger on table "public"."catatan_pelayanan_trimester_1" from "authenticated";

revoke truncate on table "public"."catatan_pelayanan_trimester_1" from "authenticated";

revoke references on table "public"."catatan_pelayanan_trimester_1" from "service_role";

revoke trigger on table "public"."catatan_pelayanan_trimester_1" from "service_role";

revoke truncate on table "public"."catatan_pelayanan_trimester_1" from "service_role";

revoke references on table "public"."catatan_pelayanan_trimester_2" from "anon";

revoke trigger on table "public"."catatan_pelayanan_trimester_2" from "anon";

revoke truncate on table "public"."catatan_pelayanan_trimester_2" from "anon";

revoke references on table "public"."catatan_pelayanan_trimester_2" from "authenticated";

revoke trigger on table "public"."catatan_pelayanan_trimester_2" from "authenticated";

revoke truncate on table "public"."catatan_pelayanan_trimester_2" from "authenticated";

revoke references on table "public"."catatan_pelayanan_trimester_2" from "service_role";

revoke trigger on table "public"."catatan_pelayanan_trimester_2" from "service_role";

revoke truncate on table "public"."catatan_pelayanan_trimester_2" from "service_role";

revoke references on table "public"."catatan_pelayanan_trimester_3" from "anon";

revoke trigger on table "public"."catatan_pelayanan_trimester_3" from "anon";

revoke truncate on table "public"."catatan_pelayanan_trimester_3" from "anon";

revoke references on table "public"."catatan_pelayanan_trimester_3" from "authenticated";

revoke trigger on table "public"."catatan_pelayanan_trimester_3" from "authenticated";

revoke truncate on table "public"."catatan_pelayanan_trimester_3" from "authenticated";

revoke references on table "public"."catatan_pelayanan_trimester_3" from "service_role";

revoke trigger on table "public"."catatan_pelayanan_trimester_3" from "service_role";

revoke truncate on table "public"."catatan_pelayanan_trimester_3" from "service_role";

revoke references on table "public"."catatan_pertumbuhan" from "anon";

revoke trigger on table "public"."catatan_pertumbuhan" from "anon";

revoke truncate on table "public"."catatan_pertumbuhan" from "anon";

revoke references on table "public"."catatan_pertumbuhan" from "authenticated";

revoke trigger on table "public"."catatan_pertumbuhan" from "authenticated";

revoke truncate on table "public"."catatan_pertumbuhan" from "authenticated";

revoke references on table "public"."catatan_pertumbuhan" from "service_role";

revoke trigger on table "public"."catatan_pertumbuhan" from "service_role";

revoke truncate on table "public"."catatan_pertumbuhan" from "service_role";

revoke references on table "public"."checklist_pemantauan_ibu_nifas" from "anon";

revoke trigger on table "public"."checklist_pemantauan_ibu_nifas" from "anon";

revoke truncate on table "public"."checklist_pemantauan_ibu_nifas" from "anon";

revoke references on table "public"."checklist_pemantauan_ibu_nifas" from "authenticated";

revoke trigger on table "public"."checklist_pemantauan_ibu_nifas" from "authenticated";

revoke truncate on table "public"."checklist_pemantauan_ibu_nifas" from "authenticated";

revoke references on table "public"."checklist_pemantauan_ibu_nifas" from "service_role";

revoke trigger on table "public"."checklist_pemantauan_ibu_nifas" from "service_role";

revoke truncate on table "public"."checklist_pemantauan_ibu_nifas" from "service_role";

revoke references on table "public"."desa" from "anon";

revoke trigger on table "public"."desa" from "anon";

revoke truncate on table "public"."desa" from "anon";

revoke references on table "public"."desa" from "authenticated";

revoke trigger on table "public"."desa" from "authenticated";

revoke truncate on table "public"."desa" from "authenticated";

revoke references on table "public"."desa" from "service_role";

revoke trigger on table "public"."desa" from "service_role";

revoke truncate on table "public"."desa" from "service_role";

revoke references on table "public"."detail_lingkungan" from "anon";

revoke trigger on table "public"."detail_lingkungan" from "anon";

revoke truncate on table "public"."detail_lingkungan" from "anon";

revoke references on table "public"."detail_lingkungan" from "authenticated";

revoke trigger on table "public"."detail_lingkungan" from "authenticated";

revoke truncate on table "public"."detail_lingkungan" from "authenticated";

revoke references on table "public"."detail_lingkungan" from "service_role";

revoke trigger on table "public"."detail_lingkungan" from "service_role";

revoke truncate on table "public"."detail_lingkungan" from "service_role";

revoke references on table "public"."detail_pelayanan_imunisasi" from "anon";

revoke trigger on table "public"."detail_pelayanan_imunisasi" from "anon";

revoke truncate on table "public"."detail_pelayanan_imunisasi" from "anon";

revoke references on table "public"."detail_pelayanan_imunisasi" from "authenticated";

revoke trigger on table "public"."detail_pelayanan_imunisasi" from "authenticated";

revoke truncate on table "public"."detail_pelayanan_imunisasi" from "authenticated";

revoke references on table "public"."detail_pelayanan_imunisasi" from "service_role";

revoke trigger on table "public"."detail_pelayanan_imunisasi" from "service_role";

revoke truncate on table "public"."detail_pelayanan_imunisasi" from "service_role";

revoke references on table "public"."detail_pelayanan_neonatus" from "anon";

revoke trigger on table "public"."detail_pelayanan_neonatus" from "anon";

revoke truncate on table "public"."detail_pelayanan_neonatus" from "anon";

revoke references on table "public"."detail_pelayanan_neonatus" from "authenticated";

revoke trigger on table "public"."detail_pelayanan_neonatus" from "authenticated";

revoke truncate on table "public"."detail_pelayanan_neonatus" from "authenticated";

revoke references on table "public"."detail_pelayanan_neonatus" from "service_role";

revoke trigger on table "public"."detail_pelayanan_neonatus" from "service_role";

revoke truncate on table "public"."detail_pelayanan_neonatus" from "service_role";

revoke references on table "public"."detail_pelayanan_vitamin" from "anon";

revoke trigger on table "public"."detail_pelayanan_vitamin" from "anon";

revoke truncate on table "public"."detail_pelayanan_vitamin" from "anon";

revoke references on table "public"."detail_pelayanan_vitamin" from "authenticated";

revoke trigger on table "public"."detail_pelayanan_vitamin" from "authenticated";

revoke truncate on table "public"."detail_pelayanan_vitamin" from "authenticated";

revoke references on table "public"."detail_pelayanan_vitamin" from "service_role";

revoke trigger on table "public"."detail_pelayanan_vitamin" from "service_role";

revoke truncate on table "public"."detail_pelayanan_vitamin" from "service_role";

revoke references on table "public"."detail_pemantauan" from "anon";

revoke trigger on table "public"."detail_pemantauan" from "anon";

revoke truncate on table "public"."detail_pemantauan" from "anon";

revoke references on table "public"."detail_pemantauan" from "authenticated";

revoke trigger on table "public"."detail_pemantauan" from "authenticated";

revoke truncate on table "public"."detail_pemantauan" from "authenticated";

revoke references on table "public"."detail_pemantauan" from "service_role";

revoke trigger on table "public"."detail_pemantauan" from "service_role";

revoke truncate on table "public"."detail_pemantauan" from "service_role";

revoke references on table "public"."detail_pemantauan_ibu" from "anon";

revoke trigger on table "public"."detail_pemantauan_ibu" from "anon";

revoke truncate on table "public"."detail_pemantauan_ibu" from "anon";

revoke references on table "public"."detail_pemantauan_ibu" from "authenticated";

revoke trigger on table "public"."detail_pemantauan_ibu" from "authenticated";

revoke truncate on table "public"."detail_pemantauan_ibu" from "authenticated";

revoke references on table "public"."detail_pemantauan_ibu" from "service_role";

revoke trigger on table "public"."detail_pemantauan_ibu" from "service_role";

revoke truncate on table "public"."detail_pemantauan_ibu" from "service_role";

revoke references on table "public"."deteksi_dini_penyimpangan" from "anon";

revoke trigger on table "public"."deteksi_dini_penyimpangan" from "anon";

revoke truncate on table "public"."deteksi_dini_penyimpangan" from "anon";

revoke references on table "public"."deteksi_dini_penyimpangan" from "authenticated";

revoke trigger on table "public"."deteksi_dini_penyimpangan" from "authenticated";

revoke truncate on table "public"."deteksi_dini_penyimpangan" from "authenticated";

revoke references on table "public"."deteksi_dini_penyimpangan" from "service_role";

revoke trigger on table "public"."deteksi_dini_penyimpangan" from "service_role";

revoke truncate on table "public"."deteksi_dini_penyimpangan" from "service_role";

revoke references on table "public"."dosis_vaksin" from "anon";

revoke trigger on table "public"."dosis_vaksin" from "anon";

revoke truncate on table "public"."dosis_vaksin" from "anon";

revoke references on table "public"."dosis_vaksin" from "authenticated";

revoke trigger on table "public"."dosis_vaksin" from "authenticated";

revoke truncate on table "public"."dosis_vaksin" from "authenticated";

revoke references on table "public"."dosis_vaksin" from "service_role";

revoke trigger on table "public"."dosis_vaksin" from "service_role";

revoke truncate on table "public"."dosis_vaksin" from "service_role";

revoke references on table "public"."dusun" from "anon";

revoke trigger on table "public"."dusun" from "anon";

revoke truncate on table "public"."dusun" from "anon";

revoke references on table "public"."dusun" from "authenticated";

revoke trigger on table "public"."dusun" from "authenticated";

revoke truncate on table "public"."dusun" from "authenticated";

revoke references on table "public"."dusun" from "service_role";

revoke trigger on table "public"."dusun" from "service_role";

revoke truncate on table "public"."dusun" from "service_role";

revoke references on table "public"."edukasi_imd" from "anon";

revoke trigger on table "public"."edukasi_imd" from "anon";

revoke truncate on table "public"."edukasi_imd" from "anon";

revoke references on table "public"."edukasi_imd" from "authenticated";

revoke trigger on table "public"."edukasi_imd" from "authenticated";

revoke truncate on table "public"."edukasi_imd" from "authenticated";

revoke references on table "public"."edukasi_imd" from "service_role";

revoke trigger on table "public"."edukasi_imd" from "service_role";

revoke truncate on table "public"."edukasi_imd" from "service_role";

revoke references on table "public"."edukasi_informasi_umum" from "anon";

revoke trigger on table "public"."edukasi_informasi_umum" from "anon";

revoke truncate on table "public"."edukasi_informasi_umum" from "anon";

revoke references on table "public"."edukasi_informasi_umum" from "authenticated";

revoke trigger on table "public"."edukasi_informasi_umum" from "authenticated";

revoke truncate on table "public"."edukasi_informasi_umum" from "authenticated";

revoke references on table "public"."edukasi_informasi_umum" from "service_role";

revoke trigger on table "public"."edukasi_informasi_umum" from "service_role";

revoke truncate on table "public"."edukasi_informasi_umum" from "service_role";

revoke references on table "public"."edukasi_kesehatan_mental" from "anon";

revoke trigger on table "public"."edukasi_kesehatan_mental" from "anon";

revoke truncate on table "public"."edukasi_kesehatan_mental" from "anon";

revoke references on table "public"."edukasi_kesehatan_mental" from "authenticated";

revoke trigger on table "public"."edukasi_kesehatan_mental" from "authenticated";

revoke truncate on table "public"."edukasi_kesehatan_mental" from "authenticated";

revoke references on table "public"."edukasi_kesehatan_mental" from "service_role";

revoke trigger on table "public"."edukasi_kesehatan_mental" from "service_role";

revoke truncate on table "public"."edukasi_kesehatan_mental" from "service_role";

revoke references on table "public"."edukasi_menyusui_asi" from "anon";

revoke trigger on table "public"."edukasi_menyusui_asi" from "anon";

revoke truncate on table "public"."edukasi_menyusui_asi" from "anon";

revoke references on table "public"."edukasi_menyusui_asi" from "authenticated";

revoke trigger on table "public"."edukasi_menyusui_asi" from "authenticated";

revoke truncate on table "public"."edukasi_menyusui_asi" from "authenticated";

revoke references on table "public"."edukasi_menyusui_asi" from "service_role";

revoke trigger on table "public"."edukasi_menyusui_asi" from "service_role";

revoke truncate on table "public"."edukasi_menyusui_asi" from "service_role";

revoke references on table "public"."edukasi_perawatan_anak" from "anon";

revoke trigger on table "public"."edukasi_perawatan_anak" from "anon";

revoke truncate on table "public"."edukasi_perawatan_anak" from "anon";

revoke references on table "public"."edukasi_perawatan_anak" from "authenticated";

revoke trigger on table "public"."edukasi_perawatan_anak" from "authenticated";

revoke truncate on table "public"."edukasi_perawatan_anak" from "authenticated";

revoke references on table "public"."edukasi_perawatan_anak" from "service_role";

revoke trigger on table "public"."edukasi_perawatan_anak" from "service_role";

revoke truncate on table "public"."edukasi_perawatan_anak" from "service_role";

revoke references on table "public"."edukasi_pola_asuh" from "anon";

revoke trigger on table "public"."edukasi_pola_asuh" from "anon";

revoke truncate on table "public"."edukasi_pola_asuh" from "anon";

revoke references on table "public"."edukasi_pola_asuh" from "authenticated";

revoke trigger on table "public"."edukasi_pola_asuh" from "authenticated";

revoke truncate on table "public"."edukasi_pola_asuh" from "authenticated";

revoke references on table "public"."edukasi_pola_asuh" from "service_role";

revoke trigger on table "public"."edukasi_pola_asuh" from "service_role";

revoke truncate on table "public"."edukasi_pola_asuh" from "service_role";

revoke references on table "public"."edukasi_setelah_melahirkan" from "anon";

revoke trigger on table "public"."edukasi_setelah_melahirkan" from "anon";

revoke truncate on table "public"."edukasi_setelah_melahirkan" from "anon";

revoke references on table "public"."edukasi_setelah_melahirkan" from "authenticated";

revoke trigger on table "public"."edukasi_setelah_melahirkan" from "authenticated";

revoke truncate on table "public"."edukasi_setelah_melahirkan" from "authenticated";

revoke references on table "public"."edukasi_setelah_melahirkan" from "service_role";

revoke trigger on table "public"."edukasi_setelah_melahirkan" from "service_role";

revoke truncate on table "public"."edukasi_setelah_melahirkan" from "service_role";

revoke references on table "public"."edukasi_tanda_melahirkan" from "anon";

revoke trigger on table "public"."edukasi_tanda_melahirkan" from "anon";

revoke truncate on table "public"."edukasi_tanda_melahirkan" from "anon";

revoke references on table "public"."edukasi_tanda_melahirkan" from "authenticated";

revoke trigger on table "public"."edukasi_tanda_melahirkan" from "authenticated";

revoke truncate on table "public"."edukasi_tanda_melahirkan" from "authenticated";

revoke references on table "public"."edukasi_tanda_melahirkan" from "service_role";

revoke trigger on table "public"."edukasi_tanda_melahirkan" from "service_role";

revoke truncate on table "public"."edukasi_tanda_melahirkan" from "service_role";

revoke references on table "public"."edukasi_trimester" from "anon";

revoke trigger on table "public"."edukasi_trimester" from "anon";

revoke truncate on table "public"."edukasi_trimester" from "anon";

revoke references on table "public"."edukasi_trimester" from "authenticated";

revoke trigger on table "public"."edukasi_trimester" from "authenticated";

revoke truncate on table "public"."edukasi_trimester" from "authenticated";

revoke references on table "public"."edukasi_trimester" from "service_role";

revoke trigger on table "public"."edukasi_trimester" from "service_role";

revoke truncate on table "public"."edukasi_trimester" from "service_role";

revoke references on table "public"."evaluasi_kesehatan_ibu" from "anon";

revoke trigger on table "public"."evaluasi_kesehatan_ibu" from "anon";

revoke truncate on table "public"."evaluasi_kesehatan_ibu" from "anon";

revoke references on table "public"."evaluasi_kesehatan_ibu" from "authenticated";

revoke trigger on table "public"."evaluasi_kesehatan_ibu" from "authenticated";

revoke truncate on table "public"."evaluasi_kesehatan_ibu" from "authenticated";

revoke references on table "public"."evaluasi_kesehatan_ibu" from "service_role";

revoke trigger on table "public"."evaluasi_kesehatan_ibu" from "service_role";

revoke truncate on table "public"."evaluasi_kesehatan_ibu" from "service_role";

revoke references on table "public"."form_aturan_risikos" from "anon";

revoke trigger on table "public"."form_aturan_risikos" from "anon";

revoke truncate on table "public"."form_aturan_risikos" from "anon";

revoke references on table "public"."form_aturan_risikos" from "authenticated";

revoke trigger on table "public"."form_aturan_risikos" from "authenticated";

revoke truncate on table "public"."form_aturan_risikos" from "authenticated";

revoke references on table "public"."form_aturan_risikos" from "service_role";

revoke trigger on table "public"."form_aturan_risikos" from "service_role";

revoke truncate on table "public"."form_aturan_risikos" from "service_role";

revoke references on table "public"."form_pertanyaans" from "anon";

revoke trigger on table "public"."form_pertanyaans" from "anon";

revoke truncate on table "public"."form_pertanyaans" from "anon";

revoke references on table "public"."form_pertanyaans" from "authenticated";

revoke trigger on table "public"."form_pertanyaans" from "authenticated";

revoke truncate on table "public"."form_pertanyaans" from "authenticated";

revoke references on table "public"."form_pertanyaans" from "service_role";

revoke trigger on table "public"."form_pertanyaans" from "service_role";

revoke truncate on table "public"."form_pertanyaans" from "service_role";

revoke references on table "public"."form_versis" from "anon";

revoke trigger on table "public"."form_versis" from "anon";

revoke truncate on table "public"."form_versis" from "anon";

revoke references on table "public"."form_versis" from "authenticated";

revoke trigger on table "public"."form_versis" from "authenticated";

revoke truncate on table "public"."form_versis" from "authenticated";

revoke references on table "public"."form_versis" from "service_role";

revoke trigger on table "public"."form_versis" from "service_role";

revoke truncate on table "public"."form_versis" from "service_role";

revoke references on table "public"."grafik_evaluasi_kehamilan" from "anon";

revoke trigger on table "public"."grafik_evaluasi_kehamilan" from "anon";

revoke truncate on table "public"."grafik_evaluasi_kehamilan" from "anon";

revoke references on table "public"."grafik_evaluasi_kehamilan" from "authenticated";

revoke trigger on table "public"."grafik_evaluasi_kehamilan" from "authenticated";

revoke truncate on table "public"."grafik_evaluasi_kehamilan" from "authenticated";

revoke references on table "public"."grafik_evaluasi_kehamilan" from "service_role";

revoke trigger on table "public"."grafik_evaluasi_kehamilan" from "service_role";

revoke truncate on table "public"."grafik_evaluasi_kehamilan" from "service_role";

revoke references on table "public"."grafik_peningkatan_bb" from "anon";

revoke trigger on table "public"."grafik_peningkatan_bb" from "anon";

revoke truncate on table "public"."grafik_peningkatan_bb" from "anon";

revoke references on table "public"."grafik_peningkatan_bb" from "authenticated";

revoke trigger on table "public"."grafik_peningkatan_bb" from "authenticated";

revoke truncate on table "public"."grafik_peningkatan_bb" from "authenticated";

revoke references on table "public"."grafik_peningkatan_bb" from "service_role";

revoke trigger on table "public"."grafik_peningkatan_bb" from "service_role";

revoke truncate on table "public"."grafik_peningkatan_bb" from "service_role";

revoke references on table "public"."ibu" from "anon";

revoke trigger on table "public"."ibu" from "anon";

revoke truncate on table "public"."ibu" from "anon";

revoke references on table "public"."ibu" from "authenticated";

revoke trigger on table "public"."ibu" from "authenticated";

revoke truncate on table "public"."ibu" from "authenticated";

revoke references on table "public"."ibu" from "service_role";

revoke trigger on table "public"."ibu" from "service_role";

revoke truncate on table "public"."ibu" from "service_role";

revoke references on table "public"."indikator_lingkungan" from "anon";

revoke trigger on table "public"."indikator_lingkungan" from "anon";

revoke truncate on table "public"."indikator_lingkungan" from "anon";

revoke references on table "public"."indikator_lingkungan" from "authenticated";

revoke trigger on table "public"."indikator_lingkungan" from "authenticated";

revoke truncate on table "public"."indikator_lingkungan" from "authenticated";

revoke references on table "public"."indikator_lingkungan" from "service_role";

revoke trigger on table "public"."indikator_lingkungan" from "service_role";

revoke truncate on table "public"."indikator_lingkungan" from "service_role";

revoke references on table "public"."informasi_umum" from "anon";

revoke trigger on table "public"."informasi_umum" from "anon";

revoke truncate on table "public"."informasi_umum" from "anon";

revoke references on table "public"."informasi_umum" from "authenticated";

revoke trigger on table "public"."informasi_umum" from "authenticated";

revoke truncate on table "public"."informasi_umum" from "authenticated";

revoke references on table "public"."informasi_umum" from "service_role";

revoke trigger on table "public"."informasi_umum" from "service_role";

revoke truncate on table "public"."informasi_umum" from "service_role";

revoke references on table "public"."jadwal_harian_mpasi" from "anon";

revoke trigger on table "public"."jadwal_harian_mpasi" from "anon";

revoke truncate on table "public"."jadwal_harian_mpasi" from "anon";

revoke references on table "public"."jadwal_harian_mpasi" from "authenticated";

revoke trigger on table "public"."jadwal_harian_mpasi" from "authenticated";

revoke truncate on table "public"."jadwal_harian_mpasi" from "authenticated";

revoke references on table "public"."jadwal_harian_mpasi" from "service_role";

revoke trigger on table "public"."jadwal_harian_mpasi" from "service_role";

revoke truncate on table "public"."jadwal_harian_mpasi" from "service_role";

revoke references on table "public"."jadwal_imunisasi_anak" from "anon";

revoke trigger on table "public"."jadwal_imunisasi_anak" from "anon";

revoke truncate on table "public"."jadwal_imunisasi_anak" from "anon";

revoke references on table "public"."jadwal_imunisasi_anak" from "authenticated";

revoke trigger on table "public"."jadwal_imunisasi_anak" from "authenticated";

revoke truncate on table "public"."jadwal_imunisasi_anak" from "authenticated";

revoke references on table "public"."jadwal_imunisasi_anak" from "service_role";

revoke trigger on table "public"."jadwal_imunisasi_anak" from "service_role";

revoke truncate on table "public"."jadwal_imunisasi_anak" from "service_role";

revoke references on table "public"."jadwal_layanan" from "anon";

revoke trigger on table "public"."jadwal_layanan" from "anon";

revoke truncate on table "public"."jadwal_layanan" from "anon";

revoke references on table "public"."jadwal_layanan" from "authenticated";

revoke trigger on table "public"."jadwal_layanan" from "authenticated";

revoke truncate on table "public"."jadwal_layanan" from "authenticated";

revoke references on table "public"."jadwal_layanan" from "service_role";

revoke trigger on table "public"."jadwal_layanan" from "service_role";

revoke truncate on table "public"."jadwal_layanan" from "service_role";

revoke references on table "public"."jadwal_layanan_dosis_vaksin" from "anon";

revoke trigger on table "public"."jadwal_layanan_dosis_vaksin" from "anon";

revoke truncate on table "public"."jadwal_layanan_dosis_vaksin" from "anon";

revoke references on table "public"."jadwal_layanan_dosis_vaksin" from "authenticated";

revoke trigger on table "public"."jadwal_layanan_dosis_vaksin" from "authenticated";

revoke truncate on table "public"."jadwal_layanan_dosis_vaksin" from "authenticated";

revoke references on table "public"."jadwal_layanan_dosis_vaksin" from "service_role";

revoke trigger on table "public"."jadwal_layanan_dosis_vaksin" from "service_role";

revoke truncate on table "public"."jadwal_layanan_dosis_vaksin" from "service_role";

revoke references on table "public"."jadwal_layanan_vaksin" from "anon";

revoke trigger on table "public"."jadwal_layanan_vaksin" from "anon";

revoke truncate on table "public"."jadwal_layanan_vaksin" from "anon";

revoke references on table "public"."jadwal_layanan_vaksin" from "authenticated";

revoke trigger on table "public"."jadwal_layanan_vaksin" from "authenticated";

revoke truncate on table "public"."jadwal_layanan_vaksin" from "authenticated";

revoke references on table "public"."jadwal_layanan_vaksin" from "service_role";

revoke trigger on table "public"."jadwal_layanan_vaksin" from "service_role";

revoke truncate on table "public"."jadwal_layanan_vaksin" from "service_role";

revoke references on table "public"."jenis_pelayanan" from "anon";

revoke trigger on table "public"."jenis_pelayanan" from "anon";

revoke truncate on table "public"."jenis_pelayanan" from "anon";

revoke references on table "public"."jenis_pelayanan" from "authenticated";

revoke trigger on table "public"."jenis_pelayanan" from "authenticated";

revoke truncate on table "public"."jenis_pelayanan" from "authenticated";

revoke references on table "public"."jenis_pelayanan" from "service_role";

revoke trigger on table "public"."jenis_pelayanan" from "service_role";

revoke truncate on table "public"."jenis_pelayanan" from "service_role";

revoke references on table "public"."jenis_pelayanan_kategori" from "anon";

revoke trigger on table "public"."jenis_pelayanan_kategori" from "anon";

revoke truncate on table "public"."jenis_pelayanan_kategori" from "anon";

revoke references on table "public"."jenis_pelayanan_kategori" from "authenticated";

revoke trigger on table "public"."jenis_pelayanan_kategori" from "authenticated";

revoke truncate on table "public"."jenis_pelayanan_kategori" from "authenticated";

revoke references on table "public"."jenis_pelayanan_kategori" from "service_role";

revoke trigger on table "public"."jenis_pelayanan_kategori" from "service_role";

revoke truncate on table "public"."jenis_pelayanan_kategori" from "service_role";

revoke references on table "public"."kader" from "anon";

revoke trigger on table "public"."kader" from "anon";

revoke truncate on table "public"."kader" from "anon";

revoke references on table "public"."kader" from "authenticated";

revoke trigger on table "public"."kader" from "authenticated";

revoke truncate on table "public"."kader" from "authenticated";

revoke references on table "public"."kader" from "service_role";

revoke trigger on table "public"."kader" from "service_role";

revoke truncate on table "public"."kader" from "service_role";

revoke references on table "public"."kader_posyandu" from "anon";

revoke trigger on table "public"."kader_posyandu" from "anon";

revoke truncate on table "public"."kader_posyandu" from "anon";

revoke references on table "public"."kader_posyandu" from "authenticated";

revoke trigger on table "public"."kader_posyandu" from "authenticated";

revoke truncate on table "public"."kader_posyandu" from "authenticated";

revoke references on table "public"."kader_posyandu" from "service_role";

revoke trigger on table "public"."kader_posyandu" from "service_role";

revoke truncate on table "public"."kader_posyandu" from "service_role";

revoke references on table "public"."kartu_keluarga" from "anon";

revoke trigger on table "public"."kartu_keluarga" from "anon";

revoke truncate on table "public"."kartu_keluarga" from "anon";

revoke references on table "public"."kartu_keluarga" from "authenticated";

revoke trigger on table "public"."kartu_keluarga" from "authenticated";

revoke truncate on table "public"."kartu_keluarga" from "authenticated";

revoke references on table "public"."kartu_keluarga" from "service_role";

revoke trigger on table "public"."kartu_keluarga" from "service_role";

revoke truncate on table "public"."kartu_keluarga" from "service_role";

revoke references on table "public"."kategori_capaian" from "anon";

revoke trigger on table "public"."kategori_capaian" from "anon";

revoke truncate on table "public"."kategori_capaian" from "anon";

revoke references on table "public"."kategori_capaian" from "authenticated";

revoke trigger on table "public"."kategori_capaian" from "authenticated";

revoke truncate on table "public"."kategori_capaian" from "authenticated";

revoke references on table "public"."kategori_capaian" from "service_role";

revoke trigger on table "public"."kategori_capaian" from "service_role";

revoke truncate on table "public"."kategori_capaian" from "service_role";

revoke references on table "public"."kategori_lingkungan" from "anon";

revoke trigger on table "public"."kategori_lingkungan" from "anon";

revoke truncate on table "public"."kategori_lingkungan" from "anon";

revoke references on table "public"."kategori_lingkungan" from "authenticated";

revoke trigger on table "public"."kategori_lingkungan" from "authenticated";

revoke truncate on table "public"."kategori_lingkungan" from "authenticated";

revoke references on table "public"."kategori_lingkungan" from "service_role";

revoke trigger on table "public"."kategori_lingkungan" from "service_role";

revoke truncate on table "public"."kategori_lingkungan" from "service_role";

revoke references on table "public"."kategori_pemantauan_ibu" from "anon";

revoke trigger on table "public"."kategori_pemantauan_ibu" from "anon";

revoke truncate on table "public"."kategori_pemantauan_ibu" from "anon";

revoke references on table "public"."kategori_pemantauan_ibu" from "authenticated";

revoke trigger on table "public"."kategori_pemantauan_ibu" from "authenticated";

revoke truncate on table "public"."kategori_pemantauan_ibu" from "authenticated";

revoke references on table "public"."kategori_pemantauan_ibu" from "service_role";

revoke trigger on table "public"."kategori_pemantauan_ibu" from "service_role";

revoke truncate on table "public"."kategori_pemantauan_ibu" from "service_role";

revoke references on table "public"."kategori_status" from "anon";

revoke trigger on table "public"."kategori_status" from "anon";

revoke truncate on table "public"."kategori_status" from "anon";

revoke references on table "public"."kategori_status" from "authenticated";

revoke trigger on table "public"."kategori_status" from "authenticated";

revoke truncate on table "public"."kategori_status" from "authenticated";

revoke references on table "public"."kategori_status" from "service_role";

revoke trigger on table "public"."kategori_status" from "service_role";

revoke truncate on table "public"."kategori_status" from "service_role";

revoke references on table "public"."kategori_tanda_bahaya" from "anon";

revoke trigger on table "public"."kategori_tanda_bahaya" from "anon";

revoke truncate on table "public"."kategori_tanda_bahaya" from "anon";

revoke references on table "public"."kategori_tanda_bahaya" from "authenticated";

revoke trigger on table "public"."kategori_tanda_bahaya" from "authenticated";

revoke truncate on table "public"."kategori_tanda_bahaya" from "authenticated";

revoke references on table "public"."kategori_tanda_bahaya" from "service_role";

revoke trigger on table "public"."kategori_tanda_bahaya" from "service_role";

revoke truncate on table "public"."kategori_tanda_bahaya" from "service_role";

revoke references on table "public"."kategori_tanda_sakit" from "anon";

revoke trigger on table "public"."kategori_tanda_sakit" from "anon";

revoke truncate on table "public"."kategori_tanda_sakit" from "anon";

revoke references on table "public"."kategori_tanda_sakit" from "authenticated";

revoke trigger on table "public"."kategori_tanda_sakit" from "authenticated";

revoke truncate on table "public"."kategori_tanda_sakit" from "authenticated";

revoke references on table "public"."kategori_tanda_sakit" from "service_role";

revoke trigger on table "public"."kategori_tanda_sakit" from "service_role";

revoke truncate on table "public"."kategori_tanda_sakit" from "service_role";

revoke references on table "public"."kategori_trimester" from "anon";

revoke trigger on table "public"."kategori_trimester" from "anon";

revoke truncate on table "public"."kategori_trimester" from "anon";

revoke references on table "public"."kategori_trimester" from "authenticated";

revoke trigger on table "public"."kategori_trimester" from "authenticated";

revoke truncate on table "public"."kategori_trimester" from "authenticated";

revoke references on table "public"."kategori_trimester" from "service_role";

revoke trigger on table "public"."kategori_trimester" from "service_role";

revoke truncate on table "public"."kategori_trimester" from "service_role";

revoke references on table "public"."kehadiran_imunisasi" from "anon";

revoke trigger on table "public"."kehadiran_imunisasi" from "anon";

revoke truncate on table "public"."kehadiran_imunisasi" from "anon";

revoke references on table "public"."kehadiran_imunisasi" from "authenticated";

revoke trigger on table "public"."kehadiran_imunisasi" from "authenticated";

revoke truncate on table "public"."kehadiran_imunisasi" from "authenticated";

revoke references on table "public"."kehadiran_imunisasi" from "service_role";

revoke trigger on table "public"."kehadiran_imunisasi" from "service_role";

revoke truncate on table "public"."kehadiran_imunisasi" from "service_role";

revoke references on table "public"."kehamilan" from "anon";

revoke trigger on table "public"."kehamilan" from "anon";

revoke truncate on table "public"."kehamilan" from "anon";

revoke references on table "public"."kehamilan" from "authenticated";

revoke trigger on table "public"."kehamilan" from "authenticated";

revoke truncate on table "public"."kehamilan" from "authenticated";

revoke references on table "public"."kehamilan" from "service_role";

revoke trigger on table "public"."kehamilan" from "service_role";

revoke truncate on table "public"."kehamilan" from "service_role";

revoke references on table "public"."keluhan_anak" from "anon";

revoke trigger on table "public"."keluhan_anak" from "anon";

revoke truncate on table "public"."keluhan_anak" from "anon";

revoke references on table "public"."keluhan_anak" from "authenticated";

revoke trigger on table "public"."keluhan_anak" from "authenticated";

revoke truncate on table "public"."keluhan_anak" from "authenticated";

revoke references on table "public"."keluhan_anak" from "service_role";

revoke trigger on table "public"."keluhan_anak" from "service_role";

revoke truncate on table "public"."keluhan_anak" from "service_role";

revoke references on table "public"."keterangan_lahir" from "anon";

revoke trigger on table "public"."keterangan_lahir" from "anon";

revoke truncate on table "public"."keterangan_lahir" from "anon";

revoke references on table "public"."keterangan_lahir" from "authenticated";

revoke trigger on table "public"."keterangan_lahir" from "authenticated";

revoke truncate on table "public"."keterangan_lahir" from "authenticated";

revoke references on table "public"."keterangan_lahir" from "service_role";

revoke trigger on table "public"."keterangan_lahir" from "service_role";

revoke truncate on table "public"."keterangan_lahir" from "service_role";

revoke references on table "public"."kunjungan_anak" from "anon";

revoke trigger on table "public"."kunjungan_anak" from "anon";

revoke truncate on table "public"."kunjungan_anak" from "anon";

revoke references on table "public"."kunjungan_anak" from "authenticated";

revoke trigger on table "public"."kunjungan_anak" from "authenticated";

revoke truncate on table "public"."kunjungan_anak" from "authenticated";

revoke references on table "public"."kunjungan_anak" from "service_role";

revoke trigger on table "public"."kunjungan_anak" from "service_role";

revoke truncate on table "public"."kunjungan_anak" from "service_role";

revoke references on table "public"."kunjungan_gizi" from "anon";

revoke trigger on table "public"."kunjungan_gizi" from "anon";

revoke truncate on table "public"."kunjungan_gizi" from "anon";

revoke references on table "public"."kunjungan_gizi" from "authenticated";

revoke trigger on table "public"."kunjungan_gizi" from "authenticated";

revoke truncate on table "public"."kunjungan_gizi" from "authenticated";

revoke references on table "public"."kunjungan_gizi" from "service_role";

revoke trigger on table "public"."kunjungan_gizi" from "service_role";

revoke truncate on table "public"."kunjungan_gizi" from "service_role";

revoke references on table "public"."kunjungan_imunisasi" from "anon";

revoke trigger on table "public"."kunjungan_imunisasi" from "anon";

revoke truncate on table "public"."kunjungan_imunisasi" from "anon";

revoke references on table "public"."kunjungan_imunisasi" from "authenticated";

revoke trigger on table "public"."kunjungan_imunisasi" from "authenticated";

revoke truncate on table "public"."kunjungan_imunisasi" from "authenticated";

revoke references on table "public"."kunjungan_imunisasi" from "service_role";

revoke trigger on table "public"."kunjungan_imunisasi" from "service_role";

revoke truncate on table "public"."kunjungan_imunisasi" from "service_role";

revoke references on table "public"."kunjungan_vitamin" from "anon";

revoke trigger on table "public"."kunjungan_vitamin" from "anon";

revoke truncate on table "public"."kunjungan_vitamin" from "anon";

revoke references on table "public"."kunjungan_vitamin" from "authenticated";

revoke trigger on table "public"."kunjungan_vitamin" from "authenticated";

revoke truncate on table "public"."kunjungan_vitamin" from "authenticated";

revoke references on table "public"."kunjungan_vitamin" from "service_role";

revoke trigger on table "public"."kunjungan_vitamin" from "service_role";

revoke truncate on table "public"."kunjungan_vitamin" from "service_role";

revoke references on table "public"."laporan_anaks" from "anon";

revoke trigger on table "public"."laporan_anaks" from "anon";

revoke truncate on table "public"."laporan_anaks" from "anon";

revoke references on table "public"."laporan_anaks" from "authenticated";

revoke trigger on table "public"."laporan_anaks" from "authenticated";

revoke truncate on table "public"."laporan_anaks" from "authenticated";

revoke references on table "public"."laporan_anaks" from "service_role";

revoke trigger on table "public"."laporan_anaks" from "service_role";

revoke truncate on table "public"."laporan_anaks" from "service_role";

revoke references on table "public"."laporan_ibus" from "anon";

revoke trigger on table "public"."laporan_ibus" from "anon";

revoke truncate on table "public"."laporan_ibus" from "anon";

revoke references on table "public"."laporan_ibus" from "authenticated";

revoke trigger on table "public"."laporan_ibus" from "authenticated";

revoke truncate on table "public"."laporan_ibus" from "authenticated";

revoke references on table "public"."laporan_ibus" from "service_role";

revoke trigger on table "public"."laporan_ibus" from "service_role";

revoke truncate on table "public"."laporan_ibus" from "service_role";

revoke references on table "public"."lembar_lingkungan" from "anon";

revoke trigger on table "public"."lembar_lingkungan" from "anon";

revoke truncate on table "public"."lembar_lingkungan" from "anon";

revoke references on table "public"."lembar_lingkungan" from "authenticated";

revoke trigger on table "public"."lembar_lingkungan" from "authenticated";

revoke truncate on table "public"."lembar_lingkungan" from "authenticated";

revoke references on table "public"."lembar_lingkungan" from "service_role";

revoke trigger on table "public"."lembar_lingkungan" from "service_role";

revoke truncate on table "public"."lembar_lingkungan" from "service_role";

revoke references on table "public"."lembar_pemantauan" from "anon";

revoke trigger on table "public"."lembar_pemantauan" from "anon";

revoke truncate on table "public"."lembar_pemantauan" from "anon";

revoke references on table "public"."lembar_pemantauan" from "authenticated";

revoke trigger on table "public"."lembar_pemantauan" from "authenticated";

revoke truncate on table "public"."lembar_pemantauan" from "authenticated";

revoke references on table "public"."lembar_pemantauan" from "service_role";

revoke trigger on table "public"."lembar_pemantauan" from "service_role";

revoke truncate on table "public"."lembar_pemantauan" from "service_role";

revoke references on table "public"."lembar_pemantauan_ibu" from "anon";

revoke trigger on table "public"."lembar_pemantauan_ibu" from "anon";

revoke truncate on table "public"."lembar_pemantauan_ibu" from "anon";

revoke references on table "public"."lembar_pemantauan_ibu" from "authenticated";

revoke trigger on table "public"."lembar_pemantauan_ibu" from "authenticated";

revoke truncate on table "public"."lembar_pemantauan_ibu" from "authenticated";

revoke references on table "public"."lembar_pemantauan_ibu" from "service_role";

revoke trigger on table "public"."lembar_pemantauan_ibu" from "service_role";

revoke truncate on table "public"."lembar_pemantauan_ibu" from "service_role";

revoke references on table "public"."log_ttd_mms" from "anon";

revoke trigger on table "public"."log_ttd_mms" from "anon";

revoke truncate on table "public"."log_ttd_mms" from "anon";

revoke references on table "public"."log_ttd_mms" from "authenticated";

revoke trigger on table "public"."log_ttd_mms" from "authenticated";

revoke truncate on table "public"."log_ttd_mms" from "authenticated";

revoke references on table "public"."log_ttd_mms" from "service_role";

revoke trigger on table "public"."log_ttd_mms" from "service_role";

revoke truncate on table "public"."log_ttd_mms" from "service_role";

revoke references on table "public"."master_imunisasi" from "anon";

revoke trigger on table "public"."master_imunisasi" from "anon";

revoke truncate on table "public"."master_imunisasi" from "anon";

revoke references on table "public"."master_imunisasi" from "authenticated";

revoke trigger on table "public"."master_imunisasi" from "authenticated";

revoke truncate on table "public"."master_imunisasi" from "authenticated";

revoke references on table "public"."master_imunisasi" from "service_role";

revoke trigger on table "public"."master_imunisasi" from "service_role";

revoke truncate on table "public"."master_imunisasi" from "service_role";

revoke references on table "public"."master_standar_antropometri" from "anon";

revoke trigger on table "public"."master_standar_antropometri" from "anon";

revoke truncate on table "public"."master_standar_antropometri" from "anon";

revoke references on table "public"."master_standar_antropometri" from "authenticated";

revoke trigger on table "public"."master_standar_antropometri" from "authenticated";

revoke truncate on table "public"."master_standar_antropometri" from "authenticated";

revoke references on table "public"."master_standar_antropometri" from "service_role";

revoke trigger on table "public"."master_standar_antropometri" from "service_role";

revoke truncate on table "public"."master_standar_antropometri" from "service_role";

revoke references on table "public"."materi_mpasi" from "anon";

revoke trigger on table "public"."materi_mpasi" from "anon";

revoke truncate on table "public"."materi_mpasi" from "anon";

revoke references on table "public"."materi_mpasi" from "authenticated";

revoke trigger on table "public"."materi_mpasi" from "authenticated";

revoke truncate on table "public"."materi_mpasi" from "authenticated";

revoke references on table "public"."materi_mpasi" from "service_role";

revoke trigger on table "public"."materi_mpasi" from "service_role";

revoke truncate on table "public"."materi_mpasi" from "service_role";

revoke references on table "public"."mp_asi" from "anon";

revoke trigger on table "public"."mp_asi" from "anon";

revoke truncate on table "public"."mp_asi" from "anon";

revoke references on table "public"."mp_asi" from "authenticated";

revoke trigger on table "public"."mp_asi" from "authenticated";

revoke truncate on table "public"."mp_asi" from "authenticated";

revoke references on table "public"."mp_asi" from "service_role";

revoke trigger on table "public"."mp_asi" from "service_role";

revoke truncate on table "public"."mp_asi" from "service_role";

revoke references on table "public"."pelayanan_ibu_nifas" from "anon";

revoke trigger on table "public"."pelayanan_ibu_nifas" from "anon";

revoke truncate on table "public"."pelayanan_ibu_nifas" from "anon";

revoke references on table "public"."pelayanan_ibu_nifas" from "authenticated";

revoke trigger on table "public"."pelayanan_ibu_nifas" from "authenticated";

revoke truncate on table "public"."pelayanan_ibu_nifas" from "authenticated";

revoke references on table "public"."pelayanan_ibu_nifas" from "service_role";

revoke trigger on table "public"."pelayanan_ibu_nifas" from "service_role";

revoke truncate on table "public"."pelayanan_ibu_nifas" from "service_role";

revoke references on table "public"."pemantauan_ibu_hamil" from "anon";

revoke trigger on table "public"."pemantauan_ibu_hamil" from "anon";

revoke truncate on table "public"."pemantauan_ibu_hamil" from "anon";

revoke references on table "public"."pemantauan_ibu_hamil" from "authenticated";

revoke trigger on table "public"."pemantauan_ibu_hamil" from "authenticated";

revoke truncate on table "public"."pemantauan_ibu_hamil" from "authenticated";

revoke references on table "public"."pemantauan_ibu_hamil" from "service_role";

revoke trigger on table "public"."pemantauan_ibu_hamil" from "service_role";

revoke truncate on table "public"."pemantauan_ibu_hamil" from "service_role";

revoke references on table "public"."pemantauan_indikator" from "anon";

revoke trigger on table "public"."pemantauan_indikator" from "anon";

revoke truncate on table "public"."pemantauan_indikator" from "anon";

revoke references on table "public"."pemantauan_indikator" from "authenticated";

revoke trigger on table "public"."pemantauan_indikator" from "authenticated";

revoke truncate on table "public"."pemantauan_indikator" from "authenticated";

revoke references on table "public"."pemantauan_indikator" from "service_role";

revoke trigger on table "public"."pemantauan_indikator" from "service_role";

revoke truncate on table "public"."pemantauan_indikator" from "service_role";

revoke references on table "public"."pemeriksaan_anak" from "anon";

revoke trigger on table "public"."pemeriksaan_anak" from "anon";

revoke truncate on table "public"."pemeriksaan_anak" from "anon";

revoke references on table "public"."pemeriksaan_anak" from "authenticated";

revoke trigger on table "public"."pemeriksaan_anak" from "authenticated";

revoke truncate on table "public"."pemeriksaan_anak" from "authenticated";

revoke references on table "public"."pemeriksaan_anak" from "service_role";

revoke trigger on table "public"."pemeriksaan_anak" from "service_role";

revoke truncate on table "public"."pemeriksaan_anak" from "service_role";

revoke references on table "public"."pemeriksaan_dewasa" from "anon";

revoke trigger on table "public"."pemeriksaan_dewasa" from "anon";

revoke truncate on table "public"."pemeriksaan_dewasa" from "anon";

revoke references on table "public"."pemeriksaan_dewasa" from "authenticated";

revoke trigger on table "public"."pemeriksaan_dewasa" from "authenticated";

revoke truncate on table "public"."pemeriksaan_dewasa" from "authenticated";

revoke references on table "public"."pemeriksaan_dewasa" from "service_role";

revoke trigger on table "public"."pemeriksaan_dewasa" from "service_role";

revoke truncate on table "public"."pemeriksaan_dewasa" from "service_role";

revoke references on table "public"."pemeriksaan_dokter_trimester_1" from "anon";

revoke trigger on table "public"."pemeriksaan_dokter_trimester_1" from "anon";

revoke truncate on table "public"."pemeriksaan_dokter_trimester_1" from "anon";

revoke references on table "public"."pemeriksaan_dokter_trimester_1" from "authenticated";

revoke trigger on table "public"."pemeriksaan_dokter_trimester_1" from "authenticated";

revoke truncate on table "public"."pemeriksaan_dokter_trimester_1" from "authenticated";

revoke references on table "public"."pemeriksaan_dokter_trimester_1" from "service_role";

revoke trigger on table "public"."pemeriksaan_dokter_trimester_1" from "service_role";

revoke truncate on table "public"."pemeriksaan_dokter_trimester_1" from "service_role";

revoke references on table "public"."pemeriksaan_dokter_trimester_3" from "anon";

revoke trigger on table "public"."pemeriksaan_dokter_trimester_3" from "anon";

revoke truncate on table "public"."pemeriksaan_dokter_trimester_3" from "anon";

revoke references on table "public"."pemeriksaan_dokter_trimester_3" from "authenticated";

revoke trigger on table "public"."pemeriksaan_dokter_trimester_3" from "authenticated";

revoke truncate on table "public"."pemeriksaan_dokter_trimester_3" from "authenticated";

revoke references on table "public"."pemeriksaan_dokter_trimester_3" from "service_role";

revoke trigger on table "public"."pemeriksaan_dokter_trimester_3" from "service_role";

revoke truncate on table "public"."pemeriksaan_dokter_trimester_3" from "service_role";

revoke references on table "public"."pemeriksaan_kehamilan" from "anon";

revoke trigger on table "public"."pemeriksaan_kehamilan" from "anon";

revoke truncate on table "public"."pemeriksaan_kehamilan" from "anon";

revoke references on table "public"."pemeriksaan_kehamilan" from "authenticated";

revoke trigger on table "public"."pemeriksaan_kehamilan" from "authenticated";

revoke truncate on table "public"."pemeriksaan_kehamilan" from "authenticated";

revoke references on table "public"."pemeriksaan_kehamilan" from "service_role";

revoke trigger on table "public"."pemeriksaan_kehamilan" from "service_role";

revoke truncate on table "public"."pemeriksaan_kehamilan" from "service_role";

revoke references on table "public"."pemeriksaan_laboratorium_jiwa" from "anon";

revoke trigger on table "public"."pemeriksaan_laboratorium_jiwa" from "anon";

revoke truncate on table "public"."pemeriksaan_laboratorium_jiwa" from "anon";

revoke references on table "public"."pemeriksaan_laboratorium_jiwa" from "authenticated";

revoke trigger on table "public"."pemeriksaan_laboratorium_jiwa" from "authenticated";

revoke truncate on table "public"."pemeriksaan_laboratorium_jiwa" from "authenticated";

revoke references on table "public"."pemeriksaan_laboratorium_jiwa" from "service_role";

revoke trigger on table "public"."pemeriksaan_laboratorium_jiwa" from "service_role";

revoke truncate on table "public"."pemeriksaan_laboratorium_jiwa" from "service_role";

revoke references on table "public"."pemeriksaan_lanjutan_trimester_3" from "anon";

revoke trigger on table "public"."pemeriksaan_lanjutan_trimester_3" from "anon";

revoke truncate on table "public"."pemeriksaan_lanjutan_trimester_3" from "anon";

revoke references on table "public"."pemeriksaan_lanjutan_trimester_3" from "authenticated";

revoke trigger on table "public"."pemeriksaan_lanjutan_trimester_3" from "authenticated";

revoke truncate on table "public"."pemeriksaan_lanjutan_trimester_3" from "authenticated";

revoke references on table "public"."pemeriksaan_lanjutan_trimester_3" from "service_role";

revoke trigger on table "public"."pemeriksaan_lanjutan_trimester_3" from "service_role";

revoke truncate on table "public"."pemeriksaan_lanjutan_trimester_3" from "service_role";

revoke references on table "public"."pemeriksaan_lansia" from "anon";

revoke trigger on table "public"."pemeriksaan_lansia" from "anon";

revoke truncate on table "public"."pemeriksaan_lansia" from "anon";

revoke references on table "public"."pemeriksaan_lansia" from "authenticated";

revoke trigger on table "public"."pemeriksaan_lansia" from "authenticated";

revoke truncate on table "public"."pemeriksaan_lansia" from "authenticated";

revoke references on table "public"."pemeriksaan_lansia" from "service_role";

revoke trigger on table "public"."pemeriksaan_lansia" from "service_role";

revoke truncate on table "public"."pemeriksaan_lansia" from "service_role";

revoke references on table "public"."pemeriksaan_remaja" from "anon";

revoke trigger on table "public"."pemeriksaan_remaja" from "anon";

revoke truncate on table "public"."pemeriksaan_remaja" from "anon";

revoke references on table "public"."pemeriksaan_remaja" from "authenticated";

revoke trigger on table "public"."pemeriksaan_remaja" from "authenticated";

revoke truncate on table "public"."pemeriksaan_remaja" from "authenticated";

revoke references on table "public"."pemeriksaan_remaja" from "service_role";

revoke trigger on table "public"."pemeriksaan_remaja" from "service_role";

revoke truncate on table "public"."pemeriksaan_remaja" from "service_role";

revoke references on table "public"."pemeriksaans" from "anon";

revoke trigger on table "public"."pemeriksaans" from "anon";

revoke truncate on table "public"."pemeriksaans" from "anon";

revoke references on table "public"."pemeriksaans" from "authenticated";

revoke trigger on table "public"."pemeriksaans" from "authenticated";

revoke truncate on table "public"."pemeriksaans" from "authenticated";

revoke references on table "public"."pemeriksaans" from "service_role";

revoke trigger on table "public"."pemeriksaans" from "service_role";

revoke truncate on table "public"."pemeriksaans" from "service_role";

revoke references on table "public"."penduduk" from "anon";

revoke trigger on table "public"."penduduk" from "anon";

revoke truncate on table "public"."penduduk" from "anon";

revoke references on table "public"."penduduk" from "authenticated";

revoke trigger on table "public"."penduduk" from "authenticated";

revoke truncate on table "public"."penduduk" from "authenticated";

revoke references on table "public"."penduduk" from "service_role";

revoke trigger on table "public"."penduduk" from "service_role";

revoke truncate on table "public"."penduduk" from "service_role";

revoke references on table "public"."pengguna" from "anon";

revoke trigger on table "public"."pengguna" from "anon";

revoke truncate on table "public"."pengguna" from "anon";

revoke references on table "public"."pengguna" from "authenticated";

revoke trigger on table "public"."pengguna" from "authenticated";

revoke truncate on table "public"."pengguna" from "authenticated";

revoke references on table "public"."pengguna" from "service_role";

revoke trigger on table "public"."pengguna" from "service_role";

revoke truncate on table "public"."pengguna" from "service_role";

revoke references on table "public"."pengukuran_lila" from "anon";

revoke trigger on table "public"."pengukuran_lila" from "anon";

revoke truncate on table "public"."pengukuran_lila" from "anon";

revoke references on table "public"."pengukuran_lila" from "authenticated";

revoke trigger on table "public"."pengukuran_lila" from "authenticated";

revoke truncate on table "public"."pengukuran_lila" from "authenticated";

revoke references on table "public"."pengukuran_lila" from "service_role";

revoke trigger on table "public"."pengukuran_lila" from "service_role";

revoke truncate on table "public"."pengukuran_lila" from "service_role";

revoke references on table "public"."penjelasan_hasil_grafik" from "anon";

revoke trigger on table "public"."penjelasan_hasil_grafik" from "anon";

revoke truncate on table "public"."penjelasan_hasil_grafik" from "anon";

revoke references on table "public"."penjelasan_hasil_grafik" from "authenticated";

revoke trigger on table "public"."penjelasan_hasil_grafik" from "authenticated";

revoke truncate on table "public"."penjelasan_hasil_grafik" from "authenticated";

revoke references on table "public"."penjelasan_hasil_grafik" from "service_role";

revoke trigger on table "public"."penjelasan_hasil_grafik" from "service_role";

revoke truncate on table "public"."penjelasan_hasil_grafik" from "service_role";

revoke references on table "public"."perangkat" from "anon";

revoke trigger on table "public"."perangkat" from "anon";

revoke truncate on table "public"."perangkat" from "anon";

revoke references on table "public"."perangkat" from "authenticated";

revoke trigger on table "public"."perangkat" from "authenticated";

revoke truncate on table "public"."perangkat" from "authenticated";

revoke references on table "public"."perangkat" from "service_role";

revoke trigger on table "public"."perangkat" from "service_role";

revoke truncate on table "public"."perangkat" from "service_role";

revoke references on table "public"."perawatan" from "anon";

revoke trigger on table "public"."perawatan" from "anon";

revoke truncate on table "public"."perawatan" from "anon";

revoke references on table "public"."perawatan" from "authenticated";

revoke trigger on table "public"."perawatan" from "authenticated";

revoke truncate on table "public"."perawatan" from "authenticated";

revoke references on table "public"."perawatan" from "service_role";

revoke trigger on table "public"."perawatan" from "service_role";

revoke truncate on table "public"."perawatan" from "service_role";

revoke references on table "public"."periksa_gigi" from "anon";

revoke trigger on table "public"."periksa_gigi" from "anon";

revoke truncate on table "public"."periksa_gigi" from "anon";

revoke references on table "public"."periksa_gigi" from "authenticated";

revoke trigger on table "public"."periksa_gigi" from "authenticated";

revoke truncate on table "public"."periksa_gigi" from "authenticated";

revoke references on table "public"."periksa_gigi" from "service_role";

revoke trigger on table "public"."periksa_gigi" from "service_role";

revoke truncate on table "public"."periksa_gigi" from "service_role";

revoke references on table "public"."periode_kunjungan" from "anon";

revoke trigger on table "public"."periode_kunjungan" from "anon";

revoke truncate on table "public"."periode_kunjungan" from "anon";

revoke references on table "public"."periode_kunjungan" from "authenticated";

revoke trigger on table "public"."periode_kunjungan" from "authenticated";

revoke truncate on table "public"."periode_kunjungan" from "authenticated";

revoke references on table "public"."periode_kunjungan" from "service_role";

revoke trigger on table "public"."periode_kunjungan" from "service_role";

revoke truncate on table "public"."periode_kunjungan" from "service_role";

revoke references on table "public"."persiapan_melahirkan" from "anon";

revoke trigger on table "public"."persiapan_melahirkan" from "anon";

revoke truncate on table "public"."persiapan_melahirkan" from "anon";

revoke references on table "public"."persiapan_melahirkan" from "authenticated";

revoke trigger on table "public"."persiapan_melahirkan" from "authenticated";

revoke truncate on table "public"."persiapan_melahirkan" from "authenticated";

revoke references on table "public"."persiapan_melahirkan" from "service_role";

revoke trigger on table "public"."persiapan_melahirkan" from "service_role";

revoke truncate on table "public"."persiapan_melahirkan" from "service_role";

revoke references on table "public"."pertumbuhan_Anak" from "anon";

revoke trigger on table "public"."pertumbuhan_Anak" from "anon";

revoke truncate on table "public"."pertumbuhan_Anak" from "anon";

revoke references on table "public"."pertumbuhan_Anak" from "authenticated";

revoke trigger on table "public"."pertumbuhan_Anak" from "authenticated";

revoke truncate on table "public"."pertumbuhan_Anak" from "authenticated";

revoke references on table "public"."pertumbuhan_Anak" from "service_role";

revoke trigger on table "public"."pertumbuhan_Anak" from "service_role";

revoke truncate on table "public"."pertumbuhan_Anak" from "service_role";

revoke references on table "public"."posyandu" from "anon";

revoke trigger on table "public"."posyandu" from "anon";

revoke truncate on table "public"."posyandu" from "anon";

revoke references on table "public"."posyandu" from "authenticated";

revoke trigger on table "public"."posyandu" from "authenticated";

revoke truncate on table "public"."posyandu" from "authenticated";

revoke references on table "public"."posyandu" from "service_role";

revoke trigger on table "public"."posyandu" from "service_role";

revoke truncate on table "public"."posyandu" from "service_role";

revoke references on table "public"."prediksi_stunting" from "anon";

revoke trigger on table "public"."prediksi_stunting" from "anon";

revoke truncate on table "public"."prediksi_stunting" from "anon";

revoke references on table "public"."prediksi_stunting" from "authenticated";

revoke trigger on table "public"."prediksi_stunting" from "authenticated";

revoke truncate on table "public"."prediksi_stunting" from "authenticated";

revoke references on table "public"."prediksi_stunting" from "service_role";

revoke trigger on table "public"."prediksi_stunting" from "service_role";

revoke truncate on table "public"."prediksi_stunting" from "service_role";

revoke references on table "public"."proses_melahirkan" from "anon";

revoke trigger on table "public"."proses_melahirkan" from "anon";

revoke truncate on table "public"."proses_melahirkan" from "anon";

revoke references on table "public"."proses_melahirkan" from "authenticated";

revoke trigger on table "public"."proses_melahirkan" from "authenticated";

revoke truncate on table "public"."proses_melahirkan" from "authenticated";

revoke references on table "public"."proses_melahirkan" from "service_role";

revoke trigger on table "public"."proses_melahirkan" from "service_role";

revoke truncate on table "public"."proses_melahirkan" from "service_role";

revoke references on table "public"."puskesmas" from "anon";

revoke trigger on table "public"."puskesmas" from "anon";

revoke truncate on table "public"."puskesmas" from "anon";

revoke references on table "public"."puskesmas" from "authenticated";

revoke trigger on table "public"."puskesmas" from "authenticated";

revoke truncate on table "public"."puskesmas" from "authenticated";

revoke references on table "public"."puskesmas" from "service_role";

revoke trigger on table "public"."puskesmas" from "service_role";

revoke truncate on table "public"."puskesmas" from "service_role";

revoke references on table "public"."rencana_persalinan" from "anon";

revoke trigger on table "public"."rencana_persalinan" from "anon";

revoke truncate on table "public"."rencana_persalinan" from "anon";

revoke references on table "public"."rencana_persalinan" from "authenticated";

revoke trigger on table "public"."rencana_persalinan" from "authenticated";

revoke truncate on table "public"."rencana_persalinan" from "authenticated";

revoke references on table "public"."rencana_persalinan" from "service_role";

revoke trigger on table "public"."rencana_persalinan" from "service_role";

revoke truncate on table "public"."rencana_persalinan" from "service_role";

revoke references on table "public"."rentang_usia" from "anon";

revoke trigger on table "public"."rentang_usia" from "anon";

revoke truncate on table "public"."rentang_usia" from "anon";

revoke references on table "public"."rentang_usia" from "authenticated";

revoke trigger on table "public"."rentang_usia" from "authenticated";

revoke truncate on table "public"."rentang_usia" from "authenticated";

revoke references on table "public"."rentang_usia" from "service_role";

revoke trigger on table "public"."rentang_usia" from "service_role";

revoke truncate on table "public"."rentang_usia" from "service_role";

revoke references on table "public"."request_perubahan_imunisasi" from "anon";

revoke trigger on table "public"."request_perubahan_imunisasi" from "anon";

revoke truncate on table "public"."request_perubahan_imunisasi" from "anon";

revoke references on table "public"."request_perubahan_imunisasi" from "authenticated";

revoke trigger on table "public"."request_perubahan_imunisasi" from "authenticated";

revoke truncate on table "public"."request_perubahan_imunisasi" from "authenticated";

revoke references on table "public"."request_perubahan_imunisasi" from "service_role";

revoke trigger on table "public"."request_perubahan_imunisasi" from "service_role";

revoke truncate on table "public"."request_perubahan_imunisasi" from "service_role";

revoke references on table "public"."resep_mpasi" from "anon";

revoke trigger on table "public"."resep_mpasi" from "anon";

revoke truncate on table "public"."resep_mpasi" from "anon";

revoke references on table "public"."resep_mpasi" from "authenticated";

revoke trigger on table "public"."resep_mpasi" from "authenticated";

revoke truncate on table "public"."resep_mpasi" from "authenticated";

revoke references on table "public"."resep_mpasi" from "service_role";

revoke trigger on table "public"."resep_mpasi" from "service_role";

revoke truncate on table "public"."resep_mpasi" from "service_role";

revoke references on table "public"."ringkasan_pelayanan_persalinan" from "anon";

revoke trigger on table "public"."ringkasan_pelayanan_persalinan" from "anon";

revoke truncate on table "public"."ringkasan_pelayanan_persalinan" from "anon";

revoke references on table "public"."ringkasan_pelayanan_persalinan" from "authenticated";

revoke trigger on table "public"."ringkasan_pelayanan_persalinan" from "authenticated";

revoke truncate on table "public"."ringkasan_pelayanan_persalinan" from "authenticated";

revoke references on table "public"."ringkasan_pelayanan_persalinan" from "service_role";

revoke trigger on table "public"."ringkasan_pelayanan_persalinan" from "service_role";

revoke truncate on table "public"."ringkasan_pelayanan_persalinan" from "service_role";

revoke references on table "public"."riwayat_kehamilan_lalu" from "anon";

revoke trigger on table "public"."riwayat_kehamilan_lalu" from "anon";

revoke truncate on table "public"."riwayat_kehamilan_lalu" from "anon";

revoke references on table "public"."riwayat_kehamilan_lalu" from "authenticated";

revoke trigger on table "public"."riwayat_kehamilan_lalu" from "authenticated";

revoke truncate on table "public"."riwayat_kehamilan_lalu" from "authenticated";

revoke references on table "public"."riwayat_kehamilan_lalu" from "service_role";

revoke trigger on table "public"."riwayat_kehamilan_lalu" from "service_role";

revoke truncate on table "public"."riwayat_kehamilan_lalu" from "service_role";

revoke references on table "public"."riwayat_proses_melahirkan" from "anon";

revoke trigger on table "public"."riwayat_proses_melahirkan" from "anon";

revoke truncate on table "public"."riwayat_proses_melahirkan" from "anon";

revoke references on table "public"."riwayat_proses_melahirkan" from "authenticated";

revoke trigger on table "public"."riwayat_proses_melahirkan" from "authenticated";

revoke truncate on table "public"."riwayat_proses_melahirkan" from "authenticated";

revoke references on table "public"."riwayat_proses_melahirkan" from "service_role";

revoke trigger on table "public"."riwayat_proses_melahirkan" from "service_role";

revoke truncate on table "public"."riwayat_proses_melahirkan" from "service_role";

revoke references on table "public"."roles" from "anon";

revoke trigger on table "public"."roles" from "anon";

revoke truncate on table "public"."roles" from "anon";

revoke references on table "public"."roles" from "authenticated";

revoke trigger on table "public"."roles" from "authenticated";

revoke truncate on table "public"."roles" from "authenticated";

revoke references on table "public"."roles" from "service_role";

revoke trigger on table "public"."roles" from "service_role";

revoke truncate on table "public"."roles" from "service_role";

revoke references on table "public"."rujukan" from "anon";

revoke trigger on table "public"."rujukan" from "anon";

revoke truncate on table "public"."rujukan" from "anon";

revoke references on table "public"."rujukan" from "authenticated";

revoke trigger on table "public"."rujukan" from "authenticated";

revoke truncate on table "public"."rujukan" from "authenticated";

revoke references on table "public"."rujukan" from "service_role";

revoke trigger on table "public"."rujukan" from "service_role";

revoke truncate on table "public"."rujukan" from "service_role";

revoke references on table "public"."skrining_dm_gestasional" from "anon";

revoke trigger on table "public"."skrining_dm_gestasional" from "anon";

revoke truncate on table "public"."skrining_dm_gestasional" from "anon";

revoke references on table "public"."skrining_dm_gestasional" from "authenticated";

revoke trigger on table "public"."skrining_dm_gestasional" from "authenticated";

revoke truncate on table "public"."skrining_dm_gestasional" from "authenticated";

revoke references on table "public"."skrining_dm_gestasional" from "service_role";

revoke trigger on table "public"."skrining_dm_gestasional" from "service_role";

revoke truncate on table "public"."skrining_dm_gestasional" from "service_role";

revoke references on table "public"."skrining_pemantauan" from "anon";

revoke trigger on table "public"."skrining_pemantauan" from "anon";

revoke truncate on table "public"."skrining_pemantauan" from "anon";

revoke references on table "public"."skrining_pemantauan" from "authenticated";

revoke trigger on table "public"."skrining_pemantauan" from "authenticated";

revoke truncate on table "public"."skrining_pemantauan" from "authenticated";

revoke references on table "public"."skrining_pemantauan" from "service_role";

revoke trigger on table "public"."skrining_pemantauan" from "service_role";

revoke truncate on table "public"."skrining_pemantauan" from "service_role";

revoke references on table "public"."skrining_preeklampsia" from "anon";

revoke trigger on table "public"."skrining_preeklampsia" from "anon";

revoke truncate on table "public"."skrining_preeklampsia" from "anon";

revoke references on table "public"."skrining_preeklampsia" from "authenticated";

revoke trigger on table "public"."skrining_preeklampsia" from "authenticated";

revoke truncate on table "public"."skrining_preeklampsia" from "authenticated";

revoke references on table "public"."skrining_preeklampsia" from "service_role";

revoke trigger on table "public"."skrining_preeklampsia" from "service_role";

revoke truncate on table "public"."skrining_preeklampsia" from "service_role";

revoke references on table "public"."status" from "anon";

revoke trigger on table "public"."status" from "anon";

revoke truncate on table "public"."status" from "anon";

revoke references on table "public"."status" from "authenticated";

revoke trigger on table "public"."status" from "authenticated";

revoke truncate on table "public"."status" from "authenticated";

revoke references on table "public"."status" from "service_role";

revoke trigger on table "public"."status" from "service_role";

revoke truncate on table "public"."status" from "service_role";

revoke references on table "public"."status_jadwal" from "anon";

revoke trigger on table "public"."status_jadwal" from "anon";

revoke truncate on table "public"."status_jadwal" from "anon";

revoke references on table "public"."status_jadwal" from "authenticated";

revoke trigger on table "public"."status_jadwal" from "authenticated";

revoke truncate on table "public"."status_jadwal" from "authenticated";

revoke references on table "public"."status_jadwal" from "service_role";

revoke trigger on table "public"."status_jadwal" from "service_role";

revoke truncate on table "public"."status_jadwal" from "service_role";

revoke references on table "public"."status_kunjungan" from "anon";

revoke trigger on table "public"."status_kunjungan" from "anon";

revoke truncate on table "public"."status_kunjungan" from "anon";

revoke references on table "public"."status_kunjungan" from "authenticated";

revoke trigger on table "public"."status_kunjungan" from "authenticated";

revoke truncate on table "public"."status_kunjungan" from "authenticated";

revoke references on table "public"."status_kunjungan" from "service_role";

revoke trigger on table "public"."status_kunjungan" from "service_role";

revoke truncate on table "public"."status_kunjungan" from "service_role";

revoke references on table "public"."status_request" from "anon";

revoke trigger on table "public"."status_request" from "anon";

revoke truncate on table "public"."status_request" from "anon";

revoke references on table "public"."status_request" from "authenticated";

revoke trigger on table "public"."status_request" from "authenticated";

revoke truncate on table "public"."status_request" from "authenticated";

revoke references on table "public"."status_request" from "service_role";

revoke trigger on table "public"."status_request" from "service_role";

revoke truncate on table "public"."status_request" from "service_role";

revoke references on table "public"."vaksin" from "anon";

revoke trigger on table "public"."vaksin" from "anon";

revoke truncate on table "public"."vaksin" from "anon";

revoke references on table "public"."vaksin" from "authenticated";

revoke trigger on table "public"."vaksin" from "authenticated";

revoke truncate on table "public"."vaksin" from "authenticated";

revoke references on table "public"."vaksin" from "service_role";

revoke trigger on table "public"."vaksin" from "service_role";

revoke truncate on table "public"."vaksin" from "service_role";

revoke references on table "public"."warna_tinja_anak" from "anon";

revoke trigger on table "public"."warna_tinja_anak" from "anon";

revoke truncate on table "public"."warna_tinja_anak" from "anon";

revoke references on table "public"."warna_tinja_anak" from "authenticated";

revoke trigger on table "public"."warna_tinja_anak" from "authenticated";

revoke truncate on table "public"."warna_tinja_anak" from "authenticated";

revoke references on table "public"."warna_tinja_anak" from "service_role";

revoke trigger on table "public"."warna_tinja_anak" from "service_role";

revoke truncate on table "public"."warna_tinja_anak" from "service_role";

alter table "public"."kategori_tanda_bahaya" drop constraint "chk_kategori_tanda_bahaya_tipe_lembar";

alter table "public"."master_standar_antropometri" drop constraint "chk_master_standar_antropometri_jenis_kelamin";

alter table "public"."kategori_tanda_bahaya" add constraint "chk_kategori_tanda_bahaya_tipe_lembar" CHECK (((tipe_lembar)::text = ANY ((ARRAY['A'::character varying, 'B'::character varying, 'Umum'::character varying])::text[]))) not valid;

alter table "public"."kategori_tanda_bahaya" validate constraint "chk_kategori_tanda_bahaya_tipe_lembar";

alter table "public"."master_standar_antropometri" add constraint "chk_master_standar_antropometri_jenis_kelamin" CHECK (((jenis_kelamin)::text = ANY ((ARRAY['Laki-laki'::character varying, 'Perempuan'::character varying])::text[]))) not valid;

alter table "public"."master_standar_antropometri" validate constraint "chk_master_standar_antropometri_jenis_kelamin";


