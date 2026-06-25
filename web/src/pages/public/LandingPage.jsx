import React, { useEffect, useState, useRef } from "react";
import { Link, useNavigate } from "react-router-dom";
import {
  Activity,
  Heart,
  BookOpen,
  Calendar,
  TrendingUp,
  Smartphone,
  Download,
  ArrowRight,
  Shield,
  Users,
  CheckCircle,
  Star,
  ChevronRight,
  BarChart3,
  Baby,
  Brain,
  Utensils,
  Bell,
  FileText,
  Play,
  Sparkles
} from "lucide-react";
import PublicLayout from "./PublicLayout";
import { listPublicEdukasi } from "../../services/edukasiDigital";

/* ─── Animated Counter Hook ─── */
function useCountUp(end, duration = 2000, startOnView = true) {
  const [count, setCount] = useState(0);
  const ref = useRef(null);
  const started = useRef(false);

  useEffect(() => {
    if (!startOnView) return;
    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting && !started.current) {
          started.current = true;
          const startTime = performance.now();
          const animate = (now) => {
            const elapsed = now - startTime;
            const progress = Math.min(elapsed / duration, 1);
            setCount(Math.floor(progress * end));
            if (progress < 1) {
              requestAnimationFrame(animate);
            } else {
              setCount(end);
            }
          };
          requestAnimationFrame(animate);
        }
      },
      { threshold: 0.3 }
    );
    if (ref.current) observer.observe(ref.current);
    return () => observer.disconnect();
  }, [end, duration, startOnView]);

  return [count, ref];
}

/* ─── Phone Mockup Component ─── */
function PhoneMockup({ children, className = "", scale = "scale-100", glow = false }) {
  return (
    <div className={`relative ${className}`}>
      {glow && (
        <div className="absolute -inset-8 bg-gradient-to-tr from-primary-400/20 to-blue-400/20 rounded-[60px] blur-2xl z-0" />
      )}
      <div className={`relative z-10 ${scale}`}>
        {/* Phone Frame */}
        <div className="w-[280px] sm:w-[300px] rounded-[40px] bg-slate-900 p-[6px] shadow-2xl shadow-slate-900/30">
          {/* Notch */}
          <div className="absolute top-[6px] left-1/2 -translate-x-1/2 w-[100px] h-[22px] bg-slate-900 rounded-b-2xl z-30" />
          {/* Screen */}
          <div className="rounded-[34px] overflow-hidden bg-white relative">
            {children}
          </div>
        </div>
      </div>
    </div>
  );
}

/* ─── Feature Pill Component ─── */
function FeaturePill({ icon: Icon, text, color = "primary" }) {
  const colors = {
    primary: "bg-primary-50 text-primary-600 border-primary-100",
    rose: "bg-rose-50 text-rose-600 border-rose-100",
    emerald: "bg-emerald-50 text-emerald-600 border-emerald-100",
    amber: "bg-amber-50 text-amber-600 border-amber-100",
    violet: "bg-violet-50 text-violet-600 border-violet-100",
    blue: "bg-blue-50 text-blue-600 border-blue-100",
  };
  return (
    <span className={`inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-bold border ${colors[color]}`}>
      <Icon size={14} />
      {text}
    </span>
  );
}

const FALLBACK_ARTIKEL = [
  {
    key: "mpasi",
    tag: "Nutrisi Bayi",
    title: "Panduan Memberikan MPASI Sesuai Usia",
    desc: "Pelajari kapan bayi siap menerima makanan pendamping ASI, tekstur makanan yang sesuai, serta frekuensi pemberiannya.",
    path: "edukasi-mpasi",
    fallbackImage: "https://images.unsplash.com/photo-1596464716127-f2a82984de30?w=600&auto=format&fit=crop"
  },
  {
    key: "kesehatan-mental",
    tag: "Kesehatan Ibu",
    title: "Menjaga Kesehatan Mental di Masa Kehamilan",
    desc: "Kesehatan emosional ibu hamil sangat memengaruhi perkembangan janin. Temukan cara rileksasi dan konseling yang tepat.",
    path: "edukasi-kesehatan-mental",
    fallbackImage: "https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?w=600&auto=format&fit=crop"
  },
  {
    key: "perawatan-anak",
    tag: "Perawatan Balita",
    title: "Pentingnya Imunisasi Dasar Lengkap",
    desc: "Imunisasi adalah pertahanan pertama anak dari penyakit menular berbahaya. Berikut tabel jadwal dan efek pasca-imunisasi.",
    path: "edukasi-perawatan-anak",
    fallbackImage: "https://images.unsplash.com/photo-1502086223501-7ea6ecd79368?w=600&auto=format&fit=crop"
  }
];

export default function LandingPage() {
  const navigate = useNavigate();
  const [activeFeature, setActiveFeature] = useState(0);

  const handleDownload = () => {
    window.open("https://github.com/kia-cerdas/kia-cerdas/releases/download/v1.0.0/generasi-sehat-app.apk", "_blank");
  };

  // Auto-cycle features
  useEffect(() => {
    const timer = setInterval(() => {
      setActiveFeature((prev) => (prev + 1) % 4);
    }, 4000);
    return () => clearInterval(timer);
  }, []);

  const [countModul, refModul] = useCountUp(10, 1500);
  const [countAkurasi, refAkurasi] = useCountUp(94, 2000);
  const [countEdukasi, refEdukasi] = useCountUp(50, 1800);

  // ─── Featured edukasi: ambil data terbaru dari API ───
  const [featuredEdukasi, setFeaturedEdukasi] = useState([]);
  const [loadingEdukasi, setLoadingEdukasi] = useState(true);

  useEffect(() => {
    const categories = [
      {
        key: "informasi-umum",
        tag: "Informasi Umum",
        path: "edukasi-informasi-umum",
        fallbackImage: "https://images.unsplash.com/photo-1505682634904-d7c8d95ccd50?w=600&auto=format&fit=crop",
        descField: "konten",
      },
      {
        key: "trimester",
        tag: "Edukasi Trimester",
        path: "edukasi-trimester",
        fallbackImage: "https://images.unsplash.com/photo-1518152006812-edab29b069ac?w=600&auto=format&fit=crop",
        descField: "isi",
      },
      {
        key: "tanda-melahirkan",
        tag: "Tanda Melahirkan",
        path: "edukasi-tanda-melahirkan",
        fallbackImage: "https://images.unsplash.com/photo-1584515901387-a7a1a2f26764?w=600&auto=format&fit=crop",
        descField: "isi",
      },
      {
        key: "imd",
        tag: "Edukasi IMD",
        path: "edukasi-imd",
        fallbackImage: "https://images.unsplash.com/photo-1544120199-8800b5e40624?w=600&auto=format&fit=crop",
        descField: "isi",
      },
      {
        key: "setelah-melahirkan",
        tag: "Setelah Melahirkan",
        path: "edukasi-setelah-melahirkan",
        fallbackImage: "https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?w=600&auto=format&fit=crop",
        descField: "isi",
      },
      {
        key: "menyusui-asi",
        tag: "Menyusui & ASI",
        path: "edukasi-menyusui-asi",
        fallbackImage: "https://images.unsplash.com/photo-1551836022-d5d88e9218df?w=600&auto=format&fit=crop",
        descField: "isi",
      },
      {
        key: "pola-asuh",
        tag: "Pola Asuh",
        path: "edukasi-pola-asuh",
        fallbackImage: "https://images.unsplash.com/photo-1502086223501-7ea6ecd79368?w=600&auto=format&fit=crop",
        descField: "isi",
      },
      {
        key: "kesehatan-mental",
        tag: "Kesehatan Ibu",
        path: "edukasi-kesehatan-mental",
        fallbackImage: "https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?w=600&auto=format&fit=crop",
        descField: "isi",
      },
      {
        key: "perawatan-anak",
        tag: "Perawatan Balita",
        path: "edukasi-perawatan-anak",
        fallbackImage: "https://images.unsplash.com/photo-1596464716127-f2a82984de30?w=600&auto=format&fit=crop",
        descField: "isi_konten",
      },
      {
        key: "mpasi",
        tag: "Nutrisi Bayi",
        path: "edukasi-mpasi",
        fallbackImage: "https://images.unsplash.com/photo-1596464716127-f2a82984de30?w=600&auto=format&fit=crop",
        descField: "konten",
      },
    ];

    const stripHtml = (html) =>
      String(html || "")
        .replace(/<[^>]*>/g, " ")
        .replace(/\s+/g, " ")
        .trim();

    const fetchFeatured = async () => {
      setLoadingEdukasi(true);
      try {
        const allArticles = [];
        await Promise.all(
          categories.map(async (cat) => {
            try {
              const data = await listPublicEdukasi(cat.path);
              if (!Array.isArray(data) || data.length === 0) return;
              data.forEach((item) => {
                const title = item.judul || item.Judul || "Tanpa Judul";
                const rawDesc =
                  item[cat.descField] ||
                  item.isi ||
                  item.isi_konten ||
                  item.konten ||
                  "";
                const descText = stripHtml(rawDesc);
                const desc =
                  descText.slice(0, 140) + (descText.length > 140 ? "..." : "");
                const image = item.gambar_url || item.GambarURL || item.thumbnail_url || item.ThumbnailURL || item.gambar || null;

                allArticles.push({
                  ...cat,
                  id: item.id ?? item.ID ?? null,
                  title,
                  desc,
                  image,
                  createdAt: item.created_at || item.CreatedAt || 0,
                });
              });
            } catch (err) {
              console.error(`Gagal memuat ${cat.path}:`, err);
            }
          })
        );

        // Sort all articles by date descending
        allArticles.sort(
          (a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
        );

        // Take top 3 articles
        setFeaturedEdukasi(allArticles.slice(0, 3));
      } catch (err) {
        console.error("Gagal memuat edukasi pilihan:", err);
      } finally {
        setLoadingEdukasi(false);
      }
    };

    fetchFeatured();
  }, []);

  const appFeatures = [
    {
      icon: Activity,
      title: "Pantau Pertumbuhan",
      desc: "Grafik BB/U, PB/U, LK/U sesuai standar WHO dengan z-score otomatis",
      color: "primary"
    },
    {
      icon: Heart,
      title: "Kesehatan Ibu Hamil",
      desc: "Pencatatan ANC lengkap, skrining risiko tinggi, dan riwayat pemeriksaan",
      color: "rose"
    },
    {
      icon: Utensils,
      title: "Panduan MPASI",
      desc: "Resep bergizi, aturan porsi, dan jadwal harian sesuai usia bayi",
      color: "amber"
    },
    {
      icon: Brain,
      title: "Deteksi Stunting AI",
      desc: "Machine Learning mendeteksi risiko stunting dan memberikan rekomendasi gizi",
      color: "violet"
    },
  ];

  return (
    <PublicLayout>
      <div className="overflow-hidden bg-[#F8FAFC]">

        {/* ═══════════════════════════════════════════════════ */}
        {/* HERO SECTION - App Showcase */}
        {/* ═══════════════════════════════════════════════════ */}
        <section className="relative pt-10 pb-16 md:pt-14 md:pb-20 overflow-hidden">
          {/* Background decorations */}
          <div className="absolute top-0 right-0 w-[60%] h-[60%] bg-gradient-to-bl from-primary-100/50 to-transparent rounded-full filter blur-3xl z-0 pointer-events-none" />
          <div className="absolute bottom-0 left-0 w-[40%] h-[50%] bg-gradient-to-tr from-blue-100/40 to-transparent rounded-full filter blur-3xl z-0 pointer-events-none" />
          <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] bg-gradient-to-br from-primary-200/20 to-transparent rounded-full filter blur-[100px] z-0 pointer-events-none" />

          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10 w-full">
            <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 lg:gap-8 items-center">
              {/* Text Content */}
              <div className="lg:col-span-6 flex flex-col items-start text-left">
                <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-primary-50 border border-primary-100 text-primary-600 text-xs font-semibold uppercase tracking-wider mb-6">
                  <Sparkles size={14} />
                  Sistem Informasi KIA Terintegrasi
                </div>

                <h1 className="text-4xl sm:text-5xl lg:text-[3.5rem] font-black text-slate-800 tracking-tight leading-[1.08] mb-6">
                  Pantau Kesehatan Ibu &
                  <span className="block text-primary bg-gradient-to-r from-primary to-blue-500 bg-clip-text text-transparent">
                    Tumbuh Kembang Anak
                  </span>
                </h1>

                <p className="text-base sm:text-lg text-slate-600 leading-relaxed mb-8 max-w-xl">
                  <strong>Generasi Sehat</strong> merupakan ekosistem digital terpadu. Menghubungkan orang tua, bidan, dan kader posyandu untuk mencatat dan memantau kehamilan (ANC), tumbuh kembang anak (KMS digital), imunisasi, serta deteksi dini risiko stunting berbasis AI.
                </p>

                <div className="flex flex-col sm:flex-row items-stretch sm:items-center gap-3 w-full sm:w-auto mb-10">
                  <button
                    onClick={handleDownload}
                    className="px-8 py-4 bg-primary hover:bg-primary-600 text-white font-bold rounded-2xl shadow-lg shadow-primary/25 flex items-center justify-center gap-2.5 group text-base"
                  >
                    <Download size={20} />
                    Unduh Gratis
                    <ArrowRight size={16} className="group-hover:translate-x-1" />
                  </button>
                </div>

                {/* Feature Pills */}
                <div className="flex flex-wrap gap-2">
                  <FeaturePill icon={BarChart3} text="Grafik WHO" color="primary" />
                  <FeaturePill icon={Brain} text="AI Stunting" color="violet" />
                  <FeaturePill icon={Utensils} text="Resep MPASI" color="amber" />
                  <FeaturePill icon={Bell} text="Pengingat Imunisasi" color="emerald" />
                </div>
              </div>

              {/* Phone Mockups */}
              <div className="lg:col-span-6 flex justify-center relative select-none min-h-[500px] sm:min-h-[560px]">
                {/* Background glow */}
                <div className="absolute top-[15%] left-[15%] w-[70%] h-[70%] bg-gradient-to-tr from-primary-200/40 to-blue-200/30 rounded-[40%_60%_55%_45%_/_55%_45%_55%_45%] filter blur-3xl z-0" />

                {/* Main Phone - App Beranda */}
                <div className="relative z-20">
                  <PhoneMockup glow>
                    {/* Simulated App Screen - Beranda */}
                    <div className="w-full aspect-[9/19.5]">
                      {/* Status Bar */}
                      <div className="bg-primary px-4 pt-8 pb-5">
                        <p className="text-white/80 text-[10px] font-medium mb-0.5">Selamat Pagi 👋</p>
                        <p className="text-white text-sm font-bold">Halo, Dewi!</p>
                        <p className="text-white/70 text-[9px] mt-0.5 flex items-center gap-1">
                          <Heart size={8} /> Semangat jalani hari ini, Bunda!
                        </p>
                      </div>

                      {/* Stages */}
                      <div className="px-4 pt-3 pb-2">
                        <p className="text-[9px] font-bold text-slate-400 uppercase tracking-wider mb-2">Tahap Saat Ini</p>
                        <div className="flex justify-between gap-1">
                          {[
                            { icon: "💗", label: "Hamil", active: false },
                            { icon: "👤", label: "Nifas", active: false },
                            { icon: "😊", label: "Menyusui", active: false },
                            { icon: "🧒", label: "Tumbuh", active: true }
                          ].map((s, i) => (
                            <div key={i} className="flex flex-col items-center gap-1">
                              <div className={`w-9 h-9 rounded-xl flex items-center justify-center text-sm ${s.active ? 'bg-primary text-white ring-2 ring-primary-200' : 'bg-slate-100'}`}>
                                {s.icon}
                              </div>
                              <span className={`text-[8px] font-semibold ${s.active ? 'text-primary' : 'text-slate-400'}`}>{s.label}</span>
                            </div>
                          ))}
                        </div>
                      </div>

                      {/* Child Profile Card */}
                      <div className="mx-4 mt-2 bg-primary-50 rounded-xl p-3 flex items-center gap-3 border border-primary-100">
                        <div className="w-9 h-9 rounded-full bg-primary-100 flex items-center justify-center">
                          <Users size={16} className="text-primary" />
                        </div>
                        <div>
                          <p className="text-[11px] font-bold text-slate-800">Eric Siregar</p>
                          <p className="text-[9px] text-slate-500">9 Bulan 1 Hari · Laki-laki</p>
                        </div>
                      </div>

                      {/* Menu Grid */}
                      <div className="px-4 mt-3">
                        <p className="text-[9px] font-bold text-slate-400 uppercase tracking-wider mb-2">Menu Tumbuh</p>
                        <div className="grid grid-cols-2 gap-2">
                          {[
                            { icon: <TrendingUp size={16} className="text-primary" />, label: "Pertumbuhan", sub: "Pantau berat dan tinggi" },
                            { icon: <Activity size={16} className="text-emerald-500" />, label: "Perkembangan", sub: "Skrining tanda bahaya" },
                            { icon: <Utensils size={16} className="text-amber-500" />, label: "MPASI", sub: "Menu makan bayi" },
                            { icon: <FileText size={16} className="text-blue-500" />, label: "Catatan", sub: "Lihat riwayat anak" }
                          ].map((m, i) => (
                            <div key={i} className="bg-white rounded-xl p-2.5 border border-slate-100 flex flex-col items-center text-center gap-1 shadow-sm">
                              <div className="w-8 h-8 rounded-lg bg-slate-50 flex items-center justify-center">{m.icon}</div>
                              <p className="text-[10px] font-bold text-slate-700">{m.label}</p>
                              <p className="text-[7px] text-slate-400 leading-tight">{m.sub}</p>
                            </div>
                          ))}
                        </div>
                      </div>

                      {/* Alert Banner */}
                      <div className="mx-4 mt-3 bg-amber-50 rounded-lg px-3 py-2 flex items-center gap-2 border border-amber-100">
                        <span className="text-amber-500 text-xs">⚠️</span>
                        <p className="text-[8px] text-amber-700 font-medium flex-grow">Kenali Tanda Bahaya — Segera ke faskes</p>
                        <ChevronRight size={10} className="text-amber-400" />
                      </div>

                      {/* Bottom Nav */}
                      <div className="mt-3 border-t border-slate-100 px-2 py-2 flex justify-around">
                        {[
                          { icon: "🏠", label: "Beranda", active: true },
                          { icon: "📋", label: "Absensi", active: false },
                          { icon: "📖", label: "Edukasi", active: false },
                          { icon: "💉", label: "Imunisasi", active: false },
                          { icon: "👤", label: "Profil", active: false }
                        ].map((n, i) => (
                          <div key={i} className="flex flex-col items-center gap-0.5">
                            <span className="text-[11px]">{n.icon}</span>
                            <span className={`text-[7px] font-semibold ${n.active ? 'text-primary' : 'text-slate-400'}`}>{n.label}</span>
                          </div>
                        ))}
                      </div>
                    </div>
                  </PhoneMockup>
                </div>

                {/* Secondary Phone - Growth Chart (behind, offset right) */}
                <div className="absolute top-12 -right-4 sm:right-0 z-10 hidden md:block">
                  <PhoneMockup className="opacity-90" scale="scale-[0.85]">
                    <div className="w-full aspect-[9/19.5]">
                      {/* Header */}
                      <div className="bg-white px-4 pt-8 pb-3 border-b border-slate-100">
                        <p className="text-sm font-bold text-slate-800">Grafik Pertumbuhan</p>
                        <p className="text-[9px] text-slate-400 mt-0.5">KMS / WHO · BB/U</p>
                      </div>

                      {/* Chart Tabs */}
                      <div className="flex gap-1 px-4 py-2">
                        {["BB/U", "BB/PB", "PB/U", "LK/U", "IMT/U"].map((tab, i) => (
                          <span key={i} className={`px-2 py-1 rounded-full text-[8px] font-bold ${i === 0 ? 'bg-primary text-white' : 'bg-slate-100 text-slate-500'}`}>
                            {tab}
                          </span>
                        ))}
                      </div>

                      {/* Child Info */}
                      <div className="mx-4 flex items-center gap-2 p-2 bg-slate-50 rounded-lg mb-2">
                        <div className="w-7 h-7 rounded-full bg-slate-200 flex items-center justify-center">
                          <Users size={12} className="text-slate-500" />
                        </div>
                        <div>
                          <p className="text-[10px] font-bold text-slate-700">Eric Siregar</p>
                          <span className="text-[8px] px-1.5 py-0.5 bg-primary-50 text-primary rounded-full font-medium">Usia: 9 Bulan</span>
                        </div>
                      </div>

                      {/* Growth Chart SVG */}
                      <div className="mx-4 bg-white rounded-xl border border-slate-100 p-3">
                        <svg viewBox="0 0 200 140" className="w-full">
                          {/* Grid Lines */}
                          {[20, 40, 60, 80, 100, 120].map((y) => (
                            <line key={y} x1="25" y1={y} x2="190" y2={y} stroke="#F1F5F9" strokeWidth="0.5" />
                          ))}
                          {/* Y-axis labels */}
                          {[{ v: "14.0", y: 20 }, { v: "12.0", y: 40 }, { v: "10.0", y: 60 }, { v: "8.0", y: 80 }, { v: "6.0", y: 100 }, { v: "4.0", y: 120 }].map(({ v, y }) => (
                            <text key={v} x="22" y={y + 2} textAnchor="end" fontSize="5" fill="#94A3B8">{v}</text>
                          ))}
                          {/* X-axis labels */}
                          {[{ v: "0", x: 30 }, { v: "3", x: 60 }, { v: "6", x: 90 }, { v: "9", x: 120 }, { v: "12", x: 150 }, { v: "18", x: 180 }].map(({ v, x }) => (
                            <text key={v} x={x} y="138" textAnchor="middle" fontSize="5" fill="#94A3B8">{v}</text>
                          ))}
                          {/* -3 SD line */}
                          <path d="M30 125 Q60 118 90 108 T150 88 180 78" stroke="#94A3B8" strokeWidth="0.6" strokeDasharray="2 2" fill="none" />
                          {/* -2 SD line (red) */}
                          <path d="M30 118 Q60 108 90 95 T150 72 180 60" stroke="#EF4444" strokeWidth="0.8" strokeDasharray="3 2" fill="none" />
                          {/* Median line (green) */}
                          <path d="M30 108 Q60 92 90 78 T150 48 180 32" stroke="#22C55E" strokeWidth="1.2" fill="none" />
                          {/* +2 SD line (red) */}
                          <path d="M30 95 Q60 76 90 58 T150 28 180 14" stroke="#EF4444" strokeWidth="0.8" strokeDasharray="3 2" fill="none" />
                          {/* Data points (blue) */}
                          <circle cx="33" cy="115" r="2.5" fill="#185FA5" />
                          <circle cx="42" cy="110" r="2.5" fill="#185FA5" />
                          <circle cx="52" cy="105" r="2.5" fill="#185FA5" />
                          <circle cx="62" cy="98" r="2.5" fill="#185FA5" />
                          <circle cx="72" cy="93" r="2.5" fill="#185FA5" />
                          <circle cx="82" cy="88" r="2.5" fill="#185FA5" />
                          <circle cx="92" cy="84" r="2.5" fill="#22C55E" />
                          <circle cx="102" cy="80" r="2.5" fill="#22C55E" />
                          <circle cx="112" cy="76" r="2.5" fill="#22C55E" />
                          {/* Connection line */}
                          <polyline points="33,115 42,110 52,105 62,98 72,93 82,88 92,84 102,80 112,76" stroke="#185FA5" strokeWidth="1" fill="none" />
                        </svg>
                      </div>

                      {/* Status Result */}
                      <div className="mx-4 mt-2 bg-emerald-50 rounded-lg p-2.5 flex items-center gap-2 border border-emerald-100">
                        <CheckCircle size={14} className="text-emerald-500 flex-shrink-0" />
                        <div>
                          <p className="text-[10px] font-bold text-emerald-700">Berat Badan Normal</p>
                          <p className="text-[7px] text-emerald-600">Z-score: -0.56 · Status WHO: Normal</p>
                        </div>
                      </div>

                      {/* History */}
                      <div className="mx-4 mt-2 mb-3">
                        <p className="text-[9px] font-bold text-slate-500 mb-1.5">Riwayat Pengukuran</p>
                        <div className="bg-white rounded-lg border border-slate-100 p-2 flex items-center justify-between">
                          <div>
                            <p className="text-[8px] text-slate-400">2026-06-11</p>
                            <p className="text-[11px] font-bold text-slate-800">8.4 kg</p>
                          </div>
                          <span className="px-2 py-0.5 bg-emerald-50 text-emerald-600 text-[7px] font-bold rounded-full">
                            Normal
                          </span>
                        </div>
                      </div>
                    </div>
                  </PhoneMockup>
                </div>

                {/* Floating badges */}
                <div className="absolute top-4 left-0 z-30 hidden lg:block">
                  <div className="bg-white rounded-2xl shadow-xl border border-slate-100 px-4 py-3 flex items-center gap-3">
                    <div className="w-10 h-10 rounded-xl bg-emerald-50 flex items-center justify-center">
                      <CheckCircle size={20} className="text-emerald-500" />
                    </div>
                    <div>
                      <p className="text-xs font-bold text-slate-800">Status Normal</p>
                      <p className="text-[10px] text-emerald-500 font-medium">Z-score: -0.56</p>
                    </div>
                  </div>
                </div>

                <div className="absolute bottom-8 left-4 z-30 hidden lg:block">
                  <div className="bg-white rounded-2xl shadow-xl border border-slate-100 px-4 py-3 flex items-center gap-3">
                    <div className="w-10 h-10 rounded-xl bg-amber-50 flex items-center justify-center">
                      <Bell size={20} className="text-amber-500" />
                    </div>
                    <div>
                      <p className="text-xs font-bold text-slate-800">Imunisasi BCG</p>
                      <p className="text-[10px] text-amber-500 font-medium">Jadwal: 15 Juni 2026</p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* ═══════════════════════════════════════════════════ */}
        {/* FULL FEATURES GRID - MODIFIED: NO HOVER EFFECTS */}
        {/* ═══════════════════════════════════════════════════ */}
        <section className="py-20 bg-slate-50/50">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="text-center max-w-3xl mx-auto mb-16">
              <p className="text-sm font-bold text-primary uppercase tracking-widest mb-3">Fitur Lengkap</p>
              <h2 className="text-3xl sm:text-4xl font-extrabold text-slate-800 tracking-tight">
                Dirancang untuk Seluruh Ekosistem Kesehatan Desa
              </h2>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {[
                { icon: <Activity className="text-primary" size={24} />, title: "Grafik Tumbuh Kembang", desc: "5 jenis grafik WHO (BB/U, PB/U, LK/U, BB/PB, IMT/U) dengan z-score otomatis dan status gizi real-time." },
                { icon: <Heart className="text-rose-500" size={24} />, title: "Pemantauan Kehamilan", desc: "Data ANC lengkap, grafik kenaikan berat badan ibu, skrining preeklampsia, dan riwayat pemeriksaan." },
                { icon: <TrendingUp className="text-blue-500" size={24} />, title: "Deteksi Stunting AI", desc: "Algoritma Machine Learning untuk peringatan dini status gizi buruk anak berdasarkan standar WHO." },
                { icon: <Calendar className="text-amber-500" size={24} />, title: "Jadwal Imunisasi", desc: "Daftar imunisasi wajib dengan pengingat digital otomatis dan riwayat vaksinasi lengkap." },
                { icon: <BookOpen className="text-teal-500" size={24} />, title: "Edukasi & MPASI", desc: "Ratusan resep MPASI bergizi, panduan porsi dan jadwal harian, serta edukasi kesehatan ibu dan anak." },
                { icon: <Shield className="text-primary" size={24} />, title: "Laporan & Manajemen", desc: "Rekap kependudukan, ekspor laporan KIA otomatis format Excel, dan manajemen bidan serta kader." }
              ].map((fitur, idx) => (
                <div
                  key={idx}
                  className="bg-white rounded-2xl border border-slate-100 p-7 text-left"
                >
                  <div className="w-12 h-12 rounded-xl bg-slate-50 flex items-center justify-center mb-5">
                    {fitur.icon}
                  </div>
                  <h3 className="text-lg font-bold text-slate-800 mb-2">{fitur.title}</h3>
                  <p className="text-sm text-slate-500 leading-relaxed">{fitur.desc}</p>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* ═══════════════════════════════════════════════════ */}
        {/* HOW IT WORKS - MODIFIED: NO HOVER EFFECTS */}
        {/* ═══════════════════════════════════════════════════ */}
        <section className="py-20 bg-white relative">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="text-center max-w-3xl mx-auto mb-16">
              <p className="text-sm font-bold text-primary uppercase tracking-widest mb-3">Cara Kerja</p>
              <h2 className="text-3xl sm:text-4xl font-extrabold text-slate-800 tracking-tight">
                4 Langkah Menuju Generasi Sehat
              </h2>
            </div>

            <div className="relative">
              <div className="hidden lg:block absolute top-1/2 left-4 right-4 h-0.5 bg-gradient-to-r from-primary-100 via-primary-200 to-primary-100 -translate-y-1/2 z-0" />
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 relative z-10">
                {[
                  { step: "01", icon: Users, title: "Pendaftaran", desc: "Data keluarga didaftarkan oleh Bidan atau Admin ke dalam sistem kependudukan." },
                  { step: "02", icon: Activity, title: "Pencatatan & ANC", desc: "Bidan mencatat pemeriksaan kehamilan (ANC) dan Kader menginput hasil tumbuh kembang anak ke dashboard." },
                  { step: "03", icon: Smartphone, title: "Pantau Real-time", desc: "Orang tua memantau riwayat kehamilan, resep MPASI, grafik pertumbuhan, dan jadwal imunisasi via aplikasi mobile." },
                  { step: "04", icon: Brain, title: "Analisis AI", desc: "Sistem mendeteksi risiko stunting dan tanda bahaya kehamilan secara otomatis menggunakan Machine Learning." }
                ].map((alur, idx) => {
                  const Icon = alur.icon;
                  return (
                    <div key={idx} className="bg-[#F8FAFC] rounded-2xl p-6 text-left border border-slate-100">
                      <div className="flex items-center gap-3 mb-4">
                        <span className="text-3xl font-black text-primary/15">{alur.step}</span>
                        <div className="w-10 h-10 rounded-xl bg-primary-50 flex items-center justify-center">
                          <Icon size={20} className="text-primary" />
                        </div>
                      </div>
                      <h4 className="text-base font-bold text-slate-800 mb-2">{alur.title}</h4>
                      <p className="text-sm text-slate-500 leading-relaxed">{alur.desc}</p>
                    </div>
                  );
                })}
              </div>
            </div>
          </div>
        </section>

        {/* ═══════════════════════════════════════════════════ */}
        {/* EDUKASI PILIHAN */}
        {/* ═══════════════════════════════════════════════════ */}
        <section className="py-20 bg-slate-50/50">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="flex flex-col sm:flex-row sm:items-end justify-between mb-12 gap-4">
              <div className="text-left">
                <p className="text-sm font-bold text-primary uppercase tracking-widest mb-3">Edukasi Pilihan</p>
                <h2 className="text-3xl font-extrabold text-slate-800 tracking-tight">Bacaan Kesehatan Terbaru</h2>
              </div>
              <Link
                to="/edukasi-publik/informasi-umum"
                className="inline-flex items-center gap-1.5 text-sm font-bold text-primary hover:text-primary-600 hover:underline text-left"
              >
                Lihat Semua Edukasi
                <ArrowRight size={16} />
              </Link>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
              {loadingEdukasi
                ? Array.from({ length: 3 }).map((_, idx) => (
                  <article
                    key={idx}
                    className="bg-white rounded-2xl border border-slate-100 overflow-hidden shadow-sm flex flex-col"
                  >
                    <div className="h-48 bg-slate-100 flex items-center justify-center relative" />
                    <div className="p-6 flex-grow flex flex-col justify-between">
                      <div className="space-y-3">
                        <div className="h-5 w-3/4 rounded-lg bg-slate-200" />
                        <div className="h-4 w-full rounded-lg bg-slate-200" />
                        <div className="h-4 w-5/6 rounded-lg bg-slate-200" />
                      </div>
                      <div className="h-4 w-32 rounded-lg bg-slate-200 mt-6" />
                    </div>
                  </article>
                ))
                : (featuredEdukasi.length > 0 ? featuredEdukasi : FALLBACK_ARTIKEL).map((artikel) => (
                  <article
                    key={artikel.key + "-" + (artikel.id || "fallback")}
                    className="bg-white rounded-2xl border border-slate-100 overflow-hidden shadow-sm text-left flex flex-col group"
                  >
                    <div className="h-48 relative overflow-hidden bg-slate-100">
                      <img
                        src={artikel.image || artikel.fallbackImage}
                        alt={artikel.title}
                        className="w-full h-full object-contain"
                        onError={(e) => {
                          e.target.src = artikel.fallbackImage || "https://images.unsplash.com/photo-1596464716127-f2a82984de30?w=600&auto=format&fit=crop";
                        }}
                      />
                      <div className="absolute top-3 left-3">
                        <span className="inline-block px-2.5 py-1 rounded-full bg-white/90 backdrop-blur-sm text-primary-600 text-xs font-bold shadow-sm">
                          {artikel.tag}
                        </span>
                      </div>
                    </div>
                    <div className="p-6 flex-grow flex flex-col justify-between">
                      <div>
                        <h3 className="text-lg font-bold text-slate-800 mb-3 group-hover:text-primary">
                          <Link to={artikel.id ? `/edukasi-publik/${artikel.key}/${artikel.id}` : `/edukasi-publik/${artikel.key}`}>
                            {artikel.title}
                          </Link>
                        </h3>
                        <p className="text-sm text-slate-500 line-clamp-3 leading-relaxed mb-6">{artikel.desc}</p>
                      </div>
                      <Link
                        to={artikel.id ? `/edukasi-publik/${artikel.key}/${artikel.id}` : `/edukasi-publik/${artikel.key}`}
                        className="inline-flex items-center gap-1 text-sm font-bold text-primary hover:text-primary-600 mt-auto group-hover:gap-2"
                      >
                        Baca Selengkapnya
                        <ArrowRight size={14} />
                      </Link>
                    </div>
                  </article>
                ))}
            </div>
          </div>
        </section>

        {/* ═══════════════════════════════════════════════════ */}
        {/* DOWNLOAD CTA - Final */}
        {/* ═══════════════════════════════════════════════════ */}
        <section className="py-16 md:py-24 bg-white relative">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="bg-gradient-to-tr from-primary-900 via-primary-800 to-slate-900 rounded-[32px] px-8 py-12 md:p-16 text-center md:text-left relative overflow-hidden shadow-2xl">
              <div className="absolute -bottom-24 -right-24 w-80 h-80 bg-primary-500/20 rounded-full filter blur-3xl" />
              <div className="absolute -top-24 -left-24 w-80 h-80 bg-primary-500/10 rounded-full filter blur-3xl" />
              <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[500px] h-[500px] bg-primary-400/5 rounded-full" />

              <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-center relative z-10">
                <div className="lg:col-span-7">
                  <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-white/10 text-primary-200 text-xs font-semibold mb-6 backdrop-blur-sm border border-white/10">
                    <Sparkles size={12} />
                    Gratis untuk Semua Keluarga Indonesia
                  </div>
                  <h2 className="text-3xl md:text-4xl font-extrabold text-white tracking-tight mb-4">
                    Unduh Aplikasi Generasi Sehat Sekarang!
                  </h2>
                  <p className="text-base text-primary-200 leading-relaxed max-w-xl mb-8">
                    Pantau grafik tumbuh kembang, jadwal imunisasi, resep MPASI, dan data kesehatan anak Anda — langsung dari handphone anda.
                  </p>

                  <div className="flex flex-col sm:flex-row items-center gap-4 justify-center md:justify-start">
                    <button
                      onClick={handleDownload}
                      className="w-full sm:w-auto px-8 py-4 bg-white hover:bg-slate-50 text-primary-900 font-bold rounded-2xl shadow-lg flex items-center justify-center gap-2.5 group"
                    >
                      <Download size={20} className="text-primary" />
                      Unduh APK
                      <ArrowRight size={16} className="group-hover:translate-x-1" />
                    </button>
                    <div className="text-center sm:text-left">
                      <p className="text-[10px] text-primary-400">Ukuran ≈ 25 MB</p>
                    </div>
                  </div>
                </div>

                <div className="lg:col-span-5 flex justify-center lg:justify-end">
                  <div className="relative">
                    <div className="w-44 h-44 md:w-56 md:h-56 bg-primary-700/40 rounded-full flex items-center justify-center border-4 border-primary-400/20 relative">
                      <Smartphone size={72} className="text-white/90" />
                      <div className="absolute -top-3 -right-3 bg-emerald-500 text-white font-bold text-xs px-3 py-1.5 rounded-full shadow-lg flex items-center gap-1">
                        <Star size={10} /> Gratis!
                      </div>
                      <div className="absolute -bottom-2 -left-2 bg-amber-500 text-white font-bold text-[10px] px-2.5 py-1 rounded-full shadow-lg flex items-center gap-1">
                        <Download size={10} /> v1.0
                      </div>
                    </div>
                    {/* Orbiting dots */}
                    <div className="absolute inset-0">
                      <div className="absolute top-0 left-1/2 -translate-x-1/2 w-3 h-3 bg-primary-400 rounded-full" />
                    </div>
                    <div className="absolute inset-0">
                      <div className="absolute bottom-0 left-1/2 -translate-x-1/2 w-2 h-2 bg-blue-400 rounded-full" />
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>
      </div>
    </PublicLayout>
  );
}