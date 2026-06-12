import React, { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import { Plus, X, Save, ShieldAlert, Smile, Loader2, Info, Calendar, Activity } from 'lucide-react';
import MainLayout from "../../components/Layout/MainLayout";
import AlertNotification from "../../components/AlertNotification";
import { dentalService } from '../../services/dentalService';

const PelayananGigi = () => {
  const { id } = useParams();
  const [records, setRecords] = useState([]);
  const [loading, setLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [notification, setNotification] = useState(null);

  // 1. Pastikan key di sini SAMA dengan yang digunakan di input
  const [formData, setFormData] = useState({
    bulan_ke: "",
    tanggal: new Date().toISOString().split('T')[0],
    jumlah_gigi: 0,
    gigi_berlubang: 0,
    status_plak: "Bersih",
    resiko_gigi_berlubang: "Rendah"
  });

  const fetchData = async () => {
    setLoading(true);
    try {
      const data = await dentalService.getByAnak(id);
      setRecords(data);
    } catch (error) {
      console.error("Fetch error:", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (id) fetchData();
  }, [id]);

  const handleOpenModal = () => {
    setFormData({
      bulan_ke: "",
      tanggal: new Date().toISOString().split('T')[0],
      jumlah_gigi: 0,
      gigi_berlubang: 0,
      status_plak: "Bersih",
      resiko_gigi_berlubang: "Rendah"
    });
    setIsModalOpen(true);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (Number(formData.gigi_berlubang) > Number(formData.jumlah_gigi)) {
      setNotification({
        type: "error",
        message: "Jumlah gigi berlubang tidak boleh melebihi total gigi!"
      });
      return;
    }

    setIsSubmitting(true);

    const payload = {
      anak_id: Number(id),
      bulan_ke: Number(formData.bulan_ke),
      tanggal: new Date(formData.tanggal).toISOString(),
      jumlah_gigi: Number(formData.jumlah_gigi),
      gigi_berlubang: Number(formData.gigi_berlubang),
      status_plak: formData.status_plak,
      resiko_gigi_berlubang: formData.resiko_gigi_berlubang
    };

    try {
      await dentalService.create(payload);
      setIsModalOpen(false);
      await fetchData();
      setNotification({
        type: "success",
        message: "Data pemeriksaan gigi anak berhasil disimpan ke dalam sistem!"
      });
    } catch (err) {
      const errorMsg = err.response?.data?.message || "Gagal menyimpan data.";
      setNotification({
        type: "error",
        message: "Permintaan gagal diproses. Silakan coba lagi nanti atau hubungi bantuan.",
        code: errorMsg
      });
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <MainLayout>
      <AlertNotification 
        notification={notification} 
        onClose={() => setNotification(null)} 
        onRetry={notification?.type === "error" ? () => {
          setNotification(null);
          setIsModalOpen(true);
        } : null}
      />
      <div className="p-4 md:p-8 bg-[#f8fafc] min-h-screen relative overflow-hidden">
        {/* Dekorasi Background */}
        <div className="absolute top-0 right-0 w-[500px] h-[500px] bg-blue-400/5 rounded-full blur-[100px] -mr-64 -mt-64"></div>
        <div className="absolute bottom-0 left-0 w-[500px] h-[500px] bg-pink-400/5 rounded-full blur-[100px] -ml-64 -mb-64"></div>

        <div className="max-w-6xl mx-auto relative z-10">

          <div className="bg-white/80 backdrop-blur-xl shadow-[0_20px_50px_rgba(0,0,0,0.05)] border border-white rounded-[40px] overflow-hidden">

            <div className="p-8 md:p-10 flex flex-col md:flex-row justify-between items-start md:items-center gap-6 border-b border-blue-50">
              <div className="flex items-center gap-5">
                <div className="w-16 h-16 bg-gradient-to-br from-blue-600 to-blue-400 rounded-3xl flex items-center justify-center shadow-lg shadow-blue-200 rotate-3 hover:rotate-0 transition-transform duration-500">
                  <Smile className="text-white w-8 h-8" />
                </div>
                <div>
                  <h1 className="text-3xl font-black text-black tracking-tight flex items-center gap-3">
                    Catatan Gigi <span className="px-3 py-1 bg-slate-100 text-slate-600 text-[10px] rounded-full uppercase tracking-widest font-black border border-slate-200">Aktif</span>
                  </h1>
                  <p className="text-sm text-slate-500 font-bold mt-1">
                    Pemantauan Kesehatan Gigi & Gusi Anak • <span className="text-slate-300">ID: {id}</span>
                  </p>
                </div>
              </div>
              <button
                onClick={handleOpenModal}
                className="group bg-blue-600 hover:bg-blue-700 text-white px-8 py-4 rounded-2xl font-black text-xs uppercase shadow-xl shadow-blue-100 transition-all active:scale-95 flex items-center gap-3"
              >
                <div className="bg-white/20 p-1 rounded-lg group-hover:rotate-90 transition-transform">
                  <Plus size={18} />
                </div>
                Tambah Pemeriksaan
              </button>
            </div>

            <div className="overflow-x-auto">
              <table className="w-full border-collapse text-center table-fixed min-w-[900px]">
                <thead>
                  <tr className="bg-slate-50/50 text-[10px] font-black uppercase tracking-[0.2em] text-slate-400">
                    <th colSpan="2" className="p-5 text-left pl-10 border-b border-slate-100">Jadwal & Waktu</th>
                    <th colSpan="2" className="p-5 border-b border-slate-100">Status Gigi</th>
                    <th colSpan="2" className="p-5 border-b border-slate-100">Higiene (Plak)</th>
                    <th colSpan="3" className="p-5 border-b border-slate-100">Risiko Gigi Berlubang</th>
                  </tr>
                  <tr className="text-[11px] font-black uppercase tracking-widest text-black">
                    <th className="p-4 pl-10 text-left w-24">Bulan</th>
                    <th className="p-4 w-40 text-left">Tanggal Periksa</th>
                    <th className="p-4">Ada</th>
                    <th className="p-4 text-red-600">Berlubang</th>
                    <th className="p-4">Bersih</th>
                    <th className="p-4">Kotor</th>
                    <th className="p-4 text-pink-600">Tinggi</th>
                    <th className="p-4 text-orange-600 text-[9px]">Sedang</th>
                    <th className="p-4 text-green-600">Rendah</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-50">
                  {loading ? (
                    <tr><td colSpan="9" className="p-24 text-center">
                      <div className="flex flex-col items-center gap-4">
                        <div className="relative">
                          <div className="w-12 h-12 border-4 border-blue-100 border-t-blue-600 rounded-full animate-spin"></div>
                          <Loader2 className="absolute inset-0 m-auto text-blue-600 animate-pulse" size={20} />
                        </div>
                        <span className="font-black text-slate-300 uppercase tracking-[0.3em] text-[10px]">Sinkronisasi Data...</span>
                      </div>
                    </td></tr>
                  ) : records.length > 0 ? (
                    records.map((row, idx) => (
                      <tr key={idx} className="group hover:bg-slate-50/30 transition-all duration-300 h-20">
                        <td className="pl-10 text-left">
                          <span className="px-3 py-1.5 bg-slate-100 text-slate-400 rounded-lg text-[10px] font-black uppercase">Ke-{row.bulan}</span>
                        </td>
                        <td className="p-4 text-left font-black text-black text-sm">
                          {new Date(row.tanggal).toLocaleDateString('id-ID', { day: '2-digit', month: 'short', year: 'numeric' })}
                        </td>
                        <td className="p-4">
                          <div className="text-lg font-black text-black">{row.jumlah_gigi}</div>
                          <div className="text-[9px] text-slate-300 uppercase">Gigi Ada</div>
                        </td>
                        <td className="p-4">
                          <div className="text-lg font-black text-red-600">{row.gigi_berlubang}</div>
                          <div className="text-[9px] text-red-200 uppercase">Berlubang</div>
                        </td>
                        <td className="p-4">
                          {row.status_plak === 'Bersih' ? <div className="mx-auto w-8 h-8 bg-slate-50 text-slate-500 rounded-2xl flex items-center justify-center shadow-sm border border-slate-100">✓</div> : ''}
                        </td>
                        <td className="p-4">
                          {row.status_plak === 'Kotor' ? <div className="mx-auto w-8 h-8 bg-red-50 text-red-500 rounded-2xl flex items-center justify-center shadow-sm border border-red-100">✓</div> : ''}
                        </td>
                        <td className={`p-4 transition-colors ${row.resiko_gigi_berlubang === 'Tinggi' ? 'bg-pink-50/50' : ''}`}>
                          {row.resiko_gigi_berlubang === 'Tinggi' && <div className="w-3.5 h-3.5 bg-pink-500 rounded-full mx-auto shadow-[0_0_15px_rgba(236,72,153,0.4)] border-2 border-white"></div>}
                        </td>
                        <td className={`p-4 transition-colors ${row.resiko_gigi_berlubang === 'Sedang' ? 'bg-orange-50/50' : ''}`}>
                          {row.resiko_gigi_berlubang === 'Sedang' && <div className="w-3.5 h-3.5 bg-orange-500 rounded-full mx-auto shadow-[0_0_15px_rgba(249,115,22,0.4)] border-2 border-white"></div>}
                        </td>
                        <td className={`p-4 transition-colors ${row.resiko_gigi_berlubang === 'Rendah' ? 'bg-green-50/50' : ''}`}>
                          {row.resiko_gigi_berlubang === 'Rendah' && <div className="w-3.5 h-3.5 bg-green-500 rounded-full mx-auto shadow-[0_0_15px_rgba(34,197,94,0.4)] border-2 border-white"></div>}
                        </td>
                      </tr>
                    ))
                  ) : (
                    [...Array(6)].map((_, i) => (
                      <tr key={i} className="h-16 border-b border-slate-50 opacity-20">
                        {[...Array(9)].map((_, j) => <td key={j}></td>)}
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>

            {/* LEGEND SECTION */}
            <div className="p-10 bg-slate-50/20 border-t border-slate-100 grid grid-cols-1 md:grid-cols-3 gap-6">
              <div className="flex items-center gap-5 bg-white p-5 rounded-3xl border border-slate-100 shadow-sm transition-transform hover:scale-105 duration-300">
                <div className="w-10 h-10 bg-slate-50 border-4 border-pink-500 rounded-2xl flex items-center justify-center">
                  <div className="w-2 h-2 bg-pink-500 rounded-full"></div>
                </div>
                <div>
                  <p className="text-[11px] font-black text-black uppercase tracking-widest">Tinggi</p>
                  <p className="text-[9px] font-bold text-slate-400 mt-1 leading-tight">Ada gigi berlubang & Faktor risiko aktif.</p>
                </div>
              </div>
              <div className="flex items-center gap-5 bg-white p-5 rounded-3xl border border-slate-100 shadow-sm transition-transform hover:scale-105 duration-300">
                <div className="w-10 h-10 bg-slate-50 border-4 border-orange-500 rounded-2xl flex items-center justify-center">
                  <div className="w-2 h-2 bg-orange-500 rounded-full"></div>
                </div>
                <div>
                  <p className="text-[11px] font-black text-black uppercase tracking-widest">Sedang</p>
                  <p className="text-[9px] font-bold text-slate-400 mt-1 leading-tight">Tidak ada lubang, namun ada risiko.</p>
                </div>
              </div>
              <div className="flex items-center gap-5 bg-white p-5 rounded-3xl border border-slate-100 shadow-sm transition-transform hover:scale-105 duration-300">
                <div className="w-10 h-10 bg-slate-50 border-4 border-green-500 rounded-2xl flex items-center justify-center">
                  <div className="w-2 h-2 bg-green-500 rounded-full"></div>
                </div>
                <div>
                  <p className="text-[11px] font-black text-black uppercase tracking-widest">Rendah</p>
                  <p className="text-[9px] font-bold text-slate-400 mt-1 leading-tight">Gigi sehat & Tidak ada faktor risiko.</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      {/* MODAL FORM - COMPACT GIZI STYLE */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/30 backdrop-blur-sm p-8">
          <div className="bg-white rounded-[28px] w-full max-w-xl overflow-hidden shadow-2xl animate-in fade-in zoom-in duration-300 flex flex-col max-h-[90vh]">
            {/* Header */}
            <div className="p-6 pb-2 flex justify-between items-start">
              <div>
                <h2 className="text-xl font-bold text-black tracking-tight">Form Input Pelayanan Gigi</h2>
                <p className="text-[10px] text-slate-400 font-bold uppercase tracking-widest mt-0.5">
                  ID ANAK: {id}
                </p>
              </div>
              <button 
                onClick={() => setIsModalOpen(false)}
                className="text-slate-300 hover:text-slate-600 transition-colors p-1.5 hover:bg-slate-50 rounded-full"
              >
                <X size={20} />
              </button>
            </div>

            <div className="overflow-y-auto p-6 pt-2 space-y-4">
              {/* Info Banner - Slimmer */}
              <div className="bg-slate-50 border border-slate-100 p-3 rounded-xl flex gap-3 items-center">
                <div className="w-8 h-8 bg-white rounded-full flex items-center justify-center text-black shadow-sm border border-slate-100 shrink-0">
                  <Info size={16} />
                </div>
                <p className="text-[11px] text-slate-600 font-medium leading-tight">
                  <span className="font-bold">Informasi:</span> Masukkan data pemeriksaan gigi anak untuk pemantauan rutin.
                </p>
              </div>
              
              <form onSubmit={handleSubmit} className="space-y-4">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  {/* Waktu Kunjungan Card */}
                  <div className="bg-white border border-slate-100 p-4 rounded-2xl shadow-sm space-y-3">
                    <div className="flex items-center gap-2 text-black">
                      <Calendar size={16} />
                      <span className="text-[11px] font-bold tracking-tight">Waktu Kunjungan</span>
                    </div>
                    <div>
                      <label className="block mb-1 text-[9px] font-bold text-slate-400 uppercase tracking-widest">Bulan Ke-</label>
                      <select 
                        className="w-full bg-[#f8fafc] border border-slate-100 rounded-lg p-2.5 outline-none focus:ring-1 focus:ring-black text-black text-xs font-bold transition-all"
                        value={formData.bulan_ke}
                        onChange={e => setFormData({ ...formData, bulan_ke: e.target.value })}
                        required
                      >
                        <option value="">Pilih Jadwal</option>
                        {[...Array(60)].map((_, i) => (
                          <option key={i} value={i + 1}>Bulan {i + 1}</option>
                        ))}
                      </select>
                    </div>
                    <div>
                      <label className="block mb-1 text-[9px] font-bold text-slate-400 uppercase tracking-widest">Tanggal Periksa</label>
                      <input
                        type="date"
                        className="w-full bg-[#f8fafc] border border-slate-100 rounded-lg p-2.5 outline-none focus:ring-1 focus:ring-black text-black text-xs font-bold transition-all"
                        value={formData.tanggal}
                        onChange={e => setFormData({ ...formData, tanggal: e.target.value })}
                        required
                      />
                    </div>
                  </div>

                  {/* Kondisi Klinis Card */}
                  <div className="bg-white border border-slate-100 p-4 rounded-2xl shadow-sm space-y-3">
                    <div className="flex items-center gap-2 text-black">
                      <Activity size={16} />
                      <span className="text-[11px] font-bold tracking-tight">Kondisi Klinis</span>
                    </div>
                    <div className="grid grid-cols-2 gap-3">
                      <div>
                        <label className="block mb-1 text-[9px] font-bold text-slate-400 uppercase tracking-widest">Gigi Ada</label>
                        <input
                          type="number"
                          className="w-full bg-[#f8fafc] border border-slate-100 rounded-lg p-2.5 outline-none focus:ring-1 focus:ring-black text-black text-sm font-bold text-center"
                          value={formData.jumlah_gigi}
                          onChange={e => setFormData({ ...formData, jumlah_gigi: e.target.value })}
                          required
                        />
                      </div>
                      <div>
                        <label className="block mb-1 text-[9px] font-bold text-red-400 uppercase tracking-widest">Berlubang</label>
                        <input
                          type="number"
                          className="w-full bg-red-50/30 border border-red-100 rounded-lg p-2.5 outline-none focus:ring-1 focus:ring-red-500 text-red-600 text-sm font-bold text-center"
                          value={formData.gigi_berlubang}
                          onChange={e => setFormData({ ...formData, gigi_berlubang: e.target.value })}
                          required
                        />
                      </div>
                    </div>
                    <div>
                      <label className="block mb-2 text-[9px] font-bold text-slate-400 uppercase tracking-widest">Status Plak</label>
                      <div className="flex bg-[#f1f5f9] p-0.5 rounded-lg gap-0.5">
                        {['Bersih', 'Kotor'].map(status => (
                          <button
                            key={status}
                            type="button"
                            onClick={() => setFormData({ ...formData, status_plak: status })}
                            className={`flex-1 py-1.5 rounded-md text-[10px] font-bold transition-all ${formData.status_plak === status
                                ? 'bg-blue-600 text-white shadow-sm'
                                : 'text-slate-400 hover:text-slate-600'
                              }`}
                          >
                            {status}
                          </button>
                        ))}
                      </div>
                    </div>
                  </div>
                </div>

                {/* Risiko Card - Very Compact */}
                <div className="bg-[#f8fafc] p-4 rounded-2xl border border-slate-100">
                  <label className="block mb-3 text-[9px] font-bold text-slate-400 uppercase tracking-widest text-center">Risiko Karies</label>
                  <div className="grid grid-cols-3 gap-2">
                    {[
                      { val: 'Tinggi', color: 'bg-pink-500' },
                      { val: 'Sedang', color: 'bg-orange-500' },
                      { val: 'Rendah', color: 'bg-green-500' }
                    ].map(item => (
                      <button
                        key={item.val}
                        type="button"
                        onClick={() => setFormData({ ...formData, resiko_gigi_berlubang: item.val })}
                        className={`py-3 rounded-xl border transition-all flex flex-col items-center gap-1.5 ${formData.resiko_gigi_berlubang === item.val
                            ? `border-blue-600 bg-blue-600 text-white shadow-md scale-[1.02]`
                            : `border-white bg-white text-slate-400 hover:border-slate-100 shadow-sm`
                          }`}
                      >
                        <div className={`w-2 h-2 rounded-full ${item.color}`}></div>
                        <span className="text-[9px] font-bold uppercase tracking-widest">{item.val}</span>
                      </button>
                    ))}
                  </div>
                </div>

                {/* Action Buttons */}
                <div className="flex items-center justify-end gap-4 pt-2">
                  <button 
                    type="button"
                    onClick={() => setIsModalOpen(false)}
                    className="text-xs font-bold text-slate-400 hover:text-slate-600 transition-colors"
                  >
                    Batal
                  </button>
                  <button
                    disabled={isSubmitting}
                    type="submit"
                    className="bg-blue-600 hover:bg-blue-700 text-white px-8 py-2.5 rounded-lg font-bold flex items-center gap-2 shadow-md transition-all active:scale-[0.98] disabled:bg-blue-300 text-xs"
                  >
                    {isSubmitting ? (
                      <Loader2 className="animate-spin" size={14} />
                    ) : (
                      <Save size={14} />
                    )}
                    <span>Simpan Data</span>
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      )}
    </MainLayout>
  );
};

export default PelayananGigi;