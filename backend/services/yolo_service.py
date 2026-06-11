from ultralytics import YOLO

# =====================================================
# VALID LABELS
# =====================================================

VALID_LABELS = [

    "Healthy",

    "Nitrogen_Deficiency",

    "Phosphorus_Deficiency",

    "Potassium_Deficiency",

    "Unknown"
]

# =====================================================
# LOAD MODEL
# =====================================================

print("[YOLO] Memuat model...")

try:

    yolo_model = YOLO(
        "models/yolov8_tanaman.pt"
    )

    print("[YOLO] Model berhasil load")

except Exception as e:

    print(f"[YOLO] Gagal load model: {e}")

    yolo_model = None

# =====================================================
# PREDICT VISUAL
# =====================================================

def predict_visual(frame):

    # ================================================
    # DUMMY MODE
    # ================================================

    if yolo_model is None:

        return {

            "label": "Healthy",

            "confidence": 0.99
        }

    results = yolo_model(
        frame,
        verbose=False
    )

    probs = results[0].probs

    class_id = probs.top1

    confidence = float(
        probs.top1conf.item()
    )

    label = results[0].names[class_id]

    # =============================================
    # VALIDASI LABEL
    # =============================================

    if label not in VALID_LABELS:

        label = "Unknown"

    return {

        "label": label,

        "confidence": confidence
    }