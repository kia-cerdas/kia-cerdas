# ANC ML Model Migration Summary

## Overview
Updated the ANC (Antenatal Care) examination system to use the new machine learning model with three risk categories:
- 🔴 **PERLU RUJUKAN** (Red) - Detected ≥1 of: Kematian Ibu, Keguguran/Prematur, Preeklampsia, Anemia Berat, Infeksi Menular
- 🟡 **PERLU TINDAKAN** (Yellow) - Only BBLR/Stunting detected, without any of the 5 risks above
- 🟢 **NORMAL** (Green) - None of the 6 risks detected

## Changes Made

### 1. Machine Learning API (api_v2.py)
- **Status**: ✅ Already correctly implemented
- The ML API already has the correct logic matching the new model requirements
- Logic: 5 risiko berat [0,1,2,3,5] → PERLU RUJUKAN (2), Hanya stunting [4] → PERLU TINDAKAN (1), Tidak ada → NORMAL (0)

### 2. Backend Go (backend_go/)

#### Models Updated
- **app/models/prediksi_risiko.go**
  - Added new fields to `PrediksiRisikoResponse`:
    - `OverallPrediction`, `OverallLabel`, `RiskTypes`, `ActiveRiskCount`
    - `AlasanKlinis`, `RekomendasiUtama`
  - Added `RiskTypeDetail` struct for detailed risk information

- **app/models/pemeriksaan_kehamilan.go**
  - Added new fields to `PemeriksaanKehamilan`:
    - `OverallPrediction`, `OverallLabel`, `ActiveRiskCount`
    - `AlasanKlinis`, `RekomendasiUtama`

#### Use Cases Updated
- **app/usecases/pemeriksaan_kehamilan_usecase.go**
  - Updated `fillPrediction()` to use new ML API response structure
  - Added `generateRiskSummaryFromTypes()` to create detailed risk summary
  - Stores ML prediction results in database fields

### 3. Database Migration
- **File**: `backend_go/sql/add_anc_ml_prediction_fields.sql`
- **Changes**:
  - Added 5 new columns to `pemeriksaan_kehamilan` table:
    - `overall_prediction` (INTEGER)
    - `overall_label` (VARCHAR(20))
    - `active_risk_count` (INTEGER)
    - `alasan_klinis` (TEXT)
    - `rekomendasi_utama` (TEXT)
  - Added PostgreSQL comments for documentation
  - Set default values for existing records

### 4. Frontend (web/src/pages/Ibu/)

#### PemeriksaanKehamilanForm.jsx
- **Removed**: Client-side risk calculation function `hitungStatusRisiko()`
- **Added**: `parseAlasanKlinis()` helper function
- **Updated**: 
  - Form now displays ML prediction results from backend
  - Shows clinical reasons (`alasan_klinis`) and main recommendation
  - Displays risk score and active risk count
  - Updated info message to indicate ML usage

#### PemeriksaanKehamilanList.jsx
- **Added**: `parseAlasanKlinis()` helper function
- **Updated**:
  - Risk calculation now prioritizes ML API results from backend
  - Displays ML prediction badge when available
  - Shows clinical reasons and detailed risk information
  - Updated header description to mention ML predictions
  - Enhanced risk banner with ML-specific information

## How to Run the Migration

### Using Supabase SQL Editor
1. Go to your Supabase project dashboard
2. Navigate to SQL Editor
3. Copy and run the contents of `backend_go/sql/add_anc_ml_prediction_fields.sql`

### Using psql Command Line
```bash
psql "postgresql://postgres.your-password@aws-1-ap-southeast-1.pooler.supabase.com:6543/postgres" -f backend_go/sql/add_anc_ml_prediction_fields.sql
```

### Using Go Migration (if available)
```bash
cd backend_go
go run cmd/migrate/main.go up
```

## Testing Checklist

1. **Database Migration**
   - [ ] Run migration SQL successfully
   - [ ] Verify new columns exist in `pemeriksaan_kehamilan` table
   - [ ] Check default values are set correctly

2. **Backend Go**
   - [ ] Restart Go backend server
   - [ ] Test creating new ANC examination
   - [ ] Verify ML API is called correctly
   - [ ] Check prediction results are saved to database

3. **Frontend**
   - [ ] Test ANC examination form
   - [ ] Verify ML prediction results display correctly
   - [ ] Check clinical reasons are shown
   - [ ] Test ANC examination list view
   - [ ] Verify risk banner displays ML predictions

4. **End-to-End**
   - [ ] Create new ANC examination with various risk factors
   - [ ] Verify prediction matches expected category (NORMAL/PERLU TINDAKAN/PERLU RUJUKAN)
   - [ ] Check risk details are accurate
   - [ ] Test editing existing examinations

## ML Model Logic

The ML model uses the following logic to determine risk category:

```python
# 5 risiko berat [0,1,2,3,5] → PERLU RUJUKAN (2)
# Hanya stunting [4] → PERLU TINDAKAN (1)
# Tidak ada → NORMAL (0)

rujukan_flags = [pred_types[0], pred_types[1], pred_types[2], pred_types[3], pred_types[5]]
if any(rujukan_flags):
    final_overall = 2  # PERLU RUJUKAN
elif pred_types[4]:
    final_overall = 1  # PERLU TINDAKAN
else:
    final_overall = 0  # NORMAL
```

Risk Types:
- [0] Risiko Kematian Ibu
- [1] Risiko Keguguran / Persalinan Prematur
- [2] Risiko Preeklampsia / Hipertensi
- [3] Risiko Anemia Berat
- [4] Risiko BBLR / Stunting Bayi
- [5] Risiko Infeksi Menular (Tripel Eliminasi)

## Notes

- The ML API (`api_v2.py`) was already correctly implemented and did not require changes
- Frontend client-side calculation has been removed in favor of backend ML API results
- Database migration is backward compatible - existing records will have default values
- The system maintains fallback to old risk calculation if ML API is unavailable
- All changes maintain backward compatibility with existing data

## Files Modified

### Backend Go
- `app/models/prediksi_risiko.go`
- `app/models/pemeriksaan_kehamilan.go`
- `app/usecases/pemeriksaan_kehamilan_usecase.go`
- `sql/add_anc_ml_prediction_fields.sql` (new file)

### Frontend
- `web/src/pages/Ibu/PemeriksaanKehamilanForm.jsx`
- `web/src/pages/Ibu/PemeriksaanKehamilanList.jsx`

### ML API
- `machine_learning/pemeriksaan_anc/api_v2.py` (no changes needed - already correct)
