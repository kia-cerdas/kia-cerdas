import React from "react";
import { Check, X } from "lucide-react";

export default function LembarPemantauanTable({ 
  rentangUsia, 
  kategoriList, 
  history, 
  onSaveCell, 
  isLoading 
}) {
  if (isLoading) return <div className="p-10 text-center text-gray-400">Memuat tabel pemantauan...</div>;
  if (!kategoriList.length) return <div className="p-10 text-center text-gray-400">Belum ada indikator untuk kategori ini.</div>;

  // Determine week range based on rentangUsia name
  // Standard for 29 hari - 3 bulan is weeks 5 to 13
  let weekRange = [];
  if (rentangUsia?.nama_rentang === "29 Hari - 3 Bulan") {
    weekRange = [5, 6, 7, 8, 9, 10, 11, 12, 13];
  } else {
    // Default to 1-10 for others or dynamic
    weekRange = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  }

  // Map history for easy lookup: historyMap[week][kategoriId] = bool
  const historyMap = {};
  history.forEach(record => {
    const week = record.periode_waktu;
    if (!historyMap[week]) historyMap[week] = {};
    (record.detail_gejala || []).forEach(detail => {
      historyMap[week][detail.kategori_tanda_sakit_id] = detail.is_terjadi;
    });
  });

  return (
    <div className="overflow-x-auto bg-white rounded-xl shadow-sm border border-gray-100">
      <table className="w-full text-left border-collapse">
        <thead>
          <tr className="bg-amber-50">
            <th className="p-4 border-b border-gray-200 text-xs font-bold text-gray-600 uppercase tracking-wider text-center w-24">
              Minggu ke-
            </th>
            {kategoriList.map((kat) => (
              <th key={kat.id} className="p-4 border-b border-gray-200 text-[10px] font-bold text-gray-700 leading-tight min-w-[120px] max-w-[200px]">
                {kat.gejala}
              </th>
            ))}
            <th className="p-4 border-b border-gray-200 text-xs font-bold text-gray-600 uppercase tracking-wider text-center min-w-[150px]">
              Tanggal & Paraf
            </th>
          </tr>
        </thead>
        <tbody className="divide-y divide-gray-100">
          {weekRange.map((week) => (
            <tr key={week} className="hover:bg-gray-50/50 transition-colors">
              <td className="p-4 text-center font-bold text-gray-800 bg-gray-50/30">
                {week}
              </td>
              {kategoriList.map((kat) => {
                const isTerjadi = historyMap[week]?.[kat.id] || false;
                return (
                  <td key={kat.id} className="p-4 text-center">
                    <button
                      onClick={() => onSaveCell(week, kat.id, !isTerjadi)}
                      className={`w-8 h-8 rounded-lg flex items-center justify-center transition-all ${
                        isTerjadi 
                        ? "bg-red-100 text-red-600 border-2 border-red-200 shadow-sm" 
                        : "bg-white text-gray-200 border border-gray-200 hover:border-blue-300 hover:text-blue-300"
                      }`}
                    >
                      {isTerjadi ? <Check size={20} strokeWidth={3} /> : <div className="w-2 h-2 rounded-full bg-current opacity-20" />}
                    </button>
                  </td>
                );
              })}
              <td className="p-4 text-center">
                <div className="flex flex-col items-center justify-center gap-1">
                  <div className="h-6 border-b border-dashed border-gray-300 flex items-end justify-center text-[10px] text-gray-500 w-full px-2">
                    {history.find(r => r.periode_waktu === week)?.nama_pemeriksa || "...................."}
                  </div>
                  {history.find(r => r.periode_waktu === week) && (
                    <span className={`text-[9px] font-bold px-2 py-0.5 rounded-full ${
                      history.find(r => r.periode_waktu === week)?.status === 'Diterima' ? 'bg-green-100 text-green-700' :
                      history.find(r => r.periode_waktu === week)?.status === 'Ditolak' ? 'bg-red-100 text-red-700' :
                      'bg-yellow-100 text-yellow-700'
                    }`}>
                      {history.find(r => r.periode_waktu === week)?.status || "Menunggu Verifikasi"}
                    </span>
                  )}
                </div>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
      <div className="p-4 bg-gray-50 border-t border-gray-100 flex items-center gap-6">
        <div className="flex items-center gap-2 text-xs text-gray-500">
           <div className="w-3 h-3 rounded bg-red-100 border border-red-200" />
           <span>Terjadi Gejala / Centang (✔)</span>
        </div>
        <div className="flex items-center gap-2 text-xs text-gray-500">
           <div className="w-3 h-3 rounded bg-white border border-gray-200" />
           <span>Kondisi Normal / Kosong</span>
        </div>
      </div>
    </div>
  );
}
