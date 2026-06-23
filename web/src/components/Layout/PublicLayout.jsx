import React, { useState, useEffect, useRef } from "react";
import { Link, useLocation, useNavigate } from "react-router-dom";
import { Menu, X, ChevronDown, Download, BookOpen, LogIn } from "lucide-react";
import { logout } from "../../services/auth";
import logo from "./LOGO.png";

export const PUBLIC_EDUKASI_MENU = [
  { label: "Informasi Umum", path: "informasi-umum", resource: "edukasi-informasi-umum" },
  { label: "Edukasi Trimester", path: "trimester", resource: "edukasi-trimester" },
  { label: "Tanda Melahirkan", path: "tanda-melahirkan", resource: "edukasi-tanda-melahirkan" },
  { label: "Edukasi IMD", path: "imd", resource: "edukasi-imd" },
  { label: "Setelah Melahirkan", path: "setelah-melahirkan", resource: "edukasi-setelah-melahirkan" },
  { label: "Menyusui ASI", path: "menyusui-asi", resource: "edukasi-menyusui-asi" },
  { label: "Pola Asuh", path: "pola-asuh", resource: "edukasi-pola-asuh" },
  { label: "Kesehatan Mental", path: "kesehatan-mental", resource: "edukasi-kesehatan-mental" },
  { label: "Perawatan Anak", path: "perawatan-anak", resource: "edukasi-perawatan-anak" },
  { 
    label: "Edukasi MPASI", 
    path: "mpasi", 
    resource: "edukasi-mpasi",
    submodules: [
      { label: "Panduan MPASI", path: "mpasi", resource: "edukasi-mpasi" },
      { label: "Aturan Porsi", path: "mpasi-aturan-porsi", resource: "edukasi-mpasi-aturan-porsi" },
      { label: "Jadwal Harian", path: "mpasi-jadwal-harian", resource: "edukasi-mpasi-jadwal-harian" },
      { label: "Resep MPASI", path: "mpasi-resep", resource: "edukasi-mpasi-resep" }
    ]
  }
];

export default function PublicLayout({ children }) {
  const [isOpen, setIsOpen] = useState(false);
  const [isEdukasiOpen, setIsEdukasiOpen] = useState(false);
  const [scrolled, setScrolled] = useState(false);
  const dropdownRef = useRef(null);
  const location = useLocation();
  const navigate = useNavigate();

  // Handle scroll effect for navbar styling
  useEffect(() => {
    const handleScroll = () => {
      if (window.scrollY > 20) {
        setScrolled(true);
      } else {
        setScrolled(false);
      }
    };
    window.addEventListener("scroll", handleScroll);
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  const handleLogout = () => {
    logout();
    window.location.href = "/"; // Redirect ke halaman utama setelah logout
  };

  // Close dropdown on click outside
  useEffect(() => {
    const handleClickOutside = (event) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target)) {
        setIsEdukasiOpen(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  // Close mobile menu when route changes
  useEffect(() => {
    setIsOpen(false);
    setIsEdukasiOpen(false);
  }, [location.pathname]);

  const handleDownload = () => {
    // Arahkan ke link download APK atau Buku KIA (Placeholder yang valid)
    window.open("https://github.com/kia-cerdas/kia-cerdas/releases/download/v1.0.0/generasi-sehat-app.apk", "_blank");
  };

  return (
    <div className="min-h-screen flex flex-col bg-slate-50/50 font-['Outfit',_sans-serif]">
      {/* Header / Navbar */}
      <header
        className={`fixed top-0 left-0 w-full z-50 transition-all duration-300 ${
          scrolled
            ? "bg-white/90 backdrop-blur-md shadow-md py-3 border-b border-slate-100"
            : "bg-transparent py-5"
        }`}
      >
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between">
            {/* Logo */}
            <Link to="/" className="flex items-center group">
              <div className="h-12 px-3 py-1.5 rounded-xl bg-white flex items-center justify-center border border-slate-100 shadow-md group-hover:scale-105 transition-transform flex-shrink-0">
                <img src={logo} alt="Generasi Sehat Logo" className="h-8 w-auto object-contain" />
              </div>
            </Link>

            {/* Desktop Menu */}
            <nav className="hidden md:flex items-center gap-8">
              <Link
                to="/"
                className={`text-sm font-medium transition-colors hover:text-primary ${
                  location.pathname === "/" ? "text-primary font-semibold" : "text-slate-600"
                }`}
              >
                Beranda
              </Link>

              {/* Edukasi Dropdown */}
              <div className="relative" ref={dropdownRef}>
                <button
                  onClick={() => setIsEdukasiOpen(!isEdukasiOpen)}
                  className={`flex items-center gap-1.5 text-sm font-medium transition-colors hover:text-primary ${
                    location.pathname.startsWith("/edukasi-publik")
                      ? "text-primary font-semibold"
                      : "text-slate-600"
                  }`}
                >
                  Edukasi
                  <ChevronDown
                    size={14}
                    className={`transition-transform duration-200 ${
                      isEdukasiOpen ? "rotate-180 text-primary" : "text-slate-400"
                    }`}
                  />
                </button>

                {/* Dropdown Menu */}
                {isEdukasiOpen && (
                  <div className="absolute left-0 mt-3 w-80 bg-white rounded-2xl shadow-xl border border-slate-100 py-3 grid grid-cols-1 gap-1 animate-in fade-in slide-in-from-top-3 duration-200 max-h-[480px] overflow-y-auto">
                    {PUBLIC_EDUKASI_MENU.map((item) => {
                      if (item.submodules) {
                        return (
                          <div key={item.path} className="border-t border-slate-50 pt-1 mt-1">
                            <div className="px-4 py-1 text-xs font-semibold text-slate-500 bg-slate-50">
                              {item.label}
                            </div>
                            {item.submodules.map((sub) => (
                              <Link
                                key={sub.path}
                                to={`/edukasi-publik/${sub.path}`}
                                className="flex items-center gap-2.5 px-6 py-2 text-sm text-slate-600 hover:bg-primary-50 hover:text-primary transition-colors"
                              >
                                <div className="w-1.5 h-1.5 rounded-full bg-slate-300 group-hover:bg-primary-500" />
                                <span>{sub.label}</span>
                              </Link>
                            ))}
                          </div>
                        );
                      }
                      return (
                        <Link
                          key={item.path}
                          to={`/edukasi-publik/${item.path}`}
                          className="flex items-center gap-2.5 px-4 py-2 text-sm text-slate-700 hover:bg-primary-50 hover:text-primary transition-colors"
                        >
                          <BookOpen size={16} className="text-slate-400" />
                          <span>{item.label}</span>
                        </Link>
                      );
                    })}
                  </div>
                )}
              </div>
            </nav>

            {/* Desktop Action Buttons */}
            <div className="hidden md:flex items-center gap-3">
              <button
                onClick={handleDownload}
                className="flex items-center gap-1.5 px-4 py-2 border border-slate-200 rounded-xl text-slate-700 text-sm font-medium hover:bg-slate-50 transition-colors active:scale-95 duration-150"
              >
                <Download size={16} />
                Unduh App
              </button>

              <Link
                to="/login"
                className="flex items-center gap-1.5 px-5 py-2 bg-primary hover:bg-primary-600 text-white text-sm font-semibold rounded-xl transition-all shadow-md shadow-primary-100 hover:shadow-lg active:scale-95 duration-150"
              >
                <LogIn size={16} />
                Login
              </Link>
            </div>

            {/* Mobile/Tablet Menu Button */}
            <div className="md:hidden flex items-center gap-2">
              <button
                onClick={handleDownload}
                className="p-2 border border-slate-200 rounded-xl text-slate-600 hover:bg-slate-50"
                title="Unduh Aplikasi"
              >
                <Download size={18} />
              </button>
              <button
                onClick={() => setIsOpen(!isOpen)}
                className="p-2 rounded-xl text-slate-600 hover:bg-slate-50"
              >
                {isOpen ? <X size={24} /> : <Menu size={24} />}
              </button>
            </div>
          </div>
        </div>

        {/* Mobile/Tablet Drawer */}
        {isOpen && (
          <div className="md:hidden bg-white border-t border-slate-100 py-4 px-4 shadow-lg flex flex-col gap-3 animate-in slide-in-from-top duration-250">
            <Link
              to="/"
              className="px-3 py-2 text-base font-semibold text-slate-700 hover:bg-slate-50 hover:text-primary rounded-xl transition-colors"
            >
              Beranda
            </Link>

            {/* Edukasi Expandable Menu */}
            <div className="border-t border-slate-50 pt-2">
              <button
                onClick={() => setIsEdukasiOpen(!isEdukasiOpen)}
                className="w-full flex items-center justify-between px-3 py-2 text-base font-semibold text-slate-700 hover:bg-slate-50 hover:text-primary rounded-xl transition-colors"
              >
                <span>Edukasi</span>
                <ChevronDown
                  size={18}
                  className={`transition-transform duration-200 ${isEdukasiOpen ? "rotate-180" : ""}`}
                />
              </button>

              {isEdukasiOpen && (
                <div className="pl-4 pr-2 py-1 flex flex-col gap-1 max-h-[300px] overflow-y-auto">
                  {PUBLIC_EDUKASI_MENU.map((item) => {
                    if (item.submodules) {
                      return (
                        <div key={item.path} className="flex flex-col gap-1 mt-1 border-l-2 border-primary-100 pl-2">
                          <span className="px-2 py-1 text-xs font-bold text-slate-400 uppercase">
                            {item.label}
                          </span>
                          {item.submodules.map((sub) => (
                            <Link
                              key={sub.path}
                              to={`/edukasi-publik/${sub.path}`}
                              className="px-4 py-1.5 text-sm text-slate-600 hover:text-primary rounded-lg hover:bg-primary-50/50"
                            >
                              {sub.label}
                            </Link>
                          ))}
                        </div>
                      );
                    }
                    return (
                      <Link
                        key={item.path}
                        to={`/edukasi-publik/${item.path}`}
                        className="px-3 py-1.5 text-sm text-slate-600 hover:text-primary rounded-lg hover:bg-primary-50/50 flex items-center gap-2"
                      >
                        <div className="w-1.5 h-1.5 rounded-full bg-slate-300" />
                        {item.label}
                      </Link>
                    );
                  })}
                </div>
              )}
            </div>

            {/* Mobile login button */}
            <div className="border-t border-slate-100 pt-3 mt-2">
              <Link
                to="/login"
                className="w-full py-2.5 bg-primary hover:bg-primary-600 text-white font-semibold rounded-xl text-center shadow-md flex items-center justify-center gap-1.5"
              >
                <LogIn size={18} />
                Login
              </Link>
            </div>
          </div>
        )}
      </header>

      {/* Main Content Area */}
      <main className="flex-grow pt-24">
        {children}
      </main>

      {/* Footer */}
      <footer className="bg-slate-900 text-slate-400 pt-16 pb-8 border-t border-slate-800">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-10 mb-12">
            {/* Col 1: Brand Info */}
            <div className="flex flex-col gap-4">
              <div className="flex items-center">
                <div className="h-10 px-3 py-1.5 rounded-lg bg-white flex items-center justify-center border border-slate-100 shadow-sm flex-shrink-0">
                  <img src={logo} alt="Generasi Sehat Logo" className="h-7 w-auto object-contain" />
                </div>
              </div>
              <p className="text-sm text-slate-400 leading-relaxed">
                Platform digital terintegrasi untuk pemantauan kesehatan ibu hamil dan tumbuh kembang anak berbasis Web, Mobile, dan Machine Learning.
              </p>
              <p className="text-xs text-slate-500">
                © {new Date().getFullYear()} Generasi Sehat. Hak Cipta Dilindungi.
              </p>
            </div>

            {/* Col 2: Fitur Utama */}
            <div>
              <h4 className="text-white font-semibold text-sm uppercase tracking-wider mb-4">Fitur Utama</h4>
              <ul className="flex flex-col gap-2.5 text-sm">
                <li><span className="hover:text-white transition-colors cursor-pointer">Pemantauan SDIDTK</span></li>
                <li><span className="hover:text-white transition-colors cursor-pointer">Deteksi Stunting AI</span></li>
                <li><span className="hover:text-white transition-colors cursor-pointer">Pemeriksaan Kehamilan</span></li>
                <li><span className="hover:text-white transition-colors cursor-pointer">Jadwal Imunisasi & Vaksin</span></li>
                <li><span className="hover:text-white transition-colors cursor-pointer">Laporan Kesehatan Digital</span></li>
              </ul>
            </div>

            {/* Col 3: Link Cepat */}
            <div>
              <h4 className="text-white font-semibold text-sm uppercase tracking-wider mb-4">Edukasi Populer</h4>
              <ul className="flex flex-col gap-2.5 text-sm">
                <li><Link to="/edukasi-publik/mpasi" className="hover:text-white transition-colors">Panduan MPASI Bayi</Link></li>
                <li><Link to="/edukasi-publik/menyusui-asi" className="hover:text-white transition-colors">Teknik Menyusui ASI</Link></li>
                <li><Link to="/edukasi-publik/trimester" className="hover:text-white transition-colors">Kesehatan Trimester Ibu</Link></li>
                <li><Link to="/edukasi-publik/pola-asuh" className="hover:text-white transition-colors">Pola Asuh Positif</Link></li>
                <li><Link to="/edukasi-publik/kesehatan-mental" className="hover:text-white transition-colors">Kesehatan Mental Keluarga</Link></li>
              </ul>
            </div>

            {/* Col 4: Hubungi Kami */}
            <div>
              <h4 className="text-white font-semibold text-sm uppercase tracking-wider mb-4">Hubungi Kami</h4>
              <p className="text-sm text-slate-400 leading-relaxed mb-3">
                Layanan KIA Generasi Sehat bermitra dengan Dinas Kesehatan Kabupaten dan Puskesmas Desa di seluruh Indonesia.
              </p>
              <div className="text-xs text-slate-500 flex flex-col gap-1">
                <p>Surel: support@generasisehat.id</p>
                <p>Telepon: (021) 1234-5678</p>
                <p>Jam Layanan: Senin - Jumat, 08.00 - 16.00 WIB</p>
              </div>
            </div>
          </div>

          <div className="border-t border-slate-800 pt-8 flex flex-col sm:flex-row items-center justify-between gap-4">
            <p className="text-xs text-slate-500">
              Dikembangkan oleh Tim Penelitian Pengabdian Masyarakat & PA Mahasiswa Kesehatan.
            </p>
            <div className="flex items-center gap-4 text-xs">
              <span className="hover:text-white transition-colors cursor-pointer">Kebijakan Privasi</span>
              <span className="hover:text-white transition-colors cursor-pointer">Syarat & Ketentuan</span>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}
