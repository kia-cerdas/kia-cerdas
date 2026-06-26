import streamlit as st
import pandas as pd
import numpy as np
import joblib
import json
import os

# Konfigurasi Halaman
st.set_page_config(page_title="Deteksi Stunting AI", page_icon="👶", layout="wide")

# ==========================================
# 1. FUNGSI LOAD MODEL & ARTIFAK
# ==========================================
@st.cache_resource
def load_model_artifacts():
    try:
        model = joblib.load('model_artifacts/stunting_model.pkl')
        scaler = joblib.load('model_artifacts/scaler.pkl')
        le = joblib.load('model_artifacts/label_encoder.pkl')
        with open('model_artifacts/metadata.json', 'r') as f:
            metadata = json.load(f)
        return model, scaler, le, metadata
    except Exception as e:
        st.error(f"Gagal memuat model. Pastikan folder 'model_artifacts' ada. Error: {e}")
        return None, None, None, None

model, scaler, le, metadata = load_model_artifacts()

# ==========================================
# 2. HALAMAN 1: PENDETEKSI STUNTING
# ==========================================
def page_deteksi():
    st.title("🧠 Deteksi Dini Risiko Stunting")
    st.markdown("Masukkan data antropometri balita dari hasil pengukuran Posyandu untuk mendeteksi tingkat risiko stunting.")

    if not model:
        st.warning("Model belum dimuat. Silakan latih model terlebih dahulu.")
        return

    # Form Input Data
    with st.form("form_pendeteksi"):
        col1, col2, col3 = st.columns(3)
        
        with col1:
            st.subheader("Data Dasar")
            usia = st.number_input("Usia (Bulan)", min_value=0.0, max_value=60.0, value=24.0, step=1.0)
            jk = st.selectbox("Jenis Kelamin", ["Laki-laki (L)", "Perempuan (P)"])
            bb_lahir = st.number_input("Berat Lahir (kg)", min_value=1.0, max_value=6.0, value=3.0, step=0.1)
            tb_lahir = st.number_input("Tinggi Lahir (cm)", min_value=40.0, max_value=60.0, value=49.0, step=0.5)

        with col2:
            st.subheader("Pengukuran Saat Ini")
            berat = st.number_input("Berat Badan Sekarang (kg)", min_value=2.0, max_value=30.0, value=10.0, step=0.1)
            tinggi = st.number_input("Tinggi Badan Sekarang (cm)", min_value=45.0, max_value=120.0, value=80.0, step=0.5)
            lila = st.number_input("Lingkar Lengan Atas / LiLA (cm)", min_value=8.0, max_value=20.0, value=14.0, step=0.5)
            cara_ukur = st.selectbox("Cara Ukur", ["Berdiri", "Terlentang"])

        with col3:
            st.subheader("Data Z-Score & KMS")
            zs_bbu = st.number_input("Z-Score Berat/Umur (ZS BB/U)", min_value=-5.0, max_value=5.0, value=0.0, step=0.1)
            zs_bbtb = st.number_input("Z-Score Berat/Tinggi (ZS BB/TB)", min_value=-5.0, max_value=5.0, value=0.0, step=0.1)
            naik_bb = st.selectbox("Status Naik Berat Badan", ["Naik (T)", "Tidak Naik (N)", "Tetap/Lainnya"])

        submit_btn = st.form_submit_button("🔍 Analisis Risiko Stunting", use_container_width=True)

    if submit_btn:
        with st.spinner("Menganalisis data antropometri..."):
            # Feature Engineering sesuai pipeline di notebook
            jk_enc = 1 if "L" in jk else 0
            naik_enc = 2 if "Naik (T)" in naik_bb else (1 if "Tidak Naik" in naik_bb else 0)
            cara_enc = 1 if cara_ukur == "Berdiri" else 0
            bmi = berat / ((tinggi / 100) ** 2)
            
            # Simulasi velocity (karena tidak ada riwayat, diset 0 sesuai fungsi di notebook)
            vel_berat = 0.0
            vel_tinggi = 0.0

            # Susun array sesuai dengan all_feature_cols dari metadata
            input_dict = {
                'usia_bulan': usia, 'jk_enc': jk_enc,
                'BB Lahir': bb_lahir, 'TB Lahir': tb_lahir,
                'Berat': berat, 'Tinggi': tinggi, 'LiLA': lila,
                'ZS BB/U': zs_bbu, 'ZS BB/TB': zs_bbtb,
                'bmi': bmi, 'naik_bb_enc': naik_enc, 'cara_ukur_enc': cara_enc,
                'velocity_berat': vel_berat, 'velocity_tinggi': vel_tinggi
            }

            # Urutkan fitur sesuai training
            full_features = [input_dict[col] for col in metadata['all_feature_cols']]
            X_full = np.array(full_features).reshape(1, -1)
            X_scaled = scaler.transform(X_full)

            # Pilih fitur yang terseleksi
            selected_features_cols = metadata['feature_cols']
            sel_idx = [metadata['all_feature_cols'].index(f) for f in selected_features_cols]
            X_model = X_scaled[:, sel_idx]

            pred_enc = model.predict(X_model)[0]
            pred_proba = model.predict_proba(X_model)[0]
            pred_class = le.inverse_transform([pred_enc])[0]

            # Menampilkan Hasil
            st.divider()
            st.subheader("📋 Hasil Analisis")
            
            # UI Berdasarkan Kelas
            colors = {"Normal": "success", "Risiko Stunting Ringan": "warning", 
                      "Risiko Stunting Sedang": "error", "Risiko Stunting Tinggi": "error"}
            
            if "Normal" in pred_class:
                st.success(f"### ✅ {pred_class}\nPertumbuhan anak berada dalam rentang normal. Tetap pantau gizi dan jadwal Posyandu.")
            elif "Ringan" in pred_class:
                st.warning(f"### ⚠️ {pred_class}\nTerdapat indikasi awal perlambatan pertumbuhan. Perlu evaluasi asupan gizi.")
            else:
                st.error(f"### 🚨 {pred_class}\nRisiko signifikan terdeteksi! Disarankan untuk segera melakukan konsultasi dengan tenaga medis/ahli gizi.")

            # Menampilkan Probabilitas
            st.write("**Tingkat Probabilitas (Kepercayaan Model):**")
            prob_df = pd.DataFrame({
                "Kelas Risiko": le.classes_,
                "Probabilitas": pred_proba
            }).sort_values(by="Probabilitas", ascending=False)
            
            st.bar_chart(prob_df, x="Kelas Risiko", y="Probabilitas", color="#3498DB")

# ==========================================
# 3. HALAMAN 2: HASIL PENGEMBANGAN MODEL
# ==========================================
def page_hasil():
    st.title("📊 Hasil Pengembangan & Evaluasi Model")
    st.markdown("Halaman ini menampilkan metrik performa dari model Machine Learning yang telah dilatih.")

    if not metadata:
        st.warning("Data metadata.json tidak ditemukan.")
        return

    # Top Metrics
    st.subheader(f"🏆 Model Terpilih: {metadata.get('model_name', 'Unknown')}")
    metrics = metadata.get('metrics', {})
    
    col1, col2, col3, col4 = st.columns(4)
    col1.metric("Akurasi Keseluruhan", f"{metrics.get('accuracy', 0) * 100:.2f}%")
    col2.metric("Balanced Accuracy", f"{metrics.get('balanced_accuracy', 0) * 100:.2f}%")
    col3.metric("F1 Score (Macro)", f"{metrics.get('f1_macro', 0):.4f}")
    col4.metric("Jumlah Fitur Dipakai", f"{len(metadata.get('feature_cols', []))}")

    st.divider()

    col_a, col_b = st.columns(2)
    with col_a:
        st.subheader("Fitur Paling Berpengaruh (Top Features)")
        st.write("Fitur-fitur ini dipilih menggunakan metode seleksi *Mutual Information* pada saat pelatihan:")
        for idx, feat in enumerate(metadata.get('feature_cols', [])):
            st.markdown(f"{idx+1}. **{feat}**")
            
    with col_b:
        st.subheader("Informasi Pelatihan")
        st.info(f"""
        - **Metode Handling Imbalance**: SMOTE (Synthetic Minority Oversampling Technique)
        - **Random State**: {metadata.get('random_state', 42)}
        - **Threshold Seleksi Fitur (MI)**: {metadata.get('mi_threshold', 0.005)}
        - **Kelas Tersedia**: {', '.join(metadata.get('class_names', []))}
        """)

    # Instruksi Menampilkan Grafik (Opsional jika gambar diexport)
    st.markdown("---")
    st.markdown("*(Catatan: Jika Anda menyimpan gambar grafik EDA/Confusion Matrix di folder `model_artifacts` melalui notebook, Anda bisa menambahkannya di sini menggunakan `st.image('path_ke_gambar.png')`)*")

# ==========================================
# 4. NAVIGASI SIDEBAR
# ==========================================
st.sidebar.title("Navigasi Menu")
pilihan = st.sidebar.radio("Pilih Halaman:", ["🔍 Pendeteksi Stunting", "📊 Hasil Pengembangan Model"])

st.sidebar.markdown("---")
st.sidebar.caption("Sistem Berbasis Web untuk Pendeteksi Dini Stunting")

# Routing
if pilihan == "🔍 Pendeteksi Stunting":
    page_deteksi()
else:
    page_hasil()