import React, { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import MainLayout from "../../components/Layout/MainLayout";
import AlertNotification from "../../components/AlertNotification";
import { PelayananLilaService } from "../../services/Pelayanan-lila-anak";
import { Plus, Calendar, Ruler, ChevronRight, Loader2, Trash2, Edit, FileText } from 'lucide-react';

const PelayananLilaIndex = () => {
  const { id: anakId } = useParams();
  const navigate = useNavigate();
  const [riwayat, setRiwayat] = useState([]);
  const [loading, setLoading] = useState(true);
  const [notification, setNotification] = useState(null);

  const fetchRiwayat = async () => {
    setLoading(true);
    try {
      const data = await PelayananLilaService.getByAnakId(anakId);
      const sorted = Array.isArray(data)
        ? data.sort((a, b) => (b.bulan_ke || 0) - (a.bulan_ke || 0))
        : [];
      setRiwayat(sorted);
    } catch (err) {
      console.error("Gagal mengambil riwayat LILA:", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (anakId) fetchRiwayat();
  }, [anakId]);

  const handleDelete = async (id) => {
    if (window.confirm("Apakah Anda yakin ingin menghapus catatan bulan ini?")) {
      try {
        await PelayananLilaService.delete(id);
        await fetchRiwayat();
        setNotification({
          type: "success",
          message: "Data pencatatan LILA anak berhasil dihapus dari sistem!"
        });
      } catch (err) {
        const errorMsg = err.response?.data?.message || err.message || "Gagal menghapus data";
        setNotification({
          type: "error",
          message: "Permintaan gagal diproses. Silakan coba lagi nanti atau hubungi bantuan.",
          code: errorMsg
        });
      }
    }
  };

  const getRisikoBadge = (kategori) => {
    const k = (kategori || '').toLowerCase();
    switch (k) {
      case "gizi_buruk":
      case "risiko":
        return { bg: "bg-red-50", text: "text-red-600", label: "Gizi Buruk / Risiko", icon: "🔴" };
      case "gizi_kurang":
        return { bg: "bg-yellow-50", text: "text-yellow-700", label: "Gizi Kurang", icon: "🟠" };
      case "baik":
        return { bg: "bg-green-50", text: "text-green-600", label: "Baik", icon: "🟢" };
      case "risiko_tinggi":
        return { bg: "bg-red-50", text: "text-red-600", label: "Risiko Tinggi", icon: "🔴" };
      case "risiko_rendah":
        return { bg: "bg-green-50", text: "text-green-600", label: "Risiko Rendah", icon: "🟢" };
      case "normal":
      default:
        return { bg: "bg-blue-50", text: "text-blue-600", label: "Normal", icon: "🟦" };
    }
  };

  return (
    <MainLayout>
      <AlertNotification 
        notification={notification} 
        onClose={() => setNotification(null)} 
        onRetry={notification?.type === "error" ? () => setNotification(null) : null}
      />
      <div className="max-w-6xl mx-auto p-6 md:p-8 bg-slate-50 min-h-screen">

        {/* HEADER */}
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-6 mb-12">
          <div>
            <h1 className="text-4xl font-black text-slate-900 tracking-tight flex items-center gap-3">
              <div className="p-3 bg-blue-600 rounded-2xl text-white shadow-lg shadow-blue-200">
                <Ruler size={28} />
              </div>
              Pencatatan LILA
            </h1>
            <p className="text-slate-400 font-bold text-[10px] uppercase tracking-[0.2em] mt-3 ml-1">
              ID Anak: {anakId} • Pantau Lingkar Lengan Atas
            </p>
          </div>

          <button
            onClick={() => navigate(`/data-anak/lila/${anakId}/create`)}
            className="group flex items-center gap-3 bg-blue-600 hover:bg-blue-700 text-white px-8 py-4 rounded-[1.5rem] font-black text-xs uppercase tracking-widest transition-all shadow-xl active:scale-95"
          >
            <Plus size={18} className="group-hover:rotate-90 transition-transform" />
            Input Data Baru
          </button>
        </div>

        {loading ? (
          <div className="flex flex-col items-center justify-center py-32">
            <Loader2 className="w-10 h-10 text-blue-600 animate-spin mb-4 opacity-20" />
            <p className="font-black text-slate-300 uppercase tracking-[0.3em] text-[10px]">Sinkronisasi Data...</p>
          </div>
        ) : riwayat.length > 0 ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {riwayat.map((item) => {
              const risiko = getRisikoBadge(item.kategori_risiko);
              return (
                <div key={item.id} className="group bg-white rounded-[2.5rem] p-7 shadow-sm border border-slate-100 hover:shadow-2xl hover:shadow-slate-200/50 transition-all">

                  {/* Header Card */}
                  <div className="flex justify-between items-start mb-8">
                    <div className="flex items-center gap-4">
                      <div className="w-16 h-16 bg-slate-50 rounded-[1.5rem] flex flex-col items-center justify-center border border-slate-100 group-hover:bg-blue-600 group-hover:border-blue-600 transition-colors">
                        <span className="text-[9px] font-black uppercase text-slate-400 group-hover:text-blue-200">Bulan</span>
                        <span className="text-2xl font-black text-slate-800 group-hover:text-white leading-none">{item.bulan_ke}</span>
                      </div>
                      <div>
                        <p className="text-[10px] font-black text-slate-300 uppercase tracking-widest mb-1 flex items-center gap-1">
                          <Calendar size={10} /> {item.tanggal ? new Date(item.tanggal).toLocaleDateString('id-ID', { day: '2-digit', month: 'short' }) : '-'}
                        </p>
                        <span className="px-3 py-1 bg-slate-100 text-slate-500 text-[9px] font-black rounded-lg uppercase">Record #{item.id}</span>
                      </div>
                    </div>

                    <div className="flex gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                      <button
                        onClick={() => navigate(`/data-anak/lila/${anakId}/edit/${item.id}`)}
                        className="p-2.5 bg-blue-50 text-blue-600 rounded-xl hover:bg-blue-600 hover:text-white transition-all"
                      >
                        <Edit size={16} />
                      </button>
                      <button
                        onClick={() => handleDelete(item.id)}
                        className="p-2.5 bg-red-50 text-red-600 rounded-xl hover:bg-red-600 hover:text-white transition-all"
                      >
                        <Trash2 size={16} />
                      </button>
                    </div>
                  </div>

                  {/* Status */}
                  <div className="space-y-3 mb-8">
                    <div className="flex items-center justify-between p-3 bg-slate-50 rounded-2xl">
                      <span className="text-[10px] font-black text-slate-400 uppercase">Hasil LILA</span>
                      <span className="text-sm font-black text-slate-700">{item.hasil_lila} cm</span>
                    </div>
                    <div className={`flex items-center justify-between p-3 ${risiko.bg} rounded-2xl`}>
                      <span className="text-[10px] font-black text-slate-400 uppercase">Status Gizi</span>
                      <span className={`text-[10px] font-black uppercase ${risiko.text}`}>
                        {risiko.icon} {risiko.label}
                      </span>
                    </div>
                  </div>

                  {/* Footer */}
                  <button
                    onClick={() => navigate(`/data-anak/lila/${anakId}/edit/${item.id}`)}
                    className="w-full py-4 bg-slate-50 group-hover:bg-blue-50 rounded-2xl text-slate-400 group-hover:text-blue-600 font-black text-[10px] uppercase tracking-[0.2em] transition-all flex items-center justify-center gap-2"
                  >
                    Edit Data <ChevronRight size={14} />
                  </button>
                </div>
              );
            })}
          </div>
        ) : (
          /* EMPTY STATE */
          <div className="bg-white rounded-[3rem] p-20 border-4 border-dashed border-slate-100 flex flex-col items-center justify-center text-center">
            <div className="w-24 h-24 bg-slate-50 rounded-full flex items-center justify-center text-slate-200 mb-8 border border-slate-50">
              <FileText size={40} />
            </div>
            <h3 className="text-2xl font-black text-slate-800 mb-3 tracking-tight">Data Masih Kosong</h3>
            <p className="text-slate-400 max-w-sm mb-10 text-sm font-medium leading-relaxed">
              Anak ini belum memiliki riwayat pencatatan LILA. Mulai catat lingkar lengan atas anak sekarang.
            </p>
            <button
              onClick={() => navigate(`/data-anak/lila/${anakId}/create`)}
              className="px-12 py-5 bg-blue-600 text-white rounded-[2rem] font-black text-xs uppercase tracking-widest hover:scale-105 shadow-2xl shadow-blue-200 transition-all"
            >
              <Plus className="inline mr-2" size={18} /> Input Data Pertama
            </button>
          </div>
        )}
      </div>
    </MainLayout>
  );
};

export default PelayananLilaIndex;