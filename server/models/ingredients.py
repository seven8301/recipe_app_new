from sqlalchemy import Column, Integer, Text, String, ForeignKey
from .base import BaseModel
from sqlalchemy.orm import relationship


class Ingredients(BaseModel):
    __tablename__ = "re_ingredients"
    ingredient_name = Column(String(100), nullable=False)
    ingredient_unit = Column(String(100), nullable=True)
    unit_need_space = Column(Integer, nullable=False)
    category_id = Column(Integer,nullable=False)

    recipe_associations = relationship("RecipeIngredients", back_populates="ingredient")