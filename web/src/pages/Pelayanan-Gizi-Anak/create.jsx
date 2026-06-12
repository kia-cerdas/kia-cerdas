import React, { useState, useMemo } from "react";
import { PelayananGiziService } from "../../services/Pelayanan-gizi-anak";
import { X, Save, Loader2, CheckCircle2, Circle } from 'lucide-react';
import AlertNotification from "../../components/AlertNotification";

const PelayananGiziModal = ({ isOpen, onClose, anakId, onSuccess }) => {
  if (!isOpen) return null;

  const [submitting, setSubmitting] = useState(false);
  const [notification, setNotification] = useState(null);
  const authUser = JSON.parse(localStorage.getItem('user')) || { id: 0, nama: 'Petugas' };

  const [formData, setFormData] = useState({
    bulan_ke: 1,
    asi: { frekuensi_menyusui: "", posisi_menyusui: "baik", asiperah: "tidak" },
    mpasi: { sudah_mpasi: false, varian_mpasi: [], jumlah_makan: "", m_utama: "", m_selingan: "" }
  });

  const handleSubmit = async () => {
    setSubmitting(true);
    const payload = {
      anak_id: parseInt(anakId),
      tanggal: new Date().toISOString().split('T')[0],
      tenaga_kesehatan_id: parseInt(authUser.id || authUser.user_id),
      bulan_ke: parseInt(formData.bulan_ke),
      lokasi: authUser.lokasi || "Puskesmas",
      asi: {
        frekuensi_menyusui: parseInt(formData.asi.frekuensi_menyusui) || 0,
        posisi_menyusui: formData.asi.posisi_menyusui,
        asi_perah: formData.asi.asiperah
      },
      mpasi: {
        diberikan_mp_asi: formData.mpasi.sudah_mpasi,
        variasi_mpasi: formData.mpasi.varian_mpasi,
        jumlah_makan_perporsi: formData.mpasi.jumlah_makan,
        frekuensi_makan_perhari: `${formData.mpasi.m_utama || 0}x utama, ${formData.mpasi.m_selingan || 0}x selingan`
      }
    };

    try {
      await PelayananGiziService.create(payload);
      setNotification({
        type: "success",
        message: "Data pelayanan gizi berhasil disimpan ke dalam sistem!"
      });
    } catch (err) {
      const errorMsg = err.response?.data?.error || err.response?.data?.message || err.message || "Gagal menyimpan data";
      setNotification({
        type: "error",
        message: "Permintaan gagal diproses. Silakan coba lagi nanti atau hubungi bantuan.",
        code: errorMsg
      });
    } finally {
      setSubmitting(false);
    }
  };

  const handleAlertClose = () => {
    if (notification && notification.type === "success") {
      onSuccess();
      onClose();
    }
    setNotification(null);
  };

  const toggleVarian = (item) => {
    setFormData(prev => {
      const current = prev.mpasi.varian_mpasi;
      const next = current.includes(item) ? current.filter(i => i !== item) : [...current, item];
      return { ...prev, mpasi: { ...prev.mpasi, varian_mpasi: next } };
    });
  };

  return (
    <div className="fixed inset-0 z-[999] flex items-center justify-center p-4">
      <AlertNotification 
        notification={notification} 
        onClose={handleAlertClose} 
        onRetry={notification?.type === "error" ? () => setNotification(null) : null}
      />
      {/* Backdrop */}
      <div className="absolute inset-0 bg-slate-900/60 backdrop-blur-sm" onClick={onClose}></div>
      
      {/* Modal Content */}
      <div className="relative bg-white w-full max-w-2xl rounded-3xl shadow-2xl overflow-hidden animate-in zoom-in-95 duration-200">
        
        {/* Header */}
        <div className="px-8 py-6 border-b border-slate-100 flex justify-between items-center bg-white">
          <div>
            <h2 className="text-xl font-black text-slate-900">Input Data Gizi</h2>
            <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mt-1">Bulan Ke: {formData.bulan_ke} • Petugas: {authUser.nama}</p>
          </div>
          <button onClick={onClose} className="p-2 hover:bg-slate-100 rounded-full text-slate-400 transition-colors"><X size={20}/></button>
        </div>

        {/* Body - Scrollable */}
        <div className="p-8 max-h-[70vh] overflow-y-auto space-y-8 text-slate-600">
          
          {/* Row 1: Pilih Bulan */}
          <div className="flex items-center gap-4 p-4 bg-slate-50 rounded-2xl border border-slate-100">
            <label className="text-xs font-black uppercase text-slate-500">Pilih Bulan Ke-</label>
            <select 
              className="flex-1 bg-white border border-slate-200 rounded-xl px-4 py-2 font-bold text-blue-600 outline-none"
              value={formData.bulan_ke}
              onChange={(e) => setFormData({...formData, bulan_ke: e.target.value})}
            >
              {[1,2,3,4,5,6,7,8,9,10,11,12].map(m => <option key={m} value={m}>{m}</option>)}
            </select>
          </div>

          {/* Section: Pola ASI */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="space-y-4">
              <h3 className="text-xs font-black uppercase tracking-widest text-blue-600">Pola ASI</h3>
              <div>
                <label className="text-[10px] font-bold text-slate-400 block mb-2 uppercase">Frekuensi (kali/hari)</label>
                <input 
                  type="number" className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-3 text-sm font-bold outline-none focus:border-blue-500 transition-all"
                  value={formData.asi.frekuensi_menyusui}
                  onChange={(e) => setFormData({...formData, asi: {...formData.asi, frekuensi_menyusui: e.target.value}})}
                />
              </div>
              <div className="flex gap-2">
                {['baik', 'tidak'].map(opt => (
                  <button 
                    key={opt}
                    onClick={() => setFormData({...formData, asi: {...formData.asi, posisi_menyusui: opt}})}
                    className={`flex-1 py-2 rounded-xl text-[10px] font-black uppercase border-2 transition-all ${formData.asi.posisi_menyusui === opt ? 'bg-slate-900 border-slate-900 text-white' : 'border-slate-100 text-slate-400'}`}
                  >
                    Posisi: {opt}
                  </button>
                ))}
              </div>
            </div>

            {/* Section: Status MPASI */}
            <div className="space-y-4">
              <h3 className="text-xs font-black uppercase tracking-widest text-orange-600">Status MPASI</h3>
              <div className="flex gap-2">
                {[true, false].map(val => (
                  <button 
                    key={val.toString()}
                    onClick={() => setFormData({...formData, mpasi: {...formData.mpasi, sudah_mpasi: val}})}
                    className={`flex-1 py-3 rounded-xl text-xs font-black border-2 transition-all ${formData.mpasi.sudah_mpasi === val ? 'bg-orange-500 border-orange-500 text-white shadow-lg shadow-orange-100' : 'border-slate-100 text-slate-400'}`}
                  >
                    {val ? 'SUDAH' : 'BELUM'}
                  </button>
                ))}
              </div>
            </div>
          </div>

          {/* Conditional Section: Detail MPASI */}
          {formData.mpasi.sudah_mpasi && (
            <div className="p-6 bg-orange-50/30 rounded-3xl border border-orange-100 space-y-6 animate-in slide-in-from-top-2">
               <div>
                  <label className="text-[10px] font-bold text-orange-600 block mb-3 uppercase">Variasi Makanan</label>
                  <div className="flex flex-wrap gap-2">
                    {['nasi', 'sayur', 'buah', 'Lauk Pauk', 'Minyak/Lemak'].map(v => {
                      const active = formData.mpasi.varian_mpasi.includes(v);
                      return (
                        <button key={v} onClick={() => toggleVarian(v)} className={`px-4 py-2 rounded-full text-[10px] font-black transition-all border ${active ? 'bg-orange-500 border-orange-500 text-white' : 'bg-white border-slate-200 text-slate-400'}`}>
                          {v}
                        </button>
                      );
                    })}
                  </div>
               </div>
               <div className="grid grid-cols-3 gap-4">
                  <div className="col-span-1">
                    <label className="text-[10px] font-bold text-slate-400 block mb-2 uppercase">Porsi</label>
                    <select className="w-full bg-white border border-slate-200 rounded-xl px-3 py-2 text-xs font-bold outline-none" onChange={(e) => setFormData({...formData, mpasi: {...formData.mpasi, jumlah_makan: e.target.value}})}>
                      <option value="">Pilih</option>
                      <option value="1 mangkuk">1 Mangkuk</option>
                      <option value="1/2 mangkuk">1/2 Mangkuk</option>
                    </select>
                  </div>
                  <div>
                    <label className="text-[10px] font-bold text-slate-400 block mb-2 uppercase">Utama</label>
                    <input type="text" placeholder="3x" className="w-full bg-white border border-slate-200 rounded-xl px-3 py-2 text-xs font-bold outline-none" onChange={(e) => setFormData({...formData, mpasi: {...formData.mpasi, m_utama: e.target.value}})}/>
                  </div>
                  <div>
                    <label className="text-[10px] font-bold text-slate-400 block mb-2 uppercase">Selingan</label>
                    <input type="text" placeholder="2x" className="w-full bg-white border border-slate-200 rounded-xl px-3 py-2 text-xs font-bold outline-none" onChange={(e) => setFormData({...formData, mpasi: {...formData.mpasi, m_selingan: e.target.value}})}/>
                  </div>
               </div>
            </div>
          )}
        </div>

        {/* Footer Actions */}
        <div className="p-8 bg-slate-50 border-t border-slate-100 flex gap-3">
          <button onClick={onClose} className="flex-1 py-4 text-slate-400 font-black text-xs uppercase tracking-widest hover:text-slate-600 transition-all">Batal</button>
          <button 
            onClick={handleSubmit} 
            disabled={submitting}
            className="flex-[2] py-4 bg-blue-600 text-white rounded-2xl font-black text-xs uppercase tracking-widest shadow-xl shadow-blue-100 hover:scale-[1.02] active:scale-[0.98] transition-all flex items-center justify-center gap-2 disabled:opacity-50"
          >
            {submitting ? <Loader2 size={16} className="animate-spin"/> : <Save size={16}/>}
            Simpan Data Gizi
          </button>
        </div>
      </div>
    </div>
  );
};

export default PelayananGiziModal;