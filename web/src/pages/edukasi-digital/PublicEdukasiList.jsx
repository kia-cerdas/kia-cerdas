import React, { useEffect, useState, useMemo } from "react";
import { useParams, Link, useNavigate } from "react-router-dom";
import { Search, BookOpen, Clock, AlertTriangle, ArrowLeft, ChevronRight, ImageIcon } from "lucide-react";
import PublicLayout, { PUBLIC_EDUKASI_MENU } from "../../components/Layout/PublicLayout";
import { listPublicEdukasi } from "../../services/edukasiDigital";

const mapCategoryToResource = (category) => {
  for (const item of PUBLIC_EDUKASI_MENU) {
    if (item.submodules) {
      const found = item.submodules.find(sub => sub.path === category);
      if (found) return found;
    }
    if (item.path === category) return item;
  }
  return null;
};

const getCategoryLabel = (category) => {
  const resource = mapCategoryToResource(category);
  return resource ? resource.label : "Edukasi Kesehatan";
};

export default function PublicEdukasiList() {
  const { category } = useParams();
  const navigate = useNavigate();
  const [rows, setRows] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [searchQuery, setSearchQuery] = useState("");
  const [activeRentangUsia, setActiveRentangUsia] = useState("");

  const categoryInfo = mapCategoryToResource(category);
  const resourcePath = categoryInfo?.resource;

  const loadData = async (filterParams = {}) => {
    if (!resourcePath) {
      setError("Kategori edukasi tidak valid.");
      setLoading(false);
      return;
    }
    setLoading(true);
    setError("");
    try {
      const data = await listPublicEdukasi(resourcePath, filterParams);
      setRows(Array.isArray(data) ? data : []);
    } catch (err) {
      setError("Gagal memuat konten edukasi dari server. Silakan coba beberapa saat lagi.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    setActiveRentangUsia("");
    setSearchQuery("");
    loadData();
  }, [category]);

  const handleFilterUsia = (usia) => {
    setActiveRentangUsia(usia);
    const params = usia ? { rentang_usia: usia } : {};
    loadData(params);
  };

  const filteredRows = useMemo(() => {
    if (!searchQuery.trim()) return rows;
    return rows.filter((item) => {
      const title = (item.judul || "").toLowerCase();
      const desc = (item.deskripsi || item.isi_konten || "").toLowerCase();
      const q = searchQuery.toLowerCase();
      return title.includes(q) || desc.includes(q);
    });
  }, [rows, searchQuery]);

  const getItemTitle = (item) => {
    if (item.judul) return item.judul;
    
    if (item.bulan_min !== undefined && item.bulan_max !== undefined) {
      if (resourcePath === "edukasi-mpasi-jadwal-harian") {
        return `Jadwal Harian MPASI Usia ${item.bulan_min} - ${item.bulan_max} Bulan`;
      }
      if (resourcePath === "edukasi-mpasi-aturan-porsi") {
        return `Aturan Porsi MPASI Usia ${item.bulan_min} - ${item.bulan_max} Bulan`;
      }
      return `Panduan MPASI Usia ${item.bulan_min} - ${item.bulan_max} Bulan`;
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
    return "Klik untuk membaca selengkapnya.";
  };

  const guessImage = (item) => {
    return item?.gambar_url ?? item?.GambarURL ?? item?.image_url ?? "";
  };

  const guessId = (item) => {
    return item?.id ?? item?.ID ?? item?.id_edukasi ?? item?.id_informasi ?? null;
  };

  return (
    <PublicLayout>
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
        {/* Breadcrumbs */}
        <nav className="flex items-center gap-1.5 text-xs sm:text-sm text-slate-500 mb-6 text-left">
          <Link to="/" className="hover:text-indigo-600 transition-colors">Beranda</Link>
          <ChevronRight size={14} className="text-slate-400" />
          <span className="text-slate-700 font-semibold">{getCategoryLabel(category)}</span>
        </nav>

        {/* Header Section */}
        <section className="bg-white rounded-3xl border border-slate-100 p-6 md:p-8 shadow-sm flex flex-col md:flex-row md:items-center justify-between gap-6 mb-8 text-left">
          <div>
            <h1 className="text-2xl md:text-3xl font-extrabold text-slate-800">
              {getCategoryLabel(category)}
            </h1>
            <p className="text-sm md:text-base text-slate-500 mt-2">
              Kumpulan artikel edukasi dan panduan kesehatan resmi dari tim medis Generasi Sehat.
            </p>
          </div>
          <button
            onClick={() => navigate("/")}
            className="flex items-center gap-1.5 text-slate-600 hover:text-indigo-600 font-semibold text-sm self-start md:self-auto"
          >
            <ArrowLeft size={16} />
            Kembali ke Beranda
          </button>
        </section>

        {/* Toolbar: Search and Filter */}
        <div className="flex flex-col md:flex-row gap-4 items-stretch md:items-center justify-between mb-8">
          {/* Search bar */}
          <div className="relative flex-grow max-w-md">
            <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none">
              <Search size={18} className="text-slate-400" />
            </div>
            <input
              type="text"
              placeholder="Cari materi edukasi..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="block w-full pl-10 pr-4 py-3 border border-slate-200 rounded-2xl text-sm bg-white placeholder-slate-400 focus:outline-none focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500 transition-all shadow-sm"
            />
          </div>

          {/* Age Filters for specific categories */}
          {["perawatan-anak", "pola-asuh"].includes(category) && (
            <div className="flex items-center gap-2 overflow-x-auto pb-1 md:pb-0">
              <span className="text-sm text-slate-500 font-medium whitespace-nowrap">Filter Usia:</span>
              <div className="flex items-center gap-1.5">
                {category === "perawatan-anak" ? (
                  <>
                    <button
                      onClick={() => handleFilterUsia("")}
                      className={`px-3.5 py-1.5 rounded-xl text-xs font-bold transition-all ${
                        activeRentangUsia === ""
                          ? "bg-indigo-600 text-white shadow-md shadow-indigo-150"
                          : "bg-white text-slate-600 border border-slate-200 hover:bg-slate-50"
                      }`}
                    >
                      Semua
                    </button>
                    {["0-28 hari", "0-3 bulan", "3-6 bulan", "6-9 bulan", "9-12 bulan", "12-18 bulan", "18-24 bulan"].map((opt) => (
                      <button
                        key={opt}
                        onClick={() => handleFilterUsia(opt)}
                        className={`px-3.5 py-1.5 rounded-xl text-xs font-bold transition-all whitespace-nowrap ${
                          activeRentangUsia === opt
                            ? "bg-indigo-600 text-white shadow-md shadow-indigo-150"
                            : "bg-white text-slate-600 border border-slate-200 hover:bg-slate-50"
                        }`}
                      >
                        {opt}
                      </button>
                    ))}
                  </>
                ) : (
                  <>
                    <button
                      onClick={() => handleFilterUsia("")}
                      className={`px-3.5 py-1.5 rounded-xl text-xs font-bold transition-all ${
                        activeRentangUsia === ""
                          ? "bg-indigo-600 text-white shadow-md shadow-indigo-150"
                          : "bg-white text-slate-600 border border-slate-200 hover:bg-slate-50"
                      }`}
                    >
                      Semua
                    </button>
                    {["0-18 Bulan", "1.5 Tahun - 3 Tahun", "3 tahun - 6 Tahun"].map((opt) => (
                      <button
                        key={opt}
                        onClick={() => handleFilterUsia(opt)}
                        className={`px-3.5 py-1.5 rounded-xl text-xs font-bold transition-all whitespace-nowrap ${
                          activeRentangUsia === opt
                            ? "bg-indigo-600 text-white shadow-md shadow-indigo-150"
                            : "bg-white text-slate-600 border border-slate-200 hover:bg-slate-50"
                        }`}
                      >
                        {opt}
                      </button>
                    ))}
                  </>
                )}
              </div>
            </div>
          )}
        </div>

        {/* Error Alert */}
        {error && (
          <div className="bg-red-50 border border-red-200 text-red-700 px-6 py-4 rounded-2xl flex items-center gap-3 mb-8 text-left">
            <AlertTriangle className="text-red-500 flex-shrink-0" size={24} />
            <div>
              <p className="font-bold text-sm">Kesalahan Koneksi</p>
              <p className="text-xs text-red-600 mt-0.5">{error}</p>
            </div>
          </div>
        )}

        {/* Loading Spinner */}
        {loading ? (
          <div className="flex flex-col items-center justify-center py-20 gap-3">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600"></div>
            <p className="text-sm text-slate-500 font-medium">Memuat materi edukasi...</p>
          </div>
        ) : filteredRows.length === 0 ? (
          /* Empty state */
          <div className="bg-white rounded-3xl border-2 border-dashed border-slate-200 py-16 px-4 text-center">
            <svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1" strokeLinecap="round" strokeLinejoin="round" className="text-slate-300 mx-auto mb-4">
              <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
              <polyline points="14,2 14,8 20,8"></polyline>
              <line x1="16" y1="13" x2="8" y2="13"></line>
              <line x1="16" y1="17" x2="8" y2="17"></line>
              <polyline points="10,9 9,9 8,9"></polyline>
            </svg>
            <h3 className="text-lg font-bold text-slate-700 mb-1">Materi Belum Tersedia</h3>
            <p className="text-sm text-slate-400 max-w-sm mx-auto">
              Belum ada artikel edukasi untuk kategori ini. Tim kesehatan kami akan segera merilis artikel terbaru dalam waktu dekat.
            </p>
          </div>
        ) : (
          /* Grid of articles */
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {filteredRows.map((item, idx) => {
              const id = guessId(item);
              const imgUrl = guessImage(item);
              
              return (
                <article
                  key={id || idx}
                  className="bg-white rounded-3xl border border-slate-100 overflow-hidden shadow-sm hover:shadow-lg hover:-translate-y-0.5 transition-all duration-300 text-left flex flex-col"
                >
                  {/* Card Image */}
                  <div className="h-48 bg-slate-100 relative overflow-hidden flex items-center justify-center flex-shrink-0">
                    {imgUrl ? (
                      <img
                        src={imgUrl}
                        alt={getItemTitle(item)}
                        className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
                        onError={(e) => {
                          e.target.parentNode.innerHTML = '<div class="text-slate-400 flex flex-col items-center gap-1.5"><svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-image"><rect width="18" height="18" x="3" y="3" rx="2" ry="2"/><circle cx="9" cy="9" r="2"/><path d="m21 15-3.086-3.086a2 2 0 0 0-2.828 0L6 21"/></svg><span class="text-xs">Gambar rusak</span></div>';
                        }}
                      />
                    ) : (
                      <div className="text-slate-400 flex flex-col items-center gap-2">
                        <ImageIcon size={36} strokeWidth={1.5} />
                        <span className="text-xs font-medium">No Image</span>
                      </div>
                    )}
                    
                    {/* Badge Rentang Usia/Kategori */}
                    <div className="absolute top-4 left-4">
                      <span className="inline-flex items-center gap-1 px-3 py-1 bg-white/90 backdrop-blur-sm text-indigo-700 rounded-full text-xs font-bold shadow-sm">
                        <BookOpen size={12} />
                        {item.rentang_usia || item.kategori || "Umum"}
                      </span>
                    </div>
                  </div>

                  {/* Card Body */}
                  <div className="p-6 flex-grow flex flex-col justify-between">
                    <div>
                      <h3 className="text-lg font-bold text-slate-800 mb-3 line-clamp-2 hover:text-indigo-600 transition-colors">
                        <Link to={`/edukasi-publik/${category}/${id}`}>
                          {getItemTitle(item)}
                        </Link>
                      </h3>
                      <p className="text-sm text-slate-500 line-clamp-3 leading-relaxed mb-6">
                        {getItemDescription(item)}
                      </p>
                    </div>

                    <div className="border-t border-slate-50 pt-4 flex items-center justify-between mt-auto">
                      <span className="text-xs text-slate-400 flex items-center gap-1">
                        <Clock size={12} />
                        {item.created_at ? new Date(item.created_at).toLocaleDateString('id-ID', { day: 'numeric', month: 'short' }) : 'Baru'}
                      </span>

                      <Link
                        to={`/edukasi-publik/${category}/${id}`}
                        className="inline-flex items-center gap-1.5 text-sm font-bold text-indigo-600 hover:text-indigo-700 transition-colors"
                      >
                        Baca Detail
                        <ChevronRight size={16} />
                      </Link>
                    </div>
                  </div>
                </article>
              );
            })}
          </div>
        )}
      </div>
    </PublicLayout>
  );
}
