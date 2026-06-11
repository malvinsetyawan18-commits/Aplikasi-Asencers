from fastapi import APIRouter, Form
from services.sensor_service import pair_device

router = APIRouter()

@router.post("/pair-device")
def pair(device_id: str = Form(...), petani: str = Form(...)):
    pair_device(device_id, petani)
    return {"status": "paired"}