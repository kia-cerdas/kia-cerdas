import React, { useState, useEffect } from "react";
import { useParams, Link } from "react-router-dom";
import MainLayout from "../../components/Layout/MainLayout";
import { getAnakById } from "../../services/Anak";
import { getPertumbuhanChart } from "../../services/pertumbuhan";
import GrowthChart from "../../components/Dashboard/GrowthChart";
import {
  ResponsiveContainer,
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
} from "recharts";

import {
  ChevronLeft, Baby, Ruler, Activity, Calendar, User,
  Plus, X, Apple, Syringe, TrendingUp, Smile, ChartLine, Stethoscope, ClipboardList
} from "lucide-react";

export default function AnakDashboard() {
  const { id } = useParams();
  const [child, setChild] = useState(null);
  const [chartData, setChartData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [activeChart, setActiveChart] = useState("bb_u"); // "bb_u" or "tb_u"

  useEffect(() => {
    let isMounted = true;
    const fetchDetailData = async () => {
      if (!id) return;
      try {
        setLoading(true);
        setError(null);
        const [resAnak, resChart] = await Promise.all([
          getAnakById(id),
          getPertumbuhanChart(id).catch(err => {
            console.warn("Error fetching chart data:", err);
            return { data: null };
          })
        ]);

        if (isMounted) {
          const childData = resAnak.data || resAnak;
          // Guard: pastikan data valid minimal punya nama/id
          if (childData && (childData.nama || childData.id)) {
            setChild(childData);
          } else {
            throw new Error("Data tidak ditemukan");
          }
          const chartResponse = resChart.data || resChart;
          console.log("🔍 Chart API Response:", chartResponse);
          if (chartResponse?.riwayat?.length > 0) {
            console.log("📊 Sample record:", chartResponse.riwayat[0]);
            console.log("🎯 LILA values:", chartResponse.riwayat.map(r => ({ usia: r.usia_ukur_bulan, lila: r.hasil_lila, lk: r.lingkar_kepala })));
          }
          setChartData(chartResponse);
        }
      } catch (err) {
        if (isMounted) {
          console.error("Error fetching detail data:", err);
          setError("Gagal mengambil data detail anak.");
        }
      } finally {
        if (isMounted) {
          setLoading(false);
        }
      }
    };
    fetchDetailData();
    return () => { isMounted = false; };
  }, [id]);

  if (loading) return <MainLayout><div className="p-10 text-center font-medium text-gray-400">Memuat...</div></MainLayout>;
  if (error) return <MainLayout><div className="p-10 text-center text-red-500">{error}</div></MainLayout>;

  const growthData = chartData?.riwayat || child?.pertumbuhan || [];
  const lastGrowth = growthData.length > 0 ? growthData[growthData.length - 1] : null;
  const isLaki = child?.jenis_kelamin?.toLowerCase() === "laki-laki";
  const themeColor = isLaki ? "#3b82f6" : "#ec4899";

  const menuInput = [
    { title: "Kesehatan Bayi", subtitle: "(0 - 28 Hari)", icon: <Baby size={32} />, link: `/data-anak/neonatus/${id}` },
    { title: "Gizi & Obat Cacing", icon: <Apple size={32} />, link: `/data-anak/pelayanan-gizi/${id}` },
    { title: "Imunisasi", icon: <Syringe size={32} />, link: `/data-anak/pelayanan-Imunisasi/${id}` },
    { title: "Kesehatan Gigi", icon: <Smile size={32} />, link: `/data-anak/pelayanan-Gigi/${id}` },
    { title: "Tumbuh Kembang", icon: <TrendingUp size={32} />, link: `/data-anak/Tumbuh-kembang-Anak/${id}` },
    { title: "Pencatatan LILA", icon: <Ruler size={32} />, link: `/data-anak/lila/${id}` },
    { title: "Pertumbuhan", icon: <Activity size={32} />, link: `/data-anak/pertumbuhan/${id}` },
    { title: "Keluhan Anak", icon: <Stethoscope size={32} />, link: `/data-anak/keluhan/${id}` },
  ];

  return (
    <MainLayout>
      <div className="p-4 md:p-8 bg-[#f8fafc] min-h-screen">

        {/* HEADER: Lebih rapat */}
        <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 mb-6">
          <div>
            <Link to="/daftar-anak" className="flex items-center gap-1.5 text-xs text-gray-400 hover:text-blue-600 mb-1 transition-all">
              <ChevronLeft size={14} /> Kembali
            </Link>
            <h1 className="text-2xl font-bold text-gray-800 tracking-tight">{child.nama}</h1>
          </div>
          <button
            onClick={() => setIsModalOpen(true)}
            className="bg-blue-600 hover:bg-blue-700 text-white px-5 py-2.5 rounded-xl flex items-center gap-2 text-sm font-semibold shadow-md transition-all active:scale-95"
          >
            <Plus size={18} /> Input Data
          </button>
        </div>

        {/* STAT CARDS: Lebih ramping */}
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-3 mb-6">
          <StatCard icon={<Calendar size={20} />} label="Usia" value={child.usia_teks || "-"} color="blue" />
          <StatCard icon={<User size={20} />} label="Ibu" value={child.kehamilan?.ibu?.nama_ibu || "-"} color="blue" />
          <StatCard icon={<Activity size={20} />} label="BB" value={lastGrowth?.berat_badan ? `${lastGrowth.berat_badan} kg` : "- kg"} color="blue" />
          <StatCard icon={<Ruler size={20} />} label="TB" value={lastGrowth?.tinggi_badan ? `${lastGrowth.tinggi_badan} cm` : "- cm"} color="blue" />
        </div>

        {/* GRAFIK: Tampilkan 4 grafik kecil dalam tata letak seperti gambar pertama */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
          <ChartCard title="Grafik Berat Badan (kg)" dataKey="berat_badan" data={growthData} color={themeColor} />
          <ChartCard title="Grafik Tinggi Badan (cm)" dataKey="tinggi_badan" data={growthData} color="#8b5cf6" />
          <ChartCard title="Grafik LILA (cm)" dataKey="hasil_lila" data={growthData} color="#f59e0b" />
          <ChartCard title="Grafik Lingkar Kepala (cm)" dataKey="lingkar_kepala" data={growthData} color="#10b981" />
        </div>

        {/* MODAL: Versi Ringkas (Compact) */}
        {isModalOpen && (
          <div className="fixed inset-0 z-[999] flex items-center justify-center p-6">
            {/* Overlay */}
            <div
              className="absolute inset-0 bg-black/20 backdrop-blur-[2px]"
              onClick={() => setIsModalOpen(false)}
            ></div>

            {/* Container Modal */}
            <div className="relative bg-[#F3F4F6] w-full max-w-lg rounded-[40px] p-8 shadow-2xl animate-in fade-in zoom-in duration-200">

              {/* Tombol Close (Opsional, di gambar tidak ada tapi bagus untuk UX) */}
              <button
                onClick={() => setIsModalOpen(false)}
                className="absolute -top-0 -right-0    z-[1000] bg-white text-gray-800 p-2 rounded-full shadow-lg border border-gray-100 hover:bg-gray-50 transition-all active:scale-90"
              >
                <X size={20} strokeWidth={3} />
              </button>

              {/* Grid Menu */}
              <div className="grid grid-cols-2 gap-5">
                {menuInput.map((item, idx) => (
                  <Link
                    key={idx}
                    to={item.link}
                    className={`
              relative bg-white p-6 rounded-[28px] flex flex-col items-center text-center justify-center gap-3 
              transition-all duration-200 group shadow-sm hover:shadow-md active:scale-95
              ${item.active ? 'border-[3px] border-blue-400' : 'border-[3px] border-transparent'}
            `}
                  >
                    {/* Icon Box */}
                    <div className="text-blue-600 transition-transform group-hover:scale-110">
                      {item.icon}
                    </div>

                    {/* Text Box */}
                    <div className="flex flex-col items-center">
                      <span className="text-[15px] font-bold text-gray-900 leading-tight">
                        {item.title}
                      </span>
                      {item.subtitle && (
                        <span className="text-[14px] font-bold text-gray-900 mt-1">
                          {item.subtitle}
                        </span>
                      )}
                    </div>
                  </Link>
                ))}
              </div>
            </div>
          </div>
        )}
      </div>
    </MainLayout>
  );
}

function StatCard({ icon, label, value, color }) {
  const colors = {
    orange: "bg-orange-50 text-orange-500",
    blue: "bg-blue-50 text-blue-500",
    green: "bg-green-50 text-green-500",
    purple: "bg-blue-50 text-blue-500",
  };
  return (
    <div className="bg-white p-3.5 rounded-xl border border-gray-100 flex items-center gap-3">
      <div className={`p-2 rounded-lg ${colors[color]}`}>{icon}</div>
      <div className="overflow-hidden">
        <p className="text-[10px] font-bold text-gray-400 uppercase tracking-tight">{label}</p>
        <p className="text-sm font-bold text-gray-800 truncate">{value}</p>
      </div>
    </div>
  );
}

function ChartCard({ title, dataKey, data = [], color = "#3b82f6" }) {
  const chartData = (data || [])
    .map((r) => ({
      name: `${r.usia_ukur_bulan} bln`,
      value: r && r[dataKey] !== null && r[dataKey] !== undefined ? Number(r[dataKey]) : null,
    }))
    .filter(d => d.value !== null && !isNaN(d.value));

  const hasData = chartData.length > 0;

  if (!hasData && dataKey !== "berat_badan" && dataKey !== "tinggi_badan") {
    console.log(`📉 No data for ${dataKey}:`, {
      totalRecords: data.length,
      sampleValues: data.slice(0, 3).map(r => r[dataKey])
    });
  }

  return (
    <div className="bg-white p-4 rounded-2xl border border-gray-100 shadow-sm h-[260px]">
      <div className="flex items-center justify-between mb-3">
        <h4 className="font-bold text-gray-700">{title}</h4>
        <div className="text-xs text-gray-400">Standar Permenkes 2/2020</div>
      </div>
      <div className="h-[180px]">
        {hasData ? (
          <ResponsiveContainer width="100%" height="100%">
            <LineChart data={chartData} margin={{ top: 5, right: 12, left: 0, bottom: 5 }}>
              <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" vertical={false} />
              <XAxis dataKey="name" tick={{ fontSize: 10 }} />
              <YAxis tick={{ fontSize: 10 }} />
              <Tooltip />
              <Line type="monotone" dataKey="value" stroke={color} strokeWidth={3} dot={{ r: 4 }} activeDot={{ r: 6 }} connectNulls />
            </LineChart>
          </ResponsiveContainer>
        ) : (
          <div className="h-full flex items-center justify-center text-gray-300 font-medium italic">Belum ada data untuk ditampilkan</div>
        )}
      </div>
      <div className="flex items-center gap-2 pt-3 text-sm text-gray-500">
        <span className="w-3 h-3 rounded-full" style={{ backgroundColor: color }} />
        <span className="font-semibold">Data anak</span>
      </div>
    </div>
  );
}