import React, { memo } from 'react';
import { Check } from 'lucide-react';

// Gunakan React.memo agar komponen tidak re-render kecuali value-nya berubah.
// Ini sangat penting agar form tetap ringan saat input banyak data.
const DynamicInput = memo(({ item, value, onChange, onToggle }) => {
  if (!item) return null;

  // Logika Sakti: Mendeteksi apakah nilai dianggap "Aktif/Checked"
  // Kita tambahkan pengecekan string "1" karena data dari database sering datang dalam format string
  const isChecked = 
    value === true || 
    value === "true" || 
    value === 1 || 
    value === "1";

  const getUnit = (name) => {
    const n = name.toLowerCase();
    if (n.includes('berat') || n.includes('bb')) return 'gr';
    if (n.includes('panjang') || n.includes('pb') || n.includes('lingkar')) return 'cm';
    if (n.includes('suhu')) return '°C';
    return '';
  };

  const labelStyle = "text-[10px] font-bold text-gray-500 uppercase tracking-wider mb-1 block ml-0.5";

  // --- RENDER NUMBER INPUT ---
  if (item.tipe_input === 'number') {
    return (
      <div className="w-full">
        <label className={labelStyle}>{item.nama}</label>
        <div className="relative group">
          <input
            type="text" 
            inputMode="numeric"
            className="w-full bg-gray-50 border border-gray-200 rounded-lg py-1.5 px-3 pr-10 focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 focus:bg-white outline-none transition-all text-sm font-bold text-gray-700 shadow-sm"
            placeholder="0"
            value={value || ''} 
            onChange={(e) => onChange(item.jenis_pelayanan_id, e.target.value)}
          />
          <span className="absolute right-3 top-1.5 text-gray-400 font-bold text-[10px] uppercase pointer-events-none group-focus-within:text-blue-500 transition-colors">
            {getUnit(item.nama)}
          </span>
        </div>
      </div>
    );
  }

  // --- RENDER CHECKBOX INPUT ---
  if (item.tipe_input === 'checkbox') {
    return (
      <button
        type="button"
        onClick={() => onToggle(item.jenis_pelayanan_id)}
        className={`flex items-center gap-2 py-2 px-3 border rounded-lg transition-all w-full text-left group ${
          isChecked 
            ? 'border-blue-600 bg-blue-50 text-blue-700 shadow-sm' 
            : 'border-gray-200 bg-white text-gray-400 hover:bg-gray-50 hover:border-gray-300'
        }`}
      >
        <div className={`flex-shrink-0 w-4 h-4 rounded flex items-center justify-center border transition-colors ${
          isChecked 
            ? 'bg-blue-600 border-blue-600 text-white' 
            : 'bg-white border-gray-300 group-hover:border-gray-400'
        }`}>
          {isChecked && <Check size={11} strokeWidth={4} />}
        </div>
        <span className={`text-[10px] uppercase tracking-tight truncate font-black ${
          isChecked ? 'text-blue-700' : 'text-gray-500'
        }`}>
          {item.nama}
        </span>
      </button>
    );
  }

  // --- RENDER TEXTAREA ---
  if (item.tipe_input === 'text') {
    return (
      <div className="w-full pt-1">
        <label className={labelStyle}>{item.nama}</label>
        <textarea
          className="w-full bg-gray-50 border border-gray-200 rounded-lg p-3 min-h-[80px] focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 focus:bg-white outline-none transition-all text-xs text-gray-700 leading-relaxed shadow-sm"
          placeholder="Tulis observasi medis di sini..."
          value={value || ''}
          onChange={(e) => onChange(item.jenis_pelayanan_id, e.target.value)}
        />
      </div>
    );
  }

  return null;
});

export default DynamicInput;