import React, { useEffect, useMemo, useState } from "react";
import Swal from "sweetalert2";
import MainLayout from "../../components/Layout/MainLayout";
import Pagination from "../../components/Pagination/Pagination";
import { listPendudukForDropdown } from "../../services/superadminPenduduk";
import {
  activateSuperadminUser,
  createAdminDesaUser,
  createBidanUser,
  createKaderUser,
  deactivateSuperadminUser,
  listSuperadminPosyandu,
  listSuperadminUsers,
  superadminUserErrorMessage,
  updateSuperadminUser,
} from "../../services/superadminUsers";
import { listDesa } from "../../services/desa";
import { formatNik, formatKodeKeluarga } from "../../utils/format";
import {
  Edit,
  Loader2,
  MapPin,
  Power,
  RefreshCw,
  Search,
  ShieldPlus,
  UserCheck,
  UserX,
  Users,
  X,
} from "lucide-react";

const cardClass = "rounded-3xl border border-slate-200 bg-white shadow-sm";

const emptyAssignForm = {
  role: "",
  name: "",
  email: "",
  password: "",
  showPassword: false,
  no_str: "",
  no_sipb: "",
  posyandu_id: "",
};

const emptyEditForm = {
  name: "",
  email: "",
  password: "",
  no_str: "",
  no_sipb: "",
};

const ASSIGN_ROLE_OPTIONS = [
  { value: "", label: "-- Pilih Role --" },
  { value: "bidan", label: "Bidan" },
  { value: "admin", label: "Admin Desa" },
  { value: "kader", label: "Kader" },
];

const UserManagement = () => {
  // Core data
  const [pendudukList, setPendudukList] = useState([]);
  const [users, setUsers] = useState([]);
  const [desasList, setDesasList] = useState([]);
  const [posyanduOptions, setPosyanduOptions] = useState([]);
  const [loadingPosyandu, setLoadingPosyandu] = useState(true);

  // Loading states
  const [loadingPenduduk, setLoadingPenduduk] = useState(true);
  const [loadingUsers, setLoadingUsers] = useState(true);
  const [submitting, setSubmitting] = useState(false);

  // Filter states
  const [search, setSearch] = useState("");
  const [selectedDesa, setSelectedDesa] = useState("");

  // Assign modal
  const [assignTarget, setAssignTarget] = useState(null);
  const [assignForm, setAssignForm] = useState(emptyAssignForm);

  // Edit user modal
  const [editUser, setEditUser] = useState(null);
  const [editForm, setEditForm] = useState(emptyEditForm);
  const [showEditModal, setShowEditModal] = useState(false);

  // Status action modal
  const [statusActionUser, setStatusActionUser] = useState(null);
  const [statusActionType, setStatusActionType] = useState("");

  // Pagination state
  const [currentPage, setCurrentPage] = useState(1);
  const [itemsPerPage] = useState(10);


  // --- Data loading ---
  const loadDesa = async () => {
    try {
      const data = await listDesa();
      setDesasList(Array.isArray(data) ? data : []);
    } catch (error) {
      console.error("Failed to load desa:", error);
    }
  };

  const loadPosyandu = async () => {
    try {
      setLoadingPosyandu(true);
      const data = await listSuperadminPosyandu();
      setPosyanduOptions(Array.isArray(data) ? data : []);
    } catch {
      // Posyandu tidak wajib, abaikan error
    } finally {
      setLoadingPosyandu(false);
    }
  };

  const loadUsers = async () => {
    try {
      setLoadingUsers(true);
      const data = await listSuperadminUsers({ search: "", role: "" });
      setUsers(Array.isArray(data) ? data : []);
    } catch (error) {
      Swal.fire({ icon: "error", title: "Gagal Memuat User", text: superadminUserErrorMessage(error, "Gagal memuat data user"), confirmButtonColor: "#4f46e5" });
    } finally {
      setLoadingUsers(false);
    }
  };

  const loadPenduduk = async (desaId = selectedDesa) => {
    try {
      setLoadingPenduduk(true);
      const params = {};
      if (desaId) params.desa_id = desaId;
      const data = await listPendudukForDropdown(params);
      setPendudukList(Array.isArray(data) ? data : []);
    } catch (error) {
      Swal.fire({ icon: "error", title: "Gagal Memuat Data", text: superadminUserErrorMessage(error, "Gagal memuat data penduduk"), confirmButtonColor: "#4f46e5" });
    } finally {
      setLoadingPenduduk(false);
    }
  };

  useEffect(() => {
    loadDesa();
    loadUsers();
    loadPenduduk("");
    loadPosyandu();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Re-fetch penduduk when desa filter changes
  useEffect(() => {
    loadPenduduk(selectedDesa);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [selectedDesa]);

  // --- Derived data ---
  const userByPendudukId = useMemo(() => {
    const map = new Map();
    users.forEach((user) => {
      if (user.penduduk_id) {
        map.set(String(user.penduduk_id), user);
      }
    });
    return map;
  }, [users]);

  const filteredPenduduk = useMemo(() => {
    const keyword = search.trim().toLowerCase();
    if (!keyword) return pendudukList;
    return pendudukList.filter((p) => {
      const name = (p.nama_anggota_keluarga || p.nama_lengkap || "").toLowerCase();
      const nik = (p.nik || "").toLowerCase();
      const kk = (p.kode_keluarga || "").toLowerCase();
      const hubungan = (p.hubungan || "").toLowerCase();
      return name.includes(keyword) || nik.includes(keyword) || kk.includes(keyword) || hubungan.includes(keyword);
    });
  }, [pendudukList, search]);

  // Paginated data
  const paginatedPenduduk = useMemo(() => {
    const startIndex = (currentPage - 1) * itemsPerPage;
    const endIndex = startIndex + itemsPerPage;
    return filteredPenduduk.slice(startIndex, endIndex);
  }, [filteredPenduduk, currentPage, itemsPerPage]);

  // Reset to page 1 when search or filter changes
  useEffect(() => {
    setCurrentPage(1);
  }, [search, selectedDesa]);

  const stats = useMemo(() => {
    const total = pendudukList.length;
    const assignedUsers = users.filter(
      (u) => u.penduduk_id && pendudukList.some((p) => String(p.id) === String(u.penduduk_id))
    );
    const assigned = assignedUsers.length;
    const unassigned = total - assigned;
    const bidanCount = assignedUsers.filter((u) => (u.role || "").toLowerCase() === "bidan").length;
    const kaderCount = assignedUsers.filter((u) => (u.role || "").toLowerCase() === "kader").length;
    const adminCount = assignedUsers.filter((u) => (u.role || "").toLowerCase() === "admin" || (u.role || "").toLowerCase() === "admindesa").length;

    return [
      { label: "Total Penduduk", value: total, icon: Users, tone: "bg-cyan-50 text-cyan-700" },
      { label: "Sudah Diassign", value: assigned, icon: UserCheck, tone: "bg-emerald-50 text-emerald-700" },
      { label: "Belum Diassign", value: unassigned, icon: UserX, tone: "bg-rose-50 text-rose-700" },
      { label: "Bidan", value: bidanCount, icon: ShieldPlus, tone: "bg-violet-50 text-violet-700" },
      { label: "Kader", value: kaderCount, icon: Users, tone: "bg-sky-50 text-sky-700" },
      { label: "Admin Desa", value: adminCount, icon: MapPin, tone: "bg-amber-50 text-amber-700" },
    ];
  }, [pendudukList, users]);

  // --- Actions ---
  const handleRefresh = async () => {
    await Promise.all([loadUsers(), loadPenduduk()]);
  };

  const handleSearch = () => {
    // Search is applied via filteredPenduduk useMemo, no additional fetch needed
  };

  const handleSearchKeyDown = (e) => {
    if (e.key === "Enter") handleSearch();
  };

  // --- Assign modal ---
  const openAssignModal = (penduduk) => {
    setAssignTarget(penduduk);
    setAssignForm({
      ...emptyAssignForm,
      name: penduduk.nama_anggota_keluarga || penduduk.nama_lengkap || "",
      email: penduduk.email || "",
    });
  };

  const closeAssignModal = () => {
    setAssignTarget(null);
    setAssignForm(emptyAssignForm);
  };

  const submitAssign = async (e) => {
    e.preventDefault();
    if (!assignTarget) return;

    if (!assignForm.role) {
      Swal.fire({ icon: "warning", title: "Role belum dipilih", text: "Pilih role terlebih dahulu.", confirmButtonColor: "#4f46e5" });
      return;
    }
    if (!assignForm.password.trim() || assignForm.password.trim().length < 8) {
      Swal.fire({ icon: "warning", title: "Password Terlalu Pendek", text: "Password minimal 8 karakter.", confirmButtonColor: "#4f46e5" });
      return;
    }
    if (assignForm.role === "bidan" && (!assignForm.no_str.trim() || !assignForm.no_sipb.trim())) {
      Swal.fire({ icon: "warning", title: "Data Bidan Kurang", text: "No STR dan No SIPB wajib diisi untuk Bidan.", confirmButtonColor: "#4f46e5" });
      return;
    }

    const pendudukId = Number(assignTarget.id);
    const name = assignForm.name.trim() || assignTarget.nama_anggota_keluarga || assignTarget.nama_lengkap || "";
    const email = assignForm.email.trim();
    const roleLabel = ASSIGN_ROLE_OPTIONS.find((o) => o.value === assignForm.role)?.label || assignForm.role;

    if (!name) {
      Swal.fire({ icon: "warning", title: "Nama wajib diisi", confirmButtonColor: "#4f46e5" });
      return;
    }
    if (!email) {
      Swal.fire({ icon: "warning", title: "Email wajib diisi", confirmButtonColor: "#4f46e5" });
      return;
    }

    try {
      setSubmitting(true);
      if (assignForm.role === "bidan") {
        await createBidanUser({ penduduk_id: pendudukId, name, email, password: assignForm.password.trim(), no_str: assignForm.no_str.trim(), no_sipb: assignForm.no_sipb.trim() });
      } else if (assignForm.role === "admin") {
        await createAdminDesaUser({ penduduk_id: pendudukId, name, email, password: assignForm.password.trim() });
      } else if (assignForm.role === "kader") {
        await createKaderUser({ penduduk_id: pendudukId, name, email, password: assignForm.password.trim(), posyandu_id: assignForm.posyandu_id ? Number(assignForm.posyandu_id) : undefined });
      }

      closeAssignModal();
      await Promise.all([loadUsers(), loadPenduduk()]);
      Swal.fire({ icon: "success", title: "Role Berhasil Diassign", text: `${name} telah ditetapkan sebagai ${roleLabel}.`, timer: 2000, showConfirmButton: false });
    } catch (error) {
      Swal.fire({ icon: "error", title: "Gagal Assign Role", text: superadminUserErrorMessage(error, "Gagal mengassign role"), confirmButtonColor: "#4f46e5" });
    } finally {
      setSubmitting(false);
    }
  };

  // --- Edit user ---
  const openEditModal = (user) => {
    setEditUser(user);
    setEditForm({
      ...emptyEditForm,
      name: user.name || "",
      email: user.email || "",
      password: "",
      no_str: user.no_str || "",
      no_sipb: user.no_sipb || "",
    });
    setShowEditModal(true);
  };

  const submitEditUser = async (event) => {
    event.preventDefault();
    if (!editUser) return;
    if (!editForm.name.trim()) {
      Swal.fire({ icon: "warning", title: "Nama wajib diisi", confirmButtonColor: "#4f46e5" });
      return;
    }
    if (!editForm.email.trim()) {
      Swal.fire({ icon: "warning", title: "Email wajib diisi", confirmButtonColor: "#4f46e5" });
      return;
    }
    if (editForm.password && editForm.password.trim().length < 8) {
      Swal.fire({ icon: "warning", title: "Password Terlalu Pendek", text: "Password minimal 8 karakter.", confirmButtonColor: "#4f46e5" });
      return;
    }
    try {
      setSubmitting(true);
      const payload = {
        name: editForm.name.trim(),
        email: editForm.email.trim(),
      };
      if (editForm.password.trim()) {
        payload.password = editForm.password.trim();
      }
      if (editForm.no_str.trim()) payload.no_str = editForm.no_str.trim();
      if (editForm.no_sipb.trim()) payload.no_sipb = editForm.no_sipb.trim();
      await updateSuperadminUser(editUser.id, payload);
      setShowEditModal(false);
      setEditUser(null);
      setEditForm(emptyEditForm);
      Swal.fire({ icon: "success", title: "Data Berhasil Diperbarui", timer: 1800, showConfirmButton: false });
      await Promise.all([loadUsers(), loadPenduduk()]);
    } catch (error) {
      Swal.fire({ icon: "error", title: "Gagal Memperbarui Data", text: superadminUserErrorMessage(error, "Gagal memperbarui data user"), confirmButtonColor: "#4f46e5" });
    } finally {
      setSubmitting(false);
    }
  };

  // --- Activate / Deactivate ---
  const openStatusActionModal = (user, actionType) => {
    if ((user.role || "").toLowerCase() === "superadmin") {
      Swal.fire({ icon: "warning", title: "Tidak Diizinkan", text: "Akun superadmin tidak dapat dinonaktifkan.", confirmButtonColor: "#4f46e5" });
      return;
    }
    setStatusActionUser(user);
    setStatusActionType(actionType);
  };

  const closeStatusActionModal = () => {
    setStatusActionUser(null);
    setStatusActionType("");
  };

  const confirmStatusAction = async () => {
    if (!statusActionUser || !statusActionType) return;
    try {
      setSubmitting(true);
      if (statusActionType === "activate") {
        await activateSuperadminUser(statusActionUser.id);
      } else {
        await deactivateSuperadminUser(statusActionUser.id);
      }
      closeStatusActionModal();
      await Promise.all([loadUsers(), loadPenduduk()]);
      Swal.fire({
        icon: "success",
        title: statusActionType === "activate" ? "User Berhasil Diaktifkan" : "User Berhasil Dinonaktifkan",
        timer: 1800,
        showConfirmButton: false,
      });
    } catch (error) {
      Swal.fire({
        icon: "error",
        title: "Gagal",
        text: superadminUserErrorMessage(error, statusActionType === "activate" ? "Gagal mengaktifkan user" : "Gagal menonaktifkan user"),
        confirmButtonColor: "#4f46e5",
      });
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <MainLayout>
      <div className="px-4 pb-6 pt-0 space-y-5 md:px-6">
        {/* Stats */}
        <section className="grid gap-2.5 grid-cols-2 md:grid-cols-3 xl:grid-cols-6">
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

        {/* Table section */}
        <section className="grid gap-6 xl:grid-cols-[minmax(0,1fr)]">
          <div className={`${cardClass} min-w-0 p-6 space-y-5`}>

            {/* Search & Filter Row */}
            <div className="flex flex-wrap items-center gap-3">
              <div className="flex-1 min-w-[200px] relative">
                <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
                <input
                  type="text"
                  value={search}
                  onChange={(e) => setSearch(e.target.value)}
                  onKeyDown={handleSearchKeyDown}
                  placeholder="Cari Nama atau NIK"
                  className="w-full rounded-2xl border border-slate-200 py-2.5 pl-10 pr-4"
                />
              </div>
              <button
                type="button"
                onClick={handleSearch}
                className="inline-flex items-center gap-2 rounded-2xl bg-indigo-600 px-4 py-2.5 text-sm font-semibold text-white hover:bg-indigo-700 transition-colors"
              >
                <Search size={16} />
                Cari
              </button>
              <select
                value={selectedDesa}
                onChange={(e) => setSelectedDesa(e.target.value)}
                className="rounded-2xl border border-slate-200 px-3 py-2.5"
              >
                <option value="">Semua Desa</option>
                {desasList.map((d) => (
                  <option key={d.id} value={d.id}>{d.nama_desa}</option>
                ))}
              </select>
              <button type="button" onClick={handleRefresh} className="inline-flex items-center gap-2 rounded-2xl border border-slate-200 px-4 py-2.5 text-sm font-semibold text-slate-600 hover:bg-slate-50">
                <RefreshCw size={16} />
                Refresh
              </button>
            </div>

            {/* Table */}
            <div className="overflow-x-auto rounded-2xl border border-slate-200">
              <table className="w-full min-w-[1100px]">
                <thead className="bg-slate-50 text-left text-sm text-slate-600">
                  <tr>
                    <th className="px-4 py-3 font-semibold">Email</th>
                    <th className="px-4 py-3 font-semibold">Nama</th>
                    <th className="px-4 py-3 font-semibold">Jenis Kelamin</th>
                    <th className="px-4 py-3 font-semibold">Desa</th>
                    <th className="px-4 py-3 font-semibold">Status Role</th>
                    <th className="px-4 py-3 text-center font-semibold">Aksi</th>
                  </tr>
                </thead>
                <tbody>
                  {loadingPenduduk ? (
                    <tr>
                      <td colSpan={6} className="px-4 py-10 text-center text-slate-500">Memuat data penduduk...</td>
                    </tr>
                  ) : filteredPenduduk.length === 0 ? (
                    <tr>
                      <td colSpan={6} className="px-4 py-10 text-center text-slate-500">Tidak ada data penduduk</td>
                    </tr>
                  ) : (
                    paginatedPenduduk.map((p) => {
                      const assignedUser = userByPendudukId.get(String(p.id));
                      const isSuperadmin = assignedUser && (assignedUser.role || "").toLowerCase() === "superadmin";
                      return (
                        <tr key={p.id} className="border-t border-slate-100 align-middle hover:bg-slate-50/70">
                          <td className="px-4 py-3 text-sm text-slate-700">{assignedUser?.email || p.email || "-"}</td>
                          <td className="px-4 py-3">
                            <div className="font-semibold text-slate-900 text-sm">{p.nama_anggota_keluarga || p.nama_lengkap || "-"}</div>
                            <div className="text-xs text-slate-400 mt-0.5 font-mono">{formatKodeKeluarga(p.kode_keluarga)}</div>
                          </td>
                          <td className="px-4 py-3 text-sm text-slate-600">{p.jenis_kelamin || "-"}</td>
                          <td className="px-4 py-3 text-sm text-slate-600">{p.desa?.nama_desa || "-"}</td>
                          <td className="px-4 py-3">
                            {assignedUser ? (
                              <div className="flex items-center gap-1.5 flex-nowrap">
                                <span className="inline-flex rounded-full bg-slate-100 px-2.5 py-0.5 text-xs font-medium text-slate-700 whitespace-nowrap">
                                  {assignedUser.role}
                                </span>
                                <span className={`inline-flex rounded-full px-2.5 py-0.5 text-xs font-medium whitespace-nowrap ${assignedUser.is_active ? "bg-emerald-50 text-emerald-700" : "bg-rose-50 text-rose-700"}`}>
                                  {assignedUser.is_active ? "Aktif" : "Nonaktif"}
                                </span>
                              </div>
                            ) : (
                              <span className="inline-flex rounded-full bg-slate-50 px-2.5 py-0.5 text-xs text-slate-400 whitespace-nowrap">
                                Belum diassign
                              </span>
                            )}
                          </td>
                          <td className="px-4 py-3 text-center">
                            {assignedUser ? (
                              <div className="flex items-center justify-center gap-2 flex-nowrap">
                                <button
                                  type="button"
                                  onClick={() => openEditModal(assignedUser)}
                                  title="Edit"
                                  className="inline-flex items-center gap-1.5 rounded-lg bg-amber-50 border border-amber-200 px-2.5 py-1.5 text-xs font-semibold text-amber-700 hover:bg-amber-100 whitespace-nowrap transition-colors"
                                >
                                  <Edit size={13} />
                                  Edit
                                </button>
                                <button
                                  type="button"
                                  onClick={() => openStatusActionModal(assignedUser, assignedUser.is_active ? "deactivate" : "activate")}
                                  disabled={isSuperadmin || submitting}
                                  title={isSuperadmin ? "Akun dilindungi" : assignedUser.is_active ? "Nonaktifkan" : "Aktifkan"}
                                  className={`inline-flex items-center gap-1.5 rounded-lg border px-2.5 py-1.5 text-xs font-semibold disabled:opacity-50 whitespace-nowrap transition-colors ${
                                    isSuperadmin
                                      ? "border-slate-200 bg-slate-50 text-slate-400 cursor-not-allowed"
                                      : assignedUser.is_active
                                      ? "border-rose-200 bg-rose-50 text-rose-700 hover:bg-rose-100"
                                      : "border-emerald-200 bg-emerald-50 text-emerald-700 hover:bg-emerald-100"
                                  }`}
                                >
                                  <Power size={13} />
                                  {isSuperadmin ? "Protected" : assignedUser.is_active ? "Nonaktif" : "Aktifkan"}
                                </button>
                              </div>
                            ) : (
                              <button
                                type="button"
                                onClick={() => openAssignModal(p)}
                                className="inline-flex items-center gap-1.5 rounded-lg bg-indigo-600 px-3 py-1.5 text-xs font-semibold text-white hover:bg-indigo-700 whitespace-nowrap transition-colors"
                              >
                                <ShieldPlus size={13} />
                                Assign Role
                              </button>
                            )}
                          </td>
                        </tr>
                      );
                    })
                  )}
                </tbody>
              </table>
            </div>

            {/* Pagination */}
            {!loadingPenduduk && filteredPenduduk.length > 0 && (
              <Pagination
                currentPage={currentPage}
                totalPages={Math.ceil(filteredPenduduk.length / itemsPerPage)}
                totalItems={filteredPenduduk.length}
                itemsPerPage={itemsPerPage}
                onPageChange={(page) => setCurrentPage(page)}
                loading={loadingPenduduk}
              />
            )}
          </div>
        </section>
      </div>

      {/* Assign Role Modal */}
      {assignTarget && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-950/50 px-4 py-6 overflow-y-auto">
          <div className="w-full max-w-xl rounded-2xl bg-white shadow-2xl overflow-hidden my-auto">

            {/* Header */}
            <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100">
              <div>
                <h2 className="text-lg font-bold text-slate-800">Buat Akun & Assign Role</h2>
                <p className="text-xs text-slate-500 mt-0.5">Isi data akun pengguna untuk penduduk ini</p>
              </div>
              <button onClick={closeAssignModal} className="p-2 rounded-lg hover:bg-slate-100 text-slate-500">
                <X size={18} />
              </button>
            </div>

            <form onSubmit={submitAssign} className="p-6 space-y-5">

              {/* Info penduduk (read-only) */}
              <div className="rounded-xl bg-indigo-50 border border-indigo-100 px-4 py-3 flex flex-wrap gap-x-6 gap-y-1.5 text-sm">
                <div>
                  <span className="text-indigo-400 text-xs">NIK</span>
                  <p className="font-semibold text-slate-800 font-mono">{formatNik(assignTarget.nik)}</p>
                </div>
                <div>
                  <span className="text-indigo-400 text-xs">Nama Penduduk</span>
                  <p className="font-semibold text-slate-800">{assignTarget.nama_anggota_keluarga || assignTarget.nama_lengkap || "-"}</p>
                </div>
                <div>
                  <span className="text-indigo-400 text-xs">Desa</span>
                  <p className="font-semibold text-slate-800">{assignTarget.desa?.nama_desa || "-"}</p>
                </div>
              </div>

              {/* ── Bagian 1: Data Akun ── */}
              <div>
                <p className="text-xs font-semibold text-slate-500 uppercase tracking-wider mb-3">Data Akun Pengguna</p>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-3">

                  {/* Nama Akun */}
                  <div className="md:col-span-2">
                    <label className="block text-sm font-medium text-slate-700 mb-1">
                      Nama Lengkap <span className="text-red-500">*</span>
                    </label>
                    <input
                      type="text"
                      value={assignForm.name}
                      onChange={(e) => setAssignForm((prev) => ({ ...prev, name: e.target.value }))}
                      placeholder="Nama yang ditampilkan di akun"
                      className="w-full rounded-xl border border-slate-200 px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
                      required
                    />
                  </div>

                  {/* Email */}
                  <div>
                    <label className="block text-sm font-medium text-slate-700 mb-1">
                      Email <span className="text-red-500">*</span>
                    </label>
                    <input
                      type="email"
                      value={assignForm.email}
                      onChange={(e) => setAssignForm((prev) => ({ ...prev, email: e.target.value }))}
                      placeholder="contoh@email.com"
                      className="w-full rounded-xl border border-slate-200 px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
                      required
                    />
                  </div>

                  {/* Password */}
                  <div>
                    <label className="block text-sm font-medium text-slate-700 mb-1">
                      Password <span className="text-red-500">*</span>
                    </label>
                    <div className="relative">
                      <input
                        type={assignForm.showPassword ? "text" : "password"}
                        value={assignForm.password}
                        onChange={(e) => setAssignForm((prev) => ({ ...prev, password: e.target.value }))}
                        placeholder="Minimal 8 karakter"
                        className="w-full rounded-xl border border-slate-200 px-3 py-2.5 pr-10 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
                        required
                      />
                      <button
                        type="button"
                        onClick={() => setAssignForm((prev) => ({ ...prev, showPassword: !prev.showPassword }))}
                        className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600"
                      >
                        {assignForm.showPassword ? (
                          <svg xmlns="http://www.w3.org/2000/svg" className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21" /></svg>
                        ) : (
                          <svg xmlns="http://www.w3.org/2000/svg" className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" /><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" /></svg>
                        )}
                      </button>
                    </div>
                    <p className="text-xs text-slate-400 mt-1">Minimal 8 karakter</p>
                  </div>
                </div>
              </div>

              {/* ── Bagian 2: Role ── */}
              <div>
                <p className="text-xs font-semibold text-slate-500 uppercase tracking-wider mb-3">Role & Penugasan</p>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-3">

                  {/* Role */}
                  <div className={assignForm.role === "kader" ? "" : ""}>
                    <label className="block text-sm font-medium text-slate-700 mb-1">
                      Role <span className="text-red-500">*</span>
                    </label>
                    <select
                      value={assignForm.role}
                      onChange={(e) => setAssignForm((prev) => ({ ...prev, role: e.target.value, no_str: "", no_sipb: "", posyandu_id: "" }))}
                      className="w-full rounded-xl border border-slate-200 px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
                      required
                    >
                      {ASSIGN_ROLE_OPTIONS.map((opt) => (
                        <option key={opt.value} value={opt.value}>{opt.label}</option>
                      ))}
                    </select>
                  </div>

                  {/* Kader: Posyandu */}
                  {assignForm.role === "kader" && (
                    <div>
                      <label className="block text-sm font-medium text-slate-700 mb-1">Posyandu</label>
                      <select
                        value={assignForm.posyandu_id}
                        onChange={(e) => setAssignForm((prev) => ({ ...prev, posyandu_id: e.target.value }))}
                        className="w-full rounded-xl border border-slate-200 px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
                      >
                        <option value="">{loadingPosyandu ? "Memuat..." : "-- Pilih Posyandu (opsional) --"}</option>
                        {posyanduOptions.map((pos) => (
                          <option key={pos.id} value={pos.id}>{pos.nama}{pos.alamat ? ` — ${pos.alamat}` : ""}</option>
                        ))}
                      </select>
                    </div>
                  )}

                  {/* Bidan: No STR & No SIPB */}
                  {assignForm.role === "bidan" && (
                    <>
                      <div>
                        <label className="block text-sm font-medium text-slate-700 mb-1">No. STR <span className="text-red-500">*</span></label>
                        <input
                          type="text"
                          value={assignForm.no_str}
                          onChange={(e) => setAssignForm((prev) => ({ ...prev, no_str: e.target.value }))}
                          placeholder="Nomor Surat Tanda Registrasi"
                          className="w-full rounded-xl border border-slate-200 px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
                          required
                        />
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-slate-700 mb-1">No. SIPB <span className="text-red-500">*</span></label>
                        <input
                          type="text"
                          value={assignForm.no_sipb}
                          onChange={(e) => setAssignForm((prev) => ({ ...prev, no_sipb: e.target.value }))}
                          placeholder="Nomor Surat Izin Praktik Bidan"
                          className="w-full rounded-xl border border-slate-200 px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
                          required
                        />
                      </div>
                    </>
                  )}
                </div>
              </div>

              {/* Action Buttons */}
              <div className="flex items-center justify-end gap-3 pt-2 border-t border-slate-100">
                <button
                  type="button"
                  onClick={closeAssignModal}
                  className="rounded-xl border border-slate-200 px-4 py-2.5 text-sm font-semibold text-slate-600 hover:bg-slate-50 transition-colors"
                >
                  Batal
                </button>
                <button
                  type="submit"
                  disabled={submitting}
                  className="inline-flex items-center gap-2 rounded-xl bg-indigo-600 px-5 py-2.5 text-sm font-semibold text-white hover:bg-indigo-700 disabled:opacity-60 transition-colors"
                >
                  {submitting ? <Loader2 size={15} className="animate-spin" /> : <ShieldPlus size={15} />}
                  {submitting ? "Membuat Akun..." : "Buat Akun & Assign"}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Edit User Modal */}
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

              {/* Bidan-specific fields */}
              {(editUser.role || "").toLowerCase() === "bidan" && (
                <div>
                  <p className="text-xs font-semibold text-slate-500 uppercase tracking-wider mb-3">Data Bidan</p>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                    <div>
                      <label className="block text-sm font-medium text-slate-700 mb-1">No. STR</label>
                      <input
                        type="text"
                        value={editForm.no_str}
                        onChange={(e) => setEditForm((prev) => ({ ...prev, no_str: e.target.value }))}
                        placeholder="Nomor Surat Tanda Registrasi"
                        className="w-full rounded-xl border border-slate-200 px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-700 mb-1">No. SIPB</label>
                      <input
                        type="text"
                        value={editForm.no_sipb}
                        onChange={(e) => setEditForm((prev) => ({ ...prev, no_sipb: e.target.value }))}
                        placeholder="Nomor Surat Izin Praktik Bidan"
                        className="w-full rounded-xl border border-slate-200 px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
                      />
                    </div>
                  </div>
                </div>
              )}

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

      {/* Activate/Deactivate Modal */}
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
              <button type="button" onClick={closeStatusActionModal} className="rounded-2xl bg-slate-100 px-4 py-2.5 text-sm font-semibold text-slate-700 hover:bg-slate-200" disabled={submitting}>
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

    </MainLayout>
  );
};

export default UserManagement;
