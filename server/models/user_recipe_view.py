from sqlalchemy import Column, Integer, Text, String, ForeignKey
from .base import BaseModel
from sqlalchemy.orm import relationship


class UserRecipe(BaseModel):
    __tablename__ = "re_user_recipes"
    user_id = Column(Integer, ForeignKey('re_users.id'), nullable=False)
    recipe_id = Column(Integer, ForeignKey('re_recipes.id'), nullable=False)
    count = Column(Integer, nullable=False)