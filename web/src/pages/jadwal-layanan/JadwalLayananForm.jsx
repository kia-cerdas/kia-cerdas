import React, { useEffect, useState } from "react";
import MainLayout from "../../components/Layout/MainLayout";
import { useNavigate, useParams } from "react-router-dom";
import {
  createJadwalLayanan,
  getJadwalLayananById,
  updateJadwalLayanan,
} from "../../services/jadwalLayanan";
import { listPosyanduForDropdown } from "../../services/adminTenagaKesehatan";
import { getDosisVaksinList } from "../../services/dosisVaksin";
import {
  ArrowLeft,
  Calendar,
  Clock,
  MapPin,
  FileText,
  Stethoscope,
  RefreshCw,
  Save,
  AlertCircle,
  Syringe,
  Check,
  X,
} from "lucide-react";

function FormField({ label, icon: Icon, children, hint }) {
  return (
    <div className="space-y-1.5">
      <label className="flex items-center gap-1.5 text-sm font-semibold text-slate-700">
        {Icon && <Icon size={14} className="text-slate-400" />}
        {label}
      </label>
      {children}
      {hint && <p className="text-xs text-slate-400">{hint}</p>}
    </div>
  );
}

const inputClass =
  "w-full px-3.5 py-2.5 text-sm border border-slate-200 rounded-xl bg-white text-slate-800 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-[#185FA5]/30 focus:border-[#185FA5] transition-all";

function normalizeTimeValue(value) {
  if (!value) return "";
  if (typeof value === "string") {
    if (/^\d{2}:\d{2}$/.test(value)) return value;
    const timeInIso = value.match(/T(\d{2}:\d{2})/);
    if (timeInIso?.[1]) return timeInIso[1];
    const timeOnly = value.match(/^(\d{2}:\d{2})(:\d{2})?$/);
    if (timeOnly?.[1]) return timeOnly[1];
  }
  return "";
}

// Fungsi validasi waktu untuk hari ini
function isTimeValidForToday(selectedDate, timeValue) {
  if (!selectedDate || !timeValue) return true;
  
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const selectedDateObj = new Date(selectedDate);
  selectedDateObj.setHours(0, 0, 0, 0);
  
  // Jika tanggal bukan hari ini, tidak perlu validasi waktu
  if (selectedDateObj.getTime() !== today.getTime()) {
    return true;
  }
  
  // Jika tanggal hari ini, cek apakah waktu sudah lewat
  const now = new Date();
  const currentHour = now.getHours();
  const currentMinute = now.getMinutes();
  
  const [hour, minute] = timeValue.split(':').map(Number);
  
  if (hour < currentHour) return false;
  if (hour === currentHour && minute < currentMinute) return false;
  
  return true;
}

// Mendapatkan waktu minimal untuk hari ini
function getMinTimeForToday() {
  const today = new Date();
  const currentHour = today.getHours();
  const currentMinute = today.getMinutes();
  return `${String(currentHour).padStart(2, '0')}:${String(currentMinute).padStart(2, '0')}`;
}

// Multi-select dropdown component untuk Dosis Vaksin
function MultiSelectDosisVaksin({ options, selectedValues, onChange, disabled }) {
  const [isOpen, setIsOpen] = useState(false);
  const [searchTerm, setSearchTerm] = useState("");

  const filteredOptions = options.filter(opt =>
    opt.Vaksin?.nama?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    opt.nama_dosis?.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const toggleOption = (dosisId) => {
    if (selectedValues.includes(dosisId)) {
      onChange(selectedValues.filter(id => id !== dosisId));
    } else {
      onChange([...selectedValues, dosisId]);
    }
  };

  const removeOption = (dosisId) => {
    onChange(selectedValues.filter(id => id !== dosisId));
  };

  const selectedDosisVaksins = options.filter(opt => selectedValues.includes(opt.id));

  return (
    <div className="relative">
      <div
        className={`${inputClass} min-h-[46px] flex flex-wrap gap-1.5 cursor-pointer`}
        onClick={() => !disabled && setIsOpen(!isOpen)}
      >
        {selectedDosisVaksins.length > 0 ? (
          selectedDosisVaksins.map(dosis => (
            <span
              key={dosis.id}
              className="inline-flex items-center gap-1 px-2 py-0.5 bg-[#185FA5]/10 text-[#185FA5] text-xs rounded-lg"
            >
              {dosis.Vaksin?.nama} - {dosis.nama_dosis}
              {!disabled && (
                <button
                  type="button"
                  onClick={(e) => {
                    e.stopPropagation();
                    removeOption(dosis.id);
                  }}
                  className="hover:text-[#A32D2D]"
                >
                  <X size={12} />
                </button>
              )}
            </span>
          ))
        ) : (
          <span className="text-slate-400">Pilih dosis vaksin yang tersedia...</span>
        )}
      </div>

      {isOpen && !disabled && (
        <>
          <div className="fixed inset-0 z-10" onClick={() => setIsOpen(false)} />
          <div className="absolute z-20 mt-1 w-full bg-white border border-slate-200 rounded-xl shadow-lg overflow-hidden">
            <div className="p-2 border-b border-slate-100">
              <input
                type="text"
                placeholder="Cari vaksin atau dosis..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full px-3 py-1.5 text-sm border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#185FA5]/30"
                onClick={(e) => e.stopPropagation()}
              />
            </div>
            <div className="max-h-48 overflow-y-auto">
              {filteredOptions.length > 0 ? (
                filteredOptions.map(dosis => (
                  <label
                    key={dosis.id}
                    className="flex items-center gap-2 px-3 py-2 hover:bg-slate-50 cursor-pointer transition-colors"
                  >
                    <input
                      type="checkbox"
                      checked={selectedValues.includes(dosis.id)}
                      onChange={() => toggleOption(dosis.id)}
                      className="w-4 h-4 rounded border-slate-300 text-[#185FA5] focus:ring-[#185FA5]/30"
                    />
                    <div className="flex-1">
                      <p className="text-sm font-medium text-slate-700">
                        {dosis.Vaksin?.nama} - {dosis.nama_dosis}
                      </p>
                      {dosis.Vaksin?.deskripsi && (
                        <p className="text-xs text-slate-400 truncate">{dosis.Vaksin.deskripsi}</p>
                      )}
                    </div>
                  </label>
                ))
              ) : (
                <p className="px-3 py-4 text-sm text-slate-400 text-center">
                  Tidak ada dosis vaksin ditemukan
                </p>
              )}
            </div>
          </div>
        </>
      )}
    </div>
  );
}

export default function JadwalLayananForm() {
  const navigate = useNavigate();
  const { id } = useParams();
  const isEdit = Boolean(id);

  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");
  const [posyanduOptions, setPosyanduOptions] = useState([]);
  const [dosisVaksinOptions, setDosisVaksinOptions] = useState([]);

  const [form, setForm] = useState({
    posyandu_id: "",
    layanan: "",
    tanggal: "",
    waktu_mulai: "",
    waktu_selesai: "",
    keterangan: "",
    dosis_vaksin_ids: [],
  });

  // Load existing data when editing
  useEffect(() => {
    if (!id) return;
    const load = async () => {
      setLoading(true);
      try {
        const data = await getJadwalLayananById(id);
        if (data) {
          setForm({
            posyandu_id: data.posyandu_id ?? "",
            layanan: data.layanan ?? "",
            tanggal: data.tanggal ? data.tanggal.split("T")[0] : "",
            waktu_mulai: normalizeTimeValue(data.waktu_mulai),
            waktu_selesai: normalizeTimeValue(data.waktu_selesai),
            keterangan: data.keterangan ?? "",
            dosis_vaksin_ids: data.dosis_vaksin_ids ?? data.dosis_vaksins?.map(d => d.id) ?? [],
          });
        }
      } catch {
        setError("Gagal memuat data jadwal. Silakan kembali dan coba lagi.");
      } finally {
        setLoading(false);
      }
    };
    load();
  }, [id]);

  // Load posyandu dropdown
  useEffect(() => {
    const loadPosyandu = async () => {
      try {
        const data = await listPosyanduForDropdown({ page: 1, per_page: 100 });
        setPosyanduOptions(Array.isArray(data) ? data : []);
      } catch {
        // ignore
      }
    };
    loadPosyandu();
  }, []);

  // Load dosis vaksin list
  useEffect(() => {
    const loadDosisVaksin = async () => {
      try {
        const data = await getDosisVaksinList();
        setDosisVaksinOptions(Array.isArray(data) ? data : []);
      } catch (error) {
        console.error("Failed to load dosis vaksin:", error);
      }
    };
    loadDosisVaksin();
  }, []);

  // Handler untuk semua input
  const handleChange = (e) => {
    const { name, value } = e.target;
    setForm((prev) => ({ ...prev, [name]: value }));
    setError("");
  };

  // Handler khusus untuk tanggal
  const handleTanggalChange = (e) => {
    const value = e.target.value;
    
    // Validasi tanggal tidak boleh kurang dari hari ini
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const selectedDate = new Date(value);
    
    if (selectedDate < today) {
      setError("Tanggal pelayanan tidak boleh kurang dari hari ini");
      return;
    }
    
    setError("");
    setForm((prev) => ({ ...prev, tanggal: value }));
  };

  // Handler khusus untuk waktu mulai
  const handleWaktuMulaiChange = (e) => {
    const value = e.target.value;
    
    if (!form.tanggal) {
      setError("Pilih tanggal terlebih dahulu");
      return;
    }
    
    if (!isTimeValidForToday(form.tanggal, value)) {
      setError("Waktu mulai tidak boleh kurang dari jam sekarang untuk hari ini");
      return;
    }
    
    setError("");
    setForm((prev) => ({ ...prev, waktu_mulai: value }));
  };

  // Handler khusus untuk waktu selesai
  const handleWaktuSelesaiChange = (e) => {
    const value = e.target.value;
    
    if (form.waktu_mulai && value <= form.waktu_mulai) {
      setError("Waktu selesai harus lebih besar dari waktu mulai");
      return;
    }
    
    if (!isTimeValidForToday(form.tanggal, value)) {
      setError("Waktu selesai tidak boleh kurang dari jam sekarang untuk hari ini");
      return;
    }
    
    setError("");
    setForm((prev) => ({ ...prev, waktu_selesai: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setSaving(true);
    setError("");

    // Validasi tanggal
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const selectedDate = new Date(form.tanggal);
    
    if (!form.tanggal) {
      setError("Tanggal harus diisi");
      setSaving(false);
      return;
    }
    
    if (selectedDate < today) {
      setError("Tanggal pelayanan tidak boleh kurang dari hari ini");
      setSaving(false);
      return;
    }

    // Validasi waktu mulai
    if (!form.waktu_mulai) {
      setError("Waktu mulai harus diisi");
      setSaving(false);
      return;
    }

    if (!isTimeValidForToday(form.tanggal, form.waktu_mulai)) {
      setError("Waktu mulai tidak boleh kurang dari jam sekarang untuk hari ini");
      setSaving(false);
      return;
    }

    // Validasi waktu selesai
    if (form.waktu_selesai) {
      if (form.waktu_selesai <= form.waktu_mulai) {
        setError("Waktu selesai harus lebih besar dari waktu mulai");
        setSaving(false);
        return;
      }
      
      if (!isTimeValidForToday(form.tanggal, form.waktu_selesai)) {
        setError("Waktu selesai tidak boleh kurang dari jam sekarang untuk hari ini");
        setSaving(false);
        return;
      }
    }

    const payload = {
      posyandu_id: form.posyandu_id ? Number(form.posyandu_id) : null,
      layanan: form.layanan,
      tanggal: form.tanggal,
      waktu_mulai: form.waktu_mulai || null,
      waktu_selesai: form.waktu_selesai || null,
      keterangan: form.keterangan || null,
      dosis_vaksin_ids: form.dosis_vaksin_ids,
    };

    try {
      if (isEdit) {
        await updateJadwalLayanan(id, payload);
      } else {
        await createJadwalLayanan(payload);
      }
      navigate("/jadwal-layanan");
    } catch (err) {
      const apiErr = err?.response?.data;
      if (apiErr?.error === "validation" && Array.isArray(apiErr?.fields)) {
        setError(apiErr.fields.map((f) => `${f.field}: ${f.message}`).join("; "));
      } else {
        setError(apiErr?.error || apiErr?.details || "Gagal menyimpan data jadwal.");
      }
    } finally {
      setSaving(false);
    }
  };

  const isTodayDate = form.tanggal === new Date().toISOString().split('T')[0];

  return (
    <MainLayout>
      <div className="space-y-5 max-w-3xl">
        {/* Back + header */}
        <section className="bg-white rounded-2xl border border-slate-200 shadow-sm">
          <div className="px-6 py-5 flex items-center gap-4">
            <button
              type="button"
              onClick={() => navigate("/jadwal-layanan")}
              className="p-2 rounded-xl hover:bg-slate-100 text-slate-500 hover:text-slate-700 transition-colors"
            >
              <ArrowLeft size={18} />
            </button>
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-xl bg-[#185FA5]/10 flex items-center justify-center">
                <Calendar size={20} className="text-[#185FA5]" />
              </div>
              <div>
                <h1 className="text-xl font-bold text-slate-800 leading-tight">
                  {isEdit ? "Edit Jadwal Layanan" : "Tambah Jadwal Layanan"}
                </h1>
                <p className="text-sm text-slate-400 mt-0.5">
                  {isEdit
                    ? "Perbarui informasi jadwal imunisasi."
                    : "Buat sesi imunisasi baru untuk posyandu."}
                </p>
              </div>
            </div>
          </div>
        </section>

        {/* Form */}
        <section className="bg-white rounded-2xl border border-slate-200 shadow-sm">
          {loading ? (
            <div className="flex flex-col items-center justify-center py-20 gap-3">
              <div className="w-10 h-10 rounded-full border-2 border-[#185FA5]/20 border-t-[#185FA5] animate-spin" />
              <p className="text-sm text-slate-400 font-medium">Memuat data...</p>
            </div>
          ) : (
            <form onSubmit={handleSubmit} className="p-6 space-y-6">
              {/* Nama Layanan */}
              <FormField label="Nama Layanan" icon={Stethoscope}>
                <input
                  name="layanan"
                  value={form.layanan}
                  onChange={handleChange}
                  placeholder="cth. Imunisasi BCG, Polio, DPT-HB-Hib"
                  className={inputClass}
                  required
                />
              </FormField>

              {/* Dosis Vaksin */}
              <FormField 
                label="Daftar Vaksin & Dosis" 
                icon={Syringe}
                hint="Pilih dosis vaksin yang akan diberikan pada jadwal ini"
              >
                <MultiSelectDosisVaksin
                  options={dosisVaksinOptions}
                  selectedValues={form.dosis_vaksin_ids}
                  onChange={(values) => setForm(prev => ({ ...prev, dosis_vaksin_ids: values }))}
                  disabled={saving}
                />
              </FormField>

              {/* Grid: Posyandu, Tanggal, Waktu */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <FormField label="Posyandu" icon={MapPin} hint="Kosongkan jika belum ditentukan">
                  <select
                    name="posyandu_id"
                    value={form.posyandu_id}
                    onChange={handleChange}
                    className={inputClass}
                  >
                    <option value="">— Pilih posyandu (opsional) —</option>
                    {posyanduOptions.map((p) => (
                      <option key={p.id} value={p.id}>
                        {p.nama || p.name || p.alamat || `Posyandu ${p.id}`}
                      </option>
                    ))}
                  </select>
                </FormField>

                <FormField label="Tanggal Pelayanan" icon={Calendar}>
                  <input
                    type="date"
                    name="tanggal"
                    value={form.tanggal}
                    onChange={handleTanggalChange}
                    className={inputClass}
                    required
                    min={new Date().toISOString().split('T')[0]}
                  />
                </FormField>

                <FormField label="Waktu Pelayanan" icon={Clock} hint="Pilih rentang waktu: mulai dan selesai (HH:MM)">
                  <div className="flex items-center gap-2">
                    <input
                      type="time"
                      name="waktu_mulai"
                      value={form.waktu_mulai}
                      onChange={handleWaktuMulaiChange}
                      className={`${inputClass} max-w-[140px]`}
                      required
                      min={isTodayDate ? getMinTimeForToday() : undefined}
                    />
                    <span className="text-sm text-slate-400">—</span>
                    <input
                      type="time"
                      name="waktu_selesai"
                      value={form.waktu_selesai}
                      onChange={handleWaktuSelesaiChange}
                      className={`${inputClass} max-w-[140px]`}
                      min={form.waktu_mulai || undefined}
                    />
                  </div>
                </FormField>
              </div>

              {/* Keterangan */}
              <FormField label="Keterangan" icon={FileText} hint="Opsional — catatan tambahan untuk jadwal ini">
                <textarea
                  name="keterangan"
                  value={form.keterangan}
                  onChange={handleChange}
                  rows={3}
                  placeholder="Catatan tambahan, syarat peserta, dsb."
                  className={`${inputClass} resize-none`}
                />
              </FormField>

              {/* Selected dosis vaksin summary */}
              {form.dosis_vaksin_ids.length > 0 && dosisVaksinOptions.length > 0 && (
                <div className="bg-slate-50 rounded-xl p-3 border border-slate-100">
                  <p className="text-xs font-semibold text-slate-500 mb-2 flex items-center gap-1">
                    <Syringe size={12} />
                    DOSIS VAKSIN YANG AKAN DIBERIKAN ({form.dosis_vaksin_ids.length})
                  </p>
                  <div className="flex flex-wrap gap-2">
                    {dosisVaksinOptions
                      .filter(d => form.dosis_vaksin_ids.includes(d.id))
                      .map(dosis => (
                        <span
                          key={dosis.id}
                          className="inline-flex items-center gap-1 px-2.5 py-1 bg-white border border-slate-200 rounded-lg text-xs text-slate-600"
                        >
                          <Check size={10} className="text-emerald-500" />
                          {dosis.Vaksin?.nama} - {dosis.nama_dosis}
                        </span>
                      ))}
                  </div>
                </div>
              )}

              {/* Error message */}
              {error && (
                <div className="flex items-start gap-3 px-4 py-3 bg-red-50 border border-red-100 rounded-xl">
                  <AlertCircle size={16} className="text-[#A32D2D] mt-0.5 shrink-0" />
                  <p className="text-sm text-[#A32D2D] leading-relaxed">{error}</p>
                </div>
              )}

              {/* Action buttons */}
              <div className="flex items-center gap-3 pt-2 border-t border-slate-100">
                <button
                  type="submit"
                  disabled={saving}
                  className="flex items-center gap-2 px-5 py-2.5 bg-[#185FA5] hover:bg-[#0e4a84] disabled:bg-[#185FA5]/60 text-white text-sm font-semibold rounded-xl transition-colors"
                >
                  {saving ? (
                    <>
                      <RefreshCw size={15} className="animate-spin" />
                      Menyimpan...
                    </>
                  ) : (
                    <>
                      <Save size={15} />
                      {isEdit ? "Update Jadwal" : "Simpan Jadwal"}
                    </>
                  )}
                </button>
                <button
                  type="button"
                  onClick={() => navigate("/jadwal-layanan")}
                  disabled={saving}
                  className="px-5 py-2.5 text-sm font-semibold text-slate-600 bg-slate-100 hover:bg-slate-200 rounded-xl transition-colors disabled:opacity-50"
                >
                  Batal
                </button>
              </div>
            </form>
          )}
        </section>
      </div>
    </MainLayout>
  );
}