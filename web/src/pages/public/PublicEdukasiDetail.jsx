import React, { useEffect, useState } from "react";
import { useParams, Link, useNavigate } from "react-router-dom";
import {
  ArrowLeft, Clock, Calendar, AlertCircle, ShieldCheck,
  ChevronRight, ImageIcon, Smartphone, Download, BookOpen,
  CheckCircle, Heart, Lightbulb, ListOrdered, Utensils,
  Timer, Users, Brain, AlertTriangle, Star, Tag
} from "lucide-react";
import PublicLayout, { PUBLIC_EDUKASI_MENU } from "./PublicLayout";
import { getPublicEdukasiById, listPublicEdukasi } from "../../services/edukasiDigital";

/* ─── Helpers (same as list) ─── */
const mapCategoryToResource = (category) => {
  for (const item of PUBLIC_EDUKASI_MENU) {
    if (item.submodules) {
      const found = item.submodules.find((sub) => sub.path === category);
      if (found) return found;
    }
    if (item.path === category) return item;
  }
  return null;
};

const getCategoryLabel = (category) => {
  const info = mapCategoryToResource(category);
  return info ? info.label : "Edukasi Kesehatan";
};

const getItemTitle = (item, resourcePath) => {
  if (!item) return "";
  if (item.judul) return item.judul;
  if (item.Judul) return item.Judul;
  if (item.bulan_min !== undefined && item.bulan_max !== undefined) {
    if (resourcePath === "edukasi-mpasi-jadwal-harian")
      return `Jadwal Harian MPASI Usia ${item.bulan_min}–${item.bulan_max} Bulan`;
    if (resourcePath === "edukasi-mpasi-aturan-porsi")
      return `Aturan Porsi MPASI Usia ${item.bulan_min}–${item.bulan_max} Bulan`;
    return `Panduan MPASI Usia ${item.bulan_min}–${item.bulan_max} Bulan`;
  }
  if (item.waktu && item.aktivitas) return `Pukul ${item.waktu} – ${item.aktivitas}`;
  return "Tanpa Judul";
};

const getItemImage = (item) => {
  if (!item) return "";
  return item.gambar_url ?? item.GambarURL ?? item.thumbnail_url ??
    item.ThumbnailURL ?? item.image_url ?? item.image ?? "";
};

const guessId = (item) =>
  item?.id ?? item?.ID ?? item?.id_edukasi ?? item?.id_informasi ?? null;

const CATEGORY_CONFIG = {
  "informasi-umum":   { color: "primary", bg: "from-primary to-primary-400", emoji: "📋" },
  "trimester":        { color: "primary", bg: "from-primary to-primary-400", emoji: "🤰" },
  "tanda-melahirkan": { color: "primary", bg: "from-primary to-primary-400", emoji: "⚡" },
  "imd":              { color: "primary", bg: "from-primary to-primary-400", emoji: "🍼" },
  "setelah-melahirkan":{ color: "primary", bg: "from-primary to-primary-400", emoji: "💝" },
  "menyusui-asi":     { color: "primary", bg: "from-primary to-primary-400", emoji: "🌱" },
  "pola-asuh":        { color: "primary", bg: "from-primary to-primary-400", emoji: "👨‍👩‍👧" },
  "kesehatan-mental": { color: "primary", bg: "from-primary to-primary-400", emoji: "🧠" },
  "perawatan-anak":   { color: "primary", bg: "from-primary to-primary-400", emoji: "👶" },
  "mpasi":            { color: "primary", bg: "from-primary to-primary-400", emoji: "🥣" },
  "mpasi-aturan-porsi":{ color: "primary", bg: "from-primary to-primary-400", emoji: "📏" },
  "mpasi-jadwal-harian":{ color: "primary", bg: "from-primary to-primary-400", emoji: "🕐" },
  "mpasi-resep":      { color: "primary", bg: "from-primary to-primary-400", emoji: "👩‍🍳" },
};

const getCatConfig = (cat) =>
  CATEGORY_CONFIG[cat] || { color: "primary", bg: "from-primary to-primary-400", emoji: "📚" };

/* ─── Section Block Components ─── */
function SectionBlock({ icon: Icon, title, content, color = "primary" }) {
  if (!content) return null;
  const colorMap = {
    primary: "bg-primary-50 border-primary-100 text-primary-600",
    indigo: "bg-indigo-50 border-indigo-200 text-indigo-800",
    rose:   "bg-rose-50 border-rose-200 text-rose-800",
    amber:  "bg-amber-50 border-amber-200 text-amber-800",
    emerald:"bg-emerald-50 border-emerald-200 text-emerald-800",
    green:  "bg-green-50 border-green-200 text-green-800",
    orange: "bg-orange-50 border-orange-200 text-orange-800",
    blue:   "bg-blue-50 border-blue-200 text-blue-800",
    cyan:   "bg-cyan-50 border-cyan-200 text-cyan-800",
  };
  const iconColor = {
    primary: "text-primary",
    indigo: "text-indigo-600", rose: "text-rose-500", amber: "text-amber-500",
    emerald: "text-emerald-600", green: "text-green-600", orange: "text-orange-500",
    blue: "text-blue-600", cyan: "text-cyan-600",
  };
  return (
    <div className={`rounded-2xl border p-5 mb-5 ${colorMap[color] || colorMap.primary}`}>
      <h3 className="flex items-center gap-2 font-bold text-base mb-3">
        <Icon size={18} className={iconColor[color] || iconColor.primary} />
        {title}
      </h3>
      <p className="text-sm leading-relaxed whitespace-pre-line opacity-90">{content}</p>
    </div>
  );
}

function ListSectionBlock({ icon: Icon, title, items, color = "primary", numbered = false }) {
  if (!items || items.length === 0) return null;
  const parsedItems = typeof items === "string"
    ? items.split("\n").filter(Boolean)
    : Array.isArray(items) ? items : [items];
  if (!parsedItems.length) return null;

  const borderColor = {
    primary: "border-primary",
    indigo: "border-indigo-500", orange: "border-orange-500",
    emerald: "border-emerald-500", green: "border-green-500",
    rose: "border-rose-500", amber: "border-amber-500",
  };
  const iconColor = {
    primary: "text-primary",
    indigo: "text-indigo-600", orange: "text-orange-500",
    emerald: "text-emerald-600", green: "text-green-600",
    rose: "text-rose-500", amber: "text-amber-500",
  };
  const numBg = {
    primary: "bg-primary-50 text-primary-600",
    indigo: "bg-indigo-100 text-indigo-700", orange: "bg-orange-100 text-orange-700",
    emerald: "bg-emerald-100 text-emerald-700", green: "bg-green-100 text-green-700",
  };

  return (
    <div className={`bg-white rounded-2xl border-l-4 ${borderColor[color] || borderColor.primary} border border-slate-100 p-5 mb-5 shadow-sm`}>
      <h3 className="flex items-center gap-2 font-bold text-slate-800 text-base mb-4">
        <Icon size={18} className={iconColor[color] || iconColor.primary} />
        {title}
      </h3>
      <ol className="flex flex-col gap-2.5">
        {parsedItems.map((step, i) => (
          <li key={i} className="flex items-start gap-3 text-sm text-slate-700 leading-relaxed">
            {numbered ? (
              <span className={`mt-0.5 min-w-[24px] h-6 w-6 rounded-full ${numBg[color] || numBg.primary} text-xs font-bold flex items-center justify-center flex-shrink-0`}>
                {i + 1}
              </span>
            ) : (
              <CheckCircle size={16} className={`mt-0.5 flex-shrink-0 ${iconColor[color] || iconColor.primary}`} />
            )}
            <span>{step}</span>
          </li>
        ))}
      </ol>
    </div>
  );
}

/* ─── Category-specific Detail Renderer ─── */
function CategoryDetailRenderer({ detail, resourcePath, catConfig }) {
  const color = catConfig.color;

  // ── INFORMASI UMUM ──
  if (resourcePath === "edukasi-informasi-umum") {
    return (
      <>
        {detail.ringkasan && (
          <p className="text-lg text-slate-700 leading-relaxed font-medium bg-slate-50 border-l-4 border-primary rounded-r-xl pl-4 pr-4 py-3 mb-6">
            {detail.ringkasan}
          </p>
        )}
        {detail.konten && (
          <div className="prose prose-slate max-w-none mb-6">
            <div className="text-slate-600 leading-relaxed whitespace-pre-line text-sm sm:text-base">
              {detail.konten}
            </div>
          </div>
        )}
        <SectionBlock icon={AlertCircle} title="Yang Perlu Diingat" content={detail.yang_perlu_diingat} color="primary" />
      </>
    );
  }

  // ── IMD ──
  if (resourcePath === "edukasi-imd") {
    return (
      <>
        <SectionBlock icon={BookOpen} title="Tentang IMD" content={detail.isi} color="emerald" />
        <SectionBlock icon={Heart} title="Manfaat IMD" content={detail.manfaat} color="green" />
        <ListSectionBlock icon={ListOrdered} title="Langkah-langkah IMD" items={detail.langkah} color="emerald" numbered />
      </>
    );
  }

  // ── TANDA MELAHIRKAN ──
  if (resourcePath === "edukasi-tanda-melahirkan") {
    return (
      <>
        <SectionBlock icon={BookOpen} title="Informasi Umum" content={detail.isi} color="amber" />
        <ListSectionBlock icon={AlertTriangle} title="Tanda-tanda Persalinan" items={detail.tanda} color="amber" />
        <ListSectionBlock icon={CheckCircle} title="Tindakan yang Perlu Dilakukan" items={detail.tindakan} color="orange" numbered />
      </>
    );
  }

  // ── MENYUSUI ASI ──
  if (resourcePath === "edukasi-menyusui-asi") {
    return (
      <>
        <SectionBlock icon={BookOpen} title="Tentang Menyusui" content={detail.isi} color="green" />
        <SectionBlock icon={Heart} title="Manfaat ASI" content={detail.manfaat_asi} color="emerald" />
        <ListSectionBlock icon={ListOrdered} title="Cara Menyusui yang Benar" items={detail.cara} color="green" numbered />
        <SectionBlock icon={AlertTriangle} title="Masalah yang Sering Terjadi" content={detail.masalah} color="amber" />
        <SectionBlock icon={Lightbulb} title="Solusi / Penanganan" content={detail.solusi} color="cyan" />
      </>
    );
  }

  // ── KESEHATAN MENTAL ──
  if (resourcePath === "edukasi-kesehatan-mental") {
    return (
      <>
        <SectionBlock icon={Brain} title="Informasi Kesehatan Mental" content={detail.isi} color="blue" />
        <ListSectionBlock icon={AlertCircle} title="Tanda dan Gejala" items={detail.tanda_gejala} color="rose" />
        <SectionBlock icon={Lightbulb} title="Solusi & Penanganan" content={detail.solusi} color="blue" />
      </>
    );
  }

  // ── NIFAS ──
  if (resourcePath === "edukasi-nifas") {
    return (
      <>
        <SectionBlock icon={BookOpen} title="Tentang Masa Nifas" content={detail.isi} color="pink" />
        <ListSectionBlock icon={CheckCircle} title="Perawatan Masa Nifas" items={detail.perawatan} color="rose" numbered />
        <ListSectionBlock icon={AlertTriangle} title="Tanda Bahaya Nifas" items={detail.tanda_bahaya} color="amber" />
      </>
    );
  }

  // ── MPASI ATURAN PORSI ──
  if (resourcePath === "edukasi-mpasi-aturan-porsi") {
    return (
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6">
        {detail.tekstur && (
          <div className="bg-primary-50 border border-primary-100 rounded-2xl p-5 text-center">
            <div className="text-3xl mb-2">🥄</div>
            <span className="text-xs font-bold text-primary-500 uppercase tracking-wide">Tekstur</span>
            <p className="text-sm font-semibold text-slate-800 mt-2 leading-relaxed">{detail.tekstur}</p>
          </div>
        )}
        {detail.frekuensi && (
          <div className="bg-primary-50/50 border border-primary-100/70 rounded-2xl p-5 text-center">
            <div className="text-3xl mb-2">🕐</div>
            <span className="text-xs font-bold text-primary-500 uppercase tracking-wide">Frekuensi</span>
            <p className="text-sm font-semibold text-slate-800 mt-2 leading-relaxed">{detail.frekuensi}</p>
          </div>
        )}
        {detail.porsi && (
          <div className="bg-slate-50 border border-slate-200 rounded-2xl p-5 text-center">
            <div className="text-3xl mb-2">🥣</div>
            <span className="text-xs font-bold text-slate-600 uppercase tracking-wide">Porsi</span>
            <p className="text-sm font-semibold text-slate-800 mt-2 leading-relaxed">{detail.porsi}</p>
          </div>
        )}
      </div>
    );
  }

  // ── MPASI JADWAL HARIAN ──
  if (resourcePath === "edukasi-mpasi-jadwal-harian") {
    return (
      <div className="bg-primary-50 border border-primary-200 rounded-2xl p-6 mb-6 flex items-center gap-5">
        <div className="w-20 h-20 rounded-2xl bg-gradient-to-br from-primary to-primary-400 flex flex-col items-center justify-center text-white flex-shrink-0 shadow-lg shadow-primary-100">
          <span className="text-lg font-extrabold">{detail.waktu || "—"}</span>
        </div>
        <div>
          <p className="text-xs font-bold text-primary-500 uppercase mb-1">Aktivitas</p>
          <p className="text-lg font-bold text-slate-800">{detail.aktivitas || "—"}</p>
          <p className="text-sm text-slate-500 mt-1">Usia {detail.bulan_min}–{detail.bulan_max} Bulan</p>
        </div>
      </div>
    );
  }

  // ── MPASI RESEP ──
  if (resourcePath === "edukasi-mpasi-resep") {
    // Parse bahan_bahan & cara_membuat (array or newline string)
    const parseList = (val) => {
      if (!val) return [];
      if (Array.isArray(val)) return val.filter(Boolean);
      if (typeof val === "string") return val.split("\n").filter(Boolean);
      return [];
    };
    const bahanList = parseList(detail.bahan_bahan);
    const caraMembuatList = parseList(detail.cara_membuat);

    return (
      <>
        {/* Meta info row */}
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 mb-6">
          {detail.bulan_min !== undefined && (
            <div className="bg-primary-50 border border-primary-200 rounded-xl p-3 text-center">
              <span className="text-[10px] font-bold text-primary-500 uppercase tracking-wide block mb-1">Usia</span>
              <p className="text-sm font-bold text-slate-800">{detail.bulan_min}–{detail.bulan_max} Bln</p>
            </div>
          )}
          {detail.waktu_persiapan && (
            <div className="bg-primary-50/50 border border-primary-100 rounded-xl p-3 text-center">
              <span className="text-[10px] font-bold text-primary-500 uppercase tracking-wide block mb-1">Waktu</span>
              <p className="text-sm font-bold text-slate-800">{detail.waktu_persiapan} mnt</p>
            </div>
          )}
          {detail.kalori && (
            <div className="bg-slate-50 border border-slate-200 rounded-xl p-3 text-center">
              <span className="text-[10px] font-bold text-slate-600 uppercase tracking-wide block mb-1">Kalori</span>
              <p className="text-sm font-bold text-slate-800">{detail.kalori} kkal</p>
            </div>
          )}
          {detail.porsi && (
            <div className="bg-primary-50 border border-primary-200 rounded-xl p-3 text-center">
              <span className="text-[10px] font-bold text-primary-500 uppercase tracking-wide block mb-1">Porsi</span>
              <p className="text-sm font-bold text-slate-800">{detail.porsi}</p>
            </div>
          )}
        </div>

        {/* Bahan-bahan */}
        {bahanList.length > 0 && (
          <div className="bg-primary-50 border-l-4 border-primary-500 border border-primary-100 rounded-r-2xl rounded-l-md p-5 mb-5">
            <h3 className="flex items-center gap-2 font-bold text-slate-800 text-base mb-3">
              <Star size={17} className="text-primary-500" /> Bahan-bahan
            </h3>
            <ul className="flex flex-col gap-2">
              {bahanList.map((b, i) => (
                <li key={i} className="flex items-center gap-2 text-sm text-slate-700">
                  <span className="w-2 h-2 rounded-full bg-primary-400 flex-shrink-0" />
                  {b}
                </li>
              ))}
            </ul>
          </div>
        )}

        {/* Cara membuat */}
        {caraMembuatList.length > 0 && (
          <ListSectionBlock
            icon={ListOrdered}
            title="Cara Membuat"
            items={caraMembuatList}
            color="primary"
            numbered
          />
        )}

        {/* Manfaat & Tips */}
        <SectionBlock icon={Heart} title="Manfaat" content={detail.manfaat} color="primary" />
        <SectionBlock icon={Lightbulb} title="Tips Memasak" content={detail.tips} color="primary" />
      </>
    );
  }

  // ── GENERIC (trimester, setelah melahirkan, pola asuh, perawatan anak, mpasi) ──
  const mainContent =
    detail.isi_konten ?? detail.isi ?? detail.konten ?? detail.deskripsi ?? "";
  const desc =
    detail.ringkasan ?? detail.deskripsi ?? "";

  return (
    <>
      {desc && desc !== mainContent && (
        <p className="text-lg text-slate-700 leading-relaxed font-medium bg-slate-50 border-l-4 border-primary rounded-r-xl pl-4 pr-4 py-3 mb-6">
          {desc}
        </p>
      )}
      {mainContent && (
        <div className="text-sm sm:text-base text-slate-600 leading-relaxed whitespace-pre-line space-y-4 mb-6">
          {mainContent}
        </div>
      )}
    </>
  );
}

/* ─── Main Component ─── */
export default function PublicEdukasiDetail() {
  const { category, id } = useParams();
  const navigate = useNavigate();

  const [detail, setDetail] = useState(null);
  const [related, setRelated] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  const categoryInfo = mapCategoryToResource(category);
  const resourcePath = categoryInfo?.resource;
  const catConfig = getCatConfig(category);
  const categoryLabel = getCategoryLabel(category);

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
        const item = await getPublicEdukasiById(resourcePath, id);
        setDetail(item);
        try {
          const allItems = await listPublicEdukasi(resourcePath);
          if (Array.isArray(allItems)) {
            setRelated(
              allItems
                .filter((row) => String(guessId(row)) !== String(id))
                .slice(0, 4)
            );
          }
        } catch (relatedErr) {
          console.error("Gagal memuat artikel terkait:", relatedErr);
        }
      } catch (err) {
        setError("Gagal memuat isi artikel edukasi.");
      } finally {
        setLoading(false);
      }
    };
    loadContent();
    window.scrollTo(0, 0);
  }, [category, id]);

  const handleDownload = () => {
    window.open(
      "https://github.com/kia-cerdas/kia-cerdas/releases/download/v1.0.0/generasi-sehat-app.apk",
      "_blank"
    );
  };

  if (loading) {
    return (
      <PublicLayout>
        <div className="flex flex-col items-center justify-center py-32 gap-4">
          <div className="w-12 h-12 border-4 border-slate-200 border-t-primary rounded-full animate-spin" />
          <p className="text-slate-500 text-sm font-medium">Memuat artikel edukasi…</p>
        </div>
      </PublicLayout>
    );
  }

  if (error || !detail) {
    return (
      <PublicLayout>
        <div className="max-w-xl mx-auto px-4 py-24 text-center">
          <div className="text-6xl mb-6">😕</div>
          <h2 className="text-xl font-bold text-slate-700 mb-2">Artikel Tidak Ditemukan</h2>
          <p className="text-sm text-slate-400 mb-6">{error || "Terjadi kesalahan saat memproses data."}</p>
          <button
            onClick={() => navigate(`/edukasi-publik/${category}`)}
            className="px-6 py-2.5 bg-primary hover:bg-primary-600 text-white font-semibold rounded-xl text-sm transition-all"
          >
            Kembali ke Daftar
          </button>
        </div>
      </PublicLayout>
    );
  }

  const title = getItemTitle(detail, resourcePath);
  const imgUrl = getItemImage(detail);
  const formattedDate = detail.created_at
    ? new Date(detail.created_at).toLocaleDateString("id-ID", {
        day: "numeric", month: "long", year: "numeric",
      })
    : "—";

  const badge =
    (detail.trimester ? `Trimester ${detail.trimester}` : null) ??
    (detail.bulan_min !== undefined && detail.bulan_max !== undefined ? `Usia ${detail.bulan_min}–${detail.bulan_max} Bulan` : null) ??
    detail.rentang_usia ?? detail.umur_target ?? detail.tipe ?? detail.kategori ?? null;

  return (
    <PublicLayout>
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 font-['Outfit',_sans-serif]">
        {/* Breadcrumbs */}
        <nav className="flex items-center gap-1.5 text-xs sm:text-sm text-slate-500 mb-6">
          <Link to="/" className="hover:text-primary transition-colors">Beranda</Link>
          <ChevronRight size={14} className="text-slate-400" />
          <Link to={`/edukasi-publik/${category}`} className="hover:text-primary transition-colors">
            {categoryLabel}
          </Link>
          <ChevronRight size={14} className="text-slate-400" />
          <span className="text-slate-700 font-semibold truncate max-w-[150px] sm:max-w-xs">{title}</span>
        </nav>

        {/* Main Grid */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-10">
          {/* ── Left Column: Main Article ── */}
          <div className="lg:col-span-8 text-left">
            {/* Category Badge & Title */}
            {badge && (
              <span className={`inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold mb-4 bg-gradient-to-r ${catConfig.bg} text-white shadow-md`}>
                <Tag size={12} /> {badge}
              </span>
            )}

            <h1 className="text-2xl sm:text-4xl font-extrabold text-slate-900 tracking-tight mb-5 leading-tight">
              {title}
            </h1>

            {/* Meta Row */}
            <div className="flex flex-wrap items-center gap-3 text-xs sm:text-sm text-slate-400 border-b border-slate-100 pb-5 mb-6">
              <span className="flex items-center gap-1.5">
                <Calendar size={14} /> {formattedDate}
              </span>
              {detail.durasi_baca && (
                <>
                  <span className="hidden sm:block w-1 h-1 rounded-full bg-slate-300" />
                  <span className="flex items-center gap-1.5">
                    <Clock size={14} /> {detail.durasi_baca}
                  </span>
                </>
              )}
            </div>

            {/* Featured Image */}
            {imgUrl && (
              <div className="w-full h-72 sm:h-96 rounded-3xl overflow-hidden border border-slate-100 bg-slate-50 mb-8 flex items-center justify-center shadow-inner">
                <img
                  src={imgUrl}
                  alt={title}
                  className="w-full h-full object-contain"
                  onError={(e) => {
                    e.target.parentNode.style.display = "none";
                  }}
                />
              </div>
            )}

            {/* Category-specific content */}
            <CategoryDetailRenderer
              detail={detail}
              resourcePath={resourcePath}
              catConfig={catConfig}
            />

            {/* Back Button */}
            <button
              onClick={() => navigate(`/edukasi-publik/${category}`)}
              className="mt-4 inline-flex items-center gap-2 px-6 py-3 border border-slate-200 hover:bg-slate-50 text-slate-700 font-bold rounded-2xl text-sm transition-all"
            >
              <ArrowLeft size={16} /> Kembali ke Daftar Artikel
            </button>
          </div>

          {/* ── Right Sidebar ── */}
          <div className="lg:col-span-4 flex flex-col gap-6 text-left">

            {/* Mobile App CTA */}
            <div className="bg-gradient-to-tr from-primary-900 to-primary-700 text-white rounded-3xl p-5 shadow-md relative overflow-hidden">
              <div className="absolute top-0 right-0 w-20 h-20 bg-primary-500/30 rounded-full blur-xl pointer-events-none" />
              <Smartphone size={28} className="text-primary-300 mb-3" />
              <h4 className="font-extrabold text-white text-base mb-2">Aplikasi Generasi Sehat</h4>
              <p className="text-xs text-primary-200 leading-relaxed mb-4">
                Pantau imunisasi & tumbuh kembang anak langsung dari genggaman Anda. Gratis!
              </p>
              <button
                onClick={handleDownload}
                className="w-full py-2.5 bg-white hover:bg-slate-50 text-primary-900 font-bold text-xs rounded-xl transition-all flex items-center justify-center gap-1.5 shadow"
              >
                <Download size={13} /> Unduh APK Gratis
              </button>
            </div>

            {/* Related Articles */}
            {related.length > 0 && (
              <div className="bg-white rounded-3xl border border-slate-100 p-5 shadow-sm">
                <h4 className="font-bold text-slate-800 text-sm mb-4 pb-3 border-b border-slate-50">
                  Artikel Terkait
                </h4>
                <div className="flex flex-col gap-3">
                  {related.map((item, idx) => {
                    const itemId = guessId(item);
                    const itemTitle = getItemTitle(item, resourcePath);
                    const itemImg = getItemImage(item);
                    return (
                      <Link
                        key={itemId || idx}
                        to={`/edukasi-publik/${category}/${itemId}`}
                        className="flex gap-3 group"
                      >
                        <div className="w-12 h-12 rounded-xl flex-shrink-0 overflow-hidden bg-slate-100 flex items-center justify-center border border-slate-100">
                          {itemImg ? (
                            <img src={itemImg} alt={itemTitle} className="w-full h-full object-cover" onError={(e) => { e.target.style.display = "none"; }} />
                          ) : (
                            <BookOpen size={16} className="text-slate-400 group-hover:text-primary transition-colors" />
                          )}
                        </div>
                        <div className="flex-grow min-w-0">
                          <h5 className="font-semibold text-xs text-slate-700 group-hover:text-primary transition-colors line-clamp-2 leading-snug">
                            {itemTitle}
                          </h5>
                          <span className="text-[10px] text-slate-400 mt-0.5 block">
                            {item.rentang_usia ?? item.umur_target ?? "Umum"}
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
