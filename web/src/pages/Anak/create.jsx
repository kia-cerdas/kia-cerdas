import React, { useEffect, useState } from "react";
import MainLayout from "../../components/Layout/MainLayout";
import { createAnak } from "../../services/Anak";
import { getIbuList } from "../../services/ibu";
import { getKehamilanByIbuId } from "../../services/kehamilan";
import { useNavigate } from "react-router-dom";
import { UserPlus, CheckCircle2, AlertCircle } from "lucide-react";

export default function CreateAnak() {
  const navigate = useNavigate();
  const [ibuList, setIbuList] = useState([]);
  const [kehamilanList, setKehamilanList] = useState([]);
  const [loading, setLoading] = useState(false);
  const [fetchingKehamilan, setFetchingKehamilan] = useState(false);
  const [errors, setErrors] = useState({});
  const [generalError, setGeneralError] = useState("");

  const [form, setForm] = useState({
    nama: "",
    jenis_kelamin: "",
    tanggal_lahir: "",
    berat_lahir_kg: "",
    ibu_id: "",
    kehamilan_id: "",
    tempat_lahir: "",
    anak_ke: "",
  });

  // Load daftar ibu saat page pertama kali dibuka
  useEffect(() => {
    const fetchIbu = async () => {
      try {
        const data = await getIbuList();
        setIbuList(data);
      } catch (err) {
        console.error("Detail Error:", err);
        setGeneralError("Gagal mengambil data ibu.");
      }
    };
    fetchIbu();
  }, []);

  // Load kehamilan saat ibu dipilih
  const handleIbuChange = async (e) => {
    const ibuId = e.target.value;
    setForm({ ...form, ibu_id: ibuId, kehamilan_id: "" });

    if (ibuId) {
      setFetchingKehamilan(true);
      try {
        const data = await getKehamilanByIbuId(Number(ibuId));
        setKehamilanList(data);
      } catch (err) {
        console.error("Detail Error:", err);
        setKehamilanList([]);
        setGeneralError("Gagal mengambil data kehamilan ibu.");
      } finally {
        setFetchingKehamilan(false);
      }
    } else {
      setKehamilanList([]);
    }

    if (errors.ibu_id) {
      setErrors((prev) => ({ ...prev, ibu_id: "" }));
    }
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setForm({ ...form, [name]: value });
    // Menghapus error saat user mulai mengetik
    if (errors[name]) {
      setErrors((prev) => {
        const newErrors = { ...prev };
        delete newErrors[name];
        return newErrors;
      });
    }
  };

  const validateForm = () => {
    let tempErrors = {};
    if (!form.ibu_id) tempErrors.ibu_id = "Pilih ibu terlebih dahulu.";
    if (!form.kehamilan_id)
      tempErrors.kehamilan_id = "Pilih data kehamilan ibu.";
    if (!form.nama.trim()) tempErrors.nama = "Nama anak wajib diisi.";
    if (!form.tanggal_lahir)
      tempErrors.tanggal_lahir = "Tanggal lahir wajib diisi.";
    if (!form.jenis_kelamin)
      tempErrors.jenis_kelamin = "Pilih jenis kelamin anak.";

    setErrors(tempErrors);
    return Object.keys(tempErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setGeneralError("");
    if (!validateForm()) return;

    setLoading(true);
    try {
      const payload = {
        nama: form.nama,
        jenis_kelamin: form.jenis_kelamin,
        tanggal_lahir: form.tanggal_lahir,
        berat_lahir_kg: parseFloat(form.berat_lahir_kg) || 0,
        kehamilan_id: Number(form.kehamilan_id),
        tempat_lahir: form.tempat_lahir,
        anak_ke: form.anak_ke,
      };
      await createAnak(payload);
      alert("Data anak berhasil disimpan.");
      navigate("/Daftar-Anak");
    } catch (err) {
      setGeneralError("Terjadi kesalahan sistem. Silakan coba lagi.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <MainLayout>
      <div className="min-h-screen bg-gray-50 flex flex-col items-center py-10 px-4">
        <div className="max-w-5xl w-full grid grid-cols-1 lg:grid-cols-3 gap-8">
          <div className="lg:col-span-2 bg-white rounded-3xl p-8 shadow-sm border border-gray-100">
            {/* Pesan Error Umum */}
            {generalError && (
              <div className="mb-6 p-4 bg-red-50 border border-red-200 text-red-600 rounded-xl flex items-center gap-2">
                <AlertCircle size={20} />
                <span className="text-sm font-medium">{generalError}</span>
              </div>
            )}

            <form onSubmit={handleSubmit} className="space-y-6">
              {/* Data Orangtua - Pilih Ibu Dulu */}
              <div className="space-y-4 p-4 bg-blue-50 rounded-xl border border-blue-200">
                <div className="flex items-center gap-2 text-gray-800 font-bold">
                  <UserPlus size={20} className="text-blue-600" />
                  <span>Data Orangtua</span>
                </div>

                {/* Pilih Ibu */}
                <div>
                  <label className="block text-[12px] font-bold text-gray-500 tracking-wider uppercase mb-2">
                    Nama Ibu <span className="text-red-500">*</span>
                  </label>
                  <select
                    name="ibu_id"
                    value={form.ibu_id}
                    onChange={handleIbuChange}
                    className={`w-full p-4 bg-white border rounded-xl outline-none transition-all ${
                      errors.ibu_id
                        ? "border-red-500 focus:ring-red-200"
                        : "border-gray-200 focus:ring-blue-500 focus:ring-2"
                    }`}
                  >
                    <option value="">-- Pilih Ibu --</option>
                    {Array.isArray(ibuList) &&
                      ibuList.map((ibu) => (
                        <option key={ibu.id_ibu} value={ibu.id_ibu}>
                          {ibu.kependudukan?.nama_lengkap ||
                            "Nama tidak ditemukan"}
                        </option>
                      ))}
                  </select>
                  {errors.ibu_id && (
                    <p className="mt-1 text-xs text-red-500 font-medium flex items-center gap-1">
                      <AlertCircle size={12} /> {errors.ibu_id}
                    </p>
                  )}
                </div>

                {/* Pilih Kehamilan */}
                {form.ibu_id && (
                  <div>
                    <label className="block text-[12px] font-bold text-gray-500 tracking-wider uppercase mb-2">
                      Data Kehamilan <span className="text-red-500">*</span>
                    </label>
                    {fetchingKehamilan ? (
                      <div className="p-4 bg-gray-100 rounded-xl text-gray-600 text-sm">
                        Memuat data kehamilan...
                      </div>
                    ) : kehamilanList.length === 0 ? (
                      <div className="p-4 bg-yellow-50 rounded-xl text-yellow-700 text-sm border border-yellow-200">
                        Ibu ini belum memiliki data kehamilan. Silakan buat
                        kehamilan terlebih dahulu.
                      </div>
                    ) : (
                      <select
                        name="kehamilan_id"
                        value={form.kehamilan_id}
                        onChange={handleChange}
                        className={`w-full p-4 bg-white border rounded-xl outline-none transition-all ${
                          errors.kehamilan_id
                            ? "border-red-500 focus:ring-red-200"
                            : "border-gray-200 focus:ring-blue-500 focus:ring-2"
                        }`}
                      >
                        <option value="">-- Pilih Kehamilan --</option>
                        {kehamilanList.map((kehamilan) => (
                          <option key={kehamilan.id} value={kehamilan.id}>
                            Kehamilan #{kehamilan.gravida} - Status:{" "}
                            {kehamilan.status_kehamilan || "N/A"}
                          </option>
                        ))}
                      </select>
                    )}
                    {errors.kehamilan_id && (
                      <p className="mt-1 text-xs text-red-500 font-medium flex items-center gap-1">
                        <AlertCircle size={12} /> {errors.kehamilan_id}
                      </p>
                    )}
                  </div>
                )}
              </div>

              <hr className="my-6 border-gray-100" />

              {/* Nama Anak */}
              <div>
                <label className="block text-[12px] font-bold text-gray-500 tracking-wider uppercase mb-2">
                  Nama Anak <span className="text-red-500">*</span>
                </label>
                <input
                  name="nama"
                  type="text"
                  placeholder="Masukkan nama"
                  value={form.nama}
                  onChange={handleChange}
                  className={`w-full p-4 bg-gray-50 border rounded-xl outline-none transition-all ${
                    errors.nama
                      ? "border-red-500 focus:ring-red-200"
                      : "border-gray-200 focus:ring-blue-500 focus:ring-2"
                  }`}
                />
                {errors.nama && (
                  <p className="mt-1 text-xs text-red-500 font-medium flex items-center gap-1">
                    <AlertCircle size={12} /> {errors.nama}
                  </p>
                )}
              </div>

              {/* Tempat & Tanggal Lahir */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-[12px] font-bold text-gray-500 tracking-wider uppercase mb-2">
                    Tempat Lahir
                  </label>
                  <input
                    name="tempat_lahir"
                    type="text"
                    placeholder="Masukkan kota atau desa"
                    value={form.tempat_lahir}
                    onChange={handleChange}
                    className="w-full p-4 bg-gray-50 border border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 outline-none transition-all"
                  />
                </div>
                <div>
                  <label className="block text-[12px] font-bold text-gray-500 tracking-wider uppercase mb-2">
                    Tanggal Lahir <span className="text-red-500">*</span>
                  </label>
                  <input
                    name="tanggal_lahir"
                    type="date"
                    value={form.tanggal_lahir}
                    onChange={handleChange}
                    className={`w-full p-4 bg-gray-50 border rounded-xl outline-none transition-all ${
                      errors.tanggal_lahir
                        ? "border-red-500 focus:ring-red-200"
                        : "border-gray-200 focus:ring-blue-500 focus:ring-2"
                    }`}
                  />
                  {errors.tanggal_lahir && (
                    <p className="mt-1 text-xs text-red-500 font-medium flex items-center gap-1">
                      <AlertCircle size={12} /> {errors.tanggal_lahir}
                    </p>
                  )}
                </div>
              </div>

              {/* Jenis Kelamin & Anak Ke */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-[12px] font-bold text-gray-500 tracking-wider uppercase mb-2">
                    Jenis Kelamin <span className="text-red-500">*</span>
                  </label>
                  <div className="flex gap-2">
                    {["Laki-laki", "Perempuan"].map((jk) => (
                      <button
                        key={jk}
                        type="button"
                        onClick={() => {
                          setForm({ ...form, jenis_kelamin: jk.toLowerCase() });
                          if (errors.jenis_kelamin)
                            setErrors((prev) => ({
                              ...prev,
                              jenis_kelamin: "",
                            }));
                        }}
                        className={`flex-1 py-4 rounded-xl border text-sm font-medium transition-all ${
                          form.jenis_kelamin === jk.toLowerCase()
                            ? "bg-white border-blue-500 text-blue-600 shadow-sm"
                            : errors.jenis_kelamin
                              ? "border-red-300 text-gray-400"
                              : "bg-white border-gray-200 text-gray-700 hover:bg-gray-50"
                        }`}
                      >
                        {jk}
                      </button>
                    ))}
                  </div>
                  {errors.jenis_kelamin && (
                    <p className="mt-1 text-xs text-red-500 font-medium flex items-center gap-1">
                      <AlertCircle size={12} /> {errors.jenis_kelamin}
                    </p>
                  )}
                </div>
                <div>
                  <label className="block text-[12px] font-bold text-gray-500 tracking-wider uppercase mb-2">
                    Anak Ke -
                  </label>
                  <input
                    name="anak_ke"
                    type="number"
                    placeholder="e.g. 1"
                    value={form.anak_ke}
                    onChange={handleChange}
                    className="w-full p-4 bg-gray-50 border border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 outline-none transition-all"
                  />
                </div>
              </div>

              {/* Berat Lahir */}
              <div>
                <label className="block text-[12px] font-bold text-gray-500 tracking-wider uppercase mb-2">
                  Berat Lahir (kg)
                </label>
                <input
                  name="berat_lahir_kg"
                  type="number"
                  placeholder="e.g. 3.5"
                  step="0.1"
                  value={form.berat_lahir_kg}
                  onChange={handleChange}
                  className="w-full p-4 bg-gray-50 border border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 outline-none transition-all"
                />
              </div>

              {/* Buttons */}
              <div className="flex flex-col md:flex-row gap-4 pt-4">
                <button
                  type="button"
                  onClick={() => navigate(-1)}
                  className="flex-1 py-4 px-6 rounded-xl bg-indigo-50 text-indigo-700 font-bold hover:bg-indigo-100 transition-all"
                >
                  Kembali
                </button>
                <button
                  type="submit"
                  disabled={loading}
                  className="flex-[2] py-4 px-6 rounded-xl bg-[#3B71FE] text-white font-bold hover:bg-blue-700 shadow-lg shadow-blue-200 transition-all flex items-center justify-center gap-2"
                >
                  <UserPlus size={20} />
                  {loading ? "Menyimpan..." : "Tambah Data Anak"}
                </button>
              </div>
            </form>
          </div>

          {/* Kolom Kanan */}
          <div className="space-y-6">
            <div className="bg-blue-50 rounded-3xl p-6 border border-blue-100">
              <p className="text-blue-800 text-sm leading-relaxed">
                Pendaftaran dini memastikan anak menerima jadwal imunisasi
                lengkap dan pemantauan nutrisi sejak hari pertama.
              </p>
            </div>
            <div className="bg-white rounded-3xl p-8 shadow-sm border border-gray-100">
              <h3 className="text-gray-800 font-bold mb-6">
                Dokumen Pendukung
              </h3>
              <ul className="space-y-4">
                {["Buku KIA", "Data Identitas Anak", "Data Identitas Ibu"].map(
                  (doc) => (
                    <li
                      key={doc}
                      className="flex items-center gap-3 text-gray-600 text-sm font-medium"
                    >
                      <CheckCircle2 size={18} className="text-teal-500" />
                      {doc}
                    </li>
                  ),
                )}
              </ul>
            </div>
          </div>
        </div>
      </div>
    </MainLayout>
  );
}
