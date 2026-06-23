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
} from "lucide-react";
import { getCurrentUser, isDokterUser, isBidanUser } from "../../services/auth";

// ─── Helper: checklist Ya/Tidak ──────────────────────────────────────────────
const RenderCheck = ({ value }) =>
  value ? (
    <span className="inline-flex items-center gap-1 text-success font-semibold text-sm">
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

// ─── Tooltip ─────────────────────────────────────────────────────────────────
const HelpTooltip = ({ text }) => (
  <span className="inline-block ml-1 text-primary cursor-help group relative">
    <Info size={14} />
    <span className="absolute bottom-full left-1/2 -translate-x-1/2 mb-1 hidden group-hover:block bg-gray-800 text-white text-xs rounded px-2 py-1 whitespace-nowrap z-10">
      {text}
    </span>
  </span>
);

// ─── SectionCard: kartu section konsisten ────────────────────────────────────
const SectionCard = ({ icon: Icon, title, iconColor = "text-primary", bgColor = "bg-primary-50", children }) => (
  <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
    <div className={`flex items-center gap-2 px-6 py-3 ${bgColor}`}>
      {Icon && <Icon size={16} className={iconColor} />}
      <h3 className={`font-bold text-lg text-gray-800`}>{title}</h3>
    </div>
    <div className="px-6 py-5">{children}</div>
  </div>
);

// ─── InfoCard: sinkronisasi data dari kehamilan/ibu (read-only) ──────────────
const DataKehamilanCard = ({ kehamilan, ibu }) => {
  if (!kehamilan) return null;

  const gravida = kehamilan.gravida ?? ibu?.gravida ?? "-";
  const paritas = kehamilan.paritas ?? ibu?.paritas ?? "-";
  const abortus = kehamilan.abortus ?? ibu?.abortus ?? "-";

  return (
    <div className="bg-primary-50 rounded-lg p-4 mb-4">
      <div className="flex items-center gap-2 mb-3">
        <Baby size={18} className="text-primary" />
        <h3 className="font-bold text-lg text-primary">
          Data Kehamilan (Tersinkronisasi Otomatis)
        </h3>
      </div>
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4 text-sm">
        <div>
        <span className="block text-xs font-bold text-gray-500 uppercase tracking-wider mb-1">
            HPHT
          </span>
          <span className="font-medium text-gray-800 flex items-center gap-1">
            <Calendar size={13} className="text-primary" />
            {formatDate(kehamilan.hpht)}
          </span>
        </div>
        <div>
          <span className="block text-xs font-bold text-gray-500 uppercase tracking-wider mb-1">
            Taksiran Persalinan
          </span>
          <span className="font-medium text-gray-800">
            {formatDate(kehamilan.taksiran_persalinan)}
          </span>
        </div>
        <div>
          <span className="block text-xs font-bold text-gray-500 uppercase tracking-wider mb-1">
            UK Saat Ini
          </span>
          <span className="font-medium text-gray-800">
            {kehamilan.uk_kehamilan_saat_ini
              ? `${kehamilan.uk_kehamilan_saat_ini} minggu`
              : "-"}
          </span>
        </div>
        <div>
          <span className="block text-xs font-bold text-gray-500 uppercase tracking-wider mb-1">
            Jarak Kehamilan
          </span>
          <span className="font-medium text-gray-800">
            {kehamilan.jarak_kehamilan_sebelumnya
              ? `${kehamilan.jarak_kehamilan_sebelumnya} bulan`
              : "-"}
          </span>
        </div>
        <div>
          <span className="block text-xs font-bold text-gray-500 uppercase tracking-wider mb-1">
            Gravida (G)
          </span>
          <span className="font-medium text-gray-800">{gravida}</span>
        </div>
        <div>
          <span className="block text-xs font-bold text-gray-500 uppercase tracking-wider mb-1">
            Paritas (P)
          </span>
          <span className="font-medium text-gray-800">{paritas}</span>
        </div>
        <div>
          <span className="block text-xs font-bold text-gray-500 uppercase tracking-wider mb-1">
            Abortus (A)
          </span>
          <span className="font-medium text-gray-800">{abortus}</span>
        </div>
        <div>
          <span className="block text-xs font-bold text-gray-500 uppercase tracking-wider mb-1">
            IMT Awal Kehamilan
          </span>
          <span className="font-medium text-gray-800">
            {kehamilan.imt_awal ? `${kehamilan.imt_awal} kg/m²` : "-"}
          </span>
        </div>
      </div>
      <p className="text-xs text-primary mt-2 italic">
        * Data ini tersinkronisasi otomatis dari data ibu dan tidak perlu diisi ulang.
      </p>
    </div>
  );
};

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
      <div className="bg-white rounded-xl shadow-sm p-8 text-center">
        <div className="flex flex-col items-center gap-4">
          <div className="p-4 rounded-full bg-indigo-50">
            <FileText size={40} className="text-indigo-400" />
          </div>
          <h3 className="text-xl font-semibold text-gray-800">Belum Ada Data Evaluasi Kesehatan</h3>
          <p className="text-gray-500 max-w-md">Silakan isi data evaluasi kesehatan untuk memulai pemantauan kesehatan ibu hamil.</p>
          {canEdit && (
            <button
              onClick={() => setIsEditing(true)}
              className="bg-indigo-600 text-white px-6 py-2.5 rounded-lg font-semibold flex items-center gap-2 hover:bg-indigo-700 transition"
            >
              <Plus size={18} /> Tambah Evaluasi Pertama
            </button>
          )}
          {!canEdit && (
            <p className="text-xs text-gray-400 mt-2">Hanya Bidan yang dapat menambahkan data Evaluasi Kesehatan.</p>
          )}
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-5">
      <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
        <div className="px-6 py-5 space-y-6">
          {/* Data kehamilan otomatis */}
          <DataKehamilanCard kehamilan={kehamilan} ibu={ibu} />

          {/* Kondisi Kesehatan Ibu */}
          <div>
            <h3 className="font-bold text-lg text-gray-800 mb-3">Kondisi Kesehatan Ibu</h3>
            <div className="grid grid-cols-2 md:grid-cols-5 gap-6 text-base">
              <div>
                <span className="font-bold text-gray-500 text-xs uppercase block mb-1">
                  TB (Tinggi)
                </span>
                {form.tb_cm ? `${form.tb_cm} cm` : "-"}
              </div>
              <div>
                <span className="font-bold text-gray-500 text-xs uppercase block mb-1">
                  BB (Berat)
                </span>
                {form.bb_kg ? `${form.bb_kg} kg` : "-"}
              </div>
              <div>
                <span className="font-bold text-gray-500 text-xs uppercase block mb-1">
                  IMT
                </span>
                {form.tb_cm && form.bb_kg
                  ? `${calculateIMT(form.tb_cm, form.bb_kg).imt} kg/m²`
                  : "-"}
              </div>
              <div>
                <span className="font-bold text-gray-500 text-xs uppercase block mb-1">
                  Status Gizi
                </span>
                <span
                  className={`px-2 py-1 rounded text-xs font-bold ${
                    form.imt_kategori === "Normal"
                      ? "bg-success/10 text-success"
                      : form.imt_kategori === "Kurus"
                      ? "bg-warning/10 text-warning"
                      : form.imt_kategori === "Gemuk" || form.imt_kategori === "Obesitas"
                      ? "bg-danger/10 text-danger"
                      : "bg-gray-100 text-gray-600"
                  }`}
                >
                  {form.imt_kategori || "-"}
                </span>
              </div>
              <div>
                <span className="font-bold text-gray-500 text-xs uppercase block mb-1">
                  LiLA (Lengan)
                </span>
                {form.lila_cm ? `${form.lila_cm} cm` : "-"}
              </div>
            </div>
          </div>

          {/* Status Imunisasi TT */}
          <div>
            <h3 className="font-bold text-lg text-gray-800 mb-3">Status Imunisasi TT</h3>
            <div className="grid grid-cols-2 md:grid-cols-5 gap-6">
              {[1, 2, 3, 4, 5].map((n) => (
                <div key={n} className="flex items-center gap-2">
                  <span className="font-bold text-gray-700 text-base">TT {n}</span>
                  <RenderCheck value={form[`status_tt_${n}`]} />
                </div>
              ))}
            </div>
            <div className="mt-6 pt-5 border-t border-gray-100">
              <span className="block text-sm font-bold text-gray-500 uppercase tracking-wider mb-2">
                Imunisasi Lainnya (Misal: Covid-19)
              </span>
              <p className="text-base text-gray-900">
                {form.imunisasi_lainnya_covid19 || "-"}
              </p>
            </div>
          </div>

          {/* Pemeriksaan Khusus (Inspeksi) */}
          <div>
            <h3 className="font-bold text-lg text-gray-800 mb-3">Pemeriksaan Khusus (Inspeksi)</h3>
            <div className="grid grid-cols-2 md:grid-cols-3 gap-8 text-base">
              {["porsio", "uretra", "vagina", "vulva", "fluksus", "fluor"].map(
                (item) => (
                  <div key={item}>
                    <span className="font-bold text-gray-500 text-xs uppercase block mb-1">
                      {item}
                    </span>
                    <span
                      className={`px-3 py-1 rounded-full text-sm font-bold ${
                        form[`inspeksi_${item}`] === "Normal"
                          ? "bg-success/10 text-success"
                          : "bg-danger/10 text-danger"
                      }`}
                    >
                      {form[`inspeksi_${item}`] || "-"}
                    </span>
                  </div>
                )
              )}
            </div>
          </div>

          {/* Riwayat Kesehatan Ibu */}
          <div>
            <h3 className="font-bold text-lg text-gray-800 mb-3">Riwayat Kesehatan Ibu</h3>
            <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-2 text-sm mb-3">
              {[
                ["alergi", "Alergi"],
                ["asma", "Asma"],
                ["autoimun", "Autoimun"],
                ["diabetes", "Diabetes"],
                ["hepatitis_b", "Hepatitis B"],
                ["hipertensi", "Hipertensi"],
                ["jantung", "Jantung"],
                ["jiwa", "Gangguan Jiwa"],
                ["sifilis", "Sifilis"],
                ["tb", "Tuberkulosis"],
              ].map(([key, label]) => (
                <div key={key} className="flex items-center gap-1.5">
                  <span className="font-medium text-gray-700">{label}:</span>{" "}
                  <RenderCheck value={form[`riwayat_${key}`]} />
                </div>
              ))}
            </div>
            <div>
              <span className="font-medium text-sm text-gray-700">Lainnya:</span>{" "}
              {form.riwayat_kesehatan_lainnya || "-"}
            </div>
          </div>

          {/* Perilaku Berisiko */}
          <div>
            <h3 className="font-bold text-lg text-gray-800 mb-3">Perilaku Berisiko (1 bulan sebelum hamil)</h3>
            <div className="grid grid-cols-2 md:grid-cols-3 gap-2 text-sm mb-3">
              {[
                ["aktivitas_fisik_kurang", "Kurang aktivitas fisik"],
                ["alkohol", "Konsumsi alkohol"],
                ["kosmetik_berbahaya", "Kosmetik berbahaya"],
                ["merokok", "Merokok"],
                ["obat_teratogenik", "Obat teratogenik"],
                ["pola_makan_berisiko", "Pola makan berisiko"],
              ].map(([key, label]) => (
                <div key={key} className="flex items-center gap-1.5">
                  <span className="font-medium text-gray-700">{label}:</span>{" "}
                  <RenderCheck value={form[`perilaku_${key}`]} />
                </div>
              ))}
            </div>
            <div>
              <span className="font-medium text-sm text-gray-700">Lainnya:</span>{" "}
              {form.perilaku_lainnya || "-"}
            </div>
          </div>

          {/* Riwayat Penyakit Keluarga */}
          <div>
            <h3 className="font-bold text-lg text-gray-800 mb-3">Riwayat Penyakit Keluarga</h3>
            <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-2 text-sm mb-3">
              {[
                ["alergi", "Alergi"],
                ["asma", "Asma"],
                ["autoimun", "Autoimun"],
                ["diabetes", "Diabetes"],
                ["hepatitis_b", "Hepatitis B"],
                ["hipertensi", "Hipertensi"],
                ["jantung", "Jantung"],
                ["jiwa", "Gangguan Jiwa"],
                ["sifilis", "Sifilis"],
                ["tb", "Tuberkulosis"],
              ].map(([key, label]) => (
                <div key={key} className="flex items-center gap-1.5">
                  <span className="font-medium text-gray-700">{label}:</span>{" "}
                  <RenderCheck value={form[`keluarga_${key}`]} />
                </div>
              ))}
            </div>
            <div>
              <span className="font-medium text-sm text-gray-700">Lainnya:</span>{" "}
              {form.keluarga_lainnya || "-"}
            </div>
          </div>

          {/* Riwayat Kehamilan Lalu — READ ONLY dari database */}
          <div className="border-t border-gray-200 pt-5">
            <div className="flex items-center justify-between mb-5">
              <h3 className="font-bold text-lg text-primary">
                Riwayat Kehamilan Lalu
              </h3>
              <span className="text-xs bg-primary-50 text-primary px-3 py-1 rounded-full border border-primary/20">
                Data dari sistem
              </span>
            </div>
            {riwayatList.length > 0 ? (
              <div className="overflow-x-auto">
                <table className="min-w-full divide-y divide-gray-200 text-base">
                  <thead className="bg-gray-50">
                    <tr>
                      <th className="px-3 py-3 text-left text-xs font-bold text-gray-500 uppercase">No</th>
                      <th className="px-3 py-3 text-left text-xs font-bold text-gray-500 uppercase">Tahun</th>
                      <th className="px-3 py-3 text-left text-xs font-bold text-gray-500 uppercase">Berat (gr)</th>
                      <th className="px-3 py-3 text-left text-xs font-bold text-gray-500 uppercase">Proses Melahirkan</th>
                      <th className="px-3 py-3 text-left text-xs font-bold text-gray-500 uppercase">Penolong</th>
                      <th className="px-3 py-3 text-left text-xs font-bold text-gray-500 uppercase">Masalah</th>
                      {canEdit && (
                        <th className="px-3 py-3 text-center text-xs font-bold text-gray-500 uppercase">Aksi</th>
                      )}
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-100">
                    {riwayatList.map((r, idx) => (
                      <tr key={r.id_riwayat || idx} className="hover:bg-gray-50">
                        <td className="px-3 py-4">{r.no_urut}</td>
                        <td className="px-3 py-4 font-bold">{r.tahun}</td>
                        <td className="px-3 py-4">{r.bb_gram || "-"}</td>
                        <td className="px-3 py-4">{r.proses_melahirkan}</td>
                        <td className="px-3 py-4">{r.penolong_proses_melahirkan || "-"}</td>
                        <td className="px-3 py-4">{r.masalah || "-"}</td>
                        {canEdit && (
                          <td className="px-3 py-4 text-center">
                            <button
                              onClick={() => handleDeleteRiwayat(r.id_riwayat)}
                              className="p-1 text-danger hover:bg-danger/10 rounded transition-colors"
                              title="Hapus baris ini"
                            >
                              <Trash2 size={16} />
                            </button>
                          </td>
                        )}
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            ) : (
              <p className="text-gray-400 text-sm">
                Belum ada riwayat kehamilan lalu tercatat di sistem.
              </p>
            )}
          </div>
        </div>
      </div>

      {canEdit && evaluasi && (
        <div className="flex justify-end gap-4">
          <button
            onClick={() => setIsEditing(true)}
            className="bg-warning text-white rounded-full px-8 py-3 text-base font-semibold flex items-center gap-2 hover:bg-warning/90 transition shadow-lg min-h-[48px]"
          >
            <Edit size={16} /> Ubah Evaluasi
          </button>
          <button
            onClick={handleDeleteEvaluasi}
            disabled={saving}
            className="bg-danger text-white rounded-full px-8 py-3 text-base font-semibold flex items-center gap-2 hover:bg-danger/90 transition shadow-lg disabled:opacity-50 min-h-[48px]"
          >
            <Trash2 size={18} /> Hapus Data
          </button>
        </div>
      )}
    </div>
  );
};

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

  // Sinkron kategori IMT ke form state
  useEffect(() => {
    if (computedKategori && computedKategori !== form.imt_kategori) {
      handleChange({ target: { name: "imt_kategori", value: computedKategori } });
    } else if (!computedKategori && form.imt_kategori) {
      handleChange({ target: { name: "imt_kategori", value: "" } });
    }
  }, [computedKategori, form.imt_kategori, handleChange]);

  return (
    <form onSubmit={handleSubmitEvaluasi} noValidate className="space-y-4">
      <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
        <div className="px-6 py-5 space-y-6">
          {/* Data kehamilan otomatis (read-only) */}
          <DataKehamilanCard kehamilan={kehamilan} ibu={ibu} />

          {/* Antropometri */}
          <div>
            <h3 className="font-bold text-lg text-gray-800 mb-2">
              Antropometri
            </h3>
            <p className="text-sm text-gray-500 mb-4">
              Isi data tinggi badan, berat badan, dan lingkar lengan atas (LiLA) ibu saat pemeriksaan dilakukan. IMT akan dihitung otomatis berdasarkan TB dan BB yang dimasukkan.
            </p>
            <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-5 gap-3">
              {/* LiLA */}
              <div>
                <label className="block text-sm font-bold text-gray-500 uppercase tracking-wider mb-2">
                  LiLA (cm) <span className="text-danger">*</span>
                </label>
                <input
                  type="number"
                  step="0.1"
                  min="10"
                  max="60"
                  name="lila_cm"
                  value={form.lila_cm}
                  onChange={handleChange}
                  placeholder="Contoh: 24,0"
                  required
                  className={`w-full border rounded-lg px-4 h-12 text-base focus:outline-none focus:ring-2 focus:ring-primary/20 transition ${
                    errors.lila_cm
                      ? "border-danger bg-danger/10"
                      : "border-gray-200 focus:border-primary"
                  }`}
                />
                {errors.lila_cm && (
                  <p className="text-danger text-xs mt-1">{errors.lila_cm}</p>
                )}
              </div>

              {/* BB */}
              <div>
                <label className="block text-sm font-bold text-gray-500 uppercase tracking-wider mb-2">
                  BB (kg) <span className="text-danger">*</span>
                </label>
                <input
                  type="number"
                  step="0.1"
                  min="20"
                  max="300"
                  name="bb_kg"
                  value={form.bb_kg}
                  onChange={handleChange}
                  placeholder="Contoh: 55,0"
                  required
                  className={`w-full border rounded-lg px-4 h-12 text-base focus:outline-none focus:ring-2 focus:ring-primary/20 transition ${
                    errors.bb_kg
                      ? "border-danger bg-danger/10"
                      : "border-gray-200 focus:border-primary"
                  }`}
                />
                {errors.bb_kg && (
                  <p className="text-danger text-xs mt-1">{errors.bb_kg}</p>
                )}
              </div>

              {/* TB */}
              <div>
                <label className="block text-sm font-bold text-gray-500 uppercase tracking-wider mb-2">
                  TB (cm) <span className="text-danger">*</span>
                </label>
                <input
                  type="number"
                  step="0.1"
                  min="50"
                  max="250"
                  name="tb_cm"
                  value={form.tb_cm}
                  onChange={handleChange}
                  placeholder="Contoh: 158,0"
                  required
                  className={`w-full border rounded-lg px-4 h-12 text-base focus:outline-none focus:ring-2 focus:ring-primary/20 transition ${
                    errors.tb_cm
                      ? "border-danger bg-danger/10"
                      : "border-gray-200 focus:border-primary"
                  }`}
                />
                {errors.tb_cm && (
                  <p className="text-danger text-xs mt-1">{errors.tb_cm}</p>
                )}
              </div>

              {/* IMT (auto-hitung) */}
              <div>
                <label className="block text-sm font-bold text-gray-500 uppercase tracking-wider mb-2">
                  IMT (kg/m²)
                </label>
                <input
                  type="text"
                  value={imtNumeric ? `${imtNumeric}` : "-"}
                  readOnly
                  className="w-full border border-gray-200 rounded-lg px-4 h-12 bg-gray-100 text-base cursor-not-allowed"
                />
                <p className="text-xs text-gray-400 mt-1">Dihitung otomatis</p>
              </div>

              {/* Kategori IMT (auto-hitung) */}
              <div>
                <label className="block text-sm font-bold text-gray-500 uppercase tracking-wider mb-2">
                  Kategori IMT
                </label>
              <input
                type="text"
                value={form.imt_kategori || "-"}
                readOnly
                className={`w-full border rounded-lg px-4 h-12 text-base cursor-not-allowed ${
                  form.imt_kategori === "Normal"
                    ? "bg-success/10 text-success border-success/30"
                    : form.imt_kategori === "Kurus"
                    ? "bg-warning/10 text-warning border-warning/30"
                    : form.imt_kategori === "Gemuk" || form.imt_kategori === "Obesitas"
                    ? "bg-danger/10 text-danger border-danger/30"
                    : "bg-gray-100 text-gray-500 border-gray-200"
                }`}
              />
                <p className="text-xs text-gray-400 mt-1">Dihitung otomatis</p>
              </div>
            </div>
          </div>

          {/* Status Imunisasi TT */}
          <div>
            <h3 className="font-bold text-lg text-primary border-b pb-3 mb-2">
              Status Imunisasi TT
            </h3>
            <p className="text-sm text-gray-500 mb-4">
              TT (Tetanus Toxoid) melindungi ibu dan bayi dari tetanus saat persalinan. Dosis lengkap 5 kali memberikan perlindungan seumur hidup. Centang dosis yang telah diterima.
            </p>
            <div className="grid grid-cols-2 md:grid-cols-5 gap-3 mb-3">
              {[
                { n: 1, desc: "Kunjungan pertama (TT1)" },
                { n: 2, desc: "4 minggu setelah TT1 (TT2)" },
                { n: 3, desc: "6 bulan setelah TT2 (TT3)" },
                { n: 4, desc: "1 tahun setelah TT3 (TT4)" },
                { n: 5, desc: "1 tahun setelah TT4 (TT5)" },
              ].map(({ n, desc }) => (
                <label
                  key={n}
                  className="flex items-center gap-2 cursor-pointer hover:bg-gray-50 p-2 rounded-lg transition-colors text-sm"
                  title={desc}
                >
                  <input
                    type="checkbox"
                    name={`status_tt_${n}`}
                    checked={form[`status_tt_${n}`]}
                    onChange={handleChange}
                    className="w-4 h-4 text-primary border-gray-200 rounded focus:ring-primary"
                  />
                  <span className="font-medium text-gray-700 text-sm">{desc}</span>
                </label>
              ))}
            </div>
            <div className="mt-4">
              <label className="block text-sm font-bold text-gray-500 uppercase tracking-wider mb-2">
                Imunisasi Lainnya (Covid-19, dll)
              </label>
              <input
                name="imunisasi_lainnya_covid19"
                value={form.imunisasi_lainnya_covid19}
                onChange={handleChange}
                className="w-full border border-gray-200 rounded-lg px-4 h-12 text-base focus:outline-none focus:border-primary focus:ring-2 focus:ring-primary/20 transition"
                placeholder="Contoh: Covid-19 dosis 2, Influenza..."
              />
            </div>
          </div>

          {/* Riwayat Kesehatan, Perilaku, Keluarga */}
          <div>
            {/* <h3 className="font-bold text-lg text-gray-800 mb-4">Riwayat Kesehatan, Perilaku, dan Keluarga</h3> */}
            {/* Riwayat Kesehatan Ibu */}
            <div className="mb-6">
              <h4 className="font-bold text-base text-primary mb-2">
                Riwayat Kesehatan, Perilaku, dan Keluarga
              </h4>
              <p className="text-xs text-gray-500 mb-3">
                Pilih riwayat penyakit yang pernah atau sedang diderita ibu atau keluarga. Centang semua yang sesuai.
              </p>
              <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
                {[
                  ["alergi", "Alergi"],
                  ["asma", "Asma"],
                  ["autoimun", "Autoimun"],
                  ["diabetes", "Diabetes"],
                  ["hepatitis_b", "Hepatitis B"],
                  ["hipertensi", "Hipertensi"],
                  ["jantung", "Jantung"],
                  ["jiwa", "Gangguan Jiwa"],
                  ["sifilis", "Sifilis"],
                  ["tb", "Tuberkulosis"],
                ].map(([key, label]) => (
                  <label key={key} className="flex items-center gap-2 text-base cursor-pointer">
                    <input
                      type="checkbox"
                      name={`riwayat_${key}`}
                      checked={form[`riwayat_${key}`]}
                      onChange={handleChange}
                      className="w-5 h-5 accent-primary"
                    />
                    {label}
                  </label>
                ))}
              </div>
              <input
                name="riwayat_kesehatan_lainnya"
                placeholder="Riwayat kesehatan lainnya (opsional)"
                value={form.riwayat_kesehatan_lainnya}
                onChange={handleChange}
                className="w-full border border-gray-200 rounded-lg px-4 h-12 mt-3 text-base focus:outline-none focus:border-primary focus:ring-2 focus:ring-primary/20 transition"
              />
            </div>

            {/* Perilaku Berisiko */}
            <div className="mb-6">
              <h4 className="font-bold text-base text-primary mb-2">
                Perilaku Berisiko (1 bulan sebelum hamil)
              </h4>
              <p className="text-xs text-gray-500 mb-3">
                Pilih perilaku berisiko yang dilakukan ibu selama 1 bulan sebelum kehamilan.
              </p>
              <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
                {[
                  ["aktivitas_fisik_kurang", "Kurang aktivitas fisik"],
                  ["alkohol", "Konsumsi alkohol"],
                  ["kosmetik_berbahaya", "Kosmetik berbahaya"],
                  ["merokok", "Merokok"],
                  ["obat_teratogenik", "Obat teratogenik"],
                  ["pola_makan_berisiko", "Pola makan berisiko"],
                ].map(([key, label]) => (
                  <label key={key} className="flex items-center gap-2 text-base cursor-pointer">
                    <input
                      type="checkbox"
                      name={`perilaku_${key}`}
                      checked={form[`perilaku_${key}`]}
                      onChange={handleChange}
                      className="w-5 h-5 accent-primary"
                    />
                    {label}
                  </label>
                ))}
              </div>
              <input
                name="perilaku_lainnya"
                placeholder="Perilaku berisiko lainnya (opsional)"
                value={form.perilaku_lainnya}
                onChange={handleChange}
                className="w-full border border-gray-200 rounded-lg px-4 h-12 mt-3 text-base focus:outline-none focus:border-primary focus:ring-2 focus:ring-primary/20 transition"
              />
            </div>

            {/* Riwayat Kesehatan Keluarga */}
            <div>
              <h4 className="font-bold text-base text-primary mb-2">
                Riwayat Kesehatan Keluarga
              </h4>
              <p className="text-xs text-gray-500 mb-3">
                Pilih riwayat penyakit yang ada pada keluarga ibu (ayah, ibu, saudara kandung).
              </p>
              <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
                {[
                  ["alergi", "Alergi"],
                  ["asma", "Asma"],
                  ["autoimun", "Autoimun"],
                  ["diabetes", "Diabetes"],
                  ["hepatitis_b", "Hepatitis B"],
                  ["hipertensi", "Hipertensi"],
                  ["jantung", "Jantung"],
                  ["jiwa", "Gangguan Jiwa"],
                  ["sifilis", "Sifilis"],
                  ["tb", "Tuberkulosis"],
                ].map(([key, label]) => (
                  <label key={key} className="flex items-center gap-2 text-base cursor-pointer">
                    <input
                      type="checkbox"
                      name={`keluarga_${key}`}
                      checked={form[`keluarga_${key}`]}
                      onChange={handleChange}
                      className="w-5 h-5 accent-primary"
                    />
                    {label}
                  </label>
                ))}
              </div>
              <input
                name="keluarga_lainnya"
                placeholder="Penyakit keluarga lainnya (opsional)"
                value={form.keluarga_lainnya}
                onChange={handleChange}
                className="w-full border border-gray-200 rounded-lg px-4 h-12 mt-3 text-base focus:outline-none focus:border-primary focus:ring-2 focus:ring-primary/20 transition"
              />
            </div>
          </div>

          {/* Inspeksi Medis */}
          <div>
            <h3 className="font-bold text-lg text-primary border-b pb-3 mb-2">
              Inspeksi Medis <span className="text-danger text-base">*</span>
            </h3>
            <p className="text-sm text-gray-500 mb-4">
              Pilih hasil pemeriksaan visual pada area genital. Semua field inspeksi wajib diisi.
            </p>
            <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
              {["porsio", "uretra", "vagina", "vulva", "fluksus", "fluor"].map(
                (item) => (
                  <div key={item}>
                    <label className="block capitalize text-sm font-bold text-gray-500 uppercase mb-2">
                      {item} <span className="text-danger">*</span>
                    </label>
                    <select
                      name={`inspeksi_${item}`}
                      value={form[`inspeksi_${item}`]}
                      onChange={handleChange}
                      required
                      className={`w-full border rounded-lg px-4 h-12 text-base focus:outline-none focus:border-primary focus:ring-2 focus:ring-primary/20 transition ${
                        errors[`inspeksi_${item}`]
                          ? "border-danger bg-danger/10"
                          : "border-gray-200"
                      }`}
                    >
                      <option value="">-- Pilih --</option>
                      <option value="Normal">Normal</option>
                      <option value="Abnormal">Abnormal</option>
                    </select>
                    {errors[`inspeksi_${item}`] && (
                      <p className="text-danger text-xs mt-1">
                        {errors[`inspeksi_${item}`]}
                      </p>
                    )}
                  </div>
                )
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Tombol aksi */}
      <div className="flex justify-end gap-4 mt-10">
        <button
          type="button"
          onClick={() => setIsEditing(false)}
          className="px-8 py-3 rounded-full border-[1.5px] border-primary text-primary text-base font-semibold hover:bg-primary/5 transition min-h-[48px]"
        >
          Batal
        </button>
        <button
          type="submit"
          disabled={saving}
          className="bg-success text-white rounded-full px-10 py-3 text-base font-semibold flex items-center gap-2 hover:bg-success/90 disabled:opacity-50 transition shadow-lg min-h-[48px]"
        >
          <Save size={20} /> {saving ? "Menyimpan..." : "Simpan"}
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

  // Evaluasi Kesehatan Ibu Hamil: bidan mengelola, dokter melibat (view only)
  const canEdit = isBidan && isActive;

  const [form, setForm] = useState({
    nama_dokter: "",
    tanggal_periksa: new Date().toISOString().split("T")[0],
    fasilitas_kesehatan: "",
    tb_cm: "",
    bb_kg: "",
    imt_kategori: "",
    lila_cm: "",
    status_tt_1: false,
    status_tt_2: false,
    status_tt_3: false,
    status_tt_4: false,
    status_tt_5: false,
    imunisasi_lainnya_covid19: "",
    riwayat_alergi: false,
    riwayat_asma: false,
    riwayat_autoimun: false,
    riwayat_diabetes: false,
    riwayat_hepatitis_b: false,
    riwayat_hipertensi: false,
    riwayat_jantung: false,
    riwayat_jiwa: false,
    riwayat_sifilis: false,
    riwayat_tb: false,
    riwayat_kesehatan_lainnya: "",
    perilaku_aktivitas_fisik_kurang: false,
    perilaku_alkohol: false,
    perilaku_kosmetik_berbahaya: false,
    perilaku_merokok: false,
    perilaku_obat_teratogenik: false,
    perilaku_pola_makan_berisiko: false,
    perilaku_lainnya: "",
    keluarga_alergi: false,
    keluarga_asma: false,
    keluarga_autoimun: false,
    keluarga_diabetes: false,
    keluarga_hepatitis_b: false,
    keluarga_hipertensi: false,
    keluarga_jantung: false,
    keluarga_jiwa: false,
    keluarga_sifilis: false,
    keluarga_tb: false,
    keluarga_lainnya: "",
    inspeksi_porsio: "",
    inspeksi_uretra: "",
    inspeksi_vagina: "",
    inspeksi_vulva: "",
    inspeksi_fluksus: "",
    inspeksi_fluor: "",
  });

  // ─── Fetch data utama ──────────────────────────────────────────────────────
  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);

        // Ambil data ibu untuk Gravida/Paritas/Abortus
        try {
          const ibuData = await getIbuById(ibuId);
          setIbu(ibuData);
        } catch {
          // tidak fatal jika gagal
        }

        const kehamilanList = await getKehamilanByIbuId(ibuId);
        if (!kehamilanList || kehamilanList.length === 0) {
          Swal.fire({
            icon: "info",
            title: "Data Tidak Tersedia",
            text: "Ibu belum memiliki data kehamilan.",
            confirmButtonColor: "#185FA5",
          });
          navigate(`/data-ibu/${ibuId}`);
          return;
        }

        let targetKehamilan = null;
        if (kehamilanId) {
          targetKehamilan = kehamilanList.find((k) => k.id == kehamilanId);
          if (!targetKehamilan) {
            Swal.fire({
              icon: "error",
              title: "Tidak Ditemukan",
              text: `Kehamilan dengan ID ${kehamilanId} tidak ditemukan.`,
            });
            navigate(`/data-ibu/${ibuId}`);
            return;
          }
        } else {
          targetKehamilan = kehamilanList[0];
        }
        setKehamilan(targetKehamilan);

        const status = targetKehamilan.status_kehamilan || "";
        setIsActive(status !== "NON-AKTIF");

        // Nama dokter dari localStorage
        const storedUser = JSON.parse(localStorage.getItem("user") || "{}");
        const dokterNama = storedUser.name || "";

        // Ambil evaluasi
        const evalData = await getEvaluasiByKehamilanId(targetKehamilan.id);

        if (evalData && evalData.length > 0) {
          const e = evalData[0];
          setEvaluasi(e);
          setForm({
            nama_dokter: dokterNama || e.nama_dokter || "",
            tanggal_periksa: new Date().toISOString().split("T")[0],
            fasilitas_kesehatan: e.fasilitas_kesehatan || "",
            tb_cm: e.tb_cm ?? "",
            bb_kg: e.bb_kg ?? "",
            imt_kategori: e.imt_kategori || "",
            lila_cm: e.lila_cm ?? "",
            status_tt_1: e.status_tt_1 || false,
            status_tt_2: e.status_tt_2 || false,
            status_tt_3: e.status_tt_3 || false,
            status_tt_4: e.status_tt_4 || false,
            status_tt_5: e.status_tt_5 || false,
            imunisasi_lainnya_covid19: e.imunisasi_lainnya_covid19 || "",
            riwayat_alergi: e.riwayat_alergi || false,
            riwayat_asma: e.riwayat_asma || false,
            riwayat_autoimun: e.riwayat_autoimun || false,
            riwayat_diabetes: e.riwayat_diabetes || false,
            riwayat_hepatitis_b: e.riwayat_hepatitis_b || false,
            riwayat_hipertensi: e.riwayat_hipertensi || false,
            riwayat_jantung: e.riwayat_jantung || false,
            riwayat_jiwa: e.riwayat_jiwa || false,
            riwayat_sifilis: e.riwayat_sifilis || false,
            riwayat_tb: e.riwayat_tb || false,
            riwayat_kesehatan_lainnya: e.riwayat_kesehatan_lainnya || "",
            perilaku_aktivitas_fisik_kurang:
              e.perilaku_aktivitas_fisik_kurang || false,
            perilaku_alkohol: e.perilaku_alkohol || false,
            perilaku_kosmetik_berbahaya: e.perilaku_kosmetik_berbahaya || false,
            perilaku_merokok: e.perilaku_merokok || false,
            perilaku_obat_teratogenik: e.perilaku_obat_teratogenik || false,
            perilaku_pola_makan_berisiko:
              e.perilaku_pola_makan_berisiko || false,
            perilaku_lainnya: e.perilaku_lainnya || "",
            keluarga_alergi: e.keluarga_alergi || false,
            keluarga_asma: e.keluarga_asma || false,
            keluarga_autoimun: e.keluarga_autoimun || false,
            keluarga_diabetes: e.keluarga_diabetes || false,
            keluarga_hepatitis_b: e.keluarga_hepatitis_b || false,
            keluarga_hipertensi: e.keluarga_hipertensi || false,
            keluarga_jantung: e.keluarga_jantung || false,
            keluarga_jiwa: e.keluarga_jiwa || false,
            keluarga_sifilis: e.keluarga_sifilis || false,
            keluarga_tb: e.keluarga_tb || false,
            keluarga_lainnya: e.keluarga_lainnya || "",
            inspeksi_porsio: e.inspeksi_porsio || "",
            inspeksi_uretra: e.inspeksi_uretra || "",
            inspeksi_vagina: e.inspeksi_vagina || "",
            inspeksi_vulva: e.inspeksi_vulva || "",
            inspeksi_fluksus: e.inspeksi_fluksus || "",
            inspeksi_fluor: e.inspeksi_fluor || "",
          });

          // Ambil riwayat kehamilan lalu (data historis dari db)
          try {
            const riwayat = await getRiwayatKehamilanByEvaluasiId(e.id);
            if (riwayat) setRiwayatList(riwayat);
          } catch (err) {
            console.error("Gagal load riwayat:", err);
          }
        } else {
          // Belum ada evaluasi — set form kosong dengan nama dokter
          setEvaluasi(null);
          setRiwayatList([]);
          setForm((prev) => ({
            ...prev,
            nama_dokter: dokterNama,
          }));
        }
      } catch (err) {
        console.error(err);
        Swal.fire({
          icon: "error",
          title: "Error",
          text: "Gagal memuat data. Silakan coba lagi.",
        });
      } finally {
        setLoading(false);
      }
    };

    if (ibuId) fetchData();
  }, [ibuId, kehamilanId, navigate]);

  // ─── Validasi form ─────────────────────────────────────────────────────────
  const validateForm = () => {
    const newErrors = {};

    if (!form.tanggal_periksa)
      newErrors.tanggal_periksa = "Tanggal periksa wajib diisi";

    if (!form.fasilitas_kesehatan || !form.fasilitas_kesehatan.trim())
      newErrors.fasilitas_kesehatan = "Fasilitas kesehatan wajib diisi";

    if (!form.tb_cm) {
      newErrors.tb_cm = "Tinggi badan wajib diisi";
    } else if (parseFloat(form.tb_cm) < 50 || parseFloat(form.tb_cm) > 250) {
      newErrors.tb_cm = "Tinggi badan harus antara 50–250 cm";
    }

    if (!form.bb_kg) {
      newErrors.bb_kg = "Berat badan wajib diisi";
    } else if (parseFloat(form.bb_kg) < 20 || parseFloat(form.bb_kg) > 300) {
      newErrors.bb_kg = "Berat badan harus antara 20–300 kg";
    }

    if (!form.lila_cm) {
      newErrors.lila_cm = "Lingkar lengan atas wajib diisi";
    } else if (parseFloat(form.lila_cm) < 10 || parseFloat(form.lila_cm) > 60) {
      newErrors.lila_cm = "LiLA harus antara 10–60 cm";
    }

    // Semua field inspeksi wajib dipilih
    ["porsio", "uretra", "vagina", "vulva", "fluksus", "fluor"].forEach(
      (item) => {
        if (!form[`inspeksi_${item}`]) {
          newErrors[`inspeksi_${item}`] = `Inspeksi ${item} wajib dipilih`;
        }
      }
    );

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  // ─── Handler perubahan input ───────────────────────────────────────────────
  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setForm((prev) => ({
      ...prev,
      [name]: type === "checkbox" ? checked : value,
    }));
    if (errors[name]) setErrors((prev) => ({ ...prev, [name]: "" }));
  };

  // ─── Submit evaluasi ───────────────────────────────────────────────────────
  const handleSubmitEvaluasi = async (e) => {
    e.preventDefault();
    if (!canEdit) {
      Swal.fire(
        "Akses Dibatasi",
        "Tidak dapat mengubah data karena kehamilan sudah selesai.",
        "warning"
      );
      return;
    }
    if (!kehamilan) {
      Swal.fire("Error", "Kehamilan tidak ditemukan", "error");
      return;
    }
    if (!validateForm()) {
      Swal.fire({
        icon: "warning",
        title: "Validasi Gagal",
        text: "Mohon lengkapi semua field yang wajib diisi sebelum menyimpan.",
        confirmButtonColor: "#185FA5",
      });
      // scroll ke error pertama
      const firstError = document.querySelector(".border-danger");
      if (firstError) firstError.scrollIntoView({ behavior: "smooth", block: "center" });
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
      Swal.fire({
        icon: "success",
        title: "Berhasil Disimpan",
        text: "Evaluasi kesehatan ibu berhasil disimpan.",
        timer: 2000,
        showConfirmButton: false,
      });
    } catch (err) {
      Swal.fire(
        "Gagal Menyimpan",
        err.response?.data?.message || "Periksa koneksi Anda atau hubungi admin.",
        "error"
      );
      console.error(err);
    } finally {
      setSaving(false);
    }
  };

  // ─── Hapus evaluasi ────────────────────────────────────────────────────────
  const handleDeleteEvaluasi = async () => {
    if (!evaluasi) return;
    const result = await Swal.fire({
      title: "Hapus Evaluasi Kesehatan?",
      text: "Tindakan ini akan menghapus seluruh data evaluasi kesehatan ibu, termasuk riwayat kehamilan lalu. Apakah Anda yakin?",
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#A32D2D",
      cancelButtonColor: "#6b7280",
      confirmButtonText: "Ya, Hapus!",
      cancelButtonText: "Batal",
    });
    if (!result.isConfirmed) return;

    setSaving(true);
    try {
      await deleteEvaluasi(evaluasi.id);
      await Swal.fire({
        icon: "success",
        title: "Berhasil",
        text: "Data evaluasi kesehatan berhasil dihapus.",
        timer: 2000,
        showConfirmButton: false,
      });
      setEvaluasi(null);
      setRiwayatList([]);
      setIsEditing(false);
      const storedUser = JSON.parse(localStorage.getItem("user") || "{}");
      setForm((prev) => ({
        ...prev,
        nama_dokter: storedUser.name || "",
        tanggal_periksa: new Date().toISOString().split("T")[0],
        fasilitas_kesehatan: "",
        tb_cm: "",
        bb_kg: "",
        imt_kategori: "",
        lila_cm: "",
        status_tt_1: false,
        status_tt_2: false,
        status_tt_3: false,
        status_tt_4: false,
        status_tt_5: false,
        imunisasi_lainnya_covid19: "",
        riwayat_alergi: false,
        riwayat_asma: false,
        riwayat_autoimun: false,
        riwayat_diabetes: false,
        riwayat_hepatitis_b: false,
        riwayat_hipertensi: false,
        riwayat_jantung: false,
        riwayat_jiwa: false,
        riwayat_sifilis: false,
        riwayat_tb: false,
        riwayat_kesehatan_lainnya: "",
        perilaku_aktivitas_fisik_kurang: false,
        perilaku_alkohol: false,
        perilaku_kosmetik_berbahaya: false,
        perilaku_merokok: false,
        perilaku_obat_teratogenik: false,
        perilaku_pola_makan_berisiko: false,
        perilaku_lainnya: "",
        keluarga_alergi: false,
        keluarga_asma: false,
        keluarga_autoimun: false,
        keluarga_diabetes: false,
        keluarga_hepatitis_b: false,
        keluarga_hipertensi: false,
        keluarga_jantung: false,
        keluarga_jiwa: false,
        keluarga_sifilis: false,
        keluarga_tb: false,
        keluarga_lainnya: "",
        inspeksi_porsio: "",
        inspeksi_uretra: "",
        inspeksi_vagina: "",
        inspeksi_vulva: "",
        inspeksi_fluksus: "",
        inspeksi_fluor: "",
      }));
    } catch (err) {
      console.error(err);
      Swal.fire({
        icon: "error",
        title: "Gagal Menghapus",
        text:
          err.response?.data?.message ||
          err.message ||
          "Terjadi kesalahan saat menghapus data.",
      });
    } finally {
      setSaving(false);
    }
  };

  // ─── Hapus baris riwayat ───────────────────────────────────────────────────
  const handleDeleteRiwayat = async (riwayatId) => {
    const result = await Swal.fire({
      title: "Hapus Riwayat?",
      text: "Yakin ingin menghapus baris riwayat kehamilan ini?",
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#A32D2D",
      cancelButtonColor: "#6b7280",
      confirmButtonText: "Ya, Hapus!",
      cancelButtonText: "Batal",
    });
    if (!result.isConfirmed) return;
    try {
      await deleteRiwayatKehamilan(riwayatId);
      setRiwayatList((prev) => prev.filter((r) => r.id_riwayat !== riwayatId));
      Swal.fire("Berhasil", "Riwayat berhasil dihapus", "success");
    } catch (err) {
      console.error(err);
      Swal.fire("Error", "Gagal menghapus riwayat.", "error");
    }
  };

  if (loading)
    return (
      <MainLayout>
        <div className="p-6 text-base text-gray-500">Memuat data...</div>
      </MainLayout>
    );

  return (
    <MainLayout>
      <div className="min-h-screen bg-background">
        <div className="max-w-5xl mx-auto p-5 space-y-5">
          {/* Header */}
          <div className="flex items-center gap-4">
            <button
              onClick={() => navigate(-1)}
              className="inline-flex items-center gap-2 px-5 py-2.5 rounded-full border border-primary text-primary text-sm font-semibold hover:bg-primary/5 transition"
            >
              <ArrowLeft size={16} />
              <span>Kembali</span>
            </button>
            <h1 className="text-[28px] font-bold text-gray-900">
              Evaluasi Kesehatan Ibu
            </h1>
          </div>

          {/* Status banner */}
          {!isActive && (
            <div className="bg-secondary/10 border border-secondary/30 text-secondary p-3 rounded-lg text-base flex items-center gap-2">
              <EyeOff size={16} /> Kehamilan ini sudah selesai (NON-AKTIF). Data hanya dapat dilihat, tidak dapat diubah.
            </div>
          )}
          {!canEdit && isActive && (
            <div className="bg-secondary/10 border border-secondary/30 text-secondary p-3 rounded-lg text-base flex items-center gap-2">
              <Eye size={16} /> Anda dalam mode baca (Dokter). Data hanya dapat dilihat, tidak dapat diubah.
            </div>
          )}

          {/* Form atau View */}
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