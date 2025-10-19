from sqlalchemy import Column, Integer, Text, String, ForeignKey
from .base import BaseModel
from sqlalchemy.orm import relationship


class UserIngredients(BaseModel):
    __tablename__ = "re_user_ingredients"
    user_id = Column(Integer, ForeignKey('re_users.id'), nullable=False)
    ingredient_id = Column(Integer, ForeignKey('re_ingredients.id'), nullable=False)
    ingredient_name = Column(String(50), nullable=False)
    count = Column(Integer, nullable=False)