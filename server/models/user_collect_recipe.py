from sqlalchemy import Column, Integer, Text, String, ForeignKey
from .base import BaseModel
from sqlalchemy.orm import relationship

# user collect recipe model
class UserCollectRecipe(BaseModel):
    __tablename__ = "re_user_collect_recipe"
    user_id = Column(Integer, ForeignKey('re_users.id'), nullable=False)
    recipe_id = Column(Integer, ForeignKey('re_recipes.id'), nullable=False)
    is_collect = Column(Integer,nullable=False)  #is_collect=1 means collected, is_collect=0 means not collected