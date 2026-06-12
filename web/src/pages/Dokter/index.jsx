import React, { useEffect, useState } from "react";
import MainLayout from "../../components/Layout/MainLayout";
import { getCurrentUser } from '../../services/auth';
import { Stethoscope, Users, Calendar, FileText } from "lucide-react";

const DokterDashboard = () => {
  const [user, setUser] = useState(null);
  const [stats, setStats] = useState({
    totalPasien: 0,
    jadwalHariIni: 0,
    pemeriksaanSelesai: 0,
    rujukan: 0,
  });

  useEffect(() => {
    const currentUser = getCurrentUser();
    setUser(currentUser);
    fetchDashboardData();
  }, []);

  const fetchDashboardData = async () => {
    try {
      setStats({
        totalPasien: 124,
        jadwalHariIni: 8,
        pemeriksaanSelesai: 42,
        rujukan: 3,
      });
    } catch (error) {
      console.error("Gagal memuat dashboard:", error);
    }
  };

  return (
    <MainLayout>
      <div className="p-6">
        <div className="mb-6">
          <h1 className="text-2xl font-bold text-gray-800">Dashboard Dokter</h1>
          <p className="text-gray-500">
            Selamat datang, dr. {user?.nama || user?.name || "Dokter"}
          </p>
        </div>

        {/* Grid Statistik */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-5 mb-8">
          <div className="bg-white p-5 rounded-xl shadow-sm border border-gray-100">
            <div className="flex justify-between items-start">
              <div>
                <p className="text-gray-500 text-sm font-medium">Total Pasien</p>
                <p className="text-2xl font-bold text-gray-800 mt-1">{stats.totalPasien}</p>
                <p className="text-xs text-gray-400 mt-1">+12%</p>
              </div>
              <div className="p-3 rounded-lg bg-blue-100 text-blue-800">
                <Users className="w-6 h-6 text-blue-600" />
              </div>
            </div>
          </div>
          <div className="bg-white p-5 rounded-xl shadow-sm border border-gray-100">
            <div className="flex justify-between items-start">
              <div>
                <p className="text-gray-500 text-sm font-medium">Jadwal Hari Ini</p>
                <p className="text-2xl font-bold text-gray-800 mt-1">{stats.jadwalHariIni}</p>
                <p className="text-xs text-gray-400 mt-1">3 pending</p>
              </div>
              <div className="p-3 rounded-lg bg-green-100 text-green-800">
                <Calendar className="w-6 h-6 text-green-600" />
              </div>
            </div>
          </div>
          <div className="bg-white p-5 rounded-xl shadow-sm border border-gray-100">
            <div className="flex justify-between items-start">
              <div>
                <p className="text-gray-500 text-sm font-medium">Pemeriksaan Selesai</p>
                <p className="text-2xl font-bold text-gray-800 mt-1">{stats.pemeriksaanSelesai}</p>
              </div>
              <div className="p-3 rounded-lg bg-purple-100 text-purple-800">
                <FileText className="w-6 h-6 text-purple-600" />
              </div>
            </div>
          </div>
          <div className="bg-white p-5 rounded-xl shadow-sm border border-gray-100">
            <div className="flex justify-between items-start">
              <div>
                <p className="text-gray-500 text-sm font-medium">Rujukan</p>
                <p className="text-2xl font-bold text-gray-800 mt-1">{stats.rujukan}</p>
              </div>
              <div className="p-3 rounded-lg bg-orange-100 text-orange-800">
                <Stethoscope className="w-6 h-6 text-orange-600" />
              </div>
            </div>
          </div>
        </div>

        {/* Jadwal & Pasien Terbaru */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div className="bg-white rounded-xl shadow-sm p-5 border border-gray-100">
            <h2 className="text-lg font-semibold text-gray-800 mb-4 flex items-center gap-2">
              <Calendar className="w-5 h-5 text-blue-600" />
              Jadwal Pemeriksaan Hari Ini
            </h2>
            <p className="text-gray-400 text-sm">Belum ada jadwal atau data belum dimuat.</p>
          </div>
          <div className="bg-white rounded-xl shadow-sm p-5 border border-gray-100">
            <h2 className="text-lg font-semibold text-gray-800 mb-4 flex items-center gap-2">
              <Users className="w-5 h-5 text-green-600" />
              Pasien Terbaru
            </h2>
            <p className="text-gray-400 text-sm">Belum ada data pasien.</p>
          </div>
        </div>
      </div>
    </MainLayout>
  );
};

export default DokterDashboard;