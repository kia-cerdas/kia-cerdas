// src/pages/Ibu/CatatanPelayanan.jsx
import React, { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import Swal from "sweetalert2";
import MainLayout from "../../components/Layout/MainLayout";
import { getKehamilanByIbuId } from "../../services/kehamilan";
import {
  catatanT1,
  catatanT2,
  catatanT3,
  catatanNifas,
} from "../../services/catatanPelayanan";
import { Save, Plus, Trash2, AlertCircle } from "lucide-react";

const services = {
  T1: catatanT1,
  T2: catatanT2,
  T3: catatanT3,
  Nifas: catatanNifas,
};
const tabLabels = {
  T1: "Trimester 1",
  T2: "Trimester 2",
  T3: "Trimester 3",
  Nifas: "Nifas",
};

// Helper fungsi validasi tanggal
const isDateAfterToday = (dateStr) => {
  if (!dateStr) return false;
  const today = new Date().toISOString().split("T")[0];
  return dateStr > today;
};

export default function CatatanPelayanan() {
  const { id } = useParams();
  const [kehamilan, setKehamilan] = useState(null);
  const [activeTab, setActiveTab] = useState("T1");
  const [records, setRecords] = useState([]);
  const [form, setForm] = useState({
    tanggal_periksa_stamp_paraf: "",
    keluhan_pemeriksaan_tindakan_saran: "",
    tanggal_kembali: "",
  });
  const [validationErrors, setValidationErrors] = useState({});
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState(null);
  const [successMessage, setSuccessMessage] = useState(null);
  const [deleteLoading, setDeleteLoading] = useState(null);

  // Helper untuk mendapatkan field ID yang tepat berdasarkan tab
  const getIdFieldName = (tab) => {
    if (tab === "Nifas") return "id_catatan_nifas";
    if (tab === "T3") return "id_catatan_t3";
    return "id_catatan";
  };

  // Fungsi validasi form
  const validateForm = () => {
    const errors = {};

    // Validasi Tanggal Periksa - WAJIB DIISI & TIDAK BOLEH MELEBIHI HARI INI
    if (!form.tanggal_periksa_stamp_paraf) {
      errors.tanggal_periksa_stamp_paraf = "Tanggal periksa harus diisi";
    } else if (isDateAfterToday(form.tanggal_periksa_stamp_paraf)) {
      errors.tanggal_periksa_stamp_paraf =
        "Tanggal periksa tidak boleh melebihi hari ini";
    }

    // Validasi Keluhan - WAJIB DIISI
    if (!form.keluhan_pemeriksaan_tindakan_saran?.trim()) {
      errors.keluhan_pemeriksaan_tindakan_saran =
        "Keluhan / pemeriksaan / tindakan / saran harus diisi";
    }

    // ✅ Validasi Tanggal Kembali - WAJIB DIISI
    if (!form.tanggal_kembali) {
      errors.tanggal_kembali = "Tanggal kembali harus diisi";
    }

    return errors;
  };

  // Fetch kehamilan dan catatan saat komponen mount atau tab berubah
  useEffect(() => {
    const fetchData = async () => {
      setLoading(true);
      setError(null);
      try {
        const kehamilanList = await getKehamilanByIbuId(id);
        if (kehamilanList.length > 0) {
          const aktif = kehamilanList[0];
          setKehamilan(aktif);

          // Fetch catatan untuk trimester aktif
          const svc = services[activeTab];
          const data = await svc.getByKehamilanId(aktif.id);
          setRecords(data || []);
        } else {
          setError("Data kehamilan tidak ditemukan");
        }
      } catch (err) {
        console.error("Error fetching data:", err);
        setError("Gagal memuat data. Silakan coba lagi.");
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, [id, activeTab]);

  // Handler perubahan input form
  const handleChange = (e) => {
    const { name, value } = e.target;
    setForm((prev) => ({ ...prev, [name]: value }));
    // Hapus error field yang sedang diubah
    if (validationErrors[name]) {
      setValidationErrors((prev) => {
        const newErrors = { ...prev };
        delete newErrors[name];
        return newErrors;
      });
    }
    setError(null);
  };

  // Handler submit form - CREATE catatan baru
  const handleSubmit = async (e) => {
    e.preventDefault();

    if (!kehamilan) {
      setError("Data kehamilan tidak ditemukan");
      return;
    }

    // Validasi input
    const errors = validateForm();
    if (Object.keys(errors).length > 0) {
      setValidationErrors(errors);
      setError("Mohon lengkapi data yang wajib diisi dengan benar.");
      return;
    }

    setSaving(true);
    setError(null);
    try {
      const svc = services[activeTab];
      const payload = {
        ...form,
        kehamilan_id: kehamilan.id,
      };

      // Call API create
      const created = await svc.create(payload);

      // Tambahkan data yang baru dibuat ke dalam list
      setRecords((prev) => [created, ...prev]);

      // Reset form
      setForm({
        tanggal_periksa_stamp_paraf: "",
        keluhan_pemeriksaan_tindakan_saran: "",
        tanggal_kembali: "",
      });
      setValidationErrors({});

      setSuccessMessage("Catatan pelayanan berhasil ditambahkan");
      setTimeout(() => setSuccessMessage(null), 3000);
    } catch (err) {
      console.error("Error creating catatan:", err);
      setError(
        "Gagal menyimpan catatan: " +
          (err.response?.data?.message || err.message),
      );
    } finally {
      setSaving(false);
    }
  };

  // Handler DELETE catatan
  const handleDelete = async (recordId) => {
    const result = await Swal.fire({
      title: "Hapus Catatan?",
      text: "Yakin ingin menghapus catatan ini?",
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#dc2626",
      cancelButtonColor: "#6b7280",
      confirmButtonText: "Ya, Hapus!",
      cancelButtonText: "Batal",
    });

    if (!result.isConfirmed) return;

    setDeleteLoading(recordId);
    setError(null);
    try {
      const svc = services[activeTab];
      await svc.delete(recordId);

      // Hapus dari state setelah Delete berhasil
      setRecords((prev) =>
        prev.filter((r) => r[getIdFieldName(activeTab)] !== recordId),
      );

      setSuccessMessage("Catatan berhasil dihapus");
      setTimeout(() => setSuccessMessage(null), 3000);
    } catch (err) {
      console.error("Error deleting catatan:", err);
      setError(
        "Gagal menghapus catatan: " +
          (err.response?.data?.message || err.message),
      );
    } finally {
      setDeleteLoading(null);
    }
  };

  const idKey = getIdFieldName(activeTab);

  if (loading) {
    return (
      <MainLayout>
        <div className="p-6 text-center">
          <div className="inline-block">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-indigo-600"></div>
            <p className="mt-2 text-gray-600">Memuat data...</p>
          </div>
        </div>
      </MainLayout>
    );
  }

  return (
    <MainLayout>
      <div className="p-6 max-w-5xl mx-auto">
        <h1 className="text-2xl font-bold mb-2">Catatan Pelayanan</h1>
        <p className="text-gray-500 mb-6">
          Catatan kunjungan pelayanan per trimester dan nifas.
        </p>

        {/* Pesan error */}
        {error && (
          <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-lg flex items-start gap-3">
            <AlertCircle
              className="text-red-500 flex-shrink-0 mt-0.5"
              size={18}
            />
            <p className="text-red-700 text-sm">{error}</p>
          </div>
        )}

        {/* Pesan sukses */}
        {successMessage && (
          <div className="mb-6 p-4 bg-green-50 border border-green-200 rounded-lg">
            <p className="text-green-700 text-sm font-medium">
              {successMessage}
            </p>
          </div>
        )}

        {/* Tab buttons */}
        <div className="flex gap-2 mb-6 border-b">
          {Object.keys(tabLabels).map((tab) => (
            <button
              key={tab}
              onClick={() => {
                setActiveTab(tab);
                setError(null);
                setSuccessMessage(null);
                setValidationErrors({});
              }}
              className={`px-4 py-2 font-medium transition-colors ${
                activeTab === tab
                  ? "border-b-2 border-indigo-600 text-indigo-600"
                  : "text-gray-500 hover:text-gray-700"
              }`}
            >
              {tabLabels[tab]}
            </button>
          ))}
        </div>

        {/* Tabel Catatan - Riwayat */}
        <div className="bg-white rounded-xl shadow-sm p-6 mb-6 border border-gray-100">
          <h3 className="font-semibold text-lg mb-4">
            Riwayat Catatan - {tabLabels[activeTab]}
          </h3>

          {records.length > 0 ? (
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                      No
                    </th>
                    <th className="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                      Tanggal Periksa
                    </th>
                    <th className="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                      Keluhan / Pemeriksaan / Tindakan / Saran
                    </th>
                    <th className="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                      Tanggal Kembali
                    </th>
                    <th className="px-4 py-3 text-center text-xs font-semibold text-gray-700 uppercase tracking-wider">
                      Aksi
                    </th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-100">
                  {records.map((r, idx) => (
                    <tr
                      key={r[idKey] || idx}
                      className="hover:bg-gray-50 transition-colors"
                    >
                      <td className="px-4 py-3 text-sm font-medium text-gray-900">
                        {idx + 1}
                      </td>
                      <td className="px-4 py-3 text-sm text-gray-600">
                        {r.tanggal_periksa_stamp_paraf
                          ? new Date(
                              r.tanggal_periksa_stamp_paraf,
                            ).toLocaleDateString("id-ID", {
                              year: "numeric",
                              month: "short",
                              day: "numeric",
                            })
                          : "-"}
                      </td>
                      <td className="px-4 py-3 text-sm text-gray-600 whitespace-pre-wrap max-w-xs">
                        {r.keluhan_pemeriksaan_tindakan_saran || "-"}
                      </td>
                      <td className="px-4 py-3 text-sm text-gray-600">
                        {r.tanggal_kembali
                          ? new Date(r.tanggal_kembali).toLocaleDateString(
                              "id-ID",
                              {
                                year: "numeric",
                                month: "short",
                                day: "numeric",
                              },
                            )
                          : "-"}
                      </td>
                      <td className="px-4 py-3 text-center">
                        <button
                          onClick={() => handleDelete(r[idKey])}
                          disabled={deleteLoading === r[idKey]}
                          className="inline-flex items-center gap-1 px-3 py-1 text-sm text-red-600 hover:bg-red-50 rounded transition-colors disabled:opacity-50"
                        >
                          {deleteLoading === r[idKey] ? (
                            <>
                              <div className="animate-spin rounded-full h-3 w-3 border-1 border-red-600 border-t-transparent"></div>
                              Hapus...
                            </>
                          ) : (
                            <>
                              <Trash2 size={14} />
                              Hapus
                            </>
                          )}
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          ) : (
            <p className="text-gray-500 text-sm text-center py-8">
              Belum ada catatan pelayanan {tabLabels[activeTab]}.
            </p>
          )}
        </div>

        {/* Form Tambah Catatan */}
        <form
          onSubmit={handleSubmit}
          className="bg-white rounded-xl shadow-sm p-6 border border-gray-100 space-y-4"
        >
          <h3 className="font-semibold text-lg">
            Tambah Catatan Baru - {tabLabels[activeTab]}
          </h3>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-semibold text-gray-700 mb-2">
                Tanggal Periksa / Stempel / Paraf{" "}
                <span className="text-red-500">*</span>
              </label>
              <input
                type="date"
                name="tanggal_periksa_stamp_paraf"
                value={form.tanggal_periksa_stamp_paraf}
                onChange={handleChange}
                max={new Date().toISOString().split("T")[0]}
                className={`w-full border rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent ${
                  validationErrors.tanggal_periksa_stamp_paraf
                    ? "border-red-500 bg-red-50"
                    : "border-gray-300"
                }`}
              />
              {validationErrors.tanggal_periksa_stamp_paraf && (
                <p className="text-xs text-red-500 font-medium mt-1">
                  {validationErrors.tanggal_periksa_stamp_paraf}
                </p>
              )}
            </div>
            <div>
              <label className="block text-sm font-semibold text-gray-700 mb-2">
                Tanggal Kembali <span className="text-red-500">*</span>
              </label>
              <input
                type="date"
                name="tanggal_kembali"
                value={form.tanggal_kembali}
                onChange={handleChange}
                required
                className={`w-full border rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent ${
                  validationErrors.tanggal_kembali
                    ? "border-red-500 bg-red-50"
                    : "border-gray-300"
                }`}
              />
              {validationErrors.tanggal_kembali && (
                <p className="text-xs text-red-500 font-medium mt-1">
                  {validationErrors.tanggal_kembali}
                </p>
              )}
            </div>
          </div>

          <div>
            <label className="block text-sm font-semibold text-gray-700 mb-2">
              Keluhan / Pemeriksaan / Tindakan / Saran{" "}
              <span className="text-red-500">*</span>
            </label>
            <textarea
              name="keluhan_pemeriksaan_tindakan_saran"
              value={form.keluhan_pemeriksaan_tindakan_saran}
              onChange={handleChange}
              className={`w-full border rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent ${
                validationErrors.keluhan_pemeriksaan_tindakan_saran
                  ? "border-red-500 bg-red-50"
                  : "border-gray-300"
              }`}
              rows="5"
              placeholder="Tuliskan keluhan, hasil pemeriksaan, tindakan yang dilakukan, dan saran untuk pasien..."
            />
            {validationErrors.keluhan_pemeriksaan_tindakan_saran && (
              <p className="text-xs text-red-500 font-medium mt-1">
                {validationErrors.keluhan_pemeriksaan_tindakan_saran}
              </p>
            )}
          </div>

          <button
            type="submit"
            disabled={saving}
            className="bg-indigo-600 hover:bg-indigo-700 disabled:opacity-50 text-white px-6 py-2 rounded-lg flex items-center gap-2 font-medium transition-colors"
          >
            {saving ? (
              <>
                <div className="animate-spin rounded-full h-4 w-4 border-2 border-white border-t-transparent"></div>
                Menyimpan...
              </>
            ) : (
              <>
                <Plus size={18} />
                Tambah Catatan
              </>
            )}
          </button>
        </form>
      </div>
    </MainLayout>
  );
}
