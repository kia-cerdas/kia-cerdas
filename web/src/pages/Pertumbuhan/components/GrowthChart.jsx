import React, { useState } from 'react';
import {
  LineChart, Line, ComposedChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip,
  ResponsiveContainer, Legend, ReferenceLine, Label
} from 'recharts';
import { TrendingUp, BarChart3 } from 'lucide-react';

/**
 * Komponen untuk menampilkan grafik pertumbuhan dengan berbagai mode tampilan
 */
export function GrowthChart({ data, activeChart, chartConfig, onChartChange }) {
  const [chartType, setChartType] = useState('line'); // line, bar, combined

  if (!data || data.length === 0) {
    return (
      <div className="h-[280px] flex items-center justify-center text-gray-300 font-medium italic">
        Belum ada data untuk ditampilkan
      </div>
    );
  }

  const cfg = chartConfig[activeChart] || chartConfig.bb;

  return (
    <div className="space-y-4">
      {/* Chart Type Selector */}
      <div className="flex gap-2 justify-center md:justify-start">
        {[
          { type: 'line', label: 'Grafik Garis', icon: TrendingUp },
          { type: 'bar', label: 'Grafik Batang', icon: BarChart3 },
        ].map(({ type, label, icon: Icon }) => (
          <button
            key={type}
            onClick={() => setChartType(type)}
            className={`flex items-center gap-2 px-3 py-2 rounded-lg text-sm font-semibold transition-all ${
              chartType === type
                ? 'bg-indigo-600 text-white shadow-md'
                : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
            }`}
          >
            <Icon size={16} />
            {label}
          </button>
        ))}
      </div>

      {/* Chart */}
      <div className="bg-gradient-to-b from-white to-gray-50 rounded-xl border border-gray-100 p-4">
        <ResponsiveContainer width="100%" height={350}>
          {chartType === 'line' ? (
            <LineChart data={data} margin={{ top: 20, right: 30, left: 10, bottom: 20 }}>
              <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
              <XAxis 
                dataKey="bulan" 
                tick={{ fontSize: 11, fontWeight: 600, fill: '#9ca3af' }}
                angle={-45}
                height={60}
              />
              <YAxis 
                tick={{ fontSize: 11, fontWeight: 600, fill: '#9ca3af' }}
                label={{ value: cfg.unit, angle: -90, position: 'insideLeft', style: { fontSize: 10, fontWeight: 600, fill: '#9ca3af' } }}
              />
              
              {/* Reference lines untuk standar pertumbuhan */}
              <ReferenceLine
                y={getMedianByChart(activeChart)}
                stroke="#059669"
                strokeDasharray="5 5"
                opacity={0.3}
                label={{ value: 'Median', position: 'insideTopRight', offset: -10, fontSize: 10, fill: '#059669' }}
              />

              <Tooltip
                contentStyle={{
                  borderRadius: 12,
                  border: 'none',
                  boxShadow: '0 4px 24px rgba(0,0,0,0.15)',
                  fontSize: 12,
                  fontWeight: 600,
                }}
                formatter={(v) => [
                  v !== null ? `${v.toFixed(2)} ${cfg.unit}` : '-',
                  cfg.label,
                ]}
                labelFormatter={(label) => `Usia: ${label}`}
              />
              
              <Legend 
                wrapperStyle={{ paddingTop: '20px' }}
                formatter={() => cfg.label}
              />

              <Line
                type="monotone"
                dataKey={activeChart}
                stroke={cfg.color}
                strokeWidth={3}
                dot={{ r: 5, fill: cfg.color, strokeWidth: 2, stroke: '#fff' }}
                activeDot={{ r: 7, shadow: true }}
                connectNulls
                isAnimationActive
                animationDuration={800}
              />
            </LineChart>
          ) : (
            <ComposedChart data={data} margin={{ top: 20, right: 30, left: 10, bottom: 20 }}>
              <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
              <XAxis 
                dataKey="bulan"
                tick={{ fontSize: 11, fontWeight: 600, fill: '#9ca3af' }}
                angle={-45}
                height={60}
              />
              <YAxis
                tick={{ fontSize: 11, fontWeight: 600, fill: '#9ca3af' }}
                label={{ value: cfg.unit, angle: -90, position: 'insideLeft', style: { fontSize: 10, fontWeight: 600, fill: '#9ca3af' } }}
              />

              <Tooltip
                contentStyle={{
                  borderRadius: 12,
                  border: 'none',
                  boxShadow: '0 4px 24px rgba(0,0,0,0.15)',
                  fontSize: 12,
                  fontWeight: 600,
                }}
                formatter={(v) => [
                  v !== null ? `${v.toFixed(2)} ${cfg.unit}` : '-',
                  cfg.label,
                ]}
                labelFormatter={(label) => `Usia: ${label}`}
              />

              <Bar
                dataKey={activeChart}
                fill={cfg.color}
                radius={[8, 8, 0, 0]}
                isAnimationActive
                animationDuration={800}
              />
              
              <Line
                type="monotone"
                dataKey={activeChart}
                stroke={cfg.color}
                strokeWidth={2}
                dot={{ r: 4, fill: cfg.color }}
                connectNulls
                isAnimationActive
              />
            </ComposedChart>
          )}
        </ResponsiveContainer>
      </div>

      {/* Legend */}
      <div className="flex flex-wrap gap-4 justify-center">
        <div className="flex items-center gap-2">
          <div className="w-4 h-1 rounded-full" style={{ backgroundColor: cfg.color }} />
          <span className="text-sm font-semibold text-gray-700">{cfg.label}</span>
        </div>
        <div className="flex items-center gap-2">
          <div className="w-4 h-1 rounded-full border-2 border-green-500" style={{ borderStyle: 'dashed' }} />
          <span className="text-sm font-semibold text-gray-700">Median (Standar)</span>
        </div>
      </div>
    </div>
  );
}

/**
 * Helper function untuk mendapatkan nilai median berdasarkan chart type
 * (dapat disesuaikan dengan data standar yang sebenarnya dari backend)
 */
function getMedianByChart(chartType) {
  const medians = {
    bb: 10, // Berat badan median untuk umur ~12 bulan
    tb: 75, // Tinggi badan median
    lila: 15, // LILA median
    lk: 46, // Lingkar kepala median
  };
  return medians[chartType] || 50;
}
