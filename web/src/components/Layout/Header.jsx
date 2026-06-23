// src/components/Layout/Header.jsx
import { useState, useRef, useEffect } from "react";
import { useLocation } from "react-router-dom";
import { LogOut, ChevronDown, User, Menu, Mail, Shield, Edit2, Save, Eye, EyeOff, X } from "lucide-react";
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

  if (pathname.startsWith("/jadwal-layanan/form")) {
    return {
      title: pathname.includes("/form/") ? "Edit Jadwal Layanan Posyandu" : "Tambah Jadwal Layanan Posyandu",
      subtitle: "1. Isi nama layanan (Contoh: Pelayanan Imunisasi Rutin).\n2. Pilih dosis vaksin yang akan diberikan pada jadwal ini.\n3. Pilih posyandu, tanggal pelayanan, dan rentang waktu mulai-selesai.\n4. Tambahkan keterangan opsional jika diperlukan.\n5. Klik 'Simpan Jadwal' untuk menyimpan data.",
      variant: "hero",
    };
  }

  if (pathname.startsWith("/jadwal-layanan")) {
    return {
      title: "Jadwal Layanan Posyandu",
      subtitle: "1. Gunakan tab 'Hari Ini', 'Akan Datang', atau 'Sudah Selesai' untuk melihat jadwal berdasarkan status.\n2. Klik 'Tambah Jadwal' untuk membuat sesi imunisasi baru.\n3. Gunakan ikon pensil untuk mengubah atau ikon tong sampah untuk menghapus jadwal.\n4. Card berwarna biru untuk jadwal hari ini, kuning untuk mendatang, dan hijau untuk selesai.",
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

const extractErrMsg = (err, fallback) => {
  const d = err?.response?.data;
  if (!d) return fallback;
  if (d.messages && Array.isArray(d.messages) && d.messages.length) return d.messages[0];
  if (d.message) return Array.isArray(d.message) ? d.message[0] : d.message;
  if (d.error) return d.error;
  return fallback;
};

function ProfilModal({ onClose }) {
  const user = getCurrentUser();
  const [tab, setTab] = useState("profil");
  const [editForm, setEditForm] = useState({ name: user?.name || "", email: user?.email || "" });
  const [pwdForm, setPwdForm] = useState({ oldPassword: "", newPassword: "", confirmPassword: "" });
  const [showOld, setShowOld] = useState(false);
  const [showNew, setShowNew] = useState(false);
  const [showConf, setShowConf] = useState(false);
  const [saving, setSaving] = useState(false);

  const handleEditSubmit = async (e) => {
    e.preventDefault();
    if (!editForm.name.trim()) {
      Swal.fire({ icon: "warning", title: "Nama wajib diisi", confirmButtonColor: "#185FA5" });
      return;
    }
    try {
      setSaving(true);
      await api.put("/auth/profile", { name: editForm.name.trim(), email: editForm.email.trim() });
      const updated = { ...user, name: editForm.name.trim(), email: editForm.email.trim() };
      localStorage.setItem("user", JSON.stringify(updated));
      Swal.fire({ icon: "success", title: "Profil Berhasil Diperbarui", timer: 1800, showConfirmButton: false });
      onClose();
      window.location.reload();
    } catch (err) {
      Swal.fire({ icon: "error", title: "Gagal Memperbarui Profil", text: extractErrMsg(err, "Gagal mengubah profil"), confirmButtonColor: "#185FA5" });
    } finally {
      setSaving(false);
    }
  };

  const handlePwdSubmit = async (e) => {
    e.preventDefault();
    if (!pwdForm.oldPassword || !pwdForm.newPassword || !pwdForm.confirmPassword) {
      Swal.fire({ icon: "warning", title: "Semua field wajib diisi", confirmButtonColor: "#185FA5" });
      return;
    }
    if (pwdForm.newPassword.length < 8) {
      Swal.fire({ icon: "warning", title: "Password baru minimal 8 karakter", confirmButtonColor: "#185FA5" });
      return;
    }
    if (pwdForm.newPassword !== pwdForm.confirmPassword) {
      Swal.fire({ icon: "warning", title: "Konfirmasi password tidak cocok", confirmButtonColor: "#185FA5" });
      return;
    }
    try {
      setSaving(true);
      await api.put("/auth/change-password", { old_password: pwdForm.oldPassword, new_password: pwdForm.newPassword });
      Swal.fire({ icon: "success", title: "Password Berhasil Diubah", text: "Silakan login kembali dengan password baru.", timer: 2000, showConfirmButton: false });
      onClose();
      setTimeout(() => { logout(); window.location.href = "/login"; }, 2100);
    } catch (err) {
      Swal.fire({ icon: "error", title: "Gagal Mengubah Password", text: extractErrMsg(err, "Gagal mengubah password"), confirmButtonColor: "#185FA5" });
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="fixed inset-0 z-[60] flex items-center justify-center bg-slate-950/60 px-4 py-6 overflow-y-auto">
      <div className="w-full max-w-2xl rounded-3xl bg-white shadow-2xl overflow-hidden my-auto">
        <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100">
          <div>
            <h2 className="text-lg font-bold text-slate-800">Profil Saya</h2>
            <p className="text-xs text-slate-500 mt-0.5">Kelola informasi akun Anda</p>
          </div>
          <button onClick={onClose} className="p-2 rounded-lg hover:bg-slate-100 text-slate-500">
            <X size={18} />
          </button>
        </div>

        <div className="flex border-b border-slate-100">
          <button onClick={() => setTab("profil")} className={`flex-1 py-3 text-sm font-medium transition-colors ${tab === "profil" ? "border-b-2 border-blue-600 text-blue-600" : "text-slate-500 hover:text-slate-700"}`}>
            Profil
          </button>
          <button onClick={() => setTab("password")} className={`flex-1 py-3 text-sm font-medium transition-colors ${tab === "password" ? "border-b-2 border-blue-600 text-blue-600" : "text-slate-500 hover:text-slate-700"}`}>
            Ubah Password
          </button>
        </div>

        <div className="p-6">
          {tab === "profil" && (
            <div>
              <div className="mb-5">
                <div className="flex items-center gap-4 mb-5 pb-5 border-b border-slate-100">
                  <div className="w-16 h-16 rounded-full bg-gradient-to-br from-blue-500 to-blue-600 flex items-center justify-center text-white text-2xl font-bold shadow-lg">
                    {user?.name?.charAt(0)?.toUpperCase() || "U"}
                  </div>
                  <div>
                    <p className="text-xl font-bold text-slate-800">{user?.name || "Pengguna"}</p>
                    <p className="text-sm text-slate-500 mt-0.5">{formatRole(user?.role)}</p>
                  </div>
                </div>
                <div className="space-y-0.5">
                  <InfoRow icon={Mail} label="Email" value={user?.email} />
                  <InfoRow icon={Shield} label="Role" value={formatRole(user?.role)} />
                </div>
              </div>
              <form onSubmit={handleEditSubmit} className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-slate-700 mb-2">Nama Lengkap</label>
                  <input type="text" value={editForm.name} onChange={(e) => setEditForm({ ...editForm, name: e.target.value })} className="w-full rounded-xl border border-slate-200 px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500" placeholder="Masukkan nama lengkap" required />
                </div>
                <div>
                  <label className="block text-sm font-medium text-slate-700 mb-2">Email</label>
                  <input type="email" value={editForm.email} onChange={(e) => setEditForm({ ...editForm, email: e.target.value })} className="w-full rounded-xl border border-slate-200 px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500" placeholder="Masukkan email" required />
                </div>
                <div className="flex items-center justify-end gap-3 pt-2">
                  <button type="button" onClick={onClose} className="rounded-xl border border-slate-200 px-4 py-2.5 text-sm font-semibold text-slate-600 hover:bg-slate-50">
                    Batal
                  </button>
                  <button type="submit" disabled={saving} className="inline-flex items-center gap-2 rounded-xl bg-blue-600 px-4 py-2.5 text-sm font-semibold text-white hover:bg-blue-700 disabled:opacity-60">
                    {saving ? <Loader2 size={15} className="animate-spin" /> : <Save size={15} />}
                    {saving ? "Menyimpan..." : "Simpan Perubahan"}
                  </button>
                </div>
              </form>
            </div>
          )}

          {tab === "password" && (
            <form onSubmit={handlePwdSubmit} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-slate-700 mb-2">Password Lama</label>
                <div className="relative">
                  <input type={showOld ? "text" : "password"} value={pwdForm.oldPassword} onChange={(e) => setPwdForm({ ...pwdForm, oldPassword: e.target.value })} className="w-full rounded-xl border border-slate-200 px-4 py-2.5 pr-11 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500" placeholder="Masukkan password lama" required />
                  <button type="button" onClick={() => setShowOld(!showOld)} className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600">
                    {showOld ? <EyeOff size={16} /> : <Eye size={16} />}
                  </button>
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium text-slate-700 mb-2">Password Baru</label>
                <div className="relative">
                  <input type={showNew ? "text" : "password"} value={pwdForm.newPassword} onChange={(e) => setPwdForm({ ...pwdForm, newPassword: e.target.value })} className="w-full rounded-xl border border-slate-200 px-4 py-2.5 pr-11 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500" placeholder="Minimal 8 karakter" required />
                  <button type="button" onClick={() => setShowNew(!showNew)} className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600">
                    {showNew ? <EyeOff size={16} /> : <Eye size={16} />}
                  </button>
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium text-slate-700 mb-2">Konfirmasi Password Baru</label>
                <div className="relative">
                  <input type={showConf ? "text" : "password"} value={pwdForm.confirmPassword} onChange={(e) => setPwdForm({ ...pwdForm, confirmPassword: e.target.value })} className="w-full rounded-xl border border-slate-200 px-4 py-2.5 pr-11 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500" placeholder="Ulangi password baru" required />
                  <button type="button" onClick={() => setShowConf(!showConf)} className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600">
                    {showConf ? <EyeOff size={16} /> : <Eye size={16} />}
                  </button>
                </div>
              </div>
              <div className="flex items-center justify-end gap-3 pt-2">
                <button type="button" onClick={onClose} className="rounded-xl border border-slate-200 px-4 py-2.5 text-sm font-semibold text-slate-600 hover:bg-slate-50">
                  Batal
                </button>
                <button type="submit" disabled={saving} className="inline-flex items-center gap-2 rounded-xl bg-blue-600 px-4 py-2.5 text-sm font-semibold text-white hover:bg-blue-700 disabled:opacity-60">
                  {saving ? <Loader2 size={15} className="animate-spin" /> : <Save size={15} />}
                  {saving ? "Mengubah..." : "Ubah Password"}
                </button>
              </div>
            </form>
          )}
        </div>
      </div>
    </div>
  );
}

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
      {/* ── Header bar ── */}
      <header className="px-4 py-3 border-b border-gray-100 bg-white relative z-50">
        <div className="bg-[#185FA5] text-white rounded-2xl px-4 py-3 flex items-center gap-3">

          {/* Tombol toggle sidebar */}
          <button
            onClick={onToggleSidebar}
            className="w-9 h-9 rounded-xl bg-white/15 hover:bg-white/25
                       border border-white/20 flex items-center justify-center
                       flex-shrink-0 transition-colors"
            aria-label="Toggle sidebar"
            title="Toggle sidebar"
          >
            <Menu size={18} className="text-white" />
          </button>

          {/* Judul halaman */}
          <div className="flex-1 min-w-0">
            <h1 className="text-lg font-semibold leading-tight truncate">
              {pageHeader.title}
            </h1>
            <p className="text-white/70 text-xs mt-0.5 leading-relaxed whitespace-pre-line">
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