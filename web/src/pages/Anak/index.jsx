import React, { useState, useEffect } from "react";
import MainLayout from "../../components/Layout/MainLayout";
import { Link, useNavigate } from "react-router-dom";
import { getAnak, deleteAnak } from "../../services/Anak";
import {
  Plus, Search, Pencil, Trash2, ChevronLeft, ChevronRight,
  Baby, AlertTriangle, CheckCircle, Minus, RefreshCw, Brain
} from "lucide-react";

export default function AnakListNakes() {
  const navigate = useNavigate();
  const [children, setChildren] = useState([]);
  const [searchTerm, setSearchTerm] = useState("");
  const [loading, setLoading] = useState(true);
  const [activeQuickFilter, setActiveQuickFilter] = useState("all");

  // --- STATE PAGINATION ---
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 10;

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        const res = await getAnak();
        const list = res.data || [];
        const balitaList = list.filter((c) => {
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
        setChildren(balitaList);
      } catch (error) {
        console.error("Error fetching data:", error);
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, []);

  useEffect(() => {
    const onKeyDown = (event) => {
      if (event.altKey && event.key.toLowerCase() === "n") {
        event.preventDefault();
        navigate("/data-anak/create");
      }
    };
    window.addEventListener("keydown", onKeyDown);
    return () => window.removeEventListener("keydown", onKeyDown);
  }, [navigate]);

  const handleDelete = async (id, name) => {
    if (!window.confirm(`Hapus data anak "${name}"?\n\nTindakan ini tidak dapat dibatalkan.`)) return;
    try {
      await deleteAnak(id);
      setChildren((prev) => prev.filter((item) => item.id !== id));
    } catch {
      alert("Gagal menghapus data. Silakan coba lagi.");
    }
  };

  const formatDate = (dateString) => {
    if (!dateString || dateString.startsWith("0001")) return "-";
    const date = new Date(dateString);
    if (isNaN(date.getTime()) || date.getFullYear() < 1900) return "-";
    return date.toLocaleDateString("id-ID", { day: "numeric", month: "long", year: "numeric" });
  };

  // Gunakan status_prediksi dari field anak (di-set backend setelah prediksi)
  const normalCount = children.filter((c) => c.status_prediksi === "Normal").length;
  const risikoCount = children.filter((c) => c.status_prediksi === "Risiko Stunting").length;
  const stuntingCount = children.filter((c) => c.status_prediksi === "Stunting").length;

  // --- LOGIC FILTER & PAGINATION ---
  const normalizedSearch = searchTerm.toLowerCase();
  const searchFiltered = children.filter((c) =>
    (c.nama || "").toLowerCase().includes(normalizedSearch) ||
    (c.kehamilan?.ibu?.nama_ibu || "").toLowerCase().includes(normalizedSearch)
  );

  const filteredChildren = searchFiltered.filter((c) => {
    if (activeQuickFilter === "normal") return c.status_prediksi === "Normal";
    if (activeQuickFilter === "risiko") return c.status_prediksi === "Risiko Stunting";
    if (activeQuickFilter === "stunting") return c.status_prediksi === "Stunting";
    return true;
  });

  const indexOfLastItem = currentPage * itemsPerPage;
  const indexOfFirstItem = indexOfLastItem - itemsPerPage;
  const currentItems = filteredChildren.slice(indexOfFirstItem, indexOfLastItem);
  const totalPages = Math.ceil(filteredChildren.length / itemsPerPage);

  const handleSearchChange = (e) => { setSearchTerm(e.target.value); setCurrentPage(1); };
  const handleQuickFilterChange = (f) => { setActiveQuickFilter(f); setCurrentPage(1); };

  return (
    <MainLayout>
      <div className="p-4 md:p-8 bg-[#f8fafc] min-h-screen">
        <div className="mb-8">
          <div className="mb-5">
            <h1 className="text-2xl font-bold text-gray-800 tracking-tight">Manajemen Data Balita</h1>
            <p className="text-gray-500 text-sm">Rekam data pertumbuhan Balita secara terpusat.</p>
          </div>

          {/* Dashboard Cards */}
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
            {/* Total */}
            <DashCard
              label="Total Balita"
              count={children.length}
              icon={<Baby size={20} />}
              active={activeQuickFilter === "all"}
              colorActive="bg-blue-600 border-blue-600 shadow-blue-100"
              colorInactive="bg-white border-gray-200 hover:border-blue-300"
              iconBgActive="bg-white/20"
              iconBgInactive="bg-blue-50"
              iconColorActive="text-white"
              iconColorInactive="text-blue-600"
              labelColorActive="text-indigo-100"
              onClick={() => handleQuickFilterChange("all")}
            />
            {/* Normal */}
            <DashCard
              label="Normal"
              count={normalCount}
              icon={<CheckCircle size={20} />}
              active={activeQuickFilter === "normal"}
              colorActive="bg-emerald-600 border-emerald-600 shadow-emerald-100"
              colorInactive="bg-white border-gray-200 hover:border-emerald-300"
              iconBgActive="bg-white/20"
              iconBgInactive="bg-emerald-50"
              iconColorActive="text-white"
              iconColorInactive="text-emerald-600"
              labelColorActive="text-emerald-100"
              onClick={() => handleQuickFilterChange("normal")}
            />
            {/* Risiko */}
            <DashCard
              label="Risiko Stunting"
              count={risikoCount}
              icon={<AlertTriangle size={20} />}
              active={activeQuickFilter === "risiko"}
              colorActive="bg-amber-500 border-amber-500 shadow-amber-100"
              colorInactive="bg-white border-gray-200 hover:border-amber-300"
              iconBgActive="bg-white/20"
              iconBgInactive="bg-amber-50"
              iconColorActive="text-white"
              iconColorInactive="text-amber-500"
              labelColorActive="text-amber-100"
              onClick={() => handleQuickFilterChange("risiko")}
            />
            {/* Stunting */}
            <DashCard
              label="Stunting"
              count={stuntingCount}
              icon={<AlertTriangle size={20} />}
              active={activeQuickFilter === "stunting"}
              colorActive="bg-rose-600 border-rose-600 shadow-rose-100"
              colorInactive="bg-white border-gray-200 hover:border-rose-300"
              iconBgActive="bg-white/20"
              iconBgInactive="bg-rose-50"
              iconColorActive="text-white"
              iconColorInactive="text-rose-600"
              labelColorActive="text-rose-100"
              onClick={() => handleQuickFilterChange("stunting")}
            />
          </div>
        </div>

        <div className="bg-white rounded-t-2xl border-x border-t border-gray-100 p-6 sticky top-4 md:top-6 z-20">
          <div className="flex flex-col md:flex-row justify-between gap-4">
            <div className="relative w-full max-w-md">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
              <input
                type="text"
                placeholder="Cari nama balita atau nama ibu..."
                className="pl-10 pr-4 py-2.5 border border-gray-200 rounded-xl w-full focus:ring-2 focus:ring-indigo-500 outline-none transition-all text-sm"
                onChange={handleSearchChange}
              />
            </div>
          </div>
        </div>

        <div className="bg-white rounded-b-2xl shadow-sm border border-gray-100 overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-gray-50/50 border-y border-gray-100 text-gray-500 uppercase text-[10px] tracking-widest font-black">
                <th className="px-6 py-4">Nama Anak</th>
                <th className="px-6 py-4">Jenis Kelamin</th>
                <th className="px-6 py-4">Status Stunting</th>
                <th className="px-6 py-4">Tanggal Lahir</th>
                <th className="px-6 py-4">Usia</th>
                <th className="px-6 py-4">Nama Ibu</th>
                <th className="px-6 py-4 text-center">Aksi</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-50">
              {loading ? (
                <tr>
                  <td colSpan="7" className="py-16">
                    <div className="flex flex-col items-center justify-center gap-3">
                      <RefreshCw size={36} className="animate-spin text-blue-600" />
                      <p className="text-[14px] text-slate-500 font-medium">Memuat data anak...</p>
                    </div>
                  </td>
                </tr>
              ) : children.length === 0 ? (
                <tr>
                  <td colSpan="7" className="text-center py-16">
                    <div className="flex flex-col items-center justify-center gap-3">
                      <p className="text-gray-500 font-semibold">Belum ada data Balita</p>
                      <p className="text-sm text-gray-400">Tambahkan data pertama untuk mulai pemantauan.</p>
                    </div>
                  </td>
                </tr>
              ) : currentItems.length === 0 ? (
                <tr>
                  <td colSpan="7" className="text-center py-16">
                    <p className="text-gray-500 font-medium">Tidak ada data yang sesuai dengan pencarian atau filter aktif.</p>
                  </td>
                </tr>
              ) : (
                currentItems.map((child) => (
                  <tr key={child.id} className="hover:bg-indigo-50/20 transition-colors group">
                    <td className="px-6 py-4 font-bold text-gray-800 text-sm">{child.nama}</td>
                    <td className="px-6 py-4 text-sm text-gray-700">{child.jenis_kelamin || "-"}</td>
                    <td className="px-6 py-4">
                      <StatusBadge status={child.status_prediksi} />
                    </td>
                    <td className="px-6 py-4 text-xs">{formatDate(child.tanggal_lahir)}</td>
                    <td className="px-6 py-4 text-xs font-bold">{child.usia_teks || "-"}</td>
                    <td className="px-6 py-4 text-sm font-semibold">{child.kehamilan?.ibu?.nama_ibu || "-"}</td>
                    <td className="px-6 py-4">
                      <div className="flex items-center justify-center gap-1.5">
                        <Link to={`/data-anak/dashboard/${child.id}`} className="bg-blue-600 text-white px-3 py-1.5 rounded-lg text-xs font-bold shadow-sm active:scale-95">
                          Detail
                        </Link>
                        <Link to={`/data-anak/edit/${child.id}`} className="p-1.5 text-gray-400 hover:text-amber-600"><Pencil size={14} /></Link>
                        <button onClick={() => handleDelete(child.id, child.nama)} className="p-1.5 text-gray-400 hover:text-red-600"><Trash2 size={14} /></button>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>

          {/* Pagination */}
          <div className="flex items-center justify-between px-6 py-4 bg-gray-50/50 border-t border-gray-100">
            <p className="text-xs text-gray-500 font-medium">
              {filteredChildren.length === 0
                ? "Tidak ada data"
                : `Menampilkan ${indexOfFirstItem + 1}-${Math.min(indexOfLastItem, filteredChildren.length)} dari ${filteredChildren.length} data`}
            </p>
            <div className="flex items-center gap-2">
              <button
                onClick={() => setCurrentPage((p) => Math.max(p - 1, 1))}
                disabled={currentPage === 1}
                className="p-2 rounded-lg border border-gray-200 bg-white text-gray-600 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <ChevronLeft size={16} />
              </button>
              <div className="flex gap-1">
                {[...Array(totalPages)].map((_, i) => (
                  <button
                    key={i}
                    onClick={() => setCurrentPage(i + 1)}
                    className={`w-8 h-8 rounded-lg text-xs font-bold transition-all ${currentPage === i + 1
                      ? "bg-indigo-600 text-white shadow-md shadow-indigo-100"
                      : "bg-white border border-gray-200 text-gray-600 hover:bg-gray-50"
                      }`}
                  >
                    {i + 1}
                  </button>
                ))}
              </div>
              <button
                onClick={() => setCurrentPage((p) => Math.min(p + 1, totalPages))}
                disabled={currentPage === totalPages || totalPages === 0}
                className="p-2 rounded-lg border border-gray-200 bg-white text-gray-600 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <ChevronRight size={16} />
              </button>
            </div>
          </div>
        </div>
      </div>
    </MainLayout>
  );
}

// ── Sub-components ──────────────────────────────────────────────────────────

function DashCard({ label, count, icon, active, colorActive, colorInactive, iconBgActive, iconBgInactive, iconColorActive, iconColorInactive, labelColorActive, onClick }) {
  return (
    <button
      type="button"
      onClick={onClick}
      className={`text-left rounded-2xl p-4 border shadow-lg transition-all ${active ? colorActive + " text-white" : colorInactive + " text-gray-700"}`}
    >
      <div className="flex items-center gap-3">
        <div className={`p-2 rounded-xl ${active ? iconBgActive : iconBgInactive}`}>
          <span className={active ? iconColorActive : iconColorInactive}>{icon}</span>
        </div>
        <div>
          <p className={`text-[10px] font-bold uppercase tracking-wider ${active ? labelColorActive : "text-gray-500"}`}>{label}</p>
          <p className="text-xl font-black">{count} <span className="text-sm font-semibold">Anak</span></p>
        </div>
      </div>
    </button>
  );
}

function StatusBadge({ status }) {
  if (!status) {
    return (
      <span className="flex items-center gap-1 px-2.5 py-1 rounded-full text-[10px] font-bold bg-gray-100 text-gray-400 border border-gray-200">
        <Minus size={10} /> Belum diprediksi
      </span>
    );
  }
  if (status === "Stunting")
    return <span className="flex items-center gap-1 px-2.5 py-1 rounded-full text-[10px] font-bold bg-red-100 text-red-700 border border-red-200">🔴 Stunting</span>;
  if (status === "Risiko Stunting")
    return <span className="flex items-center gap-1 px-2.5 py-1 rounded-full text-[10px] font-bold bg-amber-100 text-amber-700 border border-amber-200">🟡 Risiko Stunting</span>;
  return <span className="flex items-center gap-1 px-2.5 py-1 rounded-full text-[10px] font-bold bg-green-100 text-green-700 border border-green-200">🟢 Normal</span>;
}