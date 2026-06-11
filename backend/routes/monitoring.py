import os
import ast

from fastapi import (
    APIRouter,
    UploadFile,
    File,
    Form,
    Depends
)

from typing import List

from sqlalchemy.orm import Session

from services.monitoring_service import process_monitoring
from services.database_service import Monitoring, get_db
from config import UPLOAD_FOLDER

router = APIRouter()

# =========================
# POST - INPUT SENSOR + IMAGE
# =========================
@router.post("/monitoring")
async def monitoring(
    sensor_data: str = Form(...),
    images: List[UploadFile] = File(...)
):

    sensor_data = ast.literal_eval(sensor_data)

    image_paths = []

    for image in images:

        filepath = os.path.join(
            UPLOAD_FOLDER,
            image.filename
        )

        with open(filepath, "wb") as f:
            f.write(await image.read())

        image_paths.append(filepath)

    result = process_monitoring(
        sensor_data,
        image_paths
    )

    return result


# =========================
# GET - AMBIL DATA DB
# =========================
@router.get("/monitoring")
def get_monitoring(db: Session = Depends(get_db)):

    return db.query(Monitoring).all()