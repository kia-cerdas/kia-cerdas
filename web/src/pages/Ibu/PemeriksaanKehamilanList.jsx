import React, { useEffect, useState, useMemo, useCallback } from "react";
import { useParams, useSearchParams, Link, useNavigate } from "react-router-dom";
import MainLayout from "../../components/Layout/MainLayout";
import { getKehamilanByIbuId } from "../../services/kehamilan";
import { getPemeriksaanKehamilanByKehamilanId } from "../../services/pemeriksaanKehamilan";
import { getGrafikehamilanByKehamilanId } from "../../services/pemeriksaanKehamilan";
import { getCurrentUser, isDokterUser } from "../../services/auth";

import { Line } from "react-chartjs-2";
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Tooltip,
  Legend,
  Filler,
} from "chart.js";

import {
  Plus,
  AlertTriangle,
  Activity,
  Scale,
  Heart,
  Droplets,
  FileText,
  ChevronDown,
  ChevronUp,
  ArrowLeft,
  TrendingUp,
  Eye,
  CheckCircle,
  AlertCircle,
  Stethoscope,
  CalendarDays,
} from "lucide-react";
import Swal from "sweetalert2";

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Tooltip,
  Legend,
  Filler
);

// ─── Palet Generasi Sehat ─────────────────────────────────────────────────────
// Primary  : #185FA5
// Success  : #3B6D11
// Warning  : #BA7517
// Danger   : #A32D2D
// Secondary: #0F6E56
// Background: #F7FAFB

// ── Helper: Parse alasan_klinis ──
const parseAlasanKlinis = (alasanString) => {
  if (!alasanString) return [];
  try { return JSON.parse(alasanString); } catch { return []; }
};

// ── Helper: Parse risk_types ──
const parseRiskTypes = (riskTypesString) => {
  if (!riskTypesString) return [];
  try { return JSON.parse(riskTypesString); } catch { return []; }
};

// ── Helper: Batas kenaikan BB berdasarkan Buku KIA ──
const getBatasBB = (minggu, kategoriIMT) => {
  let rateMin = 0.35, rateMax = 0.5, t1Min = 0.5, t1Max = 2.0;
  const kat = kategoriIMT?.toLowerCase() || "";
  if (kat.includes("kurang")) { rateMin = 0.44; rateMax = 0.58; t1Min = 1.0; t1Max = 2.0; }
  else if (kat.includes("overweight")) { rateMin = 0.23; rateMax = 0.33; t1Min = 0.5; t1Max = 1.0; }
  else if (kat.includes("obesitas")) { rateMin = 0.17; rateMax = 0.27; t1Min = 0.2; t1Max = 0.5; }
  if (minggu <= 12) return { min: (t1Min / 12) * minggu, max: (t1Max / 12) * minggu };
  return { min: t1Min + (minggu - 12) * rateMin, max: t1Max + (minggu - 12) * rateMax };
};

// ── Helper: Normalisasi status risiko ──
const normalizeDisplayStatus = (status) => {
  if (!status) return "NORMAL";
  const s = status.toUpperCase();
  if (s === "TINGGI" || s === "PERLU RUJUKAN") return "PERLU RUJUKAN";
  if (s === "SEDANG" || s === "PERLU TINDAKAN") return "PERLU TINDAKAN";
  if (s === "RENDAH" || s === "NORMAL") return "NORMAL";
  return status;
};

// ── Helper: Hitung status risiko dari data klinis (fallback frontend) ──
const hitungStatusRisiko = (exam) => {
  if (!exam) return null;
  const faktorRujukan = [];
  const faktorTindakan = [];

  const { sistole, diastole } = exam;
  if (sistole >= 140 || diastole >= 90)
    faktorRujukan.push(`Tekanan darah tinggi (${sistole}/${diastole} mmHg)`);
  else if (sistole >= 130 || diastole >= 80)
    faktorTindakan.push(`Tekanan darah batas waspada (${sistole}/${diastole} mmHg)`);

  const djj = exam.denyut_jantung_janin;
  if (djj && (djj < 100 || djj > 180)) faktorRujukan.push(`DJJ tidak normal (${djj} bpm)`);
  else if (djj && (djj < 120 || djj > 160)) faktorTindakan.push(`DJJ di luar batas normal (${djj} bpm)`);

  const hb = exam.tes_lab_hb;
  if (hb && hb < 7) faktorRujukan.push(`Anemia berat, Hb ${hb} g/dL`);
  else if (hb && hb < 10) faktorTindakan.push(`Anemia sedang, Hb ${hb} g/dL`);

  const gds = exam.tes_lab_gula_darah;
  if (gds && gds > 200) faktorRujukan.push(`Gula darah sangat tinggi (${gds} mg/dL)`);
  else if (gds && gds > 140) faktorTindakan.push(`Gula darah meningkat (${gds} mg/dL)`);

  const protein = exam.tes_lab_protein_urine?.toLowerCase() || "";
  if (protein.includes("positif") || protein === "++" || protein === "+++")
    faktorRujukan.push(`Protein urine positif (${exam.tes_lab_protein_urine})`);
  else if (protein === "+" || protein.includes("trace"))
    faktorTindakan.push(`Protein urine trace/+1 (${exam.tes_lab_protein_urine})`);

  const lila = exam.lingkar_lengan_atas;
  if (lila && lila < 23.5) faktorTindakan.push(`LiLA kurang dari normal (${lila} cm)`);

  let status_risiko, ringkasan;
  if (faktorRujukan.length > 0) {
    status_risiko = "PERLU RUJUKAN";
    ringkasan = `Ditemukan ${faktorRujukan.length} indikator risiko tinggi: ${faktorRujukan.join("; ")}.`;
  } else if (faktorTindakan.length > 0) {
    status_risiko = "PERLU TINDAKAN";
    ringkasan = `Ditemukan ${faktorTindakan.length} indikator yang perlu perhatian: ${faktorTindakan.join("; ")}.`;
  } else {
    status_risiko = "NORMAL";
    ringkasan = "Semua parameter klinis dalam batas normal. Pantau secara rutin sesuai jadwal ANC.";
  }
  return { status_risiko, ringkasan, faktorRujukan, faktorTindakan };
};

// ── Opsi grafik ──
const commonOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: { position: "bottom", labels: { boxWidth: 12, font: { size: 11, family: "sans-serif" } } },
  },
  scales: {
    y: { beginAtZero: false, grid: { color: "#F3F4F6" } },
    x: { grid: { display: false } },
  },
};

// ── Komponen kartu ringkasan ──
const SummaryCard = ({ icon: Icon, iconColor, bgColor, label, value, unit, badge }) => (
  <div className="bg-white p-5 rounded-2xl shadow-sm border border-gray-100 flex flex-col gap-2">
    <div className="flex items-center gap-2">
      <div className="p-2 rounded-lg" style={{ backgroundColor: bgColor }}>
        <Icon size={16} style={{ color: iconColor }} />
      </div>
      <span className="text-xs font-bold text-gray-400 uppercase tracking-wider">{label}</span>
    </div>
    <div className="flex items-end gap-1.5">
      <span className="text-2xl font-black text-gray-800">{value}</span>
      {unit && <span className="text-sm text-gray-400 mb-0.5">{unit}</span>}
    </div>
    {badge && (
      <span
        className="self-start text-xs font-semibold px-2 py-0.5 rounded-lg"
        style={{ backgroundColor: bgColor, color: iconColor }}
      >
        {badge}
      </span>
    )}
  </div>
);

// ── Komponen grafik wrapper ──
const ChartCard = ({ icon: Icon, iconColor, title, empty, emptyMsg, children }) => (
  <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
    <div className="flex items-center gap-2 mb-4">
      <Icon size={18} style={{ color: iconColor }} />
      <h2 className="font-bold text-gray-800 text-sm">{title}</h2>
    </div>
    {empty ? (
      <div
        className="h-56 flex flex-col items-center justify-center rounded-xl gap-2"
        style={{ backgroundColor: "#F7FAFB" }}
      >
        <FileText size={36} strokeWidth={1.5} className="text-gray-300" />
        <p className="text-sm text-gray-400">{emptyMsg || "Tidak Ada Data"}</p>
      </div>
    ) : (
      <div className="h-56">{children}</div>
    )}
  </div>
);

// ── Komponen utama ──
export default function PemeriksaanKehamilanList() {
  const navigate = useNavigate();
  const { id: ibuId } = useParams();
  const [searchParams] = useSearchParams();
  const kehamilanIdQuery = searchParams.get("kehamilan_id");

  const user = getCurrentUser();
  const isDokter = isDokterUser(user);
  const canEdit = !isDokter;

  const [kehamilan, setKehamilan] = useState(null);
  const [examinations, setExaminations] = useState([]);
  const [grafik, setGrafik] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [expandedRisks, setExpandedRisks] = useState({});

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        setError(null);

        const kehamilanList = await getKehamilanByIbuId(ibuId);
        if (!kehamilanList || kehamilanList.length === 0) {
          setError("Belum ada data kehamilan untuk ibu ini.");
          setKehamilan(null);
          return;
        }

        let selectedKehamilan = null;
        if (kehamilanIdQuery) {
          selectedKehamilan = kehamilanList.find((k) => k.id == kehamilanIdQuery);
          if (!selectedKehamilan) {
            setError(`Kehamilan dengan ID ${kehamilanIdQuery} tidak ditemukan.`);
            setKehamilan(null);
            return;
          }
        } else {
          selectedKehamilan = kehamilanList[0];
        }

        setKehamilan(selectedKehamilan);

        const [examRes, grafikRes] = await Promise.all([
          getPemeriksaanKehamilanByKehamilanId(selectedKehamilan.id),
          getGrafikehamilanByKehamilanId(selectedKehamilan.id),
        ]);

        setExaminations(
          (examRes || []).sort((a, b) => {
            if (a.kunjungan_ke !== b.kunjungan_ke) return a.kunjungan_ke - b.kunjungan_ke;
            return new Date(a.tanggal_periksa) - new Date(b.tanggal_periksa);
          })
        );
        setGrafik(grafikRes?.data || grafikRes || null);
      } catch (err) {
        console.error(err);
        setError("Gagal memuat data pemeriksaan kehamilan.");
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [ibuId, kehamilanIdQuery]);

  const tfu = grafik?.grafik_tfu ?? [];
  const djj = grafik?.grafik_djj ?? [];
  const td = grafik?.grafik_tekanan_darah ?? [];
  const bb = grafik?.grafik_berat_badan ?? [];
  const kategoriIMT = grafik?.kategori_imt;
  const hasExaminations = examinations.length > 0;

  const latestExam = useMemo(() => {
    if (!hasExaminations) return null;
    return [...examinations].sort(
      (a, b) => new Date(b.tanggal_periksa) - new Date(a.tanggal_periksa)
    )[0];
  }, [examinations, hasExaminations]);

  const riskFromBackend = grafik?.detail_risiko;
  const riskFromFrontend = useMemo(() => hitungStatusRisiko(latestExam), [latestExam]);

  const risk = useMemo(() => {
    if (!hasExaminations) return null;
    if (latestExam?.overall_label) {
      return {
        status_risiko: latestExam.overall_label,
        ringkasan: latestExam.rekomendasi_utama || latestExam.detail_risiko || "",
        skor_risiko: latestExam.skor_risiko || 0,
        active_risk_count: latestExam.active_risk_count || 0,
        alasan_klinis: parseAlasanKlinis(latestExam.alasan_klinis),
        risk_types: parseRiskTypes(latestExam.risk_types),
        is_ml_prediction: true,
      };
    }
    if (riskFromBackend?.status_risiko && riskFromBackend.status_risiko !== "") return riskFromBackend;
    return riskFromFrontend;
  }, [hasExaminations, riskFromBackend, riskFromFrontend, latestExam]);

  // ── Styling risiko ──
  const getRiskConfig = (status) => {
    const s = normalizeDisplayStatus(status);
    if (s === "PERLU RUJUKAN") return {
      bg: "#FBE9E9", border: "#A32D2D", text: "#A32D2D",
      labelBg: "#A32D2D", icon: AlertTriangle, borderLeft: "#A32D2D",
    };
    if (s === "PERLU TINDAKAN") return {
      bg: "#FEF3CD", border: "#BA7517", text: "#BA7517",
      labelBg: "#BA7517", icon: AlertCircle, borderLeft: "#BA7517",
    };
    return {
      bg: "#EDF7E6", border: "#3B6D11", text: "#3B6D11",
      labelBg: "#3B6D11", icon: CheckCircle, borderLeft: "#3B6D11",
    };
  };

  // ── Dataset grafik ──
  const chartTFU = useMemo(() => ({
    labels: tfu.map((d) => `Mgg ${d.minggu}`),
    datasets: [
      { label: "Batas Atas (+2cm)", data: tfu.map((d) => d.minggu + 2), borderColor: "#3B6D11", borderDash: [5, 5], borderWidth: 1, pointRadius: 0, fill: false },
      { label: "Batas Bawah (-2cm)", data: tfu.map((d) => d.minggu - 2), borderColor: "#3B6D11", borderDash: [5, 5], borderWidth: 1, pointRadius: 0, fill: "-1", backgroundColor: "rgba(59,109,17,0.10)" },
      { label: "TFU Pasien (cm)", data: tfu.map((d) => d.value), borderColor: "#185FA5", backgroundColor: "#185FA5", borderWidth: 2.5, pointRadius: 4 },
    ],
  }), [tfu]);

  const chartDJJ = useMemo(() => ({
    labels: djj.map((d) => `Mgg ${d.minggu}`),
    datasets: [
      { label: "Batas Atas (160)", data: djj.map(() => 160), borderColor: "#A32D2D", borderWidth: 1, pointRadius: 0, fill: false },
      { label: "Batas Bawah (120)", data: djj.map(() => 120), borderColor: "#A32D2D", borderWidth: 1, pointRadius: 0, fill: "-1", backgroundColor: "rgba(59,109,17,0.10)" },
      { label: "DJJ Pasien (bpm)", data: djj.map((d) => d.value), borderColor: "#0F6E56", backgroundColor: "#0F6E56", borderWidth: 2.5, pointRadius: 4 },
    ],
  }), [djj]);

  const chartTD = useMemo(() => ({
    labels: td.map((d) => `Mgg ${d.minggu}`),
    datasets: [
      { label: "Batas Waspada Sistole (130)", data: td.map(() => 130), borderColor: "#A32D2D", borderDash: [8, 4], borderWidth: 1.5, pointRadius: 0 },
      { label: "Batas Waspada Diastole (80)", data: td.map(() => 80), borderColor: "#BA7517", borderDash: [8, 4], borderWidth: 1.5, pointRadius: 0 },
      { label: "Sistole Pasien", data: td.map((d) => d.sistole), borderColor: "#185FA5", backgroundColor: "#185FA5", borderWidth: 2.5, pointRadius: 4 },
      { label: "Diastole Pasien", data: td.map((d) => d.diastole), borderColor: "#0F6E56", backgroundColor: "#0F6E56", borderWidth: 2.5, pointRadius: 4 },
    ],
  }), [td]);

  const chartBB = useMemo(() => ({
    labels: bb.map((d) => `Mgg ${d.minggu}`),
    datasets: [
      { label: "Batas Atas PBB", data: bb.map((d) => getBatasBB(d.minggu, kategoriIMT).max), borderColor: "#BA7517", borderDash: [5, 5], borderWidth: 1, pointRadius: 0, fill: false },
      { label: "Batas Bawah PBB", data: bb.map((d) => getBatasBB(d.minggu, kategoriIMT).min), borderColor: "#BA7517", borderDash: [5, 5], borderWidth: 1, pointRadius: 0, fill: "-1", backgroundColor: "rgba(186,117,23,0.10)" },
      { label: "Kenaikan BB Pasien (kg)", data: bb.map((d) => d.berat), borderColor: "#BA7517", backgroundColor: "#BA7517", borderWidth: 2.5, pointRadius: 4 },
    ],
  }), [bb, kategoriIMT]);

  const withKehamilan = useCallback(
    (path) => `${path}?kehamilan_id=${kehamilan.id}`,
    [kehamilan]
  );

  const handleRujukClick = useCallback(
    (e) => {
      e.preventDefault();
      Swal.fire({
        title: "Konfirmasi Rujukan",
        text: `Ibu ini memiliki status "${normalizeDisplayStatus(risk?.status_risiko)}". Lanjutkan ke form rujukan?`,
        icon: "warning",
        showCancelButton: true,
        confirmButtonColor: "#A32D2D",
        cancelButtonColor: "#6B7280",
        confirmButtonText: "Ya, Rujuk",
        cancelButtonText: "Batal",
        reverseButtons: true,
      }).then((result) => {
        if (result.isConfirmed) navigate(withKehamilan(`/data-ibu/${ibuId}/rujukan`));
      });
    },
    [risk, navigate, withKehamilan, ibuId]
  );

  const toggleRiskExpand = useCallback((riskName) => {
    setExpandedRisks((prev) => ({ ...prev, [riskName]: !prev[riskName] }));
  }, []);

  const displayStatus = hasExaminations && risk ? normalizeDisplayStatus(risk.status_risiko) : "NORMAL";

  // ── Loading state ──
  if (loading) {
    return (
      <MainLayout>
        <div className="flex items-center justify-center min-h-screen" style={{ backgroundColor: "#F7FAFB" }}>
          <div className="flex flex-col items-center gap-3">
            <div
              className="w-8 h-8 border-4 border-t-transparent rounded-full animate-spin"
              style={{ borderColor: "#185FA5", borderTopColor: "transparent" }}
            />
            <p className="text-sm text-gray-500 font-medium">Memuat Data...</p>
          </div>
        </div>
      </MainLayout>
    );
  }

  if (error) {
    return (
      <MainLayout>
        <div className="flex items-center justify-center min-h-screen" style={{ backgroundColor: "#F7FAFB" }}>
          <div className="text-center space-y-3">
            <AlertTriangle size={40} className="mx-auto" style={{ color: "#A32D2D" }} />
            <p className="font-semibold text-gray-700">{error}</p>
            <button
              onClick={() => navigate(-1)}
              className="text-sm font-semibold px-5 py-2 rounded-full border"
              style={{ borderColor: "#185FA5", color: "#185FA5" }}
            >
              Kembali
            </button>
          </div>
        </div>
      </MainLayout>
    );
  }

  if (!kehamilan) {
    return (
      <MainLayout>
        <div className="p-10 text-center text-gray-500">Data kehamilan tidak tersedia.</div>
      </MainLayout>
    );
  }

  const riskConfig = risk ? getRiskConfig(risk.status_risiko) : getRiskConfig("NORMAL");
  const RiskIcon = riskConfig.icon;

  return (
    <MainLayout>
      <div className="min-h-screen font-sans" style={{ backgroundColor: "#F7FAFB" }}>
        <div className="max-w-6xl mx-auto px-4 py-6 space-y-5">

          {/* ── Header ── */}
          <div className="flex flex-col sm:flex-row sm:items-start justify-between gap-4">
            <div>
              <div className="flex items-center gap-3 flex-wrap mb-1">
                <Link
                  to={`/data-ibu/${ibuId}?kehamilan_id=${kehamilan.id}`}
                  className="inline-flex items-center gap-2 px-4 py-2 rounded-full border text-sm font-semibold transition hover:bg-white"
                  style={{ borderColor: "#185FA5", color: "#185FA5" }}
                >
                  <ArrowLeft size={15} /> Kembali
                </Link>
                <h1 className="text-xl sm:text-2xl font-bold text-gray-900">
                  Pemantauan Antenatal Care (ANC)
                </h1>
              </div>
              <p className="text-sm text-gray-500 ml-0 sm:ml-[108px]">
                Grafik dan riwayat pemeriksaan kehamilan berdasarkan standar Buku KIA dan Prediksi ML.
              </p>
            </div>

            <div className="flex gap-2.5 flex-shrink-0 sm:mt-0.5">
              {canEdit && (
                <Link
                  to={withKehamilan(`/data-ibu/${ibuId}/pemeriksaan-rutin/baru`)}
                  className="text-white px-5 py-2.5 rounded-full flex items-center gap-2 text-sm font-semibold transition hover:opacity-90 shadow-sm"
                  style={{ backgroundColor: "#185FA5" }}
                >
 Tambah Pemeriksaan
                </Link>
              )}
              {hasExaminations && displayStatus === "PERLU RUJUKAN" && canEdit && (
                <button
                  onClick={handleRujukClick}
                  className="text-white px-5 py-2.5 rounded-full flex items-center gap-2 text-sm font-semibold transition hover:opacity-90 shadow-sm"
                  style={{ backgroundColor: "#A32D2D" }}
                >
                  <AlertTriangle size={15} /> Rujuk Segera
                </button>
              )}
            </div>
          </div>

          {/* ── Banner mode baca dokter ── */}
          {!canEdit && (
            <div
              className="flex items-center gap-2.5 px-4 py-3 rounded-xl text-sm font-medium"
              style={{ backgroundColor: "#EBF3FC", border: "1px solid #C3D9F0", color: "#185FA5" }}
            >
              <Eye size={15} />
              Anda masuk sebagai Dokter — mode baca saja. Hanya Bidan yang dapat mengubah data ini.
            </div>
          )}

          {/* ── Banner status risiko ── */}
          {hasExaminations && risk && (
            <div
              className="rounded-2xl p-5 flex gap-4"
              style={{
                backgroundColor: riskConfig.bg,
                border: `1px solid ${riskConfig.border}`,
                borderLeft: `5px solid ${riskConfig.borderLeft}`,
              }}
            >
              <div
                className="p-2 rounded-xl flex-shrink-0 self-start mt-0.5"
                style={{ backgroundColor: riskConfig.border + "20" }}
              >
                <RiskIcon size={22} style={{ color: riskConfig.text }} />
              </div>
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2 flex-wrap mb-1.5">
                  <span
                    className="text-xs font-bold uppercase tracking-wider px-2.5 py-1 rounded-full text-white"
                    style={{ backgroundColor: riskConfig.labelBg }}
                  >
                    {displayStatus}
                  </span>
                  {/* {risk.is_ml_prediction && (
                    <span
                      className="text-xs font-semibold px-2 py-0.5 rounded-full"
                      style={{ backgroundColor: "#185FA520", color: "#185FA5" }}
                    >
                      Hasil Prediksi ML
                    </span>
                  )} */}
                </div>
                <p className="text-sm leading-relaxed" style={{ color: riskConfig.text }}>
                  {risk.ringkasan}
                </p>

                {/* Risiko yang terdeteksi (ML) */}
                {risk.is_ml_prediction && risk.risk_types?.length > 0 && (
                  <div className="mt-3">
                    <p className="text-xs font-bold mb-2" style={{ color: riskConfig.text, opacity: 0.8 }}>
                      Risiko yang Terdeteksi:
                    </p>
                    {risk.risk_types.filter((rt) => rt.detected).length > 0 ? (
                      <div className="space-y-1.5">
                        {risk.risk_types
                          .filter((rt) => rt.detected)
                          .sort((a, b) => b.probability - a.probability)
                          .map((riskType) => (
                            <div
                              key={riskType.name}
                              className="bg-white rounded-xl overflow-hidden"
                              style={{ border: `1px solid ${riskConfig.border}40` }}
                            >
                              <button
                                onClick={() => toggleRiskExpand(riskType.name)}
                                className="w-full px-3 py-2.5 flex items-center justify-between transition-colors hover:bg-black/5"
                              >
                                <div className="flex items-center gap-2">
                                  <span className="text-sm font-semibold text-gray-800">{riskType.name}</span>
                                  <span
                                    className="text-xs px-2 py-0.5 rounded-full font-bold"
                                    style={{ backgroundColor: riskConfig.bg, color: riskConfig.text }}
                                  >
                                    {(riskType.probability * 100).toFixed(1)}%
                                  </span>
                                </div>
                                {expandedRisks[riskType.name]
                                  ? <ChevronUp size={14} className="text-gray-400" />
                                  : <ChevronDown size={14} className="text-gray-400" />}
                              </button>
                              {expandedRisks[riskType.name] && riskType.tindakan?.length > 0 && (
                                <div
                                  className="px-3 py-2.5 border-t"
                                  style={{ borderColor: riskConfig.border + "30", backgroundColor: riskConfig.bg + "80" }}
                                >
                                  <p className="text-xs font-bold text-gray-600 mb-1.5">Tindakan yang Disarankan:</p>
                                  <ul className="space-y-1">
                                    {riskType.tindakan.map((t, idx) => (
                                      <li key={idx} className="flex items-start gap-2 text-xs text-gray-700">
                                        <span className="mt-0.5 flex-shrink-0" style={{ color: riskConfig.text }}>•</span>
                                        {t}
                                      </li>
                                    ))}
                                  </ul>
                                </div>
                              )}
                            </div>
                          ))}
                      </div>
                    ) : (
                      <div
                        className="px-3 py-2 rounded-xl text-xs font-semibold"
                        style={{ backgroundColor: "#EDF7E6", color: "#3B6D11", border: "1px solid #3B6D1130" }}
                      >
                        ✓ Tidak ada risiko yang terdeteksi
                      </div>
                    )}
                  </div>
                )}

                {/* Alasan klinis */}
                {risk.is_ml_prediction && risk.alasan_klinis?.length > 0 && (
                  <div className="mt-3">
                    <p className="text-xs font-bold mb-1" style={{ color: riskConfig.text, opacity: 0.8 }}>
                      Alasan Klinis:
                    </p>
                    <ul className="text-xs space-y-0.5 list-disc list-inside" style={{ color: riskConfig.text, opacity: 0.75 }}>
                      {risk.alasan_klinis.map((alasan, i) => <li key={i}>{alasan}</li>)}
                    </ul>
                  </div>
                )}

                {/* Faktor risiko fallback */}
                {!risk.is_ml_prediction && risk.faktorRujukan?.length > 0 && (
                  <ul className="mt-2 text-xs space-y-0.5 list-disc list-inside" style={{ color: riskConfig.text, opacity: 0.8 }}>
                    {risk.faktorRujukan.map((f, i) => <li key={i}>{f}</li>)}
                  </ul>
                )}
                {!risk.is_ml_prediction && risk.faktorTindakan?.length > 0 && (
                  <ul className="mt-2 text-xs space-y-0.5 list-disc list-inside" style={{ color: riskConfig.text, opacity: 0.8 }}>
                    {risk.faktorTindakan.map((f, i) => <li key={i}>{f}</li>)}
                  </ul>
                )}

                {latestExam && (
                  <p className="text-xs mt-2.5" style={{ color: riskConfig.text, opacity: 0.6 }}>
                    Berdasarkan kunjungan ke-{latestExam.kunjungan_ke} —{" "}
                    {new Date(latestExam.tanggal_periksa).toLocaleDateString("id-ID", {
                      day: "numeric", month: "long", year: "numeric",
                    })}
                  </p>
                )}
              </div>
            </div>
          )}

          {/* ── Kartu ringkasan ── */}
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
            <SummaryCard
              icon={Activity} iconColor="#185FA5" bgColor="#EBF3FC"
              label="IMT Awal"
              value={grafik?.imt_awal?.toFixed(2) || "-"}
              badge={kategoriIMT || undefined}
            />
            <SummaryCard
              icon={Heart} iconColor="#3B6D11" bgColor="#EDF7E6"
              label="DJJ Terakhir"
              value={djj.at(-1)?.value || latestExam?.denyut_jantung_janin || "-"}
              unit="bpm"
            />
            <SummaryCard
              icon={Scale} iconColor="#BA7517" bgColor="#FEF3CD"
              label="Kenaikan BB"
              value={bb.length > 0 ? bb.at(-1)?.berat ?? "0" : "-"}
              unit="kg"
            />
            <SummaryCard
              icon={CalendarDays} iconColor="#0F6E56" bgColor="#E6F4F1"
              label="Total Kunjungan"
              value={examinations.length}
              unit="kali"
            />
          </div>

          {/* ── Grafik ── */}
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
            <ChartCard icon={TrendingUp} iconColor="#185FA5" title="Tinggi Fundus Uteri (TFU)" empty={tfu.length === 0} emptyMsg="Belum ada data TFU">
              <Line data={chartTFU} options={commonOptions} />
            </ChartCard>
            <ChartCard icon={Heart} iconColor="#A32D2D" title="Detak Jantung Janin (DJJ)" empty={djj.length === 0} emptyMsg="Belum ada data DJJ">
              <Line data={chartDJJ} options={commonOptions} />
            </ChartCard>
            <ChartCard icon={Droplets} iconColor="#A32D2D" title="Tekanan Darah" empty={td.length === 0} emptyMsg="Belum ada data tekanan darah">
              <Line data={chartTD} options={commonOptions} />
            </ChartCard>
            <ChartCard icon={Scale} iconColor="#BA7517" title="Grafik Berat Badan (PBB)" empty={bb.length === 0} emptyMsg="Belum ada data berat badan">
              <Line data={chartBB} options={commonOptions} />
            </ChartCard>
          </div>

          {/* ── Riwayat Pemeriksaan ── */}
          <div className="space-y-3">
            <div className="flex items-center justify-between">
              <div>
                <h2 className="text-lg font-bold text-gray-900">Riwayat Pemeriksaan</h2>
                <p className="text-xs text-gray-400 mt-0.5">Daftar seluruh kunjungan ANC yang telah dicatat</p>
              </div>
              {/* {canEdit && hasExaminations && (
                // <Link
                //   to={withKehamilan(`/data-ibu/${ibuId}/pemeriksaan-rutin/baru`)}
                //   className="text-white px-4 py-2 rounded-full text-xs font-semibold flex items-center gap-1.5 transition hover:opacity-90"
                //   style={{ backgroundColor: "#185FA5" }}
                // >
                //   <Plus size={13} /> Tambah
                // </Link>
              )} */}
            </div>

            {!hasExaminations ? (
              <div className="bg-white rounded-2xl border border-gray-100 p-12 text-center">
                <div
                  className="mx-auto w-16 h-16 rounded-full flex items-center justify-center mb-4"
                  style={{ backgroundColor: "#F7FAFB" }}
                >
                  <Stethoscope size={32} strokeWidth={1.5} className="text-gray-300" />
                </div>
                <p className="font-semibold text-gray-600 mb-1">Tidak Ada Data Pemeriksaan</p>
                <p className="text-sm text-gray-400 mb-5">Belum ada kunjungan ANC yang tercatat untuk kehamilan ini.</p>
                {canEdit && (
                  <Link
                    to={withKehamilan(`/data-ibu/${ibuId}/pemeriksaan-rutin/baru`)}
                    className="inline-flex items-center gap-2 text-white px-6 py-2.5 rounded-full text-sm font-semibold transition hover:opacity-90"
                    style={{ backgroundColor: "#185FA5" }}
                  >
                    <Plus size={15} /> Tambah Pemeriksaan Pertama
                  </Link>
                )}
              </div>
            ) : (
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
                {examinations.map((exam) => {
                  const isLatest = latestExam?.id_periksa === exam.id_periksa;
                  return (
                    <div
                      key={exam.id_periksa}
                      className="group bg-white rounded-2xl border transition-all hover:shadow-md"
                      style={{ borderColor: isLatest ? "#185FA5" : "#E5E7EB" }}
                    >
                      <div className="p-5">
                        <div className="flex items-center justify-between mb-3">
                          <span
                            className="text-xs font-bold px-2.5 py-1 rounded-lg uppercase"
                            style={{ backgroundColor: "#EBF3FC", color: "#185FA5" }}
                          >
                            Kunjungan {exam.kunjungan_ke}
                          </span>
                          {isLatest && (
                            <span
                              className="flex items-center gap-1 text-xs font-bold px-2 py-0.5 rounded-full"
                              style={{ backgroundColor: "#EDF7E6", color: "#3B6D11" }}
                            >
                              <span
                                className="w-1.5 h-1.5 rounded-full animate-pulse"
                                style={{ backgroundColor: "#3B6D11" }}
                              />
                              Terbaru
                            </span>
                          )}
                        </div>
                        <div className="mb-4">
                          <p className="text-xs text-gray-400 mb-0.5">Tanggal Pemeriksaan</p>
                          <p className="font-bold text-gray-800 text-sm">
                            {new Date(exam.tanggal_periksa).toLocaleDateString("id-ID", {
                              day: "numeric", month: "long", year: "numeric",
                            })}
                          </p>
                        </div>
                        <Link
                          to={withKehamilan(`/data-ibu/${ibuId}/pemeriksaan-rutin/${exam.id_periksa}`)}
                          className="w-full flex items-center justify-center gap-2 py-2.5 rounded-xl text-sm font-semibold transition-all"
                          style={{
                            backgroundColor: "#F7FAFB",
                            color: "#185FA5",
                            border: "1px solid #E5E7EB",
                          }}
                          onMouseEnter={(e) => {
                            e.currentTarget.style.backgroundColor = "#185FA5";
                            e.currentTarget.style.color = "#fff";
                            e.currentTarget.style.borderColor = "#185FA5";
                          }}
                          onMouseLeave={(e) => {
                            e.currentTarget.style.backgroundColor = "#F7FAFB";
                            e.currentTarget.style.color = "#185FA5";
                            e.currentTarget.style.borderColor = "#E5E7EB";
                          }}
                        >
                          <Eye size={14} /> Detail
                        </Link>
                      </div>
                    </div>
                  );
                })}
              </div>
            )}
          </div>

        </div>
      </div>
    </MainLayout>
  );
}