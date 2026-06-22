import React from "react";
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
  CheckCircle
} from "lucide-react";
import PublicLayout from "../components/Layout/PublicLayout";
import { isAuthenticated, getPostLoginRoute } from "../services/auth";

export default function LandingPage() {
  const navigate = useNavigate();
  const loggedIn = isAuthenticated();

  const handleCTA = () => {
    if (loggedIn) {
      navigate(getPostLoginRoute());
    } else {
      navigate("/login");
    }
  };

  const handleDownload = () => {
    window.open("https://github.com/kia-cerdas/kia-cerdas/releases/download/v1.0.0/generasi-sehat-app.apk", "_blank");
  };

  return (
    <PublicLayout>
      <div className="overflow-hidden bg-[#F8FAFC]">
        {/* HERO SECTION */}
        <section className="relative min-h-[85vh] flex items-center pt-8 pb-16 md:py-24">
          {/* Background Decorative Gradients */}
          <div className="absolute top-0 right-0 w-[50%] h-[50%] bg-gradient-to-bl from-indigo-200/40 to-transparent rounded-full filter blur-3xl z-0 pointer-events-none" />
          <div className="absolute bottom-0 left-0 w-[35%] h-[40%] bg-gradient-to-tr from-blue-100/50 to-transparent rounded-full filter blur-3xl z-0 pointer-events-none" />

          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10 w-full">
            <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 lg:gap-8 items-center">
              {/* Text Info */}
              <div className="lg:col-span-6 flex flex-col items-start text-left">
                <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-indigo-50 border border-indigo-100 text-indigo-700 text-xs font-semibold uppercase tracking-wider mb-6 animate-fade-in">
                  <span className="w-2 h-2 rounded-full bg-indigo-500 animate-pulse" />
                  E-KIA & Deteksi Kesehatan Terintegrasi
                </div>
                <h1 className="text-4xl sm:text-5xl lg:text-6xl font-black text-slate-800 tracking-tight leading-[1.1] mb-6">
                  Generasi<span className="text-indigo-600 bg-gradient-to-r from-indigo-600 to-blue-600 bg-clip-text text-transparent">Sehat</span>, Masa Depan Kuat
                </h1>
                <p className="text-base sm:text-lg text-slate-600 leading-relaxed mb-8 max-w-xl">
                  Platform digital cerdas pengganti Buku KIA konvensional. Memantau kesehatan ibu hamil secara rutin dan mengawal tumbuh kembang anak dari stunting secara real-time bertenaga Machine Learning.
                </p>
                
                <div className="flex flex-col sm:flex-row items-stretch sm:items-center gap-3 w-full sm:w-auto">
                  <button
                    onClick={handleCTA}
                    className="px-8 py-3.5 bg-indigo-600 hover:bg-indigo-700 text-white font-semibold rounded-2xl shadow-lg shadow-indigo-150 hover:shadow-xl active:scale-98 transition-all flex items-center justify-center gap-2 group text-base"
                  >
                    {loggedIn ? "Ke Dashboard" : "Masuk ke Dashboard"}
                    <ArrowRight size={18} className="group-hover:translate-x-1 transition-transform" />
                  </button>
                  <button
                    onClick={handleDownload}
                    className="px-8 py-3.5 bg-white hover:bg-slate-50 text-slate-700 border border-slate-200 font-semibold rounded-2xl shadow-sm hover:shadow active:scale-98 transition-all flex items-center justify-center gap-2 text-base"
                  >
                    <Download size={18} />
                    Unduh Aplikasi Mobile
                  </button>
                </div>

                {/* Hero Stats */}
                <div className="grid grid-cols-3 gap-6 sm:gap-10 border-t border-slate-200/80 pt-8 mt-10 w-full max-w-lg">
                  <div>
                    <p className="text-2xl sm:text-3xl font-extrabold text-slate-800">100%</p>
                    <p className="text-xs font-semibold text-slate-500 mt-1">Data Terintegrasi</p>
                  </div>
                  <div>
                    <p className="text-2xl sm:text-3xl font-extrabold text-slate-800">10+</p>
                    <p className="text-xs font-semibold text-slate-500 mt-1">Modul Edukasi</p>
                  </div>
                  <div>
                    <p className="text-2xl sm:text-3xl font-extrabold text-slate-800">AI</p>
                    <p className="text-xs font-semibold text-slate-500 mt-1">Deteksi Stunting</p>
                  </div>
                </div>
              </div>

              {/* Graphic Illustration */}
              <div className="lg:col-span-6 flex justify-center relative select-none">
                {/* Decorative blob behind image */}
                <div className="absolute top-[10%] left-[10%] w-[80%] h-[80%] bg-gradient-to-tr from-indigo-100 to-indigo-200 rounded-[30%_70%_70%_30%_/_30%_30%_70%_70%] filter blur-2xl z-0 animate-spin-slow opacity-75" />

                {/* Stunning Interactive SVG Device Mockup & Dashboard Vibe */}
                <div className="relative z-10 w-full max-w-[480px]">
                  <svg viewBox="0 0 500 500" fill="none" xmlns="http://www.w3.org/2000/svg" className="w-full h-auto filter drop-shadow-2xl">
                    {/* Floating Health Card 1 */}
                    <g className="animate-bounce" style={{ animationDuration: "6s" }}>
                      <rect x="30" y="80" width="160" height="90" rx="16" fill="white" filter="drop-shadow(0px 10px 20px rgba(99,102,241,0.08))" />
                      <rect x="30" y="80" width="160" height="90" rx="16" stroke="#EEF2F6" strokeWidth="1" />
                      <circle cx="65" cy="115" r="16" fill="#EEF2F6" />
                      <path d="M60 115H70M65 110V120" stroke="#4F46E5" strokeWidth="2" strokeLinecap="round" />
                      <rect x="94" y="106" width="70" height="8" rx="4" fill="#4F46E5" />
                      <rect x="94" y="118" width="50" height="6" rx="3" fill="#94A3B8" />
                      <rect x="46" y="142" width="108" height="14" rx="7" fill="#F0FDF4" />
                      <circle cx="56" cy="149" r="3" fill="#22C55E" />
                      <rect x="66" y="146" width="76" height="6" rx="3" fill="#22C55E" />
                    </g>

                    {/* Floating Health Card 2 (Growth Chart) */}
                    <g className="animate-bounce" style={{ animationDuration: "8s", animationDelay: "1s" }}>
                      <rect x="290" y="320" width="180" height="120" rx="20" fill="white" filter="drop-shadow(0px 10px 25px rgba(99,102,241,0.1))" />
                      <rect x="290" y="320" width="180" height="120" rx="20" stroke="#EEF2F6" strokeWidth="1" />
                      <rect x="314" y="344" width="70" height="10" rx="5" fill="#1E293B" />
                      <rect x="314" y="358" width="50" height="6" rx="3" fill="#64748B" />
                      
                      {/* Mini Line Chart SVG representation */}
                      <path d="M314 416 L340 400 L370 410 L400 380 L430 395 L450 370" stroke="#3B82F6" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round" />
                      <circle cx="340" cy="400" r="3" fill="#3B82F6" />
                      <circle cx="400" cy="380" r="3" fill="#3B82F6" />
                      <circle cx="450" cy="370" r="4" fill="#3B82F6" stroke="white" strokeWidth="1.5" />
                    </g>

                    {/* Mobile Phone Device Core Layout */}
                    <rect x="180" y="110" width="170" height="310" rx="32" fill="#1E293B" />
                    <rect x="186" y="116" width="158" height="298" rx="26" fill="white" />
                    {/* Notch */}
                    <rect x="235" y="116" width="60" height="14" rx="7" fill="#1E293B" />
                    
                    {/* Phone Screen Mockup Content */}
                    <circle cx="265" cy="165" r="28" fill="#EEF2F6" />
                    <path d="M255 165 C255 155, 275 155, 275 165 C275 175, 255 175, 255 165" stroke="#4F46E5" strokeWidth="3" strokeLinecap="round" />
                    <circle cx="265" cy="162" r="5" fill="#4F46E5" />
                    
                    <rect x="215" y="210" width="100" height="10" rx="5" fill="#1E293B" />
                    <rect x="230" y="226" width="70" height="6" rx="3" fill="#94A3B8" />

                    {/* Dashboard grid inside phone */}
                    <rect x="206" y="250" width="54" height="46" rx="10" fill="#EEF2F6" />
                    <rect x="216" y="258" width="20" height="6" rx="3" fill="#4F46E5" />
                    <rect x="216" y="272" width="34" height="4" rx="2" fill="#94A3B8" />
                    <rect x="216" y="280" width="26" height="4" rx="2" fill="#94A3B8" />

                    <rect x="270" y="250" width="54" height="46" rx="10" fill="#EEF2F6" />
                    <rect x="280" y="258" width="20" height="6" rx="3" fill="#10B981" />
                    <rect x="280" y="272" width="34" height="4" rx="2" fill="#94A3B8" />
                    <rect x="280" y="280" width="26" height="4" rx="2" fill="#94A3B8" />

                    <rect x="206" y="306" width="118" height="54" rx="12" fill="#4F46E5" />
                    <rect x="220" y="320" width="50" height="8" rx="4" fill="white" />
                    <rect x="220" y="332" width="90" height="5" rx="2.5" fill="white" fillOpacity="0.6" />
                    <rect x="220" y="341" width="70" height="5" rx="2.5" fill="white" fillOpacity="0.6" />
                    
                    {/* Navigation bar inside phone */}
                    <rect x="186" y="375" width="158" height="39" rx="0" fill="#F8FAFC" />
                    <line x1="186" y1="375" x2="344" y2="375" stroke="#E2E8F0" strokeWidth="1" />
                    <circle cx="215" cy="392" r="6" fill="#4F46E5" />
                    <circle cx="265" cy="392" r="6" fill="#94A3B8" />
                    <circle cx="315" cy="392" r="6" fill="#94A3B8" />

                    {/* Shield / Safety bubble card */}
                    <g className="animate-pulse">
                      <circle cx="390" cy="180" r="32" fill="#E0E7FF" />
                      <circle cx="390" cy="180" r="26" fill="#C7D2FE" />
                      <path d="M382 177 L388 183 L399 172" stroke="#4F46E5" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round" />
                    </g>
                  </svg>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* ABOUT SECTION (SEKILAS SYSTEM) */}
        <section className="py-20 bg-white">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 items-center">
              {/* Left Column: Description */}
              <div className="lg:col-span-7 text-left">
                <p className="text-sm font-bold text-indigo-600 uppercase tracking-widest mb-3">Tentang Platform</p>
                <h2 className="text-3xl sm:text-4xl font-extrabold text-slate-800 tracking-tight mb-6">
                  Mengubah Pemantauan Kesehatan Konvensional Menjadi Serba Cepat & Digital
                </h2>
                <p className="text-slate-600 leading-relaxed mb-6">
                  Platform **Generasi Sehat** lahir dari kebutuhan posyandu dan puskesmas untuk mendigitalisasi Buku Kesehatan Ibu & Anak (KIA) yang selama ini rentan rusak dan hilang. Sistem ini mengintegrasikan peran Bidan, Kader Posyandu, Dokter, dan Orang Tua dalam satu wadah terpadu.
                </p>
                <p className="text-slate-600 leading-relaxed mb-8">
                  Dengan antarmuka yang sangat responsif di perangkat mobile dan tablet, Bidan dapat memasukkan data secara cepat saat pemeriksaan di lapangan, sementara Ibu dapat langsung melihat grafik evaluasi kehamilan serta grafik tumbuh kembang anak di rumah.
                </p>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  {[
                    "Digitalisasi Buku KIA Terlengkap",
                    "Deteksi Stunting berbasis Standar WHO",
                    "Rekomendasi Menu MPASI & Nutrisi",
                    "Pemantauan Kehamilan Berisiko Tinggi",
                  ].map((item, idx) => (
                    <div key={idx} className="flex items-center gap-3">
                      <CheckCircle size={20} className="text-indigo-600 flex-shrink-0" />
                      <span className="text-sm font-semibold text-slate-700">{item}</span>
                    </div>
                  ))}
                </div>
              </div>

              {/* Right Column: Statistics Grid */}
              <div className="lg:col-span-5 bg-gradient-to-tr from-indigo-900 to-indigo-800 text-white rounded-3xl p-8 shadow-xl relative overflow-hidden">
                {/* Background glow decoration */}
                <div className="absolute top-0 right-0 w-32 h-32 bg-indigo-500/25 rounded-full filter blur-xl" />
                
                <h3 className="text-xl font-bold mb-8 text-left border-b border-indigo-700/80 pb-4">Kinerja & Cakupan Sistem</h3>
                
                <div className="space-y-6">
                  {[
                    { label: "Pencatatan Kehamilan", count: "100%", desc: "Data terpusat aman di database cloud" },
                    { label: "Akurasi Prediksi Stunting", count: "94.2%", desc: "Berdasarkan algoritma Machine Learning terbaru" },
                    { label: "Dukungan Kategori Usia Anak", count: "0-6 Tahun", desc: "Sesuai Standar SDIDTK Kementerian Kesehatan" }
                  ].map((stat, idx) => (
                    <div key={idx} className="flex items-start gap-4 text-left">
                      <div className="w-12 h-12 rounded-xl bg-indigo-700/60 flex items-center justify-center font-bold text-xl flex-shrink-0">
                        {idx + 1}
                      </div>
                      <div>
                        <div className="flex items-baseline gap-2">
                          <h4 className="text-lg font-bold">{stat.label}</h4>
                          <span className="text-indigo-300 font-extrabold text-sm ml-auto">{stat.count}</span>
                        </div>
                        <p className="text-xs text-indigo-200 mt-1">{stat.desc}</p>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* FITUR UTAMA SECTION */}
        <section className="py-20 bg-slate-50/50">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="text-center max-w-3xl mx-auto mb-16">
              <p className="text-sm font-bold text-indigo-600 uppercase tracking-widest mb-3">Fitur Cerdas</p>
              <h2 className="text-3xl sm:text-4xl font-extrabold text-slate-800 tracking-tight">
                Dirancang untuk Kebutuhan Ibu, Bayi, dan Layanan Kesehatan Desa
              </h2>
              <p className="text-sm sm:text-base text-slate-500 mt-4 leading-relaxed">
                Generasi Sehat menyajikan integrasi fitur canggih yang mempermudah pencatatan pelayanan kesehatan ibu hamil hingga tumbuh kembang balita secara terukur.
              </p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
              {[
                {
                  icon: <Activity className="text-indigo-600" size={24} />,
                  title: "Pemantauan Tumbuh Kembang",
                  desc: "Mencatat grafik antropometri (TB/U, BB/U, LK/U) dan status perkembangan motorik anak berdasarkan standar SDIDTK."
                },
                {
                  icon: <Heart className="text-rose-600" size={24} />,
                  title: "Kesehatan Ibu Hamil (ANC)",
                  desc: "Pencatatan rekapitulasi pemeriksaan kehamilan lengkap, grafik peningkatan BB ibu, hingga skrining preeklampsia."
                },
                {
                  icon: <TrendingUp className="text-blue-600" size={24} />,
                  title: "Deteksi Stunting Cerdas",
                  desc: "Analisis stunting terkomputerisasi menggunakan Machine Learning untuk memberikan peringatan dini status gizi buruk anak."
                },
                {
                  icon: <Calendar className="text-amber-600" size={24} />,
                  title: "Jadwal Imunisasi Lengkap",
                  desc: "Daftar panduan dosis imunisasi wajib anak dan posyandu desa terdekat dengan sistem pengingat digital otomatis."
                },
                {
                  icon: <BookOpen className="text-teal-600" size={24} />,
                  title: "Edukasi Ibu & MPASI",
                  desc: "Ratusan resep MPASI bergizi, panduan aturan porsi, pola asuh, trimester kehamilan, hingga kesehatan mental keluarga."
                },
                {
                  icon: <Shield className="text-indigo-600" size={24} />,
                  title: "Laporan & Manajemen Kader",
                  desc: "Rekap data kependudukan dan ekspor laporan KIA otomatis format Excel bagi bidan puskesmas secara instan."
                }
              ].map((fitur, idx) => (
                <div 
                  key={idx} 
                  className="bg-white rounded-2xl border border-slate-100 p-8 text-left hover:shadow-xl hover:-translate-y-1 transition-all duration-300 group"
                >
                  <div className="w-12 h-12 rounded-xl bg-slate-50 flex items-center justify-center mb-6 group-hover:bg-indigo-50 transition-colors">
                    {fitur.icon}
                  </div>
                  <h3 className="text-lg font-bold text-slate-800 mb-3">{fitur.title}</h3>
                  <p className="text-sm text-slate-500 leading-relaxed">{fitur.desc}</p>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* ALUR KERJA (HOW IT WORKS) */}
        <section className="py-20 bg-white relative">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="text-center max-w-3xl mx-auto mb-16">
              <p className="text-sm font-bold text-indigo-600 uppercase tracking-widest mb-3">Cara Kerja</p>
              <h2 className="text-3xl sm:text-4xl font-extrabold text-slate-800 tracking-tight">
                Bagaimana Generasi Sehat Membantu Anda?
              </h2>
            </div>

            <div className="relative">
              {/* Connector line for desktop */}
              <div className="hidden lg:block absolute top-1/2 left-4 right-4 h-0.5 bg-slate-100 -translate-y-1/2 z-0" />

              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8 relative z-10">
                {[
                  {
                    step: "01",
                    title: "Pendaftaran Akun",
                    desc: "Data kartu keluarga didaftarkan oleh Bidan atau Admin Desa melalui sistem administrasi kependudukan."
                  },
                  {
                    step: "02",
                    title: "Pencatatan Berkala",
                    desc: "Kader posyandu mengukur berat/tinggi badan anak dan mencatatnya ke dalam dashboard web Generasi Sehat."
                  },
                  {
                    step: "03",
                    title: "Pantau Real-Time",
                    desc: "Orang tua mengakses visualisasi tumbuh kembang anak, jadwal imunisasi, dan rekam medis digital via mobile."
                  },
                  {
                    step: "04",
                    title: "Analisis Medis & AI",
                    desc: "Sistem memberikan notifikasi tanda bahaya dan rekomendasi gizi berdasarkan analisis Machine Learning."
                  }
                ].map((alur, idx) => (
                  <div key={idx} className="bg-[#F8FAFC] rounded-2xl p-6 text-left border border-slate-100 hover:bg-white hover:shadow-lg transition-all duration-300">
                    <span className="text-4xl font-black text-indigo-600/20 block mb-4">{alur.step}</span>
                    <h4 className="text-base font-bold text-slate-800 mb-2">{alur.title}</h4>
                    <p className="text-xs sm:text-sm text-slate-500 leading-relaxed">{alur.desc}</p>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </section>

        {/* EDUKASI PILIHAN (FEATURED EDUCATION) */}
        <section className="py-20 bg-slate-50/50">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="flex flex-col sm:flex-row sm:items-end justify-between mb-12 gap-4">
              <div className="text-left">
                <p className="text-sm font-bold text-indigo-600 uppercase tracking-widest mb-3">Edukasi Pilihan</p>
                <h2 className="text-3xl font-extrabold text-slate-800 tracking-tight">Bacaan Kesehatan Terbaru</h2>
              </div>
              <Link 
                to="/edukasi-publik/informasi-umum"
                className="inline-flex items-center gap-1.5 text-sm font-bold text-indigo-600 hover:text-indigo-700 hover:underline text-left"
              >
                Lihat Semua Edukasi
                <ArrowRight size={16} />
              </Link>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
              {[
                {
                  tag: "Nutrisi Bayi",
                  title: "Panduan Memberikan MPASI Sesuai Usia",
                  desc: "Pelajari kapan bayi siap menerima makanan pendamping ASI, tekstur makanan yang sesuai, serta frekuensi pemberiannya.",
                  path: "mpasi"
                },
                {
                  tag: "Kesehatan Ibu",
                  title: "Menjaga Kesehatan Mental di Masa Kehamilan",
                  desc: "Kesehatan emosional ibu hamil sangat memengaruhi perkembangan janin. Temukan cara rileksasi dan konseling yang tepat.",
                  path: "kesehatan-mental"
                },
                {
                  tag: "Perawatan Balita",
                  title: "Pentingnya Imunisasi Dasar Lengkap",
                  desc: "Imunisasi adalah pertahanan pertama anak dari penyakit menular berbahaya. Berikut tabel jadwal dan efek pasca-imunisasi.",
                  path: "perawatan-anak"
                }
              ].map((artikel, idx) => (
                <article key={idx} className="bg-white rounded-2xl border border-slate-100 overflow-hidden shadow-sm hover:shadow-md transition-shadow text-left flex flex-col">
                  {/* Decorative Header Block */}
                  <div className="h-4 bg-gradient-to-r from-indigo-600 to-indigo-400" />
                  <div className="p-6 flex-grow flex flex-col justify-between">
                    <div>
                      <span className="inline-block px-2.5 py-1 rounded bg-indigo-50 text-indigo-700 text-xs font-bold mb-4">
                        {artikel.tag}
                      </span>
                      <h3 className="text-lg font-bold text-slate-800 mb-3 hover:text-indigo-600 cursor-pointer">
                        <Link to={`/edukasi-publik/${artikel.path}`}>{artikel.title}</Link>
                      </h3>
                      <p className="text-sm text-slate-500 line-clamp-3 leading-relaxed mb-6">{artikel.desc}</p>
                    </div>
                    
                    <Link
                      to={`/edukasi-publik/${artikel.path}`}
                      className="inline-flex items-center gap-1 text-sm font-bold text-indigo-600 hover:text-indigo-700 mt-auto"
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

        {/* DOWNLOAD APP CTA */}
        <section className="py-16 md:py-24 bg-white relative">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="bg-gradient-to-tr from-indigo-900 via-indigo-800 to-slate-900 rounded-[32px] px-8 py-12 md:p-16 text-center md:text-left relative overflow-hidden shadow-2xl">
              {/* Decorative graphic backgrounds */}
              <div className="absolute -bottom-24 -right-24 w-80 h-80 bg-indigo-600/20 rounded-full filter blur-3xl" />
              <div className="absolute -top-24 -left-24 w-80 h-80 bg-indigo-500/10 rounded-full filter blur-3xl" />

              <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-center relative z-10">
                <div className="lg:col-span-8">
                  <h2 className="text-3xl md:text-4xl font-extrabold text-white tracking-tight mb-4">
                    Unduh Aplikasi Mobile Generasi Sehat Sekarang!
                  </h2>
                  <p className="text-base text-indigo-200 leading-relaxed max-w-2xl mb-8">
                    Pantau grafik tumbuh kembang anak Anda, jadwal imunisasi posyandu, serta konsultasi data kesehatan Anda dalam genggaman. Unduh langsung untuk perangkat Android.
                  </p>

                  <div className="flex flex-col sm:flex-row items-center gap-4 justify-center md:justify-start">
                    <button
                      onClick={handleDownload}
                      className="w-full sm:w-auto px-8 py-4 bg-white hover:bg-slate-50 text-indigo-900 font-bold rounded-2xl shadow-lg transition-all flex items-center justify-center gap-2 group"
                    >
                      <Download size={20} className="text-indigo-600" />
                      Unduh Berkas APK (Android)
                    </button>
                    <span className="text-xs text-indigo-300 font-medium sm:text-left">
                      *Kompatibel dengan Android OS 8.0 ke atas
                    </span>
                  </div>
                </div>

                <div className="lg:col-span-4 flex justify-center lg:justify-end">
                  <div className="relative w-36 h-36 md:w-48 md:h-48 bg-indigo-700/40 rounded-full flex items-center justify-center border-4 border-indigo-400/25">
                    <Smartphone size={64} className="text-white animate-pulse" />
                    <div className="absolute -top-2 -right-2 bg-rose-500 text-white font-bold text-xs px-2.5 py-1 rounded-full animate-bounce shadow-md">
                      Baru!
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
