from fastapi import FastAPI
from app.module1.routers import endpoint1_1 as module1_endpoint1, endpoint1_2 as module1_endpoint2
from app.module2.routers import endpoint2_1 as module2_endpoint1
from app.logging_config import get_logger
from app.config import settings

logger = get_logger(__name__)

app = FastAPI(title=settings.APP_NAME)

app.include_router(module1_endpoint1.router, prefix="/module1")
app.include_router(module1_endpoint2.router, prefix="/module1")
app.include_router(module2_endpoint1.router, prefix="/module2")

@app.on_event("startup")
async def startup_event():
    logger.info(f"Starting up {settings.APP_NAME}")

@app.on_event("shutdown")
async def shutdown_event():
    logger.info(f"Shutting down {settings.APP_NAME}")

@app.get("/")
async def read_root():
    logger.debug("Root endpoint called")
    return {"message": "Welcome to the FastAPI application"}
