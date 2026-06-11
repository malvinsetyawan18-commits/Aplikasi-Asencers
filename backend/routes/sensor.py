from fastapi import APIRouter, HTTPException
from services.sensor_service import get_sensor_data

router = APIRouter(prefix="/sensor")

@router.get("/{device_id}")
def get_sensor(device_id: str):
    data = get_sensor_data(device_id)

    if not data:
        raise HTTPException(404, "Device not found")

    return data