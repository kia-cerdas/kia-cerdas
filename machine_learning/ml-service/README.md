# Stunting Prediction ML Service

Machine Learning service untuk prediksi stunting pada anak menggunakan FastAPI.

## 📋 Requirements

- Python 3.9+
- pip

## 🚀 Quick Start

### 1. Install Dependencies

```bash
pip install -r requirements.txt
```

### 2. Prepare Dataset

Pastikan file `Stunting.csv` ada di parent directory:
```
ml-service/
├── app.py
├── train_model.py
├── requirements.txt
└── ../PA/Stunting.csv
```

### 3. Train Model

```bash
python train_model.py
```

Output akan disimpan di folder `models/`:
- `stunting_model_latest.pkl` - Model untuk prediksi
- `scaler_latest.pkl` - Scaler untuk normalisasi features
- `features_latest.pkl` - Nama-nama features

> Service ini tidak melatih model setiap kali dijalankan. Model dilatih sekali lewat `train_model.py`, lalu `app.py` hanya memuat artefak `.pkl` tersebut saat runtime.

### 4. Run FastAPI Service

```bash
python app.py
```

atau menggunakan uvicorn langsung:

```bash
uvicorn app:app --host 0.0.0.0 --port 8000 --reload
```

### 5. Run Streamlit Dashboard

```bash
streamlit run streamlit_app.py
```

Kalau ingin mengubah port, folder model, atau mematikan reload, buat file `.env` berdasarkan `.env.example`.

### 6. Access API

- **API Docs**: http://localhost:8000/docs
- **Alternative Docs**: http://localhost:8000/redoc
- **Health Check**: http://localhost:8000/health
- **Info**: http://localhost:8000/info

Untuk hasil visual, buka Streamlit dashboard pada alamat yang muncul di terminal, biasanya http://localhost:8501.

## 📝 API Endpoints

### Health Check

```bash
GET /health
```

Response:
```json
{
  "status": "healthy",
  "model_loaded": true,
  "message": "Model loaded successfully"
}
```

### Predict Stunting

```bash
POST /predict
Content-Type: application/json

{
  "bb": 12.5,
  "tb": 85.0,
  "lila": 14.5,
  "lingkar_kepala": 46.5,
  "umur": 24,
  "jenis_kelamin": "Laki-laki"
}
```

Response:
```json
{
  "stunting_risk": 75.5,
  "classification": "STUNTING",
  "confidence": 89.3,
  "z_score_tb_u_estimated": -2.15,
  "status_tb_u": "Sangat Pendek (Stunted)",
  "rekomendasi": "🚨 RISIKO TINGGI STUNTING...",
  "message": "Prediksi stunting berhasil dibuat"
}
```

## 📊 Input Parameters

| Parameter | Type | Range | Description |
|-----------|------|-------|-------------|
| `bb` | float | 0-50 | Berat Badan (kg) |
| `tb` | float | 30-150 | Tinggi Badan (cm) |
| `lila` | float | 5-35 | Lingkar Lengan Atas (cm) |
| `lingkar_kepala` | float | 20-60 | Lingkar Kepala (cm) |
| `umur` | int | 0-60 | Umur saat ukur (bulan) |
| `jenis_kelamin` | string | Laki-laki/Perempuan | Jenis Kelamin |

## 📤 Output Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `stunting_risk` | float | Probabilitas stunting (0-100%) |
| `classification` | string | STUNTING / AT_RISK / NORMAL |
| `confidence` | float | Kepercayaan prediksi (0-100%) |
| `z_score_tb_u_estimated` | float | Estimated Z-Score TB/U |
| `status_tb_u` | string | Status Tinggi Badan/Umur |
| `rekomendasi` | string | Rekomendasi tindakan |

## 🧪 Testing dengan curl

```bash
# Health check
curl http://localhost:8000/health

# Predict stunting
curl -X POST http://localhost:8000/predict \
  -H "Content-Type: application/json" \
  -d '{
    "bb": 12.5,
    "tb": 85.0,
    "lila": 14.5,
    "lingkar_kepala": 46.5,
    "umur": 24,
    "jenis_kelamin": "Laki-laki"
  }'
```

## 🧪 Testing dengan Postman

1. Import collection: `postman_collection.json`
2. Set base URL: `http://localhost:8000`
3. Run requests dari collection

## 📚 Model Information

- **Algorithm**: XGBoost + RandomizedSearchCV
- **Features**: 10 engineered features from 6 core inputs
- **Target**: Binary Classification (Stunting/Normal)
- **Training Data**: Stunting.csv

## 🔍 Training Workflow

The training script now produces:

- model before tuning
- model after tuning
- hyperparameter search using `RandomizedSearchCV`
- performance comparison before vs after tuning
- saved report at `models/training_report.json`

## 🔧 Configuration

Edit `.env` untuk konfigurasi:
- `FASTAPI_HOST`: Host untuk service (default: 0.0.0.0)
- `FASTAPI_PORT`: Port untuk service (default: 8000)
- `FASTAPI_RELOAD`: Mode reload saat development (default: true)
- `MODEL_DIR`: Direktori model (default: ./models)
- `MODEL_PATH`: File model utama
- `SCALER_PATH`: File scaler
- `FEATURES_PATH`: File daftar fitur

## 📊 Model Performance

Hasil training terakhir pada dataset ini:

- **Before tuning**: Accuracy 0.9948, ROC AUC 0.9783, Precision 0.75, Recall 0.6667, F1 0.7059
- **After tuning**: Accuracy 0.9948, ROC AUC 0.9835, Precision 0.75, Recall 0.6667, F1 0.7059

Catatan kritis: dataset sangat imbalanced, sehingga accuracy tinggi tidak cukup untuk menilai model. Pada hasil ini tuning memberi perbaikan kecil di ROC AUC, tetapi metrik kelas minoritas masih sama, jadi analisis laporan sebaiknya menekankan bahwa tuning membantu ranking/probabilitas, bukan perubahan klasifikasi akhir yang besar.

## 🐛 Troubleshooting

### Model tidak ditemukan
```
Error: Model tidak ditemukan di ./models/stunting_model_latest.pkl
```
**Solusi**: Jalankan `python train_model.py` terlebih dahulu

### Port sudah digunakan
```
Error: Address already in use
```
**Solusi**: Gunakan port lain
```bash
uvicorn app:app --port 8001
```

### CORS Error
Jika mendapat CORS error saat memanggil dari frontend, enable CORS di app.py:
```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

## 📞 Support

Untuk issues atau pertanyaan, buat issue di repository.

## 📄 License

MIT
