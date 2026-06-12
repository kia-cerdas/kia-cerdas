import React, { useState } from "react";
import { Plus, Trash2, Send } from "lucide-react";
import MainLayout from "../../components/Layout/MainLayout";
import { createAkunKeluargaAdmin } from "../../services/adminAkunKeluarga";
import { listDesa } from "../../services/desa";

const getTodayDate = () => {
  const now = new Date();
  const y = now.getFullYear();
  const m = String(now.getMonth() + 1).padStart(2, "0");
  const d = String(now.getDate()).padStart(2, "0");
  return `${y}-${m}-${d}`;
};

const createEmptyMember = () => ({
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
});

const cardClass = "bg-white rounded-2xl shadow-sm border border-slate-100";

const AdminAkunKeluargaCreate = () => {
  const [form, setForm] = useState({
    no_kk: "",
    tanggal_terbit: getTodayDate(),
    anggota_keluarga: [createEmptyMember()],
  });
  const [submitting, setSubmitting] = useState(false);
  const [successMessage, setSuccessMessage] = useState("");
  const [errorMessage, setErrorMessage] = useState("");
  const [desasList, setDesasList] = useState([]);

  React.useEffect(() => {
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

  const setTopField = (name, value) => {
    setForm((prev) => ({ ...prev, [name]: value }));
  };

  const setMemberField = (index, name, value) => {
    setForm((prev) => {
      const nextMembers = [...prev.anggota_keluarga];
      nextMembers[index] = { ...nextMembers[index], [name]: value };

      return {
        ...prev,
        anggota_keluarga: nextMembers,
      };
    });
  };

  const addMember = () => {
    setForm((prev) => ({
      ...prev,
      anggota_keluarga: [...prev.anggota_keluarga, createEmptyMember()],
    }));
  };

  const removeMember = (index) => {
    setForm((prev) => {
      if (prev.anggota_keluarga.length === 1) {
        return prev;
      }

      const nextMembers = prev.anggota_keluarga.filter((_, i) => i !== index);

      return {
        ...prev,
        anggota_keluarga: nextMembers,
      };
    });
  };

  const validate = () => {
    if (!form.no_kk.trim()) return "No KK wajib diisi";
    if (!form.tanggal_terbit) return "Tanggal terbit wajib diisi";
    if (form.anggota_keluarga.length === 0) return "Anggota keluarga minimal 1 orang";

    for (let i = 0; i < form.anggota_keluarga.length; i += 1) {
      const member = form.anggota_keluarga[i];
      const idx = i + 1;
      if (!member.nik.trim()) return `NIK anggota #${idx} wajib diisi`;
      if (!member.nama_lengkap.trim()) return `Nama anggota #${idx} wajib diisi`;
      if (!member.tanggal_lahir) return `Tanggal lahir anggota #${idx} wajib diisi`;
      if (!member.kedudukan_keluarga.trim()) return `Kedudukan keluarga anggota #${idx} wajib diisi`;
    }

    return "";
  };

  const buildPayload = () => {
    return {
      no_kk: form.no_kk.trim(),
      tanggal_terbit: form.tanggal_terbit,
      anggota_keluarga: form.anggota_keluarga.map((member) => ({
        nik: member.nik.trim(),
        nama_lengkap: member.nama_lengkap.trim(),
        jenis_kelamin: member.jenis_kelamin,
        tanggal_lahir: member.tanggal_lahir,
        tempat_lahir: member.tempat_lahir.trim(),
        golongan_darah: member.golongan_darah.trim(),
        agama: member.agama.trim(),
        status_perkawinan: member.status_perkawinan.trim(),
        pekerjaan: member.pekerjaan.trim(),
        pendidikan_terakhir: member.pendidikan_terakhir.trim(),
        baca_huruf: member.baca_huruf,
        kedudukan_keluarga: member.kedudukan_keluarga.trim(),
        dusun: member.dusun.trim(),
        asal_penduduk: member.asal_penduduk.trim(),
        tujuan_pindah: member.tujuan_pindah.trim(),
        tempat_meninggal: member.tempat_meninggal.trim(),
        keterangan: member.keterangan.trim(),
        kecamatan: member.kecamatan.trim(),
        desa_id: member.desa_id ? parseInt(member.desa_id, 10) : null,
        is_non_ktp: member.is_non_ktp === "true",
        tanggal_penambahan: member.tanggal_penambahan,
        tanggal_pengurangan: member.tanggal_pengurangan,
      })),
    };
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setSuccessMessage("");
    setErrorMessage("");

    const validationError = validate();
    if (validationError) {
      setErrorMessage(validationError);
      return;
    }

    setSubmitting(true);
    try {
      const payload = buildPayload();
      await createAkunKeluargaAdmin(payload);
      setSuccessMessage("Kartu keluarga berhasil dibuat.");
      setForm({
        no_kk: "",
        tanggal_terbit: getTodayDate(),
        anggota_keluarga: [createEmptyMember()],
      });
    } catch (error) {
      const apiMessage = error?.response?.data?.message;
      const text = Array.isArray(apiMessage) ? apiMessage.join(", ") : apiMessage;
      setErrorMessage(text || "Gagal membuat kartu keluarga");
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <MainLayout>
      <div className="space-y-6">

        <form onSubmit={handleSubmit} className="space-y-5">
          {successMessage && (
            <div className="rounded-xl bg-emerald-50 border border-emerald-200 px-4 py-3 text-emerald-700 text-sm">
              {successMessage}
            </div>
          )}
          {errorMessage && (
            <div className="rounded-xl bg-red-50 border border-red-200 px-4 py-3 text-red-700 text-sm">
              {errorMessage}
            </div>
          )}

          <section className={`${cardClass} p-5`}>
            <h2 className="text-lg font-semibold text-slate-800">Data Kartu Keluarga</h2>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mt-4">
              <div>
                <label className="text-sm text-slate-600">No KK</label>
                <input
                  type="text"
                  value={form.no_kk}
                  onChange={(e) => setTopField("no_kk", e.target.value)}
                  className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
                  placeholder="3201012026040006"
                  required
                />
              </div>
              <div>
                <label className="text-sm text-slate-600">Tanggal Terbit</label>
                <input
                  type="date"
                  value={form.tanggal_terbit}
                  onChange={(e) => setTopField("tanggal_terbit", e.target.value)}
                  className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
                  required
                />
              </div>
            </div>
          </section>

          <section className={`${cardClass} p-5`}>
            <div className="flex items-center justify-between gap-3">
              <h2 className="text-lg font-semibold text-slate-800">Anggota Keluarga</h2>
              <button
                type="button"
                onClick={addMember}
                className="inline-flex items-center gap-2 rounded-xl bg-blue-600 text-white px-3 py-2 text-sm hover:bg-blue-700"
              >
                <Plus size={16} />
                Tambah Anggota
              </button>
            </div>

            <div className="space-y-4 mt-4">
              {form.anggota_keluarga.map((member, index) => (
                <div key={index} className="rounded-2xl border border-slate-200 p-4 bg-slate-50/50">
                  <div className="flex items-center justify-between mb-3">
                    <h3 className="font-semibold text-slate-800">Anggota #{index + 1}</h3>
                    <button
                      type="button"
                      onClick={() => removeMember(index)}
                      disabled={form.anggota_keluarga.length === 1}
                      className="inline-flex items-center gap-1 text-sm px-2 py-1 rounded-lg text-red-600 hover:bg-red-50 disabled:opacity-40 disabled:cursor-not-allowed"
                    >
                      <Trash2 size={14} />
                      Hapus
                    </button>
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <div>
                      <label className="text-sm text-slate-600">NIK</label>
                      <input type="text" value={member.nik} onChange={(e) => setMemberField(index, "nik", e.target.value)} className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2" required />
                    </div>
                    <div>
                      <label className="text-sm text-slate-600">Nama Lengkap</label>
                      <input type="text" value={member.nama_lengkap} onChange={(e) => setMemberField(index, "nama_lengkap", e.target.value)} className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2" required />
                    </div>
                    <div>
                      <label className="text-sm text-slate-600">Jenis Kelamin</label>
                      <select value={member.jenis_kelamin} onChange={(e) => setMemberField(index, "jenis_kelamin", e.target.value)} className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2">
                        <option>Laki-laki</option>
                        <option>Perempuan</option>
                      </select>
                    </div>

                    <div>
                      <label className="text-sm text-slate-600">Tanggal Lahir</label>
                      <input type="date" value={member.tanggal_lahir} onChange={(e) => setMemberField(index, "tanggal_lahir", e.target.value)} className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2" required />
                    </div>
                    <div>
                      <label className="text-sm text-slate-600">Tempat Lahir</label>
                      <input type="text" value={member.tempat_lahir} onChange={(e) => setMemberField(index, "tempat_lahir", e.target.value)} className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2" />
                    </div>
                    <div>
                      <label className="text-sm text-slate-600">Golongan Darah</label>
                      <input type="text" value={member.golongan_darah} onChange={(e) => setMemberField(index, "golongan_darah", e.target.value)} className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2" placeholder="O+, A-, dst" />
                    </div>

                    <div>
                      <label className="text-sm text-slate-600">Agama</label>
                      <input type="text" value={member.agama} onChange={(e) => setMemberField(index, "agama", e.target.value)} className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2" />
                    </div>
                    <div>
                      <label className="text-sm text-slate-600">Status Perkawinan</label>
                      <input type="text" value={member.status_perkawinan} onChange={(e) => setMemberField(index, "status_perkawinan", e.target.value)} className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2" />
                    </div>
                    <div>
                      <label className="text-sm text-slate-600">Pekerjaan</label>
                      <input type="text" value={member.pekerjaan} onChange={(e) => setMemberField(index, "pekerjaan", e.target.value)} className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2" />
                    </div>

                    <div>
                      <label className="text-sm text-slate-600">Pendidikan Terakhir</label>
                      <input type="text" value={member.pendidikan_terakhir} onChange={(e) => setMemberField(index, "pendidikan_terakhir", e.target.value)} className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2" />
                    </div>
                    <div>
                      <label className="text-sm text-slate-600">Baca Huruf</label>
                      <select value={member.baca_huruf} onChange={(e) => setMemberField(index, "baca_huruf", e.target.value)} className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2">
                        <option>Ya</option>
                        <option>Tidak</option>
                      </select>
                    </div>
                    <div>
                      <label className="text-sm text-slate-600">Kedudukan Keluarga</label>
                      <input type="text" value={member.kedudukan_keluarga} onChange={(e) => setMemberField(index, "kedudukan_keluarga", e.target.value)} className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2" placeholder="Kepala Keluarga / Istri / Anak" required />
                    </div>
                    <div>
                      <label className="text-sm text-slate-600">Desa</label>
                      <select value={member.desa_id} onChange={(e) => setMemberField(index, "desa_id", e.target.value)} className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2" required>
                        <option value="">-- Pilih Desa --</option>
                        {desasList.map(d => (
                          <option key={d.id} value={d.id}>{d.nama_desa}</option>
                        ))}
                      </select>
                    </div>
                    <div>
                      <label className="text-sm text-slate-600">Kecamatan</label>
                      <input type="text" value={member.kecamatan} onChange={(e) => setMemberField(index, "kecamatan", e.target.value)} className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2" />
                    </div>
                    <div>
                      <label className="text-sm text-slate-600">KTP Warga Setempat?</label>
                      <select value={member.is_non_ktp} onChange={(e) => setMemberField(index, "is_non_ktp", e.target.value)} className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2">
                        <option value="false">Ya</option>
                        <option value="true">Tidak</option>
                      </select>
                    </div>
                    <div>
                      <label className="text-sm text-slate-600">No. Telepon (opsional)</label>
                      <input type="text" value={member.telepon} onChange={(e) => setMemberField(index, "telepon", e.target.value)} className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2" placeholder="Contoh: 081234567890" />
                    </div>

                    <div>
                      <label className="text-sm text-slate-600">Tanggal Penambahan (opsional)</label>
                      <input type="date" value={member.tanggal_penambahan} onChange={(e) => setMemberField(index, "tanggal_penambahan", e.target.value)} className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2" />
                    </div>
                    <div>
                      <label className="text-sm text-slate-600">Tanggal Pengurangan (opsional)</label>
                      <input type="date" value={member.tanggal_pengurangan} onChange={(e) => setMemberField(index, "tanggal_pengurangan", e.target.value)} className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2" />
                    </div>

                    <div>
                      <label className="text-sm text-slate-600">Dusun / Alamat Ringkas</label>
                      <input type="text" value={member.dusun} onChange={(e) => setMemberField(index, "dusun", e.target.value)} className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2" />
                    </div>
                    <div>
                      <label className="text-sm text-slate-600">Asal Penduduk</label>
                      <input type="text" value={member.asal_penduduk} onChange={(e) => setMemberField(index, "asal_penduduk", e.target.value)} className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2" />
                    </div>
                    <div>
                      <label className="text-sm text-slate-600">Tujuan Pindah (opsional)</label>
                      <input type="text" value={member.tujuan_pindah} onChange={(e) => setMemberField(index, "tujuan_pindah", e.target.value)} className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2" />
                    </div>
                    <div>
                      <label className="text-sm text-slate-600">Tempat Meninggal (opsional)</label>
                      <input type="text" value={member.tempat_meninggal} onChange={(e) => setMemberField(index, "tempat_meninggal", e.target.value)} className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2" />
                    </div>
                    <div>
                      <label className="text-sm text-slate-600">Keterangan (opsional)</label>
                      <input type="text" value={member.keterangan} onChange={(e) => setMemberField(index, "keterangan", e.target.value)} className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2" />
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </section>

          <div className="flex justify-end">
            <button
              type="submit"
              disabled={submitting}
              className="inline-flex items-center gap-2 rounded-xl bg-indigo-600 text-white px-5 py-2.5 font-medium hover:bg-indigo-700 disabled:opacity-60"
            >
              <Send size={16} />
              {submitting ? "Menyimpan..." : "Simpan Kartu Keluarga"}
            </button>
          </div>
        </form>
      </div>
    </MainLayout>
  );
};

export default AdminAkunKeluargaCreate;
