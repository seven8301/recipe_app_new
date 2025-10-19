import os
from typing import List
from fastapi import APIRouter
from pydantic import BaseModel
from core.mysql import SessionLocal
from sqlalchemy.orm import Session
from fastapi import Depends, HTTPException
from models.response import ResponseModel
from models.error import BusinessException
from services.recipe_service import RecipeService
from services.detection import FoodIngredientDetector
from  fastapi import Request

from services.recommend_service import RecipeRecommender

router = APIRouter()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

recipe_service = RecipeService()
detection_ingredient = FoodIngredientDetector()
recipe_recommender = RecipeRecommender()

class RecipeSearchRequest(BaseModel):
    ingredients: List[str]
    page: int = 1
    page_size: int = 5

class DetectionIngredients(BaseModel):
    ingredients_img:str

class RecipeListSearchRequest(BaseModel):
    page: int = 1
    page_size: int = 5

class RecommendationIngredients(BaseModel):
    ingredients:List[str]

@router.get("/recipeIngredients/{recipe_id}", response_model=ResponseModel)
def get_recipe_ingredients(request: Request, recipe_id: int, db: Session = Depends(get_db)):
    user_info = request.state.user
    user_id = request.state.user.get("user_id")
    recipe_ingredients = recipe_service.get_recipe_ingredients(recipe_id=recipe_id,user_id=user_id, db=db)
    if not recipe_ingredients:
        raise BusinessException(1013)
    recipe_service.add_recipe_view(user_id=user_info.get("user_id"), recipe_id=recipe_id, db=db)
    return ResponseModel.success_with_data(data=recipe_ingredients)


@router.post("/recipesByIngredients", response_model=ResponseModel)
def get_recipes_by_ingredients(request: Request, recipe_data: RecipeSearchRequest, db: Session = Depends(get_db)):
    user_id = request.state.user.get("user_id")
    recipes = recipe_service.get_recipes_by_ingredients(
        ingredients=recipe_data.ingredients,
        page=recipe_data.page,
        page_size=recipe_data.page_size,db=db)
    if not recipes:
        raise BusinessException(1014)
    recipe_service.add_ingredients_view(user_id=user_id,ingredients=recipe_data.ingredients,db=db)
    return ResponseModel.success_with_data(data=recipes)

@router.get("/recipesList", response_model=ResponseModel)
def get_recipes_list(page: int = 1,page_size: int = 5, db: Session = Depends(get_db)):
    recipes = recipe_service.get_recipes_list(page=page, page_size=page_size, db=db)
    if not recipes:
        raise BusinessException(1012)
    return ResponseModel.success_with_data(data=recipes)


@router.get("/ingredientsCategories", response_model=ResponseModel)
def get_ingredients_categories(db: Session = Depends(get_db)):
    categories = recipe_service.get_ingredients_categories(db=db)
    if not categories:
        raise BusinessException(1015)
    return ResponseModel.success_with_data(data=categories)

@router.get("/allIngredientsWithCategories", response_model=ResponseModel)
def get_all_ingredients_with_categories(db: Session = Depends(get_db)):
    categories = recipe_service.get_all_ingredients_with_categories(db=db)
    if not categories:
        raise BusinessException(1015)
    return ResponseModel.success_with_data(data=categories)

@router.post("/detectionIngredients", response_model=ResponseModel)
def detection_ingredients(request: DetectionIngredients):
    if not os.path.exists(request.ingredients_img):
        raise BusinessException(1000)
    recipe_ingredients = detection_ingredient.detect_image(image_path=request.ingredients_img)
    if not recipe_ingredients:
        raise BusinessException(1016)
    return ResponseModel.success_with_data(data=recipe_ingredients)


@router.post("/feedRecipe", response_model=ResponseModel)
def feed_recipe(request: Request,payload:RecommendationIngredients, db: Session = Depends(get_db)):
    user_id = request.state.user.get("user_id")
    data = recipe_recommender.get_recommendations(user_id=user_id,input_ingredients=payload.ingredients, db=db)
    if not data:
        raise BusinessException(1017)
    return ResponseModel.success_with_data(data={"recipes":data,"total":len(data)})


@router.get("/historyRecipes", response_model=ResponseModel)
def get_history_recipes(request: Request, db: Session = Depends(get_db)):
    user_id = request.state.user.get("user_id")
    history_recipes = recipe_service.get_history_recipes(user_id=user_id, db=db)
    if not history_recipes:
        raise BusinessException(1018)
    return ResponseModel.success_with_data(data=history_recipes)


@router.get("/collectRecipes", response_model=ResponseModel)
def get_history_recipes(request: Request, db: Session = Depends(get_db)):
    user_id = request.state.user.get("user_id")
    collect_recipes = recipe_service.get_collected_recipes(user_id=user_id, db=db)
    if not collect_recipes:
        raise BusinessException(1018)
    return ResponseModel.success_with_data(data=collect_recipes)


@router.get("/historyIngredients", response_model=ResponseModel)
def get_history_ingredients(request: Request, db: Session = Depends(get_db)):
    user_id = request.state.user.get("user_id")
    history_ingredients = recipe_service.get_history_ingredients(user_id=user_id, db=db)
    if not history_ingredients:
        raise BusinessException(1018)
    return ResponseModel.success_with_data(data=history_ingredients)