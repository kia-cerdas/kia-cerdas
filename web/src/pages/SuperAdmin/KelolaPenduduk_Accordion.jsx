// INSTRUKSI PENGGUNAAN:
// 1. Backup file KelolaPenduduk.jsx yang lama
// 2. Copy kode dari file ini
// 3. Replace isi file KelolaPenduduk.jsx dengan kode dari file ini
// 4. Atau rename file ini menjadi KelolaPenduduk.jsx

import React, { useState, useEffect } from "react";
import { 
  Plus, Trash2, Edit, Search, X, Filter, 
  ChevronLeft, ChevronRight, RefreshCw,
  ChevronDown, ChevronUp, CheckCircle, Circle, AlertCircle
} from "lucide-react";
import MainLayout from "../../components/Layout/MainLayout";
import { 
  getPendudukWithFilters, 
  getPendudukById,
  createKependudukan, 
  updateKependudukan, 
  deleteKependudukan 
} from "../../services/kependudukan";
import { listDesa } from "../../services/desa";
import { getAllPosyandu } from "../../services/posyandu";

// Dropdown options
const GOLONGAN_DARAH_OPTIONS = ["", "A", "B", "AB", "O", "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"];
const AGAMA_OPTIONS = ["", "Islam", "Kristen Protestan", "Katolik", "Hindu", "Buddha", "Konghucu"];
const PENDIDIKAN_OPTIONS = ["", "Tidak/Belum Sekolah", "Belum Tamat SD/Sederajat", "Tamat SD/Sederajat", "SLTP/Sederajat", "SLTA/Sederajat", "Diploma I/II", "Akademi/Diploma III/S.Muda", "Diploma IV/Strata I", "Strata II", "Strata III"];
const STATUS_OPTIONS = ["", "Kawin", "Belum Kawin", "Cerai Hidup", "Cerai Mati"];
const HUBUNGAN_OPTIONS = ["", "Kepala Keluarga", "Istri", "Anak", "Menantu", "Cucu", "Orang Tua", "Mertua", "Keluarga Lainnya"];
const JENIS_KELAMIN_OPTIONS = ["Laki-laki", "Perempuan"];
const KEWARGANEGARAAN_OPTIONS = ["WNI", "WNA"];

const cardClass = "bg-white rounded-2xl shadow-sm border border-slate-100";

// Sort order for hubungan keluarga
const HUBUNGAN_ORDER = {
  "Kepala Keluarga": 1,
  "Istri": 2,
  "Suami": 2,
  "Anak": 3,
  "Menantu": 4,
  "Cucu": 5,
  "Orang Tua": 6,
  "Mertua": 7,
  "Keluarga Lainnya": 8,
};

const sortPenduduk = (a, b) => {
  const kodeA = (a.kode_keluarga || "ZZZ").toLowerCase();
  const kodeB = (b.kode_keluarga || "ZZZ").toLowerCase();
}