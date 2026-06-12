import React, { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import MainLayout from "../../components/Layout/MainLayout";
import { EDUKASI_RESOURCES, listEdukasi } from "../../services/edukasiDigital";

export default function EdukasiDigitalIndex() {
  const navigate = useNavigate();
  const [data, setData] = useState({});
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadData = async () => {
      const newData = {};
      for (const [key, resource] of Object.entries(EDUKASI_RESOURCES)) {
        try {
          const items = await listEdukasi(resource.path);
          newData[key] = {
            items: Array.isArray(items) ? items.slice(0, 3) : [], // Show only first 3 items
            count: Array.isArray(items) ? items.length : 0
          };
        } catch (error) {
          newData[key] = { items: [], count: 0 };
        }
      }
      setData(newData);
      setLoading(false);
    };

    loadData();
  }, []);

  const handleLihatSemua = (resourcePath) => {
    // Hapus prefix "edukasi-" dari path untuk mendapatkan route segment
    const segment = resourcePath.replace(/^edukasi-/, "");
    navigate(`/edukasi-digital/${segment}`);
  };

  const handleTambah = (resourcePath) => {
    const segment = resourcePath.replace(/^edukasi-/, "");
    navigate(`/edukasi-digital/${segment}`);
  };

  return (
    <MainLayout>
      <div className="space-y-6">
        {/* Header */}
        <section className="bg-white rounded-2xl border border-slate-100 p-6 shadow-sm">
          <h1 className="text-2xl font-bold text-slate-800">Edukasi Digital</h1>
          <p className="text-sm text-slate-500 mt-2">
            Kelola konten edukasi digital untuk ibu dan keluarga.
          </p>
        </section>

        {/* Categories Grid */}
        {Object.entries(EDUKASI_RESOURCES).map(([key, resource]) => {
          const categoryData = data[key] || { items: [], count: 0 };

          return (
            <section key={key} className="bg-white rounded-2xl border border-slate-100 p-6 shadow-sm">
              {/* Category Header */}
              <div className="flex items-center justify-between mb-4">
                <div>
                  <h2 className="text-lg font-semibold text-slate-800">{resource.label}</h2>
                  <p className="text-sm text-slate-500">
                    {loading ? "Memuat..." : `${categoryData.count} konten tersedia`}
                  </p>
                </div>
                <div className="flex gap-2">
                  <button
                    onClick={() => handleLihatSemua(resource.path)}
                    className="px-4 py-2 rounded-lg bg-slate-100 text-slate-700 text-sm font-semibold hover:bg-slate-200 transition-colors"
                  >
                    Lihat Semua
                  </button>
                  <button
                    onClick={() => handleTambah(resource.path)}
                    className="px-4 py-2 rounded-lg bg-blue-600 text-white text-sm font-semibold hover:bg-blue-700 transition-colors flex items-center gap-1"
                  >
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                      <line x1="12" y1="5" x2="12" y2="19"></line>
                      <line x1="5" y1="12" x2="19" y2="12"></line>
                    </svg>
                    Tambah Konten
                  </button>
                </div>
              </div>

              {/* Content Preview */}
              <div className="space-y-3">
                {loading ? (
                  <div className="text-center py-8">
                    <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
                    <p className="text-sm text-slate-500 mt-2">Memuat data...</p>
                  </div>
                ) : categoryData.items.length === 0 ? (
                  <div className="text-center py-8 border-2 border-dashed border-slate-200 rounded-xl">
                    <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1" strokeLinecap="round" strokeLinejoin="round" className="text-slate-400 mx-auto mb-2">
                      <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
                      <polyline points="14,2 14,8 20,8"></polyline>
                      <line x1="16" y1="13" x2="8" y2="13"></line>
                      <line x1="16" y1="17" x2="8" y2="17"></line>
                      <polyline points="10,9 9,9 8,9"></polyline>
                    </svg>
                    <p className="text-sm text-slate-500">Belum ada konten</p>
                    <p className="text-xs text-slate-400 mt-1">Klik "Tambah Konten" untuk membuat konten pertama</p>
                  </div>
                ) : (
                  <>
                    <div className="grid gap-3">
                      {categoryData.items.map((item, index) => (
                        <article
                          key={item.id || item.ID || index}
                          className="border border-slate-200 rounded-lg p-4 hover:bg-slate-50 transition-colors cursor-pointer"
                          onClick={() => handleLihatSemua(resource.path)}
                        >
                          <h3 className="font-medium text-slate-800 mb-1">
                            {item.judul || "Tanpa Judul"}
                          </h3>
                          <p className="text-sm text-slate-600 line-clamp-2">
                            {item.deskripsi || item.isi_konten || "Tidak ada deskripsi"}
                          </p>
                          <div className="flex items-center justify-between mt-2">
                            <span className="text-xs text-slate-400">
                              {item.created_at ? new Date(item.created_at).toLocaleDateString('id-ID') : ''}
                            </span>
                            <span className="text-xs bg-blue-100 text-blue-700 px-2 py-1 rounded">
                              Klik untuk melihat detail
                            </span>
                          </div>
                        </article>
                      ))}
                    </div>

                    {categoryData.count > 3 && (
                      <div className="text-center pt-2">
                        <button
                          onClick={() => handleLihatSemua(resource.path)}
                          className="text-sm text-blue-600 hover:text-blue-700 font-medium"
                        >
                          Lihat {categoryData.count - 3} konten lainnya →
                        </button>
                      </div>
                    )}
                  </>
                )}
              </div>
            </section>
          );
        })}
      </div>
    </MainLayout>
  );
}
