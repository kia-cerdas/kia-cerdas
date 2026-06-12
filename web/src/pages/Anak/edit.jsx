// src/pages/Anak/edit.jsx
import React, { useEffect, useState } from "react";
import MainLayout from "../../components/Layout/MainLayout";
import { useParams, useNavigate } from "react-router-dom";
import { updateAnak, getAnakById } from "../../services/Anak";
import { ArrowLeft, Save, Baby, AlertCircle, Loader2 } from "lucide-react";

export default function EditAnak() {
  const { id } = useParams();
  const navigate = useNavigate();

  const [loading, setLoading] = useState(false);
  const [fetching, setFetching] = useState(true);
  const [errors, setErrors] = useState({});
  const [generalError, setGeneralError] = useState("");
  const [form, setForm] = useState({
    nama: "",
    jenis_kelamin: "",
    tanggal_lahir: "",
    berat_lahir_kg: ""
  });

  useEffect(() => {
    const fetchData = async () => {
      try {
        setFetching(true);
        const res = await getAnakById(id);
        const data = res.data;
        if (data) {
          // tanggal_lahir bisa ada di data langsung atau di penduduk nested
          const rawDate = data.tanggal_lahir || data.penduduk?.tanggal_lahir || "";
          // Abaikan tanggal default 0001-01-01
          const formattedDate = rawDate && !rawDate.startsWith("0001")
            ? rawDate.split('T')[0]
            : "";
          setForm({
            nama: data.nama || data.penduduk?.nama_lengkap || "",
            jenis_kelamin: data.jenis_kelamin || data.penduduk?.jenis_kelamin || "",
            tanggal_lahir: formattedDate,
            berat_lahir_kg: data.berat_lahir_kg || ""
          });
        } else {
          setGeneralError("Data anak tidak ditemukan.");
        }
      } catch (err) {
        setGeneralError("Gagal mengambil data anak.");
      } finally {
        setFetching(false);
      }
    };
    fetchData();
  }, [id]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setForm({ ...form, [name]: value });
    if (errors[name]) setErrors(prev => ({ ...prev, [name]: "" }));
  };

  const validateForm = () => {
    let tempErrors = {};
    if (!form.nama.trim()) tempErrors.nama = "Nama anak tidak boleh kosong.";
    if (!form.jenis_kelamin) tempErrors.jenis_kelamin = "Pilih jenis kelamin.";
    if (!form.tanggal_lahir) tempErrors.tanggal_lahir = "Tanggal lahir harus diisi.";
    if (!form.berat_lahir_kg || form.berat_lahir_kg <= 0) tempErrors.berat_lahir_kg = "Berat lahir harus diisi dengan angka positif.";
    if (form.tanggal_lahir && new Date(form.tanggal_lahir) > new Date()) {
      tempErrors.tanggal_lahir = "Tanggal lahir tidak boleh di masa depan.";
    }
    setErrors(tempErrors);
    return Object.keys(tempErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setGeneralError("");
    if (!validateForm()) return;
    setLoading(true);
    try {
      const payload = {
        ...form,
        berat_lahir_kg: parseFloat(form.berat_lahir_kg)
      };
      await updateAnak(id, payload);
      alert("Perubahan data anak telah disimpan.");
      navigate("/daftar-anak");
    } catch (err) {
      console.error("Save Error:", err);
      const msg = err.response?.data?.message || err.message || "Gagal menyimpan data";
      alert(msg);
    } finally {
      setLoading(false);
    }
  };

  return (
    <MainLayout>
      <div className="max-w-3xl mx-auto px-4 py-6">
        <div className="flex items-center justify-between mb-6">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-amber-100 text-amber-600 rounded-lg"><Baby size={24} /></div>
            <h1 className="text-2xl font-bold text-gray-800">Ubah Data Anak</h1>
          </div>
          <button onClick={() => navigate(-1)} className="flex items-center gap-2 text-sm text-gray-600 hover:text-indigo-600"><ArrowLeft size={18} /> Kembali</button>
        </div>

        {generalError && (
          <div className="mb-6 p-4 bg-red-50 border-l-4 border-red-500 text-red-700 flex items-start gap-3 rounded-r-lg">
            <AlertCircle className="mt-0.5" size={20} />
            <p className="text-sm font-medium">{generalError}</p>
          </div>
        )}

        {fetching ? (
          <div className="bg-white rounded-xl p-20 border flex flex-col items-center justify-center text-gray-500">
            <Loader2 className="animate-spin mb-4 text-indigo-600" size={40} />
            <p>Sedang mengambil data anak...</p>
          </div>
        ) : (
          <div className="bg-white rounded-xl shadow-sm border overflow-hidden">
            <form onSubmit={handleSubmit} className="p-6 md:p-8 space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="md:col-span-2">
                  <label className="block text-sm font-semibold text-gray-700 mb-1">Nama Lengkap Anak <span className="text-red-500">*</span></label>
                  <input name="nama" value={form.nama} onChange={handleChange} placeholder="Contoh: Budi Santoso" className={`w-full p-3 rounded-lg border outline-none transition-all ${errors.nama ? "border-red-500 bg-red-50" : "border-gray-300 focus:ring-2 focus:ring-indigo-500"}`} />
                  {errors.nama && <p className="mt-1 text-xs text-red-600">{errors.nama}</p>}
                </div>
                <div>
                  <label className="block text-sm font-semibold text-gray-700 mb-1">Jenis Kelamin <span className="text-red-500">*</span></label>
                  <select name="jenis_kelamin" value={form.jenis_kelamin} onChange={handleChange} className={`w-full p-3 rounded-lg border outline-none transition-all ${errors.jenis_kelamin ? "border-red-500 bg-red-50" : "border-gray-300 focus:ring-2 focus:ring-indigo-500"}`}>
                    <option value="">Pilih...</option>
                    <option value="laki-laki">Laki-laki</option>
                    <option value="perempuan">Perempuan</option>
                  </select>
                  {errors.jenis_kelamin && <p className="mt-1 text-xs text-red-600">{errors.jenis_kelamin}</p>}
                </div>
                <div>
                  <label className="block text-sm font-semibold text-gray-700 mb-1">Tanggal Lahir <span className="text-red-500">*</span></label>
                  <input type="date" name="tanggal_lahir" value={form.tanggal_lahir} onChange={handleChange} className={`w-full p-3 rounded-lg border outline-none transition-all ${errors.tanggal_lahir ? "border-red-500 bg-red-50" : "border-gray-300 focus:ring-2 focus:ring-indigo-500"}`} />
                  {errors.tanggal_lahir && <p className="mt-1 text-xs text-red-600">{errors.tanggal_lahir}</p>}
                </div>
                <div>
                  <label className="block text-sm font-semibold text-gray-700 mb-1">Berat Lahir (kg) <span className="text-red-500">*</span></label>
                  <input type="number" step="0.01" name="berat_lahir_kg" value={form.berat_lahir_kg} onChange={handleChange} placeholder="Contoh: 3.2" className={`w-full p-3 rounded-lg border outline-none transition-all ${errors.berat_lahir_kg ? "border-red-500 bg-red-50" : "border-gray-300 focus:ring-2 focus:ring-indigo-500"}`} />
                  {errors.berat_lahir_kg && <p className="mt-1 text-xs text-red-600">{errors.berat_lahir_kg}</p>}
                </div>
              </div>
              <div className="pt-6 border-t flex flex-col md:flex-row gap-4 justify-end">
                <button type="button" onClick={() => navigate(-1)} className="px-6 py-3 rounded-lg font-bold text-gray-600 hover:bg-gray-50 border">Batal</button>
                <button type="submit" disabled={loading} className={`flex items-center justify-center gap-2 px-8 py-3 rounded-lg font-bold text-white transition-all ${loading ? 'bg-indigo-400 cursor-not-allowed' : 'bg-indigo-600 hover:bg-indigo-700'}`}>
                  {loading ? <Loader2 className="animate-spin" size={20} /> : <Save size={20} />}
                  {loading ? "Menyimpan..." : "Simpan Perubahan"}
                </button>
              </div>
            </form>
          </div>
        )}
      </div>
    </MainLayout>
  );
}