import React, { useEffect, useMemo, useState } from "react";
import MainLayout from "../../components/Layout/MainLayout";
import Swal from "sweetalert2";
import Pagination from "../../components/Pagination/Pagination";
import {
	createDesa,
	deactivateDesa,
	desaErrorMessage,
	listDesa,
	updateDesa,
} from "../../services/desa";
import { listProvinsi, listKabupaten, listKecamatan } from "../../services/wilayah";
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
	provinsi_id: "",
	kabupaten_id: "",
	kecamatan_id: "",
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

	// Pagination state
	const [currentPage, setCurrentPage] = useState(1);
	const [itemsPerPage] = useState(10);

	// Master wilayah untuk cascading dropdown
	const [provinsiList, setProvinsiList] = useState([]);
	const [kabupatenList, setKabupatenList] = useState([]);
	const [kecamatanList, setKecamatanList] = useState([]);

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

	const fetchWilayah = async () => {
		try {
			const [prov, kab, kec] = await Promise.all([
				listProvinsi(),
				listKabupaten(),
				listKecamatan(),
			]);
			setProvinsiList(prov);
			setKabupatenList(kab);
			setKecamatanList(kec);
		} catch {
			// abaikan; dropdown akan kosong, user bisa retry
		}
	};

	useEffect(() => {
		fetchData();
		fetchWilayah();
	}, []);

	// Cascading: kabupaten ter-filter provinsi, kecamatan ter-filter kabupaten
	const kabupatenOptions = useMemo(
		() => (formData.provinsi_id ? kabupatenList.filter((k) => String(k.provinsi_id) === String(formData.provinsi_id)) : []),
		[kabupatenList, formData.provinsi_id]
	);
	const kecamatanOptions = useMemo(
		() => (formData.kabupaten_id ? kecamatanList.filter((k) => String(k.kabupaten_id) === String(formData.kabupaten_id)) : []),
		[kecamatanList, formData.kabupaten_id]
	);

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

	// Paginated data
	const paginatedDesa = useMemo(() => {
		const startIndex = (currentPage - 1) * itemsPerPage;
		const endIndex = startIndex + itemsPerPage;
		return filteredDesa.slice(startIndex, endIndex);
	}, [filteredDesa, currentPage, itemsPerPage]);

	// Reset to page 1 when search changes
	useEffect(() => {
		setCurrentPage(1);
	}, [search]);

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
		// Prefill id dari kecamatan_id; provinsi & kabupaten diturunkan dari master.
		const kec = desa.kecamatan_id
			? kecamatanList.find((k) => String(k.id) === String(desa.kecamatan_id))
			: null;
		setFormData({
			provinsi_id: kec ? String(kec.kabupaten?.provinsi_id ?? kabupatenList.find((k) => String(k.id) === String(kec.kabupaten_id))?.provinsi_id ?? "") : "",
			kabupaten_id: kec ? String(kec.kabupaten_id) : "",
			kecamatan_id: desa.kecamatan_id ? String(desa.kecamatan_id) : "",
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
			!formData.kecamatan_id ||
			!formData.nama_desa.trim() ||
			!formData.kode_desa.trim()
		) {
			setFormError("Wilayah (kecamatan), nama desa, dan kode desa wajib diisi");
			return;
		}

		try {
			setIsSubmitting(true);
			setFormError("");

			// String kecamatan/kabupaten/provinsi diisi backend dari master (sinkron).
			const payload = {
				kecamatan_id: Number(formData.kecamatan_id),
				nama_desa: formData.nama_desa.trim(),
				kode_desa: formData.kode_desa.trim(),
				keterangan: formData.keterangan.trim() || null,
			};

			if (showCreateModal) {
				await createDesa(payload);
				Swal.fire("Berhasil", "Desa berhasil ditambahkan", "success");
			} else if (selectedDesa) {
				await updateDesa(selectedDesa.id, payload);
				Swal.fire("Berhasil", "Desa berhasil diupdate", "success");
			}

			setShowCreateModal(false);
			setShowEditModal(false);
			setSelectedDesa(null);
			resetForm();
			await fetchData();
		} catch (err) {
			Swal.fire("Error", desaErrorMessage(err, "Gagal menyimpan data desa"), "error");
		} finally {
			setIsSubmitting(false);
		}
	};

	const handleDeactivate = async (desa) => {
		const result = await Swal.fire({
			title: "Nonaktifkan Desa?",
			text: `Apakah Anda yakin ingin menonaktifkan desa ${desa.nama_desa}?`,
			icon: "warning",
			showCancelButton: true,
			confirmButtonColor: "#ef4444",
			confirmButtonText: "Nonaktifkan",
			cancelButtonText: "Batal",
		});
		
		if (!result.isConfirmed) return;

		try {
			setIsSubmitting(true);
			await deactivateDesa(desa.id);
			await fetchData();
			Swal.fire("Berhasil", "Desa berhasil dinonaktifkan", "success");
		} catch (err) {
			Swal.fire("Error", desaErrorMessage(err, "Gagal menonaktifkan desa"), "error");
		} finally {
			setIsSubmitting(false);
		}
	};

	return (
		<MainLayout>
			<div className="p-4 md:p-6 lg:p-8 max-w-full overflow-hidden">
				<div className="flex flex-wrap items-center gap-3 mb-6">
					<div className="flex-1 min-w-[200px] relative">
						<Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" size={16} />
						<input
							type="text"
							value={search}
							onChange={(e) => setSearch(e.target.value)}
							placeholder="Cari nama desa, kode, kecamatan, kabupaten, atau provinsi"
							className="w-full pl-10 pr-4 py-2.5 border border-slate-200 rounded-2xl focus:outline-none focus:ring-2 focus:ring-indigo-500"
						/>
					</div>
					<button
						type="button"
						className="inline-flex items-center gap-2 rounded-2xl bg-indigo-600 px-4 py-2.5 text-sm font-semibold text-white hover:bg-indigo-700 transition-colors"
					>
						<Search size={16} />
						Cari
					</button>
					<button
						onClick={openCreateModal}
						className="inline-flex items-center gap-2 bg-indigo-600 text-white px-4 py-2.5 rounded-2xl hover:bg-indigo-700 transition text-sm font-semibold"
					>
						<Plus size={16} />
						Tambah Desa
					</button>
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
									{paginatedDesa.map((desa) => (
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

					{/* Pagination */}
					{!loading && filteredDesa.length > 0 && (
						<Pagination
							currentPage={currentPage}
							totalPages={Math.ceil(filteredDesa.length / itemsPerPage)}
							totalItems={filteredDesa.length}
							itemsPerPage={itemsPerPage}
							onPageChange={(page) => setCurrentPage(page)}
							loading={loading}
						/>
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
								{/* Cascading wilayah: Provinsi -> Kabupaten -> Kecamatan */}
								<SelectField
									label="Provinsi"
									value={formData.provinsi_id}
									onChange={(value) => setFormData((prev) => ({ ...prev, provinsi_id: value, kabupaten_id: "", kecamatan_id: "" }))}
									placeholder="Pilih Provinsi"
									options={provinsiList.map((p) => ({ value: p.id, label: p.nama }))}
								/>
								<SelectField
									label="Kabupaten"
									value={formData.kabupaten_id}
									onChange={(value) => setFormData((prev) => ({ ...prev, kabupaten_id: value, kecamatan_id: "" }))}
									placeholder={formData.provinsi_id ? "Pilih Kabupaten" : "Pilih provinsi dulu"}
									disabled={!formData.provinsi_id}
									options={kabupatenOptions.map((k) => ({ value: k.id, label: k.nama }))}
								/>
								<SelectField
									label="Kecamatan"
									value={formData.kecamatan_id}
									onChange={(value) => setFormData((prev) => ({ ...prev, kecamatan_id: value }))}
									placeholder={formData.kabupaten_id ? "Pilih Kecamatan" : "Pilih kabupaten dulu"}
									disabled={!formData.kabupaten_id}
									options={kecamatanOptions.map((k) => ({ value: k.id, label: k.nama }))}
								/>
								<Field label="Nama Desa" value={formData.nama_desa} onChange={(value) => setFormData((prev) => ({ ...prev, nama_desa: value }))} />
								<Field label="Kode Desa" value={formData.kode_desa} onChange={(value) => setFormData((prev) => ({ ...prev, kode_desa: value }))} />
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

function SelectField({ label, value, onChange, options, placeholder = "Pilih", disabled = false }) {
	return (
		<div className="space-y-2">
			<label className="block text-sm font-medium text-slate-700">{label}</label>
			<select
				value={value}
				onChange={(e) => onChange(e.target.value)}
				disabled={disabled}
				className="w-full rounded-lg border border-slate-300 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-slate-900 disabled:bg-slate-100 disabled:text-slate-400"
			>
				<option value="">{placeholder}</option>
				{options.map((opt) => (
					<option key={opt.value} value={opt.value}>{opt.label}</option>
				))}
			</select>
		</div>
	);
}