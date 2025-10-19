from core.mysql import engine, Base
from .base import BaseModel
from .recipes import Recipes
from .ingredients import Ingredients
from .rece_ingredients import RecipeIngredients
from .ingredients_categories import IngredientsCategory
from .user import User
from .user_recipe_view import UserRecipe
from .user_ingredients_view import UserIngredients
from .user_collect_recipe import UserCollectRecipe


__all__ = ["BaseModel", "Recipes", "Ingredients","IngredientsCategory", "RecipeIngredients", "User", "UserRecipe", "UserIngredients","UserCollectRecipe"]
Base.metadata.create_all(bind=engine)