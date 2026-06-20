import React, { useState, useEffect } from "react";
import { 
  Plus, Trash2, Edit, Search, X, Filter, 
  ChevronLeft, ChevronRight, Users,
  RefreshCw
} from "lucide-react";
import MainLayout from "../../components/Layout/MainLayout";
import { 
  getPendudukWithFilters, 
  getPendudukById,
  createKependudukan, 
  updateKependudukan, 
  deleteKependudukan 
} from "../../services/kependudukan";
import { listDesa } from "../../services/desa";
import { getAllPosyandu } from "../../services/posyandu";

// Dropdown options
const GOLONGAN_DARAH_OPTIONS = ["", "A", "B", "AB", "O", "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"];
const AGAMA_OPTIONS = ["", "Islam", "Kristen Protestan", "Katolik", "Hindu", "Buddha", "Konghucu"];
const PENDIDIKAN_OPTIONS = ["", "Tidak/Belum Sekolah", "Belum Tamat SD/Sederajat", "Tamat SD/Sederajat", "SLTP/Sederajat", "SLTA/Sederajat", "Diploma I/II", "Akademi/Diploma III/S.Muda", "Diploma IV/Strata I", "Strata II", "Strata III"];
const STATUS_OPTIONS = ["", "Kawin", "Belum Kawin", "Cerai Hidup", "Cerai Mati"];
const HUBUNGAN_OPTIONS = ["", "Kepala Keluarga", "Istri", "Anak", "Menantu", "Cucu", "Orang Tua", "Mertua", "Keluarga Lainnya"];
const JENIS_KELAMIN_OPTIONS = ["Laki-laki", "Perempuan"];
const KEWARGANEGARAAN_OPTIONS = ["WNI", "WNA"];

const cardClass = "bg-white rounded-2xl shadow-sm border border-slate-100";

// Modal Component
const Modal = ({ isOpen, onClose, title, children }) => {
  if (!isOpen) return null;
  
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm">
      <div className="bg-white rounded-2xl shadow-xl max-w-4xl w-full max-h-[90vh] overflow-y-auto">
        <div className="sticky top-0 bg-white border-b border-slate-200 px-6 py-4 flex items-center justify-between">
          <h2 className="text-xl font-semibold text-slate-800">{title}</h2>
          <button 
            onClick={onClose}
            className="p-2 hover:bg-slate-100 rounded-full transition-colors"
          >
            <X size={20} className="text-slate-500" />
          </button>
        </div>
        <div className="p-6">
          {children}
        </div>
      </div>
    </div>
  );
};

// Form Modal for Create/Edit
const FormPenduduk = ({ 
  initialData = null, 
  onSubmit, 
  onCancel, 
  submitting,
  desasList,
  posyanduList
}) => {
  const isEdit = !!initialData;
  const [formData, setFormData] = useState({
    nik: "",
    nama_anggota_keluarga: "",
    jenis_kelamin: "Laki-laki",
    tanggal_lahir: "",
    tempat_lahir: "",
    golongan_darah: "",
    agama: "",
    status: "",
    pekerjaan: "",
    pendidikan: "",
    kewarganegaraan: "WNI",
    etnis_suku: "",
    hubungan: "",
    rw: "",
    rt: "",
    dusun: "",
    alamat: "",
    kode_keluarga: "",
    nama_kepala_keluarga: "",
    telepon: "",
    desa_id: "",
    posyandu_id: "",
  });

  useEffect(() => {
    if (initialData) {
      console.log("📋 [FormPenduduk] Initial data:", initialData);
      
      // Format tanggal lahir untuk input date (YYYY-MM-DD)
      let tanggalLahir = "";
      if (initialData.tanggal_lahir) {
        try {
          const date = new Date(initialData.tanggal_lahir);
          // Cek apakah tanggal valid (bukan 0001-01-01)
          if (date.getFullYear() > 1) {
            tanggalLahir = date.toISOString().split('T')[0];
          } else {
            tanggalLahir = "";
          }
        } catch {
          tanggalLahir = "";
        }
      }

      setFormData({
        nik: initialData.nik || "",
        nama_anggota_keluarga: initialData.nama_anggota_keluarga || "",
        jenis_kelamin: initialData.jenis_kelamin || "Laki-laki",
        tanggal_lahir: tanggalLahir,
        tempat_lahir: initialData.tempat_lahir || "",
        golongan_darah: initialData.golongan_darah || "",
        agama: initialData.agama || "",
        status: initialData.status || "",
        pekerjaan: initialData.pekerjaan || "",
        pendidikan: initialData.pendidikan || "",
        kewarganegaraan: initialData.kewarganegaraan || "WNI",
        etnis_suku: initialData.etnis_suku || "",
        hubungan: initialData.hubungan || "",
        rw: initialData.rw || "",
        rt: initialData.rt || "",
        dusun: initialData.dusun || "",
        alamat: initialData.alamat || "",
        kode_keluarga: initialData.kode_keluarga || "",
        nama_kepala_keluarga: initialData.nama_kepala_keluarga || "",
        telepon: initialData.telepon || "",
        desa_id: initialData.desa_id || "",
        posyandu_id: initialData.posyandu_id || "",
      });
    }
  }, [initialData]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    onSubmit(formData);
  };

  return (
    <form onSubmit={handleSubmit}>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {/* NIK */}
        <div>
          <label className="text-sm text-slate-600 font-medium">NIK <span className="text-red-500">*</span></label>
          <input
            type="text"
            name="nik"
            value={formData.nik}
            onChange={handleChange}
            className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500"
            placeholder="16 digit angka"
            maxLength={16}
            required
          />
        </div>

        {/* Nama Lengkap */}
        <div>
          <label className="text-sm text-slate-600 font-medium">Nama Lengkap <span className="text-red-500">*</span></label>
          <input
            type="text"
            name="nama_anggota_keluarga"
            value={formData.nama_anggota_keluarga}
            onChange={handleChange}
            className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500"
            placeholder="Nama lengkap"
            required
          />
        </div>

        {/* Jenis Kelamin */}
        <div>
          <label className="text-sm text-slate-600 font-medium">Jenis Kelamin <span className="text-red-500">*</span></label>
          <select
            name="jenis_kelamin"
            value={formData.jenis_kelamin}
            onChange={handleChange}
            className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500"
          >
            {JENIS_KELAMIN_OPTIONS.map(opt => <option key={opt} value={opt}>{opt}</option>)}
          </select>
        </div>

        {/* Tanggal Lahir */}
        <div>
          <label className="text-sm text-slate-600 font-medium">Tanggal Lahir <span className="text-red-500">*</span></label>
          <input
            type="date"
            name="tanggal_lahir"
            value={formData.tanggal_lahir}
            onChange={handleChange}
            className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500"
            required
          />
        </div>

        {/* Tempat Lahir */}
        <div>
          <label className="text-sm text-slate-600 font-medium">Tempat Lahir</label>
          <input
            type="text"
            name="tempat_lahir"
            value={formData.tempat_lahir}
            onChange={handleChange}
            className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500"
            placeholder="Kota/Kabupaten lahir"
          />
        </div>

        {/* Golongan Darah */}
        <div>
          <label className="text-sm text-slate-600 font-medium">Golongan Darah</label>
          <select
            name="golongan_darah"
            value={formData.golongan_darah}
            onChange={handleChange}
            className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500"
          >
            {GOLONGAN_DARAH_OPTIONS.map(opt => <option key={opt} value={opt}>{opt || "-- Pilih --"}</option>)}
          </select>
        </div>

        {/* Agama */}
        <div>
          <label className="text-sm text-slate-600 font-medium">Agama</label>
          <select
            name="agama"
            value={formData.agama}
            onChange={handleChange}
            className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500"
          >
            {AGAMA_OPTIONS.map(opt => <option key={opt} value={opt}>{opt || "-- Pilih --"}</option>)}
          </select>
        </div>

        {/* Status Perkawinan */}
        <div>
          <label className="text-sm text-slate-600 font-medium">Status Perkawinan</label>
          <select
            name="status"
            value={formData.status}
            onChange={handleChange}
            className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500"
          >
            {STATUS_OPTIONS.map(opt => <option key={opt} value={opt}>{opt || "-- Pilih --"}</option>)}
          </select>
        </div>

        {/* Pekerjaan */}
        <div>
          <label className="text-sm text-slate-600 font-medium">Pekerjaan</label>
          <input
            type="text"
            name="pekerjaan"
            value={formData.pekerjaan}
            onChange={handleChange}
            className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500"
            placeholder="Pekerjaan"
          />
        </div>

        {/* Pendidikan Terakhir */}
        <div>
          <label className="text-sm text-slate-600 font-medium">Pendidikan Terakhir</label>
          <select
            name="pendidikan"
            value={formData.pendidikan}
            onChange={handleChange}
            className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500"
          >
            {PENDIDIKAN_OPTIONS.map(opt => <option key={opt} value={opt}>{opt || "-- Pilih --"}</option>)}
          </select>
        </div>

        {/* Kewarganegaraan */}
        <div>
          <label className="text-sm text-slate-600 font-medium">Kewarganegaraan</label>
          <select
            name="kewarganegaraan"
            value={formData.kewarganegaraan}
            onChange={handleChange}
            className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500"
          >
            {KEWARGANEGARAAN_OPTIONS.map(opt => <option key={opt} value={opt}>{opt}</option>)}
          </select>
        </div>

        {/* Etnis/Suku */}
        <div>
          <label className="text-sm text-slate-600 font-medium">Etnis/Suku</label>
          <input
            type="text"
            name="etnis_suku"
            value={formData.etnis_suku}
            onChange={handleChange}
            className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500"
            placeholder="Contoh: Jawa, Sunda"
          />
        </div>

        {/* Hubungan Keluarga */}
        <div>
          <label className="text-sm text-slate-600 font-medium">Hubungan Keluarga <span className="text-red-500">*</span></label>
          <select
            name="hubungan"
            value={formData.hubungan}
            onChange={handleChange}
            className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500"
            required
          >
            {HUBUNGAN_OPTIONS.map(opt => <option key={opt} value={opt}>{opt || "-- Pilih --"}</option>)}
          </select>
        </div>

        {/* Kode Keluarga */}
        <div>
          <label className="text-sm text-slate-600 font-medium">Kode Keluarga</label>
          <input
            type="text"
            name="kode_keluarga"
            value={formData.kode_keluarga}
            onChange={handleChange}
            className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500"
            placeholder="KK-2024-001"
          />
        </div>

        {/* Nama Kepala Keluarga */}
        <div>
          <label className="text-sm text-slate-600 font-medium">Nama Kepala Keluarga</label>
          <input
            type="text"
            name="nama_kepala_keluarga"
            value={formData.nama_kepala_keluarga}
            onChange={handleChange}
            className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500"
            placeholder="Nama kepala keluarga"
          />
        </div>

        {/* RW */}
        <div>
          <label className="text-sm text-slate-600 font-medium">RW</label>
          <input
            type="text"
            name="rw"
            value={formData.rw}
            onChange={handleChange}
            className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500"
            placeholder="001"
          />
        </div>

        {/* RT */}
        <div>
          <label className="text-sm text-slate-600 font-medium">RT</label>
          <input
            type="text"
            name="rt"
            value={formData.rt}
            onChange={handleChange}
            className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500"
            placeholder="002"
          />
        </div>

        {/* Dusun */}
        <div>
          <label className="text-sm text-slate-600 font-medium">Dusun</label>
          <input
            type="text"
            name="dusun"
            value={formData.dusun}
            onChange={handleChange}
            className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500"
            placeholder="Nama dusun"
          />
        </div>

        {/* Alamat */}
        <div>
          <label className="text-sm text-slate-600 font-medium">Alamat</label>
          <input
            type="text"
            name="alamat"
            value={formData.alamat}
            onChange={handleChange}
            className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500"
            placeholder="Alamat lengkap"
          />
        </div>

        {/* No. Telepon */}
        <div>
          <label className="text-sm text-slate-600 font-medium">No. Telepon</label>
          <input
            type="text"
            name="telepon"
            value={formData.telepon}
            onChange={handleChange}
            className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500"
            placeholder="081234567890"
          />
        </div>

        {/* Desa */}
        <div>
          <label className="text-sm text-slate-600 font-medium">Desa <span className="text-red-500">*</span></label>
          <select
            name="desa_id"
            value={formData.desa_id}
            onChange={handleChange}
            className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500"
            required
          >
            <option value="">-- Pilih Desa --</option>
            {desasList.map((d) => (
              <option key={d.id} value={d.id}>{d.nama_desa}</option>
            ))}
          </select>
        </div>

        {/* Posyandu */}
        <div>
          <label className="text-sm text-slate-600 font-medium">Posyandu</label>
          <select
            name="posyandu_id"
            value={formData.posyandu_id}
            onChange={handleChange}
            className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500"
          >
            <option value="">-- Pilih Posyandu --</option>
            {posyanduList.map((p) => (
              <option key={p.id} value={p.id}>{p.nama}</option>
            ))}
          </select>
        </div>
      </div>
      <div className="flex justify-end gap-3 mt-6 pt-4 border-t border-slate-200">
        <button
          type="button"
          onClick={onCancel}
          className="px-4 py-2 rounded-xl border border-slate-200 text-slate-600 hover:bg-slate-50"
        >
          Batal
        </button>
        <button
          type="submit"
          disabled={submitting}
          className="px-6 py-2 rounded-xl bg-indigo-600 text-white hover:bg-indigo-700 disabled:opacity-60"
        >
          {submitting ? "Menyimpan..." : isEdit ? "Update" : "Simpan"}
        </button>
      </div>
    </form>
  );
};

// Main Component
const AdminPendudukList = () => {
  // State
  const [penduduks, setPenduduks] = useState([]);
  const [pagination, setPagination] = useState({ page: 1, limit: 10, total: 0, total_pages: 1 });
  const [loading, setLoading] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [desasList, setDesasList] = useState([]);
  const [posyanduList, setPosyanduList] = useState([]);
  const [showModal, setShowModal] = useState(false);
  const [editingData, setEditingData] = useState(null);
  const [search, setSearch] = useState("");
  const [filters, setFilters] = useState({
    rw: "",
    rt: "",
    dusun: "",
    kode_keluarga: "",
    status: "",
    hubungan: "",
    desa_id: "",
    posyandu_id: "",
  });
  const [showFilters, setShowFilters] = useState(false);
  const [message, setMessage] = useState({ type: "", text: "" });

  // Fetch data
  const fetchData = async (params = {}) => {
    setLoading(true);
    try {
      console.log("🔍 [fetchData] Fetching with params:", { 
        page: pagination.page, 
        limit: pagination.limit, 
        search, 
        filters, 
        ...params 
      });
      
      const result = await getPendudukWithFilters({
        page: pagination.page,
        limit: pagination.limit,
        search: search || undefined,
        ...filters,
        ...params,
      });
      
      console.log("✅ [fetchData] Result:", result);
      
      // Handle response array langsung
      if (Array.isArray(result)) {
        setPenduduks(result);
        setPagination({
          page: pagination.page || 1,
          limit: pagination.limit || 10,
          total: result.length,
          total_pages: Math.ceil(result.length / (pagination.limit || 10)) || 1,
        });
      } else if (result && typeof result === 'object' && result.items !== undefined) {
        setPenduduks(result.items || []);
        setPagination(result.pagination || { 
          page: 1, 
          limit: 10, 
          total: 0, 
          total_pages: 1 
        });
      } else {
        setPenduduks([]);
        setPagination({
          page: 1,
          limit: 10,
          total: 0,
          total_pages: 1,
        });
      }
    } catch (error) {
      console.error("❌ [fetchData] Error:", error);
      setMessage({ type: "error", text: error?.message || "Gagal memuat data" });
    } finally {
      setLoading(false);
    }
  };

  // Fetch master data
  useEffect(() => {
    const fetchMaster = async () => {
      try {
        console.log("📥 [fetchMaster] Loading master data...");
        const [desas, posyandus] = await Promise.all([
          listDesa(),
          getAllPosyandu()
        ]);
        setDesasList(desas || []);
        setPosyanduList(posyandus || []);
        console.log("✅ [fetchMaster] Desa:", desas?.length, "Posyandu:", posyandus?.length);
      } catch (err) {
        console.error("❌ [fetchMaster] Error:", err);
        setMessage({ type: "error", text: "Gagal memuat data master" });
      }
    };
    fetchMaster();
  }, []);

  // Initial fetch
  useEffect(() => {
    fetchData();
  }, [pagination.page, pagination.limit]);

  // Handle search
  const handleSearch = () => {
    console.log("🔍 [handleSearch] Searching:", search);
    fetchData({ page: 1 });
  };

  const handleSearchKeyDown = (e) => {
    if (e.key === 'Enter') {
      handleSearch();
    }
  };

  // Handle filter
  const handleFilterChange = (e) => {
    const { name, value } = e.target;
    setFilters(prev => ({ ...prev, [name]: value }));
  };

  const applyFilters = () => {
    console.log("🔍 [applyFilters] Filters:", filters);
    setShowFilters(false);
    fetchData({ page: 1 });
  };

  const clearFilters = () => {
    console.log("🔄 [clearFilters] Resetting filters");
    setFilters({
      rw: "",
      rt: "",
      dusun: "",
      kode_keluarga: "",
      status: "",
      hubungan: "",
      desa_id: "",
      posyandu_id: "",
    });
    setSearch("");
    fetchData({ page: 1 });
  };

  // Handle CRUD
  const handleCreate = () => {
    console.log("➕ [handleCreate] Opening create modal");
    setEditingData(null);
    setShowModal(true);
  };

  const handleEdit = async (data) => {
    // Ambil ID dari data (support berbagai format)
    const id = data.id || data.IDKependudukan;
    console.log("✏️ [handleEdit] Editing ID:", id);
    
    try {
      // Ambil data lengkap dari API
      const fullData = await getPendudukById(id);
      console.log("✅ [handleEdit] Full data from API:", fullData);
      
      // Set data lengkap ke editingData
      setEditingData(fullData);
      setShowModal(true);
    } catch (error) {
      console.error("❌ [handleEdit] Error fetching full data:", error);
      
      // Fallback: gunakan data dari tabel jika gagal fetch
      console.warn("⚠️ [handleEdit] Using table data as fallback");
      setEditingData(data);
      setShowModal(true);
      setMessage({ type: "error", text: "Gagal memuat data lengkap, menggunakan data yang tersedia" });
      setTimeout(() => setMessage({ type: "", text: "" }), 3000);
    }
  };

  const handleDelete = async (id, name) => {
    if (!window.confirm(`Yakin ingin menghapus data "${name}"?`)) return;
    
    try {
      console.log("🗑️ [handleDelete] Deleting ID:", id);
      await deleteKependudukan(id);
      setMessage({ type: "success", text: "Data berhasil dihapus" });
      fetchData();
      setTimeout(() => setMessage({ type: "", text: "" }), 3000);
    } catch (error) {
      console.error("❌ [handleDelete] Error:", error);
      const errorMsg = error?.message || "Gagal menghapus data";
      setMessage({ type: "error", text: errorMsg });
    }
  };

  const handleSubmit = async (formData) => {
    console.log("📝 [handleSubmit] Form data:", formData);
    setSubmitting(true);
    setMessage({ type: "", text: "" });
    
    try {
      // Format tanggal ke ISO 8601
      let tanggalLahir = "";
      if (formData.tanggal_lahir) {
        try {
          const date = new Date(formData.tanggal_lahir);
          tanggalLahir = date.toISOString();
          console.log("📅 [handleSubmit] Formatted date:", tanggalLahir);
        } catch (error) {
          console.warn("⚠️ [handleSubmit] Date format error:", error);
          tanggalLahir = formData.tanggal_lahir;
        }
      }

      const payload = {
        rw: formData.rw || "",
        rt: formData.rt || "",
        dusun: formData.dusun || "",
        alamat: formData.alamat || "",
        kode_keluarga: formData.kode_keluarga || "",
        nama_kepala_keluarga: formData.nama_kepala_keluarga || "",
        nik: formData.nik || "",
        nama_anggota_keluarga: formData.nama_anggota_keluarga || "",
        jenis_kelamin: formData.jenis_kelamin || "Laki-laki",
        hubungan: formData.hubungan || "",
        tempat_lahir: formData.tempat_lahir || "",
        tanggal_lahir: tanggalLahir,
        status: formData.status || "",
        agama: formData.agama || "",
        golongan_darah: formData.golongan_darah || "",
        kewarganegaraan: formData.kewarganegaraan || "WNI",
        etnis_suku: formData.etnis_suku || "",
        pendidikan: formData.pendidikan || "",
        pekerjaan: formData.pekerjaan || "",
        telepon: formData.telepon || "",
        desa_id: formData.desa_id ? parseInt(formData.desa_id, 10) : null,
        posyandu_id: formData.posyandu_id ? parseInt(formData.posyandu_id, 10) : null,
      };

      console.log("📦 [handleSubmit] Final payload:", JSON.stringify(payload, null, 2));

      if (editingData) {
        const id = editingData.id || editingData.IDKependudukan;
        console.log(`✏️ [handleSubmit] Updating ID: ${id}`);
        await updateKependudukan(id, payload);
        setMessage({ type: "success", text: "Data berhasil diupdate" });
      } else {
        console.log("➕ [handleSubmit] Creating new data");
        await createKependudukan(payload);
        setMessage({ type: "success", text: "Data berhasil ditambahkan" });
      }
      
      setShowModal(false);
      setEditingData(null);
      fetchData();
      setTimeout(() => setMessage({ type: "", text: "" }), 3000);
    } catch (error) {
      console.error("❌ [handleSubmit] Error caught!");
      console.error("❌ [handleSubmit] Error response:", error.response?.data);
      
      let errorText = "Gagal menyimpan data";
      if (error.response?.data?.message) {
        const msg = error.response.data.message;
        errorText = Array.isArray(msg) ? msg.join(", ") : msg;
      } else if (error.message) {
        errorText = error.message;
      }
      
      setMessage({ type: "error", text: errorText });
    } finally {
      setSubmitting(false);
      console.log("🏁 [handleSubmit] Finished");
    }
  };

  const handlePageChange = (newPage) => {
    if (newPage < 1 || newPage > pagination.total_pages) return;
    console.log("📄 [handlePageChange] Page:", newPage);
    setPagination(prev => ({ ...prev, page: newPage }));
  };

  // Format date
  const formatDate = (dateStr) => {
    if (!dateStr) return "-";
    try {
      const date = new Date(dateStr);
      // Cek apakah tanggal valid
      if (date.getFullYear() <= 1) return "-";
      return date.toLocaleDateString('id-ID', { day: '2-digit', month: '2-digit', year: 'numeric' });
    } catch {
      return dateStr;
    }
  };

  return (
    <MainLayout>
      <div className="space-y-6">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="p-3 bg-indigo-50 rounded-2xl">
              <Users className="w-6 h-6 text-indigo-600" />
            </div>
            <div>
              <h1 className="text-2xl font-bold text-slate-800">Data Penduduk</h1>
              <p className="text-sm text-slate-500">Kelola data penduduk</p>
            </div>
          </div>
          <button
            onClick={handleCreate}
            className="inline-flex items-center gap-2 rounded-xl bg-indigo-600 text-white px-4 py-2 text-sm font-medium hover:bg-indigo-700 transition-colors"
          >
            <Plus size={16} />
            Tambah Penduduk
          </button>
        </div>

        {/* Message */}
        {message.text && (
          <div className={`rounded-xl px-4 py-3 text-sm flex items-center gap-2 ${
            message.type === 'success' ? 'bg-emerald-50 border border-emerald-200 text-emerald-700' :
            message.type === 'error' ? 'bg-red-50 border border-red-200 text-red-700' :
            'bg-blue-50 border border-blue-200 text-blue-700'
          }`}>
            <span>{message.type === 'success' ? '✓' : message.type === 'error' ? '✕' : 'ℹ'}</span>
            {message.text}
          </div>
        )}

        {/* Search & Filter */}
        <div className="flex flex-wrap items-center gap-3">
          <div className="flex-1 min-w-[200px] relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
            <input
              type="text"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              onKeyDown={handleSearchKeyDown}
              placeholder="Cari NIK, Nama, atau Kode Keluarga..."
              className="w-full pl-10 pr-4 py-2 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>
          <button
            onClick={handleSearch}
            className="px-4 py-2 rounded-xl bg-indigo-600 text-white hover:bg-indigo-700 transition-colors"
          >
            Cari
          </button>
          <button
            onClick={() => setShowFilters(!showFilters)}
            className="inline-flex items-center gap-2 px-4 py-2 rounded-xl border border-slate-200 text-slate-600 hover:bg-slate-50 transition-colors"
          >
            <Filter size={16} />
            Filter
          </button>
          <button
            onClick={clearFilters}
            className="inline-flex items-center gap-2 px-4 py-2 rounded-xl border border-slate-200 text-slate-600 hover:bg-slate-50 transition-colors"
          >
            <RefreshCw size={16} />
            Reset
          </button>
        </div>

        {/* Filter Panel */}
        {showFilters && (
          <div className={`${cardClass} p-5 grid grid-cols-2 md:grid-cols-4 gap-4`}>
            <div>
              <label className="text-sm text-slate-600">RW</label>
              <input
                type="text"
                name="rw"
                value={filters.rw}
                onChange={handleFilterChange}
                className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500"
                placeholder="RW"
              />
            </div>
            <div>
              <label className="text-sm text-slate-600">RT</label>
              <input
                type="text"
                name="rt"
                value={filters.rt}
                onChange={handleFilterChange}
                className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500"
                placeholder="RT"
              />
            </div>
            <div>
              <label className="text-sm text-slate-600">Dusun</label>
              <input
                type="text"
                name="dusun"
                value={filters.dusun}
                onChange={handleFilterChange}
                className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500"
                placeholder="Dusun"
              />
            </div>
            <div>
              <label className="text-sm text-slate-600">Kode Keluarga</label>
              <input
                type="text"
                name="kode_keluarga"
                value={filters.kode_keluarga}
                onChange={handleFilterChange}
                className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500"
                placeholder="KK-2024-001"
              />
            </div>
            <div>
              <label className="text-sm text-slate-600">Status</label>
              <select
                name="status"
                value={filters.status}
                onChange={handleFilterChange}
                className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500"
              >
                <option value="">Semua</option>
                {STATUS_OPTIONS.filter(s => s).map(opt => (
                  <option key={opt} value={opt}>{opt}</option>
                ))}
              </select>
            </div>
            <div>
              <label className="text-sm text-slate-600">Hubungan</label>
              <select
                name="hubungan"
                value={filters.hubungan}
                onChange={handleFilterChange}
                className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500"
              >
                <option value="">Semua</option>
                {HUBUNGAN_OPTIONS.filter(s => s).map(opt => (
                  <option key={opt} value={opt}>{opt}</option>
                ))}
              </select>
            </div>
            <div>
              <label className="text-sm text-slate-600">Desa</label>
              <select
                name="desa_id"
                value={filters.desa_id}
                onChange={handleFilterChange}
                className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500"
              >
                <option value="">Semua Desa</option>
                {desasList.map((d) => (
                  <option key={d.id} value={d.id}>{d.nama_desa}</option>
                ))}
              </select>
            </div>
            <div>
              <label className="text-sm text-slate-600">Posyandu</label>
              <select
                name="posyandu_id"
                value={filters.posyandu_id}
                onChange={handleFilterChange}
                className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500"
              >
                <option value="">Semua Posyandu</option>
                {posyanduList.map((p) => (
                  <option key={p.id} value={p.id}>{p.nama}</option>
                ))}
              </select>
            </div>
            <div className="col-span-2 md:col-span-4 flex justify-end gap-2 pt-2">
              <button
                onClick={clearFilters}
                className="px-4 py-2 rounded-xl border border-slate-200 text-slate-600 hover:bg-slate-50"
              >
                Reset
              </button>
              <button
                onClick={applyFilters}
                className="px-4 py-2 rounded-xl bg-indigo-600 text-white hover:bg-indigo-700"
              >
                Terapkan Filter
              </button>
            </div>
          </div>
        )}

        {/* Table */}
        <div className={`${cardClass} overflow-hidden`}>
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-slate-50 border-b border-slate-200">
                <tr>
                  <th className="px-4 py-3 text-left text-xs font-semibold text-slate-600 uppercase tracking-wider">No</th>
                  <th className="px-4 py-3 text-left text-xs font-semibold text-slate-600 uppercase tracking-wider">NIK</th>
                  <th className="px-4 py-3 text-left text-xs font-semibold text-slate-600 uppercase tracking-wider">Nama</th>
                  <th className="px-4 py-3 text-left text-xs font-semibold text-slate-600 uppercase tracking-wider">Jenis Kelamin</th>
                  <th className="px-4 py-3 text-left text-xs font-semibold text-slate-600 uppercase tracking-wider">Hubungan</th>
                  <th className="px-4 py-3 text-left text-xs font-semibold text-slate-600 uppercase tracking-wider">Kode Keluarga</th>
                  <th className="px-4 py-3 text-left text-xs font-semibold text-slate-600 uppercase tracking-wider">Desa</th>
                  <th className="px-4 py-3 text-center text-xs font-semibold text-slate-600 uppercase tracking-wider">Aksi</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {loading ? (
                  <tr>
                    <td colSpan="8" className="px-4 py-8 text-center text-slate-500">Memuat data...</td>
                  </tr>
                ) : penduduks.length === 0 ? (
                  <tr>
                    <td colSpan="8" className="px-4 py-8 text-center text-slate-500">Tidak ada data</td>
                  </tr>
                ) : (
                  penduduks.map((item, index) => {
                    const itemId = item.id || item.IDKependudukan || index;
                    return (
                      <tr key={itemId} className="hover:bg-slate-50 transition-colors">
                        <td className="px-4 py-3 text-sm text-slate-600">
                          {(pagination.page - 1) * pagination.limit + index + 1}
                        </td>
                        <td className="px-4 py-3 text-sm font-mono text-slate-700">{item.nik || '-'}</td>
                        <td className="px-4 py-3 text-sm font-medium text-slate-800">
                          {item.nama_anggota_keluarga || item.nama_lengkap || '-'}
                        </td>
                        <td className="px-4 py-3 text-sm text-slate-600">{item.jenis_kelamin || '-'}</td>
                        <td className="px-4 py-3 text-sm text-slate-600">{item.hubungan || '-'}</td>
                        <td className="px-4 py-3 text-sm text-slate-600">{item.kode_keluarga || '-'}</td>
                        <td className="px-4 py-3 text-sm text-slate-600">
                          {item.desa?.nama_desa || '-'}
                        </td>
                        <td className="px-4 py-3 text-center">
                          <div className="flex items-center justify-center gap-2">
                            <button
                              onClick={() => handleEdit(item)}
                              className="p-1.5 rounded-lg text-blue-600 hover:bg-blue-50 transition-colors"
                              title="Edit"
                            >
                              <Edit size={16} />
                            </button>
                            <button
                              onClick={() => handleDelete(itemId, item.nama_anggota_keluarga || item.nama_lengkap)}
                              className="p-1.5 rounded-lg text-red-600 hover:bg-red-50 transition-colors"
                              title="Hapus"
                            >
                              <Trash2 size={16} />
                            </button>
                          </div>
                        </td>
                      </tr>
                    );
                  })
                )}
              </tbody>
            </table>
          </div>

          {/* Pagination */}
          {pagination.total > 0 && (
            <div className="px-4 py-3 border-t border-slate-200 flex items-center justify-between">
              <div className="text-sm text-slate-500">
                Menampilkan {((pagination.page - 1) * pagination.limit) + 1} - {Math.min(pagination.page * pagination.limit, pagination.total)} dari {pagination.total} data
              </div>
              <div className="flex items-center gap-2">
                <button
                  onClick={() => handlePageChange(pagination.page - 1)}
                  disabled={pagination.page === 1}
                  className="p-2 rounded-lg border border-slate-200 disabled:opacity-40 disabled:cursor-not-allowed hover:bg-slate-50"
                >
                  <ChevronLeft size={16} />
                </button>
                <span className="text-sm text-slate-600">
                  Halaman {pagination.page} dari {pagination.total_pages}
                </span>
                <button
                  onClick={() => handlePageChange(pagination.page + 1)}
                  disabled={pagination.page === pagination.total_pages}
                  className="p-2 rounded-lg border border-slate-200 disabled:opacity-40 disabled:cursor-not-allowed hover:bg-slate-50"
                >
                  <ChevronRight size={16} />
                </button>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Modal Create/Edit */}
      <Modal
        isOpen={showModal}
        onClose={() => {
          setShowModal(false);
          setEditingData(null);
        }}
        title={editingData ? "Edit Penduduk" : "Tambah Penduduk"}
      >
        <FormPenduduk
          initialData={editingData}
          onSubmit={handleSubmit}
          onCancel={() => {
            setShowModal(false);
            setEditingData(null);
          }}
          submitting={submitting}
          desasList={desasList}
          posyanduList={posyanduList}
        />
      </Modal>
    </MainLayout>
  );
};

export default AdminPendudukList;