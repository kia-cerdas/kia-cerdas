import React, { useEffect, useMemo, useState } from "react";
import MainLayout from "../../components/Layout/MainLayout";
import AlertNotification from "../../components/AlertNotification";
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
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);
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

  const openDeleteModal = (item) => {
    setSelectedItem(item);
    setIsDeleteModalOpen(true);
  };

  const closeDeleteModal = () => {
    setSelectedItem(null);
    setIsDeleteModalOpen(false);
  };

  const handleDelete = async () => {
    if (!selectedItem || isSubmitting) return;

    setIsSubmitting(true);
    setErrorMsg("");
    setNotice("");

    try {
      await deleteKategoriCapaian(selectedItem.id);
      setNotification({
        type: "success",
        message: "Data indikator perkembangan anak berhasil dihapus dari sistem!"
      });
      closeDeleteModal();
      await fetchData(activeKategoriUsia, query);
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

  return (
    <MainLayout>
      <AlertNotification 
        notification={notification} 
        onClose={() => setNotification(null)} 
        onRetry={notification?.type === "error" ? () => setNotification(null) : null}
      />
      <div className="max-w-6xl mx-auto space-y-6">
        <div className="flex justify-center">
          <div className="relative w-full max-w-2xl">
            <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" size={18} />
            <input
              type="text"
              placeholder="Cari indikator..."
              className="w-full pl-12 pr-4 py-3 bg-white border border-slate-100 rounded-full text-sm shadow-sm focus:ring-2 focus:ring-blue-100 outline-none transition-all"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
            />
          </div>
        </div>

        {/* Info & Action Button */}
        <div className="flex items-center justify-between px-2">
          <div>
            <h1 className="text-2xl font-bold text-slate-800">Kelola Perawatan Anak</h1>
            <p className="text-sm text-slate-500 mt-1">Mengatur bank soal indikator checklist/milestone perkembangan perawatan anak.</p>
          </div>
          <button
            onClick={openAddModal}
            className="bg-blue-600 hover:bg-blue-700 text-white px-5 py-2.5 rounded-lg text-sm font-medium flex items-center gap-2 transition-all"
          >
            <Plus size={18} /> Tambah Indikator
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
          <div className={`grid grid-cols-12 bg-slate-50/50 px-8 py-4 border-b border-slate-100 font-bold text-[11px] text-slate-400 uppercase tracking-widest ${currentData.length === 0 ? 'hidden' : ''}`}>
            <div className="col-span-1">No</div>
            <div className="col-span-9">Indikator Ceklist (Kategori Capaian)</div>
            <div className="col-span-2 text-right">Aksi Admin</div>
          </div>

          <div className="divide-y divide-slate-100">
            {isLoading ? (
              <div className="p-20 text-center">
                <p className="text-slate-400 text-sm italic">Memuat indikator...</p>
              </div>
            ) : currentData.length > 0 ? (
              currentData.map((item, index) => (
                <div key={item.id} className="grid grid-cols-12 items-center px-8 py-6 hover:bg-slate-50/30 transition-all group">
                  <div className="col-span-1 text-sm font-mono text-slate-300">
                    {String(index + 1).padStart(2, "0")}
                  </div>
                  <div className="col-span-9 pr-10 text-sm text-slate-700 leading-relaxed font-medium">
                    <p>{item.pertanyaan_ceklist}</p>
                    {item.aspek && (
                      <span className="mt-1.5 inline-block text-[10px] px-2 py-0.5 bg-blue-50 text-blue-600 rounded-full font-bold uppercase">
                        {item.aspek}
                      </span>
                    )}
                  </div>
                  <div className="col-span-2 flex justify-end gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                    <button
                      onClick={() => openEditModal(item)}
                      onMouseDown={() => setClickedBtn({ id: item.id, type: 'edit' })}
                      onMouseUp={() => setClickedBtn({ id: null, type: null })}
                      className={`p-2 rounded-lg ${clickedBtn.id === item.id && clickedBtn.type === 'edit' ? "bg-blue-600 text-white" : "text-blue-500 bg-blue-50 hover:bg-blue-100"}`}
                    >
                      <Pencil size={18} />
                    </button>
                    <button
                      onClick={() => openDeleteModal(item)}
                      onMouseDown={() => setClickedBtn({ id: item.id, type: 'delete' })}
                      onMouseUp={() => setClickedBtn({ id: null, type: null })}
                      className={`p-2 rounded-lg ${clickedBtn.id === item.id && clickedBtn.type === 'delete' ? "bg-red-600 text-white" : "text-red-500 bg-red-50 hover:bg-red-100"}`}
                    >
                      <Trash2 size={18} />
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
          <div className="fixed inset-0 z-50 flex items-center justify-center bg-blue-900/40 p-4">
            <div className="w-full max-w-2xl bg-white rounded-2xl shadow-xl border border-slate-100 overflow-hidden">
              <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100">
                <h2 className="text-lg font-bold text-slate-800">
                  {formMode === "add" ? "Tambah Indikator" : "Edit Indikator"}
                </h2>
                <button onClick={closeModal} className="p-2 rounded-lg text-slate-500 hover:bg-slate-100">
                  <X size={18} />
                </button>
              </div>

              <div className="p-6 space-y-4">
                <div className="space-y-1">
                  <label className="text-xs font-bold text-slate-400 uppercase tracking-wider ml-1">Kategori Umur <span className="text-red-500">*</span></label>
                  <select
                    value={formKategoriUsia}
                    onChange={(e) => setFormKategoriUsia(e.target.value)}
                    className="w-full rounded-xl border border-slate-200 px-4 py-2.5 text-sm outline-none focus:ring-2 focus:ring-blue-100"
                  >
                    <option value="">-- Pilih Kategori Umur --</option>
                    {kategoriUmurList.map((kategori) => (
                      <option key={kategori.id} value={kategori.label}>
                        {kategori.label}
                      </option>
                    ))}
                  </select>
                </div>

                <div className="space-y-1">
                  <label className="text-xs font-bold text-slate-400 uppercase tracking-wider ml-1">Aspek Perkembangan <span className="text-red-500">*</span></label>
                  <select
                    value={formAspek}
                    onChange={(e) => setFormAspek(e.target.value)}
                    className="w-full rounded-xl border border-slate-200 px-4 py-2.5 text-sm outline-none focus:ring-2 focus:ring-blue-100"
                  >
                    <option value="motorik">Motorik</option>
                    <option value="sosial">Sosial / Kemandirian</option>
                    <option value="bahasa">Bahasa / Bicara</option>
                  </select>
                </div>

                <div className="space-y-1">
                  <label className="text-xs font-bold text-slate-400 uppercase tracking-wider ml-1">Pertanyaan Ceklist</label>
                  <textarea
                    rows={4}
                    value={formDeskripsi}
                    onChange={(e) => setFormDeskripsi(e.target.value)}
                    placeholder="Contoh: Apakah anak bisa makan nasi sendiri tanpa banyak tumpah?..."
                    className="w-full rounded-xl border border-slate-200 px-4 py-3 text-sm outline-none focus:ring-2 focus:ring-blue-100 resize-none"
                  />
                </div>
              </div>

              <div className="px-6 py-4 border-t border-slate-100 flex justify-end gap-2">
                <button
                  onClick={closeModal}
                  className="px-4 py-2 text-sm rounded-lg border border-slate-200 text-slate-600 hover:bg-slate-50"
                >
                  Batal
                </button>
                <button
                  onClick={handleSave}
                  disabled={isSubmitting}
                  className="px-4 py-2 text-sm rounded-lg bg-blue-600 hover:bg-blue-700 text-white flex items-center gap-2"
                >
                  <Check size={16} /> {isSubmitting ? "Menyimpan..." : "Simpan"}
                </button>
              </div>
            </div>
          </div>
        )}

        {isDeleteModalOpen && (
          <div className="fixed inset-0 z-50 flex items-center justify-center bg-blue-900/40 p-4">
            <div className="w-full max-w-md bg-white rounded-2xl shadow-xl border border-slate-100">
              <div className="p-6 space-y-4">
                <h2 className="text-lg font-bold text-slate-800">Hapus Indikator</h2>
                <p className="text-sm text-slate-500 leading-relaxed">
                  Kamu yakin ingin menghapus indikator ini? Aksi ini tidak bisa dibatalkan.
                </p>
                {selectedItem ? (
                  <div className="text-sm bg-slate-50 rounded-lg p-3 text-slate-700 border border-slate-100">
                    {selectedItem.pertanyaan_ceklist}
                  </div>
                ) : null}
              </div>
              <div className="px-6 py-4 border-t border-slate-100 flex justify-end gap-2">
                <button
                  onClick={closeDeleteModal}
                  className="px-4 py-2 text-sm rounded-lg border border-slate-200 text-slate-600 hover:bg-slate-50"
                >
                  Batal
                </button>
                <button
                  onClick={handleDelete}
                  disabled={isSubmitting}
                  className="px-4 py-2 text-sm rounded-lg bg-red-600 hover:bg-red-700 text-white"
                >
                  {isSubmitting ? "Menghapus..." : "Hapus"}
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </MainLayout>
  );
}