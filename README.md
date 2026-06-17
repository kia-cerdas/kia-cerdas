# KIA Cerdas - Sistem Kesehatan Ibu dan Anak

Aplikasi terintegrasi untuk manajemen kesehatan ibu dan anak berbasis web, mobile, dan machine learning.

## 📁 Struktur Project

# Arsitektur Sistem

KIA Cerdas terdiri dari tiga komponen utama:

* **Backend:** Golang
* **Web:** React.js
* **Mobile:** Flutter

Backend menyediakan API yang digunakan oleh aplikasi web dan mobile untuk mengakses serta mengelola data secara terpusat.

## Dokumentasi Arsitektur Backend (Clean Architecture)

Backend KIA Cerdas mengadopsi pola **Clean Architecture** untuk memisahkan *concern* dan memastikan aplikasi mudah diskalakan serta dikelola.

![Arsitektur Layer](docs/img/architecture%20layer.jpeg)

**Alur Layer Sistem:**
`Router` → `Controller` → `Usecase` → `Repository` → `DB`

* **Router**: Mendefinisikan endpoint API dan meneruskan permintaan ke Controller yang sesuai.
* **Controller**: Menerima HTTP request, melakukan validasi dasar, dan meneruskannya ke Usecase.
* **Usecase**: Menyimpan inti dari aturan bisnis (business logic) aplikasi tanpa bergantung pada antarmuka luar.
* **Repository**: Berfungsi sebagai jembatan antara aplikasi dan database (akses data, operasi CRUD).
* **DB**: Sistem manajemen basis data tempat menyimpan data persisten.

> Diagram arsitektur secara komprehensif terdapat di dalam dokumen laporan Bab 2/3. Pola interaksi antar layer (`Controller` - `Usecase` - `Repository`) juga telah digambarkan di dalam **Sequence Diagram**.
> Penjelasan detail tiap layer beserta contoh kode dapat Anda pelajari lebih lanjut di sini:
> 👉 [Dokumentasi Arsitektur Backend Lengkap](docs/architecture/backend-architecture.md)

---

# Struktur Repository

```text
backend/
web/
mobile/
docs/

.
├── backend_go/           # Backend API (Go/Fiber)
├── web/                  # Web Dashboard (React + Vite)
├── mobile/kia_app/       # Mobile App (Flutter)
├── machine_learning/     # ML Services
│   ├── MachineLearning/  # Maternal Health Prediction
│   └── ml-service/       # Stunting Prediction API
├── database/             # Database schemas & migrations
└── docs/                 # Documentation


## 🚀 Quick Start

### Prerequisites

- **Backend**: Go 1.21+
- **Web**: Node.js 18+ & npm/yarn
- **Mobile**: Flutter 3.0+
- **ML Services**: Python 3.9+

### 1. Clone Repository

```bash
git clone https://github.com/kia-cerdas/kia-cerdas.git
cd kia-cerdas
```

### 2. Setup Backend (Go)

```bash
cd backend_go

# Copy environment template
cp .env.example .env

# Edit .env with your database credentials
# You need:
# - Supabase/PostgreSQL connection string
# - JWT secret key

# Install dependencies
go mod download

# Run migrations (if needed)
go run cmd/migrate/main.go

# Run server
go run cmd/main.go
```

Backend will run on `http://localhost:8080`

### 3. Setup Web Dashboard (React)

```bash
cd web

# Copy environment template
cp .env.example .env

# Edit .env if backend URL is different

# Install dependencies
npm install

# Run development server
npm run dev
```

Web will run on `http://localhost:5173`

### 4. Setup Mobile App (Flutter)

```bash
cd mobile/kia_app

# Get dependencies
flutter pub get

# Run on your device/emulator
flutter run

# Or build APK
flutter build apk --release
```

### 5. Setup ML Services

#### Maternal Health Prediction Service

```bash
cd machine_learning/MachineLearning

# Create virtual environment
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Train model (if needed)
python mamacare_train.py

# Run API
python api.py
```

#### Stunting Prediction Service

```bash
cd machine_learning/ml-service

# Copy environment template
cp .env.example .env

# Create virtual environment
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Train model (if needed)
python train_model.py

# Run FastAPI server
python app.py
```

ML Service will run on `http://localhost:8000`

## ⚙️ Configuration

### Environment Variables

#### Backend (`backend_go/.env`)
```env
DB_POSTGRES_DSN=your_database_connection_string
JWT_SECRET=your_jwt_secret_key
APP_PORT=8080
```

#### Web (`web/.env`)
```env
VITE_API_URL=http://localhost:8080
```

#### ML Service (`machine_learning/ml-service/.env`)
```env
FASTAPI_PORT=8000
MODEL_DIR=./models
```

## 🔒 Security Notes

**IMPORTANT**: 
- Never commit `.env` files with real credentials
- Change default JWT secrets in production
- Use environment-specific configuration
- Rotate database passwords if exposed

## 📱 Mobile App Configuration

Update API endpoint in `mobile/kia_app/lib/core/constants/api_constants.dart`:

```dart
static const String baseUrl = 'http://YOUR_BACKEND_URL';
```

## 🧪 Testing

```bash
# Backend tests
cd backend_go
go test ./...

# Web tests
cd web
npm run test

# Mobile tests
cd mobile/kia_app
flutter test
```

## 📦 Building for Production

### Backend
```bash
cd backend_go
go build -o main cmd/main.go
```

### Web
```bash
cd web
npm run build
# Output in: dist/
```

### Mobile
```bash
cd mobile/kia_app
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

## 📚 Documentation

- Backend API docs: `http://localhost:8080/swagger` (if Swagger enabled)
- Database schema: See `docs/` folder
- ML model details: See `machine_learning/*/README.md`

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## 📄 License

[Add your license here]

## 👥 Team

[Add team members here]

## 🐛 Issues & Support

Report issues at: https://github.com/kia-cerdas/kia-cerdas/issues
