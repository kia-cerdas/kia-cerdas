import React, { useEffect, useMemo, useState } from "react";
import MainLayout from "../../components/Layout/MainLayout";
import {
	getAuditTrailSummary,
	auditTrailErrorMessage,
	listAuditTrails,
} from "../../services/auditTrail";
import {
	AlertTriangle,
	ArrowLeftRight,
	CheckCircle2,
	Clock3,
	Filter,
	History,
	RefreshCcw,
	Search,
	ShieldCheck,
	ShieldAlert,
	UserCog,
} from "lucide-react";

const initialDraft = {
	search: "",
	user: "",
	action: "",
	resource: "",
	role: "",
	method: "",
	success: "",
	from: "",
	to: "",
	limit: 10,
};

const actionOptions = ["", "LOGIN", "LOGIN_FAILED", "LOGOUT", "CREATE", "UPDATE", "DELETE", "READ"];
const methodOptions = ["", "GET", "POST", "PUT", "PATCH", "DELETE"];

const formatDateTime = (value) => {
	if (!value) return "-";
	const date = new Date(value);
	if (Number.isNaN(date.getTime())) return value;
	return new Intl.DateTimeFormat("id-ID", {
		dateStyle: "medium",
		timeStyle: "short",
	}).format(date);
};

const safeDetails = (details) => {
	if (!details) return null;
	try {
		return JSON.parse(details);
	} catch (_error) {
		return { raw: details };
	}
};

export default function AuditTrail() {
	const [draft, setDraft] = useState(initialDraft);
	const [query, setQuery] = useState({ ...initialDraft });
	const [items, setItems] = useState([]);
	const [summary, setSummary] = useState(null);
	const [pagination, setPagination] = useState({ page: 1, limit: 10, total: 0 });
	const [loading, setLoading] = useState(true);
	const [error, setError] = useState("");

	const queryParams = useMemo(() => ({ ...query, page: pagination.page }), [query, pagination.page]);

	useEffect(() => {
		const loadData = async () => {
			try {
				setLoading(true);
				setError("");

				const [listResult, summaryResult] = await Promise.all([
					listAuditTrails(queryParams),
					getAuditTrailSummary(queryParams),
				]);

				setItems(listResult?.items || []);
				setPagination((prev) => ({
					...prev,
					total: listResult?.total || 0,
					limit: listResult?.limit || prev.limit,
					page: listResult?.page || prev.page,
				}));
				setSummary(summaryResult || null);
			} catch (err) {
				setError(auditTrailErrorMessage(err, "Gagal memuat audit trail"));
			} finally {
				setLoading(false);
			}
		};

		loadData();
	}, [queryParams]);

	const totalPages = Math.max(1, Math.ceil((pagination.total || 0) / (pagination.limit || 10)));

	const applyFilters = (event) => {
		event.preventDefault();
		setPagination((prev) => ({ ...prev, page: 1 }));
		setQuery({ ...draft });
	};

	const resetFilters = () => {
		setDraft(initialDraft);
		setPagination({ page: 1, limit: 10, total: 0 });
		setQuery({ ...initialDraft });
	};

	const goToPage = (nextPage) => {
		setPagination((prev) => ({ ...prev, page: Math.min(Math.max(1, nextPage), totalPages) }));
	};

	const summaryCards = [
		{ label: "Total Log", value: summary?.total ?? 0, hint: "Semua aktivitas tercatat", icon: History, tone: "from-slate-900 to-slate-700" },
		{ label: "Berhasil", value: summary?.success ?? 0, hint: "Request sukses", icon: ShieldCheck, tone: "from-emerald-600 to-emerald-500" },
		{ label: "Gagal", value: summary?.failed ?? 0, hint: "Butuh perhatian", icon: ShieldAlert, tone: "from-rose-600 to-rose-500" },
		{ label: "24 Jam", value: summary?.last_24_hours ?? 0, hint: "Aktivitas terbaru", icon: Clock3, tone: "from-cyan-700 to-cyan-500" },
	];

	return (
		<MainLayout>
			<div className="p-8 space-y-8">
				<section className="overflow-hidden rounded-[2rem] border border-slate-200 bg-white shadow-[0_24px_80px_rgba(15,23,42,0.08)]">
					<div className="grid gap-6 bg-gradient-to-br from-slate-950 via-slate-900 to-cyan-950 px-6 py-8 text-white lg:grid-cols-[1.2fr_0.8fr] lg:px-8">
						<div className="space-y-4">
							<div className="inline-flex items-center gap-2 rounded-full border border-white/15 bg-white/8 px-4 py-1.5 text-xs font-semibold uppercase tracking-[0.24em] text-cyan-100">
								<Filter size={14} />
								Monitoring & Audit Trail
							</div>
							<div>
								<h1 className="text-3xl font-black tracking-tight text-white md:text-5xl">Jejak aktivitas superadmin</h1>
								<p className="mt-3 max-w-2xl text-sm leading-6 text-slate-300 md:text-base">
									Pantau CRUD, login/logout, serta aktivitas penting lain dari satu layar. Filter digunakan untuk audit, troubleshooting, dan pelacakan insiden.
								</p>
							</div>
						</div>

						<div className="grid gap-3 rounded-3xl border border-white/10 bg-white/8 p-4 backdrop-blur sm:grid-cols-2 lg:grid-cols-1 xl:grid-cols-2">
							{summaryCards.slice(0, 2).map((card) => {
								const Icon = card.icon;
								return (
									<div key={card.label} className="rounded-2xl border border-white/10 bg-white/8 p-4">
										<div className="flex items-start justify-between gap-3">
											<div>
												<p className="text-xs uppercase tracking-[0.2em] text-slate-300">{card.label}</p>
												<p className="mt-2 text-3xl font-bold text-white">{card.value}</p>
											</div>
											<div className={`flex h-11 w-11 items-center justify-center rounded-2xl bg-gradient-to-br ${card.tone}`}>
												<Icon size={18} />
											</div>
										</div>
										<p className="mt-3 text-sm text-slate-300">{card.hint}</p>
									</div>
								);
							})}
						</div>
					</div>
				</section>

				<section className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
					{summaryCards.map((card) => {
						const Icon = card.icon;
						return (
							<article key={card.label} className="rounded-3xl border border-slate-200 bg-white p-5 shadow-sm">
								<div className="flex items-start justify-between gap-3">
									<div>
										<p className="text-sm font-medium text-slate-500">{card.label}</p>
										<h3 className="mt-2 text-3xl font-black tracking-tight text-slate-900">{card.value}</h3>
									</div>
									<div className={`flex h-12 w-12 items-center justify-center rounded-2xl bg-gradient-to-br ${card.tone} text-white shadow-lg`}>
										<Icon size={20} />
									</div>
								</div>
								<p className="mt-3 text-sm text-slate-500">{card.hint}</p>
							</article>
						);
					})}
				</section>

				<section className="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm">
					<form onSubmit={applyFilters} className="grid gap-4 lg:grid-cols-4">
						<label className="space-y-2 lg:col-span-2">
							<span className="text-sm font-semibold text-slate-700">Cari</span>
							<div className="relative">
								<Search size={18} className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
								<input
									type="text"
									value={draft.search}
									onChange={(event) => setDraft((prev) => ({ ...prev, search: event.target.value }))}
									placeholder="Cari user, aksi, modul, resource, atau path"
									className="w-full rounded-2xl border border-slate-300 bg-slate-50 py-3 pl-10 pr-4 text-sm outline-none transition focus:border-slate-900 focus:bg-white"
								/>
							</div>
						</label>

								<label className="space-y-2">
									<span className="text-sm font-semibold text-slate-700">User</span>
									<input
										type="text"
										value={draft.user}
										onChange={(event) => setDraft((prev) => ({ ...prev, user: event.target.value }))}
										placeholder="email, nomor HP, atau user id"
										className="w-full rounded-2xl border border-slate-300 bg-slate-50 px-4 py-3 text-sm outline-none transition focus:border-slate-900 focus:bg-white"
									/>
								</label>

						<label className="space-y-2">
							<span className="text-sm font-semibold text-slate-700">Aksi</span>
							<select
								value={draft.action}
								onChange={(event) => setDraft((prev) => ({ ...prev, action: event.target.value }))}
								className="w-full rounded-2xl border border-slate-300 bg-slate-50 px-4 py-3 text-sm outline-none transition focus:border-slate-900 focus:bg-white"
							>
								<option value="">Semua aksi</option>
								{actionOptions.filter(Boolean).map((action) => (
									<option key={action} value={action}>{action}</option>
								))}
							</select>
						</label>

						<label className="space-y-2">
							<span className="text-sm font-semibold text-slate-700">Method</span>
							<select
								value={draft.method}
								onChange={(event) => setDraft((prev) => ({ ...prev, method: event.target.value }))}
								className="w-full rounded-2xl border border-slate-300 bg-slate-50 px-4 py-3 text-sm outline-none transition focus:border-slate-900 focus:bg-white"
							>
								<option value="">Semua method</option>
								{methodOptions.filter(Boolean).map((method) => (
									<option key={method} value={method}>{method}</option>
								))}
							</select>
						</label>

						<label className="space-y-2">
							<span className="text-sm font-semibold text-slate-700">Resource</span>
							<input
								type="text"
								value={draft.resource}
								onChange={(event) => setDraft((prev) => ({ ...prev, resource: event.target.value }))}
								placeholder="users, desa, audit-trail"
								className="w-full rounded-2xl border border-slate-300 bg-slate-50 px-4 py-3 text-sm outline-none transition focus:border-slate-900 focus:bg-white"
							/>
						</label>

						<label className="space-y-2">
							<span className="text-sm font-semibold text-slate-700">Role</span>
							<input
								type="text"
								value={draft.role}
								onChange={(event) => setDraft((prev) => ({ ...prev, role: event.target.value }))}
								placeholder="superadmin, admin, bidan"
								className="w-full rounded-2xl border border-slate-300 bg-slate-50 px-4 py-3 text-sm outline-none transition focus:border-slate-900 focus:bg-white"
							/>
						</label>

						<label className="space-y-2">
							<span className="text-sm font-semibold text-slate-700">Status</span>
							<select
								value={draft.success}
								onChange={(event) => setDraft((prev) => ({ ...prev, success: event.target.value }))}
								className="w-full rounded-2xl border border-slate-300 bg-slate-50 px-4 py-3 text-sm outline-none transition focus:border-slate-900 focus:bg-white"
							>
								<option value="">Semua</option>
								<option value="true">Berhasil</option>
								<option value="false">Gagal</option>
							</select>
						</label>

						<label className="space-y-2">
							<span className="text-sm font-semibold text-slate-700">Dari</span>
							<input
								type="date"
								value={draft.from}
								onChange={(event) => setDraft((prev) => ({ ...prev, from: event.target.value }))}
								className="w-full rounded-2xl border border-slate-300 bg-slate-50 px-4 py-3 text-sm outline-none transition focus:border-slate-900 focus:bg-white"
							/>
						</label>

						<label className="space-y-2">
							<span className="text-sm font-semibold text-slate-700">Sampai</span>
							<input
								type="date"
								value={draft.to}
								onChange={(event) => setDraft((prev) => ({ ...prev, to: event.target.value }))}
								className="w-full rounded-2xl border border-slate-300 bg-slate-50 px-4 py-3 text-sm outline-none transition focus:border-slate-900 focus:bg-white"
							/>
						</label>

						<div className="flex items-end gap-3 lg:col-span-4">
							<button type="submit" className="inline-flex items-center gap-2 rounded-2xl bg-slate-950 px-5 py-3 text-sm font-semibold text-white transition hover:bg-slate-800">
								<Filter size={16} />
								Terapkan
							</button>
							<button type="button" onClick={resetFilters} className="inline-flex items-center gap-2 rounded-2xl border border-slate-200 px-5 py-3 text-sm font-semibold text-slate-700 transition hover:border-slate-300 hover:bg-slate-50">
								<RefreshCcw size={16} />
								Reset
							</button>
						</div>
					</form>
				</section>

				{error && (
					<div className="flex gap-3 rounded-2xl border border-rose-200 bg-rose-50 px-4 py-3 text-rose-700">
						<AlertTriangle size={18} className="mt-0.5 shrink-0" />
						<p className="text-sm">{error}</p>
					</div>
				)}

				<section className="rounded-3xl border border-slate-200 bg-white shadow-sm">
					<div className="flex flex-col gap-2 border-b border-slate-200 px-6 py-5 md:flex-row md:items-center md:justify-between">
						<div>
							<h2 className="text-xl font-bold text-slate-900">Log Aktivitas</h2>
							<p className="text-sm text-slate-500">Daftar kejadian terbaru untuk audit, troubleshooting, dan monitoring.</p>
						</div>
						<div className="inline-flex items-center gap-2 rounded-full bg-cyan-50 px-4 py-2 text-sm font-semibold text-cyan-700">
							<UserCog size={16} />
							Superadmin monitoring
						</div>
					</div>

					{loading ? (
						<div className="p-10 text-center text-slate-500">Memuat audit trail...</div>
					) : items.length === 0 ? (
						<div className="p-10 text-center text-slate-500">Tidak ada log yang cocok dengan filter saat ini.</div>
					) : (
						<div className="overflow-x-auto">
							<table className="min-w-[1200px] w-full">
								<thead className="bg-slate-50">
									<tr>
										<th className="px-6 py-3 text-left text-xs font-semibold uppercase tracking-[0.2em] text-slate-500">Waktu</th>
										<th className="px-6 py-3 text-left text-xs font-semibold uppercase tracking-[0.2em] text-slate-500">Actor</th>
										<th className="px-6 py-3 text-left text-xs font-semibold uppercase tracking-[0.2em] text-slate-500">Aksi</th>
										<th className="px-6 py-3 text-left text-xs font-semibold uppercase tracking-[0.2em] text-slate-500">Resource</th>
										<th className="px-6 py-3 text-left text-xs font-semibold uppercase tracking-[0.2em] text-slate-500">Status</th>
										<th className="px-6 py-3 text-left text-xs font-semibold uppercase tracking-[0.2em] text-slate-500">Path</th>
										<th className="px-6 py-3 text-left text-xs font-semibold uppercase tracking-[0.2em] text-slate-500">Detail</th>
									</tr>
								</thead>
								<tbody>
									{items.map((item) => {
										const details = safeDetails(item.details);
										return (
											<tr key={item.id} className="border-t border-slate-100 align-top hover:bg-slate-50/70">
												<td className="px-6 py-4 whitespace-nowrap text-sm text-slate-500">{formatDateTime(item.created_at)}</td>
												<td className="px-6 py-4">
													<div className="space-y-1">
														<p className="text-sm font-semibold text-slate-900">{item.actor_identifier || "anonymous"}</p>
														<p className="text-xs uppercase tracking-[0.2em] text-slate-400">{item.actor_role || "-"}</p>
													</div>
												</td>
												<td className="px-6 py-4">
													<div className="inline-flex items-center gap-2 rounded-full bg-slate-100 px-3 py-1.5 text-xs font-bold uppercase tracking-[0.18em] text-slate-700">
														<ArrowLeftRight size={14} />
														{item.action}
													</div>
												</td>
												<td className="px-6 py-4">
													<div className="space-y-1">
														<p className="text-sm font-semibold text-slate-900">{item.resource || "system"}</p>
														<p className="text-xs text-slate-500">{item.method}</p>
													</div>
												</td>
												<td className="px-6 py-4">
													<span className={`inline-flex items-center gap-2 rounded-full px-3 py-1.5 text-xs font-semibold ${item.success ? "bg-emerald-50 text-emerald-700" : "bg-rose-50 text-rose-700"}`}>
														{item.success ? <CheckCircle2 size={14} /> : <ShieldAlert size={14} />}
														{item.status_code}
													</span>
												</td>
												<td className="px-6 py-4 max-w-[280px]">
													<p className="truncate text-sm text-slate-600" title={item.path}>{item.path}</p>
												</td>
												<td className="px-6 py-4">
													<div className="space-y-2 text-sm text-slate-600">
														<p className="truncate max-w-[320px]">{details?.message || details?.error || "-"}</p>
														{details?.query && <p className="text-xs text-slate-400">Query: {details.query}</p>}
													</div>
												</td>
											</tr>
										);
									})}
								</tbody>
							</table>
						</div>
					)}

					<div className="flex flex-col gap-3 border-t border-slate-200 px-6 py-4 md:flex-row md:items-center md:justify-between">
						<p className="text-sm text-slate-500">
							Menampilkan {items.length} dari {pagination.total} log
						</p>
						<div className="flex items-center gap-2">
							<button
								onClick={() => goToPage(pagination.page - 1)}
								disabled={pagination.page <= 1}
								className="rounded-xl border border-slate-200 px-3 py-2 text-sm font-semibold text-slate-700 disabled:cursor-not-allowed disabled:opacity-50"
							>
								Sebelumnya
							</button>
							<div className="rounded-xl bg-slate-100 px-3 py-2 text-sm font-semibold text-slate-700">
								Halaman {pagination.page} / {totalPages}
							</div>
							<button
								onClick={() => goToPage(pagination.page + 1)}
								disabled={pagination.page >= totalPages}
								className="rounded-xl border border-slate-200 px-3 py-2 text-sm font-semibold text-slate-700 disabled:cursor-not-allowed disabled:opacity-50"
							>
								Berikutnya
							</button>
						</div>
					</div>
				</section>
			</div>
		</MainLayout>
	);
}