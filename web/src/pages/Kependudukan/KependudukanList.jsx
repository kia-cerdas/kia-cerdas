import React, { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import MainLayout from "../../components/Layout/MainLayout";
import { getKependudukanList, deleteKependudukan } from "../../services/kependudukan";
import { Plus, Edit, Trash2, Search, ChevronLeft, ChevronRight, Filter, ChevronsLeft, ChevronsRight } from "lucide-react";

export default function KependudukanList() {
  const [data, setData] = useState([]);
  const [search, setSearch] = useState("");
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 10;
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      const res = await getKependudukanList();
      setData(res);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (id, nama) => {
    if (window.confirm(`Hapus data ${nama}?`)) {
      try {
        await deleteKependudukan(id);
        fetchData();
      } catch (err) {
        alert("Gagal menghapus");
      }
    }
  };

  const filtered = data.filter((item) =>
    item.nama_lengkap?.toLowerCase().includes(search.toLowerCase()) ||
    item.nik?.includes(search)
  ).sort((a, b) => (b.id_kependudukan || 0) - (a.id_kependudukan || 0));
  const totalPages = Math.ceil(filtered.length / itemsPerPage);
  const currentItems = filtered.slice((currentPage - 1) * itemsPerPage, currentPage * itemsPerPage);

  return (
    <MainLayout>
      <div className="p-3 md:p-4">
        <div className="flex justify-between items-center mb-4">
          <h1 className="text-lg md:text-xl font-bold">Manajemen Kartu Keluarga (KK)</h1>
          <Link to="/kependudukan/create" className="bg-indigo-600 text-white px-4 py-2 rounded-xl flex items-center gap-2 hover:bg-indigo-700 transition text-xs md:text-sm flex-shrink-0 whitespace-nowrap">
            <Plus size={16} /> Tambah
          </Link>
        </div>

        <div className="flex flex-col lg:flex-row justify-between gap-3 mb-4">
          <div className="relative w-full lg:w-56">
            <Search className="absolute left-3 top-2.5 text-gray-400" size={16} />
            <input
              type="text"
              placeholder="Cari nama atau NIK"
              className="pl-9 pr-4 py-2 border rounded-xl w-full text-sm focus:ring-2 focus:ring-indigo-300"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
          </div>
        </div>
        {loading ? (
          <div className="bg-white rounded-xl shadow-sm overflow-hidden">
            <table className="w-full min-w-[760px] table-fixed">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-2.5 py-2.5 text-left text-sm">Nama Lengkap</th>
                  <th className="px-2.5 py-2.5 text-left text-sm">NIK</th>
                  <th className="px-2.5 py-2.5 text-left text-sm">No. KK</th>
                  <th className="px-2.5 py-2.5 text-left text-sm">Dusun</th>
                  <th className="px-2.5 py-2.5 text-center text-sm">Aksi</th>
                </tr>
              </thead>
              <tbody>
                {Array(5).fill(0).map((_, i) => (
                  <tr key={i} className="border-t">
                    {Array(5).fill(0).map((_, j) => (
                      <td key={j} className="px-2.5 py-2.5">
                        <div className="h-5 bg-gray-200 rounded animate-pulse"></div>
                      </td>
                    ))}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        ) : currentItems.length === 0 ? (
          <div className="text-center py-12 bg-white rounded-xl shadow-sm">
            <p className="text-gray-500">Tidak ada data</p>
            <button
              onClick={() => {
                setSearch("");
                setCurrentPage(1);
              }}
              className="text-indigo-600 mt-2 hover:underline text-sm"
            >
              Reset filter
            </button>
          </div>
        ) : (
          <div className="bg-white rounded-xl shadow-sm overflow-hidden">
            <table className="w-full table-fixed">
              <thead className="bg-gray-50 sticky top-0">
                <tr>
                  <th className="px-2.5 py-2.5 text-left text-sm">Nama Lengkap</th>
                  <th className="px-2.5 py-2.5 text-left text-sm">NIK</th>
                  <th className="px-2.5 py-2.5 text-left text-sm">No. KK</th>
                  <th className="px-2.5 py-2.5 text-left text-sm">Dusun</th>
                  <th className="px-2.5 py-2.5 text-center text-sm">Aksi</th>
                </tr>
              </thead>
              <tbody>
                {currentItems.map((item) => (
                  <tr key={item.id_kependudukan} className="border-t hover:bg-gray-50 transition">
                    <td className="px-2.5 py-2.5 font-medium align-middle text-sm">
                      {item.nama_lengkap}
                      <div className="text-[11px] text-gray-400">ID: {item.id_kependudukan}</div>
                    </td>
                    <td className="px-2.5 py-2.5 text-sm align-middle">{item.nik}</td>
                    <td className="px-2.5 py-2.5 text-sm align-middle">{item.kartu_keluarga_id || "-"}</td>
                    <td className="px-2.5 py-2.5 text-sm align-middle">{item.dusun}</td>
                    <td className="px-2.5 py-2.5 text-center align-middle">
                      <div className="flex items-center justify-center gap-2 text-sm whitespace-nowrap">
                        <Link to={`/kependudukan/edit/${item.id_kependudukan}`} className="text-yellow-600 hover:underline flex items-center gap-1">
                          <Edit size={14} /> Edit
                        </Link>
                        <button onClick={() => handleDelete(item.id_kependudukan, item.nama_lengkap)} className="text-red-600 hover:underline flex items-center gap-1">
                          <Trash2 size={14} /> Hapus
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
        {!loading && currentItems.length > 0 && (
          <div className="flex flex-col sm:flex-row justify-between items-center gap-3 p-3 bg-white rounded-xl shadow-sm mt-3">
            <div className="flex items-center gap-2">
              <span className="text-xs md:text-sm text-gray-600">Tampilkan</span>
              <span className="text-xs md:text-sm text-gray-600">per halaman</span>
            </div>

            <div className="text-xs md:text-sm text-gray-600">
              {((currentPage - 1) * itemsPerPage) + 1} - {Math.min(currentPage * itemsPerPage, filtered.length)} dari {filtered.length}
            </div>

            <div className="flex items-center gap-2">
              <button
                onClick={() => setCurrentPage(1)}
                disabled={currentPage === 1}
                className="p-1 disabled:opacity-50"
              >
                <ChevronsLeft size={16} />
              </button>
              <button
                onClick={() => setCurrentPage(p => Math.max(p - 1, 1))}
                disabled={currentPage === 1}
                className="p-1 disabled:opacity-50"
              >
                <ChevronLeft size={16} />
              </button>
              <span className="text-xs md:text-sm">
                Halaman {currentPage} / {totalPages || 1}
              </span>
              <button
                onClick={() => setCurrentPage(p => Math.min(p + 1, totalPages))}
                disabled={currentPage === totalPages}
                className="p-1 disabled:opacity-50"
              >
                <ChevronRight size={16} />
              </button>
              <button
                onClick={() => setCurrentPage(totalPages)}
                disabled={currentPage === totalPages}
                className="p-1 disabled:opacity-50"
              >
                <ChevronsRight size={16} />
              </button>
            </div>
          </div>
        )}
      </div>
    </MainLayout>
  );
}