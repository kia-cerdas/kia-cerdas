import React, { useState, useEffect } from 'react';
import { Plus, X, Save, UserCheck, ClipboardCheck, Loader2 } from 'lucide-react';
import { useParams } from 'react-router-dom';
import MainLayout from "../../components/Layout/MainLayout";
import AlertNotification from "../../components/AlertNotification";
import { getCurrentUser } from '../../services/auth';
import { sdidtkService } from '../../services/SDIDTk';

const FormSDIDTK = () => {
  const { id: idAnakParam } = useParams();
  const idAnak = idAnakParam || 1;
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [dataList, setDataList] = useState([]);
  const [userLogin, setUserLogin] = useState(null);
  const [notification, setNotification] = useState(null);

  const [formData, setFormData] = useState({
    bulan_ke: "",
    tanggal: new Date().toISOString().split('T')[0],
    bb_u: "N", bb_tb: "GN", tb_u: "N", lk_u: "N", lila: "N",
    kpsp: "Ds", tdd: "N", tdl: "N",
    kmpe: "N", m_chat_revised: "N", actrs: "N",
    tindakan: "", kunjungan_ulang: ""
  });

  useEffect(() => {
    setUserLogin(getCurrentUser());
    loadData();
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
    setFormData({
      bulan_ke: "", tanggal: new Date().toISOString().split('T')[0],
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
        onRetry={notification?.type === "error" ? () => {
          setNotification(null);
          setIsModalOpen(true);
        } : null}
      />
      <div className="p-6 bg-gray-50 min-h-screen font-sans">

        {/* HEADER */}
        <div className="flex flex-col md:flex-row justify-between items-end mb-8 gap-4">
          <div>
            <p className="text-blue-600 font-bold text-[10px] uppercase tracking-widest mb-1 italic">
              Petugas Aktif: {userLogin?.nama || 'Nakes'}
            </p>
            <h1 className="text-3xl font-black text-gray-900 uppercase tracking-tighter italic">Pemantauan Pertumbuhan & Perkembangan </h1>
          </div>
          <button onClick={() => setIsModalOpen(true)} className="bg-blue-600 text-white px-8 py-4 rounded-2xl font-bold flex items-center gap-3 hover:bg-blue-700 transition-all shadow-2xl">
            <Plus size={20} /> Input Pemeriksaan
          </button>
        </div>

        {/* TABEL SESUAI GET DATA */}
        <div className="bg-white rounded-3xl shadow-sm border border-gray-200 overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-center text-[9px] border-collapse">
              <thead className="bg-blue-700 text-white uppercase font-black tracking-widest">
                <tr>
                  <th className="p-4 border-r border-gray-800" rowSpan="2">Bulan</th>
                  <th className="p-2 border-b border-gray-800" colSpan="5">Pertumbuhan</th>
                  <th className="p-2 border-b border-gray-800" colSpan="3">Perkembangan</th>
                  <th className="p-2 border-b border-gray-800" colSpan="3">Emosional</th>
                  <th className="p-4 border-l border-blue-800" rowSpan="2">PKAT</th>
                  <th className="p-4 border-l border-blue-800" rowSpan="2">Tindakan</th>
                  <th className="p-4 border-l border-blue-800" rowSpan="2">Kunjungan Ulang</th>
                </tr>
                <tr className="bg-blue-600 text-blue-100">
                  {['BB/U', 'BB/TB', 'TB/U', 'LK/U', 'LiLA', 'KPSP', 'TDD', 'TDL', 'KMPE', 'M-CHAT', 'ACTRS'].map(h => (
                    <th key={h} className="p-2 border-r border-blue-500 font-medium">{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 italic">
                {isLoading ? (
                  <tr><td colSpan="14" className="p-10"><Loader2 className="animate-spin mx-auto" /></td></tr>
                ) : dataList.map((row) => (
                  <tr key={row.id} className="hover:bg-blue-50/30 transition-colors">
                    <td className="p-4 font-black text-gray-900 border-r">{row.bulan_ke}</td>
                    <td className="p-2 border-r">{row.bb_u}</td><td className="p-2 border-r">{row.bb_tb}</td>
                    <td className="p-2 border-r">{decodeTBU(row.tb_u)}</td><td className="p-2 border-r">{row.lk_u}</td>
                    <td className="p-2 border-r">{row.lila}</td><td className="p-2 border-r">{row.kpsp}</td>
                    <td className="p-2 border-r">{row.tdd}</td><td className="p-2 border-r">{row.tdl}</td>
                    <td className="p-2 border-r">{row.kmpe}</td><td className="p-2 border-r">{row.m_chat_revised}</td>
                    <td className="p-2 border-r">{row.actrs}</td>
                    <td className="p-2 border-l font-bold text-blue-700 uppercase">{row.hasil_pkat}</td>
                    <td className="p-2 border-l text-[8px] text-gray-500 text-left px-3">{row.tindakan}</td>
                    <td className="p-2 border-l text-[8px] text-gray-500 text-left px-3">{row.kunjungan_ulang}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        {/* MODAL INPUT */}
        {isModalOpen && (
          <div className="fixed inset-0 bg-black/40 backdrop-blur-md flex items-center justify-center p-4 z-50">
            <div className="bg-white rounded-[40px] w-full max-w-5xl shadow-2xl overflow-hidden animate-in zoom-in duration-300">
              {/* Header */}
              <div className="bg-blue-600 p-6 flex justify-between items-center text-white font-black uppercase">
                <div className="flex items-center gap-4">
                  <ClipboardCheck />
                  <span>Input Laporan SDIDTK</span>
                </div>
                <button onClick={() => setIsModalOpen(false)}><X /></button>
              </div>

              <form onSubmit={handleSubmit} className="p-10">
                <div className="grid grid-cols-1 md:grid-cols-4 gap-8">

                  {/* Kolom Kiri: Hanya Informasi Utama */}
                  <div className="space-y-6">
                    <InputField
                      label="Bulan Ke-"
                      type="number"
                      min="1"
                      value={formData.bulan_ke}
                      onChange={e => {
                        const val = e.target.value;
                        if (val === "" || Number(val) > 0) {
                          setFormData({ ...formData, bulan_ke: val });
                        }
                      }}
                      required
                    />
                    <InputField
                      label="Tanggal Periksa"
                      type="date"
                      value={formData.tanggal}
                      onChange={e => setFormData({ ...formData, tanggal: e.target.value })}
                      required
                    />
                    <div className="p-4 bg-blue-50 rounded-2xl border border-blue-100">
                      <p className="text-xs font-bold text-blue-800 uppercase mb-1">Info Sistem</p>
                      <p className="text-[10px] text-blue-600 leading-relaxed">
                        Kunjungan ulang dan saran medis akan dikalkulasi otomatis oleh AI sesuai hasil pemeriksaan.
                      </p>
                    </div>
                  </div>

                  {/* Kolom Kanan: Indikator Medis */}
                  <div className="md:col-span-3 grid grid-cols-3 gap-x-6 gap-y-5 bg-gray-50 p-8 rounded-[32px] border">
                    <SelectField label="BB/U" value={formData.bb_u} options={optBBU} onChange={v => setFormData({ ...formData, bb_u: v })} />
                    <SelectField label="BB/TB" value={formData.bb_tb} options={optBBTB} onChange={v => setFormData({ ...formData, bb_tb: v })} />
                    <SelectField label="TB/U" value={formData.tb_u} options={optTBU} onChange={v => setFormData({ ...formData, tb_u: v })} />
                    <SelectField label="LK/U" value={formData.lk_u} options={optLKU} onChange={v => setFormData({ ...formData, lk_u: v })} />
                    <SelectField label="LiLA" value={formData.lila} options={optLila} onChange={v => setFormData({ ...formData, lila: v })} />
                    <SelectField label="KPSP" value={formData.kpsp} options={optKPSP} onChange={v => setFormData({ ...formData, kpsp: v })} />
                    <SelectField label="Daya Dengar" value={formData.tdd} options={optNormalRujuk} onChange={v => setFormData({ ...formData, tdd: v })} />
                    <SelectField label="Daya Lihat" value={formData.tdl} options={optNormalRujuk} onChange={v => setFormData({ ...formData, tdl: v })} />
                    <SelectField label="KMPE" value={formData.kmpe} options={optNormalRujuk} onChange={v => setFormData({ ...formData, kmpe: v })} />
                    <SelectField label="M-CHAT-R" value={formData.m_chat_revised} options={optNormalRujuk} onChange={v => setFormData({ ...formData, m_chat_revised: v })} />
                    <SelectField label="ACTRS" value={formData.actrs} options={optNormalRujuk} onChange={v => setFormData({ ...formData, actrs: v })} />
                  </div>
                </div>

                <button
                  disabled={isLoading}
                  type="submit"
                  className="w-full mt-10 bg-blue-700 text-white py-5 rounded-3xl font-black shadow-xl hover:bg-blue-800 transition-all uppercase flex items-center justify-center gap-3"
                >
                  {isLoading ? <Loader2 className="animate-spin" /> : <><Save size={20} /> Simpan</>}
                </button>
              </form>
            </div>
          </div>
        )}
      </div>
    </MainLayout>
  );
};

// --- HELPERS ---
const decodeTBU = (val) => {
  const map = { N: "Normal", TN: "Tidak Normal", SP: "Tidak Normal", P: "Tidak Normal", Ti: "Normal" };
  return map[val] ?? val ?? "-";
};

const InputField = ({ label, ...props }) => (
  <div className="flex flex-col gap-1.5">
    <label className="text-[9px] font-black text-gray-400 uppercase tracking-widest">{label}</label>
    <input {...props} className="border-b-2 border-gray-100 py-2 text-sm outline-none focus:border-blue-600 bg-transparent font-bold" />
  </div>
);

const SelectField = ({ label, value, options, onChange }) => (
  <div className="flex flex-col gap-1.5">
    <label className="text-[9px] font-black text-gray-400 uppercase tracking-widest">{label}</label>
    <select value={value} onChange={e => onChange(e.target.value)} className="border-b-2 border-gray-100 py-2 text-sm outline-none bg-transparent focus:border-blue-600 font-bold text-gray-700 cursor-pointer">
      {options.map(opt => <option key={opt.value} value={opt.value}>{opt.label}</option>)}
    </select>
  </div>
);

export default FormSDIDTK;