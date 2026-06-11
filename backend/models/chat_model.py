from pydantic import BaseModel

class ChatRequest(BaseModel):
    message: str
    device_id: str