import hashlib
import logging
from datetime import datetime

from sqlalchemy.orm import Session
from models import User, UserRecipe, UserIngredients, UserCollectRecipe
from sqlalchemy import func

from models.user import UserSignUp


class UserService:
    def __init__(self):
        pass

    def user_login(self, session: Session, username: str, password: str):
        user = session.query(User).filter(User.username == username).first()
        if not user:
            return None
        if not self.check_password(password,str(user.password)):
            return None
        return user

    def get_user(self, session: Session, user_id: int):
        return session.query(User).filter(User.id == user_id).first()

    def sign_up(self, session: Session, user: UserSignUp):
        # check if username or email already exist
        if session.query(User).filter(User.username == user.username).first():
            return "username already exist"
        if session.query(User).filter(User.email == user.email).first():
            return "email already exist"
        hashed_password = self.hash_password(user.password)
        food_preferences_str = ','.join(user.food_preferences)
        db_user = User(
            username=user.username,
            nickname=user.nickname,
            email=user.email,
            birthday=user.birthday,
            password=hashed_password,
            gender=user.gender,
            food_preferences=food_preferences_str
        )
        session.add(db_user)
        session.commit()
        return None

    def update_user(self, session: Session, user:User):
        """Update only age and email fields"""
        birthday_str = user.birthday
        if isinstance(user.birthday, str) and user.birthday.isdigit():
            age = int(user.birthday)
            current_date = datetime.now()
            birthday_date = current_date.replace(year=current_date.year - age)
            birthday_str = birthday_date.strftime('%Y-%m-%d')
        session.query(User).filter(User.id == user.id).update({
            "nickname": user.nickname,
            "email": user.email,
            "gender": user.gender,
            "birthday": birthday_str,
            "food_preferences": user.food_preferences
        })
        session.commit()
        return

    def collect_or_cancelCollect_recipe(self, session: Session, user_id: int, recipe_id: int, is_collect: bool):
        try:
            user_collect = (session.query(UserCollectRecipe)
                            .filter(UserCollectRecipe.user_id == user_id,
                                    UserCollectRecipe.recipe_id == recipe_id)
                            .first())
            if not is_collect:
                if user_collect:
                    user_collect.is_collect = 0
                    session.commit()
                    return True
                else:
                    return False

            if user_collect:
                if user_collect.is_collect == 1:
                    return True
                else:
                    user_collect.is_collect = 1
                    session.commit()
                    return True
            else:
                user_collect = UserCollectRecipe(
                    user_id=user_id,
                    recipe_id=recipe_id,
                    is_collect=1
                )
                session.add(user_collect)
                session.commit()
                return True
        except Exception as e:
            logging.error(e)
            session.rollback()
            return False

    def hash_password(self, password):
        return hashlib.md5(password.encode('utf-8')).hexdigest()

    def count_user_recipesAndIngredients(self, session: Session, user_id: int):
        user_recipe = (session.query(func.sum(UserRecipe.count))
                       .filter(UserRecipe.user_id == user_id)
                       .scalar())
        user_ingredients = (session.query(func.sum(UserIngredients.count))
                       .filter(UserIngredients.user_id == user_id)
                       .scalar())
        return user_recipe, user_ingredients

    def count_user_collect_recipes(self, session: Session, user_id: int):
        user_collect_recipes = (session.query(func.count(UserCollectRecipe.id))
                       .filter(UserCollectRecipe.user_id == user_id,
                                UserCollectRecipe.is_collect == 1)
                       .scalar())
        return user_collect_recipes


    def check_password(self,input_password:str, hashed_password:str) -> bool:
        input_md5 = hashlib.md5(input_password.encode('utf-8')).hexdigest()
        print("username:",input_md5)
        print("hashed_password", hashed_password)
        return input_md5.lower() == hashed_password.lower()