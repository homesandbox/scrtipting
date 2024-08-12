import logging
import sys
from loguru import logger
import json
import re
from app.config import settings

def obfuscate_message(message: str):
  result = re.sub(r"\d{4}-\d{4}-\d{4}-\d{4}", "<SENSITIVE>", message)
  return result

def serialize(record):
  subset = {
    "timestamp": record["time"].timestamp(),
    "name": record["name"],
    "message": obfuscate_message(record["message"]),
    "level": record["level"].name,
  }
  return json.dumps(subset)

class InterceptHandler(logging.Handler):
  def emit(self, record):
    logger_opt = logger.opt(depth=6, exception=record.exc_info)
    logger_opt.log(record.levelname, obfuscate_message(record.getMessage()))

logging.basicConfig(handlers=[InterceptHandler()], level=logging.getLevelName(settings.LOG_LEVEL), force=True)

def patching(record):
  record["extra"]["serialized"] = serialize(record)

logger.remove(0)
logger = logger.patch(patching)
logger.add(sys.stdout, format="{extra[serialized]}", level=settings.LOG_LEVEL, diagnose=False)
logger.add(settings.LOG_FILE, format="{extra[serialized]}", level=settings.LOG_LEVEL, rotation="10 MB", compression="zip", diagnose=False)

def get_logger(name: str):
  return logger.bind(name=name)
