from fastapi import APIRouter, HTTPException
from app.module2.routers import logger
from app.module2.services import service2_1

router = APIRouter()

@router.get("/endpoint1")
async def endpoint1():
  try:
    result = service2_1.do_something()
    logger.info(f"Module2 Endpoint1 result: {result}")
    return result
  except Exception as e:
    logger.error(f"Error in module2 endpoint1: {e}")
    raise HTTPException(status_code=500, detail="Internal Server Error")
