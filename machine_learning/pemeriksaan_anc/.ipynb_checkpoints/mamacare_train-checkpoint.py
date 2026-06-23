# -*- coding: utf-8 -*-
"""
================================================================
MAMACARE AI - SISTEM PREDIKSI RISIKO KEHAMILAN
================================================================
Proyek Machine Learning - Institut Teknologi Del
Mata Kuliah  : 4143104 - Pembelajaran Mesin
Dosen        : Oppir Hutapea, S.Tr.Kom., M.Kom
Domain       : Kesehatan (Maternal Health)
Topik ML     : Klasifikasi
Dataset      : dataset_anc_bumil.xlsx (10.000 baris)

Cara menjalankan script ini:
    python mamacare_train.py

Output:
    maternal_model_rf.pkl, maternal_model_lr.pkl, maternal_model.pkl
    scaler_maternal.pkl, feature_cols.pkl, label_map.pkl
    feature_importances.pkl, *.png (visualisasi)
================================================================
"""

import pandas as pd
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import seaborn as sns
import joblib
import warnings
warnings.filterwarnings('ignore')

from sklearn.model_selection import (
    train_test_split, cross_val_score, StratifiedKFold, GridSearchCV
)
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import (
    classification_report, accuracy_score, confusion_matrix, f1_score
)
from sklearn.utils import resample

print("=" * 70)
print("  MAMACARE AI – PELATIHAN MODEL PREDIKSI RISIKO KEHAMILAN")
print("=" * 70)

# ================================================================
# 1. MEMUAT DATASET
# ================================================================
print("\n[1/8] Memuat dataset...")
df = pd.read_excel('dataset_anc_bumil.xlsx')
print(f"  ✅ Dataset: {df.shape[0]:,} baris, {df.shape[1]} kolom")

# ================================================================
# 2. DATA PREPROCESSING
# ================================================================
print("\n[2/8] Preprocessing data...")

df['Tgl Lahir'] = pd.to_datetime(df['Tgl Lahir'], dayfirst=True, errors='coerce')
df['Usia_Ibu'] = df['Tgl Lahir'].apply(
    lambda x: (pd.Timestamp('2025-10-01') - x).days // 365 if pd.notnull(x) else 28
).clip(14, 55)

missing_fundus = df['Tinggi Fundus Uteri (cm)'].isnull().sum()
df['Tinggi Fundus Uteri (cm)'] = df.groupby('Trimester')['Tinggi Fundus Uteri (cm)'].transform(
    lambda x: x.fillna(x.median()))
df['Tindakan'] = df['Tindakan'].fillna('Normal')
print(f"  Imputasi Fundus Uteri: {missing_fundus} nilai menggunakan median per trimester")
print(f"  ✅ Missing setelah preprocessing: {df.isnull().sum().sum()}")

# ================================================================
# 3. TARGET ENGINEERING — RULE-BASED KLINIS
# ================================================================
print("\n[3/8] Membentuk target label risiko (rule-based klinis)...")

def compute_risk_label(row):
    """
    Label risiko berdasarkan panduan klinis maternal:
      0 = NORMAL
      1 = PERLU TINDAKAN (ada indikasi klinis intervensi)
      2 = PERLU RUJUKAN  (kondisi kritis, rujuk faskes lebih tinggi)
    """
    riwayat = str(row['Riwayat Penyakit']).strip().lower()
    hiv     = str(row['Tripel Eliminasi - HIV']).strip()
    sifilis = str(row['Tripel Eliminasi - Sifilis']).strip()

    # --- KELAS 2: PERLU RUJUKAN ---
    if row['TD Sistolik'] >= 160 or row['TD Diastolik'] >= 110:
        return 2   # Krisis hipertensi
    if row['Hemoglobin/Hb (g/dL)'] < 8.0:
        return 2   # Anemia berat
    if hiv == 'Reaktif' or sifilis == 'Reaktif':
        return 2   # Tripel eliminasi reaktif
    if riwayat in ('hipertensi', 'jantung', 'tb'):
        return 2   # Penyakit berat

    # --- SKOR TINDAKAN ---
    score = 0
    if row['TD Sistolik'] >= 140 or row['TD Diastolik'] >= 90:
        score += 3
    if row['TD Sistolik'] >= 120 or row['TD Diastolik'] >= 80:
        score += 1
    if row['Hemoglobin/Hb (g/dL)'] < 11.0:
        score += 2
    if str(row['Kategori LiLA']).strip() == 'Risiko KEK':
        score += 2
    if riwayat not in ('tidak ada', 'nan', ''):
        score += 2
    imt = row['IMT']
    if imt < 17.0 or imt >= 35.0:
        score += 2
    elif imt < 18.5 or imt >= 30.0:
        score += 1
    if row['Usia_Ibu'] < 19 or row['Usia_Ibu'] > 38:
        score += 1
    if row['Abortus'] >= 2:
        score += 1
    if row['Gravida'] >= 5:
        score += 1
    if row['Kunjungan ANC Ke-'] <= 1:
        score += 1

    # --- KELAS 1: PERLU TINDAKAN ---
    return 1 if score >= 4 else 0

df['RISIKO'] = df.apply(compute_risk_label, axis=1)
label_map = {0: 'NORMAL', 1: 'PERLU TINDAKAN', 2: 'PERLU RUJUKAN'}
df['RISIKO_LABEL'] = df['RISIKO'].map(label_map)
print("\n  Distribusi kelas risiko (rule-based klinis):")
for lbl, cnt in df['RISIKO_LABEL'].value_counts().items():
    print(f"    {lbl:<25}: {cnt:,} ({cnt/len(df)*100:.1f}%)")

# ================================================================
# 4. FEATURE ENGINEERING
# ================================================================
print("\n[4/8] Feature engineering...")

df['MAP']            = (df['TD Sistolik'] + 2 * df['TD Diastolik']) / 3
df['Pulse_Pressure'] = df['TD Sistolik'] - df['TD Diastolik']
df['Trimester_Num']  = df['Trimester'].map({'I': 1, 'II': 2, 'III': 3}).fillna(2)

df['Riwayat_Enc']  = (df['Riwayat Penyakit'].str.strip().str.lower() != 'tidak ada').astype(int)
df['Riwayat_Berat']= df['Riwayat Penyakit'].str.strip().str.lower().apply(
    lambda x: 1 if x in ('hipertensi', 'jantung', 'tb') else 0)
df['HIV_Rek']  = (df['Tripel Eliminasi - HIV'].str.strip() == 'Reaktif').astype(int)
df['Sif_Rek']  = (df['Tripel Eliminasi - Sifilis'].str.strip() == 'Reaktif').astype(int)
df['HepB_Rek'] = (df['Tripel Eliminasi - Hep B'].str.strip() == 'Reaktif').astype(int)
df['Tripel_Total'] = df['HIV_Rek'] + df['Sif_Rek'] + df['HepB_Rek']

df['KatIMT_Enc']  = df['Kategori IMT'].map({'Kurus':0,'Normal':1,'Gemuk':2,'Obesitas':3}).fillna(1)
df['KatLiLA_Enc'] = (df['Kategori LiLA'].str.strip() == 'Risiko KEK').astype(int)
df['KatTD_Enc']   = df['Kategori TD'].map({'Normal':0,'Pra-Hipertensi':1,'Hipertensi':2}).fillna(0)
df['KatHb_Enc']   = (df['Kategori Hb'].str.strip() == 'Anemia').astype(int)
df['Imunisasi_Enc'] = df['Status Imunisasi TD'].map({'T1':1,'T2':2,'T3':3,'T4':4,'T5':5}).fillna(3)

df['Usia_Risiko']   = ((df['Usia_Ibu'] < 19) | (df['Usia_Ibu'] > 38)).astype(int)
df['IMT_Kurus']     = (df['IMT'] < 18.5).astype(int)
df['IMT_Obese']     = (df['IMT'] >= 30.0).astype(int)
df['Anemia_Flag']   = (df['Hemoglobin/Hb (g/dL)'] < 11.0).astype(int)
df['Anemia_Berat']  = (df['Hemoglobin/Hb (g/dL)'] < 8.0).astype(int)
df['Hiper_Flag']    = (df['TD Sistolik'] >= 140).astype(int)
df['Hiper_Berat']   = (df['TD Sistolik'] >= 160).astype(int)
df['KEK_Flag']      = (df['LiLA (cm)'] < 23.5).astype(int)
df['Abortus_Tinggi']= (df['Abortus'] >= 2).astype(int)
df['Grandemulti']   = (df['Gravida'] >= 5).astype(int)

df['Risk_Score'] = (
    df['Anemia_Flag'] * 2 + df['Anemia_Berat'] * 3 +
    df['KatTD_Enc'] * 3  + df['Hiper_Berat'] * 5 +
    df['KEK_Flag'] * 2   + df['KatIMT_Enc'].apply(lambda x: 2 if x in [0, 3] else 0) +
    df['Riwayat_Enc'] * 2 + df['Riwayat_Berat'] * 3 +
    df['Tripel_Total'] + df['Usia_Risiko']
)

feature_cols = [
    'Usia_Ibu', 'Usia Kehamilan (minggu)', 'Trimester_Num',
    'Gravida', 'Para', 'Abortus',
    'IMT', 'LiLA (cm)', 'Tinggi Fundus Uteri (cm)',
    'TD Sistolik', 'TD Diastolik', 'MAP', 'Pulse_Pressure',
    'Hemoglobin/Hb (g/dL)', 'Kunjungan ANC Ke-',
    'KatIMT_Enc', 'KatLiLA_Enc', 'KatTD_Enc', 'KatHb_Enc',
    'Riwayat_Enc', 'Riwayat_Berat',
    'HIV_Rek', 'Sif_Rek', 'HepB_Rek', 'Tripel_Total',
    'Imunisasi_Enc',
    'Usia_Risiko', 'IMT_Kurus', 'IMT_Obese',
    'Anemia_Flag', 'Anemia_Berat',
    'Hiper_Flag', 'Hiper_Berat',
    'KEK_Flag', 'Abortus_Tinggi', 'Grandemulti',
    'Risk_Score'
]
X = df[feature_cols].fillna(0)
y = df['RISIKO']
print(f"  ✅ Total fitur: {len(feature_cols)}")

# ================================================================
# 5. TRAIN/TEST SPLIT & OVERSAMPLING
# ================================================================
print("\n[5/8] Split data dan penanganan class imbalance...")
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42, stratify=y
)
print(f"  Train: {X_train.shape[0]:,}  |  Test: {X_test.shape[0]:,}")

train_df = X_train.copy()
train_df['__T__'] = y_train.values
max_count = train_df['__T__'].value_counts().max()
parts = []
for cls in sorted(train_df['__T__'].unique()):
    cd = train_df[train_df['__T__'] == cls]
    if len(cd) < max_count:
        cd = resample(cd, replace=True, n_samples=max_count, random_state=42)
    parts.append(cd)
balanced_df = pd.concat(parts).sample(frac=1, random_state=42).reset_index(drop=True)
X_train_bal = balanced_df.drop('__T__', axis=1)
y_train_bal = balanced_df['__T__']
print(f"  Setelah oversampling: {y_train_bal.value_counts().to_dict()}")

scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train_bal)
X_test_scaled  = scaler.transform(X_test)

# ================================================================
# 6. PELATIHAN MODEL — SEBELUM TUNING
# ================================================================
print("\n[6/8] Melatih model (sebelum tuning)...")

rf_default = RandomForestClassifier(n_estimators=100, random_state=42,
    class_weight='balanced', n_jobs=1)
rf_default.fit(X_train_bal, y_train_bal)
acc_rf_before = accuracy_score(y_test, rf_default.predict(X_test))

lr_default = LogisticRegression(C=1.0, solver='lbfgs', max_iter=1000,
    random_state=42, class_weight='balanced', n_jobs=1)
lr_default.fit(X_train_scaled, y_train_bal)
acc_lr_before = accuracy_score(y_test, lr_default.predict(X_test_scaled))

print(f"  RF  sebelum tuning: Akurasi = {acc_rf_before:.4f}")
print(f"  LR  sebelum tuning: Akurasi = {acc_lr_before:.4f}")

# ================================================================
# 7. HYPERPARAMETER TUNING — GridSearchCV
# ================================================================
print("\n[7/8] Hyperparameter Tuning (GridSearchCV 5-fold CV)...")
cv5 = StratifiedKFold(n_splits=5, shuffle=True, random_state=42)

# --- Random Forest ---
print("  >> Tuning Random Forest...")
rf_param_grid = {
    'n_estimators'     : [100, 200],
    'max_depth'        : [None, 15],
    'min_samples_split': [2, 5],
    'max_features'     : ['sqrt', 'log2']
}
rf_grid = GridSearchCV(
    RandomForestClassifier(random_state=42, class_weight='balanced', n_jobs=1),
    param_grid=rf_param_grid, cv=cv5, scoring='f1_weighted', n_jobs=1, verbose=0
)
rf_grid.fit(X_train_bal, y_train_bal)
print(f"  ✅ RF best params : {rf_grid.best_params_}")
print(f"  ✅ RF best CV F1  : {rf_grid.best_score_:.4f}")

# --- Logistic Regression ---
print("  >> Tuning Logistic Regression...")
lr_param_grid = {
    'C'      : [0.1, 1.0, 10.0],
    'solver' : ['lbfgs', 'saga'],
    'max_iter': [2000]
}
lr_grid = GridSearchCV(
    LogisticRegression(random_state=42, class_weight='balanced', n_jobs=1),
    param_grid=lr_param_grid, cv=cv5, scoring='f1_weighted', n_jobs=1, verbose=0
)
lr_grid.fit(X_train_scaled, y_train_bal)
print(f"  ✅ LR best params : {lr_grid.best_params_}")
print(f"  ✅ LR best CV F1  : {lr_grid.best_score_:.4f}")

rf_best = rf_grid.best_estimator_
lr_best = lr_grid.best_estimator_

# ================================================================
# 8. EVALUASI MODEL — SETELAH TUNING
# ================================================================
print("\n[8/8] Evaluasi model final...")

y_pred_rf = rf_best.predict(X_test)
y_pred_lr = lr_best.predict(X_test_scaled)
acc_rf    = accuracy_score(y_test, y_pred_rf)
acc_lr    = accuracy_score(y_test, y_pred_lr)
f1_rf     = f1_score(y_test, y_pred_rf, average='weighted')
f1_lr     = f1_score(y_test, y_pred_lr, average='weighted')
target_names = [label_map[i] for i in sorted(label_map.keys())]

print("\n  " + "=" * 56)
print("  🔹 RANDOM FOREST PERFORMANCE (Setelah Tuning)")
print("  " + "=" * 56)
print(f"  Akurasi  : {acc_rf:.4f}  ({acc_rf*100:.2f}%)")
print(f"  F1 Score : {f1_rf:.4f}")
print(classification_report(y_test, y_pred_rf, target_names=target_names))
cv_scores_rf = cross_val_score(
    rf_best, X, y,
    cv=StratifiedKFold(5, shuffle=True, random_state=42),
    scoring='accuracy', n_jobs=1)
print(f"  Cross-Val (5-fold): {cv_scores_rf.mean():.4f} ± {cv_scores_rf.std():.4f}")

print("\n  " + "=" * 56)
print("  🔹 LOGISTIC REGRESSION PERFORMANCE (Setelah Tuning)")
print("  " + "=" * 56)
print(f"  Akurasi  : {acc_lr:.4f}  ({acc_lr*100:.2f}%)")
print(f"  F1 Score : {f1_lr:.4f}")
print(classification_report(y_test, y_pred_lr, target_names=target_names))

print("\n  Perbandingan sebelum & sesudah tuning:")
print(f"  {'Model':<30} {'Sebelum':>10} {'Sesudah':>10} {'Delta':>8}")
print(f"  {'-' * 58}")
print(f"  {'Random Forest':<30} {acc_rf_before:>10.4f} {acc_rf:>10.4f} {acc_rf-acc_rf_before:>+8.4f}")
print(f"  {'Logistic Regression':<30} {acc_lr_before:>10.4f} {acc_lr:>10.4f} {acc_lr-acc_lr_before:>+8.4f}")

# Feature Importance
imp_df = pd.DataFrame({
    'Fitur': feature_cols, 'Importance': rf_best.feature_importances_
}).sort_values('Importance', ascending=False)
print("\n  Top 10 Feature Importance:")
for _, row in imp_df.head(10).iterrows():
    bar = '█' * int(row['Importance'] * 200)
    print(f"    {row['Fitur']:35s} {row['Importance']:.4f}  {bar}")

# ================================================================
# SIMPAN VISUALISASI
# ================================================================
# Feature Importance
plt.figure(figsize=(12, 8))
sns.barplot(data=imp_df.head(15), x='Importance', y='Fitur', palette='viridis')
plt.title('Top 15 Feature Importance – Random Forest', fontsize=14, fontweight='bold')
plt.xlabel('Importance Score')
plt.tight_layout()
plt.savefig('feature_importance.png', dpi=150, bbox_inches='tight')
plt.close()

# Confusion Matrix
fig, axes = plt.subplots(1, 2, figsize=(14, 5))
for ax, (title, y_pred) in zip(axes, [
    ('Random Forest', y_pred_rf), ('Logistic Regression', y_pred_lr)
]):
    cm = confusion_matrix(y_test, y_pred)
    sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', ax=ax,
                xticklabels=target_names, yticklabels=target_names)
    ax.set_title(f'Confusion Matrix – {title}', fontweight='bold')
    ax.set_xlabel('Predicted'); ax.set_ylabel('Actual')
    plt.setp(ax.get_xticklabels(), rotation=30, ha='right')
plt.tight_layout()
plt.savefig('confusion_matrix.png', dpi=150, bbox_inches='tight')
plt.close()

# Distribusi Kelas
plt.figure(figsize=(8, 5))
counts = df['RISIKO_LABEL'].value_counts()
bars = plt.bar(counts.index, counts.values, color=['#28a745', '#ffc107', '#dc3545'])
for bar, val in zip(bars, counts.values):
    plt.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 30,
             f'{val:,}\n({val/len(df)*100:.1f}%)', ha='center', fontsize=9)
plt.title('Distribusi Kelas Risiko Kehamilan', fontsize=13, fontweight='bold')
plt.xlabel('Kategori Risiko'); plt.ylabel('Jumlah Pasien')
plt.xticks(rotation=20, ha='right'); plt.tight_layout()
plt.savefig('distribusi_kelas.png', dpi=150, bbox_inches='tight')
plt.close()

# ================================================================
# SIMPAN MODEL
# ================================================================
joblib.dump(rf_best,     'maternal_model_rf.pkl')
joblib.dump(lr_best,     'maternal_model_lr.pkl')
joblib.dump(scaler,      'scaler_maternal.pkl')
joblib.dump(feature_cols,'feature_cols.pkl')
joblib.dump(label_map,   'label_map.pkl')
joblib.dump(imp_df,      'feature_importances.pkl')
joblib.dump(rf_best,     'maternal_model.pkl')

print("\n  ✅ Semua model dan artefak tersimpan!")

# ================================================================
# RINGKASAN AKHIR
# ================================================================
print("\n" + "=" * 70)
print("  ✅ TRAINING SELESAI – RINGKASAN HASIL")
print("=" * 70)
print(f"  Dataset : dataset_anc_bumil.xlsx ({len(df):,} pasien)")
print(f"  Fitur   : {len(feature_cols)} fitur klinis")
print(f"  Kelas   : 3 (NORMAL | PERLU TINDAKAN | PERLU RUJUKAN)")
print()
print(f"  🏆 Random Forest  → Akurasi: {acc_rf:.4f} ({acc_rf*100:.2f}%)  F1: {f1_rf:.4f}")
print(f"  🏆 Logistic Reg.  → Akurasi: {acc_lr:.4f} ({acc_lr*100:.2f}%)  F1: {f1_lr:.4f}")
print()
if acc_rf >= 0.80 and acc_lr >= 0.80:
    print("  ✅ TARGET AKURASI > 0.80 TERCAPAI UNTUK KEDUA MODEL!")
else:
    print(f"  RF > 0.80 : {acc_rf >= 0.80}  |  LR > 0.80 : {acc_lr >= 0.80}")
print()
print("  Langkah selanjutnya:")
print("    streamlit run mamacare_app.py")
print("=" * 70)
