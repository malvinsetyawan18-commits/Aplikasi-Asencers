import json
import paho.mqtt.client as mqtt

BROKER = "187.77.117.24"
PORT = 1883
MQTT_USER = "petani_ai"
MQTT_PASSWORD = "AsencerS245."

# Penyimpanan sementara aksi yang menunggu persetujuan
pending_actions = {}

def publish_command(topic, payload):
    """Kirim perintah ke ESP32 via MQTT — hanya dipanggil setelah disetujui"""
    try:
        client = mqtt.Client()
        client.username_pw_set(MQTT_USER, MQTT_PASSWORD)
        client.connect(BROKER, PORT, 60)
        client.publish(topic, json.dumps(payload))
        client.disconnect()
        print(f"[MQTT] Perintah terkirim ke {topic}: {payload}")
    except Exception as e:
        print(f"[MQTT ERROR] Gagal kirim perintah: {e}")

def get_recommended_actions(fusion_status, sensor_data):
    """Buat daftar aksi yang direkomendasikan — belum dieksekusi"""
    actions = []
    ph = sensor_data.get("pH", 7.0)
    tds = sensor_data.get("TDS", 0)

    if ph < 5.5:
        actions.append({
            "id": "ph_up",
            "topic": "asencers/control/ph_up",
            "label": "Aktifkan Pompa pH Up",
            "reason": f"pH terlalu rendah: {ph}",
            "payload": {"status": "ON", "duration": 5}
        })
    elif ph > 7.0:
        actions.append({
            "id": "ph_down",
            "topic": "asencers/control/ph_down",
            "label": "Aktifkan Pompa pH Down",
            "reason": f"pH terlalu tinggi: {ph}",
            "payload": {"status": "ON", "duration": 5}
        })

    if "KEKURANGAN NUTRISI" in fusion_status or tds < 500:
        actions.append({
            "id": "abmix",
            "topic": "asencers/control/abmix",
            "label": "Aktifkan Pompa AB Mix",
            "reason": f"TDS rendah: {tds} ppm",
            "payload": {"status": "ON", "duration": 10}
        })

    return actions

def execute_approved_action(action_id, session_id):
    """Eksekusi aksi setelah disetujui petani"""
    session = pending_actions.get(session_id)
    if not session:
        return {"status": "error", "message": "Session tidak ditemukan"}

    action = next((a for a in session["actions"] if a["id"] == action_id), None)
    if not action:
        return {"status": "error", "message": "Aksi tidak ditemukan"}

    publish_command(action["topic"], action["payload"])

    # Hapus aksi dari pending setelah dieksekusi
    session["actions"] = [a for a in session["actions"] if a["id"] != action_id]

    return {"status": "success", "message": f"{action['label']} berhasil dijalankan"}

def fusion_decision(sensor_result, visual_results, sensor_data=None):
    sensor_label = sensor_result["label"]
    sensor_conf = sensor_result["confidence"]

    labels = [v["label"] for v in visual_results]
    sehat_count = labels.count("Daun Sehat")
    kuning_count = labels.count("Daun Kekuningan")
    bercak_count = labels.count("Daun Bercak Hitam")

    if (
        sensor_label == "Kekurangan Nutrisi"
        and kuning_count >= 2
        and sensor_conf >= 0.75
    ):
        result = {
            "status": "SANGAT YAKIN: KEKURANGAN NUTRISI",
            "recommendation": "Tambahkan nutrisi AB Mix dan cek nilai TDS."
        }
    elif bercak_count >= 2:
        result = {
            "status": "WASPADA: PENYAKIT TANAMAN",
            "recommendation": "Periksa kemungkinan jamur atau bakteri."
        }
    elif kuning_count >= 3:
        result = {
            "status": "WASPADA: DAUN KEKUNINGAN",
            "recommendation": "Periksa pH dan konsentrasi nutrisi."
        }
    elif sehat_count >= 3 and sensor_label == "Normal":
        result = {
            "status": "KONDISI OPTIMAL",
            "recommendation": "Tanaman dalam kondisi baik."
        }
    else:
        result = {
            "status": "PERLU PEMANTAUAN LANJUT",
            "recommendation": "Lakukan monitoring rutin."
        }

    # Buat rekomendasi aksi tanpa langsung eksekusi
    if sensor_data:
        recommended = get_recommended_actions(result["status"], sensor_data)
        result["recommended_actions"] = recommended

        # Simpan ke pending jika ada aksi
        if recommended:
            import time