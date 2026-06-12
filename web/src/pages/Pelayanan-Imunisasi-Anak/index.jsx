import React, { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import { 
  Save, Syringe, CheckSquare, Square, Calendar, 
  CheckCircle2, RefreshCw, X, ArrowLeft, AlertTriangle, Clock 
} from 'lucide-react';
import MainLayout from "../../components/Layout/MainLayout";
import { getImunisasiByAnakId, setJadwalSelesai } from "../../services/imunisasiBidanService";

const PelayananImunisasi = () => {
  const { id } = useParams();
  
  const [jadwalList, setJadwalList] = useState([]);
  const [dataAnak, setDataAnak] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [formData, setFormData] = useState({
    selectedJadwalIds: [],
    keterangan: "",
    tanggal: new Date().toISOString().split('T')[0]
  });

  // ─── BULAN STANDAR KIA ─────────────────────────
  const months = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 18, 23, "23-59"];

  // ─── FETCH DATA ────────────────────────────────
  const fetchData = async () => {
    try {
      setLoading(true);
      setError(null);
      const res = await getImunisasiByAnakId(id);
      
      if (Array.isArray(res) && res.length > 0) {
        setDataAnak(res[0]);
        setJadwalList(res[0].jadwal || []);
      } else {
        setDataAnak(null);
        setJadwalList([]);
      }
    } catch (err) {
      setError(err.message || 'Gagal memuat data');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { 
    if (id) fetchData(); 
  }, [id]);

  // ─── HELPERS ────────────────────────────────────
  const formatTanggal = (dateString) => {
    if (!dateString) return '-';
    const date = new Date(dateString);
    if (isNaN(date.getTime()) || date.getFullYear() < 1900) return '-';
    return date.toLocaleDateString('id-ID', { day: '2-digit', month: '2-digit', year: '2-digit' });
  };

  const getStatusColor = (statusId) => {
    switch (statusId) {
      case 1: return 'bg-amber-100 text-amber-700';
      case 2: return 'bg-blue-100 text-blue-700';
      case 3: return 'bg-red-100 text-red-700';
      case 4: return 'bg-orange-100 text-orange-700';
      case 5: return 'bg-red-200 text-red-800';
      case 6: return 'bg-green-100 text-green-700';
      default: return 'bg-gray-100 text-gray-500';
    }
  };

  const getStatusLabel = (statusId) => {
    switch (statusId) {
      case 1: return 'Mendekati';
      case 2: return 'Jatuh Tempo';
      case 3: return 'Terlewat';
      case 4: return 'Terlambat';
      case 5: return 'Krisis';
      case 6: return 'Selesai';
      default: return 'Tidak Diketahui';
    }
  };

  // ─── HITUNG BULAN DARI TANGGAL LAHIR ───────────
  const getBulanEstimasi = (tanggalEstimasi) => {
    if (!dataAnak?.tanggal_lahir || !tanggalEstimasi) return null;
    const lahir = new Date(dataAnak.tanggal_lahir);
    const estimasi = new Date(tanggalEstimasi);
    const diffBulan = (estimasi.getFullYear() - lahir.getFullYear()) * 12 + (estimasi.getMonth() - lahir.getMonth());
    return diffBulan;
  };

  // ─── FILTER ─────────────────────────────────────
  const perhatian = jadwalList.filter(j => [3, 4, 5].includes(j.status_id));
  const akanDatang = jadwalList.filter(j => [1, 2].includes(j.status_id));
  const selesai = jadwalList.filter(j => j.status_id === 6);
  const jadwalBelumSelesai = jadwalList.filter(j => j.status_id !== 6);

  // ─── MODAL HANDLERS ────────────────────────────
  const handleToggleJadwal = (jadwalId) => {
    setFormData(prev => ({
      ...prev,
      selectedJadwalIds: prev.selectedJadwalIds.includes(jadwalId)
        ? prev.selectedJadwalIds.filter(id => id !== jadwalId)
        : [...prev.selectedJadwalIds, jadwalId]
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (formData.selectedJadwalIds.length === 0) return;

    try {
      setIsSubmitting(true);
      
      for (const jadwalId of formData.selectedJadwalIds) {
        await setJadwalSelesai(jadwalId);
      }
      
      setIsModalOpen(false);
      setFormData({ selectedJadwalIds: [], keterangan: "", tanggal: new Date().toISOString().split('T')[0] });
      fetchData();
    } catch (err) {
      alert('Gagal menyimpan: ' + (err.message || 'Terjadi kesalahan'));
    } finally {
      setIsSubmitting(false);
    }
  };

  // ─── GROUP JADWAL BY NAMA DOSIS ────────────────
  const groupedJadwal = jadwalList.reduce((acc, j) => {
    if (!acc[j.nama_dosis]) acc[j.nama_dosis] = [];
    acc[j.nama_dosis].push(j);
    return acc;
  }, {});

  // ─── LOADING ────────────────────────────────────
  if (loading) {
    return (
      <MainLayout>
        <div className="flex items-center justify-center min-h-screen">
          <div className="flex flex-col items-center gap-3">
            <RefreshCw size={36} className="animate-spin text-blue-600" />
            <p className="text-sm text-gray-500 font-medium">Memuat data imunisasi...</p>
          </div>
        </div>
      </MainLayout>
    );
  }

  // ─── ERROR ──────────────────────────────────────
  if (error) {
    return (
      <MainLayout>
        <div className="flex items-center justify-center min-h-screen">
          <div className="text-center">
            <AlertTriangle size={48} className="mx-auto text-red-400 mb-4" />
            <p className="text-red-600 font-medium">{error}</p>
            <button onClick={fetchData} className="mt-4 text-blue-600 underline text-sm">Coba lagi</button>
          </div>
        </div>
      </MainLayout>
    );
  }

  // ─── RENDER ─────────────────────────────────────
  return (
    <MainLayout>
      <div className="p-4 md:p-6 bg-gray-50 min-h-screen">
        <div className="max-w-7xl mx-auto">
          
          {/* HEADER */}
          <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 mb-6">
            <div>
              <Link 
                to={`/data-anak/dashboard/${id}`}
                className="flex items-center gap-2 text-gray-500 hover:text-blue-600 text-sm mb-2 transition-colors"
              >
                <ArrowLeft size={16} /> Kembali ke Dashboard
              </Link>
              <h1 className="text-2xl font-bold text-gray-800">
                Pelayanan Imunisasi
              </h1>
              {dataAnak && (
                <p className="text-gray-500 text-sm mt-1">
                  {dataAnak.nama_anak} • Lahir {formatTanggal(dataAnak.tanggal_lahir)}
                </p>
              )}
            </div>
            
            <button 
              onClick={() => setIsModalOpen(true)}
              disabled={jadwalBelumSelesai.length === 0}
              className="flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white px-5 py-2.5 rounded-xl font-bold text-sm shadow-md transition-all active:scale-95 disabled:bg-gray-300 disabled:cursor-not-allowed"
            >
              <Syringe size={18} /> PARAF IMUNISASI
            </button>
          </div>

          {/* INFO CARDS */}
          <div className="grid grid-cols-2 md:grid-cols-4 gap-3 mb-6">
            <InfoCard label="Total Jadwal" value={jadwalList.length} color="bg-blue-600" />
            <InfoCard label="Butuh Perhatian" value={perhatian.length} color="bg-red-500" />
            <InfoCard label="Akan Datang" value={akanDatang.length} color="bg-amber-500" />
            <InfoCard label="Selesai" value={selesai.length} color="bg-green-500" />
          </div>

          {/* TABEL GRID KIA - DATA DARI API */}
          <div className="bg-white shadow-xl border border-gray-300 rounded-sm overflow-hidden mb-6">
            <div className="overflow-x-auto">
              {jadwalList.length === 0 ? (
                <div className="text-center py-20 text-gray-400">
                  <Syringe size={48} className="mx-auto mb-4 opacity-30" />
                  <p className="font-medium">Belum ada jadwal imunisasi untuk anak ini</p>
                </div>
              ) : (
                <table className="w-full border-collapse text-[10px] table-fixed">
                  <thead>
                    <tr className="bg-gray-800 text-white uppercase font-bold text-[9px]">
                      <th rowSpan="2" className="border border-gray-400 p-2 w-48 text-left uppercase">Jenis Vaksin</th>
                      <th colSpan={months.length} className="border border-gray-400 p-1 text-center italic tracking-widest">Bulan</th>
                    </tr>
                    <tr className="bg-gray-800 text-white font-bold">
                      {months.map((m, i) => (
                        <th key={i} className="border border-gray-400 p-1 w-12 text-center">{m}</th>
                      ))}
                    </tr>
                  </thead>
                  <tbody>
                    <tr className="bg-gray-100 font-bold uppercase text-gray-700 text-[9px]">
                      <td className="border border-gray-400 p-2">Jenis Vaksin</td>
                      <td colSpan={months.length} className="border border-gray-400 p-1 text-center italic font-normal tracking-tighter uppercase">
                        Tanggal Pemberian dan Paraf Petugas
                      </td>
                    </tr>
                    {Object.entries(groupedJadwal).map(([namaDosis, items]) => {
                      const doneItem = items.find(j => j.status_id === 6);
                      const estimasiBulan = getBulanEstimasi(items[0]?.tanggal_estimasi);
                      
                      return (
                        <tr key={namaDosis} className="hover:bg-blue-50 h-14 transition-colors">
                          <td className="border border-gray-400 p-2 bg-gray-50 font-bold text-gray-700 leading-tight uppercase">
                            {namaDosis}
                            <div className="text-[8px] font-normal italic text-gray-400 mt-1 uppercase">
                              Batch: {doneItem?.keterangan || "......"}
                            </div>
                          </td>
                          {months.map((m, mIdx) => {
                            const isDone = !!doneItem;
                            const monthValue = m === "23-59" ? 23 : parseInt(m);
                            const isThisMonth = estimasiBulan !== null && estimasiBulan === monthValue;
                            const isPast = estimasiBulan !== null && estimasiBulan < monthValue && m !== "23-59";
                            const isRange = m === "23-59" && estimasiBulan !== null && estimasiBulan >= 23;
                            
                            // Warna cell
                            let cellColor = "bg-white";
                            if (isDone) {
                              cellColor = "bg-green-50";
                            } else if (isThisMonth || isRange) {
                              if (items[0]?.status_id === 3 || items[0]?.status_id === 5) {
                                cellColor = "bg-red-50";
                              } else if (items[0]?.status_id === 4) {
                                cellColor = "bg-orange-50";
                              } else {
                                cellColor = "bg-yellow-100";
                              }
                            }
                            
                            return (
                              <td 
                                key={mIdx} 
                                className={`border border-gray-400 text-center relative ${cellColor}`}
                              >
                                {(isThisMonth || isRange) && (
                                  <div className="leading-none flex flex-col items-center justify-center">
                                    <span className={`font-bold text-[8px] mb-0.5 ${isDone ? 'text-green-700' : 'text-gray-600'}`}>
                                      {formatTanggal(items[0]?.tanggal_estimasi)}
                                    </span>
                                    {isDone && (
                                      <div className="text-green-600 font-bold text-sm leading-none">✓</div>
                                    )}
                                    {!isDone && items[0]?.status_id === 3 && (
                                      <div className="text-red-500 font-bold text-sm leading-none">!</div>
                                    )}
                                  </div>
                                )}
                                {!isThisMonth && !isRange && isDone && isPast && (
                                  <div className="text-green-600 font-bold text-sm leading-none">✓</div>
                                )}
                              </td>
                            );
                          })}
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              )}
            </div>
          </div>

          {/* SECTION CARDS (RINGKASAN) */}
          {perhatian.length > 0 && (
            <Section title="Butuh Perhatian" icon={<AlertTriangle size={18} />} color="border-red-400 bg-red-50" textColor="text-red-700">
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
                {perhatian.map(item => (
                  <JadwalCard key={item.jadwal_id} item={item} getStatusColor={getStatusColor} getStatusLabel={getStatusLabel} formatTanggal={formatTanggal} />
                ))}
              </div>
            </Section>
          )}

          {akanDatang.length > 0 && (
            <Section title="Akan Datang" icon={<Clock size={18} />} color="border-amber-400 bg-amber-50" textColor="text-amber-700">
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
                {akanDatang.map(item => (
                  <JadwalCard key={item.jadwal_id} item={item} getStatusColor={getStatusColor} getStatusLabel={getStatusLabel} formatTanggal={formatTanggal} />
                ))}
              </div>
            </Section>
          )}

          {selesai.length > 0 && (
            <Section title="Selesai" icon={<CheckCircle2 size={18} />} color="border-green-400 bg-green-50" textColor="text-green-700">
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
                {selesai.map(item => (
                  <JadwalCard key={item.jadwal_id} item={item} getStatusColor={getStatusColor} getStatusLabel={getStatusLabel} formatTanggal={formatTanggal} />
                ))}
              </div>
            </Section>
          )}
        </div>
      </div>

      {/* MODAL PARAF */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4">
          <div className="bg-white rounded-2xl w-full max-w-md overflow-hidden shadow-2xl border-t-4 border-blue-600">
            
            <div className="bg-gray-800 p-4 text-white flex justify-between items-center">
              <span className="flex items-center gap-2 font-bold text-sm uppercase tracking-wider">
                <Syringe size={18} className="text-blue-400"/> Paraf Imunisasi
              </span>
              <button onClick={() => setIsModalOpen(false)} className="hover:rotate-90 transition-transform">
                <X size={20}/>
              </button>
            </div>
            
            <form onSubmit={handleSubmit} className="p-6 space-y-4">
              <div>
                <label className="text-gray-500 mb-1 block text-xs font-bold uppercase tracking-wider">Tanggal Pelayanan</label>
                <div className="flex items-center gap-2 border-b-2 focus-within:border-blue-600 pb-2">
                  <Calendar size={16} className="text-gray-400" />
                  <input 
                    type="date" 
                    className="w-full outline-none font-bold text-sm bg-transparent" 
                    value={formData.tanggal} 
                    onChange={e => setFormData({...formData, tanggal: e.target.value})} 
                    required 
                  />
                </div>
              </div>

              <div className="bg-gray-50 p-4 rounded-xl border border-gray-200">
                <div className="flex justify-between items-center mb-3">
                  <label className="text-gray-400 text-[10px] font-bold uppercase tracking-widest">Vaksin yang Diberikan:</label>
                  <span className="text-[10px] text-gray-500">{jadwalBelumSelesai.length} tersedia</span>
                </div>

                <div className="space-y-2 max-h-56 overflow-y-auto">
                  {jadwalBelumSelesai.map(jadwal => (
                    <div 
                      key={jadwal.jadwal_id} 
                      onClick={() => handleToggleJadwal(jadwal.jadwal_id)}
                      className={`flex items-center justify-between gap-3 p-3 rounded-lg border-2 transition-all cursor-pointer
                      ${formData.selectedJadwalIds.includes(jadwal.jadwal_id) 
                        ? 'bg-blue-600 text-white border-blue-600' 
                        : 'bg-white border-gray-100 text-gray-700 hover:border-blue-300'}`}
                    >
                      <div className="flex items-center gap-3">
                        {formData.selectedJadwalIds.includes(jadwal.jadwal_id) ? <CheckSquare size={18}/> : <Square size={18}/>}
                        <span className="text-xs font-medium">{jadwal.nama_dosis}</span>
                      </div>
                      <span className={`text-[9px] px-2 py-0.5 rounded-full font-bold ${getStatusColor(jadwal.status_id)}`}>
                        {getStatusLabel(jadwal.status_id)}
                      </span>
                    </div>
                  ))}
                  {jadwalBelumSelesai.length === 0 && (
                    <div className="text-center py-6 text-green-600 font-bold text-sm">
                      <CheckCircle2 size={32} className="mx-auto mb-2" />
                      Semua jadwal sudah selesai!
                    </div>
                  )}
                </div>
              </div>

              <div>
                <label className="text-gray-500 mb-1 block text-xs font-bold uppercase tracking-wider">No Batch / Catatan</label>
                <input 
                  type="text" 
                  className="w-full border-b-2 p-2 outline-none text-sm focus:border-blue-600" 
                  placeholder="catatan batch vaksin..." 
                  value={formData.keterangan} 
                  onChange={e => setFormData({...formData, keterangan: e.target.value})} 
                />
              </div>

              <button 
                disabled={isSubmitting || formData.selectedJadwalIds.length === 0} 
                type="submit" 
                className="w-full bg-blue-600 text-white py-3.5 rounded-xl hover:bg-blue-700 flex justify-center items-center gap-3 transition-all font-bold text-sm uppercase tracking-wider disabled:bg-gray-300"
              >
                {isSubmitting ? (
                  <><RefreshCw size={18} className="animate-spin"/> MEMPROSES...</>
                ) : (
                  <><Save size={18}/> SIMPAN ({formData.selectedJadwalIds.length}) PARAF</>
                )}
              </button>
            </form>
          </div>
        </div>
      )}
    </MainLayout>
  );
};

// ─── SUB-COMPONENTS ──────────────────────────────

function InfoCard({ label, value, color }) {
  return (
    <div className="bg-white rounded-xl p-4 border border-gray-100 shadow-sm">
      <p className="text-[10px] font-bold text-gray-400 uppercase tracking-wider">{label}</p>
      <p className={`text-2xl font-black mt-1 ${color.replace('bg-', 'text-')}`}>{value}</p>
    </div>
  );
}

function Section({ title, icon, color, textColor, children }) {
  return (
    <div className={`${color} rounded-xl p-4 mb-6 border`}>
      <h3 className={`flex items-center gap-2 font-bold text-sm mb-4 ${textColor}`}>
        {icon} {title}
      </h3>
      {children}
    </div>
  );
}

function JadwalCard({ item, getStatusColor, getStatusLabel, formatTanggal }) {
  return (
    <div className="bg-white rounded-xl p-4 border border-gray-100 shadow-sm hover:shadow-md transition-shadow">
      <div className="flex justify-between items-start mb-2">
        <p className="font-bold text-gray-800 text-sm">{item.nama_dosis}</p>
        <span className={`px-2 py-0.5 rounded-full text-[10px] font-bold ${getStatusColor(item.status_id)}`}>
          {getStatusLabel(item.status_id)}
        </span>
      </div>
      <p className="text-xs text-gray-500 mb-2">Estimasi: {formatTanggal(item.tanggal_estimasi)}</p>
      <p className="text-[10px] text-gray-400 leading-relaxed line-clamp-2">{item.deskripsi}</p>
    </div>
  );
}

export default PelayananImunisasi;