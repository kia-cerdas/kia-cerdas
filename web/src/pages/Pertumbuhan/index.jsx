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
  ArrowLeft, Plus, Trash2,
  Pencil, TrendingUp,
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
      <div className="p-4 md:p-8 bg-[#f8fafc] min-h-screen">
        <div className="max-w-7xl mx-auto space-y-6">
          <AlertNotification
            notification={notification}
            onClose={() => setNotification(null)}
            onRetry={notification?.type === "error" ? () => setNotification(null) : null}
          />

          {/* Header */}
          <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
            <div>
              <Link
                to={`/data-anak/dashboard/${id}`}
                className="inline-flex items-center gap-2 px-4 py-2 mb-3 bg-[#185FA5] hover:bg-[#185FA5]/90 text-white text-sm font-semibold rounded-xl transition-all active:scale-95 shadow-sm"
              >
                <ArrowLeft size={16} /> Kembali
              </Link>
              <h1 className="text-2xl font-bold text-slate-800">Data Pertumbuhan</h1>
              {anak && (
                <p className="text-sm text-slate-500 mt-0.5">
                  Anak: <span className="font-semibold text-slate-700">{anak.nama}</span>
                </p>
              )}
            </div>
            {!isModalOpen && (
              <button
                onClick={handleOpenAdd}
                className="inline-flex items-center gap-2 px-4 py-2 bg-[#185FA5] hover:bg-[#185FA5]/90 text-white text-sm font-semibold rounded-xl transition-all active:scale-95 shadow-sm"
              >
                <Plus size={16} /> Input Pengukuran
              </button>
            )}
          </div>

          {/* Form Input — inline, tidak popup */}
          {isModalOpen && (
            <div className="bg-white rounded-2xl border border-[#e2e8f0] p-6 shadow-sm">
              <div className="flex items-center justify-between mb-5">
                <h2 className="text-[18px] font-semibold text-slate-800">
                  {isEdit ? "Ubah Data Pengukuran" : "Input Pengukuran Baru"}
                </h2>
                <button
                  type="button"
                  onClick={() => setIsModalOpen(false)}
                  className="text-sm font-semibold text-slate-500 hover:text-slate-700 px-3 py-1.5 border border-[#e2e8f0] rounded-lg hover:bg-slate-50 transition-colors"
                >
                  Batal
                </button>
              </div>

              {anak && formData.tgl_ukur && (
                <div className="mb-4 p-3 bg-slate-50 border border-[#e2e8f0] rounded-xl text-sm text-slate-600">
                  Usia anak saat tanggal pengukuran:{" "}
                  <span className="font-semibold text-slate-800">{(() => {
                    const birth = new Date(anak.tanggal_lahir);
                    const target = new Date(formData.tgl_ukur);
                    let years = target.getFullYear() - birth.getFullYear();
                    let months = target.getMonth() - birth.getMonth();
                    if (target.getDate() < birth.getDate()) months--;
                    const ageMonths = years * 12 + months;
                    return ageMonths < 0 ? "0 bulan" : `${ageMonths} bulan`;
                  })()}</span>
                </div>
              )}

              <form onSubmit={handleSubmit} className="space-y-4">
                <div>
                  <label className="block text-sm font-semibold text-slate-600 mb-1.5">Tanggal Ukur</label>
                  <input type="date" required
                    className="w-full bg-[#F7FAFB] border border-[#e2e8f0] rounded-xl px-4 py-2.5 text-sm text-slate-700 focus:outline-none focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5]"
                    value={formData.tgl_ukur}
                    max={new Date().toISOString().split("T")[0]}
                    onChange={(e) => setFormData({ ...formData, tgl_ukur: e.target.value })}
                  />
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block text-sm font-semibold text-slate-600 mb-1.5">Berat Badan (kg)</label>
                    <input type="number" step="0.01" placeholder="Cth: 8.5" required
                      className="w-full bg-[#F7FAFB] border border-[#e2e8f0] rounded-xl px-4 py-2.5 text-sm text-slate-700 focus:outline-none focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5]"
                      value={formData.berat_badan}
                      onChange={(e) => setFormData({ ...formData, berat_badan: e.target.value })}
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-semibold text-slate-600 mb-1.5">Tinggi Badan (cm)</label>
                    <input type="number" step="0.1" placeholder="Cth: 72.0" required
                      className="w-full bg-[#F7FAFB] border border-[#e2e8f0] rounded-xl px-4 py-2.5 text-sm text-slate-700 focus:outline-none focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5]"
                      value={formData.tinggi_badan}
                      onChange={(e) => setFormData({ ...formData, tinggi_badan: e.target.value })}
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-semibold text-slate-600 mb-1.5">LILA (cm)</label>
                    <input type="number" step="0.1" placeholder="Cth: 14.0" required
                      className="w-full bg-[#F7FAFB] border border-[#e2e8f0] rounded-xl px-4 py-2.5 text-sm text-slate-700 focus:outline-none focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5]"
                      value={formData.hasil_lila}
                      onChange={(e) => setFormData({ ...formData, hasil_lila: e.target.value })}
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-semibold text-slate-600 mb-1.5">Lingkar Kepala (cm)</label>
                    <input type="number" step="0.1" placeholder="Cth: 43.0" required
                      className="w-full bg-[#F7FAFB] border border-[#e2e8f0] rounded-xl px-4 py-2.5 text-sm text-slate-700 focus:outline-none focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5]"
                      value={formData.lingkar_kepala}
                      onChange={(e) => setFormData({ ...formData, lingkar_kepala: e.target.value })}
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-semibold text-slate-600 mb-1.5">Catatan (opsional)</label>
                  <textarea rows={2} placeholder="Catatan tambahan..."
                    className="w-full bg-[#F7FAFB] border border-[#e2e8f0] rounded-xl px-4 py-2.5 text-sm text-slate-700 focus:outline-none focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5]"
                    value={formData.catatan_nakes}
                    onChange={(e) => setFormData({ ...formData, catatan_nakes: e.target.value })}
                  />
                </div>

                <div className="flex justify-end pt-2">
                  <button type="submit"
                    className="inline-flex items-center gap-2 px-6 py-2.5 bg-[#185FA5] hover:bg-[#185FA5]/90 text-white text-sm font-semibold rounded-xl transition-all active:scale-95 shadow-sm"
                  >
                    {isEdit ? "Simpan Perubahan" : "Simpan Data"}
                  </button>
                </div>
              </form>
            </div>
          )}

          {/* Grafik + Panel */}
          <div className="grid grid-cols-1 xl:grid-cols-3 gap-6">
            <div className="xl:col-span-2 bg-white rounded-2xl border border-[#e2e8f0] shadow-sm p-6 space-y-4">
              <div className="flex items-center justify-between flex-wrap gap-3 mb-2">
                <h3 className="text-base font-semibold text-slate-800">Grafik Pertumbuhan</h3>
                <div className="flex gap-1.5 flex-wrap">
                  {Object.entries(chartConfig).map(([key, cfg]) => (
                    <button
                      key={key}
                      onClick={() => setActiveChart(key)}
                      className={`px-3 py-1.5 rounded-xl text-xs font-semibold transition-all ${
                        activeChart === key
                          ? "bg-[#185FA5] text-white shadow-sm"
                          : "bg-[#F7FAFB] text-slate-500 border border-[#e2e8f0] hover:border-[#185FA5]/50"
                      }`}
                    >
                      {cfg.label.split(" ")[0]}
                    </button>
                  ))}
                </div>
              </div>
              <GrowthChart data={chartData} activeChart={activeChart} chartConfig={chartConfig} onChartChange={setActiveChart} />
            </div>

            <div className="space-y-4">
              <GrowthSummary lastStatus={lastStatus} lastData={lastData} anak={anak} />
              <div className="bg-white p-5 rounded-2xl border border-[#e2e8f0] shadow-sm">
                <p className="text-xs font-semibold text-slate-600 mb-4">Pengukuran Terakhir</p>
                <div className="grid grid-cols-2 gap-3">
                  <MiniStat label="BB" value={lastData?.berat_badan ?? "-"} unit="kg" color="indigo" />
                  <MiniStat label="TB" value={lastData?.tinggi_badan ?? "-"} unit="cm" color="purple" />
                  <MiniStat label="LILA" value={lastData?.hasil_lila || "-"} unit="cm" color="amber" />
                  <MiniStat label="LK" value={lastData?.lingkar_kepala || "-"} unit="cm" color="emerald" />
                </div>
              </div>
            </div>
          </div>

          {/* Status Gizi */}
          {lastData && (
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              <GrowthStatusCard status={lastStatus.statusBBU} label="Berat Badan / Usia (BB/U)" zScore={lastData.z_score_bb_u || lastData.zScoreBBU} description="Menunjukkan pertumbuhan berat badan anak sesuai usia" />
              <GrowthStatusCard status={lastStatus.statusTBU} label="Tinggi Badan / Usia (TB/U)" zScore={lastData.z_score_tb_u || lastData.zScoreTBU} description="Menunjukkan pertumbuhan tinggi badan anak sesuai usia" />
              <GrowthStatusCard status={lastStatus.statusBBTB} label="Berat Badan / Tinggi Badan (BB/TB)" zScore={lastData.z_score_bb_tb || lastData.zScoreBBTB} description="Menunjukkan proporsi pertumbuhan berat badan terhadap tinggi badan" />
            </div>
          )}

          {/* Tabel Riwayat */}
          <div className="bg-white rounded-2xl border border-[#e2e8f0] shadow-sm overflow-hidden">
            <div className="px-6 py-4 border-b border-[#e2e8f0]">
              <h3 className="text-base font-semibold text-slate-800">Riwayat Pengukuran</h3>
            </div>
            <div className="overflow-x-auto">
              <table className="w-full text-left border-collapse">
                <thead>
                  <tr className="bg-slate-100 border-b border-slate-200">
                    <th className="px-5 py-3.5 text-xs font-semibold text-slate-600">Usia</th>
                    <th className="px-5 py-3.5 text-xs font-semibold text-slate-600">Tanggal</th>
                    <th className="px-5 py-3.5 text-xs font-semibold text-slate-600 text-center">BB (kg)</th>
                    <th className="px-5 py-3.5 text-xs font-semibold text-slate-600 text-center">TB (cm)</th>
                    <th className="px-5 py-3.5 text-xs font-semibold text-slate-600 text-center">LILA (cm)</th>
                    <th className="px-5 py-3.5 text-xs font-semibold text-slate-600 text-center">LK (cm)</th>
                    <th className="px-5 py-3.5 text-xs font-semibold text-slate-600">Status Gizi</th>
                    <th className="px-5 py-3.5 text-xs font-semibold text-slate-600 text-right">Aksi</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-[#e2e8f0]">
                  {riwayat.length > 0 ? riwayat.map((r) => (
                    <tr key={r.id} className="hover:bg-[#F7FAFB] transition-colors">
                      <td className="px-5 py-4 text-sm text-slate-700">{r.usia_ukur_bulan} bln</td>
                      <td className="px-5 py-4 text-sm text-slate-600">{r.tgl_ukur}</td>
                      <td className="px-5 py-4 text-center text-sm text-slate-700">{r.berat_badan}</td>
                      <td className="px-5 py-4 text-center text-sm text-slate-700">{r.tinggi_badan}</td>
                      <td className="px-5 py-4 text-center text-sm text-slate-700">{r.hasil_lila || "-"}</td>
                      <td className="px-5 py-4 text-center text-sm text-slate-700">{r.lingkar_kepala || "-"}</td>
                      <td className="px-5 py-4">
                        {(() => {
                          const rowStatus = deriveStatusFromZScore(r);
                          return (
                            <div className="flex flex-col gap-1">
                              <div className="flex items-center gap-1.5">
                                <span className="text-[10px] text-slate-400 w-10">BB/U:</span>
                                <StatusBadge status={rowStatus.statusBBU} />
                              </div>
                              <div className="flex items-center gap-1.5">
                                <span className="text-[10px] text-slate-400 w-10">TB/U:</span>
                                <StatusBadge status={rowStatus.statusTBU} />
                              </div>
                              <div className="flex items-center gap-1.5">
                                <span className="text-[10px] text-slate-400 w-10">BB/TB:</span>
                                <StatusBadge status={rowStatus.statusBBTB} />
                              </div>
                            </div>
                          );
                        })()}
                      </td>
                      <td className="px-5 py-4">
                        <div className="flex items-center justify-end gap-1.5">
                          <button onClick={() => handleEdit(r)} className="p-2 text-slate-400 hover:text-[#185FA5] hover:bg-[#185FA5]/10 rounded-lg transition-colors" title="Edit">
                            <Pencil size={15} />
                          </button>
                          <button onClick={() => handleDelete(r.id)} className="p-2 text-slate-400 hover:text-red-600 hover:bg-red-50 rounded-lg transition-colors" title="Hapus">
                            <Trash2 size={15} />
                          </button>
                        </div>
                      </td>
                    </tr>
                  )) : (
                    <tr>
                      <td colSpan="8" className="px-6 py-16 text-center text-slate-400 text-sm italic">
                        Belum ada riwayat pengukuran.
                      </td>
                    </tr>
                  )}
                </tbody>
              </table>
            </div>
          </div>

        </div>
      </div>
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
