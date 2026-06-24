import React, { useState, useEffect, useMemo } from "react";
import MainLayout from "../../components/Layout/MainLayout";
import { getAnak } from "../../services/Anak";
import { getRentangUsia, getPemantauanHistory } from "../../services/pemantauanAnak";
import {
  FileText,
  TriangleAlert,
  AlertCircle,
  RotateCcw,
  Eye,
  Search
} from "lucide-react";
import { Link } from "react-router-dom";

export default function LihatDataPemantauan() {
  const [loading, setLoading] = useState(true);
  const [dataBayi, setDataBayi] = useState([]);
  const [statusFilter, setStatusFilter] = useState("Semua");
  const [searchTerm, setSearchTerm] = useState("");
  const [stats, setStats] = useState({ total: 0, bahaya: 0, waspada: 0 });

  const loadData = async () => {
    setLoading(true);
    try {
      const resAnak = await getAnak();
      const listAnak = resAnak.data || resAnak;
      const balitaList = listAnak.filter((c) => {
        if (c.usia_bulan !== undefined) {
          return c.usia_bulan < 60;
        }
        if (!c.tanggal_lahir) return false;
        const birthDate = new Date(c.tanggal_lahir);
        if (isNaN(birthDate.getTime())) return false;
        const currentDate = new Date();
        const limitDate = new Date(birthDate);
        limitDate.setFullYear(birthDate.getFullYear() + 5);
        return currentDate <= limitDate;
      });
      const resRentang = await getRentangUsia();
      const activeRentang = resRentang?.[0]; // Default to first range for summary

      const processedData = await Promise.all(
        balitaList.map(async (anak) => {
          // Fetch latest history for summary (simplified)
          let history = [];
          if (activeRentang) {
            try {
              history = await getPemantauanHistory(anak.id, activeRentang.id);
            } catch (e) { }
          }

          // Detect symptoms
          const allSymptoms = history.flatMap(h => (h.detail_gejala || []).filter(d => d.is_terjadi));
          const kondisi = allSymptoms.map(s => s.kategori_tanda_sakit?.gejala || "Gejala Terdeteksi").slice(0, 2);

          let status = "NORMAL";
          if (allSymptoms.length > 3) status = "BAHAYA";
          else if (allSymptoms.length > 0) status = "WASPADA";

          return {
            id: anak.id,
            nama: anak.nama,
            ibu: anak.kehamilan?.ibu?.nama_ibu || "-",
            usia: anak.usia_teks || "-",
            tanggal: history.length > 0 ? new Date(history[history.length - 1].updated_at).toLocaleString("id-ID") : "-",
            kondisi: kondisi,
            status: status
          };
        })
      );

      setDataBayi(processedData);

      // Update stats
      setStats({
        total: processedData.length,
        bahaya: processedData.filter(d => d.status === "BAHAYA").length,
        waspada: processedData.filter(d => d.status === "WASPADA").length,
      });

    } catch (error) {
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  const filteredData = useMemo(() => {
    if (statusFilter === "Semua") return dataBayi;
    return dataBayi.filter((item) => item.status === statusFilter.toUpperCase());
  }, [dataBayi, statusFilter]);

  return (
    <MainLayout>
      <div className="p-4 md:p-6 space-y-6 bg-[#F8FAFC] min-h-screen">
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div>
            <h1 className="text-xl md:text-2xl font-bold text-slate-800">Data Pemantauan Anak</h1>
            <p className="text-sm text-slate-500">Pantau kondisi anak berdasarkan laporan checklist harian ibu.</p>
          </div>
        </div>

        {/* Stats Cards */}
        <div className="grid grid-cols-3 gap-3 md:gap-6">
          <StatCard icon={<FileText className="text-blue-600" />} label="TOTAL ANAK" value={stats.total} color="bg-blue-50" />
          <StatCard icon={<TriangleAlert className="text-red-600" />} label="KASUS BAHAYA" value={stats.bahaya} color="bg-red-50" />
          <StatCard icon={<AlertCircle className="text-orange-600" />} label="KASUS WASPADA" value={stats.waspada} color="bg-orange-50" />
        </div>

        {/* Filter Section */}
        <div className="bg-white p-4 md:p-5 rounded-2xl border border-slate-200 shadow-sm">
          <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-4 mb-4">
            <div className="flex flex-col sm:flex-row flex-wrap gap-3">
              <div className="flex flex-col gap-1.5">
                <label className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">CARI NAMA</label>
                <div className="relative">
                  <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
                  <input
                    type="text"
                    placeholder="Cari Anak..."
                    className="pl-10 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-xl text-sm outline-none focus:border-[#185FA5] w-full sm:w-56"
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                  />
                </div>
              </div>
              <div className="flex flex-col gap-1.5">
                <label className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">STATUS</label>
                <div className="flex flex-wrap gap-2">
                  {["Semua", "Bahaya", "Waspada", "Normal"].map((s) => (
                    <button
                      key={s}
                      onClick={() => setStatusFilter(s)}
                      className={`px-3 py-1.5 rounded-full text-xs font-semibold border transition-all ${statusFilter === s ? "bg-slate-800 text-white border-slate-800" : "bg-white text-slate-600 border-slate-200"}`}
                    >
                      {s}
                    </button>
                  ))}
                </div>
              </div>
            </div>
            <button onClick={() => { setStatusFilter("Semua"); setSearchTerm(""); }} className="text-[#185FA5] text-sm font-semibold flex items-center gap-1 self-start sm:self-auto">
              <RotateCcw size={14} /> Reset Filter
            </button>
          </div>

          {/* Table */}
          <div className="overflow-x-auto -mx-4 md:mx-0">
            <table className="w-full text-left min-w-[560px]">
              <thead>
                <tr className="text-xs font-semibold text-slate-500 border-b border-slate-100 bg-slate-50">
                  <th className="pb-3 px-4 py-3">Identitas</th>
                  <th className="pb-3 px-4 py-3">Usia</th>
                  <th className="pb-3 px-4 py-3 text-center">Gejala Terdeteksi</th>
                  <th className="pb-3 px-4 py-3 text-center">Status</th>
                  <th className="pb-3 px-4 py-3 text-right">Aksi</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {dataBayi
                  .filter(item => statusFilter === "Semua" || item.status === statusFilter.toUpperCase())
                  .filter(item => item.nama.toLowerCase().includes(searchTerm.toLowerCase()))
                  .map((item) => (
                    <tr key={item.id} className="hover:bg-slate-50 transition-colors">
                      <td className="py-4 px-4">
                        <div className="font-semibold text-slate-800 text-sm">{item.nama}</div>
                        <div className="text-xs text-slate-400 mt-0.5">Ibu: {item.ibu}</div>
                      </td>
                      <td className="py-4 px-4">
                        <div className="text-sm text-slate-700">{item.usia}</div>
                        <div className="text-xs text-slate-400">{item.tanggal}</div>
                      </td>
                      <td className="py-4 px-4 text-center">
                        <div className="flex flex-wrap justify-center gap-1">
                          {item.kondisi.length > 0 ? (
                            item.kondisi.map((c, i) => (
                              <span key={i} className="px-2 py-0.5 bg-red-50 text-red-600 text-xs font-semibold rounded">
                                {c}
                              </span>
                            ))
                          ) : (
                            <span className="text-slate-300 italic text-xs">Tidak ada keluhan</span>
                          )}
                        </div>
                      </td>
                      <td className="py-4 px-4 text-center">
                        <StatusBadge status={item.status} />
                      </td>
                      <td className="py-4 px-4">
                        <div className="flex justify-end">
                          <Link
                            to={`/data-anak/pemantauan/${item.id}`}
                            className="p-2 bg-slate-100 text-slate-600 rounded-lg hover:bg-[#185FA5] hover:text-white transition-all"
                            title="Lihat Lembar Pemantauan"
                          >
                            <Eye size={16} />
                          </Link>
                        </div>
                      </td>
                    </tr>
                  ))}
              </tbody>
            </table>
            {dataBayi.length === 0 && !loading && (
              <div className="py-16 text-center text-slate-400 text-sm">Belum ada data anak yang terdaftar.</div>
            )}
          </div>
        </div>
      </div>
    </MainLayout>
  );
}

// Reusable Components for the UI
function StatCard({ icon, label, value, color }) {
  return (
    <div className={`p-3 md:p-6 rounded-2xl border border-slate-100 bg-white shadow-sm flex items-center gap-2 md:gap-4`}>
      <div className={`p-2 md:p-4 rounded-xl ${color} flex-shrink-0`}>{icon}</div>
      <div className="min-w-0">
        <p className="text-[9px] md:text-[10px] font-bold text-slate-400 tracking-wider truncate">{label}</p>
        <p className="text-xl md:text-3xl font-bold text-slate-800">{value}</p>
      </div>
    </div>
  );
}

function FilterGroup({ label, defaultValue }) {
  return (
    <div className="flex flex-col gap-1.5">
      <label className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">{label}</label>
      <select className="bg-slate-50 border border-slate-200 rounded-xl px-3 py-2 text-sm font-medium text-slate-700 outline-none min-w-[140px]">
        <option>{defaultValue}</option>
      </select>
    </div>
  );
}

function StatusBadge({ status }) {
  const styles = {
    BAHAYA: "bg-red-600 text-white",
    WASPADA: "bg-orange-500 text-white",
    NORMAL: "bg-white text-slate-400 border border-slate-200",
  };
  return (
    <span className={`px-4 py-1 rounded-full text-[10px] font-black tracking-widest inline-block ${styles[status]}`}>
      {status}
    </span>
  );
}