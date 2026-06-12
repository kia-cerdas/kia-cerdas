// src/pages/Ibu/PemeriksaanFisik.jsx
import React, { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import Swal from "sweetalert2";
import MainLayout from "../../components/Layout/MainLayout";
import { getKehamilanByIbuId } from "../../services/kehamilan";
import { getPemeriksaanByKehamilanId, createPemeriksaan, updatePemeriksaan } from "../../services/pemeriksaan";
import { Save } from "lucide-react";

export default function PemeriksaanFisik() {
  const { id } = useParams();
  const [kehamilan, setKehamilan] = useState(null);
  const [pemeriksaan, setPemeriksaan] = useState(null);
  const [form, setForm] = useState({
    trimester: "T2",
    kunjungan_ke: 1,
    tanggal_periksa: "",
    tempat_periksa: "Puskesmas",
    berat_badan: "",
    tinggi_badan: "",
    lingkar_lengan_atas: "",
    tekanan_darah: "",
    tinggi_rahim: "",
    letak_denyut_jantung_bayi: "",
    status_imunisasi_tetanus: "",
    konseling: "",
    skrining_dokter: "",
    tablet_tambah_darah: "",
    tes_lab_hb: "",
    tes_golongan_darah: "",
    tes_lab_protein_urine: "",
    tes_lab_gula_darah: "",
    usg: "",
    tripel_eliminasi: "",
    tata_laksana_kasus: "",
  });
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    const fetch = async () => {
      try {
        const kehamilanList = await getKehamilanByIbuId(id);
        if (kehamilanList.length > 0) {
          const aktif = kehamilanList[0];
          setKehamilan(aktif);
          const data = await getPemeriksaanByKehamilanId(aktif.id);
          if (data && data.length > 0) {
            const p = data[0];
            setPemeriksaan(p);
            setForm({
              trimester: p.trimester,
              kunjungan_ke: p.kunjungan_ke,
              tanggal_periksa: p.tanggal_periksa ? new Date(p.tanggal_periksa).toISOString().split("T")[0] : "",
              tempat_periksa: p.tempat_periksa,
              berat_badan: p.berat_badan || "",
              tinggi_badan: p.tinggi_badan || "",
              lingkar_lengan_atas: p.lingkar_lengan_atas || "",
              tekanan_darah: p.tekanan_darah,
              tinggi_rahim: p.tinggi_rahim || "",
              letak_denyut_jantung_bayi: p.letak_denyut_jantung_bayi,
              status_imunisasi_tetanus: p.status_imunisasi_tetanus,
              konseling: p.konseling,
              skrining_dokter: p.skrining_dokter,
              tablet_tambah_darah: p.tablet_tambah_darah || "",
              tes_lab_hb: p.tes_lab_hb || "",
              tes_golongan_darah: p.tes_golongan_darah,
              tes_lab_protein_urine: p.tes_lab_protein_urine,
              tes_lab_gula_darah: p.tes_lab_gula_darah || "",
              usg: p.usg,
              tripel_eliminasi: p.tripel_eliminasi,
              tata_laksana_kasus: p.tata_laksana_kasus,
            });
          }
        }
      } catch (err) {
        console.error(err);
      } finally {
        setLoading(false);
      }
    };
    fetch();
  }, [id]);

  const handleChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!kehamilan) return;
    setSaving(true);
    try {
      const payload = { ...form, kehamilan_id: kehamilan.id, berat_badan: parseFloat(form.berat_badan) || 0, tinggi_badan: parseFloat(form.tinggi_badan) || 0 };
      if (pemeriksaan) {
        await updatePemeriksaan(pemeriksaan.id, payload);
      } else {
        await createPemeriksaan(payload);
      }
      await Swal.fire({
        icon: 'success',
        title: 'Berhasil',
        text: 'Pemeriksaan berhasil disimpan',
        timer: 2000,
        showConfirmButton: false
      });
    } catch (err) {
      Swal.fire('Error', 'Gagal menyimpan pemeriksaan', 'error');
    } finally {
      setSaving(false);
    }
  };

  if (loading) return <MainLayout><div className="p-6">Memuat...</div></MainLayout>;

  return (
    <MainLayout>
      <div className="p-6 max-w-4xl mx-auto">
        <h1 className="text-2xl font-bold mb-2">Pemeriksaan Fisik & Antenatal Care (ANC)</h1>
        <form onSubmit={handleSubmit} className="bg-white rounded-xl shadow-sm p-6 space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div><label>Trimester</label><select name="trimester" value={form.trimester} onChange={handleChange} className="w-full border rounded px-3 py-2"><option value="T1">TRIMESTER 1</option><option value="T2">TRIMESTER 2</option><option value="T3">TRIMESTER 3</option></select></div>
            <div><label>Kunjungan ke-</label><input type="number" name="kunjungan_ke" value={form.kunjungan_ke} onChange={handleChange} className="w-full border rounded px-3 py-2" /></div>
            <div><label>Tanggal Periksa</label><input type="date" name="tanggal_periksa" value={form.tanggal_periksa} onChange={handleChange} className="w-full border rounded px-3 py-2" /></div>
            <div><label>Tempat Periksa</label><input name="tempat_periksa" value={form.tempat_periksa} onChange={handleChange} className="w-full border rounded px-3 py-2" /></div>
            <div><label>Berat Badan (kg)</label><input type="number" step="0.1" name="berat_badan" value={form.berat_badan} onChange={handleChange} className="w-full border rounded px-3 py-2" /></div>
            <div><label>Tinggi Badan (cm)</label><input type="number" step="0.1" name="tinggi_badan" value={form.tinggi_badan} onChange={handleChange} className="w-full border rounded px-3 py-2" /></div>
            <div><label>LILA (cm)</label><input type="number" step="0.1" name="lingkar_lengan_atas" value={form.lingkar_lengan_atas} onChange={handleChange} className="w-full border rounded px-3 py-2" /></div>
            <div><label>Tekanan Darah (mmHg)</label><input name="tekanan_darah" placeholder="120/80" value={form.tekanan_darah} onChange={handleChange} className="w-full border rounded px-3 py-2" /></div>
            <div><label>Tinggi Rahim (cm)</label><input type="number" step="0.1" name="tinggi_rahim" value={form.tinggi_rahim} onChange={handleChange} className="w-full border rounded px-3 py-2" /></div>
            <div><label>Letak Denyut Jantung Janin</label><input name="letak_denyut_jantung_bayi" value={form.letak_denyut_jantung_bayi} onChange={handleChange} className="w-full border rounded px-3 py-2" /></div>
            <div><label>Status Imunisasi Tetanus</label><input name="status_imunisasi_tetanus" value={form.status_imunisasi_tetanus} onChange={handleChange} className="w-full border rounded px-3 py-2" /></div>
            <div><label>Konseling</label><textarea name="konseling" value={form.konseling} onChange={handleChange} className="w-full border rounded px-3 py-2" rows="2" /></div>
            <div><label>Skrining Dokter</label><textarea name="skrining_dokter" value={form.skrining_dokter} onChange={handleChange} className="w-full border rounded px-3 py-2" rows="2" /></div>
            <div><label>Tablet Tambah Darah (jumlah)</label><input type="number" name="tablet_tambah_darah" value={form.tablet_tambah_darah} onChange={handleChange} className="w-full border rounded px-3 py-2" /></div>
            <div><label>Hemoglobin (g/dL)</label><input type="number" step="0.1" name="tes_lab_hb" value={form.tes_lab_hb} onChange={handleChange} className="w-full border rounded px-3 py-2" /></div>
            <div><label>Golongan Darah</label><input name="tes_golongan_darah" value={form.tes_golongan_darah} onChange={handleChange} className="w-full border rounded px-3 py-2" maxLength={5} /></div>
            <div><label>Protein Urine</label><input name="tes_lab_protein_urine" value={form.tes_lab_protein_urine} onChange={handleChange} className="w-full border rounded px-3 py-2" maxLength={10} /></div>
            <div><label>Gula Darah Sewaktu (mg/dL)</label><input type="number" name="tes_lab_gula_darah" value={form.tes_lab_gula_darah} onChange={handleChange} className="w-full border rounded px-3 py-2" /></div>
            <div className="md:col-span-2"><label>USG</label><textarea name="usg" value={form.usg} onChange={handleChange} className="w-full border rounded px-3 py-2" rows="2" /></div>
            <div><label>Tripel Eliminasi</label><input name="tripel_eliminasi" value={form.tripel_eliminasi} onChange={handleChange} className="w-full border rounded px-3 py-2" maxLength={10} /></div>
            <div className="md:col-span-2"><label>Tata Laksana Kasus</label><textarea name="tata_laksana_kasus" value={form.tata_laksana_kasus} onChange={handleChange} className="w-full border rounded px-3 py-2" rows="2" /></div>
          </div>
          <button type="submit" disabled={saving} className="bg-indigo-600 text-white px-4 py-2 rounded-lg flex items-center gap-2"><Save size={18} /> Simpan Pemeriksaan</button>
        </form>
      </div>
    </MainLayout>
  );
}