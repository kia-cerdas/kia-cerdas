// src/pages/Ibu/SkriningDMGestasional.jsx
import React, { useEffect, useState } from "react";
import { useParams, useNavigate, useSearchParams } from "react-router-dom";
import Swal from "sweetalert2";
import MainLayout from "../../components/Layout/MainLayout";
import { getKehamilanByIbuId } from "../../services/kehamilan";
import { getSkriningDMByKehamilanId, createSkriningDM, updateSkriningDM } from "../../services/rujukanService";
import { getCurrentUser, isDokterUser, isBidanUser } from "../../services/auth";
import { Save, ArrowLeft, Loader2, Eye, EyeOff, Plus, Edit2 } from "lucide-react";

export default function SkriningDMGestasional() {
  const { id: ibuId } = useParams();
  const [searchParams] = useSearchParams();
  const kehamilanId = searchParams.get("kehamilan_id");
  const navigate = useNavigate();

  const user = getCurrentUser();
  // Skrining DM Gestasional: dokter mengelola, bidan hanya melihat
  const isDokter = isDokterUser(user);
  const isBidan  = isBidanUser(user);

  const [kehamilan, setKehamilan] = useState(null);
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [isEditing, setIsEditing] = useState(false);
  const [isActive, setIsActive] = useState(true);

  const canEdit = isDokter && isActive;

  const [form, setForm] = useState({
    gula_darah_puasa_hasil: "",
    gula_darah_puasa_rencana_tindak_lanjut: "",
    gula_darah_2_jam_post_prandial_hasil: "",
    gula_darah_2_jam_post_prandial_rencana_tindak_lanjut: "",
  });

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        const kehamilanList = await getKehamilanByIbuId(ibuId);
        if (!kehamilanList.length) {
        Swal.fire({
          icon: 'info',
          title: 'Informasi',
          text: 'Ibu belum memiliki data kehamilan.',
          confirmButtonColor: '#4f46e5'
        });
          navigate(`/data-ibu/${ibuId}`);
          return;
        }

        let targetKehamilan = null;
        if (kehamilanId) {
          targetKehamilan = kehamilanList.find(k => k.id == kehamilanId);
          if (!targetKehamilan) {
          Swal.fire({
            icon: 'error',
            title: 'Tidak Ditemukan',
            text: `Kehamilan dengan ID ${kehamilanId} tidak ditemukan.`
          });
            navigate(`/data-ibu/${ibuId}`);
            return;
          }
        } else {
          targetKehamilan = kehamilanList[0];
        }
        setKehamilan(targetKehamilan);
        setIsActive(targetKehamilan.status_kehamilan !== "NON-AKTIF");

        const result = await getSkriningDMByKehamilanId(targetKehamilan.id);
        if (result && result.length > 0) {
          const d = result[0];
          setData(d);
          setForm({
            gula_darah_puasa_hasil: d.gula_darah_puasa_hasil?.toString() || "",
            gula_darah_puasa_rencana_tindak_lanjut: d.gula_darah_puasa_rencana_tindak_lanjut || "",
            gula_darah_2_jam_post_prandial_hasil: d.gula_darah_2_jam_post_prandial_hasil?.toString() || "",
            gula_darah_2_jam_post_prandial_rencana_tindak_lanjut: d.gula_darah_2_jam_post_prandial_rencana_tindak_lanjut || "",
          });
        }
      } catch (err) {
        console.error(err);
      Swal.fire('Error', 'Gagal memuat data skrining DM.', 'error');
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, [ibuId, kehamilanId, navigate]);

  const handleChange = (e) => {
    if (!canEdit) return;
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!canEdit) {
      Swal.fire({
        icon: 'error',
        title: 'Akses Ditolak',
        text: 'Anda tidak memiliki izin untuk mengubah data.'
      });
      return;
    }
    if (!kehamilan) {
      Swal.fire({
        icon: 'error',
        title: 'Error',
        text: 'Data kehamilan tidak ditemukan.'
      });
      return;
    }
    setSaving(true);
    try {
      const payload = {
        kehamilan_id: kehamilan.id,
        gula_darah_puasa_hasil: form.gula_darah_puasa_hasil ? parseFloat(form.gula_darah_puasa_hasil) : null,
        gula_darah_puasa_rencana_tindak_lanjut: form.gula_darah_puasa_rencana_tindak_lanjut,
        gula_darah_2_jam_post_prandial_hasil: form.gula_darah_2_jam_post_prandial_hasil ? parseFloat(form.gula_darah_2_jam_post_prandial_hasil) : null,
        gula_darah_2_jam_post_prandial_rencana_tindak_lanjut: form.gula_darah_2_jam_post_prandial_rencana_tindak_lanjut,
      };

      if (data) {
        await updateSkriningDM(data.id_skrining_dm, payload);
      } else {
        await createSkriningDM(payload);
        // setelah create, ambil ulang data agar bisa ditampilkan
        const refreshed = await getSkriningDMByKehamilanId(kehamilan.id);
        if (refreshed && refreshed.length > 0) setData(refreshed[0]);
      }
      await Swal.fire({
        icon: 'success',
        title: 'Berhasil',
        text: 'Skrining DM Gestasional berhasil disimpan.',
        timer: 2000,
        showConfirmButton: false
      });
      setIsEditing(false);
      // Refresh data
      const refreshed = await getSkriningDMByKehamilanId(kehamilan.id);
      if (refreshed && refreshed.length > 0) setData(refreshed[0]);
    } catch (err) {
      console.error(err);
      Swal.fire('Error', 'Gagal menyimpan data skrining DM. Silakan coba lagi.', 'error');
    } finally {
      setSaving(false);
    }
  };

  // Tampilan hasil (view)
  const ResultView = () => {
    if (!data) {
      return (
        <div className="bg-white rounded-xl shadow-sm p-8 text-center">
          <div className="flex flex-col items-center gap-4">
            <div className="p-4 bg-[#185FA5]/10 rounded-full">
              <Save size={48} className="text-[#185FA5]" />
            </div>
            <h3 className="text-[22px] font-semibold text-gray-800">Belum Ada Data Skrining DM Gestasional</h3>
            <p className="text-gray-500 text-base max-w-md">
              Silakan lakukan skrining diabetes melitus gestasional (DMG) untuk ibu hamil ini.
            </p>
            {canEdit && (
              <button
                onClick={() => setIsEditing(true)}
                className="bg-[#185FA5] text-white rounded-lg px-5 py-2.5 font-semibold flex items-center gap-2 text-base"
              >
                <Plus size={18} /> Mulai Skrining
              </button>
            )}
            {!canEdit && !isActive && (
              <p className="text-gray-400 text-sm mt-2">Kehamilan sudah selesai (NON-AKTIF), tidak dapat menambahkan data baru.</p>
            )}
          </div>
        </div>
      );
    }

    // Fungsi untuk menentukan status risiko berdasarkan hasil
    const getStatusGDP = (nilai) => {
      if (!nilai) return null;
      const val = parseFloat(nilai);
      if (val < 92) return { text: "Normal", color: "#3B6D11", bg: "#E1F5EE" };
      if (val >= 92 && val < 126) return { text: "Gangguan Glukosa Puasa (Perlu Pantau)", color: "#BA7517", bg: "#FAEEDA" };
      return { text: "Diabetes (Rujuk)", color: "#A32D2D", bg: "#FCEBEB" };
    };

    const getStatus2Jam = (nilai) => {
      if (!nilai) return null;
      const val = parseFloat(nilai);
      if (val < 153) return { text: "Normal", color: "#3B6D11", bg: "#E1F5EE" };
      if (val >= 153 && val < 200) return { text: "Gangguan Toleransi Glukosa (Perlu Pantau)", color: "#BA7517", bg: "#FAEEDA" };
      return { text: "Diabetes Gestasional (Rujuk)", color: "#A32D2D", bg: "#FCEBEB" };
    };

    const statusGDP = getStatusGDP(form.gula_darah_puasa_hasil);
    const status2Jam = getStatus2Jam(form.gula_darah_2_jam_post_prandial_hasil);

    return (
      <div className="space-y-6">
        <div className="bg-white rounded-xl shadow-sm p-5">
          <h3 className="text-[22px] font-semibold text-[#185FA5] border-b pb-2 mb-4">Hasil Skrining DM Gestasional</h3>
          <div className="space-y-5">
            {/* GDP */}
            <div>
              <div className="flex flex-wrap justify-between items-start gap-2">
                <div>
                  <h4 className="font-semibold text-base">Gula Darah Puasa (GDP)</h4>
                  <p className="text-gray-500 text-sm">Normal: &lt; 92 mg/dL</p>
                </div>
                {statusGDP && (
                  <span className="px-3 py-1 rounded-full text-sm font-semibold" style={{ backgroundColor: statusGDP.bg, color: statusGDP.color }}>
                    {statusGDP.text}
                  </span>
                )}
              </div>
              <div className="mt-2 grid grid-cols-1 md:grid-cols-2 gap-3 text-base">
                <div><span className="font-semibold">Hasil:</span> {form.gula_darah_puasa_hasil ? `${form.gula_darah_puasa_hasil} mg/dL` : "-"}</div>
                <div><span className="font-semibold">Rencana Tindak Lanjut:</span> {form.gula_darah_puasa_rencana_tindak_lanjut || "-"}</div>
              </div>
            </div>
            {/* 2 jam post prandial */}
            <div className="border-t pt-4">
              <div className="flex flex-wrap justify-between items-start gap-2">
                <div>
                  <h4 className="font-semibold text-base">Gula Darah 2 jam Post Prandial (TTGO 75g)</h4>
                  <p className="text-gray-500 text-sm">Normal: &lt; 153 mg/dL</p>
                </div>
                {status2Jam && (
                  <span className="px-3 py-1 rounded-full text-sm font-semibold" style={{ backgroundColor: status2Jam.bg, color: status2Jam.color }}>
                    {status2Jam.text}
                  </span>
                )}
              </div>
              <div className="mt-2 grid grid-cols-1 md:grid-cols-2 gap-3 text-base">
                <div><span className="font-semibold">Hasil:</span> {form.gula_darah_2_jam_post_prandial_hasil ? `${form.gula_darah_2_jam_post_prandial_hasil} mg/dL` : "-"}</div>
                <div><span className="font-semibold">Rencana Tindak Lanjut:</span> {form.gula_darah_2_jam_post_prandial_rencana_tindak_lanjut || "-"}</div>
              </div>
            </div>
          </div>
        </div>

        <div className="flex gap-3 justify-end">
          {canEdit && (
            <button onClick={() => setIsEditing(true)} className="bg-[#185FA5] text-white rounded-lg px-5 py-2.5 font-semibold flex items-center gap-2 text-base">
              <Edit2 size={18} /> Edit Skrining
            </button>
          )}
          <button
            onClick={() => navigate(`/data-ibu/${ibuId}?kehamilan_id=${kehamilan.id}`)}
            className="border border-[#185FA5] text-[#185FA5] rounded-lg px-5 py-2.5 font-semibold flex items-center gap-2 text-base"
          >
            Kembali ke Detail Ibu
          </button>
        </div>
      </div>
    );
  };

  // Form view (edit / input)
  const FormView = () => (
    <form onSubmit={handleSubmit} className="space-y-6">
      <div className="bg-white rounded-xl shadow-sm p-5">
        <div className="bg-[#185FA5]/10 p-4 rounded-lg mb-6">
          <h2 className="text-base font-semibold text-[#185FA5] mb-1">Test Toleransi Glukosa Oral (TTGO)</h2>
          <p className="text-sm text-gray-700">
            Pemeriksaan untuk mendeteksi Diabetes Melitus Gestasional (DMG). Dilakukan umumnya pada usia kehamilan 24-28 minggu atau jika ada faktor risiko seperti riwayat keluarga DM, obesitas, riwayat melahirkan bayi besar (&gt;4000 gram), atau riwayat abortus berulang.
          </p>
        </div>

        <div className="space-y-6">
          {/* Gula Darah Puasa */}
          <div>
            <h3 className="font-semibold text-base text-gray-800 mb-3">1. Gula Darah Puasa (GDP)</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-base font-medium mb-1">Hasil (mg/dL)</label>
                <input 
                  type="number" 
                  step="0.1" 
                  name="gula_darah_puasa_hasil" 
                  value={form.gula_darah_puasa_hasil} 
                  onChange={handleChange} 
                  disabled={!canEdit}
                  className="w-full border border-gray-300 rounded-lg px-3 py-2 text-base focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5] disabled:bg-gray-100"
                  placeholder="Contoh: 90" 
                />
                <p className="text-sm text-gray-500 mt-1">Nilai normal: &lt; 92 mg/dL</p>
              </div>
              <div>
                <label className="block text-base font-medium mb-1">Rencana Tindak Lanjut</label>
                <input 
                  name="gula_darah_puasa_rencana_tindak_lanjut" 
                  value={form.gula_darah_puasa_rencana_tindak_lanjut} 
                  onChange={handleChange} 
                  disabled={!canEdit}
                  className="w-full border border-gray-300 rounded-lg px-3 py-2 text-base focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5] disabled:bg-gray-100"
                  placeholder="Contoh: Konseling gizi, ulang pemeriksaan" 
                />
              </div>
            </div>
          </div>

          {/* Gula Darah 2 jam post prandial */}
          <div className="border-t pt-4">
            <h3 className="font-semibold text-base text-gray-800 mb-3">2. Gula Darah 2 jam Post Prandial (TTGO 75g)</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-base font-medium mb-1">Hasil (mg/dL)</label>
                <input 
                  type="number" 
                  step="0.1" 
                  name="gula_darah_2_jam_post_prandial_hasil" 
                  value={form.gula_darah_2_jam_post_prandial_hasil} 
                  onChange={handleChange} 
                  disabled={!canEdit}
                  className="w-full border border-gray-300 rounded-lg px-3 py-2 text-base focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5] disabled:bg-gray-100"
                  placeholder="Contoh: 140" 
                />
                <p className="text-sm text-gray-500 mt-1">Nilai normal: &lt; 153 mg/dL</p>
              </div>
              <div>
                <label className="block text-base font-medium mb-1">Rencana Tindak Lanjut</label>
                <input 
                  name="gula_darah_2_jam_post_prandial_rencana_tindak_lanjut" 
                  value={form.gula_darah_2_jam_post_prandial_rencana_tindak_lanjut} 
                  onChange={handleChange} 
                  disabled={!canEdit}
                  className="w-full border border-gray-300 rounded-lg px-3 py-2 text-base focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5] disabled:bg-gray-100"
                  placeholder="Contoh: Rujuk ke endokrin, terapi insulin" 
                />
              </div>
            </div>
          </div>
        </div>

        {canEdit && (
          <div className="flex gap-4 justify-end mt-8 pt-4 border-t">
            <button type="button" onClick={() => setIsEditing(false)} className="px-5 py-2.5 border border-[#185FA5] text-[#185FA5] rounded-lg font-semibold text-base">
              Batal
            </button>
            <button 
              type="submit" 
              disabled={saving} 
              className="bg-[#185FA5] text-white px-6 py-2.5 rounded-lg flex items-center gap-2 text-base font-semibold hover:bg-[#185FA5]/90"
            >
              {saving ? <Loader2 className="animate-spin" size={18} /> : <Save size={18} />}
              {saving ? "Menyimpan..." : "Simpan Skrining DM"}
            </button>
          </div>
        )}
      </div>
    </form>
  );

  if (loading) return <MainLayout><div className="p-6 text-base">Memuat data...</div></MainLayout>;
  if (!kehamilan) return <MainLayout><div className="p-6 text-[#A32D2D] text-base">Error: Kehamilan tidak ditemukan</div></MainLayout>;

  return (
    <MainLayout>
      <div className="min-h-screen bg-[#F7FAFB]">
        <div className="max-w-5xl mx-auto p-5 space-y-5">
          {/* Header */}
          <div className="flex items-center gap-3">
            <button onClick={() => navigate(-1)} className="p-2 rounded-lg hover:bg-gray-200 transition">
              <ArrowLeft size={20} className="text-[#185FA5]" />
            </button>
            <h1 className="text-[28px] font-bold text-gray-900">Skrining DM Gestasional</h1>
          </div>

          {!isActive && (
            <div className="bg-blue-50 border border-blue-200 p-3 rounded-lg text-blue-700 text-base flex items-center gap-2">
              <EyeOff size={16} /> Kehamilan ini sudah selesai (NON-AKTIF). Data hanya dapat dilihat, tidak dapat diubah.
            </div>
          )}
          {!canEdit && isActive && (
            <div className="bg-blue-50 border border-blue-200 p-3 rounded-lg text-blue-700 text-base flex items-center gap-2">
              <Eye size={16} /> Anda dalam mode baca (Bidan). Data hanya dapat dilihat, tidak dapat diubah.
            </div>
          )}

          {isEditing ? <FormView /> : <ResultView />}
        </div>
      </div>
    </MainLayout>
  );
}