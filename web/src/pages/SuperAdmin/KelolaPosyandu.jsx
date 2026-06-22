import { useState, useEffect, useMemo } from "react";
import { Plus, Pencil, Trash2, Home, X, Search } from "lucide-react";
import MainLayout from "../../components/Layout/MainLayout";
import Swal from "sweetalert2";
import Pagination from "../../components/Pagination/Pagination";
import {
	getAllPosyandu,
	createPosyandu,
	updatePosyandu,
	deletePosyandu,
} from "../../services/posyandu";
import { getAllPuskesmas } from "../../services/puskesmas";
import { listDesa } from "../../services/desa";

export default function KelolaPosyandu() {
	const [posyandu, setPosyandu] = useState([]);
	const [puskesmas, setPuskesmas] = useState([]);
	const [desa, setDesa] = useState([]);
	const [loading, setLoading] = useState(true);
	const [showModal, setShowModal] = useState(false);
	const [editMode, setEditMode] = useState(false);
	const [currentPosyandu, setCurrentPosyandu] = useState(null);
	const [formData, setFormData] = useState({
		id_puskesmas: "",
		desa_id: "",
		nama: "",
		alamat: "",
	});
	const [filterPuskesmas, setFilterPuskesmas] = useState("");
	const [search, setSearch] = useState("");

	// Pagination state
	const [currentPage, setCurrentPage] = useState(1);
	const [itemsPerPage] = useState(10);

	const fetchData = async () => {
		try {
			setLoading(true);
			const [posyanduData, puskesmasData, desaData] = await Promise.all([
				getAllPosyandu(
					filterPuskesmas ? { puskesmas_id: filterPuskesmas } : {}
				),
				getAllPuskesmas(),
				listDesa(),
			]);
			// Ensure posyanduData is always an array
			setPosyandu(Array.isArray(posyanduData) ? posyanduData : []);
			setPuskesmas(Array.isArray(puskesmasData) ? puskesmasData : []);
			setDesa(Array.isArray(desaData) ? desaData : []);
		} catch (error) {
			console.error("Error fetching data:", error);
			// Set empty arrays on error
			setPosyandu([]);
			Swal.fire("Error", "Gagal memuat data", "error");
		} finally {
			setLoading(false);
		}
	};

	useEffect(() => {
		fetchData();
		// eslint-disable-next-line react-hooks/exhaustive-deps
	}, [filterPuskesmas]);

	const handleOpenModal = (posyanduData = null) => {
		if (posyanduData) {
			setEditMode(true);
			setCurrentPosyandu(posyanduData);
			setFormData({
				id_puskesmas: posyanduData.id_puskesmas || "",
				desa_id: posyanduData.desa_id || "",
				nama: posyanduData.nama || "",
				alamat: posyanduData.alamat || "",
			});
		} else {
			setEditMode(false);
			setCurrentPosyandu(null);
			setFormData({
				id_puskesmas: "",
				desa_id: "",
				nama: "",
				alamat: "",
			});
		}
		setShowModal(true);
	};

	const handleCloseModal = () => {
		setShowModal(false);
		setEditMode(false);
		setCurrentPosyandu(null);
		setFormData({
			id_puskesmas: "",
			desa_id: "",
			nama: "",
			alamat: "",
		});
	};

	const handleSubmit = async (e) => {
		e.preventDefault();

		if (!formData.nama.trim()) {
			Swal.fire("Peringatan", "Nama posyandu wajib diisi", "warning");
			return;
		}

		if (!formData.id_puskesmas) {
			Swal.fire("Peringatan", "Puskesmas wajib dipilih", "warning");
			return;
		}

		if (!formData.desa_id) {
			Swal.fire("Peringatan", "Desa wajib dipilih", "warning");
			return;
		}

		try {
			const payload = {
				...formData,
				id_puskesmas: parseInt(formData.id_puskesmas),
				desa_id: parseInt(formData.desa_id),
			};

			if (editMode) {
				await updatePosyandu(currentPosyandu.id, payload);
				Swal.fire("Berhasil", "Posyandu berhasil diupdate", "success");
			} else {
				await createPosyandu(payload);
				Swal.fire("Berhasil", "Posyandu berhasil ditambahkan", "success");
			}
			handleCloseModal();
			fetchData();
		} catch (error) {
			Swal.fire("Error", error.response?.data?.error || error.response?.data?.message || "Gagal menyimpan posyandu", "error");
		}
	};

	const handleDelete = async (id) => {
		const result = await Swal.fire({
			title: "Hapus Posyandu?",
			text: "Apakah Anda yakin ingin menghapus posyandu ini?",
			icon: "warning",
			showCancelButton: true,
			confirmButtonColor: "#ef4444",
			confirmButtonText: "Hapus",
			cancelButtonText: "Batal",
		});
		if (!result.isConfirmed) return;

		try {
			await deletePosyandu(id);
			Swal.fire("Dihapus", "Posyandu berhasil dihapus", "success");
			fetchData();
		} catch (error) {
			Swal.fire("Error", error.response?.data?.error || error.response?.data?.message || "Gagal menghapus posyandu", "error");
		}
	};

	// Filter tabel berdasarkan kata kunci (nama posyandu, desa, puskesmas, alamat)
	const filteredPosyandu = useMemo(() => {
		const keyword = search.trim().toLowerCase();
		if (!keyword) return posyandu;
		return posyandu.filter((item) =>
			[item.nama, item.nama_desa, item.nama_puskesmas, item.alamat]
				.filter(Boolean)
				.some((v) => String(v).toLowerCase().includes(keyword))
		);
	}, [posyandu, search]);

	// Paginated data
	const paginatedPosyandu = useMemo(() => {
		const startIndex = (currentPage - 1) * itemsPerPage;
		const endIndex = startIndex + itemsPerPage;
		return filteredPosyandu.slice(startIndex, endIndex);
	}, [filteredPosyandu, currentPage, itemsPerPage]);

	// Reset to page 1 when search or filter changes
	useEffect(() => {
		setCurrentPage(1);
	}, [search, filterPuskesmas]);

	return (
		<MainLayout>
			<div className="p-6 bg-gray-50 min-h-screen">
				<div className="max-w-7xl mx-auto">
					{/* Search & Actions */}
					<div className="flex flex-wrap items-center gap-3 mb-6">
						<div className="flex-1 min-w-[200px] relative">
							<Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
							<input
								type="text"
								value={search}
								onChange={(e) => setSearch(e.target.value)}
								placeholder="Cari nama posyandu, desa, atau alamat..."
								className="w-full pl-10 pr-4 py-2.5 rounded-2xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-indigo-500"
							/>
						</div>
						<button
							type="button"
							className="inline-flex items-center gap-2 rounded-2xl bg-indigo-600 px-4 py-2.5 text-sm font-semibold text-white hover:bg-indigo-700 transition-colors"
						>
							<Search className="w-4 h-4" />
							Cari
						</button>
						<select
							value={filterPuskesmas}
							onChange={(e) => setFilterPuskesmas(e.target.value)}
							className="rounded-2xl px-4 py-2.5 border border-slate-200 focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
						>
							<option value="">Semua Puskesmas</option>
							{puskesmas.map((p) => (
								<option key={p.id} value={p.id}>
									{p.nama}
								</option>
							))}
						</select>
						<button
							onClick={() => handleOpenModal()}
							className="flex items-center gap-2 bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2.5 rounded-2xl font-medium transition-colors shadow-sm text-sm"
						>
							<Plus className="w-4 h-4" />
							Tambah Posyandu
						</button>
					</div>

					{/* Table */}
					<div className="bg-white rounded-xl shadow-sm overflow-hidden">
						{loading ? (
							<div className="p-8 text-center text-gray-500">
								Memuat data...
							</div>
						) : filteredPosyandu.length === 0 ? (
							<div className="p-8 text-center text-gray-500">
								{search 
									? "Tidak ada posyandu yang cocok dengan pencarian" 
									: filterPuskesmas 
										? "Belum ada data posyandu untuk puskesmas ini" 
										: "Belum ada data posyandu"}
							</div>
						) : (
							<div className="overflow-x-auto">
								<table className="w-full">
									<thead className="bg-gray-50 border-b border-gray-200">
										<tr>
											<th className="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
												No
											</th>
											<th className="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
												Nama Posyandu
											</th>
											<th className="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
												Desa
											</th>
											<th className="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
												Puskesmas
											</th>
											<th className="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
												Alamat
											</th>
											<th className="px-6 py-4 text-center text-xs font-semibold text-gray-600 uppercase tracking-wider">
												Aksi
											</th>
										</tr>
									</thead>
									<tbody className="divide-y divide-gray-200">
										{paginatedPosyandu.map((item, index) => (
											<tr
												key={item.id}
												className="hover:bg-gray-50 transition-colors"
											>
												<td className="px-6 py-4 text-sm text-gray-900">
													{(currentPage - 1) * itemsPerPage + index + 1}
												</td>
												<td className="px-6 py-4">
													<div className="flex items-center gap-2">
														<Home className="w-5 h-5 text-indigo-600" />
														<span className="font-medium text-gray-900">
															{item.nama}
														</span>
													</div>
												</td>
												<td className="px-6 py-4 text-sm text-gray-600">
													{item.nama_desa || "-"}
												</td>
												<td className="px-6 py-4 text-sm text-gray-600">
													{item.nama_puskesmas || "-"}
												</td>
												<td className="px-6 py-4 text-sm text-gray-600">
													{item.alamat || "-"}
												</td>
												<td className="px-6 py-4">
													<div className="flex items-center justify-center gap-2">
														<button
															onClick={() => handleOpenModal(item)}
															className="p-2 text-indigo-600 hover:bg-indigo-50 rounded-lg transition-colors"
															title="Edit"
														>
															<Pencil className="w-4 h-4" />
														</button>
														<button
															onClick={() => handleDelete(item.id)}
															className="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors"
															title="Hapus"
														>
															<Trash2 className="w-4 h-4" />
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
						{!loading && filteredPosyandu.length > 0 && (
							<Pagination
								currentPage={currentPage}
								totalPages={Math.ceil(filteredPosyandu.length / itemsPerPage)}
								totalItems={filteredPosyandu.length}
								itemsPerPage={itemsPerPage}
								onPageChange={(page) => setCurrentPage(page)}
								loading={loading}
							/>
						)}
					</div>
				</div>
			</div>

			{/* Modal Form */}
			{showModal && (
				<div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
					<div className="bg-white rounded-xl shadow-xl w-full max-w-md">
						<div className="flex items-center justify-between p-6 border-b border-gray-200">
							<h2 className="text-xl font-bold text-gray-800">
								{editMode ? "Edit Posyandu" : "Tambah Posyandu"}
							</h2>
							<button
								onClick={handleCloseModal}
								className="text-gray-400 hover:text-gray-600 transition-colors"
							>
								<X className="w-6 h-6" />
							</button>
						</div>

						<form onSubmit={handleSubmit} className="p-6 space-y-4">
							<div>
								<label className="block text-sm font-medium text-gray-700 mb-2">
									Puskesmas <span className="text-red-500">*</span>
								</label>
								<select
									value={formData.id_puskesmas}
									onChange={(e) =>
										setFormData({ ...formData, id_puskesmas: e.target.value })
									}
									className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
									required
								>
									<option value="">Pilih Puskesmas</option>
									{puskesmas.map((p) => (
										<option key={p.id} value={p.id}>
											{p.nama}
										</option>
									))}
								</select>
							</div>

							<div>
								<label className="block text-sm font-medium text-gray-700 mb-2">
									Desa <span className="text-red-500">*</span>
								</label>
								<select
									value={formData.desa_id}
									onChange={(e) =>
										setFormData({ ...formData, desa_id: e.target.value })
									}
									className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
									required
								>
									<option value="">Pilih Desa</option>
									{desa.map((d) => (
										<option key={d.id} value={d.id}>
											{d.nama_desa}
										</option>
									))}
								</select>
							</div>

							<div>
								<label className="block text-sm font-medium text-gray-700 mb-2">
									Nama Posyandu <span className="text-red-500">*</span>
								</label>
								<input
									type="text"
									value={formData.nama}
									onChange={(e) =>
										setFormData({ ...formData, nama: e.target.value })
									}
									className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
									placeholder="Masukkan nama posyandu"
									required
								/>
							</div>

							<div>
								<label className="block text-sm font-medium text-gray-700 mb-2">
									Alamat
								</label>
								<textarea
									value={formData.alamat}
									onChange={(e) =>
										setFormData({ ...formData, alamat: e.target.value })
									}
									className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
									placeholder="Masukkan alamat posyandu"
									rows="3"
								/>
							</div>

							<div className="flex gap-3 pt-4">
								<button
									type="button"
									onClick={handleCloseModal}
									className="flex-1 px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors"
								>
									Batal
								</button>
								<button
									type="submit"
									className="flex-1 px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition-colors"
								>
									{editMode ? "Update" : "Simpan"}
								</button>
							</div>
						</form>
					</div>
				</div>
			)}
		</MainLayout>
	);
}
