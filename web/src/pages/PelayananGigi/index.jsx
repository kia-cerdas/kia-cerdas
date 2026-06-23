import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { Plus, Save, Loader2, ArrowLeft, Pencil } from 'lucide-react';
import MainLayout from "../../components/Layout/MainLayout";
import AlertNotification from "../../components/AlertNotification";
import { dentalService } from '../../services/dentalService';
import { getAnakById } from '../../services/Anak';

const PelayananGigi = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [records, setRecords] = useState([]);
  const [loading, setLoading] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [notification, setNotification] = useState(null);
  const [showForm, setShowForm] = useState(false);
  const [anakData, setAnakData] = useState(null);

  const [formData, setFormData] = useState({
    bulan_ke: "",
    tanggal: new Date().toISOString().split('T')[0],
    jumlah_gigi: "",
    gigi_berlubang: "",
    status_plak: "Bersih",
    resiko_gigi_berlubang: "Rendah"
  });

  const calculateAgeInMonths = (birthDateString) => {
    if (!birthDateString) return 1;
    const birth = new Date(birthDateString);
    const now = new Date();
    const diffYears = now.getFullYear() - birth.getFullYear();
    const diffMonths = now.getMonth() - birth.getMonth();
    let months = diffYears * 12 + diffMonths;
    if (now.getDate() < birth.getDate()) months--;
    return months < 1 ? 1 : months;
  };

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

  const fetchAnak = async () => {
    try {
      const res = await getAnakById(id);
      if (res?.data) setAnakData(res.data);
    } catch (error) {
      console.error("Gagal mengambil data anak:", error);
    }
  };

  useEffect(() => {
    if (id) { fetchData(); fetchAnak(); }
  }, [id]);

  const handleOpenForm = () => {
    const ageMonths = anakData ? calculateAgeInMonths(anakData.tanggal_lahir) : "";
    setFormData({
      bulan_ke: ageMonths > 60 ? 60 : ageMonths,
      tanggal: new Date().toISOString().split('T')[0],
      jumlah_gigi: "",
      gigi_berlubang: "",
      status_plak: "Bersih",
      resiko_gigi_berlubang: "Rendah"
    });
    setShowForm(true);
    window.scrollTo({ top: 0, behavior: "smooth" });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    const todayStr = new Date().toISOString().split('T')[0];
    if (formData.tanggal > todayStr) {
      setNotification({ type: "error", message: "Tanggal periksa tidak boleh tanggal yang akan datang!" });
      return;
    }
    if (Number(formData.gigi_berlubang) > Number(formData.jumlah_gigi)) {
      setNotification({ type: "error", message: "Jumlah gigi berlubang tidak boleh melebihi total gigi!" });
      return;
    }

    setIsSubmitting(true);
    try {
      await dentalService.create({
        anak_id: Number(id),
        bulan_ke: Number(formData.bulan_ke),
        tanggal: new Date(formData.tanggal).toISOString(),
        jumlah_gigi: Number(formData.jumlah_gigi),
        gigi_berlubang: Number(formData.gigi_berlubang),
        status_plak: formData.status_plak,
        resiko_gigi_berlubang: formData.resiko_gigi_berlubang
      });
      setShowForm(false);
      await fetchData();
      setNotification({ type: "success", message: "Data pemeriksaan gigi berhasil disimpan ke dalam sistem." });
    } catch (err) {
      const errorMsg = err.response?.data?.message || "Gagal menyimpan data.";
      setNotification({ type: "error", message: "Permintaan gagal diproses. Silakan coba lagi nanti.", code: errorMsg });
    } finally {
      setIsSubmitting(false);
    }
  };

  const risikoLabel = (val) => {
    if (val === "Tinggi") return <span className="px-2 py-0.5 bg-red-50 text-red-700 border border-red-100 rounded-md text-xs font-semibold">Tinggi</span>;
    if (val === "Sedang") return <span className="px-2 py-0.5 bg-amber-50 text-amber-700 border border-amber-100 rounded-md text-xs font-semibold">Sedang</span>;
    return <span className="px-2 py-0.5 bg-green-50 text-green-700 border border-green-100 rounded-md text-xs font-semibold">Rendah</span>;
  };

  return (
    <MainLayout>
      <AlertNotification
        notification={notification}
        onClose={() => setNotification(null)}
        onRetry={notification?.type === "error" ? () => setNotification(null) : null}
      />
      <div className="p-4 md:p-8 bg-[#f8fafc] min-h-screen">
        <div className="max-w-5xl mx-auto space-y-6">

          {/* Header */}
          <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
            <div>
              <button
                onClick={() => navigate(`/data-anak/dashboard/${id}`)}
                className="inline-flex items-center gap-2 px-4 py-2 mb-3 bg-[#185FA5] hover:bg-[#185FA5]/90 text-white text-sm font-semibold rounded-xl transition-all active:scale-95 shadow-sm"
              >
                <ArrowLeft size={16} /> Kembali
              </button>
              <h1 className="text-2xl font-bold text-slate-800">Pelayanan Kesehatan Gigi</h1>
              {anakData && (
                <p className="text-sm text-slate-500 mt-0.5">
                  Anak: <span className="font-semibold text-slate-700">{anakData.nama}</span>
                </p>
              )}
            </div>
            {!showForm && (
              <button
                onClick={handleOpenForm}
                className="inline-flex items-center gap-2 px-4 py-2 bg-[#185FA5] hover:bg-[#185FA5]/90 text-white text-sm font-semibold rounded-xl transition-all active:scale-95 shadow-sm"
              >
                <Plus size={16} /> Tambah Pemeriksaan
              </button>
            )}
          </div>

          {/* Form Input — inline, tidak popup */}
          {showForm && (
            <div className="bg-white rounded-2xl border border-[#e2e8f0] p-6 shadow-sm">
              <div className="flex items-center justify-between mb-5">
                <h2 className="text-[18px] font-semibold text-slate-800">Input Pemeriksaan Gigi</h2>
                <button
                  type="button"
                  onClick={() => setShowForm(false)}
                  className="text-sm font-semibold text-slate-500 hover:text-slate-700 px-3 py-1.5 border border-[#e2e8f0] rounded-lg hover:bg-slate-50 transition-colors"
                >
                  Batal
                </button>
              </div>

              <form onSubmit={handleSubmit} className="space-y-5">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  {/* Kolom kiri */}
                  <div className="space-y-4">
                    <div>
                      <label className="block text-sm font-semibold text-slate-600 mb-1.5">
                        Bulan Ke-
                        {anakData && (
                          <span className="ml-1 font-normal text-slate-400">
                            (Usia saat ini: {calculateAgeInMonths(anakData.tanggal_lahir)} bulan)
                          </span>
                        )}
                      </label>
                      <select
                        className="w-full bg-[#F7FAFB] border border-[#e2e8f0] rounded-xl px-4 py-2.5 text-sm text-slate-700 focus:outline-none focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5]"
                        value={formData.bulan_ke}
                        onChange={e => setFormData({ ...formData, bulan_ke: e.target.value })}
                        required
                      >
                        <option value="">Pilih jadwal</option>
                        {[...Array(60)].map((_, i) => {
                          const month = i + 1;
                          const currentAge = anakData ? calculateAgeInMonths(anakData.tanggal_lahir) : null;
                          return (
                            <option key={i} value={month}>
                              Bulan {month}{currentAge === month ? " (usia sekarang)" : ""}
                            </option>
                          );
                        })}
                      </select>
                    </div>

                    <div>
                      <label className="block text-sm font-semibold text-slate-600 mb-1.5">Tanggal Periksa</label>
                      <input
                        type="date"
                        max={new Date().toISOString().split('T')[0]}
                        className="w-full bg-[#F7FAFB] border border-[#e2e8f0] rounded-xl px-4 py-2.5 text-sm text-slate-700 focus:outline-none focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5]"
                        value={formData.tanggal}
                        onChange={e => setFormData({ ...formData, tanggal: e.target.value })}
                        required
                      />
                    </div>

                    <div>
                      <label className="block text-sm font-semibold text-slate-600 mb-1.5">Status Plak</label>
                      <div className="flex gap-2">
                        {['Bersih', 'Kotor'].map(status => (
                          <button
                            key={status}
                            type="button"
                            onClick={() => setFormData({ ...formData, status_plak: status })}
                            className={`flex-1 py-2.5 rounded-xl text-sm font-semibold border transition-all ${
                              formData.status_plak === status
                                ? 'bg-[#185FA5] text-white border-[#185FA5]'
                                : 'bg-[#F7FAFB] text-slate-600 border-[#e2e8f0] hover:border-[#185FA5]/50'
                            }`}
                          >
                            {status}
                          </button>
                        ))}
                      </div>
                    </div>
                  </div>

                  {/* Kolom kanan */}
                  <div className="space-y-4">
                    <div className="grid grid-cols-2 gap-3">
                      <div>
                        <label className="block text-sm font-semibold text-slate-600 mb-1.5">Jumlah Gigi</label>
                        <input
                          type="number"
                          min="0"
                          placeholder="0"
                          className="w-full bg-[#F7FAFB] border border-[#e2e8f0] rounded-xl px-4 py-2.5 text-sm text-slate-700 focus:outline-none focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5]"
                          value={formData.jumlah_gigi}
                          onChange={e => setFormData({ ...formData, jumlah_gigi: e.target.value })}
                          required
                        />
                      </div>
                      <div>
                        <label className="block text-sm font-semibold text-slate-600 mb-1.5">Gigi Berlubang</label>
                        <input
                          type="number"
                          min="0"
                          placeholder="0"
                          className="w-full bg-[#F7FAFB] border border-[#e2e8f0] rounded-xl px-4 py-2.5 text-sm text-slate-700 focus:outline-none focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5]"
                          value={formData.gigi_berlubang}
                          onChange={e => setFormData({ ...formData, gigi_berlubang: e.target.value })}
                          required
                        />
                      </div>
                    </div>

                    <div>
                      <label className="block text-sm font-semibold text-slate-600 mb-1.5">Risiko Gigi Berlubang</label>
                      <div className="flex gap-2">
                        {['Rendah', 'Sedang', 'Tinggi'].map(risiko => (
                          <button
                            key={risiko}
                            type="button"
                            onClick={() => setFormData({ ...formData, resiko_gigi_berlubang: risiko })}
                            className={`flex-1 py-2.5 rounded-xl text-sm font-semibold border transition-all ${
                              formData.resiko_gigi_berlubang === risiko
                                ? 'bg-[#185FA5] text-white border-[#185FA5]'
                                : 'bg-[#F7FAFB] text-slate-600 border-[#e2e8f0] hover:border-[#185FA5]/50'
                            }`}
                          >
                            {risiko}
                          </button>
                        ))}
                      </div>
                    </div>
                  </div>
                </div>

                <div className="flex justify-end pt-2">
                  <button
                    type="submit"
                    disabled={isSubmitting}
                    className="inline-flex items-center gap-2 px-6 py-2.5 bg-[#185FA5] hover:bg-[#185FA5]/90 text-white text-sm font-semibold rounded-xl transition-all active:scale-95 disabled:opacity-50 shadow-sm"
                  >
                    {isSubmitting ? <Loader2 className="animate-spin" size={16} /> : <Save size={16} />}
                    Simpan Data
                  </button>
                </div>
              </form>
            </div>
          )}

          {/* Tabel riwayat */}
          <div className="bg-white rounded-2xl border border-[#e2e8f0] shadow-sm overflow-hidden">
            <div className="px-6 py-4 border-b border-[#e2e8f0]">
              <h3 className="text-base font-semibold text-slate-800">Riwayat Pemeriksaan Gigi</h3>
            </div>
            <div className="overflow-x-auto">
              <table className="w-full text-left border-collapse min-w-[700px]">
                <thead>
                  <tr className="bg-slate-100 border-b border-slate-200">
                    <th className="px-6 py-3.5 text-xs font-semibold text-slate-600">Bulan</th>
                    <th className="px-6 py-3.5 text-xs font-semibold text-slate-600">Tanggal Periksa</th>
                    <th className="px-6 py-3.5 text-xs font-semibold text-slate-600 text-center">Jumlah Gigi</th>
                    <th className="px-6 py-3.5 text-xs font-semibold text-slate-600 text-center">Gigi Berlubang</th>
                    <th className="px-6 py-3.5 text-xs font-semibold text-slate-600 text-center">Status Plak</th>
                    <th className="px-6 py-3.5 text-xs font-semibold text-slate-600">Risiko Berlubang</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-[#e2e8f0]">
                  {loading ? (
                    <tr>
                      <td colSpan="6" className="py-16 text-center">
                        <div className="flex flex-col items-center gap-3">
                          <Loader2 className="animate-spin text-[#185FA5]" size={28} />
                          <span className="text-sm text-slate-500">Memuat data...</span>
                        </div>
                      </td>
                    </tr>
                  ) : records.length === 0 ? (
                    <tr>
                      <td colSpan="6" className="py-16 text-center text-slate-400 text-sm italic">
                        Belum ada data pemeriksaan gigi.
                      </td>
                    </tr>
                  ) : records.map((row, idx) => (
                    <tr key={idx} className="hover:bg-[#F7FAFB] transition-colors">
                      <td className="px-6 py-4 text-sm text-slate-700">Ke-{row.bulan}</td>
                      <td className="px-6 py-4 text-sm text-slate-700">
                        {new Date(row.tanggal).toLocaleDateString('id-ID', { day: 'numeric', month: 'long', year: 'numeric' })}
                      </td>
                      <td className="px-6 py-4 text-center text-sm font-semibold text-slate-800">{row.jumlah_gigi}</td>
                      <td className="px-6 py-4 text-center text-sm font-semibold text-slate-800">{row.gigi_berlubang}</td>
                      <td className="px-6 py-4 text-center">
                        <span className={`px-2.5 py-1 rounded-full text-xs font-semibold ${
                          row.status_plak === 'Bersih'
                            ? 'bg-green-50 text-green-700 border border-green-100'
                            : 'bg-red-50 text-red-700 border border-red-100'
                        }`}>
                          {row.status_plak}
                        </span>
                      </td>
                      <td className="px-6 py-4">{risikoLabel(row.resiko_gigi_berlubang)}</td>
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

export default PelayananGigi;
