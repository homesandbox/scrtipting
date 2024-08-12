from app.module1.services import logger

@logger.catch
def do_something_else():
  50/0
  return {"result": "Module1 Service2 action"}
