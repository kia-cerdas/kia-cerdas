// src/pages/Ibu/RujukanDashboard.jsx
import React, { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import MainLayout from "../../components/Layout/MainLayout";
import { getIbuList } from "../../services/ibu";
import { getKehamilanByIbuId } from "../../services/kehamilan";
import { getRujukanByKehamilanId } from "../../services/rujukanService";
import { FileText, ArrowRight, User, AlertCircle, Search, Calendar, Clock, Filter, ChevronDown, Baby } from "lucide-react";

export default function RujukanDashboard() {
  const [ibuList, setIbuList] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState("");
  const [statusFilter, setStatusFilter] = useState("all");
  const [sourceFilter, setSourceFilter] = useState("all");
  const [sortBy, setSortBy] = useState("terbaru");
  const [showFilterDropdown, setShowFilterDropdown] = useState(false);
  const [showSourceDropdown, setShowSourceDropdown] = useState(false);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const allIbu = await getIbuList();
        
        // Filter hanya ibu yang memiliki rujukan dari bidan
        const ibuWithRujukan = [];
        
        for (const ibu of allIbu || []) {
          try {
            // Ambil data kehamilan untuk ibu ini
            const kehamilanList = await getKehamilanByIbuId(ibu.id_ibu);
            
            // Cek apakah ada rujukan untuk kehamilan ini
            let hasRujukan = false;
            let rujukanData = null;
            let kehamilanData = null;
            
            if (kehamilanList && Array.isArray(kehamilanList)) {
              for (const kehamilan of kehamilanList) {
                const rujukanList = await getRujukanByKehamilanId(kehamilan.id);
                if (rujukanList && (Array.isArray(rujukanList) ? rujukanList.length > 0 : true)) {
                  hasRujukan = true;
                  rujukanData = Array.isArray(rujukanList) ? rujukanList[0] : rujukanList;
                  kehamilanData = kehamilan;
                  break;
                }
              }
            }
            
            // Tambahkan ke list jika ada rujukan
            if (hasRujukan) {
              ibuWithRujukan.push({
                ...ibu,
                rujukan: rujukanData,
                kehamilan: kehamilanData
              });
            }
          } catch (err) {
            console.error(`Gagal memproses ibu ${ibu.id_ibu}:`, err);
          }
        }
        
        setIbuList(ibuWithRujukan);
      } catch (err) {
        console.error("Gagal memuat daftar rujukan:", err);
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, []);

  // Get referral status
  const getReferralStatus = (rujukan) => {
    if (!rujukan) return { status: "pending", label: "Menunggu Respon", color: "yellow" };
    if (rujukan.rujukan_resume_pemeriksaan_tatalaksana && !rujukan.rujukan_balik_tanggal) {
      return { status: "responded", label: "Sudah Direspon", color: "blue" };
    }
    if (rujukan.rujukan_balik_tanggal) {
      return { status: "completed", label: "Selesai", color: "green" };
    }
    return { status: "pending", label: "Menunggu Respon", color: "yellow" };
  };

  // Get source label
  const getSourceLabel = (source) => {
    const sourceMap = {
      'preeklampsia': 'Skrining Preeklampsia',
      'anc': 'ANC Rutin',
      'dm_gestasional': 'DM Gestasional',
      'other': 'Lainnya'
    };
    return sourceMap[source] || source || 'ANC Rutin';
  };

  const getSourceColor = (source) => {
    const colorMap = {
      'preeklampsia': 'bg-purple-100 text-purple-700 border-purple-200',
      'anc': 'bg-blue-100 text-blue-700 border-blue-200',
      'dm_gestasional': 'bg-orange-100 text-orange-700 border-orange-200',
      'other': 'bg-gray-100 text-gray-700 border-gray-200'
    };
    return colorMap[source] || colorMap['anc'];
  };

  // Filter and sort
  const filteredList = ibuList
    .filter(ibu => {
      const matchesSearch =
        ibu.kependudukan?.nama_lengkap.toLowerCase().includes(searchTerm.toLowerCase()) ||
        ibu.kependudukan?.nik.includes(searchTerm);

      const referralStatus = getReferralStatus(ibu.rujukan).status;
      const matchesStatus = statusFilter === "all" || referralStatus === statusFilter;

      const source = ibu.rujukan?.source || 'anc';
      const matchesSource = sourceFilter === "all" || source === sourceFilter;

      return matchesSearch && matchesStatus && matchesSource;
    })
    .sort((a, b) => {
      if (sortBy === "terbaru") {
        return new Date(b.rujukan?.created_at || 0) - new Date(a.rujukan?.created_at || 0);
      } else if (sortBy === "terlama") {
        return new Date(a.rujukan?.created_at || 0) - new Date(b.rujukan?.created_at || 0);
      } else if (sortBy === "nama") {
        return a.kependudukan?.nama_lengkap.localeCompare(b.kependudukan?.nama_lengkap);
      }
      return 0;
    });

  const formatDate = (date) => {
    if (!date) return "-";
    return new Date(date).toLocaleDateString('id-ID', { day: 'numeric', month: 'short', year: 'numeric' });
  };

  if (loading) return <MainLayout><div className="p-6 text-center">Memuat data...</div></MainLayout>;

  return (
    <MainLayout>
      <div className="p-6 max-w-7xl mx-auto">
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">Daftar Rujukan Ibu</h1>
          <p className="text-gray-500 font-medium">Menerima dan mengelola daftar ibu yang memerlukan rujukan ke FKRTL.</p>
        </div>

        {/* Search and Filter Bar */}
        <div className="bg-white p-4 rounded-xl shadow-sm border border-gray-100 mb-6">
          <div className="flex flex-col lg:flex-row gap-4">
            {/* Search */}
            <div className="flex-1 relative">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
              <input
                type="text"
                placeholder="Cari berdasarkan Nama atau NIK..."
                className="w-full pl-10 pr-4 py-2.5 border border-gray-200 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 outline-none"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
              />
            </div>

            {/* Source Filter */}
            <div className="relative">
              <button
                onClick={() => setShowSourceDropdown(!showSourceDropdown)}
                className="flex items-center gap-2 px-4 py-2.5 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors"
              >
                <Filter size={18} className="text-gray-500" />
                <span className="text-sm font-medium text-gray-700">
                  {sourceFilter === "all" ? "Semua Sumber" :
                   sourceFilter === "preeklampsia" ? "Skrining Preeklampsia" :
                   sourceFilter === "anc" ? "ANC Rutin" :
                   sourceFilter === "dm_gestasional" ? "DM Gestasional" : "Lainnya"}
                </span>
                <ChevronDown size={16} className="text-gray-400" />
              </button>

              {showSourceDropdown && (
                <div className="absolute right-0 mt-2 w-48 bg-white rounded-lg shadow-lg border border-gray-100 z-10">
                  <button
                    onClick={() => { setSourceFilter("all"); setShowSourceDropdown(false); }}
                    className="w-full px-4 py-2 text-left text-sm hover:bg-gray-50 first:rounded-t-lg"
                  >
                    Semua Sumber
                  </button>
                  <button
                    onClick={() => { setSourceFilter("preeklampsia"); setShowSourceDropdown(false); }}
                    className="w-full px-4 py-2 text-left text-sm hover:bg-gray-50"
                  >
                    Skrining Preeklampsia
                  </button>
                  <button
                    onClick={() => { setSourceFilter("anc"); setShowSourceDropdown(false); }}
                    className="w-full px-4 py-2 text-left text-sm hover:bg-gray-50"
                  >
                    ANC Rutin
                  </button>
                  <button
                    onClick={() => { setSourceFilter("dm_gestasional"); setShowSourceDropdown(false); }}
                    className="w-full px-4 py-2 text-left text-sm hover:bg-gray-50 last:rounded-b-lg"
                  >
                    DM Gestasional
                  </button>
                </div>
              )}
            </div>

            {/* Status Filter */}
            <div className="relative">
              <button
                onClick={() => setShowFilterDropdown(!showFilterDropdown)}
                className="flex items-center gap-2 px-4 py-2.5 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors"
              >
                <Clock size={18} className="text-gray-500" />
                <span className="text-sm font-medium text-gray-700">
                  {statusFilter === "all" ? "Semua Status" :
                   statusFilter === "pending" ? "Menunggu Respon" :
                   statusFilter === "responded" ? "Sudah Direspon" : "Selesai"}
                </span>
                <ChevronDown size={16} className="text-gray-400" />
              </button>

              {showFilterDropdown && (
                <div className="absolute right-0 mt-2 w-48 bg-white rounded-lg shadow-lg border border-gray-100 z-10">
                  <button
                    onClick={() => { setStatusFilter("all"); setShowFilterDropdown(false); }}
                    className="w-full px-4 py-2 text-left text-sm hover:bg-gray-50 first:rounded-t-lg"
                  >
                    Semua Status
                  </button>
                  <button
                    onClick={() => { setStatusFilter("pending"); setShowFilterDropdown(false); }}
                    className="w-full px-4 py-2 text-left text-sm hover:bg-gray-50"
                  >
                    Menunggu Respon
                  </button>
                  <button
                    onClick={() => { setStatusFilter("responded"); setShowFilterDropdown(false); }}
                    className="w-full px-4 py-2 text-left text-sm hover:bg-gray-50"
                  >
                    Sudah Direspon
                  </button>
                  <button
                    onClick={() => { setStatusFilter("completed"); setShowFilterDropdown(false); }}
                    className="w-full px-4 py-2 text-left text-sm hover:bg-gray-50 last:rounded-b-lg"
                  >
                    Selesai
                  </button>
                </div>
              )}
            </div>

            {/* Sort */}
            <select
              value={sortBy}
              onChange={(e) => setSortBy(e.target.value)}
              className="px-4 py-2.5 border border-gray-200 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 outline-none text-sm"
            >
              <option value="terbaru">Terbaru</option>
              <option value="terlama">Terlama</option>
              <option value="nama">Nama A-Z</option>
            </select>
          </div>
        </div>

        {/* Stats */}
        <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-4 mb-6">
          <div className="bg-white p-4 rounded-xl border border-gray-100">
            <p className="text-2xl font-bold text-gray-900">{ibuList.length}</p>
            <p className="text-xs text-gray-500 font-medium">Total Rujukan</p>
          </div>
          <div className="bg-purple-50 p-4 rounded-xl border border-purple-100">
            <p className="text-2xl font-bold text-purple-700">{ibuList.filter(i => (i.rujukan?.source || 'anc') === 'preeklampsia').length}</p>
            <p className="text-xs text-purple-600 font-medium">Preeklampsia</p>
          </div>
          <div className="bg-blue-50 p-4 rounded-xl border border-blue-100">
            <p className="text-2xl font-bold text-blue-700">{ibuList.filter(i => (i.rujukan?.source || 'anc') === 'anc').length}</p>
            <p className="text-xs text-blue-600 font-medium">ANC Rutin</p>
          </div>
          <div className="bg-yellow-50 p-4 rounded-xl border border-yellow-100">
            <p className="text-2xl font-bold text-yellow-700">{ibuList.filter(i => getReferralStatus(i.rujukan).status === 'pending').length}</p>
            <p className="text-xs text-yellow-600 font-medium">Menunggu Respon</p>
          </div>
          <div className="bg-indigo-50 p-4 rounded-xl border border-indigo-100">
            <p className="text-2xl font-bold text-indigo-700">{ibuList.filter(i => getReferralStatus(i.rujukan).status === 'responded').length}</p>
            <p className="text-xs text-indigo-600 font-medium">Sudah Direspon</p>
          </div>
          <div className="bg-green-50 p-4 rounded-xl border border-green-100">
            <p className="text-2xl font-bold text-green-700">{ibuList.filter(i => getReferralStatus(i.rujukan).status === 'completed').length}</p>
            <p className="text-xs text-green-600 font-medium">Selesai</p>
          </div>
        </div>

        {/* Cards Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredList.map((ibu) => {
            const referralStatus = getReferralStatus(ibu.rujukan);
            const statusColors = {
              yellow: "bg-yellow-100 text-yellow-700 border-yellow-200",
              blue: "bg-blue-100 text-blue-700 border-blue-200",
              green: "bg-green-100 text-green-700 border-green-200"
            };
            const source = ibu.rujukan?.source || 'anc';

            return (
              <div key={ibu.id_ibu} className="bg-white rounded-2xl shadow-sm border border-gray-100 hover:shadow-lg transition-all duration-300 overflow-hidden group">
                <div className="p-5">
                  {/* Header */}
                  <div className="flex items-start justify-between mb-4">
                    <div className="p-3 bg-indigo-50 rounded-xl text-indigo-600 group-hover:bg-indigo-600 group-hover:text-white transition-colors duration-300">
                      <User size={24} />
                    </div>
                    <div className="flex flex-col gap-2 items-end">
                      <span className={`text-xs font-bold px-3 py-1 rounded-full border ${getSourceColor(source)}`}>
                        {getSourceLabel(source)}
                      </span>
                      <span className={`text-xs font-bold px-3 py-1 rounded-full border ${statusColors[referralStatus.color]}`}>
                        {referralStatus.label}
                      </span>
                    </div>
                  </div>

                  {/* Name and NIK */}
                  <div className="mb-4">
                    <h3 className="text-lg font-bold text-gray-900 group-hover:text-indigo-600 transition-colors line-clamp-1">
                      {ibu.kependudukan?.nama_lengkap || "Tanpa Nama"}
                    </h3>
                    <p className="text-sm text-gray-400 font-medium tracking-wide">NIK: {ibu.kependudukan?.nik || "-"}</p>
                  </div>

                  {/* Info Grid */}
                  <div className="grid grid-cols-2 gap-3 mb-4">
                    <div className="bg-gray-50 p-2.5 rounded-lg">
                      <div className="flex items-center gap-1.5 text-gray-500 mb-1">
                        <Baby size={14} />
                        <span className="text-xs font-medium">Usia Kehamilan</span>
                      </div>
                      <p className="text-sm font-bold text-gray-900">{ibu.kehamilan?.usia_kehamilan_minggu || "-"} minggu</p>
                    </div>
                    <div className="bg-gray-50 p-2.5 rounded-lg">
                      <div className="flex items-center gap-1.5 text-gray-500 mb-1">
                        <Calendar size={14} />
                        <span className="text-xs font-medium">Tanggal Rujukan</span>
                      </div>
                      <p className="text-sm font-bold text-gray-900">{formatDate(ibu.rujukan?.created_at)}</p>
                    </div>
                  </div>

                  {/* Status Badge */}
                  <div className="flex items-center gap-2 text-amber-600 bg-amber-50 px-3 py-2 rounded-lg mb-4">
                    <AlertCircle size={16} />
                    <span className="text-xs font-bold uppercase tracking-tight">Perlu Perhatian</span>
                  </div>
                  
                  {/* Action Button */}
                  <Link
                    to={`/data-ibu/${ibu.id_ibu}/rujukan?kehamilan_id=${ibu.kehamilan?.id}&source=${source}`}
                    className="w-full flex items-center justify-center gap-2 bg-gray-50 text-gray-700 font-bold py-3 rounded-xl hover:bg-indigo-600 hover:text-white transition-all duration-300"
                  >
                    <FileText size={18} />
                    Lihat Detail Rujukan
                    <ArrowRight size={16} />
                  </Link>
                </div>
              </div>
            );
          })}
        </div>

        {filteredList.length === 0 && (
          <div className="text-center py-20 bg-gray-50 rounded-3xl border-2 border-dashed border-gray-200">
            <Search className="mx-auto text-gray-300 mb-4" size={48} />
            <p className="text-gray-500 font-medium text-lg">Tidak ada data ibu yang ditemukan.</p>
          </div>
        )}
      </div>
    </MainLayout>
  );
}
