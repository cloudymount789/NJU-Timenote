from fastapi import FastAPI
from starlette.middleware.trustedhost import TrustedHostMiddleware

from app.api.router import api_router, public_router
from app.core.config import Settings, get_settings


def create_app(settings: Settings | None = None) -> FastAPI:
    app_settings = settings or get_settings()
    docs_url = "/docs" if app_settings.expose_docs else None
    openapi_url = "/openapi.json" if app_settings.expose_docs else None

    application = FastAPI(
        title="NJU Timenote Backend",
        description="Optional remote services for the local-first NJU Timenote app.",
        version="0.1.0",
        debug=False,
        docs_url=docs_url,
        redoc_url=None,
        openapi_url=openapi_url,
    )
    application.add_middleware(
        TrustedHostMiddleware,
        allowed_hosts=app_settings.allowed_hosts,
    )
    application.include_router(public_router)
    application.include_router(api_router)
    return application


app = create_app()
