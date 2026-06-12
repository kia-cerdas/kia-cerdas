import React, { useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { ArrowLeft, Loader2, Save } from "lucide-react";
import MainLayout from "../../components/Layout/MainLayout";
import {
  createInformasiUmum,
  getInformasiUmumById,
  updateInformasiUmum,
} from "../../services/informasiUmum";

const defaultForm = {
  tipe: "ARTIKEL",
  judul: "",
  umur_target: "",
  durasi_baca: "",
  ringkasan: "",
  konten: "",
  yang_perlu_diingat: "",
  thumbnail_url: "",
  is_active: true,
};

const InformasiUmumForm = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const isEdit = Boolean(id);

  const [form, setForm] = useState(defaultForm);
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [errorMessage, setErrorMessage] = useState("");

  useEffect(() => {
    const loadDetail = async () => {
      if (!isEdit) return;

      setLoading(true);
      setErrorMessage("");
      try {
        const data = await getInformasiUmumById(id);
        setForm({
          tipe: data?.tipe || "ARTIKEL",
          judul: data?.judul || "",
          umur_target: data?.umur_target || "",
          durasi_baca: data?.durasi_baca || "",
          ringkasan: data?.ringkasan || "",
          konten: data?.konten || "",
          yang_perlu_diingat: data?.yang_perlu_diingat || "",
          thumbnail_url: data?.thumbnail_url || "",
          is_active: Boolean(data?.is_active ?? true),
        });
      } catch (error) {
        setErrorMessage(error?.response?.data?.message || error.message || "Gagal memuat detail informasi umum");
      } finally {
        setLoading(false);
      }
    };

    loadDetail();
  }, [id, isEdit]);

  const handleChange = (event) => {
    const { name, value, type, checked } = event.target;
    setForm((current) => ({
      ...current,
      [name]: type === "checkbox" ? checked : value,
    }));
  };

  const handleSubmit = async (event) => {
    event.preventDefault();
    setSaving(true);
    setErrorMessage("");

    try {
      const payload = {
        ...form,
        judul: form.judul.trim(),
        umur_target: form.umur_target.trim(),
        durasi_baca: form.durasi_baca.trim(),
        ringkasan: form.ringkasan.trim(),
        konten: form.konten.trim(),
        yang_perlu_diingat: form.yang_perlu_diingat.trim(),
        thumbnail_url: form.thumbnail_url.trim(),
      };

      if (!payload.judul || !payload.konten) {
        setErrorMessage("Judul dan konten wajib diisi");
        setSaving(false);
        return;
      }

      if (isEdit) {
        await updateInformasiUmum(id, payload);
      } else {
        await createInformasiUmum(payload);
      }

      navigate("/dashboard/admin/informasi-umum");
    } catch (error) {
      setErrorMessage(error?.response?.data?.message || error.message || "Gagal menyimpan data");
    } finally {
      setSaving(false);
    }
  };

  return (
    <MainLayout>
      <div className="mx-auto max-w-5xl space-y-6">
        <div className="flex items-center justify-between gap-4">
          <div className="flex items-center gap-4">
            <button
              type="button"
              onClick={() => navigate(-1)}
              className="inline-flex h-11 w-11 items-center justify-center rounded-xl border border-slate-200 bg-white text-slate-600 transition hover:bg-slate-50"
            >
              <ArrowLeft size={18} />
            </button>
            <div>
              <p className="text-xs font-semibold uppercase tracking-[0.24em] text-slate-400">Informasi Umum</p>
              <h1 className="text-2xl font-bold text-slate-800">
                {isEdit ? "Edit Konten Edukasi" : "Tambah Konten Edukasi"}
              </h1>
            </div>
          </div>
        </div>

        {errorMessage ? (
          <div className="rounded-2xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">{errorMessage}</div>
        ) : null}

        <form onSubmit={handleSubmit} className="space-y-6 rounded-3xl border border-slate-100 bg-white p-6 shadow-sm md:p-8">
          {loading ? (
            <div className="py-14 text-center text-sm text-slate-500">Memuat detail data...</div>
          ) : (
            <>
              <div className="grid gap-5 md:grid-cols-2">
                <div>
                  <label className="mb-2 block text-sm font-semibold text-slate-700">Tipe Konten</label>
                  <select
                    name="tipe"
                    value={form.tipe}
                    onChange={handleChange}
                    className="w-full rounded-xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm outline-none transition focus:border-sky-400 focus:bg-white"
                  >
                    <option value="ARTIKEL">ARTIKEL</option>
                    <option value="VIDEO">VIDEO</option>
                  </select>
                </div>

                <div>
                  <label className="mb-2 block text-sm font-semibold text-slate-700">Judul</label>
                  <input
                    name="judul"
                    value={form.judul}
                    onChange={handleChange}
                    placeholder="Contoh: Cuci Tangan Pakai Sabun"
                    className="w-full rounded-xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm outline-none transition focus:border-sky-400 focus:bg-white"
                  />
                </div>

                <div>
                  <label className="mb-2 block text-sm font-semibold text-slate-700">Umur Target</label>
                  <input
                    name="umur_target"
                    value={form.umur_target}
                    onChange={handleChange}
                    placeholder="Contoh: Bayi 0-12 bulan / Semua umur"
                    className="w-full rounded-xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm outline-none transition focus:border-sky-400 focus:bg-white"
                  />
                </div>

                <div>
                  <label className="mb-2 block text-sm font-semibold text-slate-700">Durasi Baca</label>
                  <input
                    name="durasi_baca"
                    value={form.durasi_baca}
                    onChange={handleChange}
                    placeholder="Contoh: 5 Menit Baca"
                    className="w-full rounded-xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm outline-none transition focus:border-sky-400 focus:bg-white"
                  />
                </div>

                <div className="md:col-span-2">
                  <label className="mb-2 block text-sm font-semibold text-slate-700">Ringkasan</label>
                  <textarea
                    name="ringkasan"
                    value={form.ringkasan}
                    onChange={handleChange}
                    rows={3}
                    placeholder="Ringkasan singkat materi untuk kartu di mobile"
                    className="w-full rounded-xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm outline-none transition focus:border-sky-400 focus:bg-white"
                  />
                </div>

                <div className="md:col-span-2">
                  <label className="mb-2 block text-sm font-semibold text-slate-700">Konten</label>
                  <textarea
                    name="konten"
                    value={form.konten}
                    onChange={handleChange}
                    rows={8}
                    placeholder="Tulis isi edukasi lengkap di sini"
                    className="w-full rounded-xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm outline-none transition focus:border-sky-400 focus:bg-white"
                  />
                </div>

                <div className="md:col-span-2">
                  <label className="mb-2 block text-sm font-semibold text-slate-700">Yang Perlu Diingat</label>
                  <textarea
                    name="yang_perlu_diingat"
                    value={form.yang_perlu_diingat}
                    onChange={handleChange}
                    rows={5}
                    placeholder={"Tulis poin penting, satu baris per poin\nContoh:\n- ASI eksklusif sangat penting\n- Perhatikan tanda dehidrasi\n- Segera periksa jika anak demam"}
                    className="w-full rounded-xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm outline-none transition focus:border-sky-400 focus:bg-white"
                  />
                  <p className="mt-2 text-xs text-slate-500">Isi satu poin per baris agar tampil rapi di mobile.</p>
                </div>

                <div className="md:col-span-2">
                  <label className="mb-2 block text-sm font-semibold text-slate-700">Thumbnail URL</label>
                  <input
                    name="thumbnail_url"
                    value={form.thumbnail_url}
                    onChange={handleChange}
                    placeholder="https://..."
                    className="w-full rounded-xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm outline-none transition focus:border-sky-400 focus:bg-white"
                  />
                </div>

                <label className="flex items-center gap-3 rounded-2xl border border-slate-200 bg-slate-50 px-4 py-4 text-sm font-semibold text-slate-700 md:col-span-2">
                  <input
                    type="checkbox"
                    name="is_active"
                    checked={form.is_active}
                    onChange={handleChange}
                    className="h-4 w-4 rounded border-slate-300 text-sky-600 focus:ring-sky-500"
                  />
                  Tampilkan ke mobile
                </label>
              </div>

              <div className="flex flex-col gap-3 md:flex-row md:justify-end">
                <button
                  type="button"
                  onClick={() => navigate("/dashboard/admin/informasi-umum")}
                  className="inline-flex items-center justify-center rounded-xl border border-slate-200 px-5 py-3 text-sm font-semibold text-slate-600 transition hover:bg-slate-50"
                >
                  Batal
                </button>
                <button
                  type="submit"
                  disabled={saving}
                  className="inline-flex items-center justify-center gap-2 rounded-xl bg-sky-600 px-5 py-3 text-sm font-semibold text-white transition hover:bg-sky-700 disabled:cursor-not-allowed disabled:opacity-70"
                >
                  {saving ? <Loader2 size={16} className="animate-spin" /> : <Save size={16} />}
                  {saving ? "Menyimpan..." : "Simpan"}
                </button>
              </div>
            </>
          )}
        </form>
      </div>
    </MainLayout>
  );
};

export default InformasiUmumForm;