from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from services.monitoring_service import process_fusion
from services.fusion_service import execute_approved_action, pending_actions
from services.database_service import Monitoring, get_db

router = APIRouter()

@router.get("/monitoring/fusion")
def get_fusion():
    return process_fusion()

@router.get("/monitoring/history")
def get_history(db: Session = Depends(get_db)):
    return db.query(Monitoring).order_by(Monitoring.id.desc()).limit(10).all()

@router.post("/monitoring/approve")
def approve_action(session_id: str, action_id: str):
    """Petani menyetujui aksi — pompa akan dijalankan"""
    result = execute_approved_action(action_id, session_id)
    return result

@router.post("/monitoring/reject")
def reject_action(session_id: str, action_id: str):
    """Petani menolak aksi — pompa tidak dijalankan"""
    session = pending_actions.get(session_id)
    if not session:
        return {"status": "error", "message": "Session tidak ditemukan"}
    
    session["actions"] = [
        a for a in session["actions"] if a["id"] != action_id
    ]
    return {"status": "success", "message": "Aksi ditolak"}