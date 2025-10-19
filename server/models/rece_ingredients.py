from sqlalchemy import Column, Integer, String, Text, ForeignKey
from sqlalchemy.orm import relationship
from .base import BaseModel


class RecipeIngredients(BaseModel):
    __tablename__ = "re_recipe_ingredients"
    recipe_id = Column(Integer, ForeignKey('re_recipes.id'), nullable=False)
    ingredient_id = Column(Integer, ForeignKey('re_ingredients.id'), nullable=False)
    quantity = Column(Integer, nullable=False)


    recipe = relationship("Recipes", back_populates="ingredient_associations")
    ingredient = relationship("Ingredients", back_populates="recipe_associations")