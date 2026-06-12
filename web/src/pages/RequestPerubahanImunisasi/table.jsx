import {
    CheckCircle,
    XCircle
} from "lucide-react";

export default function RequestPerubahanImunisasiTable({
    data,
    showAction = false,
    onApprove,
    onReject,
    formatDate,
}) {
    if (data.length === 0) {
        return (
            <tr>
                <td colSpan="7" className="text-center py-10 text-gray-500">
                    Tidak ada data
                </td>
            </tr>
        );
    }

    return data.map((item) => (
        <tr
            key={item.request_id}
            className="hover:bg-indigo-50 transition-colors"
        >
            <td className="px-6 py-4 font-semibold">
                {item.nama_lengkap}
            </td>

            <td className="px-6 py-4">
                {item.nama_dosis}
            </td>

            <td className="px-6 py-4">
                {formatDate(item.tanggal_sebelum)}
            </td>

            <td className="px-6 py-4">
                {formatDate(item.tanggal_baru)}
            </td>

            <td className="px-6 py-4">
                {item.alasan}
            </td>

            <td className="px-6 py-4">
                {item.status_request}
            </td>

            <td className="px-6 py-4">
                {showAction ? (
                    <div className="flex justify-center gap-2">
                        <button
                            onClick={() => onApprove(item.request_id)}
                            className="px-3 py-2 bg-green-600 text-white rounded-lg"
                        >
                            <CheckCircle size={14} />
                        </button>

                        <button
                            onClick={() => onReject(item.request_id)}
                            className="px-3 py-2 bg-red-600 text-white rounded-lg"
                        >
                            <XCircle size={14} />
                        </button>
                    </div>
                ) : (
                    <div className="text-center text-xs text-gray-400">
                        Selesai
                    </div>
                )}
            </td>
        </tr>
    ));
}