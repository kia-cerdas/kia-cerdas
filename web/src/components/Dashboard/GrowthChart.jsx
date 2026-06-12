import React from "react";
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
  Scatter,
  ComposedChart
} from "recharts";

const GrowthChart = ({ data, type = "bb_u", gender = "Laki-laki" }) => {
  if (!data || !data.standar_bb_u) return <div className="text-center py-10 text-gray-400">Data tidak tersedia</div>;

  const isLaki = gender?.toLowerCase().includes("laki");
  const standar = type === "bb_u" ? data.standar_bb_u : data.standar_tb_u;

  if (!standar || !Array.isArray(standar) || standar.length === 0) {
    return <div className="text-center py-10 text-gray-400">Data standar tidak tersedia untuk gender {gender}</div>;
  }

  const dataKey = type === "bb_u" ? "berat_badan" : "tinggi_badan";
  const title = type === "bb_u" ? "Grafik Berat Badan (BB/U)" : "Grafik Tinggi Badan (TB/U)";
  const unit = type === "bb_u" ? "kg" : "cm";
  const riwayat = data.riwayat || [];

  // Merge standard curves with child data
  // nilai_sumbu_x comes as float (e.g. 0.0, 1.0) — use Number() to normalize comparison
  const chartData = standar.map((s) => {
    const month = Number(s.nilai_sumbu_x);
    const point = riwayat.find((r) => Number(r.usia_ukur_bulan) === month);
    return {
      month,
      sd_3_neg: s.sd_3_neg,
      sd_2_neg: s.sd_2_neg,
      sd_1_neg: s.sd_1_neg,
      median: s.median,
      sd_1_pos: s.sd_1_pos,
      sd_2_pos: s.sd_2_pos,
      sd_3_pos: s.sd_3_pos,
      actual: point ? point[dataKey] : null,
    };
  });

  const colors = {
    sd3: "#ef4444", // Red
    sd2: "#f59e0b", // Orange
    sd1: "#10b981", // Green
    median: "#059669", // Dark Green
    actual: isLaki ? "#3b82f6" : "#ec4899"
  };

  return (
    <div className="w-full h-full">
      <h3 className="text-sm font-bold text-gray-700 mb-4 flex items-center gap-2">
        <div className={`w-1.5 h-4 rounded-full ${isLaki ? 'bg-blue-500' : 'bg-pink-500'}`}></div>
        {title}
      </h3>
      <ResponsiveContainer width="100%" height="90%">
        <ComposedChart data={chartData} margin={{ top: 5, right: 20, left: 0, bottom: 5 }}>
          <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
          <XAxis 
            dataKey="month" 
            fontSize={11} 
            tickMargin={8} 
            axisLine={false} 
            tickLine={false}
            label={{ value: 'Umur (Bulan)', position: 'insideBottomRight', offset: -5, fontSize: 10 }}
          />
          <YAxis 
            fontSize={11} 
            axisLine={false} 
            tickLine={false}
            label={{ value: unit, angle: -90, position: 'insideLeft', fontSize: 10 }}
          />
          <Tooltip 
            contentStyle={{ borderRadius: '12px', border: 'none', fontSize: '12px', boxShadow: '0 10px 15px -3px rgba(0, 0, 0, 0.1)' }}
          />
          
          {/* Background Reference Lines */}
          <Line type="monotone" dataKey="sd_3_pos" stroke={colors.sd3} strokeDasharray="5 5" dot={false} strokeWidth={1} name="+3 SD" />
          <Line type="monotone" dataKey="sd_2_pos" stroke={colors.sd2} dot={false} strokeWidth={1} name="+2 SD" />
          <Line type="monotone" dataKey="sd_1_pos" stroke={colors.sd1} dot={false} strokeWidth={1} name="+1 SD" />
          <Line type="monotone" dataKey="median" stroke={colors.median} strokeWidth={2} dot={false} name="Median" />
          <Line type="monotone" dataKey="sd_1_neg" stroke={colors.sd1} dot={false} strokeWidth={1} name="-1 SD" />
          <Line type="monotone" dataKey="sd_2_neg" stroke={colors.sd2} dot={false} strokeWidth={1} name="-2 SD" />
          <Line type="monotone" dataKey="sd_3_neg" stroke={colors.sd3} strokeDasharray="5 5" dot={false} strokeWidth={1} name="-3 SD" />

          {/* Child Actual Data */}
          <Line 
            type="monotone" 
            dataKey="actual" 
            stroke={colors.actual} 
            strokeWidth={4} 
            dot={{ r: 6, fill: colors.actual, strokeWidth: 2, stroke: '#fff' }} 
            activeDot={{ r: 8 }}
            name="Data Anak" 
            connectNulls
          />
        </ComposedChart>
      </ResponsiveContainer>
    </div>
  );
};

export default GrowthChart;
