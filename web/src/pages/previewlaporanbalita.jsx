import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import MainLayout from "../components/Layout/MainLayout";
import { previewLaporanBalita, exportLaporanBalita } from "../services/laporan";
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

export default function LaporanBalitaPreview() {
	const navigate = useNavigate();
	const [data, setData] = useState({ balita: [], pertumbuhan: [], imunisasi: [] });
	const [loading, setLoading] = useState(true);
	const [error, setError] = useState("");
	const [exporting, setExporting] = useState(false);

	// Tabs: "balita" | "pertumbuhan" | "imunisasi"
	const [activeTab, setActiveTab] = useState("balita");

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
				rawData = await previewLaporanBalita(startDate, endDate);
			} else {
				rawData = await previewLaporanBalita();
			}
			
			// Normalize response
			const normalized = rawData?.data || { balita: [], pertumbuhan: [], imunisasi: [] };
			setData({
				balita: Array.isArray(normalized.balita) ? normalized.balita : [],
				pertumbuhan: Array.isArray(normalized.pertumbuhan) ? normalized.pertumbuhan : [],
				imunisasi: Array.isArray(normalized.imunisasi) ? normalized.imunisasi : [],
			});

			const totalItems = (normalized.balita?.length || 0) + (normalized.pertumbuhan?.length || 0) + (normalized.imunisasi?.length || 0);
			if (totalItems === 0 && filterEnabled) {
				setError(`Tidak ada data ditemukan untuk rentang tanggal ${startDate} s.d. ${endDate}`);
			} else if (totalItems === 0) {
				setError("Belum ada data laporan balita yang tersedia");
			}
		} catch (err) {
			console.error("Preview error:", err);
			const msg = err.response?.data?.message || err.message || "Gagal memuat preview data balita";
			setError(msg);
			setData({ balita: [], pertumbuhan: [], imunisasi: [] });
		} finally {
			setLoading(false);
		}
	};

	const handleExport = async () => {
		setExporting(true);
		try {
			let blob;
			if (filterEnabled && startDate && endDate) {
				blob = await exportLaporanBalita(startDate, endDate);
			} else {
				blob = await exportLaporanBalita();
			}
			const url = window.URL.createObjectURL(blob);
			const a = document.createElement("a");
			a.href = url;
			a.download = `laporan_balita_${filterEnabled ? `${startDate}_to_${endDate}` : "semua"}.xlsx`;
			a.click();
			window.URL.revokeObjectURL(url);
		} catch (err) {
			Swal.fire({
				icon: "error",
				title: "Gagal Mengekspor",
				text: "Gagal mengekspor laporan balita: " + (err.response?.data?.message || err.message),
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

	const renderTable = (currentData, columns) => {
		if (currentData.length === 0) {
			return (
				<div className="bg-gray-50 border border-gray-200 rounded-xl p-12 text-center mt-4">
					<Table size={48} className="mx-auto text-gray-400 mb-3" />
					<p className="text-gray-600 font-medium">
						Tidak ada data untuk tab ini
					</p>
					<p className="text-sm text-gray-400 mt-1">
						Data tidak ditemukan atau belum dicatat pada sistem.
					</p>
				</div>
			);
		}

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
										key={col.field}
										className="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider bg-gray-50"
									>
										{col.label}
									</th>
								))}
							</tr>
						</thead>
						<tbody className="bg-white divide-y divide-gray-100">
							{currentData.map((row, idx) => (
								<tr
									key={idx}
									className="hover:bg-green-50/30 transition-colors duration-150"
								>
									<td className="px-4 py-2.5 text-sm text-gray-500 whitespace-nowrap">
										{idx + 1}
									</td>
									{columns.map((col) => {
										let val = row[col.field];
										if (col.type === "date" && val) {
											val = new Date(val).toLocaleDateString("id-ID", {
												year: "numeric",
												month: "long",
												day: "numeric",
											});
										}
										return (
											<td key={col.field} className="px-4 py-2.5 text-sm text-gray-700 whitespace-nowrap">
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

	// Column definitions untuk BALITA (bukan ANAK)
	const balitaCols = [
		{ field: "no_kk", label: "No KK" },
		{ field: "nik", label: "NIK Balita" },
		{ field: "nama_anak", label: "Nama Balita" },
		{ field: "nama_ibu", label: "Nama Ibu" },
		{ field: "nama_ayah", label: "Nama Ayah" },
		{ field: "tanggal_lahir", label: "Tanggal Lahir", type: "date" },
		{ field: "usia", label: "Usia" },
		{ field: "berat_lahir_kg", label: "BB Lahir (Kg)" },
		{ field: "tinggi_lahir_cm", label: "TB Lahir (Cm)" },
		{ field: "lila", label: "LILA" },
		{ field: "golongan_darah", label: "Golongan Darah" },
		{ field: "kecamatan", label: "Kecamatan" },
		{ field: "desa", label: "Desa" },
	];

	const pertumbuhanCols = [
		{ field: "nik", label: "NIK Balita" },
		{ field: "nama_anak", label: "Nama Balita" },
		{ field: "tgl_ukur", label: "Tgl Pengukuran", type: "date" },
		{ field: "usia_ukur_bulan", label: "Usia Ukur (Bulan)" },
		{ field: "berat_badan", label: "BB (Kg)" },
		{ field: "tinggi_badan", label: "TB (Cm)" },
		{ field: "hasil_lila", label: "LILA" },
		{ field: "lingkar_kepala", label: "Lingkar Kepala" },
		{ field: "imt", label: "IMT" },
		{ field: "status_bb_u", label: "Status BB/U" },
		{ field: "status_tb_u", label: "Status TB/U" },
		{ field: "status_bb_tb", label: "Status BB/TB" },
		{ field: "status_imt_u", label: "Status IMT/U" },
		{ field: "catatan_nakes", label: "Catatan Nakes" },
	];

	const imunisasiCols = [
		{ field: "nik", label: "NIK Balita" },
		{ field: "nama_anak", label: "Nama Balita" },
		{ field: "nama_vaksin", label: "Nama Vaksin" },
		{ field: "tgl_pemberian", label: "Tgl Pemberian", type: "date" },
		{ field: "status", label: "Status" },
		{ field: "lokasi", label: "Lokasi" },
		{ field: "petugas", label: "Petugas" },
	];

	return (
		<MainLayout>
			<div className="p-4 md:p-6 max-w-7xl mx-auto">
				{/* Header */}
				<div className="flex flex-wrap items-center justify-between gap-3 mb-6">
					<button
						onClick={() => navigate(-1)}
						className="inline-flex items-center gap-2 text-gray-600 hover:text-green-600 transition-colors"
					>
						<ArrowLeft size={18} /> Kembali
					</button>
					<h1 className="text-xl md:text-2xl font-bold text-gray-800">
						Preview Laporan Data Balita
					</h1>
					<div className="w-20 md:w-auto"></div>
				</div>

				{/* Card Filter & Export */}
				<div className="bg-white rounded-xl shadow-sm border border-gray-100 p-4 mb-6">
					<div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
						<div className="flex flex-wrap items-center gap-3">
							<div className="bg-green-100 p-2 rounded-full">
								<Filter size={18} className="text-green-600" />
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
										className="border rounded-lg px-3 py-1.5 text-sm focus:ring-2 focus:ring-green-300 bg-white"
									/>
									<span className="text-gray-400 text-sm">s.d.</span>
									<input
										type="date"
										value={endDate}
										onChange={(e) => setEndDate(e.target.value)}
										className="border rounded-lg px-3 py-1.5 text-sm focus:ring-2 focus:ring-green-300 bg-white"
									/>
								</div>
								<div className="flex gap-2">
									<button
										onClick={handleApplyFilter}
										className="bg-green-600 text-white px-3 py-1.5 rounded-lg text-sm font-medium hover:bg-green-700 transition shadow-sm"
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
							disabled={exporting || (data.balita.length === 0 && data.pertumbuhan.length === 0 && data.imunisasi.length === 0)}
							className="bg-emerald-600 hover:bg-emerald-700 text-white px-5 py-2 rounded-lg flex items-center justify-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed transition shadow-sm w-full lg:w-auto"
						>
							{exporting ? <Loader2 className="animate-spin" size={18} /> : <Download size={18} />}
							{exporting ? "Mengekspor..." : "Download Excel (3 Sheet)"}
						</button>
					</div>

					{filterEnabled && startDate && endDate && (
						<div className="mt-3 text-xs text-green-600 bg-green-50 p-2 rounded-lg inline-flex items-center gap-1">
							<Calendar size={12} /> Memfilter data dari {new Date(startDate).toLocaleDateString("id-ID")} s.d. {new Date(endDate).toLocaleDateString("id-ID")}
						</div>
					)}
				</div>

				{/* Tab Buttons */}
				{!loading && !error && (
					<div className="flex border-b border-gray-200 mb-4 overflow-x-auto whitespace-nowrap">
						<button
							onClick={() => setActiveTab("balita")}
							className={`py-2.5 px-4 font-medium text-sm border-b-2 transition-all ${
								activeTab === "balita"
									? "border-green-600 text-green-600"
									: "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"
							}`}
						>
							Data Balita ({data.balita.length})
						</button>
						<button
							onClick={() => setActiveTab("pertumbuhan")}
							className={`py-2.5 px-4 font-medium text-sm border-b-2 transition-all ${
								activeTab === "pertumbuhan"
									? "border-green-600 text-green-600"
									: "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"
							}`}
						>
							Riwayat Pertumbuhan ({data.pertumbuhan.length})
						</button>
						<button
							onClick={() => setActiveTab("imunisasi")}
							className={`py-2.5 px-4 font-medium text-sm border-b-2 transition-all ${
								activeTab === "imunisasi"
									? "border-green-600 text-green-600"
									: "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"
							}`}
						>
							Riwayat Imunisasi ({data.imunisasi.length})
						</button>
					</div>
				)}

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
							className="mt-4 inline-flex items-center gap-2 text-green-600 text-sm hover:underline"
						>
							<RefreshCw size={14} /> Muat ulang
						</button>
					</div>
				)}

				{/* Table Views based on Active Tab */}
				{!loading && !error && activeTab === "balita" && renderTable(data.balita, balitaCols)}
				{!loading && !error && activeTab === "pertumbuhan" && renderTable(data.pertumbuhan, pertumbuhanCols)}
				{!loading && !error && activeTab === "imunisasi" && renderTable(data.imunisasi, imunisasiCols)}
			</div>
		</MainLayout>
	);
}