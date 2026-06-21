import React, { useEffect, useMemo, useState } from "react";
import MainLayout from "../../components/Layout/MainLayout";
import AlertNotification from "../../components/AlertNotification";
import Swal from "sweetalert2";
import { Search, Plus, Pencil, Trash2, X, Check, RotateCcw } from "lucide-react";
import { getRentangUsia } from "../../services/pemantauanAnak";
import {
  getKategoriCapaianList,
  createKategoriCapaian,
  updateKategoriCapaian,
  deleteKategoriCapaian,
} from "../../services/perawatan";

export default function KelolaPerkembangan() {
  const [kategoriUmurList, setKategoriUmurList] = useState([]);
  const [activeKategoriUsia, setActiveKategoriUsia] = useState("");
  const [query, setQuery] = useState("");
  const [dataIndikator, setDataIndikator] = useState({});
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [selectedItem, setSelectedItem] = useState(null);
  const [formKategoriUsia, setFormKategoriUsia] = useState("");
  const [formDeskripsi, setFormDeskripsi] = useState("");
  const [formAspek, setFormAspek] = useState("motorik");
  const [formMode, setFormMode] = useState("add");
  const [isLoading, setIsLoading] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [notice, setNotice] = useState("");
  const [errorMsg, setErrorMsg] = useState("");
  const [clickedBtn, setClickedBtn] = useState({ id: null, type: null });
  const [notification, setNotification] = useState(null);

  const normalizeKategoriUmur = (items) => {
    return (Array.isArray(items) ? items : []).map((item) => ({
      ...item,
      label: item?.kategori_umur || item?.KategoriUmur || item?.nama_rentang || item?.nama || "Kategori Umur",
    }));
  };

  useEffect(() => {
    const init = async () => {
      try {
        const list = normalizeKategoriUmur(await getRentangUsia());
        setKategoriUmurList(list);

        if (list.length > 0) {
          setActiveKategoriUsia(list[0].label);
          setFormKategoriUsia(list[0].label);
        }
      } catch (error) {
        setErrorMsg("Gagal memuat kategori umur");
      }
    };

    init();
  }, []);

  useEffect(() => {
    if (!activeKategoriUsia) return;

    const timeoutId = setTimeout(() => {
      fetchData(activeKategoriUsia, query);
    }, 250);

    return () => clearTimeout(timeoutId);
  }, [activeKategoriUsia, query]);

  const fetchData = async (kategoriUsia, searchQuery) => {
    setIsLoading(true);
    setErrorMsg("");

    try {
      const allRows = await getKategoriCapaianList(kategoriUsia);
      // Filter client-side based on search query
      const filtered = (Array.isArray(allRows) ? allRows : []).filter((row) =>
        (row.pertanyaan_ceklist || "").toLowerCase().includes(searchQuery.toLowerCase()) ||
        (row.aspek || "").toLowerCase().includes(searchQuery.toLowerCase())
      );

      setDataIndikator((prev) => ({
        ...prev,
        [kategoriUsia]: filtered,
      }));
    } catch (error) {
      setDataIndikator((prev) => ({
        ...prev,
        [kategoriUsia]: [],
      }));
      setErrorMsg("Gagal memuat data indikator");
    } finally {
      setIsLoading(false);
    }
  };

  const currentData = useMemo(() => {
    return dataIndikator[activeKategoriUsia] || [];
  }, [activeKategoriUsia, dataIndikator]);

  const openAddModal = () => {
    setFormMode("add");
    setSelectedItem(null);
    setFormKategoriUsia(activeKategoriUsia || kategoriUmurList[0]?.label || "");
    setFormDeskripsi("");
    setFormAspek("motorik");
    setIsModalOpen(true);
  };

  const openEditModal = (item) => {
    setFormMode("edit");
    setSelectedItem(item);
    setFormKategoriUsia(item.rentang_usia || activeKategoriUsia || "");
    setFormDeskripsi(item.pertanyaan_ceklist || "");
    setFormAspek(item.aspek || "motorik");
    setIsModalOpen(true);
  };

  const closeModal = () => {
    setIsModalOpen(false);
    setSelectedItem(null);
    setFormKategoriUsia(activeKategoriUsia || kategoriUmurList[0]?.label || "");
    setFormDeskripsi("");
    setFormAspek("motorik");
  };

  const handleSave = async () => {
    if (isSubmitting) return;

    const kategoriUsia = formKategoriUsia.trim();
    const deskripsi = formDeskripsi.trim();

    if (!kategoriUsia) {
      setErrorMsg("Kategori umur wajib dipilih");
      return;
    }
    if (!deskripsi) {
      setErrorMsg("Deskripsi indikator wajib diisi");
      return;
    }

    const matchedKategori = kategoriUmurList.find((k) => k.label === kategoriUsia);
    if (!matchedKategori) {
      setErrorMsg("Kategori umur tidak valid");
      return;
    }

    setIsSubmitting(true);
    setErrorMsg("");
    setNotice("");

    try {
      const payload = {
        rentang_usia: formKategoriUsia.trim(),
        pertanyaan_ceklist: deskripsi,
        aspek: formAspek,
      };

      if (formMode === "edit" && selectedItem) {
        await updateKategoriCapaian(selectedItem.id, payload);
        setNotification({
          type: "success",
          message: "Data indikator perkembangan anak berhasil diperbarui ke dalam sistem!"
        });
      } else {
        await createKategoriCapaian(payload);
        setNotification({
          type: "success",
          message: "Data indikator perkembangan anak berhasil ditambahkan ke dalam sistem!"
        });
      }

      closeModal();
      await fetchData(activeKategoriUsia || kategoriUsia, query);
    } catch (error) {
      const errMsg = error?.response?.data?.message || error.message || "Unknown error";
      setNotification({
        type: "error",
        message: "Permintaan gagal diproses. Silakan coba lagi nanti atau hubungi bantuan.",
        code: errMsg
      });
    } finally {
      setIsSubmitting(false);
    }
  };

  const openDeleteModal = async (item) => {
    const result = await Swal.fire({
      title: "Hapus Indikator Perawatan?",
      text: `"${item.pertanyaan_ceklist || item.deskripsi || ""}" akan dihapus permanen dan tidak dapat dikembalikan.`,
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#EF4444",
      cancelButtonColor: "#6B7280",
      confirmButtonText: "Ya, Hapus",
      cancelButtonText: "Batal",
    });
    if (!result.isConfirmed) return;

    try {
      await deleteKategoriCapaian(item.id);
      setNotification({
        type: "success",
        message: "Data indikator perawatan anak berhasil dihapus dari sistem.",
      });
      await fetchData(activeKategoriUsia, query);
    } catch (error) {
      const errMsg = error?.response?.data?.message || error.message || "Unknown error";
      setNotification({
        type: "error",
        message: "Permintaan gagal diproses. Silakan coba lagi nanti.",
        code: errMsg,
      });
    }
  };

  // Alias untuk kompatibilitas dengan JSX yang memanggil openDeleteModal
  const closeDeleteModal = () => {};
  const handleDelete = () => {};

  return (
    <MainLayout>
      <AlertNotification 
        notification={notification} 
        onClose={() => setNotification(null)} 
        onRetry={notification?.type === "error" ? () => setNotification(null) : null}
      />
      <div className="max-w-6xl mx-auto space-y-6">
        <div className="flex justify-between items-start gap-4 flex-col md:flex-row">
          <div className="flex items-center gap-4 w-full">
            <div className="relative w-full md:w-64">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" size={16} />
              <input
                type="text"
                placeholder="Cari indikator..."
                className="w-full pl-9 pr-4 py-2.5 bg-white border border-[#e2e8f0] rounded-xl text-sm focus:outline-none focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5] transition-all"
                value={query}
                onChange={(e) => setQuery(e.target.value)}
              />
            </div>
            <div className="flex-1">
              <h1 className="text-xl font-bold text-slate-800">Kelola Perawatan Anak</h1>
              <p className="text-sm text-slate-500">Mengatur indikator checklist perkembangan perawatan anak.</p>
            </div>
          </div>
          <button
            onClick={openAddModal}
            className="inline-flex items-center gap-2 px-4 py-2 bg-[#185FA5] hover:bg-[#185FA5]/90 text-white text-sm font-semibold rounded-xl transition-all active:scale-95 shadow-sm flex-shrink-0"
          >
            <Plus size={16} /> Tambah Indikator
          </button>
        </div>

        {notice ? (
          <div className="rounded-xl border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm text-emerald-700">
            {notice}
          </div>
        ) : null}

        {errorMsg ? (
          <div className="rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
            {errorMsg}
          </div>
        ) : null}

        {/* Tab Selector */}
        <div className="bg-slate-100/50 p-1 rounded-xl flex gap-1">
          {kategoriUmurList.map((kategori) => (
            <button
              key={kategori.id}
              onClick={() => setActiveKategoriUsia(kategori.label)}
              className={`flex-1 py-2.5 text-sm font-medium rounded-lg transition-all ${
                activeKategoriUsia === kategori.label
                  ? "bg-white text-blue-600 shadow-sm"
                  : "text-slate-500 hover:text-slate-700"
              }`}
            >
              {kategori.label}
            </button>
          ))}
        </div>

        <div className="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
          <div className={`grid grid-cols-12 bg-slate-100 px-8 py-3.5 border-b border-slate-200 ${currentData.length === 0 ? 'hidden' : ''}`}>
            <div className="col-span-1 text-xs font-semibold text-slate-600">No</div>
            <div className="col-span-8 text-xs font-semibold text-slate-600">Indikator Ceklist (Kategori Capaian)</div>
            <div className="col-span-3 text-xs font-semibold text-slate-600 text-right">Aksi Admin</div>
          </div>

          <div className="divide-y divide-slate-100">
            {isLoading ? (
              <div className="p-20 text-center">
                <p className="text-slate-400 text-sm italic">Memuat indikator...</p>
              </div>
            ) : currentData.length > 0 ? (
              currentData.map((item, index) => (
                <div key={item.id} className="grid grid-cols-12 items-center px-8 py-5 hover:bg-slate-50/50 transition-colors">
                  <div className="col-span-1 text-sm text-slate-400">
                    {String(index + 1).padStart(2, "0")}
                  </div>
                  <div className="col-span-8 pr-10 text-sm text-slate-700 leading-relaxed">
                    <p>{item.pertanyaan_ceklist}</p>
                    {item.aspek && (
                      <span className="mt-1.5 inline-block text-xs px-2.5 py-0.5 bg-blue-50 text-blue-600 rounded-full font-semibold">
                        {item.aspek}
                      </span>
                    )}
                  </div>
                  <div className="col-span-3 flex justify-end gap-2">
                    <button
                      onClick={() => openEditModal(item)}
                      className="inline-flex items-center gap-1.5 px-3 py-1.5 bg-yellow-50 hover:bg-yellow-100 text-yellow-700 border border-yellow-200 rounded-xl text-[13px] font-semibold transition-colors"
                      title="Edit Data"
                    >
                      <Pencil size={14} />
                      Edit
                    </button>
                    <button
                      onClick={() => openDeleteModal(item)}
                      className="inline-flex items-center gap-1.5 px-3 py-1.5 bg-red-50 hover:bg-red-100 text-red-600 border border-red-200 rounded-xl text-[13px] font-semibold transition-colors"
                      title="Hapus Data"
                    >
                      <Trash2 size={14} />
                      Hapus
                    </button>
                  </div>
                </div>
              ))
            ) : (
              <div className="p-20 text-center">
                <p className="text-slate-400 text-sm italic">
                  Belum ada indikator untuk kategori {activeKategoriUsia || "ini"}.
                </p>
              </div>
            )}
          </div>
        </div>

        {isModalOpen && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
            <div className="absolute inset-0 bg-black/40 backdrop-blur-sm" onClick={closeModal} />
            <div className="relative bg-white rounded-2xl shadow-xl w-full max-w-lg p-6 animate-[fadeInScale_0.2s_ease-out]">
              <div className="flex items-center justify-between mb-4">
                <h2 className="text-base font-semibold text-slate-800">
                  {formMode === "add" ? "Tambah Indikator" : "Ubah Indikator"}
                </h2>
                <button
                  onClick={closeModal}
                  className="p-1.5 text-slate-400 hover:text-slate-600 hover:bg-slate-100 rounded-lg transition-colors"
                >
                  <X size={18} />
                </button>
              </div>

              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-semibold text-slate-600 mb-1.5">Kategori Umur</label>
                  <select
                    value={formKategoriUsia}
                    onChange={(e) => setFormKategoriUsia(e.target.value)}
                    className="w-full bg-[#F7FAFB] border border-[#e2e8f0] rounded-xl px-4 py-2.5 text-sm text-slate-700 focus:outline-none focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5]"
                  >
                    <option value="">-- Pilih Kategori Umur --</option>
                    {kategoriUmurList.map((kategori) => (
                      <option key={kategori.id} value={kategori.label}>{kategori.label}</option>
                    ))}
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-semibold text-slate-600 mb-1.5">Aspek Perkembangan</label>
                  <select
                    value={formAspek}
                    onChange={(e) => setFormAspek(e.target.value)}
                    className="w-full bg-[#F7FAFB] border border-[#e2e8f0] rounded-xl px-4 py-2.5 text-sm text-slate-700 focus:outline-none focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5]"
                  >
                    <option value="motorik">Motorik</option>
                    <option value="sosial">Sosial / Kemandirian</option>
                    <option value="bahasa">Bahasa / Bicara</option>
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-semibold text-slate-600 mb-1.5">Pertanyaan Ceklist</label>
                  <textarea
                    rows={4}
                    value={formDeskripsi}
                    onChange={(e) => setFormDeskripsi(e.target.value)}
                    placeholder="Contoh: Apakah anak bisa makan sendiri tanpa banyak tumpah?"
                    className="w-full bg-[#F7FAFB] border border-[#e2e8f0] rounded-xl px-4 py-3 text-sm text-slate-700 focus:outline-none focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5] resize-none"
                  />
                </div>
              </div>

              <div className="flex justify-end gap-2 mt-4">
                <button
                  onClick={closeModal}
                  className="px-4 py-2.5 text-sm font-semibold text-slate-600 bg-slate-100 hover:bg-slate-200 rounded-xl transition-colors"
                >
                  Batal
                </button>
                <button
                  onClick={handleSave}
                  disabled={isSubmitting}
                  className="inline-flex items-center gap-2 px-5 py-2.5 bg-[#185FA5] hover:bg-[#185FA5]/90 text-white text-sm font-semibold rounded-xl transition-all active:scale-95 disabled:opacity-50 shadow-sm"
                >
                  <Check size={15} /> {isSubmitting ? "Menyimpan..." : "Simpan"}
                </button>
              </div>
            </div>
          </div>
        )}

      </div>
    </MainLayout>
  );
}