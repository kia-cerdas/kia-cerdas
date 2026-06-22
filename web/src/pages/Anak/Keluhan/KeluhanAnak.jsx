import React, { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { 
  Plus, X, Save, Loader2, Calendar, Stethoscope, 
  ChevronLeft, ArrowLeft, Trash2, Edit3, RefreshCw
} from "lucide-react";
import Swal from "sweetalert2";
import MainLayout from "../../../components/Layout/MainLayout";
import AlertNotification from "../../../components/AlertNotification";
import { 
  getKeluhanByAnakId, 
  createKeluhan, 
  updateKeluhan, 
  deleteKeluhan 
} from "../../../services/keluhanAnak";
import { getCurrentUser } from "../../../services/auth";

const inputClass =
  "w-full px-3.5 py-2.5 text-sm border border-slate-200 rounded-xl bg-white text-slate-800 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-500/30 focus:border-blue-500 transition-all";

const textareaClass =
  "w-full px-3.5 py-2.5 text-sm border border-slate-200 rounded-xl bg-white text-slate-800 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-500/30 focus:border-blue-500 transition-all resize-none";

function FormField({ label, children, hint, required }) {
  return (
    <div className="space-y-1.5">
      <label className="block text-[11px] font-bold text-slate-400 uppercase tracking-wider">
        {label}
        {required && <span className="text-red-500 ml-0.5">*</span>}
      </label>
      {children}
      {hint && <p className="text-xs text-slate-400 mt-1">{hint}</p>}
    </div>
  );
}

const KeluhanAnak = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [records, setRecords] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [editingId, setEditingId] = useState(null);
  const [notification, setNotification] = useState(null);

  const user = getCurrentUser();
  const loginName = user?.nama || user?.name || "";

  const [formData, setFormData] = useState({
    tanggal: new Date().toISOString().split('T')[0],
    keluhan: "",
    tindakan: "",
    pemeriksa: ""
  });

  const resetForm = () => {
    setEditingId(null);
    setFormData({
      tanggal: new Date().toISOString().split('T')[0],
      keluhan: "",
      tindakan: "",
      pemeriksa: loginName
    });
    setShowForm(false);
  };

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

  const handleOpenForm = (item = null) => {
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
    setShowForm(true);
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
      resetForm();
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
    const result = await Swal.fire({
      title: "Hapus Data Keluhan?",
      text: "Data yang sudah dihapus tidak dapat dikembalikan!",
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#A32D2D",
      cancelButtonColor: "#6B7280",
      confirmButtonText: "Ya, Hapus!",
      cancelButtonText: "Batal",
    });
    if (!result.isConfirmed) return;
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
        
        <div className="max-w-5xl mx-auto relative z-10 space-y-5">
          {/* Header */}
          <div className="mb-2">
            <button 
              onClick={() => navigate(`/data-anak/dashboard/${id}`)}
              className="inline-flex items-center gap-2 px-4 py-2 bg-[#185FA5] hover:bg-[#185FA5]/90 text-white rounded-xl font-semibold text-sm transition-all active:scale-95 shadow-sm w-fit mb-4 mt-2"
            >
              <ArrowLeft size={16} /> Kembali
            </button>
            <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-6">
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 bg-[#185FA5] rounded-xl flex items-center justify-center text-white shadow-md flex-shrink-0">
                  <Stethoscope size={22} />
                </div>
                <div>
                  <h1 className="text-xl font-bold text-slate-800">Keluhan Anak</h1>
                  <p className="text-sm text-slate-500 mt-0.5">Riwayat Keluhan & Tindakan</p>
                </div>
              </div>
              {!showForm && (
                <button
                  onClick={() => handleOpenForm()}
                  className="flex items-center gap-2 bg-[#185FA5] hover:bg-[#185FA5]/90 text-white px-5 py-2.5 rounded-xl font-semibold text-sm shadow-sm transition-all active:scale-95"
                >
                  <Plus size={18} /> Tambah Keluhan
                </button>
              )}
            </div>
          </div>

          {/* Inline Form */}
          {showForm && (
            <section className="bg-white rounded-2xl border border-slate-200 shadow-sm">
              <div className="px-6 py-5 flex items-center justify-between border-b border-slate-100">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-xl bg-[#185FA5]/10 flex items-center justify-center">
                    <Stethoscope size={20} className="text-[#185FA5]" />
                  </div>
                  <div>
                    <h2 className="text-base font-bold text-slate-800 leading-tight">
                      {editingId ? "Edit Keluhan" : "Tambah Keluhan"}
                    </h2>
                    <p className="text-xs text-slate-400 mt-0.5">
                      {editingId
                        ? "Perbarui riwayat keluhan dan tindakan anak."
                        : "Catat keluhan atau gejala yang dialami anak."}
                    </p>
                  </div>
                </div>
                <button
                  type="button"
                  onClick={resetForm}
                  className="p-2 rounded-xl hover:bg-slate-100 text-slate-400 hover:text-slate-600 transition-colors"
                >
                  <X size={20} />
                </button>
              </div>
              <form onSubmit={handleSubmit} className="p-6 space-y-6">
                <FormField label="Tanggal Pemeriksaan" required>
                  <input
                    type="date"
                    required
                    value={formData.tanggal}
                    onChange={(e) => setFormData({ ...formData, tanggal: e.target.value })}
                    className={inputClass}
                  />
                </FormField>

                <FormField label="Keluhan / Gejala" required>
                  <textarea
                    required
                    rows={4}
                    placeholder="Deskripsikan keluhan atau gejala yang dialami anak..."
                    value={formData.keluhan}
                    onChange={(e) => setFormData({ ...formData, keluhan: e.target.value })}
                    className={textareaClass}
                  />
                </FormField>

                <FormField
                  label="Tindakan / Saran (Opsional)"
                  hint="Tindakan yang diberikan atau saran untuk orang tua."
                >
                  <textarea
                    rows={3}
                    placeholder="Tindakan yang diberikan atau saran untuk orang tua..."
                    value={formData.tindakan}
                    onChange={(e) => setFormData({ ...formData, tindakan: e.target.value })}
                    className={textareaClass}
                  />
                </FormField>

                <FormField label="Pemeriksa">
                  <input
                    type="text"
                    placeholder="Nama Bidan / Kader"
                    value={formData.pemeriksa}
                    readOnly
                    className={`${inputClass} bg-slate-50 cursor-not-allowed`}
                  />
                </FormField>

                <div className="flex items-center gap-3 pt-4 border-t border-slate-100">
                  <button
                    type="submit"
                    disabled={isSubmitting}
                    className="flex items-center gap-2 px-6 py-2.5 bg-[#185FA5] hover:bg-[#185FA5]/90 disabled:opacity-50 text-white text-sm font-semibold rounded-xl transition-all active:scale-95 shadow-sm"
                  >
                    {isSubmitting ? (
                      <>
                        <Loader2 size={15} className="animate-spin" />
                        Menyimpan...
                      </>
                    ) : (
                      <>
                        <Save size={15} />
                        {editingId ? "Update Data" : "Simpan Data"}
                      </>
                    )}
                  </button>
                  <button
                    type="button"
                    onClick={resetForm}
                    disabled={isSubmitting}
                    className="px-5 py-2.5 text-sm font-semibold text-slate-500 hover:text-slate-600 hover:bg-slate-50 rounded-xl transition-colors disabled:opacity-50"
                  >
                    Batal
                  </button>
                </div>
              </form>
            </section>
          )}

          {/* List */}
          <div className="grid gap-4">
            {loading ? (
              <div className="py-20 text-center bg-white rounded-2xl border border-slate-200 shadow-sm">
                <Loader2 className="animate-spin mx-auto text-blue-600 mb-4" size={32} />
                <p className="text-sm text-slate-400 font-medium">Memuat data...</p>
              </div>
            ) : records.length === 0 ? (
              <div className="py-20 text-center bg-white rounded-2xl border border-slate-200 shadow-sm">
                <Stethoscope className="mx-auto text-slate-200 mb-4" size={64} />
                <p className="text-sm text-slate-400 font-medium">Belum ada riwayat keluhan</p>
              </div>
            ) : (
              records.map((record) => (
                <div key={record.id} className="bg-white rounded-2xl p-6 border border-slate-200 shadow-sm hover:shadow-md transition-all group">
                  <div className="flex flex-col md:flex-row justify-between gap-6">
                    <div className="flex-1">
                      <div className="flex items-center gap-3 mb-4">
                        <div className="px-3 py-1 bg-blue-50 text-blue-600 rounded-full text-xs font-semibold">
                          {new Date(record.tanggal).toLocaleDateString('id-ID', { day: '2-digit', month: 'long', year: 'numeric' })}
                        </div>
                        {record.pemeriksa && (
                          <div className="px-3 py-1 bg-slate-50 text-slate-400 rounded-full text-xs font-semibold">
                            Oleh: {record.pemeriksa}
                          </div>
                        )}
                      </div>
                      
                      <div className="space-y-4">
                        <div>
                          <p className="text-xs font-semibold text-slate-400 mb-1">Keluhan / Gejala</p>
                          <p className="text-slate-700 font-medium leading-relaxed">{record.keluhan}</p>
                        </div>
                        {record.tindakan && (
                          <div>
                            <p className="text-xs font-semibold text-blue-400 mb-1">Tindakan / Saran</p>
                            <p className="text-blue-600 font-medium leading-relaxed bg-blue-50/50 p-4 rounded-2xl border border-blue-50">{record.tindakan}</p>
                          </div>
                        )}
                      </div>
                    </div>

                    <div className="flex md:flex-col gap-2 shrink-0">
                      <button 
                        onClick={() => handleOpenForm(record)}
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
    </MainLayout>
  );
};

export default KeluhanAnak;
