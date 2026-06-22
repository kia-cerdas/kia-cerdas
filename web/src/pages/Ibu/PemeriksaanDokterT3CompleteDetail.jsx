// src/pages/Ibu/PemeriksaanDokterT3CompleteDetail.jsx
import React, { useEffect, useState, useCallback } from "react";
import { useParams, useNavigate, Link } from "react-router-dom";
import Swal from "sweetalert2";
import MainLayout from "../../components/Layout/MainLayout";
import { getKehamilanByIbuId } from "../../services/kehamilan";
import { getCurrentUser, isDokterUser } from "../../services/auth";
import {
  getDokterT3CompleteByKehamilanId,
  deleteDokterT3Complete,
  updateDokterT3Complete,
} from "../../services/pemeriksaanDokter";
import {
  ArrowLeft,
  Edit,
  Trash2,
  AlertCircle,
  Loader2,
  StickyNote,
  Plus,
  X,
  Save,
  Calendar,
  CalendarCheck,
  User,
  Activity,
  Eye,
  FlaskConical,
  Brain,
  CheckCircle,
  XCircle,
  ChevronDown,
  ChevronUp,
  MessageSquarePlus,
  Pencil,
} from "lucide-react";

// ─── Helper Components ────────────────────────────────────────────────────────

function InfoRow({ label, value, highlight = false }) {
  return (
    <div className="flex flex-col gap-0.5">
      <span className="text-xs font-semibold text-gray-400 uppercase tracking-wide">{label}</span>
      <span
        className={`text-sm font-medium ${
          highlight ? "text-indigo-700" : "text-gray-800"
        } ${!value || value === "-" ? "text-gray-400 italic" : ""}`}
      >
        {value || "-"}
      </span>
    </div>
  );
}

function StatusBadge({ value }) {
  if (!value || value === "-") return <span className="text-gray-400 text-sm italic">-</span>;
  return value === "Normal" ? (
    <span className="inline-flex items-center gap-1 text-xs bg-emerald-100 text-emerald-700 px-2 py-0.5 rounded-full font-semibold">
      <CheckCircle size={10} /> Normal
    </span>
  ) : (
    <span className="inline-flex items-center gap-1 text-xs bg-red-100 text-red-700 px-2 py-0.5 rounded-full font-semibold">
      <XCircle size={10} /> Abnormal
    </span>
  );
}

function ReaktifBadge({ value }) {
  const lower = (value || "").toLowerCase();
  if (!value || value === "-") return <span className="text-gray-400 text-sm italic">-</span>;
  return lower === "nonreaktif" || lower === "non reaktif" ? (
    <span className="inline-flex items-center gap-1 text-xs bg-emerald-100 text-emerald-700 px-2 py-1 rounded-full font-semibold">
      <CheckCircle size={10} /> Non Reaktif
    </span>
  ) : (
    <span className="inline-flex items-center gap-1 text-xs bg-red-100 text-red-700 px-2 py-1 rounded-full font-semibold">
      <XCircle size={10} /> Reaktif
    </span>
  );
}

function fmtDate(val) {
  if (!val) return "-";
  try {
    return new Date(val).toLocaleDateString("id-ID", {
      day: "numeric",
      month: "long",
      year: "numeric",
    });
  } catch {
    return "-";
  }
}

function DetailSection({ icon: Icon, title, colorCls = "bg-indigo-50 text-indigo-700 border-indigo-100", children, defaultOpen = true }) {
  const [open, setOpen] = useState(defaultOpen);
  return (
    <div className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
      <button
        type="button"
        onClick={() => setOpen((v) => !v)}
        className={`w-full flex items-center justify-between px-5 py-4 border-b ${colorCls} transition-colors`}
      >
        <div className="flex items-center gap-2">
          {Icon && <Icon size={17} />}
          <span className="font-semibold text-sm">{title}</span>
        </div>
        {open ? <ChevronUp size={15} /> : <ChevronDown size={15} />}
      </button>
      {open && <div className="p-5">{children}</div>}
    </div>
  );
}

// ─── Komponen Utama ───────────────────────────────────────────────────────────

export default function PemeriksaanDokterT3CompleteDetail() {
  const { id } = useParams();
  const navigate = useNavigate();

  const [kehamilan, setKehamilan] = useState(null);
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const [canEdit, setCanEdit] = useState(false);
  const [canDelete, setCanDelete] = useState(false);

  useEffect(() => {
    const user = getCurrentUser();
    const isDokter = isDokterUser(user);
    setCanEdit(isDokter);
    setCanDelete(isDokter);
  }, []);

  // Fetch data pemeriksaan utama T3
  useEffect(() => {
    const fetchData = async () => {
      try {
        const kehamilanList = await getKehamilanByIbuId(id);
        if (!kehamilanList || kehamilanList.length === 0) {
          setError("Data kehamilan tidak ditemukan.");
          setLoading(false);
          return;
        }
        const aktif = kehamilanList[0];
        setKehamilan(aktif);

        const res = await getDokterT3CompleteByKehamilanId(aktif.id);
        if (!res || !res.dokter) {
          setError("Belum ada data pemeriksaan Trimester 3. Silakan buat data terlebih dahulu.");
        } else {
          setData(res);
        }
      } catch (err) {
        console.error(err);
        setError("Terjadi kesalahan saat memuat data.");
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, [id]);

  // Hapus pemeriksaan utama T3
  const handleDelete = async () => {
    if (!canDelete) {
      Swal.fire({
        icon: "error",
        title: "Akses Ditolak",
        text: "Hanya dokter yang dapat menghapus data pemeriksaan.",
      });
      return;
    }

    const result = await Swal.fire({
      title: "Hapus Data Pemeriksaan T3?",
      html: "<p class='text-sm'>Apakah Anda yakin ingin menghapus semua data pemeriksaan Trimester 3 ini?</p>",
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#dc2626",
      cancelButtonColor: "#6b7280",
      confirmButtonText: "Ya, Hapus",
      cancelButtonText: "Batal",
    });

    if (!result.isConfirmed) return;

    try {
      // Hapus data pemeriksaan utama
      await deleteDokterT3Complete(data.dokter.id);
      await Swal.fire({
        title: "Berhasil!",
        text: "Data pemeriksaan T3 berhasil dihapus.",
        icon: "success",
        confirmButtonColor: "#10b981",
      });
      navigate(`/data-ibu/${id}`);
    } catch (err) {
      console.error("Delete error:", err);
      await Swal.fire({
        title: "Error!",
        text: "Gagal menghapus data.",
        icon: "error",
        confirmButtonColor: "#ef4444",
      });
    }
  };

  if (loading) {
    return (
      <MainLayout>
        <div className="min-h-screen flex items-center justify-center">
          <div className="flex flex-col items-center gap-3 text-indigo-600">
            <Loader2 className="animate-spin" size={40} />
            <p className="text-sm text-gray-500">Memuat data...</p>
          </div>
        </div>
      </MainLayout>
    );
  }

  if (error || !data) {
    return (
      <MainLayout>
        <div className="p-6 max-w-2xl mx-auto mt-10">
          <div className="bg-yellow-50 border border-yellow-200 rounded-2xl p-8 text-center">
            <div className="w-16 h-16 bg-yellow-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <AlertCircle className="text-yellow-500" size={32} />
            </div>
            <h2 className="text-xl font-bold text-yellow-700 mb-2">Data Tidak Ditemukan</h2>
            <p className="text-gray-600 mb-6 text-sm">{error || "Belum ada data pemeriksaan Trimester 3."}</p>
            <div className="flex gap-3 justify-center">
              {canEdit && (
                <Link
                  to={`/data-ibu/${id}/pemeriksaan-dokter-t3-complete/form`}
                  className="bg-indigo-600 text-white px-5 py-2 rounded-lg text-sm font-medium hover:bg-indigo-700 transition"
                >
                  Buat Data Baru
                </Link>
              )}
              <button
                onClick={() => navigate(-1)}
                className="bg-gray-100 text-gray-700 px-5 py-2 rounded-lg text-sm font-medium hover:bg-gray-200 transition"
              >
                Kembali
              </button>
            </div>
          </div>
        </div>
      </MainLayout>
    );
  }

  const d = data.dokter;
  const lab = data.lab_jiwa;

  const fisikItems = [
    { label: "Konjungtiva", value: d.fisik_konjungtiva },
    { label: "Sklera", value: d.fisik_sklera },
    { label: "Kulit", value: d.fisik_kulit },
    { label: "Leher", value: d.fisik_leher },
    { label: "Gigi & Mulut", value: d.fisik_gigi_mulut },
    { label: "THT", value: d.fisik_tht },
    { label: "Dada / Jantung", value: d.fisik_dada_jantung },
    { label: "Dada / Paru", value: d.fisik_dada_paru },
    { label: "Perut", value: d.fisik_perut },
    { label: "Tungkai", value: d.fisik_tungkai },
  ];

  const abnormalCount = fisikItems.filter((f) => f.value === "Abnormal").length;

  return (
    <MainLayout>
      <div className="p-4 md:p-6 max-w-5xl mx-auto">
        {/* Header */}
        <div className="flex items-start justify-between mb-6 gap-3">
          <div className="flex items-center gap-3">
            <button
              onClick={() => navigate(`/data-ibu/${id}`)}
              className="inline-flex items-center gap-2 px-5 py-2.5 rounded-full border border-[#185FA5] text-[#185FA5] text-sm font-semibold hover:bg-[#185FA5]/5 transition"
            >
              <ArrowLeft size={16} />
              <span>Kembali</span>
            </button>
            <div>
              <h1 className="text-xl md:text-2xl font-bold text-gray-800">
                Pemeriksaan Dokter Trimester 3
              </h1>
              <p className="text-sm text-gray-500 mt-0.5">
                Detail pemeriksaan fisik, USG, biometri, lanjutan, dan laboratorium
              </p>
            </div>
          </div>
          <div
            className={`px-3 py-1 rounded-full text-xs font-semibold shrink-0 ${
              canEdit
                ? "bg-green-100 text-green-700"
                : "bg-blue-100 text-blue-700"
            }`}
          >
            {/* {canEdit ? "Mode Edit (Dokter)" : "Mode Baca (Bidan)"} */}
          </div>
        </div>

        {!canEdit && (
          <div className="mb-6 p-3 bg-blue-50 rounded-lg border border-blue-200">
            <p className="text-sm text-blue-700 flex items-center gap-2">
              <Eye size={16} />
              Anda dalam mode baca (Bidan). Data hanya dapat dilihat, tidak dapat diubah.
            </p>
          </div>
        )}

        {canEdit && (
          <div className="flex gap-2 shrink-0 mb-6">
            <Link
              to={`/data-ibu/${id}/pemeriksaan-dokter-t3-complete/form`}
              className="flex items-center gap-1.5 bg-amber-500 hover:bg-amber-600 text-white px-4 py-2 rounded-xl text-sm font-medium transition"
            >
              <Edit size={15} /> Edit
            </Link>
            <button
              onClick={handleDelete}
              className="flex items-center gap-1.5 bg-red-500 hover:bg-red-600 text-white px-4 py-2 rounded-xl text-sm font-medium transition"
            >
              <Trash2 size={15} /> Hapus
            </button>
          </div>
        )}

        {/* Summary cards */}
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 mb-5">
          <div className="bg-indigo-50 rounded-2xl p-4 border border-indigo-100">
            <p className="text-xs text-indigo-500 font-semibold uppercase tracking-wide mb-1">
              Dokter
            </p>
            <p className="text-sm font-bold text-indigo-800 truncate">
              {d.nama_dokter || "-"}
            </p>
          </div>
          <div className="bg-teal-50 rounded-2xl p-4 border border-teal-100">
            <p className="text-xs text-teal-500 font-semibold uppercase tracking-wide mb-1">
              Tanggal Periksa
            </p>
            <p className="text-sm font-bold text-teal-800">{fmtDate(d.tanggal_periksa)}</p>
          </div>
          <div
            className={`rounded-2xl p-4 border ${
              abnormalCount > 0
                ? "bg-red-50 border-red-100"
                : "bg-emerald-50 border-emerald-100"
            }`}
          >
            <p
              className={`text-xs font-semibold uppercase tracking-wide mb-1 ${
                abnormalCount > 0 ? "text-red-500" : "text-emerald-500"
              }`}
            >
              Fisik Abnormal
            </p>
            <p
              className={`text-2xl font-bold ${
                abnormalCount > 0 ? "text-red-700" : "text-emerald-700"
              }`}
            >
              {abnormalCount}
              <span className="text-sm font-normal"> / 10</span>
            </p>
          </div>
          <div className="bg-violet-50 rounded-2xl p-4 border border-violet-100">
            <p className="text-xs text-violet-500 font-semibold uppercase tracking-wide mb-1">
              UK Biometri T3
            </p>
            <p className="text-sm font-bold text-violet-800">
              {d.uk_berdasarkan_biometri_usg_trimester_3_minggu
                ? `${d.uk_berdasarkan_biometri_usg_trimester_3_minggu} minggu`
                : "-"}
            </p>
          </div>
        </div>

        {/* Detail sections */}
        <div className="space-y-4">
          {/* Data Dokter */}
          <DetailSection icon={User} title="Data Dokter & Anamnesis" colorCls="bg-indigo-50 text-indigo-700 border-indigo-100">
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
              <InfoRow label="Nama Dokter" value={d.nama_dokter} highlight />
              <InfoRow label="Tanggal Periksa" value={fmtDate(d.tanggal_periksa)} />
              <div className="sm:col-span-3">
                <InfoRow label="Konsep Anamnesa Pemeriksaan" value={d.konsep_anamnesa_pemeriksaan} />
              </div>
            </div>
          </DetailSection>

          {/* Fisik */}
          <DetailSection icon={Activity} title="Pemeriksaan Fisik" colorCls="bg-teal-50 text-teal-700 border-teal-100">
            {abnormalCount > 0 && (
              <div className="mb-4 flex items-center gap-2 bg-red-50 border border-red-200 rounded-xl px-4 py-2.5">
                <AlertCircle size={15} className="text-red-500 shrink-0" />
                <p className="text-xs text-red-600 font-medium">
                  Terdapat {abnormalCount} temuan abnormal pada pemeriksaan fisik.
                </p>
              </div>
            )}
            <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-5 gap-3">
              {fisikItems.map((item) => (
                <div key={item.label} className="flex flex-col gap-1">
                  <span className="text-xs font-semibold text-gray-400 uppercase tracking-wide">
                    {item.label}
                  </span>
                  <StatusBadge value={item.value} />
                </div>
              ))}
            </div>
          </DetailSection>

          {/* USG Trimester 3 */}
          <DetailSection icon={Eye} title="USG Trimester 3" colorCls="bg-violet-50 text-violet-700 border-violet-100">
            <InfoRow label="USG Dilakukan?" value={d.usg_trimester_3_dilakukan === "Ya" ? "Ya" : (d.usg_trimester_3_dilakukan || "-")} />
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 mt-3">
              <InfoRow label="UK USG T1 (mg)" value={d.uk_berdasarkan_usg_trimester_1_minggu ? `${d.uk_berdasarkan_usg_trimester_1_minggu} mg` : null} />
              <InfoRow label="UK HPHT (mg)" value={d.uk_berdasarkan_hpht_minggu ? `${d.uk_berdasarkan_hpht_minggu} mg` : null} />
              <InfoRow label="UK Biometri T3 (mg)" value={d.uk_berdasarkan_biometri_usg_trimester_3_minggu ? `${d.uk_berdasarkan_biometri_usg_trimester_3_minggu} mg` : null} highlight />
              <InfoRow label="Selisih ≥3 mg?" value={d.selisih_uk_3_minggu_atau_lebih || "-"} />
              <InfoRow label="Jumlah Bayi" value={d.usg_jumlah_bayi || "-"} />
              <InfoRow label="Letak Bayi" value={d.usg_letak_bayi || "-"} />
              <InfoRow label="Presentasi Bayi" value={d.usg_presentasi_bayi || "-"} />
              <InfoRow label="Keadaan Bayi" value={d.usg_keadaan_bayi || "-"} />
              <InfoRow label="DJJ (x/menit)" value={d.usg_djj_nilai || "-"} />
              <InfoRow label="Status DJJ" value={d.usg_djj_status || "-"} />
              <InfoRow label="Lokasi Plasenta" value={d.usg_lokasi_plasenta || "-"} />
              <InfoRow label="Cairan Ketuban (cm)" value={d.usg_cairan_ketuban_sdp_cm ? `${d.usg_cairan_ketuban_sdp_cm} cm` : null} />
              <InfoRow label="Status Ketuban" value={d.usg_cairan_ketuban_status || "-"} />
              <div className="flex flex-col gap-1">
                <span className="text-xs font-semibold text-gray-400 uppercase tracking-wide">
                  Kecurigaan Abnormal
                </span>
                {d.usg_kecurigaan_temuan_abnormal === "Ya" ? (
                  <span className="inline-flex items-center gap-1 text-xs bg-red-100 text-red-700 px-2 py-0.5 rounded-full font-semibold">
                    <XCircle size={10} /> Ya
                  </span>
                ) : (
                  <span className="inline-flex items-center gap-1 text-xs bg-emerald-100 text-emerald-700 px-2 py-0.5 rounded-full font-semibold">
                    <CheckCircle size={10} /> Tidak
                  </span>
                )}
              </div>
              {d.usg_kecurigaan_temuan_abnormal === "Ya" && (
                <InfoRow label="Keterangan Abnormal" value={d.usg_keterangan_temuan_abnormal} />
              )}
            </div>

            {/* Display USG Image */}
            {d.gambar_usg && (
              <div className="mt-4 pt-4 border-t border-violet-200">
                <p className="text-xs font-bold text-violet-600 uppercase tracking-widest mb-3">
                  Gambar USG
                </p>
                <div className="flex justify-center">
                  <img
                    src={d.gambar_usg}
                    alt="USG Image"
                    className="max-w-full max-h-96 rounded-lg border border-violet-200 shadow-sm"
                    onError={(e) => {
                      e.target.src = "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='200' height='200'%3E%3Crect fill='%23f3f4f6' width='200' height='200'/%3E%3Ctext x='50%25' y='50%25' text-anchor='middle' dy='.3em' fill='%239ca3af' font-size='14'%3EImage not available%3C/text%3E%3C/svg%3E";
                    }}
                  />
                </div>
              </div>
            )}
          </DetailSection>

          {/* Biometri Janin */}
          <DetailSection icon={Activity} title="Biometri Janin" colorCls="bg-blue-50 text-blue-700 border-blue-100">
            <div className="grid grid-cols-2 sm:grid-cols-5 gap-3">
              <InfoRow label="BPD (cm)" value={d.biometri_bpd_cm ? `${d.biometri_bpd_cm} cm` : null} />
              <InfoRow label="BPD (mg)" value={d.biometri_bpd_minggu ? `${d.biometri_bpd_minggu} mg` : null} />
              <InfoRow label="HC (cm)" value={d.biometri_hc_cm ? `${d.biometri_hc_cm} cm` : null} />
              <InfoRow label="HC (mg)" value={d.biometri_hc_minggu ? `${d.biometri_hc_minggu} mg` : null} />
              <InfoRow label="AC (cm)" value={d.biometri_ac_cm ? `${d.biometri_ac_cm} cm` : null} />
              <InfoRow label="AC (mg)" value={d.biometri_ac_minggu ? `${d.biometri_ac_minggu} mg` : null} />
              <InfoRow label="FL (cm)" value={d.biometri_fl_cm ? `${d.biometri_fl_cm} cm` : null} />
              <InfoRow label="FL (mg)" value={d.biometri_fl_minggu ? `${d.biometri_fl_minggu} mg` : null} />
              <InfoRow label="EFW/TBJ (gram)" value={d.biometri_efw_tbj_gram ? `${d.biometri_efw_tbj_gram} gr` : null} />
              <InfoRow label="EFW/TBJ (mg)" value={d.biometri_efw_tbj_minggu ? `${d.biometri_efw_tbj_minggu} mg` : null} />
            </div>
          </DetailSection>

          {/* Lanjutan Trimester 3 */}
          <DetailSection icon={StickyNote} title="Lanjutan Trimester 3 & Rencana" colorCls="bg-amber-50 text-amber-700 border-amber-100">
            <div className="space-y-4">
              <InfoRow label="Hasil USG/Catatan" value={d.hasil_usg_catatan} />
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <InfoRow label="Tanggal Lab Lanjutan" value={fmtDate(d.tanggal_lab)} />
                <InfoRow label="Hemoglobin (g/dL)" value={d.lab_hemoglobin_hasil ? `${d.lab_hemoglobin_hasil} g/dL` : null} />
                <InfoRow label="Rencana Hb" value={d.lab_hemoglobin_rencana_tindak_lanjut} />
                <InfoRow label="Protein Urin (hasil)" value={d.lab_protein_urin_hasil != null ? String(d.lab_protein_urin_hasil) : "-"} />
                <InfoRow label="Rencana Protein Urin" value={d.lab_protein_urin_rencana_tindak_lanjut} />
                <InfoRow label="Urin Reduksi" value={d.lab_urin_reduksi_hasil} />
                <InfoRow label="Rencana Urin Reduksi" value={d.lab_urin_reduksi_rencana_tindak_lanjut} />
                <InfoRow label="Tanggal Skrining Jiwa" value={fmtDate(d.tanggal_skrining_jiwa)} />
                <InfoRow label="Hasil Skrining Jiwa" value={d.skrining_jiwa_hasil} />
                <InfoRow label="Tindak Lanjut Jiwa" value={d.skrining_jiwa_tindak_lanjut} />
                <div className="flex flex-col gap-1">
                  <span className="text-xs font-semibold text-gray-400 uppercase tracking-wide">
                    Perlu Rujukan Jiwa
                  </span>
                  {d.skrining_jiwa_perlu_rujukan === "Ya" ? (
                    <span className="inline-flex items-center gap-1 text-xs bg-red-100 text-red-700 px-2 py-0.5 rounded-full font-semibold">
                      <XCircle size={10} /> Ya
                    </span>
                  ) : (
                    <span className="inline-flex items-center gap-1 text-xs bg-emerald-100 text-emerald-700 px-2 py-0.5 rounded-full font-semibold">
                      <CheckCircle size={10} /> Tidak
                    </span>
                  )}
                </div>
              </div>
              <div>
                <p className="text-xs font-bold text-amber-600 uppercase tracking-wider mb-2">Rencana Konsultasi</p>
                <div className="flex flex-wrap gap-3 text-sm text-gray-700">
                  <span>Gizi: {d.rencana_konsultasi_gizi ? "✅ Ya" : "❌ Tidak"}</span>
                  <span>Kebidanan: {d.rencana_konsultasi_kebidanan ? "✅ Ya" : "❌ Tidak"}</span>
                  <span>Anak: {d.rencana_konsultasi_anak ? "✅ Ya" : "❌ Tidak"}</span>
                  <span>Penyakit Dalam: {d.rencana_konsultasi_penyakit_dalam ? "✅ Ya" : "❌ Tidak"}</span>
                  <span>Neurologi: {d.rencana_konsultasi_neurologi ? "✅ Ya" : "❌ Tidak"}</span>
                  <span>THT: {d.rencana_konsultasi_tht ? "✅ Ya" : "❌ Tidak"}</span>
                  <span>Psikiatri: {d.rencana_konsultasi_psikiatri ? "✅ Ya" : "❌ Tidak"}</span>
                  {d.rencana_konsultasi_lain_lain && <span>Lainnya: {d.rencana_konsultasi_lain_lain}</span>}
                </div>
              </div>
              <div>
                <p className="text-xs font-bold text-amber-600 uppercase tracking-wider mb-2">Rencana Proses Melahirkan & Kontrasepsi</p>
                <div className="grid grid-cols-2 sm:grid-cols-4 gap-2 text-sm text-gray-700">
                  <span>Proses Melahirkan: {d.rencana_proses_melahirkan || "-"}</span>
                  <span>AKDR: {d.rencana_kontrasepsi_akdr ? "✅" : "❌"}</span>
                  <span>Pil: {d.rencana_kontrasepsi_pil ? "✅" : "❌"}</span>
                  <span>Suntik: {d.rencana_kontrasepsi_suntik ? "✅" : "❌"}</span>
                  <span>Steril: {d.rencana_kontrasepsi_steril ? "✅" : "❌"}</span>
                  <span>MAL: {d.rencana_kontrasepsi_mal ? "✅" : "❌"}</span>
                  <span>Implan: {d.rencana_kontrasepsi_implan ? "✅" : "❌"}</span>
                  <span>Belum Memilih: {d.rencana_kontrasepsi_belum_memilih ? "✅" : "❌"}</span>
                </div>
              </div>
              <div>
                <p className="text-xs font-bold text-amber-600 uppercase tracking-wider mb-1">Kebutuhan Konseling</p>
                <p className="text-sm text-gray-700">{d.kebutuhan_konseling || "-"}</p>
                <p className="text-xs font-bold text-amber-600 uppercase tracking-wider mt-2 mb-1">Penjelasan</p>
                <p className="text-sm text-gray-700">{d.penjelasan || "-"}</p>
                <p className="text-xs font-bold text-amber-600 uppercase tracking-wider mt-2 mb-1">Rekomendasi Tempat Melahirkan</p>
                <p className="text-sm text-gray-700">{d.kesimpulan_rekomendasi_tempat_melahirkan || "-"}</p>
              </div>
            </div>
          </DetailSection>

          {/* Pemeriksaan Laboratorium Lanjutan T3 */}
          <DetailSection icon={FlaskConical} title="Pemeriksaan Laboratorium & Skrining Jiwa" colorCls="bg-amber-50 text-amber-700 border-amber-100">
            <div className="space-y-4">
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <InfoRow label="Tanggal Lab Lanjutan" value={fmtDate(d.tanggal_lab)} />
              </div>
              {/* Tabel lab lanjutan */}
              <div className="rounded-xl border border-amber-100 overflow-hidden">
                <table className="w-full text-sm">
                  <thead className="bg-amber-50">
                    <tr>
                      <th className="text-left px-4 py-2.5 text-xs font-bold uppercase tracking-wide w-1/3">Pemeriksaan</th>
                      <th className="text-left px-4 py-2.5 text-xs font-bold uppercase tracking-wide w-1/3">Hasil</th>
                      <th className="text-left px-4 py-2.5 text-xs font-bold uppercase tracking-wide w-1/3">Rencana Tindak Lanjut</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-amber-50">
                    <tr>
                      <td className="px-4 py-3 font-medium">Hemoglobin</td>
                      <td className="px-4 py-3">{d.lab_hemoglobin_hasil != null ? `${d.lab_hemoglobin_hasil} g/dL` : "-"}</td>
                      <td className="px-4 py-3">{d.lab_hemoglobin_rencana_tindak_lanjut || "-"}</td>
                    </tr>
                    <tr className="bg-gray-50/60">
                      <td className="px-4 py-3 font-medium">Protein Urin</td>
                      <td className="px-4 py-3">{d.lab_protein_urin_hasil != null ? String(d.lab_protein_urin_hasil) : "-"}</td>
                      <td className="px-4 py-3">{d.lab_protein_urin_rencana_tindak_lanjut || "-"}</td>
                    </tr>
                    <tr>
                      <td className="px-4 py-3 font-medium">Urin Reduksi</td>
                      <td className="px-4 py-3">{d.lab_urin_reduksi_hasil || "-"}</td>
                      <td className="px-4 py-3">{d.lab_urin_reduksi_rencana_tindak_lanjut || "-"}</td>
                    </tr>
                  </tbody>
                </table>
              </div>
              {/* Skrining Jiwa */}
              <div>
                <p className="text-xs font-bold text-amber-600 uppercase tracking-wider mb-3">Skrining Kesehatan Jiwa</p>
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                  <InfoRow label="Tanggal Skrining Jiwa" value={fmtDate(d.tanggal_skrining_jiwa)} />
                  <InfoRow label="Hasil Skrining Jiwa" value={d.skrining_jiwa_hasil} />
                  <InfoRow label="Tindak Lanjut Jiwa" value={d.skrining_jiwa_tindak_lanjut} />
                  <div className="flex flex-col gap-1">
                    <span className="text-xs font-semibold text-gray-400 uppercase tracking-wide">Perlu Rujukan Jiwa</span>
                    {d.skrining_jiwa_perlu_rujukan === "Ya" ? (
                      <span className="inline-flex items-center gap-1 text-xs bg-red-100 text-red-700 px-2 py-0.5 rounded-full font-semibold w-fit">
                        <XCircle size={10} /> Ya
                      </span>
                    ) : (
                      <span className="inline-flex items-center gap-1 text-xs bg-emerald-100 text-emerald-700 px-2 py-0.5 rounded-full font-semibold w-fit">
                        <CheckCircle size={10} /> Tidak
                      </span>
                    )}
                  </div>
                </div>
              </div>
            </div>
          </DetailSection>

          {/* Catatan Pemeriksaan */}
          <DetailSection icon={StickyNote} title="Catatan Pemeriksaan" colorCls="bg-amber-50 text-amber-700 border-amber-100">
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <InfoRow label="Tanggal Periksa / Stempel / Paraf" value={fmtDate(d.tanggal_periksa_stamp_paraf)} />
              <InfoRow label="Tanggal Kembali" value={fmtDate(d.tanggal_kembali)} />
              <div className="sm:col-span-2">
                <InfoRow label="Keluhan / Pemeriksaan / Tindakan / Saran" value={d.keluhan_pemeriksaan_tindakan_saran} />
              </div>
            </div>
          </DetailSection>
        </div>
      </div>
    </MainLayout>
  );
}
