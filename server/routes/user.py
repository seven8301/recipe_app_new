from typing import List, Optional

from fastapi import APIRouter
from pydantic import BaseModel
from core.mysql import SessionLocal
from sqlalchemy.orm import Session
from fastapi import Depends, HTTPException

from models import User
from models.error import BusinessException
from models.response import ResponseModel
from models.user import UserSignUp
from services.user_service import UserService
from utils.auth_token import TokenUtils
from fastapi import Request

from utils.date_convert import calculate_age

router = APIRouter()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
user_service = UserService()

class UserLoginRequest(BaseModel):
    username: str
    password: str

class UpdateProfileRequest(BaseModel):
    nickname: str
    gender: str
    birthday: str
    email: str
    food_preferences: str

class SignUpUserInfo(BaseModel):
    username: str
    nickname: str
    email: str
    password: str
    gender: str
    birthday: str
    food_preferences:List[str]

class UserCollectRecipe(BaseModel):
    recipe_id: int
    is_collect: bool

@router.post("/login", response_model=ResponseModel)
def auth_login(request: UserLoginRequest, db: Session = Depends(get_db)):
    user = user_service.user_login(db, request.username, request.password)
    if user:
        token_data = TokenUtils.create_user_token(user.id, user.username)
        return ResponseModel.success_with_data(data={
            "access_token": token_data,
            "token_type": "bearer"
        })
    else:
        return ResponseModel.common_error(message="invalid username or password")

@router.get("/me")
async def read_users_me(request: Request, db: Session = Depends(get_db)):
    user_info = request.state.user
    user = user_service.get_user(db, user_info.get("user_id"))
    if not user:
        raise BusinessException(status_code=1000)
    user_recipe_count, user_ingredient_count = user_service.count_user_recipesAndIngredients(db, user.id)
    user_collect_recipes = user_service.count_user_collect_recipes(db, user.id)
    return ResponseModel.success_with_data(data= {
        "nickname": user.nickname,
        "email": user.email,
        "gender": user.gender,
        "birthday": str(calculate_age(user.birthday)),
        "user_recipe_count": user_recipe_count,
        "user_ingredient_count": user_ingredient_count,
        "user_collect_recipe_count": user_collect_recipes,
        "food_preferences": user.food_preferences
    })

@router.post("/signup")
async def signup(request: Request,userInfo:SignUpUserInfo, db: Session = Depends(get_db)):
    try:
        if userInfo.food_preferences is None or userInfo.food_preferences == []:
             raise BusinessException(status_code=1000)
        result = user_service.sign_up(
            db,
            UserSignUp(
                username=userInfo.username,
                nickname=userInfo.nickname,
                email=userInfo.email,
                password=userInfo.password,
                gender=userInfo.gender,
                birthday=userInfo.birthday,
                food_preferences=userInfo.food_preferences
            )
        )
        if result:
            return ResponseModel.common_error(message=result)
        else:
            return ResponseModel.success_no_data()
    except BusinessException as e:
        raise e
    except Exception as e:
        raise BusinessException(
            status_code=getattr(e, "status_code", 500),
            detail=getattr(e, "detail", f"Sign up error: {str(e)}")
        )

@router.post("/updateProfile")
async def update_profile(request: Request,profile: UpdateProfileRequest, db: Session = Depends(get_db)):
    user_info = request.state.user
    user = user_service.get_user(db, user_info.get("user_id"))
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    user_service.update_user(db, User(
        id=user.id,
        nickname=profile.nickname,
        gender=profile.gender,
        birthday=profile.birthday,
        email=profile.email,
        food_preferences=profile.food_preferences
    ))
    return ResponseModel.success_no_data()

@router.post("/collectRecipe")
async def collect_recipe(request: Request,payload: UserCollectRecipe, db: Session = Depends(get_db)):
    user_info = request.state.user
    user = user_service.get_user(db, user_info.get("user_id"))
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    user_service.collect_or_cancelCollect_recipe(db,user_id=user.id,recipe_id=payload.recipe_id,is_collect=payload.is_collect)
    return ResponseModel.success_no_data()