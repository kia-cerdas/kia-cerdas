import React, { useEffect, useState, useMemo } from "react";
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

import { Plus, AlertTriangle, Activity, Scale, Heart, Droplets, FileText } from "lucide-react";
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

// ─────────────────────────────────────────────
// Helper: Hitung batas kenaikan BB (Buku KIA)
// ─────────────────────────────────────────────
const getBatasBB = (minggu, kategoriIMT) => {
  let rateMin = 0.35, rateMax = 0.50, t1Min = 0.5, t1Max = 2.0;
  const kat = kategoriIMT?.toLowerCase() || "";
  if (kat.includes("kurang"))        { rateMin = 0.44; rateMax = 0.58; t1Min = 1.0; t1Max = 2.0; }
  else if (kat.includes("overweight")){ rateMin = 0.23; rateMax = 0.33; t1Min = 0.5; t1Max = 1.0; }
  else if (kat.includes("obesitas"))  { rateMin = 0.17; rateMax = 0.27; t1Min = 0.2; t1Max = 0.5; }

  if (minggu <= 12) {
    return { min: (t1Min / 12) * minggu, max: (t1Max / 12) * minggu };
  }
  return {
    min: t1Min + ((minggu - 12) * rateMin),
    max: t1Max + ((minggu - 12) * rateMax),
  };
};

// ─────────────────────────────────────────────
// Helper: Hitung status risiko dari data klinis
// kunjungan terakhir (standar Buku KIA)
// ─────────────────────────────────────────────
const hitungStatusRisiko = (exam) => {
  if (!exam) return null;

  const faktorRujukan  = [];
  const faktorTindakan = [];

  // 1. Tekanan darah — ≥140/90 → rujukan; 130-139/80-89 → tindakan
  const { sistole, diastole } = exam;
  if (sistole >= 140 || diastole >= 90) {
    faktorRujukan.push(`Tekanan darah tinggi (${sistole}/${diastole} mmHg)`);
  } else if (sistole >= 130 || diastole >= 80) {
    faktorTindakan.push(`Tekanan darah batas waspada (${sistole}/${diastole} mmHg)`);
  }

  // 2. DJJ — normal 120-160 bpm
  const djj = exam.denyut_jantung_janin;
  if (djj && (djj < 100 || djj > 180)) {
    faktorRujukan.push(`DJJ tidak normal (${djj} bpm)`);
  } else if (djj && (djj < 120 || djj > 160)) {
    faktorTindakan.push(`DJJ di luar batas normal (${djj} bpm)`);
  }

  // 3. Hemoglobin (Hb) — <7 g/dL → rujukan; 7-10 → tindakan
  const hb = exam.tes_lab_hb;
  if (hb && hb < 7) {
    faktorRujukan.push(`Anemia berat, Hb ${hb} g/dL`);
  } else if (hb && hb < 10) {
    faktorTindakan.push(`Anemia sedang, Hb ${hb} g/dL`);
  }

  // 4. Gula darah — >200 → rujukan; 140-200 → tindakan
  const gds = exam.tes_lab_gula_darah;
  if (gds && gds > 200) {
    faktorRujukan.push(`Gula darah sangat tinggi (${gds} mg/dL)`);
  } else if (gds && gds > 140) {
    faktorTindakan.push(`Gula darah meningkat (${gds} mg/dL)`);
  }

  // 5. Protein urine — positif → rujukan
  const protein = exam.tes_lab_protein_urine?.toLowerCase() || "";
  if (protein.includes("positif") || protein === "++" || protein === "+++") {
    faktorRujukan.push(`Protein urine positif (${exam.tes_lab_protein_urine})`);
  } else if (protein === "+" || protein.includes("trace")) {
    faktorTindakan.push(`Protein urine trace/+1 (${exam.tes_lab_protein_urine})`);
  }

  // 6. LILA — <23.5 cm → tindakan
  const lila = exam.lingkar_lengan_atas;
  if (lila && lila < 23.5) {
    faktorTindakan.push(`LILA kurang dari normal (${lila} cm)`);
  }

  // Tentukan status akhir
  let status_risiko, ringkasan;
  if (faktorRujukan.length > 0) {
    status_risiko = "PERLU RUJUKAN";
    ringkasan = `Ditemukan ${faktorRujukan.length} indikator risiko tinggi: ${faktorRujukan.join("; ")}.`;
  } else if (faktorTindakan.length > 0) {
    status_risiko = "PERLU TINDAKAN";
    ringkasan = `Ditemukan ${faktorTindakan.length} indikator perlu perhatian: ${faktorTindakan.join("; ")}.`;
  } else {
    status_risiko = "NORMAL";
    ringkasan = "Semua parameter klinis dalam batas normal. Pantau secara rutin sesuai jadwal ANC.";
  }

  return { status_risiko, ringkasan, faktorRujukan, faktorTindakan };
};

// ─────────────────────────────────────────────
// Komponen utama
// ─────────────────────────────────────────────
export default function PemeriksaanKehamilanList() {
  const navigate = useNavigate();
  const { id: ibuId } = useParams();
  const [searchParams] = useSearchParams();
  const kehamilanIdQuery = searchParams.get("kehamilan_id");

  const user    = getCurrentUser();
  const isDokter = isDokterUser(user);
  const canEdit  = !isDokter;

  const [kehamilan,   setKehamilan]   = useState(null);
  const [examinations, setExaminations] = useState([]);
  const [grafik,       setGrafik]       = useState(null);
  const [loading,      setLoading]      = useState(true);
  const [error,        setError]        = useState(null);

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
          selectedKehamilan = kehamilanList.find(k => k.id == kehamilanIdQuery);
          if (!selectedKehamilan) {
            setError(`Kehamilan dengan ID ${kehamilanIdQuery} tidak ditemukan untuk ibu ini.`);
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

        // Sort ascending untuk tampilan riwayat (kunjungan_ke terkecil di atas)
        // tapi kita simpan juga versi sorted by tanggal untuk ambil data terbaru
        setExaminations((examRes || []).sort((a, b) => {
          // Utamakan kunjungan_ke, jika sama bandingkan tanggal
          if (a.kunjungan_ke !== b.kunjungan_ke) return a.kunjungan_ke - b.kunjungan_ke;
          return new Date(a.tanggal_periksa) - new Date(b.tanggal_periksa);
        }));
        setGrafik(grafikRes?.data || grafikRes || null);
      } catch (err) {
        console.error(err);
        setError("Gagal memuat data pemeriksaan kehamilan");
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [ibuId, kehamilanIdQuery]);

  const tfu         = grafik?.grafik_tfu            ?? [];
  const djj         = grafik?.grafik_djj            ?? [];
  const td          = grafik?.grafik_tekanan_darah  ?? [];
  const bb          = grafik?.grafik_berat_badan    ?? [];
  const kategoriIMT = grafik?.kategori_imt;

  const hasExaminations = examinations.length > 0;

  // Ambil kunjungan dengan tanggal_periksa terbaru (bukan sekadar index terakhir)
  // agar setelah edit, status risiko langsung mencerminkan data yang baru disimpan
  const latestExam = useMemo(() => {
    if (!hasExaminations) return null;
    return [...examinations].sort(
      (a, b) => new Date(b.tanggal_periksa) - new Date(a.tanggal_periksa)
    )[0];
  }, [examinations, hasExaminations]);

  // ── Hitung status risiko dari kunjungan terakhir ──
  // Prioritas: jika backend sudah mengisi status_risiko → pakai itu
  // Jika belum (string kosong) → hitung dari frontend
  const riskFromBackend = grafik?.detail_risiko;
  const riskFromFrontend = useMemo(() => hitungStatusRisiko(latestExam), [latestExam]);

  const risk = useMemo(() => {
    if (!hasExaminations) return null;
    // Gunakan data backend jika sudah terisi
    if (riskFromBackend?.status_risiko && riskFromBackend.status_risiko !== "") {
      return riskFromBackend;
    }
    // Fallback: hitung di frontend
    return riskFromFrontend;
  }, [hasExaminations, riskFromBackend, riskFromFrontend]);

  // ── Style helpers ──
  const getRiskStyles = (status) => {
    if (status === "PERLU RUJUKAN")  return "bg-red-50 border-red-200 text-red-700";
    if (status === "PERLU TINDAKAN") return "bg-yellow-50 border-yellow-200 text-yellow-700";
    return "bg-green-50 border-green-200 text-green-700";
  };

  const getBadgeStyles = (status) => {
    if (status === "PERLU RUJUKAN")  return "bg-red-100 text-red-700 border-red-200";
    if (status === "PERLU TINDAKAN") return "bg-yellow-100 text-yellow-700 border-yellow-200";
    return "bg-green-100 text-green-700 border-green-200";
  };

  // ── Chart options ──
  const commonOptions = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: { position: "bottom", labels: { boxWidth: 12, font: { size: 11 } } },
    },
    scales: {
      y: { beginAtZero: false, grid: { color: "#f3f4f6" } },
      x: { grid: { display: false } },
    },
  };

  const chartTFU = useMemo(() => ({
    labels: tfu.map((d) => `Mgg ${d.minggu}`),
    datasets: [
      { label: "Batas Atas (+2cm)",  data: tfu.map((d) => d.minggu + 2), borderColor: "#10b981", borderDash: [5,5], borderWidth: 1, pointRadius: 0, fill: false },
      { label: "Batas Bawah (-2cm)", data: tfu.map((d) => d.minggu - 2), borderColor: "#10b981", borderDash: [5,5], borderWidth: 1, pointRadius: 0, fill: "-1", backgroundColor: "rgba(16,185,129,0.15)" },
      { label: "TFU Pasien (cm)",    data: tfu.map((d) => d.value), borderColor: "#4f46e5", backgroundColor: "#4f46e5", borderWidth: 3, pointRadius: 5 },
    ],
  }), [tfu]);

  const chartDJJ = useMemo(() => ({
    labels: djj.map((d) => `Mgg ${d.minggu}`),
    datasets: [
      { label: "Batas Atas (160)",  data: djj.map(() => 160), borderColor: "#ef4444", borderWidth: 1, pointRadius: 0, fill: false },
      { label: "Batas Bawah (120)", data: djj.map(() => 120), borderColor: "#ef4444", borderWidth: 1, pointRadius: 0, fill: "-1", backgroundColor: "rgba(16,185,129,0.15)" },
      { label: "DJJ Pasien (bpm)", data: djj.map((d) => d.value), borderColor: "#06b6d4", backgroundColor: "#06b6d4", borderWidth: 3, pointRadius: 5 },
    ],
  }), [djj]);

  const chartTD = useMemo(() => ({
    labels: td.map((d) => `Mgg ${d.minggu}`),
    datasets: [
      { label: "Batas Waspada Sistole (130)", data: td.map(() => 130), borderColor: "#ef4444", borderDash: [10,5], borderWidth: 2, pointRadius: 0 },
      { label: "Batas Waspada Diastole (80)", data: td.map(() => 80),  borderColor: "#f59e0b", borderDash: [10,5], borderWidth: 2, pointRadius: 0 },
      { label: "Sistole Pasien",  data: td.map((d) => d.sistole),  borderColor: "#4f46e5", backgroundColor: "#4f46e5", borderWidth: 3, pointRadius: 4 },
      { label: "Diastole Pasien", data: td.map((d) => d.diastole), borderColor: "#06b6d4", backgroundColor: "#06b6d4", borderWidth: 3, pointRadius: 4 },
    ],
  }), [td]);

  const chartBB = useMemo(() => ({
    labels: bb.map((d) => `Mgg ${d.minggu}`),
    datasets: [
      { label: "Batas Atas PBB",  data: bb.map((d) => getBatasBB(d.minggu, kategoriIMT).max), borderColor: "#ec4899", borderDash: [5,5], borderWidth: 1, pointRadius: 0, fill: false },
      { label: "Batas Bawah PBB", data: bb.map((d) => getBatasBB(d.minggu, kategoriIMT).min), borderColor: "#ec4899", borderDash: [5,5], borderWidth: 1, pointRadius: 0, fill: "-1", backgroundColor: "rgba(236,72,153,0.15)" },
      { label: "Kenaikan BB Pasien (kg)", data: bb.map((d) => d.berat), borderColor: "#f59e0b", backgroundColor: "#f59e0b", borderWidth: 3, pointRadius: 5 },
    ],
  }), [bb, kategoriIMT]);

  // ── Handler rujukan ──
  const handleRujukClick = (e) => {
    e.preventDefault();
    Swal.fire({
      title: "Konfirmasi Rujukan",
      text: `Ibu ini memiliki status "${risk?.status_risiko}". Lanjutkan ke form rujukan?`,
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#d33",
      cancelButtonColor: "#3085d6",
      confirmButtonText: "Ya, Rujuk",
      cancelButtonText: "Batal",
      reverseButtons: true,
    }).then((result) => {
      if (result.isConfirmed) {
        navigate(withKehamilan(`/data-ibu/${ibuId}/rujukan`));
      }
    });
  };

  const withKehamilan = (path) => `${path}?kehamilan_id=${kehamilan.id}`;

  const showWarning = hasExaminations && risk && risk.status_risiko !== "NORMAL";

  // ── Render states ──
  if (loading) return <MainLayout><div className="p-10 text-center">Memuat data medis...</div></MainLayout>;
  if (error)   return <MainLayout><div className="p-10 text-center text-red-600">{error}</div></MainLayout>;
  if (!kehamilan) return <MainLayout><div className="p-10 text-center">Data kehamilan tidak tersedia</div></MainLayout>;

  return (
    <MainLayout>
      <div className="p-6 max-w-6xl mx-auto space-y-6">

        {/* ── Header ── */}
        <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
          <div className="flex-1">
            <div className="flex items-center gap-3 flex-wrap">
              <h1 className="text-3xl font-extrabold text-gray-900">Pemantauan ANC</h1>

              {/* Badge status risiko */}
              {hasExaminations && risk && (
                <span className={`inline-flex items-center gap-1 px-3 py-1 rounded-full text-xs font-bold uppercase tracking-wide border ${getBadgeStyles(risk.status_risiko)}`}>
                  <span className="w-2 h-2 rounded-full bg-current animate-pulse"></span>
                  {risk.status_risiko}
                </span>
              )}
            </div>
            <p className="text-gray-500 italic mt-1">Berdasarkan Standar Buku KIA & Skrining Risiko</p>

            {/* Peringatan jika status bukan NORMAL */}
            {showWarning && (
              <div className={`mt-2 text-sm p-2 rounded-lg inline-block ${
                risk.status_risiko === "PERLU RUJUKAN"
                  ? "text-red-600 bg-red-50"
                  : "text-yellow-700 bg-yellow-50"
              }`}>
                ⚠️ Ibu hamil dengan status {risk.status_risiko} memerlukan perhatian khusus.
                {risk.status_risiko === "PERLU RUJUKAN" && " Segera lakukan rujukan."}
              </div>
            )}
          </div>

          <div className="flex gap-3 flex-shrink-0">
            {canEdit && (
              <Link
                to={withKehamilan(`/data-ibu/${ibuId}/pemeriksaan-rutin/baru`)}
                className="bg-indigo-600 hover:bg-indigo-700 text-white px-5 py-2.5 rounded-xl flex items-center gap-2 transition-all shadow-md hover:shadow-lg"
              >
                <Plus size={20} /> Catat Pemeriksaan
              </Link>
            )}

            {/* Tombol Rujuk: muncul jika PERLU RUJUKAN, dan hanya untuk bidan (canEdit) */}
            {hasExaminations && risk?.status_risiko === "PERLU RUJUKAN" && canEdit && (
              <button
                onClick={handleRujukClick}
                className="bg-red-600 hover:bg-red-700 text-white px-5 py-2.5 rounded-xl flex items-center gap-2 transition-all shadow-md hover:shadow-lg animate-pulse"
              >
                <AlertTriangle size={18} /> Rujuk Segera
              </button>
            )}
          </div>
        </div>

        {/* ── Info mode dokter ── */}
        {!canEdit && (
          <div className="bg-blue-50 border border-blue-200 rounded-lg p-3 text-blue-700 text-sm flex items-center gap-2">
            <AlertTriangle size={16} /> Anda dalam mode baca (Dokter). Data hanya dapat dilihat, tidak dapat diubah atau menambah pemeriksaan.
          </div>
        )}

        {/* ── Banner status risiko ── */}
        {hasExaminations && risk && (
          <div className={`border-l-4 p-5 rounded-r-2xl shadow-sm flex gap-4 ${getRiskStyles(risk.status_risiko)}`}>
            <AlertTriangle className="flex-shrink-0" size={28} />
            <div>
              <h3 className="font-bold text-lg uppercase tracking-wide">
                Status: {risk.status_risiko}
              </h3>
              <p className="text-sm leading-relaxed mt-1">{risk.ringkasan}</p>

              {/* Detail faktor risiko jika ada */}
              {risk.faktorRujukan?.length > 0 && (
                <ul className="mt-2 text-xs space-y-0.5 list-disc list-inside opacity-80">
                  {risk.faktorRujukan.map((f, i) => (
                    <li key={i}>{f}</li>
                  ))}
                </ul>
              )}
              {risk.faktorTindakan?.length > 0 && (
                <ul className="mt-2 text-xs space-y-0.5 list-disc list-inside opacity-80">
                  {risk.faktorTindakan.map((f, i) => (
                    <li key={i}>{f}</li>
                  ))}
                </ul>
              )}

              {/* Sumber data */}
              {latestExam && (
                <p className="text-xs mt-2 opacity-60">
                  Berdasarkan kunjungan ke-{latestExam.kunjungan_ke} ({new Date(latestExam.tanggal_periksa).toLocaleDateString("id-ID", { day: "numeric", month: "long", year: "numeric" })})
                </p>
              )}
            </div>
          </div>
        )}

        {/* ── Summary Cards ── */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          <div className="bg-white p-5 rounded-2xl shadow-sm border border-gray-100">
            <div className="flex items-center gap-3 text-indigo-600 mb-2">
              <Activity size={18} />
              <span className="text-xs font-semibold uppercase tracking-wider text-gray-400">IMT Awal</span>
            </div>
            <p className="text-2xl font-black text-gray-800">{grafik?.imt_awal?.toFixed(2) || "-"}</p>
            <span className="text-xs font-medium px-2 py-1 bg-indigo-50 text-indigo-700 rounded-lg">{kategoriIMT || "-"}</span>
          </div>

          <div className="bg-white p-5 rounded-2xl shadow-sm border border-gray-100">
            <div className="flex items-center gap-3 text-emerald-600 mb-2">
              <Heart size={18} />
              <span className="text-xs font-semibold uppercase tracking-wider text-gray-400">DJJ Terakhir</span>
            </div>
            <p className="text-2xl font-black text-gray-800">
              {djj.at(-1)?.value || latestExam?.denyut_jantung_janin || "-"}
              <span className="text-sm font-normal text-gray-400"> bpm</span>
            </p>
          </div>

          <div className="bg-white p-5 rounded-2xl shadow-sm border border-gray-100">
            <div className="flex items-center gap-3 text-orange-600 mb-2">
              <Scale size={18} />
              <span className="text-xs font-semibold uppercase tracking-wider text-gray-400">Kenaikan BB</span>
            </div>
            <p className="text-2xl font-black text-gray-800">
              {bb.at(-1)?.berat || "0"}
              <span className="text-sm font-normal text-gray-400"> kg</span>
            </p>
          </div>

          <div className="bg-white p-5 rounded-2xl shadow-sm border border-gray-100">
            <div className="flex items-center gap-3 text-blue-600 mb-2">
              <Droplets size={18} />
              <span className="text-xs font-semibold uppercase tracking-wider text-gray-400">Total Kunjungan</span>
            </div>
            <p className="text-2xl font-black text-gray-800">
              {examinations.length}
              <span className="text-sm font-normal text-gray-400"> Kali</span>
            </p>
          </div>
        </div>

        {/* ── Grafik ── */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div className="bg-white p-6 rounded-3xl shadow-sm border border-gray-100">
            <h2 className="font-bold text-gray-700 mb-4 flex items-center gap-2">📈 Tinggi Fundus (TFU)</h2>
            {tfu.length === 0 ? (
              <div className="h-64 flex flex-col items-center justify-center text-gray-400 bg-gray-50 rounded-xl">
                <FileText size={48} strokeWidth={1.5} /><p className="mt-2 text-sm">Belum ada data TFU</p>
              </div>
            ) : (
              <div className="h-64"><Line data={chartTFU} options={commonOptions} /></div>
            )}
          </div>

          <div className="bg-white p-6 rounded-3xl shadow-sm border border-gray-100">
            <h2 className="font-bold text-gray-700 mb-4 flex items-center gap-2">💓 Detak Jantung Janin</h2>
            {djj.length === 0 ? (
              <div className="h-64 flex flex-col items-center justify-center text-gray-400 bg-gray-50 rounded-xl">
                <FileText size={48} strokeWidth={1.5} /><p className="mt-2 text-sm">Belum ada data DJJ</p>
              </div>
            ) : (
              <div className="h-64"><Line data={chartDJJ} options={commonOptions} /></div>
            )}
          </div>

          <div className="bg-white p-6 rounded-3xl shadow-sm border border-gray-100">
            <h2 className="font-bold text-gray-700 mb-4 flex items-center gap-2">🩸 Tekanan Darah</h2>
            {td.length === 0 ? (
              <div className="h-64 flex flex-col items-center justify-center text-gray-400 bg-gray-50 rounded-xl">
                <FileText size={48} strokeWidth={1.5} /><p className="mt-2 text-sm">Belum ada data tekanan darah</p>
              </div>
            ) : (
              <div className="h-64"><Line data={chartTD} options={commonOptions} /></div>
            )}
          </div>

          <div className="bg-white p-6 rounded-3xl shadow-sm border border-gray-100">
            <h2 className="font-bold text-gray-700 mb-4 flex items-center gap-2">⚖️ Grafik Berat Badan (PBB)</h2>
            {bb.length === 0 ? (
              <div className="h-64 flex flex-col items-center justify-center text-gray-400 bg-gray-50 rounded-xl">
                <FileText size={48} strokeWidth={1.5} /><p className="mt-2 text-sm">Belum ada data berat badan</p>
              </div>
            ) : (
              <div className="h-64"><Line data={chartBB} options={commonOptions} /></div>
            )}
          </div>
        </div>

        {/* ── Riwayat Pemeriksaan ── */}
        <div className="space-y-4">
          <h2 className="text-xl font-bold text-gray-800">Riwayat Pemeriksaan</h2>

          {!hasExaminations ? (
            <div className="bg-white rounded-2xl border border-gray-100 p-12 text-center">
              <FileText size={64} className="mx-auto text-gray-300 mb-4" strokeWidth={1.5} />
              <p className="text-gray-500">Belum ada pemeriksaan yang tercatat.</p>
              {canEdit && (
                <Link
                  to={withKehamilan(`/data-ibu/${ibuId}/pemeriksaan-rutin/baru`)}
                  className="inline-block mt-4 bg-indigo-600 hover:bg-indigo-700 text-white px-5 py-2 rounded-xl text-sm transition-all"
                >
                  + Catat Pemeriksaan Pertama
                </Link>
              )}
            </div>
          ) : (
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
              {examinations.map((exam) => (
                <div
                  key={exam.id_periksa}
                  className="group bg-white p-5 rounded-2xl shadow-sm border border-gray-100 hover:border-indigo-300 transition-all"
                >
                  <div className="flex justify-between items-start mb-3">
                    <span className="bg-gray-100 text-gray-600 text-[10px] font-bold px-2 py-1 rounded-md uppercase">
                      Kunjungan {exam.kunjungan_ke}
                    </span>
                    {latestExam?.id_periksa === exam.id_periksa && (
                      <span className="flex items-center gap-1 text-[10px] font-bold bg-green-100 text-green-700 px-2 py-1 rounded-md">
                        <div className="w-1.5 h-1.5 bg-green-500 rounded-full animate-pulse"></div> TERBARU
                      </span>
                    )}
                  </div>
                  <p className="text-gray-400 text-xs mb-1">Tanggal Periksa</p>
                  <p className="font-bold text-gray-800 mb-4">
                    {new Date(exam.tanggal_periksa).toLocaleDateString("id-ID", { day: "numeric", month: "long", year: "numeric" })}
                  </p>
                  <Link
                    to={withKehamilan(`/data-ibu/${ibuId}/pemeriksaan-rutin/${exam.id_periksa}`)}
                    className="w-full block text-center py-2 bg-gray-50 group-hover:bg-indigo-600 group-hover:text-white text-indigo-600 rounded-xl text-sm font-semibold transition-all"
                  >
                    Lihat Detail
                  </Link>
                </div>
              ))}
            </div>
          )}
        </div>

      </div>
    </MainLayout>
  );
}
