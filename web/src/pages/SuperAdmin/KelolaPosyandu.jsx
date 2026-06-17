import { useState, useEffect } from "react";
import { Plus, Pencil, Trash2, Home, X } from "lucide-react";
import MainLayout from "../../components/Layout/MainLayout";
import Swal from "sweetalert2";
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

	useEffect(() => {
		fetchData();
	}, [filterPuskesmas]);

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
			setPosyandu(posyanduData || []);
			setPuskesmas(puskesmasData || []);
			setDesa(desaData || []);
		} catch (error) {
			console.error("Error fetching data:", error);
			Swal.fire("Error", "Gagal memuat data", "error");
		} finally {
			setLoading(false);
		}
	};

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

	return (
		<MainLayout>
			<div className="p-6 bg-gray-50 min-h-screen">
				<div className="max-w-7xl mx-auto">
					{/* Header */}
					<div className="flex flex-col md:flex-row md:items-center md:justify-between mb-6">
						<div>
							<div className="flex items-center gap-3 mb-2">
								<Home className="w-8 h-8 text-indigo-600" />
								<h1 className="text-3xl font-bold text-gray-800">
									Kelola Posyandu
								</h1>
							</div>
							<p className="text-gray-600">
								Manajemen data posyandu untuk sistem monitoring kesehatan
							</p>
						</div>
						<button
							onClick={() => handleOpenModal()}
							className="flex items-center gap-2 bg-indigo-600 hover:bg-indigo-700 text-white px-6 py-3 rounded-lg font-medium transition-colors shadow-sm mt-4 md:mt-0"
						>
							<Plus className="w-5 h-5" />
							Tambah Posyandu
						</button>
					</div>

					{/* Filter */}
					<div className="mb-6">
						<div className="md:max-w-xs">
							<select
								value={filterPuskesmas}
								onChange={(e) => setFilterPuskesmas(e.target.value)}
								className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
							>
								<option value="">Semua Puskesmas</option>
								{puskesmas.map((p) => (
									<option key={p.id} value={p.id}>
										{p.nama}
									</option>
								))}
							</select>
						</div>
					</div>

					{/* Table */}
					<div className="bg-white rounded-xl shadow-sm overflow-hidden">
						{loading ? (
							<div className="p-8 text-center text-gray-500">
								Memuat data...
							</div>
						) : posyandu.length === 0 ? (
							<div className="p-8 text-center text-gray-500">
								Belum ada data posyandu
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
										{posyandu.map((item, index) => (
											<tr
												key={item.id}
												className="hover:bg-gray-50 transition-colors"
											>
												<td className="px-6 py-4 text-sm text-gray-900">
													{index + 1}
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
