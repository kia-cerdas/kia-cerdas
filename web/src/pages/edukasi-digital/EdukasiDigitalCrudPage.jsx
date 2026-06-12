import React, { useEffect, useMemo, useState } from "react";
import MainLayout from "../../components/Layout/MainLayout";
import AlertNotification from "../../components/AlertNotification";
import { useLocation, useNavigate, useParams } from "react-router-dom";
import {
  createEdukasi,
  deleteEdukasi,
  getEdukasiById,
  listEdukasi,
  updateEdukasi,
} from "../../services/edukasiDigital";
import { 
  Pencil, 
  Trash2, 
  Plus, 
  RefreshCw, 
  BookOpen, 
  Image as ImageIcon,
  Eye,
  Search,
  Filter,
  Download,
  ChevronLeft,
  ChevronRight
} from "lucide-react";

const emptyForm = {
  judul: "",
  gambar_url: "",
  deskripsi: "",
  isi_konten: "",
  materi_inti: "[]",
  hal_penting: "",
};

const guessId = (item) =>
  item?.id ?? item?.ID ?? item?.id_edukasi ?? item?.id_informasi ?? null;

const guessImage = (item) => 
  item?.gambar_url ?? item?.GambarURL ?? item?.image_url ?? item?.image ?? "";

const guessCategory = (item) =>
  item?.kategori_umur?.kategori_umur ?? item?.kategori_umur?.KategoriUmur ?? item?.tipe ?? "Edukasi";

export default function EdukasiDigitalCrudPage({
  title,
  resourcePath,
  view = "inline",
  createPath,
  listPath,
  fields = null,
}) {
  const navigate = useNavigate();
  const location = useLocation();
  const params = useParams();
  const [rows, setRows] = useState([]);
  const [mpasiMateriList, setMpasiMateriList] = useState([]);
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [editingId, setEditingId] = useState(null);
  const [activeRentangUsia, setActiveRentangUsia] = useState("");
  const initialForm = useMemo(() => {
    if (fields && Array.isArray(fields)) {
      const f = {};
      fields.forEach((it) => {
        if (it.type === "checkbox") {
          f[it.key] = Boolean(it.default ?? false);
          return;
        }

        f[it.key] = it.default ?? "";
      });
      return f;
    }
    return {
      judul: "",
      gambar_url: "",
      deskripsi: "",
      isi_konten: "",
      isi: "",
      materi_inti: "[]",
      hal_penting: "",
      ringkasan: "",
    };
  }, [fields]);

  const [form, setForm] = useState(initialForm);
  const [error, setError] = useState("");
  const [showForm, setShowForm] = useState(false);
  const [notification, setNotification] = useState(null);

  const sortedRows = useMemo(() => {
    return [...rows].sort((a, b) => {
      const ta = new Date(a.updated_at || a.created_at || 0).getTime();
      const tb = new Date(b.updated_at || b.created_at || 0).getTime();
      return tb - ta;
    });
  }, [rows]);

  const loadData = async (filterParams = {}) => {
    setLoading(true);
    setError("");
    try {
      const data = await listEdukasi(resourcePath, filterParams);
      setRows(Array.isArray(data) ? data : []);
    } catch (err) {
      setError(err?.response?.data?.message || "Gagal memuat data edukasi");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (view === "form") return;
    loadData();
  }, [resourcePath, view]);

  useEffect(() => {
    if (view === "form") return;
    if (["edukasi-mpasi-jadwal-harian", "edukasi-mpasi-aturan-porsi", "edukasi-mpasi-resep"].includes(resourcePath)) {
      listEdukasi("edukasi-mpasi")
        .then((data) => {
          setMpasiMateriList(Array.isArray(data) ? data : []);
        })
        .catch((err) => {
          console.error("Failed to load MPASI materials:", err);
        });
    }
  }, [resourcePath, view]);

  useEffect(() => {
    if (view !== "form") return;

    const mapItemToForm = (item) => {
      if (!item) return initialForm;
      if (fields && Array.isArray(fields)) {
        const f = {};
        fields.forEach((it) => {
          if (it.type === "checkbox") {
            f[it.key] = Boolean(item[it.key] ?? item[it.alt] ?? false);
            return;
          }

          if (it.type === "array") {
            const arr = item[it.key];
            if (Array.isArray(arr)) {
              f[it.key] = arr.join("\n");
            } else {
              f[it.key] = "";
            }
            return;
          }

          const current = item[it.key] ?? item[it.alt] ?? "";
          f[it.key] = current === null || current === undefined ? "" : String(current);
        });
        return f;
      }
      return {
        judul: item.judul || "",
        gambar_url: item.gambar_url || "",
        deskripsi: item.deskripsi || "",
        isi_konten: item.isi_konten || item.isi || "",
        isi: item.isi || "",
        materi_inti: item.materi_inti || "",
        hal_penting: item.hal_penting || "",
        ringkasan: item.ringkasan || "",
      };
    };

    const loadFormData = async () => {
      setLoading(true);
      setError("");

      try {
        if (params.id) {
          const item = await getEdukasiById(resourcePath, params.id);
          if (item) {
            setEditingId(String(guessId(item)));
            setForm(mapItemToForm(item));
          } else {
            setError("Data tidak ditemukan");
          }
          return;
        }

        const item = location.state?.item;
        if (!item) {
          setEditingId(null);
          setForm(initialForm);
          return;
        }

        setEditingId(String(guessId(item)));
        setForm(mapItemToForm(item));
      } catch (err) {
        setError(err?.response?.data?.message || "Gagal memuat data");
        setForm(emptyForm);
      } finally {
        setLoading(false);
      }
    };

    loadFormData();
  }, [location.state, view, params.id, resourcePath, fields]);

  const materiIntiList = useMemo(() => {
    try {
      const parsed = JSON.parse(form.materi_inti || "[]");
      return Array.isArray(parsed) ? parsed : [];
    } catch {
      return [];
    }
  }, [form.materi_inti]);

  const handleUpdateMateriInti = (newList) => {
    setForm((prev) => ({ ...prev, materi_inti: JSON.stringify(newList) }));
  };

  const handleAddMateriInti = () => {
    handleUpdateMateriInti([...materiIntiList, { judul: "", isi: "" }]);
  };

  const handleRemoveMateriInti = (index) => {
    const newList = [...materiIntiList];
    newList.splice(index, 1);
    handleUpdateMateriInti(newList);
  };

  const handleChangeMateriInti = (index, field, value) => {
    const newList = [...materiIntiList];
    newList[index] = { ...newList[index], [field]: value };
    handleUpdateMateriInti(newList);
  };

  const handleChange = (event) => {
    const { name, value, type, checked } = event.target;
    setForm((prev) => ({
      ...prev,
      [name]: type === "checkbox" ? checked : value,
    }));
  };

  const toPayload = () => {
    if (fields && Array.isArray(fields)) {
      const payload = {};
      fields.forEach((f) => {
        const val = form[f.key];
        if (f.type === "checkbox") {
          payload[f.key] = Boolean(val);
          return;
        }

        if (f.type === "array") {
          // Convert newline-separated string to array
          if (typeof val === "string") {
            payload[f.key] = val.split("\n").map(line => line.trim()).filter(line => line.length > 0);
          } else if (Array.isArray(val)) {
            payload[f.key] = val;
          } else {
            payload[f.key] = [];
          }
          return;
        }

        if (f.type === "number") {
          payload[f.key] = val === "" || val === null ? null : Number(val);
          return;
        }

        if (f.type === "select") {
          if (val === "" || val === null || val === undefined) {
            payload[f.key] = f.nullable ? null : "";
            return;
          }

          payload[f.key] = f.parseNumber ? Number(val) : val;
          return;
        }

        payload[f.key] = typeof val === "string" ? val.trim() : val;
      });
      return payload;
    }

    return {
      judul: (form.judul || "").trim(),
      gambar_url: (form.gambar_url || "").trim(),
      deskripsi: (form.deskripsi || "").trim(),
      isi_konten: (form.isi_konten || "").trim(),
      isi: (form.isi || "").trim(),
      materi_inti: (form.materi_inti || "").trim(),
      hal_penting: (form.hal_penting || "").trim(),
      ringkasan: (form.ringkasan || "").trim(),
    };
  };

  const resetForm = () => {
    setForm(initialForm);
    setEditingId(null);
    setShowForm(false);
  };

  const handleSubmit = async (event) => {
    event.preventDefault();

    const isJudulRequired = !fields || fields.some(f => f.key === "judul");
    if (isJudulRequired && (!form.judul || !form.judul.trim())) {
      setNotification({
        type: "error",
        message: "Judul wajib diisi!"
      });
      return;
    }

    setSaving(true);
    setError("");
    try {
      const payload = toPayload();
      if (editingId) {
        await updateEdukasi(resourcePath, editingId, payload);
        setNotification({
          type: "success",
          message: "Data edukasi digital berhasil diperbarui ke dalam sistem!"
        });
      } else {
        await createEdukasi(resourcePath, payload);
        setNotification({
          type: "success",
          message: "Data edukasi digital berhasil disimpan ke dalam sistem!"
        });
      }
    } catch (err) {
      const errMsg = err?.response?.data?.error || err?.response?.data?.message || err.message || "Unknown error";
      setNotification({
        type: "error",
        message: "Permintaan gagal diproses. Silakan coba lagi nanti atau hubungi bantuan.",
        code: errMsg
      });
    } finally {
      setSaving(false);
    }
  };

  const handleAlertClose = () => {
    if (notification && notification.type === "success") {
      if (view === "form") {
        navigate(listPath || "/edukasi-digital/informasi-umum");
      } else {
        resetForm();
        loadData();
      }
    }
    setNotification(null);
  };

  const handleEdit = (item) => {
    const id = guessId(item);
    if (!id) {
      setError("ID data tidak ditemukan");
      return;
    }
    
    if (createPath) {
      navigate(createPath, { state: { item } });
      return;
    }

    navigate(`${location.pathname.replace(/\/[^/]*$/, "")}/form/${id}`, { state: { item } });
  };

  const handleDelete = async (item) => {
    const id = guessId(item);
    if (!id) {
      setError("ID data tidak ditemukan");
      return;
    }

    const confirmed = window.confirm("Hapus data edukasi ini?");
    if (!confirmed) return;

    setError("");
    try {
      await deleteEdukasi(resourcePath, id);
      setNotification({
        type: "success",
        message: "Data edukasi digital berhasil dihapus dari sistem!"
      });
      await loadData();
    } catch (err) {
      const errMsg = err?.response?.data?.message || err.message || "Unknown error";
      setNotification({
        type: "error",
        message: "Permintaan gagal diproses. Silakan coba lagi nanti atau hubungi bantuan.",
        code: errMsg
      });
    }
  };

  // Helper untuk format tanggal
  const formatDate = (dateString) => {
    if (!dateString) return "-";
    const date = new Date(dateString);
    return date.toLocaleDateString('id-ID', { day: 'numeric', month: 'short', year: 'numeric' });
  };

  const getItemTitle = (item) => {
    if (item.judul) return item.judul;

    if (item.bulan_min !== undefined && item.bulan_max !== undefined) {
      const matchingMateri = mpasiMateriList.find(
        (m) => m.bulan_min === item.bulan_min && m.bulan_max === item.bulan_max
      );
      if (matchingMateri && matchingMateri.judul) {
        return matchingMateri.judul;
      }
      
      if (resourcePath === "edukasi-mpasi-jadwal-harian") {
        return `Jadwal Harian MPASI Usia ${item.bulan_min} - ${item.bulan_max} Bulan`;
      }
      if (resourcePath === "edukasi-mpasi-aturan-porsi") {
        return `Aturan Porsi MPASI Usia ${item.bulan_min} - ${item.bulan_max} Bulan`;
      }
      return `MPASI Usia ${item.bulan_min} - ${item.bulan_max} Bulan`;
    }

    return "Tanpa Judul";
  };

  const getItemDescription = (item) => {
    if (item.deskripsi) return item.deskripsi;
    if (item.isi_konten) return item.isi_konten;
    if (item.konten) return item.konten;
    
    if (item.waktu !== undefined && item.aktivitas !== undefined) {
      return `Pukul ${item.waktu}: ${item.aktivitas}`;
    }
    
    if (item.tekstur !== undefined) {
      return `Tekstur: ${item.tekstur} | Frekuensi: ${item.frekuensi} | Porsi: ${item.porsi}`;
    }

    return "-";
  };

  return (
    <MainLayout>
      <AlertNotification 
        notification={notification} 
        onClose={handleAlertClose} 
        onRetry={notification?.type === "error" ? () => setNotification(null) : null}
      />
      <div className="space-y-6 font-['Noto_Sans',_sans-serif]">
        
        {/* Header Section */}
        <section className="bg-white rounded-2xl border border-[#e2e8f0] p-6 shadow-sm">
          <h1 className="text-[28px] font-bold text-slate-800">{title}</h1>
          <p className="text-[16px] text-slate-500 mt-2">
            Kelola konten edukasi digital untuk kategori ini.
          </p>
        </section>

        {view === "form" && (
          <div className="flex justify-start">
            <button
              type="button"
              onClick={() => navigate(listPath || "/edukasi-digital/informasi-umum")}
              className="px-4 py-2 rounded-lg bg-white text-slate-700 text-[16px] font-semibold hover:bg-[#e2e8f0] border border-[#e2e8f0] transition-colors shadow-sm"
            >
              Kembali ke Daftar
            </button>
          </div>
        )}

        {view !== "form" ? (
          <section className="bg-white rounded-2xl border border-[#e2e8f0] p-6 shadow-sm">
            {/* Top Toolbar (Filters & Actions) */}
            <div className="flex flex-col md:flex-row items-start md:items-center justify-between mb-6 gap-4">
              <div className="flex items-center gap-2 w-full md:w-auto">
                {/* Search Bar Placeholder */}
                <div className="relative w-full md:w-64">
                  <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                    <Search size={18} className="text-slate-400" />
                  </div>
                  <input
                    type="text"
                    placeholder="Cari konten..."
                    className="block w-full pl-10 pr-3 py-2 border border-[#e2e8f0] rounded-xl text-[14px] bg-[#F7FAFB] focus:bg-white focus:outline-none focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5] transition-colors"
                  />
                </div>
              </div>

              <div className="flex flex-wrap items-center gap-3 w-full md:w-auto">
                {resourcePath === "edukasi-perawatan-anak" && (
                  <select
                    value={activeRentangUsia}
                    onChange={(e) => {
                      const newVal = e.target.value;
                      setActiveRentangUsia(newVal);
                      loadData(newVal ? { rentang_usia: newVal } : {});
                    }}
                    className="px-3 py-2 border border-[#e2e8f0] rounded-xl bg-[#F7FAFB] text-slate-700 text-[14px] font-semibold hover:bg-white focus:bg-white focus:outline-none focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5] transition-colors"
                  >
                    <option value="">Semua Umur</option>
                    <option value="0-3 bulan">0-3 bulan</option>
                    <option value="0-28 hari">0-28 hari</option>
                    <option value="3-6 bulan">3-6 bulan</option>
                    <option value="6-9 bulan">6-9 bulan</option>
                    <option value="9-12 bulan">9-12 bulan</option>
                    <option value="12-18 bulan">12-18 bulan</option>
                    <option value="18-24 bulan">18-24 bulan</option>
                    <option value="2-3 tahun">2-3 tahun</option>
                    <option value="3-4 tahun">3-4 tahun</option>
                    <option value="4-5 tahun">4-5 tahun</option>
                    <option value="5-6 tahun">5-6 tahun</option>
                  </select>
                )}
                {resourcePath === "edukasi-pola-asuh" && (
                  <select
                    value={activeRentangUsia}
                    onChange={(e) => {
                      const newVal = e.target.value;
                      setActiveRentangUsia(newVal);
                      loadData(newVal ? { rentang_usia: newVal } : {});
                    }}
                    className="px-3 py-2 border border-[#e2e8f0] rounded-xl bg-[#F7FAFB] text-slate-700 text-[14px] font-semibold hover:bg-white focus:bg-white focus:outline-none focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5] transition-colors"
                  >
                    <option value="">Semua Umur</option>
                    <option value="0-18 Bulan">0-18 Bulan</option>
                    <option value="1.5 Tahun - 3 Tahun">1.5 Tahun - 3 Tahun</option>
                    <option value="3 tahun - 6 Tahun">3 tahun - 6 Tahun</option>
                  </select>
                )}
                {/* <button className="px-4 py-2 flex items-center gap-2 rounded-xl bg-white border border-[#e2e8f0] text-slate-700 text-[14px] font-semibold hover:bg-[#F7FAFB] transition-colors">
                  <Filter size={16} /> Filter & Urutkan
                </button> */}
                <button
                  type="button"
                  onClick={() => {
                    if (createPath) {
                      navigate(createPath);
                      return;
                    }
                    setForm(emptyForm);
                    setEditingId(null);
                    setShowForm(true);
                  }}
                  className="px-4 py-2 rounded-xl bg-[#185FA5] text-white text-[16px] font-semibold hover:bg-[#185FA5]/90 flex items-center gap-2 transition-all active:scale-95"
                >
                  <Plus size={18} /> Tambah Konten
                </button>
              </div>
            </div>

            {/* UI Loader */}
            {loading ? (
              <div className="flex flex-col items-center justify-center py-16 gap-3">
                <RefreshCw size={36} className="animate-spin text-[#185FA5]" />
                <p className="text-[14px] text-slate-500 font-medium">Memuat data edukasi...</p>
              </div>
            ) : (
              <>
                {/* Modern Table Layout */}
                <div className="border border-[#e2e8f0] rounded-xl overflow-x-auto bg-white">
                  <table className="w-full text-left border-collapse whitespace-nowrap min-w-[800px]">
                    <thead className="bg-[#F7FAFB] text-[14px] text-slate-500 font-semibold border-b border-[#e2e8f0]">
                      <tr>
                        <th className="px-6 py-4 font-semibold">Info Konten</th>
                        <th className="px-6 py-4 font-semibold">Kategori</th>
                        <th className="px-6 py-4 font-semibold">Terakhir Diubah</th>
                        <th className="px-6 py-4 font-semibold text-center">Aksi</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-[#e2e8f0]">
                      {sortedRows.length === 0 ? (
                        <tr>
                          <td colSpan="4" className="px-6 py-10 text-center text-[14px] text-slate-500 bg-[#F7FAFB]/50">
                            Belum ada konten yang tersedia.
                          </td>
                        </tr>
                      ) : (
                        sortedRows.map((item) => {
                          const id = guessId(item);
                          return (
                            <tr key={id || item.judul} className="hover:bg-[#F7FAFB]/50 transition-colors group">
                              <td className="px-6 py-4">
                                <div className="flex items-center gap-4">
                                  {/* Thumbnail */}
                                  <div className="w-12 h-12 rounded-lg bg-[#F7FAFB] border border-[#e2e8f0] overflow-hidden flex-shrink-0 flex items-center justify-center">
                                    {guessImage(item) ? (
                                      <img 
                                        src={guessImage(item)} 
                                        alt={item.judul}
                                        className="w-full h-full object-cover"
                                        onError={(e) => {
                                          e.target.style.display = 'none';
                                        }}
                                      />
                                    ) : (
                                      <ImageIcon size={20} className="text-slate-400" />
                                    )}
                                  </div>
                                  {/* Text Info */}
                                  <div className="max-w-[300px] whitespace-normal">
                                    <p className="text-[16px] font-bold text-slate-800 line-clamp-1">
                                      {getItemTitle(item)}
                                    </p>
                                    <p className="text-[12px] text-slate-500 line-clamp-1 mt-0.5">
                                      {getItemDescription(item)}
                                    </p>
                                  </div>
                                </div>
                              </td>
                              
                              <td className="px-6 py-4">
                                <span className="inline-flex items-center gap-1.5 px-3 py-1 bg-[#185FA5]/10 text-[#185FA5] rounded-full text-[12px] font-semibold">
                                  <BookOpen size={14} /> {item.rentang_usia || guessCategory(item)}
                                </span>
                              </td>
                              
                              <td className="px-6 py-4">
                                <span className="text-[14px] text-slate-600">
                                  {formatDate(item.updated_at || item.created_at)}
                                </span>
                              </td>
                              
                              <td className="px-6 py-4">
                                <div className="flex items-center justify-center gap-2">
                                  {/* <button
                                    type="button"
                                    className="p-2 text-slate-400 hover:text-[#185FA5] hover:bg-[#185FA5]/10 rounded-lg transition-colors border border-transparent hover:border-[#185FA5]/20"
                                    title="Detail"
                                  >
                                    <Eye size={18} />
                                  </button> */}
                                  <button
                                    type="button"
                                    onClick={() => handleEdit(item)}
                                    className="p-2 text-slate-400 hover:text-[#185FA5] hover:bg-[#185FA5]/10 rounded-lg transition-colors border border-transparent hover:border-[#185FA5]/20"
                                    title="Edit"
                                  >
                                    <Pencil size={18} />
                                  </button>
                                  <button
                                    type="button"
                                    onClick={() => handleDelete(item)}
                                    className="p-2 text-slate-400 hover:text-[#A32D2D] hover:bg-[#A32D2D]/10 rounded-lg transition-colors border border-transparent hover:border-[#A32D2D]/20"
                                    title="Hapus"
                                  >
                                    <Trash2 size={18} />
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

                {/* Pagination Footer */}
                {sortedRows.length > 0 && (
                  <div className="flex items-center justify-between mt-6 text-[14px] text-slate-500">
                    <p>Menampilkan 1-{Math.min(5, sortedRows.length)} dari {sortedRows.length} data</p>
                    <div className="flex items-center gap-1">
                      <button className="w-8 h-8 flex items-center justify-center rounded-lg border border-[#e2e8f0] text-slate-400 hover:bg-[#F7FAFB] hover:text-slate-700 transition-colors">
                        <ChevronLeft size={16} />
                      </button>
                      <button className="w-8 h-8 flex items-center justify-center rounded-lg bg-[#185FA5] text-white font-semibold transition-colors">
                        1
                      </button>
                      <button className="w-8 h-8 flex items-center justify-center rounded-lg border border-[#e2e8f0] text-slate-600 hover:bg-[#F7FAFB] transition-colors">
                        2
                      </button>
                      <span className="px-1 text-slate-400">...</span>
                      <button className="w-8 h-8 flex items-center justify-center rounded-lg border border-[#e2e8f0] text-slate-400 hover:bg-[#F7FAFB] hover:text-slate-700 transition-colors">
                        <ChevronRight size={16} />
                      </button>
                    </div>
                  </div>
                )}
              </>
            )}
          </section>
        ) : null}

        {/* Form Section */}
        {(view === "form" || (view === "inline" && showForm)) && (
          <section className="bg-white rounded-2xl border border-[#e2e8f0] p-6 shadow-sm">
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-[22px] font-semibold text-slate-800">
                {editingId ? "Edit Konten" : "Tambah Konten"}
              </h2>
            </div>

            {view === "form" && loading ? (
              <div className="flex flex-col items-center justify-center py-16 gap-3">
                <RefreshCw size={36} className="animate-spin text-[#185FA5]" />
                <p className="text-[14px] text-slate-500 font-medium">Memuat data formulir...</p>
              </div>
            ) : (
            <form onSubmit={handleSubmit} className="space-y-4">
              {(fields && Array.isArray(fields) ? fields : [
                { key: "judul", label: "Judul", type: "text" },
                { key: "gambar_url", label: "URL gambar (opsional)", type: "text" },
                { key: "deskripsi", label: "Deskripsi", type: "textarea", rows: 2 },
                { key: "isi_konten", label: "Isi konten", type: "textarea", rows: 4 },
                { key: "materi_inti", label: "Materi inti", type: "textarea", rows: 2 },
                { key: "hal_penting", label: "Hal penting", type: "textarea", rows: 2 },
              ]).filter(f => f.key !== 'materi_inti').map((f) => {
                const value = form[f.key] ?? "";
                if (f.type === "checkbox") {
                  return (
                    <label key={f.key} className="flex items-center gap-3 rounded-xl border border-slate-200 bg-[#F7FAFB] px-4 py-3">
                      <input
                        name={f.key}
                        type="checkbox"
                        checked={Boolean(value)}
                        onChange={handleChange}
                        className="h-4 w-4 rounded border-slate-300 text-[#185FA5] focus:ring-[#185FA5]"
                      />
                      <span className="text-[14px] font-semibold text-slate-700">{f.label}</span>
                    </label>
                  );
                }

                if (f.type === "select") {
                  return (
                    <div key={f.key} className="space-y-1">
                      <label className="text-[14px] font-semibold text-slate-700 ml-1">{f.label}</label>
                      <select
                        name={f.key}
                        value={value}
                        onChange={handleChange}
                        className="w-full border border-slate-200 bg-[#F7FAFB] rounded-xl px-4 py-3 text-[14px] focus:bg-white focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5] outline-none transition-all"
                      >
                        <option value="">{f.placeholder || `Pilih ${f.label.toLowerCase()}`}</option>
                        {(f.options || []).map((option) => {
                          const optValue = typeof option === 'string' ? option : option.value;
                          const optLabel = typeof option === 'string' ? option : (option.label || optValue);
                          return (
                            <option key={String(optValue)} value={optValue}>
                              {optLabel}
                            </option>
                          );
                        })}
                      </select>
                    </div>
                  );
                }

                if (f.type === "array") {
                  return (
                    <div key={f.key} className="space-y-1">
                      <label className="text-[14px] font-semibold text-slate-700 ml-1">{f.label}</label>
                      <textarea
                        name={f.key}
                        value={value}
                        onChange={handleChange}
                        placeholder={f.placeholder || `Masukkan ${f.label.toLowerCase()} (satu item per baris)`}
                        rows={f.rows || 4}
                        className="w-full border border-slate-200 bg-[#F7FAFB] rounded-xl px-4 py-3 text-[14px] focus:bg-white focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5] outline-none transition-all"
                      />
                      <p className="text-[12px] text-slate-500 ml-1">Setiap baris akan menjadi satu item dalam daftar.</p>
                    </div>
                  );
                }

                if (f.type === "textarea") {
                  return (
                    <div key={f.key} className="space-y-1">
                      <label className="text-[14px] font-semibold text-slate-700 ml-1">{f.label}</label>
                      <textarea
                        name={f.key}
                        value={value}
                        onChange={handleChange}
                        placeholder={`Masukkan ${f.label.toLowerCase()}`}
                        rows={f.rows || 3}
                        className="w-full border border-slate-200 bg-[#F7FAFB] rounded-xl px-4 py-3 text-[14px] focus:bg-white focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5] outline-none transition-all"
                      />
                    </div>
                  );
                }

                return (
                  <div key={f.key} className="space-y-1">
                    <label className="text-[14px] font-semibold text-slate-700 ml-1">{f.label}</label>
                    <input
                      name={f.key}
                      value={value}
                      onChange={handleChange}
                      placeholder={`Masukkan ${f.label.toLowerCase()}`}
                      className="w-full border border-slate-200 bg-[#F7FAFB] rounded-xl px-4 py-3 text-[14px] focus:bg-white focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5] outline-none transition-all"
                    />
                    {f.key === "gambar_url" && value && (
                      <div className="mt-2 w-full max-w-xs h-32 rounded-xl overflow-hidden border border-slate-200 bg-[#F7FAFB] relative">
                        <img 
                          src={value} 
                          alt="Preview" 
                          key={value}
                          className="w-full h-full object-cover"
                          onError={(e) => {
                            e.target.style.opacity = '0';
                            e.target.parentElement.classList.add('bg-[#A32D2D]/10');
                          }}
                        />
                        <div className="absolute inset-0 flex flex-col items-center justify-center -z-10 text-slate-400 gap-1">
                          <ImageIcon size={24} />
                          <span className="text-[12px] font-semibold uppercase">Invalid URL</span>
                        </div>
                      </div>
                    )}
                  </div>
                );
              })}

              {/* Special Section: Materi Inti (Dynamic List) */}
              {(fields === null || fields.some(f => f.key === 'materi_inti')) && (
                <div className="pt-4 border-t border-[#e2e8f0]">
                  <div className="flex items-center justify-between mb-4">
                    <div>
                      <h3 className="text-[16px] font-bold text-slate-800">Materi Inti</h3>
                      <p className="text-[12px] text-slate-500 mt-1">Tambahkan satu atau lebih blok materi inti.</p>
                    </div>
                    <button
                      type="button"
                      onClick={handleAddMateriInti}
                      className="flex items-center gap-1.5 px-4 py-2 bg-[#185FA5]/10 text-[#185FA5] rounded-lg text-[14px] font-semibold hover:bg-[#185FA5]/20 transition-colors"
                    >
                      <Plus size={16} /> Tambah Materi
                    </button>
                  </div>

                  <div className="space-y-4">
                    {materiIntiList.map((item, index) => (
                      <div key={index} className="bg-[#F7FAFB] p-5 rounded-2xl border border-[#e2e8f0] relative group/item">
                        <button
                          type="button"
                          onClick={() => handleRemoveMateriInti(index)}
                          className="absolute top-4 right-4 p-1.5 text-slate-400 hover:text-[#A32D2D] hover:bg-[#A32D2D]/10 rounded-lg transition-colors opacity-0 group-hover/item:opacity-100"
                        >
                          <Trash2 size={16} />
                        </button>
                        <div className="space-y-4 pr-8">
                          <div className="space-y-1">
                            <label className="text-[14px] font-semibold text-slate-700 ml-1">Judul Materi {index + 1}</label>
                            <input
                              value={item.judul}
                              onChange={(e) => handleChangeMateriInti(index, "judul", e.target.value)}
                              placeholder="Contoh: Pengertian ASI Eksklusif"
                              className="w-full bg-white border border-slate-200 rounded-xl px-4 py-3 text-[14px] focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5] outline-none transition-all"
                            />
                          </div>
                          <div className="space-y-1">
                            <label className="text-[14px] font-semibold text-slate-700 ml-1">Isi Materi</label>
                            <textarea
                              value={item.isi}
                              onChange={(e) => handleChangeMateriInti(index, "isi", e.target.value)}
                              placeholder="Tulis penjelasan detail di sini..."
                              rows={3}
                              className="w-full bg-white border border-slate-200 rounded-xl px-4 py-3 text-[14px] focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5] outline-none transition-all"
                            />
                          </div>
                        </div>
                      </div>
                    ))}

                    {materiIntiList.length === 0 && (
                      <div className="text-center py-8 border-2 border-dashed border-[#e2e8f0] rounded-2xl bg-[#F7FAFB]">
                        <BookOpen size={28} className="mx-auto text-slate-300 mb-3" />
                        <p className="text-[14px] font-medium text-slate-500">Belum ada materi inti yang ditambahkan</p>
                      </div>
                    )}
                  </div>
                </div>
              )}

              {error ? <p className="text-[14px] text-[#A32D2D] bg-[#A32D2D]/10 p-3 rounded-lg">{error}</p> : null}

              <div className="flex gap-3 pt-4">
                <button
                  type="submit"
                  disabled={saving}
                  className="px-6 py-2.5 rounded-lg bg-[#185FA5] text-white text-[16px] font-semibold disabled:opacity-60 hover:bg-[#185FA5]/90 transition-colors"
                >
                  {saving ? "Menyimpan..." : editingId ? "Update Konten" : "Simpan Konten"}
                </button>
                <button
                  type="button"
                  onClick={() => {
                    if (view === "form") {
                      navigate(listPath || "/edukasi-digital/informasi-umum");
                      return;
                    }
                    resetForm();
                  }}
                  className="px-6 py-2.5 rounded-lg bg-[#F7FAFB] text-slate-700 text-[16px] font-semibold border border-slate-200 hover:bg-[#e2e8f0] transition-colors"
                >
                  Batal
                </button>
              </div>
            </form>
            )}
          </section>
        )}
      </div>
    </MainLayout>
  );

}