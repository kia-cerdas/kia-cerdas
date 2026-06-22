import React, { useEffect, useState, useMemo } from "react";
import { useParams, Link, useNavigate } from "react-router-dom";
import { ArrowLeft, Clock, Calendar, CheckSquare, AlertCircle, ShieldCheck, ChevronRight, ImageIcon, Smartphone, Download, BookOpen, Heart, Baby, Lightbulb, ListChecks, Stethoscope, Brain, Leaf } from "lucide-react";
import PublicLayout, { PUBLIC_EDUKASI_MENU } from "../../components/Layout/PublicLayout";
import { getPublicEdukasiById, listPublicEdukasi } from "../../services/edukasiDigital";

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

export default function PublicEdukasiDetail() {
  const { category, id } = useParams();
  const navigate = useNavigate();
  
  const [detail, setDetail] = useState(null);
  const [related, setRelated] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  const categoryInfo = mapCategoryToResource(category);
  const resourcePath = categoryInfo?.resource;

  useEffect(() => {
    const loadContent = async () => {
      if (!resourcePath || !id) {
        setError("Parameter artikel tidak valid.");
        setLoading(false);
        return;
      }
      setLoading(true);
      setError("");
      try {
        // Fetch current article
        const item = await getPublicEdukasiById(resourcePath, id);
        setDetail(item);

        // Fetch related articles (same category, limit 3)
        const allItems = await listPublicEdukasi(resourcePath);
        if (Array.isArray(allItems)) {
          const filtered = allItems
            .filter(row => {
              const rowId = row?.id ?? row?.ID ?? row?.id_edukasi ?? row?.id_informasi;
              return String(rowId) !== String(id);
            })
            .slice(0, 3);
          setRelated(filtered);
        }
      } catch (err) {
        setError("Gagal memuat isi artikel edukasi. Konten mungkin telah dihapus.");
      } finally {
        setLoading(false);
      }
    };

    loadContent();
    window.scrollTo(0, 0);
  }, [category, id]);

  const getItemTitle = (item) => {
    if (!item) return "";
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

  // Parse Materi Inti (JSON String)
  const materiIntiList = useMemo(() => {
    if (!detail || !detail.materi_inti) return [];
    try {
      if (typeof detail.materi_inti === "string") {
        const parsed = JSON.parse(detail.materi_inti);
        return Array.isArray(parsed) ? parsed : [];
      } else if (Array.isArray(detail.materi_inti)) {
        return detail.materi_inti;
      }
    } catch (e) {
      return [];
    }
    return [];
  }, [detail]);

  const guessImage = (item) => {
    return item?.gambar_url ?? item?.GambarURL ?? item?.image_url ?? item?.thumbnail_url ?? item?.ThumbnailURL ?? "";
  };

  const handleDownload = () => {
    window.open("https://github.com/kia-cerdas/kia-cerdas/releases/download/v1.0.0/generasi-sehat-app.apk", "_blank");
  };

  if (loading) {
    return (
      <PublicLayout>
        <div className="flex flex-col items-center justify-center py-32 gap-3">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600"></div>
          <p className="text-sm text-slate-500 font-medium">Memuat artikel edukasi...</p>
        </div>
      </PublicLayout>
    );
  }

  if (error || !detail) {
    return (
      <PublicLayout>
        <div className="max-w-xl mx-auto px-4 py-20 text-center">
          <AlertCircle size={48} className="text-red-500 mx-auto mb-4" />
          <h2 className="text-xl font-bold text-slate-700 mb-2">Artikel Tidak Ditemukan</h2>
          <p className="text-sm text-slate-400 mb-6">{error || "Terjadi kesalahan saat memproses data."}</p>
          <button
            onClick={() => navigate(`/edukasi-publik/${category}`)}
            className="px-6 py-2.5 bg-indigo-600 hover:bg-indigo-700 text-white font-semibold rounded-xl text-sm"
          >
            Kembali ke Daftar
          </button>
        </div>
      </PublicLayout>
    );
  }

  const title = getItemTitle(detail);
  const formattedDate = detail.created_at
    ? new Date(detail.created_at).toLocaleDateString('id-ID', { day: 'numeric', month: 'long', year: 'numeric' })
    : "-";

  return (
    <PublicLayout>
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10 font-['Outfit',_sans-serif]">
        {/* Breadcrumbs */}
        <nav className="flex items-center gap-1.5 text-xs sm:text-sm text-slate-500 mb-8 text-left">
          <Link to="/" className="hover:text-indigo-600 transition-colors">Beranda</Link>
          <ChevronRight size={14} className="text-slate-400" />
          <Link to={`/edukasi-publik/${category}`} className="hover:text-indigo-600 transition-colors">
            {getCategoryLabel(category)}
          </Link>
          <ChevronRight size={14} className="text-slate-400" />
          <span className="text-slate-700 font-semibold truncate max-w-[200px] sm:max-w-none">{title}</span>
        </nav>

        {/* Content Grid */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-10">
          {/* Main Article Section (8 Columns) */}
          <div className="lg:col-span-8 text-left">
            <span className="inline-block px-3 py-1 bg-indigo-50 text-indigo-700 rounded-full text-xs font-bold mb-4">
              {detail.rentang_usia || detail.kategori || detail.tipe || detail.umur_target || "Umum"}
            </span>

            <h1 className="text-3xl sm:text-4xl font-extrabold text-slate-800 tracking-tight mb-4 leading-snug">
              {title}
            </h1>

            {/* Meta info */}
            <div className="flex flex-wrap items-center gap-4 text-xs sm:text-sm text-slate-400 border-b border-slate-100 pb-6 mb-6">
              <span className="flex items-center gap-1.5">
                <Calendar size={16} />
                Diterbitkan: {formattedDate}
              </span>
              <span className="w-1.5 h-1.5 rounded-full bg-slate-300 hidden sm:inline" />
              <span className="flex items-center gap-1.5">
                <Clock size={16} />
                Est. Baca: {detail.durasi_baca || "4 Menit"}
              </span>
              <span className="w-1.5 h-1.5 rounded-full bg-slate-300 hidden sm:inline" />
              <span className="inline-flex items-center gap-1 text-emerald-600 font-semibold bg-emerald-50 px-2 py-0.5 rounded-md">
                <ShieldCheck size={14} />
                Terverifikasi Medis
              </span>
            </div>

            {/* Featured Image */}
            <div className="w-full h-80 sm:h-96 rounded-[24px] overflow-hidden border border-slate-100 bg-slate-50 mb-8 flex items-center justify-center shadow-inner">
              {guessImage(detail) ? (
                <img
                  src={guessImage(detail)}
                  alt={title}
                  className="w-full h-full object-cover"
                  onError={(e) => {
                    e.target.parentNode.innerHTML = '<div class="text-slate-400 flex flex-col items-center gap-2"><svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-image"><rect width="18" height="18" x="3" y="3" rx="2" ry="2"/><circle cx="9" cy="9" r="2"/><path d="m21 15-3.086-3.086a2 2 0 0 0-2.828 0L6 21"/></svg><span class="text-sm font-semibold">Gagal memuat gambar artikel</span></div>';
                  }}
                />
              ) : (
                <div className="text-slate-300 flex flex-col items-center gap-2">
                  <ImageIcon size={64} strokeWidth={1} />
                  <span className="text-sm font-medium">Gambar Tidak Tersedia</span>
                </div>
              )}
            </div>

            {/* Main Content Body */}
            <div className="prose prose-slate max-w-none mb-10">
              {/* Ringkasan / Deskripsi Awal */}
              {(detail.ringkasan || detail.deskripsi) && (
                <p className="text-base sm:text-lg text-slate-700 leading-relaxed font-medium mb-6">
                  {detail.ringkasan || detail.deskripsi}
                </p>
              )}

              {/* Konten Utama — semua kemungkinan nama field */}
              {(detail.isi_konten || detail.isi || detail.konten) && (
                <div className="text-sm sm:text-base text-slate-600 leading-relaxed whitespace-pre-line space-y-4 mb-6">
                  {detail.isi_konten || detail.isi || detail.konten}
                </div>
              )}

              {/* Tidak ada konten sama sekali */}
              {!detail.ringkasan && !detail.deskripsi && !detail.isi_konten && !detail.isi && !detail.konten && (
                <p className="text-sm text-slate-400 italic">Tidak ada deskripsi detail untuk artikel ini.</p>
              )}
            </div>

            {/* ── BLOK KONTEN KHUSUS PER KATEGORI ── */}

            {/* IMD: Manfaat + Langkah */}
            {(detail.manfaat || detail.langkah) && resourcePath === "edukasi-imd" && (
              <div className="space-y-6 mb-10">
                {detail.manfaat && (
                  <div className="bg-emerald-50 border border-emerald-100 rounded-3xl p-6">
                    <h3 className="text-base sm:text-lg font-bold text-slate-800 mb-3 flex items-center gap-2">
                      <Heart size={20} className="text-emerald-600" />
                      Manfaat IMD
                    </h3>
                    <p className="text-sm sm:text-base text-slate-600 leading-relaxed whitespace-pre-line">{detail.manfaat}</p>
                  </div>
                )}
                {detail.langkah && (
                  <div className="bg-indigo-50/60 border border-indigo-100 rounded-3xl p-6">
                    <h3 className="text-base sm:text-lg font-bold text-slate-800 mb-3 flex items-center gap-2">
                      <ListChecks size={20} className="text-indigo-600" />
                      Langkah-langkah IMD
                    </h3>
                    <p className="text-sm sm:text-base text-slate-600 leading-relaxed whitespace-pre-line">{detail.langkah}</p>
                  </div>
                )}
              </div>
            )}

            {/* Menyusui ASI: Manfaat ASI + Cara + Masalah + Solusi */}
            {resourcePath === "edukasi-menyusui-asi" && (detail.manfaat_asi || detail.cara || detail.masalah || detail.solusi) && (
              <div className="space-y-6 mb-10">
                {detail.manfaat_asi && (
                  <div className="bg-emerald-50 border border-emerald-100 rounded-3xl p-6">
                    <h3 className="text-base sm:text-lg font-bold text-slate-800 mb-3 flex items-center gap-2">
                      <Heart size={20} className="text-emerald-600" />
                      Manfaat ASI
                    </h3>
                    <p className="text-sm sm:text-base text-slate-600 leading-relaxed whitespace-pre-line">{detail.manfaat_asi}</p>
                  </div>
                )}
                {detail.cara && (
                  <div className="bg-indigo-50/60 border border-indigo-100 rounded-3xl p-6">
                    <h3 className="text-base sm:text-lg font-bold text-slate-800 mb-3 flex items-center gap-2">
                      <Baby size={20} className="text-indigo-600" />
                      Cara Menyusui yang Benar
                    </h3>
                    <p className="text-sm sm:text-base text-slate-600 leading-relaxed whitespace-pre-line">{detail.cara}</p>
                  </div>
                )}
                {(detail.masalah || detail.solusi) && (
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    {detail.masalah && (
                      <div className="bg-rose-50 border border-rose-100 rounded-2xl p-5">
                        <h4 className="font-bold text-rose-800 text-sm mb-2 flex items-center gap-1.5">
                          <AlertCircle size={16} className="text-rose-500" />
                          Masalah yang Sering Terjadi
                        </h4>
                        <p className="text-sm text-rose-700 leading-relaxed whitespace-pre-line">{detail.masalah}</p>
                      </div>
                    )}
                    {detail.solusi && (
                      <div className="bg-teal-50 border border-teal-100 rounded-2xl p-5">
                        <h4 className="font-bold text-teal-800 text-sm mb-2 flex items-center gap-1.5">
                          <Lightbulb size={16} className="text-teal-500" />
                          Solusi & Penanganan
                        </h4>
                        <p className="text-sm text-teal-700 leading-relaxed whitespace-pre-line">{detail.solusi}</p>
                      </div>
                    )}
                  </div>
                )}
              </div>
            )}

            {/* Kesehatan Mental: Tanda Gejala + Solusi */}
            {resourcePath === "edukasi-kesehatan-mental" && (detail.tanda_gejala || detail.solusi) && (
              <div className="space-y-6 mb-10">
                {detail.tanda_gejala && (
                  <div className="bg-rose-50 border border-rose-100 rounded-3xl p-6">
                    <h3 className="text-base sm:text-lg font-bold text-slate-800 mb-3 flex items-center gap-2">
                      <Brain size={20} className="text-rose-600" />
                      Tanda & Gejala
                    </h3>
                    <p className="text-sm sm:text-base text-slate-600 leading-relaxed whitespace-pre-line">{detail.tanda_gejala}</p>
                  </div>
                )}
                {detail.solusi && (
                  <div className="bg-teal-50 border border-teal-100 rounded-3xl p-6">
                    <h3 className="text-base sm:text-lg font-bold text-slate-800 mb-3 flex items-center gap-2">
                      <Lightbulb size={20} className="text-teal-600" />
                      Solusi & Penanganan
                    </h3>
                    <p className="text-sm sm:text-base text-slate-600 leading-relaxed whitespace-pre-line">{detail.solusi}</p>
                  </div>
                )}
              </div>
            )}

            {/* Informasi Umum: Yang Perlu Diingat */}
            {resourcePath === "edukasi-informasi-umum" && detail.yang_perlu_diingat && (
              <div className="bg-amber-50 border border-amber-100 rounded-3xl p-6 mb-10 flex items-start gap-4">
                <Lightbulb className="text-amber-500 flex-shrink-0 mt-0.5" size={22} />
                <div>
                  <h4 className="font-bold text-amber-900 text-sm sm:text-base mb-2">Yang Perlu Diingat</h4>
                  <p className="text-xs sm:text-sm text-amber-700 leading-relaxed whitespace-pre-line">{detail.yang_perlu_diingat}</p>
                </div>
              </div>
            )}

            {/* MPASI Aturan Porsi: Tekstur + Frekuensi + Porsi */}
            {(detail.porsi || detail.frekuensi || detail.tekstur) && (
              <div className="bg-indigo-50/50 border border-indigo-100 rounded-3xl p-6 mb-8">
                <h3 className="text-base sm:text-lg font-bold text-slate-800 mb-4 flex items-center gap-2">
                  <Leaf size={20} className="text-indigo-600" />
                  Rincian Pemberian Makanan (MPASI)
                </h3>
                <div className="grid grid-cols-1 sm:grid-cols-3 gap-6">
                  {detail.tekstur && (
                    <div className="bg-white rounded-2xl p-4 border border-indigo-50">
                      <span className="text-xs text-slate-400 font-semibold uppercase tracking-wide">Tekstur</span>
                      <p className="text-sm font-bold text-slate-700 mt-1.5">{detail.tekstur}</p>
                    </div>
                  )}
                  {detail.frekuensi && (
                    <div className="bg-white rounded-2xl p-4 border border-indigo-50">
                      <span className="text-xs text-slate-400 font-semibold uppercase tracking-wide">Frekuensi Harian</span>
                      <p className="text-sm font-bold text-slate-700 mt-1.5">{detail.frekuensi}</p>
                    </div>
                  )}
                  {detail.porsi && (
                    <div className="bg-white rounded-2xl p-4 border border-indigo-50">
                      <span className="text-xs text-slate-400 font-semibold uppercase tracking-wide">Takaran Porsi</span>
                      <p className="text-sm font-bold text-slate-700 mt-1.5">{detail.porsi}</p>
                    </div>
                  )}
                </div>
              </div>
            )}

            {/* MPASI Jadwal Harian: Waktu + Aktivitas */}
            {detail.waktu && detail.aktivitas && (
              <div className="bg-sky-50 border border-sky-100 rounded-3xl p-6 mb-8">
                <h3 className="text-base sm:text-lg font-bold text-slate-800 mb-4 flex items-center gap-2">
                  <Clock size={20} className="text-sky-600" />
                  Jadwal Harian MPASI
                </h3>
                <div className="flex items-center gap-4 bg-white rounded-2xl p-4 border border-sky-50">
                  <div className="w-16 h-16 rounded-xl bg-sky-100 text-sky-700 flex items-center justify-center font-extrabold text-sm flex-shrink-0">
                    {detail.waktu}
                  </div>
                  <p className="text-sm sm:text-base text-slate-700 font-medium">{detail.aktivitas}</p>
                </div>
              </div>
            )}

            {/* MPASI Resep: Bahan + Cara Membuat + Manfaat + Tips */}
            {resourcePath === "edukasi-mpasi-resep" && (
              <div className="space-y-6 mb-10">
                {/* Info Resep */}
                {(detail.kalori || detail.waktu_persiapan || detail.tipe) && (
                  <div className="grid grid-cols-2 sm:grid-cols-3 gap-4">
                    {detail.tipe && (
                      <div className="bg-slate-50 rounded-2xl p-4 border border-slate-100 text-center">
                        <span className="text-xs text-slate-400 font-semibold uppercase tracking-wide block mb-1">Tipe</span>
                        <p className="text-sm font-bold text-slate-700 capitalize">{detail.tipe}</p>
                      </div>
                    )}
                    {detail.waktu_persiapan && (
                      <div className="bg-slate-50 rounded-2xl p-4 border border-slate-100 text-center">
                        <span className="text-xs text-slate-400 font-semibold uppercase tracking-wide block mb-1">Waktu Persiapan</span>
                        <p className="text-sm font-bold text-slate-700">{detail.waktu_persiapan} menit</p>
                      </div>
                    )}
                    {detail.kalori && (
                      <div className="bg-slate-50 rounded-2xl p-4 border border-slate-100 text-center">
                        <span className="text-xs text-slate-400 font-semibold uppercase tracking-wide block mb-1">Kalori</span>
                        <p className="text-sm font-bold text-slate-700">{detail.kalori} kal</p>
                      </div>
                    )}
                  </div>
                )}

                {/* Bahan-bahan */}
                {Array.isArray(detail.bahan_bahan) && detail.bahan_bahan.length > 0 && (
                  <div className="bg-orange-50 border border-orange-100 rounded-3xl p-6">
                    <h3 className="text-base sm:text-lg font-bold text-slate-800 mb-4 flex items-center gap-2">
                      <Leaf size={20} className="text-orange-500" />
                      Bahan-bahan
                    </h3>
                    <ul className="space-y-2">
                      {detail.bahan_bahan.map((b, i) => (
                        <li key={i} className="flex items-start gap-2 text-sm text-slate-700">
                          <span className="w-1.5 h-1.5 rounded-full bg-orange-400 mt-1.5 flex-shrink-0" />
                          {b}
                        </li>
                      ))}
                    </ul>
                  </div>
                )}

                {/* Cara Membuat */}
                {Array.isArray(detail.cara_membuat) && detail.cara_membuat.length > 0 && (
                  <div className="bg-indigo-50/60 border border-indigo-100 rounded-3xl p-6">
                    <h3 className="text-base sm:text-lg font-bold text-slate-800 mb-4 flex items-center gap-2">
                      <ListChecks size={20} className="text-indigo-600" />
                      Cara Membuat
                    </h3>
                    <ol className="space-y-3">
                      {detail.cara_membuat.map((step, i) => (
                        <li key={i} className="flex items-start gap-3 text-sm text-slate-700">
                          <span className="w-6 h-6 rounded-full bg-indigo-100 text-indigo-700 font-bold flex items-center justify-center flex-shrink-0 text-xs">{i + 1}</span>
                          {step}
                        </li>
                      ))}
                    </ol>
                  </div>
                )}

                {/* Manfaat + Tips */}
                {(detail.manfaat || detail.tips) && (
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    {detail.manfaat && (
                      <div className="bg-emerald-50 border border-emerald-100 rounded-2xl p-5">
                        <h4 className="font-bold text-emerald-800 text-sm mb-2 flex items-center gap-1.5">
                          <Heart size={15} className="text-emerald-500" />
                          Manfaat
                        </h4>
                        <p className="text-sm text-emerald-700 leading-relaxed whitespace-pre-line">{detail.manfaat}</p>
                      </div>
                    )}
                    {detail.tips && (
                      <div className="bg-amber-50 border border-amber-100 rounded-2xl p-5">
                        <h4 className="font-bold text-amber-800 text-sm mb-2 flex items-center gap-1.5">
                          <Lightbulb size={15} className="text-amber-500" />
                          Tips
                        </h4>
                        <p className="text-sm text-amber-700 leading-relaxed whitespace-pre-line">{detail.tips}</p>
                      </div>
                    )}
                  </div>
                )}
              </div>
            )}

            {/* Materi Inti (Keypoints List) — field dari schema lain */}
            {materiIntiList.length > 0 && (
              <div className="mb-10 text-left">
                <h3 className="text-xl font-extrabold text-slate-800 mb-5 flex items-center gap-2">
                  <CheckSquare className="text-indigo-600" size={22} />
                  Materi Inti & Panduan Langkah
                </h3>
                <div className="grid grid-cols-1 gap-4">
                  {materiIntiList.map((materi, idx) => (
                    <div key={idx} className="bg-white border border-slate-100 p-5 rounded-2xl shadow-sm flex items-start gap-4">
                      <div className="w-8 h-8 rounded-full bg-indigo-50 text-indigo-600 font-bold flex items-center justify-center flex-shrink-0 text-sm mt-0.5">
                        {idx + 1}
                      </div>
                      <div>
                        <h4 className="font-bold text-slate-800 text-sm sm:text-base">{materi.judul}</h4>
                        <p className="text-xs sm:text-sm text-slate-500 mt-1 leading-relaxed">{materi.isi}</p>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Hal Penting Section (Alert Banner) */}
            {detail.hal_penting && (
              <div className="bg-indigo-50 border border-indigo-100 rounded-3xl p-6 mb-10 flex items-start gap-4 shadow-sm">
                <AlertCircle className="text-indigo-600 flex-shrink-0 mt-0.5 animate-pulse" size={24} />
                <div>
                  <h4 className="font-bold text-indigo-900 text-sm sm:text-base">Hal Penting yang Harus Diperhatikan:</h4>
                  <p className="text-xs sm:text-sm text-indigo-700 mt-2 leading-relaxed whitespace-pre-line">
                    {detail.hal_penting}
                  </p>
                </div>
              </div>
            )}

            {/* Back Button Link */}
            <button
              onClick={() => navigate(`/edukasi-publik/${category}`)}
              className="inline-flex items-center gap-2 px-6 py-3 border border-slate-200 hover:bg-slate-50 text-slate-700 font-bold rounded-2xl text-sm transition-all"
            >
              <ArrowLeft size={16} />
              Kembali ke Daftar Artikel
            </button>
          </div>

          {/* Sidebar Section (4 Columns) */}
          <div className="lg:col-span-4 flex flex-col gap-8 text-left">
            {/* Disclaimer & Expert Certification Card */}
            <div className="bg-white rounded-3xl border border-slate-100 p-6 shadow-sm">
              <div className="flex items-center gap-2.5 border-b border-slate-50 pb-4 mb-4">
                <div className="w-10 h-10 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center flex-shrink-0">
                  <ShieldCheck size={22} />
                </div>
                <div>
                  <h4 className="font-bold text-slate-800 text-sm sm:text-base leading-tight">Terverifikasi Medis</h4>
                  <p className="text-xs text-slate-400 mt-0.5">Sesuai Panduan Kemenkes RI</p>
                </div>
              </div>
              <p className="text-xs text-slate-500 leading-relaxed">
                Seluruh materi edukasi di Generasi Sehat bersumber dari modul resmi dan telah ditinjau oleh dokter anak & bidan puskesmas pembina untuk menjamin keakuratan informasi medis yang disampaikan.
              </p>
            </div>

            {/* Mobile App CTA Widget */}
            <div className="bg-gradient-to-tr from-indigo-900 to-indigo-850 text-white rounded-3xl p-6 shadow-md relative overflow-hidden">
              {/* Background light glow */}
              <div className="absolute top-0 right-0 w-24 h-24 bg-indigo-500/25 rounded-full filter blur-xl" />
              
              <Smartphone size={32} className="text-indigo-400 mb-4" />
              <h4 className="font-extrabold text-white text-base sm:text-lg mb-2">Aplikasi Generasi Sehat</h4>
              <p className="text-xs text-indigo-200 leading-relaxed mb-6">
                Ingin memantau grafik imunisasi & tumbuh kembang anak Anda secara langsung? Unduh aplikasi Android kami secara gratis.
              </p>

              <button
                onClick={handleDownload}
                className="w-full py-2.5 bg-white hover:bg-slate-50 text-indigo-950 font-bold text-xs sm:text-sm rounded-xl transition-all flex items-center justify-center gap-1.5 shadow-md"
              >
                <Download size={14} />
                Unduh Berkas APK
              </button>
            </div>

            {/* Related Articles list */}
            {related.length > 0 && (
              <div className="bg-white rounded-3xl border border-slate-100 p-6 shadow-sm">
                <h4 className="font-bold text-slate-800 text-base mb-4 border-b border-slate-50 pb-3">
                  Artikel Terkait
                </h4>
                <div className="flex flex-col gap-4">
                  {related.map((item, idx) => {
                    const itemId = item?.id ?? item?.ID ?? item?.id_edukasi ?? item?.id_informasi;
                    const itemTitle = getItemTitle(item);
                    return (
                      <Link
                        key={itemId || idx}
                        to={`/edukasi-publik/${category}/${itemId}`}
                        className="flex gap-3 hover:text-indigo-600 transition-colors group text-left"
                      >
                        {/* Fallback mini circle */}
                        <div className="w-10 h-10 rounded-lg bg-slate-50 border border-slate-100 flex-shrink-0 flex items-center justify-center text-slate-400 group-hover:bg-indigo-50 group-hover:text-indigo-600 transition-colors">
                          <BookOpen size={16} />
                        </div>
                        <div>
                          <h5 className="font-semibold text-xs sm:text-sm text-slate-700 group-hover:text-indigo-600 transition-colors line-clamp-2 leading-snug">
                            {itemTitle}
                          </h5>
                          <span className="text-[10px] text-slate-400 mt-1 block">
                              {item.rentang_usia || item.tipe || item.umur_target || "Umum"}
                            </span>
                        </div>
                      </Link>
                    );
                  })}
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </PublicLayout>
  );
}
