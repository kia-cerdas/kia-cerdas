"""
FastAPI ML Service — Deteksi Dini Risiko Stunting
=================================================
Menerima data antropometri dari backend Go, melakukan feature engineering,
dan memprediksi kelas risiko stunting (4 kelas) menggunakan model LightGBM.

Kelas output:
  1. Normal
  2. Risiko Stunting Ringan
  3. Risiko Stunting Sedang
  4. Risiko Stunting Tinggi
"""

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import joblib
import json
import numpy as np

app = FastAPI(title="API Deteksi Stunting SI KIA")

# ── Muat artefak model saat startup ─────────────────────────────────────
try:
    model = joblib.load("model_artifacts/stunting_model.pkl")
    scaler = joblib.load("model_artifacts/scaler.pkl")
    label_encoder = joblib.load("model_artifacts/label_encoder.pkl")
    with open("model_artifacts/metadata.json", "r") as f:
        metadata = json.load(f)
    ALL_FEATURE_COLS = metadata["all_feature_cols"]
    FEATURE_COLS = metadata["feature_cols"]
    CLASS_NAMES = metadata.get(
        "class_names",
        ["Normal", "Risiko Stunting Ringan",
         "Risiko Stunting Sedang", "Risiko Stunting Tinggi"],
    )
    print(f"✅ Model {metadata.get('model_name', '?')} berhasil dimuat")
    print(f"   Fitur model : {len(FEATURE_COLS)} dari {len(ALL_FEATURE_COLS)} total")
    print(f"   Kelas ({len(CLASS_NAMES)}): {CLASS_NAMES}")
except Exception as e:
    print("❌ Gagal memuat artefak ML:", e)


# ── Skema input (sesuai payload dari backend Go) ────────────────────────
class PredictionRequest(BaseModel):
    bb_lahir: float = 3.0          # Berat lahir (kg)
    tb_lahir: float = 49.0         # Tinggi lahir (cm)
    bb: float                      # Berat badan sekarang (kg)
    tb: float                      # Tinggi badan sekarang (cm)
    lila: float = 14.0             # Lingkar lengan atas (cm)
    umur: float                    # Usia dalam bulan
    jenis_kelamin: str = "Laki-laki"  # "Laki-laki" atau "Perempuan"


# ── Helper: estimasi Z-Score berdasarkan median WHO ─────────────────────
def estimate_z_score(actual: float, median: float, sd1: float) -> float:
    """Estimasi Z-Score ≈ (actual - median) / (SD1 / 2)."""
    sd = sd1 / 2
    if sd == 0:
        return 0.0
    return round((actual - median) / sd, 2)


def get_reference_values(usia_bulan: float):
    """
    Kembali median & SD1 referensi WHO untuk BB/U dan BB/TB.
    Disesuaikan untuk rentang usia 0-60 bulan (rata-rata laki-laki & perempuan).
    """
    if usia_bulan <= 0:
        usia_bulan = 1

    # ── BB/U (Berat menurut Umur) ──
    if usia_bulan <= 6:
        bb_median = 3.3 + usia_bulan * 0.8
        bb_sd1 = 1.5
    elif usia_bulan <= 12:
        bb_median = 8.0 + (usia_bulan - 6) * 0.3
        bb_sd1 = 2.0
    elif usia_bulan <= 24:
        bb_median = 10.0 + (usia_bulan - 12) * 0.2
        bb_sd1 = 2.5
    elif usia_bulan <= 36:
        bb_median = 12.5 + (usia_bulan - 24) * 0.18
        bb_sd1 = 3.0
    elif usia_bulan <= 48:
        bb_median = 14.5 + (usia_bulan - 36) * 0.2
        bb_sd1 = 3.5
    else:
        bb_median = 17.0 + (usia_bulan - 48) * 0.25
        bb_sd1 = 4.0

    # ── BB/TB (Berat menurut Tinggi) ──
    if usia_bulan <= 12:
        exp_tb = 49 + usia_bulan * 2.0
    elif usia_bulan <= 24:
        exp_tb = 73 + (usia_bulan - 12) * 1.0
    elif usia_bulan <= 36:
        exp_tb = 85 + (usia_bulan - 24) * 0.8
    else:
        exp_tb = 95 + (usia_bulan - 36) * 0.7

    bb_tb_median = bb_median
    bb_tb_sd1 = max(1.0, bb_sd1 * 0.7)

    return {
        "bb_median": bb_median,
        "bb_sd1": bb_sd1,
        "bb_tb_median": bb_tb_median,
        "bb_tb_sd1": bb_tb_sd1,
    }


# ── Endpoint prediksi ───────────────────────────────────────────────────
@app.post("/predict")
def predict_stunting(data: PredictionRequest):
    try:
        # 1. Feature Engineering (sesuai pipeline notebook)
        bmi = data.bb / ((data.tb / 100) ** 2)
        jk_enc = 1 if "L" in data.jenis_kelamin.upper() else 0

        # Velocity diset 0 karena prediksi tunggal (tanpa riwayat)
        velocity_berat = 0.0
        velocity_tinggi = 0.0

        # Naik BB & cara ukur tidak dikirim backend → default 0
        naik_bb_enc = 0
        cara_ukur_enc = 0

        # Estimasi Z-Score dari referensi WHO sederhana
        ref = get_reference_values(data.umur)
        zs_bb_u = estimate_z_score(data.bb, ref["bb_median"], ref["bb_sd1"])
        zs_bb_tb = estimate_z_score(data.bb, ref["bb_tb_median"], ref["bb_tb_sd1"])

        # 2. Susun array fitur sesuai urutan all_feature_cols
        input_dict = {
            "usia_bulan": data.umur,
            "jk_enc": jk_enc,
            "BB Lahir": data.bb_lahir,
            "TB Lahir": data.tb_lahir,
            "Berat": data.bb,
            "Tinggi": data.tb,
            "LiLA": data.lila,
            "ZS BB/U": zs_bb_u,
            "ZS BB/TB": zs_bb_tb,
            "bmi": bmi,
            "naik_bb_enc": naik_bb_enc,
            "cara_ukur_enc": cara_ukur_enc,
            "velocity_berat": velocity_berat,
            "velocity_tinggi": velocity_tinggi,
        }

        full_features = [input_dict[col] for col in ALL_FEATURE_COLS]
        X_full = np.array(full_features).reshape(1, -1)

        # 3. Scaling
        X_scaled = scaler.transform(X_full)

        # 4. Pilih hanya fitur yang diseleksi saat training
        sel_idx = [ALL_FEATURE_COLS.index(f) for f in FEATURE_COLS]
        X_model = X_scaled[:, sel_idx]

        # 5. Prediksi
        pred_encoded = model.predict(X_model)[0]
        pred_proba = model.predict_proba(X_model)[0]
        pred_class = label_encoder.inverse_transform([pred_encoded])[0]
        confidence = float(max(pred_proba))

        # 6. Mapping kelas → classification & rekomendasi
        if "Normal" in pred_class:
            classification = "NORMAL"
            rekomendasi = (
                "Pertumbuhan anak normal. "
                "Lanjutkan pola gizi seimbang dan pantau rutin di Posyandu."
            )
        elif "Ringan" in pred_class:
            classification = "AT_RISK"
            rekomendasi = (
                "Risiko stunting ringan terdeteksi. "
                "Evaluasi asupan gizi harian dan tingkatkan frekuensi pemantauan."
            )
        elif "Sedang" in pred_class:
            classification = "AT_RISK_HIGH"
            rekomendasi = (
                "Risiko stunting sedang terdeteksi. "
                "Konsultasikan dengan ahli gizi dan lakukan intervensi PMT."
            )
        else:  # Tinggi
            classification = "STUNTING"
            rekomendasi = (
                "Risiko stunting tinggi terdeteksi! "
                "Segera rujuk ke tenaga medis/ahli gizi untuk penanganan intensif."
            )

        # 7. Estimasi status TB/U
        if data.tb < ref["bb_median"] * 5 - 50:  # rough proxy
            status_tbu = "Pendek (Stunted)"
        else:
            status_tbu = "Normal"

        return {
            "classification": classification,
            "confidence": round(confidence, 4),
            "stunting_risk": round(confidence * 100, 2),
            "z_score_tb_u_estimated": 0.0,
            "status_tb_u": status_tbu,
            "rekomendasi": rekomendasi,
            "message": f"Prediksi: {pred_class} (confidence {confidence:.1%})",
            "detail": {
                "prediksi_kelas": pred_class,
                "probabilitas": {
                    name: round(float(prob), 4)
                    for name, prob in zip(CLASS_NAMES, pred_proba)
                },
            },
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ── Health check ────────────────────────────────────────────────────────
@app.get("/health")
def health():
    return {"status": "ok", "model": metadata.get("model_name", "unknown")}


if __name__ == "__main__":
    import uvicorn
    # Port 8000 agar sesuai default ML_SERVICE_URL di backend Go
    uvicorn.run(app, host="0.0.0.0", port=8000)