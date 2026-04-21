from pydantic import BaseModel
from datetime import datetime
from typing import Optional, Any


class ResourceBase(BaseModel):
    resource_id:   str
    resource_type: str
    name:          Optional[str] = None
    region:        str
    az:            Optional[str] = None
    state:         Optional[str] = None
    details:       Optional[Any] = None


class ResourceCreate(ResourceBase):
    pass


class ResourceOut(ResourceBase):
    id:         int
    scanned_at: datetime

    class Config:
        from_attributes = True