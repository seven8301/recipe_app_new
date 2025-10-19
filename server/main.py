import os
import uuid
from pathlib import Path
import uvicorn
from fastapi import FastAPI, Request, UploadFile, File, HTTPException
from fastapi.responses import JSONResponse
from models.response import ResponseModel
from models.error import BusinessException
from routes.recipe import router as recipe_router
from routes.user import router as user_router
from utils.auth_token import TokenUtils

app = FastAPI()

async def http_exception_handler(request: Request, exc: BusinessException):
    return JSONResponse(
        status_code=200,
        content={
            "code": exc.status_code,
            "message": exc.detail,
            "data":None
        }
    )
app.add_exception_handler(BusinessException, http_exception_handler)

@app.middleware("http")
async def auth_middleware(request: Request, call_next):
    if request.url.path in ["/auth/login","/auth/signup"]:
        response = await call_next(request)
        return response
    # check Authorization header
    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
       return JSONResponse(
           status_code=200,
           content={
               "code": 1001,
               "message": "Not found Authorization header"
           }
       )
    token = auth_header.replace("Bearer ", "")
    payload = TokenUtils.verify_token(token)
    if not payload:
        return JSONResponse(
            status_code=200,
            content={
                "code": 1001,
                "message": "Token is invalid or expired"
            }
        )
    request.state.user = payload
    response = await call_next(request)
    return response

@app.get("/test")
def test_route():
    return {"message": "Test route is working", "status": "success"}

app.include_router(recipe_router, prefix="/recipe", tags=["recipe"])
app.include_router(user_router, prefix="/auth", tags=["user"])

# make sure the upload directory exists
UPLOAD_DIR = Path("uploads")
UPLOAD_DIR.mkdir(exist_ok=True)
ALLOWED_IMAGE_EXTENSIONS = {
    '.jpg', '.jpeg', '.png'
}

def is_image_file(file: UploadFile) -> bool:
    file_extension = os.path.splitext(file.filename)[1].lower()
    if file_extension not in ALLOWED_IMAGE_EXTENSIONS:
        return False
    return True

@app.post("/upload")
async def upload_file(file: UploadFile = File(...)):
    try:
        if not is_image_file(file):
            raise BusinessException(1000)
        file_extension = os.path.splitext(file.filename)[1]
        unique_filename = f"{uuid.uuid4().hex}{file_extension}"
        file_path = UPLOAD_DIR / unique_filename
        contents = await file.read()
        with open(file_path, "wb") as f:
            f.write(contents)
        return ResponseModel.success_with_data(data={"filename": os.path.abspath(file_path)})
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"file uploaded failed: {str(e)}")

if __name__ == "__main__":
    print("🎯 starting FastAPI server...")
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=7777,
        reload=True,
        log_level="debug",
        access_log=True
    )