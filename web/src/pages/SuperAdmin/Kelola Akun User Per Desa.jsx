import React, { useEffect, useMemo, useState } from "react";
import MainLayout from "../../components/Layout/MainLayout";
import SearchablePendudukSelect from "../../components/Form/SearchablePendudukSelect";
import { listPendudukForDropdown } from "../../services/superadminPenduduk";
import {
  activateSuperadminUser,
  deactivateSuperadminUser,
  createSuperadminUser,
  listSuperadminUsers,
  resetSuperadminUserPassword,
  superadminUserErrorMessage,
  updateSuperadminUserRole,
} from "../../services/superadminUsers";
import {
  AlertCircle,
  CheckCircle2,
  ChevronDown,
  Edit,
  KeyRound,
  Loader2,
  Plus,
  Power,
  Search,
  UserCircle2,
  X,
} from "lucide-react";

const specialRoles = ["admin", "bidan", "kader", "superadmin"];
const specialRoleAliases = ["admindesa"];
const editableRoles = [
  { value: "Ibu", label: "Ibu" },
  { value: "Dokter", label: "Dokter" },
  { value: "Tenaga-kesehatan", label: "Tenaga Kesehatan" },
];

const cardClass = "rounded-3xl border border-slate-200 bg-white shadow-sm";

const emptyRoleForm = {
  role_name: "",
};

const normalizeRole = (role) => (role || "").toLowerCase().replace(/[\s_-]/g, "");

const emptyResetForm = {
  password: "",
};

const emptyCreateForm = {
  name: "",
  email: "",
  password: "",
  role_name: "",
  penduduk_id: "",
};

export default function UserPerDesaManagement() {
  const [users, setUsers] = useState([]);
  const [loadingUsers, setLoadingUsers] = useState(true);
  const [loadingPenduduk, setLoadingPenduduk] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [search, setSearch] = useState("");
  const [errorMessage, setErrorMessage] = useState("");
  const [successMessage, setSuccessMessage] = useState("");
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [createForm, setCreateForm] = useState(emptyCreateForm);
  const [pendudukOptions, setPendudukOptions] = useState([]);
  const [selectedUser, setSelectedUser] = useState(null);
  const [showRoleModal, setShowRoleModal] = useState(false);
  const [roleForm, setRoleForm] = useState(emptyRoleForm);
  const [resetUser, setResetUser] = useState(null);
  const [showResetModal, setShowResetModal] = useState(false);
  const [resetForm, setResetForm] = useState(emptyResetForm);
  const [statusActionUser, setStatusActionUser] = useState(null);
  const [statusActionType, setStatusActionType] = useState("");

  const loadUsers = async () => {
    try {
      setLoadingUsers(true);
      const data = await listSuperadminUsers();
      setUsers(Array.isArray(data) ? data : []);
    } catch (error) {
      setErrorMessage(superadminUserErrorMessage(error, "Gagal memuat data user"));
    } finally {
      setLoadingUsers(false);
    }
  };

  const loadPenduduk = async () => {
    try {
      setLoadingPenduduk(true);
      const data = await listPendudukForDropdown();
      setPendudukOptions(Array.isArray(data) ? data : []);
    } catch (error) {
      setErrorMessage(superadminUserErrorMessage(error, "Gagal memuat data penduduk"));
    } finally {
      setLoadingPenduduk(false);
    }
  };

  useEffect(() => {
    loadUsers();
    loadPenduduk();
  }, []);

  const pendudukLabel = (penduduk) => {
    const roleText = penduduk.kedudukan_keluarga ? ` - ${penduduk.kedudukan_keluarga}` : "";
    return `${penduduk.nama_lengkap} (${penduduk.nik}${roleText})`;
  };

  const visibleUsers = useMemo(() => {
    const keyword = search.trim().toLowerCase();

    return users.filter((user) => {
      const role = normalizeRole(user.role);
      if (specialRoles.includes(role) || specialRoleAliases.includes(role)) {
        return false;
      }

      if (!keyword) {
        return true;
      }

      return [user.name, user.email, user.phone_number, user.role]
        .filter(Boolean)
        .some((value) => value.toLowerCase().includes(keyword));
    });
  }, [users, search]);

  const stats = useMemo(() => {
    const activeUsers = visibleUsers.filter((user) => user.is_active).length;
    const inactiveUsers = visibleUsers.length - activeUsers;

    return [
      { label: "Total User", value: visibleUsers.length, icon: UserCircle2, tone: "bg-cyan-50 text-cyan-700" },
      { label: "Aktif", value: activeUsers, icon: CheckCircle2, tone: "bg-emerald-50 text-emerald-700" },
      { label: "Nonaktif", value: inactiveUsers, icon: Power, tone: "bg-rose-50 text-rose-700" },
    ];
  }, [visibleUsers]);

  const clearMessages = () => {
    setErrorMessage("");
    setSuccessMessage("");
  };

  const notificationMessage = errorMessage || successMessage;
  const notificationType = errorMessage ? "error" : successMessage ? "success" : "";

  useEffect(() => {
    if (!notificationMessage) return undefined;

    const timer = window.setTimeout(() => {
      clearMessages();
    }, 2500);

    return () => window.clearTimeout(timer);
  }, [notificationMessage]);

  const openCreateModal = () => {
    setCreateForm({ ...emptyCreateForm });
    setShowCreateModal(true);
  };

  const closeCreateModal = () => {
    setShowCreateModal(false);
    setCreateForm(emptyCreateForm);
  };

  const submitCreateUser = async (event) => {
    event.preventDefault();

    if (!createForm.name.trim() || !createForm.email.trim() || !createForm.password.trim() || !createForm.role_name.trim()) {
      setErrorMessage("Nama, email, password, dan role wajib diisi");
      return;
    }

    clearMessages();
    try {
      setSubmitting(true);
      await createSuperadminUser({
        name: createForm.name.trim(),
        email: createForm.email.trim(),
        password: createForm.password.trim(),
        role_name: createForm.role_name.trim(),
        penduduk_id: createForm.penduduk_id ? Number(createForm.penduduk_id) : undefined,
      });
      closeCreateModal();
      setSuccessMessage("User baru berhasil ditambahkan");
      await loadUsers();
    } catch (error) {
      setErrorMessage(superadminUserErrorMessage(error, "Gagal menambahkan user"));
    } finally {
      setSubmitting(false);
    }
  };

  const openRoleModal = (user) => {
    setSelectedUser(user);
    setRoleForm({
      role_name: user.role || "",
    });
    setShowRoleModal(true);
  };

  const openResetModal = (user) => {
    setResetUser(user);
    setResetForm(emptyResetForm);
    setShowResetModal(true);
  };

  const openStatusActionModal = (user, actionType) => {
    clearMessages();
    setStatusActionUser(user);
    setStatusActionType(actionType);
  };

  const closeStatusActionModal = () => {
    setStatusActionUser(null);
    setStatusActionType("");
  };

  const confirmStatusAction = async () => {
    if (!statusActionUser || !statusActionType) return;

    clearMessages();
    try {
      setSubmitting(true);
      if (statusActionType === "activate") {
        await activateSuperadminUser(statusActionUser.id);
      } else {
        await deactivateSuperadminUser(statusActionUser.id);
      }
      closeStatusActionModal();
      setSuccessMessage(statusActionType === "activate" ? "User berhasil diaktifkan" : "User berhasil dinonaktifkan");
      await loadUsers();
    } catch (error) {
      setErrorMessage(superadminUserErrorMessage(error, statusActionType === "activate" ? "Gagal mengaktifkan user" : "Gagal menonaktifkan user"));
    } finally {
      setSubmitting(false);
    }
  };

  const submitRoleChange = async (event) => {
    event.preventDefault();
    if (!selectedUser) return;

    if (!roleForm.role_name.trim()) {
      setErrorMessage("Role wajib dipilih");
      return;
    }

    clearMessages();
    try {
      setSubmitting(true);
      await updateSuperadminUserRole(selectedUser.id, {
        role_name: roleForm.role_name.trim(),
      });
      setShowRoleModal(false);
      setSelectedUser(null);
      setRoleForm(emptyRoleForm);
      setSuccessMessage("Role user berhasil diperbarui");
      await loadUsers();
    } catch (error) {
      setErrorMessage(superadminUserErrorMessage(error, "Gagal memperbarui role user"));
    } finally {
      setSubmitting(false);
    }
  };

  const submitResetPassword = async (event) => {
    event.preventDefault();
    if (!resetUser) return;

    if (!resetForm.password.trim() || resetForm.password.trim().length < 8) {
      setErrorMessage("Password baru minimal 8 karakter");
      return;
    }

    clearMessages();
    try {
      setSubmitting(true);
      await resetSuperadminUserPassword(resetUser.id, { password: resetForm.password.trim() });
      setShowResetModal(false);
      setResetUser(null);
      setResetForm(emptyResetForm);
      setSuccessMessage("Password user berhasil direset");
    } catch (error) {
      setErrorMessage(superadminUserErrorMessage(error, "Gagal reset password"));
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <MainLayout>
      <div className="p-8 space-y-8">
        <section className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
          {stats.map((stat) => {
            const Icon = stat.icon;
            return (
              <div key={stat.label} className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
                <div className="flex items-start justify-between gap-3">
                  <div>
                    <p className="text-sm text-slate-500">{stat.label}</p>
                    <h3 className="mt-2 text-3xl font-bold text-slate-900">{stat.value}</h3>
                  </div>
                  <div className={`flex h-11 w-11 items-center justify-center rounded-xl ${stat.tone}`}>
                    <Icon size={20} />
                  </div>
                </div>
              </div>
            );
          })}
        </section>

        <div className={`${cardClass} p-6 space-y-5`}>
          <div className="flex flex-col gap-4 lg:flex-row lg:items-end lg:justify-between">
            <div>
              <p className="text-sm font-semibold uppercase tracking-[0.2em] text-slate-400">Kelola user</p>
              <h2 className="mt-1 text-2xl font-bold text-slate-900">User selain bidan, kader, dan admin</h2>
              <p className="mt-1 text-sm text-slate-500">Gunakan halaman ini untuk mengubah role, reset password, dan menonaktifkan user biasa.</p>
            </div>
            <div className="flex flex-wrap items-center gap-3">
              <button onClick={openCreateModal} className="inline-flex items-center gap-2 rounded-2xl bg-slate-900 px-4 py-2 text-sm font-semibold text-white hover:bg-slate-800">
                <Plus size={16} />
                Tambah User
                <ChevronDown size={16} className="hidden" />
              </button>
              <button onClick={loadUsers} className="inline-flex items-center gap-2 rounded-2xl bg-slate-100 px-4 py-2 text-sm font-semibold text-slate-700 hover:bg-slate-200">
                <Loader2 size={16} />
                Refresh
              </button>
            </div>
          </div>

          <div className="grid gap-3">
            <div className="relative">
              <Search size={16} className="absolute left-3 top-3 text-slate-400" />
              <input
                type="text"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                placeholder="Cari nama, email, nomor HP, atau role"
                className="w-full rounded-2xl border border-slate-200 py-2.5 pl-10 pr-4"
              />
            </div>
          </div>

          <div className="overflow-x-auto rounded-2xl border border-slate-200">
            <table className="w-full min-w-[1100px]">
              <thead className="bg-slate-50 text-left text-sm text-slate-600">
                <tr>
                  <th className="px-4 py-3 font-semibold">User</th>
                  <th className="px-4 py-3 font-semibold">Role</th>
                  <th className="px-4 py-3 font-semibold">Status</th>
                  <th className="px-4 py-3 font-semibold">Kontak</th>
                  <th className="px-4 py-3 text-center font-semibold">Aksi</th>
                </tr>
              </thead>
              <tbody>
                {loadingUsers ? (
                  <tr>
                    <td colSpan={5} className="px-4 py-10 text-center text-slate-500">Memuat data user...</td>
                  </tr>
                ) : visibleUsers.length === 0 ? (
                  <tr>
                    <td colSpan={5} className="px-4 py-10 text-center text-slate-500">Belum ada user yang sesuai filter</td>
                  </tr>
                ) : (
                  visibleUsers.map((user) => {
                    return (
                      <tr key={user.id} className="border-t border-slate-100 align-top hover:bg-slate-50/70">
                        <td className="px-4 py-4">
                          <div className="font-semibold text-slate-900">{user.name}</div>
                          <div className="text-sm text-slate-500">ID {user.id}</div>
                        </td>
                        <td className="px-4 py-4">
                          <span className="inline-flex rounded-full bg-slate-100 px-3 py-1 text-sm font-medium text-slate-700">{user.role}</span>
                        </td>
                        <td className="px-4 py-4">
                          <span className={`inline-flex rounded-full px-3 py-1 text-sm font-medium ${user.is_active ? "bg-emerald-50 text-emerald-700" : "bg-rose-50 text-rose-700"}`}>
                            {user.is_active ? "Aktif" : "Nonaktif"}
                          </span>
                        </td>
                        <td className="px-4 py-4 text-sm text-slate-600">
                          <div>{user.email}</div>
                          <div className="text-xs text-slate-400">{user.phone_number || "-"}</div>
                        </td>
                        <td className="px-4 py-4">
                          <div className="flex flex-wrap items-center justify-center gap-2">
                            <button type="button" onClick={() => openRoleModal(user)} className="inline-flex items-center gap-2 rounded-xl bg-cyan-50 px-3 py-2 text-sm font-semibold text-cyan-700 hover:bg-cyan-100">
                              <Edit size={16} />
                              Edit Role
                            </button>
                            <button type="button" onClick={() => openResetModal(user)} className="inline-flex items-center gap-2 rounded-xl bg-amber-50 px-3 py-2 text-sm font-semibold text-amber-700 hover:bg-amber-100">
                              <KeyRound size={16} />
                              Reset Password
                            </button>
                            <button
                              type="button"
                              onClick={() => openStatusActionModal(user, user.is_active ? "deactivate" : "activate")}
                              disabled={submitting}
                              className={`inline-flex items-center gap-2 rounded-xl px-3 py-2 text-sm font-semibold disabled:opacity-60 ${user.is_active ? "bg-rose-50 text-rose-700 hover:bg-rose-100" : "bg-emerald-50 text-emerald-700 hover:bg-emerald-100"}`}
                            >
                              <Power size={16} />
                              {user.is_active ? "Nonaktifkan" : "Aktifkan"}
                            </button>
                          </div>
                        </td>
                      </tr>
                    );
                  })
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>

      {showCreateModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-950/50 px-4">
          <div className="w-full max-w-2xl rounded-3xl bg-white shadow-2xl overflow-hidden">
            <div className="flex items-start justify-between gap-4 border-b border-slate-200 px-6 py-4">
              <div>
                <p className="text-sm font-semibold uppercase tracking-[0.2em] text-slate-400">Tambah User</p>
                <h3 className="mt-1 text-2xl font-bold text-slate-900">Buat akun user baru</h3>
                <p className="mt-1 text-sm text-slate-500">Akun ini untuk role selain bidan, kader, admin, dan superadmin.</p>
              </div>
              <button type="button" onClick={closeCreateModal} className="rounded-full bg-slate-100 p-2 text-slate-500 hover:bg-slate-200">
                <X size={18} />
              </button>
            </div>

            <form onSubmit={submitCreateUser} className="space-y-4 px-6 py-6">
              <div className="grid gap-4 md:grid-cols-2">
                <div className="md:col-span-2">
                  <SearchablePendudukSelect
                    label="Penduduk"
                    value={createForm.penduduk_id}
                    onChange={(value) => {
                      const selected = pendudukOptions.find((p) => String(p.id) === String(value));
                      setCreateForm((prev) => ({
                        ...prev,
                        penduduk_id: value,
                        name: selected ? selected.nama_lengkap : prev.name,
                      }));
                    }}
                    options={pendudukOptions}
                    loading={loadingPenduduk}
                    optionLabel={pendudukLabel}
                    placeholder={loadingPenduduk ? "Memuat penduduk..." : "Ketik nama atau NIK penduduk"}
                    emptyText="Penduduk tidak ditemukan"
                  />
                </div>
                <div>
                  <label className="text-sm text-slate-600">Nama</label>
                  <input type="text" value={createForm.name} onChange={(e) => setCreateForm((prev) => ({ ...prev, name: e.target.value }))} className="mt-1 w-full rounded-2xl border border-slate-200 px-4 py-3" placeholder="Nama user" />
                </div>
                <div>
                  <label className="text-sm text-slate-600">Role</label>
                  <select value={createForm.role_name} onChange={(e) => setCreateForm((prev) => ({ ...prev, role_name: e.target.value }))} className="mt-1 w-full rounded-2xl border border-slate-200 bg-white px-4 py-3 text-slate-900 shadow-sm outline-none transition focus:border-slate-900 focus:ring-4 focus:ring-slate-900/10">
                    <option value="">Pilih role</option>
                    {editableRoles.map((role) => (
                      <option key={role.value} value={role.value}>
                        {role.label}
                      </option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="text-sm text-slate-600">Email</label>
                  <input type="email" value={createForm.email} onChange={(e) => setCreateForm((prev) => ({ ...prev, email: e.target.value }))} className="mt-1 w-full rounded-2xl border border-slate-200 px-4 py-3" placeholder="user@example.com" />
                </div>
                <div>
                  <label className="text-sm text-slate-600">Password Awal</label>
                  <input type="password" value={createForm.password} onChange={(e) => setCreateForm((prev) => ({ ...prev, password: e.target.value }))} className="mt-1 w-full rounded-2xl border border-slate-200 px-4 py-3" placeholder="Minimal 8 karakter" />
                </div>

              </div>

              <div className="flex items-center justify-end gap-3 pt-2">
                <button type="button" onClick={closeCreateModal} className="rounded-2xl bg-slate-100 px-4 py-2.5 text-sm font-semibold text-slate-700 hover:bg-slate-200">
                  Batal
                </button>
                <button type="submit" disabled={submitting} className="inline-flex items-center gap-2 rounded-2xl bg-slate-900 px-4 py-2.5 text-sm font-semibold text-white hover:bg-slate-800 disabled:opacity-60">
                  {submitting ? <Loader2 size={16} className="animate-spin" /> : <Plus size={16} />}
                  Simpan User
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {showRoleModal && selectedUser && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-950/50 px-4">
          <div className="w-full max-w-lg rounded-3xl bg-white p-6 shadow-2xl">
            <div className="flex items-start justify-between gap-4">
              <div>
                <p className="text-sm font-semibold uppercase tracking-[0.2em] text-slate-400">Edit Role</p>
                <h3 className="mt-1 text-2xl font-bold text-slate-900">{selectedUser.name}</h3>
                <p className="mt-1 text-sm text-slate-500">Ubah role user.</p>
              </div>
              <button type="button" onClick={() => setShowRoleModal(false)} className="rounded-full bg-slate-100 p-2 text-slate-500 hover:bg-slate-200">
                <X size={18} />
              </button>
            </div>

            <form onSubmit={submitRoleChange} className="mt-5 space-y-4">
              <div>
                <label className="text-sm text-slate-600">Role</label>
                <select value={roleForm.role_name} onChange={(e) => setRoleForm((prev) => ({ ...prev, role_name: e.target.value }))} className="mt-1 w-full rounded-2xl border border-slate-200 bg-white px-4 py-3 text-slate-900 shadow-sm outline-none transition focus:border-slate-900 focus:ring-4 focus:ring-slate-900/10">
                  <option value="">Pilih role</option>
                  {editableRoles.map((role) => (
                    <option key={role.value} value={role.value}>
                      {role.label}
                    </option>
                  ))}
                </select>
              </div>

              <div className="flex items-center justify-end gap-3">
                <button type="button" onClick={() => setShowRoleModal(false)} className="rounded-2xl bg-slate-100 px-4 py-2.5 text-sm font-semibold text-slate-700 hover:bg-slate-200">
                  Batal
                </button>
                <button type="submit" disabled={submitting} className="inline-flex items-center gap-2 rounded-2xl bg-slate-900 px-4 py-2.5 text-sm font-semibold text-white hover:bg-slate-800 disabled:opacity-60">
                  {submitting ? <Loader2 size={16} className="animate-spin" /> : <Edit size={16} />}
                  Simpan Perubahan
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {showResetModal && resetUser && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-950/50 px-4">
          <div className="w-full max-w-lg rounded-3xl bg-white p-6 shadow-2xl">
            <div className="flex items-start justify-between gap-4">
              <div>
                <p className="text-sm font-semibold uppercase tracking-[0.2em] text-slate-400">Reset Password</p>
                <h3 className="mt-1 text-2xl font-bold text-slate-900">{resetUser.name}</h3>
                <p className="mt-1 text-sm text-slate-500">Masukkan password baru untuk akun ini.</p>
              </div>
              <button type="button" onClick={() => setShowResetModal(false)} className="rounded-full bg-slate-100 p-2 text-slate-500 hover:bg-slate-200">
                <X size={18} />
              </button>
            </div>

            <form onSubmit={submitResetPassword} className="mt-5 space-y-4">
              <div>
                <label className="text-sm text-slate-600">Password Baru</label>
                <input type="password" value={resetForm.password} onChange={(e) => setResetForm({ password: e.target.value })} className="mt-1 w-full rounded-2xl border border-slate-200 bg-white px-4 py-3 text-slate-900 shadow-sm outline-none transition focus:border-slate-900 focus:ring-4 focus:ring-slate-900/10" placeholder="Minimal 8 karakter" />
              </div>

              <div className="flex items-center justify-end gap-3">
                <button type="button" onClick={() => setShowResetModal(false)} className="rounded-2xl bg-slate-100 px-4 py-2.5 text-sm font-semibold text-slate-700 hover:bg-slate-200">
                  Batal
                </button>
                <button type="submit" disabled={submitting} className="inline-flex items-center gap-2 rounded-2xl bg-slate-900 px-4 py-2.5 text-sm font-semibold text-white hover:bg-slate-800 disabled:opacity-60">
                  {submitting ? <Loader2 size={16} className="animate-spin" /> : <KeyRound size={16} />}
                  Simpan Password
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {statusActionUser && (
        <div className="fixed inset-0 z-[60] flex items-center justify-center bg-slate-950/60 px-4">
          <div className="w-full max-w-md rounded-3xl bg-white p-6 shadow-2xl">
            <div className="flex items-start gap-3">
              <div className={`flex h-11 w-11 items-center justify-center rounded-2xl ${statusActionType === "activate" ? "bg-emerald-50 text-emerald-600" : "bg-rose-50 text-rose-600"}`}>
                <Power size={20} />
              </div>
              <div className="min-w-0">
                <h3 className="text-lg font-bold text-slate-900">{statusActionType === "activate" ? "Aktifkan user" : "Nonaktifkan user"}</h3>
                <p className="mt-1 text-sm text-slate-600">
                  {statusActionType === "activate" ? (
                    <>Yakin ingin mengaktifkan <span className="font-semibold text-slate-900">{statusActionUser.name}</span>? User ini bisa login kembali setelah diaktifkan.</>
                  ) : (
                    <>Yakin ingin menonaktifkan <span className="font-semibold text-slate-900">{statusActionUser.name}</span>? User ini tidak akan bisa login lagi sampai diaktifkan kembali.</>
                  )}
                </p>
              </div>
            </div>

            <div className="mt-6 flex items-center justify-end gap-3">
              <button type="button" onClick={closeStatusActionModal} className="rounded-2xl bg-slate-100 px-4 py-2.5 text-sm font-semibold text-slate-700 hover:bg-slate-200 disabled:opacity-60" disabled={submitting}>
                Batal
              </button>
              <button type="button" onClick={confirmStatusAction} disabled={submitting} className={`inline-flex items-center gap-2 rounded-2xl px-4 py-2.5 text-sm font-semibold text-white disabled:opacity-60 ${statusActionType === "activate" ? "bg-emerald-600 hover:bg-emerald-700" : "bg-rose-600 hover:bg-rose-700"}`}>
                {submitting ? <Loader2 size={16} className="animate-spin" /> : <Power size={16} />}
                {statusActionType === "activate" ? "Aktifkan" : "Nonaktifkan"}
              </button>
            </div>
          </div>
        </div>
      )}

      {notificationMessage && (
        <div className="fixed inset-0 z-[60] flex items-center justify-center bg-slate-950/50 px-4">
          <div className="w-full max-w-md rounded-3xl bg-white p-6 shadow-2xl">
            <div className="flex items-start gap-3">
              {notificationType === "error" ? (
                <AlertCircle size={22} className="mt-0.5 text-red-600 flex-shrink-0" />
              ) : (
                <CheckCircle2 size={22} className="mt-0.5 text-emerald-600 flex-shrink-0" />
              )}
              <div className="min-w-0">
                <h3 className="text-lg font-bold text-slate-900">{notificationType === "error" ? "Terjadi kesalahan" : "Berhasil"}</h3>
                <p className={`mt-1 text-sm ${notificationType === "error" ? "text-red-700" : "text-emerald-700"}`}>
                  {notificationMessage}
                </p>
              </div>
            </div>

            <div className="mt-6 flex justify-end">
              <button type="button" onClick={clearMessages} className="rounded-2xl bg-slate-900 px-4 py-2.5 text-sm font-semibold text-white hover:bg-slate-800">
                Tutup
              </button>
            </div>
          </div>
        </div>
      )}
    </MainLayout>
  );
}
