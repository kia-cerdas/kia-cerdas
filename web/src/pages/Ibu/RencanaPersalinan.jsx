// src/pages/Ibu/RencanaPersalinan.jsx
import React, { useEffect, useState, useCallback, useMemo } from "react";
import { useParams, useNavigate } from "react-router-dom";
import MainLayout from "../../components/Layout/MainLayout";
import { getKehamilanByIbuId } from "../../services/kehamilan";
import { getRencanaByKehamilanId, createRencana, updateRencana, deleteRencana } from "../../services/persalinan";
import { getCurrentUser, isDokterUser } from "../../services/auth";
import { getIbuById } from "../../services/ibu";
import { getDokterT3CompleteByKehamilanId } from "../../services/pemeriksaanDokter";
import {
  Save, CheckCircle, AlertCircle, ArrowLeft, Eye, Edit, Plus,
  ClipboardList, Trash2, FileDown, User, Calendar, Heart,
  Car, Droplets, ShieldCheck, Banknote, Lock
} from "lucide-react";
import Swal from "sweetalert2";

// ─── Helper: bangun alamat dari data kependudukan ─────────────────────────
function buildAlamat(kependudukan) {
  if (!kependudukan) return "";
  const parts = [];
  if (kependudukan.dusun) parts.push(`Dusun ${kependudukan.dusun}`);
  if (kependudukan.kecamatan) parts.push(`Kec. ${kependudukan.kecamatan}`);
  return parts.join(", ");
}

// ─── Helper: generate available months based on T3 date (moved outside component) ───────────
function generateAvailableMonths(t3Tanggal) {
  if (!t3Tanggal) return [];

  const monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  const availableMonths = [];
  const t3Month = t3Tanggal.getMonth();
  const t3Year = t3Tanggal.getFullYear();

  // Generate months from T3 month to T3 month + 3 (max 4 months total)
  for (let i = 0; i <= 3; i++) {
    const monthIndex = (t3Month + i) % 12;
    const yearOffset = Math.floor((t3Month + i) / 12);
    const year = t3Year + yearOffset;
    
    availableMonths.push({
      name: monthNames[monthIndex],
      value: monthNames[monthIndex],
      year: year
    });
  }

  return availableMonths;
}

// ─── Helper: get available years based on T3 date (moved outside component) ────────────────
function generateAvailableYears(t3Tanggal) {
  if (!t3Tanggal) return [];

  const availableMonths = generateAvailableMonths(t3Tanggal);
  const years = [...new Set(availableMonths.map(m => m.year))];
  
  return years.sort((a, b) => a - b);
}

// ─── Helper: export ke DOCX ────────────────────────────────────────────────
async function exportToDocx(data) {
  const {
    Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell,
    AlignmentType, BorderStyle, WidthType, ShadingType,
  } = await import("docx");

  const noBorder = { style: BorderStyle.NONE, size: 0, color: "FFFFFF" };
  const noBorders = { top: noBorder, bottom: noBorder, left: noBorder, right: noBorder };
  const bottomBorder = { style: BorderStyle.SINGLE, size: 6, color: "000000" };

  const val = (v) => (v == null ? "" : String(v));

  const tanggal = data.tanggal_pernyataan
    ? new Date(data.tanggal_pernyataan).toLocaleDateString("id-ID", {
        day: "2-digit", month: "long", year: "numeric",
      })
    : "";

  const makeRow = (label, value, labelWidth = 2200, valueWidth = 7438) =>
    new TableRow({
      children: [
        new TableCell({
          borders: noBorders,
          width: { size: labelWidth, type: WidthType.DXA },
          children: [new Paragraph({ children: [new TextRun({ text: label, size: 20 })] })],
        }),
        new TableCell({
          borders: { ...noBorders, bottom: bottomBorder },
          width: { size: valueWidth, type: WidthType.DXA },
          children: [new Paragraph({ children: [new TextRun({ text: val(value), size: 20 })] })],
        }),
      ],
    });

  const makeDoubleRow = (label1, v1, label2, v2) =>
    new TableRow({
      children: [
        new TableCell({ borders: noBorders, width: { size: 1400, type: WidthType.DXA }, children: [new Paragraph({ children: [new TextRun({ text: label1, size: 20 })] })] }),
        new TableCell({ borders: { ...noBorders, bottom: bottomBorder }, width: { size: 2880, type: WidthType.DXA }, children: [new Paragraph({ children: [new TextRun({ text: val(v1), size: 20 })] })] }),
        new TableCell({ borders: noBorders, width: { size: 1600, type: WidthType.DXA }, children: [new Paragraph({ children: [new TextRun({ text: label2, size: 20 })] })] }),
        new TableCell({ borders: { ...noBorders, bottom: bottomBorder }, width: { size: 3758, type: WidthType.DXA }, children: [new Paragraph({ children: [new TextRun({ text: val(v2), size: 20 })] })] }),
      ],
    });

  const makeNameHPRow = (prefix, nama, hp) =>
    new TableRow({
      children: [
        new TableCell({ borders: noBorders, width: { size: 400, type: WidthType.DXA }, children: [new Paragraph({ children: [new TextRun({ text: prefix, size: 20 })] })] }),
        new TableCell({ borders: { ...noBorders, bottom: bottomBorder }, width: { size: 3880, type: WidthType.DXA }, children: [new Paragraph({ children: [new TextRun({ text: val(nama), size: 20 })] })] }),
        new TableCell({ borders: noBorders, width: { size: 600, type: WidthType.DXA }, children: [new Paragraph({ children: [new TextRun({ text: "HP", size: 20 })] })] }),
        new TableCell({ borders: { ...noBorders, bottom: bottomBorder }, width: { size: 4758, type: WidthType.DXA }, children: [new Paragraph({ children: [new TextRun({ text: val(hp), size: 20 })] })] }),
      ],
    });

  const greenShading = { fill: "2E8B57", type: ShadingType.CLEAR };
  const greenBorder = { style: BorderStyle.SINGLE, size: 1, color: "2E8B57" };
  const greenBorders = { top: greenBorder, bottom: greenBorder, left: greenBorder, right: greenBorder };

  const ttdSpaceRow = new TableRow({
    height: { value: 1440, rule: "exact" },
    children: [
      new TableCell({ borders: noBorders, width: { size: 3120, type: WidthType.DXA }, children: [new Paragraph({})] }),
      new TableCell({ borders: noBorders, width: { size: 3120, type: WidthType.DXA }, children: [new Paragraph({})] }),
      new TableCell({ borders: noBorders, width: { size: 3398, type: WidthType.DXA }, children: [new Paragraph({})] }),
    ],
  });

  const doc = new Document({
    sections: [{
      properties: {
        page: {
          size: { width: 11906, height: 16838 },
          margin: { top: 1134, right: 1134, bottom: 1134, left: 1134 },
        },
      },
      children: [
        new Paragraph({
          alignment: AlignmentType.CENTER,
          spacing: { after: 100 },
          children: [new TextRun({ text: "RENCANA PERSALINAN", bold: true, size: 28, font: "Arial" })],
        }),
        new Paragraph({ spacing: { after: 160 } }),

        new Table({
          width: { size: 9638, type: WidthType.DXA },
          columnWidths: [2200, 7438],
          rows: [
            makeRow("Saya", data.nama_ibu_pernyataan, 2200, 7438),
            makeRow("Alamat", data.alamat_ibu_pernyataan, 2200, 7438),
          ],
        }),

        new Paragraph({ spacing: { after: 100 } }),
        new Paragraph({
          spacing: { after: 80 },
          children: [new TextRun({
            text: `Memberikan kepercayaan kepada nama-nama ini untuk membantu proses melahirkan saya agar aman dan selamat, yang diperkirakan pada, Bulan: ${val(data.perkiraan_bulan_persalinan)}    Tahun: ${val(data.perkiraan_tahun_persalinan)}`,
            size: 20, font: "Arial",
          })],
        }),
        new Paragraph({ spacing: { after: 120 } }),

        new Table({
          width: { size: 9638, type: WidthType.DXA },
          columnWidths: [9638],
          rows: [
            new TableRow({
              children: [
                new TableCell({
                  borders: greenBorders, shading: greenShading,
                  margins: { top: 60, bottom: 60, left: 120, right: 120 },
                  width: { size: 9638, type: WidthType.DXA },
                  children: [new Paragraph({ children: [new TextRun({ text: "Diisi oleh Tenaga Kesehatan", bold: true, color: "FFFFFF", size: 20, font: "Arial" })] })],
                }),
              ],
            }),
          ],
        }),

        new Paragraph({ spacing: { after: 80 } }),
        new Paragraph({ spacing: { after: 60 }, children: [new TextRun({ text: "Fasyankes proses melahirkan:", size: 20, font: "Arial" })] }),

        new Table({
          width: { size: 9638, type: WidthType.DXA },
          columnWidths: [1400, 2880, 1600, 3758],
          rows: [
            makeDoubleRow("1. Bidan/dokter", data.fasyankes_1_nama_tenaga, "Nama Fasyankes", data.fasyankes_1_nama_fasilitas),
            makeDoubleRow("2. Bidan/dokter", data.fasyankes_2_nama_tenaga, "Nama Fasyankes", data.fasyankes_2_nama_fasilitas),
          ],
        }),

        new Paragraph({ spacing: { after: 100 } }),
        new Paragraph({ spacing: { after: 100 }, children: [new TextRun({ text: `Untuk dana proses melahirkan akan menggunakan ${val(data.sumber_dana_persalinan)}`, size: 20, font: "Arial" })] }),
        new Paragraph({ spacing: { after: 60 }, children: [new TextRun({ text: "Untuk kendaraan/ambulan desa oleh:", size: 20, font: "Arial" })] }),

        new Table({
          width: { size: 9638, type: WidthType.DXA },
          columnWidths: [400, 3880, 600, 4758],
          rows: [
            makeNameHPRow("1.", data.kendaraan_1_nama, data.kendaraan_1_hp),
            makeNameHPRow("2.", data.kendaraan_2_nama, data.kendaraan_2_hp),
            makeNameHPRow("3.", data.kendaraan_3_nama, data.kendaraan_3_hp),
          ],
        }),

        new Paragraph({ spacing: { after: 100 } }),
        new Paragraph({ spacing: { after: 100 }, children: [new TextRun({ text: `Metode kontrasepsi setelah melahirkan yang dipilih: ${val(data.metode_kontrasepsi_pilihan)}`, size: 20, font: "Arial" })] }),

        new Paragraph({ spacing: { after: 60 }, children: [new TextRun({ text: `Untuk sumbangan darah (golongan darah)  ${val(data.donor_golongan_darah)}  Rhesus  ${val(data.donor_rhesus)}  Dibantu oleh:`, size: 20, font: "Arial" })] }),

        new Table({
          width: { size: 9638, type: WidthType.DXA },
          columnWidths: [400, 3880, 600, 4758],
          rows: [
            makeNameHPRow("1.", data.donor_1_nama, data.donor_1_hp),
            makeNameHPRow("2.", data.donor_2_nama, data.donor_2_hp),
            makeNameHPRow("3.", data.donor_3_nama, data.donor_3_hp),
            makeNameHPRow("4.", data.donor_4_nama, data.donor_4_hp),
          ],
        }),

        new Paragraph({ spacing: { after: 400 } }),
        new Paragraph({ spacing: { after: 200 }, children: [new TextRun({ text: `                                    Tanggal  ${tanggal}`, size: 20, font: "Arial" })] }),

        new Table({
          width: { size: 9638, type: WidthType.DXA },
          columnWidths: [3120, 3120, 3398],
          rows: [
            new TableRow({
              children: [
                new TableCell({ borders: noBorders, width: { size: 3120, type: WidthType.DXA }, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "Persetujuan Suami/", size: 20 })] })] }),
                new TableCell({ borders: noBorders, width: { size: 3120, type: WidthType.DXA }, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "Persetujuan Ibu Hamil", size: 20 })] })] }),
                new TableCell({ borders: noBorders, width: { size: 3398, type: WidthType.DXA }, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "Bidan/Dokter", size: 20 })] })] }),
              ],
            }),
            new TableRow({
              children: [
                new TableCell({ borders: noBorders, width: { size: 3120, type: WidthType.DXA }, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "Orang Tua/Keluarga", size: 20 })] })] }),
                new TableCell({ borders: noBorders, width: { size: 3120, type: WidthType.DXA }, children: [new Paragraph({})] }),
                new TableCell({ borders: noBorders, width: { size: 3398, type: WidthType.DXA }, children: [new Paragraph({})] }),
              ],
            }),
            ttdSpaceRow,
          ],
        }),

        new Table({
          width: { size: 9638, type: WidthType.DXA },
          columnWidths: [3120, 360, 2760, 360, 3038],
          rows: [
            new TableRow({
              children: [
                new TableCell({ borders: { ...noBorders, bottom: bottomBorder }, width: { size: 3120, type: WidthType.DXA }, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: `( ${val(data.nama_suami_keluarga_ttd)} )`, size: 20 })] })] }),
                new TableCell({ borders: noBorders, width: { size: 360, type: WidthType.DXA }, children: [new Paragraph({})] }),
                new TableCell({ borders: { ...noBorders, bottom: bottomBorder }, width: { size: 2760, type: WidthType.DXA }, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: `( ${val(data.nama_ibu_hamil_ttd)} )`, size: 20 })] })] }),
                new TableCell({ borders: noBorders, width: { size: 360, type: WidthType.DXA }, children: [new Paragraph({})] }),
                new TableCell({ borders: { ...noBorders, bottom: bottomBorder }, width: { size: 3038, type: WidthType.DXA }, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: `( ${val(data.nama_bidan_dokter_ttd)} )`, size: 20 })] })] }),
              ],
            }),
          ],
        }),
      ],
    }],
  });

  return Packer.toBlob(doc);
}

function downloadBlob(blob, filename) {
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = filename;
  a.click();
  URL.revokeObjectURL(url);
}

// ─── Komponen UI kecil ────────────────────────────────────────────────────
const Badge = ({ children, color = "primary" }) => {
  const colors = {
    primary: "bg-[#185FA5]/10 text-[#185FA5]",
    success: "bg-[#3B6D11]/10 text-[#3B6D11]",
    warning: "bg-[#BA7517]/10 text-[#BA7517]",
    danger: "bg-[#A32D2D]/10 text-[#A32D2D]",
    secondary: "bg-[#0F6E56]/10 text-[#0F6E56]",
    gray: "bg-gray-100 text-gray-600",
  };
  return (
    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-semibold font-sans ${colors[color] || colors.primary}`}>
      {children}
    </span>
  );
};

const InfoItem = ({ label, value, className = "" }) => (
  <div className={`flex flex-col gap-0.5 ${className}`}>
    <span className="text-xs text-gray-500 font-medium uppercase tracking-wide font-sans">{label}</span>
    <span className="text-sm text-gray-800 font-semibold mt-0.5 font-sans">{value || <span className="text-gray-400 italic">—</span>}</span>
  </div>
);

const SectionCard = ({ icon: Icon, title, iconColor = "text-[#185FA5]", bgColor = "bg-[#185FA5]/10", children }) => (
  <div className="bg-white rounded-xl shadow-sm overflow-hidden border border-gray-100 font-sans">
    <div className={`flex items-center gap-3 px-5 py-3 ${bgColor}`}>
      {Icon && <Icon size={18} className={iconColor} />}
      <h4 className="text-lg font-semibold text-gray-800 font-sans">{title}</h4>
    </div>
    <div className="px-5 py-4">{children}</div>
  </div>
);

// Field yang dikunci otomatis dari data ibu — tampil abu-abu dengan ikon gembok
const LockedField = ({ label, value }) => (
  <div className="flex flex-col gap-1">
    <label className="flex items-center gap-1 text-sm font-semibold text-gray-500 font-sans">
      {label}
      <Lock size={11} className="text-gray-400" />
    </label>
    <div className="w-full border border-gray-200 rounded-lg px-4 py-2 bg-gray-50 text-gray-600 text-sm select-none font-sans">
      {value || <span className="italic text-gray-400">—</span>}
    </div>
    <p className="text-xs text-gray-400 font-sans">Diambil otomatis dari data ibu</p>
  </div>
);

// ─── FormView Component (moved outside to prevent remounting) ─────────────────────────────
const FormView = React.memo(({ 
  form, handleChange, canEdit, autoNamaIbu, autoAlamat, autoNamaSuami, autoGolDarah, 
  availableMonths, availableYears, t3Tanggal, handleSubmit, saving, existingRencana, setIsEditing 
}) => {
  // Use refs to track which input is focused to prevent focus loss
  const focusedInputRef = React.useRef(null);
  
  return (
  <form onSubmit={handleSubmit} className="bg-white rounded-xl shadow-sm p-8 space-y-8 border border-gray-100 font-sans">

    {/* ── Informasi auto-fill (banner) ── */}
    <div className="flex items-start gap-3 p-4 bg-[#185FA5]/10 border border-[#185FA5]/20 rounded-xl font-sans">
      <Lock size={16} className="text-[#185FA5] mt-0.5 shrink-0" />
      <div>
        <p className="text-sm font-semibold text-[#185FA5] font-sans">Data Ibu Diambil Otomatis</p>
        <p className="text-xs text-[#185FA5]/80 mt-0.5 font-sans">
          Nama ibu, alamat, nama suami, dan golongan darah diisi otomatis dari data yang sudah ada. Field tersebut tidak perlu diisi ulang.
        </p>
      </div>
    </div>

    {/* ── Data Diri (readonly preview) ── */}
    <div className="border-b pb-6">
      <h3 className="text-base font-bold text-gray-800 mb-4 flex items-center gap-2 font-sans">
        <User size={16} className="text-[#185FA5]" /> Data Diri Ibu
      </h3>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
        <LockedField label="Nama Ibu (Saya)" value={autoNamaIbu} />
        <LockedField label="Alamat" value={autoAlamat} />
        <LockedField label="Persetujuan Ibu Hamil (TTD)" value={autoNamaIbu} />
        <LockedField label="Persetujuan Ayah/Keluarga (TTD)" value={autoNamaSuami || "Belum ada data suami"} />
      </div>
      <div className="mt-4 p-3 bg-gray-50 rounded-lg italic text-gray-600 text-sm font-sans">
        Memberikan kepercayaan kepada nama-nama ini untuk membantu proses melahirkan saya agar aman dan selamat, yang diperkirakan pada,
        <div className="flex flex-wrap gap-4 mt-2 not-italic">
          <div className="flex items-center gap-2">
            <span className="font-sans">Bulan:</span>
            <select
              name="perkiraan_bulan_persalinan"
              value={form.perkiraan_bulan_persalinan}
              onChange={handleChange}
              disabled={!canEdit}
              className="border rounded-lg px-3 py-2 w-40 bg-white border-gray-300 focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5] font-sans"
            >
              <option value="">Pilih Bulan</option>
              {availableMonths.map((month) => (
                <option key={month.value} value={month.value}>
                  {month.name}
                </option>
              ))}
            </select>
          </div>
          <div className="flex items-center gap-2">
            <span className="font-sans">Tahun:</span>
            <select
              name="perkiraan_tahun_persalinan"
              value={form.perkiraan_tahun_persalinan}
              onChange={handleChange}
              disabled={!canEdit}
              className="border rounded-lg px-3 py-2 w-32 bg-white border-gray-300 focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5] font-sans"
            >
              <option value="">Pilih Tahun</option>
              {availableYears.map((year) => (
                <option key={year} value={year}>
                  {year}
                </option>
              ))}
            </select>
          </div>
        </div>
        {t3Tanggal && (
          <p className="text-xs text-[#185FA5] mt-2 font-sans">
            ℹ️ Berdasarkan data Trimester 3 (dicatat pada {t3Tanggal.toLocaleDateString('id-ID', { month: 'long', year: 'numeric' })}), perkiraan persalinan hanya dapat dipilih hingga 3 bulan ke depan.
          </p>
        )}
        {!t3Tanggal && (
          <p className="text-xs text-[#BA7517] mt-2 font-sans">
            ⚠️ Data Trimester 3 belum tersedia. Dropdown akan muncul setelah data T3 dicatat.
          </p>
        )}
      </div>
    </div>

    {/* ── Tenaga Kesehatan ── */}
    <div className="border-b pb-6">
      <h3 className="text-base font-bold text-gray-800 mb-4 flex items-center gap-2 font-sans">
        <ShieldCheck size={16} className="text-[#0F6E56]" /> Diisi oleh Tenaga Kesehatan
      </h3>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
        <div>
          <label className="block text-sm font-semibold text-gray-700 mb-1 font-sans">Bidan/Dokter 1</label>
          <input name="fasyankes_1_nama_tenaga" value={form.fasyankes_1_nama_tenaga} onChange={handleChange} disabled={!canEdit} className="w-full border rounded-lg px-4 py-2 border-gray-300 focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5] font-sans" placeholder="Nama tenaga kesehatan" />
        </div>
        <div>
          <label className="block text-sm font-semibold text-gray-700 mb-1 font-sans">Nama Fasilitas Kesehatan 1</label>
          <input name="fasyankes_1_nama_fasilitas" value={form.fasyankes_1_nama_fasilitas} onChange={handleChange} disabled={!canEdit} className="w-full border rounded-lg px-4 py-2 border-gray-300 focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5] font-sans" placeholder="Puskesmas, Klinik, RS" />
        </div>
        <div>
          <label className="block text-sm font-semibold text-gray-700 mb-1 font-sans">Bidan/Dokter 2</label>
          <input name="fasyankes_2_nama_tenaga" value={form.fasyankes_2_nama_tenaga} onChange={handleChange} disabled={!canEdit} className="w-full border rounded-lg px-4 py-2 border-gray-300 focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5] font-sans" placeholder="Nama tenaga kesehatan" />
        </div>
        <div>
          <label className="block text-sm font-semibold text-gray-700 mb-1 font-sans">Nama Fasilitas Kesehatan 2</label>
          <input name="fasyankes_2_nama_fasilitas" value={form.fasyankes_2_nama_fasilitas} onChange={handleChange} disabled={!canEdit} className="w-full border rounded-lg px-4 py-2 border-gray-300 focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5] font-sans" placeholder="Puskesmas, Klinik, RS" />
        </div>
      </div>
      <div className="mt-4">
        <label className="block text-sm font-semibold text-gray-700 mb-1 font-sans">Sumber Dana Persalinan</label>
        <select name="sumber_dana_persalinan" value={form.sumber_dana_persalinan} onChange={handleChange} disabled={!canEdit} className="w-full md:w-64 border rounded-lg px-4 py-2 border-gray-300 focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5] font-sans">
          <option>JKN/BPJS</option>
          <option>Jamkesda</option>
          <option>Asuransi Swasta</option>
          <option>Biaya sendiri</option>
          <option>Lainnya</option>
        </select>
      </div>
    </div>

    {/* ── Kendaraan ── */}
    <div className="border-b pb-6">
      <h3 className="text-base font-bold text-gray-800 mb-3 flex items-center gap-2 font-sans">
        <Car size={16} className="text-[#BA7517]" /> Untuk kendaraan/ambulan desa oleh:
      </h3>
      {[1, 2, 3].map((idx) => (
        <div key={idx} className="grid grid-cols-2 gap-4 mb-3">
          <input name={`kendaraan_${idx}_nama`} value={form[`kendaraan_${idx}_nama`]} onChange={handleChange} disabled={!canEdit} className="border rounded-lg px-4 py-2 border-gray-300 focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5] font-sans" placeholder={`Nama ${idx}`} />
          <input name={`kendaraan_${idx}_hp`}   value={form[`kendaraan_${idx}_hp`]}   onChange={handleChange} disabled={!canEdit} className="border rounded-lg px-4 py-2 border-gray-300 focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5] font-sans" placeholder={`No. HP ${idx}`} />
        </div>
      ))}
    </div>

    {/* ── Kontrasepsi ── */}
    <div className="border-b pb-6">
      <label className="flex items-center gap-2 text-sm font-bold text-gray-800 mb-2 font-sans">
        <Heart size={15} className="text-[#A32D2D]" /> Metode kontrasepsi setelah melahirkan yang dipilih:
      </label>
      <input name="metode_kontrasepsi_pilihan" value={form.metode_kontrasepsi_pilihan} onChange={handleChange} disabled={!canEdit} className="w-full md:w-96 border rounded-lg px-4 py-2 border-gray-300 focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5] font-sans" placeholder="Contoh: IUD, Implan, Suntik, Pil" />
    </div>

    {/* ── Donor Darah ── */}
    <div className="border-b pb-6">
      <h3 className="text-base font-bold text-gray-800 mb-3 flex items-center gap-2 font-sans">
        <Droplets size={16} className="text-[#A32D2D]" /> Untuk sumbangan darah
      </h3>
      <div className="flex flex-wrap gap-4 mb-4">
        {/* Golongan darah — readonly dari data ibu */}
        <div className="flex flex-col gap-1">
          <label className="flex items-center gap-1 text-sm font-semibold text-gray-500 font-sans">
            Golongan darah <Lock size={11} className="text-gray-400" />
          </label>
          <div className="border border-gray-200 rounded px-3 py-1.5 w-28 bg-gray-50 text-gray-600 text-sm font-sans">
            {autoGolDarah || <span className="italic text-gray-400">—</span>}
          </div>
          <p className="text-xs text-gray-400 font-sans">Dari data ibu</p>
        </div>
        {/* Rhesus — bisa diisi manual */}
        <div className="flex flex-col gap-1">
          <label className="block text-sm font-semibold text-gray-700 font-sans">Rhesus</label>
          <input name="donor_rhesus" value={form.donor_rhesus} onChange={handleChange} disabled={!canEdit} className="border rounded px-3 py-1.5 w-28 border-gray-300 focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5] font-sans" placeholder="+/−" />
        </div>
      </div>
      <p className="text-sm font-semibold text-gray-600 mb-2 font-sans">Dibantu oleh:</p>
      {[1, 2, 3, 4].map((idx) => (
        <div key={idx} className="grid grid-cols-2 gap-4 mb-2">
          <input name={`donor_${idx}_nama`} value={form[`donor_${idx}_nama`]} onChange={handleChange} disabled={!canEdit} className="border rounded-lg px-4 py-2 border-gray-300 focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5] font-sans" placeholder={`Nama pendamping ${idx}`} />
          <input name={`donor_${idx}_hp`}   value={form[`donor_${idx}_hp`]}   onChange={handleChange} disabled={!canEdit} className="border rounded-lg px-4 py-2 border-gray-300 focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5] font-sans" placeholder={`No. HP ${idx}`} />
        </div>
      ))}
    </div>

    {/* ── Tanggal & Persetujuan ── */}
    <div>
      <h3 className="text-base font-bold text-gray-800 mb-4 flex items-center gap-2 font-sans">
        <Calendar size={16} className="text-[#185FA5]" /> Tanggal & Persetujuan
      </h3>
      <div className="mb-5">
        <label className="block text-sm font-semibold text-gray-700 mb-1 font-sans">Tanggal</label>
        <input type="date" name="tanggal_pernyataan" value={form.tanggal_pernyataan} onChange={handleChange} disabled={!canEdit} className="border rounded-lg px-4 py-2 w-56 border-gray-300 focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5] font-sans" />
      </div>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
        {/* Suami — readonly */}
        <div>
          <label className="flex items-center gap-1 text-sm font-semibold text-gray-500 mb-1 font-sans">
            Persetujuan Ayah/Orang Tua/Keluarga <Lock size={11} className="text-gray-400" />
          </label>
          <div className="w-full border border-gray-200 rounded px-3 py-2 bg-gray-50 text-gray-600 text-sm font-sans">
            {autoNamaSuami || <span className="italic text-gray-400">Belum ada data suami</span>}
          </div>
          <p className="text-xs text-gray-400 mt-1 font-sans">Dari data ibu</p>
        </div>
        {/* Ibu hamil — readonly */}
        <div>
          <label className="flex items-center gap-1 text-sm font-semibold text-gray-500 mb-1 font-sans">
            Persetujuan Ibu Hamil <Lock size={11} className="text-gray-400" />
          </label>
          <div className="w-full border border-gray-200 rounded px-3 py-2 bg-gray-50 text-gray-600 text-sm font-sans">
            {autoNamaIbu || <span className="italic text-gray-400">—</span>}
          </div>
          <p className="text-xs text-gray-400 mt-1 font-sans">Dari data ibu</p>
        </div>
        {/* Bidan/Dokter — bisa diisi */}
        <div>
          <label className="block text-sm font-semibold text-gray-700 mb-1 font-sans">Bidan/Dokter</label>
          <input name="nama_bidan_dokter_ttd" value={form.nama_bidan_dokter_ttd} onChange={handleChange} disabled={!canEdit} className="w-full border rounded px-3 py-2 border-gray-300 focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5] font-sans" placeholder="Nama tenaga kesehatan" />
        </div>
      </div>
    </div>

    {canEdit && (
      <div className="flex gap-4 justify-end pt-6 border-t mt-4">
        <button type="button" onClick={() => setIsEditing(false)} className="px-6 py-2.5 rounded-full border border-[#185FA5] text-[#185FA5] font-semibold text-base hover:bg-[#185FA5]/5 transition font-sans">
          Batal
        </button>
        <button type="submit" disabled={saving} className="px-6 py-2.5 rounded-full bg-[#3B6D11] text-white font-semibold flex items-center gap-2 text-base hover:opacity-90 disabled:opacity-50 transition font-sans">
          <Save size={18} />
          {saving ? "Menyimpan..." : "Simpan"}
        </button>
      </div>
    )}
  </form>
  );
});

// ─── Komponen utama ───────────────────────────────────────────────────────
export default function RencanaPersalinan() {
  const { id } = useParams(); // id ibu
  const navigate = useNavigate();

  const user = getCurrentUser();
  const isDokter = isDokterUser(user);
  const canEdit = !isDokter;

  const [kehamilan, setKehamilan]         = useState(null);
  const [ibuData, setIbuData]             = useState(null); // data ibu lengkap (dengan kependudukan & suami)
  const [existingRencana, setExistingRencana] = useState(null);
  const [loading, setLoading]             = useState(true);
  const [saving, setSaving]               = useState(false);
  const [exporting, setExporting]         = useState(false);
  const [isEditing, setIsEditing]         = useState(false);
  const [successMessage, setSuccessMessage] = useState("");
  const [errorMessage, setErrorMessage]   = useState("");
  const [t3Complete, setT3Complete]       = useState(false); // VALIDASI: Cek kelengkapan T3
  const [t3Tanggal, setT3Tanggal]         = useState(null); // VALIDASI: Simpan tanggal pencatatan T3

  // ── Form state ──────────────────────────────────────────────────────────
  // Field otomatis (dari data ibu) — tidak bisa diedit pengguna
  // Field manual — bisa diedit pengguna
  const emptyForm = {
    perkiraan_bulan_persalinan: "",
    perkiraan_tahun_persalinan: "",
    fasyankes_1_nama_tenaga: "",
    fasyankes_1_nama_fasilitas: "",
    fasyankes_2_nama_tenaga: "",
    fasyankes_2_nama_fasilitas: "",
    sumber_dana_persalinan: "JKN/BPJS",
    kendaraan_1_nama: "",
    kendaraan_1_hp: "",
    kendaraan_2_nama: "",
    kendaraan_2_hp: "",
    kendaraan_3_nama: "",
    kendaraan_3_hp: "",
    metode_kontrasepsi_pilihan: "",
    donor_rhesus: "",
    donor_1_nama: "",
    donor_1_hp: "",
    donor_2_nama: "",
    donor_2_hp: "",
    donor_3_nama: "",
    donor_3_hp: "",
    donor_4_nama: "",
    donor_4_hp: "",
    tanggal_pernyataan: "",
    nama_bidan_dokter_ttd: "",
  };

  // Isi otomatis field Bidan/Dokter dengan nama user yang sedang login
  const currentUserName = user?.nama || user?.name || "";
  const initialForm = { ...emptyForm, nama_bidan_dokter_ttd: currentUserName };

  const [form, setForm] = useState(initialForm);
  const formRef = React.useRef(form);
  React.useEffect(() => {
    formRef.current = form;
  }, [form]);

  // ── Derive auto-filled values dari ibuData ──────────────────────────────
  // Nilai-nilai ini SELALU diambil dari data ibu (tidak dari form state)
  const autoNamaIbu     = ibuData?.kependudukan?.nama_anggota_keluarga || "";
  const autoAlamat      = ibuData ? buildAlamat(ibuData.kependudukan) : "";
  const autoNamaSuami   = ibuData?.suami?.nama_anggota_keluarga || "";
  const autoGolDarah    = ibuData?.kependudukan?.golongan_darah || "";

  // ── mapDataToForm — hanya field manual ──────────────────────────────────
  const mapDataToForm = useCallback((data) => ({
    perkiraan_bulan_persalinan: data.perkiraan_bulan_persalinan || "",
    perkiraan_tahun_persalinan: data.perkiraan_tahun_persalinan || "",
    fasyankes_1_nama_tenaga:    data.fasyankes_1_nama_tenaga || "",
    fasyankes_1_nama_fasilitas: data.fasyankes_1_nama_fasilitas || "",
    fasyankes_2_nama_tenaga:    data.fasyankes_2_nama_tenaga || "",
    fasyankes_2_nama_fasilitas: data.fasyankes_2_nama_fasilitas || "",
    sumber_dana_persalinan:     data.sumber_dana_persalinan || "JKN/BPJS",
    kendaraan_1_nama:           data.kendaraan_1_nama || "",
    kendaraan_1_hp:             data.kendaraan_1_hp || "",
    kendaraan_2_nama:           data.kendaraan_2_nama || "",
    kendaraan_2_hp:             data.kendaraan_2_hp || "",
    kendaraan_3_nama:           data.kendaraan_3_nama || "",
    kendaraan_3_hp:             data.kendaraan_3_hp || "",
    metode_kontrasepsi_pilihan: data.metode_kontrasepsi_pilihan || "",
    donor_rhesus:               data.donor_rhesus || "",
    donor_1_nama:               data.donor_1_nama || "",
    donor_1_hp:                 data.donor_1_hp || "",
    donor_2_nama:               data.donor_2_nama || "",
    donor_2_hp:                 data.donor_2_hp || "",
    donor_3_nama:               data.donor_3_nama || "",
    donor_3_hp:                 data.donor_3_hp || "",
    donor_4_nama:               data.donor_4_nama || "",
    donor_4_hp:                 data.donor_4_hp || "",
    tanggal_pernyataan:         data.tanggal_pernyataan
      ? data.tanggal_pernyataan.substring(0, 10)
      : "",
    nama_bidan_dokter_ttd:      currentUserName,
  }), [currentUserName]);

  // ── Fetch data saat mount ────────────────────────────────────────────────
  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);

        // 1. Data kehamilan
        const kehamilanList = await getKehamilanByIbuId(id);
        if (!kehamilanList || kehamilanList.length === 0) {
          setErrorMessage("Data kehamilan tidak ditemukan untuk ibu ini.");
          setLoading(false);
          return;
        }
        const aktif = kehamilanList[0];
        setKehamilan(aktif);

        // 2. VALIDASI: Cek kelengkapan data Trimester 3
        try {
          const t3Data = await getDokterT3CompleteByKehamilanId(aktif.id);
          // Cek apakah data T3 ada dan lengkap (minimal field wajib terisi)
          if (t3Data && t3Data.dokter && t3Data.dokter.tanggal_periksa) {
            setT3Complete(true);
            setT3Tanggal(new Date(t3Data.dokter.tanggal_periksa));
          } else {
            setT3Complete(false);
            setT3Tanggal(null);
          }
        } catch (t3Err) {
          console.warn("Gagal mengecek data T3:", t3Err);
          setT3Complete(false);
          setT3Tanggal(null);
        }

        // 3. Data ibu (untuk auto-fill)
        try {
          const ibu = await getIbuById(id);
          setIbuData(ibu);
        } catch (ibuErr) {
          console.warn("Gagal memuat data ibu:", ibuErr);
        }

        // 4. Data rencana persalinan
        const rencanaData = await getRencanaByKehamilanId(aktif.id);
        if (rencanaData && rencanaData.length > 0) {
          const data = rencanaData[0];
          setExistingRencana(data);
          setForm(mapDataToForm(data));
        } else {
          setExistingRencana(null);
          setForm(initialForm);
        }

        setIsEditing(false);
      } catch (err) {
        console.error(err);
        setErrorMessage("Gagal memuat data. " + (err.response?.data?.message || err.message));
      } finally {
        setLoading(false);
      }
    };
    fetchData();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [id]);

  // Memoize available months and years to prevent recalculation
  const availableMonths = useMemo(() => generateAvailableMonths(t3Tanggal), [t3Tanggal]);
  const availableYears = useMemo(() => generateAvailableYears(t3Tanggal), [t3Tanggal]);
  
  // Use ref to keep availableMonths stable for handleChange
  const availableMonthsRef = React.useRef(availableMonths);
  React.useEffect(() => {
    availableMonthsRef.current = availableMonths;
  }, [availableMonths]);

  const handleChange = useCallback((e) => {
    if (!canEdit) return;
    const { name, value } = e.target;
    
    // Auto-set year when month is selected
    if (name === "perkiraan_bulan_persalinan" && value) {
      const selectedMonth = availableMonthsRef.current.find(m => m.value === value);
      if (selectedMonth) {
        setForm((prev) => ({ 
          ...prev, 
          [name]: value,
          perkiraan_tahun_persalinan: selectedMonth.year.toString()
        }));
        return;
      }
    }
    
    // Hanya angka untuk field nomor HP
    const hpFields = ["kendaraan_1_hp", "kendaraan_2_hp", "kendaraan_3_hp", "donor_1_hp", "donor_2_hp", "donor_3_hp", "donor_4_hp"];
    if (hpFields.includes(name)) {
      const numericValue = value.replace(/\D/g, "");
      setForm((prev) => ({ ...prev, [name]: numericValue }));
      return;
    }
    
    setForm((prev) => ({ ...prev, [name]: value }));
  }, [canEdit]);

  // VALIDASI: Cek apakah perkiraan bulan/tahun persalinan valid (berdasarkan T3)
  const validatePerkiraanPersalinan = useCallback(() => {
    const { perkiraan_bulan_persalinan, perkiraan_tahun_persalinan } = form;
    
    if (!perkiraan_bulan_persalinan || !perkiraan_tahun_persalinan) {
      return null; // Belum diisi, tidak perlu validasi
    }

    // VALIDASI: Cek apakah data T3 tersedia
    if (!t3Tanggal) {
      return "Data Trimester 3 belum tersedia. Silakan lengkapi data pemeriksaan Trimester 3 terlebih dahulu.";
    }

    const monthMap = {
      'Januari': 0, 'Februari': 1, 'Maret': 2, 'April': 3, 'Mei': 4, 'Juni': 5,
      'Juli': 6, 'Agustus': 7, 'September': 8, 'Oktober': 9, 'November': 10, 'Desember': 11
    };
    
    const monthIndex = monthMap[perkiraan_bulan_persalinan];
    
    if (monthIndex === undefined) {
      return "Format bulan tidak valid.";
    }

    const rencanaDate = new Date(parseInt(perkiraan_tahun_persalinan), monthIndex, 1);
    
    // VALIDASI: Cek apakah tanggal rencana dalam rentang valid (T3 month to T3 month + 3)
    const t3Month = t3Tanggal.getMonth();
    const t3Year = t3Tanggal.getFullYear();
    
    // Hitung tanggal minimum (bulan T3) dan maksimum (T3 + 3 bulan)
    const minDate = new Date(t3Year, t3Month, 1);
    const maxDate = new Date(t3Year, t3Month + 3, 0); // Akhir bulan ke-3 setelah T3
    
    // Set jam ke 0 untuk perbandingan yang akurat
    rencanaDate.setHours(0, 0, 0, 0);
    minDate.setHours(0, 0, 0, 0);
    maxDate.setHours(23, 59, 59, 999);

    if (rencanaDate < minDate) {
      const monthNames = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 
                         'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
      return `Perkiraan persalinan tidak boleh sebelum bulan pencatatan Trimester 3. Tanggal T3: ${monthNames[t3Month]} ${t3Year}. Pilihan yang tersedia: ${monthNames[t3Month]} ${t3Year} hingga ${monthNames[(t3Month + 3) % 12]} ${t3Year + Math.floor((t3Month + 3) / 12)}.`;
    }

    if (rencanaDate > maxDate) {
      const monthNames = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 
                         'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
      return `Perkiraan persalinan tidak boleh lebih dari 3 bulan setelah pencatatan Trimester 3. Tanggal T3: ${monthNames[t3Month]} ${t3Year}. Pilihan yang tersedia: ${monthNames[t3Month]} ${t3Year} hingga ${monthNames[(t3Month + 3) % 12]} ${t3Year + Math.floor((t3Month + 3) / 12)}.`;
    }

    return null; // Valid
  }, [form, t3Tanggal]);

  // ── Bangun payload lengkap (manual + auto) ───────────────────────────────
  const buildPayload = useCallback(() => ({
    ...form,
    kehamilan_id:              kehamilan.id,
    perkiraan_tahun_persalinan: form.perkiraan_tahun_persalinan
      ? parseInt(form.perkiraan_tahun_persalinan)
      : null,
    tanggal_pernyataan: form.tanggal_pernyataan || null,
    // Auto-filled dari data ibu — selalu disesuaikan saat save
    nama_ibu_pernyataan:    autoNamaIbu,
    alamat_ibu_pernyataan:  autoAlamat,
    nama_ibu_hamil_ttd:     autoNamaIbu,
    nama_suami_keluarga_ttd: autoNamaSuami,
    donor_golongan_darah:   autoGolDarah,
  }), [form, kehamilan, autoNamaIbu, autoAlamat, autoNamaSuami, autoGolDarah]);

  const handleSubmit = useCallback(async (e) => {
    e.preventDefault();
    if (!canEdit) {
      Swal.fire({ icon: "error", title: "Akses Ditolak", text: "Anda tidak memiliki izin untuk mengubah data." });
      return;
    }
    // VALIDASI: Cek kelengkapan T3 sebelum mengizinkan submit
    if (!t3Complete) {
      Swal.fire({
        icon: "warning",
        title: "Data Trimester 3 Belum Lengkap",
        text: "Rencana Persalinan hanya dapat diisi setelah data pemeriksaan Trimester 3 lengkap. Silakan lengkapi data Trimester 3 terlebih dahulu.",
        confirmButtonColor: "#185FA5"
      });
      return;
    }
    // VALIDASI: Cek perkiraan bulan/tahun persalinan
    const persalinanValidationError = validatePerkiraanPersalinan();
    if (persalinanValidationError) {
      Swal.fire({
        icon: "warning",
        title: "Perkiraan Persalinan Tidak Valid",
        text: persalinanValidationError,
        confirmButtonColor: "#185FA5"
      });
      return;
    }
    if (!kehamilan) {
      setErrorMessage("Data kehamilan tidak ditemukan.");
      return;
    }
    setSaving(true);
    setErrorMessage("");
    setSuccessMessage("");
    try {
      const payload = buildPayload();
      if (existingRencana) {
        await updateRencana(existingRencana.id_rencana_persalinan, payload);
        setSuccessMessage("Rencana persalinan berhasil diperbarui.");
      } else {
        await createRencana(payload);
        setSuccessMessage("Rencana persalinan berhasil disimpan.");
      }
      const updated = await getRencanaByKehamilanId(kehamilan.id);
      if (updated && updated.length > 0) {
        setExistingRencana(updated[0]);
        setForm(mapDataToForm(updated[0]));
      }
      setIsEditing(false);
    } catch (err) {
      console.error(err);
      setErrorMessage("Gagal menyimpan: " + (err.response?.data?.message || err.message));
    } finally {
      setSaving(false);
    }
  }, [canEdit, t3Complete, validatePerkiraanPersalinan, kehamilan, buildPayload, existingRencana, mapDataToForm]);

  const handleDelete = useCallback(async () => {
    if (!canEdit || !existingRencana) return;
    const result = await Swal.fire({
      title: "Hapus Rencana Persalinan?",
      text: "Data yang dihapus tidak dapat dikembalikan.",
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#A32D2D",
      cancelButtonColor: "#6B7280",
      confirmButtonText: "Ya, Hapus",
      cancelButtonText: "Batal",
    });
    if (!result.isConfirmed) return;
    try {
      await deleteRencana(existingRencana.id_rencana_persalinan);
      setExistingRencana(null);
      setForm(initialForm);
      setIsEditing(false);
      Swal.fire({ icon: "success", title: "Berhasil", text: "Rencana persalinan telah dihapus.", timer: 2000, showConfirmButton: false });
    } catch (err) {
      console.error(err);
      Swal.fire({ icon: "error", title: "Gagal", text: "Gagal menghapus: " + (err.response?.data?.message || err.message) });
    }
  }, [canEdit, existingRencana, emptyForm]);

  const handleExport = useCallback(async () => {
    if (!existingRencana) return;
    setExporting(true);
    try {
      // Gabungkan data tersimpan + auto-fill terkini
      const exportData = {
        ...existingRencana,
        nama_ibu_pernyataan:     autoNamaIbu || existingRencana.nama_ibu_pernyataan,
        alamat_ibu_pernyataan:   autoAlamat  || existingRencana.alamat_ibu_pernyataan,
        nama_ibu_hamil_ttd:      autoNamaIbu || existingRencana.nama_ibu_hamil_ttd,
        nama_suami_keluarga_ttd: autoNamaSuami || existingRencana.nama_suami_keluarga_ttd,
        donor_golongan_darah:    autoGolDarah || existingRencana.donor_golongan_darah,
      };
      const blob = await exportToDocx(exportData);
      downloadBlob(blob, `Rencana_Persalinan_${autoNamaIbu || "Ibu"}.docx`);
    } catch (err) {
      console.error(err);
      Swal.fire({ icon: "error", title: "Gagal Export", text: "Gagal membuat file DOCX: " + err.message });
    } finally {
      setExporting(false);
    }
  }, [existingRencana, autoNamaIbu, autoAlamat, autoNamaSuami, autoGolDarah]);

  // ── EvaluationView ───────────────────────────────────────────────────────
  const EvaluationView = () => {
    if (!existingRencana) {
      return (
        <div className="bg-white rounded-xl shadow-sm p-10 text-center border border-gray-100 font-sans">
          <div className="flex flex-col items-center gap-4">
            <div className="p-5 rounded-full" style={{ backgroundColor: "#EBF3FC" }}>
              <ClipboardList size={52} style={{ color: "#185FA5" }} />
            </div>
            <h3 className="text-[22px] font-bold text-[#185FA5] font-sans">Belum Ada Rencana Persalinan</h3>
            <p className="text-gray-500 max-w-md text-sm font-sans">Belum ada rencana persalinan yang dibuat untuk ibu hamil ini.</p>
            {canEdit && (
              <>
                {!t3Complete && (
                  <div className="bg-[#BA7517]/10 border border-[#BA7517]/30 p-4 rounded-lg text-[#BA7517] text-sm max-w-md font-sans flex items-start gap-2">
                    <AlertCircle size={16} className="mt-0.5 flex-shrink-0" />
                    <span>Data Trimester 3 belum lengkap. Rencana Persalinan hanya dapat diisi setelah pemeriksaan Trimester 3 selesai.</span>
                  </div>
                )}
                <button 
                  onClick={() => setIsEditing(true)} 
                  disabled={!t3Complete}
                  className={`mt-2 px-6 py-2.5 rounded-full font-semibold flex items-center gap-2 text-base transition font-sans ${
                    !t3Complete 
                      ? "bg-gray-300 text-gray-500 cursor-not-allowed" 
                      : "bg-[#185FA5] text-white hover:opacity-90"
                  }`}
                >
 Tambah Rencana Persalinan
                </button>
              </>
            )}
          </div>
        </div>
      );
    }

    const r = existingRencana;
    const formatTanggal = (t) => {
      if (!t) return "—";
      try { return new Date(t).toLocaleDateString("id-ID", { day: "2-digit", month: "long", year: "numeric" }); }
      catch { return t; }
    };

    return (
      <div className="space-y-5">
        {/* ── Identitas Ibu (auto) ── */}
        <SectionCard icon={User} title="Identitas Ibu" iconColor="text-[#185FA5]" bgColor="bg-[#EBF3FC]">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <InfoItem label="Nama Ibu" value={autoNamaIbu || r.nama_ibu_pernyataan} />
            <InfoItem label="Alamat" value={autoAlamat || r.alamat_ibu_pernyataan} />
            <InfoItem label="Perkiraan Bulan Persalinan"
              value={r.perkiraan_bulan_persalinan
                ? `${r.perkiraan_bulan_persalinan}${r.perkiraan_tahun_persalinan ? ` ${r.perkiraan_tahun_persalinan}` : ""}`
                : "—"}
            />
            <InfoItem label="Ayah/Keluarga" value={autoNamaSuami || r.nama_suami_keluarga_ttd} />
          </div>
        </SectionCard>

        {/* ── Tenaga Kesehatan ── */}
        <SectionCard icon={ShieldCheck} title="Diisi oleh Tenaga Kesehatan" iconColor="text-[#0F6E56]" bgColor="bg-[#E1F5EE]">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
            <InfoItem label="Bidan/Dokter 1" value={r.fasyankes_1_nama_tenaga} />
            <InfoItem label="Fasilitas Kesehatan 1" value={r.fasyankes_1_nama_fasilitas} />
            <InfoItem label="Bidan/Dokter 2" value={r.fasyankes_2_nama_tenaga} />
            <InfoItem label="Fasilitas Kesehatan 2" value={r.fasyankes_2_nama_fasilitas} />
          </div>
          <div className="flex items-center gap-2">
            <Banknote size={15} className="text-[#0F6E56]" />
            <span className="text-xs text-gray-500 font-medium font-sans">Sumber Dana:</span>
            <Badge color="success">{r.sumber_dana_persalinan || "—"}</Badge>
          </div>
        </SectionCard>

        {/* ── Kendaraan ── */}
        <SectionCard icon={Car} title="Kendaraan / Ambulan Desa" iconColor="text-[#BA7517]" bgColor="bg-[#FEF3CD]">
          <div className="divide-y divide-gray-100">
            {[1, 2, 3].map((i) => {
              const nama = r[`kendaraan_${i}_nama`];
              const hp   = r[`kendaraan_${i}_hp`];
              if (!nama && !hp) return null;
              return (
                <div key={i} className="py-2.5 flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <span className="flex h-6 w-6 items-center justify-center rounded-full bg-[#BA7517]/20 text-[#BA7517] text-xs font-bold">{i}</span>
                    <span className="text-sm text-gray-800 font-sans">{nama || "—"}</span>
                  </div>
                  {hp && <span className="text-xs text-gray-500 bg-gray-100 px-2 py-0.5 rounded-md font-sans">{hp}</span>}
                </div>
              );
            })}
            {!r.kendaraan_1_nama && !r.kendaraan_2_nama && !r.kendaraan_3_nama && (
              <p className="text-sm text-gray-400 italic font-sans">Belum diisi</p>
            )}
          </div>
        </SectionCard>

        {/* ── Kontrasepsi ── */}
        <SectionCard icon={Heart} title="Metode Kontrasepsi Setelah Melahirkan" iconColor="text-[#A32D2D]" bgColor="bg-[#FBE9E9]">
          <Badge color="primary">{r.metode_kontrasepsi_pilihan || "Belum ditentukan"}</Badge>
        </SectionCard>

        {/* ── Donor Darah ── */}
        <SectionCard icon={Droplets} title="Sumbangan Darah" iconColor="text-[#A32D2D]" bgColor="bg-[#FBE9E9]">
          <div className="flex gap-4 mb-4">
            <div className="flex items-center gap-2 bg-[#A32D2D]/10 border border-[#A32D2D]/20 rounded-lg px-4 py-2">
              <span className="text-xs text-gray-500 font-sans">Golongan Darah</span>
              <span className="text-lg font-bold text-[#A32D2D] font-sans">{autoGolDarah || r.donor_golongan_darah || "—"}</span>
              <Lock size={11} className="text-gray-400" />
            </div>
            <div className="flex items-center gap-2 bg-[#A32D2D]/10 border border-[#A32D2D]/20 rounded-lg px-4 py-2">
              <span className="text-xs text-gray-500 font-sans">Rhesus</span>
              <span className="text-lg font-bold text-[#A32D2D] font-sans">{r.donor_rhesus || "—"}</span>
            </div>
          </div>
          <p className="text-xs font-semibold text-gray-400 uppercase tracking-wide mb-2 font-sans">Dibantu oleh:</p>
          <div className="divide-y divide-gray-100">
            {[1, 2, 3, 4].map((i) => {
              const nama = r[`donor_${i}_nama`];
              const hp   = r[`donor_${i}_hp`];
              if (!nama && !hp) return null;
              return (
                <div key={i} className="py-2.5 flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <span className="flex h-6 w-6 items-center justify-center rounded-full bg-[#A32D2D]/20 text-[#A32D2D] text-xs font-bold">{i}</span>
                    <span className="text-sm text-gray-800 font-sans">{nama || "—"}</span>
                  </div>
                  {hp && <span className="text-xs text-gray-500 bg-gray-100 px-2 py-0.5 rounded-md font-sans">{hp}</span>}
                </div>
              );
            })}
            {!r.donor_1_nama && !r.donor_2_nama && !r.donor_3_nama && !r.donor_4_nama && (
              <p className="text-sm text-gray-400 italic font-sans">Belum diisi</p>
            )}
          </div>
        </SectionCard>

        {/* ── Persetujuan ── */}
        <SectionCard icon={Calendar} title="Tanggal & Persetujuan" iconColor="text-[#185FA5]" bgColor="bg-[#EBF3FC]">
          <div className="mb-4">
            <InfoItem label="Tanggal" value={formatTanggal(r.tanggal_pernyataan)} />
          </div>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="rounded-lg border border-gray-200 p-4 text-center bg-gray-50">
              <p className="text-xs font-semibold text-gray-400 mb-2 font-sans">Persetujuan Ayah/Keluarga</p>
              <div className="h-12 flex items-end justify-center border-b border-gray-400">
                <span className="text-sm text-gray-800 font-sans">( {autoNamaSuami || r.nama_suami_keluarga_ttd || "—"} )</span>
              </div>
            </div>
            <div className="rounded-lg border border-gray-200 p-4 text-center bg-gray-50">
              <p className="text-xs font-semibold text-gray-400 mb-2 font-sans">Persetujuan Ibu Hamil</p>
              <div className="h-12 flex items-end justify-center border-b border-gray-400">
                <span className="text-sm text-gray-800 font-sans">( {autoNamaIbu || r.nama_ibu_hamil_ttd || "—"} )</span>
              </div>
            </div>
            <div className="rounded-lg border border-gray-200 p-4 text-center bg-gray-50">
              <p className="text-xs font-semibold text-gray-400 mb-2 font-sans">Bidan/Dokter</p>
              <div className="h-12 flex items-end justify-center border-b border-gray-400">
                <span className="text-sm text-gray-800 font-sans">( {r.nama_bidan_dokter_ttd || "—"} )</span>
              </div>
            </div>
          </div>
        </SectionCard>

        {/* ── Tombol Aksi ── */}
        <div className="flex flex-wrap gap-3 justify-between items-center pt-2">
          <button onClick={() => navigate(`/data-ibu/${id}`)} className="inline-flex items-center gap-2 px-5 py-2.5 rounded-full border border-[#185FA5] text-[#185FA5] text-sm font-semibold hover:bg-[#185FA5]/5 transition font-sans">
            <ArrowLeft size={16} />
            Kembali
          </button>
          <div className="flex flex-wrap gap-3">
            {canEdit && (
              <>
                <button onClick={handleDelete} className="bg-[#A32D2D] text-white px-5 py-2.5 rounded-full font-semibold flex items-center gap-2 text-base hover:opacity-90 transition font-sans">
                  <Trash2 size={18} /> Hapus
                </button>
                <button onClick={() => setIsEditing(true)} className="bg-[#BA7517] text-white px-5 py-2.5 rounded-full font-semibold flex items-center gap-2 text-base hover:opacity-90 transition font-sans">
                  <Edit size={18} /> Ubah
                </button>
              </>
            )}
            <button onClick={handleExport} disabled={exporting} className="bg-[#0F6E56] text-white px-5 py-2.5 rounded-full font-semibold flex items-center gap-2 text-base hover:opacity-90 disabled:opacity-50 transition font-sans">
              <FileDown size={18} /> {exporting ? "Mengekspor..." : "Unduh DOCX"}
            </button>
          </div>
        </div>
      </div>
    );
  };

  // ── Loading ──────────────────────────────────────────────────────────────
  if (loading) {
    return (
      <MainLayout>
        <div className="min-h-screen flex items-center justify-center bg-[#F7FAFB] font-sans">
          <div className="text-[#185FA5] text-lg font-sans">Memuat Data...</div>
        </div>
      </MainLayout>
    );
  }

  if (!kehamilan) {
    return (
      <MainLayout>
        <div className="min-h-screen bg-[#F7FAFB] p-6 font-sans">
          <div className="bg-[#A32D2D]/10 border border-[#A32D2D]/30 p-4 rounded-lg text-[#A32D2D] mb-4 font-sans">
            {errorMessage || "Data kehamilan tidak ditemukan."}
          </div>
          <button onClick={() => navigate(`/data-ibu/${id}`)} className="px-5 py-2.5 rounded-full bg-[#185FA5] text-white font-semibold text-base hover:opacity-90 transition font-sans">Kembali</button>
        </div>
      </MainLayout>
    );
  }

  return (
    <MainLayout>
      <div className="min-h-screen bg-[#F7FAFB] font-sans">
        <div className="max-w-5xl mx-auto p-5 space-y-6">
          {/* ── Header ── */}
          <div className="flex items-center gap-4">
            <button
              onClick={() => navigate(`/data-ibu/${id}`)}
              className="inline-flex items-center gap-2 px-5 py-2.5 rounded-full border border-[#185FA5] text-[#185FA5] text-sm font-semibold hover:bg-[#185FA5]/5 transition font-sans"
            >
              <ArrowLeft size={16} />
              Kembali
            </button>
            <div>
              <h1 className="text-lg sm:text-2xl md:text-[28px] font-bold text-gray-900 font-sans">Rencana Persalinan</h1>
              <p className="text-sm text-gray-600 mt-1 font-sans">
                Catat rencana persalinan ibu hamil meliputi tenaga kesehatan, kendaraan, donasi darah, dan metode kontrasepsi pasca persalinan
              </p>
            </div>
          </div>

          {/* ── Mode Baca (Dokter) ── */}
          {!canEdit && (
            <div className="bg-[#185FA5]/10 border border-[#185FA5]/20 p-3 rounded-lg text-[#185FA5] text-base flex items-center gap-2 font-sans">
              <Eye size={16} /> Anda dalam mode baca (Dokter). Data hanya dapat dilihat, tidak dapat diubah.
            </div>
          )}

          {successMessage && (
            <div className="p-4 bg-[#3B6D11]/10 border border-[#3B6D11]/30 rounded-lg flex items-center gap-2 text-[#3B6D11] font-sans">
              <CheckCircle size={20} /> <span>{successMessage}</span>
            </div>
          )}
          {errorMessage && !loading && (
            <div className="p-4 bg-[#A32D2D]/10 border border-[#A32D2D]/30 rounded-lg flex items-center gap-2 text-[#A32D2D] font-sans">
              <AlertCircle size={20} /> <span>{errorMessage}</span>
            </div>
          )}

          {/* ── Informasi T3 tidak lengkap (di luar form) ── */}
          {!t3Complete && !isEditing && (
            <div className="bg-[#BA7517]/10 border border-[#BA7517]/30 p-4 rounded-lg flex items-start gap-3 font-sans">
              <AlertCircle size={20} className="text-[#BA7517] mt-0.5 flex-shrink-0" />
              <div>
                <p className="font-semibold text-[#BA7517] text-sm">Data Trimester 3 Belum Lengkap</p>
                <p className="text-[#BA7517]/80 text-sm mt-0.5">
                  Rencana Persalinan hanya dapat diisi setelah data pemeriksaan Trimester 3 lengkap. Silakan lengkapi data Trimester 3 terlebih dahulu.
                </p>
              </div>
            </div>
          )}

          {isEditing ? (
            <FormView 
              key="rencana-form"
              form={form}
              handleChange={handleChange}
              canEdit={canEdit}
              autoNamaIbu={autoNamaIbu}
              autoAlamat={autoAlamat}
              autoNamaSuami={autoNamaSuami}
              autoGolDarah={autoGolDarah}
              availableMonths={availableMonths}
              availableYears={availableYears}
              t3Tanggal={t3Tanggal}
              handleSubmit={handleSubmit}
              saving={saving}
              existingRencana={existingRencana}
              setIsEditing={setIsEditing}
            />
          ) : (
            <EvaluationView />
          )}
        </div>
      </div>
    </MainLayout>
  );
}