from fastapi import APIRouter

from app.api.routes import capabilities, health

api_router = APIRouter(prefix="/api/v1")
api_router.include_router(capabilities.router)

public_router = APIRouter()
public_router.include_router(health.router)
