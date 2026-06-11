from typing import Literal

from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter(tags=["service"])


class CapabilitiesData(BaseModel):
    storage_policy: Literal["local_first"]
    persistent_user_data: list[str]
    ephemeral_processing: list[str]
    optional_persistent_features: list[str]


class CapabilitiesResponse(BaseModel):
    data: CapabilitiesData


@router.get("/capabilities", response_model=CapabilitiesResponse)
async def get_capabilities() -> CapabilitiesResponse:
    return CapabilitiesResponse(
        data=CapabilitiesData(
            storage_policy="local_first",
            persistent_user_data=[],
            ephemeral_processing=["course_screenshot_recognition"],
            optional_persistent_features=[
                "client_encrypted_backup",
                "cross_device_sync",
                "share_export",
            ],
        )
    )
