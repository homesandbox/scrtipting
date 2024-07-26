from pydantic import BaseSettings
import os

class Settings(BaseSettings):
  APP_NAME: str
  HOST: str
  PORT: int
  LOG_LEVEL: str
  LOG_FILE: str

  class Config:
    env_file = os.getenv("ENV_FILE", "local.env")

settings = Settings()
