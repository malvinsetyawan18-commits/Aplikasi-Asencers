import json
from database.connection import get_db

def get_sensor_data(device_id: str):
    conn = get_db()
    cursor = conn.cursor()

    try:
        # Mengubah '?' menjadi '%s' untuk PostgreSQL
        cursor.execute("SELECT sensors FROM devices WHERE id = %s", (device_id,))
        result = cursor.fetchone()
        
        if not result:
            return None

        # PostgreSQL biasanya langsung mengembalikan dict jika kolom berbentuk JSON/TEXT, 
        # kita antisipasi jika tipenya masih berupa string.
        if isinstance(result[0], dict):
            return result[0]
        return json.loads(result[0])
    except Exception as e:
        print(f"❌ Error get_sensor_data: {e}")
        return None
    finally:
        cursor.close()
        conn.close()


def pair_device(device_id: str, petani: str):
    conn = get_db()
    cursor = conn.cursor()

    # Ini adalah data awal SAAT PERTAMA KALI alat didaftarkan.
    # Setelah didaftarkan, data ini HARUS diperbarui oleh data real dari MQTT.
    default_sensor = {
        "pH": 0.0,
        "suhu_udara": 0,
        "suhu_air": 0,
        "cahaya": 0,
        "tds": 0
    }

    try:
        # 1. Cek apakah device sudah ada atau belum
        cursor.execute("SELECT id FROM devices WHERE id = %s", (device_id,))
        exists = cursor.fetchone()

        if exists:
            # Jika sudah ada, update nama petaninya saja, JANGAN timpa data sensor yang sudah ada
            cursor.execute(
                "UPDATE devices SET petani = %s WHERE id = %s",
                (petani, device_id)
            )
            print(f"🔄 Device {device_id} updated with new farmer: {petani}")
        else:
            # Jika benar-benar device baru, masukan data awal nilai 0
            cursor.execute(
                "INSERT INTO devices (id, petani, sensors) VALUES (%s, %s, %s)",
                (device_id, petani, json.dumps(default_sensor))
            )
            print(f"✅ Device {device_id} newly paired.")

        conn.commit()
    except Exception as e:
        conn.rollback()
        print(f"❌ Error pair_device: {e}")
        raise e
    finally:
        cursor.close()
        conn.close()