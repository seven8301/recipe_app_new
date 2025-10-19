from typing import List, Optional

from sqlalchemy import Column, Integer, Text, String

from models import BaseModel
from pydantic import BaseModel as ModelBase

class User(BaseModel):
    __tablename__ = "re_users"
    username = Column(String(50),nullable=False, unique=True)
    nickname = Column(String(50),nullable=False, unique=True)
    email = Column(String(100),nullable=False)
    gender = Column(String(10),nullable=False)
    password = Column(String(100),nullable=False)
    birthday = Column(String(100),nullable=False)
    food_preferences = Column(String(100),nullable=False) # user ',' separated food food_preferences

class TokenData(BaseModel):
    __abstract__ = True
    user_id = Column(Integer,nullable=False)
    username = Column(String(50),nullable=False)

class UserSignUp(ModelBase):
    username: str
    nickname: str
    email: str
    password: str
    gender: str
    birthday: str
    food_preferences: List[str] = []