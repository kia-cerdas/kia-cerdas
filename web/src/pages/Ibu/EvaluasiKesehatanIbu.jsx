// src/pages/Ibu/EvaluasiKesehatanIbu.jsx
import { useEffect, useState, useMemo } from "react";
import { useParams, useNavigate, useSearchParams } from "react-router-dom";
import Swal from "sweetalert2";
import MainLayout from "../../components/Layout/MainLayout";
import { getKehamilanByIbuId } from "../../services/kehamilan";
import { getIbuById } from "../../services/ibu";
import {
  getEvaluasiByKehamilanId,
  createEvaluasi,
  updateEvaluasi,
  getRiwayatKehamilanByEvaluasiId,
  deleteEvaluasi,
  deleteRiwayatKehamilan,
} from "../../services/evaluasiKesehatan";
import {
  Plus,
  Edit,
  Save,
  ArrowLeft,
  Eye,
  CheckCircle,
  EyeOff,
  XCircle,
  Info,
  Trash2,
  Calendar,
  User,
  Baby,
  FileText,
  ClipboardList,
  Activity,
  ShieldAlert,
  Users,
  Stethoscope,
  HeartPulse,
  Scale,
  Syringe,
} from "lucide-react";
import { getCurrentUser, isDokterUser, isBidanUser } from "../../services/auth";

// ─── Palet warna Generasi Sehat ───────────────────────────────────────────────
// Primary  : #185FA5
// Success  : #3B6D11
// Warning  : #BA7517
// Danger   : #A32D2D
// Secondary: #0F6E56
// Background: #F7FAFB

// ─── Helper: checklist Ya/Tidak ──────────────────────────────────────────────
const RenderCheck = ({ value }) =>
  value ? (
    <span className="inline-flex items-center gap-1 font-semibold text-sm" style={{ color: "#3B6D11" }}>
      <CheckCircle size={14} /> Ya
    </span>
  ) : (
    <span className="inline-flex items-center gap-1 text-gray-400 text-sm">
      <XCircle size={14} /> Tidak
    </span>
  );

// ─── Helper: hitung IMT ──────────────────────────────────────────────────────
const calculateIMT = (tbCm, bbKg) => {
  const tb = parseFloat(tbCm);
  const bb = parseFloat(bbKg);
  if (isNaN(tb) || isNaN(bb) || tb <= 0 || bb <= 0)
    return { imt: null, kategori: "" };
  const heightM = tb / 100;
  const imt = bb / (heightM * heightM);
  let kategori = "";
  if (imt < 18.5) kategori = "Kurus";
  else if (imt < 25) kategori = "Normal";
  else if (imt < 30) kategori = "Gemuk";
  else kategori = "Obesitas";
  return { imt: imt.toFixed(1), kategori };
};

// ─── Helper: format tanggal ──────────────────────────────────────────────────
const formatDate = (val) => {
  if (!val) return "-";
  try {
    return new Date(val).toLocaleDateString("id-ID", {
      day: "2-digit",
      month: "long",
      year: "numeric",
    });
  } catch {
    return val;
  }
};

// ─── Badge Status IMT ────────────────────────────────────────────────────────
const IMTBadge = ({ kategori }) => {
  const styles = {
    Normal:   { bg: "#EDF7E6", color: "#3B6D11", border: "#3B6D11" },
    Kurus:    { bg: "#FEF3CD", color: "#BA7517", border: "#BA7517" },
    Gemuk:    { bg: "#FBE9E9", color: "#A32D2D", border: "#A32D2D" },
    Obesitas: { bg: "#FBE9E9", color: "#A32D2D", border: "#A32D2D" },
  };
  const s = styles[kategori] || { bg: "#F3F4F6", color: "#6B7280", border: "#D1D5DB" };
  return (
    <span
      className="px-2 py-0.5 rounded text-xs font-bold"
      style={{ backgroundColor: s.bg, color: s.color, border: `1px solid ${s.border}` }}
    >
      {kategori || "-"}
    </span>
  );
};

// ─── SectionCard ─────────────────────────────────────────────────────────────
const SectionCard = ({ icon: Icon, title, subtitle, accentColor = "#185FA5", children }) => (
  <div className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
    <div className="flex items-start gap-3 px-6 py-4 border-b border-gray-100" style={{ backgroundColor: "#F7FAFB" }}>
      {Icon && (
        <div className="p-2 rounded-lg mt-0.5" style={{ backgroundColor: accentColor + "15" }}>
          <Icon size={16} style={{ color: accentColor }} />
        </div>
      )}
      <div>
        <h3 className="font-bold text-base text-gray-900">{title}</h3>
        {subtitle && <p className="text-xs text-gray-500 mt-0.5">{subtitle}</p>}
      </div>
    </div>
    <div className="px-6 py-5">{children}</div>
  </div>
);

// ─── DataKehamilanCard ────────────────────────────────────────────────────────
const DataKehamilanCard = ({ kehamilan, ibu }) => {
  if (!kehamilan) return null;
  const gravida = kehamilan.gravida ?? ibu?.gravida ?? "-";
  const paritas = kehamilan.paritas ?? ibu?.paritas ?? "-";
  const abortus = kehamilan.abortus ?? ibu?.abortus ?? "-";

  const items = [
    { label: "HPHT", value: formatDate(kehamilan.hpht) },
    { label: "Taksiran Persalinan", value: formatDate(kehamilan.taksiran_persalinan) },
    {
      label: "Usia Kehamilan",
      value: kehamilan.uk_kehamilan_saat_ini ? `${kehamilan.uk_kehamilan_saat_ini} minggu` : "-",
    },
    {
      label: "Jarak Kehamilan",
      value: kehamilan.jarak_kehamilan_sebelumnya ? `${kehamilan.jarak_kehamilan_sebelumnya} bulan` : "-",
    },
    { label: "Gravida (G)", value: gravida },
    { label: "Paritas (P)", value: paritas },
    { label: "Abortus (A)", value: abortus },
    { label: "IMT Awal Kehamilan", value: kehamilan.imt_awal ? `${kehamilan.imt_awal} kg/m²` : "-" },
  ];

  return (
    <div className="rounded-xl p-4 mb-2" style={{ backgroundColor: "#EBF3FC", border: "1px solid #C3D9F0" }}>
      <div className="flex items-center gap-2 mb-3">
        <Baby size={16} style={{ color: "#185FA5" }} />
        <span className="font-bold text-sm" style={{ color: "#185FA5" }}>
          Data Kehamilan — Tersinkronisasi Otomatis
        </span>
      </div>
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
        {items.map(({ label, value }) => (
          <div key={label}>
            <span className="block text-xs font-semibold text-gray-400 uppercase tracking-wider mb-0.5">
              {label}
            </span>
            <span className="text-sm font-semibold text-gray-800">{value}</span>
          </div>
        ))}
      </div>
      <p className="text-xs mt-3 italic" style={{ color: "#185FA5" }}>
        * Data ini tersinkronisasi otomatis dari data kehamilan ibu dan tidak perlu diisi ulang.
      </p>
    </div>
  );
};

// ─── InfoRow: baris label-value dua kolom ────────────────────────────────────
const InfoRow = ({ label, value, badge }) => (
  <div>
    <span className="block text-xs font-semibold text-gray-400 uppercase tracking-wider mb-1">{label}</span>
    {badge ? badge : <span className="text-sm font-semibold text-gray-800">{value ?? "-"}</span>}
  </div>
);

// ─── CheckGroup: grup checkbox read-only ─────────────────────────────────────
const CheckGroup = ({ items, formPrefix, form }) => (
  <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-2">
    {items.map(([key, label]) => (
      <div key={key} className="flex items-center gap-1.5">
        <span className="text-sm text-gray-700">{label}:</span>
        <RenderCheck value={form[`${formPrefix}${key}`]} />
      </div>
    ))}
  </div>
);

// ─── VIEW MODE ───────────────────────────────────────────────────────────────
const EvaluationView = ({
  evaluasi,
  form,
  riwayatList,
  kehamilan,
  ibu,
  canEdit,
  setIsEditing,
  handleDeleteEvaluasi,
  handleDeleteRiwayat,
  saving,
}) => {
  if (!evaluasi) {
    return (
      <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-10 text-center">
        <div className="flex flex-col items-center gap-4">
          <div className="p-5 rounded-full" style={{ backgroundColor: "#EBF3FC" }}>
            <ClipboardList size={40} style={{ color: "#185FA5" }} />
          </div>
          <h3 className="text-lg font-bold text-gray-800">Tidak Ada Data Evaluasi Kesehatan</h3>
          <p className="text-sm text-gray-500 max-w-sm">
            Belum ada data evaluasi kesehatan untuk kehamilan ini. Tambahkan data untuk memulai pemantauan kesehatan ibu hamil.
          </p>
          {canEdit && (
            <button
              onClick={() => setIsEditing(true)}
              className="text-white px-6 py-2.5 rounded-full font-semibold flex items-center gap-2 text-sm transition hover:opacity-90"
              style={{ backgroundColor: "#185FA5" }}
            >
 Tambah Evaluasi Kesehatan
            </button>
          )}
          {!canEdit && (
            <p className="text-xs text-gray-400 mt-1">Hanya Bidan yang dapat menambahkan data Evaluasi Kesehatan.</p>
          )}
        </div>
      </div>
    );
  }

  const riwayatKesehatan = [
    ["alergi", "Alergi"], ["asma", "Asma"], ["autoimun", "Autoimun"],
    ["diabetes", "Diabetes"], ["hepatitis_b", "Hepatitis B"], ["hipertensi", "Hipertensi"],
    ["jantung", "Jantung"], ["jiwa", "Gangg. Jiwa"], ["sifilis", "Sifilis"], ["tb", "TBC"],
  ];

  const perilakuBerisiko = [
    ["aktivitas_fisik_kurang", "Kurang Aktivitas"], ["alkohol", "Alkohol"],
    ["kosmetik_berbahaya", "Kosmetik Berbahaya"], ["merokok", "Merokok"],
    ["obat_teratogenik", "Obat Teratogenik"], ["pola_makan_berisiko", "Pola Makan Berisiko"],
  ];

  return (
    <div className="space-y-4">
      {/* Data Kehamilan */}
      <SectionCard icon={Baby} title="Data Kehamilan" subtitle="Data tersinkronisasi otomatis dari riwayat kehamilan ibu" accentColor="#185FA5">
        <DataKehamilanCard kehamilan={kehamilan} ibu={ibu} />
      </SectionCard>

      {/* Kondisi Kesehatan Ibu */}
      <SectionCard icon={Scale} title="Kondisi Kesehatan Ibu" subtitle="Data antropometri dan status gizi ibu saat pemeriksaan" accentColor="#0F6E56">
        <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-5 gap-5">
          <InfoRow label="Tinggi Badan" value={form.tb_cm ? `${form.tb_cm} cm` : "-"} />
          <InfoRow label="Berat Badan" value={form.bb_kg ? `${form.bb_kg} kg` : "-"} />
          <InfoRow
            label="IMT"
            value={form.tb_cm && form.bb_kg ? `${calculateIMT(form.tb_cm, form.bb_kg).imt} kg/m²` : "-"}
          />
          <InfoRow
            label="Status Gizi"
            badge={<IMTBadge kategori={form.imt_kategori} />}
          />
          <InfoRow label="LiLA" value={form.lila_cm ? `${form.lila_cm} cm` : "-"} />
        </div>
      </SectionCard>

      {/* Status Imunisasi TT */}
      <SectionCard icon={Syringe} title="Status Imunisasi TT" subtitle="Dosis Tetanus Toxoid yang sudah diterima ibu" accentColor="#3B6D11">
        <div className="grid grid-cols-2 sm:grid-cols-5 gap-3 mb-4">
          {[1, 2, 3, 4, 5].map((n) => (
            <div
              key={n}
              className="flex items-center justify-between px-3 py-2 rounded-lg border text-sm"
              style={{
                borderColor: form[`status_tt_${n}`] ? "#3B6D11" : "#E5E7EB",
                backgroundColor: form[`status_tt_${n}`] ? "#EDF7E6" : "#F9FAFB",
              }}
            >
              <span className="font-semibold text-gray-700">TT {n}</span>
              <RenderCheck value={form[`status_tt_${n}`]} />
            </div>
          ))}
        </div>
        <div className="pt-3 border-t border-gray-100">
          <span className="text-xs font-semibold text-gray-400 uppercase tracking-wider block mb-1">
            Imunisasi Lainnya
          </span>
          <p className="text-sm text-gray-800">{form.imunisasi_lainnya_covid19 || "-"}</p>
        </div>
      </SectionCard>

      {/* Inspeksi Medis */}
      <SectionCard icon={Stethoscope} title="Pemeriksaan Khusus (Inspeksi)" subtitle="Hasil pemeriksaan visual area ginekologis" accentColor="#185FA5">
        <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
          {["porsio", "uretra", "vagina", "vulva", "fluksus", "fluor"].map((item) => (
            <div key={item}>
              <span className="text-xs font-semibold text-gray-400 uppercase tracking-wider block mb-1 capitalize">
                {item}
              </span>
              <span
                className="inline-block px-3 py-1 rounded-full text-xs font-bold"
                style={
                  form[`inspeksi_${item}`] === "Normal"
                    ? { backgroundColor: "#EDF7E6", color: "#3B6D11" }
                    : form[`inspeksi_${item}`] === "Abnormal"
                    ? { backgroundColor: "#FBE9E9", color: "#A32D2D" }
                    : { backgroundColor: "#F3F4F6", color: "#9CA3AF" }
                }
              >
                {form[`inspeksi_${item}`] || "-"}
              </span>
            </div>
          ))}
        </div>
      </SectionCard>

      {/* Riwayat Kesehatan, Perilaku, Keluarga */}
      <SectionCard icon={HeartPulse} title="Riwayat Kesehatan & Perilaku" subtitle="Riwayat penyakit ibu, perilaku berisiko, dan riwayat penyakit keluarga" accentColor="#A32D2D">
        <div className="space-y-5">
          <div>
            <h4 className="text-xs font-bold text-gray-500 uppercase tracking-wider mb-2">Riwayat Kesehatan Ibu</h4>
            <CheckGroup items={riwayatKesehatan} formPrefix="riwayat_" form={form} />
            {form.riwayat_kesehatan_lainnya && (
              <p className="text-sm text-gray-600 mt-2">Lainnya: {form.riwayat_kesehatan_lainnya}</p>
            )}
          </div>
          <div className="border-t border-gray-100 pt-4">
            <h4 className="text-xs font-bold text-gray-500 uppercase tracking-wider mb-2">Perilaku Berisiko (1 bulan sebelum hamil)</h4>
            <CheckGroup items={perilakuBerisiko} formPrefix="perilaku_" form={form} />
            {form.perilaku_lainnya && (
              <p className="text-sm text-gray-600 mt-2">Lainnya: {form.perilaku_lainnya}</p>
            )}
          </div>
          <div className="border-t border-gray-100 pt-4">
            <h4 className="text-xs font-bold text-gray-500 uppercase tracking-wider mb-2">Riwayat Kesehatan Keluarga</h4>
            <CheckGroup items={riwayatKesehatan} formPrefix="keluarga_" form={form} />
            {form.keluarga_lainnya && (
              <p className="text-sm text-gray-600 mt-2">Lainnya: {form.keluarga_lainnya}</p>
            )}
          </div>
        </div>
      </SectionCard>

      {/* Riwayat Kehamilan Lalu */}
      <SectionCard icon={FileText} title="Riwayat Kehamilan Lalu" subtitle="Data historis kehamilan sebelumnya dari sistem" accentColor="#0F6E56">
        {riwayatList.length > 0 ? (
          <div className="overflow-x-auto rounded-lg border border-gray-100">
            <table className="min-w-full divide-y divide-gray-100 text-sm">
              <thead>
                <tr style={{ backgroundColor: "#F7FAFB" }}>
                  {["No", "Tahun", "Berat Lahir (gr)", "Proses Melahirkan", "Penolong", "Masalah"].map((h) => (
                    <th key={h} className="px-4 py-3 text-left text-xs font-bold text-gray-500 uppercase whitespace-nowrap">
                      {h}
                    </th>
                  ))}
                  {canEdit && <th className="px-4 py-3 text-center text-xs font-bold text-gray-500 uppercase">Aksi</th>}
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-50 bg-white">
                {riwayatList.map((r, idx) => (
                  <tr key={r.id_riwayat || idx} className="hover:bg-gray-50 transition">
                    <td className="px-4 py-3 text-gray-500">{r.no_urut}</td>
                    <td className="px-4 py-3 font-semibold text-gray-800">{r.tahun}</td>
                    <td className="px-4 py-3 text-gray-700">{r.bb_gram || "-"}</td>
                    <td className="px-4 py-3 text-gray-700">{r.proses_melahirkan}</td>
                    <td className="px-4 py-3 text-gray-700">{r.penolong_proses_melahirkan || "-"}</td>
                    <td className="px-4 py-3 text-gray-700">{r.masalah || "-"}</td>
                    {canEdit && (
                      <td className="px-4 py-3 text-center">
                        <button
                          onClick={() => handleDeleteRiwayat(r.id_riwayat)}
                          className="p-1.5 rounded-lg transition hover:opacity-90"
                          style={{ backgroundColor: "#FBE9E9", color: "#A32D2D" }}
                          title="Hapus baris ini"
                        >
                          <Trash2 size={14} />
                        </button>
                      </td>
                    )}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        ) : (
          <div className="text-center py-6 text-gray-400 text-sm">
            <FileText size={28} className="mx-auto mb-2 opacity-40" />
            Tidak Ada Data — Belum ada riwayat kehamilan lalu tercatat.
          </div>
        )}
      </SectionCard>

      {/* Tombol Aksi */}
      {canEdit && evaluasi && (
        <div className="flex justify-end gap-3 pt-2">
          <button
            onClick={() => setIsEditing(true)}
            className="text-white rounded-full px-7 py-2.5 text-sm font-semibold flex items-center gap-2 transition hover:opacity-90 shadow-sm"
            style={{ backgroundColor: "#BA7517" }}
          >
            <Edit size={15} /> Ubah Evaluasi
          </button>
          <button
            onClick={handleDeleteEvaluasi}
            disabled={saving}
            className="text-white rounded-full px-7 py-2.5 text-sm font-semibold flex items-center gap-2 transition hover:opacity-90 shadow-sm disabled:opacity-50"
            style={{ backgroundColor: "#A32D2D" }}
          >
            <Trash2 size={15} /> Hapus Data
          </button>
        </div>
      )}
    </div>
  );
};

// ─── Komponen input label ─────────────────────────────────────────────────────
const FieldLabel = ({ children, required }) => (
  <label className="block text-xs font-bold text-gray-500 uppercase tracking-wider mb-1.5">
    {children}
    {required && <span className="ml-1" style={{ color: "#A32D2D" }}>*</span>}
  </label>
);

const inputBase =
  "w-full border rounded-xl px-4 h-12 text-sm font-sans focus:outline-none focus:ring-2 transition bg-white";

const inputNormal = `${inputBase} border-gray-200 focus:border-[#185FA5] focus:ring-[#185FA5]/20`;
const inputError = `${inputBase} border-[#A32D2D] bg-[#FBE9E9]/30 focus:ring-[#A32D2D]/20`;

const FieldError = ({ msg }) =>
  msg ? <p className="text-xs mt-1 font-medium" style={{ color: "#A32D2D" }}>{msg}</p> : null;

// ─── FORM MODE ────────────────────────────────────────────────────────────────
const EvaluationForm = ({
  form,
  handleChange,
  handleSubmitEvaluasi,
  errors,
  saving,
  setIsEditing,
  kehamilan,
  ibu,
}) => {
  const { imt: imtNumeric, kategori: computedKategori } = useMemo(
    () => calculateIMT(form.tb_cm, form.bb_kg),
    [form.tb_cm, form.bb_kg]
  );

  useEffect(() => {
    if (computedKategori && computedKategori !== form.imt_kategori) {
      handleChange({ target: { name: "imt_kategori", value: computedKategori } });
    } else if (!computedKategori && form.imt_kategori) {
      handleChange({ target: { name: "imt_kategori", value: "" } });
    }
  }, [computedKategori, form.imt_kategori, handleChange]);

  const imtColor = {
    Normal:   { bg: "#EDF7E6", color: "#3B6D11", border: "#3B6D11" },
    Kurus:    { bg: "#FEF3CD", color: "#BA7517", border: "#BA7517" },
    Gemuk:    { bg: "#FBE9E9", color: "#A32D2D", border: "#A32D2D" },
    Obesitas: { bg: "#FBE9E9", color: "#A32D2D", border: "#A32D2D" },
  }[form.imt_kategori] || { bg: "#F3F4F6", color: "#6B7280", border: "#D1D5DB" };

  const riwayatPenyakit = [
    ["alergi", "Alergi"], ["asma", "Asma"], ["autoimun", "Autoimun"],
    ["diabetes", "Diabetes"], ["hepatitis_b", "Hepatitis B"], ["hipertensi", "Hipertensi"],
    ["jantung", "Jantung"], ["jiwa", "Gangguan Jiwa"], ["sifilis", "Sifilis"], ["tb", "Tuberkulosis"],
  ];

  const perilakuBerisiko = [
    ["aktivitas_fisik_kurang", "Kurang aktivitas fisik"], ["alkohol", "Konsumsi alkohol"],
    ["kosmetik_berbahaya", "Kosmetik berbahaya"], ["merokok", "Merokok"],
    ["obat_teratogenik", "Obat teratogenik"], ["pola_makan_berisiko", "Pola makan berisiko"],
  ];

  const CheckboxGroup = ({ prefix, items }) => (
    <div className="grid grid-cols-2 md:grid-cols-3 gap-2.5">
      {items.map(([key, label]) => (
        <label
          key={key}
          className="flex items-center gap-2.5 text-sm cursor-pointer hover:bg-gray-50 px-3 py-2 rounded-lg transition-colors border border-transparent hover:border-gray-100"
        >
          <input
            type="checkbox"
            name={`${prefix}${key}`}
            checked={form[`${prefix}${key}`]}
            onChange={handleChange}
            className="w-4 h-4 rounded"
            style={{ accentColor: "#185FA5" }}
          />
          <span className="text-gray-700 font-medium">{label}</span>
        </label>
      ))}
    </div>
  );

  return (
    <form onSubmit={handleSubmitEvaluasi} noValidate className="space-y-4">
      {/* Data Kehamilan (read-only) */}
      <SectionCard icon={Baby} title="Data Kehamilan" subtitle="Tersinkronisasi otomatis, tidak perlu diisi ulang" accentColor="#185FA5">
        <DataKehamilanCard kehamilan={kehamilan} ibu={ibu} />
      </SectionCard>

      {/* Antropometri */}
      <SectionCard
        icon={Scale}
        title="Antropometri"
        subtitle="Isi tinggi badan, berat badan, dan lingkar lengan atas (LiLA) ibu. IMT dihitung otomatis."
        accentColor="#0F6E56"
      >
        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-5 gap-4">
          {/* LiLA */}
          <div>
            <FieldLabel required>LiLA (cm)</FieldLabel>
            <input
              type="number" step="0.1" min="10" max="60"
              name="lila_cm" value={form.lila_cm} onChange={handleChange}
              placeholder="Contoh: 24.0"
              className={errors.lila_cm ? inputError : inputNormal}
            />
            <FieldError msg={errors.lila_cm} />
          </div>
          {/* BB */}
          <div>
            <FieldLabel required>Berat Badan (kg)</FieldLabel>
            <input
              type="number" step="0.1" min="20" max="300"
              name="bb_kg" value={form.bb_kg} onChange={handleChange}
              placeholder="Contoh: 55.0"
              className={errors.bb_kg ? inputError : inputNormal}
            />
            <FieldError msg={errors.bb_kg} />
          </div>
          {/* TB */}
          <div>
            <FieldLabel required>Tinggi Badan (cm)</FieldLabel>
            <input
              type="number" step="0.1" min="50" max="250"
              name="tb_cm" value={form.tb_cm} onChange={handleChange}
              placeholder="Contoh: 158.0"
              className={errors.tb_cm ? inputError : inputNormal}
            />
            <FieldError msg={errors.tb_cm} />
          </div>
          {/* IMT */}
          <div>
            <FieldLabel>IMT (kg/m²)</FieldLabel>
            <input
              type="text"
              value={imtNumeric ? `${imtNumeric}` : "-"}
              readOnly
              className={`${inputBase} bg-gray-100 border-gray-200 text-gray-600 cursor-not-allowed`}
            />
            <p className="text-xs text-gray-400 mt-1">Dihitung otomatis</p>
          </div>
          {/* Kategori IMT */}
          <div>
            <FieldLabel>Kategori IMT</FieldLabel>
            <input
              type="text"
              value={form.imt_kategori || "-"}
              readOnly
              className={`${inputBase} cursor-not-allowed font-semibold`}
              style={{
                backgroundColor: imtColor.bg,
                color: imtColor.color,
                borderColor: imtColor.border,
              }}
            />
            <p className="text-xs text-gray-400 mt-1">Dihitung otomatis</p>
          </div>
        </div>
      </SectionCard>

      {/* Status Imunisasi TT */}
      <SectionCard
        icon={Syringe}
        title="Status Imunisasi TT"
        subtitle="TT (Tetanus Toxoid) melindungi ibu dan bayi dari tetanus saat persalinan. Centang dosis yang sudah diterima."
        accentColor="#3B6D11"
      >
        <div className="grid grid-cols-1 sm:grid-cols-5 gap-2.5 mb-4">
          {[
            { n: 1, desc: "TT1 — Kunjungan pertama" },
            { n: 2, desc: "TT2 — 4 minggu setelah TT1" },
            { n: 3, desc: "TT3 — 6 bulan setelah TT2" },
            { n: 4, desc: "TT4 — 1 tahun setelah TT3" },
            { n: 5, desc: "TT5 — 1 tahun setelah TT4" },
          ].map(({ n, desc }) => (
            <label
              key={n}
              className="flex items-center gap-2 cursor-pointer px-3 py-2.5 rounded-xl border transition-all text-sm select-none"
              style={{
                borderColor: form[`status_tt_${n}`] ? "#3B6D11" : "#E5E7EB",
                backgroundColor: form[`status_tt_${n}`] ? "#EDF7E6" : "#FAFAFA",
              }}
              title={desc}
            >
              <input
                type="checkbox"
                name={`status_tt_${n}`}
                checked={form[`status_tt_${n}`]}
                onChange={handleChange}
                className="w-4 h-4 rounded"
                style={{ accentColor: "#3B6D11" }}
              />
              <span className="font-semibold text-gray-700">TT {n}</span>
            </label>
          ))}
        </div>
        <div>
          <FieldLabel>Imunisasi Lainnya (Covid-19, Influenza, dll) — Opsional</FieldLabel>
          <input
            name="imunisasi_lainnya_covid19"
            value={form.imunisasi_lainnya_covid19}
            onChange={handleChange}
            className={inputNormal}
            placeholder="Contoh: Covid-19 dosis 2, Influenza..."
          />
        </div>
      </SectionCard>

      {/* Riwayat Kesehatan, Perilaku, Keluarga */}
      <SectionCard
        icon={HeartPulse}
        title="Riwayat Kesehatan & Perilaku"
        subtitle="Pilih semua kondisi yang sesuai — riwayat penyakit ibu, perilaku berisiko, dan riwayat penyakit keluarga."
        accentColor="#A32D2D"
      >
        <div className="space-y-6">
          <div>
            <h4 className="text-xs font-bold uppercase tracking-wider mb-1" style={{ color: "#185FA5" }}>
              Riwayat Kesehatan Ibu
            </h4>
            <p className="text-xs text-gray-400 mb-3">Centang penyakit yang pernah atau sedang diderita ibu.</p>
            <CheckboxGroup prefix="riwayat_" items={riwayatPenyakit} />
            <input
              name="riwayat_kesehatan_lainnya"
              placeholder="Riwayat kesehatan lainnya — Opsional"
              value={form.riwayat_kesehatan_lainnya}
              onChange={handleChange}
              className={`${inputNormal} mt-3`}
            />
          </div>

          <div className="border-t border-gray-100 pt-5">
            <h4 className="text-xs font-bold uppercase tracking-wider mb-1" style={{ color: "#BA7517" }}>
              Perilaku Berisiko (1 bulan sebelum hamil)
            </h4>
            <p className="text-xs text-gray-400 mb-3">Centang perilaku yang dilakukan selama 1 bulan sebelum kehamilan.</p>
            <CheckboxGroup prefix="perilaku_" items={perilakuBerisiko} />
            <input
              name="perilaku_lainnya"
              placeholder="Perilaku berisiko lainnya — Opsional"
              value={form.perilaku_lainnya}
              onChange={handleChange}
              className={`${inputNormal} mt-3`}
            />
          </div>

          <div className="border-t border-gray-100 pt-5">
            <h4 className="text-xs font-bold uppercase tracking-wider mb-1" style={{ color: "#0F6E56" }}>
              Riwayat Kesehatan Keluarga
            </h4>
            <p className="text-xs text-gray-400 mb-3">Centang penyakit yang ada pada keluarga ibu (ayah, ibu, saudara kandung).</p>
            <CheckboxGroup prefix="keluarga_" items={riwayatPenyakit} />
            <input
              name="keluarga_lainnya"
              placeholder="Penyakit keluarga lainnya — Opsional"
              value={form.keluarga_lainnya}
              onChange={handleChange}
              className={`${inputNormal} mt-3`}
            />
          </div>
        </div>
      </SectionCard>

      {/* Inspeksi Medis */}
      <SectionCard
        icon={Stethoscope}
        title="Pemeriksaan Khusus (Inspeksi)"
        subtitle="Pilih hasil pemeriksaan visual ginekologis. Semua bidang inspeksi wajib diisi."
        accentColor="#185FA5"
      >
        <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
          {["porsio", "uretra", "vagina", "vulva", "fluksus", "fluor"].map((item) => (
            <div key={item}>
              <FieldLabel required>{item}</FieldLabel>
              <select
                name={`inspeksi_${item}`}
                value={form[`inspeksi_${item}`]}
                onChange={handleChange}
                required
                className={errors[`inspeksi_${item}`] ? inputError : inputNormal}
              >
                <option value="">— Pilih hasil —</option>
                <option value="Normal">Normal</option>
                <option value="Abnormal">Abnormal</option>
              </select>
              <FieldError msg={errors[`inspeksi_${item}`]} />
            </div>
          ))}
        </div>
      </SectionCard>

      {/* Tombol Aksi Form */}
      <div className="flex justify-end gap-3 pt-2 pb-6">
        <button
          type="button"
          onClick={() => setIsEditing(false)}
          className="px-7 py-2.5 rounded-full border-2 text-sm font-semibold transition hover:bg-gray-50"
          style={{ borderColor: "#185FA5", color: "#185FA5" }}
        >
          Batal
        </button>
        <button
          type="submit"
          disabled={saving}
          className="text-white rounded-full px-8 py-2.5 text-sm font-semibold flex items-center gap-2 transition hover:opacity-90 shadow-sm disabled:opacity-50"
          style={{ backgroundColor: "#3B6D11" }}
        >
          <Save size={16} /> {saving ? "Menyimpan..." : "Simpan"}
        </button>
      </div>
    </form>
  );
};

// ─── KOMPONEN UTAMA ───────────────────────────────────────────────────────────
export default function EvaluasiKesehatanIbu() {
  const { id: ibuId } = useParams();
  const [searchParams] = useSearchParams();
  const kehamilanId = searchParams.get("kehamilan_id");
  const navigate = useNavigate();

  const user = getCurrentUser();
  const isDokter = isDokterUser(user);
  const isBidan = isBidanUser(user);

  const [kehamilan, setKehamilan] = useState(null);
  const [ibu, setIbu] = useState(null);
  const [evaluasi, setEvaluasi] = useState(null);
  const [riwayatList, setRiwayatList] = useState([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [isEditing, setIsEditing] = useState(false);
  const [errors, setErrors] = useState({});
  const [isActive, setIsActive] = useState(true);

  const canEdit = isBidan && isActive;

  const emptyForm = {
    nama_dokter: "", tanggal_periksa: new Date().toISOString().split("T")[0],
    fasilitas_kesehatan: "", tb_cm: "", bb_kg: "", imt_kategori: "", lila_cm: "",
    status_tt_1: false, status_tt_2: false, status_tt_3: false, status_tt_4: false, status_tt_5: false,
    imunisasi_lainnya_covid19: "",
    riwayat_alergi: false, riwayat_asma: false, riwayat_autoimun: false, riwayat_diabetes: false,
    riwayat_hepatitis_b: false, riwayat_hipertensi: false, riwayat_jantung: false, riwayat_jiwa: false,
    riwayat_sifilis: false, riwayat_tb: false, riwayat_kesehatan_lainnya: "",
    perilaku_aktivitas_fisik_kurang: false, perilaku_alkohol: false, perilaku_kosmetik_berbahaya: false,
    perilaku_merokok: false, perilaku_obat_teratogenik: false, perilaku_pola_makan_berisiko: false,
    perilaku_lainnya: "",
    keluarga_alergi: false, keluarga_asma: false, keluarga_autoimun: false, keluarga_diabetes: false,
    keluarga_hepatitis_b: false, keluarga_hipertensi: false, keluarga_jantung: false, keluarga_jiwa: false,
    keluarga_sifilis: false, keluarga_tb: false, keluarga_lainnya: "",
    inspeksi_porsio: "", inspeksi_uretra: "", inspeksi_vagina: "", inspeksi_vulva: "",
    inspeksi_fluksus: "", inspeksi_fluor: "",
  };

  const [form, setForm] = useState(emptyForm);

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        try {
          const ibuData = await getIbuById(ibuId);
          setIbu(ibuData);
        } catch {}

        const kehamilanList = await getKehamilanByIbuId(ibuId);
        if (!kehamilanList || kehamilanList.length === 0) {
          Swal.fire({ icon: "info", title: "Data Tidak Tersedia", text: "Ibu belum memiliki data kehamilan.", confirmButtonColor: "#185FA5" });
          navigate(`/data-ibu/${ibuId}`);
          return;
        }

        let targetKehamilan = null;
        if (kehamilanId) {
          targetKehamilan = kehamilanList.find((k) => k.id == kehamilanId);
          if (!targetKehamilan) {
            Swal.fire({ icon: "error", title: "Tidak Ditemukan", text: `Kehamilan dengan ID ${kehamilanId} tidak ditemukan.` });
            navigate(`/data-ibu/${ibuId}`);
            return;
          }
        } else {
          targetKehamilan = kehamilanList[0];
        }
        setKehamilan(targetKehamilan);

        const status = targetKehamilan.status_kehamilan || "";
        setIsActive(status !== "NON-AKTIF");

        const storedUser = JSON.parse(localStorage.getItem("user") || "{}");
        const dokterNama = storedUser.name || "";

        const evalData = await getEvaluasiByKehamilanId(targetKehamilan.id);
        if (evalData && evalData.length > 0) {
          const e = evalData[0];
          setEvaluasi(e);
          setForm({
            nama_dokter: dokterNama || e.nama_dokter || "",
            tanggal_periksa: new Date().toISOString().split("T")[0],
            fasilitas_kesehatan: e.fasilitas_kesehatan || "",
            tb_cm: e.tb_cm ?? "", bb_kg: e.bb_kg ?? "",
            imt_kategori: e.imt_kategori || "", lila_cm: e.lila_cm ?? "",
            status_tt_1: e.status_tt_1 || false, status_tt_2: e.status_tt_2 || false,
            status_tt_3: e.status_tt_3 || false, status_tt_4: e.status_tt_4 || false,
            status_tt_5: e.status_tt_5 || false,
            imunisasi_lainnya_covid19: e.imunisasi_lainnya_covid19 || "",
            riwayat_alergi: e.riwayat_alergi || false, riwayat_asma: e.riwayat_asma || false,
            riwayat_autoimun: e.riwayat_autoimun || false, riwayat_diabetes: e.riwayat_diabetes || false,
            riwayat_hepatitis_b: e.riwayat_hepatitis_b || false, riwayat_hipertensi: e.riwayat_hipertensi || false,
            riwayat_jantung: e.riwayat_jantung || false, riwayat_jiwa: e.riwayat_jiwa || false,
            riwayat_sifilis: e.riwayat_sifilis || false, riwayat_tb: e.riwayat_tb || false,
            riwayat_kesehatan_lainnya: e.riwayat_kesehatan_lainnya || "",
            perilaku_aktivitas_fisik_kurang: e.perilaku_aktivitas_fisik_kurang || false,
            perilaku_alkohol: e.perilaku_alkohol || false,
            perilaku_kosmetik_berbahaya: e.perilaku_kosmetik_berbahaya || false,
            perilaku_merokok: e.perilaku_merokok || false,
            perilaku_obat_teratogenik: e.perilaku_obat_teratogenik || false,
            perilaku_pola_makan_berisiko: e.perilaku_pola_makan_berisiko || false,
            perilaku_lainnya: e.perilaku_lainnya || "",
            keluarga_alergi: e.keluarga_alergi || false, keluarga_asma: e.keluarga_asma || false,
            keluarga_autoimun: e.keluarga_autoimun || false, keluarga_diabetes: e.keluarga_diabetes || false,
            keluarga_hepatitis_b: e.keluarga_hepatitis_b || false, keluarga_hipertensi: e.keluarga_hipertensi || false,
            keluarga_jantung: e.keluarga_jantung || false, keluarga_jiwa: e.keluarga_jiwa || false,
            keluarga_sifilis: e.keluarga_sifilis || false, keluarga_tb: e.keluarga_tb || false,
            keluarga_lainnya: e.keluarga_lainnya || "",
            inspeksi_porsio: e.inspeksi_porsio || "", inspeksi_uretra: e.inspeksi_uretra || "",
            inspeksi_vagina: e.inspeksi_vagina || "", inspeksi_vulva: e.inspeksi_vulva || "",
            inspeksi_fluksus: e.inspeksi_fluksus || "", inspeksi_fluor: e.inspeksi_fluor || "",
          });
          try {
            const riwayat = await getRiwayatKehamilanByEvaluasiId(e.id);
            if (riwayat) setRiwayatList(riwayat);
          } catch (err) { console.error("Gagal memuat riwayat:", err); }
        } else {
          setEvaluasi(null);
          setRiwayatList([]);
          setForm((prev) => ({ ...prev, nama_dokter: dokterNama }));
        }
      } catch (err) {
        console.error(err);
        Swal.fire({ icon: "error", title: "Kesalahan", text: "Gagal memuat data. Silakan coba lagi." });
      } finally {
        setLoading(false);
      }
    };

    if (ibuId) fetchData();
  }, [ibuId, kehamilanId, navigate]);

  const validateForm = () => {
    const newErrors = {};
    if (!form.tb_cm) newErrors.tb_cm = "Tinggi badan wajib diisi";
    else if (parseFloat(form.tb_cm) < 50 || parseFloat(form.tb_cm) > 250) newErrors.tb_cm = "Tinggi badan harus antara 50–250 cm";
    if (!form.bb_kg) newErrors.bb_kg = "Berat badan wajib diisi";
    else if (parseFloat(form.bb_kg) < 20 || parseFloat(form.bb_kg) > 300) newErrors.bb_kg = "Berat badan harus antara 20–300 kg";
    if (!form.lila_cm) newErrors.lila_cm = "Lingkar lengan atas wajib diisi";
    else if (parseFloat(form.lila_cm) < 10 || parseFloat(form.lila_cm) > 60) newErrors.lila_cm = "LiLA harus antara 10–60 cm";
    ["porsio", "uretra", "vagina", "vulva", "fluksus", "fluor"].forEach((item) => {
      if (!form[`inspeksi_${item}`]) newErrors[`inspeksi_${item}`] = `Inspeksi ${item} wajib dipilih`;
    });
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setForm((prev) => ({ ...prev, [name]: type === "checkbox" ? checked : value }));
    if (errors[name]) setErrors((prev) => ({ ...prev, [name]: "" }));
  };

  const handleSubmitEvaluasi = async (e) => {
    e.preventDefault();
    if (!canEdit) {
      Swal.fire("Akses Dibatasi", "Tidak dapat mengubah data karena kehamilan sudah selesai.", "warning");
      return;
    }
    if (!kehamilan) { Swal.fire("Kesalahan", "Data kehamilan tidak ditemukan.", "error"); return; }
    if (!validateForm()) {
      const errorFields = Object.keys(errors);
      const errorMessages = errorFields.map(field => errors[field]).join("\n");
      Swal.fire({ 
        icon: "warning", 
        title: "Validasi Gagal", 
        text: "Mohon lengkapi semua bidang yang wajib diisi.\n\n" + errorMessages,
        confirmButtonColor: "#185FA5" 
      });
      const firstErrorField = errorFields[0];
      const firstErrorInput = document.querySelector(`[name="${firstErrorField}"]`);
      if (firstErrorInput) {
        firstErrorInput.scrollIntoView({ behavior: "smooth", block: "center" });
        firstErrorInput.focus();
      }
      return;
    }
    setSaving(true);
    try {
      const payload = {
        ...form,
        kehamilan_id: parseInt(kehamilan.id),
        tb_cm: form.tb_cm !== "" ? parseFloat(form.tb_cm) : null,
        bb_kg: form.bb_kg !== "" ? parseFloat(form.bb_kg) : null,
        lila_cm: form.lila_cm !== "" ? parseFloat(form.lila_cm) : null,
      };
      let savedEvaluasi;
      if (evaluasi) {
        await updateEvaluasi(evaluasi.id, payload);
        savedEvaluasi = { ...evaluasi, ...payload };
      } else {
        savedEvaluasi = await createEvaluasi(payload);
      }
      setEvaluasi(savedEvaluasi);
      setIsEditing(false);
      Swal.fire({ icon: "success", title: "Berhasil Disimpan", text: "Evaluasi kesehatan ibu berhasil disimpan.", timer: 2000, showConfirmButton: false });
    } catch (err) {
      Swal.fire("Gagal Menyimpan", err.response?.data?.message || "Periksa koneksi Anda atau hubungi admin.", "error");
      console.error(err);
    } finally {
      setSaving(false);
    }
  };

  const handleDeleteEvaluasi = async () => {
    if (!evaluasi) return;
    const result = await Swal.fire({
      title: "Hapus Evaluasi Kesehatan?",
      text: "Tindakan ini akan menghapus seluruh data evaluasi kesehatan ibu, termasuk riwayat kehamilan lalu. Apakah Anda yakin?",
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#A32D2D",
      cancelButtonColor: "#6B7280",
      confirmButtonText: "Ya, Hapus",
      cancelButtonText: "Batal",
    });
    if (!result.isConfirmed) return;
    setSaving(true);
    try {
      await deleteEvaluasi(evaluasi.id);
      await Swal.fire({ icon: "success", title: "Berhasil", text: "Data evaluasi kesehatan berhasil dihapus.", timer: 2000, showConfirmButton: false });
      const storedUser = JSON.parse(localStorage.getItem("user") || "{}");
      setEvaluasi(null);
      setRiwayatList([]);
      setIsEditing(false);
      setForm({ ...emptyForm, nama_dokter: storedUser.name || "" });
    } catch (err) {
      console.error(err);
      Swal.fire({ icon: "error", title: "Gagal Menghapus", text: err.response?.data?.message || err.message || "Terjadi kesalahan saat menghapus data." });
    } finally {
      setSaving(false);
    }
  };

  const handleDeleteRiwayat = async (riwayatId) => {
    const result = await Swal.fire({
      title: "Hapus Riwayat?",
      text: "Yakin ingin menghapus baris riwayat kehamilan ini?",
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#A32D2D",
      cancelButtonColor: "#6B7280",
      confirmButtonText: "Ya, Hapus",
      cancelButtonText: "Batal",
    });
    if (!result.isConfirmed) return;
    try {
      await deleteRiwayatKehamilan(riwayatId);
      setRiwayatList((prev) => prev.filter((r) => r.id_riwayat !== riwayatId));
      Swal.fire({ icon: "success", title: "Berhasil", text: "Riwayat berhasil dihapus.", timer: 1500, showConfirmButton: false });
    } catch (err) {
      console.error(err);
      Swal.fire("Kesalahan", "Gagal menghapus riwayat.", "error");
    }
  };

  if (loading)
    return (
      <MainLayout>
        <div className="flex items-center justify-center min-h-screen" style={{ backgroundColor: "#F7FAFB" }}>
          <div className="flex flex-col items-center gap-3">
            <div className="w-8 h-8 border-4 border-t-transparent rounded-full animate-spin" style={{ borderColor: "#185FA5", borderTopColor: "transparent" }} />
            <p className="text-sm text-gray-500 font-medium">Memuat Data...</p>
          </div>
        </div>
      </MainLayout>
    );

  return (
    <MainLayout>
      <div className="min-h-screen font-sans" style={{ backgroundColor: "#F7FAFB" }}>
        <div className="max-w-5xl mx-auto px-4 py-6 space-y-5">

          {/* ── Header ── */}
          <div className="flex items-start gap-4">
            <button
              onClick={() => navigate(-1)}
              className="inline-flex items-center gap-2 px-4 py-2 rounded-full border text-sm font-semibold transition hover:bg-white"
              style={{ borderColor: "#185FA5", color: "#185FA5" }}
            >
              <ArrowLeft size={15} /> Kembali
            </button>
            <div>
              <h1 className="text-xl sm:text-2xl font-bold text-gray-900 leading-tight">
                Evaluasi Kesehatan Ibu
              </h1>
              <p className="text-sm text-gray-500 mt-0.5">
                Pencatatan status kesehatan, imunisasi, riwayat penyakit, dan pemeriksaan fisik ibu hamil.
              </p>
            </div>
          </div>

          {/* ── Banner Status ── */}
          {!isActive && (
            <div className="flex items-center gap-2.5 px-4 py-3 rounded-xl text-sm font-medium"
              style={{ backgroundColor: "#FEF3CD", border: "1px solid #F0D070", color: "#BA7517" }}>
              <EyeOff size={15} />
              Kehamilan ini sudah selesai (Tidak Aktif). Data hanya dapat dilihat, tidak dapat diubah.
            </div>
          )}
          {!canEdit && isActive && (
            <div className="flex items-center gap-2.5 px-4 py-3 rounded-xl text-sm font-medium"
              style={{ backgroundColor: "#EBF3FC", border: "1px solid #C3D9F0", color: "#185FA5" }}>
              <Eye size={15} />
              Anda masuk sebagai Dokter — mode baca saja. Hanya Bidan yang dapat mengubah data ini.
            </div>
          )}

          {/* ── Konten Utama ── */}
          {isEditing ? (
            <EvaluationForm
              form={form}
              handleChange={handleChange}
              handleSubmitEvaluasi={handleSubmitEvaluasi}
              errors={errors}
              saving={saving}
              setIsEditing={setIsEditing}
              kehamilan={kehamilan}
              ibu={ibu}
            />
          ) : (
            <EvaluationView
              evaluasi={evaluasi}
              form={form}
              riwayatList={riwayatList}
              kehamilan={kehamilan}
              ibu={ibu}
              canEdit={canEdit}
              setIsEditing={setIsEditing}
              handleDeleteEvaluasi={handleDeleteEvaluasi}
              handleDeleteRiwayat={handleDeleteRiwayat}
              saving={saving}
            />
          )}
        </div>
      </div>
    </MainLayout>
  );
}