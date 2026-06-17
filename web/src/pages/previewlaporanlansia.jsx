import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import MainLayout from "../components/Layout/MainLayout";
import { previewLaporanLansia, exportLaporanLansia } from "../services/laporan";
import {
	Download,
	ArrowLeft,
	Loader2,
	Table,
	Filter,
	AlertCircle,
	Calendar,
	FileSpreadsheet,
	RefreshCw,
} from "lucide-react";
import Swal from "sweetalert2";

export default function LaporanLansiaPreview() {
	const navigate = useNavigate();
	const [data, setData] = useState([]);
	const [loading, setLoading] = useState(true);
	const [error, setError] = useState("");
	const [exporting, setExporting] = useState(false);

	// Filter state
	const [startDate, setStartDate] = useState("");
	const [endDate, setEndDate] = useState("");
	const [filterEnabled, setFilterEnabled] = useState(false);

	useEffect(() => {
		fetchPreview();
	}, [filterEnabled]);

	const fetchPreview = async () => {
		setLoading(true);
		setError("");
		try {
			let rawData;
			if (filterEnabled && startDate && endDate) {
				rawData = await previewLaporanLansia(startDate, endDate);
			} else {
				rawData = await previewLaporanLansia();
			}
			
			// Normalize response
			const normalized = rawData?.data || rawData || [];
			setData(Array.isArray(normalized) ? normalized : []);

			if (normalized.length === 0 && filterEnabled) {
				setError(`Tidak ada data ditemukan untuk rentang tanggal ${startDate} s.d. ${endDate}`);
			} else if (normalized.length === 0) {
				setError("Belum ada data laporan lansia yang tersedia");
			}
		} catch (err) {
			console.error("Preview error:", err);
			const msg = err.response?.data?.message || err.message || "Gagal memuat preview data lansia";
			setError(msg);
			setData([]);
		} finally {
			setLoading(false);
		}
	};

	const handleExport = async () => {
		setExporting(true);
		try {
			let blob;
			if (filterEnabled && startDate && endDate) {
				blob = await exportLaporanLansia(startDate, endDate);
			} else {
				blob = await exportLaporanLansia();
			}
			const url = window.URL.createObjectURL(blob);
			const a = document.createElement("a");
			a.href = url;
			a.download = `laporan_lansia_${filterEnabled ? `${startDate}_to_${endDate}` : "semua"}.xlsx`;
			a.click();
			window.URL.revokeObjectURL(url);
		} catch (err) {
			Swal.fire({
				icon: "error",
				title: "Gagal Mengekspor",
				text: "Gagal mengekspor laporan lansia: " + (err.response?.data?.message || err.message),
				confirmButtonColor: "#185FA5",
			});
		} finally {
			setExporting(false);
		}
	};

	const handleApplyFilter = () => {
		if (!startDate || !endDate) {
			Swal.fire({
				icon: "warning",
				title: "Tanggal Belum Dipilih",
				text: "Silakan pilih tanggal awal dan akhir terlebih dahulu.",
				confirmButtonColor: "#185FA5",
			});
			return;
		}
		setFilterEnabled(true);
	};

	const handleResetFilter = () => {
		setStartDate("");
		setEndDate("");
		setFilterEnabled(false);
	};

	const SkeletonRow = ({ cols = 6 }) => (
		<tr className="animate-pulse">
			{[...Array(cols)].map((_, i) => (
				<td key={i} className="px-4 py-3">
					<div className="h-4 bg-gray-200 rounded w-3/4"></div>
				</td>
			))}
		</tr>
	);

	const renderTable = (currentData) => {
		if (currentData.length === 0) {
			return (
				<div className="bg-gray-50 border border-gray-200 rounded-xl p-12 text-center mt-4">
					<Table size={48} className="mx-auto text-gray-400 mb-3" />
					<p className="text-gray-600 font-medium">
						Tidak ada data untuk ditampilkan
					</p>
					<p className="text-sm text-gray-400 mt-1">
						Data tidak ditemukan atau belum dicatat pada sistem.
					</p>
				</div>
			);
		}

		const columns = Object.keys(currentData[0]);

		return (
			<div className="mt-4">
				<div className="overflow-x-auto rounded-lg border border-gray-200 shadow-sm max-h-[500px]">
					<table className="min-w-full divide-y divide-gray-200">
						<thead className="bg-gray-50 sticky top-0 z-10">
							<tr>
								<th className="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider bg-gray-50">
									No
								</th>
								{columns.map((col) => (
									<th
										key={col}
										className="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider bg-gray-50"
									>
										{col.replace(/_/g, " ")}
									</th>
								))}
							</tr>
						</thead>
						<tbody className="bg-white divide-y divide-gray-100">
							{currentData.map((row, idx) => (
								<tr
									key={idx}
									className="hover:bg-orange-50/30 transition-colors duration-150"
								>
									<td className="px-4 py-2.5 text-sm text-gray-500 whitespace-nowrap">
										{idx + 1}
									</td>
									{columns.map((col) => {
										let val = row[col];
										// Check if it's a date field
										if (col.toLowerCase().includes('tanggal') || col.toLowerCase().includes('tgl') || col.toLowerCase().includes('date')) {
											if (val) {
												val = new Date(val).toLocaleDateString("id-ID", {
													year: "numeric",
													month: "long",
													day: "numeric",
												});
											}
										}
										return (
											<td key={col} className="px-4 py-2.5 text-sm text-gray-700 whitespace-nowrap">
												{val !== undefined && val !== null && val !== "" ? String(val) : "-"}
											</td>
										);
									})}
								</tr>
							))}
						</tbody>
					</table>
				</div>
				<div className="mt-3 flex flex-wrap justify-between items-center gap-2 text-sm text-gray-500">
					<span>Menampilkan <strong>{currentData.length}</strong> data</span>
				</div>
			</div>
		);
	};

	return (
		<MainLayout>
			<div className="p-4 md:p-6 max-w-7xl mx-auto">
				{/* Header */}
				<div className="flex flex-wrap items-center justify-between gap-3 mb-6">
					<button
						onClick={() => navigate(-1)}
						className="inline-flex items-center gap-2 text-gray-600 hover:text-orange-600 transition-colors"
					>
						<ArrowLeft size={18} /> Kembali
					</button>
					<h1 className="text-xl md:text-2xl font-bold text-gray-800">
						Preview Laporan Data Lansia
					</h1>
					<div className="w-20 md:w-auto"></div>
				</div>

				{/* Card Filter & Export */}
				<div className="bg-white rounded-xl shadow-sm border border-gray-100 p-4 mb-6">
					<div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
						<div className="flex flex-wrap items-center gap-3">
							<div className="bg-orange-100 p-2 rounded-full">
								<Filter size={18} className="text-orange-600" />
							</div>
							<div className="flex flex-wrap items-center gap-3">
								<span className="text-sm font-medium text-gray-700">
									Filter Tanggal:
								</span>
								<div className="flex items-center gap-2">
									<input
										type="date"
										value={startDate}
										onChange={(e) => setStartDate(e.target.value)}
										className="border rounded-lg px-3 py-1.5 text-sm focus:ring-2 focus:ring-orange-300 bg-white"
									/>
									<span className="text-gray-400 text-sm">s.d.</span>
									<input
										type="date"
										value={endDate}
										onChange={(e) => setEndDate(e.target.value)}
										className="border rounded-lg px-3 py-1.5 text-sm focus:ring-2 focus:ring-orange-300 bg-white"
									/>
								</div>
								<div className="flex gap-2">
									<button
										onClick={handleApplyFilter}
										className="bg-orange-600 text-white px-3 py-1.5 rounded-lg text-sm font-medium hover:bg-orange-700 transition shadow-sm"
									>
										Terapkan Filter
									</button>
									{filterEnabled && (
										<button
											onClick={handleResetFilter}
											className="bg-gray-100 text-gray-700 px-3 py-1.5 rounded-lg text-sm font-medium hover:bg-gray-200 transition"
										>
											Reset
										</button>
									)}
								</div>
							</div>
						</div>

						<button
							onClick={handleExport}
							disabled={exporting || data.length === 0}
							className="bg-orange-600 hover:bg-orange-700 text-white px-5 py-2 rounded-lg flex items-center justify-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed transition shadow-sm w-full lg:w-auto"
						>
							{exporting ? <Loader2 className="animate-spin" size={18} /> : <Download size={18} />}
							{exporting ? "Mengekspor..." : "Download Excel"}
						</button>
					</div>

					{filterEnabled && startDate && endDate && (
						<div className="mt-3 text-xs text-orange-600 bg-orange-50 p-2 rounded-lg inline-flex items-center gap-1">
							<Calendar size={12} /> Memfilter data dari {new Date(startDate).toLocaleDateString("id-ID")} s.d. {new Date(endDate).toLocaleDateString("id-ID")}
						</div>
					)}
				</div>

				{/* Loading skeleton */}
				{loading && (
					<div className="rounded-lg border border-gray-200 overflow-hidden">
						<div className="bg-gray-50 px-4 py-3 border-b">
							<div className="h-5 w-32 bg-gray-200 rounded animate-pulse"></div>
						</div>
						<div className="overflow-x-auto">
							<table className="min-w-full">
								<tbody>
									{[...Array(5)].map((_, i) => (
										<SkeletonRow key={i} cols={6} />
									))}
								</tbody>
							</table>
						</div>
					</div>
				)}

				{/* Error state */}
				{!loading && error && (
					<div className="bg-red-50 border border-red-200 rounded-xl p-6 text-center">
						<AlertCircle className="mx-auto text-red-500 mb-2" size={32} />
						<p className="text-red-700 font-medium">{error}</p>
						<button
							onClick={() => fetchPreview()}
							className="mt-4 inline-flex items-center gap-2 text-orange-600 text-sm hover:underline"
						>
							<RefreshCw size={14} /> Muat ulang
						</button>
					</div>
				)}

				{/* Table View */}
				{!loading && !error && renderTable(data)}
			</div>
		</MainLayout>
	);
}
