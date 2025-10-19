from sqlalchemy import Column, Integer, Text, String
from .base import BaseModel
from sqlalchemy.orm import relationship

class Recipes(BaseModel):
    __tablename__ = "re_recipes"
    recipe_name = Column(String(100), nullable=False)
    difficulty = Column(String(100), nullable=False)
    cook_time = Column(String(100), nullable=False)
    cook_steps = Column(Text, nullable=False)


    ingredient_associations = relationship("RecipeIngredients", back_populates="recipe")