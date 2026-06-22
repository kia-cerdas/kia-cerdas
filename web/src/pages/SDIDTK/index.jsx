import React, { useState, useEffect } from 'react';
import { Plus, Save, Loader2, ArrowLeft } from 'lucide-react';
import { useParams, useNavigate } from 'react-router-dom';
import MainLayout from "../../components/Layout/MainLayout";
import AlertNotification from "../../components/AlertNotification";
import { getCurrentUser } from '../../services/auth';
import { sdidtkService } from '../../services/SDIDTk';
import { getAnakById } from '../../services/Anak';

const FormSDIDTK = () => {
  const { id: idAnakParam } = useParams();
  const idAnak = idAnakParam || 1;
  const navigate = useNavigate();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [dataList, setDataList] = useState([]);
  const [userLogin, setUserLogin] = useState(null);
  const [notification, setNotification] = useState(null);
  const [anakData, setAnakData] = useState(null);

  const [formData, setFormData] = useState({
    bulan_ke: "",
    tanggal: new Date().toISOString().split('T')[0],
    bb_u: "N", bb_tb: "GN", tb_u: "N", lk_u: "N", lila: "N",
    kpsp: "Ds", tdd: "N", tdl: "N",
    kmpe: "N", m_chat_revised: "N", actrs: "N",
    tindakan: "", kunjungan_ulang: ""
  });

  const calculateAgeInMonths = (birthDateString) => {
    if (!birthDateString) return 1;
    const birth = new Date(birthDateString);
    const now = new Date();
    const diffYears = now.getFullYear() - birth.getFullYear();
    const diffMonths = now.getMonth() - birth.getMonth();
    let months = diffYears * 12 + diffMonths;
    if (now.getDate() < birth.getDate()) {
      months--;
    }
    return months < 1 ? 1 : months;
  };

  const fetchAnak = async () => {
    try {
      const res = await getAnakById(idAnak);
      if (res && res.data) {
        setAnakData(res.data);
        const ageMonths = calculateAgeInMonths(res.data.tanggal_lahir);
        setFormData(prev => ({
          ...prev,
          bulan_ke: ageMonths > 60 ? 60 : ageMonths
        }));
      }
    } catch (error) {
      console.error("Gagal mengambil data anak:", error);
    }
  };

  useEffect(() => {
    setUserLogin(getCurrentUser());
    loadData();
    fetchAnak();
  }, [idAnak]);

  const loadData = async () => {
    setIsLoading(true);
    try {
      const res = await sdidtkService.getByAnakId(idAnak);
      // Data diurutkan berdasarkan bulan_ke sesuai history medis
      const sortedData = res.data.sort((a, b) => a.bulan_ke - b.bulan_ke);
      setDataList(sortedData);
    } catch (err) {
      console.error("Gagal load data", err);
    } finally {
      setIsLoading(false);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    const todayStr = new Date().toISOString().split('T')[0];
    if (formData.tanggal > todayStr) {
      setNotification({
        type: "error",
        message: "Tanggal periksa tidak boleh tanggal yang akan datang!"
      });
      return;
    }

    const nakesId = Number(userLogin?.user_id || userLogin?.id);
    if (!nakesId || nakesId === 0) {
      setNotification({
        type: "error",
        message: "Sesi login tidak valid. Silakan login ulang."
      });
      return;
    }

    const bulanKeNum = Number(formData.bulan_ke);
    if (isNaN(bulanKeNum) || bulanKeNum <= 0) {
      setNotification({
        type: "error",
        message: "Bulan ke- harus berupa angka lebih besar dari 0."
      });
      return;
    }

    setIsLoading(true);

    const payload = {
      anak_id: Number(idAnak),
      bulan_ke: Number(formData.bulan_ke),
      tenaga_kesehatan_id: nakesId,
      bb_u: formData.bb_u,
      bb_tb: formData.bb_tb,
      tb_u: formData.tb_u,
      lk_u: formData.lk_u,
      lila: formData.lila,
      kpsp: formData.kpsp,
      tdd: formData.tdd,
      tdl: formData.tdl,
      kmpe: formData.kmpe,
      m_chat_revised: formData.m_chat_revised,
      actrs: formData.actrs,
      tanggal: sdidtkService.formatToISO(formData.tanggal),
      tindakan: formData.tindakan,
      kunjungan_ulang: formData.kunjungan_ulang ? sdidtkService.formatToISO(formData.kunjungan_ulang) : null
    };

    try {
      await sdidtkService.create(payload);
      setIsModalOpen(false);
      resetForm();
      await loadData();
      setNotification({
        type: "success",
        message: "Data pemantauan tumbuh kembang anak (SDIDTK) berhasil disimpan ke dalam sistem!"
      });
    } catch (err) {
      console.error("Gagal simpan SDIDTK. Detail error:", err);
      const status = err.response?.status;
      const serverMsg = err.response?.data?.message || err.message;
      const serverDetail = err.response?.data?.error || "";
      setNotification({
        type: "error",
        message: "Permintaan gagal diproses. Silakan coba lagi nanti atau hubungi bantuan.",
        code: `Status: ${status} | Detail: ${serverMsg}${serverDetail ? ` | ${serverDetail}` : ""}`
      });
    } finally {
      setIsLoading(false);
    }
  };

  const resetForm = () => {
    const ageMonths = anakData ? calculateAgeInMonths(anakData.tanggal_lahir) : "";
    setFormData({
      bulan_ke: ageMonths > 60 ? 60 : ageMonths,
      tanggal: new Date().toISOString().split('T')[0],
      bb_u: "N", bb_tb: "GN", tb_u: "N", lk_u: "N", lila: "N",
      kpsp: "Ds", tdd: "N", tdl: "N", kmpe: "N", m_chat_revised: "N", actrs: "N",
      tindakan: "", kunjungan_ulang: ""
    });
  };

  // --- MAPPING OPTIONS (Label Panjang, Value Kode DB) ---
  const optBBU = [{ label: "Normal", value: "N" }, { label: "Berat Badan Kurang", value: "K" }, { label: "Sangat Kurang", value: "SK" }, { label: "Risiko BB Lebih", value: "RBBL" }, { label: "Gizi Normal", value: "GN" }];
  const optBBTB = [{ label: "Gizi Baik (Normal)", value: "GN" }, { label: "Gizi Kurang", value: "GK" }, { label: "Gizi Buruk", value: "GB" }, { label: "Risiko Gizi Lebih", value: "RGL" }, { label: "Obesitas", value: "O" }, { label: "Normal", value: "N" }];
  const optTBU = [{ label: "Normal", value: "N" }, { label: "Tidak Normal", value: "TN" }];
  const optLila = [{ label: "Normal", value: "N" }, { label: "Gizi Kurang", value: "GK" }, { label: "Gizi Buruk", value: "BG" }];
  const optLKU = [{ label: "Normal", value: "N" }, { label: "Mikrosefali", value: "Mi" }, { label: "Makrosefali", value: "Ma" }];
  const optKPSP = [{ label: "Sesuai Usia", value: "Ds" }, { label: "Meragukan", value: "Dm" }, { label: "Penyimpangan", value: "Dp" }, { label: "Sesuai", value: "S" }];
  const optNormalRujuk = [{ label: "Normal", value: "N" }, { label: "Rujuk / Ada Gangguan", value: "R" }, { label: "Terdeteksi", value: "T" }];

  return (
    <MainLayout>
      <AlertNotification
        notification={notification}
        onClose={() => setNotification(null)}
        onRetry={notification?.type === "error" ? () => setNotification(null) : null}
      />
      <div className="p-4 md:p-8 bg-[#f8fafc] min-h-screen font-['Noto_Sans',_sans-serif]">
        <div className="max-w-7xl mx-auto space-y-6">

          {/* Header */}
          <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
            <div>
              <button
                onClick={() => navigate(`/data-anak/dashboard/${idAnak}`)}
                className="inline-flex items-center gap-2 px-4 py-2 mb-3 bg-[#185FA5] hover:bg-[#185FA5]/90 text-white text-sm font-semibold rounded-xl transition-all active:scale-95 shadow-sm"
              >
                <ArrowLeft size={16} /> Kembali
              </button>
              <h1 className="text-2xl font-bold text-slate-800">Pemantauan Tumbuh Kembang (SDIDTK)</h1>
              {anakData && (
                <p className="text-sm text-slate-500 mt-0.5">
                  Anak: <span className="font-semibold text-slate-700">{anakData.nama}</span>
                  {" "}· Usia saat ini: <span className="font-semibold text-slate-700">{calculateAgeInMonths(anakData.tanggal_lahir)} bulan</span>
                </p>
              )}
            </div>
            {!isModalOpen && (
              <button
                onClick={() => setIsModalOpen(true)}
                className="inline-flex items-center gap-2 px-4 py-2 bg-[#185FA5] hover:bg-[#185FA5]/90 text-white text-sm font-semibold rounded-xl transition-all active:scale-95 shadow-sm"
              >
                <Plus size={16} /> Input Pemeriksaan
              </button>
            )}
          </div>

          {/* Form Input — inline */}
          {isModalOpen && (
            <div className="bg-white rounded-2xl border border-[#e2e8f0] p-6 shadow-sm">
              <div className="flex items-center justify-between mb-5">
                <h2 className="text-[18px] font-semibold text-slate-800">Input Pemeriksaan SDIDTK</h2>
                <button
                  type="button"
                  onClick={() => setIsModalOpen(false)}
                  className="text-sm font-semibold text-slate-500 hover:text-slate-700 px-3 py-1.5 border border-[#e2e8f0] rounded-lg hover:bg-slate-50 transition-colors"
                >
                  Batal
                </button>
              </div>

              <form onSubmit={handleSubmit} className="space-y-6">
                {/* Info dasar */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-semibold text-slate-600 mb-1.5">
                      Bulan Ke-
                      {anakData && <span className="font-normal text-slate-400 ml-1">(Usia sekarang: {calculateAgeInMonths(anakData.tanggal_lahir)} bulan)</span>}
                    </label>
                    <input
                      type="number" min="1" required
                      className="w-full bg-[#F7FAFB] border border-[#e2e8f0] rounded-xl px-4 py-2.5 text-sm text-slate-700 focus:outline-none focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5]"
                      value={formData.bulan_ke}
                      onChange={e => { const v = e.target.value; if (v === "" || Number(v) > 0) setFormData({ ...formData, bulan_ke: v }); }}
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-semibold text-slate-600 mb-1.5">Tanggal Periksa</label>
                    <input
                      type="date" required
                      max={new Date().toISOString().split('T')[0]}
                      className="w-full bg-[#F7FAFB] border border-[#e2e8f0] rounded-xl px-4 py-2.5 text-sm text-slate-700 focus:outline-none focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5]"
                      value={formData.tanggal}
                      onChange={e => setFormData({ ...formData, tanggal: e.target.value })}
                    />
                  </div>
                </div>

                {/* Indikator pertumbuhan */}
                <div>
                  <p className="text-sm font-semibold text-slate-700 mb-3">Indikator Pertumbuhan</p>
                  <div className="grid grid-cols-2 md:grid-cols-5 gap-3">
                    {[
                      { label: "BB/U", key: "bb_u", opts: optBBU },
                      { label: "BB/TB", key: "bb_tb", opts: optBBTB },
                      { label: "TB/U", key: "tb_u", opts: optTBU },
                      { label: "LK/U", key: "lk_u", opts: optLKU },
                      { label: "LILA", key: "lila", opts: optLila },
                    ].map(({ label, key, opts }) => (
                      <div key={key}>
                        <label className="block text-xs font-semibold text-slate-500 mb-1">{label}</label>
                        <select
                          className="w-full bg-[#F7FAFB] border border-[#e2e8f0] rounded-xl px-3 py-2 text-sm text-slate-700 focus:outline-none focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5]"
                          value={formData[key]}
                          onChange={e => setFormData({ ...formData, [key]: e.target.value })}
                        >
                          {opts.map(o => <option key={o.value} value={o.value}>{o.label}</option>)}
                        </select>
                      </div>
                    ))}
                  </div>
                </div>

                {/* Indikator perkembangan */}
                <div>
                  <p className="text-sm font-semibold text-slate-700 mb-3">Indikator Perkembangan & Emosional</p>
                  <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-3">
                    {[
                      { label: "KPSP", key: "kpsp", opts: optKPSP },
                      { label: "Daya Dengar (TDD)", key: "tdd", opts: optNormalRujuk },
                      { label: "Daya Lihat (TDL)", key: "tdl", opts: optNormalRujuk },
                      { label: "KMPE", key: "kmpe", opts: optNormalRujuk },
                      { label: "M-CHAT-R", key: "m_chat_revised", opts: optNormalRujuk },
                      { label: "ACTRS", key: "actrs", opts: optNormalRujuk },
                    ].map(({ label, key, opts }) => (
                      <div key={key}>
                        <label className="block text-xs font-semibold text-slate-500 mb-1">{label}</label>
                        <select
                          className="w-full bg-[#F7FAFB] border border-[#e2e8f0] rounded-xl px-3 py-2 text-sm text-slate-700 focus:outline-none focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5]"
                          value={formData[key]}
                          onChange={e => setFormData({ ...formData, [key]: e.target.value })}
                        >
                          {opts.map(o => <option key={o.value} value={o.value}>{o.label}</option>)}
                        </select>
                      </div>
                    ))}
                  </div>
                </div>

                <p className="text-xs text-slate-400">Tindakan dan kunjungan ulang akan dikalkulasi otomatis oleh sistem sesuai hasil pemeriksaan.</p>

                <div className="flex justify-end pt-2">
                  <button
                    type="submit"
                    disabled={isLoading}
                    className="inline-flex items-center gap-2 px-6 py-2.5 bg-[#185FA5] hover:bg-[#185FA5]/90 text-white text-sm font-semibold rounded-xl transition-all active:scale-95 disabled:opacity-50 shadow-sm"
                  >
                    {isLoading ? <Loader2 className="animate-spin" size={16} /> : <Save size={16} />}
                    Simpan Data
                  </button>
                </div>
              </form>
            </div>
          )}

          {/* Tabel Riwayat */}
          <div className="bg-white rounded-2xl border border-[#e2e8f0] shadow-sm overflow-hidden">
            <div className="px-6 py-4 border-b border-[#e2e8f0]">
              <h3 className="text-base font-semibold text-slate-800">Riwayat Pemeriksaan SDIDTK</h3>
            </div>
            <div className="overflow-x-auto">
              <table className="w-full text-center text-xs border-collapse min-w-[900px]">
                <thead>
                  <tr className="bg-slate-100 border-b border-slate-200">
                    <th className="px-4 py-3.5 text-xs font-semibold text-slate-600 text-left">Bulan</th>
                    <th className="px-3 py-3.5 text-xs font-semibold text-slate-600">BB/U</th>
                    <th className="px-3 py-3.5 text-xs font-semibold text-slate-600">BB/TB</th>
                    <th className="px-3 py-3.5 text-xs font-semibold text-slate-600">TB/U</th>
                    <th className="px-3 py-3.5 text-xs font-semibold text-slate-600">LK/U</th>
                    <th className="px-3 py-3.5 text-xs font-semibold text-slate-600">LILA</th>
                    <th className="px-3 py-3.5 text-xs font-semibold text-slate-600">KPSP</th>
                    <th className="px-3 py-3.5 text-xs font-semibold text-slate-600">TDD</th>
                    <th className="px-3 py-3.5 text-xs font-semibold text-slate-600">TDL</th>
                    <th className="px-3 py-3.5 text-xs font-semibold text-slate-600">KMPE</th>
                    <th className="px-3 py-3.5 text-xs font-semibold text-slate-600">M-CHAT</th>
                    <th className="px-3 py-3.5 text-xs font-semibold text-slate-600">ACTRS</th>
                    <th className="px-3 py-3.5 text-xs font-semibold text-slate-600">PKAT</th>
                    <th className="px-4 py-3.5 text-xs font-semibold text-slate-600 text-left">Tindakan</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-[#e2e8f0]">
                  {isLoading ? (
                    <tr><td colSpan="14" className="py-12">
                      <div className="flex flex-col items-center gap-3">
                        <Loader2 className="animate-spin text-[#185FA5]" size={28} />
                        <span className="text-sm text-slate-500">Memuat data...</span>
                      </div>
                    </td></tr>
                  ) : dataList.length === 0 ? (
                    <tr><td colSpan="14" className="py-12 text-slate-400 text-sm italic">Belum ada data pemeriksaan.</td></tr>
                  ) : dataList.map((row) => (
                    <tr key={row.id} className="hover:bg-[#F7FAFB] transition-colors">
                      <td className="px-4 py-3 font-semibold text-slate-800 text-left">{row.bulan_ke}</td>
                      <td className="px-3 py-3 text-slate-600">{row.bb_u}</td>
                      <td className="px-3 py-3 text-slate-600">{row.bb_tb}</td>
                      <td className="px-3 py-3 text-slate-600">{decodeTBU(row.tb_u)}</td>
                      <td className="px-3 py-3 text-slate-600">{row.lk_u}</td>
                      <td className="px-3 py-3 text-slate-600">{row.lila}</td>
                      <td className="px-3 py-3 text-slate-600">{row.kpsp}</td>
                      <td className="px-3 py-3 text-slate-600">{row.tdd}</td>
                      <td className="px-3 py-3 text-slate-600">{row.tdl}</td>
                      <td className="px-3 py-3 text-slate-600">{row.kmpe}</td>
                      <td className="px-3 py-3 text-slate-600">{row.m_chat_revised}</td>
                      <td className="px-3 py-3 text-slate-600">{row.actrs}</td>
                      <td className="px-3 py-3 font-semibold text-[#185FA5]">{row.hasil_pkat}</td>
                      <td className="px-4 py-3 text-left text-slate-500 max-w-[180px] truncate">{row.tindakan}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>

        </div>
      </div>
    </MainLayout>
  );
};

// --- HELPERS ---
const decodeTBU = (val) => {
  const map = { N: "Normal", TN: "Tidak Normal", SP: "Tidak Normal", P: "Tidak Normal", Ti: "Normal" };
  return map[val] ?? val ?? "-";
};

export default FormSDIDTK;