import asyncio

from httpx import ASGITransport, AsyncClient, Response

from app.core.config import Settings
from app.main import create_app


def request(path: str, settings: Settings | None = None) -> Response:
    async def send_request() -> Response:
        app_settings = settings or Settings(
            environment="test",
            allowed_hosts=["testserver"],
            docs_enabled=True,
        )
        transport = ASGITransport(app=create_app(app_settings))
        async with AsyncClient(transport=transport, base_url="http://testserver") as client:
            return await client.get(path)

    return asyncio.run(send_request())


def test_health_check() -> None:
    response = request("/health")

    assert response.status_code == 200
    assert response.json() == {"data": {"status": "ok"}}


def test_capabilities_declares_local_first_storage() -> None:
    response = request("/api/v1/capabilities")

    assert response.status_code == 200
    assert response.json()["data"]["storage_policy"] == "local_first"
    assert response.json()["data"]["persistent_user_data"] == []


def test_production_disables_api_docs() -> None:
    settings = Settings(
        environment="production",
        allowed_hosts=["testserver"],
        docs_enabled=True,
    )
    assert request("/docs", settings).status_code == 404
    assert request("/openapi.json", settings).status_code == 404
