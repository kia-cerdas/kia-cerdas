// src/components/Layout/Header.jsx
import { useState, useRef, useEffect } from "react";
import { useLocation } from "react-router-dom";
import { LogOut, ChevronDown, User, Menu, X, Mail, Shield, Edit2, Save, Eye, EyeOff } from "lucide-react";
import { getCurrentUser, logout } from "../../services/auth";
import api from "../../services/api";
import Swal from "sweetalert2";

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
      title: "Dashboard Superadmin",
      subtitle: "1. Lihat ringkasan wilayah dan daftar desa.\n2. Pantau aktivitas operasional terkini.\n3. Buka menu sidebar untuk mengelola data spesifik.",
      variant: "hero",
    };
  }

  if (pathname.startsWith("/superadmin/audit-trail")) {
    return {
      title: "Audit Trail",
      subtitle: "1. Lihat riwayat aktivitas dan perubahan data di sistem.\n2. Gunakan filter untuk mempersempit berdasarkan aksi, pengguna, atau tanggal.\n3. Klik baris untuk melihat detail kejadian.",
      variant: "hero",
    };
  }

  if (pathname.startsWith("/superadmin/kelola-user") || pathname.startsWith("/superadmin/users")) {
    return {
      title: "Kelola User",
      subtitle: "1. Cari penduduk pada tabel, lalu klik 'Buat Akun' untuk penduduk yang belum punya akun.\n2. Isi data akun (nama, email, password, role) lalu simpan.\n3. Untuk akun yang sudah ada, gunakan 'Reset Password' atau 'Aktifkan/Nonaktifkan'.",
      variant: "hero",
    };
  }

  if (pathname.startsWith("/superadmin/kelola-nakes")) {
    return {
      title: "Kelola Nakes",
      subtitle: "1. Cari penduduk pada tabel, lalu klik 'Assign Role' untuk yang belum diassign.\n2. Pilih jenis tenaga (Bidan/Kader/Admin Desa), isi data lengkap, lalu simpan.\n3. Untuk akun yang sudah ada, gunakan 'Reset Password' atau 'Aktifkan/Nonaktifkan'.",
      variant: "hero",
    };
  }

  if (pathname.startsWith("/superadmin/kelola-desa") || pathname.startsWith("/superadmin/desa")) {
    return {
      title: "Kelola Desa",
      subtitle: "1. Klik 'Tambah Desa' untuk menambah desa baru.\n2. Isi nama dan informasi desa.\n3. Klik desa untuk mengubah data atau mengatur status aktif.",
      variant: "hero",
    };
  }

  if (pathname.startsWith("/superadmin/kelola-penduduk")) {
    return {
      title: "Kelola Penduduk",
      subtitle: "1. Cari penduduk lewat NIK, nama, atau kode keluarga.\n2. Klik '+ Tambah Penduduk' lalu isi 4 bagian form (Data Diri, Alamat, Pekerjaan, Keluarga) dan klik Simpan.\n3. Gunakan ikon pensil untuk mengubah atau tong sampah untuk menghapus data.",
      variant: "hero",
    };
  }

  if (pathname.startsWith("/superadmin/kelola-wilayah")) {
    return {
      title: "Kelola Wilayah",
      subtitle: "1. Pilih tab Provinsi, Kabupaten, atau Kecamatan.\n2. Klik 'Tambah' lalu pilih wilayah induk (untuk kabupaten/kecamatan) dan isi namanya.\n3. Gunakan ikon pensil untuk mengubah atau tong sampah untuk menghapus data.",
      variant: "hero",
    };
  }

  if (pathname.startsWith("/superadmin/kelola-posyandu")) {
    return {
      title: "Kelola Posyandu",
      subtitle: "1. Klik 'Tambah Posyandu' untuk menambah data baru.\n2. Isi informasi posyandu dengan lengkap.\n3. Klik baris untuk mengubah atau menghapus data.",
      variant: "hero",
    };
  }

  if (pathname.startsWith("/superadmin/kelola-puskesmas")) {
    return {
      title: "Kelola Puskesmas",
      subtitle: "1. Klik 'Tambah Puskesmas' untuk menambah data baru.\n2. Isi informasi puskesmas dengan lengkap.\n3. Klik baris untuk mengubah atau menghapus data.",
      variant: "hero",
    };
  }

  if (pathname.startsWith("/superadmin/form-versi")) {
    return {
      title: "Kelola Form Versi",
      subtitle: "1. Pilih kelompok usia (Anak/Remaja/Dewasa/Lansia).\n2. Klik 'Versi Baru' untuk membuat form baru.\n3. Klik versi untuk melihat detail atau mengaktifkan.",
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
  const map = {
    superadmin: "Superadmin",
    admin: "Admin Desa",
    bidan: "Bidan",
    bidan_puskesmas: "Bidan Puskesmas",
    dokter: "Dokter",
    kader: "Kader",
    ibu: "Ibu",
  };
  return map[(role || "").toString().trim().toLowerCase()] || role || "Petugas";
};

const InfoRow = ({ icon: Icon, label, value }) => (
  <div className="flex items-start gap-3 py-2.5 border-b border-slate-100 last:border-0">
    <div className="w-7 h-7 rounded-full bg-blue-50 flex items-center justify-center flex-shrink-0 mt-0.5">
      <Icon size={13} className="text-blue-600" />
    </div>
    <div className="min-w-0">
      <p className="text-[11px] text-slate-400">{label}</p>
      <p className="text-sm font-medium text-slate-800 mt-0.5 break-words">{value || "-"}</p>
    </div>
  </div>
);

// Ambil pesan error dari response backend (bisa string atau array)
const extractErrMsg = (err, fallback) => {
  const d = err?.response?.data;
  if (!d) return fallback;
  if (d.messages && Array.isArray(d.messages) && d.messages.length) return d.messages[0];
  if (d.message) return Array.isArray(d.message) ? d.message[0] : d.message;
  return fallback;
};

const ProfilModal = ({ onClose }) => {
  const localUser = getCurrentUser();
  const [profile, setProfile] = useState(null);
  const [loading, setLoading] = useState(true);
  const [tab, setTab] = useState("info");

  const [editMode, setEditMode] = useState(false);
  const [editName, setEditName] = useState("");
  const [saving, setSaving] = useState(false);

  const [oldPassword, setOldPassword] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [showOld, setShowOld] = useState(false);
  const [showNew, setShowNew] = useState(false);
  const [showConfirm, setShowConfirm] = useState(false);
  const [savingPassword, setSavingPassword] = useState(false);

  useEffect(() => {
    api.get("/auth/me")
      .then((res) => {
        const raw = res.data?.data || res.data;
        const merged = {
          user_id: raw?.user_id,
          name: raw?.name || localUser?.name || "",
          email: raw?.email || localUser?.email || "",
          role: raw?.role || localUser?.role || "",
        };
        setProfile(merged);
        setEditName(merged.name);
      })
      .catch(() => {
        const fb = {
          name: localUser?.name || "",
          email: localUser?.email || "",
          role: localUser?.role || "",
        };
        setProfile(fb);
        setEditName(fb.name);
      })
      .finally(() => setLoading(false));
  }, []);

  const handleSave = async () => {
    if (!editName.trim()) {
      Swal.fire({ icon: "warning", title: "Nama tidak boleh kosong", confirmButtonColor: "#3b82f6" });
      return;
    }
    setSaving(true);
    try {
      const res = await api.put("/auth/me", { name: editName.trim() });
      const updated = res.data?.data || {};
      const newName = updated.name || editName.trim();

      setProfile(p => ({ ...p, name: newName }));
      const stored = JSON.parse(localStorage.getItem("user") || "{}");
      localStorage.setItem("user", JSON.stringify({ ...stored, name: newName }));

      setEditMode(false);
      Swal.fire({ icon: "success", title: "Profil berhasil diperbarui", timer: 1500, showConfirmButton: false });
    } catch (err) {
      Swal.fire({ icon: "error", title: "Gagal Menyimpan", text: extractErrMsg(err, "Gagal menyimpan perubahan profil."), confirmButtonColor: "#3b82f6" });
    } finally {
      setSaving(false);
    }
  };

  const handleChangePassword = async () => {
    if (!oldPassword || !newPassword || !confirmPassword) {
      Swal.fire({ icon: "warning", title: "Semua field wajib diisi", confirmButtonColor: "#3b82f6" });
      return;
    }
    if (newPassword !== confirmPassword) {
      Swal.fire({ icon: "warning", title: "Password Baru Tidak Cocok", text: "Pastikan konfirmasi password sama dengan password baru.", confirmButtonColor: "#3b82f6" });
      return;
    }
    if (newPassword.length < 6) {
      Swal.fire({ icon: "warning", title: "Password Terlalu Pendek", text: "Password baru minimal 6 karakter.", confirmButtonColor: "#3b82f6" });
      return;
    }
    setSavingPassword(true);
    try {
      await api.put("/auth/me/password", { old_password: oldPassword, new_password: newPassword });
      setOldPassword(""); setNewPassword(""); setConfirmPassword("");
      Swal.fire({ icon: "success", title: "Password Berhasil Diubah", text: "Gunakan password baru Anda untuk login berikutnya.", timer: 2000, showConfirmButton: false });
    } catch (err) {
      Swal.fire({ icon: "error", title: "Gagal Mengubah Password", text: extractErrMsg(err, "Terjadi kesalahan. Pastikan password lama benar."), confirmButtonColor: "#3b82f6" });
    } finally {
      setSavingPassword(false);
    }
  };

  const data = profile || { name: localUser?.name || "", email: localUser?.email || "", role: localUser?.role || "" };

  return (
    <div className="fixed inset-0 z-[999] flex items-center justify-center p-4" onClick={onClose}>
      <div className="absolute inset-0 bg-black/40 backdrop-blur-sm" />
      <div
        className="relative bg-white rounded-2xl shadow-2xl w-full max-w-sm overflow-hidden"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header modal */}
        <div className="bg-gradient-to-r from-blue-600 to-cyan-500 px-5 pt-5 pb-10">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-base font-bold text-white">Profil Saya</h2>
            <button onClick={onClose} className="w-7 h-7 rounded-full bg-white/20 hover:bg-white/30 flex items-center justify-center transition-colors">
              <X size={14} className="text-white" />
            </button>
          </div>
          <div className="flex items-center gap-3">
            <div className="w-14 h-14 rounded-full bg-white/20 border-2 border-white/40 flex items-center justify-center flex-shrink-0">
              <User size={26} className="text-white" />
            </div>
            <div className="min-w-0">
              <p className="text-white font-bold text-sm leading-tight truncate">{data.name || "Pengguna"}</p>
              <p className="text-cyan-100 text-xs mt-0.5">{data.email || "-"}</p>
              <span className="inline-block mt-1 px-2 py-0.5 rounded-full bg-white/20 text-white text-[10px] font-medium">
                {formatRole(data.role)}
              </span>
            </div>
          </div>
        </div>

        {/* Tab */}
        <div className="flex border-b border-slate-100 -mt-5 mx-4 bg-white rounded-xl shadow-sm overflow-hidden">
          <button
            onClick={() => setTab("info")}
            className={`flex-1 py-2.5 text-xs font-semibold transition-colors ${tab === "info" ? "text-blue-600 bg-blue-50" : "text-slate-500 hover:bg-slate-50"}`}
          >
            Informasi
          </button>
          <button
            onClick={() => setTab("password")}
            className={`flex-1 py-2.5 text-xs font-semibold transition-colors ${tab === "password" ? "text-blue-600 bg-blue-50" : "text-slate-500 hover:bg-slate-50"}`}
          >
            Ubah Password
          </button>
        </div>

        {/* Body */}
        <div className="px-5 py-4 max-h-[340px] overflow-y-auto">
          {loading ? (
            <div className="flex justify-center py-8">
              <div className="w-6 h-6 border-2 border-blue-500 border-t-transparent rounded-full animate-spin" />
            </div>
          ) : tab === "info" ? (
            <>
              <div className="flex items-center justify-between mb-2">
                <p className="text-xs font-semibold text-slate-500">Detail Akun</p>
                {!editMode ? (
                  <button onClick={() => setEditMode(true)} className="flex items-center gap-1 text-xs text-blue-600 hover:text-blue-700">
                    <Edit2 size={11} /> Edit
                  </button>
                ) : (
                  <div className="flex gap-2">
                    <button onClick={() => { setEditMode(false); setEditName(data.name || ""); }} className="text-xs text-slate-400 hover:text-slate-600">
                      Batal
                    </button>
                    <button onClick={handleSave} disabled={saving} className="text-xs text-green-600 hover:text-green-700 disabled:opacity-50 flex items-center gap-1">
                      <Save size={11} /> {saving ? "..." : "Simpan"}
                    </button>
                  </div>
                )}
              </div>

              {!editMode ? (
                <>
                  <InfoRow icon={User} label="Nama Lengkap" value={data.name} />
                  <InfoRow icon={Mail} label="Email" value={data.email} />
                  <InfoRow icon={Shield} label="Role" value={formatRole(data.role)} />
                </>
              ) : (
                <div className="space-y-3">
                  <div>
                    <label className="text-[11px] text-slate-500 mb-1 block">Nama Lengkap</label>
                    <input
                      type="text"
                      value={editName}
                      onChange={(e) => setEditName(e.target.value)}
                      className="w-full border border-slate-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400"
                    />
                  </div>
                  <div>
                    <label className="text-[11px] text-slate-500 mb-1 block">Email (tidak dapat diubah)</label>
                    <input type="email" value={data.email || ""} disabled className="w-full border border-slate-100 rounded-lg px-3 py-2 text-sm bg-slate-50 text-slate-400 cursor-not-allowed" />
                  </div>
                </div>
              )}
            </>
          ) : (
            <div className="space-y-3">
              {[
                { label: "Password Lama", value: oldPassword, setter: setOldPassword, show: showOld, toggle: () => setShowOld(!showOld) },
                { label: "Password Baru", value: newPassword, setter: setNewPassword, show: showNew, toggle: () => setShowNew(!showNew) },
                { label: "Konfirmasi Password Baru", value: confirmPassword, setter: setConfirmPassword, show: showConfirm, toggle: () => setShowConfirm(!showConfirm) },
              ].map(({ label, value, setter, show, toggle }) => (
                <div key={label}>
                  <label className="text-[11px] text-slate-500 mb-1 block">{label}</label>
                  <div className="relative">
                    <input
                      type={show ? "text" : "password"}
                      value={value}
                      onChange={(e) => setter(e.target.value)}
                      className="w-full border border-slate-200 rounded-lg px-3 py-2 text-sm pr-9 focus:outline-none focus:ring-2 focus:ring-blue-400"
                      placeholder="••••••"
                    />
                    <button type="button" onClick={toggle} className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600">
                      {show ? <EyeOff size={14} /> : <Eye size={14} />}
                    </button>
                  </div>
                </div>
              ))}
              <button
                onClick={handleChangePassword}
                disabled={savingPassword}
                className="w-full bg-blue-600 hover:bg-blue-700 text-white text-sm font-medium py-2.5 rounded-xl transition-colors disabled:opacity-50 mt-1"
              >
                {savingPassword ? "Menyimpan..." : "Simpan Password"}
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

const Header = ({ onToggleSidebar, isSidebarOpen }) => {
  const user = getCurrentUser();
  const location = useLocation();
  const pageHeader = headerByPath(location.pathname);
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const [showProfil, setShowProfil] = useState(false);
  const dropdownRef = useRef(null);

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
    window.location.href = "/login";
  };

  return (
    <>
      <header className="px-6 py-4 border-b border-gray-100 bg-white relative z-50">
        <div className="bg-gradient-to-r from-[#185FA5] to-[#185FA5] text-white rounded-2xl p-4 md:p-5 shadow-lg flex flex-col md:flex-row md:items-start justify-between gap-3">
          {/* Judul halaman */}
          <div className="min-w-0">
            <h1 className="text-xl md:text-2xl font-bold leading-tight">{pageHeader.title}</h1>
            <p className="text-cyan-100 mt-1.5 text-xs md:text-sm leading-relaxed whitespace-pre-line">{pageHeader.subtitle}</p>
            {pageHeader.note && (
              <p className="text-cyan-100 mt-1.5 text-[11px] md:text-xs leading-relaxed">{pageHeader.note}</p>
            )}
          </div>

          {/* Dropdown user + tombol toggle sidebar */}
          <div className="relative flex-shrink-0" ref={dropdownRef}>
            <button
              onClick={() => setIsDropdownOpen(!isDropdownOpen)}
              className={`flex items-center gap-2.5 p-1.5 pr-2.5 rounded-2xl transition-all duration-200 border ${
                isDropdownOpen ? "bg-white/20 border-white/30" : "border-white/20 hover:bg-white/15"
              }`}
            >
              <div className="w-9 h-9 rounded-full bg-white/20 flex items-center justify-center text-white font-bold text-sm">
                {user?.name?.charAt(0) || "B"}
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
              <div className="absolute right-0 mt-2 w-52 bg-white rounded-2xl shadow-xl border border-slate-100 py-2 animate-in fade-in zoom-in duration-200 origin-top-right z-50">
                <div className="px-4 py-2 border-b border-slate-50 mb-1">
                  <p className="text-xs text-slate-400">Masuk sebagai</p>
                  <p className="text-sm font-semibold text-slate-800 truncate">{user?.email || "admin@kia.com"}</p>
                </div>

                <button
                  onClick={() => {
                    setIsDropdownOpen(false);
                    setShowProfil(true);
                  }}
                  className="w-full flex items-center gap-3 px-4 py-2.5 text-sm text-slate-600 hover:bg-slate-50 transition-colors"
                >
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

            {/* Tombol buka sidebar (hanya untuk mobile) */}
            <button
              onClick={onToggleSidebar}
              className="ml-2 flex items-center justify-center w-9 h-9 rounded-lg hover:bg-white/10 transition-colors md:hidden"
              aria-label="Open Menu"
              title="Buka Menu"
            >
              <Menu size={20} className="text-white" />
            </button>
          </div>

          {/* Tombol tutup sidebar (muncul saat sidebar terbuka, mobile) */}
          {isSidebarOpen && (
            <button
              onClick={onToggleSidebar}
              className="flex items-center justify-center w-9 h-9 rounded-lg hover:bg-white/10 transition-colors md:hidden self-end"
              aria-label="Close Menu"
              title="Tutup Menu"
            >
              <X size={20} className="text-white" />
            </button>
          )}
        </div>
      </header>

      {showProfil && <ProfilModal onClose={() => setShowProfil(false)} />}
    </>
  );
};

export default Header;