import cv2
from config import (
    CAMERA_INDEXES,
    IMAGE_SIZE
)

# =====================================================
# INIT CAMERA
# =====================================================

caps = []

for idx in CAMERA_INDEXES:

    cap = cv2.VideoCapture(idx)

    if cap.isOpened():

        print(f"[CAMERA] Kamera {idx} aktif")

        caps.append((idx, cap))

    else:

        print(f"[CAMERA] Kamera {idx} gagal")

# =====================================================
# CAPTURE ALL CAMERAS
# =====================================================

def capture_all_cameras():

    frames = []

    for cam_id, cap in caps:

        ret, frame = cap.read()

        if not ret:

            print(
                f"[CAMERA] "
                f"Gagal membaca kamera {cam_id}"
            )

            continue

        frame = cv2.resize(
            frame,
            (IMAGE_SIZE, IMAGE_SIZE)
        )

        frames.append({

            "camera_id": cam_id,
            "frame": frame
        })

    return frames

# =====================================================
# ANALYZE IMAGE
# =====================================================

def analyze_image(image_path):

    return {

        "status": "success",
        "message": "Analisis gambar berhasil",
        "image_path": image_path
    }

# =====================================================
# RELEASE CAMERA
# =====================================================

def release_cameras():

    for _, cap in caps:

        cap.release()

    print("[CAMERA] Semua kamera dilepas")