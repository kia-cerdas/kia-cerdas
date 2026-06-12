// src/pages/Ibu/PemeriksaanLabJiwa.jsx
import React, { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import Swal from "sweetalert2";
import MainLayout from "../../components/Layout/MainLayout";
import { getKehamilanByIbuId } from "../../services/kehamilan";
import { getLabJiwaByKehamilanId, createLabJiwa, updateLabJiwa } from "../../services/pemeriksaanDokter";
import { Save } from "lucide-react";

const LabRow = ({ label, nameHasil, nameRencana, typeHasil = "text", form, handleChange }) => (
  <div className="grid grid-cols-1 md:grid-cols-3 gap-4 items-end">
    <div><label className="block text-sm font-medium mb-1">{label} - Hasil</label><input type={typeHasil} name={nameHasil} value={form[nameHasil]} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
    <div className="md:col-span-2"><label className="block text-sm font-medium mb-1">Rencana Tindak Lanjut</label><input name={nameRencana} value={form[nameRencana]} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
  </div>
);

const TripleEliminasiRow = ({ label, nameHasil, nameRencana, form, handleChange }) => (
  <div className="grid grid-cols-1 md:grid-cols-3 gap-4 items-end">
    <div>
      <label className="block text-sm font-medium mb-1">{label} - Hasil</label>
      <select name={nameHasil} value={form[nameHasil]} onChange={handleChange} className="w-full border rounded-lg px-3 py-2">
        <option value="NonReaktif">Non-Reaktif</option><option value="Reaktif">Reaktif</option>
      </select>
    </div>
    <div className="md:col-span-2"><label className="block text-sm font-medium mb-1">Rencana Tindak Lanjut</label><input name={nameRencana} value={form[nameRencana]} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
  </div>
);

export default function PemeriksaanLabJiwa() {
  const { id } = useParams();
  const [kehamilan, setKehamilan] = useState(null);
  const [data, setData] = useState(null);
  const [form, setForm] = useState({
    tanggal_lab: "",
    lab_hemoglobin_hasil: "",
    lab_hemoglobin_rencana_tindak_lanjut: "",
    lab_golongan_darah_rhesus_hasil: "",
    lab_golongan_darah_rhesus_rencana_tindak_lanjut: "",
    lab_gula_darah_sewaktu_hasil: "",
    lab_gula_darah_sewaktu_rencana_tindak_lanjut: "",
    lab_hiv_hasil: "NonReaktif",
    lab_hiv_rencana_tindak_lanjut: "",
    lab_sifilis_hasil: "NonReaktif",
    lab_sifilis_rencana_tindak_lanjut: "",
    lab_hepatitis_b_hasil: "NonReaktif",
    lab_hepatitis_b_rencana_tindak_lanjut: "",
    tanggal_skrining_jiwa: "",
    skrining_jiwa_hasil: "",
    skrining_jiwa_tindak_lanjut: "",
    skrining_jiwa_perlu_rujukan: "Tidak",
    kesimpulan: "",
    rekomendasi: "",
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
          const result = await getLabJiwaByKehamilanId(aktif.id);
          if (result && result.length > 0) {
            const d = result[0];
            setData(d);
            setForm({
              tanggal_lab: d.tanggal_lab ? new Date(d.tanggal_lab).toISOString().split("T")[0] : "",
              lab_hemoglobin_hasil: d.lab_hemoglobin_hasil || "",
              lab_hemoglobin_rencana_tindak_lanjut: d.lab_hemoglobin_rencana_tindak_lanjut || "",
              lab_golongan_darah_rhesus_hasil: d.lab_golongan_darah_rhesus_hasil || "",
              lab_golongan_darah_rhesus_rencana_tindak_lanjut: d.lab_golongan_darah_rhesus_rencana_tindak_lanjut || "",
              lab_gula_darah_sewaktu_hasil: d.lab_gula_darah_sewaktu_hasil || "",
              lab_gula_darah_sewaktu_rencana_tindak_lanjut: d.lab_gula_darah_sewaktu_rencana_tindak_lanjut || "",
              lab_hiv_hasil: d.lab_hiv_hasil || "NonReaktif",
              lab_hiv_rencana_tindak_lanjut: d.lab_hiv_rencana_tindak_lanjut || "",
              lab_sifilis_hasil: d.lab_sifilis_hasil || "NonReaktif",
              lab_sifilis_rencana_tindak_lanjut: d.lab_sifilis_rencana_tindak_lanjut || "",
              lab_hepatitis_b_hasil: d.lab_hepatitis_b_hasil || "NonReaktif",
              lab_hepatitis_b_rencana_tindak_lanjut: d.lab_hepatitis_b_rencana_tindak_lanjut || "",
              tanggal_skrining_jiwa: d.tanggal_skrining_jiwa ? new Date(d.tanggal_skrining_jiwa).toISOString().split("T")[0] : "",
              skrining_jiwa_hasil: d.skrining_jiwa_hasil || "",
              skrining_jiwa_tindak_lanjut: d.skrining_jiwa_tindak_lanjut || "",
              skrining_jiwa_perlu_rujukan: d.skrining_jiwa_perlu_rujukan || "Tidak",
              kesimpulan: d.kesimpulan || "",
              rekomendasi: d.rekomendasi || "",
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
        ...form,
        kehamilan_id: kehamilan.id,
        lab_hemoglobin_hasil: parseFloat(form.lab_hemoglobin_hasil) || null,
        lab_gula_darah_sewaktu_hasil: parseInt(form.lab_gula_darah_sewaktu_hasil) || null,
      };
      if (data) await updateLabJiwa(data.id_lab_jiwa, payload);
      else await createLabJiwa(payload);
      await Swal.fire({
        icon: 'success',
        title: 'Berhasil',
        text: 'Pemeriksaan Lab & Skrining Jiwa berhasil disimpan',
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
        <h1 className="text-2xl font-bold mb-2">Pemeriksaan Laboratorium & Skrining Jiwa</h1>
        <p className="text-gray-500 mb-6">Pemeriksaan lab darah, triple eliminasi (HIV, Sifilis, Hepatitis B), dan skrining kesehatan jiwa.</p>

        <form onSubmit={handleSubmit} className="bg-white rounded-xl shadow-sm p-6 space-y-6">
          <div><label className="block text-sm font-medium mb-1">Tanggal Pemeriksaan Lab</label><input type="date" name="tanggal_lab" value={form.tanggal_lab} onChange={handleChange} className="w-full max-w-xs border rounded-lg px-3 py-2" /></div>

          <div>
            <h3 className="font-semibold mb-3 text-indigo-700">Pemeriksaan Darah</h3>
            <div className="space-y-4">
              <LabRow label="Hemoglobin (g/dL)" nameHasil="lab_hemoglobin_hasil" nameRencana="lab_hemoglobin_rencana_tindak_lanjut" typeHasil="number" form={form} handleChange={handleChange} />
              <LabRow label="Golongan Darah & Rhesus" nameHasil="lab_golongan_darah_rhesus_hasil" nameRencana="lab_golongan_darah_rhesus_rencana_tindak_lanjut" form={form} handleChange={handleChange} />
              <LabRow label="Gula Darah Sewaktu (mg/dL)" nameHasil="lab_gula_darah_sewaktu_hasil" nameRencana="lab_gula_darah_sewaktu_rencana_tindak_lanjut" typeHasil="number" form={form} handleChange={handleChange} />
            </div>
          </div>

          <div>
            <h3 className="font-semibold mb-3 text-indigo-700">Triple Eliminasi</h3>
            <div className="space-y-4">
              <TripleEliminasiRow label="HIV" nameHasil="lab_hiv_hasil" nameRencana="lab_hiv_rencana_tindak_lanjut" form={form} handleChange={handleChange} />
              <TripleEliminasiRow label="Sifilis" nameHasil="lab_sifilis_hasil" nameRencana="lab_sifilis_rencana_tindak_lanjut" form={form} handleChange={handleChange} />
              <TripleEliminasiRow label="Hepatitis B" nameHasil="lab_hepatitis_b_hasil" nameRencana="lab_hepatitis_b_rencana_tindak_lanjut" form={form} handleChange={handleChange} />
            </div>
          </div>

          <div>
            <h3 className="font-semibold mb-3 text-indigo-700">Skrining Kesehatan Jiwa</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div><label className="block text-sm font-medium mb-1">Tanggal Skrining</label><input type="date" name="tanggal_skrining_jiwa" value={form.tanggal_skrining_jiwa} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
              <div><label className="block text-sm font-medium mb-1">Hasil Skrining</label><input name="skrining_jiwa_hasil" value={form.skrining_jiwa_hasil} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" maxLength={10} /></div>
              <div><label className="block text-sm font-medium mb-1">Tindak Lanjut</label><input name="skrining_jiwa_tindak_lanjut" value={form.skrining_jiwa_tindak_lanjut} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
              <div><label className="block text-sm font-medium mb-1">Perlu Rujukan?</label><select name="skrining_jiwa_perlu_rujukan" value={form.skrining_jiwa_perlu_rujukan} onChange={handleChange} className="w-full border rounded-lg px-3 py-2"><option>Tidak</option><option>Ya</option></select></div>
            </div>
          </div>

          <div>
            <h3 className="font-semibold mb-3 text-indigo-700">Kesimpulan & Rekomendasi</h3>
            <div className="space-y-4">
              <div><label className="block text-sm font-medium mb-1">Kesimpulan</label><textarea name="kesimpulan" value={form.kesimpulan} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" rows="3" /></div>
              <div><label className="block text-sm font-medium mb-1">Rekomendasi</label><textarea name="rekomendasi" value={form.rekomendasi} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" rows="3" /></div>
            </div>
          </div>

          <button type="submit" disabled={saving} className="bg-indigo-600 text-white px-6 py-2 rounded-lg flex items-center gap-2">
            <Save size={18} /> {saving ? "Menyimpan..." : "Simpan Pemeriksaan Lab & Jiwa"}
          </button>
        </form>
      </div>
    </MainLayout>
  );
}
