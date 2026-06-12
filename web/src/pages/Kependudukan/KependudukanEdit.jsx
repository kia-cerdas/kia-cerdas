import React, { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import MainLayout from "../../components/Layout/MainLayout";
import { getKependudukanById, updateKependudukan } from "../../services/kependudukan";
import { Save, ArrowLeft, Loader2 } from "lucide-react";

export default function KependudukanEdit() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
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

  useEffect(() => {
    const fetch = async () => {
      try {
        const data = await getKependudukanById(id);
        setForm({
          kartu_keluarga_id: data.kartu_keluarga_id || "",
          nik: data.nik || "",
          dusun: data.dusun || "",
          nama_lengkap: data.nama_lengkap || "",
          golongan_darah: data.golongan_darah || "",
          jenis_kelamin: data.jenis_kelamin || "Perempuan",
          tempat_lahir: data.tempat_lahir || "",
          tanggal_lahir: data.tanggal_lahir ? new Date(data.tanggal_lahir).toISOString().split("T")[0] : "",
          pekerjaan: data.pekerjaan || "",
          pendidikan_terakhir: data.pendidikan_terakhir || "",
          alamat: data.alamat || "",
          nomor_telepon: data.nomor_telepon || "",
        });
      } catch (err) {
        console.error(err);
        alert("Gagal mengambil data");
      }
    };
    fetch();
  }, [id]);

  const handleChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    try {
      await updateKependudukan(id, form);
      alert("Data berhasil diupdate");
      navigate("/kependudukan");
    } catch (err) {
      alert(err.response?.data?.message || "Gagal mengupdate");
    } finally {
      setLoading(false);
    }
  };

  return (
    <MainLayout>
      <div className="p-6 max-w-3xl mx-auto">
        <div className="flex items-center gap-4 mb-6">
          <button onClick={() => navigate(-1)} className="p-2 rounded-full hover:bg-gray-100"><ArrowLeft size={20} /></button>
          <h1 className="text-2xl font-bold">Edit Data KK</h1>
        </div>
        <form onSubmit={handleSubmit} className="bg-white rounded-xl shadow-sm p-6 space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div><label>Nama Lengkap</label><input name="nama_lengkap" value={form.nama_lengkap} onChange={handleChange} className="w-full border rounded px-3 py-2" required /></div>
            <div><label>NIK</label><input name="nik" value={form.nik} onChange={handleChange} className="w-full border rounded px-3 py-2" required /></div>
            <div><label>No. KK</label><input name="kartu_keluarga_id" value={form.kartu_keluarga_id} onChange={handleChange} className="w-full border rounded px-3 py-2" /></div>
            <div><label>Tempat Lahir</label><input name="tempat_lahir" value={form.tempat_lahir} onChange={handleChange} className="w-full border rounded px-3 py-2" /></div>
            <div><label>Tanggal Lahir</label><input type="date" name="tanggal_lahir" value={form.tanggal_lahir} onChange={handleChange} className="w-full border rounded px-3 py-2" /></div>
            <div><label>Jenis Kelamin</label><select name="jenis_kelamin" value={form.jenis_kelamin} onChange={handleChange} className="w-full border rounded px-3 py-2"><option>Perempuan</option><option>Laki-laki</option></select></div>
            <div><label>Golongan Darah</label><input name="golongan_darah" value={form.golongan_darah} onChange={handleChange} className="w-full border rounded px-3 py-2" /></div>
            <div><label>Pendidikan Terakhir</label><input name="pendidikan_terakhir" value={form.pendidikan_terakhir} onChange={handleChange} className="w-full border rounded px-3 py-2" /></div>
            <div><label>Pekerjaan</label><input name="pekerjaan" value={form.pekerjaan} onChange={handleChange} className="w-full border rounded px-3 py-2" /></div>
            <div><label>Dusun</label><input name="dusun" value={form.dusun} onChange={handleChange} className="w-full border rounded px-3 py-2" /></div>
            <div className="md:col-span-2"><label>Alamat</label><textarea name="alamat" value={form.alamat} onChange={handleChange} className="w-full border rounded px-3 py-2" rows="2" /></div>
            <div><label>Nomor Telepon</label><input name="nomor_telepon" value={form.nomor_telepon} onChange={handleChange} className="w-full border rounded px-3 py-2" /></div>
          </div>
          <button type="submit" disabled={loading} className="bg-indigo-600 text-white px-4 py-2 rounded-lg flex items-center gap-2 w-full justify-center">
            {loading ? <Loader2 className="animate-spin" size={18} /> : <Save size={18} />} Simpan Perubahan
          </button>
        </form>
      </div>
    </MainLayout>
  );
}