from fastapi import APIRouter, Form, HTTPException
from services.sensor_service import pair_device
from database.connection import get_db 
import json

router = APIRouter()

# 1. Endpoint untuk mendaftarkan alat (Sudah ada di kode kamu)
@router.post("/pair-device")
def pair(device_id: str = Form(...), petani: str = Form(...)):
    try:
        pair_device(device_id, petani)
        return {"status": "paired", "message": f"Device {device_id} berhasil dipasangkan."}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Gagal pairing: {str(e)}")

# 2. TAMBAHKAN INI: Endpoint untuk mengambil daftar alat yang akan dibaca Flutter
@router.get("/list-devices")
def get_all_devices():
    conn = get_db()
    cursor = conn.cursor()
    try:
        # Mengambil semua data dari tabel devices di database sensor_monitoring
        cursor.execute("SELECT id, petani, sensors FROM devices")
        rows = cursor.fetchall()
        
        devices_list = []
        for row in rows:
            devices_list.append({
                "device_id": row[0],
                "petani": row[1],
                "sensors": row[2] # Jika formatnya string/JSON di DB
            })
            
        return {"status": "success", "data": devices_list}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Gagal mengambil data device: {str(e)}")
    finally:
        cursor.close()
        conn.close()