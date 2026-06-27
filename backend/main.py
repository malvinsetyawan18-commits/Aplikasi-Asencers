from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from routes import (
    sensor,
    device,
    ai,
    monitoring
)

from services.mqtt_service import (
    start_mqtt
)

app = FastAPI(

    title="Asencers Backend",

    version="1.0.0",

    description=(
        "Backend IoT + AI Hydroponic"
    )
)

# =========================================
# CORS
# =========================================

app.add_middleware(

    CORSMiddleware,

    allow_origins=["*"],

    allow_credentials=True,

    allow_methods=["*"],

    allow_headers=["*"],
)

# =========================================
# REGISTER ROUTES
# =========================================

app.include_router(
    sensor.router
)

app.include_router(
    device.router
)

app.include_router(
    ai.router
)

app.include_router(
    monitoring.router
)

# =========================================
# STARTUP EVENT
# =========================================

@app.on_event("startup")

def startup_event():

    print(
        "🚀 Starting Backend..."
    )

    start_mqtt()

    print(
        "✅ MQTT Service Started"
    )

    print(
        "✅ AI Service Ready"
    )

# =========================================
# ROOT
# =========================================

@app.get("/")

def root():

    return {

        "message":
        "Hydroponic AI Backend Running 🚀",

        "status":
        "running"
    }

# =========================================
# HEALTH CHECK
# =========================================

@app.get("/health")

def health_check():

    return {

        "status":
        "ok",

        "service":
        "Asencers Backend"
    }