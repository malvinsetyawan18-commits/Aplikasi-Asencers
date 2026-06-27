import os

YOLO_MODEL_PATH = "models/yolov8_tanaman.pt"
SCALER_PATH = "models/model_ML/scaler_sensor.pkl"
PCA_MODEL_PATH = "models/model_ML/pca_model.pkl"
ML_MODEL_PATH = "models/model_ML/sensor_classifier.pkl"
UPLOAD_FOLDER = "uploads"

DATABASE_URL_IMAGE = os.getenv(
    "DATABASE_URL_IMAGE", 
    "postgresql://postgres:AsencerS245.@localhost:5432/hydroponic_ai"
) 

DATABASE_URL_SENSOR = os.getenv(
    "DATABASE_URL_SENSOR", 
    "postgresql://postgres:AsencerS245.@localhost:5432/sensor_monitoring"
) 

IMAGE_SIZE = 320
CAMERA_INDEXES = [0]