import React, { useEffect, useMemo, useState } from "react";
import MainLayout from "../../components/Layout/MainLayout";
import SearchablePendudukSelect from "../../components/Form/SearchablePendudukSelect";
import { listPendudukForDropdown } from "../../services/superadminPenduduk";
import {
  activateSuperadminUser,
  createAdminDesaUser,
  createBidanUser,
  createKaderUser,
  deactivateSuperadminUser,
  listSuperadminPosyandu,
  listSuperadminUsers,
  resetSuperadminUserPassword,
  superadminUserErrorMessage,
} from "../../services/superadminUsers";
import {
  AlertCircle,
  CheckCircle2,
  Eye,
  ChevronDown,
  KeyRound,
  Loader2,
  Plus,
  Power,
  Search,
  ShieldCheck,
  ShieldPlus,
  UserPlus,
  Users,
  X,
} from "lucide-react";

const emptyBidanForm = {
  penduduk_id: "",
  name: "",
  email: "",
  password: "",
  no_str: "",
  no_sipb: "",
};

const emptyAdminDesaForm = {
  penduduk_id: "",
  name: "",
  email: "",
  password: "",
};

const emptyKaderForm = {
  penduduk_id: "",
  name: "",
  email: "",
  password: "",
  posyandu_id: "",
};

const emptyResetForm = {
  password: "",
};

const cardClass = "rounded-3xl border border-slate-200 bg-white shadow-sm";

const normalizeRole = (role) => (role || "").toLowerCase().replace(/[\s_-]/g, "");

const roleOptions = [
  { value: "", label: "Semua role" },
  { value: "Admin", label: "Admin" },
  { value: "Bidan", label: "Bidan" },
  { value: "Kader", label: "Kader" },
  { value: "Superadmin", label: "Superadmin" },
];

const UserManagement = () => {
  const [users, setUsers] = useState([]);
  const [loadingUsers, setLoadingUsers] = useState(true);
  const [loadingPenduduk, setLoadingPenduduk] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [search, setSearch] = useState("");
  const [roleFilter, setRoleFilter] = useState("");
  const [activeTab, setActiveTab] = useState("");
  const [showCreateMenu, setShowCreateMenu] = useState(false);
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [errorMessage, setErrorMessage] = useState("");
  const [successMessage, setSuccessMessage] = useState("");
  const [bidanForm, setBidanForm] = useState(emptyBidanForm);
  const [adminDesaForm, setAdminDesaForm] = useState(emptyAdminDesaForm);
  const [kaderForm, setKaderForm] = useState(emptyKaderForm);
  const [pendudukOptions, setPendudukOptions] = useState([]);
  const [posyanduOptions, setPosyanduOptions] = useState([]);
  const [loadingPosyandu, setLoadingPosyandu] = useState(true);
  const [resetUser, setResetUser] = useState(null);
  const [resetForm, setResetForm] = useState(emptyResetForm);
  const [showResetModal, setShowResetModal] = useState(false);
  const [statusActionUser, setStatusActionUser] = useState(null);
  const [statusActionType, setStatusActionType] = useState("");

  const loadUsers = async (override = {}) => {
    try {
      setLoadingUsers(true);
      const data = await listSuperadminUsers({
        search: override.search ?? search,
        role: override.role ?? roleFilter,
      });
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

  const loadPosyandu = async () => {
    try {
      setLoadingPosyandu(true);
      const data = await listSuperadminPosyandu();
      setPosyanduOptions(Array.isArray(data) ? data : []);
    } catch (error) {
      setErrorMessage(superadminUserErrorMessage(error, "Gagal memuat data posyandu"));
    } finally {
      setLoadingPosyandu(false);
    }
  };

  useEffect(() => {
    loadUsers();
    loadPenduduk();
    loadPosyandu();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const pendudukLabel = (penduduk) => `${penduduk.nama_lengkap} (${penduduk.nik})`;



  const managedUsers = useMemo(() => {
    return users.filter((user) => {
      const role = normalizeRole(user.role);
      return ["admin", "admindesa", "bidan", "kader", "superadmin"].includes(role);
    });
  }, [users]);

  const activeStats = useMemo(() => {
    const activeUsers = managedUsers.filter((user) => user.is_active).length;
    const inactiveUsers = managedUsers.length - activeUsers;
    const bidanCount = managedUsers.filter((user) => (user.role || "").toLowerCase() === "bidan").length;
    const kaderCount = managedUsers.filter((user) => (user.role || "").toLowerCase() === "kader").length;
    const adminCount = managedUsers.filter((user) => (user.role || "").toLowerCase() === "admin").length;

    return [
      { label: "Total User", value: managedUsers.length, icon: Users, tone: "bg-cyan-50 text-cyan-700" },
      { label: "Aktif", value: activeUsers, icon: CheckCircle2, tone: "bg-emerald-50 text-emerald-700" },
      { label: "Bidan", value: bidanCount, icon: ShieldPlus, tone: "bg-violet-50 text-violet-700" },
      { label: "Kader", value: kaderCount, icon: UserPlus, tone: "bg-sky-50 text-sky-700" },
      { label: "Admin Desa", value: adminCount, icon: ShieldCheck, tone: "bg-amber-50 text-amber-700" },
      { label: "Nonaktif", value: inactiveUsers, icon: Power, tone: "bg-rose-50 text-rose-700" },
    ];
  }, [managedUsers]);

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

  const resetCreateForms = () => {
    setBidanForm(emptyBidanForm);
    setAdminDesaForm(emptyAdminDesaForm);
    setKaderForm(emptyKaderForm);
  };

  const openCreateType = (type) => {
    setActiveTab(type);
    setShowCreateMenu(false);
    setShowCreateModal(true);
  };

  const createTypeLabel =
    activeTab === "bidan"
      ? "Tambah Bidan"
      : activeTab === "admin"
        ? "Assign Admin Desa"
        : activeTab === "kader"
          ? "Tambah Kader"
          : "Pilih jenis akun";

  const createTypeTitle =
    activeTab === "bidan"
      ? "Tambah Bidan"
      : activeTab === "admin"
        ? "Assign Admin Desa"
        : activeTab === "kader"
          ? "Tambah Kader"
          : "Pilih Jenis Akun";

  const createTypeSubtitle =
    activeTab === "bidan"
      ? "Lengkapi data bidan lalu simpan untuk membuat akun baru."
      : activeTab === "admin"
        ? "Lengkapi data admin desa lalu simpan untuk membuat akun baru."
        : activeTab === "kader"
          ? "Lengkapi data kader lalu simpan untuk membuat akun baru."
          : "";

  const closeCreateModal = () => {
    setShowCreateModal(false);
    setShowCreateMenu(false);
    setActiveTab("");
    resetCreateForms();
  };

  const submitBidan = async (event) => {
    event.preventDefault();
    clearMessages();

    if (!bidanForm.penduduk_id || !bidanForm.name.trim() || !bidanForm.email.trim() || !bidanForm.password.trim() || !bidanForm.no_str.trim() || !bidanForm.no_sipb.trim()) {
      setErrorMessage("Semua field bidan wajib diisi");
      return;
    }

    try {
      setSubmitting(true);
      await createBidanUser({
        penduduk_id: Number(bidanForm.penduduk_id),
        name: bidanForm.name.trim(),
        email: bidanForm.email.trim(),
        password: bidanForm.password.trim(),
        no_str: bidanForm.no_str.trim(),
        no_sipb: bidanForm.no_sipb.trim(),
      });
      resetCreateForms();
      await loadUsers();
      setSuccessMessage("Akun bidan berhasil dibuat");
    } catch (error) {
      setErrorMessage(superadminUserErrorMessage(error, "Gagal membuat akun bidan"));
    } finally {
      setSubmitting(false);
    }
  };

  const submitAdminDesa = async (event) => {
    event.preventDefault();
    clearMessages();

    if (!adminDesaForm.name.trim() || !adminDesaForm.email.trim() || !adminDesaForm.password.trim()) {
      setErrorMessage("Nama, email, dan password wajib diisi");
      return;
    }

    try {
      setSubmitting(true);
      await createAdminDesaUser({
        penduduk_id: adminDesaForm.penduduk_id ? Number(adminDesaForm.penduduk_id) : undefined,
        name: adminDesaForm.name.trim(),
        email: adminDesaForm.email.trim(),
        password: adminDesaForm.password.trim(),
      });
      setAdminDesaForm(emptyAdminDesaForm);
      await loadUsers();
      setSuccessMessage("Akun admin desa berhasil dibuat");
    } catch (error) {
      setErrorMessage(superadminUserErrorMessage(error, "Gagal membuat akun admin desa"));
    } finally {
      setSubmitting(false);
    }
  };

  const submitKader = async (event) => {
    event.preventDefault();
    clearMessages();

    if (!kaderForm.penduduk_id || !kaderForm.name.trim() || !kaderForm.email.trim() || !kaderForm.password.trim()) {
      setErrorMessage("Semua field kader wajib diisi");
      return;
    }

    try {
      setSubmitting(true);
      await createKaderUser({
        penduduk_id: Number(kaderForm.penduduk_id),
        name: kaderForm.name.trim(),
        email: kaderForm.email.trim(),
        password: kaderForm.password.trim(),
        posyandu_id: kaderForm.posyandu_id ? Number(kaderForm.posyandu_id) : undefined,
      });
      setKaderForm(emptyKaderForm);
      await loadUsers();
      setSuccessMessage("Akun kader berhasil dibuat");
    } catch (error) {
      setErrorMessage(superadminUserErrorMessage(error, "Gagal membuat akun kader"));
    } finally {
      setSubmitting(false);
    }
  };

  const openResetModal = (user) => {
    setResetUser(user);
    setResetForm(emptyResetForm);
    setShowResetModal(true);
  };

  const openStatusActionModal = (user, actionType) => {
    if ((user.role || "").toLowerCase() === "superadmin") {
      setErrorMessage("Akun superadmin tidak dapat dinonaktifkan");
      return;
    }

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
      await loadUsers();
      setSuccessMessage(statusActionType === "activate" ? "User berhasil diaktifkan" : "User berhasil dinonaktifkan");
    } catch (error) {
      setErrorMessage(superadminUserErrorMessage(error, statusActionType === "activate" ? "Gagal mengaktifkan user" : "Gagal menonaktifkan user"));
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

  const applyFilters = async (event) => {
    event.preventDefault();
    clearMessages();
    await loadUsers();
  };

  const handleRefresh = async () => {
    clearMessages();
    await loadUsers();
  };

  return (
    <MainLayout>
      <div className="p-8 space-y-8">
        <section className="grid gap-4 md:grid-cols-2 xl:grid-cols-5">
          {activeStats.map((stat) => {
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

        <section className="grid gap-6 xl:grid-cols-[minmax(0,1fr)]">
          <div className={`${cardClass} min-w-0 p-6 space-y-5`}>
            <div className="flex items-start justify-between gap-4">
              <div>
                <p className="text-sm font-semibold uppercase tracking-[0.2em] text-slate-400">Daftar user</p>
                <h2 className="mt-1 text-2xl font-bold text-slate-900">Kelola bidan, kader, dan admin desa</h2>
              </div>
              <div className="flex flex-wrap items-center justify-end gap-2">
                <div className="relative">
                  <button
                    type="button"
                    onClick={() => setShowCreateMenu((prev) => !prev)}
                    className="inline-flex items-center gap-2 rounded-2xl bg-slate-900 px-4 py-2 text-sm font-semibold text-white hover:bg-slate-800"
                  >
                    <Plus size={16} />
                    Tambah User
                    <ChevronDown size={16} className={`transition-transform ${showCreateMenu ? "rotate-180" : ""}`} />
                  </button>

                  {showCreateMenu && (
                    <div className="absolute right-0 top-full z-20 mt-2 w-56 overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-xl">
                      <button type="button" onClick={() => openCreateType("bidan")} className="flex w-full items-center gap-3 px-4 py-3 text-left text-sm font-medium text-slate-700 hover:bg-slate-50">
                        <ShieldPlus size={16} className="text-violet-600" />
                        Tambah dan Assign Bidan
                      </button>
                      <button type="button" onClick={() => openCreateType("admin")} className="flex w-full items-center gap-3 px-4 py-3 text-left text-sm font-medium text-slate-700 hover:bg-slate-50">
                        <UserPlus size={16} className="text-amber-600" />
                        Tambah dan Assign Admin Desa
                      </button>
                      <button type="button" onClick={() => openCreateType("kader")} className="flex w-full items-center gap-3 px-4 py-3 text-left text-sm font-medium text-slate-700 hover:bg-slate-50">
                        <Users size={16} className="text-sky-600" />
                        Tambah dan Assign Kader
                      </button>
                    </div>
                  )}
                </div>

                <button onClick={handleRefresh} className="inline-flex items-center gap-2 rounded-2xl bg-slate-100 px-4 py-2 text-sm font-semibold text-slate-700 hover:bg-slate-200">
                  <Loader2 size={16} />
                  Refresh
                </button>
              </div>
            </div>

            <form onSubmit={applyFilters} className="grid gap-3 md:grid-cols-3">
              <div className="md:col-span-2 relative">
                <Search size={16} className="absolute left-3 top-3 text-slate-400" />
                <input
                  type="text"
                  value={search}
                  onChange={(e) => setSearch(e.target.value)}
                  placeholder="Cari nama, email, atau nomor HP"
                  className="w-full rounded-2xl border border-slate-200 py-2.5 pl-10 pr-4"
                />
              </div>
              <div>
                <select value={roleFilter} onChange={(e) => setRoleFilter(e.target.value)} className="w-full rounded-2xl border border-slate-200 px-3 py-2.5">
                  {roleOptions.map((option) => (
                    <option key={option.value} value={option.value}>{option.label}</option>
                  ))}
                </select>
              </div>
              <div className="md:col-span-3 flex gap-3">
                <button type="submit" className="inline-flex items-center gap-2 rounded-2xl bg-cyan-600 px-4 py-2.5 text-sm font-semibold text-white hover:bg-cyan-700">
                  <Search size={16} />
                  Terapkan Filter
                </button>
              </div>
            </form>

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
                  ) : managedUsers.length === 0 ? (
                    <tr>
                      <td colSpan={5} className="px-4 py-10 text-center text-slate-500">Belum ada user yang sesuai filter</td>
                    </tr>
                  ) : (
                    managedUsers.map((user) => {
                      const isSuperadmin = (user.role || "").toLowerCase() === "superadmin";
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
                              <button type="button" onClick={() => openResetModal(user)} className="inline-flex items-center gap-2 rounded-xl bg-amber-50 px-3 py-2 text-sm font-semibold text-amber-700 hover:bg-amber-100">
                                <KeyRound size={16} />
                                Reset Password
                              </button>
                              <button
                                type="button"
                                onClick={() => openStatusActionModal(user, user.is_active ? "deactivate" : "activate")}
                                disabled={isSuperadmin || submitting}
                                className={`inline-flex items-center gap-2 rounded-xl px-3 py-2 text-sm font-semibold disabled:opacity-60 ${user.is_active ? "bg-rose-50 text-rose-700 hover:bg-rose-100" : "bg-emerald-50 text-emerald-700 hover:bg-emerald-100"}`}
                              >
                                <Power size={16} />
                                {isSuperadmin ? "Dilindungi" : user.is_active ? "Nonaktifkan" : "Aktifkan"}
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
        </section>
      </div>

      {showCreateModal && activeTab && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-950/50 px-4">
          <div className="w-full max-w-2xl rounded-2xl bg-white shadow-2xl overflow-hidden">
            <div className="flex items-center justify-between px-6 py-4 border-b border-slate-200">
              <div>
                <h2 className="text-xl font-bold text-slate-800">{createTypeTitle}</h2>
                <p className="text-sm text-slate-500">{createTypeSubtitle}</p>
              </div>
              <button onClick={closeCreateModal} className="p-2 rounded-lg hover:bg-slate-100">
                <X size={20} />
              </button>
            </div>

            <form
              onSubmit={activeTab === "bidan" ? submitBidan : activeTab === "admin" ? submitAdminDesa : submitKader}
              className="p-6 space-y-4"
            >
              {activeTab === "bidan" ? (
                <>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <SearchablePendudukSelect
                      label="Penduduk"
                      value={bidanForm.penduduk_id}
                      onChange={(value) => setBidanForm((prev) => ({ ...prev, penduduk_id: value }))}
                      options={pendudukOptions}
                      loading={loadingPenduduk}
                      optionLabel={pendudukLabel}
                      placeholder={loadingPenduduk ? "Memuat penduduk..." : "Pilih penduduk"}
                    />

                    <Field label="Nama" value={bidanForm.name} onChange={(value) => setBidanForm((prev) => ({ ...prev, name: value }))} />
                    <Field label="Email" type="email" value={bidanForm.email} onChange={(value) => setBidanForm((prev) => ({ ...prev, email: value }))} />
                    <Field label="Password Awal" type="password" value={bidanForm.password} onChange={(value) => setBidanForm((prev) => ({ ...prev, password: value }))} />
                    <Field label="No STR" value={bidanForm.no_str} onChange={(value) => setBidanForm((prev) => ({ ...prev, no_str: value }))} />
                    <Field label="No SIPB" value={bidanForm.no_sipb} onChange={(value) => setBidanForm((prev) => ({ ...prev, no_sipb: value }))} />
                  </div>
                </>
              ) : activeTab === "admin" ? (
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <SearchablePendudukSelect
                    label="Penduduk"
                    value={adminDesaForm.penduduk_id}
                    onChange={(value) => setAdminDesaForm((prev) => ({ ...prev, penduduk_id: value }))}
                    options={pendudukOptions}
                    loading={loadingPenduduk}
                    optionLabel={pendudukLabel}
                    placeholder={loadingPenduduk ? "Memuat penduduk..." : "Pilih penduduk"}
                  />

                  <Field label="Nama" value={adminDesaForm.name} onChange={(value) => setAdminDesaForm((prev) => ({ ...prev, name: value }))} />
                  <Field label="Email" type="email" value={adminDesaForm.email} onChange={(value) => setAdminDesaForm((prev) => ({ ...prev, email: value }))} />
                  <Field label="Password Awal" type="password" value={adminDesaForm.password} onChange={(value) => setAdminDesaForm((prev) => ({ ...prev, password: value }))} />
                </div>
              ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <SearchablePendudukSelect
                    label="Penduduk"
                    value={kaderForm.penduduk_id}
                    onChange={(value) => setKaderForm((prev) => ({ ...prev, penduduk_id: value }))}
                    options={pendudukOptions}
                    loading={loadingPenduduk}
                    optionLabel={pendudukLabel}
                    placeholder={loadingPenduduk ? "Memuat penduduk..." : "Pilih penduduk"}
                  />

                  <Field label="Nama" value={kaderForm.name} onChange={(value) => setKaderForm((prev) => ({ ...prev, name: value }))} />
                  <Field label="Email" type="email" value={kaderForm.email} onChange={(value) => setKaderForm((prev) => ({ ...prev, email: value }))} />
                  <Field label="Password Awal" type="password" value={kaderForm.password} onChange={(value) => setKaderForm((prev) => ({ ...prev, password: value }))} />

                  <div className="space-y-2 md:col-span-2">
                    <label className="block text-sm font-medium text-slate-700">Posyandu</label>
                    <select
                      value={kaderForm.posyandu_id}
                      onChange={(e) => setKaderForm((prev) => ({ ...prev, posyandu_id: e.target.value }))}
                      className="w-full rounded-lg border border-slate-300 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-slate-900"
                    >
                      <option value="">{loadingPosyandu ? "Memuat posyandu..." : "Pilih posyandu (opsional)"}</option>
                      {posyanduOptions.map((p) => (
                        <option key={p.id} value={p.id}>
                          {p.nama}{p.alamat ? ` - ${p.alamat}` : ""}
                        </option>
                      ))}
                    </select>
                  </div>
                </div>
              )}

              <div className="flex items-center justify-end gap-3 pt-2">
                <button type="button" onClick={closeCreateModal} className="rounded-lg border border-slate-300 px-4 py-2 text-slate-700 hover:bg-slate-50">
                  Batal
                </button>
                <button type="submit" disabled={submitting} className="inline-flex items-center gap-2 rounded-lg bg-slate-900 px-4 py-2 text-white hover:bg-slate-800 disabled:opacity-60">
                  {submitting ? <Loader2 size={16} className="animate-spin" /> : <Plus size={16} />}
                  Simpan
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
                <input type="password" value={resetForm.password} onChange={(e) => setResetForm({ password: e.target.value })} className="mt-1 w-full rounded-2xl border border-slate-200 px-4 py-3" placeholder="Minimal 8 karakter" />
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
};

function Field({ label, value, onChange, type = "text", placeholder = "" }) {
  return (
    <div className="space-y-2">
      <label className="block text-sm font-medium text-slate-700">{label}</label>
      <input
        type={type}
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder={placeholder}
        className="w-full rounded-lg border border-slate-300 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-slate-900"
      />
    </div>
  );
}

export default UserManagement;
