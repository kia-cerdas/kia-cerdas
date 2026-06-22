import React, { useEffect, useMemo, useState } from "react";
import MainLayout from "../../components/Layout/MainLayout";
import Pagination from "../../components/Pagination/Pagination";
import SearchablePendudukSelect from "../../components/Form/SearchablePendudukSelect";
import { listPendudukForDropdown } from "../../services/superadminPenduduk";
import { listDesa } from "../../services/desa";
import { formatNik } from "../../utils/format";
import {
  activateSuperadminUser,
  deactivateSuperadminUser,
  createSuperadminUser,
  listSuperadminUsers,
  superadminUserErrorMessage,
  updateSuperadminUser,
  updateSuperadminUserRole,
} from "../../services/superadminUsers";
import {
  AlertCircle,
  CheckCircle2,
  ChevronDown,
  Edit,
  Loader2,
  Plus,
  Power,
  Search,
  UserCircle2,
  UserPlus,
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

const emptyEditForm = {
  name: "",
  email: "",
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
  const [selectedDesa, setSelectedDesa] = useState("");
  const [desasList, setDesasList] = useState([]);
  const [errorMessage, setErrorMessage] = useState("");
  const [successMessage, setSuccessMessage] = useState("");
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [createForm, setCreateForm] = useState(emptyCreateForm);
  const [pendudukOptions, setPendudukOptions] = useState([]);
  const [selectedUser, setSelectedUser] = useState(null);
  const [showRoleModal, setShowRoleModal] = useState(false);
  const [roleForm, setRoleForm] = useState(emptyRoleForm);
  const [editUser, setEditUser] = useState(null);
  const [showEditModal, setShowEditModal] = useState(false);
  const [editForm, setEditForm] = useState(emptyEditForm);
  const [statusActionUser, setStatusActionUser] = useState(null);
  const [statusActionType, setStatusActionType] = useState("");

  // Pagination dan Filter state
  const [filterRole, setFilterRole] = useState("");
  const [currentPage, setCurrentPage] = useState(1);
  const [itemsPerPage] = useState(10);

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

  const loadDesa = async () => {
    try {
      const data = await listDesa();
      setDesasList(Array.isArray(data) ? data : []);
    } catch (error) {
      console.error("Failed to load desa:", error);
    }
  };

  useEffect(() => {
    loadUsers();
    loadPenduduk();
    loadDesa();
  }, []);

  const pendudukLabel = (penduduk) => {
    const hubungan = penduduk.hubungan ? ` - ${penduduk.hubungan}` : "";
    return `${penduduk.nama_anggota_keluarga || penduduk.nama_lengkap || "-"} (${formatNik(penduduk.nik)}${hubungan})`;
  };

  // Peta penduduk_id -> user (akun) untuk tahu penduduk mana yang sudah punya akun
  const userByPendudukId = useMemo(() => {
    const map = new Map();
    users.forEach((user) => {
      if (user.penduduk_id) {
        map.set(String(user.penduduk_id), user);
      }
    });
    return map;
  }, [users]);

  // Cek apakah penduduk punya role khusus (kader/bidan/admin desa) -> disembunyikan
  const isSpecialRole = (role) => {
    const r = normalizeRole(role);
    return specialRoles.includes(r) || specialRoleAliases.includes(r);
  };

  // Tampilkan SELURUH penduduk, kecuali yang akunnya ber-role kader/bidan/admin desa
  const visiblePenduduk = useMemo(() => {
    const keyword = search.trim().toLowerCase();

    return pendudukOptions.filter((penduduk) => {
      const account = userByPendudukId.get(String(penduduk.id));

      // Sembunyikan penduduk yang akunnya kader/bidan/admin desa
      if (account && isSpecialRole(account.role)) {
        return false;
      }

      // Filter berdasarkan desa
      if (selectedDesa) {
        if (String(penduduk.desa_id) !== String(selectedDesa)) {
          return false;
        }
      }

      // Filter by Role (hanya filter yang punya akun)
      if (filterRole && account) {
        const accountRole = (account.role || "").toLowerCase();
        const selectedFilterRole = filterRole.toLowerCase();
        if (accountRole !== selectedFilterRole) {
          return false;
        }
      } else if (filterRole && !account) {
        // Jika ada filter role tapi penduduk belum punya akun, hide
        return false;
      }

      if (!keyword) {
        return true;
      }

      const name = penduduk.nama_anggota_keluarga || penduduk.nama_lengkap || "";
      return [name, penduduk.nik, penduduk.email, account?.role]
        .filter(Boolean)
        .some((value) => String(value).toLowerCase().includes(keyword));
    });
  }, [pendudukOptions, userByPendudukId, search, selectedDesa, filterRole]);

  // Paginated data
  const paginatedPenduduk = useMemo(() => {
    const startIndex = (currentPage - 1) * itemsPerPage;
    const endIndex = startIndex + itemsPerPage;
    return visiblePenduduk.slice(startIndex, endIndex);
  }, [visiblePenduduk, currentPage, itemsPerPage]);

  // Reset to page 1 when filters change
  useEffect(() => {
    setCurrentPage(1);
  }, [search, selectedDesa, filterRole]);

  const stats = useMemo(() => {
    const total = visiblePenduduk.length;
    const withAccount = visiblePenduduk.filter((p) => userByPendudukId.has(String(p.id))).length;
    const withoutAccount = total - withAccount;

    return [
      { label: "Total Penduduk", value: total, icon: UserCircle2, tone: "bg-cyan-50 text-cyan-700" },
      { label: "Sudah Punya Akun", value: withAccount, icon: CheckCircle2, tone: "bg-emerald-50 text-emerald-700" },
      { label: "Belum Punya Akun", value: withoutAccount, icon: Power, tone: "bg-rose-50 text-rose-700" },
    ];
  }, [visiblePenduduk, userByPendudukId]);

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

  // Buka modal buat akun dengan data dari baris penduduk (prefill nama & penduduk)
  const openCreateModalForPenduduk = (penduduk) => {
    setCreateForm({
      ...emptyCreateForm,
      name: penduduk?.nama_anggota_keluarga || penduduk?.nama_lengkap || "",
      email: penduduk?.email || "",
      penduduk_id: penduduk?.id ? String(penduduk.id) : "",
    });
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
      setSuccessMessage("Akun baru berhasil dibuat");
      await Promise.all([loadUsers(), loadPenduduk()]);
    } catch (error) {
      setErrorMessage(superadminUserErrorMessage(error, "Gagal membuat akun"));
    } finally {
      setSubmitting(false);
    }
  };

  // Dipertahankan untuk modal Edit Role (saat ini tombolnya disembunyikan dari tabel)
  // eslint-disable-next-line no-unused-vars
  const openRoleModal = (user) => {
    setSelectedUser(user);
    setRoleForm({
      role_name: user.role || "",
    });
    setShowRoleModal(true);
  };

  const openEditModal = (user) => {
    setEditUser(user);
    setEditForm({
      ...emptyEditForm,
      name: user.name || "",
      email: user.email || "",
      password: "",
    });
    setShowEditModal(true);
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

  const submitEditUser = async (event) => {
    event.preventDefault();
    if (!editUser) return;

    if (!editForm.name.trim()) {
      setErrorMessage("Nama wajib diisi");
      return;
    }
    if (!editForm.email.trim()) {
      setErrorMessage("Email wajib diisi");
      return;
    }
    if (editForm.password && editForm.password.trim().length < 8) {
      setErrorMessage("Password minimal 8 karakter");
      return;
    }

    clearMessages();
    try {
      setSubmitting(true);
      const payload = {
        name: editForm.name.trim(),
        email: editForm.email.trim(),
      };
      if (editForm.password.trim()) {
        payload.password = editForm.password.trim();
      }
      await updateSuperadminUser(editUser.id, payload);
      setShowEditModal(false);
      setEditUser(null);
      setEditForm(emptyEditForm);
      setSuccessMessage("Data user berhasil diperbarui");
      await Promise.all([loadUsers(), loadPenduduk()]);
    } catch (error) {
      setErrorMessage(superadminUserErrorMessage(error, "Gagal memperbarui data user"));
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <MainLayout>
      <div className="px-4 pb-6 pt-0 space-y-5 md:px-6 max-w-full overflow-hidden">
        <section className="grid gap-2.5 grid-cols-2 md:grid-cols-3">
          {stats.map((stat) => {
            const Icon = stat.icon;
            return (
              <div key={stat.label} className="rounded-xl border border-slate-200 bg-white p-3 shadow-sm">
                <div className="flex items-start justify-between gap-2">
                  <div className="min-w-0">
                    <p className="text-[11px] leading-tight text-slate-500">{stat.label}</p>
                    <h3 className="mt-1 text-xl font-bold text-slate-900">{stat.value}</h3>
                  </div>
                  <div className={`flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-lg ${stat.tone}`}>
                    <Icon size={16} />
                  </div>
                </div>
              </div>
            );
          })}
        </section>

        <div className={`${cardClass} p-4 md:p-6 space-y-5`}>
          <div className="flex flex-wrap items-center gap-3">
            <div className="flex-1 min-w-[200px] relative">
              <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
              <input
                type="text"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                placeholder="Cari nama, email, nomor HP, atau role"
                className="w-full rounded-2xl border border-slate-200 py-2.5 pl-10 pr-4"
              />
            </div>
            <button
              type="button"
              className="inline-flex items-center gap-2 rounded-2xl bg-indigo-600 px-4 py-2.5 text-sm font-semibold text-white hover:bg-indigo-700 transition-colors"
            >
              <Search size={16} />
              Cari
            </button>
            <select
              value={selectedDesa}
              onChange={(e) => setSelectedDesa(e.target.value)}
              className="rounded-2xl border border-slate-200 px-3 py-2.5 text-sm text-slate-700 bg-white focus:outline-none focus:ring-2 focus:ring-indigo-500 cursor-pointer"
            >
              <option value="">Semua Desa</option>
              {desasList.map((d) => (
                <option key={d.id} value={d.id}>{d.nama_desa}</option>
              ))}
            </select>
            <select
              value={filterRole}
              onChange={(e) => setFilterRole(e.target.value)}
              className="rounded-2xl border border-slate-200 px-3 py-2.5 text-sm text-slate-700 bg-white focus:outline-none focus:ring-2 focus:ring-indigo-500 cursor-pointer"
            >
              <option value="">Semua Role</option>
              {editableRoles.map((role) => (
                <option key={role.value} value={role.value}>{role.label}</option>
              ))}
            </select>
            <button onClick={() => { loadUsers(); loadPenduduk(); }} className="inline-flex items-center gap-2 rounded-2xl border border-slate-200 px-4 py-2.5 text-sm font-semibold text-slate-600 hover:bg-slate-50">
              <Loader2 size={16} />
              Refresh
            </button>
          </div>

          <div className="overflow-x-auto rounded-2xl border border-slate-200">
            <div className="min-w-[800px]">
              <table className="w-full">
                <thead className="bg-slate-50 text-left text-sm text-slate-600">
                  <tr>
                    <th className="px-4 py-3 font-semibold">Penduduk</th>
                    <th className="px-4 py-3 font-semibold">Status Akun</th>
                    <th className="px-4 py-3 font-semibold">Email</th>
                    <th className="px-4 py-3 text-center font-semibold">Aksi</th>
                  </tr>
                </thead>
                <tbody>
                  {(loadingUsers || loadingPenduduk) ? (
                    <tr>
                      <td colSpan={4} className="px-4 py-10 text-center text-slate-500">Memuat data penduduk...</td>
                    </tr>
                  ) : visiblePenduduk.length === 0 ? (
                    <tr>
                      <td colSpan={4} className="px-4 py-10 text-center text-slate-500">Belum ada penduduk yang sesuai filter</td>
                    </tr>
                  ) : (
                    paginatedPenduduk.map((penduduk) => {
                      const account = userByPendudukId.get(String(penduduk.id));
                      const namaPenduduk = penduduk.nama_anggota_keluarga || penduduk.nama_lengkap || "-";
                      return (
                        <tr key={penduduk.id} className="border-t border-slate-100 align-top hover:bg-slate-50/70">
                          <td className="px-4 py-4">
                            <div className="font-semibold text-slate-900">{namaPenduduk}</div>
                            <div className="text-xs text-slate-400 mt-0.5 font-mono">NIK {formatNik(penduduk.nik)}</div>
                          </td>
                          <td className="px-4 py-4">
                            {account ? (
                              <div className="flex flex-wrap items-center gap-1.5">
                                <span className="inline-flex rounded-full bg-slate-100 px-3 py-1 text-xs font-medium text-slate-700">{account.role}</span>
                                <span className={`inline-flex rounded-full px-3 py-1 text-xs font-medium ${account.is_active ? "bg-emerald-50 text-emerald-700" : "bg-rose-50 text-rose-700"}`}>
                                  {account.is_active ? "Aktif" : "Nonaktif"}
                                </span>
                              </div>
                            ) : (
                              <span className="inline-flex rounded-full bg-slate-50 px-3 py-1 text-xs font-medium text-slate-400">
                                Belum punya akun
                              </span>
                            )}
                          </td>
                          <td className="px-4 py-4 text-sm text-slate-600">
                            <div>{account?.email || penduduk.email || "-"}</div>
                            <div className="text-xs text-slate-400">{account?.phone_number || penduduk.telepon || "-"}</div>
                          </td>
                          <td className="px-4 py-4">
                            <div className="flex flex-wrap items-center justify-center gap-2">
                              {account ? (
                                <>
                                  <button type="button" onClick={() => openEditModal(account)} title="Edit" className="inline-flex items-center gap-2 rounded-xl bg-amber-50 px-3 py-2 text-sm font-semibold text-amber-700 hover:bg-amber-100">
                                    <Edit size={16} />
                                    <span className="hidden sm:inline">Edit</span>
                                  </button>
                                  <button
                                    type="button"
                                    onClick={() => openStatusActionModal(account, account.is_active ? "deactivate" : "activate")}
                                    disabled={submitting}
                                    className={`inline-flex items-center gap-2 rounded-xl px-3 py-2 text-sm font-semibold disabled:opacity-60 ${account.is_active ? "bg-rose-50 text-rose-700 hover:bg-rose-100" : "bg-emerald-50 text-emerald-700 hover:bg-emerald-100"}`}
                                  >
                                    <Power size={16} />
                                    <span className="hidden sm:inline">{account.is_active ? "Nonaktifkan" : "Aktifkan"}</span>
                                  </button>
                                </>
                              ) : (
                                <button type="button" onClick={() => openCreateModalForPenduduk(penduduk)} title="Buat Akun" className="inline-flex items-center gap-2 rounded-xl bg-indigo-50 px-3 py-2 text-sm font-semibold text-indigo-700 hover:bg-indigo-100">
                                  <UserPlus size={16} />
                                  <span className="hidden sm:inline">Buat Akun</span>
                                </button>
                              )}
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

          {/* Pagination */}
          {!loadingUsers && !loadingPenduduk && visiblePenduduk.length > 0 && (
            <Pagination
              currentPage={currentPage}
              totalPages={Math.ceil(visiblePenduduk.length / itemsPerPage)}
              totalItems={visiblePenduduk.length}
              itemsPerPage={itemsPerPage}
              onPageChange={(page) => setCurrentPage(page)}
              loading={loadingUsers || loadingPenduduk}
            />
          )}
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
                        name: selected ? (selected.nama_anggota_keluarga || selected.nama_lengkap) : prev.name,
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
                <button type="submit" disabled={submitting} className="inline-flex items-center gap-2 rounded-2xl bg-indigo-600 px-4 py-2.5 text-sm font-semibold text-white hover:bg-indigo-700 disabled:opacity-60">
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
                <button type="submit" disabled={submitting} className="inline-flex items-center gap-2 rounded-2xl bg-indigo-600 px-4 py-2.5 text-sm font-semibold text-white hover:bg-indigo-700 disabled:opacity-60">
                  {submitting ? <Loader2 size={16} className="animate-spin" /> : <Edit size={16} />}
                  Simpan Perubahan
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {showEditModal && editUser && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-950/50 px-4 py-6 overflow-y-auto">
          <div className="w-full max-w-xl rounded-2xl bg-white shadow-2xl overflow-hidden my-auto">

            {/* Header */}
            <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100">
              <div>
                <h2 className="text-lg font-bold text-slate-800">Edit Akun</h2>
                <p className="text-xs text-slate-500 mt-0.5">Ubah data akun pengguna</p>
              </div>
              <button type="button" onClick={() => setShowEditModal(false)} className="p-2 rounded-lg hover:bg-slate-100 text-slate-500">
                <X size={18} />
              </button>
            </div>

            <form onSubmit={submitEditUser} className="p-6 space-y-5">

              {/* Data Akun */}
              <div>
                <p className="text-xs font-semibold text-slate-500 uppercase tracking-wider mb-3">Data Akun</p>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-3">

                  {/* Nama */}
                  <div className="md:col-span-2">
                    <label className="block text-sm font-medium text-slate-700 mb-1">
                      Nama Lengkap <span className="text-red-500">*</span>
                    </label>
                    <input
                      type="text"
                      value={editForm.name}
                      onChange={(e) => setEditForm((prev) => ({ ...prev, name: e.target.value }))}
                      placeholder="Nama yang ditampilkan di akun"
                      className="w-full rounded-xl border border-slate-200 px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
                      required
                    />
                  </div>

                  {/* Email */}
                  <div className="md:col-span-2">
                    <label className="block text-sm font-medium text-slate-700 mb-1">
                      Email <span className="text-red-500">*</span>
                    </label>
                    <input
                      type="email"
                      value={editForm.email}
                      onChange={(e) => setEditForm((prev) => ({ ...prev, email: e.target.value }))}
                      placeholder="contoh@email.com"
                      className="w-full rounded-xl border border-slate-200 px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
                      required
                    />
                  </div>

                  {/* Password */}
                  <div className="md:col-span-2">
                    <label className="block text-sm font-medium text-slate-700 mb-1">
                      Password Baru
                    </label>
                    <input
                      type="password"
                      value={editForm.password}
                      onChange={(e) => setEditForm((prev) => ({ ...prev, password: e.target.value }))}
                      placeholder="Kosongkan jika tidak ingin mengubah password"
                      className="w-full rounded-xl border border-slate-200 px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
                    />
                    <p className="text-xs text-slate-400 mt-1">Kosongkan jika tidak ingin mengubah password</p>
                  </div>
                </div>
              </div>

              {/* Action Buttons */}
              <div className="flex items-center justify-end gap-3 pt-2 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => setShowEditModal(false)}
                  className="rounded-xl border border-slate-200 px-4 py-2.5 text-sm font-semibold text-slate-600 hover:bg-slate-50 transition-colors"
                >
                  Batal
                </button>
                <button
                  type="submit"
                  disabled={submitting}
                  className="inline-flex items-center gap-2 rounded-xl bg-indigo-600 px-5 py-2.5 text-sm font-semibold text-white hover:bg-indigo-700 disabled:opacity-60 transition-colors"
                >
                  {submitting ? <Loader2 size={15} className="animate-spin" /> : <Edit size={15} />}
                  {submitting ? "Menyimpan..." : "Simpan Perubahan"}
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
              <button type="button" onClick={clearMessages} className="rounded-2xl bg-indigo-600 px-4 py-2.5 text-sm font-semibold text-white hover:bg-indigo-700">
                Tutup
              </button>
            </div>
          </div>
        </div>
      )}
    </MainLayout>
  );
}
