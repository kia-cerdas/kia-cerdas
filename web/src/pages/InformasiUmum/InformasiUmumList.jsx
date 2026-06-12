import React, { useEffect, useMemo, useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { CalendarDays, Edit3, Eye, RefreshCw, Search, Trash2, Plus } from "lucide-react";
import MainLayout from "../../components/Layout/MainLayout";
import { deleteInformasiUmum, getInformasiUmumList } from "../../services/informasiUmum";

const cardClass = "rounded-2xl border border-slate-100 bg-white shadow-sm";

const normalizeText = (value) => (value ?? "").toString().trim();

const InformasiUmumList = () => {
  const navigate = useNavigate();
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(false);
  const [search, setSearch] = useState("");
  const [errorMessage, setErrorMessage] = useState("");
  const [successMessage, setSuccessMessage] = useState("");

  const loadItems = async () => {
    setLoading(true);
    setErrorMessage("");
    try {
      const data = await getInformasiUmumList();
      setItems(Array.isArray(data) ? data : []);
    } catch (error) {
      setErrorMessage(error?.response?.data?.message || error.message || "Gagal memuat data informasi umum");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadItems();
  }, []);

  const filteredItems = useMemo(() => {
    const keyword = search.trim().toLowerCase();
    if (!keyword) return items;

    return items.filter((item) => {
      const haystack = [item.tipe, item.judul, item.umur_target, item.durasi_baca, item.ringkasan, item.konten, item.yang_perlu_diingat]
        .map(normalizeText)
        .join(" ")
        .toLowerCase();
      return haystack.includes(keyword);
    });
  }, [items, search]);

  const handleDelete = async (id) => {
    if (!window.confirm("Hapus informasi umum ini?")) return;

    setErrorMessage("");
    setSuccessMessage("");
    try {
      await deleteInformasiUmum(id);
      setSuccessMessage("Data informasi umum berhasil dihapus");
      await loadItems();
    } catch (error) {
      setErrorMessage(error?.response?.data?.message || error.message || "Gagal menghapus data");
    }
  };

  return (
    <MainLayout>
      <div className="space-y-6">
        <div className="flex flex-col gap-4 rounded-3xl bg-gradient-to-r from-blue-600 via-sky-600 to-cyan-500 px-6 py-6 text-white shadow-lg shadow-blue-100 md:flex-row md:items-center md:justify-between">
          <div>
            <p className="text-xs font-semibold uppercase tracking-[0.28em] text-white/75">Dashboard Admin</p>
            <h1 className="mt-2 text-2xl font-bold md:text-3xl">CRUD Informasi Umum</h1>
            <p className="mt-2 max-w-2xl text-sm text-white/80">
              Data yang disimpan di sini akan dipakai langsung oleh aplikasi mobile pada halaman edukasi.
            </p>
          </div>
          <div className="flex flex-wrap gap-3">
            <button
              type="button"
              onClick={loadItems}
              className="inline-flex items-center gap-2 rounded-xl border border-white/25 bg-white/10 px-4 py-2.5 text-sm font-semibold text-white backdrop-blur transition hover:bg-white/20"
            >
              <RefreshCw size={16} />
              Muat ulang
            </button>
            <Link
              to="/dashboard/admin/informasi-umum/create"
              className="inline-flex items-center gap-2 rounded-xl bg-white px-4 py-2.5 text-sm font-semibold text-sky-700 transition hover:bg-sky-50"
            >
              <Plus size={16} />
              Tambah Konten
            </Link>
          </div>
        </div>

        {errorMessage ? (
          <div className="rounded-2xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">{errorMessage}</div>
        ) : null}

        {successMessage ? (
          <div className="rounded-2xl border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm text-emerald-700">
            {successMessage}
          </div>
        ) : null}

        <div className={`${cardClass} p-4 md:p-5`}>
          <div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
            <div>
              <h2 className="text-lg font-bold text-slate-800">Daftar Informasi Umum</h2>
              <p className="text-sm text-slate-500">Kelola artikel, video, dan materi edukasi untuk mobile.</p>
            </div>
            <div className="relative w-full md:w-96">
              <Search className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" size={18} />
              <input
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                placeholder="Cari judul, tipe, umur target, ringkasan..."
                className="w-full rounded-xl border border-slate-200 bg-slate-50 py-3 pl-10 pr-4 text-sm text-slate-700 outline-none transition focus:border-sky-400 focus:bg-white"
              />
            </div>
          </div>

          <div className="mt-5 overflow-x-auto">
            <table className="min-w-full border-separate border-spacing-y-3">
              <thead>
                <tr className="text-left text-xs font-semibold uppercase tracking-[0.18em] text-slate-400">
                  <th className="px-4 py-2">Konten</th>
                  <th className="px-4 py-2">Kategori</th>
                  <th className="px-4 py-2">Target</th>
                  <th className="px-4 py-2">Status</th>
                  <th className="px-4 py-2">Aksi</th>
                </tr>
              </thead>
              <tbody>
                {loading ? (
                  <tr>
                    <td colSpan={5} className="px-4 py-10 text-center text-sm text-slate-500">
                      Memuat data...
                    </td>
                  </tr>
                ) : filteredItems.length === 0 ? (
                  <tr>
                    <td colSpan={5} className="px-4 py-10 text-center text-sm text-slate-500">
                      Belum ada data atau tidak ada hasil yang cocok.
                    </td>
                  </tr>
                ) : (
                  filteredItems.map((item) => (
                    <tr key={item.id} className="rounded-2xl bg-slate-50/70 shadow-sm ring-1 ring-slate-100">
                      <td className="rounded-l-2xl px-4 py-4 align-top">
                        <div className="flex items-start gap-3">
                          <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl bg-sky-100 text-sky-600">
                            <Eye size={18} />
                          </div>
                          <div className="space-y-1">
                            <p className="text-sm font-semibold text-slate-800">{item.judul}</p>
                            <p className="max-w-xl text-xs leading-relaxed text-slate-500 line-clamp-2">
                              {item.ringkasan || item.yang_perlu_diingat || item.konten}
                            </p>
                            <div className="flex flex-wrap gap-2 pt-1 text-[11px] text-slate-500">
                              <span className="inline-flex items-center gap-1 rounded-full bg-white px-2.5 py-1">
                                <CalendarDays size={12} />
                                {normalizeText(item.durasi_baca) || "-"}
                              </span>
                              <span className="rounded-full bg-white px-2.5 py-1">ID: {item.id}</span>
                              {normalizeText(item.yang_perlu_diingat) ? (
                                <span className="rounded-full bg-white px-2.5 py-1">
                                  Perlu Diingat: {normalizeText(item.yang_perlu_diingat).split(/\n+/).filter(Boolean).length} poin
                                </span>
                              ) : null}
                            </div>
                          </div>
                        </div>
                      </td>
                      <td className="px-4 py-4 align-top text-sm font-semibold text-slate-700">{item.tipe}</td>
                      <td className="px-4 py-4 align-top text-sm text-slate-600">{normalizeText(item.umur_target) || "-"}</td>
                      <td className="px-4 py-4 align-top">
                        <span
                          className={`inline-flex rounded-full px-3 py-1 text-xs font-semibold ${
                            item.is_active ? "bg-emerald-100 text-emerald-700" : "bg-slate-200 text-slate-600"
                          }`}
                        >
                          {item.is_active ? "Aktif" : "Nonaktif"}
                        </span>
                      </td>
                      <td className="rounded-r-2xl px-4 py-4 align-top">
                        <div className="flex flex-wrap gap-2">
                          <button
                            type="button"
                            onClick={() => navigate(`/dashboard/admin/informasi-umum/edit/${item.id}`)}
                            className="inline-flex items-center gap-2 rounded-xl border border-sky-200 bg-sky-50 px-3 py-2 text-xs font-semibold text-sky-700 transition hover:bg-sky-100"
                          >
                            <Edit3 size={14} />
                            Edit
                          </button>
                          <button
                            type="button"
                            onClick={() => handleDelete(item.id)}
                            className="inline-flex items-center gap-2 rounded-xl border border-red-200 bg-red-50 px-3 py-2 text-xs font-semibold text-red-700 transition hover:bg-red-100"
                          >
                            <Trash2 size={14} />
                            Hapus
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </MainLayout>
  );
};

export default InformasiUmumList;