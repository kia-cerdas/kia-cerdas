import React, { useState, useEffect, useCallback } from "react";
import {
  Plus, Trash2, Edit, Search, X, Filter,
  ChevronLeft, ChevronRight, RefreshCw
} from "lucide-react";
import Swal from "sweetalert2";
import MainLayout from "../../components/Layout/MainLayout";
import {
  getPendudukWithFilters,
  getPendudukById,
  createKependudukan,
  updateKependudukan,
  deleteKependudukan
} from "../../services/kependudukan";
import { listDesa } from "../../services/desa";
import { getAllPosyandu } from "../../services/posyandu";
import FormPendudukAccordion from "./components/FormPendudukAccordion";
import { formatNik, formatKodeKeluarga } from "../../utils/format";

const STATUS_OPTIONS = ["", "Kawin", "Belum Kawin", "Cerai Hidup", "Cerai Mati"];
const HUBUNGAN_OPTIONS = ["", "Kepala Keluarga", "Istri", "Anak", "Menantu", "Cucu", "Orang Tua", "Mertua", "Keluarga Lainnya"];

const cardClass = "bg-white rounded-2xl shadow-sm border border-slate-100";

const HUBUNGAN_ORDER = {
  "Kepala Keluarga": 1, "Istri": 2, "Suami": 2, "Anak": 3,
  "Menantu": 4, "Cucu": 5, "Orang Tua": 6, "Mertua": 7, "Keluarga Lainnya": 8,
};

const sortPenduduk = (a, b) => {
  const kodeA = (a.kode_keluarga || "ZZZ").toLowerCase();
  const kodeB = (b.kode_keluarga || "ZZZ").toLowerCase();
  if (kodeA !== kodeB) return kodeA.localeCompare(kodeB);
  const orderA = HUBUNGAN_ORDER[a.hubungan] ?? 99;
  const orderB = HUBUNGAN_ORDER[b.hubungan] ?? 99;
  if (orderA !== orderB) return orderA - orderB;
  return (a.nama_anggota_keluarga || "").localeCompare(b.nama_anggota_keluarga || "");
};

const Modal = ({ isOpen, onClose, title, children }) => {
  if (!isOpen) return null;
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm">
      <div className="bg-white rounded-2xl shadow-xl max-w-4xl w-full max-h-[90vh] overflow-y-auto">
        <div className="sticky top-0 bg-white border-b border-slate-200 px-6 py-4 flex items-center justify-between z-10">
          <h2 className="text-xl font-semibold text-slate-800">{title}</h2>
          <button onClick={onClose} className="p-2 hover:bg-slate-100 rounded-full transition-colors">
            <X size={20} className="text-slate-500" />
          </button>
        </div>
        <div className="p-6">{children}</div>
      </div>
    </div>
  );
};

const AdminPendudukList = () => {
  const [penduduks, setPenduduks] = useState([]);
  const [pagination, setPagination] = useState({ page: 1, limit: 10, total: 0, total_pages: 1 });
  const [loading, setLoading] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [desasList, setDesasList] = useState([]);
  const [posyanduList, setPosyanduList] = useState([]);
  const [showModal, setShowModal] = useState(false);
  const [editingData, setEditingData] = useState(null);
  const [search, setSearch] = useState("");
  const [filters, setFilters] = useState({
    rw: "", rt: "", dusun: "", kode_keluarga: "",
    status: "", hubungan: "", desa_id: "", posyandu_id: "",
  });
  const [showFilters, setShowFilters] = useState(false);

  const getDesaNameById = useCallback((desaId) => {
    const desa = desasList.find(d => d.id === desaId);
    return desa?.nama_desa || "-";
  }, [desasList]);

  const fetchData = useCallback(async (params = {}) => {
    setLoading(true);
    try {
      const result = await getPendudukWithFilters({
        page: pagination.page,
        limit: pagination.limit,
        search: search || undefined,
        ...filters,
        ...params,
      });

      const items = Array.isArray(result) ? result : (result?.items || []);

      if (Array.isArray(result)) {
        setPenduduks([...result].sort(sortPenduduk));
        setPagination(prev => ({
          ...prev,
          total: result.length,
          total_pages: Math.ceil(result.length / prev.limit) || 1,
        }));
      } else if (result?.items !== undefined) {
        setPenduduks([...(result.items || [])].sort(sortPenduduk));
        setPagination(result.pagination || { page: 1, limit: 10, total: 0, total_pages: 1 });
      } else {
        setPenduduks([]);
        setPagination({ page: 1, limit: 10, total: 0, total_pages: 1 });
      }
    } catch (error) {
      Swal.fire({
        icon: "error",
        title: "Gagal Memuat Data",
        text: error?.message || "Terjadi kesalahan saat memuat data penduduk.",
        confirmButtonColor: "#4f46e5",
      });
    } finally {
      setLoading(false);
    }
  }, [pagination.page, pagination.limit, search, filters]);

  useEffect(() => {
    const fetchMaster = async () => {
      try {
        const [desas, posyandus] = await Promise.all([listDesa(), getAllPosyandu()]);
        setDesasList(desas || []);
        setPosyanduList(posyandus || []);
      } catch {
        Swal.fire({
          icon: "warning",
          title: "Peringatan",
          text: "Gagal memuat data master (desa/posyandu). Beberapa pilihan mungkin tidak tersedia.",
          confirmButtonColor: "#4f46e5",
        });
      }
    };
    fetchMaster();
  }, []);

  useEffect(() => {
    fetchData();
  }, [pagination.page, pagination.limit]);

  const handleSearch = () => fetchData({ page: 1 });

  const handleSearchKeyDown = (e) => {
    if (e.key === "Enter") handleSearch();
  };

  const handleFilterChange = (e) => {
    const { name, value } = e.target;
    setFilters(prev => ({ ...prev, [name]: value }));
  };

  const applyFilters = () => {
    setShowFilters(false);
    fetchData({ page: 1 });
  };

  const clearFilters = () => {
    setFilters({ rw: "", rt: "", dusun: "", kode_keluarga: "", status: "", hubungan: "", desa_id: "", posyandu_id: "" });
    setSearch("");
    fetchData({ page: 1, search: undefined, rw: "", rt: "", dusun: "", kode_keluarga: "", status: "", hubungan: "", desa_id: "", posyandu_id: "" });
  };

  const handleCreate = () => {
    setEditingData(null);
    setShowModal(true);
  };

  const handleEdit = async (data) => {
    const id = data.id || data.IDKependudukan;
    try {
      const fullData = await getPendudukById(id);
      setEditingData(fullData);
      setShowModal(true);
    } catch {
      setEditingData(data);
      setShowModal(true);
    }
  };

  const handleDelete = async (id, name) => {
    const result = await Swal.fire({
      icon: "warning",
      title: "Hapus Data Penduduk?",
      html: `Data <strong>${name || "ini"}</strong> akan dihapus secara permanen dan tidak dapat dikembalikan.`,
      showCancelButton: true,
      confirmButtonColor: "#ef4444",
      cancelButtonColor: "#6b7280",
      confirmButtonText: "Ya, Hapus",
      cancelButtonText: "Batal",
    });

    if (!result.isConfirmed) return;

    try {
      await deleteKependudukan(id);
      Swal.fire({
        icon: "success",
        title: "Berhasil Dihapus",
        text: `Data ${name || "penduduk"} telah dihapus.`,
        timer: 1800,
        showConfirmButton: false,
      });
      fetchData();
    } catch (error) {
      Swal.fire({
        icon: "error",
        title: "Gagal Menghapus",
        text: error?.message || "Terjadi kesalahan saat menghapus data.",
        confirmButtonColor: "#4f46e5",
      });
    }
  };

  const handleSubmit = async (formData) => {
    setSubmitting(true);
    try {
      let tanggalLahir = "";
      if (formData.tanggal_lahir) {
        try {
          tanggalLahir = new Date(formData.tanggal_lahir).toISOString();
        } catch {
          tanggalLahir = formData.tanggal_lahir;
        }
      }

      const payload = {
        rw: formData.rw || "",
        rt: formData.rt || "",
        dusun: formData.dusun || "",
        alamat: formData.alamat || "",
        kode_keluarga: formData.kode_keluarga || "",
        nama_kepala_keluarga: formData.nama_kepala_keluarga || "",
        nik: formData.nik || "",
        nama_anggota_keluarga: formData.nama_anggota_keluarga || "",
        jenis_kelamin: formData.jenis_kelamin || "Laki-laki",
        hubungan: formData.hubungan || "",
        tempat_lahir: formData.tempat_lahir || "",
        tanggal_lahir: tanggalLahir,
        status: formData.status || "",
        agama: formData.agama || "",
        golongan_darah: formData.golongan_darah || "",
        kewarganegaraan: formData.kewarganegaraan || "WNI",
        etnis_suku: formData.etnis_suku || "",
        pendidikan: formData.pendidikan || "",
        pekerjaan: formData.pekerjaan || "",
        telepon: formData.telepon || "",
        desa_id: formData.desa_id ? parseInt(formData.desa_id, 10) : null,
        posyandu_id: formData.posyandu_id ? parseInt(formData.posyandu_id, 10) : null,
      };

      if (editingData) {
        const id = editingData.id || editingData.IDKependudukan;
        await updateKependudukan(id, payload);
        Swal.fire({
          icon: "success",
          title: "Data Diperbarui",
          text: "Data penduduk berhasil diperbarui.",
          timer: 1800,
          showConfirmButton: false,
        });
      } else {
        await createKependudukan(payload);
        Swal.fire({
          icon: "success",
          title: "Data Ditambahkan",
          text: "Data penduduk baru berhasil disimpan.",
          timer: 1800,
          showConfirmButton: false,
        });
      }

      setShowModal(false);
      setEditingData(null);
      fetchData();
    } catch (error) {
      let errorText = "Gagal menyimpan data.";
      if (error.response?.data?.message) {
        const msg = error.response.data.message;
        errorText = Array.isArray(msg) ? msg.join(", ") : msg;
      } else if (error.message) {
        errorText = error.message;
      }
      Swal.fire({
        icon: "error",
        title: "Gagal Menyimpan",
        text: errorText,
        confirmButtonColor: "#4f46e5",
      });
    } finally {
      setSubmitting(false);
    }
  };

  const handlePageChange = (newPage) => {
    if (newPage < 1 || newPage > pagination.total_pages) return;
    setPagination(prev => ({ ...prev, page: newPage }));
  };

  const formatDate = (dateStr) => {
    if (!dateStr) return "-";
    try {
      const date = new Date(dateStr);
      if (date.getFullYear() <= 1) return "-";
      return date.toLocaleDateString("id-ID", { day: "2-digit", month: "2-digit", year: "numeric" });
    } catch {
      return dateStr;
    }
  };

  return (
    <MainLayout>
      <div className="space-y-6">
        {/* Search & Filter Bar */}
        <div className="flex flex-wrap items-center gap-3">
          <div className="flex-1 min-w-[200px] relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
            <input
              type="text"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              onKeyDown={handleSearchKeyDown}
              placeholder="Cari NIK, Nama, atau Kode Keluarga..."
              className="w-full pl-10 pr-4 py-2 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>
          <button
            onClick={handleSearch}
            className="px-4 py-2 rounded-xl bg-indigo-600 text-white hover:bg-indigo-700 transition-colors"
          >
            Cari
          </button>
          <button
            onClick={() => setShowFilters(!showFilters)}
            className="inline-flex items-center gap-2 px-4 py-2 rounded-xl border border-slate-200 text-slate-600 hover:bg-slate-50 transition-colors"
          >
            <Filter size={16} />
            Filter
          </button>
          <button
            onClick={clearFilters}
            className="inline-flex items-center gap-2 px-4 py-2 rounded-xl border border-slate-200 text-slate-600 hover:bg-slate-50 transition-colors"
          >
            <RefreshCw size={16} />
            Refresh
          </button>
          <button
            onClick={handleCreate}
            className="inline-flex items-center gap-2 rounded-xl bg-indigo-600 text-white px-4 py-2 text-sm font-medium hover:bg-indigo-700 transition-colors"
          >
            <Plus size={16} />
            Tambah Penduduk
          </button>
        </div>

        {/* Filter Panel */}
        {showFilters && (
          <div className={`${cardClass} p-5 grid grid-cols-2 md:grid-cols-4 gap-4`}>
            {[
              { label: "RW", name: "rw", type: "text", placeholder: "RW" },
              { label: "RT", name: "rt", type: "text", placeholder: "RT" },
              { label: "Dusun", name: "dusun", type: "text", placeholder: "Dusun" },
              { label: "Kode Keluarga", name: "kode_keluarga", type: "text", placeholder: "KK-2024-001" },
            ].map(({ label, name, type, placeholder }) => (
              <div key={name}>
                <label className="text-sm text-slate-600">{label}</label>
                <input
                  type={type}
                  name={name}
                  value={filters[name]}
                  onChange={handleFilterChange}
                  className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500"
                  placeholder={placeholder}
                />
              </div>
            ))}
            <div>
              <label className="text-sm text-slate-600">Status</label>
              <select name="status" value={filters.status} onChange={handleFilterChange} className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500">
                <option value="">Semua</option>
                {STATUS_OPTIONS.filter(s => s).map(opt => <option key={opt} value={opt}>{opt}</option>)}
              </select>
            </div>
            <div>
              <label className="text-sm text-slate-600">Hubungan</label>
              <select name="hubungan" value={filters.hubungan} onChange={handleFilterChange} className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500">
                <option value="">Semua</option>
                {HUBUNGAN_OPTIONS.filter(s => s).map(opt => <option key={opt} value={opt}>{opt}</option>)}
              </select>
            </div>
            <div>
              <label className="text-sm text-slate-600">Desa</label>
              <select name="desa_id" value={filters.desa_id} onChange={handleFilterChange} className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500">
                <option value="">Semua Desa</option>
                {desasList.map(d => <option key={d.id} value={d.id}>{d.nama_desa}</option>)}
              </select>
            </div>
            <div>
              <label className="text-sm text-slate-600">Posyandu</label>
              <select name="posyandu_id" value={filters.posyandu_id} onChange={handleFilterChange} className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500">
                <option value="">Semua Posyandu</option>
                {posyanduList.map(p => <option key={p.id} value={p.id}>{p.nama}</option>)}
              </select>
            </div>
            <div className="col-span-2 md:col-span-4 flex justify-end gap-2 pt-2">
              <button onClick={clearFilters} className="px-4 py-2 rounded-xl border border-slate-200 text-slate-600 hover:bg-slate-50">Reset</button>
              <button onClick={applyFilters} className="px-4 py-2 rounded-xl bg-indigo-600 text-white hover:bg-indigo-700">Terapkan Filter</button>
            </div>
          </div>
        )}

        {/* Table */}
        <div className={`${cardClass} overflow-hidden`}>
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-slate-50 border-b border-slate-200">
                <tr>
                  {["No", "NIK", "Nama", "Jenis Kelamin", "Hubungan", "Kode Keluarga", "Desa", "Aksi"].map((h, i) => (
                    <th key={h} className={`px-4 py-3 text-xs font-semibold text-slate-600 uppercase tracking-wider ${i === 7 ? "text-center" : "text-left"}`}>{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {loading ? (
                  <tr><td colSpan="8" className="px-4 py-10 text-center text-slate-400">
                    <div className="flex flex-col items-center gap-2">
                      <div className="w-6 h-6 border-2 border-indigo-500 border-t-transparent rounded-full animate-spin" />
                      <span className="text-sm">Memuat data...</span>
                    </div>
                  </td></tr>
                ) : penduduks.length === 0 ? (
                  <tr><td colSpan="8" className="px-4 py-10 text-center text-slate-400 text-sm">Tidak ada data yang ditemukan</td></tr>
                ) : (
                  penduduks.map((item, index) => {
                    const itemId = item.id || item.IDKependudukan || index;
                    return (
                      <tr key={itemId} className="hover:bg-slate-50 transition-colors">
                        <td className="px-4 py-3 text-sm text-slate-500">{(pagination.page - 1) * pagination.limit + index + 1}</td>
                        <td className="px-4 py-3 text-sm font-mono text-slate-700">{formatNik(item.nik)}</td>
                        <td className="px-4 py-3 text-sm font-medium text-slate-800">{item.nama_anggota_keluarga || item.nama_lengkap || "-"}</td>
                        <td className="px-4 py-3 text-sm text-slate-600">{item.jenis_kelamin || "-"}</td>
                        <td className="px-4 py-3 text-sm text-slate-600">{item.hubungan || "-"}</td>
                        <td className="px-4 py-3 text-sm font-mono text-slate-600">{formatKodeKeluarga(item.kode_keluarga)}</td>
                        <td className="px-4 py-3 text-sm text-slate-600">
                          {item.desa?.nama_desa || (item.desa_id ? getDesaNameById(item.desa_id) : "-")}
                        </td>
                        <td className="px-4 py-3 text-center">
                          <div className="flex items-center justify-center gap-2">
                            <button onClick={() => handleEdit(item)} className="p-1.5 rounded-lg text-blue-600 hover:bg-blue-50 transition-colors" title="Edit">
                              <Edit size={16} />
                            </button>
                            <button onClick={() => handleDelete(itemId, item.nama_anggota_keluarga || item.nama_lengkap)} className="p-1.5 rounded-lg text-red-600 hover:bg-red-50 transition-colors" title="Hapus">
                              <Trash2 size={16} />
                            </button>
                          </div>
                        </td>
                      </tr>
                    );
                  })
                )}
              </tbody>
            </table>
          </div>

          {/* Pagination */}
          {pagination.total > 0 && (
            <div className="px-4 py-3 border-t border-slate-200 flex items-center justify-between">
              <span className="text-sm text-slate-500">
                Menampilkan {((pagination.page - 1) * pagination.limit) + 1}–{Math.min(pagination.page * pagination.limit, pagination.total)} dari {pagination.total} data
              </span>
              <div className="flex items-center gap-2">
                <button onClick={() => handlePageChange(pagination.page - 1)} disabled={pagination.page === 1} className="p-2 rounded-lg border border-slate-200 disabled:opacity-40 disabled:cursor-not-allowed hover:bg-slate-50">
                  <ChevronLeft size={16} />
                </button>
                <span className="text-sm text-slate-600">Hal. {pagination.page} / {pagination.total_pages}</span>
                <button onClick={() => handlePageChange(pagination.page + 1)} disabled={pagination.page === pagination.total_pages} className="p-2 rounded-lg border border-slate-200 disabled:opacity-40 disabled:cursor-not-allowed hover:bg-slate-50">
                  <ChevronRight size={16} />
                </button>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Modal Create / Edit */}
      <Modal
        isOpen={showModal}
        onClose={() => { setShowModal(false); setEditingData(null); }}
        title={editingData ? "Edit Data Penduduk" : "Tambah Data Penduduk"}
      >
        <FormPendudukAccordion
          initialData={editingData}
          onSubmit={handleSubmit}
          onCancel={() => { setShowModal(false); setEditingData(null); }}
          submitting={submitting}
          desasList={desasList}
          posyanduList={posyanduList}
        />
      </Modal>
    </MainLayout>
  );
};

export default AdminPendudukList;
