from services.ml_service import predict_sensor
from services.yolo_service import predict_visual
from services.fusion_service import fusion_decision
from services.database_service import save_monitoring
from services.notification_service import send_notification
from sqlalchemy import create_engine, text
from config import DATABASE_URL_SENSOR, DATABASE_URL_IMAGE

engine_sensor = create_engine(DATABASE_URL_SENSOR)
engine_image = create_engine(DATABASE_URL_IMAGE)

def get_latest_sensor():
    with engine_sensor.connect() as conn:
        result = conn.execute(text("""
            SELECT tds_ppm, ph_value, dht_humidity, dht_temp, water_temp
            FROM public.hydroponic_logs
            ORDER BY created_at DESC
            LIMIT 1
        """)).fetchone()
    if not result:
        return None
    return {
        "TDS": float(result[0] or 0),
        "pH": float(result[1] or 0),
        "DHT_humidity": float(result[2] or 0),
        "DHT_temp": float(result[3] or 0),
        "water_temp": float(result[4] or 0)
    }

def get_latest_visual():
    with engine_image.connect() as conn:
        results = conn.execute(text("""
            SELECT nama_kamera, kondisi_daun, tingkat_akurasi
            FROM public.hasil_deteksi
            ORDER BY waktu_analisis DESC
            LIMIT 3
        """)).fetchall()
    if not results:
        return []
    return [
        {
            "camera": row[0],
            "label": row[1],
            "confidence": float(row[2] or 0)
        }
        for row in results
    ]

def process_fusion():
    sensor_data = get_latest_sensor()
    if not sensor_data:
        return {"error": "Data sensor tidak tersedia"}

    sensor_result = predict_sensor(sensor_data)
    visual_results = get_latest_visual()
    if not visual_results:
        visual_results = [{"label": "Tidak Ada Objek", "confidence": 0}]

    # Kirim sensor_data ke fusion untuk generate recommended_actions
    fusion_result = fusion_decision(sensor_result, visual_results, sensor_data)

    final_result = {
        "sensor_data": sensor_data,
        "sensor_result": sensor_result,
        "visual_results": visual_results,
        "fusion_result": fusion_result
    }

    save_monitoring(final_result)
    send_notification(fusion_result["status"])

    return final_result

def process_monitoring(sensor_data, image_paths):
    sensor_result = predict_sensor(sensor_data)
    visual_results = []
    for path in image_paths:
        result = predict_visual(path)
        visual_results.append(result)

    fusion_result = fusion_decision(sensor_result, visual_results, sensor_data)

    final_result = {
        "sensor_data": sensor_data,
        "sensor_result": sensor_result,
        "visual_results": visual_results,
        "fusion_result": fusion_result
    }

    save_monitoring(final_result)
    send_notification(fusion_result["status"])

    return final_result