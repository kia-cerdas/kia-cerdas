import React, { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import {
  Save, Syringe, CheckSquare, Square, Calendar,
  CheckCircle2, RefreshCw, X, ArrowLeft, AlertTriangle, XCircle, CalendarClock
} from 'lucide-react';
import Swal from 'sweetalert2';
import MainLayout from "../../components/Layout/MainLayout";
import {
  getImunisasiByAnakId,
  setJadwalSelesai,
  setPencatatanSelesai,
  createPelayananImunisasi,
  getAturanVaksinAnak,
  getPencatatanByAnakId,
  batalParafImunisasi
} from "../../services/imunisasiBidanService";
import { getJadwalLayananList } from "../../services/jadwalLayanan";

const MONTHS = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 18, 23, '23-59'];

// Extract numeric start from a month value (e.g. '23-59' → 23, 18 → 18)
const getMonthStart = (m) => {
  if (typeof m === 'number') return m;
  return parseInt(String(m).split('-')[0]);
};

// ══════════════════════════════════════════════════
// MAIN COMPONENT
// ══════════════════════════════════════════════════
const PelayananImunisasi = () => {
  const { id } = useParams();

  // ─── STATE ─────────────────────────────────────
  const [jadwalList, setJadwalList] = useState([]);
  const [dataAnak, setDataAnak] = useState(null);
  const [aturanVaksin, setAturanVaksin] = useState([]);
  const [pencatatanList, setPencatatanList] = useState([]);
  const [jadwalLayananList, setJadwalLayananList] = useState([]);
  const [jadwalLayananToday, setJadwalLayananToday] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [formData, setFormData] = useState({
    selectedJadwalIds: [],
    batches: {},
    catatan: "",
    tanggal: new Date().toISOString().split('T')[0],
  });

  // ─── DATA FETCHING ─────────────────────────────
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

      try {
        const resAturan = await getAturanVaksinAnak();
        setAturanVaksin(Array.isArray(resAturan) ? resAturan : []);
      } catch {
        setAturanVaksin([]);
      }

      try {
        const resPencatatan = await getPencatatanByAnakId(id);
        const list = Array.isArray(resPencatatan) ? resPencatatan : [];
        setPencatatanList(list);
        console.log('[DEBUG] Pencatatan data:', list.length, 'records');
        console.log('[DEBUG] Pencatatan sample FULL:', JSON.stringify(list[0], null, 2));
        if (list.length > 0) {
          console.log('[DEBUG] Bidan petugas:', list[0]?.bidan_petugas);
          console.log('[DEBUG] id_bidan_petugas:', list[0]?.id_bidan_petugas);
        }
      } catch {
        setPencatatanList([]);
        console.log('[DEBUG] Pencatatan fetch failed');
      }

      // Fetch jadwal layanan
      try {
        const resJadwalLayanan = await getJadwalLayananList();
        const jadwalLayananData = Array.isArray(resJadwalLayanan) ? resJadwalLayanan : [];
        setJadwalLayananList(jadwalLayananData);
        
        console.log('[DEBUG] All jadwal layanan:', jadwalLayananData);
        
        // Find today's schedule with better date parsing
        const today = new Date();
        today.setHours(0, 0, 0, 0); // Reset time to midnight
        const todayStr = today.toISOString().split('T')[0]; // YYYY-MM-DD format
        
        console.log('[DEBUG] Today date string:', todayStr);
        
        const todaySchedule = jadwalLayananData.find(jl => {
          if (!jl.tanggal) {
            console.log('[DEBUG] Jadwal tanpa tanggal:', jl);
            return false;
          }
          
          // Parse schedule date - handle both ISO string and date-only format
          const scheduleDate = new Date(jl.tanggal);
          scheduleDate.setHours(0, 0, 0, 0); // Reset time
          const scheduleDateStr = scheduleDate.toISOString().split('T')[0];
          
          console.log('[DEBUG] Comparing:', {
            id: jl.id,
            layanan: jl.layanan,
            scheduleDateStr,
            todayStr,
            match: scheduleDateStr === todayStr,
            rawTanggal: jl.tanggal,
            dosisVaksinIds: jl.dosis_vaksin_ids
          });
          
          return scheduleDateStr === todayStr;
        });
        
        setJadwalLayananToday(todaySchedule);
        console.log('[DEBUG] ✅ Jadwal layanan hari ini FOUND:', todaySchedule);
        
        if (todaySchedule) {
          console.log('[DEBUG] Dosis vaksin IDs di jadwal:', todaySchedule.dosis_vaksin_ids);
          console.log('[DEBUG] Dosis vaksins detail:', todaySchedule.dosis_vaksins);
        } else {
          console.log('[DEBUG] ❌ Tidak ada jadwal untuk hari ini');
        }
      } catch (err) {
        console.error('[DEBUG] Failed to fetch jadwal layanan:', err);
        setJadwalLayananList([]);
        setJadwalLayananToday(null);
      }
    } catch (err) {
      setError(err.message || 'Gagal memuat data');
      setJadwalList([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (id) fetchData();
    else setError('ID Anak tidak ditemukan');
  }, [id]);

  // ─── HELPERS ───────────────────────────────────
  // Group jadwal by nama_dosis → each group = 1 table row (from API data)
  // Track firstId to preserve database ordering
  const groupedJadwal = React.useMemo(() => {
    const map = {};
    for (const j of jadwalList) {
      if (!j?.nama_dosis) continue;
      const key = j.nama_dosis;
      if (!map[key]) map[key] = { items: [], done: null, dosisVaksinId: j.dosis_vaksin_id, firstId: j.jadwal_id };
      map[key].items.push(j);
      if (j.status_id === 6) map[key].done = j;
      if (j.jadwal_id < map[key].firstId) map[key].firstId = j.jadwal_id;
    }
    return map;
  }, [jadwalList]);

  // Find aturan vaksin by dosis_vaksin_id
  const findAturanByDosisId = (dosisVaksinId) => {
    if (!dosisVaksinId || !aturanVaksin.length) return null;
    return aturanVaksin.find(a => a.dosis_vaksin_id === dosisVaksinId) || null;
  };

  // Calculate which month column a vaccine belongs to.
  // Maps to the nearest available MONTHS column (0-12, 18, 23, 23-59).
  const getJadwalBulan = (tanggalEstimasi, dosisVaksinId) => {
    const aturan = findAturanByDosisId(dosisVaksinId);
    if (aturan && aturan.min_usia_hari !== undefined && aturan.min_usia_hari !== null) {
      const bulan = Math.floor(aturan.min_usia_hari / 30);
      // Map to nearest MONTHS column
      const monthCols = MONTHS.map(getMonthStart);
      let closest = monthCols[monthCols.length - 1];
      for (const col of monthCols) {
        if (col <= bulan) closest = col;
      }
      return closest;
    }
    // Fallback: date-based calculation
    if (!dataAnak?.tanggal_lahir || !tanggalEstimasi) return null;
    const lahir = new Date(dataAnak.tanggal_lahir);
    const estimasi = new Date(tanggalEstimasi);
    if (isNaN(lahir.getTime()) || isNaN(estimasi.getTime())) return null;
    const diff = (estimasi.getFullYear() - lahir.getFullYear()) * 12 + (estimasi.getMonth() - lahir.getMonth());
    const monthCols = MONTHS.map(getMonthStart);
    let closest = monthCols[monthCols.length - 1];
    for (const col of monthCols) {
      if (col <= diff) closest = col;
    }
    return closest;
  };

  // Find pencatatan record by jadwal_imunisasi_anak ID
  const findPencatatanByJadwalId = (jadwalId) => {
    if (!jadwalId || !pencatatanList.length) return null;
    const target = Number(jadwalId);
    return pencatatanList.find(p => Number(p.id_jadwal_imunisasi_anak) === target && p.is_selesai) || null;
  };

  // Get cell content for each month column
  const getCellContent = (group, monthValue) => {
    const doneItem = group.done;
    if (doneItem) {
      const doneBulan = getJadwalBulan(doneItem.tanggal_estimasi, group.dosisVaksinId);
      const monthStart = getMonthStart(monthValue);

      // Look up pencatatan_imunisasi for the actual tanggal_pemberian
      const pencatatan = findPencatatanByJadwalId(doneItem.jadwal_id);
      const displayDate = pencatatan?.tanggal_pemberian || doneItem.tanggal_estimasi;

      // Range column like '23-59'
      if (typeof monthValue === 'string' && monthValue.includes('-')) {
        const [, endStr] = monthValue.split('-');
        const monthEnd = parseInt(endStr);
        if (doneBulan >= monthStart && doneBulan <= monthEnd) {
          return { show: 'done', date: formatTanggal(displayDate) };
        }
      } else {
        if (doneBulan === monthStart) {
          return { show: 'done', date: formatTanggal(displayDate) };
        }
      }
    }
    return { show: 'empty' };
  };

  // Get cell color based on aturan min/max usia hari
  // min_usia_hari = Usia Tepat, max_usia_hari = Masih Diperbolehkan, past max = Tidak Diperbolehkan
  const getCellColor = (dosisVaksinId, monthValue, doneBulan) => {
    const monthStart = getMonthStart(monthValue);
    const monthEnd = (typeof monthValue === 'string' && monthValue.includes('-'))
      ? parseInt(monthValue.split('-')[1])
      : monthStart;

    // Completed dose → green
    if (doneBulan !== null && doneBulan >= monthStart && doneBulan <= monthEnd)
      return 'bg-green-100 border-green-300';

    const aturan = findAturanByDosisId(dosisVaksinId);
    if (!aturan || aturan.min_usia_hari == null) return 'bg-gray-100 border-gray-200';

    const minHari = aturan.min_usia_hari;
    const maxHari = aturan.max_usia_hari || minHari;

    // Convert month column to days range
    // Month 0 = 0-29 days, Month 1 = 30-59 days, etc.
    const monthStartDays = monthStart * 30;
    const monthEndDays = (monthEnd + 1) * 30 - 1;

    // Past max usia → GRAY (Tidak Diperbolehkan)
    // If the month START is already past the max allowed days
    if (monthStartDays > maxHari)
      return 'bg-[#A9A9A9] border-[#888888]';

    // Before min usia → neutral gray
    // If the month END is before the min allowed days
    if (monthEndDays < minHari)
      return 'bg-gray-100 border-gray-200';

    // Calculate ideal window: minHari to minHari + 30 days (1 month tolerance)
    const idealEndDays = minHari + 30;

    // At ideal usia window → WHITE (Usia Tepat)
    // If month overlaps with ideal period
    if (monthStartDays <= idealEndDays && monthEndDays >= minHari)
      return 'bg-white border-gray-300';

    // After ideal, up to max usia → ORANGE (Masih Diperbolehkan)
    if (monthStartDays <= maxHari)
      return 'bg-[#F4B183] border-[#D99A6C]';

    // Fallback: past max → GRAY
    return 'bg-[#A9A9A9] border-[#888888]';
  };

  const formatTanggal = (dateString) => {
    if (!dateString) return '-';
    const d = new Date(dateString);
    if (isNaN(d.getTime()) || d.getFullYear() < 1900) return '-';
    return d.toLocaleDateString('id-ID', { day: '2-digit', month: '2-digit', year: '2-digit' });
  };

  // All unfinished jadwal for modal
  const jadwalBelumSelesai = jadwalList.filter(j => j.status_id !== 6);

  // Filter jadwal based on selected jadwal layanan
  // Uses useMemo to recalculate whenever jadwalLayananToday or jadwalList changes
  const availableJadwalToday = React.useMemo(() => {
    if (!jadwalLayananToday) {
      console.log('[DEBUG] ❌ No jadwal layanan selected');
      return [];
    }

    // All unfinished jadwal
    const jadwalBelumSelesai = jadwalList.filter(j => j.status_id !== 6);

    // Extract dosis vaksin IDs from the preloaded relationship
    // Backend returns: { dosis_vaksins: [{ id: 1, nama_dosis: "BCG", ... }, ...] }
    let allowedDosisIds = [];
    
    if (jadwalLayananToday.dosis_vaksins && Array.isArray(jadwalLayananToday.dosis_vaksins)) {
      // Extract IDs from the preloaded DosisVaksin objects
      allowedDosisIds = jadwalLayananToday.dosis_vaksins.map(dv => dv.id);
      console.log('[DEBUG] ✅ Extracted dosis IDs from dosis_vaksins:', allowedDosisIds);
    } else if (jadwalLayananToday.DosisVaksins && Array.isArray(jadwalLayananToday.DosisVaksins)) {
      // Fallback: capital D (some APIs use PascalCase)
      allowedDosisIds = jadwalLayananToday.DosisVaksins.map(dv => dv.id);
      console.log('[DEBUG] ✅ Extracted dosis IDs from DosisVaksins:', allowedDosisIds);
    } else {
      console.log('[DEBUG] ⚠️ No dosis_vaksins array found in jadwal layanan:', jadwalLayananToday);
    }

    if (allowedDosisIds.length === 0) {
      console.log('[DEBUG] ⚠️ No dosis vaksin IDs in jadwal layanan');
      console.log('[DEBUG] Jadwal structure:', Object.keys(jadwalLayananToday));
      return [];
    }

    console.log('[DEBUG] 📋 Allowed dosis IDs from schedule:', allowedDosisIds);
    console.log('[DEBUG] 📋 Available jadwal belum selesai:', jadwalBelumSelesai.length);

    // Filter jadwal that match selected schedule AND not yet completed
    const filtered = jadwalBelumSelesai.filter(j => {
      const isAllowed = allowedDosisIds.includes(j.dosis_vaksin_id);
      console.log('[DEBUG] 🔍 Checking:', {
        nama_dosis: j.nama_dosis,
        dosis_vaksin_id: j.dosis_vaksin_id,
        jadwal_id: j.jadwal_id,
        isAllowed,
        allowedDosisIds
      });
      return isAllowed;
    });

    console.log('[DEBUG] ✅ Filtered available jadwal count:', filtered.length);
    if (filtered.length > 0) {
      console.log('[DEBUG] Available vaccines:', filtered.map(f => f.nama_dosis).join(', '));
    }
    
    return filtered;
  }, [jadwalLayananToday, jadwalList]);

  // Check if a jadwal item's prerequisite dose has been completed
  const isPreviousDoseComplete = (dosisVaksinId) => {
    if (!aturanVaksin.length || !dosisVaksinId) return true; // no aturan = no restriction
    const aturan = aturanVaksin.find(a => a.dosis_vaksin_id === dosisVaksinId);
    if (!aturan || !aturan.dosis_sebelum_id) return true; // no prerequisite
    // Check if the required previous dose is completed in jadwalList
    return jadwalList.some(j => j.dosis_vaksin_id === aturan.dosis_sebelum_id && j.status_id === 6);
  };

  // Get prerequisite dose name for display
  const getPreviousDoseName = (dosisVaksinId) => {
    if (!aturanVaksin.length || !dosisVaksinId) return '';
    const aturan = aturanVaksin.find(a => a.dosis_vaksin_id === dosisVaksinId);
    if (!aturan || !aturan.dosis_sebelum_id) return '';
    const prevAturan = aturanVaksin.find(a => a.dosis_vaksin_id === aturan.dosis_sebelum_id);
    if (prevAturan?.dosis_vaksin) return prevAturan.dosis_vaksin.nama_dosis;
    // Fallback: find name from jadwalList
    const prevJadwal = jadwalList.find(j => j.dosis_vaksin_id === aturan.dosis_sebelum_id);
    return prevJadwal?.nama_dosis || `Dosis ID ${aturan.dosis_sebelum_id}`;
  };

  // Cancel paraf handler
  const handleBatalParaf = async (jadwalId, namaDosis) => {
    const result = await Swal.fire({
      icon: 'warning',
      title: 'Batalkan Paraf?',
      html: `Apakah Anda yakin ingin membatalkan paraf <b>${namaDosis}</b>?<br/><small class="text-gray-500">Data pencatatan akan dihapus dan jadwal akan dikembalikan ke status belum selesai.</small>`,
      showCancelButton: true,
      confirmButtonText: 'Ya, Batalkan',
      cancelButtonText: 'Tidak',
      confirmButtonColor: '#ef4444',
      cancelButtonColor: '#6b7280',
      reverseButtons: true
    });

    if (!result.isConfirmed) return;

    try {
      await batalParafImunisasi(jadwalId);
      await fetchData();
      Swal.fire({
        icon: 'success',
        title: 'Berhasil!',
        text: `Paraf ${namaDosis} berhasil dibatalkan.`,
        confirmButtonColor: '#10b981',
        timer: 3000,
        timerProgressBar: true
      });
    } catch (err) {
      Swal.fire({
        icon: 'error',
        title: 'Gagal Membatalkan',
        text: err.response?.data?.message?.join(', ') || err.message || 'Terjadi kesalahan',
        confirmButtonColor: '#ef4444'
      });
    }
  };

  // ─── MODAL HANDLERS ────────────────────────────
  const handleToggleJadwal = (jadwalId) => {
    setFormData(prev => ({
      ...prev,
      selectedJadwalIds: prev.selectedJadwalIds.includes(jadwalId)
        ? prev.selectedJadwalIds.filter(x => x !== jadwalId)
        : [...prev.selectedJadwalIds, jadwalId],
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (formData.selectedJadwalIds.length === 0) {
      Swal.fire({
        icon: 'warning',
        title: 'Peringatan',
        text: 'Pilih minimal 1 vaksin!',
        confirmButtonColor: '#2563eb'
      });
      return;
    }

    try {
      setIsSubmitting(true);
      for (const jadwalId of formData.selectedJadwalIds) {
        const jadwal = jadwalList.find(j => j.jadwal_id === jadwalId);
        if (!jadwal) continue;

        // 1. Create pencatatan imunisasi record (new table)
        let pencatatanId = null;
        try {
          const result = await createPelayananImunisasi({
            id_jadwal_imunisasi_anak: jadwalId,
            tanggal_pemberian: formData.tanggal,
            nomor_batch: formData.batches[jadwalId] || '',
            catatan: formData.catatan || '',
          });
          pencatatanId = result?.id;
        } catch (err) {
          console.error('Gagal simpan pencatatan:', err.message);
        }

        // 2. Mark pencatatan as selesai (new table)
        if (pencatatanId) {
          try {
            await setPencatatanSelesai(pencatatanId);
          } catch (err) {
            console.error('Gagal set pencatatan selesai:', err.message);
          }
        }

        // 3. Mark jadwal as selesai (existing endpoint)
        await setJadwalSelesai(jadwalId);
      }

      setIsModalOpen(false);
      setFormData({
        selectedJadwalIds: [],
        batches: {},
        catatan: "",
        tanggal: new Date().toISOString().split('T')[0],
      });
      await fetchData();
      Swal.fire({
        icon: 'success',
        title: 'Berhasil!',
        text: `Berhasil menyimpan ${formData.selectedJadwalIds.length} paraf imunisasi!`,
        confirmButtonColor: '#10b981',
        timer: 3000,
        timerProgressBar: true
      });
    } catch (err) {
      Swal.fire({
        icon: 'error',
        title: 'Gagal Menyimpan',
        text: err.message || 'Terjadi kesalahan saat menyimpan data',
        confirmButtonColor: '#ef4444'
      });
    } finally {
      setIsSubmitting(false);
    }
  };

  // ─── LOADING ───────────────────────────────────
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

  // ─── ERROR ─────────────────────────────────────
  if (error) {
    return (
      <MainLayout>
        <div className="flex items-center justify-center min-h-screen">
          <div className="text-center">
            <AlertTriangle size={48} className="mx-auto text-red-400 mb-4" />
            <p className="text-red-600 font-medium">{error}</p>
            <button onClick={fetchData} className="mt-4 text-blue-600 underline text-sm">
              Coba lagi
            </button>
          </div>
        </div>
      </MainLayout>
    );
  }

  // ─── RENDER ────────────────────────────────────
  return (
    <MainLayout>
      <div className="p-4 md:p-6 bg-gray-50 min-h-screen">
        <div className="max-w-7xl mx-auto">

          {/* ═══════════ HEADER ═══════════ */}
          <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-3 mb-6">
            <div>
              <Link
                to={`/data-anak/dashboard/${id}`}
                className="flex items-center gap-2 text-gray-500 hover:text-blue-600 text-sm mb-1 transition-colors"
              >
                <ArrowLeft size={16} /> Kembali
              </Link>
              <h1 className="text-2xl font-bold text-gray-800">Pelayanan Imunisasi</h1>
              {dataAnak && (
                <p className="text-gray-500 text-sm mt-1">
                  {dataAnak.nama_anak} &bull; Lahir {formatTanggal(dataAnak.tanggal_lahir)}
                </p>
              )}
            </div>

            <div className="flex items-center gap-3">
              <span className="bg-green-600 text-white text-xs font-bold px-3 py-1.5 rounded-lg shadow-sm">
                Diisi oleh Tenaga Kesehatan
              </span>
              
              {/* Show schedule info */}
              {jadwalLayananToday && jadwalLayananToday.dosis_vaksins && jadwalLayananToday.dosis_vaksins.length > 0 ? (
                <div className="flex items-center gap-2 bg-blue-50 text-blue-700 text-xs font-semibold px-3 py-1.5 rounded-lg border border-blue-200">
                  <CalendarClock size={14} />
                  <span>Jadwal Hari Ini: {jadwalLayananToday.layanan || 'Imunisasi'}</span>
                </div>
              ) : jadwalLayananToday && jadwalLayananToday.DosisVaksins && jadwalLayananToday.DosisVaksins.length > 0 ? (
                <div className="flex items-center gap-2 bg-blue-50 text-blue-700 text-xs font-semibold px-3 py-1.5 rounded-lg border border-blue-200">
                  <CalendarClock size={14} />
                  <span>Jadwal Hari Ini: {jadwalLayananToday.layanan || 'Imunisasi'}</span>
                </div>
              ) : (
                <div className="flex items-center gap-2 bg-amber-50 text-amber-700 text-xs font-semibold px-3 py-1.5 rounded-lg border border-amber-200">
                  <AlertTriangle size={14} />
                  <span>Tidak Ada Jadwal Hari Ini</span>
                </div>
              )}

              <button
                onClick={() => {
                  const hasSchedule = jadwalLayananToday && 
                    ((jadwalLayananToday.dosis_vaksins && jadwalLayananToday.dosis_vaksins.length > 0) ||
                     (jadwalLayananToday.DosisVaksins && jadwalLayananToday.DosisVaksins.length > 0));
                  
                  if (!hasSchedule) {
                    Swal.fire({
                      icon: 'warning',
                      title: 'Tidak Ada Jadwal Layanan',
                      html: 'Belum ada jadwal layanan untuk hari ini.<br/><small class="text-gray-500">Silakan buat jadwal layanan terlebih dahulu di menu <b>Jadwal Layanan</b>.</small>',
                      confirmButtonColor: '#2563eb'
                    });
                    return;
                  }
                  
                  if (availableJadwalToday.length === 0) {
                    Swal.fire({
                      icon: 'info',
                      title: 'Tidak Ada Vaksin yang Tersedia',
                      html: 'Semua vaksin dari jadwal hari ini sudah selesai diparaf,<br/>atau anak ini tidak memiliki jadwal vaksin yang sesuai dengan jadwal layanan hari ini.',
                      confirmButtonColor: '#2563eb'
                    });
                    return;
                  }
                  
                  setIsModalOpen(true);
                }}
                disabled={!jadwalLayananToday || availableJadwalToday.length === 0}
                className="flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-xl font-bold text-sm shadow-md transition-all active:scale-95 disabled:bg-gray-300 disabled:cursor-not-allowed"
              >
                <Syringe size={16} /> PARAF IMUNISASI
              </button>
            </div>
          </div>

          {/* ═══════════ TABEL IMUNISASI KIA ═══════════ */}
          <div className="bg-white shadow-xl border border-gray-300 rounded overflow-hidden mb-4">
            <div className="overflow-x-auto">
              <table className="w-full border-collapse text-[11px]">
                <thead>
                  {/* Row 1: Umur | Bulan */}
                  <tr className="bg-gray-800 text-white">
                    <th
                      rowSpan={2}
                      className="border border-gray-500 p-2 text-center font-bold text-[11px] uppercase"
                      style={{ width: '200px', minWidth: '200px' }}
                    >
                      Umur
                    </th>
                    <th
                      colSpan={MONTHS.length}
                      className="border border-gray-500 p-1.5 text-center font-bold text-[11px] uppercase tracking-wider"
                    >
                      Bulan
                    </th>
                  </tr>
                  {/* Row 2: Month numbers (0, 1, 2, ..., 23-59) */}
                  <tr className="bg-gray-700 text-white">
                    {MONTHS.map((m, i) => (
                      <th
                        key={i}
                        className="border border-gray-500 p-1 text-center font-bold text-[9px]"
                        style={{ width: '44px', minWidth: '44px' }}
                      >
                        {m}
                      </th>
                    ))}
                  </tr>
                  {/* Row 3: Jenis Vaksin | Tanggal Pemberian dan Paraf Petugas */}
                  <tr className="bg-gray-200 text-gray-800">
                    <th
                    

                       className="border border-gray-500 p-2 text-center font-bold text-[11px] uppercase"
                    >
                      Jenis Vaksin
                    </th>
                    <th
                      colSpan={MONTHS.length}
                      className="border border-gray-500 p-2 text-center font-bold text-[11px] uppercase"
                    >
                      Tanggal Pemberian dan Paraf Petugas
                    </th>
                  </tr>
                </thead>
                <tbody>
                  {Object.entries(groupedJadwal)
                    .sort(([, a], [, b]) => (a.firstId || 0) - (b.firstId || 0))
                    .map(([namaDosis, group], vIdx) => {
                    const doneItem = group.done;
                    const dosisVaksinId = group.dosisVaksinId;
                    // Calculate which month column the ✓ belongs in (uses aturan min_usia_hari)
                    const doneBulan = doneItem ? getJadwalBulan(doneItem.tanggal_estimasi, dosisVaksinId) : null;

                    return (
                      <tr
                        key={namaDosis}
                        className={`hover:bg-blue-50 transition-colors ${
                          vIdx % 2 === 0 ? 'bg-white' : 'bg-gray-50/50'
                        }`}
                      >
                        {/* Vaccine Name Cell (Jenis Vaksin) */}
                        <td className="border border-gray-300 p-2 font-semibold text-gray-700 text-[10px] leading-tight">
                          <div className="flex items-center justify-between gap-1">
                            <span>{namaDosis}</span>
                            {doneItem && (
                              <button
                                onClick={() => handleBatalParaf(doneItem.jadwal_id, namaDosis)}
                                className="flex-shrink-0 text-red-400 hover:text-red-600 hover:bg-red-50 rounded p-0.5 transition-colors"
                                title="Batalkan paraf"
                              >
                                <XCircle size={12} />
                              </button>
                            )}
                          </div>
                        </td>

                        {/* Month Cells */}
                        {MONTHS.map((m, mIdx) => {
                          const monthValue = parseInt(m);
                          const cellColor = getCellColor(dosisVaksinId, monthValue, doneBulan);
                          const cell = getCellContent(group, monthValue);

                          return (
                            <td
                              key={mIdx}
                              className={`border border-gray-300 text-center p-0.5 ${cellColor}`}
                            >
                              {cell.show === 'done' ? (
                                <div className="flex flex-col items-center justify-center py-0.5">
                                  <span className="text-green-700 font-bold text-sm leading-none">
                                    ✓
                                  </span>
                                  <span className="text-green-600 font-medium text-[7px] leading-none mt-0.5">
                                    {cell.date}
                                  </span>
                                </div>
                              ) : null}
                            </td>
                          );
                        })}
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          </div>

        

          {/* ═══════════ LEGENDA WARNA ═══════════ */}
          <div className="bg-white p-4 rounded-xl border border-gray-200 shadow-sm mb-6">
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 text-xs">
              <div className="flex items-center gap-2.5">
                <div className="w-8 h-5 bg-white border border-gray-300 rounded flex-shrink-0" />
                <span className="text-gray-700">Usia Tepat Dan Masih Diperbolehkan Pemberian Imunisasi</span>
              </div>
              
              <div className="flex items-center gap-2.5">
                <div className="w-8 h-5 rounded flex-shrink-0 border border-[#888888]" style={{ backgroundColor: '#A9A9A9' }} />
                <span className="text-gray-700">
                  Usia yang tidak diperbolehkan untuk pemberian Imunisasi
                </span>
              </div>
            </div>
          </div>

          {/* ═══════════ TABEL CATATAN IMUNISASI ═══════════ */}
          {pencatatanList.filter(p => p.is_selesai).length > 0 && (
            <div className="bg-white shadow-xl border border-gray-300 rounded-xl overflow-hidden">
              <div className="bg-gradient-to-r from-blue-600 to-blue-700 p-4 border-b border-blue-800">
                <h2 className="text-white font-bold text-lg flex items-center gap-2">
                  <Syringe size={20} />
                  Catatan Imunisasi
                </h2>
                <p className="text-blue-100 text-xs mt-1">
                  Riwayat pemberian imunisasi yang telah dilakukan
                </p>
              </div>

              <div className="overflow-x-auto">
                <table className="w-full">
                  <thead>
                    <tr className="bg-gray-100 border-b border-gray-300">
                      <th className="px-4 py-3 text-left text-xs font-bold text-gray-700 uppercase tracking-wider">
                        No
                      </th>
                      <th className="px-4 py-3 text-left text-xs font-bold text-gray-700 uppercase tracking-wider">
                        Jenis Vaksin
                      </th>
                      <th className="px-4 py-3 text-left text-xs font-bold text-gray-700 uppercase tracking-wider">
                        Tanggal Pemberian
                      </th>
                      <th className="px-4 py-3 text-left text-xs font-bold text-gray-700 uppercase tracking-wider">
                        No. Batch
                      </th>
                      <th className="px-4 py-3 text-left text-xs font-bold text-gray-700 uppercase tracking-wider">
                        Nama Bidan/Petugas
                      </th>
                      <th className="px-4 py-3 text-left text-xs font-bold text-gray-700 uppercase tracking-wider">
                        Catatan
                      </th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-200">
                    {pencatatanList
                      .filter(p => p.is_selesai)
                      .sort((a, b) => new Date(b.tanggal_pemberian) - new Date(a.tanggal_pemberian))
                      .map((pencatatan, index) => {
                        const namaDosis = pencatatan.jadwal_imunisasi_anak?.dosis_vaksin?.nama_dosis || '-';
                        const namaBidan = pencatatan.bidan_petugas?.name || 'Tidak tersedia';  // Changed from 'nama' to 'name'
                        
                        return (
                          <tr 
                            key={pencatatan.id} 
                            className="hover:bg-blue-50 transition-colors"
                          >
                            <td className="px-4 py-3 text-sm text-gray-700 font-medium">
                              {index + 1}
                            </td>
                            <td className="px-4 py-3 text-sm text-gray-900 font-semibold">
                              {namaDosis}
                            </td>
                            <td className="px-4 py-3 text-sm text-gray-700">
                              {formatTanggal(pencatatan.tanggal_pemberian)}
                            </td>
                            <td className="px-4 py-3 text-sm text-gray-700">
                              {pencatatan.nomor_batch || '-'}
                            </td>
                            <td className="px-4 py-3 text-sm text-gray-900">
                              <div className="flex items-center gap-2">
                                <div className="w-8 h-8 rounded-full bg-blue-100 flex items-center justify-center flex-shrink-0">
                                  <span className="text-blue-700 font-bold text-xs">
                                    {namaBidan.charAt(0).toUpperCase()}
                                  </span>
                                </div>
                                <span className="font-medium">{namaBidan}</span>
                              </div>
                            </td>
                            <td className="px-4 py-3 text-sm text-gray-600">
                              {pencatatan.catatan || '-'}
                            </td>
                          </tr>
                        );
                      })}
                  </tbody>
                </table>
              </div>

              {pencatatanList.filter(p => p.is_selesai).length === 0 && (
                <div className="p-8 text-center text-gray-500">
                  <Syringe size={48} className="mx-auto mb-3 text-gray-300" />
                  <p className="font-medium">Belum ada catatan imunisasi</p>
                  <p className="text-xs mt-1">Catatan akan muncul setelah melakukan paraf imunisasi</p>
                </div>
              )}
            </div>
          )}
        </div>
      </div>

      {/* ═══════════ MODAL PARAF IMUNISASI ═══════════ */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4">
          <div className="bg-white rounded-2xl w-full max-w-lg max-h-[90vh] overflow-hidden shadow-2xl border-t-4 border-blue-600 flex flex-col">
            {/* Modal Header */}
            <div className="bg-gray-800 p-4 text-white flex justify-between items-center flex-shrink-0">
              <span className="flex items-center gap-2 font-bold text-sm uppercase tracking-wider">
                <Syringe size={18} className="text-blue-400" /> Paraf Imunisasi
              </span>
              <button
                onClick={() => setIsModalOpen(false)}
                className="hover:rotate-90 transition-transform"
              >
                <X size={20} />
              </button>
            </div>

            {/* Modal Form - Scrollable */}
            <form onSubmit={handleSubmit} className="flex-1 overflow-y-auto">
              <div className="p-6 space-y-4">
                {/* Tanggal - Dropdown dari Jadwal Layanan */}
                <div>
                  <label className="text-gray-500 mb-1 block text-xs font-bold uppercase tracking-wider">
                    Tanggal Pelayanan
                  </label>
                  <div className="flex items-center gap-2 border-b-2 focus-within:border-blue-600 pb-2">
                    <Calendar size={16} className="text-gray-400" />
                    <select
                      className="w-full outline-none font-bold text-sm bg-transparent cursor-pointer"
                      value={formData.tanggal}
                      onChange={(e) => {
                        const selectedDate = e.target.value;
                        setFormData({ ...formData, tanggal: selectedDate });
                        
                        // Find jadwal for selected date and update available vaccines
                        const selectedJadwal = jadwalLayananList.find(j => {
                          const jadwalDate = j.tanggal ? new Date(j.tanggal).toISOString().split('T')[0] : '';
                          return jadwalDate === selectedDate;
                        });
                        
                        if (selectedJadwal) {
                          setJadwalLayananToday(selectedJadwal);
                          console.log('[DEBUG] Selected jadwal for date:', selectedDate, selectedJadwal);
                        }
                      }}
                      required
                    >
                      <option value="">Pilih tanggal dari jadwal layanan...</option>
                      {jadwalLayananList
                        .filter(jadwal => jadwal.tanggal) // Only jadwal with valid date
                        .map(jadwal => {
                          const tanggalFormatted = new Date(jadwal.tanggal).toISOString().split('T')[0];
                          const tanggalDisplay = new Date(jadwal.tanggal).toLocaleDateString('id-ID', {
                            weekday: 'long',
                            year: 'numeric',
                            month: 'long',
                            day: 'numeric'
                          });
                          const dosisCount = (jadwal.dosis_vaksins || jadwal.DosisVaksins || []).length;
                          
                          return (
                            <option key={jadwal.id} value={tanggalFormatted}>
                              {tanggalDisplay} - {jadwal.layanan} ({dosisCount} vaksin)
                            </option>
                          );
                        })
                      }
                    </select>
                  </div>
                  <p className="text-xs text-gray-400 mt-1">
                    📅 Pilih dari jadwal layanan yang sudah dibuat
                  </p>
                  {jadwalLayananList.length === 0 && (
                    <p className="text-xs text-amber-600 mt-2 flex items-center gap-1">
                      <AlertTriangle size={12} />
                      Belum ada jadwal layanan. Silakan buat jadwal terlebih dahulu di menu Jadwal Layanan.
                    </p>
                  )}
                </div>

                {/* Vaccine Selection */}
                <div className="bg-gray-50 p-4 rounded-xl border border-gray-200">
                  <div className="flex justify-between items-center mb-3">
                    <label className="text-gray-400 text-[10px] font-bold uppercase tracking-widest">
                      Vaksin yang Diberikan Hari Ini:
                    </label>
                    <span className="text-[10px] text-gray-500">
                      {availableJadwalToday.length} tersedia dari jadwal
                    </span>
                  </div>

                  {/* Jadwal Layanan Info */}
                  {jadwalLayananToday && (
                    <div className="mb-3 p-2 bg-blue-50 border border-blue-200 rounded-lg">
                      <p className="text-[10px] text-blue-700 font-semibold flex items-center gap-1">
                        <CalendarClock size={12} />
                        Jadwal: {jadwalLayananToday.layanan || 'Imunisasi'}
                      </p>
                      <p className="text-[9px] text-blue-600 mt-0.5">
                        {(jadwalLayananToday.dosis_vaksins || jadwalLayananToday.DosisVaksins) && 
                         (jadwalLayananToday.dosis_vaksins || jadwalLayananToday.DosisVaksins).length > 0 
                          ? (jadwalLayananToday.dosis_vaksins || jadwalLayananToday.DosisVaksins)
                              .map(dv => `${dv.Vaksin?.nama || dv.vaksin?.nama || 'Vaksin'} - ${dv.nama_dosis}`)
                              .join(', ')
                          : 'Daftar vaksin tersedia'
                        }
                      </p>
                    </div>
                  )}

                  {/* Empty State Messages */}
                  {!formData.tanggal && (
                    <div className="text-center py-8">
                      <Calendar size={32} className="text-gray-300 mx-auto mb-2" />
                      <p className="text-sm text-gray-500">Pilih tanggal pelayanan terlebih dahulu</p>
                    </div>
                  )}

                  {formData.tanggal && availableJadwalToday.length === 0 && (
                    <div className="text-center py-8">
                      <AlertTriangle size={32} className="text-amber-400 mx-auto mb-2" />
                      <p className="text-sm text-gray-600 font-medium">Tidak ada vaksin tersedia</p>
                      <p className="text-xs text-gray-500 mt-1">
                        Semua vaksin pada tanggal ini sudah diberikan atau tidak ada jadwal vaksin untuk anak ini.
                      </p>
                    </div>
                  )}

                  <div className="space-y-2 max-h-64 overflow-y-auto pr-2">
                    {availableJadwalToday.map((jadwal) => {
                      const isSelected = formData.selectedJadwalIds.includes(
                        jadwal.jadwal_id
                      );
                      const prevDoseOk = isPreviousDoseComplete(jadwal.dosis_vaksin_id);
                      const prevDoseName = !prevDoseOk ? getPreviousDoseName(jadwal.dosis_vaksin_id) : '';

                      return (
                        <div key={jadwal.jadwal_id} className="space-y-2">
                          <div
                            onClick={() => {
                              if (!prevDoseOk) {
                                Swal.fire({
                                  icon: 'warning',
                                  title: 'Belum Bisa Diberikan',
                                  html: `<b>${jadwal.nama_dosis}</b> memerlukan dosis <b>${prevDoseName}</b> diselesaikan terlebih dahulu.`,
                                  confirmButtonColor: '#2563eb'
                                });
                                return;
                              }
                              handleToggleJadwal(jadwal.jadwal_id);
                            }}
                            className={`flex items-center justify-between gap-3 p-3 rounded-lg border-2 transition-all cursor-pointer ${
                              !prevDoseOk
                                ? 'bg-gray-100 border-gray-200 text-gray-400 cursor-not-allowed opacity-70'
                                : isSelected
                                  ? 'bg-blue-600 text-white border-blue-600'
                                  : 'bg-white border-gray-100 text-gray-700 hover:border-blue-300'
                            }`}
                          >
                            <div className="flex items-center gap-3">
                              {!prevDoseOk ? (
                                <XCircle size={18} className="text-gray-400 flex-shrink-0" />
                              ) : isSelected ? (
                                <CheckSquare size={18} />
                              ) : (
                                <Square size={18} />
                              )}
                              <div className="flex flex-col">
                                <span className="text-xs font-medium">
                                  {jadwal.nama_dosis}
                                </span>
                                {!prevDoseOk && (
                                  <span className="text-[10px] text-red-500 mt-0.5">
                                    Memerlukan {prevDoseName} selesai
                                  </span>
                                )}
                              </div>
                            </div>
                            <CheckCircle2
                              size={16}
                              className={isSelected ? 'text-white' : !prevDoseOk ? 'text-gray-300' : 'text-gray-300'}
                            />
                          </div>

                          {isSelected && (
                            <div className="pl-8 pr-2">
                              <input
                                type="text"
                                placeholder="No. Batch Vaksin (opsional)"
                                className="w-full text-xs border-2 border-blue-200 rounded-lg px-3 py-2 outline-none focus:border-blue-400 bg-blue-50/30"
                                value={formData.batches[jadwal.jadwal_id] || ''}
                                onChange={(e) =>
                                  setFormData((prev) => ({
                                    ...prev,
                                    batches: {
                                      ...prev.batches,
                                      [jadwal.jadwal_id]: e.target.value,
                                    },
                                  }))
                                }
                                onClick={(e) => e.stopPropagation()}
                              />
                            </div>
                          )}
                        </div>
                      );
                    })}

                    
                  </div>
                </div>

                {/* Catatan */}
                <div>
                  <label className="text-gray-500 mb-1 block text-xs font-bold uppercase tracking-wider">
                    Catatan Umum
                  </label>
                  <textarea
                    className="w-full border-2 border-gray-200 p-2 outline-none text-sm focus:border-blue-600 rounded-lg resize-none"
                    placeholder="Catatan tambahan (opsional)..."
                    rows="2"
                    value={formData.catatan}
                    onChange={(e) =>
                      setFormData({ ...formData, catatan: e.target.value })
                    }
                  />
                </div>
              </div>

              {/* Submit Button - Fixed at bottom */}
              <div className="p-6 pt-0 border-t border-gray-100 bg-white flex-shrink-0">
                <button
                  disabled={
                    isSubmitting || formData.selectedJadwalIds.length === 0
                  }
                  type="submit"
                  className="w-full bg-blue-600 text-white py-3.5 rounded-xl hover:bg-blue-700 flex justify-center items-center gap-3 transition-all font-bold text-sm uppercase tracking-wider disabled:bg-gray-300"
                >
                  {isSubmitting ? (
                    <>
                      <RefreshCw size={18} className="animate-spin" /> MEMPROSES...
                    </>
                  ) : (
                    <>
                      <Save size={18} /> SIMPAN ({formData.selectedJadwalIds.length}) PARAF
                    </>
                  )}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </MainLayout>
  );
};

export default PelayananImunisasi;
