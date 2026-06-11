from functools import lru_cache
from typing import Literal

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_prefix="NJUT_",
        extra="ignore",
    )

    environment: Literal["development", "test", "production"] = "development"
    allowed_hosts: list[str] = Field(
        default_factory=lambda: ["localhost", "127.0.0.1", "testserver"]
    )
    docs_enabled: bool = True

    @property
    def expose_docs(self) -> bool:
        return self.docs_enabled and self.environment != "production"


@lru_cache
def get_settings() -> Settings:
    return Settings()
