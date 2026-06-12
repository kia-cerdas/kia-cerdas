import React, { useState, useMemo, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import MainLayout from "../../components/Layout/MainLayout";
import AlertNotification from "../../components/AlertNotification";
import { PelayananLilaService } from "../../services/Pelayanan-lila-anak";
import { Save, AlertCircle, Loader2, CheckCircle2 } from 'lucide-react';

const PelayananLilaEdit = () => {
  const { id, lilaId } = useParams();
  const navigate = useNavigate();

  const [submitting, setSubmitting] = useState(false);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState(false);
  const [notification, setNotification] = useState(null);

  const authUser = useMemo(() => {
    try {
      const storedUser = localStorage.getItem('user');
      return storedUser ? JSON.parse(storedUser) : { id: 0, nama: 'Unknown' };
    } catch {
      return { id: 0, nama: 'Guest' };
    }
  }, []);

  const [formData, setFormData] = useState({
    bulan_ke: 1,
    tanggal: new Date().toISOString().split('T')[0],
    hasil_lila: "",
    kategori_risiko: "normal"
  });

  useEffect(() => {
    const fetchData = async () => {
      try {
        const data = await PelayananLilaService.getById(lilaId);
        if (data) {
          setFormData({
            bulan_ke: data.bulan_ke || data.bulan || 1,
            tanggal: data.tanggal ? new Date(data.tanggal).toISOString().split('T')[0] : new Date().toISOString().split('T')[0],
            hasil_lila: data.hasil_lila || "",
            kategori_risiko: data.kategori_risiko || "normal"
          });
        }
      } catch (err) {
        setError("Gagal mengambil data LILA");
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, [lilaId]);

  const hitungKategori = (bulan, lila) => {
    const b = parseInt(bulan) || 0;
    const v = parseFloat(lila) || 0;
    if (!v) return "normal";
    if (b < 6) {
      return v < 10.0 ? "gizi_buruk" : v >= 11.0 ? "baik" : "gizi_buruk";
    } else {
      if (v < 11.5) return "gizi_buruk";
      if (v < 12.5) return "gizi_kurang";
      return "baik";
    }
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    const updated = {
      ...formData,
      [name]: name === 'bulan_ke' ? parseInt(value) || 1 : value
    };
    if (name === 'bulan_ke' && formData.hasil_lila) {
      updated.kategori_risiko = hitungKategori(value, formData.hasil_lila);
    }
    setFormData(updated);
  };

  const handleLilaChange = (e) => {
    const value = e.target.value;
    const kategori = hitungKategori(formData.bulan_ke, value);
    setFormData(prev => ({
      ...prev,
      hasil_lila: value,
      kategori_risiko: kategori
    }));
  };

  const handleSubmit = async () => {
    if (!formData.hasil_lila) {
      setNotification({
        type: "error",
        message: "Hasil LILA harus diisi!"
      });
      return;
    }
    if (formData.bulan_ke <= 0 || formData.bulan_ke > 60) {
      setNotification({
        type: "error",
        message: "Bulan harus antara 1-60!"
      });
      return;
    }

    const payload = {
      id: parseInt(lilaId),
      anak_id: parseInt(id) || 0,
      tanggal: formData.tanggal ? new Date(formData.tanggal).toISOString() : new Date().toISOString(),
      bulan_ke: formData.bulan_ke,
      hasil_lila: parseFloat(formData.hasil_lila) || 0,
      kategori_risiko: formData.kategori_risiko || "normal",
      tenaga_kesehatan_id: parseInt(authUser.id || authUser.user_id) || 0
    };

    setSubmitting(true);
    try {
      await PelayananLilaService.update(lilaId, payload);
      setNotification({
        type: "success",
        message: "Data pencatatan LILA anak berhasil diperbarui ke dalam sistem!"
      });
    } catch (err) {
      console.error("Gagal update:", err);
      const errMsg = err.response?.data?.error || err.response?.data?.message || err.message;
      setNotification({
        type: "error",
        message: "Permintaan gagal diproses. Silakan coba lagi nanti atau hubungi bantuan.",
        code: errMsg
      });
    } finally {
      setSubmitting(false);
    }
  };

  const handleAlertClose = () => {
    if (notification && notification.type === "success") {
      navigate(`/data-anak/lila/${id}`);
    }
    setNotification(null);
  };

  const getRisikoBadge = (kategori) => {
    switch (kategori?.toLowerCase()) {
      case "gizi_buruk": return { bg: "bg-red-50", text: "text-red-700", label: "Gizi Buruk", icon: "🔴" };
      case "gizi_kurang": return { bg: "bg-yellow-50", text: "text-yellow-700", label: "Gizi Kurang", icon: "🟠" };
      case "baik": return { bg: "bg-green-50", text: "text-green-700", label: "Baik", icon: "🟢" };
      default: return { bg: "bg-blue-50", text: "text-blue-700", label: "Normal", icon: "🟦" };
    }
  };

  const risiko = getRisikoBadge(formData.kategori_risiko);

  if (loading) {
    return (
      <MainLayout>
        <div className="flex flex-col items-center justify-center py-32">
          <Loader2 className="w-10 h-10 text-blue-600 animate-spin mb-4" />
          <p className="text-slate-500 font-semibold">Memuat data...</p>
        </div>
      </MainLayout>
    );
  }

  return (
    <MainLayout>
      <AlertNotification 
        notification={notification} 
        onClose={handleAlertClose} 
        onRetry={notification?.type === "error" ? () => setNotification(null) : null}
      />
      <div className="max-w-6xl mx-auto p-4 md:p-8 bg-slate-50 min-h-screen pb-24 font-sans">

        {/* Header */}
        <header className="mb-10 border-b border-slate-200 pb-8">
          <nav className="flex items-center gap-2 text-[10px] font-black tracking-widest text-slate-400 uppercase mb-3">
            <span>Data Anak</span>
            <span className="w-1 h-1 rounded-full bg-slate-300"></span>
            <span className="text-blue-600 font-black">Edit Pencatatan LILA</span>
          </nav>
          <h1 className="text-4xl font-black text-slate-900 tracking-tight">Edit Pencatatan LILA</h1>
          <p className="text-[10px] text-slate-400 font-bold mt-2 uppercase tracking-widest">
            Petugas: {authUser.nama} • ID Anak: {id}
          </p>
        </header>

        {/* Error */}
        {error && (
          <div className="mb-6 p-4 bg-red-100 border border-red-300 rounded-2xl flex items-start gap-3">
            <AlertCircle className="text-red-600 flex-shrink-0 mt-0.5" size={20} />
            <p className="font-bold text-red-800">{error}</p>
          </div>
        )}

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 mb-8">
          {/* Form */}
          <div className="lg:col-span-2">
            <div className="space-y-6 bg-white rounded-[3rem] p-8 shadow-sm border border-slate-100">
              <div>
                <label className="block text-sm font-black text-slate-700 mb-3 uppercase tracking-wider">
                  Bulan Ke <span className="text-red-600">*</span>
                </label>
                <input
                  type="number"
                  name="bulan_ke"
                  value={formData.bulan_ke}
                  onChange={handleInputChange}
                  min="1"
                  max="60"
                  className="w-full px-5 py-4 border-2 border-slate-200 rounded-2xl focus:outline-none focus:border-blue-600 focus:ring-2 focus:ring-blue-100 font-semibold"
                  placeholder="Contoh: 6"
                />
                <p className="text-xs text-slate-500 mt-2">Usia anak dalam bulan (1-60)</p>
              </div>

              <div>
                <label className="block text-sm font-black text-slate-700 mb-3 uppercase tracking-wider">
                  Tanggal Pengukuran <span className="text-red-600">*</span>
                </label>
                <input
                  type="date"
                  name="tanggal"
                  value={formData.tanggal}
                  onChange={handleInputChange}
                  className="w-full px-5 py-4 border-2 border-slate-200 rounded-2xl focus:outline-none focus:border-blue-600 focus:ring-2 focus:ring-blue-100 font-semibold"
                />
              </div>

              <div>
                <label className="block text-sm font-black text-slate-700 mb-3 uppercase tracking-wider">
                  Hasil LILA (cm) <span className="text-red-600">*</span>
                </label>
                <input
                  type="number"
                  step="0.1"
                  value={formData.hasil_lila}
                  onChange={handleLilaChange}
                  className="w-full px-5 py-4 border-2 border-slate-200 rounded-2xl focus:outline-none focus:border-blue-600 focus:ring-2 focus:ring-blue-100 text-lg font-black"
                  placeholder="Contoh: 13.5"
                />
                <p className="text-xs text-slate-500 mt-2">Ukuran lingkar lengan atas dalam sentimeter</p>
              </div>

              <div>
                <label className="block text-sm font-black text-slate-700 mb-3 uppercase tracking-wider">
                  Kategori Risiko
                </label>
                <select
                  name="kategori_risiko"
                  value={formData.kategori_risiko}
                  onChange={handleInputChange}
                  className="w-full px-5 py-4 border-2 border-slate-200 rounded-2xl focus:outline-none focus:border-blue-600 focus:ring-2 focus:ring-blue-100 font-semibold"
                >
                  <option value="gizi_buruk">🔴 Gizi Buruk</option>
                  <option value="gizi_kurang">🟠 Gizi Kurang</option>
                  <option value="baik">🟢 Baik</option>
                  <option value="normal">🟦 Normal</option>
                </select>
                <p className="text-xs text-slate-500 mt-2">Otomatis terisi berdasarkan hasil LILA</p>
              </div>
            </div>
          </div>

          {/* Preview */}
          <div className="space-y-6">
            {formData.hasil_lila && (
              <div className="bg-gradient-to-br from-blue-600 to-blue-700 rounded-[2.5rem] p-8 shadow-2xl shadow-blue-200 text-white">
                <p className="text-[10px] font-black uppercase tracking-widest mb-3 text-blue-200">Hasil Pengukuran</p>
                <p className="text-5xl font-black mb-2">{formData.hasil_lila}</p>
                <p className="text-sm font-semibold mb-6 text-blue-100">Lingkar Lengan Atas (cm)</p>
                <div className={`${risiko.bg} rounded-2xl p-4 text-center`}>
                  <p className="text-[9px] font-black text-slate-600 uppercase mb-1">Status Gizi</p>
                  <p className={`text-lg font-black ${risiko.text}`}>{risiko.icon}</p>
                  <p className={`text-sm font-bold ${risiko.text}`}>{risiko.label}</p>
                </div>
              </div>
            )}

            <div className="bg-white rounded-[2.5rem] p-6 shadow-sm border border-slate-100">
              <p className="text-xs font-black text-slate-600 uppercase mb-4 tracking-wider">Referensi LILA</p>
              <div className="space-y-3">
                <div className="p-3 bg-red-50 rounded-xl border-l-4 border-red-600">
                  <p className="text-[10px] font-black text-red-600 uppercase">&lt;6 bln: &lt;10cm / ≥6bln: &lt;11.5cm</p>
                  <p className="text-xs text-red-700 font-semibold mt-1">Gizi Buruk</p>
                </div>
                <div className="p-3 bg-yellow-50 rounded-xl border-l-4 border-yellow-600">
                  <p className="text-[10px] font-black text-yellow-700 uppercase">≥6 bln: 11.5 – 12.4 cm</p>
                  <p className="text-xs text-yellow-800 font-semibold mt-1">Gizi Kurang</p>
                </div>
                <div className="p-3 bg-green-50 rounded-xl border-l-4 border-green-600">
                  <p className="text-[10px] font-black text-green-600 uppercase">&lt;6bln: ≥11cm / ≥6bln: ≥12.5cm</p>
                  <p className="text-xs text-green-700 font-semibold mt-1">Baik</p>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Buttons */}
        <div className="flex gap-3 sticky bottom-0 bg-slate-50 p-4 rounded-2xl border border-slate-200 shadow-lg">
          <button
            onClick={() => navigate(`/data-anak/lila/${id}`)}
            className="flex-1 px-6 py-4 border-2 border-slate-300 text-slate-700 font-black rounded-2xl hover:bg-slate-100 transition-all uppercase text-sm tracking-wider"
          >
            Batal
          </button>
          <button
            onClick={handleSubmit}
            disabled={submitting}
            className="flex-1 flex items-center justify-center gap-2 bg-blue-600 hover:bg-blue-700 disabled:bg-gray-400 text-white font-black py-4 rounded-2xl transition-all shadow-lg uppercase text-sm tracking-wider"
          >
            {submitting ? (
              <><Loader2 size={18} className="animate-spin" /> Menyimpan...</>
            ) : (
              <><Save size={18} /> Simpan Perubahan</>
            )}
          </button>
        </div>
      </div>
    </MainLayout>
  );
};

export default PelayananLilaEdit;