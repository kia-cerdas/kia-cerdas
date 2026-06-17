import json
import os

import joblib
import numpy as np
import pandas as pd
import streamlit as st


BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_DIR = os.path.join(BASE_DIR, "models")
DATASET_PATH = os.path.join(BASE_DIR, "Dataset ML.csv")
MODEL_PATH = os.path.join(MODEL_DIR, "stunting_model_latest.pkl")
SCALER_PATH = os.path.join(MODEL_DIR, "scaler_latest.pkl")
FEATURES_PATH = os.path.join(MODEL_DIR, "features_latest.pkl")
REPORT_PATH = os.path.join(MODEL_DIR, "training_report.json")


st.set_page_config(
    page_title="Stunting ML Dashboard",
    page_icon="📊",
    layout="wide",
)


@st.cache_resource
def load_artifacts():
    model = joblib.load(MODEL_PATH)
    scaler = joblib.load(SCALER_PATH)
    feature_names = joblib.load(FEATURES_PATH)

    report = {}
    if os.path.exists(REPORT_PATH):
        with open(REPORT_PATH, "r", encoding="utf-8") as report_file:
            report = json.load(report_file)

    return model, scaler, feature_names, report


@st.cache_data
def load_dataset():
    dataset = pd.read_csv(DATASET_PATH, sep=";")
    dataset.columns = dataset.columns.str.strip()
    return dataset


def parse_age(age_str):
    if pd.isna(age_str):
        return 0

    age_str = str(age_str)
    tahun = 0
    bulan = 0

    try:
        if "Tahun" in age_str:
            tahun = int(age_str.split("Tahun")[0].strip())
        if "Bulan" in age_str:
            bulan_part = age_str.split("Bulan")[0]
            bulan = int(bulan_part.split("-")[-1].strip())
    except Exception:
        return 0

    return (tahun * 12) + bulan


def build_feature_vector(bb_lahir, tb_lahir, bb, tb, lila, umur, gender):
    bmi = bb / ((tb / 100) ** 2)
    bb_tb_ratio = bb / tb
    growth_height = tb - tb_lahir
    growth_weight = bb - bb_lahir
    gender_binary = 1 if gender == "Laki-laki" else 0

    feature_value_map = {
        "BB Lahir": bb_lahir,
        "TB Lahir": tb_lahir,
        "Berat": bb,
        "Tinggi": tb,
        "LiLA": lila,
        "Usia_Bulan": umur,
        "JK_Binary": gender_binary,
        "BMI": bmi,
        "BB_TB_Ratio": bb_tb_ratio,
        "Growth_Height": growth_height,
        "Growth_Weight": growth_weight,
    }

    feature_row = [float(feature_value_map.get(feature_name, 0)) for feature_name in FEATURE_NAMES]
    feature_summary = {
        "BMI": round(bmi, 2),
        "BB_TB_Ratio": round(bb_tb_ratio, 4),
        "Growth_Height": round(growth_height, 2),
        "Growth_Weight": round(growth_weight, 2),
        "JK_Binary": gender_binary,
    }
    return pd.DataFrame([feature_row], columns=FEATURE_NAMES), feature_summary


def classify_stunting(risk_percentage):
    if risk_percentage >= 70:
        return "STUNTING", "RISIKO TINGGI STUNTING. Segera konsultasi ke dokter atau ahli gizi.", "Sangat Pendek"
    if risk_percentage >= 40:
        return "AT_RISK", "RISIKO SEDANG. Perlu pemantauan rutin dan edukasi nutrisi.", "Pendek"
    return "NORMAL", "Pertumbuhan anak normal. Lanjutkan pola makan sehat dan pemantauan rutin.", "Normal"


def format_metric_table(dataframe):
    display_df = dataframe.copy()

    def format_value(value):
        if value is None:
            return "-"
        if isinstance(value, (int, float, np.floating, np.integer)):
            return f"{value:.4f}"
        return value

    return display_df.apply(lambda column: column.map(format_value))


MODEL, SCALER, FEATURE_NAMES, REPORT = load_artifacts()
DATASET = load_dataset()

st.markdown(
    """
    <style>
        .block-container { padding-top: 1.5rem; }
        .hero {
            padding: 1.4rem 1.6rem;
            border-radius: 1.25rem;
            background: linear-gradient(135deg, #102A43 0%, #1F3A5F 55%, #F4A261 100%);
            color: white;
            box-shadow: 0 18px 50px rgba(16, 42, 67, 0.25);
        }
        .hero h1 { margin: 0; font-size: 2.1rem; }
        .hero p { margin: 0.45rem 0 0 0; opacity: 0.92; }
        .metric-card {
            padding: 1rem 1.1rem;
            border-radius: 1rem;
            background: white;
            border: 1px solid rgba(16, 42, 67, 0.08);
            box-shadow: 0 10px 25px rgba(16, 42, 67, 0.06);
        }
    </style>
    """,
    unsafe_allow_html=True,
)

st.markdown(
    "<div class='hero'><h1>Stunting ML Dashboard</h1><p>Ringkasan hasil training, perbandingan tuning, dan prediksi interaktif dalam satu tampilan.</p></div>",
    unsafe_allow_html=True,
)

dataset_rows = len(DATASET)
dataset_features = len(FEATURE_NAMES)
stunting_count = int((DATASET["ZS TB/U"] < -2).sum()) if "ZS TB/U" in DATASET.columns else 0
normal_count = dataset_rows - stunting_count

col1, col2, col3, col4 = st.columns(4)
col1.metric("Baris data", f"{dataset_rows:,}")
col2.metric("Fitur relevan", dataset_features)
col3.metric("Label stunting", f"{stunting_count:,}")
col4.metric("Label normal", f"{normal_count:,}")

st.divider()

left, right = st.columns([1.05, 0.95])

with left:
    st.subheader("Prediksi Interaktif")
    bb_lahir = st.number_input("Berat badan lahir (kg)", min_value=1.0, max_value=6.0, value=3.1, step=0.1)
    tb_lahir = st.number_input("Tinggi badan lahir (cm)", min_value=30.0, max_value=60.0, value=49.0, step=0.5)
    bb = st.number_input("Berat badan saat ukur (kg)", min_value=0.0, max_value=50.0, value=10.5, step=0.1)
    tb = st.number_input("Tinggi badan saat ukur (cm)", min_value=0.0, max_value=150.0, value=78.0, step=0.5)
    lila = st.number_input("LiLA (cm)", min_value=0.0, max_value=35.0, value=13.5, step=0.1)
    umur = st.slider("Umur (bulan)", min_value=0, max_value=60, value=24)

    gender = st.radio("Jenis kelamin", ["Laki-laki", "Perempuan"], horizontal=True)

    if st.button("Jalankan Prediksi", type="primary", use_container_width=True):
        features, feature_summary = build_feature_vector(bb_lahir, tb_lahir, bb, tb, lila, umur, gender)
        features_scaled = SCALER.transform(features)
        prediction_proba = MODEL.predict_proba(features_scaled)[0]
        stunting_probability = float(prediction_proba[1])
        risk_percent = stunting_probability * 100
        confidence = max(prediction_proba) * 100
        classification, recommendation, status = classify_stunting(risk_percent)

        result_col1, result_col2, result_col3 = st.columns(3)
        result_col1.metric("Risiko stunting", f"{risk_percent:.2f}%")
        result_col2.metric("Klasifikasi", classification)
        result_col3.metric("Confidence", f"{confidence:.2f}%")

        st.success(f"Status TB/U: {status}")
        st.info(recommendation)

        st.json(
            {
                "input": {
                    "bb_lahir": bb_lahir,
                    "tb_lahir": tb_lahir,
                    "bb": bb,
                    "tb": tb,
                    "lila": lila,
                    "umur": umur,
                    "jenis_kelamin": gender,
                },
                "feature_summary": feature_summary,
                "risk_percentage": round(risk_percent, 2),
                "classification": classification,
                "confidence": round(confidence, 2),
            }
        )

with right:
    st.subheader("Hasil Training")
    if REPORT:
        baseline = REPORT.get("baseline", {})
        tuned = REPORT.get("tuned", {})
        comparison_baseline = pd.DataFrame(
            {
                "Random Forest": [
                    baseline.get("random_forest", {}).get("accuracy"),
                    baseline.get("random_forest", {}).get("roc_auc"),
                    baseline.get("random_forest", {}).get("precision"),
                    baseline.get("random_forest", {}).get("recall"),
                    baseline.get("random_forest", {}).get("f1"),
                ],
                "XGBoost": [
                    baseline.get("xgboost", {}).get("accuracy"),
                    baseline.get("xgboost", {}).get("roc_auc"),
                    baseline.get("xgboost", {}).get("precision"),
                    baseline.get("xgboost", {}).get("recall"),
                    baseline.get("xgboost", {}).get("f1"),
                ],
            },
            index=["Accuracy", "ROC AUC", "Precision", "Recall", "F1"],
        )
        comparison_tuned = pd.DataFrame(
            {
                "Random Forest": [
                    tuned.get("random_forest", {}).get("accuracy"),
                    tuned.get("random_forest", {}).get("roc_auc"),
                    tuned.get("random_forest", {}).get("precision"),
                    tuned.get("random_forest", {}).get("recall"),
                    tuned.get("random_forest", {}).get("f1"),
                ],
                "XGBoost": [
                    tuned.get("xgboost", {}).get("accuracy"),
                    tuned.get("xgboost", {}).get("roc_auc"),
                    tuned.get("xgboost", {}).get("precision"),
                    tuned.get("xgboost", {}).get("recall"),
                    tuned.get("xgboost", {}).get("f1"),
                ],
            },
            index=["Accuracy", "ROC AUC", "Precision", "Recall", "F1"],
        )
        st.markdown("**Before tuning**")
        st.dataframe(format_metric_table(comparison_baseline), width="stretch")
        st.markdown("**After tuning (GridSearchCV)**")
        st.dataframe(format_metric_table(comparison_tuned), width="stretch")
        st.caption("Gunakan tabel di atas untuk menunjukkan perbandingan baseline vs hasil tuning pada Random Forest dan XGBoost.")

        best_model = REPORT.get("best_model", {})
        st.caption(f"Best model: {best_model.get('name', '-')}")
        st.caption("Best parameters dari model terbaik")
        st.json(best_model.get("best_params", {}))
        st.caption(f"Best test metrics F1: {best_model.get('metrics', {}).get('f1', 0):.4f}")
    else:
        st.warning("training_report.json tidak ditemukan.")

    st.subheader("Ringkasan Dataset")
    summary_df = pd.DataFrame(
        {
            "Metric": ["Rows", "Columns", "Stunting", "Normal"],
            "Value": [dataset_rows, DATASET.shape[1], stunting_count, normal_count],
        }
    )
    st.dataframe(summary_df, width="stretch", hide_index=True)

    with st.expander("Lihat 5 baris data awal"):
        st.dataframe(DATASET.head(), width="stretch")
