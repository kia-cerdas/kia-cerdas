import { useState, useEffect } from "react";
import { Plus, Pencil, Trash2, Building2, X } from "lucide-react";
import MainLayout from "../../components/Layout/MainLayout";
import Swal from "sweetalert2";
import {
	getAllPuskesmas,
	createPuskesmas,
	updatePuskesmas,
	deletePuskesmas,
} from "../../services/puskesmas";

export default function KelolaPuskesmas() {
	const [puskesmas, setPuskesmas] = useState([]);
	const [loading, setLoading] = useState(true);
	const [showModal, setShowModal] = useState(false);
	const [editMode, setEditMode] = useState(false);
	const [currentPuskesmas, setCurrentPuskesmas] = useState(null);
	const [formData, setFormData] = useState({
		nama: "",
		alamat: "",
		no_telepon: "",
	});

	useEffect(() => {
		fetchPuskesmas();
	}, []);

	const fetchPuskesmas = async () => {
		try {
			setLoading(true);
			const data = await getAllPuskesmas();
			setPuskesmas(data || []);
		} catch (error) {
			console.error("Error fetching puskesmas:", error);
			if (error.response) {
				const status = error.response.status;
				const msg = error.response.data?.message || error.response.data?.error;
				if (status === 401) {
					Swal.fire("Sesi Berakhir", "Sesi Anda telah berakhir. Silakan login kembali.", "warning");
				} else if (status === 403) {
					Swal.fire("Akses Ditolak", "Anda tidak memiliki akses untuk melihat data puskesmas.", "error");
				} else {
					Swal.fire("Error", msg || `Server error (${status}). Gagal memuat data puskesmas.`, "error");
				}
			} else if (error.request) {
				Swal.fire("Server Tidak Tersedia", "Tidak dapat terhubung ke server. Pastikan backend sudah berjalan di port 8080.", "error");
			} else {
				Swal.fire("Error", "Gagal memuat data puskesmas.", "error");
			}
		} finally {
			setLoading(false);
		}
	};

	const handleOpenModal = (puskesmasData = null) => {
		if (puskesmasData) {
			setEditMode(true);
			setCurrentPuskesmas(puskesmasData);
			setFormData({
				nama: puskesmasData.nama || "",
				alamat: puskesmasData.alamat || "",
				no_telepon: puskesmasData.no_telepon || "",
			});
		} else {
			setEditMode(false);
			setCurrentPuskesmas(null);
			setFormData({
				nama: "",
				alamat: "",
				no_telepon: "",
			});
		}
		setShowModal(true);
	};

	const handleCloseModal = () => {
		setShowModal(false);
		setEditMode(false);
		setCurrentPuskesmas(null);
		setFormData({
			nama: "",
			alamat: "",
			no_telepon: "",
		});
	};

	const handleSubmit = async (e) => {
		e.preventDefault();

		if (!formData.nama.trim()) {
			Swal.fire("Peringatan", "Nama puskesmas wajib diisi", "warning");
			return;
		}

		try {
			if (editMode) {
				await updatePuskesmas(currentPuskesmas.id, formData);
				Swal.fire("Berhasil", "Puskesmas berhasil diupdate", "success");
			} else {
				await createPuskesmas(formData);
				Swal.fire("Berhasil", "Puskesmas berhasil ditambahkan", "success");
			}
			handleCloseModal();
			fetchPuskesmas();
		} catch (error) {
			Swal.fire("Error", error.response?.data?.error || error.response?.data?.message || "Gagal menyimpan puskesmas", "error");
		}
	};

	const handleDelete = async (id) => {
		const result = await Swal.fire({
			title: "Hapus Puskesmas?",
			text: "Apakah Anda yakin ingin menghapus puskesmas ini?",
			icon: "warning",
			showCancelButton: true,
			confirmButtonColor: "#ef4444",
			confirmButtonText: "Hapus",
			cancelButtonText: "Batal",
		});
		if (!result.isConfirmed) return;

		try {
			await deletePuskesmas(id);
			Swal.fire("Dihapus", "Puskesmas berhasil dihapus", "success");
			fetchPuskesmas();
		} catch (error) {
			Swal.fire("Error", error.response?.data?.error || error.response?.data?.message || "Gagal menghapus puskesmas. Pastikan tidak ada posyandu terkait.", "error");
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
								<Building2 className="w-8 h-8 text-indigo-600" />
								<h1 className="text-3xl font-bold text-gray-800">
									Kelola Puskesmas
								</h1>
							</div>
							<p className="text-gray-600">
								Manajemen data puskesmas untuk sistem monitoring kesehatan
							</p>
						</div>
						<button
							onClick={() => handleOpenModal()}
							className="flex items-center gap-2 bg-indigo-600 hover:bg-indigo-700 text-white px-6 py-3 rounded-lg font-medium transition-colors shadow-sm mt-4 md:mt-0"
						>
							<Plus className="w-5 h-5" />
							Tambah Puskesmas
						</button>
					</div>

					{/* Table */}
					<div className="bg-white rounded-xl shadow-sm overflow-hidden">
						{loading ? (
							<div className="p-8 text-center text-gray-500">
								Memuat data...
							</div>
						) : puskesmas.length === 0 ? (
							<div className="p-8 text-center text-gray-500">
								Belum ada data puskesmas
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
												Nama Puskesmas
											</th>
											<th className="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
												Alamat
											</th>
											<th className="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
												No. Telepon
											</th>
											<th className="px-6 py-4 text-center text-xs font-semibold text-gray-600 uppercase tracking-wider">
												Aksi
											</th>
										</tr>
									</thead>
									<tbody className="divide-y divide-gray-200">
										{puskesmas.map((item, index) => (
											<tr
												key={item.id}
												className="hover:bg-gray-50 transition-colors"
											>
												<td className="px-6 py-4 text-sm text-gray-900">
													{index + 1}
												</td>
												<td className="px-6 py-4">
													<div className="flex items-center gap-2">
														<Building2 className="w-5 h-5 text-indigo-600" />
														<span className="font-medium text-gray-900">
															{item.nama}
														</span>
													</div>
												</td>
												<td className="px-6 py-4 text-sm text-gray-600">
													{item.alamat || "-"}
												</td>
												<td className="px-6 py-4 text-sm text-gray-600">
													{item.no_telepon || "-"}
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
								{editMode ? "Edit Puskesmas" : "Tambah Puskesmas"}
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
									Nama Puskesmas <span className="text-red-500">*</span>
								</label>
								<input
									type="text"
									value={formData.nama}
									onChange={(e) =>
										setFormData({ ...formData, nama: e.target.value })
									}
									className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
									placeholder="Masukkan nama puskesmas"
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
									placeholder="Masukkan alamat puskesmas"
									rows="3"
								/>
							</div>

							<div>
								<label className="block text-sm font-medium text-gray-700 mb-2">
									No. Telepon
								</label>
								<input
									type="text"
									value={formData.no_telepon}
									onChange={(e) =>
										setFormData({ ...formData, no_telepon: e.target.value })
									}
									className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
									placeholder="Contoh: 021-1234567"
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
