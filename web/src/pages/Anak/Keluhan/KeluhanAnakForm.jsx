import React, { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import {
  ArrowLeft,
  Calendar,
  MessageSquare,
  Save,
  RefreshCw,
  AlertCircle,
} from "lucide-react";
import MainLayout from "../../../components/Layout/MainLayout";
import AlertNotification from "../../../components/AlertNotification";
import {
  getKeluhanByAnakId,
  createKeluhan,
  updateKeluhan,
} from "../../../services/keluhanAnak";
import { getCurrentUser } from "../../../services/auth";

const inputClass =
  "w-full px-3.5 py-2.5 text-sm border border-slate-200 rounded-xl bg-white text-slate-800 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-500/30 focus:border-blue-500 transition-all";

const textareaClass =
  "w-full px-3.5 py-2.5 text-sm border border-slate-200 rounded-xl bg-white text-slate-800 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-500/30 focus:border-blue-500 transition-all resize-none";

function FormField({ label, icon: Icon, children, hint, required }) {
  return (
    <div className="space-y-1.5">
      <label className="flex items-center gap-1.5 text-sm font-semibold text-slate-700">
        {Icon && <Icon size={14} className="text-slate-400" />}
        {label}
        {required && <span className="text-red-500">*</span>}
      </label>
      {children}
      {hint && <p className="text-xs text-slate-400">{hint}</p>}
    </div>
  );
}

export default function KeluhanAnakForm() {
  const { id, recordId } = useParams();
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  const [fetching, setFetching] = useState(false);
  const [notification, setNotification] = useState(null);
  const user = getCurrentUser();
  const [formData, setFormData] = useState({
    tanggal: new Date().toISOString().split("T")[0],
    keluhan: "",
    tindakan: "",
    pemeriksa: user?.nama || user?.name || "",
  });

  const isEdit = Boolean(recordId);

  useEffect(() => {
    if (!isEdit) return;

    const fetchRecord = async () => {
      setFetching(true);
      try {
        const res = await getKeluhanByAnakId(id);
        const records = res.data || [];
        const record = records.find((r) => String(r.id) === recordId);
        if (record) {
          setFormData({
            tanggal: record.tanggal
              ? record.tanggal.split("T")[0]
              : new Date().toISOString().split("T")[0],
            keluhan: record.keluhan || "",
            tindakan: record.tindakan || "",
            pemeriksa: record.pemeriksa || user?.nama || user?.name || "",
          });
        } else {
          setNotification({
            type: "error",
            message: "Data keluhan tidak ditemukan.",
          });
        }
      } catch (err) {
        console.error("Fetch error:", err);
        setNotification({
          type: "error",
          message: "Gagal memuat data keluhan.",
        });
      } finally {
        setFetching(false);
      }
    };

    fetchRecord();
  }, [id, recordId, isEdit]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);

    const payload = {
      anak_id: Number(id),
      tanggal: new Date(formData.tanggal).toISOString(),
      keluhan: formData.keluhan,
      tindakan: formData.tindakan,
      pemeriksa: formData.pemeriksa,
    };

    try {
      if (isEdit) {
        await updateKeluhan(recordId, payload);
        setNotification({
          type: "success",
          message: "Data keluhan anak berhasil diperbarui.",
        });
      } else {
        await createKeluhan(payload);
        setNotification({
          type: "success",
          message: "Data keluhan anak berhasil disimpan.",
        });
      }
      setTimeout(() => navigate(`/data-anak/keluhan/${id}`), 1200);
    } catch (err) {
      console.error("Save error:", err);
      const errMsg =
        err.response?.data?.message ||
        err.response?.data?.Message ||
        err.message ||
        "Unknown error";
      setNotification({
        type: "error",
        message: "Permintaan gagal diproses. Silakan coba lagi nanti.",
        code: errMsg,
      });
    } finally {
      setLoading(false);
    }
  };

  return (
    <MainLayout>
      <AlertNotification
        notification={notification}
        onClose={() => setNotification(null)}
        onRetry={
          notification?.type === "error" ? () => setNotification(null) : null
        }
      />
      <div className="p-4 md:p-8 bg-[#f8fafc] min-h-screen">
        <div className="max-w-3xl mx-auto space-y-5">
          {/* Header Card */}
          <section className="bg-white rounded-2xl border border-slate-200 shadow-sm">
            <div className="px-6 py-5 flex items-center gap-4">
              <button
                type="button"
                onClick={() => navigate(`/data-anak/keluhan/${id}`)}
                className="p-2 rounded-xl hover:bg-slate-100 text-slate-500 hover:text-slate-700 transition-colors"
              >
                <ArrowLeft size={18} />
              </button>
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-xl bg-blue-50 flex items-center justify-center">
                  <MessageSquare size={20} className="text-blue-600" />
                </div>
                <div>
                  <h1 className="text-xl font-bold text-slate-800 leading-tight">
                    {isEdit ? "Edit Keluhan" : "Tambah Keluhan"}
                  </h1>
                  <p className="text-sm text-slate-400 mt-0.5">
                    {isEdit
                      ? "Perbarui riwayat keluhan dan tindakan anak."
                      : "Catat keluhan atau gejala yang dialami anak."}
                  </p>
                </div>
              </div>
            </div>
          </section>

          {/* Form Card */}
          <section className="bg-white rounded-2xl border border-slate-200 shadow-sm">
            {fetching ? (
              <div className="flex flex-col items-center justify-center py-20 gap-3">
                <div className="w-10 h-10 rounded-full border-2 border-blue-500/20 border-t-blue-500 animate-spin" />
                <p className="text-sm text-slate-400 font-medium">Memuat data...</p>
              </div>
            ) : (
              <form onSubmit={handleSubmit} className="p-6 space-y-6">
                <FormField label="Tanggal Pemeriksaan" icon={Calendar} required>
                  <input
                    type="date"
                    name="tanggal"
                    required
                    value={formData.tanggal}
                    onChange={handleChange}
                    className={inputClass}
                  />
                </FormField>

                <FormField
                  label="Keluhan / Gejala"
                  icon={MessageSquare}
                  required
                >
                  <textarea
                    name="keluhan"
                    required
                    rows={4}
                    placeholder="Deskripsikan keluhan atau gejala yang dialami anak..."
                    value={formData.keluhan}
                    onChange={handleChange}
                    className={textareaClass}
                  />
                </FormField>

                <FormField
                  label="Tindakan / Saran"
                  icon={MessageSquare}
                  hint="Opsional — tindakan yang diberikan atau saran untuk orang tua."
                >
                  <textarea
                    name="tindakan"
                    rows={3}
                    placeholder="Tindakan yang diberikan atau saran untuk orang tua..."
                    value={formData.tindakan}
                    onChange={handleChange}
                    className={textareaClass}
                  />
                </FormField>

                <FormField label="Pemeriksa" icon={MessageSquare}>
                  <input
                    type="text"
                    name="pemeriksa"
                    placeholder="Nama Bidan / Kader"
                    value={formData.pemeriksa}
                    onChange={handleChange}
                    className={inputClass}
                  />
                </FormField>

                {notification?.type === "error" && (
                  <div className="flex items-start gap-3 px-4 py-3 bg-red-50 border border-red-100 rounded-xl">
                    <AlertCircle size={16} className="text-red-600 mt-0.5 shrink-0" />
                    <p className="text-sm text-red-600 leading-relaxed">
                      {notification.message}
                      {notification.code && (
                        <span className="block text-xs mt-1 opacity-80">
                          {notification.code}
                        </span>
                      )}
                    </p>
                  </div>
                )}

                {/* Action buttons */}
                <div className="flex items-center gap-3 pt-2 border-t border-slate-100">
                  <button
                    type="submit"
                    disabled={loading}
                    className="flex items-center gap-2 px-5 py-2.5 bg-blue-600 hover:bg-blue-700 disabled:bg-blue-600/60 text-white text-sm font-semibold rounded-xl transition-colors"
                  >
                    {loading ? (
                      <>
                        <RefreshCw size={15} className="animate-spin" />
                        Menyimpan...
                      </>
                    ) : (
                      <>
                        <Save size={15} />
                        {isEdit ? "Update Data" : "Simpan Data"}
                      </>
                    )}
                  </button>
                  <button
                    type="button"
                    onClick={() => navigate(`/data-anak/keluhan/${id}`)}
                    disabled={loading}
                    className="px-5 py-2.5 text-sm font-semibold text-slate-600 bg-slate-100 hover:bg-slate-200 rounded-xl transition-colors disabled:opacity-50"
                  >
                    Batal
                  </button>
                </div>
              </form>
            )}
          </section>
        </div>
      </div>
    </MainLayout>
  );
}
