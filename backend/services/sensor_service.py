import json
from database.connection import get_db

def get_sensor_data(device_id: str):
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("SELECT sensors FROM devices WHERE id=?", (device_id,))
    result = cursor.fetchone()

    conn.close()

    if not result:
        return None

    return json.loads(result[0])


def pair_device(device_id: str, petani: str):
    conn = get_db()
    cursor = conn.cursor()

    default_sensor = {
        "pH": 6.5,
        "suhu_udara": 28,
        "suhu_air": 26,
        "cahaya": 700,
        "tds": 800
    }

    cursor.execute(
        "INSERT OR REPLACE INTO devices (id, petani, sensors) VALUES (?, ?, ?)",
        (device_id, petani, json.dumps(default_sensor))
    )

    conn.commit()
    conn.close()