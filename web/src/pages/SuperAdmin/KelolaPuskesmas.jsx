import { useState, useEffect, useMemo } from "react";
import { Plus, Pencil, Trash2, Building2, X, Search } from "lucide-react";
import MainLayout from "../../components/Layout/MainLayout";
import Swal from "sweetalert2";
import {
	getAllPuskesmas,
	createPuskesmas,
	updatePuskesmas,
	deletePuskesmas,
} from "../../services/puskesmas";
import { listProvinsi, listKabupaten, listKecamatan } from "../../services/wilayah";

export default function KelolaPuskesmas() {
	const [puskesmas, setPuskesmas] = useState([]);
	const [loading, setLoading] = useState(true);
	const [search, setSearch] = useState("");
	const [showModal, setShowModal] = useState(false);
	const [editMode, setEditMode] = useState(false);
	const [currentPuskesmas, setCurrentPuskesmas] = useState(null);
	const [formData, setFormData] = useState({
		nama: "",
		alamat: "",
		no_telepon: "",
		provinsi_id: "",
		kabupaten_id: "",
		kecamatan_id: "",
	});

	// Master wilayah untuk cascading dropdown
	const [provinsiList, setProvinsiList] = useState([]);
	const [kabupatenList, setKabupatenList] = useState([]);
	const [kecamatanList, setKecamatanList] = useState([]);

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
			// abaikan; dropdown akan kosong
		}
	};

	const kabupatenOptions = useMemo(
		() => (formData.provinsi_id ? kabupatenList.filter((k) => String(k.provinsi_id) === String(formData.provinsi_id)) : []),
		[kabupatenList, formData.provinsi_id]
	);
	const kecamatanOptions = useMemo(
		() => (formData.kabupaten_id ? kecamatanList.filter((k) => String(k.kabupaten_id) === String(formData.kabupaten_id)) : []),
		[kecamatanList, formData.kabupaten_id]
	);

	// Lookup nama kecamatan untuk kolom tabel
	const kecamatanNama = (id) => kecamatanList.find((k) => String(k.id) === String(id))?.nama || "-";

	// Sub-teks "Kabupaten, Provinsi" untuk kolom kecamatan (pakai data preload bila ada,
	// jika tidak fallback ke master list).
	const wilayahDariKecamatan = (id, preloadKecamatan) => {
		const kec = preloadKecamatan || kecamatanList.find((k) => String(k.id) === String(id));
		if (!kec) return "";
		const kab = kec.kabupaten || kabupatenList.find((k) => String(k.id) === String(kec.kabupaten_id));
		if (!kab) return "";
		const provNama = kab.provinsi?.nama || provinsiList.find((p) => String(p.id) === String(kab.provinsi_id))?.nama || "";
		return [kab.nama, provNama].filter(Boolean).join(", ");
	};

	// Filter tabel berdasarkan kata kunci pencarian (nama, alamat, telepon, kecamatan)
	const filteredPuskesmas = useMemo(() => {
		const keyword = search.trim().toLowerCase();
		if (!keyword) return puskesmas;
		return puskesmas.filter((p) => {
			const namaKec = p.kecamatan?.nama || kecamatanNama(p.kecamatan_id);
			return [p.nama, p.alamat, p.no_telepon, namaKec]
				.filter(Boolean)
				.some((v) => String(v).toLowerCase().includes(keyword));
		});
		// eslint-disable-next-line react-hooks/exhaustive-deps
	}, [puskesmas, search, kecamatanList]);

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

	useEffect(() => {
		fetchPuskesmas();
		fetchWilayah();
	}, []);

	const handleOpenModal = (puskesmasData = null) => {
		if (puskesmasData) {
			setEditMode(true);
			setCurrentPuskesmas(puskesmasData);
			// Prefill provinsi & kabupaten dari kecamatan induk
			const kec = puskesmasData.kecamatan_id
				? kecamatanList.find((k) => String(k.id) === String(puskesmasData.kecamatan_id))
				: null;
			const kab = kec ? kabupatenList.find((k) => String(k.id) === String(kec.kabupaten_id)) : null;
			setFormData({
				nama: puskesmasData.nama || "",
				alamat: puskesmasData.alamat || "",
				no_telepon: puskesmasData.no_telepon || "",
				provinsi_id: kab ? String(kab.provinsi_id) : "",
				kabupaten_id: kec ? String(kec.kabupaten_id) : "",
				kecamatan_id: puskesmasData.kecamatan_id ? String(puskesmasData.kecamatan_id) : "",
			});
		} else {
			setEditMode(false);
			setCurrentPuskesmas(null);
			setFormData({
				nama: "",
				alamat: "",
				no_telepon: "",
				provinsi_id: "",
				kabupaten_id: "",
				kecamatan_id: "",
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
			provinsi_id: "",
			kabupaten_id: "",
			kecamatan_id: "",
		});
	};

	const handleSubmit = async (e) => {
		e.preventDefault();

		if (!formData.nama.trim()) {
			Swal.fire("Peringatan", "Nama puskesmas wajib diisi", "warning");
			return;
		}

		const payload = {
			nama: formData.nama,
			alamat: formData.alamat,
			no_telepon: formData.no_telepon,
			kecamatan_id: formData.kecamatan_id ? Number(formData.kecamatan_id) : null,
		};

		try {
			if (editMode) {
				await updatePuskesmas(currentPuskesmas.id, payload);
				Swal.fire("Berhasil", "Puskesmas berhasil diupdate", "success");
			} else {
				await createPuskesmas(payload);
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
					{/* Actions */}
					<div className="flex flex-wrap items-center gap-3 mb-6">
						<div className="flex-1 min-w-[200px] relative">
							<Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
							<input
								type="text"
								value={search}
								onChange={(e) => setSearch(e.target.value)}
								placeholder="Cari nama puskesmas, kecamatan, atau alamat..."
								className="w-full pl-10 pr-4 py-2.5 rounded-2xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-indigo-500"
							/>
						</div>
						<button
							onClick={() => handleOpenModal()}
							className="flex items-center gap-2 bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2.5 rounded-2xl font-medium transition-colors shadow-sm text-sm"
						>
							<Plus className="w-4 h-4" />
							Tambah Puskesmas
						</button>
					</div>

					{/* Table */}
					<div className="bg-white rounded-xl shadow-sm overflow-hidden">
						{loading ? (
							<div className="p-8 text-center text-gray-500">
								Memuat data...
							</div>
						) : filteredPuskesmas.length === 0 ? (
							<div className="p-8 text-center text-gray-500">
								{search ? "Tidak ada puskesmas yang cocok dengan pencarian" : "Belum ada data puskesmas"}
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
												Kecamatan
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
										{filteredPuskesmas.map((item, index) => (
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
													{item.kecamatan_id ? (
														<div>
															<div className="font-medium text-gray-800">
																{item.kecamatan?.nama || kecamatanNama(item.kecamatan_id)}
															</div>
															{(() => {
																const wil = wilayahDariKecamatan(item.kecamatan_id, item.kecamatan);
																return wil ? (
																	<div className="text-xs text-gray-400">{wil}</div>
																) : null;
															})()}
														</div>
													) : (
														<span className="inline-flex rounded-full bg-slate-100 px-2.5 py-0.5 text-xs text-slate-400">
															Belum diatur
														</span>
													)}
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
					<div className="bg-white rounded-xl shadow-xl w-full max-w-lg max-h-[90vh] overflow-y-auto">
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

							{/* Cascading wilayah: Provinsi -> Kabupaten -> Kecamatan */}
							<div className="grid grid-cols-1 gap-3">
								<div>
									<label className="block text-sm font-medium text-gray-700 mb-2">Provinsi</label>
									<select
										value={formData.provinsi_id}
										onChange={(e) => setFormData({ ...formData, provinsi_id: e.target.value, kabupaten_id: "", kecamatan_id: "" })}
										className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
									>
										<option value="">Pilih Provinsi</option>
										{provinsiList.map((p) => (
											<option key={p.id} value={p.id}>{p.nama}</option>
										))}
									</select>
								</div>
								<div>
									<label className="block text-sm font-medium text-gray-700 mb-2">Kabupaten</label>
									<select
										value={formData.kabupaten_id}
										onChange={(e) => setFormData({ ...formData, kabupaten_id: e.target.value, kecamatan_id: "" })}
										disabled={!formData.provinsi_id}
										className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent disabled:bg-gray-100"
									>
										<option value="">{formData.provinsi_id ? "Pilih Kabupaten" : "Pilih provinsi dulu"}</option>
										{kabupatenOptions.map((k) => (
											<option key={k.id} value={k.id}>{k.nama}</option>
										))}
									</select>
								</div>
								<div>
									<label className="block text-sm font-medium text-gray-700 mb-2">Kecamatan</label>
									<select
										value={formData.kecamatan_id}
										onChange={(e) => setFormData({ ...formData, kecamatan_id: e.target.value })}
										disabled={!formData.kabupaten_id}
										className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent disabled:bg-gray-100"
									>
										<option value="">{formData.kabupaten_id ? "Pilih Kecamatan" : "Pilih kabupaten dulu"}</option>
										{kecamatanOptions.map((k) => (
											<option key={k.id} value={k.id}>{k.nama}</option>
										))}
									</select>
								</div>
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
