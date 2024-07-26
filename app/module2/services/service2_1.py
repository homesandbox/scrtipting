from app.logging_config import logger

def do_something():
  logger.debug("Doing something else in module2 service1")
  return {"result": "Module2 Service1 action"}
