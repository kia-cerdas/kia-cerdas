import React, { useEffect, useState } from "react";
import MainLayout from "../../components/Layout/MainLayout";
import {
  getVaksinList,
  createVaksin,
  updateVaksin,
  deleteVaksin,
  getDosisByVaksinId,
  createDosisVaksin,
  updateDosisVaksin,
  deleteDosisVaksin,
} from "../../services/vaksin";
import {
  Syringe,
  Plus,
  Pencil,
  Trash2,
  ChevronDown,
  ChevronRight,
  X,
  ShieldCheck,
} from "lucide-react";
import Swal from "sweetalert2";

const KelolaVaksin = () => {
  // ==================== VAKSIN STATE ====================
  const [vaksinList, setVaksinList] = useState([]);
  const [loading, setLoading] = useState(true);
  const [expandedId, setExpandedId] = useState(null);

  // Vaksin modal
  const [showVaksinModal, setShowVaksinModal] = useState(false);
  const [editingVaksin, setEditingVaksin] = useState(null);
  const [vaksinForm, setVaksinForm] = useState({
    nama: "",
    deskripsi: "",
    efek_samping: "",
  });

  // ==================== DOSIS STATE ====================
  const [dosisList, setDosisList] = useState({});
  const [showDosisModal, setShowDosisModal] = useState(false);
  const [editingDosis, setEditingDosis] = useState(null);
  const [dosisForm, setDosisForm] = useState({
    nama_dosis: "",
    vaksin_id: "",
    jumlah_dosis: "",
  });

  // ==================== FETCH DATA ====================
  const fetchVaksin = async () => {
    try {
      setLoading(true);
      const data = await getVaksinList();
      setVaksinList(Array.isArray(data) ? data : []);
    } catch (err) {
      console.error("Gagal memuat data vaksin:", err);
      Swal.fire("Error", "Gagal memuat data vaksin", "error");
    } finally {
      setLoading(false);
    }
  };

  const fetchDosis = async (vaksinId) => {
    try {
      const data = await getDosisByVaksinId(vaksinId);
      setDosisList((prev) => ({
        ...prev,
        [vaksinId]: Array.isArray(data) ? data : [],
      }));
    } catch (err) {
      console.error("Gagal memuat dosis:", err);
    }
  };

  useEffect(() => {
    fetchVaksin();
  }, []);

  // ==================== VAKSIN CRUD ====================
  const openCreateVaksin = () => {
    setEditingVaksin(null);
    setVaksinForm({ nama: "", deskripsi: "", efek_samping: "" });
    setShowVaksinModal(true);
  };

  const openEditVaksin = (v) => {
    setEditingVaksin(v);
    setVaksinForm({
      nama: v.nama || "",
      deskripsi: v.deskripsi || "",
      efek_samping: v.efek_samping || "",
    });
    setShowVaksinModal(true);
  };

  const handleSaveVaksin = async (e) => {
    e.preventDefault();
    try {
      if (editingVaksin) {
        await updateVaksin(editingVaksin.id, vaksinForm);
        Swal.fire("Berhasil", "Vaksin berhasil diupdate", "success");
      } else {
        await createVaksin(vaksinForm);
        Swal.fire("Berhasil", "Vaksin berhasil ditambahkan", "success");
      }
      setShowVaksinModal(false);
      fetchVaksin();
    } catch (err) {
      Swal.fire("Error", err?.response?.data?.error || "Gagal menyimpan vaksin", "error");
    }
  };

  const handleDeleteVaksin = async (v) => {
    const result = await Swal.fire({
      title: "Hapus Vaksin?",
      text: `Apakah Anda yakin ingin menghapus "${v.nama}"?`,
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#ef4444",
      confirmButtonText: "Hapus",
      cancelButtonText: "Batal",
    });
    if (result.isConfirmed) {
      try {
        await deleteVaksin(v.id);
        Swal.fire("Dihapus", "Vaksin berhasil dihapus", "success");
        fetchVaksin();
      } catch (err) {
        Swal.fire("Error", "Gagal menghapus vaksin", "error");
      }
    }
  };

  // ==================== DOSIS CRUD ====================
  const toggleExpand = (vaksinId) => {
    if (expandedId === vaksinId) {
      setExpandedId(null);
    } else {
      setExpandedId(vaksinId);
      if (!dosisList[vaksinId]) {
        fetchDosis(vaksinId);
      }
    }
  };

  const openCreateDosis = (vaksinId) => {
    setEditingDosis(null);
    setDosisForm({ nama_dosis: "", vaksin_id: vaksinId, jumlah_dosis: "" });
    setShowDosisModal(true);
  };

  const openEditDosis = (d) => {
    setEditingDosis(d);
    setDosisForm({
      nama_dosis: d.nama_dosis || "",
      vaksin_id: d.vaksin_id || d.vaksin?.id || "",
      jumlah_dosis: d.jumlah_dosis || "",
    });
    setShowDosisModal(true);
  };

  const handleSaveDosis = async (e) => {
    e.preventDefault();
    try {
      if (editingDosis) {
        await updateDosisVaksin(editingDosis.id, dosisForm);
        Swal.fire("Berhasil", "Dosis berhasil diupdate", "success");
      } else {
        await createDosisVaksin(dosisForm);
        Swal.fire("Berhasil", "Dosis berhasil ditambahkan", "success");
      }
      setShowDosisModal(false);
      fetchDosis(dosisForm.vaksin_id);
    } catch (err) {
      Swal.fire("Error", err?.response?.data?.error || "Gagal menyimpan dosis", "error");
    }
  };

  const handleDeleteDosis = async (d) => {
    const result = await Swal.fire({
      title: "Hapus Dosis?",
      text: `Apakah Anda yakin ingin menghapus "${d.nama_dosis}"?`,
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#ef4444",
      confirmButtonText: "Hapus",
      cancelButtonText: "Batal",
    });
    if (result.isConfirmed) {
      try {
        await deleteDosisVaksin(d.id);
        Swal.fire("Dihapus", "Dosis berhasil dihapus", "success");
        fetchDosis(d.vaksin_id);
      } catch (err) {
        Swal.fire("Error", "Gagal menghapus dosis", "error");
      }
    }
  };

  // ==================== RENDER ====================
  return (
    <MainLayout>
      <div className="p-6">
        {/* Header */}
        <div className="flex items-center justify-between mb-6">
          <div className="flex items-center gap-3">
            <div className="p-3 rounded-xl bg-blue-100 text-blue-700">
              <Syringe className="w-7 h-7" />
            </div>
            <div>
              <h1 className="text-2xl font-bold text-gray-800">Kelola Vaksin & Dosis</h1>
              <p className="text-gray-500 text-sm">
                Kelola data vaksin dan dosis vaksin untuk imunisasi
              </p>
            </div>
          </div>
          <button
            onClick={openCreateVaksin}
            className="flex items-center gap-2 px-4 py-2.5 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700 transition-colors shadow-sm"
          >
            <Plus className="w-4 h-4" />
            Tambah Vaksin
          </button>
        </div>

        {/* Vaksin Table */}
        {loading ? (
          <div className="text-center py-12 text-gray-400">Memuat data vaksin...</div>
        ) : vaksinList.length === 0 ? (
          <div className="text-center py-12 text-gray-400">
            Belum ada data vaksin. Klik "Tambah Vaksin" untuk menambahkan.
          </div>
        ) : (
          <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
            <table className="w-full text-sm">
              <thead className="bg-gray-50 border-b border-gray-100">
                <tr>
                  <th className="text-left py-3 px-4 font-semibold text-gray-600 w-10"></th>
                  <th className="text-left py-3 px-4 font-semibold text-gray-600">Nama Vaksin</th>
                  <th className="text-left py-3 px-4 font-semibold text-gray-600">Deskripsi</th>
                  <th className="text-left py-3 px-4 font-semibold text-gray-600">Efek Samping</th>
                  <th className="text-center py-3 px-4 font-semibold text-gray-600 w-32">Aksi</th>
                </tr>
              </thead>
              <tbody>
                {vaksinList.map((v) => (
                  <React.Fragment key={v.id}>
                    {/* Vaksin Row */}
                    <tr className="border-b border-gray-50 hover:bg-gray-50 transition-colors">
                      <td className="py-3 px-4">
                        <button
                          onClick={() => toggleExpand(v.id)}
                          className="p-1 rounded hover:bg-gray-200 transition-colors"
                        >
                          {expandedId === v.id ? (
                            <ChevronDown className="w-4 h-4 text-gray-500" />
                          ) : (
                            <ChevronRight className="w-4 h-4 text-gray-500" />
                          )}
                        </button>
                      </td>
                      <td className="py-3 px-4 font-medium text-gray-800">{v.nama}</td>
                      <td className="py-3 px-4 text-gray-600 max-w-xs truncate">
                        {v.deskripsi || "-"}
                      </td>
                      <td className="py-3 px-4 text-gray-600 max-w-xs truncate">
                        {v.efek_samping || "-"}
                      </td>
                      <td className="py-3 px-4">
                        <div className="flex items-center justify-center gap-2">
                          <button
                            onClick={() => openEditVaksin(v)}
                            className="p-1.5 rounded-lg hover:bg-blue-50 text-blue-600 transition-colors"
                            title="Edit"
                          >
                            <Pencil className="w-4 h-4" />
                          </button>
                          <button
                            onClick={() => handleDeleteVaksin(v)}
                            className="p-1.5 rounded-lg hover:bg-red-50 text-red-500 transition-colors"
                            title="Hapus"
                          >
                            <Trash2 className="w-4 h-4" />
                          </button>
                        </div>
                      </td>
                    </tr>

                    {/* Expanded Dosis Rows */}
                    {expandedId === v.id && (
                      <tr>
                        <td colSpan={5} className="bg-gray-50 px-6 py-4">
                          <div className="flex items-center justify-between mb-3">
                            <h3 className="text-sm font-semibold text-gray-700 flex items-center gap-2">
                              <ShieldCheck className="w-4 h-4 text-purple-600" />
                              Dosis Vaksin
                            </h3>
                            <button
                              onClick={() => openCreateDosis(v.id)}
                              className="flex items-center gap-1 px-3 py-1.5 bg-purple-600 text-white rounded-lg text-xs font-medium hover:bg-purple-700 transition-colors"
                            >
                              <Plus className="w-3 h-3" />
                              Tambah Dosis
                            </button>
                          </div>

                          {dosisList[v.id]?.length > 0 ? (
                            <table className="w-full text-sm bg-white rounded-lg overflow-hidden border border-gray-200">
                              <thead className="bg-purple-50">
                                <tr>
                                  <th className="text-left py-2 px-4 font-medium text-purple-700">
                                    No
                                  </th>
                                  <th className="text-left py-2 px-4 font-medium text-purple-700">
                                    Nama Dosis
                                  </th>
                                  <th className="text-left py-2 px-4 font-medium text-purple-700">
                                    Jumlah Dosis
                                  </th>
                                  <th className="text-center py-2 px-4 font-medium text-purple-700 w-24">
                                    Aksi
                                  </th>
                                </tr>
                              </thead>
                              <tbody>
                                {dosisList[v.id].map((d, idx) => (
                                  <tr
                                    key={d.id}
                                    className="border-t border-gray-100 hover:bg-gray-50"
                                  >
                                    <td className="py-2 px-4 text-gray-500">{idx + 1}</td>
                                    <td className="py-2 px-4 text-gray-800">{d.nama_dosis}</td>
                                    <td className="py-2 px-4 text-gray-600">{d.jumlah_dosis || "-"}</td>
                                    <td className="py-2 px-4">
                                      <div className="flex items-center justify-center gap-2">
                                        <button
                                          onClick={() => openEditDosis(d)}
                                          className="p-1 rounded hover:bg-blue-50 text-blue-600 transition-colors"
                                          title="Edit"
                                        >
                                          <Pencil className="w-3.5 h-3.5" />
                                        </button>
                                        <button
                                          onClick={() => handleDeleteDosis(d)}
                                          className="p-1 rounded hover:bg-red-50 text-red-500 transition-colors"
                                          title="Hapus"
                                        >
                                          <Trash2 className="w-3.5 h-3.5" />
                                        </button>
                                      </div>
                                    </td>
                                  </tr>
                                ))}
                              </tbody>
                            </table>
                          ) : (
                            <p className="text-gray-400 text-sm text-center py-3">
                              Belum ada dosis untuk vaksin ini.
                            </p>
                          )}
                        </td>
                      </tr>
                    )}
                  </React.Fragment>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* ==================== VAKSIN MODAL ==================== */}
      {showVaksinModal && (
        <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">
          <div className="bg-white rounded-2xl shadow-xl w-full max-w-md mx-4">
            <div className="flex items-center justify-between p-5 border-b border-gray-100">
              <h2 className="text-lg font-semibold text-gray-800">
                {editingVaksin ? "Edit Vaksin" : "Tambah Vaksin"}
              </h2>
              <button
                onClick={() => setShowVaksinModal(false)}
                className="p-1 rounded-lg hover:bg-gray-100 transition-colors"
              >
                <X className="w-5 h-5 text-gray-500" />
              </button>
            </div>
            <form onSubmit={handleSaveVaksin} className="p-5 space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Nama Vaksin <span className="text-red-500">*</span>
                </label>
                <input
                  type="text"
                  value={vaksinForm.nama}
                  onChange={(e) => setVaksinForm({ ...vaksinForm, nama: e.target.value })}
                  className="w-full px-3 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  placeholder="Contoh: BCG"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Deskripsi
                </label>
                <textarea
                  value={vaksinForm.deskripsi}
                  onChange={(e) => setVaksinForm({ ...vaksinForm, deskripsi: e.target.value })}
                  className="w-full px-3 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  rows={3}
                  placeholder="Deskripsi vaksin..."
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Efek Samping
                </label>
                <textarea
                  value={vaksinForm.efek_samping}
                  onChange={(e) =>
                    setVaksinForm({ ...vaksinForm, efek_samping: e.target.value })
                  }
                  className="w-full px-3 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  rows={3}
                  placeholder="Efek samping vaksin..."
                />
              </div>
              <div className="flex justify-end gap-3 pt-2">
                <button
                  type="button"
                  onClick={() => setShowVaksinModal(false)}
                  className="px-4 py-2.5 border border-gray-200 rounded-lg text-sm text-gray-600 hover:bg-gray-50 transition-colors"
                >
                  Batal
                </button>
                <button
                  type="submit"
                  className="px-5 py-2.5 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700 transition-colors"
                >
                  {editingVaksin ? "Update" : "Simpan"}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* ==================== DOSIS MODAL ==================== */}
      {showDosisModal && (
        <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">
          <div className="bg-white rounded-2xl shadow-xl w-full max-w-md mx-4">
            <div className="flex items-center justify-between p-5 border-b border-gray-100">
              <h2 className="text-lg font-semibold text-gray-800">
                {editingDosis ? "Edit Dosis" : "Tambah Dosis"}
              </h2>
              <button
                onClick={() => setShowDosisModal(false)}
                className="p-1 rounded-lg hover:bg-gray-100 transition-colors"
              >
                <X className="w-5 h-5 text-gray-500" />
              </button>
            </div>
            <form onSubmit={handleSaveDosis} className="p-5 space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Nama Dosis <span className="text-red-500">*</span>
                </label>
                <input
                  type="text"
                  value={dosisForm.nama_dosis}
                  onChange={(e) => setDosisForm({ ...dosisForm, nama_dosis: e.target.value })}
                  className="w-full px-3 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  placeholder="Contoh: Dosis 1"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Jumlah Dosis
                </label>
                <input
                  type="text"
                  value={dosisForm.jumlah_dosis}
                  onChange={(e) => setDosisForm({ ...dosisForm, jumlah_dosis: e.target.value })}
                  className="w-full px-3 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  placeholder="Contoh: 0.5 ml"
                />
              </div>
              <div className="flex justify-end gap-3 pt-2">
                <button
                  type="button"
                  onClick={() => setShowDosisModal(false)}
                  className="px-4 py-2.5 border border-gray-200 rounded-lg text-sm text-gray-600 hover:bg-gray-50 transition-colors"
                >
                  Batal
                </button>
                <button
                  type="submit"
                  className="px-5 py-2.5 bg-purple-600 text-white rounded-lg text-sm font-medium hover:bg-purple-700 transition-colors"
                >
                  {editingDosis ? "Update" : "Simpan"}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </MainLayout>
  );
};

export default KelolaVaksin;
