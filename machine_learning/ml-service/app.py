"""
================================================================
STUNTING AI - FASTAPI SERVICE
================================================================
Machine Learning Service untuk Prediksi Risiko Stunting
Menggunakan model hasil training:
    - stunting_model.pkl
    - scaler_stunting.pkl
    - feature_cols.pkl

Cara menjalankan:
    uvicorn app:app --reload

API Docs:
    http://127.0.0.1:8000/docs
================================================================
"""

import logging
import os
from enum import Enum
from typing import Optional

import joblib
import numpy as np
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

# ================================================================
# ENV CONFIG
# ================================================================
load_dotenv()

BASE_DIR = os.path.dirname(
    os.path.abspath(__file__)
)


def resolve_path(
    path_value: Optional[str],
    fallback_relative: str
) -> str:

    candidate = (
        path_value
        or fallback_relative
    )

    return (
        candidate
        if os.path.isabs(candidate)
        else os.path.join(BASE_DIR, candidate)
    )


FASTAPI_HOST = os.getenv(
    "FASTAPI_HOST",
    "0.0.0.0"
)

FASTAPI_PORT = int(
    os.getenv(
        "FASTAPI_PORT",
        "8000"
    )
)

FASTAPI_RELOAD = (
    os.getenv(
        "FASTAPI_RELOAD",
        "true"
    ).lower() == "true"
)

MODEL_DIR = resolve_path(
    os.getenv("MODEL_DIR"),
    "models"
)

MODEL_PATH = resolve_path(
    os.getenv("MODEL_PATH"),
    os.path.join(
        "models",
        "stunting_model.pkl"
    )
)

SCALER_PATH = resolve_path(
    os.getenv("SCALER_PATH"),
    os.path.join(
        "models",
        "scaler_stunting.pkl"
    )
)

FEATURES_PATH = resolve_path(
    os.getenv("FEATURES_PATH"),
    os.path.join(
        "models",
        "feature_cols.pkl"
    )
)

# ================================================================
# LOGGING
# ================================================================
logging.basicConfig(level=logging.INFO)

logger = logging.getLogger(__name__)

# ================================================================
# FASTAPI INIT
# ================================================================
app = FastAPI(
    title="STUNTING AI SERVICE",
    description="Machine Learning Service untuk Prediksi Risiko Stunting Anak",
    version="3.0.0"
)

# ================================================================
# CORS
# ================================================================
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ================================================================
# GLOBAL VARIABLES
# ================================================================
model = None
scaler = None
feature_cols = None

# ================================================================
# ENUM
# ================================================================
class JenisKelaminEnum(str, Enum):

    LAKI_LAKI = "Laki-laki"

    PEREMPUAN = "Perempuan"

# ================================================================
# REQUEST MODEL
# ================================================================
class PredictStuntingRequest(BaseModel):

    bb_lahir: float = Field(
        ...,
        description="Berat badan lahir (kg)",
        ge=1,
        le=6
    )

    tb_lahir: float = Field(
        ...,
        description="Tinggi badan lahir (cm)",
        ge=30,
        le=60
    )

    bb: float = Field(
        ...,
        description="Berat badan saat ukur (kg)",
        ge=1,
        le=50
    )

    tb: float = Field(
        ...,
        description="Tinggi badan saat ukur (cm)",
        ge=30,
        le=150
    )

    lila: float = Field(
        ...,
        description="Lingkar lengan atas (cm)",
        ge=5,
        le=35
    )

    umur: int = Field(
        ...,
        description="Umur dalam bulan",
        ge=0,
        le=60
    )

    jenis_kelamin: JenisKelaminEnum

    class Config:

        json_schema_extra = {

            "example": {

                "bb_lahir": 2.8,

                "tb_lahir": 48,

                "bb": 9.5,

                "tb": 74,

                "lila": 13.2,

                "umur": 24,

                "jenis_kelamin": "Laki-laki"
            }
        }

# ================================================================
# RESPONSE MODEL
# ================================================================
class PredictStuntingResponse(BaseModel):

    stunting_risk: float

    classification: str

    confidence: float

    status_tb_u: str

    rekomendasi: str

    feature_summary: dict

    message: str

# ================================================================
# HEALTH RESPONSE
# ================================================================
class HealthCheckResponse(BaseModel):

    status: str

    model_loaded: bool

    message: str

# ================================================================
# LOAD MODEL
# ================================================================
def load_model_artifacts():

    global model
    global scaler
    global feature_cols

    try:

        if not os.path.exists(MODEL_PATH):

            raise FileNotFoundError(
                f"Model tidak ditemukan: {MODEL_PATH}"
            )

        if not os.path.exists(SCALER_PATH):

            raise FileNotFoundError(
                f"Scaler tidak ditemukan: {SCALER_PATH}"
            )

        if not os.path.exists(FEATURES_PATH):

            raise FileNotFoundError(
                f"Feature columns tidak ditemukan: {FEATURES_PATH}"
            )

        model = joblib.load(MODEL_PATH)

        scaler = joblib.load(SCALER_PATH)

        feature_cols = joblib.load(FEATURES_PATH)

        logger.info("✅ Model berhasil di-load")

        logger.info(
            f"✅ Total fitur: {len(feature_cols)}"
        )

        return True

    except Exception as e:

        logger.error(
            f"❌ Error loading model: {str(e)}"
        )

        return False

# ================================================================
# FEATURE ENGINEERING
# ================================================================
def build_feature_vector(
    request: PredictStuntingRequest
):

    # ------------------------------------------------------------
    # FEATURE ENGINEERING
    # ------------------------------------------------------------

    bmi = (
        request.bb /
        ((request.tb / 100) ** 2)
    )

    bb_tb_ratio = (
        request.bb / request.tb
    )

    growth_height = (
        request.tb - request.tb_lahir
    )

    growth_weight = (
        request.bb - request.bb_lahir
    )

    underweight = (
        1 if request.bb < 8 else 0
    )

    wasting = (
        1 if bmi < 14 else 0
    )

    short_birth = (
        1 if request.tb_lahir < 48 else 0
    )

    low_birth_weight = (
        1 if request.bb_lahir < 2.5 else 0
    )

    jk_binary = (
        1
        if request.jenis_kelamin == JenisKelaminEnum.LAKI_LAKI
        else 0
    )

    # ------------------------------------------------------------
    # FEATURE MAP
    # ------------------------------------------------------------

    feature_map = {

        "BB Lahir": request.bb_lahir,

        "TB Lahir": request.tb_lahir,

        "Berat": request.bb,

        "Tinggi": request.tb,

        "LiLA": request.lila,

        "Usia_Bulan": request.umur,

        "JK_Binary": jk_binary,

        "BMI": bmi,

        "BB_TB_Ratio": bb_tb_ratio,

        "Growth_Height": growth_height,

        "Growth_Weight": growth_weight,

        "Underweight": underweight,

        "Wasting": wasting,

        "Short_Birth": short_birth,

        "Low_Birth_Weight": low_birth_weight,
    }

    # ------------------------------------------------------------
    # BUILD FEATURE VECTOR
    # ------------------------------------------------------------

    feature_row = []

    for feature_name in feature_cols:

        value = feature_map.get(
            feature_name,
            0
        )

        feature_row.append(
            float(value)
        )

    return (
        np.array([feature_row]),
        {
            "BMI": round(bmi, 2),
            "BB_TB_Ratio": round(bb_tb_ratio, 4),
            "Growth_Height": round(growth_height, 2),
            "Growth_Weight": round(growth_weight, 2),
            "Underweight": underweight,
            "Wasting": wasting,
            "Short_Birth": short_birth,
            "Low_Birth_Weight": low_birth_weight,
            "JK_Binary": jk_binary
        }
    )

# ================================================================
# CLASSIFICATION
# ================================================================
def classify_stunting(
    probability_percent: float
):

    if probability_percent >= 70:

        classification = "STUNTING"

        status = "Sangat Pendek"

        rekomendasi = (
            "RISIKO TINGGI STUNTING. "
            "Segera konsultasi ke dokter atau ahli gizi. "
            "Lakukan pemantauan pertumbuhan intensif."
        )

    elif probability_percent >= 40:

        classification = "AT_RISK"

        status = "Pendek"

        rekomendasi = (
            "RISIKO SEDANG. "
            "Perlu pemantauan rutin dan edukasi nutrisi."
        )

    else:

        classification = "NORMAL"

        status = "Normal"

        rekomendasi = (
            "Pertumbuhan anak normal. "
            "Lanjutkan pola makan sehat dan pemantauan rutin."
        )

    return (
        classification,
        status,
        rekomendasi
    )

# ================================================================
# STARTUP EVENT
# ================================================================
@app.on_event("startup")
async def startup_event():

    logger.info(
        "🚀 Starting STUNTING AI Service..."
    )

    if load_model_artifacts():

        logger.info(
            "✅ Service Ready"
        )

    else:

        logger.error(
            "❌ Failed loading model"
        )

# ================================================================
# ROOT
# ================================================================
@app.get("/")
async def root():

    return {

        "message": "STUNTING AI SERVICE",

        "version": "3.0.0",

        "docs": "/docs"
    }

# ================================================================
# HEALTH CHECK
# ================================================================
@app.get(
    "/health",
    response_model=HealthCheckResponse
)
async def health_check():

    model_loaded = (
        model is not None and
        scaler is not None
    )

    return HealthCheckResponse(

        status=(
            "healthy"
            if model_loaded
            else "unhealthy"
        ),

        model_loaded=model_loaded,

        message=(
            "Model loaded successfully"
            if model_loaded
            else "Model not loaded"
        )
    )

# ================================================================
# INFO
# ================================================================
@app.get("/info")
async def info():

    return {

        "service": "STUNTING AI SERVICE",

        "version": "3.0.0",

        "model_loaded": model is not None,

        "total_features": len(feature_cols)
        if feature_cols
        else 0,

        "features": feature_cols
    }

# ================================================================
# PREDICT
# ================================================================
@app.post(
    "/predict",
    response_model=PredictStuntingResponse
)
async def predict_stunting(
    request: PredictStuntingRequest
):

    try:

        if model is None or scaler is None:

            raise HTTPException(
                status_code=500,
                detail="Model belum di-load"
            )

        # --------------------------------------------------------
        # FEATURE ENGINEERING
        # --------------------------------------------------------

        features, feature_summary = (
            build_feature_vector(request)
        )

        # --------------------------------------------------------
        # SCALING
        # --------------------------------------------------------

        features_scaled = scaler.transform(
            features
        )

        # --------------------------------------------------------
        # PREDICTION
        # --------------------------------------------------------

        prediction_proba = (
            model.predict_proba(
                features_scaled
            )[0]
        )

        stunting_probability = float(
            prediction_proba[1]
        )

        stunting_risk = (
            stunting_probability * 100
        )

        confidence = (
            max(prediction_proba) * 100
        )

        # --------------------------------------------------------
        # CLASSIFICATION
        # --------------------------------------------------------

        classification, status, rekomendasi = (
            classify_stunting(
                stunting_risk
            )
        )

        logger.info(
            f"Prediction => "
            f"{classification} | "
            f"Risk: {stunting_risk:.2f}%"
        )

        return PredictStuntingResponse(

            stunting_risk=round(
                stunting_risk,
                2
            ),

            classification=classification,

            confidence=round(
                confidence,
                2
            ),

            status_tb_u=status,

            rekomendasi=rekomendasi,

            feature_summary=feature_summary,

            message="Prediksi berhasil"
        )

    except HTTPException:

        raise

    except Exception as e:

        logger.error(
            f"Prediction error: {str(e)}"
        )

        raise HTTPException(
            status_code=500,
            detail=str(e)
        )

# ================================================================
# MAIN
# ================================================================
if __name__ == "__main__":

    import uvicorn

    uvicorn.run(
        "app:app",
        host=FASTAPI_HOST,
        port=FASTAPI_PORT,
        reload=FASTAPI_RELOAD
    )