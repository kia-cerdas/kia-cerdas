// src/pages/Ibu/RujukanDashboard.jsx
import React, { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import MainLayout from "../../components/Layout/MainLayout";
import { getIbuList } from "../../services/ibu";
import { getKehamilanByIbuId } from "../../services/kehamilan";
import { getRujukanByKehamilanId } from "../../services/rujukanService";
import { FileText, ArrowRight, User, AlertCircle, Search } from "lucide-react";

export default function RujukanDashboard() {
  const [ibuList, setIbuList] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState("");

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
            if (kehamilanList && Array.isArray(kehamilanList)) {
              for (const kehamilan of kehamilanList) {
                const rujukanList = await getRujukanByKehamilanId(kehamilan.id);
                if (rujukanList && (Array.isArray(rujukanList) ? rujukanList.length > 0 : true)) {
                  hasRujukan = true;
                  break;
                }
              }
            }
            
            // Tambahkan ke list jika ada rujukan
            if (hasRujukan) {
              ibuWithRujukan.push(ibu);
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

  const filteredList = ibuList.filter(ibu => 
    ibu.kependudukan?.nama_lengkap.toLowerCase().includes(searchTerm.toLowerCase()) ||
    ibu.kependudukan?.nik.includes(searchTerm)
  );

  if (loading) return <MainLayout><div className="p-6 text-center">Memuat data...</div></MainLayout>;

  return (
    <MainLayout>
      <div className="p-6 max-w-6xl mx-auto">
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">Daftar Rujukan Ibu</h1>
          <p className="text-gray-500 font-medium">Menerima dan mengelola daftar ibu yang memerlukan rujukan ke FKRTL.</p>
        </div>

        {/* Search Bar */}
        <div className="bg-white p-4 rounded-xl shadow-sm border border-gray-100 mb-6 flex items-center gap-4">
          <div className="flex-1 relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
            <input 
              type="text" 
              placeholder="Cari berdasarkan Nama atau NIK..." 
              className="w-full pl-10 pr-4 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 outline-none"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredList.map((ibu) => (
            <div key={ibu.id_ibu} className="bg-white rounded-2xl shadow-sm border border-gray-100 hover:shadow-lg transition-all duration-300 overflow-hidden group">
              <div className="p-6">
                <div className="flex items-start justify-between mb-4">
                  <div className="p-3 bg-indigo-50 rounded-xl text-indigo-600 group-hover:bg-indigo-600 group-hover:text-white transition-colors duration-300">
                    <User size={24} />
                  </div>
                  <div className="flex flex-col items-end">
                    <span className={`text-[10px] uppercase font-bold px-2 py-1 rounded-md ${ibu.status_kehamilan === 'Hamil' ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-600'}`}>
                      {ibu.status_kehamilan}
                    </span>
                  </div>
                </div>

                <div className="mb-6">
                  <h3 className="text-lg font-bold text-gray-900 group-hover:text-indigo-600 transition-colors">{ibu.kependudukan?.nama_lengkap || "Tanpa Nama"}</h3>
                  <p className="text-sm text-gray-400 font-medium tracking-wide">NIK: {ibu.kependudukan?.nik || "-"}</p>
                </div>

                <div className="flex items-center gap-2 text-amber-600 bg-amber-50 px-3 py-2 rounded-lg mb-6">
                  <AlertCircle size={16} />
                  <span className="text-xs font-bold uppercase tracking-tight">Periksa Status Rujukan</span>
                </div>
                
                <Link 
                  to={`/data-ibu/${ibu.id_ibu}/rujukan`}
                  className="w-full flex items-center justify-center gap-2 bg-gray-50 text-gray-700 font-bold py-3 rounded-xl hover:bg-indigo-600 hover:text-white transition-all duration-300"
                >
                  <FileText size={18} />
                  Lihat Proposal Rujukan
                  <ArrowRight size={16} />
                </Link>
              </div>
            </div>
          ))}
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
