from app.module1.services import logger

def do_something(card: str = None):
  logger.debug(f"Doing something in module1 service1, card: {card}")
  return {"result": "Module1 Service1 action"}
