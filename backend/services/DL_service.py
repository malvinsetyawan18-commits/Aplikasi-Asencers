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

print("Load model")

yolo_model = YOLO(
    "models/yolov8_tanaman.pt"
)

print("Model berhasil load")

# =====================================================
# PREDICT VISUAL
# =====================================================

def predict_visual(frame):

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