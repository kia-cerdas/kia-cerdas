import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import MainLayout from "../../components/Layout/MainLayout";
import { createKependudukan } from "../../services/kependudukan";
import { Save, ArrowLeft } from "lucide-react";

export default function KependudukanCreate() {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  const [errors, setErrors] = useState({});
  const [form, setForm] = useState({
    kartu_keluarga_id: "",
    nik: "",
    dusun: "",
    nama_lengkap: "",
    golongan_darah: "",
    jenis_kelamin: "Perempuan",
    tempat_lahir: "",
    tanggal_lahir: "",
    pekerjaan: "",
    pendidikan_terakhir: "",
    alamat: "",
    nomor_telepon: "",
  });

  // Validasi NIK (hanya angka, tepat 16 digit)
  const validateNIK = (value) => {
    if (!value) return "";
    if (!/^\d*$/.test(value)) return "NIK hanya boleh berisi angka";
    if (value.length !== 16) return "NIK harus tepat 16 digit";
    return "";
  };

  // Validasi No. KK (hanya angka, tepat 16 digit)
  const validateKartuKeluargaID = (value) => {
    if (!value) return "";
    if (!/^\d*$/.test(value)) return "No. KK hanya boleh berisi angka";
    if (value.length !== 16) return "No. KK harus tepat 16 digit";
    return "";
  };

  // Validasi Nomor Telepon (10-13 digit)
  const validateNomorTelepon = (value) => {
    if (!value) return "";
    if (!/^\d*$/.test(value)) return "Nomor telepon hanya boleh berisi angka";
    if (value.length < 10 || value.length > 13) return "Nomor telepon harus 10-13 digit";
    return "";
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    
    // Filter hanya angka untuk NIK, kartu_keluarga_id dan nomor_telepon
    let newValue = value;
    if (name === "nik" || name === "kartu_keluarga_id" || name === "nomor_telepon") {
      newValue = value.replace(/\D/g, '');
    }
    
    setForm({ ...form, [name]: newValue });

    // Validasi real-time
    let error = "";
    if (name === "nik") error = validateNIK(newValue);
    else if (name === "kartu_keluarga_id") error = validateKartuKeluargaID(newValue);
    else if (name === "nomor_telepon") error = validateNomorTelepon(newValue);

    setErrors({ ...errors, [name]: error });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    // Validasi sebelum submit
    const newErrors = {};
    
    // NIK wajib dan harus 16 digit
    if (!form.nik) {
      newErrors.nik = "NIK wajib diisi";
    } else if (form.nik.length !== 16) {
      newErrors.nik = "NIK harus tepat 16 digit";
    }
    
    // No. KK jika ada isi harus 16 digit
    if (form.kartu_keluarga_id && form.kartu_keluarga_id.length !== 16) {
      newErrors.kartu_keluarga_id = "No. KK harus tepat 16 digit";
    }
    
    // Telepon jika ada isi harus 10-13 digit
    if (form.nomor_telepon && validateNomorTelepon(form.nomor_telepon)) {
      newErrors.nomor_telepon = validateNomorTelepon(form.nomor_telepon);
    }

    if (Object.keys(newErrors).length > 0) {
      setErrors(newErrors);
      alert("Mohon perbaiki error pada form");
      return;
    }

    setLoading(true);
    try {
      // Konversi kartu_keluarga_id string ke int64 untuk backend
      const formData = {
        ...form,
        kartu_keluarga_id: form.kartu_keluarga_id ? BigInt(form.kartu_keluarga_id) : null,
      };
      await createKependudukan(formData);
      alert("Data KK berhasil ditambahkan");
      navigate("/kependudukan");
    } catch (err) {
      alert(err.response?.data?.message || "Gagal menambahkan data");
    } finally {
      setLoading(false);
    }
  };

  return (
    <MainLayout>
      <div className="p-3 md:px-6 md:py-4">
        <div className="flex items-center gap-3 mb-4">
          <button onClick={() => navigate(-1)} className="p-1.5 rounded-full hover:bg-gray-100"><ArrowLeft size={18} /></button>
          <h1 className="text-lg md:text-xl font-bold">Tambah Data KK</h1>
        </div>
        <form onSubmit={handleSubmit} className="bg-white rounded-lg shadow-sm p-4 space-y-3">
          <div className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-4 gap-3">
            {/* Nama Lengkap */}
            <div className="md:col-span-2 lg:col-span-2">
              <label className="block text-xs font-medium text-gray-700 mb-1">Nama Lengkap</label>
              <input name="nama_lengkap" required onChange={handleChange} value={form.nama_lengkap} className="w-full border rounded px-2 py-1.5 text-sm focus:ring-1 focus:ring-indigo-500 focus:border-indigo-500" />
            </div>

            {/* NIK */}
            <div className="md:col-span-1">
              <label className="block text-xs font-medium text-gray-700 mb-1">NIK <span className="text-gray-400 text-xs">(16 angka)</span></label>
              <input 
                name="nik" 
                required 
                value={form.nik}
                onChange={handleChange} 
                maxLength="16"
                className={`w-full border rounded px-2 py-1.5 text-sm focus:ring-1 focus:border-indigo-500 ${errors.nik ? 'border-red-500 focus:ring-red-500' : 'focus:ring-indigo-500'}`} 
              />
              {errors.nik && <p className="text-red-500 text-xs mt-1">{errors.nik}</p>}
            </div>

            {/* No. KK */}
            <div className="md:col-span-1">
              <label className="block text-xs font-medium text-gray-700 mb-1">No. KK <span className="text-gray-400 text-xs">(16 angka)</span></label>
              <input 
                name="kartu_keluarga_id" 
                value={form.kartu_keluarga_id}
                onChange={handleChange}
                maxLength="16"
                className={`w-full border rounded px-2 py-1.5 text-sm focus:ring-1 focus:border-indigo-500 ${errors.kartu_keluarga_id ? 'border-red-500 focus:ring-red-500' : 'focus:ring-indigo-500'}`}
              />
              {errors.kartu_keluarga_id && <p className="text-red-500 text-xs mt-1">{errors.kartu_keluarga_id}</p>}
            </div>

            {/* Tempat Lahir */}
            <div className="md:col-span-1">
              <label className="block text-xs font-medium text-gray-700 mb-1">Tempat Lahir</label>
              <input name="tempat_lahir" onChange={handleChange} value={form.tempat_lahir} className="w-full border rounded px-2 py-1.5 text-sm focus:ring-1 focus:ring-indigo-500 focus:border-indigo-500" />
            </div>

            {/* Tanggal Lahir */}
            <div className="md:col-span-1">
              <label className="block text-xs font-medium text-gray-700 mb-1">Tanggal Lahir</label>
              <input type="date" name="tanggal_lahir" required onChange={handleChange} value={form.tanggal_lahir} className="w-full border rounded px-2 py-1.5 text-sm focus:ring-1 focus:ring-indigo-500 focus:border-indigo-500" />
            </div>

            {/* Jenis Kelamin */}
            <div className="md:col-span-1">
              <label className="block text-xs font-medium text-gray-700 mb-1">Jenis Kelamin</label>
              <select name="jenis_kelamin" onChange={handleChange} value={form.jenis_kelamin} className="w-full border rounded px-2 py-1.5 text-sm focus:ring-1 focus:ring-indigo-500 focus:border-indigo-500">
                <option>Perempuan</option>
                <option>Laki-laki</option>
              </select>
            </div>

            {/* Golongan Darah */}
            <div className="md:col-span-1">
              <label className="block text-xs font-medium text-gray-700 mb-1">Golongan Darah</label>
              <select name="golongan_darah" onChange={handleChange} value={form.golongan_darah} className="w-full border rounded px-2 py-1.5 text-sm focus:ring-1 focus:ring-indigo-500 focus:border-indigo-500">
                <option value="">-- Pilih --</option>
                <option value="A">A</option>
                <option value="B">B</option>
                <option value="AB">AB</option>
                <option value="O">O</option>
              </select>
            </div>

            {/* Pendidikan Terakhir */}
            <div className="md:col-span-1">
              <label className="block text-xs font-medium text-gray-700 mb-1">Pendidikan Terakhir</label>
              <input name="pendidikan_terakhir" onChange={handleChange} value={form.pendidikan_terakhir} className="w-full border rounded px-2 py-1.5 text-sm focus:ring-1 focus:ring-indigo-500 focus:border-indigo-500" />
            </div>

            {/* Pekerjaan */}
            <div className="md:col-span-1">
              <label className="block text-xs font-medium text-gray-700 mb-1">Pekerjaan</label>
              <input name="pekerjaan" onChange={handleChange} value={form.pekerjaan} className="w-full border rounded px-2 py-1.5 text-sm focus:ring-1 focus:ring-indigo-500 focus:border-indigo-500" />
            </div>

            {/* Dusun */}
            <div className="md:col-span-1">
              <label className="block text-xs font-medium text-gray-700 mb-1">Dusun</label>
              <input name="dusun" onChange={handleChange} value={form.dusun} className="w-full border rounded px-2 py-1.5 text-sm focus:ring-1 focus:ring-indigo-500 focus:border-indigo-500" />
            </div>

            {/* Nomor Telepon */}
            <div className="md:col-span-1">
              <label className="block text-xs font-medium text-gray-700 mb-1">Nomor Telepon <span className="text-gray-400 text-xs">(10-13 digit)</span></label>
              <input 
                name="nomor_telepon" 
                value={form.nomor_telepon}
                onChange={handleChange}
                maxLength="13"
                className={`w-full border rounded px-2 py-1.5 text-sm focus:ring-1 focus:border-indigo-500 ${errors.nomor_telepon ? 'border-red-500 focus:ring-red-500' : 'focus:ring-indigo-500'}`}
              />
              {errors.nomor_telepon && <p className="text-red-500 text-xs mt-1">{errors.nomor_telepon}</p>}
            </div>

            {/* Alamat */}
            <div className="md:col-span-3 lg:col-span-4">
              <label className="block text-xs font-medium text-gray-700 mb-1">Alamat</label>
              <textarea name="alamat" rows="2" onChange={handleChange} value={form.alamat} className="w-full border rounded px-2 py-1.5 text-sm focus:ring-1 focus:ring-indigo-500 focus:border-indigo-500" />
            </div>
          </div>

          <div className="flex justify-end pt-2">
            <button 
              type="submit" 
              disabled={loading || Object.values(errors).some(e => e)} 
              className="bg-indigo-600 text-white px-6 py-2 rounded-lg flex items-center justify-center gap-1.5 text-sm font-medium hover:bg-indigo-700 disabled:bg-gray-400 disabled:cursor-not-allowed transition"
            >
              <Save size={14} /> {loading ? "Menyimpan..." : "Simpan"}
            </button>
          </div>
        </form>
      </div>
    </MainLayout>
  );
}