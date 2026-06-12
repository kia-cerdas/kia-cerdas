import React, { useEffect, useMemo, useState } from "react";
import { Plus, Save, MessageSquare, RefreshCw, Pencil, Trash2, X, Send, Search, ChevronLeft, ChevronRight } from "lucide-react";
import { getIbuList } from "../../services/ibu";
import {
  createCatatanKader,
  createKesehatanLingkungan,
  deleteCatatanKader,
  getCatatanKaderByKesehatanId,
  getKesehatanLingkunganList,
  kirimCatatanKeMobile,
  updateCatatanKader,
} from "../../services/kesehatanLingkunganCatatan";

const KESEHATAN_LINGKUNGAN_TEMPLATE = [
  {
    key: "sanitasi",
    title: "Sarana Sanitasi",
    questions: [
      {
        label: "1. Di mana ibu dan keluarga buang air besar?",
        options: [
          "Sembarangan (di kebun, sungai dll)",
          "Jamban milik sendiri",
        ],
      },
      {
        label: "2. Bila jamban milik sendiri, bagian bawah/bak penampung tinja berupa apa?",
        options: [
          "Tangki septik disedot setiap 3-5 tahun terakhir atau disalurkan ke sistem pengolahan",
          "Cubluk/lubang tanah",
          "Dibuang langsung ke drainase/kolam/sawah/sungai/danau/laut dan pantai/tanah lapang/kebun",
        ],
      },
      {
        label: "3. Bagaimana bentuk kloset jambannya?",
        options: ["Kloset leher angsa/lainnya yang mencegah binatang pembawa penyakit masuk"],
      },
    ],
  },
  {
    key: "cuci_tangan",
    title: "Cuci Tangan Pakai Sabun",
    questions: [
      {
        label: "1. Seperti apa jenis sarana cuci tangan di rumah ibu?",
        options: ["Memiliki sarana/tempat", "Memiliki air mengalir", "Memiliki sabun"],
      },
      {
        label: "2-3. Waktu kritis cuci tangan pakai sabun yang diketahui ibu",
        options: [
          "Sebelum makan",
          "Sebelum mengolah dan menghidangkan makanan",
          "Sebelum menyusui anak, sebelum memberi makan bayi/balita",
          "Setelah buang air besar/kecil",
        ],
      },
    ],
  },
  {
    key: "air_makanan",
    title: "Pengelolaan Makanan dan Air Minum",
    questions: [
      {
        label: "1. Apa sumber air minum di rumah ibu?",
        options: [
          "Pipa",
          "Kran umum",
          "Sumur bor/pompa/sumur gali yang terlindungi",
          "Mata air terlindungi",
          "Sungai/mata air tidak terlindungi",
          "Danau/kolam/sumur gali tidak terlindungi",
          "Kolam",
          "Irigasi",
          "Air hujan",
          "Waduk",
        ],
      },
      {
        label: "2. Bagaimana ibu mengelola air minum di rumah tangga?",
        options: [
          "Melalui proses pengolahan (misal: merebus)",
          "Jika air keruh dilakukan pengolahan, seperti: pengendapan atau penyaringan",
          "Menyimpan air minum di dalam wadah tertutup rapat, kuat dan diambil dengan cara aman",
        ],
      },
      {
        label: "3. Bagaimana ibu mengelola makanan di dalam keluarga?",
        options: [
          "Makanan tertutup baik dengan penutup yang bersih",
          "Makanan tidak berdekatan dengan bahan berbahaya dan beracun",
          "Mengelola makanan dengan baik dan benar",
        ],
      },
    ],
  },
  {
    key: "sampah",
    title: "Pengelolaan Sampah",
    questions: [
      {
        label: "Bagaimana ibu mengelola sampah?",
        options: [
          "Tidak ada sampah berserakan di lingkungan sekitar rumah",
          "Ada tempat sampah yang tertutup, kuat dan mudah dibersihkan",
          "Telah melakukan pemilahan sampah",
          "Tidak dibakar",
          "Tidak dibuang ke sungai/kebun/saluran drainase/tempat terbuka",
        ],
      },
    ],
  },
  {
    key: "limbah",
    title: "Pengelolaan Limbah Cair",
    questions: [
      {
        label: "Bagaimana ibu mengelola limbah cair di rumah?",
        options: [
          "Tidak terlihat genangan air di sekitar rumah",
          "Ada saluran pembuangan limbah cair rumah tangga (non kakus) yang kedap dan tertutup",
          "Terhubung dengan sumur resapan dan atau sistem pengolahan limbah",
        ],
      },
    ],
  },
];

const KESELAMATAN_LINGKUNGAN_TEMPLATE = [
  {
    title: "Hindarkan Anak dari Risiko Jatuh",
    options: [
      "Televisi, meja, lemari, dan rak yang tidak cukup kuat dipanjat oleh bayi harus diikat atau menempel di dinding.",
      "Baby walker tidak disarankan karena menghambat anak melakukan langkah dan dapat menyebabkan bayi terjatuh.",
      "Jendela paling sedikit 1 meter dari lantai untuk mencegah bayi memanjat.",
      "Sering memeriksa gerbang pagar rumah untuk mencegah bayi memanjat.",
      "Jangan tinggalkan bayi sendirian di tempat tinggi.",
      "Tangga dan balkon dipasang pagar dan jarak antar pagar tidak lebih dari 9 cm.",
      "Memasang pengaman di sekitar tempat tidur anak.",
    ],
  },
  {
    title: "Hindarkan Anak dari Luka Bakar dan Bahaya Listrik",
    options: [
      "Jauhkan anak dari kabel listrik dan api panas.",
      "Soket listrik dipasang jauh dari jangkauan anak.",
      "Jangan memegang barang panas ketika menggendong/memangku bayi.",
    ],
  },
  {
    title: "Mencegah Bayi Kekurangan Napas",
    options: [
      "Jangan memberikan makanan anak yang keras dan sulit dikunyah.",
      "Jangan biarkan anak bermain dengan benda kecil berisiko tertelan/terceik.",
      "Hindari menidurkan bayi dalam posisi telungkup tanpa pengawasan.",
    ],
  },
  {
    title: "Hindarkan Anak dari Bahaya Tenggelam",
    options: [
      "Jangan biarkan anak sendiri di bak mandi atau ember.",
      "Beri pembatas aman agar anak tidak leluasa menjangkau sumber air.",
      "Anak usia 1 tahun 6 bulan diajari tentang bahaya air.",
      "Anak usia 2 tahun dijaga cara melayang ketika jatuh di air.",
      "Anak usia 6 tahun harus bisa berenang dengan keterampilan bertahan di air.",
    ],
  },
];

const emptyPayload = {
  ibu_id: "",
  sanitasi: [],
  cuci_tangan: [],
  air_makanan: [],
  sampah: [],
  limbah: [],
};

const FORM_CHOICES = [
  { key: "kesehatan_lingkungan", label: "Form Pencatatan Kesehatan Lingkungan" },
  { key: "keselamatan_lingkungan", label: "Form Pencatatan Keselamatan Lingkungan" },
];

export default function KesehatanLingkunganCatatan() {
  const [form, setForm] = useState(emptyPayload);
  const [selectedFormChoices, setSelectedFormChoices] = useState({
    kesehatan_lingkungan: true,
    keselamatan_lingkungan: true,
  });
  const [ibuList, setIbuList] = useState([]);
  const [records, setRecords] = useState([]);
  const [searchIbu, setSearchIbu] = useState("");
  const [currentPage, setCurrentPage] = useState(1);
  const [selectedId, setSelectedId] = useState("");
  const [catatanList, setCatatanList] = useState([]);
  const [catatan, setCatatan] = useState("");
  const [editingCatatanId, setEditingCatatanId] = useState(null);
  const [editingCatatanText, setEditingCatatanText] = useState("");
  const [savingForm, setSavingForm] = useState(false);
  const [savingCatatan, setSavingCatatan] = useState(false);
  const [loadingList, setLoadingList] = useState(true);
  const recordsPerPage = 5;

  const ibuNameById = useMemo(() => {
    const map = new Map();
    ibuList.forEach((item) => {
      map.set(String(item.id_ibu), item.kependudukan?.nama_lengkap || `Ibu ${item.id_ibu}`);
    });
    return map;
  }, [ibuList]);

  const filteredRecords = useMemo(() => {
    const keyword = searchIbu.trim().toLowerCase();
    if (!keyword) return records;

    return records.filter((item) => {
      const ibuName = (ibuNameById.get(String(item.ibu_id)) || "").toLowerCase();
      return ibuName.includes(keyword);
    });
  }, [records, ibuNameById, searchIbu]);

  const isChecklistFilled = (record) =>
    (record?.sanitasi || []).length > 0 ||
    (record?.cuci_tangan || []).length > 0 ||
    (record?.air_makanan || []).length > 0 ||
    (record?.sampah || []).length > 0 ||
    (record?.limbah || []).length > 0;

  const checklistRecords = useMemo(
    () => filteredRecords.filter((record) => isChecklistFilled(record)),
    [filteredRecords]
  );

  const totalPages = Math.max(1, Math.ceil(checklistRecords.length / recordsPerPage));
  const paginatedRecords = useMemo(() => {
    const start = (currentPage - 1) * recordsPerPage;
    return checklistRecords.slice(start, start + recordsPerPage);
  }, [checklistRecords, currentPage]);

  const selectedRecord = useMemo(
    () => records.find((item) => String(item.id) === String(selectedId)) || null,
    [records, selectedId]
  );

  const loadData = async () => {
    setLoadingList(true);
    try {
      const [listIbu, listRecord] = await Promise.all([
        getIbuList(),
        getKesehatanLingkunganList(),
      ]);
      setIbuList(listIbu || []);
      setRecords(listRecord || []);
      if (listRecord?.length) {
        const hasSelected = listRecord.some((item) => String(item.id) === String(selectedId));
        if (!hasSelected) {
          setSelectedId(String(listRecord[0].id));
        }
      } else {
        setSelectedId("");
      }
    } catch (error) {
      alert(error?.response?.data?.message || "Gagal memuat data");
    } finally {
      setLoadingList(false);
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  useEffect(() => {
    setCurrentPage(1);
  }, [searchIbu]);

  useEffect(() => {
    if (currentPage > totalPages) {
      setCurrentPage(totalPages);
    }
  }, [currentPage, totalPages]);

  useEffect(() => {
    if (!checklistRecords.length) {
      return;
    }
    const selectedStillExists = checklistRecords.some((item) => String(item.id) === String(selectedId));
    if (!selectedStillExists) {
      setSelectedId(String(checklistRecords[0].id));
    }
  }, [checklistRecords, selectedId]);

  useEffect(() => {
    if (!selectedId) {
      setCatatanList([]);
      return;
    }

    const loadCatatan = async () => {
      try {
        const data = await getCatatanKaderByKesehatanId(selectedId);
        setCatatanList(data || []);
      } catch (error) {
        setCatatanList([]);
      }
    };

    loadCatatan();
  }, [selectedId]);

  const toggleChecklist = (key, value) => {
    setForm((prev) => {
      const exists = prev[key].includes(value);
      return {
        ...prev,
        [key]: exists ? prev[key].filter((item) => item !== value) : [...prev[key], value],
      };
    });
  };

  const handleSubmitForm = async (event) => {
    event.preventDefault();
    const ibuIdToUse = form.ibu_id || (ibuList[0]?.id_ibu ? String(ibuList[0].id_ibu) : "");
    if (!ibuIdToUse) {
      alert("Data ibu belum tersedia");
      return;
    }
    const activeChoices = Object.values(selectedFormChoices).filter(Boolean).length;
    if (activeChoices === 0) {
      alert("Pilih minimal satu form yang akan dikirim ke mobile");
      return;
    }

    setSavingForm(true);
    try {
      await createKesehatanLingkungan({
        ...form,
        ibu_id: Number(ibuIdToUse),
        selected_forms: Object.entries(selectedFormChoices)
          .filter(([, active]) => active)
          .map(([key]) => key),
      });
      setForm(emptyPayload);
      await loadData();
      alert("Form berhasil dibuat dan siap dikirim ke mobile untuk diisi ibu");
    } catch (error) {
      alert(error?.response?.data?.message || "Gagal menyimpan form");
    } finally {
      setSavingForm(false);
    }
  };

  const handleSubmitCatatan = async (event) => {
    event.preventDefault();
    if (!selectedId) {
      alert("Pilih data hasil pengisian terlebih dahulu");
      return;
    }
    if (!catatan.trim()) {
      alert("Catatan kader wajib diisi");
      return;
    }

    setSavingCatatan(true);
    try {
      await createCatatanKader(selectedId, { catatan: catatan.trim() });
      setCatatan("");
      const data = await getCatatanKaderByKesehatanId(selectedId);
      setCatatanList(data || []);
      alert("Catatan kader berhasil dikirim");
    } catch (error) {
      alert(error?.response?.data?.message || "Gagal menyimpan catatan");
    } finally {
      setSavingCatatan(false);
    }
  };

  const startEditCatatan = (item) => {
    setEditingCatatanId(item.id);
    setEditingCatatanText(item.catatan || "");
  };

  const cancelEditCatatan = () => {
    setEditingCatatanId(null);
    setEditingCatatanText("");
  };

  const saveEditCatatan = async (catatanId) => {
    if (!selectedId) return;
    if (!editingCatatanText.trim()) {
      alert("Isi catatan tidak boleh kosong");
      return;
    }

    try {
      await updateCatatanKader(selectedId, catatanId, { catatan: editingCatatanText.trim() });
      const data = await getCatatanKaderByKesehatanId(selectedId);
      setCatatanList(data || []);
      cancelEditCatatan();
    } catch (error) {
      alert(error?.response?.data?.message || "Gagal memperbarui catatan");
    }
  };

  const handleDeleteCatatan = async (catatanId) => {
    if (!selectedId) return;
    if (!window.confirm("Hapus catatan ini?")) return;

    try {
      await deleteCatatanKader(selectedId, catatanId);
      const data = await getCatatanKaderByKesehatanId(selectedId);
      setCatatanList(data || []);
    } catch (error) {
      alert(error?.response?.data?.message || "Gagal menghapus catatan");
    }
  };

  const handleKirimKeMobile = async (catatanId) => {
    if (!selectedId) return;
    try {
      await kirimCatatanKeMobile(selectedId, catatanId);
      const data = await getCatatanKaderByKesehatanId(selectedId);
      setCatatanList(data || []);
      alert("Catatan berhasil dikirim ke mobile");
    } catch (error) {
      alert(error?.response?.data?.message || "Gagal kirim catatan ke mobile");
    }
  };

  const toggleFormChoice = (key) => {
    setSelectedFormChoices((prev) => ({
      ...prev,
      [key]: !prev[key],
    }));
  };

  const formatDateTime = (value) => {
    if (!value) return "-";
    const date = new Date(value);
    if (Number.isNaN(date.getTime())) return "-";
    return date.toLocaleString("id-ID");
  };

  const renderTemplateGroup = (title, items, options = {}) => (
    <div className="rounded-lg border border-amber-300 bg-amber-50/40 p-4">
      <h3 className="mb-2 text-sm font-semibold text-slate-900">{title}</h3>
      <p className="mb-3 text-xs text-slate-600">
        Ini adalah template yang akan tampil di mobile dan diisi oleh ibu. Admin tidak mengisi checklist ini.
      </p>
      <div className={options.twoColumns ? "grid grid-cols-1 gap-4 md:grid-cols-2" : "space-y-3"}>
        {items.map((item) => (
          <div key={item.title || item.key}>
            <p className="mb-2 text-xs font-semibold text-slate-800">{item.title}</p>
            <div className="space-y-1.5">
              {(item.questions ? item.questions.flatMap((q) => q.options) : item.options).map((option) => (
                <label key={`${item.title}-${option}`} className="flex items-start gap-2 text-xs text-slate-700">
                  <input type="checkbox" className="mt-0.5" disabled />
                  <span>{option}</span>
                </label>
              ))}
            </div>
          </div>
        ))}
      </div>
    </div>
  );

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Form Pencatatan Kesehatan Lingkungan dan Keselamatan Lingkungan</h1>
          <p className="text-sm text-slate-500">Form checklist untuk ibu dan catatan untuk kader.</p>
        </div>
        <button
          type="button"
          onClick={loadData}
          className="inline-flex items-center gap-2 rounded-lg border border-slate-200 bg-white px-4 py-2 text-sm font-medium text-slate-700 hover:bg-slate-50"
        >
          <RefreshCw size={16} /> Muat Ulang
        </button>
      </div>

      <div className="grid grid-cols-1 gap-6 xl:grid-cols-2">
        <form onSubmit={handleSubmitForm} className="rounded-xl bg-white p-6 shadow-sm">
          <div className="mb-4 flex items-center gap-2">
            <Plus size={18} className="text-indigo-600" />
            <h2 className="text-lg font-semibold text-slate-900">CREATE FORM</h2>
          </div>

          <div className="mb-5 rounded-lg border border-slate-200 p-4">
            <h3 className="mb-2 text-sm font-semibold text-slate-900">Pilih Form yang Dikirim ke Mobile</h3>
            <div className="space-y-2">
              {FORM_CHOICES.map((choice) => (
                <label key={choice.key} className="flex items-center gap-2 text-sm text-slate-700">
                  <input
                    type="checkbox"
                    checked={selectedFormChoices[choice.key]}
                    onChange={() => toggleFormChoice(choice.key)}
                  />
                  <span>{choice.label}</span>
                </label>
              ))}
            </div>
          </div>

          <div className="space-y-4">
            {selectedFormChoices.kesehatan_lingkungan &&
              renderTemplateGroup("Template 1: Form Pencatatan Kesehatan Lingkungan", KESEHATAN_LINGKUNGAN_TEMPLATE)}
            {selectedFormChoices.keselamatan_lingkungan &&
              renderTemplateGroup(
                "Template 2: Form Pencatatan Keselamatan Lingkungan (Diisi oleh Keluarga)",
                KESELAMATAN_LINGKUNGAN_TEMPLATE,
                { twoColumns: true }
              )}
          </div>

          <button
            type="submit"
            disabled={savingForm}
            className="mt-5 inline-flex w-full items-center justify-center gap-2 rounded-lg bg-indigo-600 px-4 py-2 text-sm font-semibold text-white hover:bg-indigo-700 disabled:opacity-60"
          >
            <Save size={16} /> {savingForm ? "Membuat Form..." : "Create Form & Kirim ke Mobile"}
          </button>
        </form>

        <div className="space-y-6">
          <div className="rounded-xl bg-white p-6 shadow-sm">
            <h2 className="mb-4 text-lg font-semibold text-slate-900">Checklist Ibu</h2>
            <div className="mb-4">
              <label className="mb-1 block text-sm font-medium text-slate-700">Cari Nama Ibu</label>
              <div className="relative">
                <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
                <input
                  type="text"
                  className="w-full rounded-lg border border-slate-300 py-2 pl-9 pr-3 text-sm"
                  placeholder="Contoh: Siti"
                  value={searchIbu}
                  onChange={(event) => setSearchIbu(event.target.value)}
                />
              </div>
            </div>
            {loadingList ? (
              <p className="text-sm text-slate-500">Memuat data...</p>
            ) : (
              <>
                <div className="mb-4 overflow-x-auto rounded-lg border border-slate-200">
                  <table className="min-w-full text-sm">
                    <thead className="bg-slate-50">
                      <tr>
                        <th className="px-3 py-2 text-left font-semibold text-slate-700">No</th>
                        <th className="px-3 py-2 text-left font-semibold text-slate-700">Nama Orang Tua</th>
                        <th className="px-3 py-2 text-left font-semibold text-slate-700">Tanggal Pengiriman</th>
                      </tr>
                    </thead>
                    <tbody>
                      {paginatedRecords.length === 0 ? (
                        <tr className="border-t bg-white">
                          <td colSpan={3} className="px-3 py-6 text-center text-slate-500">
                            Belum ada data checklist ibu.
                          </td>
                        </tr>
                      ) : (
                        paginatedRecords.map((item, index) => {
                          const isSelected = String(item.id) === String(selectedId);
                          return (
                            <tr
                              key={item.id}
                              className={`border-t ${isSelected ? "bg-indigo-50" : "bg-white"}`}
                            >
                              <td className="px-3 py-2 text-slate-700">{(currentPage - 1) * recordsPerPage + index + 1}</td>
                              <td className="px-3 py-2 text-slate-700">{ibuNameById.get(String(item.ibu_id)) || `Ibu ${item.ibu_id}`}</td>
                              <td className="px-3 py-2 text-slate-700">{formatDateTime(item.updated_at || item.created_at)}</td>
                            </tr>
                          );
                        })
                      )}
                    </tbody>
                  </table>
                </div>

                <div className="mb-4 flex items-center justify-between">
                  <p className="text-xs text-slate-500">
                    Menampilkan {paginatedRecords.length} dari {checklistRecords.length} data terisi
                  </p>
                  <div className="flex items-center gap-2">
                    <button
                      type="button"
                      onClick={() => setCurrentPage((prev) => Math.max(1, prev - 1))}
                      disabled={currentPage === 1}
                      className="rounded border border-slate-300 p-1 text-slate-600 disabled:opacity-50"
                    >
                      <ChevronLeft size={14} />
                    </button>
                    <span className="text-xs text-slate-500">{currentPage}/{totalPages}</span>
                    <button
                      type="button"
                      onClick={() => setCurrentPage((prev) => Math.min(totalPages, prev + 1))}
                      disabled={currentPage === totalPages}
                      className="rounded border border-slate-300 p-1 text-slate-600 disabled:opacity-50"
                    >
                      <ChevronRight size={14} />
                    </button>
                  </div>
                </div>

                {selectedRecord && (
                  <div className="space-y-3 rounded-lg border border-slate-200 p-4 text-sm">
                    <p><span className="font-semibold">Nama Ibu:</span> {ibuNameById.get(String(selectedRecord.ibu_id)) || "-"}</p>
                    <p><span className="font-semibold">Ibu ID:</span> {selectedRecord.ibu_id}</p>
                    <p>
                      <span className="font-semibold">Status Pengisian:</span>{" "}
                      {(selectedRecord.sanitasi || []).length > 0 || (selectedRecord.cuci_tangan || []).length > 0 || (selectedRecord.air_makanan || []).length > 0 || (selectedRecord.sampah || []).length > 0 || (selectedRecord.limbah || []).length > 0
                        ? "Sudah diisi oleh ibu"
                        : "Menunggu diisi oleh ibu (mobile)"}
                    </p>
                    <p><span className="font-semibold">Sanitasi:</span> {(selectedRecord.sanitasi || []).join(", ") || "-"}</p>
                    <p><span className="font-semibold">Cuci Tangan:</span> {(selectedRecord.cuci_tangan || []).join(", ") || "-"}</p>
                    <p><span className="font-semibold">Air & Makanan:</span> {(selectedRecord.air_makanan || []).join(", ") || "-"}</p>
                    <p><span className="font-semibold">Sampah:</span> {(selectedRecord.sampah || []).join(", ") || "-"}</p>
                    <p><span className="font-semibold">Limbah:</span> {(selectedRecord.limbah || []).join(", ") || "-"}</p>
                  </div>
                )}
              </>
            )}
          </div>

          <div className="rounded-xl bg-white p-6 shadow-sm">
            <div className="mb-4 flex items-center gap-2">
              <MessageSquare size={18} className="text-indigo-600" />
              <h2 className="text-lg font-semibold text-slate-900">Catatan Kader</h2>
            </div>

            <form onSubmit={handleSubmitCatatan} className="mb-4 space-y-3">
              <textarea
                rows={4}
                className="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm"
                placeholder="Tulis catatan untuk ditampilkan di aplikasi mobile ibu..."
                value={catatan}
                onChange={(event) => setCatatan(event.target.value)}
              />
              <button
                type="submit"
                disabled={savingCatatan || !selectedId}
                className="inline-flex items-center gap-2 rounded-lg bg-indigo-600 px-4 py-2 text-sm font-semibold text-white hover:bg-indigo-700 disabled:opacity-60"
              >
                <Save size={16} /> {savingCatatan ? "Mengirim..." : "Kirim Catatan"}
              </button>
            </form>

            <div className="space-y-3">
              {catatanList.length === 0 ? (
                <p className="text-sm text-slate-500">Belum ada catatan kader.</p>
              ) : (
                catatanList.map((item) => (
                  <div key={item.id} className="rounded-lg border border-slate-200 p-3 text-sm">
                    {editingCatatanId === item.id ? (
                      <div className="space-y-2">
                        <textarea
                          rows={3}
                          className="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm"
                          value={editingCatatanText}
                          onChange={(event) => setEditingCatatanText(event.target.value)}
                        />
                        <div className="flex items-center gap-2">
                          <button
                            type="button"
                            onClick={() => saveEditCatatan(item.id)}
                            className="inline-flex items-center gap-1 rounded-md bg-indigo-600 px-3 py-1.5 text-xs font-semibold text-white"
                          >
                            <Save size={14} /> Simpan
                          </button>
                          <button
                            type="button"
                            onClick={cancelEditCatatan}
                            className="inline-flex items-center gap-1 rounded-md border border-slate-300 px-3 py-1.5 text-xs font-semibold text-slate-700"
                          >
                            <X size={14} /> Batal
                          </button>
                        </div>
                      </div>
                    ) : (
                      <>
                        <p className="text-slate-700">{item.catatan}</p>
                        <div>
                          <span className={`inline-flex rounded-full px-2 py-1 text-[11px] font-semibold ${item.is_sent_to_mobile ? "bg-emerald-100 text-emerald-700" : "bg-amber-100 text-amber-700"}`}>
                            {item.is_sent_to_mobile ? "Terkirim ke mobile" : "Belum terkirim"}
                          </span>
                        </div>
                        <div className="mt-2 flex items-center gap-2">
                          <button
                            type="button"
                            onClick={() => startEditCatatan(item)}
                            className="inline-flex items-center gap-1 rounded-md border border-slate-300 px-2 py-1 text-xs font-medium text-slate-700"
                          >
                            <Pencil size={12} /> Edit
                          </button>
                          <button
                            type="button"
                            onClick={() => handleDeleteCatatan(item.id)}
                            className="inline-flex items-center gap-1 rounded-md border border-rose-300 px-2 py-1 text-xs font-medium text-rose-700"
                          >
                            <Trash2 size={12} /> Hapus
                          </button>
                          {!item.is_sent_to_mobile && (
                            <button
                              type="button"
                              onClick={() => handleKirimKeMobile(item.id)}
                              className="inline-flex items-center gap-1 rounded-md border border-emerald-300 px-2 py-1 text-xs font-medium text-emerald-700"
                            >
                              <Send size={12} /> Kirim ke Mobile
                            </button>
                          )}
                        </div>
                      </>
                    )}
                    <p className="mt-1 text-xs text-slate-400">
                      {new Date(item.created_at).toLocaleString("id-ID")}
                    </p>
                    {item.sent_to_mobile_at && (
                      <p className="text-xs text-emerald-600">
                        Dikirim: {new Date(item.sent_to_mobile_at).toLocaleString("id-ID")}
                      </p>
                    )}
                  </div>
                ))
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
