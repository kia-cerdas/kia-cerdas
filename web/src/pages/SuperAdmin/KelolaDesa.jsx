import React, { useEffect, useMemo, useState } from "react";
import MainLayout from "../../components/Layout/MainLayout";
import {
	createDesa,
	deactivateDesa,
	desaErrorMessage,
	listDesa,
	updateDesa,
} from "../../services/desa";
import {
	AlertCircle,
	CheckCircle2,
	Edit,
	MapPinned,
	Plus,
	Power,
	Search,
	X,
} from "lucide-react";

const emptyForm = {
	kecamatan: "",
	kabupaten: "",
	provinsi: "",
	nama_desa: "",
	kode_desa: "",
	keterangan: "",
};

export default function KelolaDesa() {
	const [desaList, setDesaList] = useState([]);
	const [loading, setLoading] = useState(true);
	const [search, setSearch] = useState("");
	const [showCreateModal, setShowCreateModal] = useState(false);
	const [showEditModal, setShowEditModal] = useState(false);
	const [selectedDesa, setSelectedDesa] = useState(null);
	const [formData, setFormData] = useState(emptyForm);
	const [isSubmitting, setIsSubmitting] = useState(false);
	const [error, setError] = useState("");
	const [formError, setFormError] = useState("");

	const fetchData = async () => {
		try {
			setLoading(true);
			const data = await listDesa();
			setDesaList(data || []);
		} catch (err) {
			setError(desaErrorMessage(err, "Gagal memuat data desa"));
		} finally {
			setLoading(false);
		}
	};

	useEffect(() => {
		fetchData();
	}, []);

	const filteredDesa = useMemo(() => {
		const keyword = search.trim().toLowerCase();
		if (!keyword) return desaList;

		return desaList.filter((desa) => {
			return [
				desa.nama_desa,
				desa.kode_desa,
				desa.kecamatan,
				desa.kabupaten,
				desa.provinsi,
			]
				.filter(Boolean)
				.some((value) => value.toLowerCase().includes(keyword));
		});
	}, [desaList, search]);

	const resetForm = () => {
		setFormData(emptyForm);
		setFormError("");
	};

	const openCreateModal = () => {
		resetForm();
		setSelectedDesa(null);
		setShowEditModal(false);
		setShowCreateModal(true);
	};

	const openEditModal = (desa) => {
		setSelectedDesa(desa);
		setFormData({
			kecamatan: desa.kecamatan || "",
			kabupaten: desa.kabupaten || "",
			provinsi: desa.provinsi || "",
			nama_desa: desa.nama_desa || "",
			kode_desa: desa.kode_desa || "",
			keterangan: desa.keterangan || "",
		});
		setFormError("");
		setShowCreateModal(false);
		setShowEditModal(true);
	};

	const handleSubmit = async (event) => {
		event.preventDefault();

		if (
			!formData.kecamatan.trim() ||
			!formData.kabupaten.trim() ||
			!formData.provinsi.trim() ||
			!formData.nama_desa.trim() ||
			!formData.kode_desa.trim()
		) {
			setFormError("Semua field utama wajib diisi");
			return;
		}

		try {
			setIsSubmitting(true);
			setFormError("");

			const payload = {
				kecamatan: formData.kecamatan.trim(),
				kabupaten: formData.kabupaten.trim(),
				provinsi: formData.provinsi.trim(),
				nama_desa: formData.nama_desa.trim(),
				kode_desa: formData.kode_desa.trim(),
				keterangan: formData.keterangan.trim() || null,
			};

			if (showCreateModal) {
				await createDesa(payload);
			} else if (selectedDesa) {
				await updateDesa(selectedDesa.id, payload);
			}

			setShowCreateModal(false);
			setShowEditModal(false);
			setSelectedDesa(null);
			resetForm();
			await fetchData();
		} catch (err) {
			setFormError(desaErrorMessage(err, "Gagal menyimpan data desa"));
		} finally {
			setIsSubmitting(false);
		}
	};

	const handleDeactivate = async (desa) => {
		const confirmed = window.confirm(`Nonaktifkan desa ${desa.nama_desa}?`);
		if (!confirmed) return;

		try {
			setIsSubmitting(true);
			await deactivateDesa(desa.id);
			await fetchData();
		} catch (err) {
			setError(desaErrorMessage(err, "Gagal menonaktifkan desa"));
		} finally {
			setIsSubmitting(false);
		}
	};

	return (
		<MainLayout>
			<div className="p-4 md:p-6 lg:p-8 max-w-full overflow-hidden">
				<div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between mb-6">
					<div>
						<h1 className="text-3xl font-bold text-gray-800">Kelola Desa</h1>
						<p className="text-gray-600 mt-1">Fitur terpisah untuk tambah, ubah, dan nonaktifkan desa</p>
					</div>
					<button
						onClick={openCreateModal}
						className="inline-flex items-center gap-2 bg-indigo-600 text-white px-4 py-2 rounded-lg hover:bg-indigo-700 transition"
					>
						<Plus size={18} />
						Tambah Desa
					</button>
				</div>

				<div className="bg-white rounded-xl border border-slate-200 p-4 mb-6 shadow-sm">
					<div className="relative">
						<Search className="absolute left-3 top-3 text-slate-400" size={18} />
						<input
							type="text"
							value={search}
							onChange={(e) => setSearch(e.target.value)}
							placeholder="Cari nama desa, kode, kecamatan, kabupaten, atau provinsi"
							className="w-full pl-10 pr-4 py-2.5 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-slate-900"
						/>
					</div>
				</div>

				{error && (
					<div className="bg-red-50 border border-red-200 rounded-lg p-4 mb-6 flex gap-3">
						<AlertCircle className="text-red-600 mt-1" size={20} />
						<div className="text-red-700">{error}</div>
					</div>
				)}

				<div className="bg-white rounded-xl border border-slate-200 overflow-hidden shadow-sm">
					{loading ? (
						<div className="p-10 text-center text-slate-500">Memuat data desa...</div>
					) : filteredDesa.length === 0 ? (
						<div className="p-10 text-center text-slate-500">Tidak ada data desa</div>
					) : (
						<div className="overflow-x-auto">
							<table className="w-full">
								<thead className="bg-slate-50 border-b border-slate-200">
									<tr>
										<th className="px-4 py-3 text-left text-xs font-semibold text-slate-700">Nama Desa</th>
										<th className="px-3 py-3 text-left text-xs font-semibold text-slate-700">Kecamatan</th>
										<th className="px-3 py-3 text-left text-xs font-semibold text-slate-700">Kabupaten</th>
										<th className="px-3 py-3 text-left text-xs font-semibold text-slate-700">Provinsi</th>
										<th className="px-3 py-3 text-left text-xs font-semibold text-slate-700">Kode</th>
										<th className="px-3 py-3 text-left text-xs font-semibold text-slate-700">Status</th>
										<th className="px-3 py-3 text-left text-xs font-semibold text-slate-700">Keterangan</th>
										<th className="px-3 py-3 text-center text-xs font-semibold text-slate-700">Aksi</th>
									</tr>
								</thead>
								<tbody>
									{filteredDesa.map((desa) => (
										<tr key={desa.id} className="border-b border-slate-100 hover:bg-slate-50/70">
											<td className="px-4 py-3">
												<div className="flex items-center gap-2">
													<div className="h-8 w-8 rounded-full bg-slate-100 flex items-center justify-center text-slate-700 flex-shrink-0">
														<MapPinned size={16} />
													</div>
													<div className="min-w-0">
														<div className="font-semibold text-sm text-slate-800 truncate">{desa.nama_desa}</div>
														<div className="text-xs text-slate-500">Dibuat {new Date(desa.created_at).toLocaleDateString("id-ID", { day: '2-digit', month: '2-digit', year: '2-digit' })}</div>
													</div>
												</div>
											</td>
											<td className="px-3 py-3 text-sm text-slate-600">{desa.kecamatan}</td>
											<td className="px-3 py-3 text-sm text-slate-600">{desa.kabupaten}</td>
											<td className="px-3 py-3 text-sm text-slate-600">{desa.provinsi}</td>
											<td className="px-3 py-3 text-sm text-slate-700 font-medium">{desa.kode_desa}</td>
											<td className="px-3 py-3">
												<span
													className={`inline-flex items-center gap-1 px-2 py-1 rounded-full text-xs font-medium whitespace-nowrap ${
														desa.is_active
															? "bg-emerald-50 text-emerald-700"
															: "bg-slate-100 text-slate-500"
													}`}
												>
													<CheckCircle2 size={12} />
													{desa.is_active ? "Aktif" : "Nonaktif"}
												</span>
											</td>
											<td className="px-3 py-3 text-sm text-slate-600 max-w-[150px] truncate" title={desa.keterangan}>
												{desa.keterangan || "-"}
											</td>
											<td className="px-3 py-3">
												<div className="flex items-center justify-center gap-1">
													<button
														onClick={() => openEditModal(desa)}
														className="inline-flex items-center gap-1 px-2 py-1.5 rounded-lg text-xs font-medium text-indigo-700 hover:bg-indigo-50 transition"
														title="Edit Desa"
													>
														<Edit size={14} />
														<span className="hidden lg:inline">Edit</span>
													</button>
													<button
														onClick={() => handleDeactivate(desa)}
														disabled={!desa.is_active || isSubmitting}
														className="inline-flex items-center gap-1 px-2 py-1.5 rounded-lg text-xs font-medium text-red-700 hover:bg-red-50 transition disabled:opacity-40 disabled:cursor-not-allowed"
														title="Nonaktifkan Desa"
													>
														<Power size={14} />
														<span className="hidden lg:inline">Nonaktif</span>
													</button>
												</div>
											</td>
										</tr>
									))}
								</tbody>
							</table>
						</div>
					)}
				</div>
			</div>

			{(showCreateModal || showEditModal) && (
				<div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-950/50 px-4">
					<div className="w-full max-w-2xl rounded-2xl bg-white shadow-2xl overflow-hidden">
						<div className="flex items-center justify-between px-6 py-4 border-b border-slate-200">
							<div>
								<h2 className="text-xl font-bold text-slate-800">
									{showCreateModal ? "Tambah Desa" : "Edit Desa"}
								</h2>
								<p className="text-sm text-slate-500">Lengkapi data desa secara konsisten</p>
							</div>
							<button
								onClick={() => {
									setShowCreateModal(false);
									setShowEditModal(false);
									setSelectedDesa(null);
									resetForm();
								}}
								className="p-2 rounded-lg hover:bg-slate-100"
							>
								<X size={20} />
							</button>
						</div>

						<form onSubmit={handleSubmit} className="p-6 space-y-4">
							{formError && (
								<div className="bg-red-50 border border-red-200 rounded-lg p-3 text-red-700 text-sm">
									{formError}
								</div>
							)}

							<div className="grid grid-cols-1 md:grid-cols-2 gap-4">
								<Field label="Nama Desa" value={formData.nama_desa} onChange={(value) => setFormData((prev) => ({ ...prev, nama_desa: value }))} />
								<Field label="Kode Desa" value={formData.kode_desa} onChange={(value) => setFormData((prev) => ({ ...prev, kode_desa: value }))} />
								<Field label="Kecamatan" value={formData.kecamatan} onChange={(value) => setFormData((prev) => ({ ...prev, kecamatan: value }))} />
								<Field label="Kabupaten" value={formData.kabupaten} onChange={(value) => setFormData((prev) => ({ ...prev, kabupaten: value }))} />
								<Field label="Provinsi" value={formData.provinsi} onChange={(value) => setFormData((prev) => ({ ...prev, provinsi: value }))} />
								<div className="space-y-2 md:col-span-2">
									<label className="block text-sm font-medium text-slate-700">Keterangan</label>
									<textarea
										rows={4}
										value={formData.keterangan}
										onChange={(e) => setFormData((prev) => ({ ...prev, keterangan: e.target.value }))}
										className="w-full rounded-lg border border-slate-300 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-slate-900"
										placeholder="Opsional"
									/>
								</div>
							</div>

							<div className="flex items-center justify-end gap-3 pt-2">
								<button
									type="button"
									onClick={() => {
										setShowCreateModal(false);
										setShowEditModal(false);
										setSelectedDesa(null);
										resetForm();
									}}
									className="px-4 py-2 rounded-lg border border-slate-300 text-slate-700 hover:bg-slate-50"
								>
									Batal
								</button>
								<button
									type="submit"
									disabled={isSubmitting}
									className="px-4 py-2 rounded-lg bg-indigo-600 text-white hover:bg-indigo-700 disabled:opacity-60"
								>
									{isSubmitting ? "Menyimpan..." : "Simpan"}
								</button>
							</div>
						</form>
					</div>
				</div>
			)}
		</MainLayout>
	);
}

function Field({ label, value, onChange }) {
	return (
		<div className="space-y-2">
			<label className="block text-sm font-medium text-slate-700">{label}</label>
			<input
				type="text"
				value={value}
				onChange={(e) => onChange(e.target.value)}
				className="w-full rounded-lg border border-slate-300 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-slate-900"
			/>
		</div>
	);
}