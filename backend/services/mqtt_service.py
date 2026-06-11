import json
import paho.mqtt.client as mqtt
from datetime import datetime
from services.database_service import save_monitoring 

BROKER = "187.77.117.24" 
PORT = 1883
TOPIC = "asencers/sensor/#"
MQTT_USER = "petani_ai"
MQTT_PASSWORD = "AsencerS245."  

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("✅ MQTT Connected")
        client.subscribe(TOPIC)
    else:
        print("❌ MQTT Failed, code:", rc)


def on_message(client, userdata, msg):
    try:
        payload = json.loads(msg.payload.decode())

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

        print("💾 Data berhasil disimpan ke PostgreSQL")

    except Exception as e:
        print("❌ MQTT Error:", e)


def start_mqtt():
    client = mqtt.Client()
    client.on_connect = on_connect
    client.on_message = on_message

    # DI SINI CARA MASUKNYA: Menyuntikkan username & password sebelum konek
    client.username_pw_set(MQTT_USER, MQTT_PASSWORD)

    # Memperbaiki parameter ketiga dari 1883 (salah tempat) menjadi 60 (keepalive dalam detik)
    client.connect(BROKER, PORT, 60)
    client.loop_start()