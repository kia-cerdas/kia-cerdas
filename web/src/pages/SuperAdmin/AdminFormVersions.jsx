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
import { 
  Plus, 
  Edit, 
  Trash2, 
  Copy, 
  CheckCircle, 
  XCircle, 
  Eye, 
  RefreshCw,
  FileText,
  Layers,
  Settings,
  AlertTriangle,
  Shield,
  ChevronDown,
  ChevronUp,
  Zap,
  Code,
  List,
  ArrowUp,
  ArrowDown,
  Info
} from "lucide-react";

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
  const [activeTab, setActiveTab] = useState("questions");
  const [showJsonEditor, setShowJsonEditor] = useState(false);
  const [expandedRules, setExpandedRules] = useState({});
  
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
    rekomendasi: "",
    prioritas: 1,
    is_active: true,
  });

  // Rule builder state
  const [ruleBuilder, setRuleBuilder] = useState({
    type: "simple", // "simple" | "complex"
    field: "",
    operator: "==",
    value: "",
    logicType: "and", // "and" | "or"
    conditions: [],
  });

  // Get question keys for dropdown
  const questionKeys = questionsDetail.map(q => q.key);

  const getRuleDescription = (kondisi) => {
    if (!kondisi || Object.keys(kondisi).length === 0) return "Kondisi tidak valid";
    try {
      // Handle simple conditions
      if (kondisi["<"] && kondisi["<"][0]?.var && kondisi["<"][1] !== undefined) {
        return `${kondisi["<"][0].var} < ${kondisi["<"][1]}`;
      }
      if (kondisi["<="] && kondisi["<="][0]?.var && kondisi["<="][1] !== undefined) {
        return `${kondisi["<="][0].var} <= ${kondisi["<="][1]}`;
      }
      if (kondisi[">"] && kondisi[">"][0]?.var && kondisi[">"][1] !== undefined) {
        return `${kondisi[">"][0].var} > ${kondisi[">"][1]}`;
      }
      if (kondisi[">="] && kondisi[">="][0]?.var && kondisi[">="][1] !== undefined) {
        return `${kondisi[">="][0].var} >= ${kondisi[">="][1]}`;
      }
      if (kondisi["=="] && kondisi["=="][0]?.var && kondisi["=="][1] !== undefined) {
        return `${kondisi["=="][0].var} = "${kondisi["=="][1]}"`;
      }
      if (kondisi["!="] && kondisi["!="][0]?.var && kondisi["!="][1] !== undefined) {
        return `${kondisi["!="][0].var} != "${kondisi["!="][1]}"`;
      }
      if (kondisi["in"] && kondisi["in"][0]?.var && kondisi["in"][1]) {
        return `${kondisi["in"][0].var} mengandung "${kondisi["in"][1]}"`;
      }
      
      // Handle complex conditions
      if (kondisi["and"]) {
        const parts = kondisi["and"].map(c => getRuleDescription(c));
        return `(${parts.join(" DAN ")})`;
      }
      if (kondisi["or"]) {
        const parts = kondisi["or"].map(c => getRuleDescription(c));
        return `(${parts.join(" ATAU ")})`;
      }
      if (kondisi["sum"]) {
        const vars = kondisi["sum"].map(v => v.var || v).join(" + ");
        return `Jumlah (${vars})`;
      }
      
      return JSON.stringify(kondisi);
    } catch {
      return "Kondisi tidak valid";
    }
  };

  const getOperatorLabel = (op) => {
    const map = {
      "==": "sama dengan (=)",
      "!=": "tidak sama dengan",
      "<": "kurang dari",
      "<=": "kurang dari atau sama dengan",
      ">": "lebih dari",
      ">=": "lebih dari atau sama dengan",
      "contains": "mengandung teks",
      "sum": "jumlah dari"
    };
    return map[op] || op;
  };

  const generateJSONLogic = (builder) => {
    if (builder.type === "simple") {
      if (!builder.field || builder.value === "") return {};
      const opMap = {
        "==": "==",
        "!=": "!=",
        "<": "<",
        "<=": "<=",
        ">": ">",
        ">=": ">=",
        "contains": "in",
      };
      const op = opMap[builder.operator];
      if (builder.operator === "contains") {
        return { in: [{ var: builder.field }, builder.value] };
      }
      let numericVal = builder.value;
      if (!isNaN(Number(builder.value)) && builder.value.trim() !== "") {
        numericVal = Number(builder.value);
      }
      return { [op]: [{ var: builder.field }, numericVal] };
    } else {
      // Complex: build and/or with multiple conditions
      if (builder.conditions.length === 0) return {};
      const conditions = builder.conditions
        .filter(c => c.field && c.value)
        .map(c => {
          const opMap = {
            "==": "==",
            "!=": "!=",
            "<": "<",
            "<=": "<=",
            ">": ">",
            ">=": ">=",
          };
          const op = opMap[c.operator] || "==";
          let val = c.value;
          if (!isNaN(Number(c.value)) && c.value.trim() !== "") {
            val = Number(c.value);
          }
          return { [op]: [{ var: c.field }, val] };
        });
      
      if (conditions.length === 0) return {};
      if (conditions.length === 1) return conditions[0];
      
      const logicType = builder.logicType || "and";
      return { [logicType]: conditions };
    }
  };

  useEffect(() => {
    const newKondisi = generateJSONLogic(ruleBuilder);
    if (Object.keys(newKondisi).length > 0) {
      setRuleForm((prev) => ({ ...prev, kondisi: newKondisi }));
    }
  }, [ruleBuilder]);

  useEffect(() => {
    setSelectedVersion(null);
    setQuestionsDetail([]);
    setRulesDetail([]);
    setActiveTab("questions");
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

  const handleAddQuestion = async () => {
    const versiId = selectedVersion?.id;
    if (!versiId) {
      alert("Silakan pilih versi terlebih dahulu");
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

  const handleAddRule = async () => {
    const versiId = selectedVersion?.id;
    if (!versiId) {
      alert("Pilih versi terlebih dahulu");
      return;
    }
    if (!ruleForm.nama_aturan.trim()) {
      alert("Nama aturan wajib diisi");
      return;
    }
    if (!ruleForm.rekomendasi.trim()) {
      alert("Rekomendasi wajib diisi");
      return;
    }
    if (Object.keys(ruleForm.kondisi).length === 0) {
      alert("Kondisi aturan belum lengkap. Silakan pilih field dan nilai.");
      return;
    }
    try {
      await addRiskRule(Number(versiId), {
        nama_aturan: ruleForm.nama_aturan,
        kondisi: ruleForm.kondisi,
        kategori_risiko: ruleForm.kategori_risiko,
        rekomendasi: ruleForm.rekomendasi,
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
    if (!ruleForm.rekomendasi.trim()) {
      alert("Rekomendasi wajib diisi");
      return;
    }
    try {
      await updateRiskRule(Number(editingRuleId), {
        nama_aturan: ruleForm.nama_aturan,
        kondisi: ruleForm.kondisi,
        kategori_risiko: ruleForm.kategori_risiko,
        rekomendasi: ruleForm.rekomendasi,
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

  const toggleRuleExpand = (id) => {
    setExpandedRules(prev => ({ ...prev, [id]: !prev[id] }));
  };

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
      
      // Parse kondisi ke builder
      const kondisi = rule.kondisi;
      if (kondisi["and"] || kondisi["or"]) {
        // Complex condition
        const logicType = kondisi["and"] ? "and" : "or";
        const conditions = (kondisi["and"] || kondisi["or"]).map(c => {
          let field = "", operator = "==", value = "";
          if (c["=="]) { field = c["=="][0]?.var || ""; value = c["=="][1]; operator = "=="; }
          else if (c["!="]) { field = c["!="][0]?.var || ""; value = c["!="][1]; operator = "!="; }
          else if (c["<"]) { field = c["<"][0]?.var || ""; value = c["<"][1]; operator = "<"; }
          else if (c["<="]) { field = c["<="][0]?.var || ""; value = c["<="][1]; operator = "<="; }
          else if (c[">"]) { field = c[">"][0]?.var || ""; value = c[">"][1]; operator = ">"; }
          else if (c[">="]) { field = c[">="][0]?.var || ""; value = c[">="][1]; operator = ">="; }
          return { field, operator, value: String(value) };
        });
        setRuleBuilder({
          type: "complex",
          field: "",
          operator: "==",
          value: "",
          logicType: logicType,
          conditions: conditions.filter(c => c.field),
        });
      } else {
        // Simple condition
        let field = "", operator = "==", value = "";
        if (kondisi["=="]) { field = kondisi["=="][0]?.var || ""; value = kondisi["=="][1]; operator = "=="; }
        else if (kondisi["!="]) { field = kondisi["!="][0]?.var || ""; value = kondisi["!="][1]; operator = "!="; }
        else if (kondisi["<"]) { field = kondisi["<"][0]?.var || ""; value = kondisi["<"][1]; operator = "<"; }
        else if (kondisi["<="]) { field = kondisi["<="][0]?.var || ""; value = kondisi["<="][1]; operator = "<="; }
        else if (kondisi[">"]) { field = kondisi[">"][0]?.var || ""; value = kondisi[">"][1]; operator = ">"; }
        else if (kondisi[">="]) { field = kondisi[">="][0]?.var || ""; value = kondisi[">="][1]; operator = ">="; }
        else if (kondisi["in"]) { field = kondisi["in"][0]?.var || ""; value = kondisi["in"][1]; operator = "contains"; }
        setRuleBuilder({
          type: "simple",
          field: field,
          operator: operator,
          value: String(value),
          logicType: "and",
          conditions: [],
        });
      }
      setShowJsonEditor(false);
    } else {
      resetRuleForm();
      setShowJsonEditor(false);
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
    setRuleBuilder({
      type: "simple",
      field: "",
      operator: "==",
      value: "",
      logicType: "and",
      conditions: [],
    });
  };

  const addCondition = () => {
    setRuleBuilder(prev => ({
      ...prev,
      conditions: [...prev.conditions, { field: "", operator: "==", value: "" }]
    }));
  };

  const removeCondition = (index) => {
    setRuleBuilder(prev => ({
      ...prev,
      conditions: prev.conditions.filter((_, i) => i !== index)
    }));
  };

  const updateCondition = (index, field, value) => {
    setRuleBuilder(prev => ({
      ...prev,
      conditions: prev.conditions.map((c, i) => 
        i === index ? { ...c, [field]: value } : c
      )
    }));
  };

  const getRiskColor = (risk) => {
    const map = {
      "Tinggi": "bg-red-100 text-red-800 border-red-300",
      "Sedang": "bg-yellow-100 text-yellow-800 border-yellow-300",
      "Rendah": "bg-green-100 text-green-800 border-green-300",
      "Normal": "bg-blue-100 text-blue-800 border-blue-300"
    };
    return map[risk] || "bg-gray-100 text-gray-800 border-gray-300";
  };

  const getRiskIcon = (risk) => {
    const map = {
      "Tinggi": <AlertTriangle className="w-4 h-4 text-red-600" />,
      "Sedang": <Shield className="w-4 h-4 text-yellow-600" />,
      "Rendah": <CheckCircle className="w-4 h-4 text-green-600" />,
      "Normal": <CheckCircle className="w-4 h-4 text-blue-600" />
    };
    return map[risk] || <Shield className="w-4 h-4 text-gray-600" />;
  };

  if (loading) return <MainLayout><div className="p-6 text-center">Memuat data...</div></MainLayout>;

  return (
    <MainLayout>
      <div className="p-6 max-w-7xl mx-auto">
        {/* Header */}
        <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 mb-6">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Kelola Formulir Pemeriksaan</h1>
            <p className="text-sm text-gray-500">Buat dan kelola versi formulir serta aturan penentuan risiko</p>
          </div>
          <button
            onClick={() => setShowVersionModal(true)}
            className="bg-blue-600 text-white px-4 py-2 rounded-lg flex items-center gap-2 hover:bg-blue-700 transition shadow-sm"
          >
            <Plus size={18} /> Versi Baru
          </button>
        </div>

        {/* Tab Kelompok */}
        <div className="flex flex-wrap gap-2 mb-6">
          {["anak", "remaja", "dewasa", "lansia"].map((k) => (
            <button
              key={k}
              onClick={() => {
                setKelompok(k);
                setSelectedVersion(null);
              }}
              className={`px-4 py-2 rounded-lg text-sm font-medium transition ${
                kelompok === k 
                  ? "bg-blue-600 text-white shadow-md" 
                  : "bg-gray-100 text-gray-700 hover:bg-gray-200"
              }`}
            >
              {k.charAt(0).toUpperCase() + k.slice(1)}
            </button>
          ))}
        </div>

        {/* Daftar Versi */}
        <div className="mb-8">
          <h2 className="text-lg font-semibold text-gray-800 mb-3 flex items-center gap-2">
            <Layers size={20} className="text-blue-600" />
            Daftar Versi Formulir
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {versions.map((v) => (
              <div key={v.id} className="border rounded-xl p-4 shadow-sm bg-white hover:shadow-md transition">
                <div className="flex justify-between items-start">
                  <div className="flex-1">
                    <h3 className="font-bold text-gray-900">{v.nama}</h3>
                    <p className="text-sm text-gray-500">{v.kelompok} - Tahun {v.tahun}</p>
                    {v.keterangan && (
                      <p className="text-xs text-gray-400 mt-1">{v.keterangan}</p>
                    )}
                  </div>
                  <div>
                    {v.aktif ? (
                      <span className="inline-flex items-center gap-1 bg-green-100 text-green-800 px-2 py-1 rounded-full text-xs font-medium">
                        <CheckCircle size={12} /> Aktif
                      </span>
                    ) : (
                      <span className="inline-flex items-center gap-1 bg-gray-100 text-gray-500 px-2 py-1 rounded-full text-xs font-medium">
                        <XCircle size={12} /> Nonaktif
                      </span>
                    )}
                  </div>
                </div>
                <div className="flex flex-wrap gap-2 mt-3">
                  <button 
                    onClick={() => fetchVersionDetail(v.id)} 
                    className="text-blue-600 hover:text-blue-800 text-sm flex items-center gap-1 bg-blue-50 hover:bg-blue-100 px-3 py-1 rounded-lg transition"
                  >
                    <Eye size={14} /> Detail
                  </button>
                  {!v.aktif && (
                    <button 
                      onClick={() => handleActivate(v.id)} 
                      className="text-green-600 hover:text-green-800 text-sm flex items-center gap-1 bg-green-50 hover:bg-green-100 px-3 py-1 rounded-lg transition"
                    >
                      <CheckCircle size={14} /> Aktifkan
                    </button>
                  )}
                  {v.aktif && (
                    <button 
                      onClick={() => handleDeactivate(v.id)} 
                      className="text-yellow-600 hover:text-yellow-800 text-sm flex items-center gap-1 bg-yellow-50 hover:bg-yellow-100 px-3 py-1 rounded-lg transition"
                    >
                      <XCircle size={14} /> Nonaktifkan
                    </button>
                  )}
                  <button 
                    onClick={() => handleDuplicate(v.id)} 
                    className="text-purple-600 hover:text-purple-800 text-sm flex items-center gap-1 bg-purple-50 hover:bg-purple-100 px-3 py-1 rounded-lg transition"
                  >
                    <Copy size={14} /> Duplikasi
                  </button>
                </div>
              </div>
            ))}
            {versions.length === 0 && (
              <div className="col-span-full text-center text-gray-400 py-8 bg-gray-50 rounded-xl">
                <FileText className="w-12 h-12 mx-auto text-gray-300 mb-2" />
                <p>Belum ada versi untuk kelompok {kelompok}</p>
                <button 
                  onClick={() => setShowVersionModal(true)}
                  className="mt-2 text-blue-600 hover:text-blue-800 text-sm"
                >
                  + Buat versi baru
                </button>
              </div>
            )}
          </div>
        </div>

        {/* Detail Versi */}
        {selectedVersion && (
          <div className="border-t pt-6">
            <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-3 mb-4">
              <div>
                <h2 className="text-xl font-bold text-gray-900">
                  {selectedVersion.nama} 
                  <span className="text-sm font-normal text-gray-500 ml-2">
                    (Tahun {selectedVersion.tahun})
                  </span>
                </h2>
                <p className="text-sm text-gray-500">{selectedVersion.keterangan}</p>
              </div>
              <button 
                onClick={() => setSelectedVersion(null)} 
                className="text-gray-400 hover:text-gray-600 text-sm px-3 py-1 bg-gray-100 rounded-lg hover:bg-gray-200 transition"
              >
                Tutup Detail
              </button>
            </div>

            {/* Tabs */}
            <div className="border-b flex gap-2 mb-4">
              <button
                onClick={() => setActiveTab("questions")}
                className={`py-2 px-4 text-sm font-medium transition ${
                  activeTab === "questions"
                    ? "text-blue-600 border-b-2 border-blue-600"
                    : "text-gray-500 hover:text-gray-700"
                }`}
              >
                <span className="flex items-center gap-2">
                  <FileText size={16} /> Pertanyaan ({questionsDetail.length})
                </span>
              </button>
              <button
                onClick={() => setActiveTab("rules")}
                className={`py-2 px-4 text-sm font-medium transition ${
                  activeTab === "rules"
                    ? "text-blue-600 border-b-2 border-blue-600"
                    : "text-gray-500 hover:text-gray-700"
                }`}
              >
                <span className="flex items-center gap-2">
                  <Settings size={16} /> Aturan Risiko ({rulesDetail.length})
                </span>
              </button>
            </div>

            {/* Tab: Pertanyaan */}
            {activeTab === "questions" && (
              <div>
                <div className="flex justify-end mb-3">
                  <button 
                    onClick={() => openQuestionModal()} 
                    className="bg-green-600 text-white px-4 py-2 rounded-lg text-sm flex items-center gap-2 hover:bg-green-700 transition"
                  >
                    <Plus size={16} /> Tambah Pertanyaan
                  </button>
                </div>
                {loadingDetail ? (
                  <div className="text-center py-8">
                    <RefreshCw className="w-8 h-8 animate-spin text-blue-600 mx-auto" />
                    <p className="mt-2 text-gray-500">Memuat pertanyaan...</p>
                  </div>
                ) : (
                  <div className="space-y-2">
                    {questionsDetail.map((q) => (
                      <div key={q.id} className="border rounded-lg p-4 bg-white hover:shadow-sm transition">
                        <div className="flex justify-between items-start">
                          <div className="flex-1">
                            <div className="flex items-center gap-2 flex-wrap">
                              <span className="font-medium text-gray-900">{q.label}</span>
                              {q.wajib && (
                                <span className="text-xs bg-red-100 text-red-600 px-2 py-0.5 rounded-full">Wajib</span>
                              )}
                              <span className="text-xs bg-gray-100 text-gray-600 px-2 py-0.5 rounded-full">
                                {q.tipe}
                              </span>
                            </div>
                            <div className="text-xs text-gray-500 mt-1">
                              Key: <code className="bg-gray-100 px-1 rounded">{q.key}</code>
                              {q.satuan && ` | Satuan: ${q.satuan}`}
                              {q.urutan !== undefined && ` | Urutan: ${q.urutan}`}
                            </div>
                            {q.opsi?.length > 0 && (
                              <div className="text-xs text-gray-400 mt-1">
                                Opsi: {q.opsi.join(", ")}
                              </div>
                            )}
                          </div>
                          <div className="flex gap-1 ml-2">
                            <button 
                              onClick={() => openQuestionModal(q)} 
                              className="text-blue-600 hover:text-blue-800 p-1 rounded hover:bg-blue-50 transition"
                              title="Edit"
                            >
                              <Edit size={16} />
                            </button>
                            <button 
                              onClick={() => handleDeleteQuestion(q.id)} 
                              className="text-red-600 hover:text-red-800 p-1 rounded hover:bg-red-50 transition"
                              title="Hapus"
                            >
                              <Trash2 size={16} />
                            </button>
                          </div>
                        </div>
                      </div>
                    ))}
                    {questionsDetail.length === 0 && (
                      <div className="text-center text-gray-400 py-8 bg-gray-50 rounded-xl">
                        <FileText className="w-12 h-12 mx-auto text-gray-300 mb-2" />
                        <p>Belum ada pertanyaan</p>
                      </div>
                    )}
                  </div>
                )}
              </div>
            )}

            {/* Tab: Aturan Risiko */}
            {activeTab === "rules" && (
              <div>
                <div className="flex justify-between items-center mb-3">
                  <div className="text-sm text-gray-500">
                    Aturan dievaluasi dari prioritas tertinggi ke terendah
                  </div>
                  <button 
                    onClick={() => openRuleModal()} 
                    className="bg-green-600 text-white px-4 py-2 rounded-lg text-sm flex items-center gap-2 hover:bg-green-700 transition"
                  >
                    <Plus size={16} /> Tambah Aturan
                  </button>
                </div>

                {/* Panduan */}
                <div className="mb-4 p-4 bg-blue-50 rounded-xl border border-blue-200">
                  <div className="flex items-start gap-3">
                    <Info className="w-5 h-5 text-blue-600 mt-0.5" />
                    <div className="text-sm text-blue-800">
                      <strong className="block">Cara Kerja Aturan Risiko</strong>
                      <ul className="list-disc list-inside text-xs space-y-1 mt-1">
                        <li>Aturan dievaluasi berurutan dari prioritas <strong>tertinggi</strong> ke terendah</li>
                        <li>Aturan pertama yang kondisi terpenuhi akan menentukan <strong>kategori risiko</strong></li>
                        <li>Jika tidak ada aturan yang cocok, risiko akan dianggap <strong>Normal</strong></li>
                        <li>Aturan yang <strong>nonaktif</strong> tidak akan dievaluasi</li>
                      </ul>
                    </div>
                  </div>
                </div>

                {loadingDetail ? (
                  <div className="text-center py-8">
                    <RefreshCw className="w-8 h-8 animate-spin text-blue-600 mx-auto" />
                    <p className="mt-2 text-gray-500">Memuat aturan...</p>
                  </div>
                ) : (
                  <div className="space-y-3">
                    {rulesDetail
                      .sort((a, b) => b.prioritas - a.prioritas)
                      .map((r) => (
                        <div 
                          key={r.id} 
                          className={`border rounded-xl p-4 bg-white hover:shadow-md transition ${!r.is_active ? 'opacity-60' : ''}`}
                        >
                          <div className="flex justify-between items-start">
                            <div className="flex-1">
                              <div className="flex items-center gap-2 flex-wrap">
                                <button
                                  onClick={() => toggleRuleExpand(r.id)}
                                  className="text-gray-500 hover:text-gray-700"
                                >
                                  {expandedRules[r.id] ? <ChevronUp size={16} /> : <ChevronDown size={16} />}
                                </button>
                                <span className="font-medium text-gray-900">{r.nama_aturan}</span>
                                <span className={`text-xs font-medium px-2 py-0.5 rounded-full border ${getRiskColor(r.kategori_risiko)}`}>
                                  <span className="inline-flex items-center gap-1">
                                    {getRiskIcon(r.kategori_risiko)} {r.kategori_risiko}
                                  </span>
                                </span>
                                {!r.is_active && (
                                  <span className="text-xs bg-gray-200 text-gray-600 px-2 py-0.5 rounded-full">Nonaktif</span>
                                )}
                                <span className="text-xs bg-blue-100 text-blue-700 px-2 py-0.5 rounded-full">
                                  Prioritas: {r.prioritas}
                                </span>
                              </div>
                              
                              {expandedRules[r.id] && (
                                <>
                                  <div className="text-sm text-gray-600 mt-2">
                                    <span className="font-medium">Kondisi:</span> {getRuleDescription(r.kondisi)}
                                  </div>
                                  <div className="text-sm text-gray-600 mt-1">
                                    <span className="font-medium">Rekomendasi:</span>{" "}
                                    <span className="text-blue-600 font-medium">{r.rekomendasi || "-"}</span>
                                  </div>
                                  <div className="mt-2">
                                    <button
                                      onClick={() => {
                                        setShowJsonEditor(true);
                                        openRuleModal(r);
                                      }}
                                      className="text-xs text-gray-500 hover:text-gray-700 bg-gray-100 hover:bg-gray-200 px-2 py-1 rounded transition"
                                    >
                                      <Code size={12} className="inline mr-1" /> Lihat JSON
                                    </button>
                                  </div>
                                </>
                              )}
                            </div>
                            <div className="flex gap-1 ml-2">
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
                              <button 
                                onClick={() => openRuleModal(r)} 
                                className="text-blue-600 hover:text-blue-800 p-1 rounded hover:bg-blue-50 transition"
                                title="Edit"
                              >
                                <Edit size={16} />
                              </button>
                              <button 
                                onClick={() => handleDeleteRule(r.id)} 
                                className="text-red-600 hover:text-red-800 p-1 rounded hover:bg-red-50 transition"
                                title="Hapus"
                              >
                                <Trash2 size={16} />
                              </button>
                            </div>
                          </div>
                        </div>
                      ))}
                    {rulesDetail.length === 0 && (
                      <div className="text-center text-gray-400 py-8 bg-gray-50 rounded-xl">
                        <Settings className="w-12 h-12 mx-auto text-gray-300 mb-2" />
                        <p>Belum ada aturan risiko</p>
                      </div>
                    )}
                  </div>
                )}
              </div>
            )}
          </div>
        )}
      </div>

      {/* Modal Buat Versi */}
      {showVersionModal && (
        <Modal title="Buat Versi Baru" onClose={() => setShowVersionModal(false)}>
          <div className="space-y-3">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Nama Versi *</label>
              <input
                className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                placeholder="Contoh: Formulir Remaja v2"
                value={versionForm.nama}
                onChange={(e) => setVersionForm({ ...versionForm, nama: e.target.value })}
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Tahun *</label>
              <input
                className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                type="number"
                placeholder="2024"
                value={versionForm.tahun}
                onChange={(e) => setVersionForm({ ...versionForm, tahun: parseInt(e.target.value) })}
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Keterangan</label>
              <textarea
                className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                placeholder="Deskripsi versi ini"
                rows={2}
                value={versionForm.keterangan}
                onChange={(e) => setVersionForm({ ...versionForm, keterangan: e.target.value })}
              />
            </div>
            <button 
              onClick={handleCreateVersion} 
              className="w-full bg-blue-600 text-white py-2 rounded-lg hover:bg-blue-700 transition font-medium"
            >
              Simpan
            </button>
          </div>
        </Modal>
      )}

      {/* Modal Pertanyaan */}
      {showQuestionModal && (
        <Modal title={editingQuestionId ? "Edit Pertanyaan" : "Tambah Pertanyaan"} onClose={() => setShowQuestionModal(false)}>
          <div className="space-y-3">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Key (unique) *</label>
              <input
                className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500"
                placeholder="tekanan_darah_sistolik"
                value={questionForm.key}
                onChange={(e) => setQuestionForm({ ...questionForm, key: e.target.value })}
                disabled={!!editingQuestionId}
              />
              <p className="text-xs text-gray-400 mt-1">Identifier unik untuk field ini</p>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Label *</label>
              <input
                className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500"
                placeholder="Tekanan Darah Sistolik"
                value={questionForm.label}
                onChange={(e) => setQuestionForm({ ...questionForm, label: e.target.value })}
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Tipe Data *</label>
              <select
                className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500"
                value={questionForm.tipe}
                onChange={(e) => setQuestionForm({ ...questionForm, tipe: e.target.value })}
              >
                <option value="teks">Teks</option>
                <option value="angka">Angka</option>
                <option value="pilihan">Pilihan</option>
                <option value="boolean">Boolean (Ya/Tidak)</option>
                <option value="tanggal">Tanggal</option>
              </select>
            </div>
            {questionForm.tipe === "pilihan" && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Opsi (pisahkan koma)</label>
                <input
                  className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500"
                  placeholder="Ya, Tidak, Tidak Tahu"
                  value={questionForm.opsi.join(",")}
                  onChange={(e) =>
                    setQuestionForm({
                      ...questionForm,
                      opsi: e.target.value.split(",").map((s) => s.trim()),
                    })
                  }
                />
              </div>
            )}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Satuan</label>
              <input
                className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500"
                placeholder="mmHg, cm, kg, dll"
                value={questionForm.satuan}
                onChange={(e) => setQuestionForm({ ...questionForm, satuan: e.target.value })}
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Urutan</label>
              <input
                type="number"
                className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500"
                placeholder="0"
                value={questionForm.urutan}
                onChange={(e) => setQuestionForm({ ...questionForm, urutan: parseInt(e.target.value) })}
              />
            </div>
            <div className="flex items-center gap-2">
              <input
                type="checkbox"
                id="isRequired"
                checked={questionForm.wajib}
                onChange={(e) => setQuestionForm({ ...questionForm, wajib: e.target.checked })}
                className="w-4 h-4 text-blue-600 focus:ring-blue-500"
              />
              <label htmlFor="isRequired" className="text-sm text-gray-700">Wajib diisi</label>
            </div>
            <button
              onClick={editingQuestionId ? handleUpdateQuestion : handleAddQuestion}
              className="w-full bg-blue-600 text-white py-2 rounded-lg hover:bg-blue-700 transition font-medium"
            >
              {editingQuestionId ? "Update" : "Simpan"}
            </button>
          </div>
        </Modal>
      )}

      {/* Modal Aturan Risiko */}
      {showRuleModal && (
        <Modal title={editingRuleId ? "Edit Aturan Risiko" : "Tambah Aturan Risiko"} onClose={() => setShowRuleModal(false)}>
          <div className="space-y-4 max-h-[70vh] overflow-y-auto">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Nama Aturan <span className="text-red-500">*</span>
              </label>
              <input
                type="text"
                className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500"
                placeholder="Contoh: Gizi Buruk, Hipertensi Tahap 2"
                value={ruleForm.nama_aturan}
                onChange={(e) => setRuleForm({ ...ruleForm, nama_aturan: e.target.value })}
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Tipe Kondisi
              </label>
              <div className="flex gap-2 mb-2">
                <button
                  onClick={() => setRuleBuilder(prev => ({ ...prev, type: "simple" }))}
                  className={`px-3 py-1 rounded text-sm transition ${
                    ruleBuilder.type === "simple"
                      ? "bg-blue-600 text-white"
                      : "bg-gray-200 text-gray-700 hover:bg-gray-300"
                  }`}
                >
                  Sederhana
                </button>
                <button
                  onClick={() => setRuleBuilder(prev => ({ ...prev, type: "complex" }))}
                  className={`px-3 py-1 rounded text-sm transition ${
                    ruleBuilder.type === "complex"
                      ? "bg-blue-600 text-white"
                      : "bg-gray-200 text-gray-700 hover:bg-gray-300"
                  }`}
                >
                  Kompleks (AND/OR)
                </button>
              </div>
            </div>

            {ruleBuilder.type === "simple" ? (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Kondisi (Jika...) <span className="text-red-500">*</span>
                </label>
                <div className="bg-gray-50 p-3 rounded-lg space-y-2">
                  <div className="grid grid-cols-1 md:grid-cols-3 gap-2">
                    <select
                      className="border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500"
                      value={ruleBuilder.field}
                      onChange={(e) => setRuleBuilder({ ...ruleBuilder, field: e.target.value })}
                    >
                      <option value="">Pilih field</option>
                      {questionsDetail.map((q) => (
                        <option key={q.key} value={q.key}>
                          {q.label} ({q.key})
                        </option>
                      ))}
                    </select>
                    <select
                      className="border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500"
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
                      className="border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500"
                      placeholder="Nilai (contoh: 18.5)"
                      value={ruleBuilder.value}
                      onChange={(e) => setRuleBuilder({ ...ruleBuilder, value: e.target.value })}
                    />
                  </div>
                  {ruleBuilder.field && ruleBuilder.value && (
                    <div className="bg-green-50 p-2 rounded text-sm text-green-800">
                      <span className="font-medium">Jika</span> {ruleBuilder.field} {getOperatorLabel(ruleBuilder.operator)} <strong>{ruleBuilder.value}</strong>
                    </div>
                  )}
                </div>
              </div>
            ) : (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Kondisi Kompleks <span className="text-red-500">*</span>
                </label>
                <div className="bg-gray-50 p-3 rounded-lg space-y-3">
                  <div className="flex items-center gap-2">
                    <span className="text-sm font-medium">Gabungkan dengan:</span>
                    <select
                      className="border border-gray-300 rounded-lg px-3 py-1 text-sm focus:ring-2 focus:ring-blue-500"
                      value={ruleBuilder.logicType}
                      onChange={(e) => setRuleBuilder({ ...ruleBuilder, logicType: e.target.value })}
                    >
                      <option value="and">DAN (semua harus terpenuhi)</option>
                      <option value="or">ATAU (salah satu terpenuhi)</option>
                    </select>
                  </div>
                  
                  {ruleBuilder.conditions.map((cond, index) => (
                    <div key={index} className="flex items-center gap-2">
                      <span className="text-xs text-gray-500">#{index + 1}</span>
                      <select
                        className="flex-1 border border-gray-300 rounded-lg px-3 py-1 text-sm focus:ring-2 focus:ring-blue-500"
                        value={cond.field}
                        onChange={(e) => updateCondition(index, "field", e.target.value)}
                      >
                        <option value="">Pilih field</option>
                        {questionsDetail.map((q) => (
                          <option key={q.key} value={q.key}>
                            {q.label}
                          </option>
                        ))}
                      </select>
                      <select
                        className="w-32 border border-gray-300 rounded-lg px-3 py-1 text-sm focus:ring-2 focus:ring-blue-500"
                        value={cond.operator}
                        onChange={(e) => updateCondition(index, "operator", e.target.value)}
                      >
                        <option value="==">=</option>
                        <option value="!=">≠</option>
                        <option value="<">&lt;</option>
                        <option value="<=">≤</option>
                        <option value=">">&gt;</option>
                        <option value=">=">≥</option>
                      </select>
                      <input
                        type="text"
                        className="w-24 border border-gray-300 rounded-lg px-3 py-1 text-sm focus:ring-2 focus:ring-blue-500"
                        placeholder="Nilai"
                        value={cond.value}
                        onChange={(e) => updateCondition(index, "value", e.target.value)}
                      />
                      <button
                        onClick={() => removeCondition(index)}
                        className="text-red-500 hover:text-red-700"
                      >
                        <Trash2 size={16} />
                      </button>
                    </div>
                  ))}
                  
                  <button
                    onClick={addCondition}
                    className="text-blue-600 hover:text-blue-800 text-sm flex items-center gap-1"
                  >
                    <Plus size={14} /> Tambah kondisi
                  </button>
                  
                  {ruleBuilder.conditions.length > 0 && (
                    <div className="bg-green-50 p-2 rounded text-sm text-green-800">
                      <span className="font-medium">Preview:</span> {ruleBuilder.logicType === "and" ? "SEMUA" : "SATU DARI"} kondisi berikut terpenuhi
                    </div>
                  )}
                </div>
              </div>
            )}

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Kategori Risiko <span className="text-red-500">*</span>
              </label>
              <select
                className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500"
                value={ruleForm.kategori_risiko}
                onChange={(e) => setRuleForm({ ...ruleForm, kategori_risiko: e.target.value })}
              >
                <option value="Rendah">🟢 Rendah (Risiko rendah)</option>
                <option value="Sedang">🟡 Sedang (Perlu perhatian)</option>
                <option value="Tinggi">🔴 Tinggi (Butuh tindakan segera)</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Rekomendasi <span className="text-red-500">*</span>
              </label>
              <input
                type="text"
                className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500"
                placeholder="Contoh: Rujuk ke fasilitas kesehatan"
                value={ruleForm.rekomendasi}
                onChange={(e) => setRuleForm({ ...ruleForm, rekomendasi: e.target.value })}
              />
              <p className="text-xs text-gray-500 mt-1">Rekomendasi akan ditampilkan ke petugas saat pemeriksaan</p>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Prioritas <span className="text-red-500">*</span>
              </label>
              <input
                type="number"
                className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500"
                placeholder="Semakin besar angka, semakin didahulukan"
                value={ruleForm.prioritas}
                onChange={(e) => setRuleForm({ ...ruleForm, prioritas: parseInt(e.target.value) })}
                min="1"
              />
              <p className="text-xs text-gray-500 mt-1">Aturan dengan prioritas tertinggi dievaluasi pertama</p>
            </div>

            <div className="flex items-center gap-2">
              <input
                type="checkbox"
                id="ruleActive"
                className="w-4 h-4 text-blue-600 focus:ring-blue-500"
                checked={ruleForm.is_active}
                onChange={(e) => setRuleForm({ ...ruleForm, is_active: e.target.checked })}
              />
              <label htmlFor="ruleActive" className="text-sm text-gray-700">
                Aturan aktif (jika tidak aktif, tidak akan dievaluasi)
              </label>
            </div>

            {showJsonEditor && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  JSON Logic Preview
                </label>
                <pre className="text-xs bg-gray-100 p-3 rounded-lg overflow-x-auto">
                  {JSON.stringify(ruleForm.kondisi, null, 2)}
                </pre>
              </div>
            )}

            <div className="flex gap-3 pt-2">
              <button
                onClick={editingRuleId ? handleUpdateRule : handleAddRule}
                disabled={
                  !ruleForm.nama_aturan.trim() || 
                  !ruleForm.rekomendasi.trim() ||
                  (ruleBuilder.type === "simple" && (!ruleBuilder.field || !ruleBuilder.value)) ||
                  (ruleBuilder.type === "complex" && ruleBuilder.conditions.some(c => !c.field || !c.value))
                }
                className="flex-1 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {editingRuleId ? "Update" : "Simpan"}
              </button>
              <button
                onClick={() => setShowRuleModal(false)}
                className="flex-1 bg-gray-200 text-gray-800 px-4 py-2 rounded-lg hover:bg-gray-300 transition"
              >
                Batal
              </button>
            </div>
          </div>
        </Modal>
      )}
    </MainLayout>
  );
}

function Modal({ title, onClose, children }) {
  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4" onClick={onClose}>
      <div className="bg-white rounded-xl max-w-3xl w-full max-h-[90vh] overflow-hidden" onClick={(e) => e.stopPropagation()}>
        <div className="flex justify-between items-center p-4 border-b">
          <h3 className="text-lg font-bold text-gray-900">{title}</h3>
          <button onClick={onClose} className="text-gray-400 hover:text-gray-600 transition">
            <XCircle size={24} />
          </button>
        </div>
        <div className="p-5 overflow-y-auto max-h-[calc(90vh-80px)]">
          {children}
        </div>
      </div>
    </div>
  );
}