import { useState, useEffect, useMemo } from "react";
import MainLayout from "../../components/Layout/MainLayout";
import { getAnak } from "../../services/Anak";
import { getKategoriCapaianList, getPerawatanByAnak } from "../../services/perawatan";
import {
  FileText,
  CheckCircle2,
  AlertCircle,
  RotateCcw,
  Eye,
  Search,
  RefreshCw,
} from "lucide-react";
import { Link } from "react-router-dom";

export default function LihatDataPerkembangan() {
  const [loading, setLoading] = useState(true);
  const [dataAnak, setDataAnak] = useState([]);
  const [statusFilter, setStatusFilter] = useState("Semua");
  const [searchTerm, setSearchTerm] = useState("");
  const [stats, setStats] = useState({ total: 0, tercapai: 0, belum: 0 });

  const loadData = async () => {
    setLoading(true);
    try {
      // Ambil daftar anak dan total indikator secara paralel
      const [resAnak, kategoriList] = await Promise.all([
        getAnak(),
        getKategoriCapaianList(),
      ]);

      const listAnak = resAnak.data || resAnak;
      const totalIndikator = Array.isArray(kategoriList) ? kategoriList.length : 0;

      // Untuk setiap anak, ambil data perawatan yang sudah diisi
      const processedData = await Promise.all(
        listAnak.map(async (anak) => {
          let tercapai = 0;

          try {
            const perawatanList = await getPerawatanByAnak(anak.id);
            // Hitung yang jawabannya true (tercapai)
            tercapai = Array.isArray(perawatanList)
              ? perawatanList.filter((p) => p.jawaban === true).length
              : 0;
          } catch {
            tercapai = 0;
          }

          // Tentukan status berdasarkan persentase capaian
          let status = "BELUM";
          if (totalIndikator > 0) {
            const persen = tercapai / totalIndikator;
            if (persen >= 0.75) status = "TERCAPAI";
            else if (persen >= 0.5) status = "SEBAGIAN";
          }

          return {
            id: anak.id,
            nama: anak.nama,
            ibu: anak.kehamilan?.ibu?.nama_ibu || "-",
            usia: anak.usia_teks || "-",
            tercapai,
            total: totalIndikator,
            status,
          };
        })
      );

      setDataAnak(processedData);
      setStats({
        total: processedData.length,
        tercapai: processedData.filter((d) => d.status === "TERCAPAI").length,
        belum: processedData.filter((d) => d.status === "BELUM").length,
      });
    } catch (error) {
      console.error("Error loading data perawatan:", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  const filteredData = useMemo(() => {
    let result = dataAnak;
    if (statusFilter !== "Semua") {
      result = result.filter((item) => item.status === statusFilter.toUpperCase());
    }
    if (searchTerm.trim()) {
      result = result.filter((item) =>
        item.nama.toLowerCase().includes(searchTerm.toLowerCase())
      );
    }
    return result;
  }, [dataAnak, statusFilter, searchTerm]);

  return (
    <MainLayout>
      <div className="p-6 space-y-6 bg-[#F8FAFC] min-h-screen">

        {/* Header */}
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div>
            <h1 className="text-2xl font-bold text-slate-800">Data Perawatan Anak</h1>
            <p className="text-slate-500 text-sm">
              Pantau pencapaian indikator perkembangan anak berdasarkan lembar perawatan.
            </p>
          </div>
          <button
            onClick={loadData}
            disabled={loading}
            className="flex items-center gap-2 bg-white border border-slate-200 hover:bg-slate-50 text-slate-700 px-4 py-2 rounded-lg transition-all text-sm font-semibold shadow-sm"
          >
            <RefreshCw size={16} className={loading ? "animate-spin" : ""} />
            Refresh
          </button>
        </div>

        {/* Stats Cards */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <StatCard
            icon={<FileText className="text-blue-600" />}
            label="TOTAL ANAK"
            value={stats.total}
            color="bg-blue-50"
          />
          <StatCard
            icon={<CheckCircle2 className="text-green-600" />}
            label="SUDAH TERCAPAI (≥75%)"
            value={stats.tercapai}
            color="bg-green-50"
          />
          <StatCard
            icon={<AlertCircle className="text-orange-600" />}
            label="BELUM TERCAPAI"
            value={stats.belum}
            color="bg-orange-50"
          />
        </div>

        {/* Filter + Tabel */}
        <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm">

          {/* Filter Bar */}
          <div className="flex flex-wrap items-center justify-between gap-4 mb-6">
            <div className="flex flex-wrap items-center gap-4">
              {/* Search */}
              <div className="flex flex-col gap-1">
                <label className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">
                  CARI NAMA
                </label>
                <div className="relative">
                  <Search
                    size={15}
                    className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400"
                  />
                  <input
                    type="text"
                    placeholder="Cari anak..."
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    className="pl-9 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-xl text-sm outline-none focus:border-blue-500 w-56"
                  />
                </div>
              </div>

              {/* Status Filter */}
              <div className="flex flex-col gap-1">
                <label className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">
                  STATUS
                </label>
                <div className="flex gap-2">
                  {["Semua", "Tercapai", "Sebagian", "Belum"].map((s) => (
                    <button
                      key={s}
                      onClick={() => setStatusFilter(s)}
                      className={`px-3 py-1.5 rounded-full text-xs font-semibold border transition-all ${
                        statusFilter === s
                          ? "bg-slate-800 text-white border-slate-800"
                          : "bg-white text-slate-600 border-slate-200 hover:border-slate-400"
                      }`}
                    >
                      {s}
                    </button>
                  ))}
                </div>
              </div>
            </div>

            <button
              onClick={() => { setStatusFilter("Semua"); setSearchTerm(""); }}
              className="text-blue-600 text-sm font-semibold flex items-center gap-1 hover:underline"
            >
              <RotateCcw size={13} /> Reset
            </button>
          </div>

          {/* Tabel */}
          <div className="overflow-x-auto">
            <table className="w-full text-left">
              <thead>
                <tr className="text-[11px] font-bold text-slate-400 uppercase tracking-widest border-b border-slate-100">
                  <th className="pb-3 px-2">IDENTITAS</th>
                  <th className="pb-3 px-2">USIA</th>
                  <th className="pb-3 px-2 text-center">CAPAIAN INDIKATOR</th>
                  <th className="pb-3 px-2 text-center">STATUS</th>
                  <th className="pb-3 px-2 text-right">AKSI</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-50">
                {loading ? (
                  <tr>
                    <td colSpan={5} className="py-16 text-center text-slate-300 italic text-sm">
                      Memuat data...
                    </td>
                  </tr>
                ) : filteredData.length === 0 ? (
                  <tr>
                    <td colSpan={5} className="py-16 text-center text-slate-400 text-sm">
                      Tidak ada data yang sesuai filter.
                    </td>
                  </tr>
                ) : (
                  filteredData.map((item) => (
                    <tr
                      key={item.id}
                      className="group hover:bg-slate-50/60 transition-colors"
                    >
                      {/* Identitas */}
                      <td className="py-4 px-2">
                        <div className="font-bold text-slate-800 text-sm">{item.nama}</div>
                        <div className="text-xs text-slate-400 mt-0.5">Ibu: {item.ibu}</div>
                      </td>

                      {/* Usia */}
                      <td className="py-4 px-2">
                        <span className="text-sm text-slate-700">{item.usia}</span>
                      </td>

                      {/* Capaian */}
                      <td className="py-4 px-2">
                        <div className="flex items-center justify-center gap-3">
                          <span className="text-sm font-bold text-slate-800 w-12 text-right">
                            {item.tercapai}/{item.total}
                          </span>
                          <div className="w-28 bg-slate-100 rounded-full h-2">
                            <div
                              className="h-2 rounded-full transition-all bg-blue-500"
                              style={{
                                width: `${item.total > 0 ? (item.tercapai / item.total) * 100 : 0}%`,
                              }}
                            />
                          </div>
                          <span className="text-xs text-slate-400 w-10">
                            {item.total > 0
                              ? Math.round((item.tercapai / item.total) * 100)
                              : 0}%
                          </span>
                        </div>
                      </td>

                      {/* Status */}
                      <td className="py-4 px-2 text-center">
                        <StatusBadge status={item.status} />
                      </td>

                      {/* Aksi */}
                      <td className="py-4 px-2">
                        <div className="flex justify-end">
                          <Link
                            to={`/data-anak/perawatan/${item.id}`}
                            className="p-2 bg-slate-100 text-slate-600 rounded-lg hover:bg-blue-600 hover:text-white transition-all"
                            title="Lihat & Isi Lembar Perawatan"
                          >
                            <Eye size={17} />
                          </Link>
                        </div>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </MainLayout>
  );
}

// ── Komponen kecil ──────────────────────────────────────

function StatCard({ icon, label, value, color }) {
  return (
    <div className="p-5 rounded-2xl border border-slate-100 bg-white shadow-sm flex items-center gap-4">
      <div className={`p-3.5 rounded-xl ${color}`}>{icon}</div>
      <div>
        <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">{label}</p>
        <p className="text-3xl font-black text-slate-800">{value}</p>
      </div>
    </div>
  );
}

function StatusBadge({ status }) {
  const styles = {
    TERCAPAI: "bg-green-100 text-green-700",
    SEBAGIAN: "bg-yellow-100 text-yellow-700",
    BELUM: "bg-red-100 text-red-700",
  };
  return (
    <span className={`px-3 py-1 text-[10px] font-bold rounded-full ${styles[status] || styles.BELUM}`}>
      {status}
    </span>
  );
}
