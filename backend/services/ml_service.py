import joblib
import numpy as np
from config import (
    SCALER_PATH,
    PCA_MODEL_PATH,   # tambahkan path ini di config
    ML_MODEL_PATH
)

# =====================================================
# LOAD MODEL
# =====================================================
print("[ML] Memuat model sensor...")
try:
    scaler = joblib.load(SCALER_PATH)
    pca = joblib.load(PCA_MODEL_PATH)
    clf_sensor = joblib.load(ML_MODEL_PATH)
    print("[ML] Model sensor berhasil dimuat")
except Exception as e:
    print(f"[ML] Gagal memuat model: {e}")
    scaler = None
    pca = None
    clf_sensor = None

# =====================================================
# PREDICT SENSOR
# =====================================================
def predict_sensor(sensor_data):
    # =================================================
    # DUMMY MODE
    # =================================================
    if scaler is None or pca is None or clf_sensor is None:
        return {
            "label": "normal",
            "confidence": 0.99
        }

    raw_data = [[
        sensor_data["TDS"],
        sensor_data["pH"],
        sensor_data["DHT_humidity"],
        sensor_data["DHT_temp"],
        sensor_data["water_temp"]
    ]]

    # ================================================
    # SCALING
    # ================================================
    scaled_data = scaler.transform(raw_data)

    # ================================================
    # PCA TRANSFORM
    # ================================================
    pca_data = pca.transform(scaled_data)

    # ================================================
    # PREDICTION
    # ================================================
    prediction = clf_sensor.predict(pca_data)[0]

    # ================================================
    # CONFIDENCE
    # ================================================
    probability = clf_sensor.predict_proba(pca_data)
    confidence = float(np.max(probability))

    return {
        "label": prediction,
        "confidence": confidence
    }