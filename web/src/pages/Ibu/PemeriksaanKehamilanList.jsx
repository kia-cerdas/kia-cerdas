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

// ── Helper: Parse alasan_klinis dari string JSON ──
const parseAlasanKlinis = (alasanString) => {
  if (!alasanString) return [];
  try {
    return JSON.parse(alasanString);
  } catch {
    return [];
  }
};

// ── Helper: Parse risk_types dari string JSON ──
const parseRiskTypes = (riskTypesString) => {
  if (!riskTypesString) return [];
  try {
    return JSON.parse(riskTypesString);
  } catch {
    return [];
  }
};

// ── Helper: Batas kenaikan BB berdasarkan Buku KIA ──
const getBatasBB = (minggu, kategoriIMT) => {
  let rateMin = 0.35,
    rateMax = 0.5,
    t1Min = 0.5,
    t1Max = 2.0;
  const kat = kategoriIMT?.toLowerCase() || "";

  if (kat.includes("kurang")) {
    rateMin = 0.44; rateMax = 0.58; t1Min = 1.0; t1Max = 2.0;
  } else if (kat.includes("overweight")) {
    rateMin = 0.23; rateMax = 0.33; t1Min = 0.5; t1Max = 1.0;
  } else if (kat.includes("obesitas")) {
    rateMin = 0.17; rateMax = 0.27; t1Min = 0.2; t1Max = 0.5;
  }

  if (minggu <= 12) {
    return { min: (t1Min / 12) * minggu, max: (t1Max / 12) * minggu };
  }
  return {
    min: t1Min + (minggu - 12) * rateMin,
    max: t1Max + (minggu - 12) * rateMax,
  };
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

  // 1. Tekanan darah
  const { sistole, diastole } = exam;
  if (sistole >= 140 || diastole >= 90) {
    faktorRujukan.push(`Tekanan darah tinggi (${sistole}/${diastole} mmHg)`);
  } else if (sistole >= 130 || diastole >= 80) {
    faktorTindakan.push(`Tekanan darah batas waspada (${sistole}/${diastole} mmHg)`);
  }

  // 2. DJJ
  const djj = exam.denyut_jantung_janin;
  if (djj && (djj < 100 || djj > 180)) {
    faktorRujukan.push(`DJJ tidak normal (${djj} bpm)`);
  } else if (djj && (djj < 120 || djj > 160)) {
    faktorTindakan.push(`DJJ di luar batas normal (${djj} bpm)`);
  }

  // 3. Hemoglobin
  const hb = exam.tes_lab_hb;
  if (hb && hb < 7) {
    faktorRujukan.push(`Anemia berat, Hb ${hb} g/dL`);
  } else if (hb && hb < 10) {
    faktorTindakan.push(`Anemia sedang, Hb ${hb} g/dL`);
  }

  // 4. Gula darah
  const gds = exam.tes_lab_gula_darah;
  if (gds && gds > 200) {
    faktorRujukan.push(`Gula darah sangat tinggi (${gds} mg/dL)`);
  } else if (gds && gds > 140) {
    faktorTindakan.push(`Gula darah meningkat (${gds} mg/dL)`);
  }

  // 5. Protein urine
  const protein = exam.tes_lab_protein_urine?.toLowerCase() || "";
  if (protein.includes("positif") || protein === "++" || protein === "+++") {
    faktorRujukan.push(`Protein urine positif (${exam.tes_lab_protein_urine})`);
  } else if (protein === "+" || protein.includes("trace")) {
    faktorTindakan.push(`Protein urine trace/+1 (${exam.tes_lab_protein_urine})`);
  }

  // 6. LILA
  const lila = exam.lingkar_lengan_atas;
  if (lila && lila < 23.5) {
    faktorTindakan.push(`LILA kurang dari normal (${lila} cm)`);
  }

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

// ── Opsi grafik (konstan, didefinisikan di luar komponen) ──
const commonOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: {
      position: "bottom",
      labels: { boxWidth: 12, font: { size: 11 } },
    },
  },
  scales: {
    y: { beginAtZero: false, grid: { color: "#f3f4f6" } },
    x: { grid: { display: false } },
  },
};

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

  // ── Pengambilan data ──
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
        setError("Gagal memuat data pemeriksaan kehamilan");
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

  // Pemeriksaan terakhir berdasarkan tanggal
  const latestExam = useMemo(() => {
    if (!hasExaminations) return null;
    return [...examinations].sort(
      (a, b) => new Date(b.tanggal_periksa) - new Date(a.tanggal_periksa)
    )[0];
  }, [examinations, hasExaminations]);

  // Status risiko dari backend (detail_risiko dari grafik)
  const riskFromBackend = grafik?.detail_risiko;

  // Fallback frontend
  const riskFromFrontend = useMemo(
    () => hitungStatusRisiko(latestExam),
    [latestExam]
  );

  // Obyek risiko final
  const risk = useMemo(() => {
    if (!hasExaminations) return null;

    // 1. Prediksi ML dari backend (ada di pemeriksaan terakhir)
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

    // 2. Data dari grafik (backend) bila ada status yang valid
    if (riskFromBackend?.status_risiko && riskFromBackend.status_risiko !== "") {
      return riskFromBackend;
    }

    // 3. Hitung manual di frontend
    return riskFromFrontend;
  }, [hasExaminations, riskFromBackend, riskFromFrontend, latestExam]);

  // ── Helper untuk styling ──
  const getRiskStyles = (status) => {
    const s = status?.toUpperCase() || "";
    if (s === "PERLU RUJUKAN" || s === "TINGGI") return "bg-danger/10 border-danger/30 text-danger";
    if (s === "PERLU TINDAKAN" || s === "SEDANG") return "bg-warning/10 border-warning/30 text-warning";
    return "bg-success/10 border-success/30 text-success";
  };

  // ── Data grafik (memoized) ──
  const chartTFU = useMemo(
    () => ({
      labels: tfu.map((d) => `Mgg ${d.minggu}`),
      datasets: [
        {
          label: "Batas Atas (+2cm)",
          data: tfu.map((d) => d.minggu + 2),
          borderColor: "#10b981",
          borderDash: [5, 5],
          borderWidth: 1,
          pointRadius: 0,
          fill: false,
        },
        {
          label: "Batas Bawah (-2cm)",
          data: tfu.map((d) => d.minggu - 2),
          borderColor: "#10b981",
          borderDash: [5, 5],
          borderWidth: 1,
          pointRadius: 0,
          fill: "-1",
          backgroundColor: "rgba(16,185,129,0.15)",
        },
        {
          label: "TFU Pasien (cm)",
          data: tfu.map((d) => d.value),
          borderColor: "#185FA5",
          backgroundColor: "#185FA5",
          borderWidth: 3,
          pointRadius: 5,
        },
      ],
    }),
    [tfu]
  );

  const chartDJJ = useMemo(
    () => ({
      labels: djj.map((d) => `Mgg ${d.minggu}`),
      datasets: [
        {
          label: "Batas Atas (160)",
          data: djj.map(() => 160),
          borderColor: "#ef4444",
          borderWidth: 1,
          pointRadius: 0,
          fill: false,
        },
        {
          label: "Batas Bawah (120)",
          data: djj.map(() => 120),
          borderColor: "#ef4444",
          borderWidth: 1,
          pointRadius: 0,
          fill: "-1",
          backgroundColor: "rgba(16,185,129,0.15)",
        },
        {
          label: "DJJ Pasien (bpm)",
          data: djj.map((d) => d.value),
          borderColor: "#06b6d4",
          backgroundColor: "#06b6d4",
          borderWidth: 3,
          pointRadius: 5,
        },
      ],
    }),
    [djj]
  );

  const chartTD = useMemo(
    () => ({
      labels: td.map((d) => `Mgg ${d.minggu}`),
      datasets: [
        {
          label: "Batas Waspada Sistole (130)",
          data: td.map(() => 130),
          borderColor: "#ef4444",
          borderDash: [10, 5],
          borderWidth: 2,
          pointRadius: 0,
        },
        {
          label: "Batas Waspada Diastole (80)",
          data: td.map(() => 80),
          borderColor: "#f59e0b",
          borderDash: [10, 5],
          borderWidth: 2,
          pointRadius: 0,
        },
        {
          label: "Sistole Pasien",
          data: td.map((d) => d.sistole),
          borderColor: "#185FA5",
          backgroundColor: "#185FA5",
          borderWidth: 3,
          pointRadius: 4,
        },
        {
          label: "Diastole Pasien",
          data: td.map((d) => d.diastole),
          borderColor: "#06b6d4",
          backgroundColor: "#06b6d4",
          borderWidth: 3,
          pointRadius: 4,
        },
      ],
    }),
    [td]
  );

  const chartBB = useMemo(
    () => ({
      labels: bb.map((d) => `Mgg ${d.minggu}`),
      datasets: [
        {
          label: "Batas Atas PBB",
          data: bb.map((d) => getBatasBB(d.minggu, kategoriIMT).max),
          borderColor: "#ec4899",
          borderDash: [5, 5],
          borderWidth: 1,
          pointRadius: 0,
          fill: false,
        },
        {
          label: "Batas Bawah PBB",
          data: bb.map((d) => getBatasBB(d.minggu, kategoriIMT).min),
          borderColor: "#ec4899",
          borderDash: [5, 5],
          borderWidth: 1,
          pointRadius: 0,
          fill: "-1",
          backgroundColor: "rgba(236,72,153,0.15)",
        },
        {
          label: "Kenaikan BB Pasien (kg)",
          data: bb.map((d) => d.berat),
          borderColor: "#f59e0b",
          backgroundColor: "#f59e0b",
          borderWidth: 3,
          pointRadius: 5,
        },
      ],
    }),
    [bb, kategoriIMT]
  );

  // ── Handler rujukan ──
  const withKehamilan = useCallback(
    (path) => `${path}?kehamilan_id=${kehamilan.id}`,
    [kehamilan]
  );

  const handleRujukClick = useCallback(
    (e) => {
      e.preventDefault();
      Swal.fire({
        title: "Konfirmasi Rujukan",
        text: `Ibu ini memiliki status "${normalizeDisplayStatus(
          risk?.status_risiko
        )}". Lanjutkan ke form rujukan?`,
        icon: "warning",
        showCancelButton: true,
        confirmButtonColor: "#A32D2D",
        cancelButtonColor: "#6b7280",
        confirmButtonText: "Ya, Rujuk",
        cancelButtonText: "Batal",
        reverseButtons: true,
      }).then((result) => {
        if (result.isConfirmed) {
          navigate(withKehamilan(`/data-ibu/${ibuId}/rujukan`));
        }
      });
    },
    [risk, navigate, withKehamilan, ibuId]
  );

  // ── Toggle expanded untuk detail risiko ML ──
  const toggleRiskExpand = useCallback((riskName) => {
    setExpandedRisks((prev) => ({ ...prev, [riskName]: !prev[riskName] }));
  }, []);

  // ── Ikon status ──
  const displayStatus = hasExaminations && risk ? normalizeDisplayStatus(risk.status_risiko) : "NORMAL";
  const StatusIcon =
    displayStatus === "NORMAL" ? CheckCircle : displayStatus === "PERLU TINDAKAN" ? AlertCircle : AlertTriangle;

  // ── Render ──
  if (loading) {
    return (
      <MainLayout>
        <div className="p-10 text-center text-gray-500">Memuat Data...</div>
      </MainLayout>
    );
  }

  if (error) {
    return (
      <MainLayout>
        <div className="p-10 text-center text-danger">{error}</div>
      </MainLayout>
    );
  }

  if (!kehamilan) {
    return (
      <MainLayout>
        <div className="p-10 text-center text-gray-500">Data kehamilan tidak tersedia</div>
      </MainLayout>
    );
  }

  return (
    <MainLayout>
      <div className="min-h-screen bg-background p-6">
        <div className="max-w-6xl mx-auto space-y-6">
          {/* ── Header ── */}
          <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
            <div className="flex-1">
              <div className="flex items-center gap-3 flex-wrap">
                <Link
                  to={`/data-ibu/${ibuId}?kehamilan_id=${kehamilan.id}`}
                  className="inline-flex items-center gap-2 px-5 py-2.5 rounded-full border border-primary text-primary text-sm font-semibold hover:bg-primary/5 transition"
                >
                  <ArrowLeft size={16} />
                  <span>Kembali</span>
                </Link>
                <h1 className="text-[28px] font-bold text-gray-900">Pemantauan Antenatal Care</h1>
              </div>
              <p className="text-gray-500 italic mt-1">
                Berdasarkan Standar Buku KIA & Prediksi Machine Learning
              </p>
            </div>

            <div className="flex gap-3 flex-shrink-0">
              {canEdit && (
                <Link
                  to={withKehamilan(`/data-ibu/${ibuId}/pemeriksaan-rutin/baru`)}
                  className="bg-primary hover:bg-primary/90 text-white px-5 py-2.5 rounded-xl flex items-center gap-2 transition-all shadow-md hover:shadow-lg"
                >
                  <Plus size={20} /> Tambah Pemeriksaan
                </Link>
              )}

              {hasExaminations &&
                normalizeDisplayStatus(risk?.status_risiko) === "PERLU RUJUKAN" &&
                canEdit && (
                  <button
                    onClick={handleRujukClick}
                    className="bg-danger hover:bg-danger/90 text-white px-5 py-2.5 rounded-xl flex items-center gap-2 transition-all shadow-md hover:shadow-lg animate-pulse"
                  >
                    <AlertTriangle size={18} /> Rujuk Segera
                  </button>
                )}
            </div>
          </div>

          {/* ── Mode baca dokter ── */}
          {!canEdit && (
            <div className="bg-secondary/10 border border-secondary/30 text-secondary p-3 rounded-lg text-base flex items-center gap-2">
              <Eye size={16} /> Anda dalam mode baca (Dokter). Data hanya dapat dilihat, tidak dapat diubah.
            </div>
          )}

          {/* ── Banner status risiko ── */}
          {hasExaminations && risk && (
            <div
              className={`border-l-4 p-5 rounded-r-2xl shadow-sm flex gap-4 ${getRiskStyles(risk.status_risiko)}`}
            >
              <StatusIcon className="flex-shrink-0" size={28} />
              <div className="flex-1">
                <h3 className="font-bold text-lg uppercase tracking-wide">
                  Status: {normalizeDisplayStatus(risk.status_risiko)}
                </h3>
                <p className="text-sm leading-relaxed mt-1">{risk.ringkasan}</p>

                {/* Risiko yang terdeteksi (ML) */}
                {risk.is_ml_prediction && risk.risk_types && risk.risk_types.length > 0 && (
                  <div className="mt-3">
                    <p className="text-xs font-semibold opacity-80 mb-3">Risiko yang Terdeteksi:</p>
                    {risk.risk_types.filter((rt) => rt.detected).length > 0 ? (
                      <div className="space-y-2">
                        {risk.risk_types
                          .filter((rt) => rt.detected)
                          .sort((a, b) => b.probability - a.probability)
                          .map((riskType) => (
                            <div
                              key={riskType.name}
                              className="bg-white rounded-lg border border-danger/30 shadow-sm"
                            >
                              <button
                                onClick={() => toggleRiskExpand(riskType.name)}
                                className="w-full p-2 flex items-center justify-between hover:bg-danger/5 transition-colors"
                              >
                                <div className="flex items-center gap-2">
                                  <span className="font-semibold text-xs text-gray-800">
                                    {riskType.name}
                                  </span>
                                  <span className="text-xs px-2 py-0.5 rounded-full bg-danger/10 text-danger font-medium">
                                    {(riskType.probability * 100).toFixed(1)}%
                                  </span>
                                </div>
                                {expandedRisks[riskType.name] ? (
                                  <ChevronUp size={14} />
                                ) : (
                                  <ChevronDown size={14} />
                                )}
                              </button>
                              {expandedRisks[riskType.name] &&
                                riskType.tindakan &&
                                riskType.tindakan.length > 0 && (
                                  <div className="p-2 pt-0 border-t border-danger/20">
                                    <p className="text-xs font-semibold text-gray-700 mb-1 mt-2">
                                      Tindakan yang Disarankan:
                                    </p>
                                    <ul className="text-xs text-gray-600 space-y-0.5">
                                      {riskType.tindakan.map((t, idx) => (
                                        <li key={idx} className="flex items-start gap-2">
                                          <span className="text-danger mt-0.5">•</span>
                                          <span>{t}</span>
                                        </li>
                                      ))}
                                    </ul>
                                  </div>
                                )}
                            </div>
                          ))}
                      </div>
                    ) : (
                      <div className="p-3 rounded-xl border border-success/30 bg-success/10">
                        <p className="text-xs text-success font-medium">
                          ✅ Tidak Ada Risiko yang Terdeteksi
                        </p>
                      </div>
                    )}
                  </div>
                )}

                {/* Alasan klinis (ML) */}
                {risk.is_ml_prediction &&
                  risk.alasan_klinis &&
                  risk.alasan_klinis.length > 0 && (
                    <div className="mt-3">
                      <p className="text-xs font-semibold opacity-80 mb-1">Alasan Klinis:</p>
                      <ul className="text-xs space-y-0.5 list-disc list-inside opacity-80">
                        {risk.alasan_klinis.map((alasan, i) => (
                          <li key={i}>{alasan}</li>
                        ))}
                      </ul>
                    </div>
                  )}

                {/* Faktor risiko fallback (frontend) */}
                {!risk.is_ml_prediction && risk.faktorRujukan?.length > 0 && (
                  <ul className="mt-2 text-xs space-y-0.5 list-disc list-inside opacity-80">
                    {risk.faktorRujukan.map((f, i) => (
                      <li key={i}>{f}</li>
                    ))}
                  </ul>
                )}
                {!risk.is_ml_prediction && risk.faktorTindakan?.length > 0 && (
                  <ul className="mt-2 text-xs space-y-0.5 list-disc list-inside opacity-80">
                    {risk.faktorTindakan.map((f, i) => (
                      <li key={i}>{f}</li>
                    ))}
                  </ul>
                )}

                {/* Sumber data */}
                {latestExam && (
                  <p className="text-xs mt-2 opacity-60">
                    Berdasarkan kunjungan ke-{latestExam.kunjungan_ke} (
                    {new Date(latestExam.tanggal_periksa).toLocaleDateString("id-ID", {
                      day: "numeric",
                      month: "long",
                      year: "numeric",
                    })}
                    )
                  </p>
                )}
              </div>
            </div>
          )}

          {/* ── Kartu ringkasan ── */}
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            <div className="bg-white p-5 rounded-2xl shadow-sm border border-gray-200">
              <div className="flex items-center gap-3 text-primary mb-2">
                <Activity size={18} />
                <span className="text-xs font-semibold uppercase tracking-wider text-gray-500">
                  IMT Awal
                </span>
              </div>
              <p className="text-2xl font-black text-gray-800">
                {grafik?.imt_awal?.toFixed(2) || "-"}
              </p>
              <span className="text-xs font-medium px-2 py-1 bg-primary/10 text-primary rounded-lg">
                {kategoriIMT || "-"}
              </span>
            </div>

            <div className="bg-white p-5 rounded-2xl shadow-sm border border-gray-200">
              <div className="flex items-center gap-3 text-success mb-2">
                <Heart size={18} />
                <span className="text-xs font-semibold uppercase tracking-wider text-gray-500">
                  DJJ Terakhir
                </span>
              </div>
              <p className="text-2xl font-black text-gray-800">
                {djj.at(-1)?.value || latestExam?.denyut_jantung_janin || "-"}
                <span className="text-sm font-normal text-gray-400"> bpm</span>
              </p>
            </div>

            <div className="bg-white p-5 rounded-2xl shadow-sm border border-gray-200">
              <div className="flex items-center gap-3 text-warning mb-2">
                <Scale size={18} />
                <span className="text-xs font-semibold uppercase tracking-wider text-gray-500">
                  Kenaikan BB
                </span>
              </div>
              <p className="text-2xl font-black text-gray-800">
                {bb.length > 0 ? bb.at(-1)?.berat ?? "0" : "-"}
                <span className="text-sm font-normal text-gray-400"> kg</span>
              </p>
            </div>

            <div className="bg-white p-5 rounded-2xl shadow-sm border border-gray-200">
              <div className="flex items-center gap-3 text-secondary mb-2">
                <Droplets size={18} />
                <span className="text-xs font-semibold uppercase tracking-wider text-gray-500">
                  Total Kunjungan
                </span>
              </div>
              <p className="text-2xl font-black text-gray-800">
                {examinations.length}
                <span className="text-sm font-normal text-gray-400"> Kali</span>
              </p>
            </div>
          </div>

          {/* ── Grafik ── */}
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <div className="bg-white p-6 rounded-3xl shadow-sm border border-gray-200">
              <h2 className="font-bold text-gray-800 mb-4 flex items-center gap-2">
                <TrendingUp size={20} className="text-primary" /> Tinggi Fundus (TFU)
              </h2>
              {tfu.length === 0 ? (
                <div className="h-64 flex flex-col items-center justify-center text-gray-400 bg-gray-50 rounded-xl">
                  <FileText size={48} strokeWidth={1.5} />
                  <p className="mt-2 text-sm">Belum ada data TFU</p>
                </div>
              ) : (
                <div className="h-64">
                  <Line data={chartTFU} options={commonOptions} />
                </div>
              )}
            </div>

            <div className="bg-white p-6 rounded-3xl shadow-sm border border-gray-200">
              <h2 className="font-bold text-gray-800 mb-4 flex items-center gap-2">
                <Heart size={20} className="text-danger" /> Detak Jantung Janin
              </h2>
              {djj.length === 0 ? (
                <div className="h-64 flex flex-col items-center justify-center text-gray-400 bg-gray-50 rounded-xl">
                  <FileText size={48} strokeWidth={1.5} />
                  <p className="mt-2 text-sm">Belum ada data DJJ</p>
                </div>
              ) : (
                <div className="h-64">
                  <Line data={chartDJJ} options={commonOptions} />
                </div>
              )}
            </div>

            <div className="bg-white p-6 rounded-3xl shadow-sm border border-gray-200">
              <h2 className="font-bold text-gray-800 mb-4 flex items-center gap-2">
                <Droplets size={20} className="text-danger" /> Tekanan Darah
              </h2>
              {td.length === 0 ? (
                <div className="h-64 flex flex-col items-center justify-center text-gray-400 bg-gray-50 rounded-xl">
                  <FileText size={48} strokeWidth={1.5} />
                  <p className="mt-2 text-sm">Belum ada data tekanan darah</p>
                </div>
              ) : (
                <div className="h-64">
                  <Line data={chartTD} options={commonOptions} />
                </div>
              )}
            </div>

            <div className="bg-white p-6 rounded-3xl shadow-sm border border-gray-200">
              <h2 className="font-bold text-gray-800 mb-4 flex items-center gap-2">
                <Scale size={20} className="text-warning" /> Grafik Berat Badan (PBB)
              </h2>
              {bb.length === 0 ? (
                <div className="h-64 flex flex-col items-center justify-center text-gray-400 bg-gray-50 rounded-xl">
                  <FileText size={48} strokeWidth={1.5} />
                  <p className="mt-2 text-sm">Belum ada data berat badan</p>
                </div>
              ) : (
                <div className="h-64">
                  <Line data={chartBB} options={commonOptions} />
                </div>
              )}
            </div>
          </div>

          {/* ── Riwayat Pemeriksaan ── */}
          <div className="space-y-4">
            <h2 className="text-xl font-bold text-gray-800">Riwayat Pemeriksaan</h2>

            {!hasExaminations ? (
              <div className="bg-white rounded-2xl border border-gray-200 p-12 text-center">
                <FileText size={64} className="mx-auto text-gray-300 mb-4" strokeWidth={1.5} />
                <p className="text-gray-500">Tidak Ada Pemeriksaan yang Tercatat</p>
                {canEdit && (
                  <Link
                    to={withKehamilan(`/data-ibu/${ibuId}/pemeriksaan-rutin/baru`)}
                    className="inline-block mt-4 bg-primary hover:bg-primary/90 text-white px-5 py-2 rounded-xl text-sm transition-all"
                  >
                    + Tambah Pemeriksaan Pertama
                  </Link>
                )}
              </div>
            ) : (
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                {examinations.map((exam) => (
                  <div
                    key={exam.id_periksa}
                    className="group bg-white p-5 rounded-2xl shadow-sm border border-gray-200 hover:border-primary/30 transition-all"
                  >
                    <div className="flex justify-between items-start mb-3">
                      <span className="bg-gray-100 text-gray-600 text-[10px] font-bold px-2 py-1 rounded-md uppercase">
                        Kunjungan {exam.kunjungan_ke}
                      </span>
                      {latestExam?.id_periksa === exam.id_periksa && (
                        <span className="flex items-center gap-1 text-[10px] font-bold bg-success/10 text-success px-2 py-1 rounded-md">
                          <div className="w-1.5 h-1.5 bg-success rounded-full animate-pulse"></div> TERBARU
                        </span>
                      )}
                    </div>
                    <p className="text-gray-500 text-xs mb-1">Tanggal Periksa</p>
                    <p className="font-bold text-gray-800 mb-4">
                      {new Date(exam.tanggal_periksa).toLocaleDateString("id-ID", {
                        day: "numeric",
                        month: "long",
                        year: "numeric",
                      })}
                    </p>
                    <Link
                      to={withKehamilan(`/data-ibu/${ibuId}/pemeriksaan-rutin/${exam.id_periksa}`)}
                      className="w-full block text-center py-2 bg-gray-50 group-hover:bg-primary group-hover:text-white text-primary rounded-xl text-sm font-semibold transition-all"
                    >
                      Detail
                    </Link>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    </MainLayout>
  );
}