import React, { useState, useEffect, useCallback, useMemo } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import MainLayout from "../../components/Layout/MainLayout";
import AlertNotification from "../../components/AlertNotification";
import { neonatusService } from "../../services/Neonatus";
import {
  Scale, User, Loader2, ClipboardCheck, Stethoscope,
  ChevronLeft, ArrowLeft, Calendar, Edit3, PlusCircle, Save, Check,
  Activity, ShieldAlert, Thermometer, Clock
} from 'lucide-react';

const fallbackIds = {
  "bb": 9,
  "pb": 10,
  "lk": 12,
  "imd": 2,
  "vitamin k1": 3,
  "salep": 4,
  "salep/tetes mata": 4,
  "salep/tetes mata antibiotik": 4,
  "hb": 7,
  "imunisasi hepatitis b": 7,
  "imunisasi hb": 7,
  "menyusu": 17,
  "tali_pusat": 1,
  "perawatan tali pusat": 1,
  "tanda bahaya": 19,
  "identifikasi kuning": 22,
  "skrining_hipotiroid": 26,
  "skrining hipotiroid": 26,
  "skrining hipotiroid kongenital": 26,
  "skrining penyakit jantung bawaan kritis 24-48 jam.": 29,
  "bagian kuning": 27,
  "tripel eliminasi": 8
};

const NeonatusIndex = () => {
  const { id } = useParams();
  const navigate = useNavigate();

  const authUser = useMemo(() => {
    try {
      const storedUser = localStorage.getItem('user');
      const parsed = storedUser ? JSON.parse(storedUser) : null;
      return {
        id: parsed?.id || parsed?.user_id || 0,
        nama: parsed?.nama || parsed?.name || parsed?.username || parsed?.full_name || 'Petugas Kesehatan',
        lokasi: parsed?.lokasi || parsed?.puskesmas || 'Puskesmas',
        tenaga_kesehatan_id: parsed?.tenaga_kesehatan_id || parsed?.id || 0,
        user_id: parsed?.user_id || parsed?.id || 0,
      };
    } catch {
      return { id: 0, nama: 'Petugas Kesehatan', lokasi: 'Puskesmas', tenaga_kesehatan_id: 0, user_id: 0 };
    }
  }, []);

  const [activeTab, setActiveTab] = useState('0-6 JAM');
  const [viewMode, setViewMode] = useState('LIST'); // 'LIST' or 'FORM'
  const [tanggal, setTanggal] = useState(new Date().toISOString().split('T')[0]);
  const [pelayananList, setPelayananList] = useState([]);
  const [allRecords, setAllRecords] = useState([]); // Store all 4 periods data
  const [loading, setLoading] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [existingRecordId, setExistingRecordId] = useState(null);
  // periodeMap: maps tab label → actual periode_id from DB
  const [periodeMap, setPeriodeMap] = useState({ '0-6 JAM': 1, 'KN1': 2, 'KN2': 3, 'KN3': 4 });
  // kategori_umur_id dari DB (bayi_0_28_hari)
  const [kategoriUmurId, setKategoriUmurId] = useState(1);
  const [notification, setNotification] = useState(null);

  // Local state with human-readable keys for absolute reactivity and zero input locking
  const [formData, setFormData] = useState({
    bb: "",
    pb: "",
    lk: "",
    imd: false,
    vitk: false,
    salep: false,
    hb: false,
    menyusu: false,
    tali_pusat: false,
    tanda_bahaya: false,
    kuning: false,
    skrining_hipotiroid: false,
    jantung_bawaan: "",
    h: "Non-Reaktif",
    s: "Non-Reaktif",
    hepb: "Non-Reaktif",
    tgl_imunisasi: "",
    jam_imunisasi: "",
    batch_imunisasi: "",
    bagian_kuning: ""
  });

  // tabToPeriode is replaced by dynamic periodeMap (set below after API fetch)
  // Keep as fallback for tab key matching
  const tabLabelToPeriodeNama = {
    '0-6 JAM': '0-6 jam',
    'KN1': '6-48 jam',
    'KN2': '3-7 hari',
    'KN3': '8-28 hari'
  };

  // Dynamic lookup: uses periodeMap (populated from API)
  const tabToPeriode = periodeMap;


  // Load periode_id mapping from backend on mount
  useEffect(() => {
    const loadPeriodeMap = async () => {
      try {
        // Fetch by nama kategori agar dapat ID yang benar dari DB
        const response = await neonatusService.getPeriodeKunjungan();
        const periodes = Array.isArray(response) ? response : (response?.data || []);
        const katId = response?.kategori_umur_id || null;
        if (periodes && periodes.length > 0) {
          // Map tab label -> periode_id
          const newMap = {};
          Object.entries(tabLabelToPeriodeNama).forEach(([tabKey, periodeNama]) => {
            const found = periodes.find(p => p.nama === periodeNama);
            newMap[tabKey] = found ? found.id : periodeMap[tabKey];
          });
          console.log("✅ Periode Map dari DB:", newMap, "kategori_umur_id:", katId || periodes[0]?.kategori_umur_id);
          setPeriodeMap(newMap);
          if (katId) setKategoriUmurId(katId);
          else if (periodes[0]?.kategori_umur_id) setKategoriUmurId(periodes[0].kategori_umur_id);
        }
      } catch (err) {
        console.warn("Gagal load periode map, menggunakan fallback:", err);
      }
    };
    loadPeriodeMap();
  }, []);

  // --- LOAD ALL DATA FOR LIST ---
  const loadAllData = useCallback(async () => {
    setLoading(true);
    try {
      const res = await neonatusService.getPemeriksaanDetail(id);
      setAllRecords(Array.isArray(res) ? res : (res ? [res] : []));
    } catch (err) {
      console.error("Gagal memuat daftar pemeriksaan:", err);
    } finally {
      setLoading(false);
    }
  }, [id]);

  useEffect(() => {
    if (id && viewMode === 'LIST') loadAllData();
  }, [id, viewMode, loadAllData]);

  // --- LOAD STRUCTURE AND EXISTING DATA ON FORM OPEN ---
  useEffect(() => {
    const loadFormStructure = async () => {
      if (viewMode !== 'FORM') return;

      setLoading(true);
      setExistingRecordId(null);

      // Reset form to defaults
      setFormData({
        bb: "",
        pb: "",
        lk: "",
        imd: false,
        vitk: false,
        salep: false,
        hb: false,
        menyusu: false,
        tali_pusat: false,
        tanda_bahaya: false,
        kuning: false,
        skrining_hipotiroid: false,
        jantung_bawaan: "",
        h: "Non-Reaktif",
        s: "Non-Reaktif",
        hepb: "Non-Reaktif",
        tgl_imunisasi: new Date().toISOString().split('T')[0],
        jam_imunisasi: "08:00",
        batch_imunisasi: "",
        bagian_kuning: ""
      });

      try {
        // Load all 4 periods metadata to guarantee we have all possible jenis_pelayanan IDs
        const [p1, p2, p3, p4] = await Promise.all([
          neonatusService.getJenisPelayanan(1),
          neonatusService.getJenisPelayanan(2),
          neonatusService.getJenisPelayanan(3),
          neonatusService.getJenisPelayanan(4)
        ]);

        const mergedList = [...(p1 || []), ...(p2 || []), ...(p3 || []), ...(p4 || [])];
        const uniqueList = [];
        const seenIds = new Set();
        mergedList.forEach(item => {
          if (!seenIds.has(item.jenis_pelayanan_id)) {
            seenIds.add(item.jenis_pelayanan_id);
            uniqueList.push(item);
          }
        });
        setPelayananList(uniqueList);

        const periodeId = tabToPeriode[activeTab];
        const data = allRecords.find(r => r.periode_id === periodeId);

        if (data) {
          setExistingRecordId(data.id);
          if (data.tanggal) setTanggal(data.tanggal.split('T')[0]);

          const localData = {
            bb: "",
            pb: "",
            lk: "",
            imd: false,
            vitk: false,
            salep: false,
            hb: false,
            menyusu: false,
            tali_pusat: false,
            tanda_bahaya: false,
            kuning: false,
            skrining_hipotiroid: false,
            jantung_bawaan: "",
            h: "Non-Reaktif",
            s: "Non-Reaktif",
            hepb: "Non-Reaktif",
            tgl_imunisasi: "",
            jam_imunisasi: "",
            batch_imunisasi: "",
            bagian_kuning: ""
          };

          if (data.detail_pelayanan) {
            data.detail_pelayanan.forEach(d => {
              const item = uniqueList.find(i => i.jenis_pelayanan_id === d.jenis_pelayanan_id);
              const name = item ? item.nama?.toLowerCase().trim() :
                Object.keys(fallbackIds).find(k => fallbackIds[k] === d.jenis_pelayanan_id);
              if (!name) return;
              const isChecked = d.nilai === "1" || d.nilai === "true";

              if (name === "bb") localData.bb = d.nilai;
              else if (name === "pb") localData.pb = d.nilai;
              else if (name === "lk") localData.lk = d.nilai;
              else if (name === "imd" || name === "dini(imd)") localData.imd = isChecked;
              else if (name === "vitamin k1") localData.vitk = isChecked;
              else if (name === "salep/tetes mata antibiotik" || name.includes("salep")) localData.salep = isChecked;
              else if (name === "imunisasi hepatitis b" || name === "imunisasi hb*") {
                localData.hb = isChecked;
                if (d.keterangan) {
                  const parts = d.keterangan.split(' | ');
                  parts.forEach(p => {
                    if (p.startsWith('Tgl: ')) localData.tgl_imunisasi = p.replace('Tgl: ', '');
                    if (p.startsWith('Jam: ')) localData.jam_imunisasi = p.replace('Jam: ', '');
                    if (p.startsWith('Batch: ')) localData.batch_imunisasi = p.replace('Batch: ', '');
                  });
                }
              }
              else if (name === "menyusu") localData.menyusu = isChecked;
              else if (name === "perawatan tali pusat" || name.includes("tali pusat")) localData.tali_pusat = isChecked;
              else if (name === "tanda bahaya") localData.tanda_bahaya = isChecked;
              else if (name === "identifikasi kuning") localData.kuning = isChecked;
              else if (name === "skrining hipotiroid kongenital" || name === "skrining bbl/shk") localData.skrining_hipotiroid = isChecked;
              else if (name === "skrining penyakit jantung bawaan kritis 24-48 jam.") localData.jantung_bawaan = d.nilai;
              else if (name === "bagian kuning") localData.bagian_kuning = d.nilai;
              else if (name === "tripel eliminasi") {
                if (d.keterangan) {
                  const parts = d.keterangan.split(' | ');
                  parts.forEach(p => {
                    if (p.startsWith('H: ')) localData.h = p.replace('H: ', '');
                    if (p.startsWith('S: ')) localData.s = p.replace('S: ', '');
                    if (p.startsWith('Hep B: ')) localData.hepb = p.replace('Hep B: ', '');
                  });
                }
              }
            });
          }

          if (!localData.tgl_imunisasi) localData.tgl_imunisasi = new Date().toISOString().split('T')[0];
          if (!localData.jam_imunisasi) localData.jam_imunisasi = "08:00";

          setFormData(localData);
        }
      } catch (err) {
        console.error("Gagal memuat struktur form:", err);
      } finally {
        setLoading(false);
      }
    };

    loadFormStructure();
  }, [activeTab, viewMode, allRecords]);

  // --- SUBMIT PAYLOAD MAPPING (reimplemented) ---
  const buildRequestPayload = () => {
    const nakesId = authUser?.tenaga_kesehatan_id || authUser?.user_id || authUser?.id || 0;
    const details = [];

    const addDetail = (name, nilai, keterangan = "") => {
      const jpId = fallbackIds[name.toLowerCase().trim()];
      if (!jpId) {
        console.warn(`ID not found for ${name}`);
        return;
      }
      details.push({
        jenis_pelayanan_id: jpId,
        nilai: typeof nilai === "string" ? nilai : String(nilai),
        keterangan: keterangan
      });
    };

    // Map form fields
    addDetail("bb", formData.bb);
    addDetail("pb", formData.pb);
    addDetail("lk", formData.lk);
    addDetail("imd", formData.imd ? "1" : "0");
    addDetail("vitamin k1", formData.vitk ? "1" : "0");
    addDetail("salep", formData.salep ? "1" : "0");
    const hbKet = `Tgl: ${tanggal} | Jam: ${formData.jam_imunisasi} | Batch: ${formData.batch_imunisasi}`;
    addDetail("hb", formData.hb ? "1" : "0", hbKet);
    addDetail("menyusu", formData.menyusu ? "1" : "0");
    addDetail("tali_pusat", formData.tali_pusat ? "1" : "0");
    addDetail("tanda bahaya", formData.tanda_bahaya ? "1" : "0");
    addDetail("identifikasi kuning", formData.kuning ? "1" : "0");
    addDetail("skrining_hipotiroid", formData.skrining_hipotiroid ? "1" : "0");
    addDetail("skrining penyakit jantung bawaan kritis 24-48 jam.", formData.jantung_bawaan);
    addDetail("bagian kuning", formData.bagian_kuning);
    const tripelKet = `H: ${formData.h} | S: ${formData.s} | Hep B: ${formData.hepb}`;
    addDetail("tripel eliminasi", "1", tripelKet);

    return {
      anak_id: parseInt(id),
      tanggal: tanggal,
      periode_id: tabToPeriode[activeTab],
      kategori_umur_id: kategoriUmurId,
      lokasi: authUser.lokasi || "Puskesmas",
      tenaga_kesehatan_id: parseInt(nakesId),
      detail_pelayanan: details
    };
  };

  // Memoized requestPayload for compatibility
  const requestPayload = useMemo(() => buildRequestPayload(), [id, tanggal, activeTab, formData, authUser, fallbackIds]);

  const handleFinalSubmit = async () => {
    const todayStr = new Date().toISOString().split('T')[0];
    if (tanggal > todayStr) {
      setNotification({
        type: "error",
        message: "Tanggal pemeriksaan tidak boleh tanggal yang akan datang!"
      });
      return;
    }

    let emptyFields = [];

    if (activeTab === '0-6 JAM') {
      if (!formData.bb) emptyFields.push("Berat Badan (BB)");
      if (!formData.pb) emptyFields.push("Panjang Badan (PB)");
      if (!formData.lk) emptyFields.push("Lingkar Kepala (LK)");
      if (!formData.imd) emptyFields.push("Inisiasi Menyusu Dini (IMD)");
      if (!formData.vitk) emptyFields.push("Pemberian Vitamin K1");
      if (!formData.salep) emptyFields.push("Salep/Tetes Mata Antibiotik");
      if (!formData.hb) emptyFields.push("Imunisasi Hepatitis B (HB0)");
    } else if (activeTab === 'KN1') {
      if (!formData.bb) emptyFields.push("Berat Badan (BB)");
      if (!formData.pb) emptyFields.push("Panjang Badan (PB)");
      if (!formData.lk) emptyFields.push("Lingkar Kepala (LK)");
      if (!formData.menyusu) emptyFields.push("Bayi Menyusu Baik");
      if (!formData.tali_pusat) emptyFields.push("Perawatan Tali Pusat");
      if (!formData.vitk) emptyFields.push("Pemberian Vitamin K1");
      if (!formData.salep) emptyFields.push("Salep/Tetes Mata Antibiotik");
      if (!formData.hb) emptyFields.push("Imunisasi Hepatitis B");
    } else if (activeTab === 'KN2') {
      if (!formData.menyusu) emptyFields.push("Bayi Menyusu Baik");
      if (!formData.tali_pusat) emptyFields.push("Perawatan Tali Pusat");
      if (!formData.tanda_bahaya) emptyFields.push("Pemeriksaan Tanda Bahaya");
      if (!formData.kuning) emptyFields.push("Identifikasi Bayi Kuning");
      if (!formData.hb) emptyFields.push("Imunisasi Hepatitis B");
    } else if (activeTab === 'KN3') {
      if (!formData.menyusu) emptyFields.push("Bayi Menyusu Baik");
      if (!formData.tali_pusat) emptyFields.push("Perawatan Tali Pusat");
      if (!formData.tanda_bahaya) emptyFields.push("Pemeriksaan Tanda Bahaya");
      if (!formData.kuning) emptyFields.push("Identifikasi Bayi Kuning");
      if (!formData.bagian_kuning) emptyFields.push("Kramer Jaundice Scale (Kuning)");
    }

    if (emptyFields.length > 0) {
      setNotification({
        type: "error",
        message: `Semua data harus diisi! Mohon lengkapi data berikut: ${emptyFields.join(", ")}.`
      });
      return;
    }

    setSubmitting(true);
    try {
      if (existingRecordId) {
        await neonatusService.updatePemeriksaan(existingRecordId, requestPayload);
      } else {
        await neonatusService.savePemeriksaan(requestPayload);
      }
      setViewMode('LIST');
      await loadAllData();
      setNotification({
        type: "success",
        message: "Data pemeriksaan neonatus berhasil disimpan ke dalam sistem!"
      });
    } catch (err) {
      console.error("Gagal menyimpan neonatus:", err);
      const errMsg = err.error || err.message || (typeof err === "string" ? err : "") || "Kesalahan Server";
      setNotification({
        type: "error",
        message: "Permintaan gagal diproses. Silakan coba lagi nanti atau hubungi bantuan.",
        code: errMsg
      });
    } finally {
      setSubmitting(false);
    }
  };

  const handleEdit = (periodeName) => {
    setActiveTab(periodeName);
    setViewMode('FORM');
  };

  return (
    <MainLayout>
      <AlertNotification
        notification={notification}
        onClose={() => setNotification(null)}
        onRetry={notification?.type === "error" ? () => {
          setNotification(null);
          setViewMode('FORM');
        } : null}
      />
      <div className="max-w-6xl mx-auto pb-20 px-4 font-['Noto_Sans',_sans-serif]">
        {/* HEADER */}
        <header className="mb-8 pt-2">
          {/* Baris atas: Kembali */}
          <div className="mb-4">
            <button
              onClick={() => navigate(`/data-anak/dashboard/${id}`)}
              className="inline-flex items-center gap-2 px-4 py-2 bg-[#185FA5] hover:bg-[#185FA5]/90 text-white rounded-xl font-semibold text-sm transition-all active:scale-95 shadow-sm"
            >
              <ArrowLeft size={16} /> Kembali
            </button>
          </div>

          {/* Baris bawah: Ikon + Judul */}
          <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-4 pb-6 border-b border-slate-100">
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 bg-[#185FA5] rounded-xl flex items-center justify-center text-white shadow-md flex-shrink-0">
                <Stethoscope size={22} />
              </div>
              <div>
                <div className="flex items-center gap-3 flex-wrap">
                  <h1 className="text-xl font-bold text-slate-800">Pemeriksaan Neonatus</h1>
                  {existingRecordId ? (
                    <span className="inline-flex items-center gap-1.5 px-3 py-1 bg-amber-50 text-amber-700 text-xs font-semibold rounded-full border border-amber-200">
                      <Edit3 size={11} /> Mode Edit — ubah data yang sudah tersimpan
                    </span>
                  ) : (
                    <span className="inline-flex items-center gap-1.5 px-3 py-1 bg-blue-50 text-[#185FA5] text-xs font-semibold rounded-full border border-blue-200">
                      <PlusCircle size={11} /> Mode Baru — isi data pemeriksaan baru
                    </span>
                  )}
                </div>
                <p className="text-sm text-slate-500 mt-0.5">
                  Petugas: <span className="font-semibold text-slate-700">{authUser.nama}</span>
                </p>
              </div>
            </div>
          </div>
        </header>

        {loading ? (
          <div className="flex flex-col items-center justify-center py-24 text-center">
            <Loader2 className="w-10 h-10 text-[#185FA5] animate-spin mb-3" />
            <p className="text-sm font-medium text-slate-500">Memuat data pemeriksaan...</p>
          </div>
        ) : viewMode === 'LIST' ? (
          <div className="bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden">
            <table className="w-full text-left">
              <thead>
                <tr className="bg-slate-100 border-b border-slate-200">
                  <th className="p-5 pl-8 text-xs font-semibold text-slate-600">Periode Pemeriksaan</th>
                  <th className="p-5 text-xs font-semibold text-slate-600">Tanggal</th>
                  <th className="p-5 text-xs font-semibold text-slate-600">Status</th>
                  <th className="p-5 text-xs font-semibold text-slate-600">Aksi</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {Object.keys(tabToPeriode).map(key => {
                  const record = allRecords.find(r => r.periode_id === tabToPeriode[key]);
                  return (
                    <tr key={key} className="hover:bg-slate-50/50 transition-colors">
                      <td className="p-5 pl-8">
                        <p className="text-sm font-semibold text-slate-800">
                          {key === '0-6 JAM' ? '0 - 6 JAM' : key === 'KN1' ? 'KN 1' : key === 'KN2' ? 'KN 2' : 'KN 3'}
                        </p>
                        <p className="text-xs text-slate-500 mt-0.5">
                          Rentang Usia: {key === '0-6 JAM' ? '0-6 jam' : key === 'KN1' ? '6-48 jam' : key === 'KN2' ? '3-7 hari' : '8-24 hari'} • Pelayanan Kesehatan Bayi Baru Lahir
                        </p>
                      </td>
                      <td className="p-5 text-sm text-slate-700">
                        {record?.tanggal
                          ? new Date(record.tanggal).toLocaleDateString('id-ID', { day: 'numeric', month: 'long', year: 'numeric' })
                          : <span className="text-slate-400">-</span>}
                      </td>
                      <td className="p-5">
                        {record ? (
                          <span className="inline-flex items-center px-3 py-1 bg-green-50 text-green-700 text-xs font-semibold rounded-full border border-green-200">
                            Lengkap
                          </span>
                        ) : (
                          <span className="inline-flex items-center px-3 py-1 bg-slate-100 text-slate-500 text-xs font-semibold rounded-full border border-slate-200">
                            Belum Diisi
                          </span>
                        )}
                      </td>
                      <td className="p-5">
                        <button
                          onClick={() => handleEdit(key)}
                          className="inline-flex items-center px-4 py-2 bg-[#185FA5] hover:bg-[#185FA5]/90 text-white text-xs font-semibold rounded-xl transition-all active:scale-95 shadow-sm"
                        >
                          {record ? 'Edit Data' : 'Isi Form'}
                        </button>
                      </td>
                    </tr>
                  )
                })}
              </tbody>
            </table>
          </div>
        ) : (
          <div className="space-y-6">
            {/* Form Nav & Top Info */}
            <div className="flex items-center justify-between bg-white p-5 rounded-2xl border border-slate-100 shadow-sm">
              <div>
                <h3 className="text-sm font-semibold text-slate-800">
                  Input Data Kunjungan: {
                    activeTab === '0-6 JAM' ? '0-6 JAM (0-6 jam)' :
                      activeTab === 'KN1' ? 'KN 1 (6-48 jam)' :
                        activeTab === 'KN2' ? 'KN 2 (3-7 hari)' :
                          'KN 3 (8-24 hari)'
                  }
                </h3>
                <p className="text-xs text-slate-500 mt-0.5">Lengkapi data rekam medis bayi di bawah ini</p>
              </div>
              <div>
                <label className="block text-xs font-semibold text-slate-500 mb-1">Tanggal Pemeriksaan</label>
                <input
                  type="date"
                  value={tanggal}
                  onChange={(e) => setTanggal(e.target.value)}
                  max={new Date().toISOString().split('T')[0]}
                  className="px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-sm text-slate-700 outline-none focus:ring-2 focus:ring-[#185FA5]/20 focus:border-[#185FA5]"
                />
              </div>
            </div>

            {/* Form Columns */}
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">

              {/* SECTION A: Kondisi & Antropometri */}
              <div className="bg-white p-6 rounded-2xl border border-slate-100 shadow-sm space-y-5">
                <h3 className="text-sm font-semibold text-[#185FA5] flex items-center gap-2 border-b border-slate-100 pb-3">
                  <Scale size={16} /> Kondisi &amp; Antropometri
                </h3>

                {(activeTab === '0-6 JAM' || activeTab === 'KN1') ? (
                  <div className="space-y-4">
                    {/* BB Input */}
                    <div className="w-full">
                      <label className="block text-xs font-semibold text-slate-600 mb-1.5">Berat Badan (BB)</label>
                      <div className="relative">
                        <input
                          type="number"
                          step="0.1"
                          className="w-full bg-slate-50 border border-slate-200 rounded-xl py-2.5 px-4 pr-16 focus:ring-2 focus:ring-[#185FA5]/20 focus:border-[#185FA5] focus:bg-white outline-none transition-all text-sm text-slate-700"
                          placeholder="Cth: 3000.0"
                          value={formData.bb}
                          onChange={(e) => setFormData({ ...formData, bb: e.target.value })}
                        />
                        <span className="absolute right-4 top-1/2 -translate-y-1/2 text-slate-400 text-xs font-semibold pointer-events-none">
                          gram
                        </span>
                      </div>
                    </div>

                    {/* PB Input */}
                    <div className="w-full">
                      <label className="block text-xs font-semibold text-slate-600 mb-1.5">Panjang Badan (PB)</label>
                      <div className="relative">
                        <input
                          type="number"
                          step="0.1"
                          className="w-full bg-slate-50 border border-slate-200 rounded-xl py-2.5 px-4 pr-12 focus:ring-2 focus:ring-[#185FA5]/20 focus:border-[#185FA5] focus:bg-white outline-none transition-all text-sm text-slate-700"
                          placeholder="Cth: 48.0"
                          value={formData.pb}
                          onChange={(e) => setFormData({ ...formData, pb: e.target.value })}
                        />
                        <span className="absolute right-4 top-1/2 -translate-y-1/2 text-slate-400 text-xs font-semibold pointer-events-none">
                          cm
                        </span>
                      </div>
                    </div>

                    {/* LK Input */}
                    <div className="w-full">
                      <label className="block text-xs font-semibold text-slate-600 mb-1.5">Lingkar Kepala (LK)</label>
                      <div className="relative">
                        <input
                          type="number"
                          step="0.1"
                          className="w-full bg-slate-50 border border-slate-200 rounded-xl py-2.5 px-4 pr-12 focus:ring-2 focus:ring-[#185FA5]/20 focus:border-[#185FA5] focus:bg-white outline-none transition-all text-sm text-slate-700"
                          placeholder="Cth: 33.0"
                          value={formData.lk}
                          onChange={(e) => setFormData({ ...formData, lk: e.target.value })}
                        />
                        <span className="absolute right-4 top-1/2 -translate-y-1/2 text-slate-400 text-xs font-semibold pointer-events-none">
                          cm
                        </span>
                      </div>
                    </div>
                  </div>
                ) : (
                  <div className="py-8 text-center text-slate-300 font-bold text-xs uppercase tracking-widest flex flex-col items-center gap-3">
                    <Thermometer size={32} />
                    <span>Tidak ada input BB/PB/LK untuk periode ini</span>
                  </div>
                )}
              </div>

              {/* SECTION B: Pelayanan & Tindakan Medis */}
              <div className="bg-white p-6 rounded-2xl border border-slate-100 shadow-sm space-y-5">
                <h3 className="text-sm font-semibold text-green-600 flex items-center gap-2 border-b border-slate-100 pb-3">
                  <ClipboardCheck size={16} /> Pelayanan &amp; Tindakan Medis
                </h3>

                {activeTab === '0-6 JAM' && (
                  <div className="space-y-4">
                    {/* IMD */}
                    <button
                      type="button"
                      onClick={() => setFormData({ ...formData, imd: !formData.imd })}
                      className={`flex items-center gap-3 p-3.5 border rounded-2xl transition-all w-full text-left text-sm group ${formData.imd ? "bg-green-50 border-green-500 text-green-700 font-bold" : "border-slate-200 bg-white text-slate-500 hover:bg-slate-50"
                        }`}
                    >
                      <div className={`w-5 h-5 rounded-lg flex items-center justify-center border transition-colors ${formData.imd ? "bg-green-600 border-green-600 text-white" : "bg-white border-slate-300"}`}>
                        {formData.imd && <Check size={12} strokeWidth={4} />}
                      </div>
                      <span>Inisiasi Menyusu Dini (IMD)</span>
                    </button>

                    {/* Vitamin K1 */}
                    <button
                      type="button"
                      onClick={() => setFormData({ ...formData, vitk: !formData.vitk })}
                      className={`flex items-center gap-3 p-3.5 border rounded-2xl transition-all w-full text-left text-sm group ${formData.vitk ? "bg-green-50 border-green-500 text-green-700 font-bold" : "border-slate-200 bg-white text-slate-500 hover:bg-slate-50"
                        }`}
                    >
                      <div className={`w-5 h-5 rounded-lg flex items-center justify-center border transition-colors ${formData.vitk ? "bg-green-600 border-green-600 text-white" : "bg-white border-slate-300"}`}>
                        {formData.vitk && <Check size={12} strokeWidth={4} />}
                      </div>
                      <span>Pemberian Vitamin K1</span>
                    </button>

                    {/* Salep Mata */}
                    <button
                      type="button"
                      onClick={() => setFormData({ ...formData, salep: !formData.salep })}
                      className={`flex items-center gap-3 p-3.5 border rounded-2xl transition-all w-full text-left text-sm group ${formData.salep ? "bg-green-50 border-green-500 text-green-700 font-bold" : "border-slate-200 bg-white text-slate-500 hover:bg-slate-50"
                        }`}
                    >
                      <div className={`w-5 h-5 rounded-lg flex items-center justify-center border transition-colors ${formData.salep ? "bg-green-600 border-green-600 text-white" : "bg-white border-slate-300"}`}>
                        {formData.salep && <Check size={12} strokeWidth={4} />}
                      </div>
                      <span>Salep/Tetes Mata Antibiotik</span>
                    </button>

                    {/* Imunisasi Hepatitis B */}
                    <button
                      type="button"
                      onClick={() => setFormData({ ...formData, hb: !formData.hb })}
                      className={`flex items-center gap-3 p-3.5 border rounded-2xl transition-all w-full text-left text-sm group ${formData.hb ? "bg-green-50 border-green-500 text-green-700 font-bold" : "border-slate-200 bg-white text-slate-500 hover:bg-slate-50"
                        }`}
                    >
                      <div className={`w-5 h-5 rounded-lg flex items-center justify-center border transition-colors ${formData.hb ? "bg-green-600 border-green-600 text-white" : "bg-white border-slate-300"}`}>
                        {formData.hb && <Check size={12} strokeWidth={4} />}
                      </div>
                      <span>Imunisasi Hepatitis B (HB0)</span>
                    </button>
                  </div>
                )}

                {activeTab === 'KN1' && (
                  <div className="space-y-4">
                    {/* Menyusu */}
                    <button
                      type="button"
                      onClick={() => setFormData({ ...formData, menyusu: !formData.menyusu })}
                      className={`flex items-center gap-3 p-3.5 border rounded-2xl transition-all w-full text-left text-sm group ${formData.menyusu ? "bg-green-50 border-green-500 text-green-700 font-bold" : "border-slate-200 bg-white text-slate-500 hover:bg-slate-50"
                        }`}
                    >
                      <div className={`w-5 h-5 rounded-lg flex items-center justify-center border transition-colors ${formData.menyusu ? "bg-green-600 border-green-600 text-white" : "bg-white border-slate-300"}`}>
                        {formData.menyusu && <Check size={12} strokeWidth={4} />}
                      </div>
                      <span>Bayi Menyusu Baik</span>
                    </button>

                    {/* Tali Pusat */}
                    <button
                      type="button"
                      onClick={() => setFormData({ ...formData, tali_pusat: !formData.tali_pusat })}
                      className={`flex items-center gap-3 p-3.5 border rounded-2xl transition-all w-full text-left text-sm group ${formData.tali_pusat ? "bg-green-50 border-green-500 text-green-700 font-bold" : "border-slate-200 bg-white text-slate-500 hover:bg-slate-50"
                        }`}
                    >
                      <div className={`w-5 h-5 rounded-lg flex items-center justify-center border transition-colors ${formData.tali_pusat ? "bg-green-600 border-green-600 text-white" : "bg-white border-slate-300"}`}>
                        {formData.tali_pusat && <Check size={12} strokeWidth={4} />}
                      </div>
                      <span>Perawatan Tali Pusat</span>
                    </button>

                    {/* Vitamin K1* */}
                    <button
                      type="button"
                      onClick={() => setFormData({ ...formData, vitk: !formData.vitk })}
                      className={`flex items-center gap-3 p-3.5 border rounded-2xl transition-all w-full text-left text-sm group ${formData.vitk ? "bg-green-50 border-green-500 text-green-700 font-bold" : "border-slate-200 bg-white text-slate-500 hover:bg-slate-50"
                        }`}
                    >
                      <div className={`w-5 h-5 rounded-lg flex items-center justify-center border transition-colors ${formData.vitk ? "bg-green-600 border-green-600 text-white" : "bg-white border-slate-300"}`}>
                        {formData.vitk && <Check size={12} strokeWidth={4} />}
                      </div>
                      <span>Pemberian Vitamin K1*</span>
                    </button>

                    {/* Salep Mata* */}
                    <button
                      type="button"
                      onClick={() => setFormData({ ...formData, salep: !formData.salep })}
                      className={`flex items-center gap-3 p-3.5 border rounded-2xl transition-all w-full text-left text-sm group ${formData.salep ? "bg-green-50 border-green-500 text-green-700 font-bold" : "border-slate-200 bg-white text-slate-500 hover:bg-slate-50"
                        }`}
                    >
                      <div className={`w-5 h-5 rounded-lg flex items-center justify-center border transition-colors ${formData.salep ? "bg-green-600 border-green-600 text-white" : "bg-white border-slate-300"}`}>
                        {formData.salep && <Check size={12} strokeWidth={4} />}
                      </div>
                      <span>Salep/Tetes Mata Antibiotik*</span>
                    </button>

                    {/* Imunisasi Hepatitis B* */}
                    <button
                      type="button"
                      onClick={() => setFormData({ ...formData, hb: !formData.hb })}
                      className={`flex items-center gap-3 p-3.5 border rounded-2xl transition-all w-full text-left text-sm group ${formData.hb ? "bg-green-50 border-green-500 text-green-700 font-bold" : "border-slate-200 bg-white text-slate-500 hover:bg-slate-50"
                        }`}
                    >
                      <div className={`w-5 h-5 rounded-lg flex items-center justify-center border transition-colors ${formData.hb ? "bg-green-600 border-green-600 text-white" : "bg-white border-slate-300"}`}>
                        {formData.hb && <Check size={12} strokeWidth={4} />}
                      </div>
                      <span>Imunisasi Hepatitis B (HB0)*</span>
                    </button>

                    {/* Skrining Hipotiroid */}
                    <button
                      type="button"
                      onClick={() => setFormData({ ...formData, skrining_hipotiroid: !formData.skrining_hipotiroid })}
                      className={`flex items-center gap-3 p-3.5 border rounded-2xl transition-all w-full text-left text-sm group ${formData.skrining_hipotiroid ? "bg-green-50 border-green-500 text-green-700 font-bold" : "border-slate-200 bg-white text-slate-500 hover:bg-slate-50"
                        }`}
                    >
                      <div className={`w-5 h-5 rounded-lg flex items-center justify-center border transition-colors ${formData.skrining_hipotiroid ? "bg-green-600 border-green-600 text-white" : "bg-white border-slate-300"}`}>
                        {formData.skrining_hipotiroid && <Check size={12} strokeWidth={4} />}
                      </div>
                      <span>Skrining Hipotiroid Kongenital (Opsional)</span>
                    </button>

                    <div className="pt-2 border-t border-slate-50">
                      <label className="block text-xs font-semibold text-slate-600 mb-1.5">Skrining Jantung Bawaan Kritis (Hasil) (Opsional)</label>
                      <input
                        type="text"
                        placeholder="Contoh: Normal / Dirujuk"
                        className="w-full bg-slate-50 border border-slate-200 rounded-xl py-3 px-4 text-xs font-bold text-slate-700 outline-none focus:ring-2 focus:ring-blue-500/10 focus:border-blue-500"
                        value={formData.jantung_bawaan}
                        onChange={(e) => setFormData({ ...formData, jantung_bawaan: e.target.value })}
                      />
                    </div>
                  </div>
                )}

                {activeTab === 'KN2' && (
                  <div className="space-y-4">
                    {/* Menyusu */}
                    <button
                      type="button"
                      onClick={() => setFormData({ ...formData, menyusu: !formData.menyusu })}
                      className={`flex items-center gap-3 p-3.5 border rounded-2xl transition-all w-full text-left text-sm group ${formData.menyusu ? "bg-green-50 border-green-500 text-green-700 font-bold" : "border-slate-200 bg-white text-slate-500 hover:bg-slate-50"
                        }`}
                    >
                      <div className={`w-5 h-5 rounded-lg flex items-center justify-center border transition-colors ${formData.menyusu ? "bg-green-600 border-green-600 text-white" : "bg-white border-slate-300"}`}>
                        {formData.menyusu && <Check size={12} strokeWidth={4} />}
                      </div>
                      <span>Bayi Menyusu Baik</span>
                    </button>

                    {/* Tali Pusat */}
                    <button
                      type="button"
                      onClick={() => setFormData({ ...formData, tali_pusat: !formData.tali_pusat })}
                      className={`flex items-center gap-3 p-3.5 border rounded-2xl transition-all w-full text-left text-sm group ${formData.tali_pusat ? "bg-green-50 border-green-500 text-green-700 font-bold" : "border-slate-200 bg-white text-slate-500 hover:bg-slate-50"
                        }`}
                    >
                      <div className={`w-5 h-5 rounded-lg flex items-center justify-center border transition-colors ${formData.tali_pusat ? "bg-green-600 border-green-600 text-white" : "bg-white border-slate-300"}`}>
                        {formData.tali_pusat && <Check size={12} strokeWidth={4} />}
                      </div>
                      <span>Perawatan Tali Pusat</span>
                    </button>

                    {/* Tanda Bahaya */}
                    <button
                      type="button"
                      onClick={() => setFormData({ ...formData, tanda_bahaya: !formData.tanda_bahaya })}
                      className={`flex items-center gap-3 p-3.5 border rounded-2xl transition-all w-full text-left text-sm group ${formData.tanda_bahaya ? "bg-green-50 border-green-500 text-green-700 font-bold" : "border-slate-200 bg-white text-slate-500 hover:bg-slate-50"
                        }`}
                    >
                      <div className={`w-5 h-5 rounded-lg flex items-center justify-center border transition-colors ${formData.tanda_bahaya ? "bg-green-600 border-green-600 text-white" : "bg-white border-slate-300"}`}>
                        {formData.tanda_bahaya && <Check size={12} strokeWidth={4} />}
                      </div>
                      <span>Pemeriksaan Tanda Bahaya</span>
                    </button>

                    {/* Identifikasi Kuning */}
                    <button
                      type="button"
                      onClick={() => setFormData({ ...formData, kuning: !formData.kuning })}
                      className={`flex items-center gap-3 p-3.5 border rounded-2xl transition-all w-full text-left text-sm group ${formData.kuning ? "bg-green-50 border-green-500 text-green-700 font-bold" : "border-slate-200 bg-white text-slate-500 hover:bg-slate-50"
                        }`}
                    >
                      <div className={`w-5 h-5 rounded-lg flex items-center justify-center border transition-colors ${formData.kuning ? "bg-green-600 border-green-600 text-white" : "bg-white border-slate-300"}`}>
                        {formData.kuning && <Check size={12} strokeWidth={4} />}
                      </div>
                      <span>Identifikasi Bayi Kuning</span>
                    </button>

                    {/* Imunisasi HB* */}
                    <button
                      type="button"
                      onClick={() => setFormData({ ...formData, hb: !formData.hb })}
                      className={`flex items-center gap-3 p-3.5 border rounded-2xl transition-all w-full text-left text-sm group ${formData.hb ? "bg-green-50 border-green-500 text-green-700 font-bold" : "border-slate-200 bg-white text-slate-500 hover:bg-slate-50"
                        }`}
                    >
                      <div className={`w-5 h-5 rounded-lg flex items-center justify-center border transition-colors ${formData.hb ? "bg-green-600 border-green-600 text-white" : "bg-white border-slate-300"}`}>
                        {formData.hb && <Check size={12} strokeWidth={4} />}
                      </div>
                      <span>Imunisasi Hepatitis B*</span>
                    </button>

                    {/* Skrining Hipotiroid (bila belum) */}
                    <button
                      type="button"
                      onClick={() => setFormData({ ...formData, skrining_hipotiroid: !formData.skrining_hipotiroid })}
                      className={`flex items-center gap-3 p-3.5 border rounded-2xl transition-all w-full text-left text-sm group ${formData.skrining_hipotiroid ? "bg-green-50 border-green-500 text-green-700 font-bold" : "border-slate-200 bg-white text-slate-500 hover:bg-slate-50"
                        }`}
                    >
                      <div className={`w-5 h-5 rounded-lg flex items-center justify-center border transition-colors ${formData.skrining_hipotiroid ? "bg-green-600 border-green-600 text-white" : "bg-white border-slate-300"}`}>
                        {formData.skrining_hipotiroid && <Check size={12} strokeWidth={4} />}
                      </div>
                      <span>Skrining Hipotiroid Kongenital (Bila belum) (Opsional)</span>
                    </button>
                  </div>
                )}

                {activeTab === 'KN3' && (
                  <div className="space-y-4">
                    {/* Menyusu */}
                    <button
                      type="button"
                      onClick={() => setFormData({ ...formData, menyusu: !formData.menyusu })}
                      className={`flex items-center gap-3 p-3.5 border rounded-2xl transition-all w-full text-left text-sm group ${formData.menyusu ? "bg-green-50 border-green-500 text-green-700 font-bold" : "border-slate-200 bg-white text-slate-500 hover:bg-slate-50"
                        }`}
                    >
                      <div className={`w-5 h-5 rounded-lg flex items-center justify-center border transition-colors ${formData.menyusu ? "bg-green-600 border-green-600 text-white" : "bg-white border-slate-300"}`}>
                        {formData.menyusu && <Check size={12} strokeWidth={4} />}
                      </div>
                      <span>Bayi Menyusu Baik</span>
                    </button>

                    {/* Tali Pusat */}
                    <button
                      type="button"
                      onClick={() => setFormData({ ...formData, tali_pusat: !formData.tali_pusat })}
                      className={`flex items-center gap-3 p-3.5 border rounded-2xl transition-all w-full text-left text-sm group ${formData.tali_pusat ? "bg-green-50 border-green-500 text-green-700 font-bold" : "border-slate-200 bg-white text-slate-500 hover:bg-slate-50"
                        }`}
                    >
                      <div className={`w-5 h-5 rounded-lg flex items-center justify-center border transition-colors ${formData.tali_pusat ? "bg-green-600 border-green-600 text-white" : "bg-white border-slate-300"}`}>
                        {formData.tali_pusat && <Check size={12} strokeWidth={4} />}
                      </div>
                      <span>Perawatan Tali Pusat</span>
                    </button>

                    {/* Tanda Bahaya */}
                    <button
                      type="button"
                      onClick={() => setFormData({ ...formData, tanda_bahaya: !formData.tanda_bahaya })}
                      className={`flex items-center gap-3 p-3.5 border rounded-2xl transition-all w-full text-left text-sm group ${formData.tanda_bahaya ? "bg-green-50 border-green-500 text-green-700 font-bold" : "border-slate-200 bg-white text-slate-500 hover:bg-slate-50"
                        }`}
                    >
                      <div className={`w-5 h-5 rounded-lg flex items-center justify-center border transition-colors ${formData.tanda_bahaya ? "bg-green-600 border-green-600 text-white" : "bg-white border-slate-300"}`}>
                        {formData.tanda_bahaya && <Check size={12} strokeWidth={4} />}
                      </div>
                      <span>Pemeriksaan Tanda Bahaya</span>
                    </button>

                    {/* Identifikasi Kuning */}
                    <button
                      type="button"
                      onClick={() => setFormData({ ...formData, kuning: !formData.kuning })}
                      className={`flex items-center gap-3 p-3.5 border rounded-2xl transition-all w-full text-left text-sm group ${formData.kuning ? "bg-green-50 border-green-500 text-green-700 font-bold" : "border-slate-200 bg-white text-slate-500 hover:bg-slate-50"
                        }`}
                    >
                      <div className={`w-5 h-5 rounded-lg flex items-center justify-center border transition-colors ${formData.kuning ? "bg-green-600 border-green-600 text-white" : "bg-white border-slate-300"}`}>
                        {formData.kuning && <Check size={12} strokeWidth={4} />}
                      </div>
                      <span>Identifikasi Bayi Kuning</span>
                    </button>

                    {/* Skrining Hipotiroid */}
                    <button
                      type="button"
                      onClick={() => setFormData({ ...formData, skrining_hipotiroid: !formData.skrining_hipotiroid })}
                      className={`flex items-center gap-3 p-3.5 border rounded-2xl transition-all w-full text-left text-sm group ${formData.skrining_hipotiroid ? "bg-green-50 border-green-500 text-green-700 font-bold" : "border-slate-200 bg-white text-slate-500 hover:bg-slate-50"
                        }`}
                    >
                      <div className={`w-5 h-5 rounded-lg flex items-center justify-center border transition-colors ${formData.skrining_hipotiroid ? "bg-green-600 border-green-600 text-white" : "bg-white border-slate-300"}`}>
                        {formData.skrining_hipotiroid && <Check size={12} strokeWidth={4} />}
                      </div>
                      <span>Skrining Hipotiroid s.d 14 Hari (Bila belum) (Opsional)</span>
                    </button>
                  </div>
                )}
              </div>

              {/* SECTION C: Metadata Imunisasi & Tripel Eliminasi */}
              <div className="space-y-6">

                {/* Batch / Tgl Imunisasi Card */}
                {activeTab !== 'KN3' && (
                  <div className="bg-white p-6 rounded-2xl border border-slate-100 shadow-sm space-y-4">
                    <h3 className="text-sm font-semibold text-slate-700 flex items-center gap-2 border-b border-slate-100 pb-3">
                      <Clock size={16} /> Log Tindakan / Imunisasi
                    </h3>
                    <div className="grid grid-cols-2 gap-3">
                      <div>
                        <label className="block text-xs font-semibold text-slate-600 mb-1.5">Jam (HH:MM)</label>
                        <input
                          type="text"
                          inputMode="numeric"
                          maxLength={5}
                          placeholder="Cth: 08:30"
                          className="w-full bg-slate-50 border border-slate-200 rounded-xl py-2.5 px-3 text-sm text-slate-700 outline-none focus:ring-2 focus:ring-[#185FA5]/20 focus:border-[#185FA5]"
                          value={formData.jam_imunisasi}
                          onChange={(e) => {
                            let val = e.target.value.replace(/[^0-9:]/g, '');
                            if (val.length === 2 && !val.includes(':')) val = val + ':';
                            setFormData({ ...formData, jam_imunisasi: val });
                          }}
                        />
                      </div>
                      <div>
                        <label className="block text-xs font-semibold text-slate-600 mb-1.5">No. Batch (Opsional)</label>
                        <input
                          type="text"
                          placeholder="Cth: BC-2026-001"
                          className="w-full bg-slate-50 border border-slate-200 rounded-xl py-2.5 px-3 text-sm text-slate-700 outline-none focus:ring-2 focus:ring-[#185FA5]/20 focus:border-[#185FA5]"
                          value={formData.batch_imunisasi}
                          onChange={(e) => setFormData({ ...formData, batch_imunisasi: e.target.value })}
                        />
                      </div>
                    </div>
                  </div>
                )}

                {/* Kramer Visual Scale for KN3 only */}
                {activeTab === 'KN3' && (
                  <div className="bg-white p-6 rounded-2xl border border-slate-100 shadow-sm space-y-4">
                    <h3 className="text-sm font-semibold text-amber-600 flex items-center gap-2 border-b border-slate-100 pb-3">
                      <Stethoscope size={16} /> Kramer Jaundice Scale (Kuning)
                    </h3>

                    <div className="grid grid-cols-5 gap-2">
                      {[1, 2, 3, 4, 5].map(num => {
                        const isSel = formData.bagian_kuning === num.toString();
                        return (
                          <button
                            key={num}
                            type="button"
                            onClick={() => setFormData({ ...formData, bagian_kuning: isSel ? "" : num.toString() })}
                            className={`py-3.5 rounded-xl font-black text-sm border transition-all flex flex-col items-center justify-center ${isSel
                              ? 'bg-amber-500 border-amber-600 text-white shadow-md shadow-amber-100 scale-105'
                              : 'bg-slate-50 border-slate-100 text-slate-400 hover:bg-slate-100'
                              }`}
                          >
                            <span>{num}</span>
                          </button>
                        );
                      })}
                    </div>
                    <div className="p-3 bg-amber-50 rounded-2xl border border-amber-100 text-[10px] text-amber-800 leading-relaxed font-bold">
                      ℹ️ <span className="font-extrabold">Derajat Kramer:</span> 1 (Kepala-Leher), 2 (Dada-Pusat), 3 (Pusat-Paha), 4 (Lengan-Tungkai), 5 (Tangan-Kaki).
                    </div>
                  </div>
                )}

                {/* Tripel Eliminasi Card */}
                <div className="bg-white p-6 rounded-2xl border border-slate-100 shadow-sm space-y-4">
                  <h3 className="text-sm font-semibold text-red-600 flex items-center gap-2 border-b border-slate-100 pb-3">
                    <ShieldAlert size={16} /> Tripel Eliminasi
                  </h3>

                  <div className="space-y-3">
                    {[
                      { key: 'h', label: 'HIV (H)' },
                      { key: 's', label: 'Sifilis (S)' },
                      { key: 'hepb', label: 'Hepatitis B (Hep B)' }
                    ].map(item => (
                      <div key={item.key} className="flex items-center justify-between gap-4 p-2 bg-slate-50 rounded-xl border border-slate-100">
                        <span className="text-xs font-semibold text-slate-700">{item.label}</span>
                        <div className="flex gap-1 bg-slate-200 p-0.5 rounded-lg">
                          {['Non-Reaktif', 'Reaktif'].map(opt => {
                            const isSel = formData[item.key] === opt;
                            return (
                              <button
                                key={opt}
                                type="button"
                                onClick={() => setFormData({ ...formData, [item.key]: opt })}
                                className={`px-3 py-1 rounded-md text-xs font-semibold transition-all ${isSel
                                  ? opt === 'Reaktif' ? 'bg-red-600 text-white shadow-sm' : 'bg-blue-600 text-white shadow-sm'
                                  : 'text-slate-400 hover:text-slate-600'
                                  }`}
                              >
                                {opt === 'Non-Reaktif' ? 'NR' : 'R'}
                              </button>
                            );
                          })}
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              </div>

            </div>

            {/* Bottom Actions */}
            <div className="flex items-center justify-end gap-4 pt-6 border-t border-slate-100">
              <button
                onClick={() => setViewMode('LIST')}
                className="px-4 py-2 text-sm font-semibold text-slate-500 hover:text-slate-700 border border-slate-200 rounded-xl hover:bg-slate-50 transition-colors"
              >
                Batal
              </button>
              <button
                onClick={handleFinalSubmit}
                disabled={submitting}
                className="inline-flex items-center gap-2 px-6 py-2.5 bg-[#185FA5] hover:bg-[#185FA5]/90 text-white text-sm font-semibold rounded-xl transition-all active:scale-95 disabled:opacity-50 shadow-sm"
              >
                {submitting ? (
                  <Loader2 className="animate-spin" size={16} />
                ) : (
                  <Save size={16} />
                )}
                <span>{existingRecordId ? 'Simpan Perubahan' : 'Simpan Data'}</span>
              </button>
            </div>
          </div>
        )}

      </div>
    </MainLayout>
  );
};

export default NeonatusIndex;