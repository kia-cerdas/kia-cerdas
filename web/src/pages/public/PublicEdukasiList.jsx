import React, { useEffect, useState, useMemo, useRef } from "react";
import { useParams, Link, useNavigate } from "react-router-dom";
import {
  Search, BookOpen, Clock, AlertTriangle, ArrowLeft,
  ChevronRight, ImageIcon, Tag, Timer, Baby, Heart,
  Brain, Utensils, Calendar, Users, Leaf, X
} from "lucide-react";
import PublicLayout, { PUBLIC_EDUKASI_MENU } from "./PublicLayout";
import { listPublicEdukasi } from "../../services/edukasiDigital";

/* ─── Category Config ─── */
const CATEGORY_CONFIG = {
  "informasi-umum": {
    icon: BookOpen,
    color: "primary",
    bg: "from-primary to-primary-400",
    desc: "Artikel dan panduan kesehatan umum untuk ibu dan anak.",
    emoji: "📋",
  },
  "trimester": {
    icon: Heart,
    color: "primary",
    bg: "from-primary to-primary-400",
    desc: "Panduan kesehatan selama tiga trimester kehamilan.",
    emoji: "🤰",
  },
  "tanda-melahirkan": {
    icon: AlertTriangle,
    color: "primary",
    bg: "from-primary to-primary-400",
    desc: "Kenali tanda-tanda persalinan dan tindakan yang harus dilakukan.",
    emoji: "⚡",
  },
  "imd": {
    icon: Baby,
    color: "primary",
    bg: "from-primary to-primary-400",
    desc: "Panduan Inisiasi Menyusu Dini untuk bayi baru lahir.",
    emoji: "🍼",
  },
  "setelah-melahirkan": {
    icon: Heart,
    color: "primary",
    bg: "from-primary to-primary-400",
    desc: "Informasi penting untuk ibu pada masa setelah melahirkan.",
    emoji: "💝",
  },
  "menyusui-asi": {
    icon: Leaf,
    color: "primary",
    bg: "from-primary to-primary-400",
    desc: "Panduan lengkap menyusui ASI eksklusif untuk ibu dan bayi.",
    emoji: "🌱",
  },
  "pola-asuh": {
    icon: Users,
    color: "primary",
    bg: "from-primary to-primary-400",
    desc: "Panduan pola asuh positif sesuai usia tumbuh kembang anak.",
    emoji: "👨‍👩‍👧",
  },
  "kesehatan-mental": {
    icon: Brain,
    color: "primary",
    bg: "from-primary to-primary-400",
    desc: "Informasi dan solusi untuk menjaga kesehatan mental ibu dan keluarga.",
    emoji: "🧠",
  },
  "perawatan-anak": {
    icon: Baby,
    color: "primary",
    bg: "from-primary to-primary-400",
    desc: "Panduan perawatan anak sesuai tahapan usia.",
    emoji: "👶",
  },
  "mpasi": {
    icon: Utensils,
    color: "primary",
    bg: "from-primary to-primary-400",
    desc: "Panduan makanan pendamping ASI untuk bayi 6 bulan ke atas.",
    emoji: "🥣",
  },
  "mpasi-aturan-porsi": {
    icon: Utensils,
    color: "primary",
    bg: "from-primary to-primary-400",
    desc: "Panduan tekstur, frekuensi, dan porsi MPASI sesuai usia bayi.",
    emoji: "📏",
  },
  "mpasi-jadwal-harian": {
    icon: Calendar,
    color: "primary",
    bg: "from-primary to-primary-400",
    desc: "Jadwal makan harian MPASI yang seimbang untuk bayi.",
    emoji: "🕐",
  },
  "mpasi-resep": {
    icon: Utensils,
    color: "primary",
    bg: "from-primary to-primary-400",
    desc: "Resep MPASI bergizi dan praktis untuk bayi.",
    emoji: "👩‍🍳",
  },
};

const getCategoryConfig = (category) =>
  CATEGORY_CONFIG[category] || {
    icon: BookOpen, color: "primary",
    bg: "from-primary to-primary-400",
    desc: "Konten edukasi kesehatan.",
    emoji: "📚",
  };

/* ─── Data Helpers ─── */
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
  const resource = mapCategoryToResource(category);
  return resource ? resource.label : "Edukasi Kesehatan";
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
  if (item.waktu && item.aktivitas)
    return `${item.waktu} — ${item.aktivitas}`;
  return "Tanpa Judul";
};

const getItemImage = (item) => {
  if (!item) return "";
  return (
    item.gambar_url ?? item.GambarURL ?? item.thumbnail_url ??
    item.ThumbnailURL ?? item.image_url ?? item.image ?? ""
  );
};

const getItemSummary = (item) => {
  if (!item) return "";
  // For Jadwal Harian
  if (item.waktu && item.aktivitas) return `Pukul ${item.waktu} – ${item.aktivitas}`;
  // For Aturan Porsi
  if (item.tekstur) return `Tekstur: ${item.tekstur} · Frekuensi: ${item.frekuensi} · Porsi: ${item.porsi}`;
  // Generic
  return (
    item.ringkasan ?? item.deskripsi ?? item.Ringkasan ??
    item.konten ?? item.isi_konten ?? item.isi ?? ""
  );
};

// Kumpulkan semua teks yang relevan untuk pencarian dari semua field
const getSearchableText = (item, resourcePath) => {
  if (!item) return "";
  const parts = [
    item.judul ?? item.Judul ?? "",
    item.ringkasan ?? item.Ringkasan ?? "",
    item.deskripsi ?? "",
    item.konten ?? "",
    item.isi_konten ?? "",
    item.isi ?? "",
    item.aktivitas ?? "",
    item.waktu ?? "",
    item.tekstur ?? "",
    item.frekuensi ?? "",
    item.porsi ?? "",
    item.tipe ?? "",
    item.rentang_usia ?? "",
    item.umur_target ?? "",
    item.kategori ?? "",
    item.trimester ?? "",
    item.manfaat ?? "",
    item.manfaat_asi ?? "",
    item.cara ?? "",
    item.masalah ?? "",
    item.solusi ?? "",
    item.langkah ?? "",
    item.tanda_gejala ?? "",
    item.yang_perlu_diingat ?? "",
    item.tips ?? "",
    // MPASI Resep: array fields
    ...(Array.isArray(item.bahan_bahan) ? item.bahan_bahan : []),
    ...(Array.isArray(item.cara_membuat) ? item.cara_membuat : []),
    // bulan range label
    item.bulan_min !== undefined
      ? `${item.bulan_min} ${item.bulan_max} bulan`
      : "",
  ];
  return parts.filter(Boolean).join(" ").toLowerCase();
};

const getItemBadge = (item) => {
  if (item.trimester) return `Trimester ${item.trimester}`;
  if (item.bulan_min !== undefined && item.bulan_max !== undefined) {
    return `Usia ${item.bulan_min}–${item.bulan_max} Bulan`;
  }
  return item.rentang_usia ?? item.umur_target ?? item.tipe ?? item.kategori ?? "Umum";
};

const guessId = (item) =>
  item?.id ?? item?.ID ?? item?.id_edukasi ?? item?.id_informasi ?? null;

/* ─── Age Filter Config — Satu sumber kebenaran untuk semua kategori ─── */
const AGE_FILTER_CONFIG = {
  "perawatan-anak": {
    label: "Filter Usia",
    paramType: "server",   // kirim ke server via ?rentang_usia=
    paramKey: "rentang_usia",
    options: [
      "0-28 hari",
      "0-3 bulan",
      "3-6 bulan",
      "6-9 bulan",
      "9-12 bulan",
      "12-18 bulan",
      "18-24 bulan",
      "2-3 tahun",
      "3-4 tahun",
      "4-5 tahun",
      "5-6 tahun",
    ],
  },
  "pola-asuh": {
    label: "Filter Usia",
    paramType: "server",
    paramKey: "rentang_usia",
    options: [
      "0-18 Bulan",
      "1.5 Tahun - 3 Tahun",
      "3 tahun - 6 Tahun",
    ],
  },
  "trimester": {
    label: "Filter Trimester",
    paramType: "local",    // filter di sisi klien (field: trimester)
    filterField: "trimester",
    options: ["1", "2", "3"],
    labelMap: { "1": "Trimester 1", "2": "Trimester 2", "3": "Trimester 3" },
  },
  "mpasi": {
    label: "Filter Usia (Bulan)",
    paramType: "local",    // filter bulan_min/bulan_max di sisi klien
    filterField: "bulan",
    options: ["0-6", "6-9", "9-12", "12-24"],
    labelMap: {
      "0-6": "0–6 Bulan",
      "6-9": "6–9 Bulan",
      "9-12": "9–12 Bulan",
      "12-24": "12–24 Bulan",
    },
  },
  "mpasi-aturan-porsi": {
    label: "Filter Usia (Bulan)",
    paramType: "local",
    filterField: "bulan",
    options: ["0-6", "6-9", "9-12", "12-24"],
    labelMap: {
      "0-6": "0–6 Bulan",
      "6-9": "6–9 Bulan",
      "9-12": "9–12 Bulan",
      "12-24": "12–24 Bulan",
    },
  },
  "mpasi-jadwal-harian": {
    label: "Filter Usia (Bulan)",
    paramType: "local",
    filterField: "bulan",
    options: ["0-6", "6-9", "9-12", "12-24"],
    labelMap: {
      "0-6": "0–6 Bulan",
      "6-9": "6–9 Bulan",
      "9-12": "9–12 Bulan",
      "12-24": "12–24 Bulan",
    },
  },
  "mpasi-resep": {
    label: "Filter Usia (Bulan)",
    paramType: "local",
    filterField: "bulan",
    options: ["0-6", "6-9", "9-12", "12-24"],
    labelMap: {
      "0-6": "0–6 Bulan",
      "6-9": "6–9 Bulan",
      "9-12": "9–12 Bulan",
      "12-24": "12–24 Bulan",
    },
  },
};

// Helper: apakah item cocok dengan filter bulan
function matchesBulanFilter(item, rangeStr) {
  if (!rangeStr) return true;
  const [minStr, maxStr] = rangeStr.split("-");
  const filterMin = parseInt(minStr, 10);
  const filterMax = parseInt(maxStr, 10);
  const itemMin = item.bulan_min ?? 0;
  const itemMax = item.bulan_max ?? 999;
  // Overlap check: item range overlaps dengan filter range
  return itemMin < filterMax && itemMax > filterMin;
}

/* ─── Age Filter Options (legacy — dipertahankan untuk kompatibilitas) ─── */
const PERAWATAN_FILTER = ["0-28 hari", "0-3 bulan", "3-6 bulan", "6-9 bulan", "9-12 bulan", "12-18 bulan", "18-24 bulan"];
const POLA_ASUH_FILTER = ["0-18 Bulan", "1.5 Tahun - 3 Tahun", "3 tahun - 6 Tahun"];

/* ─── Color Helpers ─── */
const colorClasses = {
  primary: { pill: "bg-primary-50 text-primary-600", btn: "bg-primary text-white" },
  indigo: { pill: "bg-primary-50 text-primary-600", btn: "bg-primary text-white" },
  rose: { pill: "bg-primary-50 text-primary-600", btn: "bg-primary text-white" },
  amber: { pill: "bg-primary-50 text-primary-600", btn: "bg-primary text-white" },
  emerald: { pill: "bg-primary-50 text-primary-600", btn: "bg-primary text-white" },
  pink: { pill: "bg-primary-50 text-primary-600", btn: "bg-primary text-white" },
  green: { pill: "bg-primary-50 text-primary-600", btn: "bg-primary text-white" },
  violet: { pill: "bg-primary-50 text-primary-600", btn: "bg-primary text-white" },
  blue: { pill: "bg-primary-50 text-primary-600", btn: "bg-primary text-white" },
  cyan: { pill: "bg-primary-50 text-primary-600", btn: "bg-primary text-white" },
  orange: { pill: "bg-primary-50 text-primary-600", btn: "bg-primary text-white" },
};

/* ─── Special Card for MPASI Jadwal Harian ─── */
function JadwalCard({ item, category, id }) {
  return (
    <article className="bg-white rounded-2xl border border-slate-100 overflow-hidden shadow-sm hover:shadow-lg hover:-translate-y-0.5 transition-all duration-300 flex items-center gap-4 p-5">
      <div className="w-14 h-14 rounded-2xl bg-gradient-to-br from-primary to-primary-400 flex items-center justify-center text-white font-bold text-sm flex-shrink-0 shadow-md shadow-primary-100">
        {item.waktu || "—"}
      </div>
      <div className="flex-grow min-w-0">
        <p className="font-bold text-slate-800 text-sm mb-1">{item.aktivitas || "Aktivitas"}</p>
        <p className="text-xs text-slate-400">
          {item.bulan_min}–{item.bulan_max} Bulan
        </p>
      </div>
      <Link
        to={`/edukasi-publik/${category}/${id}`}
        className="flex-shrink-0 p-2 rounded-xl bg-primary-50 text-primary-600 hover:bg-primary-100 transition-colors"
      >
        <ChevronRight size={18} />
      </Link>
    </article>
  );
}

/* ─── Special Card for MPASI Aturan Porsi ─── */
function AturanPorsiCard({ item, category, id }) {
  return (
    <article className="bg-white rounded-2xl border border-slate-100 overflow-hidden shadow-sm hover:shadow-lg hover:-translate-y-0.5 transition-all duration-300 flex flex-col">
      <div className="bg-gradient-to-br from-primary to-primary-400 p-4 text-white">
        <p className="text-xs font-semibold opacity-80 mb-1">Usia</p>
        <h3 className="font-extrabold text-lg">
          {item.bulan_min}–{item.bulan_max} Bulan
        </h3>
      </div>
      <div className="p-5 flex-grow flex flex-col gap-3">
        {item.tekstur && (
          <div>
            <span className="text-[10px] uppercase font-bold text-slate-400 tracking-wide">Tekstur</span>
            <p className="text-sm text-slate-700 mt-0.5 line-clamp-2">{item.tekstur}</p>
          </div>
        )}
        {item.frekuensi && (
          <div>
            <span className="text-[10px] uppercase font-bold text-slate-400 tracking-wide">Frekuensi</span>
            <p className="text-sm text-slate-700 mt-0.5 line-clamp-2">{item.frekuensi}</p>
          </div>
        )}
        {item.porsi && (
          <div>
            <span className="text-[10px] uppercase font-bold text-slate-400 tracking-wide">Porsi</span>
            <p className="text-sm text-slate-700 mt-0.5 line-clamp-2">{item.porsi}</p>
          </div>
        )}
        <Link
          to={`/edukasi-publik/${category}/${id}`}
          className="mt-auto inline-flex items-center gap-1 text-xs font-bold text-primary-600 hover:text-primary-700 transition-colors"
        >
          Lihat Detail <ChevronRight size={14} />
        </Link>
      </div>
    </article>
  );
}

/* ─── Special Card for Resep MPASI ─── */
function ResepCard({ item, category, id }) {
  const imgUrl = getItemImage(item);
  return (
    <article className="bg-white rounded-3xl border border-slate-100 overflow-hidden shadow-sm hover:shadow-xl hover:-translate-y-1 transition-all duration-300 flex flex-col group">
      <div className="h-52 bg-slate-100 relative overflow-hidden flex items-center justify-center flex-shrink-0">
        {imgUrl ? (
          <img
            src={imgUrl}
            alt={item.judul}
            className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
            onError={(e) => { e.target.style.display = "none"; }}
          />
        ) : (
          <div className="text-slate-300 flex flex-col items-center gap-2">
            <Utensils size={40} strokeWidth={1} />
          </div>
        )}
        <div className="absolute inset-0 bg-gradient-to-t from-black/40 to-transparent" />
        <div className="absolute bottom-3 left-3 right-3 flex items-center justify-between">
          {item.tipe && (
            <span className="px-2 py-0.5 bg-primary text-white text-xs font-bold rounded-full">
              {item.tipe}
            </span>
          )}
          {item.kalori && (
            <span className="px-2 py-0.5 bg-white/90 text-primary-700 text-xs font-bold rounded-full backdrop-blur-sm">
              {item.kalori} kkal
            </span>
          )}
        </div>
      </div>
      <div className="p-5 flex-grow flex flex-col">
        <p className="text-xs text-primary-600 font-semibold mb-2">
          Usia {item.bulan_min}–{item.bulan_max} Bulan
        </p>
        <h3 className="font-bold text-slate-800 text-base mb-2 line-clamp-2 group-hover:text-primary-600 transition-colors">
          <Link to={`/edukasi-publik/${category}/${id}`}>{item.judul}</Link>
        </h3>
        <div className="flex items-center gap-3 text-xs text-slate-400 mt-auto pt-3 border-t border-slate-50">
          {item.waktu_persiapan && (
            <span className="flex items-center gap-1">
              <Timer size={12} /> {item.waktu_persiapan} mnt
            </span>
          )}
          {item.porsi && (
            <span className="flex items-center gap-1">
              <Utensils size={12} /> {item.porsi}
            </span>
          )}
          <Link
            to={`/edukasi-publik/${category}/${id}`}
            className="ml-auto text-primary-600 font-bold hover:text-primary-700 flex items-center gap-0.5"
          >
            Lihat Resep <ChevronRight size={14} />
          </Link>
        </div>
      </div>
    </article>
  );
}

/* ─── Generic Article Card ─── */
function ArticleCard({ item, category, resourcePath, catConfig }) {
  const id = guessId(item);
  const imgUrl = getItemImage(item);
  const title = getItemTitle(item, resourcePath);
  const summary = getItemSummary(item);
  const badge = getItemBadge(item);
  const colors = colorClasses[catConfig?.color] || colorClasses.primary;
  const emoji = catConfig?.emoji || "📚";
  const bg = catConfig?.bg || "from-primary to-primary-400";

  return (
    <article className="bg-white rounded-3xl border border-slate-100 overflow-hidden shadow-sm hover:shadow-xl hover:-translate-y-1 transition-all duration-300 flex flex-col group">
      <div className="h-48 bg-slate-100 relative overflow-hidden flex items-center justify-center flex-shrink-0">
        {imgUrl ? (
          <img
            src={imgUrl}
            alt={title}
            className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
            onError={(e) => { e.target.style.display = "none"; }}
          />
        ) : (
          <div className={`w-full h-full bg-gradient-to-br ${bg} opacity-10 absolute inset-0`} />
        )}
        {!imgUrl && (
          <div className="relative z-10 flex flex-col items-center gap-2 text-slate-400">
            <span className="text-5xl">{emoji}</span>
          </div>
        )}
        {badge && badge !== "Umum" && (
          <div className="absolute top-3 left-3">
            <span className={`px-2.5 py-1 text-xs font-bold rounded-full shadow-sm backdrop-blur-sm ${colors.pill}`}>
              {badge}
            </span>
          </div>
        )}
      </div>
      <div className="p-5 flex-grow flex flex-col">
        <h3 className="font-bold text-slate-800 text-base mb-2 line-clamp-2 group-hover:text-primary transition-colors">
          <Link to={`/edukasi-publik/${category}/${id}`}>{title}</Link>
        </h3>
        {summary && (
          <p className="text-sm text-slate-500 line-clamp-3 leading-relaxed mb-4">
            {summary}
          </p>
        )}
        <div className="mt-auto pt-3 border-t border-slate-50 flex items-center justify-between">
          <span className="text-xs text-slate-400 flex items-center gap-1">
            <Clock size={12} />
            {item.created_at
              ? new Date(item.created_at).toLocaleDateString("id-ID", { day: "numeric", month: "short" })
              : "Baru"}
          </span>
          <Link
            to={`/edukasi-publik/${category}/${id}`}
            className="inline-flex items-center gap-1 text-sm font-bold text-primary hover:text-primary-600 transition-colors"
          >
            Baca <ChevronRight size={15} />
          </Link>
        </div>
      </div>
    </article>
  );
}

/* ─── Main Component ─── */
export default function PublicEdukasiList() {
  const { category } = useParams();
  const navigate = useNavigate();
  const [rows, setRows] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [searchQuery, setSearchQuery] = useState("");
  const [activeRentangUsia, setActiveRentangUsia] = useState("");
  const searchInputRef = useRef(null);

  const categoryInfo = mapCategoryToResource(category);
  const resourcePath = categoryInfo?.resource;
  const catConfig = getCategoryConfig(category);
  const categoryLabel = getCategoryLabel(category);
  const ageFilterCfg = AGE_FILTER_CONFIG[category] ?? null;

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
      setError("Gagal memuat konten edukasi. Silakan coba beberapa saat lagi.");
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
    setSearchQuery("");
    // Server-side filter: kirim ke API
    if (!ageFilterCfg || ageFilterCfg.paramType === "server") {
      loadData(usia ? { rentang_usia: usia } : {});
    }
    // Local filter: data sudah di-load, filter dilakukan di filteredRows
  };

  const handleClearSearch = () => {
    setSearchQuery("");
    searchInputRef.current?.focus();
  };

  // Filter lokal: search query + filter usia lokal (trimester, bulan)
  const filteredRows = useMemo(() => {
    let result = rows;

    // Filter usia lokal (untuk kategori yang tidak support server filter)
    if (ageFilterCfg?.paramType === "local" && activeRentangUsia) {
      if (ageFilterCfg.filterField === "trimester") {
        result = result.filter((item) => String(item.trimester) === activeRentangUsia);
      } else if (ageFilterCfg.filterField === "bulan") {
        result = result.filter((item) => matchesBulanFilter(item, activeRentangUsia));
      }
    }

    // Filter teks
    const q = searchQuery.trim().toLowerCase();
    if (q) {
      result = result.filter((item) => getSearchableText(item, resourcePath).includes(q));
    }

    return result;
  }, [rows, searchQuery, resourcePath, activeRentangUsia, ageFilterCfg]);

  const isJadwal = resourcePath === "edukasi-mpasi-jadwal-harian";
  const isPorsi = resourcePath === "edukasi-mpasi-aturan-porsi";
  const isResep = resourcePath === "edukasi-mpasi-resep";

  return (
    <PublicLayout>
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Breadcrumbs */}
        <nav className="flex items-center gap-1.5 text-xs sm:text-sm text-slate-500 mb-6">
          <Link to="/" className="hover:text-primary transition-colors">Beranda</Link>
          <ChevronRight size={14} className="text-slate-400" />
          <span className="text-slate-700 font-semibold">{categoryLabel}</span>
        </nav>

        {/* Toolbar */}
        <div className="flex flex-col md:flex-row gap-3 items-stretch md:items-center mb-6">
          <div className="relative flex-grow max-w-md">
            <Search size={17} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none" />
            <input
              ref={searchInputRef}
              type="text"
              placeholder={`Cari di ${categoryLabel}...`}
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="block w-full pl-10 pr-10 py-3 border border-slate-200 rounded-2xl text-sm bg-white placeholder-slate-400 focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all shadow-sm"
            />
            {searchQuery && (
              <button
                onClick={handleClearSearch}
                className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 transition-colors"
                title="Hapus pencarian"
              >
                <X size={16} />
              </button>
            )}
          </div>

          {ageFilterCfg && (
            <div className="flex items-center gap-2 flex-shrink-0">
              <span className="text-xs text-slate-500 font-semibold whitespace-nowrap hidden sm:block">
                {ageFilterCfg.label}:
              </span>
              <div className="relative">
                <select
                  value={activeRentangUsia}
                  onChange={(e) => handleFilterUsia(e.target.value)}
                  className="appearance-none pl-3 pr-8 py-2.5 border border-slate-200 rounded-2xl text-sm font-semibold text-slate-700 bg-white focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all shadow-sm cursor-pointer min-w-[140px]"
                >
                  <option value="">Semua Umur</option>
                  {ageFilterCfg.options.map((opt) => (
                    <option key={opt} value={opt}>
                      {ageFilterCfg.labelMap ? ageFilterCfg.labelMap[opt] : opt}
                    </option>
                  ))}
                </select>
                <ChevronRight
                  size={14}
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none rotate-90"
                />
              </div>
            </div>
          )}
        </div>

        {/* Info hasil pencarian / filter aktif */}
        {!loading && (searchQuery.trim() || activeRentangUsia) && (
          <div className="flex items-center flex-wrap gap-2 mb-4">
            {/* Badge filter usia aktif */}
            {activeRentangUsia && ageFilterCfg && (
              <span className="inline-flex items-center gap-1.5 px-3 py-1 bg-primary/10 text-primary text-xs font-semibold rounded-full">
                <span>{ageFilterCfg.label}:</span>
                <strong>{ageFilterCfg.labelMap ? ageFilterCfg.labelMap[activeRentangUsia] : activeRentangUsia}</strong>
                <button
                  onClick={() => handleFilterUsia("")}
                  className="ml-0.5 text-primary/60 hover:text-primary"
                >
                  <X size={12} />
                </button>
              </span>
            )}

            {/* Info hasil search */}
            {searchQuery.trim() && (
              <div className="flex items-center gap-2 text-sm text-slate-500">
                <Search size={14} className="text-slate-400" />
                <span>
                  {filteredRows.length === 0
                    ? <span>Tidak ada hasil untuk <strong className="text-slate-700">"{searchQuery}"</strong></span>
                    : <span>Menampilkan <strong className="text-slate-700">{filteredRows.length}</strong> hasil untuk <strong className="text-slate-700">"{searchQuery}"</strong></span>
                  }
                </span>
                <button
                  onClick={handleClearSearch}
                  className="text-xs text-primary hover:underline font-semibold"
                >
                  Hapus
                </button>
              </div>
            )}
          </div>
        )}

        {/* Error */}
        {error && (
          <div className="bg-red-50 border border-red-200 text-red-700 px-5 py-4 rounded-2xl flex items-center gap-3 mb-6">
            <AlertTriangle className="text-red-500 flex-shrink-0" size={22} />
            <div>
              <p className="font-bold text-sm">Kesalahan Koneksi</p>
              <p className="text-xs text-red-500 mt-0.5">{error}</p>
            </div>
          </div>
        )}

        {/* Content */}
        {loading ? (
          <div className="flex flex-col items-center justify-center py-24 gap-4">
            <div className="w-12 h-12 border-4 border-slate-200 border-t-primary rounded-full animate-spin" />
            <p className="text-slate-500 text-sm font-medium">Memuat materi edukasi…</p>
          </div>
        ) : filteredRows.length === 0 ? (
          <div className="bg-white rounded-3xl border-2 border-dashed border-slate-200 py-20 px-4 text-center">
            {searchQuery.trim() ? (
              <>
                <div className="text-6xl mb-4">🔍</div>
                <h3 className="text-lg font-bold text-slate-700 mb-2">Tidak Ada Hasil</h3>
                <p className="text-sm text-slate-400 max-w-sm mx-auto mb-4">
                  Tidak ditemukan materi yang cocok dengan kata kunci <strong className="text-slate-600">"{searchQuery}"</strong>.
                </p>
                <button
                  onClick={handleClearSearch}
                  className="px-5 py-2 bg-primary text-white text-sm font-semibold rounded-xl hover:bg-primary-600 transition-colors"
                >
                  Hapus Pencarian
                </button>
              </>
            ) : (
              <>
                <div className="text-6xl mb-4">📭</div>
                <h3 className="text-lg font-bold text-slate-700 mb-2">Materi Belum Tersedia</h3>
                <p className="text-sm text-slate-400 max-w-sm mx-auto">
                  Belum ada konten untuk kategori ini. Tim bidan kami akan segera menambahkan materi edukasi terbaru.
                </p>
              </>
            )}
          </div>
        ) : isJadwal ? (
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            {filteredRows.map((item, idx) => {
              const id = guessId(item);
              return <JadwalCard key={id || idx} item={item} category={category} id={id} />;
            })}
          </div>
        ) : isPorsi ? (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
            {filteredRows.map((item, idx) => {
              const id = guessId(item);
              return <AturanPorsiCard key={id || idx} item={item} category={category} id={id} />;
            })}
          </div>
        ) : isResep ? (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
            {filteredRows.map((item, idx) => {
              const id = guessId(item);
              return <ResepCard key={id || idx} item={item} category={category} id={id} />;
            })}
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {filteredRows.map((item, idx) => {
              const id = guessId(item);
              return (
                <ArticleCard
                  key={id || idx}
                  item={item}
                  category={category}
                  resourcePath={resourcePath}
                  catConfig={catConfig}
                />
              );
            })}
          </div>
        )}
      </div>
    </PublicLayout>
  );
}
