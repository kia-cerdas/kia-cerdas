import React, { useState, useRef, useCallback } from "react";
import * as XLSX from "xlsx";
import {
  X, Upload, FileSpreadsheet, Download, AlertCircle,
  CheckCircle, Loader, ChevronDown, ChevronUp, MapPin,
  RefreshCw, ChevronRight, ChevronLeft,
} from "lucide-react";
import { importBulkPenduduk } from "../../../services/kependudukan";

// ── Column map ────────────────────────────────────────────────────────────────
const COLUMN_MAP = {
  "RW": "rw", "RT": "rt", "Dusun": "dusun", "Alamat": "alamat",
  "Kode Keluarga": "kode_keluarga", "Nama Kepala Keluarga": "nama_kepala_keluarga",
  "NIK": "nik", "No.NIK": "nik", "No.N I K": "nik", "Nomor NIK": "nik",
  "Nama Anggota Keluarga": "nama_anggota_keluarga",
  "Jenis Kelamin": "jenis_kelamin", "Hubungan": "hubungan",
  "Tempat Lahir": "tempat_lahir", "Tanggal Lahir": "tanggal_lahir",
  "Status": "status", "Agama": "agama",
  "Golongan Darah": "golongan_darah", "GDarah": "golongan_darah",
  "Gol. Darah": "golongan_darah", "Gol.Darah": "golongan_darah",
  "Kewarganegaraan": "kewarganegaraan",
  "Etnis/Suku": "etnis_suku", "Etnis / Suku": "etnis_suku",
  "Etnis": "etnis_suku", "Suku": "etnis_suku",
  "Pendidikan": "pendidikan", "Pekerjaan": "pekerjaan",
  "Telepon": "telepon", "No. Telepon": "telepon",
  "No.Telepon": "telepon", "HP": "telepon",
};

const NUMERIC_AS_TEXT_FIELDS = new Set(["nik", "kode_keluarga"]);

const REQUIRED_HEADER_OPTIONS = {
  nama_anggota_keluarga: ["Nama Anggota Keluarga"],
  tanggal_lahir: ["Tanggal Lahir"],
};

const CORRECTION_COLUMNS = [
  { key: "nama_anggota_keluarga", label: "Nama", width: "min-w-[140px]" },
  { key: "nik",                   label: "NIK",  width: "min-w-[150px]", mono: true },
  { key: "jenis_kelamin",         label: "Jenis Kelamin", width: "min-w-[100px]" },
  { key: "hubungan",              label: "Hubungan", width: "min-w-[110px]" },
  { key: "tanggal_lahir",         label: "Tgl Lahir", width: "min-w-[110px]" },
  { key: "tempat_lahir",          label: "Tempat Lahir", width: "min-w-[110px]" },
  { key: "status",                label: "Status", width: "min-w-[90px]" },
  { key: "agama",                 label: "Agama", width: "min-w-[80px]" },
  { key: "golongan_darah",        label: "Gol. Darah", width: "min-w-[75px]" },
  { key: "kewarganegaraan",       label: "Kewarganegaraan", width: "min-w-[110px]" },
  { key: "etnis_suku",            label: "Etnis/Suku", width: "min-w-[90px]" },
  { key: "pendidikan",            label: "Pendidikan", width: "min-w-[90px]" },
  { key: "pekerjaan",             label: "Pekerjaan", width: "min-w-[110px]" },
  { key: "telepon",               label: "Telepon", width: "min-w-[110px]" },
  { key: "rw",                    label: "RW", width: "min-w-[55px]" },
  { key: "rt",                    label: "RT", width: "min-w-[55px]" },
  { key: "dusun",                 label: "Dusun", width: "min-w-[100px]" },
  { key: "alamat",                label: "Alamat", width: "min-w-[140px]" },
  { key: "kode_keluarga",         label: "Kode KK", width: "min-w-[120px]", mono: true },
  { key: "nama_kepala_keluarga",  label: "Kepala KK", width: "min-w-[130px]" },
];

// ── Helpers ───────────────────────────────────────────────────────────────────
const cellToText = (raw_val) => {
  if (raw_val === undefined || raw_val === null || raw_val === "") return "";
  if (typeof raw_val === "number") return raw_val.toFixed(0);
  return String(raw_val).trim();
};

const parseExcelDate = (raw_val) => {
  if (raw_val === undefined || raw_val === null || raw_val === "") return "";
  if (typeof raw_val === "number") {
    const date = XLSX.SSF.parse_date_code(raw_val);
    if (!date) return "";
    return `${date.y}-${String(date.m).padStart(2, "0")}-${String(date.d).padStart(2, "0")}`;
  }
  const s = String(raw_val).trim();
  const dmy = s.match(/^(\d{1,2})[/\-](\d{1,2})[/\-](\d{4})$/);
  if (dmy) return `${dmy[3]}-${String(dmy[2]).padStart(2, "0")}-${String(dmy[1]).padStart(2, "0")}`;
  if (/^\d{4}-\d{2}-\d{2}$/.test(s)) return s;
  return s;
};

const toISODate = (dateStr) => {
  if (!dateStr) return "";
  if (/^\d{4}-\d{2}-\d{2}T/.test(dateStr)) return dateStr;
  if (/^\d{4}-\d{2}-\d{2}$/.test(dateStr)) return `${dateStr}T00:00:00Z`;
  return dateStr;
};

const buildPayload = (obj, desaId) => ({
  rw:                    String(obj.rw || ""),
  rt:                    String(obj.rt || ""),
  dusun:                 String(obj.dusun || ""),
  alamat:                String(obj.alamat || ""),
  kode_keluarga:         String(obj.kode_keluarga || ""),
  nama_kepala_keluarga:  String(obj.nama_kepala_keluarga || ""),
  nik:                   String(obj.nik || ""),
  nama_anggota_keluarga: String(obj.nama_anggota_keluarga || ""),
  jenis_kelamin:         String(obj.jenis_kelamin || "Laki-laki"),
  hubungan:              String(obj.hubungan || ""),
  tempat_lahir:          String(obj.tempat_lahir || ""),
  tanggal_lahir:         toISODate(obj.tanggal_lahir),
  status:                String(obj.status || ""),
  agama:                 String(obj.agama || ""),
  golongan_darah:        String(obj.golongan_darah || ""),
  kewarganegaraan:       String(obj.kewarganegaraan || "WNI"),
  etnis_suku:            String(obj.etnis_suku || ""),
  pendidikan:            String(obj.pendidikan || ""),
  pekerjaan:             String(obj.pekerjaan || ""),
  telepon:               String(obj.telepon || ""),
  desa_id:               desaId ? parseInt(desaId, 10) : null,
  posyandu_id:           null,
});

const translateError = (msg) => {
  if (!msg) return "Terjadi kesalahan tidak diketahui.";
  const m = String(msg).toLowerCase();
  if (m.includes("duplicate key") || m.includes("unique constraint"))
    return "Data sudah terdaftar di sistem.";
  if (m.includes("nik sudah terdaftar"))
    return "NIK sudah terdaftar di sistem.";
  if (m.includes("format request tidak valid"))
    return "Format data tidak valid.";
  if (m.includes("nama_anggota_keluarga wajib"))
    return "Nama anggota keluarga wajib diisi.";
  if (m.includes("tanggal_lahir wajib"))
    return "Tanggal lahir wajib diisi.";
  if (m.includes("unauthorized"))
    return "Sesi login habis, silakan login ulang.";
  return msg;
};

// ── Template ──────────────────────────────────────────────────────────────────
const TEMPLATE_HEADERS = [
  "RW", "RT", "Dusun", "Alamat", "Kode Keluarga", "Nama Kepala Keluarga",
  "No.N I K", "Nama Anggota Keluarga", "Jenis Kelamin", "Hubungan",
  "Tempat Lahir", "Tanggal Lahir", "Status", "Agama", "GDarah",
  "Kewarganegaraan", "Etnis / Suku", "Pendidikan", "Pekerjaan",
];
const TEMPLATE_EXAMPLE = {
  "RW": "001", "RT": "002", "Dusun": "Dusun Mawar", "Alamat": "Jl. Mawar No.1",
  "Kode Keluarga": "KK-2024-001", "Nama Kepala Keluarga": "Budi Santoso",
  "No.N I K": "3271010101990001", "Nama Anggota Keluarga": "Budi Santoso",
  "Jenis Kelamin": "Laki-laki", "Hubungan": "Kepala Keluarga",
  "Tempat Lahir": "Bandung", "Tanggal Lahir": "1990-01-01",
  "Status": "Kawin", "Agama": "Islam", "GDarah": "O",
  "Kewarganegaraan": "WNI", "Etnis / Suku": "Sunda",
  "Pendidikan": "S1", "Pekerjaan": "Petani",
};
const downloadTemplate = () => {
  const ws = XLSX.utils.aoa_to_sheet([
    TEMPLATE_HEADERS,
    TEMPLATE_HEADERS.map(h => TEMPLATE_EXAMPLE[h] ?? ""),
  ]);
  ws["!cols"] = TEMPLATE_HEADERS.map(() => ({ wch: 24 }));
  const wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, ws, "Data Penduduk");
  XLSX.writeFile(wb, "template_import_penduduk.xlsx");
};

// ── Step Indicator ────────────────────────────────────────────────────────────
const STEPS = [
  { n: 1, label: "Pilih Desa" },
  { n: 2, label: "Upload File" },
  { n: 3, label: "Import Data" },
  { n: 4, label: "Selesai" },
];

const StepIndicator = ({ current }) => (
  <div className="flex items-center justify-center gap-0 mb-6">
    {STEPS.map((s, i) => {
      const done    = current > s.n;
      const active  = current === s.n;
      return (
        <React.Fragment key={s.n}>
          <div className="flex flex-col items-center">
            <div className={`w-8 h-8 rounded-full flex items-center justify-center text-xs font-bold border-2 transition-all
              ${done   ? "bg-green-500 border-green-500 text-white"
              : active ? "bg-indigo-600 border-indigo-600 text-white"
                       : "bg-white border-slate-300 text-slate-400"}`}>
              {done ? <CheckCircle size={14} /> : s.n}
            </div>
            <span className={`mt-1 text-[10px] font-medium whitespace-nowrap
              ${done ? "text-green-600" : active ? "text-indigo-600" : "text-slate-400"}`}>
              {s.label}
            </span>
          </div>
          {i < STEPS.length - 1 && (
            <div className={`h-0.5 w-12 mb-4 mx-1 transition-all ${current > s.n ? "bg-green-400" : "bg-slate-200"}`} />
          )}
        </React.Fragment>
      );
    })}
  </div>
);

// ── Editable Cell ─────────────────────────────────────────────────────────────
const EditableCell = ({ value, onChange, mono }) => {
  const [editing, setEditing] = useState(false);
  const [draft, setDraft]     = useState(value);

  const commit = () => {
    setEditing(false);
    if (draft !== value) onChange(draft);
  };

  if (editing) {
    return (
      <input
        autoFocus
        value={draft}
        onChange={e => setDraft(e.target.value)}
        onBlur={commit}
        onKeyDown={e => {
          if (e.key === "Enter") commit();
          if (e.key === "Escape") { setDraft(value); setEditing(false); }
        }}
        className={`w-full px-1.5 py-0.5 border border-indigo-400 rounded focus:outline-none bg-white text-xs ${mono ? "font-mono" : ""}`}
        style={{ minWidth: 80 }}
      />
    );
  }
  return (
    <div
      onClick={() => { setDraft(value); setEditing(true); }}
      title="Klik untuk edit"
      className={`px-1.5 py-0.5 rounded cursor-pointer hover:bg-indigo-50 hover:ring-1 hover:ring-indigo-300 transition-colors text-xs truncate
        ${mono ? "font-mono" : ""} ${!value ? "text-slate-300 italic" : "text-slate-700"}`}
    >
      {value || "—"}
    </div>
  );
};

// ── Main Component ────────────────────────────────────────────────────────────
const ImportExcelModal = ({ isOpen, onClose, onSuccess, desasList = [] }) => {
  const fileRef = useRef(null);

  // step: 1 | 2 | 3 | 4
  const [step, setStep]               = useState(1);
  const [selectedDesaId, setSelectedDesaId] = useState("");
  const [file, setFile]               = useState(null);
  const [rows, setRows]               = useState([]);
  const [parseErrors, setParseErrors] = useState([]);
  const [importing, setImporting]     = useState(false);
  const [progress, setProgress]       = useState({ done: 0, total: 0, errors: [] });

  // Koreksi
  const [failedRows, setFailedRows]   = useState([]);
  const [correcting, setCorrecting]   = useState(false);
  const [retryProgress, setRetryProgress] = useState({ done: 0, total: 0, errors: [] });
  const [showErrDetail, setShowErrDetail] = useState(false);

  const resetAll = () => {
    setStep(1); setSelectedDesaId(""); setFile(null); setRows([]);
    setParseErrors([]); setImporting(false);
    setProgress({ done: 0, total: 0, errors: [] });
    setFailedRows([]); setCorrecting(false);
    setRetryProgress({ done: 0, total: 0, errors: [] });
    setShowErrDetail(false);
    if (fileRef.current) fileRef.current.value = "";
  };

  const handleClose = () => { resetAll(); onClose(); };

  const selectedDesaName = desasList.find(d => String(d.id) === String(selectedDesaId))?.nama_desa || "";

  // ── Parse file Excel ──
  const parseFile = (f) => {
    setParseErrors([]); setRows([]);
    const reader = new FileReader();
    reader.onload = (e) => {
      try {
        const wb  = XLSX.read(e.target.result, { type: "array", cellDates: false, raw: true });
        const ws  = wb.Sheets[wb.SheetNames[0]];
        const raw = XLSX.utils.sheet_to_json(ws, { header: 1, defval: "", raw: true });

        if (raw.length < 2) { setParseErrors(["File kosong atau tidak memiliki data."]); return; }

        const headers = raw[0].map(h => String(h).trim());
        const missingFields = [];
        for (const [, candidates] of Object.entries(REQUIRED_HEADER_OPTIONS)) {
          if (!candidates.some(c => headers.includes(c))) missingFields.push(candidates[0]);
        }
        if (missingFields.length > 0) {
          setParseErrors([`Kolom wajib tidak ditemukan: ${missingFields.join(", ")}`]); return;
        }

        const rowErrors = [];
        const parsed    = [];
        raw.slice(1).forEach((row, idx) => {
          if (row.every(c => c === "" || c === null || c === undefined)) return;
          const obj = {};
          headers.forEach((h, i) => {
            const field = COLUMN_MAP[h];
            if (!field) return;
            const rv = row[i];
            if (field === "tanggal_lahir")              obj[field] = parseExcelDate(rv);
            else if (NUMERIC_AS_TEXT_FIELDS.has(field)) obj[field] = cellToText(rv);
            else obj[field] = rv !== undefined && rv !== null ? String(rv).trim() : "";
          });
          const errs = [];
          if (!obj.nama_anggota_keluarga) errs.push("Nama kosong");
          if (!obj.tanggal_lahir)         errs.push("Tanggal Lahir kosong");
          if (errs.length > 0) rowErrors.push(`Baris ${idx + 2}: ${errs.join(", ")}`);
          else parsed.push(obj);
        });

        setParseErrors(rowErrors);
        setRows(parsed);
      } catch (err) {
        setParseErrors([`Gagal membaca file: ${err.message}`]);
      }
    };
    reader.readAsArrayBuffer(f);
  };

  const handleFileChange = (e) => {
    const f = e.target.files?.[0];
    if (!f) return;
    setFile(f); parseFile(f);
  };

  const handleDrop = (e) => {
    e.preventDefault();
    const f = e.dataTransfer.files?.[0];
    if (!f) return;
    setFile(f); parseFile(f);
  };

  // ── Import pertama ──
  const handleImport = async () => {
    const payloads = rows.map(r => buildPayload(r, selectedDesaId));
    setImporting(true);
    setProgress({ done: 0, total: payloads.length, errors: [] });

    const result = await importBulkPenduduk(payloads, (done, total, errors) => {
      setProgress({ done, total, errors: [...errors] });
    }, translateError);

    setImporting(false);
    if (result.success > 0) onSuccess?.();

    if (result.errors.length > 0) {
      setFailedRows(result.errors.map(e => ({ payload: { ...e.row }, message: e.message })));
    }
    // Otomatis pindah ke step 4 setelah import selesai
    setStep(4);
  };

  // ── Edit cell di tabel koreksi ──
  const handleFailedCellChange = useCallback((rowIdx, field, value) => {
    setFailedRows(prev => {
      const next = [...prev];
      next[rowIdx] = { ...next[rowIdx], payload: { ...next[rowIdx].payload, [field]: value } };
      return next;
    });
  }, []);

  // ── Simpan koreksi ──
  const handleRetry = async () => {
    const payloads = failedRows.map(fr => buildPayload(fr.payload, selectedDesaId));
    setCorrecting(true);
    setRetryProgress({ done: 0, total: payloads.length, errors: [] });

    const result = await importBulkPenduduk(payloads, (done, total, errors) => {
      setRetryProgress({ done, total, errors: [...errors] });
    }, translateError);

    setCorrecting(false);
    if (result.success > 0) onSuccess?.();

    setFailedRows(result.errors.length > 0
      ? result.errors.map(e => ({ payload: { ...e.row }, message: e.message }))
      : []
    );
  };

  if (!isOpen) return null;

  const firstSuccess = progress.total - progress.errors.length;
  const retrySuccess = retryProgress.total - retryProgress.errors.length;

  // ─────────────────────────────────────────────────────────────────────────────
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm md:pl-64">
      <div className="bg-white rounded-2xl shadow-xl w-full max-w-4xl max-h-[92vh] flex flex-col mx-4">

        {/* ── Header ── */}
        <div className="px-6 pt-5 pb-4 border-b border-slate-100">
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center gap-2">
              <FileSpreadsheet size={20} className="text-green-600" />
              <h2 className="text-lg font-semibold text-slate-800">Import Data Penduduk</h2>
            </div>
            <button onClick={handleClose} className="p-2 hover:bg-slate-100 rounded-full transition-colors">
              <X size={18} className="text-slate-400" />
            </button>
          </div>
          <StepIndicator current={step} />
        </div>

        {/* ── Body ── */}
        <div className="flex-1 overflow-y-auto px-6 py-6">

          {/* ══════════ STEP 1 — Pilih Desa ══════════ */}
          {step === 1 && (
            <div className="max-w-md mx-auto space-y-6">
              <div className="text-center">
                <div className="w-14 h-14 bg-indigo-50 rounded-2xl flex items-center justify-center mx-auto mb-3">
                  <MapPin size={28} className="text-indigo-600" />
                </div>
                <h3 className="text-base font-semibold text-slate-800">Pilih Desa Tujuan</h3>
                <p className="text-sm text-slate-400 mt-1">Data yang diimport akan masuk ke desa yang dipilih.</p>
              </div>

              <div>
                <label className="block text-sm font-medium text-slate-600 mb-1.5">Desa</label>
                <select
                  value={selectedDesaId}
                  onChange={e => setSelectedDesaId(e.target.value)}
                  className="w-full px-4 py-3 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-indigo-500 text-sm bg-white"
                >
                  <option value="">-- Pilih Desa --</option>
                  {desasList.map(d => <option key={d.id} value={d.id}>{d.nama_desa}</option>)}
                </select>
              </div>

              {selectedDesaId && (
                <div className="flex items-center gap-2 p-3 bg-green-50 rounded-xl border border-green-200">
                  <CheckCircle size={16} className="text-green-600 shrink-0" />
                  <p className="text-sm text-green-700">
                    Desa <strong>{selectedDesaName}</strong> dipilih sebagai tujuan import.
                  </p>
                </div>
              )}
            </div>
          )}

          {/* ══════════ STEP 2 — Upload File ══════════ */}
          {step === 2 && (
            <div className="max-w-md mx-auto space-y-5">
              <div className="text-center">
                <div className="w-14 h-14 bg-green-50 rounded-2xl flex items-center justify-center mx-auto mb-3">
                  <Upload size={28} className="text-green-600" />
                </div>
                <h3 className="text-base font-semibold text-slate-800">Upload File Excel</h3>
                <p className="text-sm text-slate-400 mt-1">
                  Desa tujuan: <strong className="text-slate-600">{selectedDesaName}</strong>
                </p>
              </div>

              {/* Download template */}
              <div className="flex items-center justify-between p-3 bg-blue-50 rounded-xl border border-blue-100">
                <div>
                  <p className="text-xs font-semibold text-blue-800">Belum punya template?</p>
                  <p className="text-xs text-blue-500 mt-0.5">Download template Excel untuk format yang benar.</p>
                </div>
                <button
                  onClick={downloadTemplate}
                  className="inline-flex items-center gap-1.5 px-3 py-1.5 bg-blue-600 text-white rounded-lg text-xs font-medium hover:bg-blue-700 transition-colors whitespace-nowrap"
                >
                  <Download size={12} /> Template
                </button>
              </div>

              {/* Drop zone */}
              <div
                onDrop={handleDrop}
                onDragOver={e => e.preventDefault()}
                onClick={() => fileRef.current?.click()}
                className={`border-2 border-dashed rounded-xl p-8 text-center cursor-pointer transition-colors
                  ${file && rows.length > 0
                    ? "border-green-400 bg-green-50/40"
                    : "border-slate-300 hover:border-indigo-400 hover:bg-indigo-50/20"}`}
              >
                {file && rows.length > 0
                  ? <CheckCircle size={30} className="mx-auto text-green-500 mb-2" />
                  : <Upload size={30} className="mx-auto text-slate-400 mb-2" />
                }
                <p className="text-sm font-medium text-slate-600">
                  {file ? file.name : "Klik atau seret file Excel ke sini"}
                </p>
                <p className="text-xs text-slate-400 mt-1">.xlsx, .xls</p>
                <input ref={fileRef} type="file" accept=".xlsx,.xls" className="hidden" onChange={handleFileChange} />
              </div>

              {/* Parse errors */}
              {parseErrors.length > 0 && (
                <div className="p-3 bg-amber-50 rounded-xl border border-amber-200">
                  <p className="text-xs font-semibold text-amber-700 flex items-center gap-1.5 mb-1">
                    <AlertCircle size={13} /> {parseErrors.length} baris dilewati
                  </p>
                  <div className="max-h-24 overflow-y-auto space-y-0.5">
                    {parseErrors.map((e, i) => <p key={i} className="text-xs text-amber-600 pl-4">{e}</p>)}
                  </div>
                </div>
              )}

              {/* Info jumlah baris */}
              {rows.length > 0 && (
                <div className="p-3 bg-slate-50 rounded-xl border border-slate-200 text-center">
                  <p className="text-sm text-slate-600">
                    <span className="text-indigo-600 font-bold text-lg">{rows.length}</span> baris data siap diimport
                  </p>
                </div>
              )}
            </div>
          )}

          {/* ══════════ STEP 3 — Proses Import ══════════ */}
          {step === 3 && (
            <div className="max-w-md mx-auto space-y-6">
              <div className="text-center">
                <div className={`w-14 h-14 rounded-2xl flex items-center justify-center mx-auto mb-3 ${importing ? "bg-indigo-50" : "bg-green-50"}`}>
                  {importing
                    ? <Loader size={28} className="text-indigo-600 animate-spin" />
                    : <CheckCircle size={28} className="text-green-600" />
                  }
                </div>
                <h3 className="text-base font-semibold text-slate-800">
                  {importing ? "Sedang Mengimport..." : "Import Selesai"}
                </h3>
                <p className="text-sm text-slate-400 mt-1">
                  {importing
                    ? `Memproses ${progress.done} dari ${progress.total} data`
                    : `${firstSuccess} dari ${progress.total} data berhasil disimpan`
                  }
                </p>
              </div>

              {/* Progress bar */}
              <div className="space-y-2">
                <div className="flex justify-between text-xs text-slate-500">
                  <span>Progress</span>
                  <span>{progress.total > 0 ? Math.round((progress.done / progress.total) * 100) : 0}%</span>
                </div>
                <div className="w-full bg-slate-200 rounded-full h-3 overflow-hidden">
                  <div
                    className="bg-indigo-600 h-3 rounded-full transition-all duration-300"
                    style={{ width: `${progress.total > 0 ? (progress.done / progress.total) * 100 : 0}%` }}
                  />
                </div>
                <div className="flex justify-between text-xs">
                  <span className="text-green-600 font-medium">{firstSuccess} berhasil</span>
                  <span className="text-red-500">{progress.errors.length} gagal</span>
                </div>
              </div>

              {/* Info */}
              {importing && (
                <p className="text-xs text-slate-400 text-center">
                  Mohon tunggu, jangan tutup jendela ini...
                </p>
              )}
            </div>
          )}

          {/* ══════════ STEP 4 — Hasil & Koreksi ══════════ */}
          {step === 4 && (
            <div className="space-y-5">

              {/* Ringkasan hasil import */}
              <div className="grid grid-cols-2 gap-3">
                <div className="p-4 bg-green-50 rounded-xl border border-green-200 text-center">
                  <p className="text-2xl font-bold text-green-600">{firstSuccess}</p>
                  <p className="text-xs text-green-700 mt-0.5">Berhasil disimpan</p>
                </div>
                <div className={`p-4 rounded-xl border text-center ${progress.errors.length > 0 ? "bg-red-50 border-red-200" : "bg-slate-50 border-slate-200"}`}>
                  <p className={`text-2xl font-bold ${progress.errors.length > 0 ? "text-red-500" : "text-slate-400"}`}>
                    {progress.errors.length}
                  </p>
                  <p className={`text-xs mt-0.5 ${progress.errors.length > 0 ? "text-red-600" : "text-slate-400"}`}>
                    Gagal diimport
                  </p>
                </div>
              </div>

              {/* Semua berhasil */}
              {progress.errors.length === 0 && (
                <div className="p-4 bg-green-50 rounded-xl border border-green-200 flex items-center gap-3">
                  <CheckCircle size={20} className="text-green-600 shrink-0" />
                  <div>
                    <p className="text-sm font-semibold text-green-800">Semua data berhasil disimpan!</p>
                    <p className="text-xs text-green-600 mt-0.5">Ke desa: <strong>{selectedDesaName}</strong></p>
                  </div>
                </div>
              )}

              {/* Ada yang gagal → tabel koreksi */}
              {failedRows.length > 0 && (
                <div className="space-y-3">
                  <div className="p-3 bg-amber-50 rounded-xl border border-amber-200 flex items-start gap-2">
                    <AlertCircle size={16} className="text-amber-500 shrink-0 mt-0.5" />
                    <div>
                      <p className="text-sm font-semibold text-amber-800">
                        {failedRows.length} data perlu dikoreksi
                      </p>
                      <p className="text-xs text-amber-600 mt-0.5">
                        Klik pada cell untuk mengedit langsung. Setelah selesai klik <strong>"Simpan Koreksi"</strong>.
                      </p>
                    </div>
                  </div>

                  {/* Tabel editable */}
                  <div className="overflow-auto rounded-xl border border-red-200" style={{ maxHeight: "320px" }}>
                    <table className="text-xs border-collapse" style={{ minWidth: "max-content" }}>
                      <thead className="bg-red-50 sticky top-0 z-10">
                        <tr>
                          <th className="px-2 py-2 text-left font-semibold text-slate-500 border-b border-red-200 sticky left-0 bg-red-50 z-20">No</th>
                          <th className="px-2 py-2 text-left font-semibold text-red-600 border-b border-red-200 min-w-[180px]">Alasan Gagal</th>
                          {CORRECTION_COLUMNS.map(col => (
                            <th key={col.key} className={`px-2 py-2 text-left font-semibold text-slate-600 border-b border-red-200 whitespace-nowrap ${col.width}`}>
                              {col.label}
                            </th>
                          ))}
                        </tr>
                      </thead>
                      <tbody>
                        {failedRows.map((fr, rowIdx) => (
                          <tr key={rowIdx} className="border-b border-red-100 hover:bg-red-50/40 transition-colors">
                            <td className="px-2 py-1.5 text-slate-400 sticky left-0 bg-white border-r border-red-100 z-10">{rowIdx + 1}</td>
                            <td className="px-2 py-1.5">
                              <span className="inline-block text-xs text-red-600 bg-red-100 px-2 py-0.5 rounded-lg max-w-[180px] truncate" title={fr.message}>
                                {fr.message}
                              </span>
                            </td>
                            {CORRECTION_COLUMNS.map(col => (
                              <td key={col.key} className="px-1 py-0.5">
                                <EditableCell
                                  value={fr.payload[col.key] || ""}
                                  mono={col.mono}
                                  onChange={val => handleFailedCellChange(rowIdx, col.key, val)}
                                />
                              </td>
                            ))}
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>

                  {/* Hasil retry jika sudah pernah coba */}
                  {retryProgress.total > 0 && (
                    <div className="space-y-2">
                      {retryProgress.errors.length === 0 ? (
                        <div className="p-3 bg-green-50 rounded-xl border border-green-200 flex items-center gap-2">
                          <CheckCircle size={15} className="text-green-600" />
                          <p className="text-sm font-semibold text-green-800">Semua koreksi berhasil disimpan!</p>
                        </div>
                      ) : (
                        <div className="p-3 bg-red-50 rounded-xl border border-red-200">
                          <button
                            onClick={() => setShowErrDetail(v => !v)}
                            className="w-full flex items-center justify-between text-sm font-medium text-red-700"
                          >
                            <span className="flex items-center gap-1.5">
                              <AlertCircle size={14} />
                              {retryProgress.errors.length} masih gagal setelah koreksi
                            </span>
                            {showErrDetail ? <ChevronUp size={14} /> : <ChevronDown size={14} />}
                          </button>
                          {showErrDetail && (
                            <div className="mt-2 space-y-1 max-h-28 overflow-y-auto">
                              {retryProgress.errors.map((e, i) => (
                                <div key={i} className="text-xs">
                                  <span className="font-medium text-slate-700">{e.row?.nama_anggota_keluarga || `Baris ${i+1}`}</span>
                                  <span className="text-red-500 ml-1">— {e.message}</span>
                                </div>
                              ))}
                            </div>
                          )}
                        </div>
                      )}
                      {/* Ringkasan retry */}
                      <p className="text-xs text-slate-400 text-center">
                        Koreksi terakhir: {retrySuccess} berhasil · {retryProgress.errors.length} masih gagal
                      </p>
                    </div>
                  )}
                </div>
              )}
            </div>
          )}

        </div>

        {/* ── Footer navigasi ── */}
        <div className="border-t border-slate-100 px-6 py-4 flex items-center justify-between rounded-b-2xl bg-white">

          {/* Kiri — Batal / Kembali */}
          <div>
            {step === 1 && (
              <button onClick={handleClose} className="px-4 py-2 rounded-xl border border-slate-200 text-slate-500 hover:bg-slate-50 text-sm transition-colors">
                Batal
              </button>
            )}
            {step === 2 && (
              <button onClick={() => setStep(1)} className="inline-flex items-center gap-1.5 px-4 py-2 rounded-xl border border-slate-200 text-slate-500 hover:bg-slate-50 text-sm transition-colors">
                <ChevronLeft size={15} /> Kembali
              </button>
            )}
            {step === 4 && (
              <button onClick={handleClose} className="px-4 py-2 rounded-xl border border-slate-200 text-slate-500 hover:bg-slate-50 text-sm transition-colors">
                Tutup
              </button>
            )}
          </div>

          {/* Kanan — Aksi utama */}
          <div className="flex items-center gap-2">

            {/* Step 1 → 2 */}
            {step === 1 && (
              <button
                onClick={() => setStep(2)}
                disabled={!selectedDesaId}
                className="inline-flex items-center gap-1.5 px-5 py-2 rounded-xl bg-indigo-600 text-white text-sm font-medium hover:bg-indigo-700 disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
              >
                Lanjut <ChevronRight size={15} />
              </button>
            )}

            {/* Step 2 → 3 (import) */}
            {step === 2 && (
              <button
                onClick={() => { setStep(3); handleImport(); }}
                disabled={rows.length === 0 || importing}
                className="inline-flex items-center gap-1.5 px-5 py-2 rounded-xl bg-indigo-600 text-white text-sm font-medium hover:bg-indigo-700 disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
              >
                Import {rows.length > 0 ? `${rows.length} Data` : ""} <ChevronRight size={15} />
              </button>
            )}

            {/* Step 4 — Import file lain */}
            {step === 4 && (
              <button onClick={resetAll} className="px-4 py-2 rounded-xl border border-indigo-300 text-indigo-600 hover:bg-indigo-50 text-sm transition-colors">
                Import File Lain
              </button>
            )}

            {/* Step 4 — Simpan koreksi (jika ada yg gagal) */}
            {step === 4 && failedRows.length > 0 && (
              <button
                onClick={handleRetry}
                disabled={correcting}
                className="inline-flex items-center gap-2 px-5 py-2 rounded-xl bg-indigo-600 text-white text-sm font-medium hover:bg-indigo-700 disabled:opacity-40 transition-colors"
              >
                {correcting
                  ? <><Loader size={14} className="animate-spin" /> Menyimpan...</>
                  : <><RefreshCw size={14} /> Simpan Koreksi ({failedRows.length})</>
                }
              </button>
            )}
          </div>
        </div>

      </div>
    </div>
  );
};

export default ImportExcelModal;
