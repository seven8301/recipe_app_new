from sqlalchemy import Column, Integer, Text, String, ForeignKey
from .base import BaseModel


class IngredientsCategory(BaseModel):
    __tablename__ = "re_ingredient_categories"
    name = Column(String(255), nullable=False)