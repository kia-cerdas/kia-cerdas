// src/pages/SuperAdmin/AdminFormVersions.jsx
import { useState, useEffect } from "react";
import MainLayout from "../../components/Layout/MainLayout";
import {
  getFormVersions,
  createFormVersion,
  activateFormVersion,
  deactivateFormVersion,
  duplicateFormVersion,
  getVersionDetail,
  addQuestion,
  updateQuestion,
  deleteQuestion,
  addRiskRule,
  updateRiskRule,
  deleteRiskRule,
} from "../../services/formVersion";
import { Plus, Edit, Trash2, Copy, CheckCircle, XCircle, Eye } from "lucide-react";

export default function AdminFormVersions() {
  const [kelompok, setKelompok] = useState("remaja");
  const [versions, setVersions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selectedVersion, setSelectedVersion] = useState(null);
  const [questionsDetail, setQuestionsDetail] = useState([]);
  const [rulesDetail, setRulesDetail] = useState([]);
  const [loadingDetail, setLoadingDetail] = useState(false);
  const [showVersionModal, setShowVersionModal] = useState(false);
  const [showQuestionModal, setShowQuestionModal] = useState(false);
  const [showRuleModal, setShowRuleModal] = useState(false);
  const [editingQuestionId, setEditingQuestionId] = useState(null);
  const [editingRuleId, setEditingRuleId] = useState(null);
  const [versionForm, setVersionForm] = useState({
    nama: "",
    kelompok: "remaja",
    tahun: new Date().getFullYear(),
    keterangan: "",
  });
  const [questionForm, setQuestionForm] = useState({
    key: "",
    label: "",
    tipe: "teks",
    opsi: [],
    satuan: "",
    wajib: false,
    urutan: 0,
  });
  const [ruleForm, setRuleForm] = useState({
    nama_aturan: "",
    kondisi: { "==": [{ var: "" }, ""] },
    kategori_risiko: "Sedang",
    rekomendasi: "", // tambahan field rekomendasi
    prioritas: 1,
    is_active: true,
  });

  // Builder aturan (mudah untuk superadmin)
  const [ruleBuilder, setRuleBuilder] = useState({
    field: "",
    operator: "==",
    value: "",
  });

  // ==================== HELPER: DESKRIPSI ATURAN RISIKO (BAHASA INDONESIA) ====================
  const getRuleDescription = (kondisi) => {
    if (!kondisi || Object.keys(kondisi).length === 0) return "Kondisi tidak valid";
    try {
      if (kondisi["<"] && kondisi["<"][0]?.var && kondisi["<"][1] !== undefined) {
        return `${kondisi["<"][0].var} kurang dari ${kondisi["<"][1]}`;
      }
      if (kondisi["<="] && kondisi["<="][0]?.var && kondisi["<="][1] !== undefined) {
        return `${kondisi["<="][0].var} kurang dari atau sama dengan ${kondisi["<="][1]}`;
      }
      if (kondisi[">"] && kondisi[">"][0]?.var && kondisi[">"][1] !== undefined) {
        return `${kondisi[">"][0].var} lebih dari ${kondisi[">"][1]}`;
      }
      if (kondisi[">="] && kondisi[">="][0]?.var && kondisi[">="][1] !== undefined) {
        return `${kondisi[">="][0].var} lebih dari atau sama dengan ${kondisi[">="][1]}`;
      }
      if (kondisi["=="] && kondisi["=="][0]?.var && kondisi["=="][1] !== undefined) {
        return `${kondisi["=="][0].var} sama dengan "${kondisi["=="][1]}"`;
      }
      if (kondisi["!="] && kondisi["!="][0]?.var && kondisi["!="][1] !== undefined) {
        return `${kondisi["!="][0].var} tidak sama dengan "${kondisi["!="][1]}"`;
      }
      if (kondisi["in"] && kondisi["in"][0]?.var && kondisi["in"][1]) {
        return `${kondisi["in"][0].var} mengandung "${kondisi["in"][1]}"`;
      }
      if (kondisi["and"] || kondisi["or"]) {
        return `Kondisi kompleks: ${JSON.stringify(kondisi).substring(0, 80)}...`;
      }
      return JSON.stringify(kondisi);
    } catch {
      return "Kondisi tidak valid";
    }
  };

  // Generate JSON logic dari builder
  const generateJSONLogic = (field, operator, val) => {
    if (!field || val === "") return {};
    const opMap = {
      "==": "==",
      "!=": "!=",
      "<": "<",
      "<=": "<=",
      ">": ">",
      ">=": ">=",
      "contains": "in",
    };
    const op = opMap[operator];
    if (operator === "contains") {
      return { in: [{ var: field }, val] };
    }
    let numericVal = val;
    if (!isNaN(Number(val)) && val.trim() !== "") {
      numericVal = Number(val);
    }
    return { [op]: [{ var: field }, numericVal] };
  };

  // Update ruleForm.kondisi setiap kali builder berubah
  useEffect(() => {
    const newKondisi = generateJSONLogic(ruleBuilder.field, ruleBuilder.operator, ruleBuilder.value);
    if (Object.keys(newKondisi).length > 0) {
      setRuleForm((prev) => ({ ...prev, kondisi: newKondisi }));
    } else {
      setRuleForm((prev) => ({ ...prev, kondisi: {} }));
    }
  }, [ruleBuilder]);

  // RESET state saat kategori berubah
  useEffect(() => {
    setSelectedVersion(null);
    setQuestionsDetail([]);
    setRulesDetail([]);
  }, [kelompok]);

  useEffect(() => {
    setVersionForm((prev) => ({ ...prev, kelompok }));
  }, [kelompok]);

  useEffect(() => {
    if (kelompok) fetchVersions();
  }, [kelompok]);

  const fetchVersions = async () => {
    try {
      setLoading(true);
      const data = await getFormVersions(kelompok);
      setVersions(data);
    } catch (error) {
      console.error(error);
      alert("Gagal mengambil data versi");
    } finally {
      setLoading(false);
    }
  };

  const fetchVersionDetail = async (id) => {
    const numericId = Number(id);
    if (isNaN(numericId)) {
      alert("ID versi tidak valid");
      return;
    }
    setLoadingDetail(true);
    try {
      const detail = await getVersionDetail(numericId);
      setSelectedVersion(detail.versi);
      setQuestionsDetail(detail.pertanyaan || []);
      setRulesDetail(detail.aturan || []);
    } catch (error) {
      console.error(error);
      alert("Gagal mengambil detail versi");
      setSelectedVersion(null);
      setQuestionsDetail([]);
      setRulesDetail([]);
    } finally {
      setLoadingDetail(false);
    }
  };

  const handleCreateVersion = async () => {
    if (!versionForm.nama.trim()) {
      alert("Nama versi wajib diisi");
      return;
    }
    try {
      await createFormVersion(versionForm);
      setShowVersionModal(false);
      setVersionForm({ nama: "", kelompok, tahun: new Date().getFullYear(), keterangan: "" });
      fetchVersions();
    } catch (error) {
      alert(error.response?.data?.error || "Gagal membuat versi");
    }
  };

  const handleActivate = async (id) => {
    const numericId = Number(id);
    if (isNaN(numericId)) return;
    if (window.confirm("Aktivasi versi ini akan menonaktifkan versi aktif sebelumnya. Lanjutkan?")) {
      try {
        await activateFormVersion(numericId);
        fetchVersions();
      } catch (error) {
        alert(error.response?.data?.error || "Gagal mengaktifkan versi");
      }
    }
  };

  const handleDeactivate = async (id) => {
    const numericId = Number(id);
    if (isNaN(numericId)) return;
    try {
      await deactivateFormVersion(numericId);
      fetchVersions();
    } catch (error) {
      alert(error.response?.data?.error || "Gagal menonaktifkan versi");
    }
  };

  const handleDuplicate = async (id) => {
    const numericId = Number(id);
    if (isNaN(numericId)) return;
    const tahunBaru = prompt("Masukkan tahun baru:", new Date().getFullYear());
    if (!tahunBaru) return;
    const namaBaru = prompt("Masukkan nama baru:", "Copy dari versi");
    if (!namaBaru) return;
    try {
      await duplicateFormVersion(numericId, { tahun_baru: parseInt(tahunBaru), nama_baru: namaBaru, keterangan: "" });
      fetchVersions();
    } catch (error) {
      alert(error.response?.data?.error || "Gagal menduplikasi versi");
    }
  };

  // ==================== PERTANYAAN ====================
  const handleAddQuestion = async () => {
    const versiId = selectedVersion?.id;
    if (!versiId) {
      alert("Silakan pilih versi terlebih dahulu (klik tombol Detail pada versi yang diinginkan)");
      return;
    }
    if (!questionForm.key.trim() || !questionForm.label.trim()) {
      alert("Key dan label pertanyaan wajib diisi");
      return;
    }
    const payload = {
      key: questionForm.key,
      label: questionForm.label,
      tipe: questionForm.tipe,
      opsi: questionForm.opsi,
      satuan: questionForm.satuan,
      wajib: questionForm.wajib,
      urutan: Number(questionForm.urutan),
      validasi: null,
    };
    try {
      await addQuestion(Number(versiId), payload);
      setShowQuestionModal(false);
      resetQuestionForm();
      fetchVersionDetail(versiId);
    } catch (error) {
      console.error(error);
      alert(error.response?.data?.error || "Gagal menambah pertanyaan");
    }
  };

  const handleUpdateQuestion = async () => {
    if (!editingQuestionId) {
      alert("Tidak ada pertanyaan yang sedang diedit");
      return;
    }
    const payload = {
      label: questionForm.label,
      tipe: questionForm.tipe,
      opsi: questionForm.opsi,
      satuan: questionForm.satuan,
      wajib: questionForm.wajib,
      urutan: Number(questionForm.urutan),
      validasi: null,
    };
    try {
      await updateQuestion(Number(editingQuestionId), payload);
      setShowQuestionModal(false);
      resetQuestionForm();
      fetchVersionDetail(selectedVersion.id);
    } catch (error) {
      console.error(error);
      alert(error.response?.data?.error || "Gagal update pertanyaan");
    }
  };

  const handleDeleteQuestion = async (id) => {
    const numericId = Number(id);
    if (isNaN(numericId)) return;
    if (window.confirm("Hapus pertanyaan ini?")) {
      try {
        await deleteQuestion(numericId);
        fetchVersionDetail(selectedVersion.id);
      } catch (error) {
        alert(error.response?.data?.error || "Gagal menghapus pertanyaan");
      }
    }
  };

  // ==================== ATURAN RISIKO ====================
  const handleAddRule = async () => {
    const versiId = selectedVersion?.id;
    if (!versiId) {
      alert("Pilih versi terlebih dahulu (klik Detail pada versi)");
      return;
    }
    if (!ruleForm.nama_aturan.trim()) {
      alert("Nama aturan wajib diisi");
      return;
    }
    // Gunakan kondisi dari ruleForm (sudah diupdate oleh useEffect builder)
    try {
      await addRiskRule(Number(versiId), {
        nama_aturan: ruleForm.nama_aturan,
        kondisi: ruleForm.kondisi,
        kategori_risiko: ruleForm.kategori_risiko,
        rekomendasi: ruleForm.rekomendasi, // field rekomendasi
        prioritas: ruleForm.prioritas,
        is_active: ruleForm.is_active,
      });
      setShowRuleModal(false);
      resetRuleForm();
      fetchVersionDetail(versiId);
    } catch (error) {
      alert(error.response?.data?.error || "Gagal menambah aturan risiko");
    }
  };

  const handleUpdateRule = async () => {
    if (!editingRuleId) {
      alert("Tidak ada aturan yang sedang diedit");
      return;
    }
    try {
      await updateRiskRule(Number(editingRuleId), {
        nama_aturan: ruleForm.nama_aturan,
        kondisi: ruleForm.kondisi,
        kategori_risiko: ruleForm.kategori_risiko,
        rekomendasi: ruleForm.rekomendasi, // field rekomendasi
        prioritas: ruleForm.prioritas,
        is_active: ruleForm.is_active,
      });
      setShowRuleModal(false);
      resetRuleForm();
      fetchVersionDetail(selectedVersion.id);
    } catch (error) {
      alert(error.response?.data?.error || "Gagal update aturan");
    }
  };

  const handleDeleteRule = async (id) => {
    const numericId = Number(id);
    if (isNaN(numericId)) return;
    if (window.confirm("Hapus aturan risiko ini?")) {
      try {
        await deleteRiskRule(numericId);
        fetchVersionDetail(selectedVersion.id);
      } catch (error) {
        alert(error.response?.data?.error || "Gagal menghapus aturan");
      }
    }
  };

  const toggleRuleStatus = async (rule) => {
    const updated = { ...rule, is_active: !rule.is_active };
    try {
      await updateRiskRule(rule.id, updated);
      fetchVersionDetail(selectedVersion.id);
    } catch (error) {
      alert(error.response?.data?.error || "Gagal mengubah status aturan");
    }
  };

  // ==================== MODAL HANDLERS ====================
  const openQuestionModal = (question = null) => {
    if (question) {
      setEditingQuestionId(question.id);
      setQuestionForm({
        key: question.key,
        label: question.label,
        tipe: question.tipe,
        opsi: question.opsi || [],
        satuan: question.satuan || "",
        wajib: question.wajib,
        urutan: question.urutan,
      });
    } else {
      resetQuestionForm();
    }
    setShowQuestionModal(true);
  };

  const openRuleModal = (rule = null) => {
    if (rule) {
      setEditingRuleId(rule.id);
      setRuleForm({
        nama_aturan: rule.nama_aturan,
        kondisi: rule.kondisi,
        kategori_risiko: rule.kategori_risiko,
        rekomendasi: rule.rekomendasi || "",
        prioritas: rule.prioritas,
        is_active: rule.is_active,
      });
      // Parsing kondisi ke ruleBuilder untuk menampilkan di builder visual saat edit
      const kondisi = rule.kondisi;
      let field = "", operator = "", value = "";
      if (kondisi["=="]) {
        field = kondisi["=="][0]?.var || "";
        value = kondisi["=="][1];
        operator = "==";
      } else if (kondisi["!="]) {
        field = kondisi["!="][0]?.var || "";
        value = kondisi["!="][1];
        operator = "!=";
      } else if (kondisi["<"]) {
        field = kondisi["<"][0]?.var || "";
        value = kondisi["<"][1];
        operator = "<";
      } else if (kondisi["<="]) {
        field = kondisi["<="][0]?.var || "";
        value = kondisi["<="][1];
        operator = "<=";
      } else if (kondisi[">"]) {
        field = kondisi[">"][0]?.var || "";
        value = kondisi[">"][1];
        operator = ">";
      } else if (kondisi[">="]) {
        field = kondisi[">="][0]?.var || "";
        value = kondisi[">="][1];
        operator = ">=";
      } else if (kondisi["in"]) {
        field = kondisi["in"][0]?.var || "";
        value = kondisi["in"][1];
        operator = "contains";
      }
      setRuleBuilder({ field, operator, value: String(value) });
    } else {
      resetRuleForm();
    }
    setShowRuleModal(true);
  };

  const resetQuestionForm = () => {
    setEditingQuestionId(null);
    setQuestionForm({
      key: "",
      label: "",
      tipe: "teks",
      opsi: [],
      satuan: "",
      wajib: false,
      urutan: 0,
    });
  };

  const resetRuleForm = () => {
    setEditingRuleId(null);
    setRuleForm({
      nama_aturan: "",
      kondisi: { "==": [{ var: "" }, ""] },
      kategori_risiko: "Sedang",
      rekomendasi: "",
      prioritas: 1,
      is_active: true,
    });
    setRuleBuilder({ field: "", operator: "==", value: "" });
  };

  if (loading) return <MainLayout><div className="p-6 text-center">Memuat data...</div></MainLayout>;

  return (
    <MainLayout>
      <div className="p-6 max-w-7xl mx-auto">
        <div className="flex justify-between items-center mb-6">
          <div>
            <h1 className="text-2xl font-bold">Kelola Form Versi</h1>
            <div className="flex gap-2 mt-2">
              {["anak", "remaja", "dewasa", "lansia"].map((k) => (
                <button
                  key={k}
                  onClick={() => {
                    setKelompok(k);
                    setSelectedVersion(null);
                  }}
                  className={`px-3 py-1 rounded-md text-sm ${
                    kelompok === k ? "bg-indigo-600 text-white" : "bg-gray-200 text-gray-700 hover:bg-gray-300"
                  }`}
                >
                  {k.toUpperCase()}
                </button>
              ))}
            </div>
          </div>
          <button
            onClick={() => setShowVersionModal(true)}
            className="bg-indigo-600 text-white px-4 py-2 rounded-lg flex items-center gap-2"
          >
            <Plus size={18} /> Versi Baru
          </button>
        </div>

        {/* Daftar Versi */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 mb-8">
          {versions.map((v) => (
            <div key={v.id} className="border rounded-lg p-4 shadow-sm bg-white">
              <div className="flex justify-between items-start">
                <div>
                  <h3 className="font-bold text-lg">{v.nama}</h3>
                  <p className="text-sm text-gray-500">{v.kelompok} - Tahun {v.tahun}</p>
                  <p className="text-xs text-gray-400 mt-1">{v.keterangan}</p>
                </div>
                <div>
                  {v.aktif ? (
                    <span className="inline-flex items-center gap-1 bg-green-100 text-green-800 px-2 py-1 rounded-full text-xs">
                      <CheckCircle size={12} /> Aktif
                    </span>
                  ) : (
                    <span className="inline-flex items-center gap-1 bg-gray-100 text-gray-600 px-2 py-1 rounded-full text-xs">
                      <XCircle size={12} /> Nonaktif
                    </span>
                  )}
                </div>
              </div>
              <div className="flex flex-wrap gap-2 mt-3">
                <button onClick={() => fetchVersionDetail(v.id)} className="text-blue-600 text-sm flex items-center gap-1">
                  <Eye size={14} /> Detail
                </button>
                {!v.aktif && <button onClick={() => handleActivate(v.id)} className="text-green-600 text-sm">Aktifkan</button>}
                {v.aktif && <button onClick={() => handleDeactivate(v.id)} className="text-yellow-600 text-sm">Nonaktifkan</button>}
                <button onClick={() => handleDuplicate(v.id)} className="text-purple-600 text-sm flex items-center gap-1">
                  <Copy size={14} /> Duplikasi
                </button>
              </div>
            </div>
          ))}
          {versions.length === 0 && (
            <div className="col-span-full text-center text-gray-400 py-8">Belum ada versi untuk kelompok {kelompok}</div>
          )}
        </div>

        {/* Detail Versi */}
        {selectedVersion && (
          <div className="border-t pt-6">
            <div className="flex justify-between items-center mb-4">
              <h2 className="text-xl font-bold">Detail: {selectedVersion.nama} (Tahun {selectedVersion.tahun})</h2>
              <button onClick={() => setSelectedVersion(null)} className="text-gray-500">Tutup</button>
            </div>
            <div className="border-b flex gap-4 mb-4">
              <button className="py-2 px-1 text-indigo-600 border-b-2 border-indigo-600">Pertanyaan</button>
              <button className="py-2 px-1 text-gray-500">Aturan Risiko</button>
            </div>

            {/* Pertanyaan */}
            <div>
              <div className="flex justify-end mb-3">
                <button onClick={openQuestionModal} className="bg-green-600 text-white px-3 py-1 rounded text-sm flex items-center gap-1">
                  <Plus size={14} /> Tambah Pertanyaan
                </button>
              </div>
              {loadingDetail ? (
                <div className="text-center py-4">Memuat pertanyaan...</div>
              ) : (
                <div className="space-y-2">
                  {questionsDetail.map((q) => (
                    <div key={q.id} className="border rounded p-3 flex justify-between items-center">
                      <div>
                        <div className="font-medium">{q.label}</div>
                        <div className="text-xs text-gray-500">
                          Key: {q.key} | Tipe: {q.tipe} {q.wajib && "(Wajib)"} | Urutan: {q.urutan}
                          {q.satuan && ` | Satuan: ${q.satuan}`}
                        </div>
                        {q.opsi?.length > 0 && <div className="text-xs text-gray-400">Opsi: {q.opsi.join(", ")}</div>}
                      </div>
                      <div className="flex gap-2">
                        <button onClick={() => openQuestionModal(q)} className="text-blue-600">
                          <Edit size={16} />
                        </button>
                        <button onClick={() => handleDeleteQuestion(q.id)} className="text-red-600">
                          <Trash2 size={16} />
                        </button>
                      </div>
                    </div>
                  ))}
                  {questionsDetail.length === 0 && <div className="text-center text-gray-400 py-4">Belum ada pertanyaan</div>}
                </div>
              )}
            </div>

            {/* Aturan Risiko */}
            <div className="mt-6">
              <div className="flex justify-between items-center mb-3">
                <div className="flex items-center gap-2">
                  <h3 className="text-md font-semibold">Aturan Risiko</h3>
                  <button onClick={() => openRuleModal()} className="bg-green-600 text-white px-3 py-1 rounded text-sm flex items-center gap-1">
                    <Plus size={14} /> Tambah Aturan
                  </button>
                </div>
              </div>
              {/* Panduan aturan */}
              <div className="mb-4 p-3 bg-blue-50 rounded-lg text-sm text-blue-800">
                <div className="flex items-center gap-2 mb-1">
                  <span>ℹ️</span>
                  <strong>Cara kerja aturan risiko:</strong>
                </div>
                <ul className="list-disc list-inside text-xs space-y-1">
                  <li>Aturan dievaluasi berurutan dari prioritas <strong>tertinggi</strong> (angka besar) ke terendah.</li>
                  <li>Aturan pertama yang kondisi terpenuhi akan menentukan <strong>kategori risiko</strong> (Tinggi/Sedang/Normal).</li>
                  <li>Jika tidak ada aturan yang cocok, risiko akan dianggap <strong>Normal</strong>.</li>
                  <li>Anda dapat menonaktifkan aturan tanpa menghapusnya.</li>
                </ul>
              </div>
              {loadingDetail ? (
                <div className="text-center py-4">Memuat aturan...</div>
              ) : (
                <div className="space-y-2">
                  {rulesDetail.map((r) => (
                    <div key={r.id} className="border rounded p-3 bg-white hover:shadow-sm transition">
                      <div className="flex justify-between items-start">
                        <div className="flex-1">
                          <div className="font-medium text-gray-800">{r.nama_aturan}</div>
                          <div className="text-sm text-gray-700 mt-1">
                            <span className="font-medium">Jika</span> {getRuleDescription(r.kondisi)}
                          </div>
                          <div className="flex flex-wrap gap-x-4 gap-y-1 mt-1 text-xs">
                            <span className="text-gray-500">Prioritas: {r.prioritas}</span>
                            <span>
                              <span className="font-medium">Maka risiko:</span>{" "}
                              <span className={`font-medium ${
                                r.kategori_risiko === "Tinggi"
                                  ? "text-red-600"
                                  : r.kategori_risiko === "Sedang"
                                  ? "text-yellow-600"
                                  : "text-green-600"
                              }`}>
                                {r.kategori_risiko}
                              </span>
                            </span>
                            <span>
                              <span className="font-medium">Rekomendasi:</span>{" "}
                              <span className="font-medium text-blue-600">{r.rekomendasi || "-"}</span>
                            </span>
                            <span>
                              Status:{" "}
                              <span className={`font-medium ${r.is_active ? "text-green-600" : "text-gray-500"}`}>
                                {r.is_active ? "Aktif" : "Nonaktif"}
                              </span>
                            </span>
                          </div>
                        </div>
                        <div className="flex gap-2 ml-2">
                          <button
                            onClick={() => toggleRuleStatus(r)}
                            className={`text-xs px-2 py-1 rounded transition ${
                              r.is_active
                                ? "bg-gray-200 text-gray-700 hover:bg-gray-300"
                                : "bg-green-100 text-green-700 hover:bg-green-200"
                            }`}
                          >
                            {r.is_active ? "Nonaktifkan" : "Aktifkan"}
                          </button>
                          <button onClick={() => openRuleModal(r)} className="text-blue-600 hover:text-blue-800">
                            <Edit size={16} />
                          </button>
                          <button onClick={() => handleDeleteRule(r.id)} className="text-red-600 hover:text-red-800">
                            <Trash2 size={16} />
                          </button>
                        </div>
                      </div>
                    </div>
                  ))}
                  {rulesDetail.length === 0 && (
                    <div className="text-center text-gray-400 py-4">Belum ada aturan risiko</div>
                  )}
                </div>
              )}
            </div>
          </div>
        )}

        {/* Modal Buat Versi */}
        {showVersionModal && (
          <Modal title="Buat Versi Baru" onClose={() => setShowVersionModal(false)}>
            <input
              className="w-full border p-2 rounded mb-2"
              placeholder="Nama Versi"
              value={versionForm.nama}
              onChange={(e) => setVersionForm({ ...versionForm, nama: e.target.value })}
            />
            <input
              className="w-full border p-2 rounded mb-2"
              type="number"
              placeholder="Tahun"
              value={versionForm.tahun}
              onChange={(e) => setVersionForm({ ...versionForm, tahun: parseInt(e.target.value) })}
            />
            <textarea
              className="w-full border p-2 rounded mb-2"
              placeholder="Keterangan"
              rows={2}
              value={versionForm.keterangan}
              onChange={(e) => setVersionForm({ ...versionForm, keterangan: e.target.value })}
            />
            <button onClick={handleCreateVersion} className="bg-indigo-600 text-white px-4 py-2 rounded w-full">
              Simpan
            </button>
          </Modal>
        )}

        {/* Modal Pertanyaan */}
        {showQuestionModal && (
          <Modal title={editingQuestionId ? "Edit Pertanyaan" : "Tambah Pertanyaan"} onClose={() => setShowQuestionModal(false)}>
            <input
              className="w-full border p-2 rounded mb-2"
              placeholder="Key (unique identifier)"
              value={questionForm.key}
              onChange={(e) => setQuestionForm({ ...questionForm, key: e.target.value })}
            />
            <input
              className="w-full border p-2 rounded mb-2"
              placeholder="Label"
              value={questionForm.label}
              onChange={(e) => setQuestionForm({ ...questionForm, label: e.target.value })}
            />
            <select
              className="w-full border p-2 rounded mb-2"
              value={questionForm.tipe}
              onChange={(e) => setQuestionForm({ ...questionForm, tipe: e.target.value })}
            >
              <option value="teks">Teks</option>
              <option value="angka">Angka</option>
              <option value="pilihan">Pilihan</option>
              <option value="boolean">Boolean</option>
              <option value="tanggal">Tanggal</option>
            </select>
            {questionForm.tipe === "pilihan" && (
              <input
                className="w-full border p-2 rounded mb-2"
                placeholder="Opsi (pisahkan koma)"
                value={questionForm.opsi.join(",")}
                onChange={(e) =>
                  setQuestionForm({
                    ...questionForm,
                    opsi: e.target.value.split(",").map((s) => s.trim()),
                  })
                }
              />
            )}
            <input
              className="w-full border p-2 rounded mb-2"
              placeholder="Satuan"
              value={questionForm.satuan}
              onChange={(e) => setQuestionForm({ ...questionForm, satuan: e.target.value })}
            />
            <div className="flex items-center gap-2 mb-2">
              <input
                type="checkbox"
                checked={questionForm.wajib}
                onChange={(e) => setQuestionForm({ ...questionForm, wajib: e.target.checked })}
              />
              <label>Wajib diisi</label>
            </div>
            <input
              type="number"
              className="w-full border p-2 rounded mb-2"
              placeholder="Urutan"
              value={questionForm.urutan}
              onChange={(e) => setQuestionForm({ ...questionForm, urutan: parseInt(e.target.value) })}
            />
            <button
              onClick={editingQuestionId ? handleUpdateQuestion : handleAddQuestion}
              className="bg-indigo-600 text-white px-4 py-2 rounded w-full"
            >
              Simpan
            </button>
          </Modal>
        )}

        {/* Modal Aturan Risiko dengan builder visual */}
        {showRuleModal && (
          <Modal title={editingRuleId ? "Edit Aturan Risiko" : "Tambah Aturan Risiko"} onClose={() => setShowRuleModal(false)}>
            <div className="space-y-4">
              {/* Nama Aturan */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Nama Aturan <span className="text-red-500">*</span>
                </label>
                <input
                  type="text"
                  className="w-full border p-2 rounded-lg"
                  placeholder="Contoh: IMT Kurus, Tekanan Darah Tinggi, Anemia"
                  value={ruleForm.nama_aturan}
                  onChange={(e) => setRuleForm({ ...ruleForm, nama_aturan: e.target.value })}
                />
              </div>

              {/* Builder Kondisi */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Kondisi (Jika...)
                </label>
                <div className="flex flex-col sm:flex-row gap-2 items-center bg-gray-50 p-3 rounded-lg">
                  <select
                    className="w-full sm:w-1/2 border p-2 rounded-lg"
                    value={ruleBuilder.field}
                    onChange={(e) => setRuleBuilder({ ...ruleBuilder, field: e.target.value })}
                  >
                    <option value="">Pilih field pertanyaan</option>
                    {questionsDetail.map((q) => (
                      <option key={q.key} value={q.key}>
                        {q.label} ({q.key})
                      </option>
                    ))}
                  </select>
                  <select
                    className="w-full sm:w-1/3 border p-2 rounded-lg"
                    value={ruleBuilder.operator}
                    onChange={(e) => setRuleBuilder({ ...ruleBuilder, operator: e.target.value })}
                  >
                    <option value="==">sama dengan (=)</option>
                    <option value="!=">tidak sama dengan</option>
                    <option value="<">kurang dari</option>
                    <option value="<=">kurang dari atau sama dengan</option>
                    <option value=">">lebih dari</option>
                    <option value=">=">lebih dari atau sama dengan</option>
                    <option value="contains">mengandung teks</option>
                  </select>
                  <input
                    type="text"
                    className="w-full sm:w-1/2 border p-2 rounded-lg"
                    placeholder="Nilai (contoh: 18.5, Ya, Tinggi)"
                    value={ruleBuilder.value}
                    onChange={(e) => {
                      setRuleBuilder({ ...ruleBuilder, value: e.target.value });
                    }}
                  />
                </div>
                <p className="text-xs text-gray-500 mt-1">
                  * Pilih field pertanyaan, operator, dan nilai batas.
                </p>
              </div>

              {/* Live Preview */}
              {ruleBuilder.field && ruleBuilder.value && (
                <div className="bg-green-50 p-2 rounded text-sm text-green-800">
                  ✅ <strong>Jika</strong> {ruleBuilder.field} {
                    ruleBuilder.operator === "==" ? "sama dengan" :
                    ruleBuilder.operator === "!=" ? "tidak sama dengan" :
                    ruleBuilder.operator === "<" ? "kurang dari" :
                    ruleBuilder.operator === "<=" ? "kurang dari atau sama dengan" :
                    ruleBuilder.operator === ">" ? "lebih dari" :
                    ruleBuilder.operator === ">=" ? "lebih dari atau sama dengan" :
                    ruleBuilder.operator === "contains" ? "mengandung" : ""
                  } <strong>{ruleBuilder.value}</strong>
                </div>
              )}

              {/* Kategori Risiko */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Maka Kategori Risiko <span className="text-red-500">*</span>
                </label>
                <select
                  className="w-full border p-2 rounded-lg"
                  value={ruleForm.kategori_risiko}
                  onChange={(e) => setRuleForm({ ...ruleForm, kategori_risiko: e.target.value })}
                >
                  <option value="Rendah">Rendah (Risiko rendah)</option>
                  <option value="Sedang">Sedang (Perlu perhatian)</option>
                  <option value="Tinggi">Tinggi (Butuh tindakan segera)</option>
                </select>
              </div>

              {/* Rekomendasi - field baru */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Rekomendasi <span className="text-red-500">*</span>
                </label>
                <input
                  type="text"
                  className="w-full border p-2 rounded-lg"
                  placeholder="Contoh: Rujuk IGD, Berikan TTD, Edukasi gizi"
                  value={ruleForm.rekomendasi}
                  onChange={(e) => setRuleForm({ ...ruleForm, rekomendasi: e.target.value })}
                />
                <p className="text-xs text-gray-500 mt-1">
                  Rekomendasi akan ditampilkan ke petugas saat pemeriksaan selesai.
                </p>
              </div>

              {/* Prioritas */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Prioritas <span className="text-red-500">*</span>
                </label>
                <input
                  type="number"
                  className="w-full border p-2 rounded-lg"
                  placeholder="Semakin besar angka, semakin didahulukan"
                  value={ruleForm.prioritas}
                  onChange={(e) => setRuleForm({ ...ruleForm, prioritas: parseInt(e.target.value) })}
                  min="1"
                />
                <p className="text-xs text-gray-500">Aturan dengan prioritas tertinggi akan dievaluasi pertama.</p>
              </div>

              {/* Aktif / Nonaktif */}
              <div className="flex items-center gap-2">
                <input
                  type="checkbox"
                  id="ruleActive"
                  className="w-4 h-4"
                  checked={ruleForm.is_active}
                  onChange={(e) => setRuleForm({ ...ruleForm, is_active: e.target.checked })}
                />
                <label htmlFor="ruleActive" className="text-sm text-gray-700">
                  Aturan aktif (jika tidak aktif, tidak akan dievaluasi)
                </label>
              </div>

              {/* Preview JSON (opsional) */}
              <details className="text-xs text-gray-400">
                <summary>Lihat JSON Logic (opsional)</summary>
                <pre className="mt-1 p-2 bg-gray-100 rounded overflow-x-auto">
                  {JSON.stringify(ruleForm.kondisi, null, 2)}
                </pre>
              </details>

              {/* Tombol Aksi */}
              <div className="flex gap-3 pt-2">
                <button
                  onClick={editingRuleId ? handleUpdateRule : handleAddRule}
                  className="flex-1 bg-indigo-600 text-white px-4 py-2 rounded-lg hover:bg-indigo-700"
                >
                  Simpan
                </button>
                <button
                  onClick={() => setShowRuleModal(false)}
                  className="flex-1 bg-gray-200 text-gray-800 px-4 py-2 rounded-lg hover:bg-gray-300"
                >
                  Batal
                </button>
              </div>
            </div>
          </Modal>
        )}
      </div>
    </MainLayout>
  );
}

function Modal({ title, onClose, children }) {
  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-lg max-w-md w-full p-5">
        <div className="flex justify-between items-center mb-3">
          <h3 className="text-lg font-bold">{title}</h3>
          <button onClick={onClose} className="text-gray-400 text-2xl">&times;</button>
        </div>
        {children}
      </div>
    </div>
  );
}