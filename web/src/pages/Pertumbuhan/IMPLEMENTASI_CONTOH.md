/**
 * CONTOH IMPLEMENTASI LENGKAP - REACT
 * File: PA3/web/react-kia/src/pages/Pertumbuhan/IMPLEMENTASI_CONTOH.md
 * 
 * Panduan step-by-step cara menggunakan komponen-komponen baru
 */

# Implementasi Tampilan Pertumbuhan - React Web

## Quick Start

### 1. Import Komponen Baru

Di file `PA3/web/react-kia/src/pages/Pertumbuhan/index.jsx`, tambahkan imports:

```jsx
import { GrowthStatusCard, GrowthSummary } from "./components/GrowthStatusCard";
import { GrowthChart } from "./components/GrowthChart";
```

### 2. Struktur State

State yang sudah ada di component sudah cukup:

```jsx
const [activeChart, setActiveChart] = useState("bb");
const [riwayat, setRiwayat] = useState([]);
const [anak, setAnak] = useState(null);
```

### 3. Konfigurasi Chart

```jsx
const chartConfig = {
  bb:   { label: "Berat Badan (kg)", color: "#6366f1", unit: "kg" },
  tb:   { label: "Tinggi Badan (cm)", color: "#8b5cf6", unit: "cm" },
  lila: { label: "LILA (cm)", color: "#f59e0b", unit: "cm" },
  lk:   { label: "Lingkar Kepala (cm)", color: "#10b981", unit: "cm" },
};
```

### 4. Prepare Chart Data

```jsx
const chartData = [...riwayat].reverse().map((r) => ({
  bulan: `${r.usia_ukur_bulan}bln`,
  bb:   r.berat_badan   || null,
  tb:   r.tinggi_badan  || null,
  lila: r.hasil_lila    || null,
  lk:   r.lingkar_kepala || null,
}));
```

### 5. Get Latest Data & Status

```jsx
const lastData = riwayat.length > 0
  ? [...riwayat].sort((a, b) => new Date(b.tgl_ukur) - new Date(a.tgl_ukur))[0]
  : null;

const lastStatus = deriveStatusFromZScore(lastData);
```

### 6. Render Layout

#### Sebelumnya (Old Layout):

```jsx
<div className="grid grid-cols-1 xl:grid-cols-3 gap-6">
  {/* Grafik dengan recharts */}
  <div className="xl:col-span-2">
    <LineChart data={chartData}>
      {/* ... recharts config ... */}
    </LineChart>
  </div>
  
  {/* Panel kanan */}
  <div className="space-y-4">
    {/* Pengukuran Terakhir */}
    {/* Status Gizi Summary */}
  </div>
</div>
```

#### Sesudahnya (New Layout - IMPROVED):

```jsx
<div className="grid grid-cols-1 xl:grid-cols-3 gap-6">
  {/* Grafik dengan komponen baru */}
  <div className="xl:col-span-2 bg-white rounded-3xl border border-gray-100 shadow-sm p-6 space-y-4">
    <div className="flex items-center justify-between flex-wrap gap-3 mb-4">
      <h3 className="text-base font-extrabold text-gray-900 flex items-center gap-2">
        <TrendingUp size={18} className="text-indigo-500" /> Grafik Pertumbuhan
      </h3>
      <div className="flex gap-1.5 flex-wrap">
        {Object.entries(chartConfig).map(([key, cfg]) => (
          <button
            key={key}
            onClick={() => setActiveChart(key)}
            className={`px-3 py-1.5 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all ${
              activeChart === key ? "text-white shadow-sm" : "bg-gray-100 text-gray-400 hover:bg-gray-200"
            }`}
            style={activeChart === key ? { backgroundColor: cfg.color } : {}}
          >
            {key.toUpperCase()}
          </button>
        ))}
      </div>
    </div>

    {/* Gunakan GrowthChart Component */}
    <GrowthChart 
      data={chartData}
      activeChart={activeChart}
      chartConfig={chartConfig}
      onChartChange={setActiveChart}
    />
  </div>

  {/* Panel kanan - Ringkasan & Status */}
  <div className="space-y-4">
    {/* Gunakan GrowthSummary Component */}
    <GrowthSummary 
      lastStatus={lastStatus}
      lastData={lastData}
      anak={anak}
    />

    {/* Pengukuran Terakhir - tetap sama atau gunakan MiniStat */}
    <div className="bg-white p-5 rounded-3xl border border-gray-100 shadow-sm">
      <p className="text-xs font-black text-gray-600 uppercase tracking-widest mb-4 flex items-center gap-2">
        <Scale size={14} className="text-indigo-500" /> Pengukuran Terakhir
      </p>
      <div className="grid grid-cols-2 gap-3">
        <MiniStat label="BB"   value={lastData?.berat_badan    ?? "-"} unit="kg" color="indigo" />
        <MiniStat label="TB"   value={lastData?.tinggi_badan   ?? "-"} unit="cm" color="purple" />
        <MiniStat label="LILA" value={lastData?.hasil_lila     || "-"} unit="cm" color="amber" />
        <MiniStat label="LK"   value={lastData?.lingkar_kepala || "-"} unit="cm" color="emerald" />
      </div>
    </div>
  </div>
</div>

{/* Detail Status Gizi dengan GrowthStatusCard - KOMPONEN BARU */}
{lastData && (
  <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
    <GrowthStatusCard 
      status={lastStatus.statusBBU}
      label="Berat Badan / Usia (BB/U)"
      zScore={lastData.z_score_bb_u || lastData.zScoreBBU}
      description="Menunjukkan status berat badan anak dibandingkan dengan standar usia"
    />
    <GrowthStatusCard 
      status={lastStatus.statusTBU}
      label="Tinggi Badan / Usia (TB/U)"
      zScore={lastData.z_score_tb_u || lastData.zScoreTBU}
      description="Menunjukkan pertumbuhan tinggi badan anak sesuai usia"
    />
    <GrowthStatusCard 
      status={lastStatus.statusBBTB}
      label="Berat Badan / Tinggi Badan (BB/TB)"
      zScore={lastData.z_score_bb_tb || lastData.zScoreBBTB}
      description="Menunjukkan proporsi berat badan terhadap tinggi badan"
    />
  </div>
)}

{/* Tabel Riwayat - tetap sama seperti sebelumnya */}
```

### 7. Update MiniStat Function

Update fungsi helper untuk support warna:

```jsx
function MiniStat({ label, value, unit, color = 'indigo' }) {
  const colorMap = {
    indigo: 'bg-indigo-50 text-indigo-700',
    purple: 'bg-purple-50 text-purple-700',
    amber: 'bg-amber-50 text-amber-700',
    emerald: 'bg-emerald-50 text-emerald-700',
  };

  return (
    <div className={`${colorMap[color]} rounded-xl p-3 text-center`}>
      <p className="text-[9px] font-black uppercase tracking-widest opacity-70">{label}</p>
      <p className="text-lg font-black">
        {value} <span className="text-[10px] opacity-60">{unit}</span>
      </p>
    </div>
  );
}
```

---

## Contoh Lengkap Data Flow

```
1. Component Mount
   ↓
2. fetchData() - GET /api/riwayat-pertumbuhan/{id}
   ↓
3. Parse Response
   - setRiwayat(data)
   - setAnak(data)
   ↓
4. Transform untuk Chart
   - chartData = riwayat.reverse().map(...)
   ↓
5. Derivasi Status Gizi
   - lastStatus = deriveStatusFromZScore(lastData)
   ↓
6. Render Components
   - GrowthChart dengan activeChart
   - GrowthSummary dengan lastStatus
   - GrowthStatusCard untuk 3 metrik
   - Tabel Riwayat
   ↓
7. User Interaction
   - Klik tab chart → setActiveChart() → GrowthChart re-render
   - Klik tombol tambah → Modal → POST → fetchData()
   - Klik edit/delete → PUT/DELETE → fetchData()
```

---

## Fitur-Fitur Utama

### ✅ GrowthChart Component

**Fitur:**
- [x] Grafik garis dan batang
- [x] Toggle chart type
- [x] Reference line untuk median
- [x] Tooltip interaktif
- [x] Animasi smooth
- [x] Responsive container

**Customization:**
- Ubah `getMedianByChart()` untuk sesuaikan nilai referensi
- Ubah duration animasi di `animationDuration={800}`
- Ubah margin dan padding di `margin={{ ... }}`

### ✅ GrowthStatusCard Component

**Fitur:**
- [x] Status color mapping otomatis
- [x] Z-Score bar visual
- [x] Icon indicator
- [x] Description text
- [x] Responsive design

**Props:**
```jsx
{
  status: "Normal",           // String status
  label: "BB/U",              // Label
  zScore: 0.5,                // Number Z-Score
  description: "Deskripsi..." // Optional string
}
```

### ✅ GrowthSummary Component

**Fitur:**
- [x] Gradient background
- [x] Child info display
- [x] 3 status summary
- [x] Shadow effect

**Props:**
```jsx
{
  lastStatus: { statusBBU, statusTBU, statusBBTB },
  lastData: { usia_ukur_bulan, ... },
  anak: { nama, ... }
}
```

---

## Troubleshooting

### Chart tidak muncul
- Pastikan `data` tidak kosong
- Check console untuk error dari recharts
- Pastikan ResponsiveContainer parent punya height

### Z-Score Bar tidak akurat
- Check nilai zScore benar-benar number
- Value zScore dari API sesuai format?
- Fungsi `getMedianByChart()` perlu disesuaikan dengan standar sebenarnya

### Warna status tidak berubah
- Check `status` prop string formatting
- Pastikan lowercase comparison di `getStatusColor()`
- Coba hardcode warna dulu untuk test

### Grafik lag saat scroll
- Reduce `animationDuration`
- Ubah ResponsiveContainer height ke fixed value
- Gunakan React.memo untuk component

---

## Performance Tips

1. **Memoization**
   ```jsx
   const chartData = useMemo(() => 
     [...riwayat].reverse().map(...),
     [riwayat]
   );
   ```

2. **Lazy Loading**
   - Load chart hanya ketika visible
   - Gunakan Intersection Observer

3. **Data Pagination**
   - Jika riwayat banyak, pagination untuk tabel
   - Chart maks 24 data points

4. **Debounce Tab Change**
   ```jsx
   const handleTabChange = debounce((tab) => {
     setActiveChart(tab);
   }, 300);
   ```

---

## Next Steps

1. Test dengan data real dari API
2. Adjust warna sesuai brand guidelines
3. Optimize untuk mobile viewport
4. Integrate dengan notification system
5. Add export/download functionality
