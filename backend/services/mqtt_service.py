import json
import paho.mqtt.client as mqtt
from datetime import datetime
from services.database_service import save_monitoring 
from database.connection import get_db 

BROKER = "187.77.117.24" 
PORT = 1883
TOPIC = "asencers/sensor/#"
MQTT_USER = "petani_ai"
MQTT_PASSWORD = "AsencerS245."  

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("✅ MQTT Connected")
        client.subscribe(TOPIC)
        client.subscribe("asencers/camera/#")  
    else:
        print("❌ MQTT Failed, code:", rc)


def on_message(client, userdata, msg):
    try:
        payload = json.loads(msg.payload.decode())
        if "asencers/sensor" in msg.topic:
            device_id = payload.get("device_id")
            sensor_data = payload.get("data")

            if not device_id or not sensor_data:
                return

            print("📥 Data MQTT masuk:", device_id)

            result = {
                "sensor_result": {
                    "label": device_id,
                    "confidence": 1.0
                },
                "visual_results": sensor_data,
                "fusion_result": {
                    "status": "mqtt_received"
                }
            }

            save_monitoring(result)
            print("💾 Data berhasil disimpan ke PostgreSQL (Tabel Monitoring)")

            conn = get_db()
            cursor = conn.cursor()
            try:
                cursor.execute(
                    "UPDATE devices SET sensors = %s WHERE id = %s",
                    (json.dumps(sensor_data), device_id)
                )
                conn.commit()
                print(f"📡 Tabel devices berhasil diupdate dengan data real MQTT untuk {device_id}")
            except Exception as db_err:
                conn.rollback()
                print(f"❌ Gagal update data real ke tabel devices: {db_err}")
            finally:
                cursor.close()
                conn.close()

        elif "asencers/camera" in msg.topic:
            device_id = payload.get("device_id")
            camera_data = payload.get("camera_data") 

            if not device_id or not camera_data:
                return

            print("📥 Data MQTT Kamera masuk:", device_id)

            conn = get_db()
            cursor = conn.cursor()
            try:
                cursor.execute(
                    "UPDATE devices SET camera_data = %s WHERE id = %s",
                    (json.dumps(camera_data), device_id)
                )
                conn.commit()
                print(f"📸 Tabel devices berhasil diupdate dengan data kamera MQTT untuk {device_id}")
            except Exception as db_err:
                conn.rollback()
                print(f"❌ Gagal update data kamera ke tabel devices: {db_err}")
            finally:
                cursor.close()
                conn.close()

    except Exception as e:
        print("❌ MQTT Error:", e)


def start_mqtt():
    client = mqtt.Client()
    client.on_connect = on_connect
    client.on_message = on_message
    client.username_pw_set(MQTT_USER, MQTT_PASSWORD)
    client.connect(BROKER, PORT, 60)
    client.loop_start()