import React, { useState, useEffect } from "react";
import MainLayout from "../../components/Layout/MainLayout";
import { useNavigate, useParams, Link } from "react-router-dom";
import { 
  updatePelayananKesehatanAnak, 
  getPelayananKesehatanAnakById, 
  getKategoriUmur, 
  getPeriodeByKategori, 
  getJenisPelayananByPeriode 
} from "../../services/PelayananKesehatanAnak";
import { ChevronRight, ChevronLeft, Save } from "lucide-react";

export default function EditPelayananKesehatanAnak() {
  const navigate = useNavigate();
  const { id } = useParams();

  // ────────────────────────── STATE ──────────────────────────
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState("");

  // Form data
  const [formData, setFormData] = useState({
    anak_id: 0,
    tanggal: "",
    kategori_umur_id: 0,
    periode_id: 0,
    lokasi: "",
    keluhan: "",
    pemeriksaan_tindakan: "",
    catatan_kie: "",
    tanggal_kembali: "",
    detail_pelayanan: [],
  });

  // Master data
  const [kategoriUmur, setKategoriUmur] = useState([]);
  const [periode, setPeriode] = useState([]);
  const [jenisPelayanan, setJenisPelayanan] = useState([]);

  // ────────────────────────── FETCH DATA ──────────────────────────
  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);

        // Fetch kunjungan data
        const kunjunganRes = await getPelayananKesehatanAnakById(id);
        const kunjungan = kunjunganRes.data;

        // Fetch kategori umur
        const kategoriRes = await getKategoriUmur();
        setKategoriUmur(kategoriRes.data || []);

        // Set form data
        setFormData({
          anak_id: kunjungan.data_anak_id,
          tanggal: kunjungan.tanggal ? new Date(kunjungan.tanggal).toISOString().split("T")[0] : "",
          kategori_umur_id: kunjungan.kategori_umur_id,
          periode_id: kunjungan.periode_id,
          lokasi: kunjungan.lokasi || "",
          keluhan: kunjungan.keluhan || "",
          pemeriksaan_tindakan: kunjungan.pemeriksaan_tindakan || "",
          catatan_kie: kunjungan.catatan_kie || "",
          tanggal_kembali: kunjungan.tanggal_kembali ? new Date(kunjungan.tanggal_kembali).toISOString().split("T")[0] : "",
          detail_pelayanan: kunjungan.detail_pelayanan?.map(d => ({
            id: d.id,
            jenis_pelayanan_id: d.jenis_pelayanan_id,
            nilai: d.nilai,
            keterangan: d.keterangan,
          })) || [],
        });

        // Fetch periode berdasarkan kategori umur
        if (kunjungan.kategori_umur_id) {
          const periodeRes = await getPeriodeByKategori(kunjungan.kategori_umur_id);
          setPeriode(periodeRes.data || []);

          // Fetch jenis pelayanan
          const jenisRes = await getJenisPelayananByPeriode(kunjungan.periode_id, kunjungan.kategori_umur_id);
          setJenisPelayanan(jenisRes.data || []);
        }
      } catch (error) {
        setError("Gagal memuat data. Silakan refresh halaman.");
        console.error(error);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [id]);

  // ────────────────────────── HANDLERS ──────────────────────────

  const handleKategoriUmurChange = async (e) => {
    const kategoriID = parseInt(e.target.value);
    setFormData(prev => ({
      ...prev,
      kategori_umur_id: kategoriID,
      periode_id: 0,
      detail_pelayanan: [],
    }));

    if (kategoriID === 0) {
      setPeriode([]);
      setJenisPelayanan([]);
      return;
    }

    try {
      const res = await getPeriodeByKategori(kategoriID);
      setPeriode(res.data || []);
    } catch (error) {
      console.error("Error fetching periode:", error);
      setError("Gagal memuat periode kunjungan.");
    }
  };

  const handlePeriodeChange = async (e) => {
    const periodeID = parseInt(e.target.value);
    setFormData(prev => ({
      ...prev,
      periode_id: periodeID,
      detail_pelayanan: [],
    }));

    if (periodeID === 0 || formData.kategori_umur_id === 0) {
      setJenisPelayanan([]);
      return;
    }

    try {
      const res = await getJenisPelayananByPeriode(periodeID, formData.kategori_umur_id);
      setJenisPelayanan(res.data || []);
    } catch (error) {
      console.error("Error fetching jenis pelayanan:", error);
      setError("Gagal memuat jenis pelayanan.");
    }
  };

  const handleDetailChange = (jenisPelayananID, field, value, detailID = null) => {
    const updated = [...formData.detail_pelayanan];
    const existingIndex = updated.findIndex(d => 
      detailID ? d.id === detailID : d.jenis_pelayanan_id === jenisPelayananID
    );

    if (existingIndex !== -1) {
      updated[existingIndex] = {
        ...updated[existingIndex],
        [field]: value,
      };
    } else {
      updated.push({
        id: detailID,
        jenis_pelayanan_id: jenisPelayananID,
        nilai: field === "nilai" ? value : "",
        keterangan: field === "keterangan" ? value : "",
      });
    }

    setFormData(prev => ({...prev, detail_pelayanan: updated}));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    // Validasi
    if (!formData.tanggal) {
      setError("Tanggal periksa wajib diisi");
      return;
    }
    if (!formData.lokasi) {
      setError("Lokasi wajib diisi");
      return;
    }
    if (formData.detail_pelayanan.length === 0) {
      setError("Tambahkan minimal satu detail pelayanan");
      return;
    }

    const validDetails = formData.detail_pelayanan.filter(d => d.nilai || d.keterangan);
    if (validDetails.length === 0) {
      setError("Minimal satu item pelayanan harus memiliki nilai atau keterangan");
      return;
    }

    try {
      setSubmitting(true);
      setError("");
      
      const payload = {
        anak_id: formData.anak_id,
        tanggal: formData.tanggal,
        kategori_umur_id: formData.kategori_umur_id,
        periode_id: formData.periode_id,
        lokasi: formData.lokasi,
        keluhan: formData.keluhan || null,
        pemeriksaan_tindakan: formData.pemeriksaan_tindakan || null,
        catatan_kie: formData.catatan_kie || null,
        tanggal_kembali: formData.tanggal_kembali || null,
        detail_pelayanan: validDetails,
      };

      await updatePelayananKesehatanAnak(id, payload);
      alert("Data kunjungan berhasil diperbarui!");
      navigate(`/pelayanan-kesehatan-anak/detail/${id}`);
    } catch (error) {
      console.error("Error updating data:", error);
      setError(error.response?.data?.error || "Gagal menyimpan data. Silakan coba lagi.");
    } finally {
      setSubmitting(false);
    }
  };

  // ────────────────────────── RENDER ──────────────────────────

  if (loading) {
    return (
      <MainLayout>
        <div className="text-center py-20">
          <p className="text-gray-500">Memuat formulir...</p>
        </div>
      </MainLayout>
    );
  }

  return (
    <MainLayout>
      {/* BREADCRUMB */}
      <nav className="flex items-center text-sm text-gray-500 mb-6 gap-2 bg-white p-3 rounded-lg shadow-sm border border-gray-100 w-fit">
        <Link to="/dashboard" className="hover:text-indigo-600">Dashboard</Link>
        <ChevronRight size={14} />
        <Link to="/pelayanan-kesehatan-anak" className="hover:text-indigo-600">Pelayanan Kesehatan Anak</Link>
        <ChevronRight size={14} />
        <span className="font-semibold text-indigo-700">Edit Kunjungan</span>
      </nav>

      <h1 className="text-3xl font-bold text-gray-800 mb-8">Edit Pencatatan Pelayanan Kesehatan Anak</h1>

      {/* ERROR MESSAGE */}
      {error && (
        <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg mb-6">
          {error}
        </div>
      )}

      <div className="bg-white rounded-2xl shadow-lg border border-gray-100 p-8">
        <form onSubmit={handleSubmit} className="space-y-8">
          {/* ──── SECTION 1: DATA KUNJUNGAN ──── */}
          <div>
            <h2 className="text-xl font-bold text-gray-800 mb-6 pb-4 border-b border-gray-200">
              Data Kunjungan
            </h2>

            <div className="space-y-6">
              {/* Tanggal Periksa */}
              <div>
                <label className="block text-sm font-bold text-gray-700 mb-2">
                  Tanggal Periksa <span className="text-red-500">*</span>
                </label>
                <input
                  type="date"
                  value={formData.tanggal}
                  onChange={(e) => setFormData(prev => ({...prev, tanggal: e.target.value}))}
                  className="w-full px-4 py-2.5 border border-gray-200 rounded-xl focus:ring-2 focus:ring-indigo-500 outline-none"
                />
              </div>

              {/* Kategori Umur */}
              <div>
                <label className="block text-sm font-bold text-gray-700 mb-2">
                  Kategori Umur <span className="text-red-500">*</span>
                </label>
                <select
                  value={formData.kategori_umur_id}
                  onChange={handleKategoriUmurChange}
                  className="w-full px-4 py-2.5 border border-gray-200 rounded-xl focus:ring-2 focus:ring-indigo-500 outline-none"
                >
                  <option value="">-- Pilih Kategori Umur --</option>
                  {kategoriUmur.map(k => (
                    <option key={k.id} value={k.id}>{k.kategori_umur}</option>
                  ))}
                </select>
              </div>

              {/* Periode */}
              <div>
                <label className="block text-sm font-bold text-gray-700 mb-2">
                  Periode Kunjungan <span className="text-red-500">*</span>
                </label>
                <select
                  value={formData.periode_id}
                  onChange={handlePeriodeChange}
                  disabled={!formData.kategori_umur_id}
                  className="w-full px-4 py-2.5 border border-gray-200 rounded-xl focus:ring-2 focus:ring-indigo-500 outline-none disabled:bg-gray-100"
                >
                  <option value="">-- Pilih Periode --</option>
                  {periode.map(p => (
                    <option key={p.id} value={p.id}>{p.nama}</option>
                  ))}
                </select>
              </div>

              {/* Lokasi */}
              <div>
                <label className="block text-sm font-bold text-gray-700 mb-2">
                  Lokasi Periksa <span className="text-red-500">*</span>
                </label>
                <input
                  type="text"
                  placeholder="Contoh: Polindes, Rumah, Puskesmas"
                  value={formData.lokasi}
                  onChange={(e) => setFormData(prev => ({...prev, lokasi: e.target.value}))}
                  className="w-full px-4 py-2.5 border border-gray-200 rounded-xl focus:ring-2 focus:ring-indigo-500 outline-none"
                />
              </div>

              {/* Keluhan */}
              <div>
                <label className="block text-sm font-bold text-gray-700 mb-2">Keluhan Utama</label>
                <textarea
                  placeholder="Keluhan yang disampaikan ibu/keluarga"
                  value={formData.keluhan}
                  onChange={(e) => setFormData(prev => ({...prev, keluhan: e.target.value}))}
                  rows="3"
                  className="w-full px-4 py-2.5 border border-gray-200 rounded-xl focus:ring-2 focus:ring-indigo-500 outline-none"
                />
              </div>

              {/* Pemeriksaan & Tindakan */}
              <div>
                <label className="block text-sm font-bold text-gray-700 mb-2">Pemeriksaan & Tindakan</label>
                <textarea
                  placeholder="Hasil pemeriksaan fisik dan tindakan yang diberikan"
                  value={formData.pemeriksaan_tindakan}
                  onChange={(e) => setFormData(prev => ({...prev, pemeriksaan_tindakan: e.target.value}))}
                  rows="3"
                  className="w-full px-4 py-2.5 border border-gray-200 rounded-xl focus:ring-2 focus:ring-indigo-500 outline-none"
                />
              </div>

              {/* Tanggal Kembali */}
              <div>
                <label className="block text-sm font-bold text-gray-700 mb-2">Tanggal Kembali</label>
                <input
                  type="date"
                  value={formData.tanggal_kembali}
                  onChange={(e) => setFormData(prev => ({...prev, tanggal_kembali: e.target.value}))}
                  className="w-full px-4 py-2.5 border border-gray-200 rounded-xl focus:ring-2 focus:ring-indigo-500 outline-none"
                />
              </div>
            </div>
          </div>

          {/* ──── SECTION 2: DETAIL PELAYANAN ──── */}
          <div className="pt-8 border-t border-gray-200">
            <h2 className="text-xl font-bold text-gray-800 mb-6 pb-4 border-b border-gray-200">
              Detail Pelayanan
            </h2>

            {jenisPelayanan.length === 0 ? (
              <div className="bg-blue-50 border border-blue-200 text-blue-700 px-4 py-3 rounded-lg">
                Pilih kategori umur dan periode terlebih dahulu untuk melihat item pelayanan yang sesuai.
              </div>
            ) : (
              <div className="space-y-6">
                {jenisPelayanan.map((jenis) => {
                  const detail = formData.detail_pelayanan.find(d => d.jenis_pelayanan_id === jenis.id);
                  
                  return (
                    <div key={jenis.id} className="border border-gray-200 rounded-xl p-4">
                      <h3 className="font-bold text-gray-800 mb-3">{jenis.nama}</h3>
                      
                      {jenis.tipe_input === "number" && (
                        <input
                          type="number"
                          placeholder="Masukkan nilai"
                          step="0.1"
                          value={detail?.nilai || ""}
                          onChange={(e) => handleDetailChange(jenis.id, "nilai", e.target.value, detail?.id)}
                          className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-indigo-500 outline-none"
                        />
                      )}

                      {jenis.tipe_input === "checkbox" && (
                        <div className="flex items-center gap-3">
                          <input
                            type="checkbox"
                            checked={detail?.nilai === "true" || false}
                            onChange={(e) => handleDetailChange(jenis.id, "nilai", e.target.checked ? "true" : "false", detail?.id)}
                            className="w-4 h-4"
                          />
                          <label className="text-sm text-gray-700">Sudah diberikan</label>
                        </div>
                      )}

                      {jenis.tipe_input === "text" && (
                        <input
                          type="text"
                          placeholder="Masukkan teks"
                          value={detail?.nilai || ""}
                          onChange={(e) => handleDetailChange(jenis.id, "nilai", e.target.value, detail?.id)}
                          className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-indigo-500 outline-none"
                        />
                      )}

                      {jenis.tipe_input === "select" && (
                        <select
                          value={detail?.nilai || ""}
                          onChange={(e) => handleDetailChange(jenis.id, "nilai", e.target.value, detail?.id)}
                          className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-indigo-500 outline-none"
                        >
                          <option value="">-- Pilih --</option>
                          <option value="Sesuai">Sesuai</option>
                          <option value="Tidak Sesuai">Tidak Sesuai</option>
                        </select>
                      )}

                      <div className="mt-3">
                        <textarea
                          placeholder="Keterangan (opsional)"
                          value={detail?.keterangan || ""}
                          onChange={(e) => handleDetailChange(jenis.id, "keterangan", e.target.value, detail?.id)}
                          rows="2"
                          className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-indigo-500 outline-none text-sm"
                        />
                      </div>
                    </div>
                  );
                })}
              </div>
            )}

            {/* KIE */}
            <div className="mt-6 border border-gray-200 rounded-xl p-4">
              <h3 className="font-bold text-gray-800 mb-3">Catatan KIE (Komunikasi, Informasi, Edukasi)</h3>
              <textarea
                placeholder="Edukasi/KIE yang diberikan kepada ibu/keluarga"
                value={formData.catatan_kie}
                onChange={(e) => setFormData(prev => ({...prev, catatan_kie: e.target.value}))}
                rows="4"
                className="w-full px-4 py-2.5 border border-gray-200 rounded-xl focus:ring-2 focus:ring-indigo-500 outline-none"
              />
            </div>
          </div>

          {/* ──── BUTTONS ──── */}
          <div className="flex justify-between pt-8 border-t border-gray-200">
            <button
              type="button"
              onClick={() => navigate(`/pelayanan-kesehatan-anak/detail/${id}`)}
              className="flex items-center gap-2 px-6 py-2.5 border border-gray-300 text-gray-700 rounded-xl font-bold hover:bg-gray-50 transition-all"
            >
              <ChevronLeft size={18} /> Batal
            </button>

            <button
              type="submit"
              disabled={submitting}
              className="flex items-center gap-2 px-6 py-2.5 bg-indigo-600 text-white rounded-xl font-bold hover:bg-indigo-700 disabled:opacity-50 disabled:cursor-not-allowed transition-all"
            >
              <Save size={18} /> {submitting ? "Menyimpan..." : "Simpan Perubahan"}
            </button>
          </div>
        </form>
      </div>
    </MainLayout>
  );
}
