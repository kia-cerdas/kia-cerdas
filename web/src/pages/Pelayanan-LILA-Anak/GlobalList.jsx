import React, { useState, useEffect } from "react";
import MainLayout from "../../components/Layout/MainLayout";
import { Link, useNavigate } from "react-router-dom";
import { getAnak } from "../../services/Anak";
import { Search, ChevronLeft, ChevronRight, Activity, Baby } from "lucide-react";

export default function PelayananLilaGlobalList() {
  const navigate = useNavigate();
  const [children, setChildren] = useState([]);
  const [searchTerm, setSearchTerm] = useState("");
  const [loading, setLoading] = useState(true);

  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 10;

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        const res = await getAnak();
        setChildren(res.data || []);
      } catch (error) {
        console.error("Error fetching data:", error);
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, []);

  const formatDate = (dateString) => {
    if (!dateString) return "-";
    const date = new Date(dateString);
    return date.toLocaleDateString("id-ID", {
      day: "numeric", month: "long", year: "numeric",
    });
  };

  const filteredChildren = children.filter((c) =>
    c.nama?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    c.kehamilan?.ibu?.nama_ibu?.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const indexOfLastItem = currentPage * itemsPerPage;
  const indexOfFirstItem = indexOfLastItem - itemsPerPage;
  const currentItems = filteredChildren.slice(indexOfFirstItem, indexOfLastItem);
  const totalPages = Math.ceil(filteredChildren.length / itemsPerPage);

  const handleSearchChange = (e) => {
    setSearchTerm(e.target.value);
    setCurrentPage(1);
  };

  return (
    <MainLayout>
      <div className="p-6">
        <h1 className="text-2xl font-bold text-gray-800 mb-2">Pilih Anak untuk Pelayanan LILA</h1>
        <p className="text-gray-500 text-sm mb-6">Pilih anak dari daftar berikut untuk mengelola pencatatan Lingkar Lengan Atas (LILA).</p>

        <div className="bg-white rounded-t-2xl border-x border-t border-gray-100 p-6">
          <div className="relative w-full max-w-md">
            <Search className="absolute left-3 top-1/2 -transform -translate-y-1/2 text-gray-400" size={18} />
            <input
              type="text"
              placeholder="Cari nama anak atau nama ibu..."
              className="pl-10 pr-4 py-2.5 border border-gray-200 rounded-xl w-full focus:ring-2 focus:ring-indigo-500 outline-none text-sm"
              onChange={handleSearchChange}
            />
          </div>
        </div>

        <div className="bg-white rounded-b-2xl shadow-sm border border-gray-100 overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-gray-50/50 border-y border-gray-100 text-gray-500 uppercase text-[10px] tracking-widest font-black">
                <th className="px-6 py-4">Nama Anak</th>
                <th className="px-6 py-4">Jenis Kelamin</th>
                <th className="px-6 py-4">Tanggal Lahir</th>
                <th className="px-6 py-4">Usia</th>
                <th className="px-6 py-4">Nama Ibu</th>
                <th className="px-6 py-4 text-center">Aksi</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-50">
              {loading ? (
                <tr><td colSpan="6" className="p-6 text-center">Memuat data...</td></tr>
              ) : currentItems.length === 0 ? (
                <tr><td colSpan="6" className="p-6 text-center text-gray-400">Tidak ada data ditemukan</td></tr>
              ) : (
                currentItems.map((child) => (
                  <tr key={child.id} className="hover:bg-indigo-50/20">
                    <td className="px-6 py-4 font-bold text-gray-800 text-sm">{child.nama}</td>
                    <td className="px-6 py-4">
                      <span className={`px-3 py-1 rounded-full text-[10px] font-bold uppercase border ${
                        child.jenis_kelamin === 'laki-laki' ? 'bg-blue-50 text-blue-700 border-blue-100' : 'bg-pink-50 text-pink-700 border-pink-100'
                      }`}>
                        {child.jenis_kelamin}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-xs">{formatDate(child.tanggal_lahir)}</td>
                    <td className="px-6 py-4 text-xs font-bold">{child.usia_teks || "-"}</td>
                    <td className="px-6 py-4 text-sm font-semibold">{child.kehamilan?.ibu?.nama_ibu || "-"}</td>
                    <td className="px-6 py-4 text-center">
                      <Link to={`/data-anak/lila/${child.id}`} className="inline-flex items-center gap-1 bg-indigo-600 text-white px-4 py-2 rounded-lg text-xs font-bold shadow-sm hover:bg-indigo-700">
                        <Activity size={14} /> Kelola LILA
                      </Link>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>

          <div className="flex items-center justify-between px-6 py-4 bg-gray-50/50 border-t border-gray-100">
            <p className="text-xs text-gray-500 font-medium">
              Menampilkan <span className="text-indigo-600">{indexOfFirstItem + 1}</span> - <span className="text-indigo-600">{Math.min(indexOfLastItem, filteredChildren.length)}</span> dari <span className="text-indigo-600">{filteredChildren.length}</span> data
            </p>
            <div className="flex gap-2">
              <button
                onClick={() => setCurrentPage(p => Math.max(p - 1, 1))}
                disabled={currentPage === 1}
                className="p-2 border rounded-lg disabled:opacity-50"
              >
                <ChevronLeft size={16} />
              </button>
              <button
                onClick={() => setCurrentPage(p => Math.min(p + 1, totalPages))}
                disabled={currentPage === totalPages || totalPages === 0}
                className="p-2 border rounded-lg disabled:opacity-50"
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