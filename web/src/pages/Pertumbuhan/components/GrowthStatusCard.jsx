import React from 'react';
import { AlertCircle, CheckCircle, AlertTriangle, TrendingDown } from 'lucide-react';

/**
 * Komponen untuk menampilkan status gizi anak dengan visual yang lebih jelas
 */
export function GrowthStatusCard({ status, label, zScore, description }) {
  const getStatusColor = (statusText) => {
    if (!statusText) return { bg: 'bg-gray-100', text: 'text-gray-600', icon: 'text-gray-400', border: 'border-gray-200' };
    
    const lower = statusText.toLowerCase();
    
    // Hijau - Gizi Baik
    if (lower.includes('baik') || lower.includes('normal')) {
      return { 
        bg: 'bg-emerald-50', 
        text: 'text-emerald-700', 
        icon: 'text-emerald-500',
        border: 'border-emerald-200',
        color: '#10b981'
      };
    }
    
    // Kuning/Oranye - Gizi Kurang atau Risiko
    if (lower.includes('kurang') || lower.includes('risiko') || lower.includes('pendek')) {
      return { 
        bg: 'bg-amber-50', 
        text: 'text-amber-700', 
        icon: 'text-amber-500',
        border: 'border-amber-200',
        color: '#f59e0b'
      };
    }
    
    // Merah - Gizi Buruk atau Sangat Kurang
    if (lower.includes('buruk') || lower.includes('sangat') || lower.includes('stunting') || lower.includes('obesitas')) {
      return { 
        bg: 'bg-red-50', 
        text: 'text-red-700', 
        icon: 'text-red-500',
        border: 'border-red-200',
        color: '#ef4444'
      };
    }
    
    return { bg: 'bg-blue-50', text: 'text-blue-700', icon: 'text-blue-500', border: 'border-blue-200', color: '#3b82f6' };
  };

  const colors = getStatusColor(status);
  const isGood = colors.color === '#10b981';
  const isWarning = colors.color === '#f59e0b';
  const isCritical = colors.color === '#ef4444';

  const IconComponent = isGood ? CheckCircle : isCritical ? AlertCircle : AlertTriangle;

  return (
    <div className={`${colors.bg} border-2 ${colors.border} rounded-2xl p-4 transition-all hover:shadow-md`}>
      <div className="flex items-start justify-between mb-3">
        <div className="flex-1">
          <p className="text-[11px] font-black text-gray-500 uppercase tracking-widest mb-1">{label}</p>
          <p className={`text-sm font-black ${colors.text} leading-tight`}>
            {status || 'Belum dihitung'}
          </p>
        </div>
        <IconComponent size={24} className={colors.icon} />
      </div>

      {/* Z-Score Visual */}
      {zScore !== null && zScore !== undefined && (
        <div className="mt-3 pt-3 border-t border-white/50">
          <div className="flex items-center justify-between mb-2">
            <span className="text-[10px] font-bold text-gray-500">Z-Score</span>
            <span className={`text-xs font-black ${colors.text}`}>{zScore.toFixed(2)}</span>
          </div>
          
          {/* Z-Score Bar */}
          <div className="relative h-2 bg-white/60 rounded-full overflow-hidden">
            {/* Reference lines for Z-Score */}
            <div className="absolute h-full w-full flex">
              {/* -3 */}
              <div className="absolute h-full w-px bg-red-300/40" style={{ left: '5%' }} />
              {/* -2 */}
              <div className="absolute h-full w-px bg-amber-300/40" style={{ left: '25%' }} />
              {/* 0 (Median) */}
              <div className="absolute h-full w-px bg-gray-400/40" style={{ left: '50%' }} />
              {/* 2 */}
              <div className="absolute h-full w-px bg-amber-300/40" style={{ left: '75%' }} />
              {/* 3 */}
              <div className="absolute h-full w-px bg-red-300/40" style={{ left: '95%' }} />
            </div>
            
            {/* Z-Score Position */}
            <div 
              className="absolute h-full w-1 rounded-full transition-all"
              style={{
                left: `${Math.max(5, Math.min(95, 50 + (zScore / 3) * 45))}%`,
                backgroundColor: colors.color,
                transform: 'translateX(-50%)',
                boxShadow: `0 0 8px ${colors.color}40`
              }}
            />
          </div>
          
          {/* Legend Z-Score */}
          <div className="flex justify-between mt-2 text-[9px] font-bold text-gray-400">
            <span>-3</span>
            <span>-2</span>
            <span>0</span>
            <span>2</span>
            <span>3</span>
          </div>
        </div>
      )}

      {/* Description */}
      {description && (
        <p className="text-[10px] text-gray-600 mt-3 leading-relaxed italic">
          {description}
        </p>
      )}
    </div>
  );
}

/**
 * Komponen untuk menampilkan ringkasan status gizi secara keseluruhan
 */
export function GrowthSummary({ lastStatus, lastData, anak }) {
  return (
    <div className="bg-gradient-to-br from-blue-600 to-indigo-700 rounded-3xl p-6 text-white shadow-xl">
      <h3 className="text-lg font-black mb-4">Ringkasan Status Gizi</h3>
      
      <div className="space-y-3">
        {/* Anak Info */}
        <div className="flex items-center gap-3 pb-4 border-b border-white/20">
          <div className="w-12 h-12 rounded-full bg-white/20 flex items-center justify-center">
            <span className="text-2xl">👶</span>
          </div>
          <div>
            <p className="font-bold text-sm">{anak?.nama}</p>
            <p className="text-xs opacity-70">{lastData?.usia_ukur_bulan} bulan</p>
          </div>
        </div>

        {/* Status Cards Mini */}
        <div className="space-y-2">
          {[
            { label: 'Berat/Usia', status: lastStatus?.statusBBU },
            { label: 'Tinggi/Usia', status: lastStatus?.statusTBU },
            { label: 'Berat/Tinggi', status: lastStatus?.statusBBTB },
          ].map(({ label, status }) => (
            <div key={label} className="flex items-center justify-between text-sm">
              <span className="font-semibold">{label}</span>
              <span className="px-3 py-1 bg-white/20 rounded-full text-xs font-bold">
                {status || '-'}
              </span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
