import React, { useState, useEffect, useRef } from "react";
import { ChevronDown, ChevronUp, CheckCircle, Circle, AlertCircle, Users, Info } from "lucide-react";
import Swal from "sweetalert2";
import { getPendudukByKodeKeluarga } from "../../../services/kependudukan";

const GOLONGAN_DARAH_OPTIONS = ["", "A", "B", "AB", "O", "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"];
const AGAMA_OPTIONS = ["", "Islam", "Kristen Protestan", "Katolik", "Hindu", "Buddha", "Konghucu"];
const PENDIDIKAN_OPTIONS = ["", "Tidak/Belum Sekolah", "Belum Tamat SD/Sederajat", "Tamat SD/Sederajat", "SLTP/Sederajat", "SLTA/Sederajat", "Diploma I/II", "Akademi/Diploma III/S.Muda", "Diploma IV/Strata I", "Strata II", "Strata III"];
const STATUS_OPTIONS = ["", "Kawin", "Belum Kawin", "Cerai Hidup", "Cerai Mati"];
const JENIS_KELAMIN_OPTIONS = ["Laki-laki", "Perempuan"];
const KEWARGANEGARAAN_OPTIONS = ["WNI", "WNA"];
const ALL_HUBUNGAN = ["Kepala Keluarga", "Istri", "Anak", "Menantu", "Cucu", "Orang Tua", "Mertua", "Keluarga Lainnya"];

// Hubungan yang hanya boleh 1 orang per KK
const UNIQUE_HUBUNGAN = ["Kepala Keluarga", "Istri"];

const SectionHeader = ({ title, isOpen, isValid, onClick }) => (
  <button
    type="button"
    onClick={onClick}
    className={`w-full flex items-center justify-between px-5 py-4 transition-all ${
      isOpen ? "bg-indigo-50 border-b border-indigo-100" : "bg-slate-50 hover:bg-slate-100 border-b border-slate-200"
    }`}
  >
    <div className="flex items-center gap-3">
      {isValid ? (
        <CheckCircle size={20} className="text-green-600" />
      ) : isOpen ? (
        <AlertCircle size={20} className="text-amber-500" />
      ) : (
        <Circle size={20} className="text-slate-400" />
      )}
      <h3 className={`text-sm font-semibold ${isOpen ? "text-indigo-700" : "text-slate-700"}`}>{title}</h3>
      {isValid && !isOpen && (
        <span className="text-xs bg-green-100 text-green-700 px-2 py-0.5 rounded-full">Lengkap</span>
      )}
    </div>
    {isOpen ? <ChevronUp size={18} className="text-indigo-600" /> : <ChevronDown size={18} className="text-slate-400" />}
  </button>
);

const FormPendudukAccordion = ({
  initialData = null,
  onSubmit,
  onCancel,
  submitting,
  desasList,
  posyanduList,
  // Semua data penduduk yang sudah ada (untuk cek aturan per KK)
  existingPenduduks = [],
}) => {
  const isEdit = !!initialData;
  const kodeDebounceRef = useRef(null);

  const [formData, setFormData] = useState({
    nik: "", nama_anggota_keluarga: "", jenis_kelamin: "Laki-laki",
    tanggal_lahir: "", tempat_lahir: "", golongan_darah: "", agama: "",
    status: "", pekerjaan: "", pendidikan: "", kewarganegaraan: "WNI",
    etnis_suku: "", hubungan: "", rw: "", rt: "", dusun: "", alamat: "",
    kode_keluarga: "", nama_kepala_keluarga: "", telepon: "",
    desa_id: "", posyandu_id: "",
  });

  // State khusus untuk logika KK
  const [isKepalaKeluarga, setIsKepalaKeluarga] = useState(false);
  const [kkInfo, setKkInfo] = useState(null); // { hasKK, hasIstri, namaKK }
  const [kkLoading, setKkLoading] = useState(false);
  const [availableHubungan, setAvailableHubungan] = useState(ALL_HUBUNGAN);

  const [openSections, setOpenSections] = useState({ dataDiri: true, alamat: false, pekerjaan: false, keluarga: false });
  const [sectionValid, setSectionValid] = useState({ dataDiri: false, alamat: false, pekerjaan: false, keluarga: false });

  // ── Init saat edit ──
  useEffect(() => {
    if (initialData) {
      let tanggalLahir = "";
      if (initialData.tanggal_lahir) {
        try {
          const d = new Date(initialData.tanggal_lahir);
          if (d.getFullYear() > 1) tanggalLahir = d.toISOString().split("T")[0];
        } catch { tanggalLahir = ""; }
      }
      const fd = {
        nik: initialData.nik || "",
        nama_anggota_keluarga: initialData.nama_anggota_keluarga || "",
        jenis_kelamin: initialData.jenis_kelamin || "Laki-laki",
        tanggal_lahir: tanggalLahir,
        tempat_lahir: initialData.tempat_lahir || "",
        golongan_darah: initialData.golongan_darah || "",
        agama: initialData.agama || "",
        status: initialData.status || "",
        pekerjaan: initialData.pekerjaan || "",
        pendidikan: initialData.pendidikan || "",
        kewarganegaraan: initialData.kewarganegaraan || "WNI",
        etnis_suku: initialData.etnis_suku || "",
        hubungan: initialData.hubungan || "",
        rw: initialData.rw || "",
        rt: initialData.rt || "",
        dusun: initialData.dusun || "",
        alamat: initialData.alamat || "",
        kode_keluarga: initialData.kode_keluarga || "",
        nama_kepala_keluarga: initialData.nama_kepala_keluarga || "",
        telepon: initialData.telepon || "",
        desa_id: initialData.desa_id || "",
        posyandu_id: initialData.posyandu_id || "",
      };
      setFormData(fd);
      setIsKepalaKeluarga(initialData.hubungan === "Kepala Keluarga");
      setOpenSections({ dataDiri: true, alamat: true, pekerjaan: true, keluarga: true });
    }
  }, [initialData]);

  // ── Cek data KK saat kode_keluarga berubah (debounce 600ms) ──
  useEffect(() => {
    const kode = formData.kode_keluarga.trim();
    if (!kode) {
      setKkInfo(null);
      setAvailableHubungan(ALL_HUBUNGAN);
      return;
    }

    clearTimeout(kodeDebounceRef.current);
    kodeDebounceRef.current = setTimeout(async () => {
      setKkLoading(true);
      try {
        const members = await getPendudukByKodeKeluarga(kode);
        // Response: { kode_keluarga, nama_kepala_keluarga, jumlah_anggota, anggota: [...] }
        // atau bisa jadi array langsung
        const list = Array.isArray(members)
          ? members
          : Array.isArray(members?.anggota)
          ? members.anggota
          : (members?.items || []);

        // Saat edit: kecualikan diri sendiri dari pengecekan
        const others = isEdit
          ? list.filter(m => (m.id || m.IDKependudukan) !== (initialData?.id || initialData?.IDKependudukan))
          : list;

        const hasKK = others.some(m => m.hubungan === "Kepala Keluarga");
        const hasIstri = others.some(m => m.hubungan === "Istri");
        const kkMember = others.find(m => m.hubungan === "Kepala Keluarga");
        const namaKK = kkMember?.nama_anggota_keluarga || kkMember?.nama_lengkap || "";

        setKkInfo({ hasKK, hasIstri, namaKK, count: others.length });

        // Otomatis isi nama KK jika ada & belum diisi sendiri
        if (namaKK && !isKepalaKeluarga) {
          setFormData(prev => ({ ...prev, nama_kepala_keluarga: namaKK }));
        }

        // Hitung opsi hubungan yang tersedia
        const blocked = [];
        if (hasKK) blocked.push("Kepala Keluarga");
        if (hasIstri) blocked.push("Istri");
        setAvailableHubungan(ALL_HUBUNGAN.filter(h => !blocked.includes(h)));

        // Jika hubungan yang dipilih sekarang sudah tidak tersedia, reset
        if (blocked.includes(formData.hubungan)) {
          setFormData(prev => ({ ...prev, hubungan: "" }));
        }
      } catch (err) {
        // 404 = kode belum pernah dipakai (KK baru), error lain = tetap reset ke safe state
        const is404 = err?.response?.status === 404;
        setKkInfo({ hasKK: false, hasIstri: false, namaKK: "", count: 0, isNew: is404 });
        setAvailableHubungan(ALL_HUBUNGAN);
      } finally {
        setKkLoading(false);
      }
    }, 600);

    return () => clearTimeout(kodeDebounceRef.current);
  }, [formData.kode_keluarga]);

  // ── Sinkron centang KK ↔ hubungan ──
  const handleKepalaToggle = () => {
    if (isKepalaKeluarga) {
      // Un-check: lepas sebagai KK
      setIsKepalaKeluarga(false);
      setFormData(prev => ({
        ...prev,
        hubungan: "",
        // Kosongkan nama KK kalau sebelumnya diisi otomatis dari nama sendiri
        nama_kepala_keluarga: prev.nama_kepala_keluarga === prev.nama_anggota_keluarga ? "" : prev.nama_kepala_keluarga,
      }));
    } else {
      // Check: jadikan KK
      if (kkInfo?.hasKK && !isEdit) {
        Swal.fire({
          icon: "warning",
          title: "Sudah Ada Kepala Keluarga",
          text: `Kode keluarga ini sudah memiliki Kepala Keluarga atas nama "${kkInfo.namaKK}". Tidak bisa menambahkan Kepala Keluarga kedua.`,
          confirmButtonColor: "#4f46e5",
        });
        return;
      }
      setIsKepalaKeluarga(true);
      setFormData(prev => ({
        ...prev,
        hubungan: "Kepala Keluarga",
        // Otomatis isi nama KK dari nama sendiri
        nama_kepala_keluarga: prev.nama_anggota_keluarga || prev.nama_kepala_keluarga,
      }));
    }
  };

  // ── Sinkron nama KK saat nama berubah dan dia adalah KK ──
  useEffect(() => {
    if (isKepalaKeluarga && formData.nama_anggota_keluarga) {
      setFormData(prev => ({ ...prev, nama_kepala_keluarga: prev.nama_anggota_keluarga }));
    }
  }, [formData.nama_anggota_keluarga, isKepalaKeluarga]);

  // ── Validasi section ──
  useEffect(() => {
    setSectionValid({
      dataDiri: formData.nik.length === 16 && formData.nama_anggota_keluarga.trim() !== "" && formData.tanggal_lahir !== "",
      alamat: formData.desa_id !== "",
      pekerjaan: formData.pendidikan !== "" || formData.pekerjaan.trim() !== "",
      keluarga: formData.hubungan !== "",
    });
  }, [formData]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleHubunganChange = (e) => {
    const val = e.target.value;
    if (val === "Kepala Keluarga") {
      // Gunakan toggle KK
      if (!isKepalaKeluarga) handleKepalaToggle();
      return;
    }
    // Jika sebelumnya KK dan sekarang ganti, lepas flag KK
    if (isKepalaKeluarga) {
      setIsKepalaKeluarga(false);
      setFormData(prev => ({
        ...prev,
        hubungan: val,
        nama_kepala_keluarga: kkInfo?.namaKK || "",
      }));
    } else {
      setFormData(prev => ({ ...prev, hubungan: val }));
    }
  };

  const toggleSection = (s) => setOpenSections(prev => ({ ...prev, [s]: !prev[s] }));

  const handleSubmit = (e) => {
    e.preventDefault();

    if (!sectionValid.dataDiri || !sectionValid.alamat || !sectionValid.keluarga) {
      const missing = [];
      if (!sectionValid.dataDiri) missing.push("Data Diri (NIK 16 digit, Nama, Tanggal Lahir)");
      if (!sectionValid.alamat) missing.push("Alamat & Domisili (Desa wajib dipilih)");
      if (!sectionValid.keluarga) missing.push("Data Keluarga (Hubungan wajib dipilih)");
      Swal.fire({
        icon: "warning",
        title: "Data Belum Lengkap",
        html: `Harap lengkapi bagian berikut:<ul class="text-left mt-2 space-y-1 text-sm">${missing.map(m => `<li>• ${m}</li>`).join("")}</ul>`,
        confirmButtonColor: "#4f46e5",
        confirmButtonText: "Oke, Saya Lengkapi",
      });
      return;
    }

    onSubmit(formData);
  };

  // ── Badge info anggota KK yang sudah ada ──
  const KkInfoBadge = () => {
    if (!formData.kode_keluarga.trim()) return null;
    if (kkLoading) return (
      <p className="text-xs text-slate-400 mt-1 flex items-center gap-1">
        <span className="w-3 h-3 border border-slate-400 border-t-transparent rounded-full animate-spin inline-block" />
        Mengecek kode keluarga...
      </p>
    );
    if (!kkInfo) return null;

    // Kode belum pernah dipakai (404 dari API)
    if (kkInfo.count === 0 && kkInfo.isNew) {
      return <p className="text-xs text-blue-600 mt-1 flex items-center gap-1"><Info size={12} /> Kode keluarga baru — belum ada anggota terdaftar.</p>;
    }

    // Ada anggota
    return (
      <div className="mt-2 p-2.5 bg-slate-50 rounded-lg border border-slate-200 text-xs text-slate-600 space-y-1">
        <p className="font-semibold text-slate-700 flex items-center gap-1">
          <Users size={12} /> {kkInfo.count} anggota terdaftar di KK ini
        </p>
        
      </div>
    );
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-0">
      {/* Progress Bar */}
      <div className="mb-4 p-4 bg-slate-50 rounded-xl">
        <div className="flex items-center justify-between text-xs text-slate-600 mb-2">
          <span>Progress Pengisian</span>
          <span className="font-semibold">
            {Object.values(sectionValid).filter(Boolean).length} / {Object.keys(sectionValid).length} Section
          </span>
        </div>
        <div className="w-full bg-slate-200 rounded-full h-2">
          <div
            className="bg-indigo-600 h-2 rounded-full transition-all duration-300"
            style={{ width: `${(Object.values(sectionValid).filter(Boolean).length / Object.keys(sectionValid).length) * 100}%` }}
          />
        </div>
      </div>

      {/* ── Section 1: Data Diri ── */}
      <div className="border border-slate-200 rounded-xl overflow-hidden mb-3">
        <SectionHeader title="1. Data Diri" isOpen={openSections.dataDiri} isValid={sectionValid.dataDiri} onClick={() => toggleSection("dataDiri")} />
        {openSections.dataDiri && (
          <div className="p-5 bg-white">
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              <div>
                <label className="block text-xs font-medium text-slate-700 mb-1.5">NIK <span className="text-red-500">*</span></label>
                <input type="text" name="nik" value={formData.nik} onChange={handleChange} maxLength="16"
                  className="w-full px-3 py-2 text-sm border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
                  placeholder="16 digit" required />
              </div>
              <div>
                <label className="block text-xs font-medium text-slate-700 mb-1.5">Nama Lengkap <span className="text-red-500">*</span></label>
                <input type="text" name="nama_anggota_keluarga" value={formData.nama_anggota_keluarga} onChange={handleChange}
                  className="w-full px-3 py-2 text-sm border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
                  placeholder="Nama sesuai KTP" required />
              </div>
              <div>
                <label className="block text-xs font-medium text-slate-700 mb-1.5">Jenis Kelamin <span className="text-red-500">*</span></label>
                <select name="jenis_kelamin" value={formData.jenis_kelamin} onChange={handleChange}
                  className="w-full px-3 py-2 text-sm border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent" required>
                  {JENIS_KELAMIN_OPTIONS.map(o => <option key={o} value={o}>{o}</option>)}
                </select>
              </div>
              <div>
                <label className="block text-xs font-medium text-slate-700 mb-1.5">Tanggal Lahir <span className="text-red-500">*</span></label>
                <input type="date" name="tanggal_lahir" value={formData.tanggal_lahir} onChange={handleChange}
                  className="w-full px-3 py-2 text-sm border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent" required />
              </div>
              <div>
                <label className="block text-xs font-medium text-slate-700 mb-1.5">Tempat Lahir</label>
                <input type="text" name="tempat_lahir" value={formData.tempat_lahir} onChange={handleChange}
                  className="w-full px-3 py-2 text-sm border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent" placeholder="Kota/Kabupaten" />
              </div>
              <div>
                <label className="block text-xs font-medium text-slate-700 mb-1.5">Golongan Darah</label>
                <select name="golongan_darah" value={formData.golongan_darah} onChange={handleChange}
                  className="w-full px-3 py-2 text-sm border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent">
                  {GOLONGAN_DARAH_OPTIONS.map(o => <option key={o} value={o}>{o || "-- Pilih --"}</option>)}
                </select>
              </div>
              <div>
                <label className="block text-xs font-medium text-slate-700 mb-1.5">Agama</label>
                <select name="agama" value={formData.agama} onChange={handleChange}
                  className="w-full px-3 py-2 text-sm border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent">
                  {AGAMA_OPTIONS.map(o => <option key={o} value={o}>{o || "-- Pilih --"}</option>)}
                </select>
              </div>
              <div>
                <label className="block text-xs font-medium text-slate-700 mb-1.5">Status</label>
                <select name="status" value={formData.status} onChange={handleChange}
                  className="w-full px-3 py-2 text-sm border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent">
                  {STATUS_OPTIONS.map(o => <option key={o} value={o}>{o || "-- Pilih --"}</option>)}
                </select>
              </div>
              <div>
                <label className="block text-xs font-medium text-slate-700 mb-1.5">Kewarganegaraan</label>
                <select name="kewarganegaraan" value={formData.kewarganegaraan} onChange={handleChange}
                  className="w-full px-3 py-2 text-sm border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent">
                  {KEWARGANEGARAAN_OPTIONS.map(o => <option key={o} value={o}>{o}</option>)}
                </select>
              </div>
              <div className="md:col-span-2 lg:col-span-3">
                <label className="block text-xs font-medium text-slate-700 mb-1.5">Etnis/Suku</label>
                <input type="text" name="etnis_suku" value={formData.etnis_suku} onChange={handleChange}
                  className="w-full px-3 py-2 text-sm border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
                  placeholder="Contoh: Jawa, Sunda, Batak" />
              </div>
            </div>
          </div>
        )}
      </div>

      {/* ── Section 2: Alamat ── */}
      <div className="border border-slate-200 rounded-xl overflow-hidden mb-3">
        <SectionHeader title="2. Alamat & Domisili" isOpen={openSections.alamat} isValid={sectionValid.alamat} onClick={() => toggleSection("alamat")} />
        {openSections.alamat && (
          <div className="p-5 bg-white">
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div>
                <label className="block text-xs font-medium text-slate-700 mb-1.5">Desa <span className="text-red-500">*</span></label>
                <select name="desa_id" value={formData.desa_id} onChange={handleChange}
                  className="w-full px-3 py-2 text-sm border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent" required>
                  <option value="">-- Pilih Desa --</option>
                  {desasList.map(d => <option key={d.id} value={d.id}>{d.nama_desa}</option>)}
                </select>
              </div>
              <div>
                <label className="block text-xs font-medium text-slate-700 mb-1.5">Posyandu</label>
                <select name="posyandu_id" value={formData.posyandu_id} onChange={handleChange}
                  className="w-full px-3 py-2 text-sm border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
                  disabled={!formData.desa_id}>
                  <option value="">-- Pilih Posyandu --</option>
                  {posyanduList.filter(p => !formData.desa_id || p.desa_id === parseInt(formData.desa_id))
                    .map(p => <option key={p.id} value={p.id}>{p.nama_posyandu || p.nama || `Posyandu ${p.id}`}</option>)}
                </select>
                {!formData.desa_id && <p className="text-xs text-amber-600 mt-1">Pilih Desa terlebih dahulu</p>}
              </div>
              <div>
                <label className="block text-xs font-medium text-slate-700 mb-1.5">RW</label>
                <input type="text" name="rw" value={formData.rw} onChange={handleChange}
                  className="w-full px-3 py-2 text-sm border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent" placeholder="001" />
              </div>
              <div>
                <label className="block text-xs font-medium text-slate-700 mb-1.5">RT</label>
                <input type="text" name="rt" value={formData.rt} onChange={handleChange}
                  className="w-full px-3 py-2 text-sm border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent" placeholder="001" />
              </div>
              <div>
                <label className="block text-xs font-medium text-slate-700 mb-1.5">Dusun</label>
                <input type="text" name="dusun" value={formData.dusun} onChange={handleChange}
                  className="w-full px-3 py-2 text-sm border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent" placeholder="Nama dusun" />
              </div>
              <div>
                <label className="block text-xs font-medium text-slate-700 mb-1.5">No. Telepon</label>
                <input type="text" name="telepon" value={formData.telepon} onChange={handleChange}
                  className="w-full px-3 py-2 text-sm border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent" placeholder="08xxxxxxxxxx" />
              </div>
              <div className="md:col-span-3">
                <label className="block text-xs font-medium text-slate-700 mb-1.5">Alamat Lengkap</label>
                <textarea name="alamat" value={formData.alamat} onChange={handleChange} rows="2"
                  className="w-full px-3 py-2 text-sm border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
                  placeholder="Alamat detail (jalan, nomor rumah, RT/RW)" />
              </div>
            </div>
          </div>
        )}
      </div>

      {/* ── Section 3: Pekerjaan & Pendidikan ── */}
      <div className="border border-slate-200 rounded-xl overflow-hidden mb-3">
        <SectionHeader title="3. Pekerjaan & Pendidikan" isOpen={openSections.pekerjaan} isValid={sectionValid.pekerjaan} onClick={() => toggleSection("pekerjaan")} />
        {openSections.pekerjaan && (
          <div className="p-5 bg-white">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-xs font-medium text-slate-700 mb-1.5">Pendidikan Terakhir</label>
                <select name="pendidikan" value={formData.pendidikan} onChange={handleChange}
                  className="w-full px-3 py-2 text-sm border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent">
                  {PENDIDIKAN_OPTIONS.map(o => <option key={o} value={o}>{o || "-- Pilih --"}</option>)}
                </select>
              </div>
              <div>
                <label className="block text-xs font-medium text-slate-700 mb-1.5">Pekerjaan</label>
                <input type="text" name="pekerjaan" value={formData.pekerjaan} onChange={handleChange}
                  className="w-full px-3 py-2 text-sm border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
                  placeholder="Contoh: PNS, Wiraswasta, Petani" />
              </div>
            </div>
          </div>
        )}
      </div>

      {/* ── Section 4: Data Keluarga ── */}
      <div className="border border-slate-200 rounded-xl overflow-hidden mb-3">
        <SectionHeader title="4. Data Keluarga" isOpen={openSections.keluarga} isValid={sectionValid.keluarga} onClick={() => toggleSection("keluarga")} />
        {openSections.keluarga && (
          <div className="p-5 bg-white space-y-4">

            {/* Baris: Kode Keluarga + Checkbox KK */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-xs font-medium text-slate-700 mb-1.5">Kode Keluarga</label>
                <input type="text" name="kode_keluarga" value={formData.kode_keluarga} onChange={handleChange}
                  className="w-full px-3 py-2 text-sm border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
                  placeholder="Kode identifikasi keluarga" />
                <KkInfoBadge />
              </div>

              {/* Centang Kepala Keluarga */}
              <div className="flex flex-col justify-center">
                <label className="block text-xs font-medium text-slate-700 mb-2">Status dalam KK</label>
                <button
                  type="button"
                  onClick={handleKepalaToggle}
                  disabled={!!(kkInfo?.hasKK && !isKepalaKeluarga)}
                  className={`inline-flex items-center gap-2.5 px-4 py-2.5 rounded-xl border-2 text-sm font-medium transition-all w-fit ${
                    isKepalaKeluarga
                      ? "border-indigo-500 bg-indigo-50 text-indigo-700"
                      : kkInfo?.hasKK
                      ? "border-slate-200 bg-slate-50 text-slate-400 cursor-not-allowed"
                      : "border-slate-300 bg-white text-slate-600 hover:border-indigo-400 hover:bg-indigo-50"
                  }`}
                >
                  <span className={`w-5 h-5 rounded border-2 flex items-center justify-center transition-all flex-shrink-0 ${
                    isKepalaKeluarga ? "border-indigo-600 bg-indigo-600" : "border-slate-400 bg-white"
                  }`}>
                    {isKepalaKeluarga && (
                      <svg className="w-3 h-3 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={3}>
                        <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
                      </svg>
                    )}
                  </span>
                  <span>
                    {isKepalaKeluarga ? "Saya adalah Kepala Keluarga" : kkInfo?.hasKK ? `Kepala Keluarga: ${kkInfo.namaKK || "sudah terisi"}` : "Tandai sebagai Kepala Keluarga"}
                  </span>
                </button>
                {kkInfo?.hasKK && !isKepalaKeluarga && (
                  <p className="text-xs text-slate-400 mt-1.5">
                    Kepala keluarga sudah terdaftar. Centang hanya bisa diubah dengan edit data KK yang bersangkutan.
                  </p>
                )}
              </div>
            </div>

            {/* Baris: Hubungan + Nama KK */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-xs font-medium text-slate-700 mb-1.5">
                  Hubungan dalam Keluarga <span className="text-red-500">*</span>
                </label>
                <select
                  name="hubungan"
                  value={formData.hubungan}
                  onChange={handleHubunganChange}
                  className="w-full px-3 py-2 text-sm border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
                  required
                >
                  <option value="">-- Pilih Hubungan --</option>
                  {ALL_HUBUNGAN.map(h => {
                    const isBlocked = !availableHubungan.includes(h) && h !== formData.hubungan;
                    return (
                      <option key={h} value={h} disabled={isBlocked}>
                        {h}{isBlocked ? " (sudah ada)" : ""}
                      </option>
                    );
                  })}
                </select>
              </div>

              <div>
                <label className="block text-xs font-medium text-slate-700 mb-1.5">Nama Kepala Keluarga</label>
                <input
                  type="text"
                  name="nama_kepala_keluarga"
                  value={formData.nama_kepala_keluarga}
                  onChange={handleChange}
                  readOnly={!!(kkInfo?.namaKK && !isKepalaKeluarga)}
                  className={`w-full px-3 py-2 text-sm border rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent ${
                    kkInfo?.namaKK && !isKepalaKeluarga
                      ? "bg-slate-50 border-slate-200 text-slate-500 cursor-not-allowed"
                      : "border-slate-300"
                  }`}
                  placeholder="Nama lengkap kepala keluarga"
                />
                {kkInfo?.namaKK && !isKepalaKeluarga && (
                  <p className="text-xs text-slate-400 mt-1">Terisi otomatis dari data kepala keluarga yang sudah ada.</p>
                )}
                {isKepalaKeluarga && (
                  <p className="text-xs text-indigo-500 mt-1">Terisi otomatis dari nama Anda.</p>
                )}
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Action Buttons */}
      <div className="flex justify-end gap-3 mt-6 pt-4 border-t border-slate-200">
        <button type="button" onClick={onCancel}
          className="px-4 py-2 rounded-xl border border-slate-200 text-slate-600 hover:bg-slate-50 transition-colors">
          Batal
        </button>
        <button
          type="submit"
          disabled={submitting || !sectionValid.dataDiri || !sectionValid.alamat || !sectionValid.keluarga || kkLoading}
          className="px-6 py-2 rounded-xl bg-indigo-600 text-white hover:bg-indigo-700 disabled:opacity-60 disabled:cursor-not-allowed transition-colors"
        >
          {submitting ? "Menyimpan..." : isEdit ? "Update Data" : "Simpan Data"}
        </button>
      </div>
    </form>
  );
};

export default FormPendudukAccordion;
