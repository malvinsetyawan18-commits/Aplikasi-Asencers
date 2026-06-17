import os

YOLO_MODEL_PATH = "models/yolov8_tanaman.pt"
SCALER_PATH = "models/scaler_sensor.pkl"
ML_MODEL_PATH = "models/sensor_classifier.pkl"
UPLOAD_FOLDER = "uploads"

DATABASE_URL_IMAGE = os.getenv(
    "DATABASE_URL_IMAGE", 
    "postgresql://postgres:postgres@localhost/hydroponic_ai"
) 

DATABASE_URL_SENSOR = os.getenv(
    "DATABASE_URL_SENSOR", 
    "postgresql://postgres:postgres@localhost/sensor_monitoring"
) 

IMAGE_SIZE = 320
CAMERA_INDEXES = [0]