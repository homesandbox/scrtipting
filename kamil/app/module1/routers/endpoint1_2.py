from fastapi import APIRouter, HTTPException
from app.module1.routers import logger
from app.module1.services import service1_2

router = APIRouter()

@router.get("/endpoint2")
async def endpoint2():
  try:
    result = service1_2.do_something_else()
    logger.info(f"Endpoint2 result: {result}")
    return result
  except Exception as e:
    logger.error(f"Error in endpoint2: {e}")
    raise HTTPException(status_code=500, detail="Internal Server Error")
