import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { User, Mail, Phone, Shield, Building, MapPin, ArrowLeft, Edit2, Save, X, Eye, EyeOff } from "lucide-react";
import api from "../services/api";
import { getCurrentUser } from "../services/auth";
import Swal from "sweetalert2";

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
  return map[(role || "").toLowerCase()] || role || "-";
};

const InfoRow = ({ icon: Icon, label, value }) => (
  <div className="flex items-start gap-3 py-3 border-b border-slate-100 last:border-0">
    <div className="w-8 h-8 rounded-full bg-blue-50 flex items-center justify-center flex-shrink-0 mt-0.5">
      <Icon size={15} className="text-blue-600" />
    </div>
    <div className="min-w-0">
      <p className="text-xs text-slate-400">{label}</p>
      <p className="text-sm font-medium text-slate-800 mt-0.5 break-words">{value || "-"}</p>
    </div>
  </div>
);

export default function ProfilSaya() {
  const navigate = useNavigate();
  const localUser = getCurrentUser();

  const [profile, setProfile] = useState(null);
  const [loading, setLoading] = useState(true);

  const [editMode, setEditMode] = useState(false);
  const [editName, setEditName] = useState("");
  const [editPhone, setEditPhone] = useState("");
  const [saving, setSaving] = useState(false);

  const [showPasswordForm, setShowPasswordForm] = useState(false);
  const [oldPassword, setOldPassword] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [showOld, setShowOld] = useState(false);
  const [showNew, setShowNew] = useState(false);
  const [showConfirm, setShowConfirm] = useState(false);
  const [savingPassword, setSavingPassword] = useState(false);

  useEffect(() => {
    const fetchProfile = async () => {
      try {
        const res = await api.get("/auth/me");
        const data = res.data?.data || res.data;
        setProfile(data);
        setEditName(data?.name || "");
        setEditPhone(data?.phone_number || "");
      } catch {
        setProfile(localUser);
        setEditName(localUser?.name || "");
        setEditPhone(localUser?.phone_number || "");
      } finally {
        setLoading(false);
      }
    };
    fetchProfile();
  }, []);

  const handleSaveProfile = async () => {
    if (!editName.trim()) {
      Swal.fire({ icon: "warning", title: "Nama tidak boleh kosong", confirmButtonColor: "#3b82f6" });
      return;
    }
    setSaving(true);
    try {
      await api.put("/auth/me", { name: editName.trim(), phone_number: editPhone.trim() });
      setProfile((prev) => ({ ...prev, name: editName.trim(), phone_number: editPhone.trim() }));
      const stored = JSON.parse(localStorage.getItem("user") || "{}");
      localStorage.setItem("user", JSON.stringify({ ...stored, name: editName.trim(), phone_number: editPhone.trim() }));
      setEditMode(false);
      Swal.fire({ icon: "success", title: "Profil berhasil diperbarui", timer: 1500, showConfirmButton: false });
    } catch (err) {
      const msg = err.response?.data?.message || "Gagal menyimpan perubahan";
      Swal.fire({ icon: "error", title: "Gagal", text: msg, confirmButtonColor: "#3b82f6" });
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
      Swal.fire({ icon: "warning", title: "Password baru tidak cocok", confirmButtonColor: "#3b82f6" });
      return;
    }
    if (newPassword.length < 6) {
      Swal.fire({ icon: "warning", title: "Password minimal 6 karakter", confirmButtonColor: "#3b82f6" });
      return;
    }
    setSavingPassword(true);
    try {
      await api.put("/auth/me/password", { old_password: oldPassword, new_password: newPassword });
      setShowPasswordForm(false);
      setOldPassword("");
      setNewPassword("");
      setConfirmPassword("");
      Swal.fire({ icon: "success", title: "Password berhasil diubah", timer: 1500, showConfirmButton: false });
    } catch (err) {
      const msg = err.response?.data?.message || "Gagal mengubah password";
      Swal.fire({ icon: "error", title: "Gagal", text: msg, confirmButtonColor: "#3b82f6" });
    } finally {
      setSavingPassword(false);
    }
  };

  const goBack = () => navigate(-1);

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-slate-50">
        <div className="w-8 h-8 border-4 border-blue-500 border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  const data = profile || localUser || {};

  return (
    <div className="min-h-screen bg-slate-50 pb-10">
      {/* Header */}
      <div className="bg-gradient-to-r from-blue-700 via-cyan-600 to-teal-600 px-4 pt-6 pb-16">
        <button onClick={goBack} className="flex items-center gap-2 text-white/80 hover:text-white mb-4 transition-colors">
          <ArrowLeft size={18} />
          <span className="text-sm">Kembali</span>
        </button>
        <h1 className="text-xl font-bold text-white">Profil Saya</h1>
        <p className="text-cyan-100 text-sm mt-1">Informasi akun dan pengaturan</p>
      </div>

      <div className="px-4 -mt-10 max-w-lg mx-auto space-y-4">
        {/* Avatar card */}
        <div className="bg-white rounded-2xl shadow-sm p-6 flex flex-col items-center">
          <div className="w-20 h-20 rounded-full bg-gradient-to-br from-blue-500 to-cyan-500 flex items-center justify-center shadow-md mb-3">
            <User size={36} className="text-white" />
          </div>
          <h2 className="text-lg font-bold text-slate-800">{data.name || "Pengguna"}</h2>
          <span className="mt-1 px-3 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-700">
            {formatRole(data.role)}
          </span>
          {data.email && <p className="text-sm text-slate-400 mt-1">{data.email}</p>}
        </div>

        {/* Info card */}
        <div className="bg-white rounded-2xl shadow-sm p-5">
          <div className="flex items-center justify-between mb-2">
            <h3 className="text-sm font-semibold text-slate-700">Informasi Akun</h3>
            {!editMode ? (
              <button
                onClick={() => setEditMode(true)}
                className="flex items-center gap-1.5 text-xs text-blue-600 hover:text-blue-700 transition-colors"
              >
                <Edit2 size={13} />
                Edit
              </button>
            ) : (
              <div className="flex gap-2">
                <button
                  onClick={() => { setEditMode(false); setEditName(data.name || ""); setEditPhone(data.phone_number || ""); }}
                  className="flex items-center gap-1 text-xs text-slate-400 hover:text-slate-600"
                >
                  <X size={13} /> Batal
                </button>
                <button
                  onClick={handleSaveProfile}
                  disabled={saving}
                  className="flex items-center gap-1 text-xs text-green-600 hover:text-green-700 disabled:opacity-50"
                >
                  <Save size={13} /> {saving ? "Menyimpan..." : "Simpan"}
                </button>
              </div>
            )}
          </div>

          {!editMode ? (
            <>
              <InfoRow icon={User} label="Nama Lengkap" value={data.name} />
              <InfoRow icon={Mail} label="Email" value={data.email} />
              <InfoRow icon={Phone} label="Nomor Telepon" value={data.phone_number} />
              <InfoRow icon={Shield} label="Role" value={formatRole(data.role)} />
              {data.desa_name && <InfoRow icon={MapPin} label="Desa" value={data.desa_name} />}
              {data.puskesmas_name && <InfoRow icon={Building} label="Puskesmas" value={data.puskesmas_name} />}
            </>
          ) : (
            <div className="space-y-3 mt-2">
              <div>
                <label className="text-xs text-slate-500 mb-1 block">Nama Lengkap</label>
                <input
                  type="text"
                  value={editName}
                  onChange={(e) => setEditName(e.target.value)}
                  className="w-full border border-slate-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400"
                  placeholder="Masukkan nama lengkap"
                />
              </div>
              <div>
                <label className="text-xs text-slate-500 mb-1 block">Nomor Telepon</label>
                <input
                  type="tel"
                  value={editPhone}
                  onChange={(e) => setEditPhone(e.target.value)}
                  className="w-full border border-slate-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400"
                  placeholder="Masukkan nomor telepon"
                />
              </div>
              <div>
                <label className="text-xs text-slate-500 mb-1 block">Email</label>
                <input
                  type="email"
                  value={data.email || ""}
                  disabled
                  className="w-full border border-slate-100 rounded-lg px-3 py-2 text-sm bg-slate-50 text-slate-400 cursor-not-allowed"
                />
                <p className="text-xs text-slate-400 mt-1">Email tidak dapat diubah</p>
              </div>
            </div>
          )}
        </div>

        {/* Ubah password card */}
        <div className="bg-white rounded-2xl shadow-sm p-5">
          <div className="flex items-center justify-between">
            <h3 className="text-sm font-semibold text-slate-700">Ubah Password</h3>
            <button
              onClick={() => setShowPasswordForm(!showPasswordForm)}
              className="text-xs text-blue-600 hover:text-blue-700 transition-colors"
            >
              {showPasswordForm ? "Sembunyikan" : "Ubah"}
            </button>
          </div>

          {showPasswordForm && (
            <div className="space-y-3 mt-4">
              {[
                { label: "Password Lama", value: oldPassword, setter: setOldPassword, show: showOld, toggleShow: () => setShowOld(!showOld) },
                { label: "Password Baru", value: newPassword, setter: setNewPassword, show: showNew, toggleShow: () => setShowNew(!showNew) },
                { label: "Konfirmasi Password Baru", value: confirmPassword, setter: setConfirmPassword, show: showConfirm, toggleShow: () => setShowConfirm(!showConfirm) },
              ].map(({ label, value, setter, show, toggleShow }) => (
                <div key={label}>
                  <label className="text-xs text-slate-500 mb-1 block">{label}</label>
                  <div className="relative">
                    <input
                      type={show ? "text" : "password"}
                      value={value}
                      onChange={(e) => setter(e.target.value)}
                      className="w-full border border-slate-200 rounded-lg px-3 py-2 text-sm pr-10 focus:outline-none focus:ring-2 focus:ring-blue-400"
                      placeholder={`Masukkan ${label.toLowerCase()}`}
                    />
                    <button
                      type="button"
                      onClick={toggleShow}
                      className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600"
                    >
                      {show ? <EyeOff size={15} /> : <Eye size={15} />}
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
}
