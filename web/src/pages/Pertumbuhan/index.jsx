import React, { useState, useEffect } from "react";
import { useParams, Link } from "react-router-dom";
import MainLayout from "../../components/Layout/MainLayout";
import AlertNotification from "../../components/AlertNotification";
import {
  getRiwayatPertumbuhan,
  addCatatanPertumbuhan,
  deleteCatatanPertumbuhan,
  updateCatatanPertumbuhan,
} from "../../services/pertumbuhan";
import { getAnakById } from "../../services/Anak";
import {
  ChevronLeft, ArrowLeft, Plus, Trash2, Calendar, Scale, Ruler,
  Info, Pencil, TrendingUp, Target, Heart,
  AlertTriangle, Check, X, Smile,
} from "lucide-react";
import { GrowthStatusCard, GrowthSummary } from "./components/GrowthStatusCard";
import { GrowthChart } from "./components/GrowthChart";

export default function PertumbuhanIndex() {
  const { id } = useParams();
  const [riwayat, setRiwayat] = useState([]);
  const [anak, setAnak] = useState(null);
  const [loading, setLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isEdit, setIsEdit] = useState(false);
  const [currentId, setCurrentId] = useState(null);
  const [activeChart, setActiveChart] = useState("bb");

  const initialForm = {
    anak_id: parseInt(id),
    tgl_ukur: new Date().toISOString().split("T")[0],
    berat_badan: "",
    tinggi_badan: "",
    lingkar_kepala: "",
    hasil_lila: "",
    catatan_nakes: "",
  };
  const [formData, setFormData] = useState(initialForm);

  const fetchData = async () => {
    try {
      setLoading(true);
      const [resAnak, resRiwayat] = await Promise.all([
        getAnakById(id),
        getRiwayatPertumbuhan(id),
      ]);
      setAnak(resAnak.data || resAnak);
      setRiwayat(resRiwayat.data || []);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, [id]);

  const handleOpenAdd = () => {
    setIsEdit(false);
    setCurrentId(null);
    setFormData(initialForm);
    setIsModalOpen(true);
  };

  const handleEdit = (r) => {
    setIsEdit(true);
    setCurrentId(r.id);
    setFormData({
      anak_id: r.anak_id,
      tgl_ukur: r.tgl_ukur,
      berat_badan: r.berat_badan?.toString() ?? "",
      tinggi_badan: r.tinggi_badan?.toString() ?? "",
      lingkar_kepala: r.lingkar_kepala?.toString() ?? "",
      hasil_lila: r.hasil_lila?.toString() ?? "",
      catatan_nakes: r.catatan_nakes ?? "",
    });
    setIsModalOpen(true);
  };

  const getCurrentTimeWIB = () => {
    const now = new Date();
    const hours = String(now.getHours()).padStart(2, '0');
    const minutes = String(now.getMinutes()).padStart(2, '0');
    return `${hours}:${minutes} WIB`;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (anak?.tanggal_lahir && formData.tgl_ukur) {
      const birthDate = new Date(anak.tanggal_lahir);
      const targetDate = new Date(formData.tgl_ukur);
      let targetAgeBulan = 0;
      if (birthDate <= targetDate) {
        let years = targetDate.getFullYear() - birthDate.getFullYear();
        let months = targetDate.getMonth() - birthDate.getMonth();
        if (months < 0) {
          years--;
          months += 12;
        }
        targetAgeBulan = years * 12 + months;
      }

      const hasReached60 = riwayat.some(r => r.usia_ukur_bulan >= 60 && r.id !== currentId);
      if (hasReached60 && targetAgeBulan < 60) {
        setNotification({
          type: "error",
          message: "Permintaan gagal diproses. Silakan coba lagi nanti atau hubungi bantuan.",
          code: "Kunjungan sudah mencapai usia 60 bulan ke atas. Tidak dapat melakukan pengisian untuk usia di bawah 60 bulan.",
          time: getCurrentTimeWIB()
        });
        return;
      }
    }

    try {
      const payload = {
        ...formData,
        berat_badan: parseFloat(formData.berat_badan),
        tinggi_badan: parseFloat(formData.tinggi_badan),
        lingkar_kepala: parseFloat(formData.lingkar_kepala) || 0,
        hasil_lila: parseFloat(formData.hasil_lila) || 0,
      };
      let res;
      if (isEdit) {
        res = await updateCatatanPertumbuhan(currentId, payload);
      } else {
        res = await addCatatanPertumbuhan(payload);
      }
      setIsModalOpen(false);
      await fetchData();
      if (res?.data?.prediksi?.status_prediksi) {
        setNotification({
          type: "success",
          message: `Data pertumbuhan anak berhasil disimpan!\n\nStatus Prediksi Anak: ${res.data.prediksi.status_prediksi}`,
          time: getCurrentTimeWIB()
        });
      } else {
        setNotification({
          type: "success",
          message: "Data pertumbuhan anak berhasil disimpan ke dalam sistem!",
          time: getCurrentTimeWIB()
        });
      }
    } catch (err) {
      console.error("Save Error:", err);
      const msg = err.response?.data?.message || err.message || "Gagal menyimpan data";
      setNotification({
        type: "error",
        message: "Permintaan gagal diproses. Silakan coba lagi nanti atau hubungi bantuan.",
        code: msg,
        time: getCurrentTimeWIB()
      });
    }
  };

  const handleDelete = async (recId) => {
    if (!window.confirm("Hapus catatan ini?")) return;
    try {
      await deleteCatatanPertumbuhan(recId);
      await fetchData();
      setNotification({
        type: "success",
        message: "Data pertumbuhan anak berhasil dihapus dari sistem!",
        time: getCurrentTimeWIB()
      });
    } catch (err) {
      console.error("Delete Error:", err);
      const msg = err.response?.data?.message || err.message || "Gagal menghapus data";
      setNotification({
        type: "error",
        message: "Permintaan gagal diproses. Silakan coba lagi nanti atau hubungi bantuan.",
        code: msg,
        time: getCurrentTimeWIB()
      });
    }
  };

  // ── Konfigurasi grafik ────────────────────────────────────────────────────
  const chartConfig = {
    bb: { label: "Berat Badan (kg)", color: "#6366f1", unit: "kg" },
    tb: { label: "Tinggi Badan (cm)", color: "#8b5cf6", unit: "cm" },
    lila: { label: "LILA (cm)", color: "#f59e0b", unit: "cm" },
    lk: { label: "Lingkar Kepala (cm)", color: "#10b981", unit: "cm" },
  };

  // Notification state
  const [notification, setNotification] = useState(null);

  // Modified chart data to start from left (oldest first)
  const sortedRiwayat = [...riwayat].sort((a, b) => new Date(a.tgl_ukur) - new Date(b.tgl_ukur));
  const chartData = sortedRiwayat.map((r) => ({
    bulan: `${r.usia_ukur_bulan}bln`,
    bb: r.berat_badan || null,
    tb: r.tinggi_badan || null,
    lila: r.hasil_lila || null,
    lk: r.lingkar_kepala || null,
  }));

  if (loading) return (
    <MainLayout>
      <div className="p-10 text-center font-medium text-gray-400 animate-pulse">Memuat data...</div>
    </MainLayout>
  );

  const lastData = riwayat.length > 0
    ? [...riwayat].sort((a, b) => new Date(b.tgl_ukur) - new Date(a.tgl_ukur))[0]
    : null;
  const lastStatus = deriveStatusFromZScore(lastData);

  return (
    <MainLayout>
      <div className="p-6 bg-[#f8fafc] min-h-screen">
        <div className="max-w-7xl mx-auto space-y-6">
          <AlertNotification
            notification={notification}
            onClose={() => setNotification(null)}
            onRetry={notification?.type === "error" ? () => {
              setNotification(null);
              if (!notification.message.includes("hapus")) {
                setIsModalOpen(true);
              }
            } : null}
          />

          {/* ── HEADER ── */}
          <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
            <div>
              <Link
                to={`/data-anak/dashboard/${id}`}
                className="flex items-center gap-2 px-6 py-2 border border-blue-600 text-blue-600 hover:bg-blue-50 rounded-full font-medium text-sm transition-all group w-fit mb-4 mt-2"
              >
                <ArrowLeft size={16} className="group-hover:-translate-x-1 transition-transform" />
                Kembali
              </Link>
              <h1 className="text-3xl font-extrabold text-gray-900 tracking-tight">Manajemen Pertumbuhan</h1>
              <p className="text-sm font-semibold text-gray-500 mt-1">
                Anak: <span className="text-indigo-600">{anak?.nama}</span>
              </p>
            </div>
            <div className="flex gap-3 flex-wrap">
              <button
                onClick={handleOpenAdd}
                className="bg-blue-600 hover:bg-blue-700 text-white px-5 py-3 rounded-2xl flex items-center gap-2 font-bold shadow-lg shadow-blue-100 transition-all active:scale-95"
              >
                <Plus size={18} strokeWidth={3} /> Input Pengukuran
              </button>
            </div>
          </div>

          {/* ── GRAFIK + PANEL KANAN ── */}
          <div className="grid grid-cols-1 xl:grid-cols-3 gap-6">

            {/* Grafik */}
            <div className="xl:col-span-2 bg-white rounded-3xl border border-gray-100 shadow-sm p-6 space-y-4">
              <div className="flex items-center justify-between flex-wrap gap-3 mb-4">
                <h3 className="text-base font-extrabold text-gray-900 flex items-center gap-2">
                  <TrendingUp size={18} className="text-indigo-500" /> Grafik Pertumbuhan
                </h3>
                <div className="flex gap-1.5 flex-wrap">
                  {Object.entries(chartConfig).map(([key, cfg]) => (
                    <button
                      key={key}
                      onClick={() => setActiveChart(key)}
                      className={`px-3 py-1.5 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all ${activeChart === key ? "text-white shadow-sm" : "bg-gray-100 text-gray-400 hover:bg-gray-200"
                        }`}
                      style={activeChart === key ? { backgroundColor: cfg.color } : {}}
                    >
                      {key.toUpperCase()}
                    </button>
                  ))}
                </div>
              </div>

              <GrowthChart
                data={chartData}
                activeChart={activeChart}
                chartConfig={chartConfig}
                onChartChange={setActiveChart}
              />
            </div>

            {/* Panel kanan - Ringkasan & Status */}
            <div className="space-y-4">
              {/* Ringkasan Status */}
              <GrowthSummary
                lastStatus={lastStatus}
                lastData={lastData}
                anak={anak}
              />

              {/* Pengukuran Terakhir */}
              <div className="bg-white p-5 rounded-3xl border border-gray-100 shadow-sm">
                <p className="text-xs font-black text-gray-600 uppercase tracking-widest mb-4 flex items-center gap-2">
                  <Scale size={14} className="text-indigo-500" /> Pengukuran Terakhir
                </p>
                <div className="grid grid-cols-2 gap-3">
                  <MiniStat label="BB" value={lastData?.berat_badan ?? "-"} unit="kg" color="indigo" />
                  <MiniStat label="TB" value={lastData?.tinggi_badan ?? "-"} unit="cm" color="purple" />
                  <MiniStat label="LILA" value={lastData?.hasil_lila || "-"} unit="cm" color="amber" />
                  <MiniStat label="LK" value={lastData?.lingkar_kepala || "-"} unit="cm" color="emerald" />
                </div>
              </div>
            </div>
          </div>

          {/* ── DETAIL STATUS GIZI LENGKAP ── */}
          {lastData && (
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              <GrowthStatusCard
                status={lastStatus.statusBBU}
                label="Berat Badan / Usia (BB/U)"
                zScore={lastData.z_score_bb_u || lastData.zScoreBBU}
                description="Menunjukkan pertumbuhan berat badan anak sesuai usia"
              />
              <GrowthStatusCard
                status={lastStatus.statusTBU}
                label="Tinggi Badan / Usia (TB/U)"
                zScore={lastData.z_score_tb_u || lastData.zScoreTBU}
                description="Menunjukkan pertumbuhan tinggi badan anak sesuai usia"
              />
              <GrowthStatusCard
                status={lastStatus.statusBBTB}
                label="BeratBadan / TinggiBadan (BB/TB)"
                zScore={lastData.z_score_bb_tb || lastData.zScoreBBTB}
                description="Menunjukkan proporsi pertumbuhan berat badan terhadap tinggi badan"
              />
            </div>
          )}

          {/* ── TABEL RIWAYAT ── */}
          <div className="bg-white rounded-3xl border border-gray-100 shadow-sm overflow-hidden">
            <div className="px-6 py-4 border-b border-gray-50">
              <h3 className="text-base font-extrabold text-gray-900">Riwayat Pengukuran</h3>
            </div>
            <div className="overflow-x-auto">
              <table className="w-full text-left border-collapse">
                <thead>
                  <tr className="bg-gray-50/50 text-gray-400 text-[11px] font-bold uppercase tracking-widest border-b border-gray-100">
                    <th className="px-5 py-4">Usia</th>
                    <th className="px-5 py-4">Tanggal</th>
                    <th className="px-5 py-4 text-center">BB (kg)</th>
                    <th className="px-5 py-4 text-center">TB (cm)</th>
                    <th className="px-5 py-4 text-center">LILA (cm)</th>
                    <th className="px-5 py-4 text-center">LK (cm)</th>
                    <th className="px-5 py-4">Status Gizi</th>
                    <th className="px-5 py-4 text-right">Aksi</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-50">
                  {riwayat.length > 0 ? riwayat.map((r) => (
                    <tr key={r.id} className="hover:bg-indigo-50/30 transition-colors">
                      <td className="px-5 py-4">
                        <span className="text-sm font-bold text-gray-900">{r.usia_ukur_bulan}</span>
                        <span className="text-[10px] text-gray-400 ml-1 font-bold uppercase">Bln</span>
                      </td>
                      <td className="px-5 py-4">
                        <div className="flex items-center gap-1.5 text-gray-500">
                          <Calendar size={11} className="text-gray-300" />
                          <span className="text-xs font-semibold">{r.tgl_ukur}</span>
                        </div>
                      </td>
                      <td className="px-5 py-4 text-center">
                        <span className="inline-block px-2.5 py-1 bg-indigo-50 text-indigo-700 rounded-lg text-xs font-bold">{r.berat_badan}</span>
                      </td>
                      <td className="px-5 py-4 text-center">
                        <span className="inline-block px-2.5 py-1 bg-purple-50 text-purple-700 rounded-lg text-xs font-bold">{r.tinggi_badan}</span>
                      </td>
                      <td className="px-5 py-4 text-center">
                        <span className="inline-block px-2.5 py-1 bg-amber-50 text-amber-700 rounded-lg text-xs font-bold">{r.hasil_lila || "-"}</span>
                      </td>
                      <td className="px-5 py-4 text-center">
                        <span className="inline-block px-2.5 py-1 bg-emerald-50 text-emerald-700 rounded-lg text-xs font-bold">{r.lingkar_kepala || "-"}</span>
                      </td>
                      <td className="px-5 py-4">
                        {(() => {
                          const rowStatus = deriveStatusFromZScore(r);
                          return (
                            <div className="flex flex-col gap-1">
                              <div className="flex items-center gap-1.5">
                                <span className="text-[9px] font-black text-gray-400 w-8">BB/U:</span>
                                <StatusBadge status={rowStatus.statusBBU} />
                              </div>
                              <div className="flex items-center gap-1.5">
                                <span className="text-[9px] font-black text-gray-400 w-8">TB/U:</span>
                                <StatusBadge status={rowStatus.statusTBU} />
                              </div>
                              <div className="flex items-center gap-1.5">
                                <span className="text-[9px] font-black text-gray-400 w-8">BB/TB:</span>
                                <StatusBadge status={rowStatus.statusBBTB} />
                              </div>
                            </div>
                          );
                        })()}
                      </td>
                      <td className="px-5 py-4">
                        <div className="flex items-center justify-end gap-1.5">
                          <button onClick={() => handleEdit(r)} className="p-2 text-gray-400 hover:text-indigo-600 hover:bg-indigo-50 rounded-xl transition-all" title="Edit">
                            <Pencil size={16} />
                          </button>
                          <button onClick={() => handleDelete(r.id)} className="p-2 text-gray-400 hover:text-red-600 hover:bg-red-50 rounded-xl transition-all" title="Hapus">
                            <Trash2 size={16} />
                          </button>
                        </div>
                      </td>
                    </tr>
                  )) : (
                    <tr>
                      <td colSpan="8" className="px-6 py-20 text-center text-gray-400 font-medium italic">
                        Belum ada riwayat pengukuran
                      </td>
                    </tr>
                  )}
                </tbody>
              </table>
            </div>
          </div>

        </div>
      </div>

      {/* ── MODAL INPUT / EDIT ── */}
      {isModalOpen && (
        <div className="fixed inset-0 z-[100] flex items-center justify-center p-4">
          <div className="absolute inset-0 bg-blue-900/40 backdrop-blur-sm" onClick={() => setIsModalOpen(false)} />
          <div className="relative bg-white w-full max-w-md rounded-[32px] p-8 shadow-2xl border border-white overflow-y-auto max-h-[90vh]">
            <div className="mb-6">
              <div className="flex justify-between items-center">
                <h2 className="text-2xl font-black text-gray-900">{isEdit ? "Update Pengukuran" : "Input Pengukuran"}</h2>
                <div className={`px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-widest ${isEdit ? "bg-orange-100 text-orange-600" : "bg-green-100 text-green-600"}`}>
                  {isEdit ? "Mode Edit" : "Data Baru"}
                </div>
              </div>
              {anak && formData.tgl_ukur && (
                <div className="mt-3 p-4 bg-indigo-50/50 rounded-2xl border border-indigo-100 flex flex-col gap-1">
                  <p className="text-xs font-bold text-slate-700">
                    Nama Anak: <span className="text-indigo-600">{anak.nama}</span>
                  </p>
                  <p className="text-xs font-bold text-slate-700">
                    Usia Saat Pengukuran: <span className="text-blue-600">{(() => {
                      const birth = new Date(anak.tanggal_lahir);
                      const target = new Date(formData.tgl_ukur);
                      let years = target.getFullYear() - birth.getFullYear();
                      let months = target.getMonth() - birth.getMonth();
                      if (target.getDate() < birth.getDate()) {
                        months--;
                      }
                      const ageMonths = years * 12 + months;
                      return ageMonths < 0 ? "0 Bulan (Belum Lahir)" : `${ageMonths} Bulan`;
                    })()}</span>
                  </p>
                </div>
              )}
            </div>

            <form onSubmit={handleSubmit} className="space-y-4">
              {/* Tanggal */}
              <div>
                <label className="block text-[11px] font-black text-gray-400 uppercase tracking-widest mb-2 ml-1">Tanggal Ukur</label>
                <div className="relative">
                  <Calendar size={16} className="absolute left-3.5 top-3.5 text-gray-400" />
                  <input type="date" required
                    className="w-full bg-gray-50 border-none rounded-2xl py-3.5 pl-11 pr-4 font-bold text-gray-800 focus:ring-2 focus:ring-indigo-500 outline-none"
                    value={formData.tgl_ukur}
                    max={new Date().toISOString().split("T")[0]}
                    onChange={(e) => setFormData({ ...formData, tgl_ukur: e.target.value })}
                  />
                </div>
              </div>

              {/* BB & TB */}
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-[11px] font-black text-gray-400 uppercase tracking-widest mb-2 ml-1">Berat (kg) *</label>
                  <div className="relative">
                    <Scale size={15} className="absolute left-3.5 top-3.5 text-gray-400" />
                    <input type="number" step="0.01" placeholder="0.0" required
                      className="w-full bg-gray-50 border-none rounded-2xl py-3.5 pl-10 pr-3 font-bold text-gray-800 focus:ring-2 focus:ring-indigo-500 outline-none"
                      value={formData.berat_badan}
                      onChange={(e) => setFormData({ ...formData, berat_badan: e.target.value })}
                    />
                  </div>
                </div>
                <div>
                  <label className="block text-[11px] font-black text-gray-400 uppercase tracking-widest mb-2 ml-1">Tinggi (cm) *</label>
                  <div className="relative">
                    <Ruler size={15} className="absolute left-3.5 top-3.5 text-gray-400" />
                    <input type="number" step="0.1" placeholder="0.0" required
                      className="w-full bg-gray-50 border-none rounded-2xl py-3.5 pl-10 pr-3 font-bold text-gray-800 focus:ring-2 focus:ring-indigo-500 outline-none"
                      value={formData.tinggi_badan}
                      onChange={(e) => setFormData({ ...formData, tinggi_badan: e.target.value })}
                    />
                  </div>
                </div>
              </div>

              {/* LILA & LK */}
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-[11px] font-black text-gray-400 uppercase tracking-widest mb-2 ml-1">LILA (cm) *</label>
                  <input type="number" step="0.1" placeholder="0.0" required
                    className="w-full bg-gray-50 border-none rounded-2xl py-3.5 px-4 font-bold text-gray-800 focus:ring-2 focus:ring-amber-400 outline-none"
                    value={formData.hasil_lila}
                    onChange={(e) => setFormData({ ...formData, hasil_lila: e.target.value })}
                  />
                </div>
                <div>
                  <label className="block text-[11px] font-black text-gray-400 uppercase tracking-widest mb-2 ml-1">Lingkar Kepala (cm) *</label>
                  <input type="number" step="0.1" placeholder="0.0" required
                    className="w-full bg-gray-50 border-none rounded-2xl py-3.5 px-4 font-bold text-gray-800 focus:ring-2 focus:ring-emerald-400 outline-none"
                    value={formData.lingkar_kepala}
                    onChange={(e) => setFormData({ ...formData, lingkar_kepala: e.target.value })}
                  />
                </div>
              </div>

              {/* Catatan */}
              <div>
                <label className="block text-[11px] font-black text-gray-400 uppercase tracking-widest mb-2 ml-1">Catatan</label>
                <textarea rows={2} placeholder="Catatan tambahan..."
                  className="w-full bg-gray-50 border-none rounded-2xl py-3.5 px-4 font-bold text-gray-800 focus:ring-2 focus:ring-indigo-500 outline-none"
                  value={formData.catatan_nakes}
                  onChange={(e) => setFormData({ ...formData, catatan_nakes: e.target.value })}
                />
              </div>

              <div className="flex gap-3 pt-2">
                <button type="button" onClick={() => setIsModalOpen(false)}
                  className="flex-1 py-4 rounded-2xl font-black text-gray-400 hover:bg-gray-100 transition-all">
                  Batal
                </button>
                <button type="submit"
                  className={`flex-[2] py-4 rounded-2xl font-black text-white shadow-lg transition-all active:scale-95 ${isEdit ? "bg-orange-500 hover:bg-orange-600" : "bg-blue-600 hover:bg-blue-700"}`}>
                  {isEdit ? "Simpan Perubahan" : "Simpan Data"}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </MainLayout>
  );
}

// ── Helper Components ─────────────────────────────────────────────────────

function parseZScore(value) {
  if (value === null || value === undefined || value === "") return null;
  const raw = typeof value === "string" ? value.replace(",", ".") : value;
  const parsed = Number(raw);
  // Number.isFinite memastikan NaN dan Infinity tidak lolos
  // Nilai 0 adalah z-score valid (tepat di median), jangan dianggap null
  return Number.isFinite(parsed) ? parsed : null;
}

function firstValidZScore(candidates) {
  for (const candidate of candidates) {
    const parsed = parseZScore(candidate);
    if (parsed !== null) return parsed;
  }
  return null;
}


function labelFromZScoreBBU(z) {
  if (z === null) return null;
  if (z < -3) return "Berat Badan Sangat Kurang";
  if (z < -2) return "Berat Badan Kurang";
  if (z <= 1) return "Normal";
  if (z <= 2) return "Risiko Berat Badan Lebih";
  return "Berat Badan Lebih";
}

function labelFromZScoreTBU(z) {
  if (z === null) return null;
  if (z < -3) return "Sangat Pendek";
  if (z < -2) return "Pendek";
  if (z <= 3) return "Normal";
  return "Tinggi";
}

function labelFromZScoreBBTB(z) {
  if (z === null) return null;
  if (z < -3) return "Gizi Buruk";
  if (z < -2) return "Gizi Kurang";
  if (z <= 1) return "Gizi Baik";
  if (z <= 2) return "Berisiko Gizi Lebih";
  if (z <= 3) return "Gizi Lebih";
  return "Obesitas";
}

// Normalisasi teks status dari backend agar cocok dengan deteksi warna StatusBadge
function normalizeBackendStatus(value) {
  if (!value) return null;
  const text = String(value).trim();
  if (!text || text.toLowerCase() === "data standar tidak tersedia") return null;

  // BB/U
  if (text.includes("Severely Underweight") || text.includes("Sangat Kurang")) return "Berat Badan Sangat Kurang";
  if (text.includes("Underweight") && !text.includes("Severely")) return "Berat Badan Kurang";
  if (text.includes("Berat Badan Normal")) return "Normal";
  if (text.includes("Risiko Berat Badan Lebih")) return "Risiko Berat Badan Lebih";

  // TB/U
  if (text.includes("Severely Stunted") || text === "Sangat Pendek (Severely Stunted)") return "Sangat Pendek";
  if (text.includes("Stunted") || text === "Pendek (Stunted)") return "Pendek";

  // BB/TB & IMT/U
  if (text.includes("Severely Wasted") || text === "Gizi Buruk (Severely Wasted)") return "Gizi Buruk";
  if (text.includes("Wasted") || text === "Gizi Kurang (Wasted)") return "Gizi Kurang";
  if (text === "Gizi Baik (Normal)" || text.includes("Gizi Baik")) return "Gizi Baik";
  if (text.includes("Possible Risk") || text.includes("Berisiko Gizi Lebih")) return "Berisiko Gizi Lebih";
  if (text === "Gizi Lebih (Overweight)" || text === "Gizi Lebih") return "Gizi Lebih";

  return text;
}

function deriveStatusFromZScore(row) {
  const zBBU = firstValidZScore([
    row?.z_score_bb_u,
    row?.zScoreBBU,
    row?.zscore_bb_u,
    row?.z_score?.bb_u,
  ]);

  const zTBU = firstValidZScore([
    row?.z_score_tb_u,
    row?.zScoreTBU,
    row?.zscore_tb_u,
    row?.z_score?.tb_u,
  ]);

  const zBBTB = firstValidZScore([
    row?.z_score_bb_tb,
    row?.zScoreBBTB,
    row?.zscore_bb_tb,
    row?.z_score?.bb_tb,
  ]);

  // Prioritas: status teks dari backend (sudah dihitung dengan standar WHO)
  const fallbackBBU = normalizeBackendStatus(row?.status_bb_u) || normalizeBackendStatus(row?.statusBBU);
  const fallbackTBU = normalizeBackendStatus(row?.status_tb_u) || normalizeBackendStatus(row?.statusTBU);
  const fallbackBBTB = normalizeBackendStatus(row?.status_bb_tb) || normalizeBackendStatus(row?.statusBBTB);

  return {
    // Gunakan status dari backend jika ada, fallback ke perhitungan z-score lokal
    statusBBU: fallbackBBU || labelFromZScoreBBU(zBBU) || "Belum dihitung",
    statusTBU: fallbackTBU || labelFromZScoreTBU(zTBU) || "Belum dihitung",
    statusBBTB: fallbackBBTB || labelFromZScoreBBTB(zBBTB) || "Belum dihitung",
  };
}

function StatusBadge({ status }) {
  if (!status || status === "Data Standar Tidak Tersedia") {
    return <span className="px-2 py-0.5 rounded-lg text-[9px] font-black uppercase tracking-tight bg-gray-100 text-gray-400">-</span>;
  }
  const s = status.toLowerCase();
  const isNormal = s.includes("normal") || s.includes("baik") || s === "tinggi";
  const isWarning = s.includes("kurang") || s.includes("pendek") || s.includes("risiko") || s.includes("berisiko");
  const isCritical = s.includes("buruk") || s.includes("sangat") || s.includes("stunting") || s.includes("obesitas") || s.includes("lebih");
  let cls = "bg-blue-100 text-blue-700";
  if (isNormal) cls = "bg-green-100 text-green-700";
  else if (isCritical) cls = "bg-red-100 text-red-700";
  else if (isWarning) cls = "bg-orange-100 text-orange-700";
  return <span className={`px-2 py-0.5 rounded-lg text-[9px] font-black uppercase tracking-tight ${cls}`}>{status}</span>;
}

function MiniStat({ label, value, unit, color = 'indigo' }) {
  const colorMap = {
    indigo: 'bg-indigo-50 text-indigo-700',
    purple: 'bg-purple-50 text-purple-700',
    amber: 'bg-amber-50 text-amber-700',
    emerald: 'bg-emerald-50 text-emerald-700',
  };

  return (
    <div className={`${colorMap[color]} rounded-xl p-3 text-center`}>
      <p className="text-[9px] font-black uppercase tracking-widest opacity-70">{label}</p>
      <p className="text-lg font-black">
        {value} <span className="text-[10px] opacity-60">{unit}</span>
      </p>
    </div>
  );
}
