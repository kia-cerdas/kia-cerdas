import React, { useEffect, useState } from "react";
import MainLayout from "../../components/Layout/MainLayout";
import { useNavigate } from "react-router-dom";
import { Search, Calendar, User, ChevronRight, ClipboardList, Trash2, Home } from "lucide-react";
import { getLingkunganHistory, deleteLingkungan } from "../../services/kesehatanLingkungan";

export default function DataLingkungan() {
  const navigate = useNavigate();
  const [history, setHistory] = useState([]);
  const [query, setQuery] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState("");

  const fetchData = async () => {
    setIsLoading(true);
    try {
      const res = await getLingkunganHistory();
      setHistory(res);
    } catch (e) {
      setErrorMsg("Gagal memuat data kesehatan lingkungan");
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  const filteredData = history.filter(item => 
    item.ibu?.nama?.toLowerCase().includes(query.toLowerCase()) ||
    item.pemeriksa?.toLowerCase().includes(query.toLowerCase())
  );

  const handleDelete = async (id) => {
    if (!window.confirm("Hapus data pencatatan ini?")) return;
    try {
      await deleteLingkungan(id);
      fetchData();
    } catch (e) {
      alert("Gagal menghapus data");
    }
  };

  return (
    <MainLayout>
      <div className="max-w-6xl mx-auto space-y-6">
        <div className="flex justify-center">
          <div className="relative w-full max-w-2xl">
            <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" size={18} />
            <input 
              type="text"
              placeholder="Cari berdasarkan nama ibu atau pemeriksa..."
              className="w-full pl-12 pr-4 py-3 bg-white border border-slate-100 rounded-full text-sm shadow-sm focus:ring-2 focus:ring-blue-100 outline-none transition-all"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
            />
          </div>
        </div>

        <div className="flex items-center justify-between px-2">
          <div>
            <h1 className="text-2xl font-bold text-slate-800">Data Kesehatan Lingkungan</h1>
            <p className="text-sm text-slate-500 mt-1">Daftar laporan kesehatan dan keselamatan lingkungan yang diisi oleh Ibu.</p>
          </div>
        </div>

        {errorMsg && <div className="rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">{errorMsg}</div>}

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {isLoading ? (
            <div className="col-span-full py-20 text-center text-slate-400 italic">Memuat data...</div>
          ) : filteredData.length > 0 ? (
            filteredData.map((item) => (
              <div key={item.id} className="bg-white rounded-3xl border border-slate-100 p-6 shadow-sm hover:shadow-md transition-all group relative overflow-hidden">
                <div className="absolute top-0 right-0 w-32 h-32 bg-blue-50/50 rounded-full -mr-16 -mt-16 group-hover:scale-110 transition-transform duration-500" />
                
                <div className="relative space-y-4">
                  <div className="flex items-center gap-4">
                    <div className="w-12 h-12 bg-blue-100 text-blue-600 rounded-2xl flex items-center justify-center">
                      <Home size={24} />
                    </div>
                    <div>
                      <h3 className="font-bold text-slate-800">{item.ibu?.nama || "Ibu Tidak Diketahui"}</h3>
                      <p className="text-[10px] text-slate-400 uppercase font-black tracking-widest">Laporan Lingkungan</p>
                    </div>
                  </div>

                  <div className="grid grid-cols-2 gap-3">
                    <div className="bg-slate-50 rounded-2xl p-3">
                      <div className="flex items-center gap-2 text-slate-400 mb-1">
                        <Calendar size={14} />
                        <span className="text-[10px] font-bold uppercase">Tanggal</span>
                      </div>
                      <p className="text-xs font-semibold text-slate-700">
                        {new Date(item.tanggal_periksa).toLocaleDateString("id-ID", {
                          day: "2-digit",
                          month: "short",
                          year: "numeric"
                        })}
                      </p>
                    </div>
                    <div className="bg-slate-50 rounded-2xl p-3">
                      <div className="flex items-center gap-2 text-slate-400 mb-1">
                        <User size={14} />
                        <span className="text-[10px] font-bold uppercase">Pemeriksa</span>
                      </div>
                      <p className="text-xs font-semibold text-slate-700 truncate">{item.pemeriksa || "-"}</p>
                    </div>
                  </div>

                  <div className="pt-4 flex items-center justify-between">
                    <div className="flex gap-1 text-[10px] font-bold text-slate-400">
                      <span>{item.detail_jawaban?.length || 0} Indikator Dinilai</span>
                    </div>
                    <div className="flex gap-2">
                      <button 
                        onClick={() => handleDelete(item.id)}
                        className="p-2 text-red-400 hover:bg-red-50 hover:text-red-600 rounded-xl transition-all"
                      >
                        <Trash2 size={18} />
                      </button>
                      <button 
                        onClick={() => navigate(`/pencatatan/kesehatan-lingkungan/detail/${item.id}`)}
                        className="p-2 text-blue-600 bg-blue-50 hover:bg-blue-600 hover:text-white rounded-xl transition-all flex items-center gap-2 px-4 text-xs font-bold">
                        DETAIL <ChevronRight size={14} />
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            ))
          ) : (
            <div className="col-span-full py-20 text-center">
              <ClipboardList className="mx-auto text-slate-200 mb-4" size={64} />
              <p className="text-slate-400 text-lg font-medium">Belum ada data pencatatan lingkungan.</p>
            </div>
          )}
        </div>
      </div>
    </MainLayout>
  );
}
