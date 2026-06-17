import React, { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { 
  Plus, X, Save, Loader2, Calendar, MessageSquare, 
  ChevronLeft, ArrowLeft, Trash2, Edit3, Stethoscope
} from "lucide-react";
import MainLayout from "../../../components/Layout/MainLayout";
import AlertNotification from "../../../components/AlertNotification";
import { 
  getKeluhanByAnakId, 
  createKeluhan, 
  updateKeluhan, 
  deleteKeluhan 
} from "../../../services/keluhanAnak";
import { getCurrentUser } from "../../../services/auth";

const KeluhanAnak = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [records, setRecords] = useState([]);
  const [loading, setLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [editingId, setEditingId] = useState(null);
  const [notification, setNotification] = useState(null);

  const [formData, setFormData] = useState({
    tanggal: new Date().toISOString().split('T')[0],
    keluhan: "",
    tindakan: "",
    pemeriksa: ""
  });

  const fetchData = async () => {
    setLoading(true);
    try {
      const res = await getKeluhanByAnakId(id);
      setRecords(res.data || []);
    } catch (error) {
      console.error("Fetch error:", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (id) fetchData();
  }, [id]);

  const handleOpenModal = (item = null) => {
    const user = getCurrentUser();
    const loginName = user?.nama || user?.name || "";
    if (item) {
      setEditingId(item.id);
      setFormData({
        tanggal: item.tanggal ? item.tanggal.split('T')[0] : new Date().toISOString().split('T')[0],
        keluhan: item.keluhan || "",
        tindakan: item.tindakan || "",
        pemeriksa: item.pemeriksa || loginName
      });
    } else {
      setEditingId(null);
      setFormData({
        tanggal: new Date().toISOString().split('T')[0],
        keluhan: "",
        tindakan: "",
        pemeriksa: loginName
      });
    }
    setIsModalOpen(true);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsSubmitting(true);

    const payload = {
      anak_id: Number(id),
      tanggal: new Date(formData.tanggal).toISOString(),
      keluhan: formData.keluhan,
      tindakan: formData.tindakan,
      pemeriksa: formData.pemeriksa
    };

    try {
      if (editingId) {
        await updateKeluhan(editingId, payload);
        setNotification({
          type: "success",
          message: "Data keluhan anak berhasil diperbarui ke dalam sistem!"
        });
      } else {
        await createKeluhan(payload);
        setNotification({
          type: "success",
          message: "Data keluhan anak berhasil disimpan ke dalam sistem!"
        });
      }
      setIsModalOpen(false);
      fetchData();
    } catch (err) {
      console.error("Save error:", err);
      const errMsg = err.response?.data?.message || err.response?.data?.Message || err.message || "Unknown error";
      setNotification({
        type: "error",
        message: "Permintaan gagal diproses. Silakan coba lagi nanti atau hubungi bantuan.",
        code: errMsg
      });
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleDelete = async (recordId) => {
    if (!window.confirm("Hapus data keluhan ini?")) return;
    try {
      await deleteKeluhan(recordId);
      setNotification({
        type: "success",
        message: "Data keluhan anak berhasil dihapus dari sistem!"
      });
      fetchData();
    } catch (err) {
      const errMsg = err.response?.data?.message || err.message || "Unknown error";
      setNotification({
        type: "error",
        message: "Permintaan gagal diproses. Silakan coba lagi nanti atau hubungi bantuan.",
        code: errMsg
      });
    }
  };

  return (
    <MainLayout>
      <AlertNotification 
        notification={notification} 
        onClose={() => setNotification(null)} 
        onRetry={notification?.type === "error" ? () => setNotification(null) : null}
      />
      <div className="p-4 md:p-8 bg-[#f8fafc] min-h-screen relative overflow-hidden">
        <div className="absolute top-0 right-0 w-[500px] h-[500px] bg-blue-400/5 rounded-full blur-[100px] -mr-64 -mt-64"></div>
        
        <div className="max-w-5xl mx-auto relative z-10">
          {/* Header */}
          <div className="mb-8">
            <button 
              onClick={() => navigate(`/data-anak/dashboard/${id}`)}
              className="flex items-center gap-2 px-6 py-2 border border-blue-600 text-blue-600 hover:bg-blue-50 rounded-full font-medium text-sm transition-all group w-fit mb-4 mt-2"
            >
              <ArrowLeft size={16} className="group-hover:-translate-x-1 transition-transform" /> Kembali
            </button>
            <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-6">
              <div className="flex items-center gap-5">
                <div className="w-14 h-14 bg-gradient-to-br from-blue-600 to-blue-400 rounded-2xl flex items-center justify-center shadow-lg shadow-blue-100">
                  <Stethoscope className="text-white w-7 h-7" />
                </div>
                <div>
                  <h1 className="text-2xl font-black text-slate-800 tracking-tight">Keluhan Anak</h1>
                  <p className="text-sm text-slate-500 font-bold mt-1 uppercase tracking-wider">Riwayat Keluhan & Tindakan</p>
                </div>
              </div>
              <button
                onClick={() => handleOpenModal()}
                className="bg-blue-600 hover:bg-blue-700 text-white px-6 py-3 rounded-xl font-bold text-sm shadow-xl shadow-blue-100 transition-all active:scale-95 flex items-center gap-2"
              >
                <Plus size={18} /> Tambah Keluhan
              </button>
            </div>
          </div>

          {/* List */}
          <div className="grid gap-4">
            {loading ? (
              <div className="py-20 text-center bg-white rounded-[32px] border border-slate-100">
                <Loader2 className="animate-spin mx-auto text-blue-600 mb-4" size={32} />
                <p className="text-slate-400 font-bold uppercase tracking-widest text-[10px]">Memuat data...</p>
              </div>
            ) : records.length === 0 ? (
              <div className="py-20 text-center bg-white rounded-[32px] border border-slate-100 shadow-sm">
                <MessageSquare className="mx-auto text-slate-100 mb-4" size={64} />
                <p className="text-slate-400 font-bold uppercase tracking-widest text-[10px]">Belum ada riwayat keluhan</p>
              </div>
            ) : (
              records.map((record) => (
                <div key={record.id} className="bg-white rounded-[28px] p-6 border border-slate-100 shadow-sm hover:shadow-md transition-all group">
                  <div className="flex flex-col md:flex-row justify-between gap-6">
                    <div className="flex-1">
                      <div className="flex items-center gap-3 mb-4">
                        <div className="px-3 py-1 bg-blue-50 text-blue-600 rounded-full text-[10px] font-black uppercase tracking-widest">
                          {new Date(record.tanggal).toLocaleDateString('id-ID', { day: '2-digit', month: 'long', year: 'numeric' })}
                        </div>
                        {record.pemeriksa && (
                          <div className="px-3 py-1 bg-slate-50 text-slate-400 rounded-full text-[10px] font-black uppercase tracking-widest">
                            Oleh: {record.pemeriksa}
                          </div>
                        )}
                      </div>
                      
                      <div className="space-y-4">
                        <div>
                          <p className="text-[10px] font-black text-slate-300 uppercase tracking-widest mb-1">Keluhan / Gejala</p>
                          <p className="text-slate-700 font-bold leading-relaxed">{record.keluhan}</p>
                        </div>
                        {record.tindakan && (
                          <div>
                            <p className="text-[10px] font-black text-blue-200 uppercase tracking-widest mb-1">Tindakan / Saran</p>
                            <p className="text-blue-600 font-bold leading-relaxed bg-blue-50/50 p-4 rounded-2xl border border-blue-50">{record.tindakan}</p>
                          </div>
                        )}
                      </div>
                    </div>

                    <div className="flex md:flex-col gap-2 shrink-0">
                      <button 
                        onClick={() => handleOpenModal(record)}
                        className="p-3 bg-slate-50 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded-2xl transition-all"
                      >
                        <Edit3 size={18} />
                      </button>
                      <button 
                        onClick={() => handleDelete(record.id)}
                        className="p-3 bg-slate-50 text-slate-400 hover:text-red-600 hover:bg-red-50 rounded-2xl transition-all"
                      >
                        <Trash2 size={18} />
                      </button>
                    </div>
                  </div>
                </div>
              ))
            )}
          </div>
        </div>
      </div>

      {/* Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 z-[999] flex items-center justify-center p-6">
          <div className="absolute inset-0 bg-slate-900/40 backdrop-blur-sm" onClick={() => setIsModalOpen(false)}></div>
          <div className="relative bg-white w-full max-w-lg rounded-[40px] p-8 shadow-2xl animate-in fade-in zoom-in duration-200">
            <div className="flex justify-between items-center mb-6">
              <h2 className="text-2xl font-black text-slate-800 tracking-tight">
                {editingId ? "Edit Keluhan" : "Tambah Keluhan"}
              </h2>
              <button onClick={() => setIsModalOpen(false)} className="text-slate-300 hover:text-slate-600 transition-all">
                <X size={24} />
              </button>
            </div>

            <form onSubmit={handleSubmit} className="space-y-5">
              <div>
                <label className="block text-[10px] font-black text-slate-400 uppercase tracking-widest mb-2 px-1">Tanggal Pemeriksaan</label>
                <div className="relative">
                  <Calendar className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-300" size={18} />
                  <input
                    type="date"
                    required
                    value={formData.tanggal}
                    onChange={(e) => setFormData({ ...formData, tanggal: e.target.value })}
                    className="w-full bg-slate-50 border border-slate-100 rounded-[20px] py-4 pl-12 pr-4 text-sm font-bold text-slate-700 outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-all"
                  />
                </div>
              </div>

              <div>
                <label className="block text-[10px] font-black text-slate-400 uppercase tracking-widest mb-2 px-1">Keluhan / Gejala</label>
                <textarea
                  required
                  placeholder="Deskripsikan keluhan atau gejala yang dialami anak..."
                  value={formData.keluhan}
                  onChange={(e) => setFormData({ ...formData, keluhan: e.target.value })}
                  className="w-full bg-slate-50 border border-slate-100 rounded-[20px] p-5 text-sm font-bold text-slate-700 outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-all min-h-[120px]"
                />
              </div>

              <div>
                <label className="block text-[10px] font-black text-slate-400 uppercase tracking-widest mb-2 px-1">Tindakan / Saran (Opsional)</label>
                <textarea
                  placeholder="Tindakan yang diberikan atau saran untuk orang tua..."
                  value={formData.tindakan}
                  onChange={(e) => setFormData({ ...formData, tindakan: e.target.value })}
                  className="w-full bg-slate-50 border border-slate-100 rounded-[20px] p-5 text-sm font-bold text-slate-700 outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-all min-h-[100px]"
                />
              </div>

              <div>
                <label className="block text-[10px] font-black text-slate-400 uppercase tracking-widest mb-2 px-1">Pemeriksa</label>
                <input
                  type="text"
                  placeholder="Nama Bidan / Kader"
                  value={formData.pemeriksa}
                  readOnly
                  className="w-full bg-slate-100 border border-slate-200 rounded-[20px] py-4 px-6 text-sm font-bold text-slate-500 cursor-not-allowed outline-none"
                />
              </div>

              <div className="pt-4 flex gap-3">
                <button
                  type="button"
                  onClick={() => setIsModalOpen(false)}
                  className="flex-1 bg-slate-100 text-slate-500 py-4 rounded-[20px] font-black text-xs uppercase tracking-widest hover:bg-slate-200 transition-all"
                >
                  Batal
                </button>
                <button
                  type="submit"
                  disabled={isSubmitting}
                  className="flex-[2] bg-blue-600 text-white py-4 rounded-[20px] font-black text-xs uppercase tracking-widest shadow-xl shadow-blue-100 hover:bg-blue-700 transition-all flex items-center justify-center gap-2 disabled:opacity-50"
                >
                  {isSubmitting ? <Loader2 className="animate-spin" size={18} /> : <Save size={18} />}
                  Simpan Data
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </MainLayout>
  );
};

export default KeluhanAnak;
