// src/pages/Ibu/PemeriksaanLanjutanT3.jsx
import React, { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import Swal from "sweetalert2";
import MainLayout from "../../components/Layout/MainLayout";
import { getKehamilanByIbuId } from "../../services/kehamilan";
import { getLanjutanT3ByKehamilanId, createLanjutanT3, updateLanjutanT3 } from "../../services/pemeriksaanDokter";
import { Save } from "lucide-react";

export default function PemeriksaanLanjutanT3() {
  const { id } = useParams();
  const [kehamilan, setKehamilan] = useState(null);
  const [data, setData] = useState(null);
  const [form, setForm] = useState({
    hasil_usg_catatan: "",
    tanggal_lab: "",
    lab_hemoglobin_hasil: "",
    lab_hemoglobin_rencana_tindak_lanjut: "",
    lab_protein_urin_hasil: "",
    lab_protein_urin_rencana_tindak_lanjut: "",
    lab_urin_reduksi_hasil: "",
    lab_urin_reduksi_rencana_tindak_lanjut: "",
    tanggal_skrining_jiwa: "",
    skrining_jiwa_hasil: "",
    skrining_jiwa_tindak_lanjut: "",
    skrining_jiwa_perlu_rujukan: "Tidak",
    rencana_konsultasi_gizi: false,
    rencana_konsultasi_kebidanan: false,
    rencana_konsultasi_anak: false,
    rencana_konsultasi_penyakit_dalam: false,
    rencana_konsultasi_neurologi: false,
    rencana_konsultasi_tht: false,
    rencana_konsultasi_psikiatri: false,
    rencana_konsultasi_lain_lain: "",
    rencana_proses_melahirkan: "",
    rencana_kontrasepsi_akdr: false,
    rencana_kontrasepsi_pil: false,
    rencana_kontrasepsi_suntik: false,
    rencana_kontrasepsi_steril: false,
    rencana_kontrasepsi_mal: false,
    rencana_kontrasepsi_implan: false,
    rencana_kontrasepsi_belum_memilih: false,
    kebutuhan_konseling: "Tidak",
    penjelasan: "",
    kesimpulan_rekomendasi_tempat_melahirkan: "",
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
          const result = await getLanjutanT3ByKehamilanId(aktif.id);
          if (result && result.length > 0) {
            const d = result[0];
            setData(d);
            setForm(prev => {
              const updated = { ...prev };
              Object.keys(prev).forEach(key => {
                if (d[key] !== undefined && d[key] !== null) {
                  if (key.includes("tanggal")) updated[key] = d[key] ? new Date(d[key]).toISOString().split("T")[0] : "";
                  else updated[key] = d[key];
                }
              });
              return updated;
            });
          }
        }
      } catch (err) { console.error(err); }
      finally { setLoading(false); }
    };
    fetchData();
  }, [id]);

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setForm({ ...form, [name]: type === "checkbox" ? checked : value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!kehamilan) return;
    setSaving(true);
    try {
      const payload = {
        ...form,
        kehamilan_id: kehamilan.id,
        lab_hemoglobin_hasil: parseFloat(form.lab_hemoglobin_hasil) || null,
        lab_protein_urin_hasil: parseInt(form.lab_protein_urin_hasil) || null,
      };
      if (data) await updateLanjutanT3(data.id_lanjutan_t3, payload);
      else await createLanjutanT3(payload);
      await Swal.fire({
        icon: 'success',
        title: 'Berhasil',
        text: 'Pemeriksaan Lanjutan T3 berhasil disimpan',
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
        <h1 className="text-2xl font-bold mb-2">Pemeriksaan Lanjutan Trimester 3</h1>
        <p className="text-gray-500 mb-6">Lab lanjutan, skrining jiwa, rencana konsultasi, dan kontrasepsi pasca persalinan.</p>
        <form onSubmit={handleSubmit} className="bg-white rounded-xl shadow-sm p-6 space-y-6">
          <div>
            <h3 className="font-semibold mb-3 text-indigo-700">Catatan USG</h3>
            <textarea name="hasil_usg_catatan" value={form.hasil_usg_catatan} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" rows="3" />
          </div>

          <div>
            <h3 className="font-semibold mb-3 text-indigo-700">Pemeriksaan Lab Lanjutan</h3>
            <div className="space-y-4">
              <div><label className="block text-sm font-medium mb-1">Tanggal Lab</label><input type="date" name="tanggal_lab" value={form.tanggal_lab} onChange={handleChange} className="w-full max-w-xs border rounded-lg px-3 py-2" /></div>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div><label className="block text-sm font-medium mb-1">Hemoglobin (g/dL)</label><input type="number" step="0.1" name="lab_hemoglobin_hasil" value={form.lab_hemoglobin_hasil} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
                <div className="md:col-span-2"><label className="block text-sm font-medium mb-1">Rencana Tindak Lanjut</label><input name="lab_hemoglobin_rencana_tindak_lanjut" value={form.lab_hemoglobin_rencana_tindak_lanjut} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
              </div>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div><label className="block text-sm font-medium mb-1">Protein Urin</label><input type="number" name="lab_protein_urin_hasil" value={form.lab_protein_urin_hasil} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
                <div className="md:col-span-2"><label className="block text-sm font-medium mb-1">Rencana</label><input name="lab_protein_urin_rencana_tindak_lanjut" value={form.lab_protein_urin_rencana_tindak_lanjut} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
              </div>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div><label className="block text-sm font-medium mb-1">Urin Reduksi</label><input name="lab_urin_reduksi_hasil" value={form.lab_urin_reduksi_hasil} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
                <div className="md:col-span-2"><label className="block text-sm font-medium mb-1">Rencana</label><input name="lab_urin_reduksi_rencana_tindak_lanjut" value={form.lab_urin_reduksi_rencana_tindak_lanjut} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
              </div>
            </div>
          </div>

          <div>
            <h3 className="font-semibold mb-3 text-indigo-700">Skrining Kesehatan Jiwa</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div><label className="block text-sm font-medium mb-1">Tanggal Skrining</label><input type="date" name="tanggal_skrining_jiwa" value={form.tanggal_skrining_jiwa} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
              <div><label className="block text-sm font-medium mb-1">Hasil</label><input name="skrining_jiwa_hasil" value={form.skrining_jiwa_hasil} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" maxLength={10} /></div>
              <div><label className="block text-sm font-medium mb-1">Tindak Lanjut</label><input name="skrining_jiwa_tindak_lanjut" value={form.skrining_jiwa_tindak_lanjut} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" maxLength={10} /></div>
              <div><label className="block text-sm font-medium mb-1">Perlu Rujukan?</label><select name="skrining_jiwa_perlu_rujukan" value={form.skrining_jiwa_perlu_rujukan} onChange={handleChange} className="w-full border rounded-lg px-3 py-2"><option>Tidak</option><option>Ya</option></select></div>
            </div>
          </div>

          <div>
            <h3 className="font-semibold mb-3 text-indigo-700">Rencana Konsultasi</h3>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-2">
              {[
                {name:"rencana_konsultasi_gizi",label:"Gizi"},{name:"rencana_konsultasi_kebidanan",label:"Kebidanan"},
                {name:"rencana_konsultasi_anak",label:"Anak"},{name:"rencana_konsultasi_penyakit_dalam",label:"Penyakit Dalam"},
                {name:"rencana_konsultasi_neurologi",label:"Neurologi"},{name:"rencana_konsultasi_tht",label:"THT"},
                {name:"rencana_konsultasi_psikiatri",label:"Psikiatri"},
              ].map(item => (
                <label key={item.name} className="flex items-center gap-2 text-sm"><input type="checkbox" name={item.name} checked={form[item.name]} onChange={handleChange} className="rounded" />{item.label}</label>
              ))}
            </div>
            <div className="mt-2"><label className="block text-sm font-medium mb-1">Konsultasi Lain-lain</label><input name="rencana_konsultasi_lain_lain" value={form.rencana_konsultasi_lain_lain} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
            <div className="mt-2"><label className="block text-sm font-medium mb-1">Rencana Proses Melahirkan</label><input name="rencana_proses_melahirkan" value={form.rencana_proses_melahirkan} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
          </div>

          <div>
            <h3 className="font-semibold mb-3 text-indigo-700">Rencana Kontrasepsi Pasca Persalinan</h3>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-2">
              {[
                {name:"rencana_kontrasepsi_akdr",label:"AKDR"},{name:"rencana_kontrasepsi_pil",label:"Pil"},
                {name:"rencana_kontrasepsi_suntik",label:"Suntik"},{name:"rencana_kontrasepsi_steril",label:"Steril"},
                {name:"rencana_kontrasepsi_mal",label:"MAL"},{name:"rencana_kontrasepsi_implan",label:"Implan"},
                {name:"rencana_kontrasepsi_belum_memilih",label:"Belum Memilih"},
              ].map(item => (
                <label key={item.name} className="flex items-center gap-2 text-sm"><input type="checkbox" name={item.name} checked={form[item.name]} onChange={handleChange} className="rounded" />{item.label}</label>
              ))}
            </div>
          </div>

          <div>
            <h3 className="font-semibold mb-3 text-indigo-700">Konseling & Kesimpulan</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div><label className="block text-sm font-medium mb-1">Kebutuhan Konseling</label><select name="kebutuhan_konseling" value={form.kebutuhan_konseling} onChange={handleChange} className="w-full border rounded-lg px-3 py-2"><option>Tidak</option><option>Ya</option></select></div>
              <div><label className="block text-sm font-medium mb-1">Rekomendasi Tempat Melahirkan</label><input name="kesimpulan_rekomendasi_tempat_melahirkan" value={form.kesimpulan_rekomendasi_tempat_melahirkan} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
            </div>
            <div className="mt-2"><label className="block text-sm font-medium mb-1">Penjelasan</label><textarea name="penjelasan" value={form.penjelasan} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" rows="3" /></div>
          </div>

          <button type="submit" disabled={saving} className="bg-indigo-600 text-white px-6 py-2 rounded-lg flex items-center gap-2">
            <Save size={18} /> {saving ? "Menyimpan..." : "Simpan Pemeriksaan Lanjutan T3"}
          </button>
        </form>
      </div>
    </MainLayout>
  );
}
