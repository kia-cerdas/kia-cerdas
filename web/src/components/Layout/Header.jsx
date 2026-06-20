// src/components/Layout/Header.jsx
import { useState, useRef, useEffect } from "react";
import { useLocation } from "react-router-dom";
import { LogOut, ChevronDown, User, Menu, X } from "lucide-react";
import { getCurrentUser, logout } from "../../services/auth";

const headerByPath = (pathname) => {
  if (pathname === "/dashboard" || pathname === "/dashboard/admin") {
    return {
      title: "Ringkasan Desa",
      subtitle: "Pantau kesehatan ibu dan anak secara menyeluruh di wilayah desa Anda.",
      variant: "hero",
    };
  }

  if (pathname === "/superadmin/dashboard") {
    return {
      title: "Dashboard ",
      subtitle: "Pantau ringkasan wilayah, daftar desa, dan aktivitas operasional secara cepat.",
      variant: "hero",
    };
  }

  if (pathname.startsWith("/superadmin/kelola-user-per-desa") || pathname.startsWith("/superadmin/user-desa")) {
    return {
      title: "Kelola User Per Desa",
      subtitle: "Atur role, reset password, dan nonaktifkan user biasa di tiap desa.",
      variant: "hero",
    };
  }

  if (pathname.startsWith("/superadmin/kelola-user") || pathname.startsWith("/superadmin/users")) {
    return {
      title: "Kelola bidan, kader, dan admin desa",
      subtitle: "Tambah bidan, kader, dan admin desa, lalu reset password atau nonaktifkan akun khusus.",
      variant: "hero",
    };
  }

  if (pathname.startsWith("/superadmin/kelola-desa") || pathname.startsWith("/superadmin/desa")) {
    return {
      title: "Kelola Desa",
      subtitle: "Atur data desa, status aktif, dan informasi wilayah secara terpisah dari dashboard.",
      variant: "hero",
    };
  }

  if (pathname.startsWith("/data-ibu")) {
    return {
      title: "Data Ibu",
      subtitle: "Kelola data ibu hamil, nifas, dan catatan pelayanan secara terpadu.",
      variant: "hero",
    };
  }

  if (pathname.startsWith("/daftar-anak") || pathname.startsWith("/data-anak")) {
    return {
      title: "Data Anak",
      subtitle: "Pantau pertumbuhan, pelayanan, dan riwayat kesehatan anak.",
      variant: "hero",
    };
  }

  if (pathname.startsWith("/kependudukan")) {
    return {
      title: "Manajemen Kartu Keluarga",
      subtitle: "Kelola data keluarga dan anggota penduduk di wilayah desa.",
      variant: "hero",
    };
  }

  if (pathname === "/monitoring") {
    return {
      title: "Monitoring Kesehatan",
      subtitle: "Lihat rekap wilayah, risiko tinggi, dan prioritas kunjungan lapangan.",
      variant: "hero",
    };
  }

  if (pathname === "/laporan") {
    return {
      title: "Laporan",
      subtitle: "Tinjau ringkasan program KIA dan capaian indikator layanan.",
      variant: "hero",
    };
  }

  if (pathname.startsWith("/dashboard/admin/tenaga-kesehatan")) {
    return {
      title: "Manajemen Bidan & Kader",
      subtitle: "Tetapkan penduduk sebagai bidan/kader, kelola profil, aktif-nonaktifkan status, dan buat akun login.",
      note: "Catatan: pilihan penduduk diambil dari dropdown penduduk eligible agar tidak perlu input ID manual.",
      variant: "hero",
    };
  }

  if (pathname.startsWith("/superadmin/manajemen-keluarga")) {
    return {
      title: "Manajemen Profil Keluarga",
      subtitle: "Kelola data kartu keluarga dan detail anggota keluarga.",
      variant: "hero",
    };
  }

  if (pathname.startsWith("/superadmin/akun-keluarga")) {
    return {
      title: "Pembuatan Akun Keluarga",
      subtitle: "Buat akun login keluarga secara langsung dari data kependudukan.",
      variant: "hero",
    };
  }

  if (pathname.startsWith("/dashboard/admin/jadwal-layanan")) {
    return {
      title: "Jadwal Layanan",
      subtitle: "Kelola daftar posyandu sebagai referensi jadwal layanan kesehatan.",
      variant: "hero",
    };
  }

  if (pathname.startsWith("/dashboard/admin/informasi-umum")) {
    return {
      title: "CRUD Edukasi",
      subtitle: "Kelola konten edukasi yang ditampilkan di aplikasi mobile.",
      variant: "hero",
    };
  }

  return {
    title: "Generasi Sehat",
    subtitle: "Sistem layanan kesehatan ibu dan anak untuk wilayah desa.",
    variant: "default",
  };
};

const formatRole = (role) => {
  const normalized = (role || "").toString().trim().toLowerCase();
  if (normalized === "superadmin") return "Superadmin";
  if (normalized === "admin") return "Admin";
  if (normalized === "bidan") return "Bidan";
  return "Petugas Medis";
};

const Header = ({ onToggleSidebar, isSidebarOpen }) => {
  const user = getCurrentUser();
  const location = useLocation();
  const pageHeader = headerByPath(location.pathname);
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const dropdownRef = useRef(null);

  // Menutup dropdown saat klik di luar area profil
  useEffect(() => {
    const handleClickOutside = (event) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target)) {
        setIsDropdownOpen(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  const handleLogout = () => {
    logout();
    window.location.href = "/login"; // Redirect ke login setelah logout
  };

  return (
    <header className="px-4 md:px-6 py-4 border-b border-gray-100 bg-white relative z-50">
      <div className="bg-[#185FA5] md:bg-gradient-to-r md:from-blue-700 md:via-cyan-600 md:to-teal-600 text-white rounded-2xl p-4 md:p-5 shadow-lg flex items-start justify-between gap-3">
        {/* Container untuk hamburger dengan width tetap agar tidak jump */}
        <div className="w-9 h-9 flex-shrink-0">
          {/* Hamburger Menu - Saat sidebar tertutup */}
          {!isSidebarOpen && (
            <button
              onClick={onToggleSidebar}
              className="flex items-center justify-center w-9 h-9 rounded-lg hover:bg-white/10 transition-colors"
              aria-label="Open Menu"
              title="Buka Menu"
            >
              <Menu size={20} className="text-white" />
            </button>
          )}
          {/* Close Button - Saat sidebar terbuka (mobile) */}
          {isSidebarOpen && (
            <button
              onClick={onToggleSidebar}
              className="flex items-center justify-center w-9 h-9 rounded-lg hover:bg-white/10 transition-colors md:hidden"
              aria-label="Close Menu"
              title="Tutup Menu"
            >
              <X size={20} className="text-white" />
            </button>
          )}
        </div>

        <div className="min-w-0 flex-1">
          <h1 className="text-xl md:text-2xl font-bold leading-tight">{pageHeader.title}</h1>
          <p className="text-cyan-100 mt-1.5 text-xs md:text-sm leading-relaxed">{pageHeader.subtitle}</p>
          {pageHeader.note && (
            <p className="text-cyan-100 mt-1.5 text-[11px] md:text-xs leading-relaxed">{pageHeader.note}</p>
          )}
        </div>

        <div className="relative flex-shrink-0" ref={dropdownRef}>
          <button
            onClick={() => setIsDropdownOpen(!isDropdownOpen)}
            className={`flex items-center gap-2.5 p-1.5 pr-2.5 rounded-2xl transition-all duration-200 border ${
              isDropdownOpen ? "bg-white/20 border-white/30" : "border-white/20 hover:bg-white/15"
            }`}
          >
            <div className="w-9 h-9 rounded-full bg-[#185FA5] flex items-center justify-center text-white flex-shrink-0">
              <User size={18} className="text-white" />
            </div>

            <div className="text-left hidden sm:block">
              <p className="text-[11px] font-bold text-white leading-none">{user?.name || "Bidan Desa"}</p>
              <p className="text-[10px] text-cyan-100 mt-0.5">{formatRole(user?.role)}</p>
            </div>

            <ChevronDown
              size={14}
              className={`text-cyan-100 transition-transform duration-200 ${isDropdownOpen ? "rotate-180" : ""}`}
            />
          </button>

          {isDropdownOpen && (
            <div className="absolute right-0 mt-2 w-52 bg-white rounded-2xl shadow-xl border border-slate-100 py-2 animate-in fade-in zoom-in duration-200 origin-top-right">
              <div className="px-4 py-2 border-b border-slate-50 mb-1">
                <p className="text-xs text-slate-400">Masuk sebagai</p>
                <p className="text-sm font-semibold text-slate-800 truncate">{user?.email || "admin@kia.com"}</p>
              </div>

              <button className="w-full flex items-center gap-3 px-4 py-2.5 text-sm text-slate-600 hover:bg-slate-50 transition-colors">
                <User size={18} className="text-slate-400" />
                <span>Profil Saya</span>
              </button>

              <button
                onClick={handleLogout}
                className="w-full flex items-center gap-3 px-4 py-2.5 text-sm text-red-500 hover:bg-red-50 transition-colors"
              >
                <LogOut size={18} />
                <span className="font-medium">Keluar</span>
              </button>
            </div>
          )}
        </div>
      </div>
    </header>
  );
};

export default Header;