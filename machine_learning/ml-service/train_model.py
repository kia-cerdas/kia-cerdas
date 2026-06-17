# -*- coding: utf-8 -*-
"""
================================================================
STUNTING AI - SISTEM PREDIKSI RISIKO STUNTING
================================================================
Proyek Machine Learning - Institut Teknologi Del
Mata Kuliah  : 4143104 - Pembelajaran Mesin
Domain       : Kesehatan Anak
Topik ML     : Klasifikasi
Dataset      : raw_dataset.csv

Cara menjalankan script ini:
    python train_model.py

Output:
    stunting_model_rf.pkl
    stunting_model_xgb.pkl
    stunting_model.pkl
    scaler_stunting.pkl
    feature_cols.pkl
    feature_importances.pkl

    feature_importance.png
    confusion_matrix.png
    distribusi_kelas.png
================================================================
"""

import json
import os
import sys
import warnings

import joblib
import matplotlib
matplotlib.use('Agg')

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns
import xgboost as xgb

from imblearn.over_sampling import RandomOverSampler, SMOTE
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import (
    accuracy_score,
    classification_report,
    confusion_matrix,
    f1_score,
    precision_score,
    recall_score,
    roc_auc_score,
)
from sklearn.model_selection import (
    GridSearchCV,
    StratifiedKFold,
    cross_val_score,
    train_test_split,
)
from sklearn.preprocessing import StandardScaler

warnings.filterwarnings("ignore")

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
if hasattr(sys.stderr, "reconfigure"):
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")

print("=" * 70)
print("  STUNTING AI - PELATIHAN MODEL PREDIKSI RISIKO STUNTING")
print("=" * 70)

# ================================================================
# CONFIGURATION
# ================================================================
DATASET_PATH = "raw_dataset.csv"

MODEL_DIR = "./models"
os.makedirs(MODEL_DIR, exist_ok=True)

REPORT_PATH = os.path.join(MODEL_DIR, "training_report.json")

FEATURE_IMPORTANCE_PATH = os.path.join(
    MODEL_DIR,
    "feature_importance.png"
)

CONFUSION_MATRIX_PATH = os.path.join(
    MODEL_DIR,
    "confusion_matrix.png"
)

CLASS_DISTRIBUTION_PATH = os.path.join(
    MODEL_DIR,
    "distribusi_kelas.png"
)

# ================================================================
# HELPER FUNCTIONS
# ================================================================

def parse_age(age_str):
    if pd.isna(age_str):
        return 0

    text = str(age_str)
    tahun = 0
    bulan = 0

    try:
        if "Tahun" in text:
            tahun = int(text.split("Tahun")[0].strip())

        if "Bulan" in text:
            bulan_part = text.split("Bulan")[0]
            bulan = int(bulan_part.split("-")[-1].strip())

    except Exception:
        return 0

    return (tahun * 12) + bulan


def encode_gender(value):
    value = str(value).strip().upper()

    if value == "L":
        return 1

    if value == "P":
        return 0

    return np.nan


def evaluate_model(model, x_test, y_test):
    y_pred = model.predict(x_test)
    y_prob = model.predict_proba(x_test)[:, 1]

    return {
        "accuracy": accuracy_score(y_test, y_pred),
        "roc_auc": roc_auc_score(y_test, y_prob),
        "precision": precision_score(
            y_test,
            y_pred,
            zero_division=0
        ),
        "recall": recall_score(
            y_test,
            y_pred,
            zero_division=0
        ),
        "f1": f1_score(
            y_test,
            y_pred,
            zero_division=0
        ),
        "classification_report": classification_report(
            y_test,
            y_pred,
            target_names=["NORMAL", "STUNTING"],
            zero_division=0
        ),
        "confusion_matrix": confusion_matrix(
            y_test,
            y_pred
        ),
        "y_pred": y_pred,
    }


# ================================================================
# 1. MEMUAT DATASET
# ================================================================
print("\n[1/8] Memuat dataset...")

df = pd.read_csv(DATASET_PATH)
df.columns = df.columns.str.strip()

print(f"  ✅ Dataset: {df.shape[0]:,} baris, {df.shape[1]} kolom")

# ================================================================
# 2. DATA PREPROCESSING
# ================================================================
print("\n[2/8] Preprocessing data...")

numeric_cols = [
    "BB Lahir",
    "TB Lahir",
    "Berat",
    "Tinggi",
    "LiLA",
    "ZS BB/U",
    "ZS TB/U",
    "ZS BB/TB",
]

for column in numeric_cols:
    if column in df.columns:
        df[column] = pd.to_numeric(
            df[column],
            errors="coerce"
        )

df["JK_Binary"] = df["JK"].apply(encode_gender)

df["Usia_Bulan"] = df["Usia Saat Ukur"].apply(
    parse_age
)

required_columns = [
    "BB Lahir",
    "TB Lahir",
    "Berat",
    "Tinggi",
    "LiLA",
    "ZS TB/U",
    "JK_Binary",
    "Usia_Bulan",
]

before_drop = len(df)

df = df.dropna(subset=required_columns)

print(
    f"  Missing values dibuang: "
    f"{before_drop - len(df)} baris"
)

# Outlier filtering
df = df[
    (df["Berat"] >= 1)
    & (df["Berat"] <= 40)
    & (df["Tinggi"] >= 30)
    & (df["Tinggi"] <= 130)
    & (df["LiLA"] >= 5)
    & (df["LiLA"] <= 30)
].copy()

print(f"  ✅ Missing setelah preprocessing: {df.isnull().sum().sum()}")
print(f"  ✅ Total data setelah filtering: {len(df):,}")

# ================================================================
# 3. TARGET ENGINEERING
# ================================================================
print("\n[3/8] Membentuk target label stunting...")

df["STUNTING"] = (
    df["ZS TB/U"] < -2
).astype(int)

target_counts = df["STUNTING"].value_counts().sort_index()

print("\n  Distribusi kelas stunting:")

for lbl, cnt in target_counts.items():

    label_name = (
        "NORMAL"
        if lbl == 0
        else "STUNTING"
    )

    print(
        f"    {label_name:<15}: "
        f"{cnt:,} "
        f"({cnt/len(df)*100:.1f}%)"
    )

# ================================================================
# 4. FEATURE ENGINEERING
# ================================================================
print("\n[4/8] Feature engineering...")

df["BMI"] = (
    df["Berat"] /
    ((df["Tinggi"] / 100) ** 2)
)

df["BB_TB_Ratio"] = (
    df["Berat"] / df["Tinggi"]
)

df["Growth_Height"] = (
    df["Tinggi"] - df["TB Lahir"]
)

df["Growth_Weight"] = (
    df["Berat"] - df["BB Lahir"]
)

df["Underweight"] = (
    df["ZS BB/U"] < -2
).astype(int)

df["Wasting"] = (
    df["ZS BB/TB"] < -2
).astype(int)

df["Short_Birth"] = (
    df["TB Lahir"] < 48
).astype(int)

df["Low_Birth_Weight"] = (
    df["BB Lahir"] < 2.5
).astype(int)

feature_cols = [
    "BB Lahir",
    "TB Lahir",
    "Berat",
    "Tinggi",
    "LiLA",
    "Usia_Bulan",
    "JK_Binary",
    "BMI",
    "BB_TB_Ratio",
    "Growth_Height",
    "Growth_Weight",
    "Underweight",
    "Wasting",
    "Short_Birth",
    "Low_Birth_Weight",
]

X = df[feature_cols].fillna(0)
y = df["STUNTING"]

print(f"  ✅ Total fitur: {len(feature_cols)}")

# ================================================================
# 5. TRAIN/TEST SPLIT & OVERSAMPLING
# ================================================================
print("\n[5/8] Split data dan penanganan class imbalance...")

X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.2,
    random_state=42,
    stratify=y
)

print(
    f"  Train: {X_train.shape[0]:,} "
    f"| Test: {X_test.shape[0]:,}"
)

scaler = StandardScaler()

X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

minority_count = int(
    y_train.value_counts().min()
)

if minority_count > 1:
    sampler = SMOTE(
        random_state=42,
        k_neighbors=min(
            1,
            minority_count - 1
        )
    )
else:
    sampler = RandomOverSampler(
        random_state=42
    )

X_train_bal, y_train_bal = sampler.fit_resample(
    X_train_scaled,
    y_train
)

print(
    f"  Setelah oversampling: "
    f"{pd.Series(y_train_bal).value_counts().to_dict()}"
)

# ================================================================
# 6. PELATIHAN MODEL — SEBELUM TUNING
# ================================================================
print("\n[6/8] Melatih model (sebelum tuning)...")

rf_default = RandomForestClassifier(
    n_estimators=200,
    random_state=42,
    class_weight='balanced'
)

xgb_default = xgb.XGBClassifier(
    n_estimators=200,
    max_depth=4,
    learning_rate=0.05,
    subsample=0.8,
    colsample_bytree=0.8,
    objective='binary:logistic',
    eval_metric='logloss',
    random_state=42
)

rf_default.fit(
    X_train_bal,
    y_train_bal
)

xgb_default.fit(
    X_train_bal,
    y_train_bal
)

rf_before = evaluate_model(
    rf_default,
    X_test_scaled,
    y_test
)

xgb_before = evaluate_model(
    xgb_default,
    X_test_scaled,
    y_test
)

print(
    f"  RF sebelum tuning : "
    f"Akurasi = {rf_before['accuracy']:.4f}"
)

print(
    f"  XGB sebelum tuning: "
    f"Akurasi = {xgb_before['accuracy']:.4f}"
)

# ================================================================
# 7. HYPERPARAMETER TUNING — GridSearchCV
# ================================================================
print("\n[7/8] Hyperparameter Tuning (GridSearchCV 5-fold CV)...")

cv5 = StratifiedKFold(
    n_splits=5,
    shuffle=True,
    random_state=42
)

# ---------------- RANDOM FOREST ----------------
print("  >> Tuning Random Forest...")

rf_param_grid = {
    'n_estimators': [100, 200],
    'max_depth': [None, 6],
    'min_samples_split': [2, 4],
    'min_samples_leaf': [1, 2],
}

rf_grid = GridSearchCV(
    RandomForestClassifier(
        random_state=42,
        class_weight='balanced'
    ),
    param_grid=rf_param_grid,
    cv=cv5,
    scoring='f1',
    n_jobs=-1,
    verbose=0
)

rf_grid.fit(
    X_train_bal,
    y_train_bal
)

print(f"  ✅ RF best params : {rf_grid.best_params_}")
print(f"  ✅ RF best CV F1  : {rf_grid.best_score_:.4f}")

# ---------------- XGBOOST ----------------
print("  >> Tuning XGBoost...")

xgb_param_grid = {
    'n_estimators': [100, 200],
    'max_depth': [3, 4],
    'learning_rate': [0.03, 0.1],
    'subsample': [0.8, 1.0],
    'colsample_bytree': [0.8, 1.0],
}

xgb_grid = GridSearchCV(
    xgb.XGBClassifier(
        objective='binary:logistic',
        eval_metric='logloss',
        random_state=42
    ),
    param_grid=xgb_param_grid,
    cv=cv5,
    scoring='f1',
    n_jobs=-1,
    verbose=0
)

xgb_grid.fit(
    X_train_bal,
    y_train_bal
)

print(f"  ✅ XGB best params: {xgb_grid.best_params_}")
print(f"  ✅ XGB best CV F1 : {xgb_grid.best_score_:.4f}")

rf_best = rf_grid.best_estimator_
xgb_best = xgb_grid.best_estimator_

# ================================================================
# 8. EVALUASI MODEL — SETELAH TUNING
# ================================================================
print("\n[8/8] Evaluasi model final...")

rf_metrics = evaluate_model(
    rf_best,
    X_test_scaled,
    y_test
)

xgb_metrics = evaluate_model(
    xgb_best,
    X_test_scaled,
    y_test
)

# ---------------- RANDOM FOREST ----------------
print("\n  " + "=" * 56)
print("  🔹 RANDOM FOREST PERFORMANCE (Setelah Tuning)")
print("  " + "=" * 56)

print(
    f"  Akurasi  : "
    f"{rf_metrics['accuracy']:.4f} "
    f"({rf_metrics['accuracy']*100:.2f}%)"
)

print(
    f"  ROC AUC  : "
    f"{rf_metrics['roc_auc']:.4f}"
)

print(
    f"  F1 Score : "
    f"{rf_metrics['f1']:.4f}"
)

print(
    rf_metrics["classification_report"]
)

cv_scores_rf = cross_val_score(
    rf_best,
    X,
    y,
    cv=cv5,
    scoring='accuracy',
    n_jobs=-1
)

print(
    f"  Cross-Val (5-fold): "
    f"{cv_scores_rf.mean():.4f} "
    f"± {cv_scores_rf.std():.4f}"
)

# ---------------- XGBOOST ----------------
print("\n  " + "=" * 56)
print("  🔹 XGBOOST PERFORMANCE (Setelah Tuning)")
print("  " + "=" * 56)

print(
    f"  Akurasi  : "
    f"{xgb_metrics['accuracy']:.4f} "
    f"({xgb_metrics['accuracy']*100:.2f}%)"
)

print(
    f"  ROC AUC  : "
    f"{xgb_metrics['roc_auc']:.4f}"
)

print(
    f"  F1 Score : "
    f"{xgb_metrics['f1']:.4f}"
)

print(
    xgb_metrics["classification_report"]
)

# ================================================================
# PERBANDINGAN
# ================================================================
print("\n  Perbandingan sebelum & sesudah tuning:")

print(
    f"  {'Model':<30} "
    f"{'Sebelum':>10} "
    f"{'Sesudah':>10} "
    f"{'Delta':>8}"
)

print(f"  {'-' * 58}")

print(
    f"  {'Random Forest':<30} "
    f"{rf_before['accuracy']:>10.4f} "
    f"{rf_metrics['accuracy']:>10.4f} "
    f"{rf_metrics['accuracy'] - rf_before['accuracy']:>+8.4f}"
)

print(
    f"  {'XGBoost':<30} "
    f"{xgb_before['accuracy']:>10.4f} "
    f"{xgb_metrics['accuracy']:>10.4f} "
    f"{xgb_metrics['accuracy'] - xgb_before['accuracy']:>+8.4f}"
)

# ================================================================
# FEATURE IMPORTANCE
# ================================================================
best_model = (
    rf_best
    if rf_metrics['f1'] >= xgb_metrics['f1']
    else xgb_best
)

best_model_name = (
    "Random Forest"
    if rf_metrics['f1'] >= xgb_metrics['f1']
    else "XGBoost"
)

importance_df = pd.DataFrame({
    'Fitur': feature_cols,
    'Importance': best_model.feature_importances_
}).sort_values(
    'Importance',
    ascending=False
)

print("\n  Top 10 Feature Importance:")

for _, row in importance_df.head(10).iterrows():

    bar = '█' * int(row['Importance'] * 200)

    print(
        f"    {row['Fitur']:35s} "
        f"{row['Importance']:.4f}  {bar}"
    )

# ================================================================
# VISUALISASI
# ================================================================

# Feature Importance
plt.figure(figsize=(12, 8))

sns.barplot(
    data=importance_df.head(15),
    x='Importance',
    y='Fitur',
    palette='viridis'
)

plt.title(
    f'Top 15 Feature Importance – {best_model_name}',
    fontsize=14,
    fontweight='bold'
)

plt.xlabel('Importance Score')

plt.tight_layout()

plt.savefig(
    FEATURE_IMPORTANCE_PATH,
    dpi=150,
    bbox_inches='tight'
)

plt.close()

# Confusion Matrix
fig, axes = plt.subplots(
    1,
    2,
    figsize=(14, 5)
)

for ax, (title, y_pred) in zip(
    axes,
    [
        ('Random Forest', rf_metrics['y_pred']),
        ('XGBoost', xgb_metrics['y_pred'])
    ]
):

    cm = confusion_matrix(
        y_test,
        y_pred
    )

    sns.heatmap(
        cm,
        annot=True,
        fmt='d',
        cmap='Blues',
        ax=ax,
        xticklabels=['NORMAL', 'STUNTING'],
        yticklabels=['NORMAL', 'STUNTING']
    )

    ax.set_title(
        f'Confusion Matrix – {title}',
        fontweight='bold'
    )

    ax.set_xlabel('Predicted')
    ax.set_ylabel('Actual')

    plt.setp(
        ax.get_xticklabels(),
        rotation=30,
        ha='right'
    )

plt.tight_layout()

plt.savefig(
    CONFUSION_MATRIX_PATH,
    dpi=150,
    bbox_inches='tight'
)

plt.close()

# Distribusi kelas
plt.figure(figsize=(8, 5))

counts = df['STUNTING'].value_counts().sort_index()

bars = plt.bar(
    ['NORMAL', 'STUNTING'],
    counts.values,
    color=['#28a745', '#dc3545']
)

for bar, val in zip(bars, counts.values):

    plt.text(
        bar.get_x() + bar.get_width()/2,
        bar.get_height() + 30,
        f'{val:,}\n({val/len(df)*100:.1f}%)',
        ha='center',
        fontsize=9
    )

plt.title(
    'Distribusi Kelas Risiko Stunting',
    fontsize=13,
    fontweight='bold'
)

plt.xlabel('Kategori Risiko')
plt.ylabel('Jumlah Pasien')

plt.xticks(
    rotation=20,
    ha='right'
)

plt.tight_layout()

plt.savefig(
    CLASS_DISTRIBUTION_PATH,
    dpi=150,
    bbox_inches='tight'
)

plt.close()

# ================================================================
# SIMPAN MODEL
# ================================================================
joblib.dump(
    rf_best,
    os.path.join(
        MODEL_DIR,
        'stunting_model_rf.pkl'
    )
)

joblib.dump(
    xgb_best,
    os.path.join(
        MODEL_DIR,
        'stunting_model_xgb.pkl'
    )
)

joblib.dump(
    best_model,
    os.path.join(
        MODEL_DIR,
        'stunting_model.pkl'
    )
)

joblib.dump(
    scaler,
    os.path.join(
        MODEL_DIR,
        'scaler_stunting.pkl'
    )
)

joblib.dump(
    feature_cols,
    os.path.join(
        MODEL_DIR,
        'feature_cols.pkl'
    )
)

joblib.dump(
    importance_df,
    os.path.join(
        MODEL_DIR,
        'feature_importances.pkl'
    )
)

# ================================================================
# SIMPAN REPORT JSON
# ================================================================
report = {
    "best_model": best_model_name,
    "rf_accuracy": rf_metrics['accuracy'],
    "xgb_accuracy": xgb_metrics['accuracy'],
    "rf_f1": rf_metrics['f1'],
    "xgb_f1": xgb_metrics['f1'],
    "rf_best_params": rf_grid.best_params_,
    "xgb_best_params": xgb_grid.best_params_,
}

with open(REPORT_PATH, "w") as f:
    json.dump(
        report,
        f,
        indent=4
    )

print("\n  ✅ Semua model dan artefak tersimpan!")

# ================================================================
# RINGKASAN AKHIR
# ================================================================
print("\n" + "=" * 70)
print("  ✅ TRAINING SELESAI – RINGKASAN HASIL")
print("=" * 70)

print(
    f"  Dataset : raw_dataset.csv "
    f"({len(df):,} pasien)"
)

print(
    f"  Fitur   : "
    f"{len(feature_cols)} fitur klinis"
)

print(
    "  Kelas   : "
    "2 (NORMAL | STUNTING)"
)

print()

print(
    f"  🏆 Random Forest → "
    f"Akurasi: {rf_metrics['accuracy']:.4f} "
    f"({rf_metrics['accuracy']*100:.2f}%) "
    f"F1: {rf_metrics['f1']:.4f}"
)

print(
    f"  🏆 XGBoost       → "
    f"Akurasi: {xgb_metrics['accuracy']:.4f} "
    f"({xgb_metrics['accuracy']*100:.2f}%) "
    f"F1: {xgb_metrics['f1']:.4f}"
)

print()

if (
    rf_metrics['accuracy'] >= 0.80 and
    xgb_metrics['accuracy'] >= 0.80
):
    print(
        "  ✅ TARGET AKURASI > 0.80 "
        "TERCAPAI UNTUK KEDUA MODEL!"
    )

else:

    print(
        f"  RF > 0.80 : "
        f"{rf_metrics['accuracy'] >= 0.80} "
        f"| XGB > 0.80 : "
        f"{xgb_metrics['accuracy'] >= 0.80}"
    )

print()
print("  Langkah selanjutnya:")
print("    streamlit run streamlit_app.py")

print("=" * 70)