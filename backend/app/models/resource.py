from sqlalchemy import Column, Integer, String, DateTime, JSON
from sqlalchemy.sql import func
from app.db.session import Base


class Resource(Base):
    __tablename__ = "resources"

    id            = Column(Integer, primary_key=True, index=True)
    resource_id   = Column(String, unique=True, index=True)
    resource_type = Column(String)
    name          = Column(String, nullable=True)
    region        = Column(String)
    az            = Column(String, nullable=True)
    state         = Column(String, nullable=True)
    details       = Column(JSON, nullable=True)
    scanned_at    = Column(DateTime, server_default=func.now())