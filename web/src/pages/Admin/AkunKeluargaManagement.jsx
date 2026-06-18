import React, { useEffect, useState } from "react";
import { Loader2, Pencil, RefreshCw, Save, Search, Trash2, UserPlus } from "lucide-react";
import MainLayout from "../../components/Layout/MainLayout";
import {
  addAnggotaKeluargaAdmin,
  adminAkunKeluargaErrorMessage,
  deleteAnggotaKeluargaAdmin,
  deleteKartuKeluargaAdmin,
  detailKartuKeluargaAdmin,
  listKartuKeluargaAdmin,
  updateAnggotaKeluargaAdmin,
  updateKartuKeluargaAdmin,
} from "../../services/adminAkunKeluarga";
import { listDesa } from "../../services/desa";

// Dropdown options
const GOLONGAN_DARAH_OPTIONS = ["", "A", "B", "AB", "O", "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"];
const AGAMA_OPTIONS = ["", "Islam", "Kristen Protestan", "Katolik", "Hindu", "Buddha", "Konghucu"];
const PENDIDIKAN_OPTIONS = ["", "Tidak/Belum Sekolah", "Belum Tamat SD/Sederajat", "Tamat SD/Sederajat", "SLTP/Sederajat", "SLTA/Sederajat", "Diploma I/II", "Akademi/Diploma III/S.Muda", "Diploma IV/Strata I", "Strata II", "Strata III"];

// Validation helpers
const validateNIK = (nik) => {
  if (!nik) return { valid: false, message: "NIK wajib diisi" };
  if (!/^\d+$/.test(nik)) return { valid: false, message: "NIK hanya boleh berisi angka" };
  if (nik.length !== 16) return { valid: false, message: "NIK harus 16 digit" };
  return { valid: true, message: "" };
};

const validateNoKK = (noKK) => {
  if (!noKK) return { valid: false, message: "No KK wajib diisi" };
  if (!/^\d+$/.test(noKK)) return { valid: false, message: "No KK hanya boleh berisi angka" };
  if (noKK.length !== 16) return { valid: false, message: "No KK harus 16 digit" };
  return { valid: true, message: "" };
};

const handleNumericInput = (value, maxLength = 16) => {
  // Remove non-digit characters and limit length
  return value.replace(/\D/g, '').slice(0, maxLength);
};

const emptyMember = {
  nik: "",
  nama_lengkap: "",
  jenis_kelamin: "Laki-laki",
  tanggal_lahir: "",
  tempat_lahir: "",
  golongan_darah: "",
  agama: "",
  status_perkawinan: "",
  pekerjaan: "",
  pendidikan_terakhir: "",
  baca_huruf: "Ya",
  kedudukan_keluarga: "",
  dusun: "",
  asal_penduduk: "Lahir",
  tujuan_pindah: "",
  tempat_meninggal: "",
  keterangan: "",
  kecamatan: "",
  desa_id: "",
  is_non_ktp: "false",
  telepon: "",
  tanggal_penambahan: "",
  tanggal_pengurangan: "",
};

const cardClass = "bg-white rounded-2xl shadow-sm border border-slate-100";

const AkunKeluargaManagement = () => {
  const [filters, setFilters] = useState({ search: "", page: 1, limit: 10 });
  const [listData, setListData] = useState([]);
  const [pagination, setPagination] = useState({ page: 1, limit: 10, total: 0, total_pages: 0 });
  const [selectedKKId, setSelectedKKId] = useState(null);

  const [headerForm, setHeaderForm] = useState({
    no_kk: "",
    tanggal_terbit: "",
  });

  const [detail, setDetail] = useState(null);
  const [addForm, setAddForm] = useState(emptyMember);
  const [editingPendudukId, setEditingPendudukId] = useState(null);
  const [editMemberForm, setEditMemberForm] = useState(emptyMember);

  const [loadingList, setLoadingList] = useState(false);
  const [loadingDetail, setLoadingDetail] = useState(false);
  const [saving, setSaving] = useState(false);
  const [errorMessage, setErrorMessage] = useState("");
  const [successMessage, setSuccessMessage] = useState("");
  const [desasList, setDesasList] = useState([]);

  useEffect(() => {
    const fetchDesas = async () => {
      try {
        const data = await listDesa();
        setDesasList(data);
      } catch (err) {
        console.error("Gagal memuat daftar desa", err);
      }
    };
    fetchDesas();
  }, []);

  const resetNotice = () => {
    setErrorMessage("");
    setSuccessMessage("");
  };

  const loadList = async (override = {}) => {
    setLoadingList(true);
    try {
      const query = {
        search: override.search ?? filters.search,
        page: override.page ?? filters.page,
        limit: override.limit ?? filters.limit,
        sort_by: "created_at",
        sort_dir: "desc",
      };
      const data = await listKartuKeluargaAdmin(query);
      setListData(Array.isArray(data.items) ? data.items : []);
      setPagination(data.pagination || { page: 1, limit: query.limit, total: 0, total_pages: 0 });
    } catch (error) {
      setErrorMessage(adminAkunKeluargaErrorMessage(error, "Gagal memuat daftar kartu keluarga"));
    } finally {
      setLoadingList(false);
    }
  };

  const loadDetail = async (kartuKeluargaId) => {
    if (!kartuKeluargaId) return;
    setLoadingDetail(true);
    try {
      const data = await detailKartuKeluargaAdmin(kartuKeluargaId);
      setDetail(data);
      setHeaderForm({
        no_kk: data?.no_kk || "",
        tanggal_terbit: data?.tanggal_terbit || "",
      });
    } catch (error) {
      setErrorMessage(adminAkunKeluargaErrorMessage(error, "Gagal memuat detail kartu keluarga"));
    } finally {
      setLoadingDetail(false);
    }
  };

  useEffect(() => {
    loadList();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const handleSearch = (e) => {
    e.preventDefault();
    resetNotice();
    const next = { ...filters, page: 1 };
    setFilters(next);
    loadList(next);
  };

  const handleSelectKK = async (kartuKeluargaId) => {
    resetNotice();
    setSelectedKKId(kartuKeluargaId);
    setEditingPendudukId(null);
    await loadDetail(kartuKeluargaId);
  };

  const handleSaveHeader = async () => {
    if (!selectedKKId) return;
    
    // Validate No KK
    const noKKValidation = validateNoKK(headerForm.no_kk);
    if (!noKKValidation.valid) {
      setErrorMessage(noKKValidation.message);
      return;
    }

    resetNotice();
    setSaving(true);
    try {
      await updateKartuKeluargaAdmin(selectedKKId, headerForm);
      await Promise.all([loadDetail(selectedKKId), loadList()]);
      setSuccessMessage("Data kartu keluarga berhasil diperbarui");
    } catch (error) {
      setErrorMessage(adminAkunKeluargaErrorMessage(error, "Gagal memperbarui kartu keluarga"));
    } finally {
      setSaving(false);
    }
  };

  const startEditMember = (member) => {
    setEditingPendudukId(member.penduduk_id);
    setEditMemberForm({
      nik: member.nik || "",
      nama_lengkap: member.nama_lengkap || "",
      jenis_kelamin: member.jenis_kelamin || "Laki-laki",
      tanggal_lahir: member.tanggal_lahir || "",
      tempat_lahir: member.tempat_lahir || "",
      golongan_darah: member.golongan_darah || "",
      agama: member.agama || "",
      status_perkawinan: member.status_perkawinan || "",
      pekerjaan: member.pekerjaan || "",
      pendidikan_terakhir: member.pendidikan_terakhir || "",
      baca_huruf: member.baca_huruf || "Ya",
      kedudukan_keluarga: member.kedudukan_keluarga || "",
      dusun: member.dusun || "",
      asal_penduduk: member.asal_penduduk || "Lahir",
      tujuan_pindah: member.tujuan_pindah || "",
      tempat_meninggal: member.tempat_meninggal || "",
      keterangan: member.keterangan || "",
      kecamatan: member.kecamatan || "",
      desa_id: member.desa_id || "",
      is_non_ktp: member.is_non_ktp ? "true" : "false",
      telepon: member.telepon || "",
      tanggal_penambahan: member.tanggal_penambahan || "",
      tanggal_pengurangan: member.tanggal_pengurangan || "",
    });
  };

  const saveEditMember = async () => {
    if (!selectedKKId || !editingPendudukId) return;
    
    // Validate NIK
    const nikValidation = validateNIK(editMemberForm.nik);
    if (!nikValidation.valid) {
      setErrorMessage(nikValidation.message);
      return;
    }
    
    if (!editMemberForm.nama_lengkap) {
      setErrorMessage("Nama lengkap anggota wajib diisi");
      return;
    }

    resetNotice();
    setSaving(true);
    try {
      const payload = {
        ...editMemberForm,
        desa_id: editMemberForm.desa_id ? parseInt(editMemberForm.desa_id, 10) : null,
        is_non_ktp: editMemberForm.is_non_ktp === "true",
      };
      await updateAnggotaKeluargaAdmin(selectedKKId, editingPendudukId, payload);
      setEditingPendudukId(null);
      await Promise.all([loadDetail(selectedKKId), loadList()]);
      setSuccessMessage("Data anggota keluarga berhasil diperbarui");
    } catch (error) {
      setErrorMessage(adminAkunKeluargaErrorMessage(error, "Gagal memperbarui anggota keluarga"));
    } finally {
      setSaving(false);
    }
  };

  const handleAddMember = async () => {
    if (!selectedKKId) return;
    
    // Validate NIK
    const nikValidation = validateNIK(addForm.nik);
    if (!nikValidation.valid) {
      setErrorMessage(nikValidation.message);
      return;
    }
    
    if (!addForm.nama_lengkap || !addForm.tanggal_lahir) {
      setErrorMessage("Nama lengkap dan tanggal lahir anggota baru wajib diisi");
      return;
    }

    resetNotice();
    setSaving(true);
    try {
      const payload = {
        ...addForm,
        desa_id: addForm.desa_id ? parseInt(addForm.desa_id, 10) : null,
        is_non_ktp: addForm.is_non_ktp === "true",
      };
      await addAnggotaKeluargaAdmin(selectedKKId, payload);
      setAddForm(emptyMember);
      await Promise.all([loadDetail(selectedKKId), loadList()]);
      setSuccessMessage("Anggota keluarga berhasil ditambahkan");
    } catch (error) {
      setErrorMessage(adminAkunKeluargaErrorMessage(error, "Gagal menambahkan anggota keluarga"));
    } finally {
      setSaving(false);
    }
  };

  const handleDeleteMember = async (pendudukId) => {
    if (!selectedKKId) return;
    if (!window.confirm("Hapus anggota ini?")) return;

    resetNotice();
    setSaving(true);
    try {
      await deleteAnggotaKeluargaAdmin(selectedKKId, pendudukId);
      await Promise.all([loadDetail(selectedKKId), loadList()]);
      setSuccessMessage("Anggota keluarga berhasil dihapus");
    } catch (error) {
      setErrorMessage(adminAkunKeluargaErrorMessage(error, "Gagal menghapus anggota keluarga"));
    } finally {
      setSaving(false);
    }
  };

  const handleDeleteKK = async () => {
    if (!selectedKKId) return;
    if (!window.confirm("Hapus kartu keluarga ini?")) return;

    resetNotice();
    setSaving(true);
    try {
      await deleteKartuKeluargaAdmin(selectedKKId);
      setSelectedKKId(null);
      setDetail(null);
      setEditingPendudukId(null);
      await loadList();
      setSuccessMessage("Kartu keluarga berhasil dihapus");
    } catch (error) {
      setErrorMessage(adminAkunKeluargaErrorMessage(error, "Gagal menghapus kartu keluarga"));
    } finally {
      setSaving(false);
    }
  };

  return (
    <MainLayout>
      <div className="space-y-6">

        {errorMessage && <div className="rounded-xl bg-red-50 border border-red-200 px-4 py-3 text-red-700 text-sm">{errorMessage}</div>}
        {successMessage && <div className="rounded-xl bg-emerald-50 border border-emerald-200 px-4 py-3 text-emerald-700 text-sm">{successMessage}</div>}

        <section className={`${cardClass} p-5`}>
          <form onSubmit={handleSearch} className="grid grid-cols-1 md:grid-cols-5 gap-3">
            <div className="md:col-span-3">
              <label className="text-sm text-slate-600">Cari KK / Kepala Keluarga / NIK</label>
              <input
                type="text"
                value={filters.search}
                onChange={(e) => setFilters((prev) => ({ ...prev, search: e.target.value }))}
                className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2"
                placeholder="contoh: 3201... / Budi / 3201..."
              />
            </div>
            <div>
              <label className="text-sm text-slate-600">Limit</label>
              <select
                value={filters.limit}
                onChange={(e) => setFilters((prev) => ({ ...prev, limit: Number(e.target.value) }))}
                className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2"
              >
                <option value={10}>10</option>
                <option value={20}>20</option>
                <option value={50}>50</option>
              </select>
            </div>
            <div className="flex items-end gap-2">
              <button type="submit" className="inline-flex items-center gap-2 rounded-xl bg-blue-600 text-white px-4 py-2 hover:bg-blue-700">
                <Search size={16} />
                Cari
              </button>
              <button type="button" onClick={() => loadList()} className="inline-flex items-center gap-2 rounded-xl bg-slate-100 text-slate-700 px-4 py-2 hover:bg-slate-200">
                <RefreshCw size={16} />
                Muat Ulang
              </button>
            </div>
          </form>
        </section>

        <section className="grid grid-cols-1 xl:grid-cols-3 gap-5">
          <div className={`${cardClass} p-5 xl:col-span-1`}>
            <h2 className="text-lg font-semibold text-slate-800">Daftar KK</h2>
            {loadingList ? (
              <div className="py-10 flex justify-center text-slate-500">
                <Loader2 className="animate-spin" size={20} />
              </div>
            ) : (
              <div className="mt-4 space-y-2">
                {listData.map((item) => (
                  <button
                    key={item.kartu_keluarga_id}
                    type="button"
                    onClick={() => handleSelectKK(item.kartu_keluarga_id)}
                    className={`w-full text-left rounded-xl border px-3 py-3 transition ${selectedKKId === item.kartu_keluarga_id
                        ? "border-blue-300 bg-blue-50"
                        : "border-slate-200 hover:bg-slate-50"
                      }`}
                  >
                    <p className="font-semibold text-slate-800">{item.no_kk}</p>
                    <p className="text-sm text-slate-500">Anggota: {item.jumlah_anggota || 0}</p>
                    <p className="text-xs text-slate-500 mt-1">
                      Kepala: {item.kepala_keluarga?.nama_lengkap || "-"}
                    </p>
                  </button>
                ))}
                {listData.length === 0 && <p className="text-sm text-slate-500">Belum ada data.</p>}
              </div>
            )}

            <div className="mt-4 flex items-center justify-between text-sm text-slate-600">
              <span>
                Halaman {pagination.page || 1} / {pagination.total_pages || 1}
              </span>
              <div className="flex gap-2">
                <button
                  type="button"
                  onClick={() => {
                    if ((pagination.page || 1) <= 1) return;
                    const next = { ...filters, page: (pagination.page || 1) - 1 };
                    setFilters(next);
                    loadList(next);
                  }}
                  className="px-3 py-1 rounded-lg border border-slate-200 disabled:opacity-40"
                  disabled={(pagination.page || 1) <= 1 || loadingList}
                >
                  Prev
                </button>
                <button
                  type="button"
                  onClick={() => {
                    if ((pagination.page || 1) >= (pagination.total_pages || 1)) return;
                    const next = { ...filters, page: (pagination.page || 1) + 1 };
                    setFilters(next);
                    loadList(next);
                  }}
                  className="px-3 py-1 rounded-lg border border-slate-200 disabled:opacity-40"
                  disabled={(pagination.page || 1) >= (pagination.total_pages || 1) || loadingList}
                >
                  Next
                </button>
              </div>
            </div>
          </div>

          <div className={`${cardClass} p-5 xl:col-span-2`}>
            {!selectedKKId ? (
              <p className="text-slate-500">Pilih kartu keluarga dari daftar kiri untuk melihat detail.</p>
            ) : loadingDetail ? (
              <div className="py-10 flex justify-center text-slate-500">
                <Loader2 className="animate-spin" size={20} />
              </div>
            ) : (
              <div className="space-y-5">
                <div className="flex items-center justify-between">
                  <h2 className="text-lg font-semibold text-slate-800">Detail KK</h2>
                  <button
                    type="button"
                    onClick={handleDeleteKK}
                    className="inline-flex items-center gap-2 rounded-xl bg-red-600 text-white px-3 py-2 hover:bg-red-700"
                    disabled={saving}
                  >
                    <Trash2 size={16} />
                    Hapus KK
                  </button>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                  <div>
                    <label className="text-sm text-slate-600">No KK <span className="text-red-500">*</span></label>
                    <input
                      type="text"
                      value={headerForm.no_kk}
                      onChange={(e) => setHeaderForm((prev) => ({ ...prev, no_kk: handleNumericInput(e.target.value, 16) }))}
                      className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2"
                      placeholder="16 digit angka"
                      maxLength={16}
                    />
                    <p className="text-xs text-slate-500 mt-0.5">{headerForm.no_kk.length}/16 digit</p>
                  </div>
                  <div>
                    <label className="text-sm text-slate-600">Tanggal Terbit</label>
                    <input
                      type="date"
                      value={headerForm.tanggal_terbit || ""}
                      onChange={(e) => setHeaderForm((prev) => ({ ...prev, tanggal_terbit: e.target.value }))}
                      className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2"
                    />
                  </div>
                </div>

                <button
                  type="button"
                  onClick={handleSaveHeader}
                  className="inline-flex items-center gap-2 rounded-xl bg-indigo-600 text-white px-4 py-2 hover:bg-indigo-700 disabled:opacity-60"
                  disabled={saving}
                >
                  <Save size={16} />
                  Simpan Perubahan KK
                </button>

                <div className="pt-2 border-t border-slate-100">
                  <h3 className="text-base font-semibold text-slate-800">Anggota Keluarga</h3>
                  <div className="space-y-3 mt-3">
                    {(detail?.anggota_keluarga || []).map((member) => (
                      <div key={member.penduduk_id} className="rounded-xl border border-slate-200 p-3">
                        {editingPendudukId === member.penduduk_id ? (
                          <div className="space-y-3">
                            <div className="grid grid-cols-1 md:grid-cols-3 gap-2">
                              <input
                                value={editMemberForm.nik}
                                onChange={(e) => setEditMemberForm((prev) => ({ ...prev, nik: handleNumericInput(e.target.value, 16) }))}
                                className="rounded-xl border border-slate-200 px-3 py-2"
                                placeholder="NIK (16 digit)"
                                maxLength={16}
                              />
                              <span className="text-xs text-slate-500">{editMemberForm.nik.length}/16</span>
                              <input
                                value={editMemberForm.nama_lengkap}
                                onChange={(e) => setEditMemberForm((prev) => ({ ...prev, nama_lengkap: e.target.value }))}
                                className="rounded-xl border border-slate-200 px-3 py-2"
                                placeholder="Nama lengkap"
                              />
                              <input
                                type="date"
                                value={editMemberForm.tanggal_lahir}
                                onChange={(e) => setEditMemberForm((prev) => ({ ...prev, tanggal_lahir: e.target.value }))}
                                className="rounded-xl border border-slate-200 px-3 py-2"
                              />
                              <input
                                value={editMemberForm.kedudukan_keluarga}
                                onChange={(e) => setEditMemberForm((prev) => ({ ...prev, kedudukan_keluarga: e.target.value }))}
                                className="rounded-xl border border-slate-200 px-3 py-2"
                                placeholder="Kedudukan keluarga"
                              />
                              <input
                                value={editMemberForm.jenis_kelamin}
                                onChange={(e) => setEditMemberForm((prev) => ({ ...prev, jenis_kelamin: e.target.value }))}
                                className="rounded-xl border border-slate-200 px-3 py-2"
                                placeholder="Jenis kelamin"
                              />
                              <select
                                value={editMemberForm.desa_id}
                                onChange={(e) => setEditMemberForm((prev) => ({ ...prev, desa_id: e.target.value }))}
                                className="rounded-xl border border-slate-200 px-3 py-2"
                              >
                                <option value="">-- Pilih Desa --</option>
                                {desasList.map(d => (
                                  <option key={d.id} value={d.id}>{d.nama_desa}</option>
                                ))}
                              </select>
                              <input
                                value={editMemberForm.kecamatan}
                                onChange={(e) => setEditMemberForm((prev) => ({ ...prev, kecamatan: e.target.value }))}
                                className="rounded-xl border border-slate-200 px-3 py-2"
                                placeholder="Kecamatan"
                              />
                              <select
                                value={editMemberForm.is_non_ktp}
                                onChange={(e) => setEditMemberForm((prev) => ({ ...prev, is_non_ktp: e.target.value }))}
                                className="rounded-xl border border-slate-200 px-3 py-2"
                              >
                                <option value="false">KTP Warga Setempat: Ya</option>
                                <option value="true">KTP Warga Setempat: Tidak</option>
                              </select>
                              <input
                                value={editMemberForm.telepon}
                                onChange={(e) => setEditMemberForm((prev) => ({ ...prev, telepon: e.target.value }))}
                                className="rounded-xl border border-slate-200 px-3 py-2"
                                placeholder="No. Telepon"
                              />
                              <input
                                type="date"
                                value={editMemberForm.tanggal_penambahan}
                                onChange={(e) => setEditMemberForm((prev) => ({ ...prev, tanggal_penambahan: e.target.value }))}
                                className="rounded-xl border border-slate-200 px-3 py-2"
                                placeholder="Tanggal Penambahan"
                              />
                              <input
                                type="date"
                                value={editMemberForm.tanggal_pengurangan}
                                onChange={(e) => setEditMemberForm((prev) => ({ ...prev, tanggal_pengurangan: e.target.value }))}
                                className="rounded-xl border border-slate-200 px-3 py-2"
                                placeholder="Tanggal Pengurangan"
                              />
                            </div>
                            <div className="flex gap-2">
                              <button
                                type="button"
                                onClick={saveEditMember}
                                className="inline-flex items-center gap-2 rounded-xl bg-blue-600 text-white px-3 py-2 hover:bg-blue-700"
                              >
                                <Save size={14} />
                                Simpan
                              </button>
                              <button
                                type="button"
                                onClick={() => setEditingPendudukId(null)}
                                className="rounded-xl bg-slate-100 text-slate-700 px-3 py-2 hover:bg-slate-200"
                              >
                                Batal
                              </button>
                            </div>
                          </div>
                        ) : (
                          <div className="flex items-center justify-between gap-3">
                            <div>
                              <p className="font-semibold text-slate-800">{member.nama_lengkap}</p>
                              <p className="text-sm text-slate-600">{member.nik} • {member.kedudukan_keluarga || "-"}{member.telepon && ` • ${member.telepon}`}</p>
                            </div>
                            <div className="flex gap-2">
                              <button
                                type="button"
                                onClick={() => startEditMember(member)}
                                className="inline-flex items-center gap-1 rounded-lg bg-slate-100 text-slate-700 px-2 py-1 hover:bg-slate-200"
                              >
                                <Pencil size={14} />
                                Edit
                              </button>
                              <button
                                type="button"
                                onClick={() => handleDeleteMember(member.penduduk_id)}
                                className="inline-flex items-center gap-1 rounded-lg bg-red-50 text-red-700 px-2 py-1 hover:bg-red-100"
                              >
                                <Trash2 size={14} />
                                Hapus
                              </button>
                            </div>
                          </div>
                        )}
                      </div>
                    ))}
                  </div>
                </div>

                <div className="pt-2 border-t border-slate-100">
                  <h3 className="text-base font-semibold text-slate-800">Tambah Anggota</h3>
                  <div className="grid grid-cols-1 md:grid-cols-3 gap-2 mt-2">
                    <input
                      value={addForm.nik}
                      onChange={(e) => setAddForm((prev) => ({ ...prev, nik: handleNumericInput(e.target.value, 16) }))}
                      className="rounded-xl border border-slate-200 px-3 py-2"
                      placeholder="NIK (16 digit)"
                      maxLength={16}
                    />
                    <span className="text-xs text-slate-500">{addForm.nik.length}/16</span>
                    <input
                      value={addForm.nama_lengkap}
                      onChange={(e) => setAddForm((prev) => ({ ...prev, nama_lengkap: e.target.value }))}
                      className="rounded-xl border border-slate-200 px-3 py-2"
                      placeholder="Nama lengkap"
                    />
                    <input
                      type="date"
                      value={addForm.tanggal_lahir}
                      onChange={(e) => setAddForm((prev) => ({ ...prev, tanggal_lahir: e.target.value }))}
                      className="rounded-xl border border-slate-200 px-3 py-2"
                    />
                    <input
                      value={addForm.kedudukan_keluarga}
                      onChange={(e) => setAddForm((prev) => ({ ...prev, kedudukan_keluarga: e.target.value }))}
                      className="rounded-xl border border-slate-200 px-3 py-2"
                      placeholder="Kedudukan keluarga"
                    />
                    <select
                      value={addForm.jenis_kelamin}
                      onChange={(e) => setAddForm((prev) => ({ ...prev, jenis_kelamin: e.target.value }))}
                      className="rounded-xl border border-slate-200 px-3 py-2"
                    >
                      <option>Laki-laki</option>
                      <option>Perempuan</option>
                    </select>
                    <select
                      value={addForm.desa_id}
                      onChange={(e) => setAddForm((prev) => ({ ...prev, desa_id: e.target.value }))}
                      className="rounded-xl border border-slate-200 px-3 py-2"
                    >
                      <option value="">-- Pilih Desa --</option>
                      {desasList.map(d => (
                        <option key={d.id} value={d.id}>{d.nama_desa}</option>
                      ))}
                    </select>
                    <input
                      value={addForm.kecamatan}
                      onChange={(e) => setAddForm((prev) => ({ ...prev, kecamatan: e.target.value }))}
                      className="rounded-xl border border-slate-200 px-3 py-2"
                      placeholder="Kecamatan"
                    />
                    <select
                      value={addForm.is_non_ktp}
                      onChange={(e) => setAddForm((prev) => ({ ...prev, is_non_ktp: e.target.value }))}
                      className="rounded-xl border border-slate-200 px-3 py-2"
                    >
                      <option value="false">KTP Warga Setempat: Ya</option>
                      <option value="true">KTP Warga Setempat: Tidak</option>
                    </select>
                    <input
                      value={addForm.telepon}
                      onChange={(e) => setAddForm((prev) => ({ ...prev, telepon: e.target.value }))}
                      className="rounded-xl border border-slate-200 px-3 py-2"
                      placeholder="No. Telepon"
                    />
                    <input
                      type="date"
                      value={addForm.tanggal_penambahan}
                      onChange={(e) => setAddForm((prev) => ({ ...prev, tanggal_penambahan: e.target.value }))}
                      className="rounded-xl border border-slate-200 px-3 py-2"
                      placeholder="Tanggal Penambahan"
                    />
                    <input
                      type="date"
                      value={addForm.tanggal_pengurangan}
                      onChange={(e) => setAddForm((prev) => ({ ...prev, tanggal_pengurangan: e.target.value }))}
                      className="rounded-xl border border-slate-200 px-3 py-2"
                      placeholder="Tanggal Pengurangan"
                    />
                  </div>
                  <button
                    type="button"
                    onClick={handleAddMember}
                    className="inline-flex items-center gap-2 rounded-xl bg-emerald-600 text-white px-4 py-2 hover:bg-emerald-700 mt-3 disabled:opacity-60"
                    disabled={saving}
                  >
                    <UserPlus size={16} />
                    Tambah Anggota
                  </button>
                </div>
              </div>
            )}
          </div>
        </section>
      </div>
    </MainLayout>
  );
};

export default AkunKeluargaManagement;
