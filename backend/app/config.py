from pydantic_settings import BaseSettings
from functools import lru_cache

class Settings(BaseSettings):
    database_url: str
    aws_access_key_id: str
    aws_secret_access_key: str
    aws_region: str = "us-east-1"
    app_env: str = "development"
    app_name: str = "AWS Infrastructure Tracker"

    model_config = {
        "env_file": ".env",
        "case_sensitive": False,
        "extra": "ignore"
    }

@lru_cache()
def get_settings() -> Settings:
    return Settings()
