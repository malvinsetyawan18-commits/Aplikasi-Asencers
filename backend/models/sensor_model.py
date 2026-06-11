from pydantic import BaseModel
from typing import Optional

class SensorData(BaseModel):
    device_id: Optional[str] = None
    tds: float
    pH: float
    humadity: float
    temperature: float
    water_temp: float
    timestamp: Optional[str] = None