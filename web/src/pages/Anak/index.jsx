import React, { useState, useEffect } from "react";
import MainLayout from "../../components/Layout/MainLayout";
import { Link, useNavigate } from "react-router-dom";
import { getAnak, deleteAnak } from "../../services/Anak";
import Swal from "sweetalert2";
import {
  Plus, Search, Pencil, ChevronLeft, ChevronRight,
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
    const result = await Swal.fire({
      title: "Hapus Data Anak?",
      text: `Data "${name}" akan dihapus permanen dan tidak dapat dikembalikan.`,
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#EF4444",
      cancelButtonColor: "#6B7280",
      confirmButtonText: "Ya, Hapus",
      cancelButtonText: "Batal",
    });
    if (!result.isConfirmed) return;
    try {
      await deleteAnak(id);
      setChildren((prev) => prev.filter((item) => item.id !== id));
      Swal.fire({
        icon: "success",
        title: "Berhasil",
        text: `Data "${name}" berhasil dihapus.`,
        timer: 2000,
        showConfirmButton: false,
      });
    } catch {
      Swal.fire({ icon: "error", title: "Gagal", text: "Gagal menghapus data. Silakan coba lagi." });
    }
  };

  const formatDate = (dateString) => {
    if (!dateString || dateString.startsWith("0001")) return "-";
    const date = new Date(dateString);
    if (isNaN(date.getTime()) || date.getFullYear() < 1900) return "-";
    return date.toLocaleDateString("id-ID", { day: "numeric", month: "long", year: "numeric" });
  };

  // Konstanta: minimal catatan pertumbuhan untuk mendeteksi status stunting
  const MIN_PENGUKURAN = 3;

  // Gunakan status_prediksi dari field anak (di-set backend setelah prediksi)
  // Hanya hitung anak yang sudah punya >= 3 pengukuran
  const belumTerdeteksiCount = children.filter((c) => (c.jumlah_pengukuran || 0) < MIN_PENGUKURAN).length;
  const normalCount = children.filter((c) => (c.jumlah_pengukuran || 0) >= MIN_PENGUKURAN && c.status_prediksi === "Normal").length;
  const risikoCount = children.filter((c) => (c.jumlah_pengukuran || 0) >= MIN_PENGUKURAN && (c.status_prediksi === "Risiko Stunting Ringan" || c.status_prediksi === "Risiko Stunting Sedang")).length;
  const stuntingCount = children.filter((c) => (c.jumlah_pengukuran || 0) >= MIN_PENGUKURAN && c.status_prediksi === "Stunting").length;

  // --- LOGIC FILTER & PAGINATION ---
  const normalizedSearch = searchTerm.toLowerCase();
  const searchFiltered = children.filter((c) =>
    (c.nama || "").toLowerCase().includes(normalizedSearch) ||
    (c.kehamilan?.ibu?.nama_ibu || "").toLowerCase().includes(normalizedSearch)
  );

  const filteredChildren = searchFiltered.filter((c) => {
    const cukup = (c.jumlah_pengukuran || 0) >= MIN_PENGUKURAN;
    if (activeQuickFilter === "belum") return !cukup;
    if (activeQuickFilter === "normal") return cukup && c.status_prediksi === "Normal";
    if (activeQuickFilter === "risiko") return cukup && (c.status_prediksi === "Risiko Stunting Ringan" || c.status_prediksi === "Risiko Stunting Sedang");
    if (activeQuickFilter === "stunting") return cukup && c.status_prediksi === "Stunting";
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
          <div className="grid grid-cols-2 gap-2 sm:gap-3 lg:grid-cols-5">
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
              labelColorActive="text-blue-100"
              onClick={() => handleQuickFilterChange("all")}
            />
            {/* Belum Terdeteksi */}
            <DashCard
              label="Belum Terdeteksi"
              count={belumTerdeteksiCount}
              icon={<Minus size={20} />}
              active={activeQuickFilter === "belum"}
              colorActive="bg-gray-500 border-gray-500 shadow-gray-100"
              colorInactive="bg-white border-gray-200 hover:border-gray-300"
              iconBgActive="bg-white/20"
              iconBgInactive="bg-gray-50"
              iconColorActive="text-white"
              iconColorInactive="text-gray-400"
              labelColorActive="text-gray-100"
              onClick={() => handleQuickFilterChange("belum")}
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

        <div className="bg-white rounded-t-2xl border-x border-t border-gray-100 p-3 sm:p-4 md:p-6 sticky top-0 md:top-6 z-20">
          <div className="flex flex-col sm:flex-row justify-between gap-3">
            <div className="relative w-full sm:max-w-md">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
              <input
                type="text"
                placeholder="Cari nama balita atau nama ibu..."
                className="pl-10 pr-4 py-2.5 border border-gray-200 rounded-xl w-full focus:ring-2 focus:ring-[#185FA5] outline-none transition-all text-sm"
                onChange={handleSearchChange}
              />
            </div>
          </div>
        </div>

        {/* Desktop Table View */}
        <div className="hidden md:block bg-white rounded-b-2xl shadow-sm border border-gray-100 overflow-x-auto">
          <table className="w-full text-left border-collapse min-w-[640px]">
            <thead>
              <tr className="bg-gray-50 border-y border-gray-100">
                <th className="px-6 py-3.5 text-xs font-semibold text-gray-500">Nama Anak</th>
                <th className="px-6 py-3.5 text-xs font-semibold text-gray-500">Jenis Kelamin</th>
                <th className="px-6 py-3.5 text-xs font-semibold text-gray-500">Status Stunting</th>
                <th className="px-6 py-3.5 text-xs font-semibold text-gray-500">Tanggal Lahir</th>
                <th className="px-6 py-3.5 text-xs font-semibold text-gray-500">Usia</th>
                <th className="px-6 py-3.5 text-xs font-semibold text-gray-500">Nama Ibu</th>
                <th className="px-6 py-3.5 text-xs font-semibold text-gray-500 text-center">Aksi</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {loading ? (
                <tr>
                  <td colSpan="7" className="py-16">
                    <div className="flex flex-col items-center justify-center gap-3">
                      <RefreshCw size={36} className="animate-spin text-blue-600" />
                      <p className="text-sm text-slate-500 font-medium">Memuat data anak...</p>
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
                    <p className="text-gray-500 text-sm">Tidak ada data yang sesuai dengan pencarian atau filter aktif.</p>
                  </td>
                </tr>
              ) : (
                currentItems.map((child) => (
                  <tr key={child.id} className="hover:bg-blue-50/20 transition-colors group">
                    <td className="px-6 py-4 text-sm font-semibold text-gray-800">{child.nama}</td>
                    <td className="px-6 py-4 text-sm text-gray-600">{child.jenis_kelamin || "-"}</td>
                    <td className="px-6 py-4">
                      <StatusBadge status={child.status_prediksi} jumlahPengukuran={child.jumlah_pengukuran} />
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-600">{formatDate(child.tanggal_lahir)}</td>
                    <td className="px-6 py-4 text-sm text-gray-600">{child.usia_teks || "-"}</td>
                    <td className="px-6 py-4 text-sm text-gray-600">{child.kehamilan?.ibu?.nama_ibu || "-"}</td>
                    <td className="px-6 py-4">
                      <div className="flex items-center justify-center gap-1.5">
                        <Link
                          to={`/data-anak/dashboard/${child.id}`}
                          className="inline-flex items-center px-3 py-1.5 bg-[#185FA5] hover:bg-[#185FA5]/90 text-white text-xs font-semibold rounded-xl transition-all active:scale-95 shadow-sm"
                        >
                          Detail
                        </Link>
                        <Link
                          to={`/data-anak/edit/${child.id}`}
                          className="p-1.5 rounded-lg text-gray-400 hover:text-amber-600 hover:bg-amber-50 transition-colors"
                          title="Edit"
                        >
                          <Pencil size={14} />
                        </Link>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>

        {/* Mobile Card View */}
        <div className="md:hidden bg-white rounded-b-2xl shadow-sm border border-gray-100">
          {loading ? (
            <div className="flex flex-col items-center justify-center gap-3 py-16">
              <RefreshCw size={36} className="animate-spin text-blue-600" />
              <p className="text-sm text-slate-500 font-medium">Memuat data anak...</p>
            </div>
          ) : children.length === 0 ? (
            <div className="flex flex-col items-center justify-center gap-3 py-16 text-center px-4">
              <p className="text-gray-500 font-semibold">Belum ada data Balita</p>
              <p className="text-sm text-gray-400">Tambahkan data pertama untuk mulai pemantauan.</p>
            </div>
          ) : currentItems.length === 0 ? (
            <div className="text-center py-16 px-4">
              <p className="text-gray-500 text-sm">Tidak ada data yang sesuai dengan pencarian atau filter aktif.</p>
            </div>
          ) : (
            <div className="divide-y divide-gray-100">
              {currentItems.map((child) => (
                <div key={child.id} className="p-4 hover:bg-blue-50/20 transition-colors">
                  <div className="flex items-start justify-between gap-3 mb-2">
                    <div className="min-w-0 flex-1">
                      <p className="text-sm font-bold text-gray-800 truncate">{child.nama}</p>
                      <p className="text-xs text-gray-500 mt-0.5">Ibu: {child.kehamilan?.ibu?.nama_ibu || "-"}</p>
                    </div>
                    <StatusBadge status={child.status_prediksi} jumlahPengukuran={child.jumlah_pengukuran} />
                  </div>
                  <div className="grid grid-cols-3 gap-2 text-xs text-gray-500 mb-3">
                    <div>
                      <span className="text-[10px] font-bold uppercase text-gray-400 block">Kelamin</span>
                      {child.jenis_kelamin || "-"}
                    </div>
                    <div>
                      <span className="text-[10px] font-bold uppercase text-gray-400 block">Tgl Lahir</span>
                      {formatDate(child.tanggal_lahir)}
                    </div>
                    <div>
                      <span className="text-[10px] font-bold uppercase text-gray-400 block">Usia</span>
                      {child.usia_teks || "-"}
                    </div>
                  </div>
                  <div className="flex items-center gap-2">
                    <Link
                      to={`/data-anak/dashboard/${child.id}`}
                      className="flex-1 inline-flex items-center justify-center px-3 py-2 bg-[#185FA5] hover:bg-[#185FA5]/90 text-white text-xs font-semibold rounded-xl transition-all active:scale-95 shadow-sm"
                    >
                      Lihat Detail
                    </Link>
                    <Link
                      to={`/data-anak/edit/${child.id}`}
                      className="p-2 rounded-lg text-gray-400 hover:text-amber-600 hover:bg-amber-50 transition-colors border border-gray-200"
                      title="Edit"
                    >
                      <Pencil size={14} />
                    </Link>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Pagination */}
        <div className="flex items-center justify-between px-4 sm:px-6 py-3 sm:py-4 bg-white border border-gray-100 rounded-b-2xl md:rounded-none -mt-px">
          <p className="text-[10px] sm:text-xs text-gray-500 font-medium">
            {filteredChildren.length === 0
              ? "Tidak ada data"
              : `${indexOfFirstItem + 1}-${Math.min(indexOfLastItem, filteredChildren.length)} / ${filteredChildren.length}`}
          </p>
          <div className="flex items-center gap-1 sm:gap-2">
            <button
              onClick={() => setCurrentPage((p) => Math.max(p - 1, 1))}
              disabled={currentPage === 1}
              className="p-1.5 sm:p-2 rounded-lg border border-gray-200 bg-white text-gray-600 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <ChevronLeft size={14} className="sm:hidden" />
              <ChevronLeft size={16} className="hidden sm:block" />
            </button>
            <div className="flex gap-1">
              {[...Array(totalPages)].map((_, i) => {
                // On mobile, show limited page numbers
                const showOnMobile = totalPages <= 5 || i === 0 || i === totalPages - 1 || Math.abs(i + 1 - currentPage) <= 1;
                return (
                  <button
                    key={i}
                    onClick={() => setCurrentPage(i + 1)}
                    className={`w-7 h-7 sm:w-8 sm:h-8 rounded-lg text-[10px] sm:text-xs font-bold transition-all ${!showOnMobile ? 'hidden sm:flex items-center justify-center' : ''} ${currentPage === i + 1
                      ? "bg-[#185FA5] text-white shadow-md shadow-blue-100"
                      : "bg-white border border-gray-200 text-gray-600 hover:bg-gray-50"
                    }`}
                  >
                    {i + 1}
                  </button>
                );
              })}
            </div>
            <button
              onClick={() => setCurrentPage((p) => Math.min(p + 1, totalPages))}
              disabled={currentPage === totalPages || totalPages === 0}
              className="p-1.5 sm:p-2 rounded-lg border border-gray-200 bg-white text-gray-600 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <ChevronRight size={14} className="sm:hidden" />
              <ChevronRight size={16} className="hidden sm:block" />
            </button>
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
      className={`text-left rounded-xl sm:rounded-2xl p-2.5 sm:p-4 border shadow-lg transition-all ${active ? colorActive + " text-white" : colorInactive + " text-gray-700"}`}
    >
      <div className="flex items-center gap-2 sm:gap-3">
        <div className={`p-1.5 sm:p-2 rounded-lg sm:rounded-xl flex-shrink-0 ${active ? iconBgActive : iconBgInactive}`}>
          <span className={active ? iconColorActive : iconColorInactive}>{icon}</span>
        </div>
        <div className="min-w-0">
          <p className={`text-[8px] sm:text-[10px] font-bold uppercase tracking-wider truncate ${active ? labelColorActive : "text-gray-500"}`}>{label}</p>
          <p className="text-base sm:text-xl font-black">{count} <span className="text-[10px] sm:text-sm font-semibold">Anak</span></p>
        </div>
      </div>
    </button>
  );
}

function StatusBadge({ status, jumlahPengukuran }) {
  const MIN_PENGUKURAN = 3;
  const cukup = (jumlahPengukuran || 0) >= MIN_PENGUKURAN;

  if (!cukup) {
    return (
      <span className="flex items-center gap-1 px-2.5 py-1 rounded-full text-[10px] font-bold bg-slate-100 text-slate-500 border border-slate-200" title={`Perlu minimal ${MIN_PENGUKURAN} kali pengukuran antropometri`}>
        <Minus size={10} /> Belum dapat dideteksi ({jumlahPengukuran || 0}/{MIN_PENGUKURAN})
      </span>
    );
  }
  if (!status) {
    return (
      <span className="flex items-center gap-1 px-2.5 py-1 rounded-full text-[10px] font-bold bg-gray-100 text-gray-400 border border-gray-200">
        <Minus size={10} /> Belum diprediksi
      </span>
    );
  }
  if (status === "Stunting")
    return <span className="flex items-center gap-1 px-2.5 py-1 rounded-full text-[10px] font-bold bg-red-100 text-red-700 border border-red-200">🔴 Stunting</span>;
  if (status === "Risiko Stunting Sedang")
    return <span className="flex items-center gap-1 px-2.5 py-1 rounded-full text-[10px] font-bold bg-orange-100 text-orange-700 border border-orange-200">🟠 Risiko Stunting Sedang</span>;
  if (status === "Risiko Stunting Ringan")
    return <span className="flex items-center gap-1 px-2.5 py-1 rounded-full text-[10px] font-bold bg-yellow-100 text-yellow-700 border border-yellow-200">🟡 Risiko Stunting Ringan</span>;
  return <span className="flex items-center gap-1 px-2.5 py-1 rounded-full text-[10px] font-bold bg-green-100 text-green-700 border border-green-200">🟢 Normal</span>;
}