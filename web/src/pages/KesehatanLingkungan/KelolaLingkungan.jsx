import React, { useEffect, useMemo, useState } from "react";
import MainLayout from "../../components/Layout/MainLayout";
import {
  Search,
  Plus,
  Pencil,
  Trash2,
  X,
  Check,
  ClipboardList,
  RotateCcw,
} from "lucide-react";
import {
  getKategoriLingkungan,
  createKategoriLingkungan,
  deleteKategoriLingkungan,
  addIndikatorLingkungan,
  deleteIndikatorLingkungan,
} from "../../services/kesehatanLingkungan";

export default function KelolaLingkungan() {
  const [kategoriList, setKategoriList] = useState([]);
  const [activeKategoriId, setActiveKategoriId] = useState("");
  const [query, setQuery] = useState("");
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);
  const [selectedItem, setSelectedItem] = useState(null);
  const [formType, setFormType] = useState("kategori"); // kategori or indikator
  const [formData, setFormData] = useState({
    nama: "",
    deskripsi: "",
    pertanyaan: "",
  });
  const [isLoading, setIsLoading] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [notice, setNotice] = useState("");
  const [errorMsg, setErrorMsg] = useState("");

  const fetchData = async () => {
    setIsLoading(true);
    try {
      const res = await getKategoriLingkungan();
      setKategoriList(res);
      if (res.length > 0 && !activeKategoriId) {
        setActiveKategoriId(String(res[0].id));
      }
    } catch (e) {
      // setErrorMsg("Gagal memuat data kategori lingkungan");
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  const activeKategori = useMemo(() => {
    return kategoriList.find((k) => String(k.id) === activeKategoriId);
  }, [activeKategoriId, kategoriList]);

  const filteredIndikator = useMemo(() => {
    if (!activeKategori) return [];
    if (!query) return activeKategori.indikator || [];
    return (activeKategori.indikator || []).filter((ind) =>
      ind.pertanyaan.toLowerCase().includes(query.toLowerCase()),
    );
  }, [activeKategori, query]);

  const openAddKategori = () => {
    setFormType("kategori");
    setFormData({ nama: "", deskripsi: "" });
    setIsModalOpen(true);
  };

  const openAddIndikator = () => {
    if (!activeKategoriId) return;
    setFormType("indikator");
    setFormData({ pertanyaan: "" });
    setIsModalOpen(true);
  };

  const handleSave = async () => {
    if (isSubmitting) return;
    const value =
      formType === "kategori"
        ? formData.nama.trim()
        : formData.pertanyaan.trim();
    if (!value) return;

    setIsSubmitting(true);
    try {
      if (formType === "kategori") {
        await createKategoriLingkungan({
          nama: formData.nama,
          deskripsi: formData.deskripsi,
          indikator: [],
        });
        setNotice("Kategori berhasil ditambahkan");
      } else {
        await addIndikatorLingkungan(Number(activeKategoriId), {
          pertanyaan: formData.pertanyaan,
        });
        setNotice("Pertanyaan berhasil ditambahkan");
      }
      setIsModalOpen(false);
      fetchData();
    } catch (e) {
      setErrorMsg("Gagal menyimpan data");
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleDeleteIndikator = async (id) => {
    if (!window.confirm("Hapus indikator ini?")) return;
    try {
      await deleteIndikatorLingkungan(id);
      setNotice("Indikator berhasil dihapus");
      fetchData();
    } catch (e) {
      setErrorMsg("Gagal menghapus indikator");
    }
  };

  const handleDeleteKategori = async () => {
    if (
      !activeKategoriId ||
      !window.confirm("Hapus kategori ini beserta seluruh indikatornya?")
    )
      return;
    try {
      await deleteKategoriLingkungan(Number(activeKategoriId));
      setNotice("Kategori berhasil dihapus");
      setActiveKategoriId("");
      fetchData();
    } catch (e) {
      setErrorMsg("Gagal menghapus kategori");
    }
  };

  return (
    <MainLayout>
      <div className="max-w-6xl mx-auto space-y-6">
        <div className="flex justify-center">
          <div className="relative w-full max-w-2xl">
            <Search
              className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400"
              size={18}
            />
            <input
              type="text"
              placeholder="Cari pertanyaan indikator..."
              className="w-full pl-12 pr-4 py-3 bg-white border border-slate-100 rounded-full text-sm shadow-sm focus:ring-2 focus:ring-blue-100 outline-none transition-all"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
            />
          </div>
        </div>

        <div className="flex items-center justify-between px-2">
          <div>
            <h1 className="text-2xl font-bold text-slate-800">
              Kelola Pertanyaan Lingkungan
            </h1>
            <p className="text-sm text-slate-500 mt-1">
              Mengatur kategori dan pertanyaan untuk kesehatan & keselamatan
              lingkungan rumah.
            </p>
          </div>
          <button
            onClick={openAddKategori}
            className="bg-white border border-slate-200 text-slate-600 hover:bg-slate-50 px-5 py-2.5 rounded-lg text-sm font-medium flex items-center gap-2 transition-all shadow-sm"
          >
            <Plus size={18} /> Kategori Baru
          </button>
        </div>

        {notice && (
          <div className="rounded-xl border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm text-emerald-700">
            {notice}
          </div>
        )}
        {errorMsg && (
          <div className="rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
            {errorMsg}
          </div>
        )}

        <div className="bg-slate-100/50 p-1.5 rounded-2xl flex flex-wrap gap-1">
          {kategoriList.map((k) => (
            <button
              key={k.id}
              onClick={() => setActiveKategoriId(String(k.id))}
              className={`px-4 py-2 text-[10px] font-black uppercase tracking-widest rounded-xl transition-all ${
                activeKategoriId === String(k.id)
                  ? "bg-white text-blue-600 shadow-sm"
                  : "text-slate-500 hover:bg-slate-100"
              }`}
            >
              {k.nama}
            </button>
          ))}
          {/* 
<button 
  onClick={handleDeleteKategori}
  className="ml-auto p-2 text-red-400 hover:text-red-600 transition-all"
  title="Hapus Kategori Aktif"
>
  <Trash2 size={16} />
</button> 
*/}
        </div>

        <div className="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
          <div className={`grid grid-cols-12 bg-slate-50/50 px-8 py-4 border-b border-slate-100 font-bold text-[10px] text-slate-400 uppercase tracking-widest ${filteredIndikator.length === 0 ? 'hidden' : ''}`}>
            <div className="col-span-1 text-center">No</div>
            <div className="col-span-9">Pertanyaan</div>
            <div className="col-span-2 text-right">Aksi</div>
          </div>

          <div className="divide-y divide-slate-100">
            {isLoading ? (
              <div className="p-20 text-center text-slate-400 italic text-sm">
                Memuat data...
              </div>
            ) : filteredIndikator.length > 0 ? (
              filteredIndikator.map((item, index) => (
                <div
                  key={item.id}
                  className="grid grid-cols-12 items-center px-8 py-3 hover:bg-slate-50/30 transition-all group"
                >
                  <div className="col-span-1 text-xs font-mono text-slate-400 text-center">
                    {index + 1}
                  </div>
                  <div className="col-span-9 pr-10 text-sm text-slate-700 leading-relaxed">
                    {item.pertanyaan}
                  </div>
                  <div className="col-span-2 flex justify-end gap-2">
                    <button
                      onClick={() => handleDeleteIndikator(item.id)}
                      className="p-2 text-red-500 bg-red-50 hover:bg-red-600 hover:text-white rounded-lg transition-all"
                    >
                      <Trash2 size={18} />
                    </button>
                  </div>
                </div>
              ))
            ) : (
              <div className="p-20 text-center">
                <ClipboardList
                  className="mx-auto text-slate-200 mb-4"
                  size={48}
                />
                <p className="text-slate-400 text-sm italic">
                  Belum ada indikator untuk kategori ini.
                </p>
              </div>
            )}
          </div>
        </div>

        {isModalOpen && (
          <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/40 p-4">
            <div className="w-full max-w-2xl bg-white rounded-3xl shadow-2xl border border-slate-100 overflow-hidden">
              <div className="flex items-center justify-between px-8 py-6 border-b border-slate-100 bg-slate-50/50">
                <h2 className="text-xl font-bold text-slate-800">
                  {formType === "kategori"
                    ? "Tambah Kategori"
                    : "Tambah Pertanyaan"}
                </h2>
                <button
                  onClick={() => setIsModalOpen(false)}
                  className="p-2 rounded-full text-slate-400 hover:bg-white hover:text-slate-600 shadow-sm transition-all"
                >
                  <X size={20} />
                </button>
              </div>

              <div className="p-8 space-y-6">
                {formType === "kategori" ? (
                  <>
                    <div className="space-y-2">
                      <label className="text-xs font-bold text-slate-400 uppercase tracking-wider ml-1">
                        Nama Kategori
                      </label>
                      <input
                        type="text"
                        value={formData.nama}
                        onChange={(e) =>
                          setFormData({ ...formData, nama: e.target.value })
                        }
                        placeholder="Contoh: Kesehatan Lingkungan"
                        className="w-full rounded-xl border border-slate-200 px-5 py-3 text-sm outline-none focus:ring-4 focus:ring-blue-100 focus:border-blue-400 transition-all"
                      />
                    </div>
                    <div className="space-y-2">
                      <label className="text-xs font-bold text-slate-400 uppercase tracking-wider ml-1">
                        Deskripsi
                      </label>
                      <textarea
                        rows={3}
                        value={formData.deskripsi}
                        onChange={(e) =>
                          setFormData({
                            ...formData,
                            deskripsi: e.target.value,
                          })
                        }
                        placeholder="Deskripsi singkat kategori ini..."
                        className="w-full rounded-xl border border-slate-200 px-5 py-3 text-sm outline-none focus:ring-4 focus:ring-blue-100 focus:border-blue-400 transition-all"
                      />
                    </div>
                  </>
                ) : (
                  <div className="space-y-2">
                    <label className="text-xs font-bold text-slate-400 uppercase tracking-wider ml-1">
                      Pertanyaan
                    </label>
                    <textarea
                      rows={5}
                      value={formData.pertanyaan}
                      onChange={(e) =>
                        setFormData({ ...formData, pertanyaan: e.target.value })
                      }
                      placeholder="Contoh: Apakah tersedia sarana air bersih yang memenuhi syarat?"
                      className="w-full rounded-xl border border-slate-200 px-5 py-3 text-sm outline-none focus:ring-4 focus:ring-blue-100 focus:border-blue-400 transition-all"
                    />
                  </div>
                )}
              </div>

              <div className="px-8 py-6 border-t border-slate-100 bg-slate-50/50 flex justify-end gap-3">
                <button
                  onClick={() => setIsModalOpen(false)}
                  className="px-6 py-2.5 text-sm font-bold text-slate-500 hover:text-slate-700"
                >
                  BATAL
                </button>
                <button
                  onClick={handleSave}
                  disabled={isSubmitting}
                  className="px-8 py-2.5 text-sm font-bold rounded-xl bg-blue-600 hover:bg-blue-700 text-white shadow-lg shadow-blue-100 flex items-center gap-2 transition-all"
                >
                  {isSubmitting ? (
                    <RotateCcw className="animate-spin" size={18} />
                  ) : (
                    <Check size={18} />
                  )}{" "}
                  SIMPAN
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </MainLayout>
  );
}
