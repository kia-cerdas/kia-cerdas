// src/pages/Ibu/RencanaPersalinanForm.jsx
import React, { useEffect, useState } from "react";
import { useParams, useNavigate, useSearchParams } from "react-router-dom";
import Swal from "sweetalert2";
import MainLayout from "../../components/Layout/MainLayout";
import { getKehamilanByIbuId } from "../../services/kehamilan";
import { getRencanaById, createRencana, updateRencana, getRencanaByKehamilanId } from "../../services/persalinan";
import { Save, ArrowLeft, AlertCircle } from "lucide-react";

export default function RencanaPersalinanForm() {
  const { id: ibuId } = useParams();
  const [searchParams] = useSearchParams();
  const rencanaId = searchParams.get("id");
  const kehamilanIdQuery = searchParams.get("kehamilan_id");
  const navigate = useNavigate();

  const [kehamilan, setKehamilan] = useState(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");

  const [form, setForm] = useState({
    nama_ibu_pernyataan: "",
    alamat_ibu_pernyataan: "",
    perkiraan_bulan_persalinan: "",
    perkiraan_tahun_persalinan: "",
    fasyankes_1_nama_tenaga: "",
    fasyankes_1_nama_fasilitas: "",
    fasyankes_2_nama_tenaga: "",
    fasyankes_2_nama_fasilitas: "",
    sumber_dana_persalinan: "JKN/BPJS",
    kendaraan_1_nama: "",
    kendaraan_1_hp: "",
    metode_kontrasepsi_pilihan: "",
    donor_golongan_darah: "",
    donor_rhesus: "",
  });

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        if (!ibuId) {
          setError("ID ibu tidak valid.");
          setLoading(false);
          return;
        }
        const kehamilanList = await getKehamilanByIbuId(ibuId);
        if (kehamilanList.length === 0) {
          setError("Data kehamilan tidak ditemukan untuk ibu ini.");
          setLoading(false);
          return;
        }
        // Pilih kehamilan berdasarkan query parameter, fallback ke pertama
        let targetKehamilan = null;
        if (kehamilanIdQuery) {
          targetKehamilan = kehamilanList.find(k => k.id == kehamilanIdQuery);
        }
        if (!targetKehamilan) targetKehamilan = kehamilanList[0];
        setKehamilan(targetKehamilan);

        // Jika ada rencanaId, ambil data untuk edit
        if (rencanaId && rencanaId !== "undefined" && rencanaId !== "null") {
          const data = await getRencanaById(rencanaId);
          setForm({
            nama_ibu_pernyataan: data.nama_ibu_pernyataan || "",
            alamat_ibu_pernyataan: data.alamat_ibu_pernyataan || "",
            perkiraan_bulan_persalinan: data.perkiraan_bulan_persalinan || "",
            perkiraan_tahun_persalinan: data.perkiraan_tahun_persalinan || "",
            fasyankes_1_nama_tenaga: data.fasyankes_1_nama_tenaga || "",
            fasyankes_1_nama_fasilitas: data.fasyankes_1_nama_fasilitas || "",
            fasyankes_2_nama_tenaga: data.fasyankes_2_nama_tenaga || "",
            fasyankes_2_nama_fasilitas: data.fasyankes_2_nama_fasilitas || "",
            sumber_dana_persalinan: data.sumber_dana_persalinan || "JKN/BPJS",
            kendaraan_1_nama: data.kendaraan_1_nama || "",
            kendaraan_1_hp: data.kendaraan_1_hp || "",
            metode_kontrasepsi_pilihan: data.metode_kontrasepsi_pilihan || "",
            donor_golongan_darah: data.donor_golongan_darah || "",
            donor_rhesus: data.donor_rhesus || "",
          });
        } else {
          // Cek apakah sudah ada rencana untuk kehamilan ini (supaya tidak duplikat)
          const existing = await getRencanaByKehamilanId(targetKehamilan.id);
          if (existing && existing.length > 0) {
            const idExisting = existing[0].id_rencana_persalinan || existing[0].id;
            navigate(`/data-ibu/${ibuId}/rencana-persalinan/detail?id=${idExisting}&kehamilan_id=${targetKehamilan.id}`, { replace: true });
            return;
          }
        }
      } catch (err) {
        console.error(err);
        setError("Gagal memuat data: " + (err.response?.data?.message || err.message));
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, [ibuId, kehamilanIdQuery, rencanaId, navigate]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setForm(prev => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!kehamilan) {
      Swal.fire({
        icon: 'error',
        title: 'Error',
        text: 'Data kehamilan tidak ditemukan.'
      });
      return;
    }
    setSaving(true);
    setError("");
    try {
      const payload = {
        ...form,
        kehamilan_id: kehamilan.id,
        perkiraan_tahun_persalinan: form.perkiraan_tahun_persalinan ? parseInt(form.perkiraan_tahun_persalinan) : null,
      };
      let savedId;
      if (rencanaId && rencanaId !== "undefined" && rencanaId !== "null") {
        await updateRencana(rencanaId, payload);
        savedId = rencanaId;
      } else {
        const response = await createRencana(payload);
        savedId = response.data?.data?.id_rencana_persalinan || response.data?.data?.id;
        if (!savedId) throw new Error("Server tidak mengembalikan ID");
      }
      navigate(`/data-ibu/${ibuId}/rencana-persalinan/detail?id=${savedId}&kehamilan_id=${kehamilan.id}`, { replace: true });
    } catch (err) {
      console.error(err);
      setError("Gagal menyimpan: " + (err.response?.data?.message || err.message));
    } finally {
      setSaving(false);
    }
  };

  if (loading) return <MainLayout><div className="p-6 text-center">Memuat...</div></MainLayout>;

  return (
    <MainLayout>
      <div className="p-6 max-w-4xl mx-auto">
        <div className="flex items-center gap-4 mb-6">
          <button onClick={() => navigate(`/data-ibu/${ibuId}?kehamilan_id=${kehamilan?.id || ''}`)} className="p-2 rounded-full hover:bg-gray-100">
            <ArrowLeft size={20} />
          </button>
          <div>
            <h1 className="text-2xl font-bold">{rencanaId && rencanaId !== "undefined" ? "Edit Rencana Persalinan" : "Tambah Rencana Persalinan"}</h1>
            <p className="text-gray-500">Isi data rencana persalinan ibu hamil.</p>
            {kehamilan && <p className="text-xs text-gray-400">Kehamilan ID: {kehamilan.id}</p>}
          </div>
        </div>

        {error && (
          <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-lg flex items-center gap-2 text-red-700">
            <AlertCircle size={20} />
            <span>{error}</span>
          </div>
        )}

        <form onSubmit={handleSubmit} className="bg-white rounded-xl shadow-sm p-8 space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
            <div><label className="block text-sm font-semibold text-gray-700 mb-1">Nama Ibu <span className="text-red-500">*</span></label><input name="nama_ibu_pernyataan" value={form.nama_ibu_pernyataan} onChange={handleChange} className="w-full border border-gray-300 rounded-lg px-4 py-2" required/></div>
            <div><label className="block text-sm font-semibold text-gray-700 mb-1">Alamat Ibu</label><textarea name="alamat_ibu_pernyataan" value={form.alamat_ibu_pernyataan} onChange={handleChange} rows="2" className="w-full border border-gray-300 rounded-lg px-4 py-2"/></div>
            <div><label className="block text-sm font-semibold text-gray-700 mb-1">Perkiraan Bulan Persalinan</label><input name="perkiraan_bulan_persalinan" placeholder="Contoh: Januari" value={form.perkiraan_bulan_persalinan} onChange={handleChange} className="w-full border border-gray-300 rounded-lg px-4 py-2"/></div>
            <div><label className="block text-sm font-semibold text-gray-700 mb-1">Perkiraan Tahun Persalinan</label><input type="number" name="perkiraan_tahun_persalinan" placeholder="2025" value={form.perkiraan_tahun_persalinan} onChange={handleChange} className="w-full border border-gray-300 rounded-lg px-4 py-2"/></div>
            <div><label className="block text-sm font-semibold text-gray-700 mb-1">Fasilitas Kesehatan 1 - Nama Tenaga</label><input name="fasyankes_1_nama_tenaga" value={form.fasyankes_1_nama_tenaga} onChange={handleChange} className="w-full border border-gray-300 rounded-lg px-4 py-2"/></div>
            <div><label className="block text-sm font-semibold text-gray-700 mb-1">Fasilitas Kesehatan 1 - Nama Fasilitas</label><input name="fasyankes_1_nama_fasilitas" value={form.fasyankes_1_nama_fasilitas} onChange={handleChange} className="w-full border border-gray-300 rounded-lg px-4 py-2"/></div>
            <div><label className="block text-sm font-semibold text-gray-700 mb-1">Fasilitas Kesehatan 2 - Nama Tenaga</label><input name="fasyankes_2_nama_tenaga" value={form.fasyankes_2_nama_tenaga} onChange={handleChange} className="w-full border border-gray-300 rounded-lg px-4 py-2"/></div>
            <div><label className="block text-sm font-semibold text-gray-700 mb-1">Fasilitas Kesehatan 2 - Nama Fasilitas</label><input name="fasyankes_2_nama_fasilitas" value={form.fasyankes_2_nama_fasilitas} onChange={handleChange} className="w-full border border-gray-300 rounded-lg px-4 py-2"/></div>
            <div><label className="block text-sm font-semibold text-gray-700 mb-1">Sumber Dana Persalinan</label><select name="sumber_dana_persalinan" value={form.sumber_dana_persalinan} onChange={handleChange} className="w-full border border-gray-300 rounded-lg px-4 py-2"><option>JKN/BPJS</option><option>Jamkesda</option><option>Asuransi Swasta</option><option>Biaya sendiri</option></select></div>
            <div><label className="block text-sm font-semibold text-gray-700 mb-1">Kendaraan / Nama Pengantar</label><input name="kendaraan_1_nama" value={form.kendaraan_1_nama} onChange={handleChange} className="w-full border border-gray-300 rounded-lg px-4 py-2"/></div>
            <div><label className="block text-sm font-semibold text-gray-700 mb-1">No HP Kendaraan / Pengantar</label><input name="kendaraan_1_hp" value={form.kendaraan_1_hp} onChange={handleChange} className="w-full border border-gray-300 rounded-lg px-4 py-2"/></div>
            <div><label className="block text-sm font-semibold text-gray-700 mb-1">Metode Kontrasepsi Pilihan</label><input name="metode_kontrasepsi_pilihan" value={form.metode_kontrasepsi_pilihan} onChange={handleChange} className="w-full border border-gray-300 rounded-lg px-4 py-2"/></div>
            <div><label className="block text-sm font-semibold text-gray-700 mb-1">Golongan Darah Donor</label><input name="donor_golongan_darah" value={form.donor_golongan_darah} onChange={handleChange} className="w-full border border-gray-300 rounded-lg px-4 py-2"/></div>
            <div><label className="block text-sm font-semibold text-gray-700 mb-1">Rhesus Donor</label><input name="donor_rhesus" value={form.donor_rhesus} onChange={handleChange} className="w-full border border-gray-300 rounded-lg px-4 py-2"/></div>
          </div>
          <div className="flex gap-4 justify-end pt-6 border-t">
            <button type="button" onClick={() => navigate(`/data-ibu/${ibuId}?kehamilan_id=${kehamilan?.id || ''}`)} className="px-6 py-2 border rounded-lg bg-white text-gray-700 hover:bg-gray-50">Batal</button>
            <button type="submit" disabled={saving} className="px-8 py-2 bg-indigo-600 text-white rounded-lg flex items-center gap-2 hover:bg-indigo-700 disabled:opacity-50"><Save size={18} />{saving ? "Menyimpan..." : (rencanaId && rencanaId !== "undefined" ? "Perbarui" : "Simpan")}</button>
          </div>
        </form>
      </div>
    </MainLayout>
  );
}