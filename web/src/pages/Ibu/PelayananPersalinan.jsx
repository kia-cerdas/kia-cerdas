// src/pages/Ibu/PelayananPersalinan.jsx
import React, { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import MainLayout from "../../components/Layout/MainLayout";
import { getKehamilanByIbuId, updateKehamilan, updateStatusKehamilan } from "../../services/kehamilan";
import { getIbuById } from "../../services/ibu";
import Swal from "sweetalert2";
import {
  getRingkasanPersalinanByKehamilanId,
  createRingkasanPersalinan,
  updateRingkasanPersalinan,
  deleteRingkasanPersalinan,
  getRiwayatMelahirkanByKehamilanId,
  createRiwayatMelahirkan,
  updateRiwayatMelahirkan,
  getKeteranganLahirByIbuId,
  createKeteranganLahir,
  updateKeteranganLahir,
} from "../../services/prosesMelahirkan";
import {
  createAnakDenganPenduduk, deleteAnak,
  getAnakByKehamilanId,
} from "../../services/Anak";
import { getRencanaByKehamilanId } from "../../services/persalinan";
import {
  Save, ArrowLeft, Edit2, CheckCircle, Printer, Trash2,
  Plus, ChevronDown, ChevronUp, Baby, X, Info, Link2, Eye, Lock, AlertCircle
} from "lucide-react";
import { getCurrentUser, isBidanUser, isDokterUser } from "../../services/auth";

// ─── helpers ────────────────────────────────────────────────────────────────

const DetailItem = ({ label, value }) => (
  <div className="flex flex-col">
    <span className="text-xs text-gray-500 font-medium uppercase tracking-wide">{label}</span>
    <span className="text-sm text-gray-800 font-semibold mt-0.5 break-all">{value ?? "-"}</span>
  </div>
);

// Helper function to convert month number to Roman numeral
const toRomanNumeral = (month) => {
  const romanNumerals = ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII"];
  return romanNumerals[month - 1] || "";
};

// Helper function to generate official nomor surat format
// Format: 09.[nomor_urut]/[nama_lembaga]/[bulan_romawi]/[tahun]
const generateNomorSurat = (nomorUrut, namaLembaga, tanggal) => {
  const date = new Date(tanggal);
  const month = date.getMonth() + 1;
  const year = date.getFullYear();
  const monthRoman = toRomanNumeral(month);
  const paddedNomor = String(nomorUrut).padStart(3, '0');
  return `09.${paddedNomor}/${namaLembaga}/${monthRoman}/${year}`;
};

// Validation function for nomor surat format
const validateNomorSuratFormat = (nomorSurat) => {
  // Expected format: 09.[nomor_urut]/[nama_lembaga]/[bulan_romawi]/[tahun]
  const pattern = /^09\.\d{3}\/[^\/]+\/[IVX]+\/\d{4}$/;
  return pattern.test(nomorSurat);
};

// Helper: tanggal hari ini dalam format YYYY-MM-DD (untuk batas max input date)
const getTodayStr = () => new Date().toISOString().split("T")[0];

const emptyRingkasan = (ibuData) => ({
  tanggal_melahirkan: "", umur_kehamilan_minggu: "",
  penolong_proses_melahirkan: "", cara_melahirkan: "",
  keadaan_ibu: "", keadaan_ibu_detail_sakit: "", keterangan_tambahan_ibu: "",
  kb_pasca_melahirkan: "",
  gravida: ibuData?.gravida ?? "", paritas: ibuData?.paritas ?? "", abortus: ibuData?.abortus ?? "",
  kondisi_bayi_segera_menangis: false,
  kondisi_bayi_menangis_beberapa_saat: false,
  kondisi_bayi_tidak_menangis: false,
  kondisi_bayi_seluruh_tubuh_kemerahan: false,
  kondisi_bayi_anggota_gerak_kebiruan: false,
  kondisi_bayi_seluruh_tubuh_biru: false,
  kondisi_bayi_kelainan_bawaan: false,
  kondisi_bayi_kelainan_bawaan_detail: "",
  kondisi_bayi_meninggal: false,
  asuhan_imd_1_jam_pertama: false,
  asuhan_suntikan_vitamin_k1: false,
  asuhan_salep_mata_antibiotika: false,
  asuhan_imunisasi_hb0: false,
  keterangan_tambahan_bayi: "",
  bayi_anak_ke: "", bayi_berat_lahir_kg: "",
  bayi_panjang_badan_cm: "", bayi_lingkar_kepala_cm: "",
  nama_anak: "", anak_tanggal_lahir: "", anak_jenis_kelamin: "",
   tempat_lahir: "", 
  anak_nama_ibu: ibuData?.kependudukan?.nama_anggota_keluarga || "",
  anak_nama_ayah: ibuData?.suami?.nama_anggota_keluarga || "",
});

// ─── SuratKeteranganLahir ───────────────────────────────────────────────────

const SuratKeteranganLahir = ({ data }) => (
  <div id="surat-keterangan-lahir" className="bg-white p-8 max-w-3xl mx-auto font-serif text-sm text-gray-800 border border-gray-300 shadow">
    <h1 className="text-center text-xl font-bold tracking-widest mb-2">SURAT KETERANGAN LAHIR</h1>
    <div className="flex justify-center mb-4">
      <span className="text-sm">No. <span className="inline-block border-b border-gray-800 w-56 ml-1">{data?.nomor_surat || ""}</span></span>
    </div>
    <p className="mb-4">Yang bertandatangan di bawah ini menerangkan bahwa:</p>

    <div className="mb-4">
      <span>Pada hari ini </span>
      <span className="inline-block border-b border-gray-800 w-32 mx-1">{data?.hari_lahir || ""}</span>
      <span> tanggal </span>
      <span className="inline-block border-b border-gray-800 w-40 mx-1">{data?.tanggal_lahir ? new Date(data.tanggal_lahir).toLocaleDateString("id-ID") : ""}</span>
      <span> pukul </span>
      <span className="inline-block border-b border-gray-800 w-24 mx-1">{data?.pukul_lahir || ""}</span>
    </div>

    <p className="font-bold mb-3">Telah lahir seorang bayi:</p>
    <table className="w-full mb-4 text-sm">
      <tbody>
        <tr><td className="py-1.5 w-40">Nama</td><td><span className="inline-block border-b border-gray-800 w-full">{data?.nama_bayi_diberi_nama || ""}</span></td></tr>
        <tr><td className="py-1.5">Jenis Kelamin</td><td><span className="inline-block border-b border-gray-800 w-full">{data?.jenis_kelamin || ""}</span></td></tr>
        <tr><td className="py-1.5">Anak ke-</td><td><span className="inline-block border-b border-gray-800 w-24">{data?.anak_ke || ""}</span></td></tr>
        <tr><td className="py-1.5">Berat</td><td><span className="inline-block border-b border-gray-800 w-24">{data?.berat_lahir_gram || ""}</span> gram</td></tr>
        <tr><td className="py-1.5">Panjang</td><td><span className="inline-block border-b border-gray-800 w-24">{data?.panjang_badan_cm || ""}</span> cm</td></tr>
        <tr><td className="py-1.5">Lingkar Kepala</td><td><span className="inline-block border-b border-gray-800 w-24">{data?.lingkar_kepala_cm || ""}</span> cm</td></tr>
      </tbody>
    </table>

    <p className="font-bold mb-3">Dari orang tua:</p>
    <table className="w-full mb-4 text-sm">
      <tbody>
        <tr><td className="py-1.5 w-40">Nama Ibu</td><td><span className="inline-block border-b border-gray-800 w-full">{data?.nama_ibu || ""}</span></td></tr>
        <tr><td className="py-1.5">Nama Ayah</td><td><span className="inline-block border-b border-gray-800 w-full">{data?.nama_ayah || ""}</span></td></tr>
        <tr><td className="py-1.5">Pekerjaan</td><td><span className="inline-block border-b border-gray-800 w-full">{data?.pekerjaan_orang_tua || ""}</span></td></tr>
        <tr><td className="py-1.5">Alamat</td><td><span className="inline-block border-b border-gray-800 w-full">{data?.alamat_orang_tua || ""}</span></td></tr>
      </tbody>
    </table>

    <table className="w-full mb-4 text-sm">
      <tbody>
        <tr><td className="py-1.5 w-48">Tempat lahir</td><td><span className="inline-block border-b border-gray-800 w-full">{data?.lokasi_persalinan || ""}</span></td></tr>
        <tr><td className="py-1.5">Alamat tempat lahir</td><td><span className="inline-block border-b border-gray-800 w-full">{data?.alamat_lokasi_persalinan || ""}</span></td></tr>
      </tbody>
    </table>

    <div className="grid grid-cols-3 text-center gap-6 mt-8 mb-4">
      <div>
        <p className="mb-20">Saksi I</p>
        <p className="border-t border-gray-800 pt-1">(<span className="inline-block border-b border-gray-800 w-28"></span>)</p>
      </div>
      <div>
        <p className="mb-20">Saksi II</p>
        <p className="border-t border-gray-800 pt-1">(<span className="inline-block border-b border-gray-800 w-28"></span>)</p>
      </div>
      <div>
        <p className="mb-20">Penolong Kelahiran</p>
        <p className="border-t border-gray-800 pt-1">(<span className="inline-block border-b border-gray-800 w-28">{data?.nama_penolong_kelahiran || ""}</span>)</p>
      </div>
    </div>

    <div className="text-right mt-4">
      <p className="mb-1">{data?.tanggal_surat ? new Date(data.tanggal_surat).toLocaleDateString("id-ID", { day: 'numeric', month: 'long', year: 'numeric' }) : ""}</p>
    </div>
  </div>
);

// ─── KelahiranCard ──────────────────────────────────────────────────────────

function KelahiranCard({ index, ringkasan, anakList, kehamilanId, ibuId, onEdit, onAnakAdded, onDelete, canEdit }) {
  const [expanded, setExpanded] = useState(index === 0);

  const kondisiList = [
    ringkasan.kondisi_bayi_segera_menangis && "Segera menangis",
    ringkasan.kondisi_bayi_menangis_beberapa_saat && "Menangis beberapa saat",
    ringkasan.kondisi_bayi_tidak_menangis && "Tidak menangis",
    ringkasan.kondisi_bayi_seluruh_tubuh_kemerahan && "Seluruh tubuh kemerahan",
    ringkasan.kondisi_bayi_anggota_gerak_kebiruan && "Anggota gerak kebiruan",
    ringkasan.kondisi_bayi_seluruh_tubuh_biru && "Seluruh tubuh biru",
    ringkasan.kondisi_bayi_kelainan_bawaan && "Kelainan bawaan",
    ringkasan.kondisi_bayi_meninggal && "Meninggal",
  ].filter(Boolean);

  const asuhanList = [
    ringkasan.asuhan_imd_1_jam_pertama && "IMD 1 jam pertama",
    ringkasan.asuhan_suntikan_vitamin_k1 && "Suntikan Vitamin K1",
    ringkasan.asuhan_salep_mata_antibiotika && "Salep mata antibiotika",
    ringkasan.asuhan_imunisasi_hb0 && "Imunisasi HB0",
  ].filter(Boolean);

  return (
    <div className="border border-indigo-100 rounded-2xl overflow-hidden shadow-sm">
      <div
        className="flex items-center justify-between px-5 py-4 bg-gradient-to-r from-indigo-50 to-white cursor-pointer select-none"
        onClick={() => setExpanded((v) => !v)}
      >
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-full bg-indigo-600 text-white flex items-center justify-center text-sm font-bold flex-shrink-0">
            {index + 1}
          </div>
          <div>
            <p className="font-bold text-gray-800 text-sm md:text-base">
              Kelahiran ke-{index + 1}
            </p>
            <p className="text-xs text-gray-500 break-all">
  {ringkasan.tanggal_melahirkan || "-"} &bull; {ringkasan.cara_melahirkan || "-"} &bull; {anakList.length} anak
</p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          {canEdit && onEdit && (
            <button
              onClick={(e) => { e.stopPropagation(); onEdit(ringkasan); }}
              className="text-xs text-indigo-600 border border-indigo-300 px-3 py-1.5 rounded-lg hover:bg-indigo-50 flex items-center gap-1"
            >
              <Edit2 size={12} /> Edit
            </button>
          )}
          {canEdit && onDelete && (
            <button
              onClick={(e) => { e.stopPropagation(); onDelete(ringkasan.id_ringkasan || ringkasan.id || 0); }}
              className="text-xs text-red-600 border border-red-300 px-3 py-1.5 rounded-lg hover:bg-red-50 flex items-center gap-1"
            >
              <Trash2 size={12} /> Hapus
            </button>
          )}
          {expanded ? <ChevronUp size={18} className="text-gray-400" /> : <ChevronDown size={18} className="text-gray-400" />}
        </div>
      </div>

      {expanded && (
        <div className="p-5 space-y-5 bg-white">
          <div>
            <p className="text-xs font-bold text-gray-400 uppercase tracking-widest mb-3">Ringkasan Persalinan</p>
            <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-3 bg-gray-50 rounded-xl p-4">
              <DetailItem label="Tanggal Melahirkan" value={ringkasan.tanggal_melahirkan} />
              <DetailItem label="Umur Kehamilan" value={ringkasan.umur_kehamilan_minggu ? `${ringkasan.umur_kehamilan_minggu} mgg` : "-"} />
              <DetailItem label="Penolong" value={ringkasan.penolong_proses_melahirkan} />
              <DetailItem label="Cara Melahirkan" value={ringkasan.cara_melahirkan} />
              <DetailItem label="Keadaan Ibu" value={ringkasan.keadaan_ibu} />
              <DetailItem label="KB Pasca Salin" value={ringkasan.kb_pasca_melahirkan} />
            </div>
          </div>

          {(kondisiList.length > 0 || asuhanList.length > 0) && (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {kondisiList.length > 0 && (
                <div className="bg-amber-50 rounded-xl p-4">
                  <p className="text-xs font-bold text-amber-700 uppercase tracking-widest mb-2">Kondisi Bayi Saat Lahir</p>
                  <div className="flex flex-wrap gap-1.5">
                    {kondisiList.map((k, i) => (
                      <span key={i} className="text-xs bg-amber-100 text-amber-800 px-2.5 py-1 rounded-full font-medium">{k}</span>
                    ))}
                  </div>
                </div>
              )}
              {asuhanList.length > 0 && (
                <div className="bg-green-50 rounded-xl p-4">
                  <p className="text-xs font-bold text-green-700 uppercase tracking-widest mb-2">Asuhan Bayi Baru Lahir</p>
                  <div className="flex flex-wrap gap-1.5">
                    {asuhanList.map((a, i) => (
                      <span key={i} className="text-xs bg-green-100 text-green-800 px-2.5 py-1 rounded-full font-medium">✓ {a}</span>
                    ))}
                  </div>
                </div>
              )}
            </div>
          )}

          <div>
            <p className="text-xs font-bold text-gray-400 uppercase tracking-widest mb-3 flex items-center gap-2">
              <Baby size={14} /> Anak yang Lahir ({anakList.length})
            </p>
            {anakList.length === 0 ? (
              <p className="text-sm text-gray-400 italic">Belum ada data anak untuk kelahiran ini.</p>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                {anakList.map((anak) => (
                  <div key={anak.id} className="rounded-xl border border-indigo-100 bg-indigo-50/40 p-4">
                    <div className="flex flex-col gap-1">
  <p className="font-bold text-gray-800">{anak.nama || "Tanpa Nama"}</p>
  <p className="text-xs text-gray-500">
    Anak ke-{anak.anak_ke ?? "-"} &bull; {anak.jenis_kelamin || "-"}
  </p>
  <p className="text-xs text-gray-400">Lahir: {anak.tanggal_lahir || "-"}</p>
</div>
                    <div className="mt-3 grid grid-cols-3 gap-2 text-xs text-gray-600">
                      <div className="rounded-lg bg-white px-2 py-1.5 border text-center">
                        <p className="text-gray-400 text-[10px]">BB</p>
                        <p className="font-bold">{anak.berat_lahir_kg ?? "-"} kg</p>
                      </div>
                      <div className="rounded-lg bg-white px-2 py-1.5 border text-center">
                        <p className="text-gray-400 text-[10px]">PB</p>
                        <p className="font-bold">{anak.tinggi_lahir_cm ?? "-"} cm</p>
                      </div>
                      <div className="rounded-lg bg-white px-2 py-1.5 border text-center">
                        <p className="text-gray-400 text-[10px]">LK</p>
                        <p className="font-bold">{anak.lingkar_kepala_cm ?? "-"} cm</p>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}

// ─── RingkasanForm ──────────────────────────────────────────────────────────

function RingkasanForm({ initial, onSubmit, onCancel, saving, title }) {
  const [form, setForm] = useState(initial || emptyRingkasan());
  const [errors, setErrors] = useState({});
  const todayStr = getTodayStr();

  // Auto-fill anak_tanggal_lahir when tanggal_melahirkan changes (selalu ikut tanggal_melahirkan, tidak bisa diedit manual)
  useEffect(() => {
    if (form.tanggal_melahirkan !== form.anak_tanggal_lahir) {
      setForm(prev => ({ ...prev, anak_tanggal_lahir: prev.tanggal_melahirkan }));
    }
  }, [form.tanggal_melahirkan]);

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setForm((prev) => ({ ...prev, [name]: type === "checkbox" ? checked : value }));
    // Clear error when field is changed
    if (errors[name]) {
      setErrors(prev => ({ ...prev, [name]: "" }));
    }
  };

  const validateForm = () => {
    const newErrors = {};

    if (!form.tanggal_melahirkan) {
      newErrors.tanggal_melahirkan = "Tanggal melahirkan wajib diisi";
    } else if (form.tanggal_melahirkan > todayStr) {
      newErrors.tanggal_melahirkan = "Tanggal melahirkan tidak boleh lebih dari hari ini";
    }
    if (!form.penolong_proses_melahirkan || !form.penolong_proses_melahirkan.trim()) {
      newErrors.penolong_proses_melahirkan = "Penolong proses melahirkan wajib diisi";
    }
    if (!form.cara_melahirkan) {
      newErrors.cara_melahirkan = "Cara melahirkan wajib dipilih";
    }
    if (!form.keadaan_ibu || !form.keadaan_ibu.trim()) {
      newErrors.keadaan_ibu = "Keadaan ibu wajib diisi";
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!validateForm()) {
      return;
    }
    onSubmit(form);
  };

  return (
    <form onSubmit={handleSubmit} className="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 space-y-5">
      <div className="flex items-center justify-between">
        <h2 className="text-lg font-bold text-[#185FA5]">{title}</h2>
        {onCancel && (
          <button type="button" onClick={onCancel} className="p-2 rounded-full hover:bg-gray-100">
            <X size={18} className="text-gray-500" />
          </button>
        )}
      </div>

      {/* Info Persalinan */}
      <div>
        <p className="text-xs font-bold text-gray-400 uppercase tracking-widest mb-3">Info Persalinan</p>
        <div className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-6 gap-3">
          <div><label className="block text-xs font-medium mb-1">Tanggal Melahirkan <span className="text-red-500">*</span></label>
            <input type="date" name="tanggal_melahirkan" value={form.tanggal_melahirkan} max={todayStr} onChange={handleChange} className={`w-full border rounded-lg px-2 py-1.5 text-sm ${errors.tanggal_melahirkan ? "border-red-500 bg-red-50" : ""}`} />
            {errors.tanggal_melahirkan && <p className="text-red-500 text-xs mt-1">{errors.tanggal_melahirkan}</p>}
          </div>
          <div><label className="block text-xs font-medium mb-1">Umur Kehamilan (Mgg)</label>
            <input type="number" name="umur_kehamilan_minggu" value={form.umur_kehamilan_minggu} onChange={handleChange} className="w-full border rounded-lg px-2 py-1.5 text-sm" /></div>
          <div><label className="block text-xs font-medium mb-1">Penolong <span className="text-red-500">*</span></label>
            <input name="penolong_proses_melahirkan" value={form.penolong_proses_melahirkan} onChange={handleChange} className={`w-full border rounded-lg px-2 py-1.5 text-sm ${errors.penolong_proses_melahirkan ? "border-red-500 bg-red-50" : ""}`} />
            {errors.penolong_proses_melahirkan && <p className="text-red-500 text-xs mt-1">{errors.penolong_proses_melahirkan}</p>}
          </div>
          <div><label className="block text-xs font-medium mb-1">Cara Melahirkan <span className="text-red-500">*</span></label>
            <select name="cara_melahirkan" value={form.cara_melahirkan} onChange={handleChange} className={`w-full border rounded-lg px-2 py-1.5 text-sm ${errors.cara_melahirkan ? "border-red-500 bg-red-50" : ""}`}>
              <option value="">-- Pilih --</option>
              <option>Spontan/Normal</option><option>SC</option><option>Vakum</option>
            </select>
            {errors.cara_melahirkan && <p className="text-red-500 text-xs mt-1">{errors.cara_melahirkan}</p>}
          </div>
          <div><label className="block text-xs font-medium mb-1">Keadaan Ibu <span className="text-red-500">*</span></label>
            <input name="keadaan_ibu" value={form.keadaan_ibu} onChange={handleChange} className={`w-full border rounded-lg px-2 py-1.5 text-sm ${errors.keadaan_ibu ? "border-red-500 bg-red-50" : ""}`} />
            {errors.keadaan_ibu && <p className="text-red-500 text-xs mt-1">{errors.keadaan_ibu}</p>}
          </div>
          <div><label className="block text-xs font-medium mb-1">KB Pasca Salin</label>
            <input name="kb_pasca_melahirkan" value={form.kb_pasca_melahirkan} onChange={handleChange} className="w-full border rounded-lg px-2 py-1.5 text-sm" /></div>
        </div>
      </div>

      {/* Gravida, Paritas, Abortus (dari ibu / diubah) */}
      <div className="grid grid-cols-3 gap-3">
        <div><label className="block text-xs font-medium mb-1">Gravida (G)</label>
          <input type="number" name="gravida" value={form.gravida} onChange={handleChange} className="w-full border rounded-lg px-2 py-1.5 text-sm" /></div>
        <div><label className="block text-xs font-medium mb-1">Paritas (P)</label>
          <input type="number" name="paritas" value={form.paritas} onChange={handleChange} className="w-full border rounded-lg px-2 py-1.5 text-sm" /></div>
        <div><label className="block text-xs font-medium mb-1">Abortus (A)</label>
          <input type="number" name="abortus" value={form.abortus} onChange={handleChange} className="w-full border rounded-lg px-2 py-1.5 text-sm" /></div>
      </div>

      {/* Data Bayi & Anak (digabung) */}
      {/* Data Bayi & Anak (digabung) */}
      <div>
        <p className="text-xs font-bold text-gray-400 uppercase tracking-widest mb-3">Data Bayi / Anak Lahir</p>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
                    <div><label className="block text-xs font-medium mb-1">Nama Anak</label>
            <input name="nama_anak" value={form.nama_anak} onChange={handleChange} className="w-full border rounded-lg px-2 py-1.5 text-sm" /></div>
                      <div><label className="block text-xs font-medium mb-1">Tanggal Lahir Anak</label>
            <input type="date" name="anak_tanggal_lahir" value={form.anak_tanggal_lahir} readOnly disabled title="Otomatis mengikuti Tanggal Melahirkan" className="w-full bg-gray-100 border border-gray-200 text-gray-500 rounded-lg px-2 py-1.5 text-sm cursor-not-allowed" /></div>
             <div>
      <label className="block text-xs font-medium mb-1">Tempat Lahir</label>  
      <input name="tempat_lahir" value={form.tempat_lahir} onChange={handleChange} placeholder="Contoh: Balige" className="w-full border rounded-lg px-2 py-1.5 text-sm" />
    </div>
          <div><label className="block text-xs font-medium mb-1">Jenis Kelamin</label>
            <select name="anak_jenis_kelamin" value={form.anak_jenis_kelamin} onChange={handleChange} className="w-full border rounded-lg px-2 py-1.5 text-sm">
              <option value="">-- Pilih --</option>
              <option value="Laki-laki">Laki-laki</option>
              <option value="Perempuan">Perempuan</option>
            </select></div>
          <div><label className="block text-xs font-medium mb-1">Anak Ke</label>
            <input type="number" name="bayi_anak_ke" value={form.bayi_anak_ke} onChange={handleChange} className="w-full border rounded-lg px-2 py-1.5 text-sm" /></div>
          <div><label className="block text-xs font-medium mb-1">Berat (kg)</label>
            <input type="number" step="0.01" name="bayi_berat_lahir_kg" value={form.bayi_berat_lahir_kg} onChange={handleChange} className="w-full border rounded-lg px-2 py-1.5 text-sm" /></div>
          <div><label className="block text-xs font-medium mb-1">Panjang (cm)</label>
            <input type="number" name="bayi_panjang_badan_cm" value={form.bayi_panjang_badan_cm} onChange={handleChange} className="w-full border rounded-lg px-2 py-1.5 text-sm" /></div>
          <div><label className="block text-xs font-medium mb-1">Lingkar Kepala (cm)</label>
            <input type="number" name="bayi_lingkar_kepala_cm" value={form.bayi_lingkar_kepala_cm} onChange={handleChange} className="w-full border rounded-lg px-2 py-1.5 text-sm" /></div>
        </div>
      </div>	

      {/* Kondisi Bayi */}
      <div className="bg-gray-50 rounded-xl p-4 space-y-3">
        <p className="text-xs font-bold text-gray-500 uppercase tracking-widest">Kondisi Bayi Saat Lahir</p>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-2 text-sm">
          {[
            ["kondisi_bayi_segera_menangis", "Segera menangis"],
            ["kondisi_bayi_menangis_beberapa_saat", "Menangis beberapa saat"],
            ["kondisi_bayi_tidak_menangis", "Tidak menangis"],
            ["kondisi_bayi_seluruh_tubuh_kemerahan", "Seluruh tubuh kemerahan"],
            ["kondisi_bayi_anggota_gerak_kebiruan", "Anggota gerak kebiruan"],
            ["kondisi_bayi_seluruh_tubuh_biru", "Seluruh tubuh biru"],
            ["kondisi_bayi_kelainan_bawaan", "Kelainan bawaan"],
            ["kondisi_bayi_meninggal", "Meninggal"],
          ].map(([name, label]) => (
            <label key={name} className="flex items-center gap-2 cursor-pointer">
              <input type="checkbox" name={name} checked={form[name]} onChange={handleChange} className="w-4 h-4 accent-indigo-600" />
              {label}
            </label>
          ))}
        </div>
        {form.kondisi_bayi_kelainan_bawaan && (
          <div><label className="block text-xs font-medium mb-1">Detail Kelainan Bawaan</label>
            <input name="kondisi_bayi_kelainan_bawaan_detail" value={form.kondisi_bayi_kelainan_bawaan_detail} onChange={handleChange} className="w-full border rounded-lg px-2 py-1.5 text-sm" /></div>
        )}
      </div>

      {/* Asuhan Bayi */}
      <div className="bg-gray-50 rounded-xl p-4 space-y-3">
        <p className="text-xs font-bold text-gray-500 uppercase tracking-widest">Asuhan Bayi Baru Lahir</p>
        <div className="grid grid-cols-1 gap-2 text-sm">
          {[
            ["asuhan_imd_1_jam_pertama", "Inisiasi Menyusu Dini (IMD) dalam 1 jam pertama"],
            ["asuhan_suntikan_vitamin_k1", "Suntikan Vitamin K1"],
            ["asuhan_salep_mata_antibiotika", "Salep mata Antibiotika Profilaksis"],
            ["asuhan_imunisasi_hb0", "Imunisasi HB0"],
          ].map(([name, label]) => (
            <label key={name} className="flex items-center gap-2 cursor-pointer">
              <input type="checkbox" name={name} checked={form[name]} onChange={handleChange} className="w-4 h-4 accent-indigo-600" />
              {label}
            </label>
          ))}
        </div>
        <div><label className="block text-xs font-medium mb-1">Keterangan Tambahan Bayi</label>
          <textarea name="keterangan_tambahan_bayi" value={form.keterangan_tambahan_bayi} onChange={handleChange} rows={2} className="w-full border rounded-lg px-2 py-1.5 text-sm" /></div>
      </div>

      <div className="flex gap-2 pt-2">
        <button type="submit" disabled={saving}
          className="bg-indigo-600 text-white px-6 py-2.5 rounded-xl flex items-center gap-2 hover:bg-indigo-700 font-semibold text-sm">
          <Save size={16} /> {saving ? "Menyimpan..." : "Simpan"}
        </button>
        {onCancel && (
          <button type="button" onClick={onCancel}
            className="px-6 py-2.5 rounded-xl border border-gray-200 text-gray-600 hover:bg-gray-50 text-sm">
            Batal
          </button>
        )}
      </div>
    </form>
  );
}

// ─── HALAMAN UTAMA ──────────────────────────────────────────────────────────

export default function PelayananPersalinan() {
  const { id } = useParams();
  const navigate = useNavigate();

  // Role-based access control
  const user = getCurrentUser();
  const isBidan = isBidanUser(user);
  const isDokter = isDokterUser(user);

  // Bingkasan Melahirkan (Ringkasan): dokter melihat, bidan mengelola
  const canEditRingkasan = isBidan;

  // Riwayat Melahirkan: dokter melibat, bidan mengelola
  const canEditRiwayat = isBidan;

  // Keterangan Lahir: dokter melibat, bidan mengelola
  const canEditKeterangan = isBidan;

  const [activeTab, setActiveTab] = useState("ringkasan");
  const [kehamilan, setKehamilan] = useState(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [ibuData, setIbuData] = useState(null); // data gravida, paritas, abortus ibu

  const [kelahiranList, setKelahiranList] = useState([]);
  const [showNewForm, setShowNewForm] = useState(false);
  const [editTarget, setEditTarget] = useState(null);

  const [modeRiwayat, setModeRiwayat] = useState("empty");
  const [riwayat, setRiwayat] = useState(null);
  const [formRiwayat, setFormRiwayat] = useState({
    g_gravida: "", p_partus: "", a_abortus: "",
    tanggal_melahirkan: "", fasyankes_tempat_melahirkan: "",
    cara_melahirkan_spontan: false, tindakan_sc: false,
  });

  const [modeKeterangan, setModeKeterangan] = useState("empty");
  const [keterangan, setKeterangan] = useState(null);
  const [selectedRingkasanId, setSelectedRingkasanId] = useState(""); // id ringkasan yang dipilih untuk keterangan
  const [formKeterangan, setFormKeterangan] = useState({
    nomor_surat: "", hari_lahir: "", tanggal_lahir: "", pukul_lahir: "",
    jenis_kelamin: "", jenis_kelahiran: "", anak_ke: "", usia_gestasi_minggu: "",
    berat_lahir_gram: "", panjang_badan_cm: "", lingkar_kepala_cm: "",
    lokasi_persalinan: "", alamat_lokasi_persalinan: "",
    nama_bayi_diberi_nama: "", nama_ibu: "", nik_ibu: "",
    nama_ayah: "", pekerjaan_orang_tua: "", alamat_orang_tua: "",
    nama_penolong_kelahiran: "",
  });

  // Auto-generate nomor surat when switching to form mode for new keterangan
  useEffect(() => {
    if (modeKeterangan === "form" && !keterangan) {
      // Generate default nomor surat with current date and placeholder values
      const today = new Date();
      const defaultNomor = generateNomorSurat(1, "PUSKESMAS", today);
      setFormKeterangan(prev => ({
        ...prev,
        nomor_surat: defaultNomor,
      }));
    }
  }, [modeKeterangan, keterangan]);

  // Auto-update nomor surat when tanggal_lahir changes
  useEffect(() => {
    if (modeKeterangan === "form" && formKeterangan.tanggal_lahir) {
      const nomorUrut = 1; // Default sequence number
      const namaLembaga = "PUSKESMAS"; // Default institution name
      const updatedNomor = generateNomorSurat(nomorUrut, namaLembaga, formKeterangan.tanggal_lahir);
      setFormKeterangan(prev => ({
        ...prev,
        nomor_surat: updatedNomor,
      }));
    }
  }, [formKeterangan.tanggal_lahir, modeKeterangan]);

  // Auto-fill locked fields from ibuData when ibuData changes
  useEffect(() => {
    if (ibuData) {
      setFormKeterangan(prev => ({
        ...prev,
        nama_ibu: ibuData?.kependudukan?.nama_lengkap || prev.nama_ibu,
        nik_ibu: ibuData?.kependudukan?.nik || prev.nik_ibu,
        nama_ayah: ibuData?.suami?.nama_lengkap || ibuData?.nama_suami || ibuData?.nama_ayah || prev.nama_ayah,
        pekerjaan_orang_tua: ibuData?.kependudukan?.pekerjaan || prev.pekerjaan_orang_tua,
        alamat_orang_tua: ibuData?.kependudukan?.dusun || ibuData?.kependudukan?.alamat || prev.alamat_orang_tua,
      }));
    }
  }, [ibuData]);
  const [autoFilledFields, setAutoFilledFields] = useState([]);

  // VALIDASI: Cek rencana persalinan untuk date-based locking
  const [rencanaPersalinan, setRencanaPersalinan] = useState(null);
  const [canAccessPersalinan, setCanAccessPersalinan] = useState(false);
  const [lockMessage, setLockMessage] = useState("");

  const fetchKelahiran = async (kehamilanId, ibuIdParam) => {
    try {
      const [ringkasanList, anakList] = await Promise.all([
        getRingkasanPersalinanByKehamilanId(kehamilanId),
        getAnakByKehamilanId(kehamilanId),
      ]);
      const safeRingkasan = Array.isArray(ringkasanList) ? ringkasanList : [];
      const safeAnak = Array.isArray(anakList) ? anakList : [];
      const sorted = [...safeRingkasan].sort(
        (a, b) => new Date(a.tanggal_melahirkan) - new Date(b.tanggal_melahirkan)
      );
      const grouped = sorted.map((r, i) => {
        const nextDate = sorted[i + 1]?.tanggal_melahirkan;
        const anakForThis = safeAnak.filter((a) => {
          if (!a.tanggal_lahir) return i === 0;
          const tgl = new Date(a.tanggal_lahir);
          const from = new Date(r.tanggal_melahirkan);
          const to = nextDate ? new Date(nextDate) : new Date("9999-12-31");
          return tgl >= from && tgl < to;
        });
        return { ringkasan: r, anakList: anakForThis };
      });
      if (grouped.length > 0) {
        const allGroupedAnakIds = grouped.flatMap((g) => g.anakList.map((a) => a.id));
        const orphans = safeAnak.filter((a) => !allGroupedAnakIds.includes(a.id));
        grouped[0].anakList = [...orphans, ...grouped[0].anakList];
      }
      setKelahiranList(grouped);
    } catch (err) {
      console.error("Error fetching kelahiran:", err);
    }
  };

  useEffect(() => {
    const fetchData = async () => {
      try {
        // ambil data ibu
        const ibuResponse = await getIbuById(id);
        setIbuData(ibuResponse); // asumsi response langsung berisi field gravida, paritas, abortus

        // Prefill default riwayat & keterangan from ibuData
        const defaultGravida = ibuResponse?.gravida ?? "";
        const defaultParitas = ibuResponse?.paritas ?? "";
        const defaultAbortus = ibuResponse?.abortus ?? "";

        const kehamilanListRes = await getKehamilanByIbuId(id);
        if (kehamilanListRes.length > 0) {
          const aktif = kehamilanListRes[0];
          setKehamilan(aktif);
          await fetchKelahiran(aktif.id, id);

          // VALIDASI: Fetch rencana persalinan untuk date-based locking
          try {
            const rencanaData = await getRencanaByKehamilanId(aktif.id);
            if (rencanaData && rencanaData.length > 0) {
              setRencanaPersalinan(rencanaData[0]);

              // Cek apakah tanggal hari ini sudah melewati atau sama dengan tanggal rencana persalinan
              const today = new Date();
              today.setHours(0, 0, 0, 0);

              // Parse tanggal rencana dari bulan dan tahun
              const rencanaBulan = rencanaData[0].perkiraan_bulan_persalinan;
              const rencanaTahun = rencanaData[0].perkiraan_tahun_persalinan;

              if (rencanaBulan && rencanaTahun) {
                // Normalize month name (trim and capitalize first letter)
                const normalizedBulan = rencanaBulan.trim().charAt(0).toUpperCase() + rencanaBulan.trim().slice(1).toLowerCase();

                const monthMap = {
                  'Januari': 0, 'Februari': 1, 'Maret': 2, 'April': 3, 'Mei': 4, 'Juni': 5,
                  'Juli': 6, 'Agustus': 7, 'September': 8, 'Oktober': 9, 'November': 10, 'Desember': 11
                };
                const monthIndex = monthMap[normalizedBulan];

                if (monthIndex !== undefined) {
                  const rencanaDate = new Date(rencanaTahun, monthIndex, 1);
                  rencanaDate.setHours(0, 0, 0, 0);

                  if (today >= rencanaDate) {
                    setCanAccessPersalinan(true);
                    setLockMessage("");
                  } else {
                    setCanAccessPersalinan(false);
                    const daysUntil = Math.ceil((rencanaDate - today) / (1000 * 60 * 60 * 24));
                    setLockMessage(`Form ini terkunci. Hanya dapat diakses mulai ${rencanaBulan} ${rencanaTahun} (${daysUntil} hari lagi).`);
                  }
                } else {
                  setCanAccessPersalinan(false);
                  setLockMessage(`Format bulan rencana persalinan tidak valid: "${rencanaBulan}". Gunakan format nama bulan dalam bahasa Indonesia (contoh: Januari, Februari, dst).`);
                }
              } else {
                setCanAccessPersalinan(false);
                setLockMessage("Rencana persalinan belum diisi. Silakan isi rencana persalinan terlebih dahulu.");
              }
            } else {
              setCanAccessPersalinan(false);
              setLockMessage("Rencana persalinan belum diisi. Silakan isi rencana persalinan terlebih dahulu.");
            }
          } catch (rencanaErr) {
            console.warn("Gagal mengecek rencana persalinan:", rencanaErr);
            setCanAccessPersalinan(false);
            setLockMessage("Gagal memverifikasi rencana persalinan.");
          }

          // Riwayat
          const dRiwayat = await getRiwayatMelahirkanByKehamilanId(aktif.id);
          if (dRiwayat && dRiwayat.length > 0) {
            const d = dRiwayat[0];
            setRiwayat(d);
            setFormRiwayat({
              g_gravida: d.g_gravida ?? "", p_partus: d.p_partus ?? "",
              a_abortus: d.a_abortus ?? "",
              tanggal_melahirkan: d.tanggal_melahirkan ? d.tanggal_melahirkan.split("T")[0] : "",
              fasyankes_tempat_melahirkan: d.fasyankes_tempat_melahirkan || "",
              cara_melahirkan_spontan: d.cara_melahirkan_spontan || false,
              tindakan_sc: d.tindakan_sc || false,
            });
            setModeRiwayat("detail");
          } else {
            // Auto prefill riwayat jika belum ada
            setFormRiwayat(prev => ({
              ...prev,
              g_gravida: defaultGravida,
              p_partus: defaultParitas,
              a_abortus: defaultAbortus,
            }));
          }
        }

        // Keterangan
        const dKet = await getKeteranganLahirByIbuId(id);
        if (dKet && dKet.length > 0) {
          const d = dKet[0];
          setKeterangan(d);
          setFormKeterangan({
            nomor_surat: d.nomor_surat || "", hari_lahir: d.hari_lahir || "",
            tanggal_lahir: d.tanggal_lahir ? d.tanggal_lahir.split("T")[0] : "",
            pukul_lahir: d.pukul_lahir || "", jenis_kelamin: d.jenis_kelamin || "",
            jenis_kelahiran: d.jenis_kelahiran || "", anak_ke: d.anak_ke ?? "",
            usia_gestasi_minggu: d.usia_gestasi_minggu ?? "",
            berat_lahir_gram: d.berat_lahir_gram ?? "", panjang_badan_cm: d.panjang_badan_cm ?? "",
            lingkar_kepala_cm: d.lingkar_kepala_cm ?? "", lokasi_persalinan: d.lokasi_persalinan || "",
            alamat_lokasi_persalinan: d.alamat_lokasi_persalinan || "",
            nama_bayi_diberi_nama: d.nama_bayi_diberi_nama || "",
            nama_ibu: ibuResponse?.kependudukan?.nama_lengkap || d.nama_ibu || "",
            nik_ibu: ibuResponse?.kependudukan?.nik || d.nik_ibu || "",
            nama_ayah: ibuResponse?.suami?.nama_lengkap || ibuResponse?.nama_suami || ibuResponse?.nama_ayah || d.nama_ayah || "",
            pekerjaan_orang_tua: ibuResponse?.kependudukan?.pekerjaan || d.pekerjaan_orang_tua || "",
            alamat_orang_tua: ibuResponse?.kependudukan?.dusun || ibuResponse?.kependudukan?.alamat || d.alamat_orang_tua || "",
            nama_penolong_kelahiran: d.nama_penolong_kelahiran || "",
          });
          setModeKeterangan("detail");
          setSelectedRingkasanId(d.ringkasan_pelayanan_persalinan_id || "");
        } else {
          // Auto prefill keterangan data orang tua dari ibuData
          setFormKeterangan(prev => ({
            ...prev,
            nama_ibu: ibuResponse?.kependudukan?.nama_lengkap || "",
            nik_ibu: ibuResponse?.kependudukan?.nik || "",
            nama_ayah: ibuResponse?.suami?.nama_lengkap || ibuResponse?.nama_suami || ibuResponse?.nama_ayah || "",
            alamat_orang_tua: ibuResponse?.kependudukan?.dusun || ibuResponse?.kependudukan?.alamat || "",
            pekerjaan_orang_tua: ibuResponse?.kependudukan?.pekerjaan || "",
          }));
        }
      } catch (err) {
        console.error(err);
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, [id]);

  // Sinkronisasi otomatis dari Ringkasan ke Riwayat
  const syncRiwayatFromRingkasan = async (ringkasanData) => {
    if (!kehamilan) return;
    try {
      const payloadRiwayat = {
        kehamilan_id: kehamilan.id,
        g_gravida: parseInt(ringkasanData.gravida) || 0,
        p_partus: parseInt(ringkasanData.paritas) || 0,
        a_abortus: parseInt(ringkasanData.abortus) || 0,
        tanggal_melahirkan: ringkasanData.tanggal_melahirkan || "",
        cara_melahirkan_spontan: ringkasanData.cara_melahirkan === "Spontan/Normal",
        tindakan_sc: ringkasanData.cara_melahirkan === "SC",
      };

      if (riwayat) {
        // Update riwayat yang ada
        const updated = await updateRiwayatMelahirkan(riwayat.id_riwayat_melahirkan || riwayat.id, payloadRiwayat);
        setRiwayat(updated);
      } else {
        // Buat riwayat baru
        const saved = await createRiwayatMelahirkan(payloadRiwayat);
        setRiwayat(saved);
      }

      // Update state form riwayat
      setFormRiwayat(prev => ({
        ...prev,
        ...payloadRiwayat,
        tanggal_melahirkan: payloadRiwayat.tanggal_melahirkan ? payloadRiwayat.tanggal_melahirkan.split("T")[0] : "",
      }));
      setModeRiwayat("detail");
    } catch (err) {
      console.error("Gagal sinkronisasi riwayat:", err);
    }
  };

  const buildPayload = (form, kehamilanId) => {
    const p = {
      kehamilan_id: kehamilanId,
      tanggal_melahirkan: form.tanggal_melahirkan,
      umur_kehamilan_minggu: parseInt(form.umur_kehamilan_minggu) || 0,
      penolong_proses_melahirkan: form.penolong_proses_melahirkan,
      cara_melahirkan: form.cara_melahirkan,
      keadaan_ibu: form.keadaan_ibu,
      keadaan_ibu_detail_sakit: form.keadaan_ibu_detail_sakit,
      keterangan_tambahan_ibu: form.keterangan_tambahan_ibu,
      kb_pasca_melahirkan: form.kb_pasca_melahirkan,
      gravida: parseInt(form.gravida) || 0,
      paritas: parseInt(form.paritas) || 0,
      abortus: parseInt(form.abortus) || 0,
      kondisi_bayi_segera_menangis: form.kondisi_bayi_segera_menangis,
      kondisi_bayi_menangis_beberapa_saat: form.kondisi_bayi_menangis_beberapa_saat,
      kondisi_bayi_tidak_menangis: form.kondisi_bayi_tidak_menangis,
      kondisi_bayi_seluruh_tubuh_kemerahan: form.kondisi_bayi_seluruh_tubuh_kemerahan,
      kondisi_bayi_anggota_gerak_kebiruan: form.kondisi_bayi_anggota_gerak_kebiruan,
      kondisi_bayi_seluruh_tubuh_biru: form.kondisi_bayi_seluruh_tubuh_biru,
      kondisi_bayi_kelainan_bawaan: form.kondisi_bayi_kelainan_bawaan,
      kondisi_bayi_kelainan_bawaan_detail: form.kondisi_bayi_kelainan_bawaan_detail,
      kondisi_bayi_meninggal: form.kondisi_bayi_meninggal,
      asuhan_imd_1_jam_pertama: form.asuhan_imd_1_jam_pertama,
      asuhan_suntikan_vitamin_k1: form.asuhan_suntikan_vitamin_k1,
      asuhan_salep_mata_antibiotika: form.asuhan_salep_mata_antibiotika,
      asuhan_imunisasi_hb0: form.asuhan_imunisasi_hb0,
      keterangan_tambahan_bayi: form.keterangan_tambahan_bayi,
      bayi_anak_ke: parseInt(form.bayi_anak_ke) || 0,
      // Disimpan dalam gram di database, input form dalam kg
      bayi_berat_lahir_gram: (parseFloat(form.bayi_berat_lahir_kg) || 0) * 1000,
      bayi_panjang_badan_cm: parseFloat(form.bayi_panjang_badan_cm) || 0,
      bayi_lingkar_kepala_cm: parseFloat(form.bayi_lingkar_kepala_cm) || 0,
      bayi_jenis_kelamin: form.anak_jenis_kelamin || "",
    };
    return p;
  };

  const handleSubmitNew = async (form) => {
    if (!kehamilan) return;

    // VALIDASI: Cek date-based locking sebelum mengizinkan submit
    if (!canAccessPersalinan) {
      Swal.fire({
        icon: "warning",
        title: "Form Terkunci",
        text: lockMessage || "Form ini terkunci berdasarkan tanggal rencana persalinan.",
        confirmButtonColor: "#185FA5"
      });
      return;
    }

    setSaving(true);
    try {
      const payload = buildPayload(form, kehamilan.id);
      await createRingkasanPersalinan(payload);

      // Update tanggal_lahir dan status kehamilan
      if (form.tanggal_melahirkan && (!kehamilan.tanggal_lahir || kehamilan.tanggal_lahir !== form.tanggal_melahirkan)) {
        try {
          await updateKehamilan(kehamilan.id, { tanggal_lahir: form.tanggal_melahirkan });
          setKehamilan((prev) => ({ ...prev, tanggal_lahir: form.tanggal_melahirkan }));
        } catch (err) {
          console.error("Gagal update tanggal_lahir:", err);
        }
      }

      // AUTO-UPDATE STATUS: Ubah status dari Hamil ke Nifas setelah data kelahiran disimpan
      if (kehamilan.status_kehamilan !== "NIFAS" && kehamilan.status_kehamilan !== "NON-AKTIF") {
        try {
          await updateStatusKehamilan(kehamilan.id, "NIFAS");
          setKehamilan((prev) => ({ ...prev, status_kehamilan: "NIFAS" }));
        } catch (err) {
          console.error("Gagal update status:", err);
        }
      }

      if (form.nama_anak && form.nama_anak.trim()) {
        await createAnakDenganPenduduk({
          kehamilan_id: kehamilan.id,
          ibu_id: kehamilan.ibu_id,
          nama: form.nama_anak,
          jenis_kelamin: form.anak_jenis_kelamin || "",
          tanggal_lahir: form.anak_tanggal_lahir || "",
           tempat_lahir: form.tempat_lahir || "", 
          anak_ke: parseInt(form.bayi_anak_ke) || 0,
          berat_lahir_kg: form.bayi_berat_lahir_kg ? parseFloat(form.bayi_berat_lahir_kg) : null,
          tinggi_lahir_cm: form.bayi_panjang_badan_cm ? parseFloat(form.bayi_panjang_badan_cm) : null,
          lingkar_kepala_cm: form.bayi_lingkar_kepala_cm ? parseFloat(form.bayi_lingkar_kepala_cm) : null,
          // Ambil langsung dari ibuData (state terbaru), bukan dari snapshot form, agar tidak pernah kosong
          nama_ibu: ibuData?.kependudukan?.nama_anggota_keluarga || ibuData?.nama_ibu || ibuData?.nama_anggota_keluarga || "",
          nama_ayah: ibuData?.suami?.nama_anggota_keluarga || ibuData?.nama_suami || ibuData?.nama_anggota_keluarga || "",
        });
      }

      // Sinkronisasi ke Riwayat Melahirkan
      await syncRiwayatFromRingkasan(form);

      setShowNewForm(false);
      await fetchKelahiran(kehamilan.id, id);
      await Swal.fire({ icon: "success", title: "Berhasil", text: "Kelahiran baru berhasil disimpan", timer: 1800, showConfirmButton: false });
    } catch (err) {
      const msg = err.response?.data?.message || err.message;
      Swal.fire({ icon: "error", title: "Gagal", text: msg });
    } finally {
      setSaving(false);
    }
  };

  const handleSubmitEdit = async (form) => {
    if (!editTarget || !kehamilan) return;

    // VALIDASI: Cek date-based locking sebelum mengizinkan submit
    if (!canAccessPersalinan) {
      Swal.fire({
        icon: "warning",
        title: "Form Terkunci",
        text: lockMessage || "Form ini terkunci berdasarkan tanggal rencana persalinan.",
        confirmButtonColor: "#185FA5"
      });
      return;
    }

    setSaving(true);
    try {
      const idR = editTarget.id_ringkasan || editTarget.id || editTarget.ID;
      const payload = buildPayload(form, kehamilan.id);
      await updateRingkasanPersalinan(idR, payload);

      // Update tanggal_lahir jika berubah
      if (form.tanggal_melahirkan && (!kehamilan.tanggal_lahir || kehamilan.tanggal_lahir !== form.tanggal_melahirkan)) {
        try {
          await updateKehamilan(kehamilan.id, { tanggal_lahir: form.tanggal_melahirkan });
          setKehamilan((prev) => ({ ...prev, tanggal_lahir: form.tanggal_melahirkan }));
        } catch (err) {
          console.error("Gagal update tanggal_lahir:", err);
        }
      }

      // ✅ Hanya buat anak baru jika belum ada anak yang terkait dengan ringkasan ini
      if (form.nama_anak && form.nama_anak.trim()) {
        const idR = editTarget.id_ringkasan || editTarget.id || editTarget.ID;
        const groupForThis = kelahiranList.find(
          (g) => (g.ringkasan?.id_ringkasan || g.ringkasan?.id || g.ringkasan?.ID) === idR
        );
        const sudahAdaAnak = groupForThis && groupForThis.anakList && groupForThis.anakList.length > 0;

        if (!sudahAdaAnak) {
          await createAnakDenganPenduduk({
            kehamilan_id: kehamilan.id,
            ibu_id: kehamilan.ibu_id,
            nama: form.nama_anak,
            jenis_kelamin: form.anak_jenis_kelamin || "",
            tanggal_lahir: form.anak_tanggal_lahir || "",
            tempat_lahir: form.tempat_lahir || "",
            anak_ke: parseInt(form.bayi_anak_ke) || 0,
            berat_lahir_kg: form.bayi_berat_lahir_kg ? parseFloat(form.bayi_berat_lahir_kg) : null,
            tinggi_lahir_cm: form.bayi_panjang_badan_cm ? parseFloat(form.bayi_panjang_badan_cm) : null,
            lingkar_kepala_cm: form.bayi_lingkar_kepala_cm ? parseFloat(form.bayi_lingkar_kepala_cm) : null,
            // Ambil langsung dari ibuData (state terbaru), bukan dari snapshot form, agar tidak pernah kosong
            nama_ibu: ibuData?.kependudukan?.nama_anggota_keluarga || ibuData?.nama_ibu || ibuData?.nama_anggota_keluarga || "",
            nama_ayah: ibuData?.suami?.nama_anggota_keluarga || ibuData?.nama_suami || ibuData?.nama_ayah || "",
          });
        }
      }

      // Sinkronisasi ke Riwayat Melahirkan
      await syncRiwayatFromRingkasan(form);

      setEditTarget(null);
      await fetchKelahiran(kehamilan.id, id);
      await Swal.fire({ icon: "success", title: "Berhasil", text: "Data berhasil diperbarui", timer: 1800, showConfirmButton: false });
    } catch (err) {
      const msg = err.response?.data?.message || err.message;
      Swal.fire({ icon: "error", title: "Gagal", text: msg });
    } finally {
      setSaving(false);
    }
  };

  const submitRiwayat = async (e) => {
    e.preventDefault();
    if (!kehamilan) return;

    // Validation
    if (!formRiwayat.g_gravida) {
      Swal.fire({ icon: "warning", title: "Perhatian", text: "Gravida (G) wajib diisi.", confirmButtonColor: "#4f46e5" });
      return;
    }
    if (!formRiwayat.p_partus) {
      Swal.fire({ icon: "warning", title: "Perhatian", text: "Partus (P) wajib diisi.", confirmButtonColor: "#4f46e5" });
      return;
    }
    if (!formRiwayat.a_abortus) {
      Swal.fire({ icon: "warning", title: "Perhatian", text: "Abortus (A) wajib diisi.", confirmButtonColor: "#4f46e5" });
      return;
    }
    if (!formRiwayat.tanggal_melahirkan) {
      Swal.fire({ icon: "warning", title: "Perhatian", text: "Tanggal melahirkan wajib diisi.", confirmButtonColor: "#4f46e5" });
      return;
    }
    if (!formRiwayat.fasyankes_tempat_melahirkan || !formRiwayat.fasyankes_tempat_melahirkan.trim()) {
      Swal.fire({ icon: "warning", title: "Perhatian", text: "Fasyankes tempat melahirkan wajib diisi.", confirmButtonColor: "#4f46e5" });
      return;
    }

    setSaving(true);
    try {
      const payload = { ...formRiwayat, kehamilan_id: kehamilan.id };
      payload.g_gravida = parseInt(payload.g_gravida) || 0;
      payload.p_partus = parseInt(payload.p_partus) || 0;
      payload.a_abortus = parseInt(payload.a_abortus) || 0;
      if (riwayat) {
        await updateRiwayatMelahirkan(riwayat.id_riwayat_melahirkan || riwayat.id, payload);
      } else {
        const saved = await createRiwayatMelahirkan(payload);
        setRiwayat(saved);
      }
      setModeRiwayat("detail");
    } catch (err) {
      Swal.fire({
        icon: "error",
        title: "Gagal",
        text: err.response?.data?.message || err.message,
        confirmButtonColor: "#185FA5",
      });
    } finally {
      setSaving(false);
    }
  };

  const submitKeterangan = async (e) => {
    e.preventDefault();

    // Validation
    if (!formKeterangan.nomor_surat || !formKeterangan.nomor_surat.trim()) {
      Swal.fire({ icon: "warning", title: "Perhatian", text: "Nomor surat wajib diisi.", confirmButtonColor: "#4f46e5" });
      return;
    }
    if (!validateNomorSuratFormat(formKeterangan.nomor_surat)) {
      Swal.fire({
        icon: "warning",
        title: "Format Nomor Surat Salah",
        text: "Format nomor surat harus: 09.[nomor_urut]/[nama_lembaga]/[bulan_romawi]/[tahun]\nContoh: 09.004/PUSKESMAS/V/2024",
        confirmButtonColor: "#4f46e5"
      });
      return;
    }
    if (!formKeterangan.hari_lahir || !formKeterangan.hari_lahir.trim()) {
      Swal.fire({ icon: "warning", title: "Perhatian", text: "Hari lahir wajib diisi.", confirmButtonColor: "#4f46e5" });
      return;
    }
    if (!formKeterangan.tanggal_lahir) {
      Swal.fire({ icon: "warning", title: "Perhatian", text: "Tanggal lahir wajib diisi.", confirmButtonColor: "#4f46e5" });
      return;
    }
    if (!formKeterangan.jenis_kelamin) {
      Swal.fire({ icon: "warning", title: "Perhatian", text: "Jenis kelamin wajib dipilih.", confirmButtonColor: "#4f46e5" });
      return;
    }
    if (!formKeterangan.nama_bayi_diberi_nama || !formKeterangan.nama_bayi_diberi_nama.trim()) {
      Swal.fire({ icon: "warning", title: "Perhatian", text: "Nama bayi wajib diisi.", confirmButtonColor: "#4f46e5" });
      return;
    }
    if (!formKeterangan.nama_ibu || !formKeterangan.nama_ibu.trim()) {
      Swal.fire({ icon: "warning", title: "Perhatian", text: "Nama ibu wajib diisi.", confirmButtonColor: "#4f46e5" });
      return;
    }
    if (!formKeterangan.nik_ibu || !formKeterangan.nik_ibu.trim()) {
      Swal.fire({ icon: "warning", title: "Perhatian", text: "NIK ibu wajib diisi.", confirmButtonColor: "#4f46e5" });
      return;
    }
    // Nama ayah diisi otomatis dari data ibu, tidak perlu validasi manual
    if (!formKeterangan.nama_penolong_kelahiran || !formKeterangan.nama_penolong_kelahiran.trim()) {
      Swal.fire({ icon: "warning", title: "Perhatian", text: "Nama penolong kelahiran wajib diisi.", confirmButtonColor: "#4f46e5" });
      return;
    }

    setSaving(true);
    try {
      const payload = { ...formKeterangan, id_ibu_relasi: parseInt(id) };
      payload.berat_lahir_gram = parseInt(payload.berat_lahir_gram) || 0;
      payload.panjang_badan_cm = parseInt(payload.panjang_badan_cm) || 0;
      payload.lingkar_kepala_cm = parseInt(payload.lingkar_kepala_cm) || 0;
      payload.usia_gestasi_minggu = parseInt(payload.usia_gestasi_minggu) || 0;
      payload.anak_ke = parseInt(payload.anak_ke) || 0;
      // kirim ringkasan_pelayanan_persalinan_id jika dipilih
      if (selectedRingkasanId) {
        payload.ringkasan_pelayanan_persalinan_id = parseInt(selectedRingkasanId);
      }
      if (keterangan) {
        await updateKeteranganLahir(keterangan.id_keterangan_lahir || keterangan.id, payload);
      } else {
        const saved = await createKeteranganLahir(payload);
        setKeterangan(saved);
      }
      setModeKeterangan("detail");
    } catch (err) {
      Swal.fire({
        icon: "error",
        title: "Gagal",
        text: err.response?.data?.message || err.message,
        confirmButtonColor: "#185FA5",
      });
    } finally {
      setSaving(false);
    }
  };

  const handlePrint = () => {
    const printContents = document.getElementById("surat-keterangan-lahir").innerHTML;
    const w = window.open("", "_blank");
    w.document.write(`<html><head><title>Surat Keterangan Lahir</title>
      <style>body{font-family:serif;font-size:13px;padding:40px;color:#111}table{width:100%;border-collapse:collapse}td{padding:3px 2px;vertical-align:top}.border-dotted{border-bottom:1px dotted #555;display:inline-block;min-width:60px}hr{border:1px solid #555;margin:16px 0}h1{text-align:center;letter-spacing:6px}</style>
      </head><body>${printContents}</body></html>`);
    w.document.close(); w.print();
  };

  // Fungsi untuk mengisi form keterangan dari ringkasan yang dipilih
  const handlePilihRingkasan = (ringkasanId) => {
    setSelectedRingkasanId(ringkasanId);
    if (!ringkasanId) {
      // reset sebagian field ke default
      setAutoFilledFields([]);
      setFormKeterangan(prev => ({
        ...prev,
        tanggal_lahir: "", pukul_lahir: "", anak_ke: "", usia_gestasi_minggu: "",
        berat_lahir_gram: "", panjang_badan_cm: "", lingkar_kepala_cm: "",
        jenis_kelamin: "", nama_penolong_kelahiran: "", nama_bayi_diberi_nama: ""
      }));
      return;
    }
    const chosen = kelahiranList.find(item => item.ringkasan.id == ringkasanId);
    if (chosen) {
      const r = chosen.ringkasan;
      // Gunakan data anak pertama yang terkait (jika ada) untuk nama bayi & jam lahir (jika ada properti jam)
      const anak = chosen.anakList?.[0];

      setAutoFilledFields([
        "tanggal_lahir", "anak_ke", "usia_gestasi_minggu",
        "berat_lahir_gram", "panjang_badan_cm", "lingkar_kepala_cm",
        "jenis_kelamin", "nama_penolong_kelahiran", "nama_bayi_diberi_nama"
      ]);

      setFormKeterangan(prev => ({
        ...prev,
        tanggal_lahir: r.tanggal_melahirkan || "",
        pukul_lahir: r.pukul_melahirkan ? r.pukul_melahirkan.slice(0, 5) : prev.pukul_lahir,
        anak_ke: r.bayi_anak_ke || "",
        usia_gestasi_minggu: r.umur_kehamilan_minggu || "",
        berat_lahir_gram: r.bayi_berat_lahir_gram || "",
        panjang_badan_cm: r.bayi_panjang_badan_cm || "",
        lingkar_kepala_cm: r.bayi_lingkar_kepala_cm || "",
        jenis_kelamin: anak?.jenis_kelamin || r.bayi_jenis_kelamin || "",
        nama_penolong_kelahiran: r.penolong_proses_melahirkan || "",
        nama_bayi_diberi_nama: anak?.nama || r.nama_anak || "",
      }));
    }
  };

  const handleDeleteRingkasan = async (ringkasanId) => {
    const result = await Swal.fire({
      title: 'Hapus Kelahiran?',
      text: 'Data kelahiran ini akan dihapus secara permanen! Ini juga akan menghapus data anak yang terkait dengan kelahiran ini.',
      icon: 'warning',
      showCancelButton: true,
      confirmButtonColor: '#dc2626',
      cancelButtonColor: '#6b7280',
      confirmButtonText: 'Ya, Hapus!',
      cancelButtonText: 'Batal'
    });

    if (!result.isConfirmed) return;

    setSaving(true);
    try {
      await deleteRingkasanPersalinan(ringkasanId);
      await Swal.fire({ icon: "success", title: "Terhapus", text: "Data kelahiran berhasil dihapus.", timer: 1500, showConfirmButton: false });
      await fetchKelahiran(kehamilan.id, id); // Re-fetch all data
    } catch (err) {
      console.error("Error deleting ringkasan:", err);
      Swal.fire({ icon: "error", title: "Gagal", text: 'Gagal menghapus data: ' + (err.response?.data?.message || err.message) });
    } finally {
      setSaving(false);
    }
  };

  const TabButton = ({ tabId, label }) => (
    <button onClick={() => setActiveTab(tabId)}
      className={`py-2.5 px-4 md:px-5 text-xs md:text-sm font-medium border-b-2 transition-colors whitespace-nowrap ${activeTab === tabId ? "border-indigo-600 text-indigo-600 bg-indigo-50" : "border-transparent text-gray-500 hover:text-gray-700"}`}>
      {label}
    </button>
  );

  if (loading) return <MainLayout><div className="p-6 text-gray-400">Memuat...</div></MainLayout>;

  return (
    <MainLayout>
      <div className="p-4 md:p-6 max-w-5xl w-full mx-auto">
        <div className="flex items-center gap-3 mb-5">
          <button
            onClick={() => navigate(-1)}
            className="inline-flex items-center gap-2 px-5 py-2.5 rounded-full border border-[#185FA5] text-[#185FA5] text-sm font-semibold hover:bg-[#185FA5]/5 transition"
          >
            <ArrowLeft size={16} />
            Kembali
          </button>
          <div>
            <h1 className="text-xl md:text-2xl font-bold text-gray-900">Proses & Riwayat Melahirkan</h1>
            <p className="text-sm text-gray-500">Pencatatan proses persalinan hingga bayi lahir.</p>
          </div>
        </div>

        {/* VALIDASI: Banner untuk date-based locking */}
        {!canAccessPersalinan && lockMessage && (
          <div className="mb-5 bg-amber-50 border border-amber-200 rounded-lg p-4 flex items-start gap-3">
            <Lock size={20} className="text-amber-600 mt-0.5 flex-shrink-0" />
            <div>
              <h3 className="font-semibold text-amber-800 text-sm">Form Terkunci</h3>
              <p className="text-amber-700 text-sm mt-1">{lockMessage}</p>
            </div>
          </div>
        )}

        {/* Mode baca alert untuk Dokter */}
        {isDokter && (
          <div className="bg-blue-50 border border-blue-200 p-3 rounded-lg text-blue-700 text-base flex items-center gap-2 mb-6">
            <Eye size={16} /> Anda dalam mode baca (Dokter). Data hanya dapat dilihat, tidak dapat diubah.
          </div>
        )}

        <div className="w-full border-b border-gray-200 mb-6 flex overflow-x-auto">
          <TabButton tabId="ringkasan" label="Ringkasan Melahirkan" />
          <TabButton tabId="riwayat" label="Riwayat Melahirkan" />
          <TabButton tabId="keterangan" label="Surat Keterangan Lahir" />
        </div>

        {activeTab === "ringkasan" && (
          <div className="space-y-4">
            {editTarget && (
              <div className="max-w-5xl mx-auto">
                <RingkasanForm
                  key={editTarget.id}
                  initial={{
                    ...editTarget,
                    // Field tanggal harus diformat YYYY-MM-DD agar terbaca oleh <input type="date">
                    tanggal_melahirkan: editTarget.tanggal_melahirkan ? String(editTarget.tanggal_melahirkan).split("T")[0] : "",
                    tempat_lahir: "",
                    umur_kehamilan_minggu: editTarget.umur_kehamilan_minggu ?? "",
                    penolong_proses_melahirkan: editTarget.penolong_proses_melahirkan ?? "",
                    cara_melahirkan: editTarget.cara_melahirkan ?? "",
                    keadaan_ibu: editTarget.keadaan_ibu ?? "",
                    keadaan_ibu_detail_sakit: editTarget.keadaan_ibu_detail_sakit ?? "",
                    keterangan_tambahan_ibu: editTarget.keterangan_tambahan_ibu ?? "",
                    kb_pasca_melahirkan: editTarget.kb_pasca_melahirkan ?? "",
                    gravida: editTarget.gravida ?? "",
                    paritas: editTarget.paritas ?? "",
                    abortus: editTarget.abortus ?? "",
                    bayi_anak_ke: editTarget.bayi_anak_ke ?? "",
                    bayi_berat_lahir_kg: editTarget.bayi_berat_lahir_gram ? (parseFloat(editTarget.bayi_berat_lahir_gram) / 1000) : "",
                    bayi_panjang_badan_cm: editTarget.bayi_panjang_badan_cm ?? "",
                    bayi_lingkar_kepala_cm: editTarget.bayi_lingkar_kepala_cm ?? "",
                    nama_anak: "", anak_tanggal_lahir: "", anak_jenis_kelamin: "",
                    anak_nama_ibu: ibuData?.kependudukan?.nama_anggota_keluarga || editTarget.anak_nama_ibu || "",
                    anak_nama_ayah: ibuData?.suami?.nama_anggota_keluarga || editTarget.anak_nama_ayah || "",
                  }}
                  title={`Edit Kelahiran`}
                  onSubmit={handleSubmitEdit}
                  onCancel={() => setEditTarget(null)}
                  saving={saving}
                />
              </div>
            )}

            {!editTarget && kelahiranList.length === 0 && !showNewForm && (
              <div className="bg-white rounded-2xl border border-dashed border-gray-200 p-10 text-center">
                <div className="flex flex-col items-center gap-3">
                  <div className="w-12 h-12 bg-indigo-50 rounded-full flex items-center justify-center">
                    <Plus size={24} className="text-indigo-400" />
                  </div>
                  <p className="font-semibold text-gray-700">Belum Ada Data Persalinan</p>
                  <p className="text-sm text-gray-400">Tambahkan ringkasan persalinan pertama.</p>
                  {canEditRingkasan && canAccessPersalinan && (
                    <button onClick={() => setShowNewForm(true)}
                      className="bg-indigo-600 text-white px-5 py-2 rounded-xl text-sm font-semibold hover:bg-indigo-700 flex items-center gap-2 mt-1">
                      <Plus size={16} /> Tambah Kelahiran
                    </button>
                  )}
                  {canEditRingkasan && !canAccessPersalinan && (
                    <button
                      disabled
                      className="bg-gray-300 text-gray-500 px-5 py-2 rounded-xl text-sm font-semibold cursor-not-allowed flex items-center gap-2 mt-1"
                      title={lockMessage}
                    >
                      <Lock size={16} /> Tambah Kelahiran (Terkunci)
                    </button>
                  )}
                  {!canEditRingkasan && (
                    <p className="text-xs text-gray-400 mt-2">Hanya Bidan yang dapat menambahkan data persalinan.</p>
                  )}
                </div>
              </div>
            )}

            {!editTarget && kelahiranList.map(({ ringkasan, anakList }, i) => (
              <KelahiranCard
                key={ringkasan.id || i}
                index={i}
                ringkasan={ringkasan}
                anakList={anakList}
                kehamilanId={kehamilan?.id}
                ibuId={id}
                onEdit={canEditRingkasan ? (r) => { setEditTarget(r); setShowNewForm(false); } : undefined}
                onAnakAdded={() => fetchKelahiran(kehamilan?.id, id)}
                onDelete={canEditRingkasan ? handleDeleteRingkasan : undefined}
                canEdit={canEditRingkasan}
              />
            ))}

            {!editTarget && showNewForm && (
              <div className="max-w-5xl mx-auto">
                <RingkasanForm
                  initial={emptyRingkasan(ibuData)}
                  title={`Tambah Kelahiran ke-${kelahiranList.length + 1}`}
                  onSubmit={handleSubmitNew}
                  onCancel={() => setShowNewForm(false)}
                  saving={saving}
                />
              </div>
            )}

            {!editTarget && !showNewForm && kelahiranList.length > 0 && canEditRingkasan && canAccessPersalinan && (
              <button onClick={() => setShowNewForm(true)}
                className="w-full py-3 border-2 border-dashed border-indigo-200 rounded-2xl text-indigo-500 font-semibold text-sm hover:border-indigo-400 hover:bg-indigo-50 transition flex items-center justify-center gap-2">
                <Plus size={18} /> Tambah Kelahiran Baru
              </button>
            )}
            {!editTarget && !showNewForm && kelahiranList.length > 0 && canEditRingkasan && !canAccessPersalinan && (
              <button
                disabled
                className="w-full py-3 border-2 border-dashed border-gray-300 rounded-2xl text-gray-400 font-semibold text-sm cursor-not-allowed flex items-center justify-center gap-2"
                title={lockMessage}
              >
                <Lock size={18} /> Tambah Kelahiran Baru (Terkunci)
              </button>
            )}
          </div>
        )}

        {activeTab === "riwayat" && (
          <>
            <div className="mb-6 bg-indigo-50 border border-indigo-100 rounded-xl p-4 flex gap-3">
              <Info size={20} className="text-indigo-600 shrink-0 mt-0.5" />
              <div>
                <p className="text-sm font-semibold text-indigo-900">Sinkronisasi Otomatis</p>
                <p className="text-xs text-indigo-700 mt-1">
                  Data Riwayat Melahirkan otomatis terisi dan diperbarui dari <strong>Ringkasan Melahirkan</strong>. Data bersifat read-only dan tidak dapat diubah secara manual.
                </p>
              </div>
            </div>

            {kelahiranList.length > 0 && (
              <div className="mb-6 space-y-3">
                <p className="text-xs font-bold text-gray-400 uppercase tracking-widest">Riwayat dari Ringkasan</p>
                {kelahiranList.map((k, i) => (
                  <div key={k.ringkasan.id || i} className="bg-white rounded-xl border border-gray-100 p-4 flex items-center justify-between shadow-sm">
                    <div>
                      <p className="font-semibold text-sm text-gray-800">Kelahiran ke-{i + 1} ({k.ringkasan.tanggal_melahirkan || "-"})</p>
                      <p className="text-xs text-gray-500 mt-0.5">Cara: {k.ringkasan.cara_melahirkan || "-"} &bull; Penolong: {k.ringkasan.penolong_proses_melahirkan || "-"}</p>
                    </div>
                    <span className="bg-green-100 text-green-800 text-[10px] px-2 py-1 rounded-md font-medium flex items-center gap-1">
                      <Link2 size={12} /> Tersinkron
                    </span>
                  </div>
                ))}
              </div>
            )}

            {modeRiwayat === "detail" && (
              <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-5">
                <div className="flex items-center gap-2 mb-4 text-green-600">
                  <CheckCircle size={18} />
                  <h2 className="text-base font-semibold text-gray-800">Riwayat Proses Melahirkan</h2>
                </div>
                <div className="grid grid-cols-2 md:grid-cols-3 gap-3 bg-gray-50 rounded-xl p-4">
                  <DetailItem label="Gravida (G)" value={formRiwayat.g_gravida} />
                  <DetailItem label="Partus (P)" value={formRiwayat.p_partus} />
                  <DetailItem label="Abortus (A)" value={formRiwayat.a_abortus} />
                  <DetailItem label="Tanggal Melahirkan" value={formRiwayat.tanggal_melahirkan} />
                  <DetailItem label="Faskes" value={formRiwayat.fasyankes_tempat_melahirkan} />
                  <DetailItem label="Cara Melahirkan" value={formRiwayat.cara_melahirkan_spontan ? "Spontan/Normal" : formRiwayat.tindakan_sc ? "Operasi Caesar" : "-"} />
                </div>
              </div>
            )}
            {modeRiwayat === "empty" && (
              <div className="bg-white rounded-2xl border border-dashed border-gray-200 p-10 text-center">
                <p className="font-semibold text-gray-700 mb-1">Belum Ada Riwayat Melahirkan</p>
                <p className="text-sm text-gray-400">Data Riwayat Melahirkan akan otomatis terisi setelah Anda menambahkan data di <strong>Ringkasan Melahirkan</strong>.</p>
              </div>
            )}
          </>
        )}

        {activeTab === "keterangan" && (
          <>
            {modeKeterangan === "detail" && (
              <div className="space-y-4">
                <div className="flex justify-between items-center">
                  {canEditKeterangan && (
                    <button onClick={() => setModeKeterangan("form")} className="text-sm text-indigo-600 border border-indigo-300 px-3 py-1.5 rounded-lg hover:bg-indigo-50 flex items-center gap-1"><Edit2 size={13} /> Edit Data</button>
                  )}
                  <button onClick={handlePrint} className="text-sm bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 flex items-center gap-2"><Printer size={16} /> Cetak</button>
                </div>
                <SuratKeteranganLahir data={formKeterangan} />
              </div>
            )}
            {modeKeterangan === "empty" && (
              <div className="bg-white rounded-2xl border border-dashed border-gray-200 p-10 text-center">
                {kelahiranList.length === 0 ? (
                  <>
                    <p className="font-semibold text-gray-700 mb-1">Belum Ada Data Persalinan</p>
                    <p className="text-sm text-gray-400 mb-4">Silakan isi <strong>Ringkasan Melahirkan</strong> terlebih dahulu untuk dapat membuat Surat Keterangan Lahir yang terhubung otomatis.</p>
                    <button onClick={() => setActiveTab("ringkasan")} className="bg-indigo-600 text-white px-5 py-2 rounded-xl text-sm font-semibold hover:bg-indigo-700 flex items-center gap-2 mx-auto">Ke Ringkasan Melahirkan</button>
                  </>
                ) : (
                  <>
                    <p className="font-semibold text-gray-700 mb-1">Belum Ada Surat Keterangan Lahir</p>
                    <p className="text-sm text-gray-400 mb-4">Silakan pilih kelahiran untuk membuat Surat Keterangan Lahir.</p>
                    {canEditKeterangan && (
                      <button onClick={() => setModeKeterangan("form")} className="bg-indigo-600 text-white px-5 py-2 rounded-xl text-sm font-semibold hover:bg-indigo-700 flex items-center gap-2 mx-auto"><Plus size={16} /> Tambah Data</button>
                    )}
                    {!canEditKeterangan && (
                      <p className="text-xs text-gray-400 mt-2">Hanya Bidan yang dapat mengelola Surat Keterangan Lahir.</p>
                    )}
                  </>
                )}
              </div>
            )}
            {modeKeterangan === "form" && (
              <form onSubmit={submitKeterangan} className="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
                <div className="flex items-center justify-between mb-4">
                  <h2 className="text-lg font-bold text-indigo-700">Surat Keterangan Lahir</h2>
                  {keterangan && <button type="button" onClick={() => setModeKeterangan("detail")} className="p-2 rounded-full hover:bg-gray-100"><X size={18} className="text-gray-500" /></button>}
                </div>

                <div className="mb-5 bg-blue-50 border border-blue-100 p-4 rounded-xl flex gap-3">
                  <Info size={20} className="text-blue-600 shrink-0 mt-0.5" />
                  <div>
                    <p className="text-sm font-semibold text-blue-900">Pengisian Otomatis</p>
                    <p className="text-xs text-blue-700 mt-1">Data orang tua telah disinkronkan. Pilih data kelahiran di bawah ini untuk mengisi detail bayi otomatis dari <strong>Ringkasan Melahirkan</strong>.</p>
                  </div>
                </div>

                {/* Pilih Ringkasan untuk prefill */}
                <div className="mb-4">
                  <label className="block text-xs font-medium mb-1">Pilih Data Kelahiran</label>
                  <select
                    value={selectedRingkasanId}
                    onChange={(e) => handlePilihRingkasan(e.target.value)}
                    className="w-full border-2 border-indigo-300 rounded-lg px-2 py-2 text-sm focus:ring-2 focus:ring-indigo-100"
                  >
                    <option value="">-- Pilih Kelahiran --</option>
                    {kelahiranList.map((item, idx) => (
                      <option key={item.ringkasan.id} value={item.ringkasan.id}>
                        Kelahiran {idx + 1} ({item.ringkasan.tanggal_melahirkan || "tanpa tgl"})
                      </option>
                    ))}
                  </select>
                </div>
                <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
                  {[
                    { label: "Nomor Surat", name: "nomor_surat", type: "text", placeholder: "09.001/PUSKESMAS/V/2024", readOnly: true },
                    { label: "Nama Bayi", name: "nama_bayi_diberi_nama", type: "text" },
                    { label: "Tanggal Lahir", name: "tanggal_lahir", type: "date" },
                    { label: "Hari Lahir", name: "hari_lahir", type: "text", placeholder: "Senin" },
                    { label: "Pukul Lahir", name: "pukul_lahir", type: "time-select" },
                    { label: "Anak Ke", name: "anak_ke", type: "number" },
                    { label: "Usia Gestasi (Mgg)", name: "usia_gestasi_minggu", type: "number" },
                    { label: "Berat Lahir (gram)", name: "berat_lahir_gram", type: "number" },
                    { label: "Panjang Badan (cm)", name: "panjang_badan_cm", type: "number" },
                    { label: "Lingkar Kepala (cm)", name: "lingkar_kepala_cm", type: "number" },
                    { label: "Nama Ibu", name: "nama_ibu", type: "text" },
                    { label: "NIK Ibu", name: "nik_ibu", type: "text" },
                    { label: "Nama Ayah", name: "nama_ayah", type: "text" },
                    { label: "Pekerjaan", name: "pekerjaan_orang_tua", type: "text" },
                    { label: "Alamat", name: "alamat_orang_tua", type: "text" },
                    { label: "Penolong Kelahiran", name: "nama_penolong_kelahiran", type: "text" },
                    { label: "Lokasi Persalinan", name: "lokasi_persalinan", type: "text" },
                  ].map(({ label, name, type, placeholder, readOnly }) => {
                    const isAuto = autoFilledFields.includes(name);
                    const isLocked = ["nama_ibu", "nik_ibu", "nama_ayah", "pekerjaan_orang_tua", "alamat_orang_tua"].includes(name);
                    const isReadOnly = readOnly === true;
                    return (
                      <div key={name}>
                        <label className="block text-xs font-medium mb-1">{label}</label>
                        {type === "time-select" ? (
                          <select name={name} value={formKeterangan[name] || ""}
                            onChange={(e) => setFormKeterangan((p) => ({ ...p, [name]: e.target.value }))}
                            disabled={isLocked || isReadOnly}
                            className={`w-full rounded-lg px-2 py-1.5 text-sm ${isLocked || isReadOnly ? "bg-gray-100 border-gray-200 text-gray-500 cursor-not-allowed" : isAuto ? "border-green-300 bg-green-50/30 focus:ring-green-100" : "border focus:ring-indigo-100"} focus:ring-2 outline-none transition-all`}>
                            <option value="">-- Pilih --</option>
                            {Array.from({ length: 24 }, (_, i) => {
                              const hour = i.toString().padStart(2, '0');
                              return (
                                <option key={hour} value={`${hour}:00`}>{hour}:00</option>
                              );
                            })}
                          </select>
                        ) : (
                          <input type={type} name={name} value={formKeterangan[name] || ""} placeholder={placeholder}
                            onChange={(e) => setFormKeterangan((p) => ({ ...p, [name]: e.target.value }))}
                            disabled={isLocked || isReadOnly}
                            readOnly={isReadOnly}
                            className={`w-full rounded-lg px-2 py-1.5 text-sm ${isLocked || isReadOnly ? "bg-gray-100 border-gray-200 text-gray-500 cursor-not-allowed" : isAuto ? "border-green-300 bg-green-50/30 focus:ring-green-100" : "border focus:ring-indigo-100"} focus:ring-2 outline-none transition-all`} />
                        )}
                      </div>
                    )
                  })}
                  <div>
                    <label className="block text-xs font-medium mb-1">Jenis Kelamin</label>
                    <select name="jenis_kelamin" value={formKeterangan.jenis_kelamin} onChange={(e) => setFormKeterangan((p) => ({ ...p, jenis_kelamin: e.target.value }))} className={`w-full rounded-lg px-2 py-1.5 text-sm ${autoFilledFields.includes("jenis_kelamin") ? "border-green-300 bg-green-50/30 focus:ring-green-100" : "border focus:ring-indigo-100"} focus:ring-2 outline-none transition-all`}>
                      <option value="">-- Pilih --</option><option>Laki-laki</option><option>Perempuan</option>
                    </select>
                  </div>
                  <div><label className="block text-xs font-medium mb-1">Jenis Kelahiran</label>
                    <select name="jenis_kelahiran" value={formKeterangan.jenis_kelahiran} onChange={(e) => setFormKeterangan((p) => ({ ...p, jenis_kelahiran: e.target.value }))} className="w-full border rounded-lg px-2 py-1.5 text-sm focus:ring-2 focus:ring-indigo-100 outline-none transition-all">
                      <option value="">-- Pilih --</option><option>Tunggal</option><option>Kembar 2</option><option>Kembar 3</option><option>Lainnya</option>
                    </select></div>
                </div>
                <div className="flex gap-2 pt-4">
                  <button type="submit" disabled={saving} className="bg-indigo-600 text-white px-6 py-2.5 rounded-xl font-semibold text-sm flex items-center gap-2 hover:bg-indigo-700">
                    <Save size={16} /> {saving ? "Menyimpan..." : "Simpan"}
                  </button>
                </div>
              </form>
            )}
          </>
        )}
      </div>
    </MainLayout>
  );
}
