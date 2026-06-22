import React from "react";
import { ChevronLeft, ChevronRight } from "lucide-react";

/**
 * Komponen Pagination yang reusable untuk semua halaman SuperAdmin
 * 
 * @param {Object} props
 * @param {number} props.currentPage - Halaman saat ini (1-indexed)
 * @param {number} props.totalPages - Total jumlah halaman
 * @param {number} props.totalItems - Total jumlah item
 * @param {number} props.itemsPerPage - Jumlah item per halaman
 * @param {Function} props.onPageChange - Callback saat halaman berubah
 * @param {boolean} props.loading - Status loading
 */
export default function Pagination({
  currentPage = 1,
  totalPages = 1,
  totalItems = 0,
  itemsPerPage = 10,
  onPageChange,
  loading = false,
}) {
  const startItem = totalItems === 0 ? 0 : (currentPage - 1) * itemsPerPage + 1;
  const endItem = Math.min(currentPage * itemsPerPage, totalItems);

  const handlePrevious = () => {
    if (currentPage > 1 && !loading) {
      onPageChange(currentPage - 1);
    }
  };

  const handleNext = () => {
    if (currentPage < totalPages && !loading) {
      onPageChange(currentPage + 1);
    }
  };

  const handlePageClick = (page) => {
    if (page !== currentPage && !loading) {
      onPageChange(page);
    }
  };

  // Generate page numbers to display
  const getPageNumbers = () => {
    const pages = [];
    const maxVisible = 5;

    if (totalPages <= maxVisible) {
      // Show all pages if total is small
      for (let i = 1; i <= totalPages; i++) {
        pages.push(i);
      }
    } else {
      // Always show first page
      pages.push(1);

      let startPage = Math.max(2, currentPage - 1);
      let endPage = Math.min(totalPages - 1, currentPage + 1);

      // Adjust if we're near the start
      if (currentPage <= 3) {
        endPage = 4;
      }

      // Adjust if we're near the end
      if (currentPage >= totalPages - 2) {
        startPage = totalPages - 3;
      }

      // Add ellipsis after first page if needed
      if (startPage > 2) {
        pages.push("...");
      }

      // Add middle pages
      for (let i = startPage; i <= endPage; i++) {
        pages.push(i);
      }

      // Add ellipsis before last page if needed
      if (endPage < totalPages - 1) {
        pages.push("...");
      }

      // Always show last page
      if (totalPages > 1) {
        pages.push(totalPages);
      }
    }

    return pages;
  };

  if (totalPages <= 1) {
    return (
      <div className="flex items-center justify-between px-6 py-4 border-t border-slate-200">
        <p className="text-sm text-slate-500">
          Menampilkan {totalItems} data
        </p>
      </div>
    );
  }

  return (
    <div className="flex flex-col sm:flex-row items-center justify-between gap-4 px-6 py-4 border-t border-slate-200">
      {/* Info text */}
      <p className="text-sm text-slate-500">
        Menampilkan <span className="font-semibold text-slate-700">{startItem}</span> - <span className="font-semibold text-slate-700">{endItem}</span> dari <span className="font-semibold text-slate-700">{totalItems}</span> data
      </p>

      {/* Pagination controls */}
      <div className="flex items-center gap-2">
        {/* Previous button */}
        <button
          onClick={handlePrevious}
          disabled={currentPage <= 1 || loading}
          className="inline-flex items-center gap-2 rounded-xl border border-slate-200 px-4 py-2 text-sm font-semibold text-slate-700 hover:bg-slate-50 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
          title="Halaman sebelumnya"
        >
          <ChevronLeft size={16} />
          <span className="hidden sm:inline">Sebelumnya</span>
        </button>

        {/* Page numbers */}
        <div className="flex items-center gap-1">
          {getPageNumbers().map((page, index) => {
            if (page === "...") {
              return (
                <span key={`ellipsis-${index}`} className="px-3 py-2 text-sm text-slate-400">
                  ...
                </span>
              );
            }

            const isActive = page === currentPage;
            return (
              <button
                key={page}
                onClick={() => handlePageClick(page)}
                disabled={loading}
                className={`min-w-[40px] rounded-xl px-3 py-2 text-sm font-semibold transition-colors ${
                  isActive
                    ? "bg-indigo-600 text-white"
                    : "text-slate-700 hover:bg-slate-100 disabled:opacity-50"
                }`}
              >
                {page}
              </button>
            );
          })}
        </div>

        {/* Next button */}
        <button
          onClick={handleNext}
          disabled={currentPage >= totalPages || loading}
          className="inline-flex items-center gap-2 rounded-xl border border-slate-200 px-4 py-2 text-sm font-semibold text-slate-700 hover:bg-slate-50 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
          title="Halaman berikutnya"
        >
          <span className="hidden sm:inline">Berikutnya</span>
          <ChevronRight size={16} />
        </button>
      </div>
    </div>
  );
}
