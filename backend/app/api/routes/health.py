from typing import Literal

from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter(tags=["service"])


class HealthData(BaseModel):
    status: Literal["ok"] = "ok"


class HealthResponse(BaseModel):
    data: HealthData


@router.get("/health", response_model=HealthResponse)
async def health_check() -> HealthResponse:
    return HealthResponse(data=HealthData())
