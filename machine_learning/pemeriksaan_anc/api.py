# api.py
import joblib
import numpy as np
import pandas as pd
import warnings
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List


# Suppress sklearn feature name warnings
warnings.filterwarnings('ignore', message='X does not have valid feature names')


app = FastAPI(title="MamaCare ML API")

# Load semua artifact yang dihasilkan oleh mamacare_train.py
print("Loading models...")
rf = joblib.load('maternal_model_rf.pkl')
scaler = joblib.load('scaler_maternal.pkl')
feature_cols = joblib.load('feature_cols.pkl')
label_map = joblib.load('label_map.pkl')
print("✅ All models loaded successfully!")

class PredictRequest(BaseModel):
    usia_ibu: float
    usia_kehamilan: int
    trimester_num: int
    gravida: int
    para: int
    abortus: int
    imt: float
    lila: float
    tinggi_fundus_uteri: float
    td_sistolik: float
    td_diastolik: float
    hemoglobin: float
    kunjungan_anc_ke: int
    imunisasi_enc: int
    riwayat_enc: int
    riwayat_berat: int
    hiv_rek: int
    sif_rek: int
    hepb_rek: int

def compute_features(d: dict) -> dict:
    """Menghitung fitur turunan (sama seperti di mamacare_train.py)"""
    d = d.copy()
    td_s = d.get('td_sistolik', 120)
    td_d = d.get('td_diastolik', 80)
    hb = d.get('hemoglobin', 12)
    lila = d.get('lila', 26)
    imt = d.get('imt', 22)
    usia = d.get('usia_ibu', 25)

    d['MAP'] = (td_s + 2 * td_d) / 3
    d['Pulse_Pressure'] = td_s - td_d
    d['Trimester_Num'] = d.get('trimester_num', 2)

    d['KatTD_Enc'] = 2 if (td_s >= 140 or td_d >= 90) else (1 if (td_s >= 120 or td_d >= 80) else 0)
    d['KatHb_Enc'] = 1 if hb < 11.0 else 0
    d['KatLiLA_Enc'] = 1 if lila < 23.5 else 0
    d['KatIMT_Enc'] = 0 if imt < 18.5 else (3 if imt >= 30 else (2 if imt >= 25 else 1))

    d['Anemia_Flag'] = 1 if hb < 11.0 else 0
    d['Anemia_Berat'] = 1 if hb < 8.0 else 0
    d['Hiper_Flag'] = 1 if td_s >= 140 else 0
    d['Hiper_Berat'] = 1 if td_s >= 160 else 0
    d['KEK_Flag'] = 1 if lila < 23.5 else 0
    d['IMT_Kurus'] = 1 if imt < 18.5 else 0
    d['IMT_Obese'] = 1 if imt >= 30.0 else 0
    d['Usia_Risiko'] = 1 if (usia < 19 or usia > 38) else 0
    d['Abortus_Tinggi'] = 1 if d.get('abortus', 0) >= 2 else 0
    d['Grandemulti'] = 1 if d.get('gravida', 1) >= 5 else 0

    hiv = d.get('hiv_rek', 0)
    sif = d.get('sif_rek', 0)
    hepb = d.get('hepb_rek', 0)
    d['Tripel_Total'] = hiv + sif + hepb

    riwayat_enc = d.get('riwayat_enc', 0)
    riwayat_berat = d.get('riwayat_berat', 0)
    d['Risk_Score'] = (
        d['Anemia_Flag'] * 2 + d['Anemia_Berat'] * 3 +
        d['KatTD_Enc'] * 3 + d['Hiper_Berat'] * 5 +
        d['KEK_Flag'] * 2 + (2 if d['KatIMT_Enc'] in [0, 3] else 0) +
        riwayat_enc * 2 + riwayat_berat * 3 +
        d['Tripel_Total'] + d['Usia_Risiko']
    )
    return d

@app.post("/predict")
async def predict(req: PredictRequest):
    try:
        input_dict = req.model_dump()
        features_dict = compute_features(input_dict)
        # Buat dataframe dengan urutan fitur yang benar
        row = {col: features_dict.get(col, 0) for col in feature_cols}
        X = pd.DataFrame([row])[feature_cols].fillna(0)
        X_scaled = scaler.transform(X)
        pred = rf.predict(X_scaled)[0]
        proba = rf.predict_proba(X_scaled)[0].tolist()
        label = label_map[pred]
        return {
            "prediction": int(pred),
            "label": label,
            "probabilities": proba,
            "risk_score": features_dict.get('Risk_Score', 0)
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)