import React, { useEffect, useMemo, useRef, useState } from "react";
import { Check, ChevronDown, Search, X } from "lucide-react";

export default function SearchablePendudukSelect({
  label,
  value,
  onChange,
  options,
  loading,
  optionLabel = (item) => item.nama_lengkap || String(item.id),
  placeholder = "Ketik untuk mencari penduduk",
  emptyText = "Tidak ada penduduk yang cocok",
  disabled = false,
}) {
  const wrapperRef = useRef(null);
  const [query, setQuery] = useState("");
  const [open, setOpen] = useState(false);

  const selectedOption = useMemo(
    () => options.find((item) => String(item.id) === String(value)) || null,
    [options, value],
  );

  const getPendudukSearchText = (item) => {
    const labelText = optionLabel(item);
    const nikText = item?.nik || item?.nik_penduduk || item?.no_nik || item?.nik_ktp || "";
    return `${labelText} ${nikText}`.trim();
  };

  useEffect(() => {
    if (open) return;
    setQuery(selectedOption ? optionLabel(selectedOption) : "");
  }, [selectedOption, optionLabel, open]);

  useEffect(() => {
    const handleDocumentClick = (event) => {
      if (wrapperRef.current && !wrapperRef.current.contains(event.target)) {
        setOpen(false);
      }
    };

    document.addEventListener("mousedown", handleDocumentClick);
    return () => document.removeEventListener("mousedown", handleDocumentClick);
  }, []);

  const filteredOptions = useMemo(() => {
    const normalizedQuery = query.trim().toLowerCase();
    if (!normalizedQuery) return options;

    return options.filter((item) => getPendudukSearchText(item).toLowerCase().includes(normalizedQuery));
  }, [options, optionLabel, query]);

  const handleInputChange = (event) => {
    const nextValue = event.target.value;
    setQuery(nextValue);
    onChange("");
    setOpen(true);
  };

  const handleSelect = (item) => {
    onChange(String(item.id));
    setQuery(optionLabel(item));
    setOpen(false);
  };

  const handleClear = () => {
    setQuery("");
    onChange("");
    setOpen(true);
  };

  return (
    <div ref={wrapperRef} className="relative space-y-2">
      <label className="block text-sm font-semibold text-slate-700">{label}</label>
      <div className="relative">
        <Search size={16} className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
        <input
          type="text"
          value={query}
          onChange={handleInputChange}
          onFocus={() => setOpen(true)}
          placeholder={loading ? "Memuat penduduk..." : placeholder}
          disabled={disabled || loading}
          className="w-full rounded-2xl border border-slate-200 bg-white py-3 pl-10 pr-20 text-slate-900 shadow-sm outline-none transition placeholder:text-slate-400 focus:border-slate-900 focus:ring-4 focus:ring-slate-900/10 disabled:cursor-not-allowed disabled:bg-slate-50 disabled:text-slate-400"
        />
        <div className="absolute inset-y-0 right-3 flex items-center gap-1">
          {query ? (
            <button
              type="button"
              onClick={handleClear}
              className="rounded-full p-1 text-slate-400 hover:bg-slate-100 hover:text-slate-600"
              aria-label="Hapus pencarian penduduk"
            >
              <X size={14} />
            </button>
          ) : null}
          <ChevronDown size={16} className={`text-slate-400 transition-transform ${open ? "rotate-180" : ""}`} />
        </div>
      </div>

      {open && !disabled && !loading ? (
        <div className="absolute left-0 right-0 top-full z-30 mt-2 max-h-72 w-full overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-2xl">
          <div className="max-h-72 overflow-auto py-2">
            {filteredOptions.length === 0 ? (
              <div className="px-4 py-3 text-sm text-slate-500">{emptyText}</div>
            ) : (
              filteredOptions.map((item) => {
                const isSelected = String(item.id) === String(value);
                return (
                  <button
                    key={item.id}
                    type="button"
                    onMouseDown={(event) => event.preventDefault()}
                    onClick={() => handleSelect(item)}
                    className={`flex w-full items-start gap-3 px-4 py-3 text-left text-sm transition hover:bg-slate-50 ${isSelected ? "bg-emerald-50/60" : ""}`}
                  >
                    <span className={`mt-0.5 flex h-5 w-5 items-center justify-center rounded-full ${isSelected ? "bg-emerald-600 text-white" : "bg-slate-100 text-slate-400"}`}>
                      <Check size={12} />
                    </span>
                    <span className="min-w-0 flex-1">
                      <span className="block font-medium text-slate-900">{optionLabel(item)}</span>
                      {item.nik ? <span className="block text-xs text-slate-500">NIK: {item.nik}</span> : null}
                    </span>
                  </button>
                );
              })
            )}
          </div>
        </div>
      ) : null}

      <p className="text-xs text-slate-500">Ketik nama atau NIK untuk mencari, lalu pilih penduduk yang sesuai.</p>
    </div>
  );
}