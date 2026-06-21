import React, { useEffect, useMemo, useState } from "react";
import MainLayout from "../../components/Layout/MainLayout";
import AlertNotification from "../../components/AlertNotification";
import Swal from "sweetalert2";
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

  const openDeleteModal = async (item) => {
    const result = await Swal.fire({
      title: "Hapus Indikator Pemantauan?",
      text: `"${item.deskripsi || ""}" akan dihapus permanen dan tidak dapat dikembalikan.`,
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#EF4444",
      cancelButtonColor: "#6B7280",
      confirmButtonText: "Ya, Hapus",
      cancelButtonText: "Batal",
    });
    if (!result.isConfirmed) return;

    try {
      await deleteIndicator(item.id);
      setNotification({
        type: "success",
        message: "Data indikator pemantauan anak berhasil dihapus dari sistem.",
      });
      await fetchData(activeRentangId, query);
    } catch (error) {
      const errMsg = error?.response?.data?.message || error.message || "Unknown error";
      setNotification({
        type: "error",
        message: "Permintaan gagal diproses. Silakan coba lagi nanti.",
        code: errMsg,
      });
    }
  };

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
              <h1 className="text-xl font-bold text-slate-800">Kelola Lembar Pemantauan Anak</h1>
              <p className="text-sm text-slate-500">Mengatur indikator kesehatan anak per kategori umur.</p>
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
          <div className={`grid grid-cols-12 bg-slate-100 px-8 py-3.5 border-b border-slate-200 ${filteredData.length === 0 ? 'hidden' : ''}`}>
            <div className="col-span-1 text-xs font-semibold text-slate-600">No</div>
            <div className="col-span-8 text-xs font-semibold text-slate-600">Indikator Kondisi Kesehatan</div>
            <div className="col-span-3 text-xs font-semibold text-slate-600 text-right">Aksi Admin</div>
          </div>

          <div className="divide-y divide-slate-100">
            {isLoading ? (
              <div className="p-20 text-center">
                <p className="text-slate-400 text-sm italic">Memuat indikator...</p>
              </div>
            ) : filteredData.length > 0 ? (
              filteredData.map((item, index) => (
                <div key={item.id} className="grid grid-cols-12 items-center px-8 py-5 hover:bg-slate-50/50 transition-colors">
                  <div className="col-span-1 text-sm text-slate-400">
                    {String(index + 1).padStart(2, '0')}
                  </div>
                  <div className="col-span-8 pr-10 text-sm text-slate-700 leading-relaxed">
                    {item.deskripsi}
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
                <p className="text-slate-400 text-sm italic">Belum ada indikator untuk kategori {rentangList.find(r => String(r.id) === activeRentangId)?.nama_rentang}.</p>
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

              <p className="text-sm text-slate-500 mb-3">
                Kategori aktif: <span className="font-semibold text-slate-700">{rentangList.find(r => String(r.id) === activeRentangId)?.nama_rentang}</span>
              </p>
              <textarea
                rows={4}
                value={formText}
                onChange={(e) => setFormText(e.target.value)}
                placeholder="Tulis indikator kondisi kesehatan..."
                className="w-full bg-[#F7FAFB] border border-[#e2e8f0] rounded-xl px-4 py-3 text-sm text-slate-700 outline-none focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5] mb-4 resize-none"
              />
              <div className="flex justify-end gap-2">
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