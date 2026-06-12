// src/pages/Ibu/IbuEdit.jsx
import React, { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import Swal from "sweetalert2";
import MainLayout from "../../components/Layout/MainLayout";
import { getIbuById, updateIbu } from "../../services/ibu";
import { getKehamilanByIbuId, updateKehamilan, createKehamilan } from "../../services/kehamilan";
import { updateKependudukan } from "../../services/kependudukan";
import { Save, ArrowLeft, Loader2 } from "lucide-react";

export default function IbuEdit() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  const [fetching, setFetching] = useState(true);
  const [ibu, setIbu] = useState(null);
  const [kehamilan, setKehamilan] = useState(null);

  // Form state - data kependudukan
  const [form, setForm] = useState({
    // Kependudukan fields
    no_kk: "",
    nik: "",
    nama_lengkap: "",
    jenis_kelamin: "Perempuan",
    tempat_lahir: "",
    tanggal_lahir: "",
    golongan_darah: "",
    dusun: "",
    pendidikan_terakhir: "",
    pekerjaan: "",
    alamat: "",
    telepon: "",
    // Ibu fields
    status_kehamilan: "TRIMESTER 1",
    // Kehamilan fields
    hpht: "",
    taksiran_persalinan: "",
    gravida: "",
    paritas: "",
    abortus: "",
    uk_kehamilan_saat_ini: "",
    jarak_kehamilan_sebelumnya: "",
    status_kehamilan_detail: "",
  });

  useEffect(() => {
    const fetchData = async () => {
      try {
        const ibuData = await getIbuById(id);
        setIbu(ibuData);
        const kehamilanData = await getKehamilanByIbuId(id);
        const aktif = kehamilanData.length > 0 ? kehamilanData[0] : null;
        setKehamilan(aktif);
        const kd = ibuData.kependudukan || {};
        setForm({
          // Kependudukan
          no_kk: kd.no_kk || "",
          nik: kd.nik || "",
          nama_lengkap: kd.nama_lengkap || "",
          jenis_kelamin: kd.jenis_kelamin || "Perempuan",
          tempat_lahir: kd.tempat_lahir || "",
          tanggal_lahir: kd.tanggal_lahir ? new Date(kd.tanggal_lahir).toISOString().split("T")[0] : "",
          golongan_darah: kd.golongan_darah || "",
          dusun: kd.dusun || "",
          pendidikan_terakhir: kd.pendidikan_terakhir || "",
          pekerjaan: kd.pekerjaan || "",
          alamat: kd.alamat || "",
          telepon: kd.telepon || "",
          // Ibu
          status_kehamilan: ibuData.status_kehamilan || "TRIMESTER 1",
          // Kehamilan
          hpht: aktif?.hpht ? new Date(aktif.hpht).toISOString().split("T")[0] : "",
          taksiran_persalinan: aktif?.taksiran_persalinan ? new Date(aktif.taksiran_persalinan).toISOString().split("T")[0] : "",
          gravida: aktif?.gravida?.toString() || "",
          paritas: aktif?.paritas?.toString() || "",
          abortus: aktif?.abortus?.toString() || "",
          uk_kehamilan_saat_ini: aktif?.uk_kehamilan_saat_ini?.toString() || "",
          jarak_kehamilan_sebelumnya: aktif?.jarak_kehamilan_sebelumnya?.toString() || "",
          status_kehamilan_detail: aktif?.status_kehamilan || "",
        });
      } catch (err) {
        console.error(err);
      } finally {
        setFetching(false);
      }
    };
    fetchData();
  }, [id]);

  const handleChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    try {
      // 1. Update Kependudukan (nama, NIK, alamat, dll)
      if (ibu?.id_kependudukan) {
        const kependudukanPayload = {
          no_kk: form.no_kk,
          nik: form.nik,
          nama_lengkap: form.nama_lengkap,
          jenis_kelamin: form.jenis_kelamin,
          tempat_lahir: form.tempat_lahir,
          tanggal_lahir: form.tanggal_lahir,
          golongan_darah: form.golongan_darah,
          dusun: form.dusun,
          pendidikan_terakhir: form.pendidikan_terakhir,
          pekerjaan: form.pekerjaan,
          alamat: form.alamat,
          telepon: form.telepon,
        };
        await updateKependudukan(ibu.id_kependudukan, kependudukanPayload);
      }

      // 2. Update Ibu (hanya status_kehamilan)
      await updateIbu(id, {
        status_kehamilan: form.status_kehamilan,
      });

      // 3. Update atau Create Kehamilan
      const kehamilanPayload = {
        ibu_id: parseInt(id),
        hpht: form.hpht,
        taksiran_persalinan: form.taksiran_persalinan,
        gravida: parseInt(form.gravida) || 0,
        paritas: parseInt(form.paritas) || 0,
        abortus: parseInt(form.abortus) || 0,
        uk_kehamilan_saat_ini: parseInt(form.uk_kehamilan_saat_ini) || 0,
        jarak_kehamilan_sebelumnya: parseInt(form.jarak_kehamilan_sebelumnya) || 0,
        status_kehamilan: form.status_kehamilan_detail || form.status_kehamilan,
      };

      if (kehamilan) {
        await updateKehamilan(kehamilan.id, kehamilanPayload);
      } else {
        await createKehamilan(kehamilanPayload);
      }

      await Swal.fire({
        icon: 'success',
        title: 'Berhasil',
        text: 'Profil berhasil diperbarui',
        timer: 2000,
        showConfirmButton: false
      });
      navigate(`/data-ibu/${id}`);
    } catch (err) {
      console.error(err);
      Swal.fire('Error', err.response?.data?.message || "Gagal menyimpan perubahan", 'error');
    } finally {
      setLoading(false);
    }
  };

  if (fetching)
    return (
      <MainLayout>
        <div className="p-6">Memuat...</div>
      </MainLayout>
    );
  if (!ibu)
    return (
      <MainLayout>
        <div className="p-6">Data tidak ditemukan</div>
      </MainLayout>
    );

  return (
    <MainLayout>
      <div className="p-6 max-w-4xl mx-auto">
        <div className="flex items-center gap-4 mb-6">
          <button onClick={() => navigate(-1)} className="p-2 rounded-full hover:bg-gray-100">
            <ArrowLeft size={20} />
          </button>
          <div>
            <h1 className="text-2xl font-bold">Edit Profil Lengkap</h1>
            <p className="text-gray-500">Perbarui data kependudukan, status ibu, dan data kehamilan.</p>
          </div>
        </div>

        <form onSubmit={handleSubmit} className="space-y-6">
          {/* Data Kependudukan */}
          <div className="bg-white rounded-xl shadow-sm p-6">
            <h2 className="text-lg font-semibold mb-4 text-indigo-700">Data Kependudukan</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium mb-1">
                  Nama Lengkap <span className="text-red-500">*</span>
                </label>
                <input name="nama_lengkap" value={form.nama_lengkap} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" required />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">
                  NIK <span className="text-red-500">*</span>
                </label>
                <input name="nik" value={form.nik} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" required />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">No. KK</label>
                <input name="no_kk" value={form.no_kk} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Jenis Kelamin</label>
                <select name="jenis_kelamin" value={form.jenis_kelamin} onChange={handleChange} className="w-full border rounded-lg px-3 py-2">
                  <option>Perempuan</option>
                  <option>Laki-laki</option>
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Tempat Lahir</label>
                <input name="tempat_lahir" value={form.tempat_lahir} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Tanggal Lahir</label>
                <input type="date" name="tanggal_lahir" value={form.tanggal_lahir} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Golongan Darah</label>
                <select name="golongan_darah" value={form.golongan_darah} onChange={handleChange} className="w-full border rounded-lg px-3 py-2">
                  <option value="">-- Pilih --</option>
                  <option>A</option>
                  <option>B</option>
                  <option>AB</option>
                  <option>O</option>
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Dusun</label>
                <input name="dusun" value={form.dusun} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Pendidikan Terakhir</label>
                <select name="pendidikan_terakhir" value={form.pendidikan_terakhir} onChange={handleChange} className="w-full border rounded-lg px-3 py-2">
                  <option value="">-- Pilih --</option>
                  <option>SD</option>
                  <option>SMP</option>
                  <option>SMA</option>
                  <option>D3</option>
                  <option>S1</option>
                  <option>S2</option>
                  <option>S3</option>
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Pekerjaan</label>
                <input name="pekerjaan" value={form.pekerjaan} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Nomor Telepon</label>
                <input name="telepon" value={form.telepon} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" />
              </div>
              <div className="md:col-span-2">
                <label className="block text-sm font-medium mb-1">Alamat</label>
                <textarea name="alamat" value={form.alamat} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" rows="2" />
              </div>
            </div>
          </div>

          {/* Status Ibu */}
          <div className="bg-white rounded-xl shadow-sm p-6">
            <h2 className="text-lg font-semibold mb-4 text-indigo-700">Status Ibu</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium mb-1">Status Kehamilan</label>
                <select name="status_kehamilan" value={form.status_kehamilan} onChange={handleChange} className="w-full border rounded-lg px-3 py-2">
                  <option>TRIMESTER 1</option>
                  <option>TRIMESTER 2</option>
                  <option>TRIMESTER 3</option>
                  <option>NIFAS</option>
                  <option>SELESAI</option>
                </select>
              </div>
            </div>
          </div>

          {/* Data Kehamilan */}
          <div className="bg-white rounded-xl shadow-sm p-6">
            <h2 className="text-lg font-semibold mb-4 text-indigo-700">Data Kehamilan</h2>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div>
                <label className="block text-sm font-medium mb-1">HPHT</label>
                <input type="date" name="hpht" value={form.hpht} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Taksiran Persalinan (HPL)</label>
                <input type="date" name="taksiran_persalinan" value={form.taksiran_persalinan} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">UK Saat Ini (minggu)</label>
                <input type="number" name="uk_kehamilan_saat_ini" value={form.uk_kehamilan_saat_ini} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Gravida (G)</label>
                <input type="number" name="gravida" value={form.gravida} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Paritas (P)</label>
                <input type="number" name="paritas" value={form.paritas} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Abortus (A)</label>
                <input type="number" name="abortus" value={form.abortus} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Jarak Kehamilan Sebelumnya (bulan)</label>
                <input type="number" name="jarak_kehamilan_sebelumnya" value={form.jarak_kehamilan_sebelumnya} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" />
              </div>
            </div>
          </div>

          {/* Submit */}
          <div className="flex gap-3">
            <button type="button" onClick={() => navigate(-1)} className="px-6 py-2 border rounded-lg hover:bg-gray-50">
              Batal
            </button>
            <button type="submit" disabled={loading} className="bg-indigo-600 text-white px-6 py-2 rounded-lg flex items-center gap-2 hover:bg-indigo-700">
              {loading ? <Loader2 className="animate-spin" size={18} /> : <Save size={18} />}
              {loading ? "Menyimpan..." : "Simpan Perubahan"}
            </button>
          </div>
        </form>
      </div>
    </MainLayout>
  );
}
