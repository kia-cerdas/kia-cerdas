import React, { useState, useEffect } from "react";
import { useParams, Link } from "react-router-dom";
import MainLayout from "../../components/Layout/MainLayout";
import { getAnakById } from "../../services/Anak";
import {
  getMeasurementData,
  prediksiStunting,
  getRiwayatPrediksi,
} from "../../services/pertumbuhan";
import {
  ChevronLeft, Brain, CheckCircle, AlertTriangle, XCircle,
  RefreshCw, Activity, Ruler, Weight, Circle,
} from "lucide-react";

const today = new Date().toISOString().split("T")[0];

function StatusBadge({ status }) {
  if (!status) return <span className="text-gray-400 text-xs">-</span>;
  if (status === "Normal")
    return (
      <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold bg-emerald-100 text-emerald-700 border border-emerald-200">
        🟢 Normal
      </span>
    );
  if (status === "Risiko Stunting")
    return (
      <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold bg-amber-100 text-amber-700 border border-amber-200">
        🟡 Risiko Stunting
      </span>
    );
  return (
    <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold bg-red-100 text-red-700 border border-red-200">
      🔴 Stunting
    </span>
  );
}

function ResultCard({ status }) {
  if (!status) return null;

  const config = {
    Normal: {
      bg: "from-emerald-50 to-emerald-100/50",
      border: "border-emerald-200",
      icon: <CheckCircle size={56} className="text-emerald-500" />,
      label: "Normal",
      desc: "Tumbuh kembang anak berada dalam kondisi baik.",
      badge: "bg-emerald-500",
    },
    "Risiko Stunting": {
      bg: "from-amber-50 to-amber-100/50",
      border: "border-amber-200",
      icon: <AlertTriangle size={56} className="text-amber-500" />,
      label: "Risiko Stunting",
      desc: "Anak berisiko mengalami stunting. Segera lakukan intervensi gizi.",
      badge: "bg-amber-500",
    },
    Stunting: {
      bg: "from-red-50 to-red-100/50",
      border: "border-red-200",
      icon: <XCircle size={56} className="text-red-500" />,
      label: "Stunting",
      desc: "Anak terdeteksi stunting. Diperlukan penanganan segera.",
      badge: "bg-red-500",
    },
  };

  const c = config[status] || config["Normal"];

  return (
    <div className={`bg-gradient-to-br ${c.bg} border ${c.border} rounded-2xl p-6 flex flex-col items-center gap-3 text-center`}>
      {c.icon}
      <h3 className="text-xl font-black text-gray-800">Hasil Prediksi</h3>
      <span className={`px-4 py-2 rounded-full text-white font-bold text-base ${c.badge}`}>
        {c.label === "Normal" ? "🟢" : c.label === "Risiko Stunting" ? "🟡" : "🔴"} {c.label}
      </span>
      <p className="text-sm text-gray-600 max-w-xs">{c.desc}</p>
    </div>
  );
}

export default function PrediksiStunting() {
  const { id } = useParams();
  const [child, setChild] = useState(null);
  const [form, setForm] = useState({
    berat_badan: "",
    tinggi_badan: "",
    hasil_lila: "",
    lingkar_kepala: "",
    usia_ukur_bulan: "",
    jenis_kelamin: "",
    tanggal_prediksi: today,
  });
  const [result, setResult] = useState(null);
  const [history, setHistory] = useState([]);
  const [loading, setLoading] = useState(false);
  const [fetchingData, setFetchingData] = useState(true);
  const [errors, setErrors] = useState({});
  const [submitError, setSubmitError] = useState("");

  useEffect(() => {
    const load = async () => {
      setFetchingData(true);
      try {
        const [resAnak, resMeasure] = await Promise.all([
          getAnakById(id),
          getMeasurementData(id),
        ]);
        const anak = resAnak.data || resAnak;
        setChild(anak);

        // Pre-fill dari data pengukuran terbaru
        if (resMeasure) {
          setForm((f) => ({
            ...f,
            berat_badan: resMeasure.berat_badan ? String(resMeasure.berat_badan) : "",
            tinggi_badan: resMeasure.tinggi_badan ? String(resMeasure.tinggi_badan) : "",
            hasil_lila: resMeasure.hasil_lila ? String(resMeasure.hasil_lila) : "",
            lingkar_kepala: resMeasure.lingkar_kepala ? String(resMeasure.lingkar_kepala) : "",
            usia_ukur_bulan: resMeasure.usia_ukur_bulan ? String(resMeasure.usia_ukur_bulan) : "",
            jenis_kelamin: anak?.jenis_kelamin || "",
          }));
        } else {
          setForm((f) => ({
            ...f,
            jenis_kelamin: anak?.jenis_kelamin || "",
          }));
        }

        // Muat riwayat prediksi
        try {
          const resHist = await getRiwayatPrediksi(id);
          setHistory(resHist.data || resHist || []);
        } catch {
          setHistory([]);
        }
      } catch (e) {
        console.error("Load failed:", e);
      } finally {
        setFetchingData(false);
      }
    };
    load();
  }, [id]);

  const validate = () => {
    const errs = {};
    const fields = ["berat_badan", "tinggi_badan", "hasil_lila", "lingkar_kepala"];
    fields.forEach((f) => {
      const v = parseFloat(form[f]);
      if (!form[f] || isNaN(v) || v <= 0) {
        errs[f] = "Nilai harus lebih dari 0";
      }
    });
    if (!form.tanggal_prediksi) errs.tanggal_prediksi = "Wajib diisi";
    if (form.tanggal_prediksi > today) errs.tanggal_prediksi = "Tanggal tidak boleh melebihi hari ini";
    return errs;
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setForm((f) => ({ ...f, [name]: value }));
    setErrors((e) => ({ ...e, [name]: undefined }));
    setSubmitError("");
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    const errs = validate();
    if (Object.keys(errs).length > 0) {
      setErrors(errs);
      return;
    }
    setLoading(true);
    setResult(null);
    setSubmitError("");
    try {
      const payload = {
        anak_id: parseInt(id),
        berat_badan: parseFloat(form.berat_badan),
        tinggi_badan: parseFloat(form.tinggi_badan),
        hasil_lila: parseFloat(form.hasil_lila),
        lingkar_kepala: parseFloat(form.lingkar_kepala),
        usia_ukur_bulan: parseInt(form.usia_ukur_bulan) || 0,
        jenis_kelamin: form.jenis_kelamin || "Laki-laki",
      };
      const res = await prediksiStunting(payload);
      const status = res.status_prediksi || res.data?.status_prediksi;
      setResult(status);

      // Refresh riwayat
      try {
        const resHist = await getRiwayatPrediksi(id);
        setHistory(resHist.data || resHist || []);
      } catch { /* ignore */ }
    } catch (err) {
      setSubmitError(err?.response?.data?.error || err.message || "Terjadi kesalahan. Coba lagi.");
    } finally {
      setLoading(false);
    }
  };

  const formatDate = (s) => {
    if (!s) return "-";
    return new Date(s).toLocaleDateString("id-ID", { day: "numeric", month: "long", year: "numeric" });
  };

  if (fetchingData) {
    return (
      <MainLayout>
        <div className="flex items-center justify-center min-h-[50vh]">
          <RefreshCw size={32} className="animate-spin text-blue-600" />
        </div>
      </MainLayout>
    );
  }

  return (
    <MainLayout>
      <div className="p-4 md:p-8 bg-[#f8fafc] min-h-screen max-w-4xl mx-auto">

        {/* Header */}
        <div className="mb-6">
          <Link
            to={`/data-anak/dashboard/${id}`}
            className="inline-flex items-center gap-1.5 text-xs text-gray-400 hover:text-blue-600 mb-2 transition-all"
          >
            <ChevronLeft size={14} /> Kembali ke Dashboard
          </Link>
          <div className="flex items-center gap-3">
            <div className="p-2.5 rounded-xl bg-violet-100">
              <Brain size={24} className="text-violet-600" />
            </div>
            <div>
              <h1 className="text-2xl font-bold text-gray-800">Prediksi Stunting</h1>
              <p className="text-sm text-gray-500">{child?.nama || "—"}</p>
            </div>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* Form */}
          <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6">
            <h2 className="font-bold text-gray-700 mb-4 text-sm uppercase tracking-wide">Input Data Pengukuran</h2>
            <form onSubmit={handleSubmit} className="space-y-4">

              {/* Tanggal */}
              <div>
                <label className="block text-xs font-bold text-gray-600 mb-1">Tanggal Prediksi</label>
                <input
                  type="date"
                  name="tanggal_prediksi"
                  value={form.tanggal_prediksi}
                  max={today}
                  onChange={handleChange}
                  className={`w-full border rounded-xl px-3 py-2.5 text-sm focus:ring-2 focus:ring-violet-500 outline-none transition ${errors.tanggal_prediksi ? "border-red-400 bg-red-50" : "border-gray-200"}`}
                />
                {errors.tanggal_prediksi && <p className="text-red-500 text-xs mt-1">{errors.tanggal_prediksi}</p>}
              </div>

              {/* BB */}
              <div>
                <label className="block text-xs font-bold text-gray-600 mb-1 flex items-center gap-1.5">
                  <Weight size={12} /> Berat Badan (kg)
                </label>
                <input
                  type="number"
                  step="0.1"
                  min="0.1"
                  name="berat_badan"
                  value={form.berat_badan}
                  onChange={handleChange}
                  placeholder="Contoh: 10.5"
                  className={`w-full border rounded-xl px-3 py-2.5 text-sm focus:ring-2 focus:ring-violet-500 outline-none transition ${errors.berat_badan ? "border-red-400 bg-red-50" : "border-gray-200"}`}
                />
                {errors.berat_badan && <p className="text-red-500 text-xs mt-1">{errors.berat_badan}</p>}
              </div>

              {/* TB */}
              <div>
                <label className="block text-xs font-bold text-gray-600 mb-1 flex items-center gap-1.5">
                  <Ruler size={12} /> Tinggi Badan (cm)
                </label>
                <input
                  type="number"
                  step="0.1"
                  min="0.1"
                  name="tinggi_badan"
                  value={form.tinggi_badan}
                  onChange={handleChange}
                  placeholder="Contoh: 80.0"
                  className={`w-full border rounded-xl px-3 py-2.5 text-sm focus:ring-2 focus:ring-violet-500 outline-none transition ${errors.tinggi_badan ? "border-red-400 bg-red-50" : "border-gray-200"}`}
                />
                {errors.tinggi_badan && <p className="text-red-500 text-xs mt-1">{errors.tinggi_badan}</p>}
              </div>

              {/* LILA */}
              <div>
                <label className="block text-xs font-bold text-gray-600 mb-1 flex items-center gap-1.5">
                  <Activity size={12} /> LILA — Lingkar Lengan Atas (cm)
                </label>
                <input
                  type="number"
                  step="0.1"
                  min="0.1"
                  name="hasil_lila"
                  value={form.hasil_lila}
                  onChange={handleChange}
                  placeholder="Contoh: 13.5"
                  className={`w-full border rounded-xl px-3 py-2.5 text-sm focus:ring-2 focus:ring-violet-500 outline-none transition ${errors.hasil_lila ? "border-red-400 bg-red-50" : "border-gray-200"}`}
                />
                {errors.hasil_lila && <p className="text-red-500 text-xs mt-1">{errors.hasil_lila}</p>}
              </div>

              {/* LK */}
              <div>
                <label className="block text-xs font-bold text-gray-600 mb-1 flex items-center gap-1.5">
                  <Circle size={12} /> Lingkar Kepala (cm)
                </label>
                <input
                  type="number"
                  step="0.1"
                  min="0.1"
                  name="lingkar_kepala"
                  value={form.lingkar_kepala}
                  onChange={handleChange}
                  placeholder="Contoh: 46.0"
                  className={`w-full border rounded-xl px-3 py-2.5 text-sm focus:ring-2 focus:ring-violet-500 outline-none transition ${errors.lingkar_kepala ? "border-red-400 bg-red-50" : "border-gray-200"}`}
                />
                {errors.lingkar_kepala && <p className="text-red-500 text-xs mt-1">{errors.lingkar_kepala}</p>}
              </div>

              {submitError && (
                <div className="bg-red-50 border border-red-200 rounded-xl px-4 py-3 text-red-700 text-sm">
                  {submitError}
                </div>
              )}

              <button
                type="submit"
                disabled={loading}
                className="w-full bg-violet-600 hover:bg-violet-700 disabled:opacity-60 text-white font-bold py-3 rounded-xl transition-all active:scale-95 flex items-center justify-center gap-2"
              >
                {loading ? <RefreshCw size={16} className="animate-spin" /> : <Brain size={16} />}
                {loading ? "Memprediksi..." : "Prediksi Sekarang"}
              </button>
            </form>
          </div>

          {/* Result */}
          <div className="flex flex-col gap-4">
            {result ? (
              <ResultCard status={result} />
            ) : (
              <div className="bg-white rounded-2xl border border-dashed border-gray-200 p-8 flex flex-col items-center justify-center gap-3 text-center min-h-[240px]">
                <Brain size={40} className="text-gray-200" />
                <p className="text-gray-400 font-medium text-sm">Hasil prediksi akan tampil di sini</p>
                <p className="text-gray-300 text-xs">Isi form dan klik "Prediksi Sekarang"</p>
              </div>
            )}

            {/* Riwayat Prediksi */}
            <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-5">
              <h3 className="font-bold text-gray-700 text-sm uppercase tracking-wide mb-3">Riwayat Prediksi</h3>
              {history.length === 0 ? (
                <p className="text-gray-400 text-xs text-center py-4">Belum ada riwayat prediksi.</p>
              ) : (
                <div className="space-y-2 max-h-64 overflow-y-auto pr-1">
                  {[...history].reverse().map((h, i) => (
                    <div
                      key={h.id || i}
                      className="flex items-center justify-between gap-2 p-3 rounded-xl bg-gray-50 border border-gray-100"
                    >
                      <div>
                        <p className="text-xs font-semibold text-gray-700">{formatDate(h.created_at || h.tanggal)}</p>
                        <p className="text-[10px] text-gray-400">
                          BB: {h.berat_badan}kg · TB: {h.tinggi_badan}cm
                        </p>
                      </div>
                      <StatusBadge status={h.status_prediksi} />
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </MainLayout>
  );
}
