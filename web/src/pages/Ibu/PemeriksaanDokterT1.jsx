// src/pages/Ibu/PemeriksaanDokterT1.jsx
import React, { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import Swal from "sweetalert2";
import MainLayout from "../../components/Layout/MainLayout";
import { getKehamilanByIbuId } from "../../services/kehamilan";
import { getDokterT1ByKehamilanId, createDokterT1, updateDokterT1 } from "../../services/pemeriksaanDokter";
import { Save } from "lucide-react";

const FisikSelect = ({ name, label, form, handleChange }) => (
  <div>
    <label className="block text-sm font-medium mb-1">{label}</label>
    <select name={name} value={form[name]} onChange={handleChange} className="w-full border rounded-lg px-3 py-2">
      <option>Normal</option><option>Abnormal</option>
    </select>
  </div>
);

export default function PemeriksaanDokterT1() {
  const { id } = useParams();
  const [kehamilan, setKehamilan] = useState(null);
  const [data, setData] = useState(null);
  const [form, setForm] = useState({
    nama_dokter: "", tanggal_periksa: "", konsep_anamnesa_pemeriksaan: "",
    fisik_konjungtiva: "Normal", fisik_sklera: "Normal", fisik_kulit: "Normal", fisik_leher: "Normal",
    fisik_gigi_mulut: "Normal", fisik_tht: "Normal", fisik_dada_jantung: "Normal", fisik_dada_paru: "Normal",
    fisik_perut: "Normal", fisik_tungkai: "Normal", hpht: "", keteraturan_haid: "Teratur",
    umur_hamil_hpht_minggu: "", hpl_berdasarkan_hpht: "", umur_hamil_usg_minggu: "", hpl_berdasarkan_usg: "",
    usg_jumlah_gs: "", usg_diameter_gs_cm: "", usg_diameter_gs_minggu: "", usg_diameter_gs_hari: "",
    usg_jumlah_bayi: "", usg_crl_cm: "", usg_crl_minggu: "", usg_crl_hari: "",
    usg_letak_produk_kehamilan: "", usg_pulsasi_jantung: "",
    usg_kecurigaan_temuan_abnormal: "Tidak", usg_keterangan_temuan_abnormal: "",
  });
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const kehamilanList = await getKehamilanByIbuId(id);
        if (kehamilanList.length > 0) {
          const aktif = kehamilanList[0];
          setKehamilan(aktif);
          const result = await getDokterT1ByKehamilanId(aktif.id);
          if (result && result.length > 0) {
            const d = result[0];
            setData(d);
            setForm({
              nama_dokter: d.nama_dokter || "", tanggal_periksa: d.tanggal_periksa ? new Date(d.tanggal_periksa).toISOString().split("T")[0] : "",
              konsep_anamnesa_pemeriksaan: d.konsep_anamnesa_pemeriksaan || "",
              fisik_konjungtiva: d.fisik_konjungtiva || "Normal", fisik_sklera: d.fisik_sklera || "Normal",
              fisik_kulit: d.fisik_kulit || "Normal", fisik_leher: d.fisik_leher || "Normal",
              fisik_gigi_mulut: d.fisik_gigi_mulut || "Normal", fisik_tht: d.fisik_tht || "Normal",
              fisik_dada_jantung: d.fisik_dada_jantung || "Normal", fisik_dada_paru: d.fisik_dada_paru || "Normal",
              fisik_perut: d.fisik_perut || "Normal", fisik_tungkai: d.fisik_tungkai || "Normal",
              hpht: d.hpht ? new Date(d.hpht).toISOString().split("T")[0] : "",
              keteraturan_haid: d.keteraturan_haid || "Teratur",
              umur_hamil_hpht_minggu: d.umur_hamil_hpht_minggu || "",
              hpl_berdasarkan_hpht: d.hpl_berdasarkan_hpht ? new Date(d.hpl_berdasarkan_hpht).toISOString().split("T")[0] : "",
              umur_hamil_usg_minggu: d.umur_hamil_usg_minggu || "",
              hpl_berdasarkan_usg: d.hpl_berdasarkan_usg ? new Date(d.hpl_berdasarkan_usg).toISOString().split("T")[0] : "",
              usg_jumlah_gs: d.usg_jumlah_gs || "", usg_diameter_gs_cm: d.usg_diameter_gs_cm || "",
              usg_diameter_gs_minggu: d.usg_diameter_gs_minggu || "", usg_diameter_gs_hari: d.usg_diameter_gs_hari || "",
              usg_jumlah_bayi: d.usg_jumlah_bayi || "", usg_crl_cm: d.usg_crl_cm || "",
              usg_crl_minggu: d.usg_crl_minggu || "", usg_crl_hari: d.usg_crl_hari || "",
              usg_letak_produk_kehamilan: d.usg_letak_produk_kehamilan || "",
              usg_pulsasi_jantung: d.usg_pulsasi_jantung || "",
              usg_kecurigaan_temuan_abnormal: d.usg_kecurigaan_temuan_abnormal || "Tidak",
              usg_keterangan_temuan_abnormal: d.usg_keterangan_temuan_abnormal || "",
            });
          }
        }
      } catch (err) { console.error(err); }
      finally { setLoading(false); }
    };
    fetchData();
  }, [id]);

  const handleChange = (e) => setForm({ ...form, [e.target.name]: e.target.value });

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!kehamilan) return;
    setSaving(true);
    try {
      const payload = {
        ...form, kehamilan_id: kehamilan.id,
        umur_hamil_hpht_minggu: parseInt(form.umur_hamil_hpht_minggu) || null,
        umur_hamil_usg_minggu: parseInt(form.umur_hamil_usg_minggu) || null,
        usg_diameter_gs_cm: parseFloat(form.usg_diameter_gs_cm) || null,
        usg_diameter_gs_minggu: parseInt(form.usg_diameter_gs_minggu) || null,
        usg_diameter_gs_hari: parseInt(form.usg_diameter_gs_hari) || null,
        usg_crl_cm: parseFloat(form.usg_crl_cm) || null,
        usg_crl_minggu: parseInt(form.usg_crl_minggu) || null,
        usg_crl_hari: parseInt(form.usg_crl_hari) || null,
      };
      if (data) await updateDokterT1(data.id_trimester_1, payload);
      else await createDokterT1(payload);
      await Swal.fire({
        icon: 'success',
        title: 'Berhasil',
        text: 'Pemeriksaan Dokter Trimester 1 berhasil disimpan',
        timer: 2000,
        showConfirmButton: false
      });
    } catch (err) {
      Swal.fire('Error', 'Gagal menyimpan data.', 'error');
      console.error(err);
    }
    finally { setSaving(false); }
  };

  if (loading) return <MainLayout><div className="p-6">Memuat...</div></MainLayout>;

  return (
    <MainLayout>
      <div className="p-6 max-w-5xl mx-auto">
        <h1 className="text-2xl font-bold mb-2">Pemeriksaan Dokter Trimester 1</h1>
        <p className="text-gray-500 mb-6">Evaluasi awal kehamilan oleh dokter termasuk pemeriksaan fisik dan USG pertama.</p>

        <form onSubmit={handleSubmit} className="bg-white rounded-xl shadow-sm p-6 space-y-6">
          <div>
            <h3 className="font-semibold mb-3 text-indigo-700">Data Pemeriksaan</h3>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div><label className="block text-sm font-medium mb-1">Nama Dokter</label><input name="nama_dokter" value={form.nama_dokter} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
              <div><label className="block text-sm font-medium mb-1">Tanggal Periksa</label><input type="date" name="tanggal_periksa" value={form.tanggal_periksa} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
              <div><label className="block text-sm font-medium mb-1">Konsep Anamnesa</label><textarea name="konsep_anamnesa_pemeriksaan" value={form.konsep_anamnesa_pemeriksaan} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" rows="2" /></div>
            </div>
          </div>

          <div>
            <h3 className="font-semibold mb-3 text-indigo-700">Pemeriksaan Fisik</h3>
            <div className="grid grid-cols-2 md:grid-cols-5 gap-4">
              <FisikSelect name="fisik_konjungtiva" label="Konjungtiva" form={form} handleChange={handleChange} />
              <FisikSelect name="fisik_sklera" label="Sklera" form={form} handleChange={handleChange} />
              <FisikSelect name="fisik_kulit" label="Kulit" form={form} handleChange={handleChange} />
              <FisikSelect name="fisik_leher" label="Leher" form={form} handleChange={handleChange} />
              <FisikSelect name="fisik_gigi_mulut" label="Gigi & Mulut" form={form} handleChange={handleChange} />
              <FisikSelect name="fisik_tht" label="THT" form={form} handleChange={handleChange} />
              <FisikSelect name="fisik_dada_jantung" label="Dada/Jantung" form={form} handleChange={handleChange} />
              <FisikSelect name="fisik_dada_paru" label="Dada/Paru" form={form} handleChange={handleChange} />
              <FisikSelect name="fisik_perut" label="Perut" form={form} handleChange={handleChange} />
              <FisikSelect name="fisik_tungkai" label="Tungkai" form={form} handleChange={handleChange} />
            </div>
          </div>

          <div>
            <h3 className="font-semibold mb-3 text-indigo-700">Usia Kehamilan</h3>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div><label className="block text-sm font-medium mb-1">HPHT</label><input type="date" name="hpht" value={form.hpht} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
              <div><label className="block text-sm font-medium mb-1">Keteraturan Haid</label><select name="keteraturan_haid" value={form.keteraturan_haid} onChange={handleChange} className="w-full border rounded-lg px-3 py-2"><option>Teratur</option><option>Tidak Teratur</option></select></div>
              <div><label className="block text-sm font-medium mb-1">UK berdasarkan HPHT (minggu)</label><input type="number" name="umur_hamil_hpht_minggu" value={form.umur_hamil_hpht_minggu} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
              <div><label className="block text-sm font-medium mb-1">HPL berdasarkan HPHT</label><input type="date" name="hpl_berdasarkan_hpht" value={form.hpl_berdasarkan_hpht} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
              <div><label className="block text-sm font-medium mb-1">UK berdasarkan USG (minggu)</label><input type="number" name="umur_hamil_usg_minggu" value={form.umur_hamil_usg_minggu} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
              <div><label className="block text-sm font-medium mb-1">HPL berdasarkan USG</label><input type="date" name="hpl_berdasarkan_usg" value={form.hpl_berdasarkan_usg} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
            </div>
          </div>

          <div>
            <h3 className="font-semibold mb-3 text-indigo-700">Hasil USG Trimester 1</h3>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
              <div><label className="block text-sm font-medium mb-1">Jumlah GS</label><input name="usg_jumlah_gs" value={form.usg_jumlah_gs} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
              <div><label className="block text-sm font-medium mb-1">Diameter GS (cm)</label><input type="number" step="0.1" name="usg_diameter_gs_cm" value={form.usg_diameter_gs_cm} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
              <div><label className="block text-sm font-medium mb-1">Diameter GS (minggu)</label><input type="number" name="usg_diameter_gs_minggu" value={form.usg_diameter_gs_minggu} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
              <div><label className="block text-sm font-medium mb-1">Diameter GS (hari)</label><input type="number" name="usg_diameter_gs_hari" value={form.usg_diameter_gs_hari} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
              <div><label className="block text-sm font-medium mb-1">Jumlah Bayi</label><input name="usg_jumlah_bayi" value={form.usg_jumlah_bayi} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
              <div><label className="block text-sm font-medium mb-1">CRL (cm)</label><input type="number" step="0.1" name="usg_crl_cm" value={form.usg_crl_cm} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
              <div><label className="block text-sm font-medium mb-1">CRL (minggu)</label><input type="number" name="usg_crl_minggu" value={form.usg_crl_minggu} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
              <div><label className="block text-sm font-medium mb-1">CRL (hari)</label><input type="number" name="usg_crl_hari" value={form.usg_crl_hari} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
              <div><label className="block text-sm font-medium mb-1">Letak Produk Kehamilan</label><input name="usg_letak_produk_kehamilan" value={form.usg_letak_produk_kehamilan} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
              <div><label className="block text-sm font-medium mb-1">Pulsasi Jantung</label><input name="usg_pulsasi_jantung" value={form.usg_pulsasi_jantung} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
              <div><label className="block text-sm font-medium mb-1">Kecurigaan Abnormal</label><select name="usg_kecurigaan_temuan_abnormal" value={form.usg_kecurigaan_temuan_abnormal} onChange={handleChange} className="w-full border rounded-lg px-3 py-2"><option>Tidak</option><option>Ya</option></select></div>
              <div><label className="block text-sm font-medium mb-1">Keterangan Abnormal</label><input name="usg_keterangan_temuan_abnormal" value={form.usg_keterangan_temuan_abnormal} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
            </div>
          </div>

          <button type="submit" disabled={saving} className="bg-indigo-600 text-white px-6 py-2 rounded-lg flex items-center gap-2">
            <Save size={18} /> {saving ? "Menyimpan..." : "Simpan Pemeriksaan Dokter T1"}
          </button>
        </form>
      </div>
    </MainLayout>
  );
}
