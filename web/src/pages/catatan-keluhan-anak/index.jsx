import React, { useState, useEffect } from "react";
import MainLayout from "../../components/Layout/MainLayout";
import { Link, useNavigate, useParams } from "react-router-dom";
import { getPelayananKesehatanAnak, deletePelayananKesehatanAnak } from "../../services/PelayananKesehatanAnak";
import {
  Plus, Search, Pencil, Trash2, ChevronLeft, ChevronRight,
  Eye, Calendar, Stethoscope
} from "lucide-react";

export default function PelayananKesehatanAnakList() {
  const navigate = useNavigate();
  const { anakID } = useParams(); // dari URL jika datang dari halaman detail anak
  
  const [kunjungan, setKunjungan] = useState([]);
  const [searchTerm, setSearchTerm] = useState("");
  const [loading, setLoading] = useState(true);
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 10;

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        const res = await getPelayananKesehatanAnak(anakID || null);
        console.log("DATA DARI BACKEND:", res); // Cek Inspect Element -> tab Console
        setKunjungan(res.data || []);
      } catch (error) {
        console.error("Error fetching data:", error);
        alert("Gagal memuat data kunjungan. Silakan coba lagi.");
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, [anakID]);

  const handleDelete = async (id, namaAnak) => {
    if (!window.confirm(`Apakah Anda yakin ingin menghapus kunjungan ${namaAnak || 'anak ini'}?`)) return;
    try {
      await deletePelayananKesehatanAnak(id);
      setKunjungan((prev) => prev.filter((item) => item.id !== id));
      alert("Data kunjungan berhasil dihapus!");
    } catch (error) {
      alert("Gagal menghapus data. Silakan coba lagi.");
    }
  };

  const formatDate = (dateString) => {
    if (!dateString) return "-";
    const date = new Date(dateString);
    return date.toLocaleDateString("id-ID", {
      day: "numeric", month: "long", year: "numeric",
    });
  };

  // Filter & Pagination (Sudah diperbaiki)
  const filteredData = kunjungan.filter((k) => {
    const searchLower = searchTerm.toLowerCase();
    const namaAnak = (k.anak?.nama || "").toLowerCase();
    const namaKategori = (k.kategori_umur?.Kategori_umur || "").toLowerCase();

    return namaAnak.includes(searchLower) || namaKategori.includes(searchLower);
  });

  const indexOfLastItem = currentPage * itemsPerPage;
  const indexOfFirstItem = indexOfLastItem - itemsPerPage;
  const currentItems = filteredData.slice(indexOfFirstItem, indexOfLastItem);
  const totalPages = Math.ceil(filteredData.length / itemsPerPage);

  const handleSearchChange = (e) => {
    setSearchTerm(e.target.value);
    setCurrentPage(1);
  };

  return (
    <MainLayout>
      {/* BREADCRUMB */}
      <nav className="flex items-center text-sm text-gray-500 mb-6 gap-2 bg-white p-3 rounded-lg shadow-sm border border-gray-100 w-fit">
        <Link to="/dashboard" className="hover:text-indigo-600 flex items-center gap-1">
          Dashboard
        </Link>
        <ChevronRight size={14} />
        <span className="font-semibold text-indigo-700">Pencatatan Pelayanan Kesehatan Anak</span>
      </nav>

      <div className="flex flex-col md:flex-row md:items-end justify-between gap-4 mb-8">
        <div>
          <h1 className="text-2xl font-bold text-gray-800 tracking-tight">Daftar Kunjungan Pelayanan Kesehatan Anak</h1>
          <p className="text-gray-500 text-sm">Kelola data pencatatan pelayanan kesehatan anak oleh bidan.</p>
        </div>
        
        <div className="bg-gradient-to-br from-indigo-600 to-indigo-700 text-white px-6 py-3 rounded-2xl shadow-lg shadow-indigo-100 flex items-center gap-4">
          <div className="p-2 bg-white/20 rounded-xl">
            <Stethoscope size={24} />
          </div>
          <div>
            <p className="text-[10px] text-indigo-100 font-bold uppercase tracking-wider">Total Kunjungan</p>
            <p className="text-2xl font-black">{kunjungan.length}</p>
          </div>
        </div>
      </div>

      <div className="bg-white rounded-t-2xl border-x border-t border-gray-100 p-6">
        <div className="flex flex-col md:flex-row justify-between gap-4">
          <div className="relative w-full max-w-md">
            <Search className="absolute left-3 top-1/2 -transform -translate-y-1/2 text-gray-400" size={18} />
            <input
              type="text"
              placeholder="Cari nama anak atau kategori umur..."
              className="pl-10 pr-4 py-2.5 border border-gray-200 rounded-xl w-full focus:ring-2 focus:ring-indigo-500 outline-none transition-all text-sm"
              onChange={handleSearchChange}
            />
          </div>
          <Link
            to={anakID ? `/pelayanan-kesehatan-anak/create/${anakID}` : "/pelayanan-kesehatan-anak/create"}
            className="bg-indigo-600 hover:bg-indigo-700 text-white px-6 py-2.5 rounded-xl flex items-center justify-center gap-2 font-bold transition-all shadow-md active:scale-95"
          >
            <Plus size={20} /> Tambah Kunjungan
          </Link>
        </div>
      </div>

      <div className="bg-white rounded-b-2xl shadow-sm border border-gray-100 overflow-x-auto">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="bg-gray-50/50 border-y border-gray-100 text-gray-500 uppercase text-[10px] tracking-widest font-black">
              <th className="px-6 py-4">Nama Anak</th>
              <th className="px-6 py-4">Kategori Umur</th>
              <th className="px-6 py-4">Tanggal Periksa</th>
              <th className="px-6 py-4">Periode</th>
              <th className="px-6 py-4">Lokasi</th>
              <th className="px-6 py-4 text-center">Aksi</th>
            </tr>
          </thead>

          <tbody className="divide-y divide-gray-50">
            {loading ? (
              [...Array(3)].map((_, i) => (
                <tr key={i} className="animate-pulse">
                  <td colSpan="6" className="p-6 text-center">Memuat data...</td>
                </tr>
              ))
            ) : currentItems.length === 0 ? (
              <tr>
                <td colSpan="6" className="text-center py-20">
                  <p className="text-gray-400">Tidak ada data kunjungan ditemukan</p>
                </td>
              </tr>
            ) : (
              currentItems.map((item) => (
                <tr key={item.id} className="hover:bg-indigo-50/20 transition-colors group">
                  {/* UBAH: dari item.anak?.nama menjadi item.anak?.nama_anak */}
                  <td className="px-6 py-4 font-bold text-gray-800 text-sm">
                    {item.anak?.nama_anak || "-"}
                  </td>
                  
                  <td className="px-6 py-4">
                    <span className="px-3 py-1 rounded-full text-[10px] font-bold uppercase bg-indigo-50 text-indigo-700 border border-indigo-100">
                      {/* UBAH: K-nya kecil, sesuai tag JSON di model Golang */}
                      {item.kategori_umur?.kategori_umur || "-"}
                    </span>
                  </td>
                  
                  <td className="px-6 py-4 text-sm">{formatDate(item.tanggal)}</td>
                  {/* UBAH: pastikan periode mengambil properti yang tepat, misalnya nama_periode, tergantung model Anda */}
                  <td className="px-6 py-4 text-sm font-semibold">{item.periode?.nama || "-"}</td>
                  <td className="px-6 py-4 text-sm">{item.lokasi || "-"}</td>
                  
                  <td className="px-6 py-4">
                    <div className="flex items-center justify-center gap-2">
                      <Link
                        to={`/pelayanan-kesehatan-anak/detail/${item.id}`}
                        className="p-1.5 text-gray-400 hover:text-indigo-600 transition-colors"
                        title="Lihat Detail"
                      >
                        <Eye size={16} />
                      </Link>
                      <Link
                        to={`/pelayanan-kesehatan-anak/edit/${item.id}`}
                        className="p-1.5 text-gray-400 hover:text-amber-600 transition-colors"
                        title="Edit"
                      >
                        <Pencil size={16} />
                      </Link>
                      {/* (Sudah diperbaiki: menggunakan item.anak?.nama) */}
                      <button
                        onClick={() => handleDelete(item.id, item.anak?.nama)}
                        className="p-1.5 text-gray-400 hover:text-red-600 transition-colors"
                        title="Hapus"
                      >
                        <Trash2 size={16} />
                      </button>
                    </div>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>

        {/* PAGINATION */}
        <div className="flex items-center justify-between px-6 py-4 bg-gray-50/50 border-t border-gray-100">
          <p className="text-xs text-gray-500 font-medium">
            Menampilkan <span className="text-indigo-600">{filteredData.length > 0 ? indexOfFirstItem + 1 : 0}</span> - <span className="text-indigo-600">{Math.min(indexOfLastItem, filteredData.length)}</span> dari <span className="text-indigo-600">{filteredData.length}</span> data
          </p>
          
          <div className="flex items-center gap-2">
            <button
              onClick={() => setCurrentPage(prev => Math.max(prev - 1, 1))}
              disabled={currentPage === 1}
              className="p-2 rounded-lg border border-gray-200 bg-white text-gray-600 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed transition-all"
            >
              <ChevronLeft size={16} />
            </button>
            
            <div className="flex gap-1">
              {[...Array(totalPages)].map((_, i) => (
                <button
                  key={i}
                  onClick={() => setCurrentPage(i + 1)}
                  className={`w-8 h-8 rounded-lg text-xs font-bold transition-all ${
                    currentPage === i + 1 
                    ? "bg-indigo-600 text-white shadow-md shadow-indigo-100" 
                    : "bg-white border border-gray-200 text-gray-600 hover:bg-gray-50"
                  }`}
                >
                  {i + 1}
                </button>
              ))}
            </div>

            <button
              onClick={() => setCurrentPage(prev => Math.min(prev + 1, totalPages))}
              disabled={currentPage === totalPages || totalPages === 0}
              className="p-2 rounded-lg border border-gray-200 bg-white text-gray-600 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed transition-all"
            >
              <ChevronRight size={16} />
            </button>
          </div>
        </div>
      </div>
    </MainLayout>
  );
}