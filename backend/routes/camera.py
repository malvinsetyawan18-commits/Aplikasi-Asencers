from fastapi import APIRouter, UploadFile, File
from services.image_service import analyze_image

router = APIRouter(prefix="/camera")

@router.post("/analyze")
async def analyze(file: UploadFile = File(...)):
    contents = await file.read()
    return analyze_image(contents)