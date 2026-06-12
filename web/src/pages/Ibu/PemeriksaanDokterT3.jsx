// src/pages/Ibu/PemeriksaanDokterT3.jsx
import React, { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import Swal from "sweetalert2";
import MainLayout from "../../components/Layout/MainLayout";
import { getKehamilanByIbuId } from "../../services/kehamilan";
import { getDokterT3ByKehamilanId, createDokterT3, updateDokterT3 } from "../../services/pemeriksaanDokter";
import { Save } from "lucide-react";

export default function PemeriksaanDokterT3() {
  const { id } = useParams();
  const [kehamilan, setKehamilan] = useState(null);
  const [data, setData] = useState(null);
  const [form, setForm] = useState({
    nama_dokter: "", tanggal_periksa: "", konsep_anamnesa_pemeriksaan: "",
    fisik_konjungtiva: "Normal", fisik_sklera: "Normal", fisik_kulit: "Normal", fisik_leher: "Normal",
    fisik_gigi_mulut: "Normal", fisik_tht: "Normal", fisik_dada_jantung: "Normal", fisik_dada_paru: "Normal",
    fisik_perut: "Normal", fisik_tungkai: "Normal",
    usg_trimester_3_dilakukan: "Ya",
    uk_berdasarkan_usg_trimester_1_minggu: "", uk_berdasarkan_hpht_minggu: "",
    uk_berdasarkan_biometri_usg_trimester_3_minggu: "", selisih_uk_3_minggu_atau_lebih: "Tidak",
    usg_jumlah_bayi: "", usg_letak_bayi: "", usg_presentasi_bayi: "", usg_keadaan_bayi: "",
    usg_djj_nilai: "", usg_djj_status: "Normal", usg_lokasi_plasenta: "",
    usg_cairan_ketuban_sdp_cm: "", usg_cairan_ketuban_status: "Normal",
    biometri_bpd_cm: "", biometri_bpd_minggu: "", biometri_hc_cm: "", biometri_hc_minggu: "",
    biometri_ac_cm: "", biometri_ac_minggu: "", biometri_fl_cm: "", biometri_fl_minggu: "",
    biometri_efw_tbj_gram: "", biometri_efw_tbj_minggu: "",
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
          const result = await getDokterT3ByKehamilanId(aktif.id);
          if (result && result.length > 0) {
            const d = result[0];
            setData(d);
            setForm(prev => {
              const updated = { ...prev };
              Object.keys(prev).forEach(key => {
                if (d[key] !== undefined && d[key] !== null) {
                  if (key === "tanggal_periksa") updated[key] = new Date(d[key]).toISOString().split("T")[0];
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

  const handleChange = (e) => setForm({ ...form, [e.target.name]: e.target.value });

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!kehamilan) return;
    setSaving(true);
    try {
      const numFields = ["uk_berdasarkan_usg_trimester_1_minggu", "uk_berdasarkan_hpht_minggu",
        "uk_berdasarkan_biometri_usg_trimester_3_minggu", "usg_djj_nilai",
        "biometri_bpd_minggu", "biometri_hc_minggu", "biometri_ac_minggu", "biometri_fl_minggu",
        "biometri_efw_tbj_gram", "biometri_efw_tbj_minggu"];
      const floatFields = ["usg_cairan_ketuban_sdp_cm", "biometri_bpd_cm", "biometri_hc_cm",
        "biometri_ac_cm", "biometri_fl_cm"];
      const payload = { ...form, kehamilan_id: kehamilan.id };
      numFields.forEach(f => { payload[f] = parseInt(form[f]) || null; });
      floatFields.forEach(f => { payload[f] = parseFloat(form[f]) || null; });
      if (data) await updateDokterT3(data.id_trimester_3, payload);
      else await createDokterT3(payload);
      await Swal.fire({
        icon: 'success',
        title: 'Berhasil',
        text: 'Pemeriksaan Dokter Trimester 3 berhasil disimpan',
        timer: 2000,
        showConfirmButton: false
      });
    } catch (err) {
      Swal.fire('Error', 'Gagal menyimpan data.', 'error');
      console.error(err);
    }
    finally { setSaving(false); }
  };

  const FisikSelect = ({ name, label }) => (
    <div>
      <label className="block text-sm font-medium mb-1">{label}</label>
      <select name={name} value={form[name]} onChange={handleChange} className="w-full border rounded-lg px-3 py-2">
        <option>Normal</option><option>Abnormal</option>
      </select>
    </div>
  );

  if (loading) return <MainLayout><div className="p-6">Memuat...</div></MainLayout>;

  return (
    <MainLayout>
      <div className="p-6 max-w-5xl mx-auto">
        <h1 className="text-2xl font-bold mb-2">Pemeriksaan Dokter Trimester 3</h1>
        <p className="text-gray-500 mb-6">Evaluasi akhir kehamilan meliputi USG biometri dan pemeriksaan fisik lengkap.</p>
        <form onSubmit={handleSubmit} className="bg-white rounded-xl shadow-sm p-6 space-y-6">
          <div>
            <h3 className="font-semibold mb-3 text-indigo-700">Data Pemeriksaan</h3>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div><label className="block text-sm font-medium mb-1">Nama Dokter</label><input name="nama_dokter" value={form.nama_dokter} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
              <div><label className="block text-sm font-medium mb-1">Tanggal Periksa</label><input type="date" name="tanggal_periksa" value={form.tanggal_periksa} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
              <div><label className="block text-sm font-medium mb-1">Anamnesa</label><textarea name="konsep_anamnesa_pemeriksaan" value={form.konsep_anamnesa_pemeriksaan} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" rows="2" /></div>
            </div>
          </div>
          <div>
            <h3 className="font-semibold mb-3 text-indigo-700">Pemeriksaan Fisik</h3>
            <div className="grid grid-cols-2 md:grid-cols-5 gap-4">
              {["konjungtiva","sklera","kulit","leher","gigi_mulut","tht","dada_jantung","dada_paru","perut","tungkai"].map(f => (
                <FisikSelect key={f} name={`fisik_${f}`} label={f.replace("_"," ").replace(/\b\w/g,l=>l.toUpperCase())} />
              ))}
            </div>
          </div>
          <div>
            <h3 className="font-semibold mb-3 text-indigo-700">USG Trimester 3</h3>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
              <div><label className="block text-sm font-medium mb-1">USG Dilakukan?</label><select name="usg_trimester_3_dilakukan" value={form.usg_trimester_3_dilakukan} onChange={handleChange} className="w-full border rounded-lg px-3 py-2"><option>Ya</option><option>Tidak</option></select></div>
              <div><label className="block text-sm font-medium mb-1">UK USG T1 (minggu)</label><input type="number" name="uk_berdasarkan_usg_trimester_1_minggu" value={form.uk_berdasarkan_usg_trimester_1_minggu} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
              <div><label className="block text-sm font-medium mb-1">UK HPHT (minggu)</label><input type="number" name="uk_berdasarkan_hpht_minggu" value={form.uk_berdasarkan_hpht_minggu} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
              <div><label className="block text-sm font-medium mb-1">UK Biometri T3 (minggu)</label><input type="number" name="uk_berdasarkan_biometri_usg_trimester_3_minggu" value={form.uk_berdasarkan_biometri_usg_trimester_3_minggu} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
              <div><label className="block text-sm font-medium mb-1">Selisih ≥3 minggu?</label><select name="selisih_uk_3_minggu_atau_lebih" value={form.selisih_uk_3_minggu_atau_lebih} onChange={handleChange} className="w-full border rounded-lg px-3 py-2"><option>Tidak</option><option>Ya</option></select></div>
              <div><label className="block text-sm font-medium mb-1">Jumlah Bayi</label><input name="usg_jumlah_bayi" value={form.usg_jumlah_bayi} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
              <div><label className="block text-sm font-medium mb-1">Letak Bayi</label><input name="usg_letak_bayi" value={form.usg_letak_bayi} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
              <div><label className="block text-sm font-medium mb-1">Presentasi</label><input name="usg_presentasi_bayi" value={form.usg_presentasi_bayi} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
              <div><label className="block text-sm font-medium mb-1">Keadaan Bayi</label><input name="usg_keadaan_bayi" value={form.usg_keadaan_bayi} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
              <div><label className="block text-sm font-medium mb-1">DJJ (x/menit)</label><input type="number" name="usg_djj_nilai" value={form.usg_djj_nilai} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
              <div><label className="block text-sm font-medium mb-1">Status DJJ</label><select name="usg_djj_status" value={form.usg_djj_status} onChange={handleChange} className="w-full border rounded-lg px-3 py-2"><option>Normal</option><option>Abnormal</option></select></div>
              <div><label className="block text-sm font-medium mb-1">Lokasi Plasenta</label><input name="usg_lokasi_plasenta" value={form.usg_lokasi_plasenta} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
              <div><label className="block text-sm font-medium mb-1">Cairan Ketuban SDP (cm)</label><input type="number" step="0.1" name="usg_cairan_ketuban_sdp_cm" value={form.usg_cairan_ketuban_sdp_cm} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
              <div><label className="block text-sm font-medium mb-1">Status Ketuban</label><select name="usg_cairan_ketuban_status" value={form.usg_cairan_ketuban_status} onChange={handleChange} className="w-full border rounded-lg px-3 py-2"><option>Normal</option><option>Oligohidramnion</option><option>Polihidramnion</option></select></div>
            </div>
          </div>
          <div>
            <h3 className="font-semibold mb-3 text-indigo-700">Biometri Janin</h3>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
              {[{l:"BPD",p:"bpd"},{l:"HC",p:"hc"},{l:"AC",p:"ac"},{l:"FL",p:"fl"}].map(({l,p})=>(
                <React.Fragment key={p}>
                  <div><label className="block text-sm font-medium mb-1">{l} (cm)</label><input type="number" step="0.1" name={`biometri_${p}_cm`} value={form[`biometri_${p}_cm`]} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
                  <div><label className="block text-sm font-medium mb-1">{l} (minggu)</label><input type="number" name={`biometri_${p}_minggu`} value={form[`biometri_${p}_minggu`]} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
                </React.Fragment>
              ))}
              <div><label className="block text-sm font-medium mb-1">EFW/TBJ (gram)</label><input type="number" name="biometri_efw_tbj_gram" value={form.biometri_efw_tbj_gram} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
              <div><label className="block text-sm font-medium mb-1">EFW/TBJ (minggu)</label><input type="number" name="biometri_efw_tbj_minggu" value={form.biometri_efw_tbj_minggu} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
              <div><label className="block text-sm font-medium mb-1">Kecurigaan Abnormal</label><select name="usg_kecurigaan_temuan_abnormal" value={form.usg_kecurigaan_temuan_abnormal} onChange={handleChange} className="w-full border rounded-lg px-3 py-2"><option>Tidak</option><option>Ya</option></select></div>
              <div><label className="block text-sm font-medium mb-1">Keterangan</label><input name="usg_keterangan_temuan_abnormal" value={form.usg_keterangan_temuan_abnormal} onChange={handleChange} className="w-full border rounded-lg px-3 py-2" /></div>
            </div>
          </div>
          <button type="submit" disabled={saving} className="bg-indigo-600 text-white px-6 py-2 rounded-lg flex items-center gap-2">
            <Save size={18} /> {saving ? "Menyimpan..." : "Simpan Pemeriksaan Dokter T3"}
          </button>
        </form>
      </div>
    </MainLayout>
  );
}
