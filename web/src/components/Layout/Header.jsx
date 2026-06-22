// src/components/Layout/Header.jsx
import { useState, useRef, useEffect } from "react";
import { useLocation } from "react-router-dom";
import { LogOut, ChevronDown, User, PanelLeftOpen, PanelLeftClose, Mail, Shield, Edit2, Save, Eye, EyeOff, X } from "lucide-react";
import { getCurrentUser, logout } from "../../services/auth";
import api from "../../services/api";
import Swal from "sweetalert2";

// ── headerByPath, formatRole, InfoRow, extractErrMsg, ProfilModal ──
// (semua tidak berubah, copy persis dari kode lama)

const Header = ({ onToggleSidebar, isSidebarOpen }) => {
  const user = getCurrentUser();
  const location = useLocation();
  const pageHeader = headerByPath(location.pathname);
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const [showProfil, setShowProfil] = useState(false);
  const dropdownRef = useRef(null);

  useEffect(() => {
    const handleClickOutside = (e) => {
      if (dropdownRef.current && !dropdownRef.current.contains(e.target)) {
        setIsDropdownOpen(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  const handleLogout = () => {
    logout();
    window.location.href = "/login";
  };

  return (
    <>
      {/* ── Floating toggle saat sidebar TERTUTUP ── */}
      {!isSidebarOpen && (
        <button
          onClick={onToggleSidebar}
          className="fixed left-0 top-1/2 -translate-y-1/2 z-[9999]
                     w-9 h-9 bg-blue-600 hover:bg-blue-700
                     flex items-center justify-center
                     rounded-r-xl shadow-lg transition-colors"
          aria-label="Buka sidebar"
          title="Buka sidebar"
        >
          <PanelLeftOpen size={18} className="text-white" />
        </button>
      )}

      {/* ── Header bar ── */}
      <header className="px-4 py-3 border-b border-gray-100 bg-white relative z-50">
        <div className="bg-[#185FA5] text-white rounded-2xl px-4 py-3 flex items-center gap-3">

          {/* Tombol toggle sidebar (hanya muncul saat sidebar TERBUKA) */}
          {isSidebarOpen && (
            <button
              onClick={onToggleSidebar}
              className="w-9 h-9 rounded-xl bg-white/15 hover:bg-white/25
                         border border-white/20 flex items-center justify-center
                         flex-shrink-0 transition-colors"
              aria-label="Tutup sidebar"
              title="Tutup sidebar"
            >
              <PanelLeftClose size={18} className="text-white" />
            </button>
          )}

          {/* Judul halaman */}
          <div className="flex-1 min-w-0">
            <h1 className="text-lg font-semibold leading-tight truncate">
              {pageHeader.title}
            </h1>
            <p className="text-white/70 text-xs mt-0.5 leading-relaxed whitespace-pre-line line-clamp-2">
              {pageHeader.subtitle}
            </p>
            {pageHeader.note && (
              <p className="text-white/60 text-[11px] mt-0.5 leading-relaxed">
                {pageHeader.note}
              </p>
            )}
          </div>

          {/* Dropdown user */}
          <div className="relative flex-shrink-0" ref={dropdownRef}>
            <button
              onClick={() => setIsDropdownOpen(!isDropdownOpen)}
              className={`flex items-center gap-2 py-1.5 pl-1.5 pr-3 rounded-full
                          border transition-colors
                          ${isDropdownOpen
                            ? "bg-white/20 border-white/30"
                            : "border-white/20 hover:bg-white/15"}`}
            >
              <div className="w-8 h-8 rounded-full bg-white/20 flex items-center justify-center
                              text-white font-semibold text-sm flex-shrink-0">
                {user?.name?.charAt(0)?.toUpperCase() || "U"}
              </div>
              <div className="text-left hidden sm:block">
                <p className="text-[11px] font-semibold text-white leading-none">
                  {user?.name || "Pengguna"}
                </p>
                <p className="text-[10px] text-white/65 mt-0.5">
                  {formatRole(user?.role)}
                </p>
              </div>
              <ChevronDown
                size={13}
                className={`text-white/70 transition-transform duration-200
                            ${isDropdownOpen ? "rotate-180" : ""}`}
              />
            </button>

            {isDropdownOpen && (
              <div className="absolute right-0 mt-2 w-52 bg-white rounded-2xl
                              shadow-xl border border-slate-100 py-2 z-50
                              animate-in fade-in zoom-in duration-150 origin-top-right">
                <div className="px-4 py-2 border-b border-slate-100 mb-1">
                  <p className="text-[11px] text-slate-400">Masuk sebagai</p>
                  <p className="text-sm font-semibold text-slate-800 truncate">
                    {user?.email || "-"}
                  </p>
                </div>
                <button
                  onClick={() => { setIsDropdownOpen(false); setShowProfil(true); }}
                  className="w-full flex items-center gap-3 px-4 py-2.5 text-sm
                             text-slate-600 hover:bg-slate-50 transition-colors"
                >
                  <User size={16} className="text-slate-400" />
                  Profil Saya
                </button>
                <button
                  onClick={handleLogout}
                  className="w-full flex items-center gap-3 px-4 py-2.5 text-sm
                             text-red-500 hover:bg-red-50 transition-colors"
                >
                  <LogOut size={16} />
                  <span className="font-medium">Keluar</span>
                </button>
              </div>
            )}
          </div>
        </div>
      </header>

      {showProfil && <ProfilModal onClose={() => setShowProfil(false)} />}
    </>
  );
};

export default Header;