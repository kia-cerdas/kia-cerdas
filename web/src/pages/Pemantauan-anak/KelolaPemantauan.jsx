import React, { useEffect, useMemo, useState } from "react";
import MainLayout from "../../components/Layout/MainLayout";
import AlertNotification from "../../components/AlertNotification";
import { Search, Plus, Pencil, Trash2, X, Check } from "lucide-react";
import {
  getRentangUsia,
  getKategoriByRentang,
  createIndicator,
  updateIndicator,
  deleteIndicator
} from "../../services/pemantauanAnak";

export default function KelolaPemantauan() {
  const [rentangList, setRentangList] = useState([]);
  const [activeRentangId, setActiveRentangId] = useState("");
  const [query, setQuery] = useState("");
  const [dataPertanyaan, setDataPertanyaan] = useState({});
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);
  const [selectedItem, setSelectedItem] = useState(null);
  const [formText, setFormText] = useState("");
  const [formMode, setFormMode] = useState("add");
  const [clickedBtn, setClickedBtn] = useState({ id: null, type: null });
  const [isLoading, setIsLoading] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [notice, setNotice] = useState("");
  const [errorMsg, setErrorMsg] = useState("");
  const [notification, setNotification] = useState(null);

  useEffect(() => {
    const init = async () => {
      try {
        const res = await getRentangUsia();
        setRentangList(res || []);
        if (res.length > 0) {
          setActiveRentangId(String(res[0].id));
        }
      } catch (e) {
        setErrorMsg("Gagal memuat kategori usia");
      }
    };
    init();
  }, []);

  useEffect(() => {
    if (!activeRentangId) return;
    const t = setTimeout(() => {
      fetchData(activeRentangId, query);
    }, 300);

    return () => clearTimeout(t);
  }, [activeRentangId, query]);

  const fetchData = async (rentangId, q) => {
    setIsLoading(true);
    setErrorMsg("");

    try {
      const rows = await getKategoriByRentang(rentangId);
      // Client-side filtering for 'q' if backend doesn't support it yet
      const filtered = q
        ? rows.filter(item => item.gejala.toLowerCase().includes(q.toLowerCase()))
        : rows;

      const mapped = (filtered || []).map((item) => ({
        id: item.id,
        deskripsi: item.gejala,
        rentangUsiaId: item.rentang_usia_id,
      }));

      setDataPertanyaan((prev) => ({
        ...prev,
        [rentangId]: mapped,
      }));
    } catch (error) {
      setErrorMsg("Gagal memuat data indikator pemantauan");
    } finally {
      setIsLoading(false);
    }
  };

  const filteredData = useMemo(() => {
    return dataPertanyaan[activeRentangId] || [];
  }, [activeRentangId, dataPertanyaan]);

  const openAddModal = () => {
    setFormMode("add");
    setSelectedItem(null);
    setFormText("");
    setIsModalOpen(true);
  };

  const openEditModal = (item) => {
    setFormMode("edit");
    setSelectedItem(item);
    setFormText(item.deskripsi);
    setIsModalOpen(true);
  };

  const closeModal = () => {
    setIsModalOpen(false);
    setSelectedItem(null);
    setFormText("");
  };

  const handleSave = () => {
    if (isSubmitting) return;
    const value = formText.trim();
    if (!value) return;

    (async () => {
      setIsSubmitting(true);
      setErrorMsg("");
      setNotice("");

      try {
        if (formMode === "edit" && selectedItem) {
          await updateIndicator(selectedItem.id, {
            rentang_usia_id: Number(activeRentangId),
            gejala: value,
          });
          setNotification({
            type: "success",
            message: "Data indikator pemantauan anak berhasil diperbarui ke dalam sistem!"
          });
        } else {
          await createIndicator({
            rentang_usia_id: Number(activeRentangId),
            gejala: value,
          });
          setNotification({
            type: "success",
            message: "Data indikator pemantauan anak berhasil ditambahkan ke dalam sistem!"
          });
        }

        closeModal();
        await fetchData(activeRentangId, query);
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
    })();
  };

  const openDeleteModal = (item) => {
    setSelectedItem(item);
    setIsDeleteModalOpen(true);
  };

  const closeDeleteModal = () => {
    setSelectedItem(null);
    setIsDeleteModalOpen(false);
  };

  const handleDelete = () => {
    if (!selectedItem || isSubmitting) return;

    (async () => {
      setIsSubmitting(true);
      setErrorMsg("");
      setNotice("");

      try {
        await deleteIndicator(selectedItem.id);
        setNotification({
          type: "success",
          message: "Data indikator pemantauan anak berhasil dihapus dari sistem!"
        });
        closeDeleteModal();
        await fetchData(activeRentangId, query);
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
    })();
  };

  return (
    <MainLayout>
      <AlertNotification
        notification={notification}
        onClose={() => setNotification(null)}
        onRetry={notification?.type === "error" ? () => setNotification(null) : null}
      />
      <div className="max-w-6xl mx-auto space-y-6">

        {/* Header: Search Bar */}
        <div className="flex justify-center">
          <div className="relative w-full max-w-2xl">
            <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" size={18} />
            <input
              type="text"
              placeholder={`Cari indikator...`}
              className="w-full pl-12 pr-4 py-3 bg-white border border-slate-100 rounded-full text-sm shadow-sm focus:ring-2 focus:ring-blue-100 outline-none transition-all"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
            />
          </div>
        </div>

        {/* Info & Action Button */}
        <div className="flex items-center justify-between px-2">
          <div>
            <h1 className="text-2xl font-bold text-slate-800">Kelola Lembar Pemantauan Anak</h1>
            <p className="text-sm text-slate-500 mt-1">Mengatur bank soal indikator kesehatan anak per kategori umur.</p>
          </div>
          <button
            onClick={openAddModal}
            className="bg-blue-600 hover:bg-blue-700 text-white px-5 py-2.5 rounded-lg text-sm font-medium flex items-center gap-2 transition-all"
          >
            <Plus size={18} /> Tambah Kondisi
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
          {rentangList.map((rentang) => (
            <button
              key={rentang.id}
              onClick={() => setActiveRentangId(String(rentang.id))}
              className={`flex-1 py-2.5 text-sm font-medium rounded-lg transition-all ${activeRentangId === String(rentang.id)
                ? "bg-white text-blue-600 shadow-sm"
                : "text-slate-500 hover:text-slate-700"
                }`}
            >
              {rentang.nama_rentang}
            </button>
          ))}
        </div>

        {/* Table Content */}
        <div className="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
          <div className={`grid grid-cols-12 bg-slate-50/50 px-8 py-4 border-b border-slate-100 font-bold text-[11px] text-slate-400 uppercase tracking-widest ${filteredData.length === 0 ? 'hidden' : ''}`}>
            <div className="col-span-1">No</div>
            <div className="col-span-9">Indikator Kondisi Kesehatan</div>
            <div className="col-span-2 text-right">Aksi Admin</div>
          </div>

          <div className="divide-y divide-slate-100">
            {isLoading ? (
              <div className="p-20 text-center">
                <p className="text-slate-400 text-sm italic">Memuat indikator...</p>
              </div>
            ) : filteredData.length > 0 ? (
              filteredData.map((item, index) => (
                <div key={item.id} className="grid grid-cols-12 items-center px-8 py-6 hover:bg-slate-50/30 transition-all group">
                  <div className="col-span-1 text-sm font-mono text-slate-300">
                    {String(index + 1).padStart(2, '0')}
                  </div>
                  <div className="col-span-9 pr-10 text-sm text-slate-700 font-medium leading-relaxed">
                    {item.deskripsi}
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
                <p className="text-slate-400 text-sm italic">Belum ada indikator untuk kategori {rentangList.find(r => String(r.id) === activeRentangId)?.nama_rentang}.</p>
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
                <p className="text-sm text-slate-500">
                  Kategori aktif: <span className="font-semibold text-slate-700">{rentangList.find(r => String(r.id) === activeRentangId)?.nama_rentang}</span>
                </p>
                <textarea
                  rows={5}
                  value={formText}
                  onChange={(e) => setFormText(e.target.value)}
                  placeholder="Tulis indikator kondisi kesehatan..."
                  className="w-full rounded-xl border border-slate-200 px-4 py-3 text-sm outline-none focus:ring-2 focus:ring-blue-100"
                />
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
                    {selectedItem.deskripsi}
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