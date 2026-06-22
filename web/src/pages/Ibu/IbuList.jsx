  // src/pages/Ibu/IbuList.jsx
  import React, { useEffect, useState, useMemo } from "react";
  import { Link, useNavigate } from "react-router-dom";
  import MainLayout from "../../components/Layout/MainLayout";
  import { getIbuDashboard } from "../../services/ibu";
  import { 
    Plus, Search, Users, Eye, Edit, Filter, 
    Activity, AlertTriangle, UserCheck
  } from "lucide-react";

  // Badge untuk status kehamilan (trimester + nifas)
  const statusBadge = (status) => {
    if (status === "TRIMESTER 1") return "bg-[#E1F5EE] text-[#085041]";
    if (status === "TRIMESTER 2") return "bg-[#FAEEDA] text-[#633806]";
    if (status === "TRIMESTER 3") return "bg-[#DCFCE7] text-[#3B6D11]";
    if (status === "NIFAS") return "bg-[#DBEAFE] text-[#1E3A8A]";       // biru untuk nifas
    if (status === "NON-AKTIF") return "bg-gray-200 text-gray-700";
    return "bg-gray-100 text-gray-800";
  };

  // Normalisasi risiko
  const normalizeRiskStatus = (risk) => {
    if (!risk || risk.trim() === "") return "BELUM_DIPERIKSA";
    const upperRisk = risk.toUpperCase();
    if (upperRisk === "PERLU RUJUKAN" || upperRisk === "TINGGI") return "PERLU_RUJUKAN";
    if (upperRisk === "PERLU TINDAKAN" || upperRisk === "SEDANG") return "PERLU_TINDAKAN";
    if (upperRisk === "NORMAL" || upperRisk === "RENDAH" || upperRisk === "RISIKO RENDAH") return "NORMAL";
    return "BELUM_DIPERIKSA";
  };

  const riskLabel = (risk) => {
    const normalized = normalizeRiskStatus(risk);
    if (normalized === "PERLU_RUJUKAN") {
      return { label: "Tinggi", class: "bg-red-100 text-red-700 border border-red-200" };
    }
    if (normalized === "PERLU_TINDAKAN") {
      return { label: "Sedang", class: "bg-yellow-100 text-yellow-700 border border-yellow-200" };
    }
    if (normalized === "NORMAL") {
      return { label: "Normal", class: "bg-green-100 text-green-700 border border-green-200" };
    }
    return { label: "Belum Diperiksa", class: "bg-gray-100 text-gray-500 border border-gray-200" };
  };

  export default function IbuList() {
    const navigate = useNavigate();
    const [ibuList, setIbuList] = useState([]);
    const [loading, setLoading] = useState(true);
    const [search, setSearch] = useState("");
    const [debouncedSearch, setDebouncedSearch] = useState("");
    const [filterRisiko, setFilterRisiko] = useState("");
    const [filterTrimester, setFilterTrimester] = useState("");
    const [showHistory, setShowHistory] = useState(false);
    const [currentPage, setCurrentPage] = useState(1);
    const [itemsPerPage, setItemsPerPage] = useState(10);

    // Fetch data
    useEffect(() => {
      const fetchData = async () => {
        try {
          const data = await getIbuDashboard();
          setIbuList(data || []);
        } catch (err) {
          console.error(err);
          setIbuList([]);
        } finally {
          setLoading(false);
        }
      };
      fetchData();
    }, []);

    // Debounce search
    useEffect(() => {
      const timer = setTimeout(() => setDebouncedSearch(search), 300);
      return () => clearTimeout(timer);
    }, [search]);

    // Reset page saat filter berubah
    useEffect(() => {
      setCurrentPage(1);
    }, [debouncedSearch, filterRisiko, filterTrimester, showHistory]);

    // Data aktif = TRIMESTER 1/2/3 atau NIFAS
  const activeOnlyList = useMemo(() => {
    return ibuList.filter(ibu => {
      const status = (ibu.status_kehamilan || "").toUpperCase();
      return (
        status.startsWith("TRIMESTER") || 
        status === "NIFAS" || 
        status === "" ||        // ← status kosong
        status === "AKTIF" ||   // ← kemungkinan nilai lain dari backend
        status === "HAMIL"      // ← kemungkinan nilai lain dari backend
      );
    });
  }, [ibuList]);

    // Data riwayat = NON-AKTIF
    const historyList = useMemo(() => {
      return ibuList.filter(ibu => ibu.status_kehamilan === "NON-AKTIF");
    }, [ibuList]);

    // Data yang ditampilkan sesuai toggle
    const displayedData = useMemo(() => {
      let data = showHistory ? historyList : activeOnlyList;

      if (debouncedSearch) {
        data = data.filter(ibu =>
          ibu.nama_lengkap?.toLowerCase().includes(debouncedSearch.toLowerCase())
        );
      }
      if (filterRisiko) {
        data = data.filter(ibu => 
          normalizeRiskStatus(ibu.status_risiko) === filterRisiko
        );
      }
      if (filterTrimester && !showHistory) {
        // Filter trimester hanya untuk data aktif (karena riwayat tidak punya trimester)
        data = data.filter(ibu => ibu.status_kehamilan === filterTrimester);
      }
      return data.sort((a, b) => (b.id_ibu || 0) - (a.id_ibu || 0));
    }, [activeOnlyList, historyList, showHistory, debouncedSearch, filterRisiko, filterTrimester]);

    // Statistik berdasarkan risiko pada kehamilan aktif (TRIMESTER + NIFAS)
    const totalAktifRows = activeOnlyList.length;
    const totalTinggi = activeOnlyList.filter(i => normalizeRiskStatus(i.status_risiko) === "PERLU_RUJUKAN").length;
    const totalSedang = activeOnlyList.filter(i => normalizeRiskStatus(i.status_risiko) === "PERLU_TINDAKAN").length;
    const totalNormal = activeOnlyList.filter(i => normalizeRiskStatus(i.status_risiko) === "NORMAL").length;

    // Jumlah ibu unik aktif (bukan kehamilan)
    const uniqueIbuAktif = new Set(activeOnlyList.map(i => i.id_ibu)).size;

    // Pagination
    const totalPages = Math.ceil(displayedData.length / itemsPerPage);
    const startIndex = (currentPage - 1) * itemsPerPage;
    const paginatedData = displayedData.slice(startIndex, startIndex + itemsPerPage);

    const filterByRisiko = (risiko) => {
      setFilterRisiko(prev => prev === risiko ? "" : risiko);
      setCurrentPage(1);
      setShowHistory(false);
    };

    const EmptyState = () => (
      <div className="text-center py-12">
        <Users size={48} className="mx-auto text-gray-300" />
        <p className="mt-2 text-gray-600 text-base">
          {showHistory ? "Tidak ada 0 kehamilan yang tersedia." : "Tidak ada ibu hamil atau nifas aktif."}
        </p>
        <button
          onClick={() => {
            setSearch("");
            setFilterRisiko("");
            setFilterTrimester("");
            setShowHistory(false);
          }}
          className="text-[#185FA5] mt-2 hover:underline text-base"
        >
          Reset filter
        </button>
      </div>
    );

    const TableSkeleton = () => (
      <tbody>
        {Array(5).fill(0).map((_, i) => (
          <tr key={i} className="border-t">
            {Array(6).fill(0).map((_, j) => (
              <td key={j} className="p-3">
                <div className="h-5 bg-gray-200 rounded animate-pulse"></div>
              </td>
            ))}
          </tr>
        ))}
      </tbody>
    );

    return (
      <MainLayout>
        <div className="p-4 bg-white min-h-screen">
          {/* STATS CARDS */}
          <div className="grid grid-cols-1 sm:grid-cols-4 gap-3 mb-5">
            <button
              onClick={() => {
                setFilterRisiko("");
                setFilterTrimester("");
                setSearch("");
                setShowHistory(false);
              }}
              className="bg-white rounded-lg shadow-sm p-3 border-l-4 border-[#185FA5] text-left hover:shadow-md transition"
            >
              <div className="flex items-center gap-2 text-[#185FA5] mb-1">
                <Users size={16} />
                <span className="text-sm font-medium">IBU HAMIL & NIFAS AKTIF</span>
              </div>
              <p className="text-xl font-bold text-gray-800">{uniqueIbuAktif}</p>
              <p className="text-xs text-gray-400">{totalAktifRows} kehamilan aktif</p>
            </button>

            <button
              onClick={() => filterByRisiko("PERLU_RUJUKAN")}
              className={`bg-white rounded-lg shadow-sm p-3 border-l-4 border-red-600 text-left hover:shadow-md transition ${
                filterRisiko === "PERLU_RUJUKAN" && !showHistory ? "ring-2 ring-red-300" : ""
              }`}
            >
              <div className="flex items-center gap-2 text-red-600 mb-1">
                <AlertTriangle size={16} />
                <span className="text-sm font-medium">RISIKO TINGGI</span>
              </div>
              <p className="text-xl font-bold text-gray-800">{totalTinggi}</p>
            </button>

            <button
              onClick={() => filterByRisiko("PERLU_TINDAKAN")}
              className={`bg-white rounded-lg shadow-sm p-3 border-l-4 border-yellow-500 text-left hover:shadow-md transition ${
                filterRisiko === "PERLU_TINDAKAN" && !showHistory ? "ring-2 ring-yellow-300" : ""
              }`}
            >
              <div className="flex items-center gap-2 text-yellow-600 mb-1">
                <Activity size={16} />
                <span className="text-sm font-medium">RISIKO SEDANG</span>
              </div>
              <p className="text-xl font-bold text-gray-800">{totalSedang}</p>
            </button>

            <button
              onClick={() => filterByRisiko("NORMAL")}
              className={`bg-white rounded-lg shadow-sm p-3 border-l-4 border-[#3B6D11] text-left hover:shadow-md transition ${
                filterRisiko === "NORMAL" && !showHistory ? "ring-2 ring-green-300" : ""
              }`}
            >
              <div className="flex items-center gap-2 border-[#3B6D11] mb-1">
                <Activity size={16} />
                <span className="text-sm font-medium">RISIKO RENDAH/NORMAL</span>
              </div>
              <p className="text-xl font-bold text-gray-800">{totalNormal}</p>
            </button>

            {/* <div className="bg-white rounded-lg shadow-sm p-3 border-l-4 border-[#3B6D11]">
              <div className="flex items-center gap-2 text-[#3B6D11] mb-1">
                <UserCheck size={16} />
                <span className="text-sm font-medium">RISIKO RENDAH/NORMAL</span>
              </div>
               <p className="text-xl font-bold text-gray-800">{totalNormal}</p>
            </div> */}
          </div>

          {/* SEARCH & FILTERS */}
          <div className="flex flex-col md:flex-row justify-between gap-3 mb-5">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-3 text-gray-400" size={18} />
              <input
                className="pl-10 pr-4 py-2 border border-[#E2E8F0] rounded-lg w-full focus:ring-2 focus:ring-[#185FA5] focus:border-[#185FA5] text-sm"
                placeholder="Cari Nama Ibu..."
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                style={{ height: "40px" }}
              />
            </div>

            <div className="flex flex-wrap lg:flex-nowrap gap-2 items-center">
              <div className="relative flex-shrink-0">
                <select
                  className="pl-3 pr-12 py-2 border border-[#E2E8F0] rounded-lg bg-white text-sm"
                  value={showHistory ? "RIWAYAT" : filterTrimester}
                  onChange={(e) => {
                    if (e.target.value === "RIWAYAT") {
                      setShowHistory(true);
                    } else if (e.target.value === "KEMBALI") {
                      setShowHistory(false);
                    } else {
                      setFilterTrimester(e.target.value);
                    }
                  }}
                >
                  {showHistory ? (
                    <>
                      <option value="RIWAYAT">Riwayat</option>
                      <option value="KEMBALI">Kembali</option>
                    </>
                  ) : (
                    <>
                      <option value="">Semua Status</option>
                      <option value="TRIMESTER 1">Trimester 1</option>
                      <option value="TRIMESTER 2">Trimester 2</option>
                      <option value="TRIMESTER 3">Trimester 3</option>
                      <option value="NIFAS">Nifas</option>
                      <option value="RIWAYAT">Riwayat</option>
                    </>
                  )}
                </select>
                {/* <Filter size={12} className="absolute right-3 top-2.5 text-gray-400 pointer-events-none" /> */}
              </div>


              <Link
                to="/data-ibu/create"
                className="bg-[#185FA5] text-white px-5 py-2 rounded-full flex items-center gap-2 hover:bg-[#0F4A82] transition text-sm font-semibold whitespace-nowrap"
              >
                <Plus size={16} /> Tambah Ibu Hamil
              </Link>
            </div>
          </div>

          {/* MAIN TABLE */}
          {loading ? (
            <div className="bg-white rounded-lg shadow-sm overflow-hidden">
              <table className="w-full">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="p-2 text-left text-sm font-semibold text-gray-700">Nama</th>
                    <th className="p-2 text-center text-sm font-semibold text-gray-700">Status</th>
                    <th className="p-2 text-center text-sm font-semibold text-gray-700">Risiko</th>
                    <th className="p-2 text-center text-sm font-semibold text-gray-700">Usia Hamil</th>
                    <th className="p-2 text-center text-sm font-semibold text-gray-700">Dusun</th>
                    <th className="p-2 text-center text-sm font-semibold text-gray-700">Aksi</th>
                  </tr>
                </thead>
                <TableSkeleton />
              </table>
            </div>
          ) : paginatedData.length === 0 ? (
            <EmptyState />
          ) : (
            <div className="bg-white rounded-lg shadow-sm overflow-x-auto">
              <table className="w-full min-w-[700px]">
                <thead className="bg-gray-50 sticky top-0">
                  <tr>
                    <th className="p-2 text-left text-sm font-semibold text-gray-700">Nama</th>
                    <th className="p-2 text-center text-sm font-semibold text-gray-700">Status</th>
                    <th className="p-2 text-center text-sm font-semibold text-gray-700">Risiko</th>
                    <th className="p-2 text-center text-sm font-semibold text-gray-700">Usia Hamil</th>
                    <th className="p-2 text-center text-sm font-semibold text-gray-700">Dusun</th>
                    <th className="p-2 text-center text-sm font-semibold text-gray-700">Aksi</th>
                  </tr>
                </thead>
                <tbody>
                  {paginatedData.map((ibu) => {
                    const risk = riskLabel(ibu.status_risiko);
                    const isActive = ibu.status_kehamilan?.startsWith("TRIMESTER") || ibu.status_kehamilan === "NIFAS";
                    let displayStatus = ibu.status_kehamilan || "-";
                    if (displayStatus === "NON-AKTIF") displayStatus = "Selesai";
                    else if (displayStatus === "NIFAS") displayStatus = "Nifas";
                    
                    return (
                      <tr key={`${ibu.id_ibu}-${ibu.kehamilan_id}`} className="border-t hover:bg-gray-50 transition">
                        <td className="p-2 font-medium text-sm">{ibu.nama_lengkap}</td>
                        <td className="p-2 text-center text-sm">
                          <span className={`px-2 py-1 text-xs rounded-full inline-block ${statusBadge(ibu.status_kehamilan)}`}>
                            {displayStatus}
                          </span>
                        </td>
                        <td className="p-2 text-center text-sm">
                          <span className={`px-2 py-1 text-xs rounded-full inline-block ${risk.class}`} title={`Skor: ${ibu.skor_risiko}`}>
                            {risk.label}
                          </span>
                        </td>
                        <td className="p-2 text-center text-sm">{ibu.usia_kehamilan || "-"} {ibu.usia_kehamilan ? "Minggu" : ""}</td>
                        <td className="p-2 text-center text-sm">{ibu.dusun || "-"}</td>
                        <td className="p-2 text-center">
                          <div className="flex gap-1 justify-center items-center">
                            <button
                              onClick={() => {
                                if (ibu.kehamilan_id) navigate(`/data-ibu/${ibu.id_ibu}?kehamilan_id=${ibu.kehamilan_id}`);
                              }}
                              disabled={!ibu.kehamilan_id}
                              className="flex items-center gap-1 px-3 py-1.5 rounded-lg border border-[#185FA5] text-[#185FA5] bg-transparent text-xs font-medium hover:bg-[#185FA5]/5 disabled:opacity-50 disabled:cursor-not-allowed whitespace-nowrap"
                            >
                              <Eye size={14} /> Detail
                            </button>
                            {/* {isActive ? (
                              // Edit tombol dikomentari sesuai keinginan awal
                              <></>
                            ) : (
                              <button
                                disabled
                                className="flex items-center gap-1 px-3 py-1.5 rounded-lg border border-gray-300 text-gray-400 bg-gray-100 text-xs cursor-not-allowed whitespace-nowrap"
                              >
                                <Edit size={14} /> Selesai
                              </button>
                            )} */}
                          </div>
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          )}

          {/* PAGINATION */}
          {!loading && displayedData.length > 0 && (
            <div className="flex justify-end items-center gap-1 p-3 bg-white rounded-lg shadow-sm mt-3">
              <button
                onClick={() => setCurrentPage(prev => Math.max(1, prev - 1))}
                disabled={currentPage === 1}
                className={`w-8 h-8 flex items-center justify-center rounded-lg text-sm font-medium transition ${
                  currentPage === 1
                    ? "text-gray-400 bg-gray-100 cursor-not-allowed"
                    : "text-gray-600 hover:bg-gray-50"
                }`}
              >
                &lt;
              </button>
              {Array.from({ length: totalPages || 1 }, (_, i) => i + 1).map((page) => (
                <button
                  key={page}
                  onClick={() => setCurrentPage(page)}
                  className={`w-8 h-8 flex items-center justify-center rounded-lg text-sm font-medium transition ${
                    currentPage === page
                      ? "bg-[#185FA5] text-white"
                      : "text-gray-600 hover:bg-gray-50"
                  }`}
                >
                  {page}
                </button>
              ))}
              <button
                onClick={() => setCurrentPage(prev => Math.min(totalPages, prev + 1))}
                disabled={currentPage === totalPages}
                className={`w-8 h-8 flex items-center justify-center rounded-lg text-sm font-medium transition ${
                  currentPage === totalPages
                    ? "text-gray-400 bg-gray-100 cursor-not-allowed"
                    : "text-gray-600 hover:bg-gray-50"
                }`}
              >
                &gt;
              </button>
            </div>
          )}
        </div>
      </MainLayout>
    );
  }