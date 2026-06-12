// src/components/SearchableSelect.jsx
import React, { useState, useRef, useEffect } from "react";
import { ChevronDown, X, Search, Loader2 } from "lucide-react";

/**
 * SearchableSelect
 * Props:
 *  - options: [{ value, label, data? }]
 *  - value: { value, label } | null
 *  - onChange: (option | null) => void
 *  - placeholder: string
 *  - isLoading: bool
 *  - error: string | null
 *  - disabled: bool
 *  - clearable: bool (default true)
 */
export default function SearchableSelect({
  options = [],
  value = null,
  onChange,
  placeholder = "Pilih atau ketik untuk mencari...",
  isLoading = false,
  error = null,
  disabled = false,
  clearable = true,
}) {
  const [isOpen, setIsOpen] = useState(false);
  const [inputValue, setInputValue] = useState("");
  const containerRef = useRef(null);
  const inputRef = useRef(null);

  // Sync input display with selected value
  useEffect(() => {
    if (!isOpen) {
      setInputValue(value ? value.label : "");
    }
  }, [value, isOpen]);

  // Close on outside click
  useEffect(() => {
    const handleClickOutside = (e) => {
      if (containerRef.current && !containerRef.current.contains(e.target)) {
        setIsOpen(false);
        setInputValue(value ? value.label : "");
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, [value]);

  const filteredOptions = options.filter((opt) =>
    opt.label.toLowerCase().includes(inputValue.toLowerCase())
  );

  const handleOpen = () => {
    if (disabled) return;
    setIsOpen(true);
    setInputValue("");
    setTimeout(() => inputRef.current?.focus(), 50);
  };

  const handleSelect = (opt) => {
    onChange(opt);
    setIsOpen(false);
    setInputValue(opt.label);
  };

  const handleClear = (e) => {
    e.stopPropagation();
    onChange(null);
    setInputValue("");
    setIsOpen(false);
  };

  const handleInputChange = (e) => {
    setInputValue(e.target.value);
    if (!isOpen) setIsOpen(true);
  };

  const handleKeyDown = (e) => {
    if (e.key === "Escape") {
      setIsOpen(false);
      setInputValue(value ? value.label : "");
    }
    if (e.key === "Enter" && filteredOptions.length === 1) {
      handleSelect(filteredOptions[0]);
    }
  };

  return (
    <div ref={containerRef} className="relative w-full">
      {/* Input Box */}
      <div
        onClick={handleOpen}
        className={`
          flex items-center w-full border rounded-lg bg-white cursor-text
          transition-all duration-150
          ${isOpen ? "border-blue-500 ring-2 ring-blue-100" : "border-gray-300"}
          ${error ? "border-red-400 ring-2 ring-red-100" : ""}
          ${disabled ? "bg-gray-50 cursor-not-allowed opacity-60" : "hover:border-gray-400"}
        `}
      >
        {/* Search icon */}
        <span className="pl-3 text-slate-400 flex-shrink-0">
          {isLoading ? (
            <Loader2 size={16} className="animate-spin text-blue-500" />
          ) : (
            <Search size={16} />
          )}
        </span>

        <input
          ref={inputRef}
          type="text"
          className="flex-1 px-2 py-2.5 text-sm bg-transparent outline-none text-slate-800 placeholder-slate-400"
          placeholder={isOpen ? "Ketik untuk mencari..." : placeholder}
          value={isOpen ? inputValue : (value ? value.label : "")}
          onChange={handleInputChange}
          onFocus={handleOpen}
          onKeyDown={handleKeyDown}
          disabled={disabled}
          readOnly={!isOpen}
        />

        {/* Clear / Chevron */}
        <span className="pr-2 flex items-center gap-1">
          {clearable && value && !isOpen && (
            <button
              type="button"
              onClick={handleClear}
              className="p-0.5 text-slate-400 hover:text-slate-600 rounded transition"
            >
              <X size={14} />
            </button>
          )}
          <ChevronDown
            size={16}
            className={`text-slate-400 transition-transform duration-200 ${isOpen ? "rotate-180" : ""}`}
          />
        </span>
      </div>

      {/* Dropdown */}
      {isOpen && (
        <div className="absolute z-50 w-full mt-1 bg-white border border-gray-200 rounded-lg shadow-lg max-h-60 overflow-y-auto">
          {isLoading ? (
            <div className="px-4 py-3 text-sm text-slate-500 flex items-center gap-2">
              <Loader2 size={14} className="animate-spin" />
              Memuat data...
            </div>
          ) : filteredOptions.length === 0 ? (
            <div className="px-4 py-3 text-sm text-slate-400 text-center">
              {inputValue ? `Tidak ditemukan "${inputValue}"` : "Tidak ada pilihan"}
            </div>
          ) : (
            filteredOptions.map((opt) => (
              <div
                key={opt.value}
                onMouseDown={(e) => e.preventDefault()}
                onClick={() => handleSelect(opt)}
                className={`
                  px-4 py-2.5 text-sm cursor-pointer transition-colors
                  ${value?.value === opt.value
                    ? "bg-blue-50 text-blue-700 font-medium"
                    : "text-slate-700 hover:bg-slate-50"}
                `}
              >
                {opt.label}
              </div>
            ))
          )}
        </div>
      )}

      {/* Error */}
      {error && (
        <p className="mt-1 text-xs text-red-500">{error}</p>
      )}
    </div>
  );
}