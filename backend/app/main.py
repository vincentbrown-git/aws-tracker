from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.routes_health import router as health_router
from app.api.routes_resources import router as resources_router
from app.db.session import engine, Base

Base.metadata.create_all(bind=engine)

app = FastAPI(title="AWS Infrastructure Tracker")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(health_router)
app.include_router(resources_router, prefix="/api")
