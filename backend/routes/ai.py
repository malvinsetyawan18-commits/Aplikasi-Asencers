from fastapi import APIRouter
from models.chat_model import ChatRequest
from services.ai_service import get_ai_response

router = APIRouter(prefix="/ai")

@router.post("/chat")
def chat(request: ChatRequest):
    return {"reply": get_ai_response(request.message)}