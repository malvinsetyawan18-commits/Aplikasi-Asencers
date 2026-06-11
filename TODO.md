# TODO: Implementasi Backend untuk Aplikasi Asencers

## Status: Belum dimulai

### 1. [x] Setup Backend Folder & Files
   - Buat `backend/main.py` (FastAPI server)
   - Buat `backend/requirements.txt`

### 2. [x] Update Flutter Dependencies
   - Edit `pubspec.yaml` tambah dio
   - `flutter pub get`

### 3. [x] Buat Flutter Services & Models
   - Buat `lib/services/api_service.dart`
   - Buat `lib/models/sensor_model.dart`

### 4. [ ] Update Frontend Pages
   - Edit `lib/main.dart` (Dashboard fetch data)
   - Edit `lib/frontend/camera.dart` (capture & upload)
   - Edit `lib/frontend/ai_page.dart` (real chat)

### 5. [ ] Test Backend
   - `cd backend && python -m venv venv && venv\\Scripts\\activate && pip install -r requirements.txt`
   - `uvicorn main:app --reload`

### 6. [ ] Test Full App
   - `flutter run`
   - Verifikasi sensor data, image analysis, AI chat

### 7. [ ] Deploy (Opsional)
   - Backend ke Render/Heroku
   - Update API URL di Flutter
