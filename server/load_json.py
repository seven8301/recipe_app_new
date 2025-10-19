from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base
from typing import List, Dict, Any
from models import Recipes, RecipeIngredients, Ingredients, UserIngredients
import json

SQLALCHEMY_DATABASE_URL = "mysql+pymysql://root:123456@127.0.0.1:3306/rec-app"
engine = create_engine(SQLALCHEMY_DATABASE_URL, echo=False)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

base_instance = {
    "beef":1,
    "butter":2,
    "capsicum":3,
    "carrot":4,
    "chicken breast":5,
    "egg":6,
    "onion":7,
    "potatoes":8,
    "shrimp":9,
    "tofu":10,
    "tomatoes":11,
    "rice":12,
}

def get_db_session():
    """get data"""
    db = SessionLocal()
    try:
        return db
    finally:
        db.close()

def read_recipe_from_file(filename):
    """get data from file"""
    try:
        with open(filename, 'r', encoding='utf-8') as file:
            data = json.load(file)
            return data
    except FileNotFoundError:
        print(f"file {filename} does not exist")
        return None
    except json.JSONDecodeError:
        print("JSON format error")
        return None

def print_recipe_info(recipe_data, db: SessionLocal):
    """Print and save the recipe information"""
    if not recipe_data:
        print("No recipe data")
        return
    for recipe in recipe_data:
        try:
            print(f"name: {recipe['title']}")


            ingredients_ids = process_ingredients(recipe['normalized_ingredients'], db)


            recipe_steps = ",".join(recipe['steps']) if isinstance(recipe['steps'], list) else recipe['steps']


            recipe_obj = Recipes(
                recipe_name=recipe['title'],
                difficulty="easy",
                cook_time=f"{recipe.get('prep_time_min', 0)} min",
                cook_steps=recipe_steps
            )
            db.add(recipe_obj)
            db.flush()


            create_recipe_ingredient_associations(recipe_obj.id, ingredients_ids, db)


            db.commit()

            print(f"Successfully saved the recipe: {recipe['title']}")
            print("=" * 50)
            print()

        except Exception as e:
            db.rollback()
            print(f"When procrss the recipe '{recipe['title']}' an error occurred: {str(e)}")
            continue


def process_ingredients(normalized_ingredients, db):
    """Process the list of ingredients and return the list of ingredient IDs"""
    ingredients_ids = []

    for ingredient in normalized_ingredients:
        ingredient_found = False


        for key, value in base_instance.items():
            if key in ingredient:
                ingredients_ids.append(value)
                ingredient_found = True
                break


        if not ingredient_found:
            try:
                ingredient_obj = Ingredients(
                    ingredient_name=ingredient,
                    unit_need_space=2,
                    category_id=0
                )
                db.add(ingredient_obj)
                db.flush()


                base_instance[ingredient] = ingredient_obj.id
                ingredients_ids.append(ingredient_obj.id)

            except Exception as e:
                print(f"when creat ingredient '{ingredient}' an error occurred: {str(e)}")
                continue

    return ingredients_ids

def create_recipe_ingredient_associations(recipe_id, ingredients_ids, db):
    """Create recipe - Ingredient association relationship"""
    for ingredient_id in ingredients_ids:
        try:
            recipe_ingredient = RecipeIngredients(
                recipe_id=recipe_id,
                ingredient_id=ingredient_id,
                quantity=0
            )
            db.add(recipe_ingredient)
        except Exception as e:
            print(f"Error creating recipe-ingredient association (Recipe ID: {recipe_id}, Ingredient ID: {ingredient_id}): {str(e)}")
            continue

def create_base_ingredients(db):
    """Disable foreign key constraints, clear table and recreate base ingredients"""
    try:

        db.execute(text("SET FOREIGN_KEY_CHECKS = 0"))


        db.execute(text("TRUNCATE TABLE re_ingredients"))


        db.execute(text("SET FOREIGN_KEY_CHECKS = 1"))


        for key, value in base_instance.items():
            ingredient = Ingredients(
                id=value,
                ingredient_name=key,
                unit_need_space=2,
                category_id=0
            )
            db.add(ingredient)

        db.commit()
        print("Base ingredients creation completed")

    except Exception as e:
        db.rollback()

        db.execute(text("SET FOREIGN_KEY_CHECKS = 1"))
        print(f"Error creating base ingredients: {str(e)}")

if __name__ == '__main__':
    data = read_recipe_from_file("./fridge_recipes.recipes.json")
    db = get_db_session()
    create_base_ingredients(db)
    print_recipe_info(data,db)
