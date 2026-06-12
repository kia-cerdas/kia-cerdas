import React, { useState, useEffect } from "react";
import MainLayout from "../../components/Layout/MainLayout";
import { useNavigate, useParams, Link } from "react-router-dom";
import { createPelayananKesehatanAnak, getKategoriUmur, getPeriodeByKategori, getJenisPelayananByPeriode } from "../../services/PelayananKesehatanAnak";
import { getAnak } from "../../services/Anak";
// Tambahkan import Search dan ChevronDown
import { ChevronRight, ChevronLeft, Check, Search, ChevronDown } from "lucide-react";

export default function CreatePelayananKesehatanAnak() {
  const navigate = useNavigate();
  const { anakID } = useParams();

  // ────────────────────────── STATE ──────────────────────────
  const [step, setStep] = useState(1);
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState("");

  // Form data
  const [formData, setFormData] = useState({
    anak_id: anakID ? parseInt(anakID) : 0,
    tanggal: new Date().toISOString().split("T")[0],
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
  const [anak, setAnak] = useState(null);
  const [kategoriUmur, setKategoriUmur] = useState([]);
  const [periode, setPeriode] = useState([]);
  const [jenisPelayanan, setJenisPelayanan] = useState([]);
  const [anakList, setAnakList] = useState([]);

  // State khusus untuk Live Search Anak
  const [searchTermAnak, setSearchTermAnak] = useState("");
  const [isAnakDropdownOpen, setIsAnakDropdownOpen] = useState(false);

  // ────────────────────────── FETCH DATA ──────────────────────────
  useEffect(() => {
    const fetchMasterData = async () => {
      try {
        setLoading(true);
        
        // Fetch kategori umur
        const kategoriRes = await getKategoriUmur();
        setKategoriUmur(kategoriRes.data || []);

        // Fetch list anak
        const anakRes = await getAnak();
        setAnakList(anakRes.data || []);

        // Jika dari params, set anak
        if (anakID) {
          const selectedAnak = anakRes.data?.find(a => a.id == anakID);
          if (selectedAnak) {
            setAnak(selectedAnak);
            setFormData(prev => ({...prev, anak_id: parseInt(anakID)}));
            // Set input search langsung ke nama anak
            setSearchTermAnak(selectedAnak.nama_anak || selectedAnak.nama || "");
          }
        }
      } catch (error) {
        setError("Gagal memuat data master. Silakan refresh halaman.");
        console.error(error);
      } finally {
        setLoading(false);
      }
    };

    fetchMasterData();
  }, [anakID]);

  // ────────────────────────── HANDLERS ──────────────────────────

  // Handler untuk Live Search mengetik nama anak
  const handleSearchAnakChange = (e) => {
    setSearchTermAnak(e.target.value);
    setIsAnakDropdownOpen(true);
    setFormData(prev => ({...prev, anak_id: 0})); // Reset ID jika user ngetik ulang
    setAnak(null);
  };

  // Handler saat user mengklik nama anak dari dropdown pencarian
  const handleSelectAnak = (selected) => {
    setFormData(prev => ({...prev, anak_id: selected.id}));
    setAnak(selected);
    setSearchTermAnak(selected.nama_anak || selected.nama || ""); 
    setIsAnakDropdownOpen(false); 
  };

  // Memfilter daftar anak berdasarkan ketikan
  const filteredAnakList = anakList.filter(a =>
    (a.nama_anak || a.nama)?.toLowerCase().includes(searchTermAnak.toLowerCase())
  );

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

  const handleDetailChange = (jenisPelayananID, field, value) => {
    const updated = [...formData.detail_pelayanan];
    const existingIndex = updated.findIndex(d => d.jenis_pelayanan_id === jenisPelayananID);

    if (existingIndex !== -1) {
      updated[existingIndex] = {
        ...updated[existingIndex],
        [field]: value,
      };
    } else {
      updated.push({
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
    if (!formData.anak_id) {
      setError("Pilih anak terlebih dahulu");
      return;
    }
    if (!formData.tanggal) {
      setError("Tanggal periksa wajib diisi");
      return;
    }
    if (!formData.kategori_umur_id) {
      setError("Kategori umur wajib dipilih");
      return;
    }
    if (!formData.periode_id) {
      setError("Periode wajib dipilih");
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

    // Filter detail yang ada nilainya
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

      await createPelayananKesehatanAnak(payload);
      alert("Data kunjungan berhasil disimpan!");
      navigate("/pelayanan-kesehatan-anak");
    } catch (error) {
      console.error("Error creating data:", error);
      console.log("Detail Error dari Golang:", error.response?.data); 
      
      setError(
        error.response?.data?.error || 
        error.response?.data?.message || 
        "Gagal menyimpan data. Silakan coba lagi."
      );
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
        <span className="font-semibold text-indigo-700">Tambah Kunjungan</span>
      </nav>

      <h1 className="text-3xl font-bold text-gray-800 mb-8">Pencatatan Pelayanan Kesehatan Anak</h1>

      {/* ERROR MESSAGE */}
      {error && (
        <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg mb-6">
          {error}
        </div>
      )}

      <div className="bg-white rounded-2xl shadow-lg border border-gray-100 p-8">
        <form onSubmit={handleSubmit}>
          {/* ──── STEP 1: DATA KUNJUNGAN ──── */}
          <div className={step === 1 ? "block" : "hidden"}>
            <h2 className="text-xl font-bold text-gray-800 mb-6">Step 1: Data Kunjungan</h2>

            <div className="space-y-6">
              {/* Anak (Live Search) */}
              <div>
                <label className="block text-sm font-bold text-gray-700 mb-2">
                  Pilih Anak <span className="text-red-500">*</span>
                </label>
                
                <div className="relative">
                  <div className="relative">
                    <Search className="absolute left-3 top-1/2 -transform -translate-y-1/2 text-gray-400" size={18} />
                    <input
                      type="text"
                      placeholder="Ketik nama anak untuk mencari..."
                      value={searchTermAnak}
                      onChange={handleSearchAnakChange}
                      onFocus={() => setIsAnakDropdownOpen(true)}
                      onBlur={() => setTimeout(() => setIsAnakDropdownOpen(false), 200)}
                      className="w-full pl-10 pr-10 py-2.5 border border-gray-200 rounded-xl focus:ring-2 focus:ring-indigo-500 outline-none transition-all"
                    />
                    <ChevronDown className="absolute right-3 top-1/2 -transform -translate-y-1/2 text-gray-400" size={18} />
                  </div>

                  {/* Dropdown Menu untuk Search */}
                  {isAnakDropdownOpen && (
                    <ul className="absolute z-20 w-full mt-1 bg-white border border-gray-200 rounded-xl shadow-lg max-h-60 overflow-auto">
                      {filteredAnakList.length > 0 ? (
                        filteredAnakList.map(a => (
                          <li
                            key={a.id}
                            onClick={() => handleSelectAnak(a)}
                            className="px-4 py-2.5 hover:bg-indigo-50 cursor-pointer text-sm text-gray-700 transition-colors border-b border-gray-50 last:border-0"
                          >
                            {a.nama_anak || a.nama}
                          </li>
                        ))
                      ) : (
                        <li className="px-4 py-3 text-sm text-gray-500 text-center bg-gray-50 rounded-xl">
                          Anak tidak ditemukan
                        </li>
                      )}
                    </ul>
                  )}
                </div>
              </div>

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

          {/* ──── STEP 2: DETAIL PELAYANAN ──── */}
          <div className={step === 2 ? "block" : "hidden"}>
            <h2 className="text-xl font-bold text-gray-800 mb-6">Step 2: Detail Pelayanan</h2>

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
                          onChange={(e) => handleDetailChange(jenis.id, "nilai", e.target.value)}
                          className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-indigo-500 outline-none"
                        />
                      )}

                      {jenis.tipe_input === "checkbox" && (
                        <div className="flex items-center gap-3">
                          <input
                            type="checkbox"
                            checked={detail?.nilai === "true" || false}
                            onChange={(e) => handleDetailChange(jenis.id, "nilai", e.target.checked ? "true" : "false")}
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
                          onChange={(e) => handleDetailChange(jenis.id, "nilai", e.target.value)}
                          className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-indigo-500 outline-none"
                        />
                      )}

                      {jenis.tipe_input === "select" && (
                        <select
                          value={detail?.nilai || ""}
                          onChange={(e) => handleDetailChange(jenis.id, "nilai", e.target.value)}
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
                          onChange={(e) => handleDetailChange(jenis.id, "keterangan", e.target.value)}
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

          {/* ──── STEP 3: REVIEW & SUBMIT ──── */}
          <div className={step === 3 ? "block" : "hidden"}>
            <h2 className="text-xl font-bold text-gray-800 mb-6">Step 3: Ringkasan & Simpan</h2>

            <div className="space-y-6">
              <div className="bg-indigo-50 border border-indigo-200 rounded-xl p-4">
                <h3 className="font-bold text-indigo-900 mb-2">Data Anak</h3>
                {/* Sudah diperbaiki dengan nama_anak */}
                <p className="text-sm text-indigo-800">{anak?.nama_anak || anak?.nama || "-"}</p>
              </div>

              <div className="bg-indigo-50 border border-indigo-200 rounded-xl p-4">
                <h3 className="font-bold text-indigo-900 mb-2">Tanggal & Lokasi</h3>
                <p className="text-sm text-indigo-800">{formData.tanggal} di {formData.lokasi}</p>
              </div>

              <div className="bg-indigo-50 border border-indigo-200 rounded-xl p-4">
                <h3 className="font-bold text-indigo-900 mb-3">Pelayanan yang Dicatat</h3>
                <div className="space-y-2">
                  {formData.detail_pelayanan
                    .filter(d => d.nilai || d.keterangan)
                    .map((detail, idx) => {
                      const jenis = jenisPelayanan.find(j => j.id === detail.jenis_pelayanan_id);
                      return (
                        <p key={idx} className="text-sm text-indigo-800">
                          • {jenis?.nama}: {detail.nilai || "-"} {detail.keterangan && `(${detail.keterangan})`}
                        </p>
                      );
                    })
                  }
                </div>
              </div>

              <div className="bg-green-50 border border-green-200 rounded-xl p-4">
                <p className="text-sm text-green-800">
                  <Check className="inline mr-2" size={16} />
                  Semua data siap disimpan. Klik tombol Simpan untuk menyelesaikan.
                </p>
              </div>
            </div>
          </div>

          {/* ──── BUTTONS ──── */}
          <div className="flex justify-between mt-8 pt-8 border-t border-gray-200">
            <button
              type="button"
              onClick={() => setStep(prev => Math.max(prev - 1, 1))}
              disabled={step === 1}
              className="flex items-center gap-2 px-6 py-2.5 border border-gray-300 text-gray-700 rounded-xl font-bold hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed transition-all"
            >
              <ChevronLeft size={18} /> Sebelumnya
            </button>

            <div className="flex gap-2">
              {step === 1 && (
                <button
                  type="button"
                  onClick={() => setStep(2)}
                  className="flex items-center gap-2 px-6 py-2.5 bg-indigo-600 text-white rounded-xl font-bold hover:bg-indigo-700 transition-all"
                >
                  Selanjutnya <ChevronRight size={18} />
                </button>
              )}

              {step === 2 && (
                <button
                  type="button"
                  onClick={() => setStep(3)}
                  className="flex items-center gap-2 px-6 py-2.5 bg-indigo-600 text-white rounded-xl font-bold hover:bg-indigo-700 transition-all"
                >
                  Selanjutnya <ChevronRight size={18} />
                </button>
              )}

              {step === 3 && (
                <button
                  type="submit"
                  disabled={submitting}
                  className="flex items-center gap-2 px-6 py-2.5 bg-green-600 text-white rounded-xl font-bold hover:bg-green-700 disabled:opacity-50 disabled:cursor-not-allowed transition-all"
                >
                  <Check size={18} /> {submitting ? "Menyimpan..." : "Simpan"}
                </button>
              )}
            </div>
          </div>
        </form>
      </div>
    </MainLayout>
  );
}