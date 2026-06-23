import React, { useState, useEffect } from "react";
import Swal from "sweetalert2";
import MainLayout from "../../components/Layout/MainLayout";
import RequestPerubahanImunisasiTable from "./table";
import {
    Search,
    RefreshCw,
    ChevronLeft,
    ChevronRight,
    CheckCircle,
    XCircle,
} from "lucide-react";

import {
    getAllRequestPerubahanImunisasi,
    approveRequestPerubahanImunisasi,
    rejectRequestPerubahanImunisasi,
} from "../../services/RequestPerubahanImunisasi";

export default function RequestPerubahanImunisasiPage() {
    const [requests, setRequests] = useState([]);
    const [loading, setLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState("");

    const [currentPage, setCurrentPage] = useState(1);
    const [pendingPage, setPendingPage] = useState(1);
    const [completedPage, setCompletedPage] = useState(1);

    const itemsPerPage = 10;

    const fetchRequests = async () => {
        try {
            setLoading(true);

            const res = await getAllRequestPerubahanImunisasi();

            setRequests(res.data || []);
        } catch (error) {
            console.error(error);
            alert("Gagal mengambil data permintaan perubahan jadwal imunisasi");
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchRequests();
    }, []);

    const handleApprove = async (id) => {
        const confirm = await Swal.fire({
            title: "Terima Permintaan?",
            text: "Jadwal imunisasi akan diubah sesuai tanggal baru yang diajukan.",
            icon: "question",
            showCancelButton: true,
            confirmButtonColor: "#16a34a",
            cancelButtonColor: "#6b7280",
            confirmButtonText: "Ya, Terima",
            cancelButtonText: "Batal",
        });

        if (!confirm.isConfirmed) return;

        try {
            await approveRequestPerubahanImunisasi(id);

            Swal.fire({
                title: "Berhasil!",
                text: "Permintaan perubahan jadwal telah diterima.",
                icon: "success",
                confirmButtonColor: "#16a34a",
            });

            await fetchRequests();
        } catch (error) {
            console.error("APPROVE ERROR:", error);

            Swal.fire({
                title: "Gagal!",
                text:
                    error?.response?.data?.message ||
                    JSON.stringify(error?.response?.data) ||
                    error.message,
                icon: "error",
                confirmButtonColor: "#dc2626",
            });
        }
    };

    const handleReject = async (id) => {
        const confirm = await Swal.fire({
            title: "Tolak Permintaan?",
            text: "Permintaan perubahan jadwal ini akan ditolak.",
            icon: "warning",
            showCancelButton: true,
            confirmButtonColor: "#dc2626",
            cancelButtonColor: "#6b7280",
            confirmButtonText: "Ya, Tolak",
            cancelButtonText: "Batal",
        });

        if (!confirm.isConfirmed) return;

        try {
            await rejectRequestPerubahanImunisasi(id);

            Swal.fire({
                title: "Ditolak",
                text: "Permintaan perubahan jadwal telah ditolak.",
                icon: "success",
                confirmButtonColor: "#16a34a",
            });

            await fetchRequests();
        } catch (error) {
            console.error(error);

            Swal.fire({
                title: "Gagal!",
                text: "Gagal menolak permintaan.",
                icon: "error",
                confirmButtonColor: "#dc2626",
            });
        }
    };

    const formatDate = (dateString) => {
        if (!dateString) return "-";

        return new Date(dateString).toLocaleDateString("id-ID", {
            day: "numeric",
            month: "long",
            year: "numeric",
        });
    };

    const filteredRequests = requests.filter((item) =>
        item.nama_lengkap?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        item.nama_dosis?.toLowerCase().includes(searchTerm.toLowerCase())
    );

    const pendingRequests = filteredRequests.filter(
        (item) => item.status_request === "Menunggu"
    );

    const completedRequests = filteredRequests.filter(
        (item) =>
            item.status_request === "Terima" ||
            item.status_request === "Tolak"
    );

    // const indexOfLastItem = currentPage * itemsPerPage;
    // const indexOfFirstItem = indexOfLastItem - itemsPerPage;

    // const currentItems = filteredRequests.slice(
    //     indexOfFirstItem,
    //     indexOfLastItem
    // );

    // const totalPages = Math.ceil(
    //     filteredRequests.length / itemsPerPage
    // );

    const pendingLastIndex = pendingPage * itemsPerPage;
    const pendingFirstIndex = pendingLastIndex - itemsPerPage;

    const pendingItems = pendingRequests.slice(
        pendingFirstIndex,
        pendingLastIndex
    );

    const pendingTotalPages = Math.ceil(
        pendingRequests.length / itemsPerPage
    );

    const completedLastIndex = completedPage * itemsPerPage;
    const completedFirstIndex = completedLastIndex - itemsPerPage;

    const completedItems = completedRequests.slice(
        completedFirstIndex,
        completedLastIndex
    );

    const completedTotalPages = Math.ceil(
        completedRequests.length / itemsPerPage
    );

    const renderRows = (data, showAction = false) => {
        if (data.length === 0) {
            return (
                <tr>
                    <td
                        colSpan="7"
                        className="text-center py-16 text-gray-500"
                    >
                        Tidak ada data
                    </td>
                </tr>
            );
        }

        return data.map((item) => (
            <tr
                key={item.request_id}
                className="hover:bg-indigo-50 transition-colors"
            >
                <td className="px-6 py-4 font-semibold">
                    {item.nama_lengkap}
                </td>

                <td className="px-6 py-4">
                    {item.nama_dosis}
                </td>

                <td className="px-6 py-4">
                    {formatDate(item.tanggal_sebelum)}
                </td>

                <td className="px-6 py-4">
                    {formatDate(item.tanggal_baru)}
                </td>

                <td className="px-6 py-4 max-w-xs">
                    {item.alasan}
                </td>

                <td className="px-6 py-4">
                    <StatusBadge status={item.status_request} />
                </td>

                <td className="px-6 py-4">
                    {showAction ? (
                        <div className="flex justify-center gap-2">
                            <button
                                onClick={() =>
                                    handleApprove(item.request_id)
                                }
                                className="flex items-center gap-1 px-3 py-2 rounded-lg bg-green-600 hover:bg-green-700 text-white text-xs font-semibold"
                            >
                                <CheckCircle size={14} />
                                Terima
                            </button>

                            <button
                                onClick={() =>
                                    handleReject(item.request_id)
                                }
                                className="flex items-center gap-1 px-3 py-2 rounded-lg bg-red-600 hover:bg-red-700 text-white text-xs font-semibold"
                            >
                                <XCircle size={14} />
                                Tolak
                            </button>
                        </div>
                    ) : (
                        <div className="text-center text-xs text-gray-400">
                            Selesai
                        </div>
                    )}
                </td>
            </tr>
        ));
    };

    return (
        <MainLayout>
            <div className="p-4 md:p-8 bg-[#f8fafc] min-h-screen">

                <div className="mb-8">
                    <h1 className="text-2xl font-bold text-gray-800 tracking-tight">
                        Permintaan Perubahan Jadwal Imunisasi
                    </h1>

                    <p className="text-gray-500 text-sm">
                        Kelola dan tinjau permintaan perubahan jadwal imunisasi yang diajukan oleh orang tua.
                    </p>
                </div>

                <div className="bg-white rounded-t-2xl border-x border-t border-gray-100 p-6">
                    <div className="relative w-full max-w-md">
                        <Search
                            className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400"
                            size={18}
                        />

                        <input
                            type="text"
                            placeholder="Cari nama anak atau dosis vaksin"
                            className="pl-10 pr-4 py-2.5 border border-gray-200 rounded-xl w-full focus:ring-2 focus:ring-indigo-500 outline-none"
                            value={searchTerm}
                            onChange={(e) => {
                                setSearchTerm(e.target.value);
                                setCurrentPage(1);
                            }}
                        />
                    </div>
                </div>

                <div className="mt-6">
                    <h2 className="text-lg font-bold text-gray-800 mb-3">
                        Permintaan Menunggu
                    </h2>

                    <div className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-x-auto">
                        <table className="w-full text-left border-collapse">
                            <thead>
                                <tr className="bg-gray-50 border-y border-gray-100 text-gray-500 uppercase text-[10px] tracking-widest font-black">
                                    <th className="px-6 py-4">Nama Anak</th>
                                    <th className="px-6 py-4">Dosis Vaksin</th>
                                    <th className="px-6 py-4">Tanggal Sebelum</th>
                                    <th className="px-6 py-4">Tanggal Baru</th>
                                    <th className="px-6 py-4">Alasan</th>
                                    <th className="px-6 py-4">Status</th>
                                    <th className="px-6 py-4 text-center">Aksi</th>
                                </tr>
                            </thead>

                            <tbody>
                                {loading ? (
                                    <tr>
                                        <td colSpan="7" className="py-16">
                                            <div className="flex flex-col items-center gap-3">
                                                <RefreshCw
                                                    size={36}
                                                    className="animate-spin text-blue-600"
                                                />
                                            </div>
                                        </td>
                                    </tr>
                                ) : (
                                    renderRows(pendingItems, true)
                                )}
                            </tbody>
                        </table>

                        <div className="flex justify-between items-center px-6 py-4 border-t bg-gray-50">
                            <p className="text-xs text-gray-500">
                                {pendingRequests.length === 0
                                    ? "Tidak ada data"
                                    : `Menampilkan ${pendingFirstIndex + 1}-${Math.min(pendingLastIndex, pendingRequests.length)} dari ${pendingRequests.length} data`}
                            </p>

                            <div className="flex items-center gap-1">
                                <button
                                    disabled={pendingPage === 1}
                                    onClick={() => setPendingPage((prev) => prev - 1)}
                                    className="p-2 border rounded-lg disabled:opacity-40 hover:bg-gray-100"
                                >
                                    <ChevronLeft size={16} />
                                </button>

                                {Array.from({ length: pendingTotalPages }, (_, i) => i + 1).map((page) => (
                                    <button
                                        key={page}
                                        onClick={() => setPendingPage(page)}
                                        className={`w-8 h-8 text-xs rounded-lg border font-medium ${
                                            page === pendingPage
                                                ? "bg-indigo-600 text-white border-indigo-600"
                                                : "hover:bg-gray-100 text-gray-600"
                                        }`}
                                    >
                                        {page}
                                    </button>
                                ))}

                                <button
                                    disabled={pendingPage === pendingTotalPages || pendingTotalPages === 0}
                                    onClick={() => setPendingPage((prev) => prev + 1)}
                                    className="p-2 border rounded-lg disabled:opacity-40 hover:bg-gray-100"
                                >
                                    <ChevronRight size={16} />
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <div className="mt-8">
                    <h2 className="text-lg font-bold text-gray-800 mb-3">
                        Riwayat Permintaan
                    </h2>

                    <div className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-x-auto">
                        <table className="w-full text-left border-collapse">
                            <thead>
                                <tr className="bg-gray-50 border-y border-gray-100 text-gray-500 uppercase text-[10px] tracking-widest font-black">
                                    <th className="px-6 py-4">Nama Anak</th>
                                    <th className="px-6 py-4">Dosis Vaksin</th>
                                    <th className="px-6 py-4">Tanggal Sebelum</th>
                                    <th className="px-6 py-4">Tanggal Baru</th>
                                    <th className="px-6 py-4">Alasan</th>
                                    <th className="px-6 py-4">Status</th>
                                    <th className="px-6 py-4 text-center">Aksi</th>
                                </tr>
                            </thead>

                            <tbody>
                                {loading ? (
                                    <tr>
                                        <td colSpan="7" className="py-16">
                                            <div className="flex flex-col items-center gap-3">
                                                <RefreshCw
                                                    size={36}
                                                    className="animate-spin text-blue-600"
                                                />
                                            </div>
                                        </td>
                                    </tr>
                                ) : (
                                    renderRows(completedItems, false)
                                )}
                            </tbody>
                        </table>

                        <div className="flex justify-between items-center px-6 py-4 border-t bg-gray-50">
                            <p className="text-xs text-gray-500">
                                {completedRequests.length === 0
                                    ? "Tidak ada data"
                                    : `Menampilkan ${completedFirstIndex + 1}-${Math.min(completedLastIndex, completedRequests.length)} dari ${completedRequests.length} data`}
                            </p>

                            <div className="flex items-center gap-1">
                                <button
                                    disabled={completedPage === 1}
                                    onClick={() => setCompletedPage((prev) => prev - 1)}
                                    className="p-2 border rounded-lg disabled:opacity-40 hover:bg-gray-100"
                                >
                                    <ChevronLeft size={16} />
                                </button>

                                {Array.from({ length: completedTotalPages }, (_, i) => i + 1).map((page) => (
                                    <button
                                        key={page}
                                        onClick={() => setCompletedPage(page)}
                                        className={`w-8 h-8 text-xs rounded-lg border font-medium ${
                                            page === completedPage
                                                ? "bg-indigo-600 text-white border-indigo-600"
                                                : "hover:bg-gray-100 text-gray-600"
                                        }`}
                                    >
                                        {page}
                                    </button>
                                ))}

                                <button
                                    disabled={completedPage === completedTotalPages || completedTotalPages === 0}
                                    onClick={() => setCompletedPage((prev) => prev + 1)}
                                    className="p-2 border rounded-lg disabled:opacity-40 hover:bg-gray-100"
                                >
                                    <ChevronRight size={16} />
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </MainLayout>
    );
}

function StatusBadge({ status }) {
    if (status === "Menunggu") {
        return (
            <span className="px-3 py-1 rounded-full bg-yellow-100 text-yellow-700 text-xs font-semibold">
                Menunggu
            </span>
        );
    }

    if (status === "Terima") {
        return (
            <span className="px-3 py-1 rounded-full bg-green-100 text-green-700 text-xs font-semibold">
                Disetujui
            </span>
        );
    }

    if (status === "Tolak") {
        return (
            <span className="px-3 py-1 rounded-full bg-red-100 text-red-700 text-xs font-semibold">
                Ditolak
            </span>
        );
    }

    return (
        <span className="px-3 py-1 rounded-full bg-gray-100 text-gray-700 text-xs font-semibold">
            {status}
        </span>
    );
}