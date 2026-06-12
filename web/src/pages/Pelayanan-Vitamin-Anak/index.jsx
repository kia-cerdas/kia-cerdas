import React, { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import MainLayout from "../../components/Layout/MainLayout";

// Import Service Sesuai File Kamu
import { PelayananVitaminService } from "../../services/pelayananvitaminanak"; 
import { getAnakById } from "../../services/Anak"; // Sesuaikan path-nya

import { Pill, Check, Loader2, Lock, Plus, ArrowLeft } from 'lucide-react';

const PelayananVitaminIndex = () => {
  const { id: anakId } = useParams();
  const navigate = useNavigate();
  const [riwayat, setRiwayat] = useState([]);
  const [dataAnak, setDataAnak] = useState(null);
  const [loading, setLoading] = useState(true);

  // Konfigurasi Aturan (Hardcoded sesuai standar Posyandu/Kemenkes)
  const aturanPelayanan = [
    { id: 30, nama: "VIT A KAPSUL BIRU", min: 6, max: 11 },
    { id: 31, nama: "VIT A KAPSUL MERAH", min: 12, max: 59 },
    { id: 32, nama: "OBAT CACING", min: 12, max: 59 }
  ];

  const kolomUmur = [
    { label: "6 - 11 Bln", min: 6, max: 11 },
    { label: "1 - 2 Thn", min: 12, max: 23 },
    { label: "2 - 3 Thn", min: 24, max: 35 },
    { label: "3 - 4 Thn", min: 36, max: 47 },
    { label: "4 - 5 Thn", min: 48, max: 59 },
    { label: "5 - 6 Thn", min: 60, max: 71 },
  ];

  useEffect(() => {
    const fetchData = async () => {
      setLoading(true);
      try {
        // Menggunakan getAnakById dari service yang kamu berikan
        const [resRiwayat, resAnak] = await Promise.all([
          PelayananVitaminService.getByAnakId(anakId),
          getAnakById(anakId) 
        ]);

        // JSON Riwayat biasanya ada di resRiwayat.data
        // JSON Anak biasanya ada di resAnak.data (tergantung return API kamu)
        setRiwayat(resRiwayat.data || []);
        setDataAnak(resAnak.data || resAnak); 
      } catch (err) {
        console.error("Gagal load data:", err);
      } finally {
        setLoading(false);
      }
    };

    if (anakId) fetchData();
  }, [anakId]);

  // Kalkulator Umur (Bulan)
  const hitungUmurBulan = (tglLahir, tglKunjungan) => {
    if (!tglLahir || !tglKunjungan) return 0;
    const lahir = new Date(tglLahir);
    const kunjungan = new Date(tglKunjungan);
    return (kunjungan.getFullYear() - lahir.getFullYear()) * 12 + (kunjungan.getMonth() - lahir.getMonth());
  };

  // Logika Cek Centang (isGiven)
  const isGiven = (jenisId, kMin, kMax, targetBulan = null) => {
    if (!dataAnak?.tanggal_lahir || !riwayat) return false;

    return riwayat.some(kunjungan => {
      const umurBulan = hitungUmurBulan(dataAnak.tanggal_lahir, kunjungan.tanggal);
      const tgl = new Date(kunjungan.tanggal);
      const bulanKunjungan = tgl.getMonth() + 1; // 1-12

      const matchUmur = umurBulan >= kMin && umurBulan <= kMax;
      const matchJenis = kunjungan.detail?.some(d => d.jenis_pelayanan_id === jenisId);
      const matchBulan = targetBulan ? bulanKunjungan === targetBulan : true;

      return matchUmur && matchJenis && matchBulan;
    });
  };

  // Logika Cek Kolom Aktif (isEnabled)
  const isEnabled = (jenisId, kMin, kMax) => {
    const aturan = aturanPelayanan.find(a => a.id === jenisId);
    if (!aturan) return false;
    // Kolom aktif jika range umur kolom bersinggungan dengan aturan medis
    return kMin >= aturan.min || kMax <= aturan.max;
  };

  return (
    <MainLayout>
      <div className="max-w-7xl mx-auto p-4 md:p-8 bg-slate-50 min-h-screen">
        
        {/* Tombol Back & Header */}
        <button 
          onClick={() => navigate(-1)}
          className="flex items-center gap-2 text-slate-500 hover:text-slate-800 font-bold text-xs uppercase tracking-wider mb-6 transition-all"
        >
          <ArrowLeft size={16} /> Kembali
        </button>

        <div className="flex flex-col md:flex-row md:items-center justify-between gap-6 mb-10">
          <div>
            <h1 className="text-4xl font-black text-slate-900 tracking-tight flex items-center gap-3">
              <div className="p-3 bg-pink-600 rounded-2xl text-white shadow-lg">
                <Pill size={28} />
              </div>
              Vitamin & Obat Cacing
            </h1>
            <div className="flex items-center gap-3 mt-4">
               <span className="px-3 py-1 bg-slate-200 text-slate-700 rounded-full text-[10px] font-bold uppercase">
                 ID: {anakId}
               </span>
               <span className="text-slate-400 font-bold text-[10px] uppercase">
                 Nama: <span className="text-slate-900">{dataAnak?.nama || '...'}</span>
               </span>
            </div>
          </div>
          
          <button 
            onClick={() => navigate(`/data-anak/pelayanan-vitamin/${anakId}/create`)}
            className="bg-slate-900 hover:bg-pink-600 transition-all duration-300 text-white px-8 py-4 rounded-2xl font-black text-xs uppercase shadow-xl flex items-center gap-2 group"
          >
            <Plus size={16} className="group-hover:rotate-90 transition-transform" /> 
            Input Data Baru
          </button>
        </div>

        {loading ? (
          <div className="flex flex-col items-center py-20">
            <Loader2 className="animate-spin text-pink-600" size={40} />
            <p className="text-slate-400 font-bold text-xs mt-4 uppercase tracking-widest">Memuat Riwayat...</p>
          </div>
        ) : (
          <div className="bg-white rounded-[2.5rem] shadow-xl shadow-slate-200/50 border border-slate-100 overflow-hidden">
            <div className="overflow-x-auto">
              <table className="w-full text-left border-collapse">
                <thead>
                  <tr className="bg-slate-900 text-white text-[10px] uppercase tracking-widest text-center">
                    <th rowSpan="2" className="p-6 border-r border-slate-800 text-left w-72">Jenis Layanan Kesehatan</th>
                    <th className="p-3 border-b border-slate-800 bg-slate-800">Interval Umur</th>
                    <th colSpan="5" className="p-3 border-b border-slate-800">Status Pemberian Berdasarkan Tahun</th>
                  </tr>
                  <tr className="bg-slate-800 text-white text-[9px] text-center">
                    {kolomUmur.map(k => (
                      <th key={k.label} className="p-4 border-r border-slate-700 w-32">{k.label}</th>
                    ))}
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100">
                  <TableRow 
                    label="VIT A KAPSUL BIRU" 
                    sub="Target: 6-11 Bulan (1x Seumur Hidup)" 
                    jenisId={30} 
                    kolomUmur={kolomUmur} 
                    isEnabled={isEnabled} 
                    isGiven={isGiven} 
                  />
                  <TableRow 
                    label="VIT A KAPSUL MERAH" 
                    sub="Periode: Februari" 
                    targetBulan={2}
                    jenisId={31} 
                    kolomUmur={kolomUmur} 
                    isEnabled={isEnabled} 
                    isGiven={isGiven} 
                  />
                  <TableRow 
                    label="VIT A KAPSUL MERAH" 
                    sub="Periode: Agustus" 
                    targetBulan={8}
                    jenisId={31} 
                    kolomUmur={kolomUmur} 
                    isEnabled={isEnabled} 
                    isGiven={isGiven} 
                  />
                  <TableRow 
                    label="OBAT CACING" 
                    sub="Interval: Tiap 6 Bulan"
                    jenisId={32} 
                    kolomUmur={kolomUmur} 
                    isEnabled={isEnabled} 
                    isGiven={isGiven} 
                  />
                </tbody>
              </table>
            </div>
          </div>
        )}

        {/* Legend / Keterangan */}
        <div className="mt-8 flex gap-6 px-4">
          <div className="flex items-center gap-2 text-[10px] font-bold text-slate-400 uppercase">
            <div className="w-3 h-3 bg-white border border-slate-200 rounded"></div> Tersedia
          </div>
          <div className="flex items-center gap-2 text-[10px] font-bold text-slate-400 uppercase">
            <Check size={14} className="text-green-500" /> Sudah Diberikan
          </div>
          <div className="flex items-center gap-2 text-[10px] font-bold text-slate-400 uppercase">
            <Lock size={12} className="text-slate-300" /> Belum Masuk Usia
          </div>
        </div>
      </div>
    </MainLayout>
  );
};

// Komponen Row Tabel
const TableRow = ({ label, sub, jenisId, targetBulan, kolomUmur, isEnabled, isGiven }) => (
  <tr className="group hover:bg-slate-50/80 transition-colors">
    <td className="p-6 border-r border-slate-100 bg-slate-50/30">
      <p className="font-black text-slate-800 text-xs mb-1">{label}</p>
      {sub && <p className="text-[9px] text-slate-400 font-bold uppercase tracking-tight">{sub}</p>}
    </td>
    {kolomUmur.map((k, i) => {
      const active = isEnabled(jenisId, k.min, k.max);
      const done = isGiven(jenisId, k.min, k.max, targetBulan);
      
      return (
        <td key={i} className={`p-4 border-r border-slate-100 text-center ${!active ? 'bg-slate-50/50' : ''}`}>
          {active ? (
            done ? (
              <div className="flex justify-center animate-in zoom-in duration-300">
                <div className="bg-green-500 p-1.5 rounded-xl shadow-lg shadow-green-200">
                  <Check className="text-white stroke-[4px]" size={14} />
                </div>
              </div>
            ) : (
              <div className="w-8 h-8 border-2 border-dashed border-slate-200 rounded-xl mx-auto group-hover:border-slate-300 transition-colors" />
            )
          ) : (
            <Lock size={14} className="mx-auto text-slate-200 opacity-40" />
          )}
        </td>
      );
    })}
  </tr>
);

export default PelayananVitaminIndex;