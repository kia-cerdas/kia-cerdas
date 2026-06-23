import React, { useEffect, useMemo, useState } from "react";
import MainLayout from "../../components/Layout/MainLayout";
import Pagination from "../../components/Pagination/Pagination";
import {
  listProvinsi, createProvinsi, updateProvinsi, deleteProvinsi,
  listKabupaten, createKabupaten, updateKabupaten, deleteKabupaten,
  listKecamatan, createKecamatan, updateKecamatan, deleteKecamatan,
  wilayahErrorMessage,
} from "../../services/wilayah";
import Swal from "sweetalert2";
import { Plus, Pencil, Trash2, X, MapPinned, Building2, Map, Search } from "lucide-react";

const TABS = [
  { key: "provinsi", label: "Provinsi", icon: Map },
  { key: "kabupaten", label: "Kabupaten", icon: Building2 },
  { key: "kecamatan", label: "Kecamatan", icon: MapPinned },
];

export default function KelolaWilayah() {
  const [activeTab, setActiveTab] = useState("provinsi");
  const [search, setSearch] = useState("");

  // Pagination state
  const [currentPage, setCurrentPage] = useState(1);
  const [itemsPerPage] = useState(10);

  const [provinsi, setProvinsi] = useState([]);
  const [kabupaten, setKabupaten] = useState([]);
  const [kecamatan, setKecamatan] = useState([]);
  const [loading, setLoading] = useState(true);

  // Modal state
  const [showModal, setShowModal] = useState(false);
  const [editItem, setEditItem] = useState(null); // item being edited, or null for create
  const [form, setForm] = useState({ nama: "", provinsi_id: "", kabupaten_id: "" });
  const [submitting, setSubmitting] = useState(false);

  const fetchAll = async () => {
    try {
      setLoading(true);
      const [prov, kab, kec] = await Promise.all([
        listProvinsi(),
        listKabupaten(),
        listKecamatan(),
      ]);
      setProvinsi(prov);
      setKabupaten(kab);
      setKecamatan(kec);
    } catch (error) {
      Swal.fire("Error", wilayahErrorMessage(error, "Gagal memuat data wilayah"), "error");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchAll();
  }, []);

  // Kabupaten ter-filter berdasarkan provinsi_id terpilih (untuk cascading di form kecamatan)
  const kabupatenForForm = useMemo(() => {
    if (!form.provinsi_id) return [];
    return kabupaten.filter((k) => String(k.provinsi_id) === String(form.provinsi_id));
  }, [kabupaten, form.provinsi_id]);

  const openCreate = () => {
    setEditItem(null);
    setForm({ nama: "", provinsi_id: "", kabupaten_id: "" });
    setShowModal(true);
  };

  const openEdit = (item) => {
    setEditItem(item);
    if (activeTab === "provinsi") {
      setForm({ nama: item.nama, provinsi_id: "", kabupaten_id: "" });
    } else if (activeTab === "kabupaten") {
      setForm({ nama: item.nama, provinsi_id: String(item.provinsi_id), kabupaten_id: "" });
    } else {
      // kecamatan: prefill provinsi dari kabupaten induk
      const kab = kabupaten.find((k) => String(k.id) === String(item.kabupaten_id));
      setForm({
        nama: item.nama,
        provinsi_id: kab ? String(kab.provinsi_id) : "",
        kabupaten_id: String(item.kabupaten_id),
      });
    }
    setShowModal(true);
  };

  const closeModal = () => {
    setShowModal(false);
    setEditItem(null);
    setForm({ nama: "", provinsi_id: "", kabupaten_id: "" });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!form.nama.trim()) {
      Swal.fire("Peringatan", "Nama wajib diisi", "warning");
      return;
    }
    if (activeTab === "kabupaten" && !form.provinsi_id) {
      Swal.fire("Peringatan", "Provinsi wajib dipilih", "warning");
      return;
    }
    if (activeTab === "kecamatan" && !form.kabupaten_id) {
      Swal.fire("Peringatan", "Kabupaten wajib dipilih", "warning");
      return;
    }

    try {
      setSubmitting(true);
      if (activeTab === "provinsi") {
        const payload = { nama: form.nama.trim() };
        if (editItem) await updateProvinsi(editItem.id, payload);
        else await createProvinsi(payload);
      } else if (activeTab === "kabupaten") {
        const payload = { nama: form.nama.trim(), provinsi_id: Number(form.provinsi_id) };
        if (editItem) await updateKabupaten(editItem.id, payload);
        else await createKabupaten(payload);
      } else {
        const payload = { nama: form.nama.trim(), kabupaten_id: Number(form.kabupaten_id) };
        if (editItem) await updateKecamatan(editItem.id, payload);
        else await createKecamatan(payload);
      }
      Swal.fire("Berhasil", `Data ${activeTab} berhasil disimpan`, "success");
      closeModal();
      fetchAll();
    } catch (error) {
      Swal.fire("Error", wilayahErrorMessage(error, "Gagal menyimpan data"), "error");
    } finally {
      setSubmitting(false);
    }
  };

  const handleDelete = async (item) => {
    const result = await Swal.fire({
      title: `Hapus ${activeTab}?`,
      text: `Hapus "${item.nama}"?`,
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#ef4444",
      confirmButtonText: "Hapus",
      cancelButtonText: "Batal",
    });
    if (!result.isConfirmed) return;

    try {
      if (activeTab === "provinsi") await deleteProvinsi(item.id);
      else if (activeTab === "kabupaten") await deleteKabupaten(item.id);
      else await deleteKecamatan(item.id);
      Swal.fire("Dihapus", "Data berhasil dihapus", "success");
      fetchAll();
    } catch (error) {
      Swal.fire("Error", wilayahErrorMessage(error, "Gagal menghapus data"), "error");
    }
  };

  // Lookup nama provinsi/kabupaten untuk kolom tabel
  const provinsiNama = (id) => provinsi.find((p) => String(p.id) === String(id))?.nama || "-";
  const kabupatenNama = (id) => kabupaten.find((k) => String(k.id) === String(id))?.nama || "-";

  const allRows = activeTab === "provinsi" ? provinsi : activeTab === "kabupaten" ? kabupaten : kecamatan;

  // Filter berdasarkan kata kunci (nama wilayah, dan nama induk untuk kabupaten/kecamatan)
  const rows = useMemo(() => {
    const keyword = search.trim().toLowerCase();
    if (!keyword) return allRows;
    return allRows.filter((item) => {
      const parts = [item.nama];
      if (activeTab === "kabupaten") {
        parts.push(provinsiNama(item.provinsi_id));
      } else if (activeTab === "kecamatan") {
        parts.push(kabupatenNama(item.kabupaten_id));
        const kab = kabupaten.find((k) => String(k.id) === String(item.kabupaten_id));
        if (kab) parts.push(provinsiNama(kab.provinsi_id));
      }
      return parts.filter(Boolean).some((v) => String(v).toLowerCase().includes(keyword));
    });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [allRows, search, activeTab, provinsi, kabupaten]);

  // Paginated data
  const paginatedRows = useMemo(() => {
    const startIndex = (currentPage - 1) * itemsPerPage;
    const endIndex = startIndex + itemsPerPage;
    return rows.slice(startIndex, endIndex);
  }, [rows, currentPage, itemsPerPage]);

  // Reset to page 1 when tab or search changes
  useEffect(() => {
    setCurrentPage(1);
  }, [activeTab, search]);

  return (
    <MainLayout>
      <div className="px-4 pb-6 pt-0 md:px-6">
        {/* Tabs */}
        <div className="flex flex-wrap items-center gap-2 mb-4">
          {TABS.map((tab) => {
            const Icon = tab.icon;
            const isActive = activeTab === tab.key;
            return (
              <button
                key={tab.key}
                onClick={() => { setActiveTab(tab.key); setSearch(""); }}
                className={`inline-flex items-center gap-2 rounded-2xl px-4 py-2 text-sm font-semibold transition-colors ${
                  isActive ? "bg-indigo-600 text-white" : "bg-white border border-slate-200 text-slate-600 hover:bg-slate-50"
                }`}
              >
                <Icon size={16} />
                {tab.label}
              </button>
            );
          })}
          <div className="ml-auto flex items-center gap-3">
            <div className="relative w-56 md:w-72">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
              <input
                type="text"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                placeholder={`Cari ${TABS.find((t) => t.key === activeTab)?.label.toLowerCase()}...`}
                className="w-full pl-10 pr-4 py-2 rounded-2xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-indigo-500 text-sm"
              />
            </div>
            <button
              type="button"
              className="inline-flex items-center gap-2 rounded-2xl bg-indigo-600 px-4 py-2 text-sm font-semibold text-white hover:bg-indigo-700 transition-colors"
            >
              <Search className="w-4 h-4" />
              Cari
            </button>
            <button
              onClick={openCreate}
              className="inline-flex items-center gap-2 bg-indigo-600 text-white px-4 py-2 rounded-2xl hover:bg-indigo-700 transition text-sm font-semibold"
            >
              <Plus size={16} />
              Tambah {TABS.find((t) => t.key === activeTab)?.label}
            </button>
          </div>
        </div>

        {/* Table */}
        <div className="bg-white rounded-xl border border-slate-200 overflow-hidden shadow-sm">
          {loading ? (
            <div className="p-10 text-center text-slate-500">Memuat data...</div>
          ) : rows.length === 0 ? (
            <div className="p-10 text-center text-slate-500">
              {search ? `Tidak ada ${activeTab} yang cocok dengan pencarian` : `Belum ada data ${activeTab}`}
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead className="bg-slate-50 border-b border-slate-200">
                  <tr>
                    <th className="px-4 py-3 text-left text-xs font-semibold text-slate-700">No</th>
                    <th className="px-4 py-3 text-left text-xs font-semibold text-slate-700">Nama {TABS.find((t) => t.key === activeTab)?.label}</th>
                    {activeTab === "kabupaten" && (
                      <th className="px-4 py-3 text-left text-xs font-semibold text-slate-700">Provinsi</th>
                    )}
                    {activeTab === "kecamatan" && (
                      <>
                        <th className="px-4 py-3 text-left text-xs font-semibold text-slate-700">Kabupaten</th>
                        <th className="px-4 py-3 text-left text-xs font-semibold text-slate-700">Provinsi</th>
                      </>
                    )}
                    <th className="px-4 py-3 text-center text-xs font-semibold text-slate-700">Aksi</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100">
                  {paginatedRows.map((item, index) => {
                    const kab = activeTab === "kecamatan" ? kabupaten.find((k) => String(k.id) === String(item.kabupaten_id)) : null;
                    return (
                      <tr key={item.id} className="hover:bg-slate-50/70">
                        <td className="px-4 py-3 text-sm text-slate-700">{(currentPage - 1) * itemsPerPage + index + 1}</td>
                        <td className="px-4 py-3 text-sm font-medium text-slate-900">{item.nama}</td>
                        {activeTab === "kabupaten" && (
                          <td className="px-4 py-3 text-sm text-slate-600">{provinsiNama(item.provinsi_id)}</td>
                        )}
                        {activeTab === "kecamatan" && (
                          <>
                            <td className="px-4 py-3 text-sm text-slate-600">{kabupatenNama(item.kabupaten_id)}</td>
                            <td className="px-4 py-3 text-sm text-slate-600">{kab ? provinsiNama(kab.provinsi_id) : "-"}</td>
                          </>
                        )}
                        <td className="px-4 py-3">
                          <div className="flex items-center justify-center gap-2">
                            <button onClick={() => openEdit(item)} className="p-2 text-indigo-600 hover:bg-indigo-50 rounded-lg" title="Edit">
                              <Pencil className="w-4 h-4" />
                            </button>
                            <button onClick={() => handleDelete(item)} className="p-2 text-red-600 hover:bg-red-50 rounded-lg" title="Hapus">
                              <Trash2 className="w-4 h-4" />
                            </button>
                          </div>
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          )}

          {/* Pagination */}
          {!loading && rows.length > 0 && (
            <Pagination
              currentPage={currentPage}
              totalPages={Math.ceil(rows.length / itemsPerPage)}
              totalItems={rows.length}
              itemsPerPage={itemsPerPage}
              onPageChange={(page) => setCurrentPage(page)}
              loading={loading}
            />
          )}
        </div>
      </div>

      {/* Modal */}
      {showModal && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-xl shadow-xl w-full max-w-md">
            <div className="flex items-center justify-between p-6 border-b border-gray-200">
              <h2 className="text-xl font-bold text-gray-800">
                {editItem ? "Edit" : "Tambah"} {TABS.find((t) => t.key === activeTab)?.label}
              </h2>
              <button onClick={closeModal} className="text-gray-400 hover:text-gray-600">
                <X className="w-6 h-6" />
              </button>
            </div>

            <form onSubmit={handleSubmit} className="p-6 space-y-4">
              {/* Provinsi dropdown (untuk kabupaten & kecamatan) */}
              {(activeTab === "kabupaten" || activeTab === "kecamatan") && (
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Provinsi <span className="text-red-500">*</span>
                  </label>
                  <select
                    value={form.provinsi_id}
                    onChange={(e) => setForm({ ...form, provinsi_id: e.target.value, kabupaten_id: "" })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
                    required
                  >
                    <option value="">Pilih Provinsi</option>
                    {provinsi.map((p) => (
                      <option key={p.id} value={p.id}>{p.nama}</option>
                    ))}
                  </select>
                </div>
              )}

              {/* Kabupaten dropdown (untuk kecamatan, cascading) */}
              {activeTab === "kecamatan" && (
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Kabupaten <span className="text-red-500">*</span>
                  </label>
                  <select
                    value={form.kabupaten_id}
                    onChange={(e) => setForm({ ...form, kabupaten_id: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent disabled:bg-gray-100"
                    disabled={!form.provinsi_id}
                    required
                  >
                    <option value="">{form.provinsi_id ? "Pilih Kabupaten" : "Pilih provinsi dulu"}</option>
                    {kabupatenForForm.map((k) => (
                      <option key={k.id} value={k.id}>{k.nama}</option>
                    ))}
                  </select>
                </div>
              )}

              {/* Nama */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Nama {TABS.find((t) => t.key === activeTab)?.label} <span className="text-red-500">*</span>
                </label>
                <input
                  type="text"
                  value={form.nama}
                  onChange={(e) => setForm({ ...form, nama: e.target.value })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
                  placeholder={`Masukkan nama ${activeTab}`}
                  required
                />
              </div>

              <div className="flex gap-3 pt-4">
                <button type="button" onClick={closeModal} className="flex-1 px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50">
                  Batal
                </button>
                <button type="submit" disabled={submitting} className="flex-1 px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 disabled:opacity-60">
                  {submitting ? "Menyimpan..." : editItem ? "Update" : "Simpan"}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </MainLayout>
  );
}
