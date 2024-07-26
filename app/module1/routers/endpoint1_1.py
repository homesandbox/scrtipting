from fastapi import APIRouter, HTTPException
from app.module1.routers import logger
from app.module1.services import service1_1

router = APIRouter()

@router.get("/endpoint1")
async def endpoint1():
  try:
    card: str = "1234-5678-9012-3456"
    result = service1_1.do_something(card)
    logger.info(f"Module1 Endpoint1 result: {result}")
    return result
  except Exception as e:
    logger.error(f"Error in module1 endpoint1: {e}")
    raise HTTPException(status_code=500, detail="Internal Server Error")
