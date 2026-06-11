import psycopg2

DATABASE_URL = "postgresql://postgres:postgres@localhost/sensor_monitoring"


def get_db():
    conn = psycopg2.connect(DATABASE_URL)
    return conn


def init_db():
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS devices (
        id VARCHAR(255) PRIMARY KEY,
        petani TEXT,
        sensors TEXT
    )
    """)

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS logs (
        id SERIAL PRIMARY KEY,
        device_id TEXT,
        timestamp TEXT,
        data TEXT
    )
    """)

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS sensor_data (
        id SERIAL PRIMARY KEY,
        device_id TEXT,
        tds REAL,
        pH REAL,
        humidity REAL,
        temperature REAL,
        water_temp REAL,
        timestamp TEXT
    )
    """)

    conn.commit()
    cursor.close()
    conn.close()