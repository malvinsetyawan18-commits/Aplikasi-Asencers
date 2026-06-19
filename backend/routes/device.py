from fastapi import APIRouter, Form, HTTPException
from services.sensor_service import pair_device
from database.connection import get_db 
from services import mqtt_service 
import json

router = APIRouter()

# 1. Endpoint untuk mendaftarkan alat (Tetap Sama)
@router.post("/pair-device")
def pair(device_id: str = Form(...), petani: str = Form(...)):
    try:
        pair_device(device_id, petani)
        return {"status": "paired", "message": f"Device {device_id} berhasil dipasangkan."}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Gagal pairing: {str(e)}")

# 2. Endpoint untuk mengambil daftar alat yang akan dibaca Flutter (Tetap Sama)
@router.get("/list-devices")
def get_all_devices():
    conn = get_db()
    cursor = conn.cursor()
    try:
        cursor.execute("SELECT id, petani, sensors FROM devices")
        rows = cursor.fetchall()
        
        devices_list = []
        for row in rows:
            devices_list.append({
                "device_id": row[0],
                "petani": row[1],
                "sensors": row[2] 
            })
            
        return {"status": "success", "data": devices_list}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Gagal mengambil data device: {str(e)}")
    finally:
        cursor.close()
        conn.close()

# 3. TAMBAHKAN INI: Endpoint Kontrol Pompa via MQTT sesuai standard ESP32 Anda
@router.post("/control-pump")
def control_pump(status: str = Form(...)):
    try:
        # ESP32 Anda membaca string uppercase "ON" atau "OFF"
        payload = "ON" if status.upper() == "ON" else "OFF"
        
        # Mengirimkan pesan ke topik yang di-subscribe oleh ESP32
        mqtt_service.publish("control/pump", payload)
        
        return {"status": "success", "message": f"Perintah {payload} berhasil dikirim ke pompa."}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Gagal mengirim perintah ke pompa: {str(e)}")