# -*- coding: utf-8 -*-
"""
================================================================
MAMACARE AI - STREAMLIT WEB APPLICATION
================================================================
Sistem Prediksi Risiko Kehamilan Terintegrasi
Proyek Machine Learning – Institut Teknologi Del
Mata Kuliah: 4143104 – Pembelajaran Mesin

Cara menjalankan:
    streamlit run mamacare_app.py

Pastikan sudah menjalankan: python mamacare_train.py
================================================================
"""

import streamlit as st
import joblib
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import seaborn as sns
import warnings
warnings.filterwarnings('ignore')

# ================================================================
# KONFIGURASI HALAMAN
# ================================================================
st.set_page_config(
    page_title="MamaCare AI – Prediksi Risiko Kehamilan",
    page_icon="🤰",
    layout="wide",
    initial_sidebar_state="expanded"
)

# ================================================================
# CSS STYLING
# ================================================================
st.markdown("""
<style>
    .main-header {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        padding: 24px; border-radius: 14px; color: white;
        text-align: center; margin-bottom: 22px;
    }
    .metric-card {
        background: white; padding: 15px; border-radius: 10px;
        border-left: 5px solid #667eea;
        box-shadow: 0 2px 8px rgba(0,0,0,0.08); margin: 8px 0;
    }
    .info-box    { background:#e8f4fd; padding:15px; border-radius:8px; border-left:4px solid #3498db; margin:8px 0; }
    .warning-box { background:#fff3cd; padding:15px; border-radius:8px; border-left:4px solid #ffc107; margin:8px 0; }
    .danger-box  { background:#f8d7da; padding:15px; border-radius:8px; border-left:4px solid #dc3545; margin:8px 0; }
    .success-box { background:#d4edda; padding:15px; border-radius:8px; border-left:4px solid #28a745; margin:8px 0; }
    .stButton>button {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white; border: none; border-radius: 8px;
        padding: 12px 24px; font-size: 16px; font-weight: bold;
        width: 100%; cursor: pointer;
    }
    .sidebar-info { background:#f0f0f0; padding:10px; border-radius:8px; font-size:12px; }
</style>
""", unsafe_allow_html=True)

# ================================================================
# LOAD MODEL
# ================================================================
@st.cache_resource
def load_models():
    m = {}
    try:
        m['rf']           = joblib.load('maternal_model_rf.pkl')
        m['lr']           = joblib.load('maternal_model_lr.pkl')
        m['scaler']       = joblib.load('scaler_maternal.pkl')
        m['feature_cols'] = joblib.load('feature_cols.pkl')
        m['label_map']    = joblib.load('label_map.pkl')
        try:
            m['importances'] = joblib.load('feature_importances.pkl')
        except Exception:
            m['importances'] = None
        m['status'] = 'loaded'
    except FileNotFoundError:
        m['status'] = 'not_found'
    return m

models = load_models()

# ================================================================
# FUNGSI HELPER
# ================================================================
def compute_features(d):
    """Hitung semua fitur turunan dari input dasar."""
    d = dict(d)   # copy
    td_s = float(d.get('TD Sistolik', 120))
    td_d = float(d.get('TD Diastolik', 80))
    hb   = float(d.get('Hemoglobin/Hb (g/dL)', 12))
    lila = float(d.get('LiLA (cm)', 26))
    imt  = float(d.get('IMT', 22))
    usia = float(d.get('Usia_Ibu', 25))

    d['MAP']           = (td_s + 2 * td_d) / 3
    d['Pulse_Pressure']= td_s - td_d
    d['Trimester_Num'] = d.get('Trimester_Num', 2)

    # Kategori
    d['KatTD_Enc']  = 2 if (td_s >= 140 or td_d >= 90) else (1 if (td_s >= 120 or td_d >= 80) else 0)
    d['KatHb_Enc']  = 1 if hb < 11.0 else 0
    d['KatLiLA_Enc']= 1 if lila < 23.5 else 0
    d['KatIMT_Enc'] = 0 if imt < 18.5 else (3 if imt >= 30 else (2 if imt >= 25 else 1))

    # Flags
    d['Anemia_Flag']  = 1 if hb < 11.0 else 0
    d['Anemia_Berat'] = 1 if hb < 8.0  else 0
    d['Hiper_Flag']   = 1 if td_s >= 140 else 0
    d['Hiper_Berat']  = 1 if td_s >= 160 else 0
    d['KEK_Flag']     = 1 if lila < 23.5 else 0
    d['IMT_Kurus']    = 1 if imt < 18.5 else 0
    d['IMT_Obese']    = 1 if imt >= 30.0 else 0
    d['Usia_Risiko']  = 1 if (usia < 19 or usia > 38) else 0
    d['Abortus_Tinggi']= 1 if d.get('Abortus', 0) >= 2 else 0
    d['Grandemulti']  = 1 if d.get('Gravida', 1) >= 5 else 0

    # Tripel
    hiv   = int(d.get('HIV_Rek', 0))
    sif   = int(d.get('Sif_Rek', 0))
    hepb  = int(d.get('HepB_Rek', 0))
    d['Tripel_Total'] = hiv + sif + hepb

    # Risk Score
    riwayat_enc   = int(d.get('Riwayat_Enc', 0))
    riwayat_berat = int(d.get('Riwayat_Berat', 0))
    d['Risk_Score'] = (
        d['Anemia_Flag'] * 2 + d['Anemia_Berat'] * 3 +
        d['KatTD_Enc'] * 3  + d['Hiper_Berat'] * 5 +
        d['KEK_Flag'] * 2   + (2 if d['KatIMT_Enc'] in [0, 3] else 0) +
        riwayat_enc * 2 + riwayat_berat * 3 +
        d['Tripel_Total'] + d['Usia_Risiko']
    )
    return d

def predict_with_model(data_dict):
    """Prediksi risiko menggunakan Random Forest."""
    feature_cols = models['feature_cols']
    label_map    = models['label_map']
    d = compute_features(data_dict)
    row = {col: d.get(col, 0) for col in feature_cols}
    input_df = pd.DataFrame([row])[feature_cols].fillna(0)
    pred  = models['rf'].predict(input_df)[0]
    proba = models['rf'].predict_proba(input_df)[0]
    return pred, proba, label_map[pred]

def generate_recommendation(d):
    """Rekomendasi tindakan klinis berbasis kondisi pasien."""
    recs = []
    hb   = float(d.get('Hemoglobin/Hb (g/dL)', 12))
    lila = float(d.get('LiLA (cm)', 26))
    imt  = float(d.get('IMT', 22))
    td_s = float(d.get('TD Sistolik', 120))
    td_d = float(d.get('TD Diastolik', 80))
    usia = float(d.get('Usia_Ibu', 25))
    kunjungan   = int(d.get('Kunjungan ANC Ke-', 4))
    riwayat_enc = int(d.get('Riwayat_Enc', 0))
    riwayat_txt = d.get('Riwayat_Text', 'Tidak Ada')
    hiv = int(d.get('HIV_Rek', 0))
    sif = int(d.get('Sif_Rek', 0))

    if hb < 8.0:
        recs.append(('🚨 Rujuk Segera', 'KRITIS',
            f'Hb {hb:.1f} g/dL → anemia berat. Kemungkinan perlu transfusi darah.'))
    elif hb < 11.0:
        recs.append(('💊 Suplementasi Fe', 'TINGGI',
            f'Hb {hb:.1f} g/dL → anemia. Tablet Fe 60 mg/hari minimal 90 tablet.'))
    if lila < 23.5:
        recs.append(('🥗 Konseling Gizi & PMT', 'TINGGI',
            f'LiLA {lila:.1f} cm (< 23,5 cm) → Risiko KEK. PMT bumil diperlukan.'))
    if imt < 18.5:
        recs.append(('🥗 Konseling Gizi', 'SEDANG',
            f'IMT {imt:.1f} → kurus. Tingkatkan asupan kalori dan protein.'))
    elif imt >= 30.0:
        recs.append(('🥗 Konseling Gizi', 'SEDANG',
            f'IMT {imt:.1f} → obesitas. Atur pola makan seimbang.'))
    if td_s >= 160 or td_d >= 110:
        recs.append(('🚨 Rujuk Segera', 'KRITIS',
            f'Krisis hipertensi (TD {td_s:.0f}/{td_d:.0f} mmHg). Risiko preeklampsia berat!'))
    elif td_s >= 140 or td_d >= 90:
        recs.append(('🚨 Rujuk Segera', 'TINGGI',
            f'Hipertensi (TD {td_s:.0f}/{td_d:.0f} mmHg). Rujuk ke RSUD.'))
    elif td_s >= 120 or td_d >= 80:
        recs.append(('📋 Konseling ANC', 'SEDANG',
            f'Pra-hipertensi (TD {td_s:.0f}/{td_d:.0f} mmHg). Pantau TD & edukasi gaya hidup.'))
    if riwayat_enc and riwayat_txt.lower() not in ('tidak ada', ''):
        recs.append(('🔬 Pemeriksaan Lab', 'SEDANG',
            f'Riwayat penyakit: {riwayat_txt}. Perlu pemantauan laboratorium lanjutan.'))
    if hiv or sif:
        recs.append(('🚨 Rujuk Segera', 'KRITIS',
            'Tripel Eliminasi Reaktif (HIV/Sifilis). Rujuk segera untuk penanganan khusus.'))
    if kunjungan <= 1:
        recs.append(('📋 Konseling ANC', 'SEDANG',
            f'Baru {kunjungan}x kunjungan ANC. Dorong kunjungan rutin min. 6x selama kehamilan.'))
    if usia < 19:
        recs.append(('📋 Konseling ANC', 'SEDANG',
            f'Usia ibu {usia:.0f} tahun (< 19). Kehamilan remaja berisiko, konseling intensif.'))
    elif usia > 38:
        recs.append(('📋 Konseling ANC', 'SEDANG',
            f'Usia ibu {usia:.0f} tahun (> 38). Kehamilan usia lanjut, pantau ketat.'))

    # Deduplikasi berdasarkan nama tindakan
    seen, uniq = set(), []
    for r in recs:
        if r[0] not in seen:
            seen.add(r[0]); uniq.append(r)
    if not uniq:
        uniq.append(('✅ Konseling ANC Rutin', 'RENDAH',
            'Kondisi ibu hamil baik. Lanjutkan pemantauan ANC rutin.'))
    return uniq

def plot_proba(proba, label_map):
    fig, ax = plt.subplots(figsize=(8, 3))
    colors = ['#28a745', '#ffc107', '#dc3545']
    labels = [label_map[i] for i in range(len(proba))]
    bars = ax.barh(labels, proba * 100, color=colors[:len(proba)],
                   height=0.5, edgecolor='white')
    for bar, val in zip(bars, proba):
        ax.text(bar.get_width() + 0.8, bar.get_y() + bar.get_height()/2,
                f'{val*100:.1f}%', va='center', fontsize=10, fontweight='bold')
    ax.set_xlabel('Probabilitas (%)', fontsize=11)
    ax.set_title('Distribusi Probabilitas Risiko', fontsize=12, fontweight='bold')
    ax.set_xlim(0, 115)
    ax.axvline(50, color='gray', linestyle='--', alpha=0.4, linewidth=1)
    plt.tight_layout()
    return fig

# ================================================================
# SIDEBAR
# ================================================================
with st.sidebar:
    st.markdown("## 🤰 MamaCare AI")
    st.markdown("**Prediksi Risiko Kehamilan**")
    st.markdown("---")

    if models.get('status') == 'loaded':
        st.success("✅ Model siap digunakan")
    else:
        st.error("❌ Model belum tersedia!\n\nJalankan:\n```\npython mamacare_train.py\n```")

    st.markdown("---")
    page = st.selectbox("📂 Navigasi", [
        "🏠 Beranda",
        "🔍 Prediksi Risiko",
        "📊 Dashboard Analitik",
        "🤖 Chatbot Asisten",
        "ℹ️ Tentang"
    ])
    st.markdown("---")
    st.markdown("""
    <div class="sidebar-info">
    <b>Kategori Risiko:</b><br>
    🟢 <b>Normal</b> – Tidak ada tindakan khusus<br>
    🟡 <b>Perlu Tindakan</b> – Intervensi dini<br>
    🔴 <b>Perlu Rujukan</b> – Rujuk segera
    </div>
    """, unsafe_allow_html=True)
    st.markdown("---")
    st.caption("© 2025 MamaCare AI – IT Del")

# ================================================================
# HALAMAN: BERANDA
# ================================================================
if page == "🏠 Beranda":
    st.markdown("""
    <div class="main-header">
        <h1>🤰 MamaCare AI</h1>
        <h3>Sistem Prediksi Risiko Kehamilan Berbasis Machine Learning</h3>
        <p>Institut Teknologi Del | Mata Kuliah: Pembelajaran Mesin (4143104)</p>
    </div>
    """, unsafe_allow_html=True)

    col1, col2, col3, col4 = st.columns(4)
    for col, (val, label) in zip(
        [col1, col2, col3, col4],
        [("10.000+", "Data Pasien Bumil"),
         ("3 Kelas", "Kategori Risiko"),
         ("37 Fitur", "Parameter Klinis"),
         (">98%", "Akurasi RF")]
    ):
        col.markdown(f"""
        <div class="metric-card">
            <h3 style="color:#667eea; margin:0">{val}</h3>
            <p style="margin:0">{label}</p>
        </div>""", unsafe_allow_html=True)

    st.markdown("---")
    col1, col2 = st.columns(2)
    with col1:
        st.info("""
**Cara Menggunakan:**
1. Pilih **🔍 Prediksi Risiko** di sidebar
2. Isi data pasien ibu hamil
3. Klik tombol **Prediksi Risiko**
4. Lihat hasil & rekomendasi tindakan
        """)
    with col2:
        st.info("""
**Fitur Tersedia:**
- 🔍 Prediksi risiko berbasis AI (Random Forest)
- 📊 Dashboard analitik dataset ANC Bumil
- 🤖 Chatbot asisten informasi kehamilan
- 📈 Visualisasi probabilitas per kelas
        """)
    st.warning("""⚠️ **Disclaimer:** Aplikasi ini adalah alat bantu skrining edukatif dan TIDAK menggantikan
    diagnosis medis profesional. Untuk penanganan, selalu konsultasikan dengan bidan/dokter.""")

# ================================================================
# HALAMAN: PREDIKSI RISIKO
# ================================================================
elif page == "🔍 Prediksi Risiko":
    st.markdown("## 🔍 Prediksi Risiko Kehamilan")
    st.caption("Isi data pasien di bawah ini untuk mendapatkan prediksi risiko dan rekomendasi tindakan klinis.")

    if models.get('status') != 'loaded':
        st.error("Model belum tersedia. Jalankan `python mamacare_train.py` terlebih dahulu.")
        st.stop()

    with st.form("form_prediksi"):
        # --- Demografi ---
        st.markdown("### 👤 Data Demografi & Obstetri")
        c1, c2, c3 = st.columns(3)
        with c1:
            usia_ibu       = st.number_input("Usia Ibu (tahun)", 14, 55, 28)
            gravida        = st.number_input("Gravida (Jml. Kehamilan)", 1, 15, 1)
        with c2:
            usia_kehamilan = st.number_input("Usia Kehamilan (minggu)", 1, 42, 20)
            para           = st.number_input("Para (Jml. Persalinan)", 0, 14, 0)
        with c3:
            trimester_sel  = st.selectbox("Trimester", ["I (1-12 minggu)", "II (13-27 minggu)", "III (28-42 minggu)"])
            abortus        = st.number_input("Abortus", 0, 10, 0)
        trimester_num = {"I (1-12 minggu)":1, "II (13-27 minggu)":2, "III (28-42 minggu)":3}[trimester_sel]

        # --- Antropometri ---
        st.markdown("---")
        st.markdown("### 📏 Antropometri")
        c1, c2, c3 = st.columns(3)
        with c1:
            imt    = st.number_input("IMT (kg/m²)", 10.0, 60.0, 23.0, 0.1, format="%.1f")
        with c2:
            lila   = st.number_input("LiLA / Lingkar Lengan Atas (cm)", 15.0, 45.0, 26.0, 0.1, format="%.1f")
        with c3:
            fundus = st.number_input("Tinggi Fundus Uteri (cm)", 0.0, 45.0, 25.0, 0.5, format="%.1f")

        # --- Vital Signs & Lab ---
        st.markdown("---")
        st.markdown("### 💉 Tanda Vital & Laboratorium")
        c1, c2, c3 = st.columns(3)
        with c1:
            td_s = st.number_input("TD Sistolik (mmHg)", 70, 220, 115)
            td_d = st.number_input("TD Diastolik (mmHg)", 40, 140, 75)
        with c2:
            hb   = st.number_input("Hemoglobin / Hb (g/dL)", 4.0, 20.0, 12.0, 0.1, format="%.1f")
        with c3:
            kunjungan  = st.number_input("Kunjungan ANC Ke-", 1, 10, 3)
            imunisasi  = st.selectbox("Status Imunisasi TD", ["T1","T2","T3","T4","T5"], index=2)
        imunisasi_enc = {"T1":1,"T2":2,"T3":3,"T4":4,"T5":5}[imunisasi]

        # --- Riwayat & Skrining ---
        st.markdown("---")
        st.markdown("### 🏥 Riwayat Penyakit & Tripel Eliminasi")
        c1, c2 = st.columns(2)
        with c1:
            riwayat_opts = ["Tidak Ada","Hipertensi","Anemia","Diabetes","Hepatitis B","TB","Jantung","Asma","Lainnya"]
            riwayat_sel  = st.selectbox("Riwayat Penyakit", riwayat_opts)
        with c2:
            hiv_sel  = st.selectbox("Tripel Eliminasi – HIV",        ["Non Reaktif","Reaktif"])
            sif_sel  = st.selectbox("Tripel Eliminasi – Sifilis",    ["Non Reaktif","Reaktif"])
            hepb_sel = st.selectbox("Tripel Eliminasi – Hepatitis B",["Non Reaktif","Reaktif"])

        submitted = st.form_submit_button("🔮 Prediksi Risiko Sekarang", use_container_width=True)

    if submitted:
        riwayat_enc   = 0 if riwayat_sel == "Tidak Ada" else 1
        riwayat_berat = 1 if riwayat_sel.lower() in ('hipertensi','jantung','tb') else 0

        data_dict = {
            'Usia_Ibu'                : float(usia_ibu),
            'Usia Kehamilan (minggu)' : int(usia_kehamilan),
            'Trimester_Num'           : int(trimester_num),
            'Gravida'                 : int(gravida),
            'Para'                    : int(para),
            'Abortus'                 : int(abortus),
            'IMT'                     : float(imt),
            'LiLA (cm)'               : float(lila),
            'Tinggi Fundus Uteri (cm)': float(fundus),
            'TD Sistolik'             : float(td_s),
            'TD Diastolik'            : float(td_d),
            'Hemoglobin/Hb (g/dL)'   : float(hb),
            'Kunjungan ANC Ke-'       : int(kunjungan),
            'Imunisasi_Enc'           : int(imunisasi_enc),
            'Riwayat_Enc'             : int(riwayat_enc),
            'Riwayat_Berat'           : int(riwayat_berat),
            'Riwayat_Text'            : riwayat_sel,
            'HIV_Rek'                 : 1 if hiv_sel == "Reaktif" else 0,
            'Sif_Rek'                 : 1 if sif_sel == "Reaktif" else 0,
            'HepB_Rek'                : 1 if hepb_sel == "Reaktif" else 0,
        }

        try:
            pred, proba, label = predict_with_model(data_dict)
            rekomendasi        = generate_recommendation(data_dict)

            st.markdown("---")
            st.markdown("## 📊 Hasil Prediksi")

            risk_cfg = {
                0: ('#28a745', '✅', 'success-box'),
                1: ('#ffc107', '⚠️', 'warning-box'),
                2: ('#dc3545', '🚨', 'danger-box')
            }
            clr, ikon, box = risk_cfg[pred]
            st.markdown(f"""
            <div class="{box}">
                <h2 style="text-align:center;color:{clr};">{ikon} {label}</h2>
                <p style="text-align:center;">Probabilitas: <strong>{proba[pred]*100:.1f}%</strong></p>
            </div>""", unsafe_allow_html=True)

            c1, c2 = st.columns([1.2, 1])
            with c1:
                st.markdown("### 📈 Distribusi Probabilitas")
                fig = plot_proba(proba, models['label_map'])
                st.pyplot(fig); plt.close()
            with c2:
                st.markdown("### 📋 Ringkasan Kondisi")
                def _hb(v):   return "🔴 Anemia" if v < 11 else ("🟡 Borderline" if v < 12 else "🟢 Normal")
                def _lila(v): return "🔴 KEK" if v < 23.5 else "🟢 Normal"
                def _td(s,d): return "🔴 Hipertensi" if s>=140 or d>=90 else ("🟡 Pra-HT" if s>=120 or d>=80 else "🟢 Normal")
                def _imt(v):  return "🔴 Kurus" if v<18.5 else ("🟢 Normal" if v<25 else ("🟡 Gemuk" if v<30 else "🔴 Obesitas"))
                def _usia(v): return "🟡 Berisiko" if v<19 or v>38 else "🟢 Normal"
                st.markdown(f"""
| Parameter | Nilai | Status |
|---|---|---|
| Hemoglobin | {hb:.1f} g/dL | {_hb(hb)} |
| LiLA | {lila:.1f} cm | {_lila(lila)} |
| TD | {td_s:.0f}/{td_d:.0f} mmHg | {_td(td_s,td_d)} |
| IMT | {imt:.1f} kg/m² | {_imt(imt)} |
| Usia | {usia_ibu} tahun | {_usia(usia_ibu)} |
""")

            st.markdown("---")
            st.markdown("### 🔧 Rekomendasi Tindakan")
            prio_box = {'KRITIS':'danger-box','TINGGI':'warning-box','SEDANG':'info-box','RENDAH':'success-box'}
            for tindakan, prio, alasan in rekomendasi:
                st.markdown(f"""
                <div class="{prio_box.get(prio,'info-box')}">
                    <strong>{tindakan}</strong>
                    &nbsp; <small>Prioritas: <b>{prio}</b></small><br>{alasan}
                </div>""", unsafe_allow_html=True)

            st.markdown("---")
            st.caption("⚕️ Hasil ini adalah alat bantu skrining, bukan pengganti diagnosis medis profesional.")

        except Exception as e:
            st.error(f"Error prediksi: {e}")
            st.info("Pastikan model sudah dilatih: `python mamacare_train.py`")

# ================================================================
# HALAMAN: DASHBOARD ANALITIK
# ================================================================
elif page == "📊 Dashboard Analitik":
    st.markdown("## 📊 Dashboard Analitik Dataset ANC Bumil")

    @st.cache_data
    def load_data():
        df = pd.read_excel('dataset_anc_bumil.xlsx')
        df['Tgl Lahir'] = pd.to_datetime(df['Tgl Lahir'], dayfirst=True, errors='coerce')
        df['Usia_Ibu']  = df['Tgl Lahir'].apply(
            lambda x: (pd.Timestamp('2025-10-01')-x).days//365 if pd.notnull(x) else 28
        ).clip(14, 55)
        df['Tindakan'] = df['Tindakan'].fillna('Normal')
        def _risk(row):
            r = str(row['Riwayat Penyakit']).strip().lower()
            if row['TD Sistolik']>=160 or row['TD Diastolik']>=110: return 'PERLU RUJUKAN'
            if row['Hemoglobin/Hb (g/dL)']<8.0: return 'PERLU RUJUKAN'
            if str(row['Tripel Eliminasi - HIV']).strip()=='Reaktif' or \
               str(row['Tripel Eliminasi - Sifilis']).strip()=='Reaktif': return 'PERLU RUJUKAN'
            if r in ('hipertensi','jantung','tb'): return 'PERLU RUJUKAN'
            score = 0
            if row['TD Sistolik']>=140 or row['TD Diastolik']>=90: score+=3
            if row['TD Sistolik']>=120 or row['TD Diastolik']>=80: score+=1
            if row['Hemoglobin/Hb (g/dL)']<11.0: score+=2
            if str(row.get('Kategori LiLA','')).strip()=='Risiko KEK': score+=2
            if r not in ('tidak ada','nan',''): score+=2
            imt=row['IMT']
            if imt<17.0 or imt>=35.0: score+=2
            elif imt<18.5 or imt>=30.0: score+=1
            if row['Usia_Ibu']<19 or row['Usia_Ibu']>38: score+=1
            if row['Abortus']>=2: score+=1
            if row['Gravida']>=5: score+=1
            if row['Kunjungan ANC Ke-']<=1: score+=1
            return 'PERLU TINDAKAN' if score>=4 else 'NORMAL'
        df['RISIKO_LABEL'] = df.apply(_risk, axis=1)
        return df

    try:
        df = load_data()
    except FileNotFoundError:
        st.error("Dataset `dataset_anc_bumil.xlsx` tidak ditemukan."); st.stop()

    c1,c2,c3,c4 = st.columns(4)
    c1.metric("Total Pasien", f"{len(df):,}")
    c2.metric("Perlu Rujukan", f"{(df['RISIKO_LABEL']=='PERLU RUJUKAN').sum():,}")
    c3.metric("Rata-rata Usia", f"{df['Usia_Ibu'].mean():.1f} th")
    c4.metric("Rata-rata Hb", f"{df['Hemoglobin/Hb (g/dL)'].mean():.1f} g/dL")

    st.markdown("---")
    c1, c2 = st.columns(2)
    with c1:
        st.markdown("#### Distribusi Kelas Risiko")
        fig, ax = plt.subplots(figsize=(6,4))
        counts = df['RISIKO_LABEL'].value_counts()
        bars   = ax.bar(counts.index, counts.values,
                        color=['#28a745','#ffc107','#dc3545'][:len(counts)])
        for b, v in zip(bars, counts.values):
            ax.text(b.get_x()+b.get_width()/2, b.get_height()+30,
                    f'{v:,}\n({v/len(df)*100:.1f}%)', ha='center', fontsize=9)
        ax.set_ylabel('Jumlah'); ax.set_title('Distribusi Risiko Kehamilan')
        plt.xticks(rotation=20, ha='right'); plt.tight_layout()
        st.pyplot(fig); plt.close()

    with c2:
        st.markdown("#### Distribusi Hemoglobin")
        fig, ax = plt.subplots(figsize=(6,4))
        ax.hist(df['Hemoglobin/Hb (g/dL)'].dropna(), bins=30, color='#667eea', edgecolor='white', alpha=0.8)
        ax.axvline(11.0, color='red', linestyle='--', label='Batas Anemia (11 g/dL)')
        ax.axvline(df['Hemoglobin/Hb (g/dL)'].mean(), color='orange', linestyle='--',
                   label=f'Mean ({df["Hemoglobin/Hb (g/dL)"].mean():.1f})')
        ax.set_xlabel('Hb (g/dL)'); ax.set_ylabel('Frekuensi')
        ax.set_title('Distribusi Hemoglobin'); ax.legend(fontsize=8)
        plt.tight_layout(); st.pyplot(fig); plt.close()

    c1, c2 = st.columns(2)
    with c1:
        st.markdown("#### Distribusi Tekanan Darah")
        fig, ax = plt.subplots(figsize=(6,4))
        td_dist = df['Kategori TD'].value_counts()
        ax.pie(td_dist.values, labels=td_dist.index,
               autopct='%1.1f%%', colors=['#28a745','#ffc107','#dc3545'][:len(td_dist)])
        ax.set_title('Kategori Tekanan Darah'); plt.tight_layout()
        st.pyplot(fig); plt.close()

    with c2:
        st.markdown("#### Distribusi Trimester")
        fig, ax = plt.subplots(figsize=(6,4))
        tr = df['Trimester'].value_counts().reindex(['I','II','III'])
        bars = ax.bar(['Trimester I','Trimester II','Trimester III'],
                      tr.values, color=['#a8edea','#667eea','#764ba2'])
        for b, v in zip(bars, tr.values):
            ax.text(b.get_x()+b.get_width()/2, b.get_height()+20, f'{v:,}', ha='center')
        ax.set_title('Pasien per Trimester'); ax.set_ylabel('Jumlah')
        plt.tight_layout(); st.pyplot(fig); plt.close()

    if models.get('importances') is not None:
        st.markdown("---")
        st.markdown("#### 🎯 Feature Importance (Top 15)")
        imp = models['importances'].head(15)
        fig, ax = plt.subplots(figsize=(10,6))
        sns.barplot(data=imp, x='Importance', y='Fitur', palette='viridis', ax=ax)
        ax.set_title('Top 15 Feature Importance – Random Forest', fontsize=13, fontweight='bold')
        plt.tight_layout(); st.pyplot(fig); plt.close()

    st.markdown("---")
    st.markdown("#### 📋 Statistik Deskriptif")
    num_cols = ['Usia_Ibu','Usia Kehamilan (minggu)','IMT','LiLA (cm)',
                'TD Sistolik','TD Diastolik','Hemoglobin/Hb (g/dL)']
    st.dataframe(df[[c for c in num_cols if c in df.columns]].describe().round(2),
                 use_container_width=True)

# ================================================================
# HALAMAN: CHATBOT
# ================================================================
elif page == "🤖 Chatbot Asisten":
    st.markdown("## 🤖 MamaCare Chat Assistant")
    st.caption("Tanyakan seputar kehamilan, risiko, dan panduan ANC.")

    faq = {
        "apa itu risiko normal": "🟢 **Normal** – Tidak ada tanda bahaya. Lanjutkan ANC rutin.",
        "apa itu perlu tindakan": "🟡 **Perlu Tindakan** – Ada indikasi klinis yang perlu ditangani: konseling ANC, suplementasi zat besi, atau konseling gizi.",
        "apa itu perlu rujukan": "🔴 **Perlu Rujukan** – Kondisi berbahaya (hipertensi berat, anemia berat, tripel eliminasi reaktif). Segera rujuk ke RSUD.",
        "apa itu anemia": "🩸 **Anemia kehamilan** adalah Hb < 11 g/dL. Gejala: lemas, pusing, pucat. Penanganan: tablet Fe 60 mg/hari minimal 90 tablet.",
        "apa itu kek": "⚖️ **KEK (Kurang Energi Kronik)** ditandai LiLA < 23,5 cm. Risiko melahirkan BBLR. Perlu PMT (Pemberian Makanan Tambahan).",
        "apa itu preeklampsia": "💉 **Preeklampsia** = TD ≥ 140/90 mmHg + proteinuria setelah 20 minggu. Gejala: sakit kepala, bengkak, pandangan kabur. **Rujuk segera!**",
        "berapa kali kunjungan anc": "📅 Standar WHO minimal **6 kunjungan ANC**: T1 (2x), T2 (1x), T3 (3x).",
        "apa yang dimakan ibu hamil": "🥗 Makan seimbang: protein (ikan, telur, tempe), zat besi (bayam, hati), kalsium (susu, brokoli), folat (sayuran hijau). Hindari makanan mentah dan alkohol.",
        "apakah boleh olahraga": "🏃‍♀️ Boleh! Jalan kaki 30 menit/hari, senam hamil, renang. Hindari olahraga berat dan kontak fisik.",
        "tanda bahaya kehamilan": "🚨 **Tanda bahaya:** Perdarahan, sakit kepala berat, pandangan kabur, bengkak wajah/tangan, gerakan janin berkurang, nyeri perut hebat, demam tinggi.",
        "apa itu tablet fe": "💊 Tablet Fe (zat besi) 60 mg/hari, minimal 90 tablet. Minum malam hari atau bersama vitamin C agar terserap optimal.",
        "apa itu tripel eliminasi": "🔬 Skrining 3 penyakit: **HIV, Sifilis, Hepatitis B**. Wajib dilakukan pada ibu hamil karena dapat menular ke bayi.",
        "apa itu imunisasi td": "💉 Imunisasi TD mencegah tetanus neonatorum. T1–T5, diberikan gratis di Puskesmas. T5 = perlindungan seumur hidup.",
        "apa itu imt": "⚖️ **IMT (Indeks Massa Tubuh)** = Berat Badan (kg) / Tinggi² (m). Normal: 18,5–24,9. Kurus < 18,5. Gemuk ≥ 25. Obesitas ≥ 30.",
        "apa itu lila": "📏 **LiLA** = Lingkar Lengan Atas, diukur di pertengahan lengan kiri. LiLA < 23,5 cm menandakan ibu hamil berisiko KEK.",
        "apa itu map": "🩺 **MAP (Mean Arterial Pressure)** = (Sistolik + 2×Diastolik) / 3. Normal: 70–100 mmHg. Tinggi jika > 107 mmHg.",
    }

    user_q = st.text_input("💬 Ketik pertanyaan Anda:",
                           placeholder="Contoh: apa itu anemia pada kehamilan?")
    if user_q:
        q = user_q.lower().strip()
        found = False
        for key, ans in faq.items():
            if any(w in q for w in key.split()):
                st.markdown(f'<div class="info-box"><b>🤖 MamaCare AI:</b><br><br>{ans}</div>',
                            unsafe_allow_html=True)
                found = True; break
        if not found:
            st.markdown('<div class="warning-box">🤔 Saya tidak menemukan jawaban spesifik. '
                        'Silakan hubungi bidan/dokter Puskesmas terdekat.</div>',
                        unsafe_allow_html=True)

    st.markdown("---")
    st.markdown("### 💡 Pertanyaan Cepat")
    groups = {
        "Tentang Risiko": ["apa itu anemia","apa itu kek","apa itu preeklampsia"],
        "Panduan ANC": ["berapa kali kunjungan anc","apa itu imunisasi td","apa itu tripel eliminasi"],
        "Gaya Hidup": ["apa yang dimakan ibu hamil","apakah boleh olahraga","tanda bahaya kehamilan"],
    }
    for grp, qs in groups.items():
        st.markdown(f"**{grp}:**")
        cols = st.columns(len(qs))
        for col, q in zip(cols, qs):
            with col:
                if st.button(q.title()[:30], key=f"faq_{q}"):
                    st.info(faq.get(q, "Tidak ditemukan."))

    st.markdown("---")
    st.caption("⚕️ Informasi bersifat edukatif. Selalu konsultasikan dengan tenaga kesehatan profesional.")

# ================================================================
# HALAMAN: TENTANG
# ================================================================
elif page == "ℹ️ Tentang":
    st.markdown("## ℹ️ Tentang MamaCare AI")
    st.markdown("""
    <div class="main-header">
        <h2>🤰 MamaCare AI</h2>
        <p>Sistem Prediksi Risiko Kehamilan Berbasis Machine Learning</p>
        <p>Institut Teknologi Del | Mata Kuliah 4143104</p>
    </div>
    """, unsafe_allow_html=True)

    c1, c2 = st.columns(2)
    with c1:
        st.markdown("""
### 📚 Informasi Proyek
| Item | Detail |
|---|---|
| Mata Kuliah | Pembelajaran Mesin (4143104) |
| Institusi | Institut Teknologi Del |
| Dosen | Oppir Hutapea, S.Tr.Kom., M.Kom |
| Domain | Kesehatan Maternal |
| Topik ML | Klasifikasi |
| Dataset | ANC Bumil – 10.000 pasien |
| Algoritma | Random Forest & Logistic Regression |
""")
    with c2:
        st.markdown("""
### 🔧 Spesifikasi Teknis
| Komponen | Detail |
|---|---|
| Jumlah Fitur | 37 fitur klinis |
| Kelas Prediksi | 3 kelas risiko |
| Metode Tuning | GridSearchCV 5-fold CV |
| Handling Imbalance | Oversampling (sklearn resample) |
| Target Akurasi | > 80% |
| RF Akurasi | ~98% |
| LR Akurasi | ~96% |
| Framework | scikit-learn, Streamlit |
""")

    st.markdown("---")
    st.markdown("### 🗂️ Kelas Risiko")
    c1, c2, c3 = st.columns(3)
    with c1:
        st.markdown('<div class="success-box"><b>✅ NORMAL</b><br>Tidak ada tanda bahaya.<br>Lanjutkan ANC rutin sesuai jadwal.</div>', unsafe_allow_html=True)
    with c2:
        st.markdown('<div class="warning-box"><b>🟡 PERLU TINDAKAN</b><br>Ada indikasi klinis.<br>Konseling, suplementasi, atau pemeriksaan lab.</div>', unsafe_allow_html=True)
    with c3:
        st.markdown('<div class="danger-box"><b>🔴 PERLU RUJUKAN</b><br>Kondisi kritis/berbahaya.<br>Rujuk segera ke RSUD/faskes lebih tinggi.</div>', unsafe_allow_html=True)

    st.markdown("---")
    st.warning("""
**⚠️ Disclaimer:**
Aplikasi MamaCare AI adalah alat bantu skrining edukatif dan **TIDAK DAPAT** menggantikan
pemeriksaan & diagnosa oleh tenaga kesehatan profesional (bidan, dokter, dokter spesialis kandungan).

**Untuk kondisi darurat, segera hubungi:**
- 📞 Bidan / Dokter Puskesmas terdekat
- 🏥 IGD Rumah Sakit terdekat
- 📱 Hotline Kesehatan: **119**
""")
