import React, { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import Swal from "sweetalert2";
import MainLayout from "../../components/Layout/MainLayout";
import { getKehamilanByIbuId } from "../../services/kehamilan";
import {
  getDokterT1CompleteByKehamilanId,
  createDokterT1Complete,
  updateDokterT1Complete,
} from "../../services/pemeriksaanDokter";
import { Save, ArrowLeft, Loader2, AlertCircle } from "lucide-react";

export default function PemeriksaanDokterT1Form() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [kehamilan, setKehamilan] = useState(null);
  const [existingData, setExistingData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState(null);
  const isEdit = window.location.pathname.includes("/edit");

  const initialState = { /* sama seperti sebelumnya, tetapi saya tulis ulang singkat */ };
  const [form, setForm] = useState(initialState);

  useEffect(() => {
    const fetch = async () => {
      try {
        const kehamilanList = await getKehamilanByIbuId(id);
        if (!kehamilanList.length) {
          setError("Data kehamilan tidak ditemukan.");
          setLoading(false);
          return;
        }
        const aktif = kehamilanList[0];
        setKehamilan(aktif);
        setForm(prev => ({ ...prev, kehamilan_id: aktif.id }));
        const res = await getDokterT1CompleteByKehamilanId(aktif.id);
        if (res && res.dokter) {
          setExistingData(res.dokter);
          // map data ke form (sama seperti sebelumnya)
        }
      } catch (err) {
        console.error(err);
        setError("Gagal memuat data.");
      } finally {
        setLoading(false);
      }
    };
    fetch();
  }, [id]);

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setForm(prev => ({ ...prev, [name]: type === "checkbox" ? checked : value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!kehamilan) return;
    setSaving(true);
    try {
      const payload = { ...form, kehamilan_id: kehamilan.id };
      // parsing angka
      // ... (sama seperti sebelumnya)
      if (isEdit && existingData) {
        await updateDokterT1Complete(existingData.id, payload);
        await Swal.fire('Berhasil', 'Data berhasil diperbarui!', 'success');
      } else {
        await createDokterT1Complete(payload);
        await Swal.fire('Berhasil', 'Data berhasil disimpan!', 'success');
      }
      // Redirect ke halaman detail
      navigate(`/data-ibu/${id}/pemeriksaan-dokter-t1-complete`);
    } catch (err) {
      console.error(err);
      Swal.fire('Error', 'Gagal menyimpan: ' + (err.response?.data?.message || err.message), 'error');
    } finally {
      setSaving(false);
    }
  };

  if (loading) return <MainLayout><div className="p-6">Memuat...</div></MainLayout>;
  if (error) return <MainLayout><div className="p-6 text-red-500">{error}</div></MainLayout>;

  return (
    <MainLayout>
      <div className="p-6 max-w-5xl mx-auto">
        <div className="flex items-center gap-4 mb-6">
          <button onClick={() => navigate(-1)} className="p-2 rounded-full hover:bg-gray-100">
            <ArrowLeft size={20} />
          </button>
          <div>
            <h1 className="text-2xl font-bold">{isEdit ? "Edit" : "Tambah"} Pemeriksaan Dokter Trimester 1 & Lab Jiwa</h1>
          </div>
        </div>
        <form onSubmit={handleSubmit} className="space-y-8">
          {/* Semua input field seperti sebelumnya, tapi saya ringkas */} 
          <button type="submit" disabled={saving} className="bg-indigo-600 text-white px-8 py-3 rounded-lg flex items-center gap-2">
            <Save size={18} /> {saving ? "Menyimpan..." : "Simpan"}
          </button>
        </form>
      </div>
    </MainLayout>
  );
}