import React, { useEffect, useMemo, useState } from "react";
import {
  ArrowLeft, Baby, Calendar, Droplets, Info, Loader2,
  Save, Utensils
} from "lucide-react";
import { PelayananGiziService } from "../../services/Pelayanan-gizi-anak";

const PelayananGiziForm = ({ anakId, ageNow, authUser, onSaved, onCancel, setNotification }) => {
  const initialForm = useMemo(() => ({
    bulan_ke: ageNow || 1,
    asi: {
      frekuensi_menyusui: "",
      posisi_menyusui: "baik",
      asiperah: "tidak"
    },
    mpasi: {
      sudah_mpasi: false,
      varian_mpasi: [],
      jumlah_makan: "",
      frekuensi_makan: {
        makanan_utama: "",
        makanan_selingan: ""
      }
    },
    obat_cacing: false,
    jenis_pemberian_susu: "ASI Eksklusif",
    masih_menyusui: true,
    menggunakan_formula: false,
    alasan_formula: "",
    usia_mulai_mpasi: 6
  }), [ageNow]);

  const [formData, setFormData] = useState(initialForm);
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    setFormData(prev => ({
      ...initialForm,
      bulan_ke: ageNow || prev.bulan_ke || 1
    }));
  }, [initialForm, ageNow]);

  const requestPayload = useMemo(() => {
    const formatFrekuensi = () => {
      const utama = formData.mpasi.frekuensi_makan.makanan_utama || "0";
      const selingan = formData.mpasi.frekuensi_makan.makanan_selingan || "0";
      const cleanUtama = utama.replace('/hari', '').toLowerCase();
      const cleanSelingan = selingan.replace('/hari', '').toLowerCase();
      return `${cleanUtama} utama, ${cleanSelingan} selingan`;
    };

    const bulan = parseInt(formData.bulan_ke);

    return {
      anak_id: parseInt(anakId),
      tanggal: new Date().toISOString().split('T')[0],
      tenaga_kesehatan_id: parseInt(authUser.id || authUser.user_id || 0),
      bulan_ke: bulan,
      lokasi: authUser.lokasi || "Puskesmas Medan",

      asi: bulan < 24 ? {
        frekuensi_menyusui: parseInt(formData.asi.frekuensi_menyusui) || 0,
        posisi_menyusui: formData.asi.posisi_menyusui,
        asi_perah: formData.asi.asiperah
      } : null,

      mpasi: (bulan >= 6) ? {
        diberikan_mp_asi: formData.mpasi.sudah_mpasi,
        variasi_mpasi: formData.mpasi.varian_mpasi.map(v => v.toLowerCase()),
        jumlah_makan_perporsi: formData.mpasi.jumlah_makan || "-",
        frekuensi_makan_perhari: formData.mpasi.sudah_mpasi ? formatFrekuensi() : "-"
      } : null,

      obat_cacing: (bulan >= 24) ? formData.obat_cacing : null,
      jenis_pemberian_susu: bulan < 24 ? formData.jenis_pemberian_susu : "",
      masih_menyusui: (bulan >= 6) ? formData.masih_menyusui : null,
      menggunakan_formula: (bulan < 24) ? (formData.jenis_pemberian_susu === "ASI + Formula" || formData.jenis_pemberian_susu === "Formula") : false,
      alasan_formula: (bulan < 24 && (formData.jenis_pemberian_susu === "ASI + Formula" || formData.jenis_pemberian_susu === "Formula")) ? formData.alasan_formula : "",
      usia_mulai_mpasi: (bulan >= 6 && formData.mpasi.sudah_mpasi) ? parseInt(formData.usia_mulai_mpasi) : null
    };
  }, [formData, anakId, authUser]);

  const handleSave = async () => {
    const bulan = parseInt(formData.bulan_ke);

    if (bulan < 6 && formData.mpasi.sudah_mpasi) {
      setNotification({
        type: "error",
        message: "MPASI hanya dapat diberikan mulai usia 6 bulan."
      });
      return;
    }

    if (bulan < 24 && formData.asi.frekuensi_menyusui === "") {
      setNotification({
        type: "error",
        message: "Mohon isi frekuensi menyusui."
      });
      return;
    }

    setSubmitting(true);
    try {
      await PelayananGiziService.create(requestPayload);
      setNotification({
        type: "success",
        message: "Data pelayanan gizi berhasil disimpan."
      });
      onSaved();
    } catch (err) {
      const errorMsg = err.response?.data?.error || err.response?.data?.message || err.message;
      setNotification({
        type: "error",
        message: errorMsg || "Permintaan gagal diproses.",
        code: errorMsg
      });
    } finally {
      setSubmitting(false);
    }
  };

  const updateField = (path, value) => {
    setFormData(prev => {
      const keys = path.split('.');
      const next = { ...prev };
      let target = next;
      for (let i = 0; i < keys.length - 1; i++) {
        target[keys[i]] = { ...target[keys[i]] };
        target = target[keys[i]];
      }
      target[keys[keys.length - 1]] = value;
      return next;
    });
  };

  const isSelected = (item) => formData.mpasi.varian_mpasi.includes(item);
  const toggleVarian = (item) => {
    const next = isSelected(item)
      ? formData.mpasi.varian_mpasi.filter(i => i !== item)
      : [...formData.mpasi.varian_mpasi, item];
    updateField('mpasi.varian_mpasi', next);
  };

  const SectionTitle = ({ icon: Icon, color = "text-blue-500", label }) => (
    <h4 className="text-sm font-bold text-slate-800 mb-3 flex items-center gap-2">
      <Icon size={18} className={color} /> {label}
    </h4>
  );

  const FieldLabel = ({ children }) => (
    <label className="text-xs font-semibold text-slate-600 block mb-1">{children}</label>
  );

  const Input = (props) => (
    <input
      {...props}
      className={`w-full bg-slate-50 border border-slate-200 rounded-xl px-3 py-2 text-sm outline-none focus:bg-white focus:ring-2 focus:ring-blue-100 transition-all ${props.className || ""}`}
    />
  );

  const Select = (props) => (
    <select
      {...props}
      className={`w-full bg-slate-50 border border-slate-200 rounded-xl px-3 py-2 text-sm outline-none focus:bg-white focus:ring-2 focus:ring-blue-100 transition-all ${props.className || ""}`}
    />
  );

  return (
    <div className="space-y-5">
      {/* FORM HEADER */}
      <section className="bg-white rounded-2xl border border-slate-200 shadow-sm">
        <div className="px-5 py-4 flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div className="flex items-center gap-3">
            <button
              type="button"
              onClick={onCancel}
              className="p-2 rounded-xl hover:bg-slate-100 text-slate-500 hover:text-slate-700 transition-colors"
            >
              <ArrowLeft size={18} />
            </button>
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-xl bg-blue-50 flex items-center justify-center">
                <Baby size={20} className="text-blue-600" />
              </div>
              <div>
                <h1 className="text-lg font-bold text-slate-800 leading-tight">Input Pelayanan Gizi</h1>
                <p className="text-xs text-slate-500 font-medium mt-0.5">
                  Petugas: {authUser.nama || authUser.name || authUser.username || "Petugas"}
                </p>
              </div>
            </div>
          </div>
          {ageNow && (
            <span className="inline-flex items-center gap-1.5 self-start md:self-auto px-3 py-1.5 bg-blue-50 text-blue-700 text-xs font-medium rounded-full border border-blue-100">
              <Calendar size={12} /> Usia Anak: <strong>{ageNow} Bulan</strong>
            </span>
          )}
        </div>
      </section>

      {/* FORM BODY */}
      <section className="bg-white rounded-2xl border border-slate-200 shadow-sm p-5 md:p-6">
        {/* INFO BANNER */}
        {parseInt(formData.bulan_ke) < 24 ? (
          <div className="flex items-start gap-3 bg-orange-50 p-3 rounded-xl border border-orange-100 mb-5">
            <Info size={18} className="text-orange-600 shrink-0 mt-0.5" />
            <div className="text-sm text-orange-800 leading-relaxed">
              <strong>Info Obat Cacing:</strong> Belum masuk usia rekomendasi pemberian obat cacing menurut IDAI.
            </div>
          </div>
        ) : (
          <div className="flex items-start gap-3 bg-rose-50 p-3 rounded-xl border border-rose-100 mb-5">
            <Info size={18} className="text-rose-600 shrink-0 mt-0.5" />
            <div className="text-sm text-rose-800 leading-relaxed">
              <strong>Jadwal Suplementasi Obat Cacing:</strong> Anak berada di usia <strong>{formData.bulan_ke} bulan</strong>. Jadwalkan pemberian obat cacing dan catat statusnya di bawah.
            </div>
          </div>
        )}

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-5">
          {/* LEFT COLUMN */}
          <div className="space-y-4">
            <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm">
              <SectionTitle icon={Calendar} label="Waktu Kunjungan" />
              <FieldLabel>Bulan Kunjungan</FieldLabel>
              <Select
                value={formData.bulan_ke}
                onChange={(e) => {
                  const newBulan = parseInt(e.target.value);
                  setFormData(prev => ({
                    ...prev,
                    bulan_ke: newBulan,
                    mpasi: {
                      ...prev.mpasi,
                      sudah_mpasi: newBulan >= 6 ? prev.mpasi.sudah_mpasi : false
                    }
                  }));
                }}
              >
                {[...Array(60)].map((_, m) => (
                  <option key={m} value={m + 1}>Bulan {m + 1}</option>
                ))}
              </Select>
            </div>

            {parseInt(formData.bulan_ke) < 6 ? (
              <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm space-y-4">
                <SectionTitle icon={Droplets} label="Pola Pemberian ASI" />

                <div>
                  <FieldLabel>Jenis Pemberian Susu</FieldLabel>
                  <Select
                    value={formData.jenis_pemberian_susu}
                    onChange={(e) => {
                      const val = e.target.value;
                      setFormData(prev => ({
                        ...prev,
                        jenis_pemberian_susu: val,
                        menggunakan_formula: val === "ASI + Formula" || val === "Formula",
                        alasan_formula: (val === "ASI + Formula" || val === "Formula") ? prev.alasan_formula : ""
                      }));
                    }}
                  >
                    <option value="ASI Eksklusif">ASI Eksklusif</option>
                    <option value="ASI + Formula">ASI + Formula</option>
                    <option value="Formula">Formula</option>
                  </Select>
                </div>

                {(formData.jenis_pemberian_susu === "ASI + Formula" || formData.jenis_pemberian_susu === "Formula") && (
                  <div className="animate-in fade-in duration-200">
                    <FieldLabel>Alasan Pemberian Formula</FieldLabel>
                    <Select
                      value={formData.alasan_formula}
                      onChange={(e) => updateField('alasan_formula', e.target.value)}
                    >
                      <option value="">Pilih Alasan...</option>
                      <option value="Produksi ASI kurang">Produksi ASI kurang</option>
                      <option value="Ibu bekerja">Ibu bekerja</option>
                      <option value="Kondisi medis ibu">Kondisi medis ibu</option>
                      <option value="Bayi sulit menyusu">Bayi sulit menyusu</option>
                      <option value="Lainnya">Lainnya</option>
                    </Select>
                  </div>
                )}

                <div>
                  <FieldLabel>Frekuensi Menyusui (Kali/Hari)</FieldLabel>
                  <Input
                    type="number"
                    placeholder="Contoh: 8"
                    value={formData.asi.frekuensi_menyusui}
                    onChange={(e) => updateField('asi.frekuensi_menyusui', e.target.value)}
                  />
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <FieldLabel>Posisi Menyusu</FieldLabel>
                    <Select
                      value={formData.asi.posisi_menyusui}
                      onChange={(e) => updateField('asi.posisi_menyusui', e.target.value)}
                    >
                      <option value="baik">Sudah Baik</option>
                      <option value="tidak">Perlu Perbaikan</option>
                    </Select>
                  </div>
                  <div>
                    <FieldLabel>Menggunakan ASI Pembantu</FieldLabel>
                    <Select
                      value={formData.asi.asiperah}
                      onChange={(e) => updateField('asi.asiperah', e.target.value)}
                    >
                      <option value="tidak">Tidak</option>
                      <option value="ya">Ya</option>
                    </Select>
                  </div>
                </div>
              </div>
            ) : parseInt(formData.bulan_ke) < 24 ? (
              <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm space-y-4">
                <SectionTitle icon={Droplets} label="Pola Pemberian ASI & Susu" />

                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <FieldLabel>Masih Mendapat ASI?</FieldLabel>
                    <Select
                      value={formData.masih_menyusui ? "ya" : "tidak"}
                      onChange={(e) => updateField('masih_menyusui', e.target.value === "ya")}
                    >
                      <option value="ya">Ya</option>
                      <option value="tidak">Tidak</option>
                    </Select>
                  </div>
                  <div>
                    <FieldLabel>Jenis Pemberian Susu</FieldLabel>
                    <Select
                      value={formData.jenis_pemberian_susu}
                      onChange={(e) => {
                        const val = e.target.value;
                        setFormData(prev => ({
                          ...prev,
                          jenis_pemberian_susu: val,
                          menggunakan_formula: val === "ASI + Formula" || val === "Formula",
                          alasan_formula: (val === "ASI + Formula" || val === "Formula") ? prev.alasan_formula : ""
                        }));
                      }}
                    >
                      <option value="ASI">ASI</option>
                      <option value="ASI + Formula">ASI + Formula</option>
                      <option value="Formula">Formula</option>
                    </Select>
                  </div>
                </div>

                {(formData.jenis_pemberian_susu === "ASI + Formula" || formData.jenis_pemberian_susu === "Formula") && (
                  <div className="animate-in fade-in duration-200">
                    <FieldLabel>Alasan Pemberian Formula</FieldLabel>
                    <Select
                      value={formData.alasan_formula}
                      onChange={(e) => updateField('alasan_formula', e.target.value)}
                    >
                      <option value="">Pilih Alasan...</option>
                      <option value="Produksi ASI kurang">Produksi ASI kurang</option>
                      <option value="Ibu bekerja">Ibu bekerja</option>
                      <option value="Kondisi medis ibu">Kondisi medis ibu</option>
                      <option value="Bayi sulit menyusu">Bayi sulit menyusu</option>
                      <option value="Lainnya">Lainnya</option>
                    </Select>
                  </div>
                )}

                <div>
                  <FieldLabel>Frekuensi Menyusui (Kali/Hari)</FieldLabel>
                  <Input
                    type="number"
                    placeholder="Contoh: 8"
                    value={formData.asi.frekuensi_menyusui}
                    onChange={(e) => updateField('asi.frekuensi_menyusui', e.target.value)}
                  />
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <FieldLabel>Posisi Menyusu</FieldLabel>
                    <Select
                      value={formData.asi.posisi_menyusui}
                      onChange={(e) => updateField('asi.posisi_menyusui', e.target.value)}
                    >
                      <option value="baik">Sudah Baik</option>
                      <option value="tidak">Perlu Perbaikan</option>
                    </Select>
                  </div>
                  <div>
                    <FieldLabel>Gunakan ASI P?</FieldLabel>
                    <Select
                      value={formData.asi.asiperah}
                      onChange={(e) => updateField('asi.asiperah', e.target.value)}
                    >
                      <option value="tidak">Tidak</option>
                      <option value="ya">Ya</option>
                    </Select>
                  </div>
                </div>
              </div>
            ) : (
              <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm space-y-4">
                <SectionTitle icon={Droplets} label="Pola Menyusui" />
                <div>
                  <FieldLabel>Masih Menyusui?</FieldLabel>
                  <Select
                    value={formData.masih_menyusui ? "ya" : "tidak"}
                    onChange={(e) => updateField('masih_menyusui', e.target.value === "ya")}
                  >
                    <option value="ya">Ya</option>
                    <option value="tidak">Tidak</option>
                  </Select>
                </div>
              </div>
            )}

            {parseInt(formData.bulan_ke) >= 24 && (
              <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm space-y-3">
                <SectionTitle icon={Info} color="text-rose-500" label="Pemberian Obat Cacing" />
                <div className="flex justify-between items-center bg-slate-50 p-2.5 rounded-xl border border-slate-100">
                  <span className="text-xs font-semibold text-slate-600">Apakah obat cacing sudah diberikan?</span>
                  <div className="flex bg-slate-200/60 p-0.5 rounded-lg">
                    {[{ l: 'Sudah', v: true }, { l: 'Belum', v: false }].map(item => (
                      <button
                        key={item.l}
                        type="button"
                        onClick={() => updateField('obat_cacing', item.v)}
                        className={`px-3 py-1.5 text-[10px] font-bold rounded-md transition-all ${formData.obat_cacing === item.v ? 'bg-white text-blue-600 shadow-sm' : 'text-slate-500'}`}
                      >
                        {item.l.toUpperCase()}
                      </button>
                    ))}
                  </div>
                </div>
              </div>
            )}
          </div>

          {/* RIGHT COLUMN: MPASI */}
          <div className="space-y-4">
            {parseInt(formData.bulan_ke) < 6 ? (
              <div className="bg-slate-50 border border-slate-200 rounded-xl p-6 text-center">
                <div className="w-12 h-12 rounded-full bg-white border border-slate-200 flex items-center justify-center mx-auto mb-3">
                  <Utensils size={22} className="text-slate-400" />
                </div>
                <h4 className="text-sm font-bold text-slate-700 mb-1">MPASI Belum Tersedia</h4>
                <p className="text-xs text-slate-500 leading-relaxed max-w-xs mx-auto">
                  Status MPASI tidak tersedia untuk anak usia di bawah 6 bulan. Anak di fase ini hanya diperbolehkan mendapatkan ASI Eksklusif (atau susu formula jika ibu tidak dapat menghasilkan ASI).
                </p>
              </div>
            ) : (
              <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm space-y-4">
                <div className="flex items-center justify-between">
                  <SectionTitle icon={Utensils} color="text-orange-500" label="Status MPASI" />
                  <div className="flex bg-slate-100 p-0.5 rounded-lg">
                    {[{ l: 'Sudah', v: true }, { l: 'Belum', v: false }].map(item => (
                      <button
                        key={item.l}
                        type="button"
                        onClick={() => updateField('mpasi.sudah_mpasi', item.v)}
                        className={`px-3 py-1.5 text-[10px] font-bold rounded-md transition-all ${formData.mpasi.sudah_mpasi === item.v ? 'bg-white text-blue-600 shadow-sm' : 'text-slate-400'}`}
                      >
                        {item.l.toUpperCase()}
                      </button>
                    ))}
                  </div>
                </div>

                {parseInt(formData.bulan_ke) >= 12 && parseInt(formData.bulan_ke) <= 24 && (
                  <div className="p-3 bg-blue-50 border border-blue-100 rounded-xl flex items-start gap-2.5">
                    <Info size={16} className="text-blue-600 shrink-0 mt-0.5" />
                    <div className="text-xs text-blue-800 leading-relaxed">
                      <strong>Rekomendasi Usia 1-2 Tahun:</strong> Pada rentang usia 1-2 tahun (12-24 bulan), anak dapat diberikan makanan tambahan dengan proporsi nutrisi: <strong>ASI 30% dan MPASI 70%</strong>.
                    </div>
                  </div>
                )}

                {formData.mpasi.sudah_mpasi ? (
                  <div className="space-y-4 animate-in fade-in duration-200">
                    <div>
                      <FieldLabel>Usia Mulai MPASI (Bulan)</FieldLabel>
                      <Input
                        type="number"
                        placeholder="Contoh: 6"
                        value={formData.usia_mulai_mpasi}
                        onChange={(e) => updateField('usia_mulai_mpasi', e.target.value)}
                      />
                    </div>

                    <div>
                      <FieldLabel>Variasi Makanan</FieldLabel>
                      <div className="flex flex-wrap gap-2 mt-1">
                        {['Nasi', 'Sayur', 'Buah', 'Lauk Pauk', 'Lemak'].map(item => {
                          const selected = isSelected(item);
                          return (
                            <button
                              key={item}
                              type="button"
                              onClick={() => toggleVarian(item)}
                              className={`px-2.5 py-1.5 rounded-lg text-xs font-semibold border transition-all ${selected ? 'bg-orange-50 border-orange-200 text-orange-600' : 'bg-white border-slate-200 text-slate-500 hover:bg-slate-50'}`}
                            >
                              {selected ? '✓ ' : '+ '} {item}
                            </button>
                          );
                        })}
                      </div>
                    </div>

                    <div className="space-y-3">
                      <div>
                        <FieldLabel>Porsi per Makan</FieldLabel>
                        <Select
                          value={formData.mpasi.jumlah_makan}
                          onChange={(e) => updateField('mpasi.jumlah_makan', e.target.value)}
                        >
                          <option value="">Pilih Ukuran Porsi...</option>
                          <option value="2 - 3 sdm (1/2 mangkok ukuran 250 ml)">2 - 3 sdm (1/2 mangkok 250 ml)</option>
                          <option value="1/2 - 3/4 mangkok (ukuran 250 ml)">1/2 - 3/4 mangkok (250 ml)</option>
                          <option value="3/4 - 1 mangkok (ukuran 250 ml)">3/4 - 1 mangkok (250 ml)</option>
                          <option value="1 mangkok (ukuran 250 ml)">1 mangkok (250 ml)</option>
                        </Select>
                      </div>

                      <div className="grid grid-cols-2 gap-3">
                        <div>
                          <FieldLabel>Makanan Utama</FieldLabel>
                          <Select
                            value={formData.mpasi.frekuensi_makan.makanan_utama}
                            onChange={(e) => updateField('mpasi.frekuensi_makan.makanan_utama', e.target.value)}
                          >
                            <option value="">Frekuensi...</option>
                            <option value="1x/hari">1x / hari</option>
                            <option value="2x/hari">2x / hari</option>
                            <option value="3x/hari">3x / hari</option>
                          </Select>
                        </div>
                        <div>
                          <FieldLabel>Selingan</FieldLabel>
                          <Select
                            value={formData.mpasi.frekuensi_makan.makanan_selingan}
                            onChange={(e) => updateField('mpasi.frekuensi_makan.makanan_selingan', e.target.value)}
                          >
                            <option value="">Frekuensi...</option>
                            <option value="0x/hari">Tidak Ada</option>
                            <option value="1x/hari">1x / hari</option>
                            <option value="2x/hari">2x / hari</option>
                          </Select>
                        </div>
                      </div>
                    </div>
                  </div>
                ) : (
                  <div className="bg-slate-50 border border-slate-200 rounded-xl p-5 text-center">
                    <Utensils size={24} className="text-slate-300 mx-auto mb-2" />
                    <p className="text-xs font-semibold text-slate-400 italic">Belum waktunya atau belum diberikan MPASI</p>
                  </div>
                )}
              </div>
            )}
          </div>
        </div>

        {/* FOOTER BUTTONS */}
        <div className="mt-6 pt-5 border-t border-slate-100 flex flex-col-reverse sm:flex-row items-center justify-end gap-3">
          <button
            type="button"
            onClick={onCancel}
            className="w-full sm:w-auto px-6 py-2.5 text-slate-600 font-semibold text-sm hover:bg-slate-50 rounded-xl transition-all border border-slate-200"
          >
            Batal
          </button>
          <button
            type="button"
            onClick={handleSave}
            disabled={submitting}
            className="w-full sm:w-auto px-6 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-xl font-semibold text-sm shadow-md shadow-blue-100 transition-all flex items-center justify-center gap-2 disabled:opacity-50"
          >
            {submitting ? <Loader2 size={18} className="animate-spin" /> : <Save size={18} />}
            Simpan Data
          </button>
        </div>
      </section>
    </div>
  );
};

export default PelayananGiziForm;
