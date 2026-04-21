from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List
from app.db.session import get_db
from app.models.resource import Resource
from app.schemas.resource import ResourceOut
from app.services.aws_scanner import scan_all

router = APIRouter()


@router.get("/resources", response_model=List[ResourceOut])
def get_resources(db: Session = Depends(get_db)):
    return db.query(Resource).all()


@router.post("/resources/scan", response_model=List[ResourceOut])
def trigger_scan(db: Session = Depends(get_db)):
    scanned = scan_all()
    saved = []
    for item in scanned:
        existing = db.query(Resource).filter(
            Resource.resource_id == item["resource_id"]
        ).first()
        if existing:
            for key, value in item.items():
                setattr(existing, key, value)
            db.add(existing)
            saved.append(existing)
        else:
            resource = Resource(**item)
            db.add(resource)
            saved.append(resource)
    db.commit()
    for r in saved:
        db.refresh(r)
    return saved