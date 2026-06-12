import React, { useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import MainLayout from "../../components/Layout/MainLayout";
import { PelayananVitaminService } from "../../services/pelayananvitaminanak";
import { Save, ArrowLeft, Pill, AlertTriangle, CheckCircle2, Info, Loader2, Code, User, Lock } from 'lucide-react';

const PelayananVitaminCreate = () => {
  const { id: anakId } = useParams();
  const navigate = useNavigate();
  const [submitting, setSubmitting] = useState(false);

  // 'bulan' disimpan di state untuk validasi UI, namun akan dibuang saat getPreparedPayload()
  const [formData, setFormData] = useState({
    anak_id: parseInt(anakId),
    tanggal: new Date().toISOString().split('T')[0],
    bulan: "", 
    detail: []
  });

  // 1. Validasi Jadwal Nasional Vitamin A (Februari = 2, Agustus = 8)
  const isJadwalNasional = () => {
    const selectedMonth = new Date(formData.tanggal).getMonth() + 1;
    return selectedMonth === 2 || selectedMonth === 8;
  };

  // 2. Validasi Kelayakan Umur
  const checkEligibility = (id) => {
    const umur = parseInt(formData.bulan);
    if (isNaN(umur)) return false;

    if (id === 30) return umur >= 6 && umur <= 11; // Vitamin A Biru
    if (id === 31) return umur >= 12 && umur <= 59; // Vitamin A Merah (Max 5 tahun)
    if (id === 32) return umur >= 12; // Obat Cacing (12 bulan ke atas, bisa > 60 bln)
    return false;
  };

  const handleToggleVitamin = (id, label) => {
    // Vitamin A (30 & 31) terikat jadwal Nasional, Obat Cacing (32) biasanya lebih fleksibel
    if ((id === 30 || id === 31) && !isJadwalNasional()) {
      return alert(`Gagal: Pemberian ${label} hanya diperbolehkan pada bulan Februari atau Agustus.`);
    }
    
    if (!checkEligibility(id)) {
      return alert(`Gagal: Umur anak (${formData.bulan} bln) tidak memenuhi kriteria untuk ${label}.`);
    }

    const exists = formData.detail.find(d => d.jenis_pelayanan_id === id);
    if (exists) {
      setFormData({ ...formData, detail: formData.detail.filter(d => d.jenis_pelayanan_id !== id) });
    } else {
      setFormData({ ...formData, detail: [...formData.detail, { jenis_pelayanan_id: id, keterangan: "" }] });
    }
  };

  const handleKeterangan = (id, teks) => {
    const newDetail = formData.detail.map(d => 
      d.jenis_pelayanan_id === id ? { ...d, keterangan: teks } : d
    );
    setFormData({ ...formData, detail: newDetail });
  };

  // Fungsi untuk membersihkan data sebelum dikirim ke Backend Go
  const getPreparedPayload = () => {
    return {
      anak_id: formData.anak_id,
      tanggal: new Date(formData.tanggal).toISOString(), // Mengubah ke format ISO time.Time
      detail: formData.detail.map(d => ({
        jenis_pelayanan_id: parseInt(d.jenis_pelayanan_id),
        keterangan: d.keterangan || ""
      }))
    };
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    const umurBulan = Number(formData.bulan);
    if (isNaN(umurBulan) || umurBulan <= 0) {
      alert("Umur anak (bulan) harus lebih besar dari 0!");
      return;
    }
    if (formData.detail.length === 0) return alert("Pilih minimal satu pelayanan!");
    
    setSubmitting(true);
    try {
      const payload = getPreparedPayload();
      await PelayananVitaminService.create(payload);
      alert("Data berhasil disimpan ke sistem!");
      navigate(`/data-anak/pelayanan-vitamin/${anakId}`);
    } catch (err) {
      console.error("Submit Error:", err.response?.data);
      alert("Gagal menyimpan data. Periksa koneksi atau validasi server.");
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <MainLayout>
      <div className="max-w-4xl mx-auto p-4 md:p-10 bg-slate-50 min-h-screen">
        <button 
          onClick={() => navigate(-1)} 
          className="flex items-center gap-2 text-slate-400 font-black text-[10px] uppercase mb-6 hover:text-slate-900 transition-all"
        >
          <ArrowLeft size={14} /> Kembali ke Riwayat
        </button>

        <div className="bg-white rounded-[3.5rem] shadow-2xl border border-slate-100 overflow-hidden">
          {/* HEADER */}
          <div className="bg-slate-900 p-10 text-white flex flex-col md:flex-row justify-between items-start md:items-center gap-6">
            <div>
              <h1 className="text-3xl font-black tracking-tight flex items-center gap-3">
                <Pill className="text-pink-500" size={36} /> Input Pelayanan
              </h1>
              <p className="text-slate-400 text-[10px] font-black uppercase mt-2 tracking-widest flex items-center gap-2">
                <User size={12} /> ID Anak: {anakId}
              </p>
            </div>
            
            <div className={`px-5 py-3 rounded-2xl text-[10px] font-black uppercase tracking-widest flex items-center gap-3 shadow-xl transition-all ${isJadwalNasional() ? 'bg-green-600' : 'bg-amber-500'}`}>
              {isJadwalNasional() ? <CheckCircle2 size={16} /> : <AlertTriangle size={16} />}
              {isJadwalNasional() ? "Jadwal Nasional Aktif" : "Bukan Jadwal Vit A"}
            </div>
          </div>

          <form onSubmit={handleSubmit} className="p-10 space-y-10">
            {/* INPUT VALIDASI (Bulan tidak disubmit) */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
              <div className="space-y-3">
                <label className="text-[10px] font-black text-pink-600 uppercase tracking-widest ml-1">
                  Umur Anak (Bulan) *Validasi
                </label>
                <input 
                  type="number" 
                  min="1"
                  placeholder="Masukkan umur..."
                  value={formData.bulan}
                  onChange={(e) => {
                    const val = e.target.value;
                    if (val === "" || Number(val) > 0) {
                      setFormData({...formData, bulan: val});
                    }
                  }}
                  className="w-full p-5 bg-pink-50/20 border-2 border-pink-100 rounded-[1.5rem] font-black text-slate-700 focus:border-pink-500 outline-none transition-all"
                  required
                />
              </div>
              <div className="space-y-3">
                <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest ml-1">Tanggal Pemberian</label>
                <input 
                  type="date" 
                  value={formData.tanggal}
                  onChange={(e) => setFormData({...formData, tanggal: e.target.value})}
                  className="w-full p-5 bg-slate-50 border-2 border-slate-100 rounded-[1.5rem] font-bold text-slate-700 focus:border-pink-500 outline-none transition-all"
                  required
                />
              </div>
            </div>

            {/* SEKSI PILIHAN */}
            <div className="space-y-4">
              <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest ml-1">Pilih Jenis Pelayanan</label>
              <div className="grid grid-cols-1 gap-4">
                <VitaminCard 
                  id={30} label="Vitamin A Biru" desc="6-11 Bulan" 
                  eligible={checkEligibility(30)} active={isJadwalNasional()} 
                  formData={formData} onToggle={handleToggleVitamin} onKeterangan={handleKeterangan} 
                />
                <VitaminCard 
                  id={31} label="Vitamin A Merah" desc="12-59 Bulan" 
                  eligible={checkEligibility(31)} active={isJadwalNasional()} 
                  formData={formData} onToggle={handleToggleVitamin} onKeterangan={handleKeterangan} 
                />
                <VitaminCard 
                  id={32} label="Obat Cacing" desc="12 Bulan ke Atas" 
                  eligible={checkEligibility(32)} active={true} 
                  formData={formData} onToggle={handleToggleVitamin} onKeterangan={handleKeterangan} 
                />
              </div>
            </div>

            <button 
              type="submit"
              disabled={submitting || formData.detail.length === 0}
              className="w-full py-6 bg-slate-900 text-white rounded-[2.5rem] font-black text-xs uppercase tracking-widest hover:bg-pink-600 shadow-2xl transition-all disabled:opacity-30 flex items-center justify-center gap-3"
            >
              {submitting ? <Loader2 className="animate-spin" size={18} /> : <Save size={18} />}
              Simpan Rekam Medis
            </button>

            {/* DEBUG VIEW - MEMASTIKAN PAYLOAD TANPA FIELD 'BULAN' */}
            <div className="mt-12 pt-8 border-t border-slate-100">
              <div className="flex items-center gap-3 mb-6">
                <div className="p-2 bg-slate-100 rounded-lg text-slate-600"><Code size={18} /></div>
                <div>
                  <h2 className="text-[10px] font-black text-slate-400 uppercase tracking-widest">JSON Payload Submit</h2>
                  <p className="text-[9px] text-slate-400 font-bold italic">Data yang akan dikirim ke Go Backend</p>
                </div>
              </div>
              
              <div className="bg-slate-900 rounded-[2.5rem] p-8 shadow-inner overflow-hidden">
                <pre className="text-green-400 font-mono text-[11px] leading-relaxed overflow-x-auto whitespace-pre-wrap">
                  {JSON.stringify(getPreparedPayload(), null, 2)}
                </pre>
              </div>
            </div>
          </form>
        </div>
      </div>
    </MainLayout>
  );
};

const VitaminCard = ({ id, label, desc, eligible, active, formData, onToggle, onKeterangan }) => {
  const isChecked = formData.detail.some(d => d.jenis_pelayanan_id === id);
  const isLocked = !eligible || !active;

  return (
    <div className={`p-6 rounded-[2rem] border-2 transition-all duration-300 ${isLocked ? 'bg-slate-50 border-slate-100 opacity-40' : isChecked ? 'border-pink-500 bg-pink-50/30' : 'border-slate-100 bg-white hover:border-slate-300'}`}>
      <div className="flex items-start justify-between">
        <div className="flex items-center gap-5">
          <input 
            type="checkbox" 
            disabled={isLocked}
            checked={isChecked}
            onChange={() => onToggle(id, label)}
            className="w-7 h-7 accent-pink-600 cursor-pointer rounded-lg"
          />
          <div>
            <p className={`font-black text-sm leading-none ${isLocked ? 'text-slate-400' : 'text-slate-800'}`}>{label}</p>
            <p className="text-[10px] font-bold text-slate-400 mt-2 uppercase tracking-tight">{desc}</p>
          </div>
        </div>
        {isLocked && (
          <div className="p-2 bg-slate-200 rounded-lg text-slate-500 shadow-sm">
            <Lock size={14} />
          </div>
        )}
      </div>
      
      {isChecked && (
        <div className="mt-5 animate-in fade-in slide-in-from-top-2 duration-300">
          <input 
            type="text"
            placeholder="Catatan tambahan (kondisi anak)..."
            value={formData.detail.find(d => d.jenis_pelayanan_id === id)?.keterangan || ""}
            onChange={(e) => onKeterangan(id, e.target.value)}
            className="w-full bg-white border border-pink-200 rounded-[1.2rem] px-5 py-3 text-xs font-bold text-slate-600 focus:ring-4 ring-pink-100 outline-none transition-all"
          />
        </div>
      )}
    </div>
  );
};

export default PelayananVitaminCreate;