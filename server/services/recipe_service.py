from sqlalchemy.orm import Session
from models.ingredients_categories import IngredientsCategory
from models import RecipeIngredients, UserRecipe, UserIngredients, recipes, UserCollectRecipe
from models.recipes import Recipes
from models.ingredients import Ingredients
from pydantic import BaseModel
from typing import List, Optional, Any, Dict



class RecipeIngredientsVO(BaseModel):
    """Recipe ingredients list value object"""
    recipe_id: int
    recipe_name: str
    difficulty: str
    cook_time: str
    cook_steps: List[str]
    ingredients: List[str]
    is_collected: bool = False


class RecipeService:
    def __init__(self):
        pass

    def get_ingredients_by_category(self, category_id: int, db: Session):
        ingredients = db.query(Ingredients).filter(Ingredients.category_id == category_id).all()
        result = []
        for ingredient in ingredients:
            result.append({
                'id': ingredient.id,
                'ingredient_name': ingredient.ingredient_name
            })
        return result

    def get_all_ingredients_with_categories(self, db: Session):
        result = (db.query(
            Ingredients.id,
            Ingredients.ingredient_name,
            IngredientsCategory.name.label('category_name')).
                  filter(Ingredients.category_id != 0).
                  join(IngredientsCategory, Ingredients.category_id == IngredientsCategory.id
                       ).all())

        return [{
            'id': item.id,
            'ingredient_name': item.ingredient_name,
            'category_name': item.category_name
        } for item in result]

    def get_history_ingredients(self, user_id: int, db: Session):
        user_ingredients = (db.query(UserIngredients).
                            filter(UserIngredients.user_id == user_id).
                            order_by(UserIngredients.count.desc()).
                            all())
        result = []
        for user_ingredient in user_ingredients:
            result.append({
                'ingredient_name': user_ingredient.ingredient_name,
                'count': user_ingredient.count
            })
        return result

    def get_history_recipes(self, user_id: int, db: Session):
        user_recipes_ids = [row[0] for row in
                            db.query(UserRecipe.recipe_id, UserRecipe.count)
                            .filter(UserRecipe.user_id == user_id)
                            .order_by(UserRecipe.count.desc())
                            .distinct()
                            .all()]
        user_recipes = db.query(Recipes).filter(Recipes.id.in_(user_recipes_ids)).all()
        recipe_dict = {recipe.id: recipe for recipe in user_recipes}
        user_recipes_sorted = [recipe_dict[recipe_id] for recipe_id in user_recipes_ids if recipe_id in recipe_dict]
        recipe_list = []
        for recipe in user_recipes_sorted:
            all_ingredients = []
            for association in recipe.ingredient_associations:
                ingredient_info = {
                    "ingredient_name": association.ingredient.ingredient_name,
                    "quantity": association.quantity,
                    "unit": association.ingredient.ingredient_unit
                }
                all_ingredients.append(ingredient_info)

            recipe_list.append({
                "recipe_id": recipe.id,
                "recipe_name": recipe.recipe_name,
                "difficulty": recipe.difficulty,
                "cook_time": recipe.cook_time,
                "ingredients": all_ingredients,
            })
        return recipe_list

    def get_collected_recipes(self, user_id: int, db: Session):
        user_recipes_ids = [row[0] for row in
                            db.query(UserCollectRecipe.recipe_id, UserCollectRecipe.id)
                            .filter(UserCollectRecipe.user_id == user_id,
                                    UserCollectRecipe.is_collect == 1)
                            .order_by(UserCollectRecipe.id.desc())
                            .distinct()
                            .all()]
        if not user_recipes_ids:
            return []
        user_collect_recipes = db.query(Recipes).filter(Recipes.id.in_(user_recipes_ids)).all()
        recipe_list = []
        for recipe in user_collect_recipes:
            all_ingredients = []

            if hasattr(recipe, 'ingredient_associations'):
                for association in recipe.ingredient_associations:
                    ingredient_info = {
                        "ingredient_name": association.ingredient.ingredient_name,
                        "quantity": association.quantity,
                        "unit": association.ingredient.ingredient_unit
                    }
                    all_ingredients.append(ingredient_info)
            recipe_list.append({
                "recipe_id": recipe.id,
                "recipe_name": recipe.recipe_name,
                "difficulty": recipe.difficulty,
                "cook_time": recipe.cook_time,
                "ingredients": all_ingredients,
            })

        return recipe_list

    def get_ingredients_categories(self, db: Session):
        ingredients_categories = db.query(IngredientsCategory).all()
        return [{"id": category.id, "name": category.name} for category in ingredients_categories]

    def get_recipe_ingredients(self, recipe_id: int,user_id: int, db: Session):
        recipe = db.query(Recipes).filter(Recipes.id == recipe_id).first()
        if not recipe:
            return None
        ingredients = []
        for association in recipe.ingredient_associations:
            if association.quantity == 0:
                ingredientsStr = f"{association.ingredient.ingredient_name}"
            else:
                ingredientsStr = f"{association.quantity}"
                if association.ingredient.unit_need_space == 1:
                    ingredientsStr += f" {association.ingredient.ingredient_unit}"
                elif association.ingredient.unit_need_space == 2:
                    if association.ingredient.ingredient_unit is not None:
                        ingredientsStr += f"{association.ingredient.ingredient_unit}"
                ingredientsStr += f" {association.ingredient.ingredient_name}"
            ingredients.append(ingredientsStr)
        is_collected = self.get_is_collected(user_id=user_id, recipe_id=recipe_id, db=db)
        return RecipeIngredientsVO(
            recipe_id=recipe_id,
            recipe_name=str(recipe.recipe_name),
            difficulty=str(recipe.difficulty),
            cook_time=str(recipe.cook_time),
            cook_steps=recipe.cook_steps.split(','),
            ingredients=ingredients,
            is_collected=is_collected,
        )

    def get_is_collected(self, user_id: int, recipe_id: int, db: Session):
        user_collect_recipe = db.query(UserCollectRecipe).filter(
            UserCollectRecipe.user_id == user_id,
            UserCollectRecipe.recipe_id == recipe_id
        ).first()
        if user_collect_recipe:
            return user_collect_recipe.is_collect == 1
        else:
            return False

    def get_recipes_list(self, page: int, page_size: int, db: Session) -> Dict[str, Any]:
        try:

            offset = (page - 1) * page_size

            recipes = db.query(Recipes).offset(offset).limit(page_size).all()

            total = db.query(Recipes).count()

            recipe_list = []
            for recipe in recipes:
                all_ingredients = []
                for association in recipe.ingredient_associations:
                    ingredient_info = {
                        "ingredient_name": association.ingredient.ingredient_name,
                        "quantity": association.quantity,
                        "unit": association.ingredient.ingredient_unit
                    }
                    all_ingredients.append(ingredient_info)
                recipe_list.append({
                    "recipe_id": recipe.id,
                    "recipe_name": recipe.recipe_name,
                    "difficulty": recipe.difficulty,
                    "cook_time": recipe.cook_time,
                    "ingredients": all_ingredients,
                })
            return {
                "recipes": recipe_list,
                "total": total,
            }
        except Exception as e:
            print(f"Error getting recipe list: {e}")
            import traceback
            traceback.print_exc()
            return {
                "recipes": [],
                "total": 0,
            }

    def get_recipes_by_ingredients(
            self,
            ingredients: List[str],
            page: int,
            page_size: int,
            db: Session
    ) -> Dict[str, Any]:
        if not ingredients:
            return {
                "recipes": [],
                "total": 0,
                "page": page,
                "page_size": page_size,
                "total_pages": 0
            }
        try:

            offset = (page - 1) * page_size

            base_query = (db.query(Recipes)
                          .join(RecipeIngredients, Recipes.id == RecipeIngredients.recipe_id)
                          .join(Ingredients, RecipeIngredients.ingredient_id == Ingredients.id)
                          .filter(Ingredients.ingredient_name.in_(ingredients)))

            total = base_query.distinct(Recipes.id).count()

            recipes = (base_query.distinct(Recipes.id)
                       .offset(offset)
                       .limit(page_size)
                       .all())
            print(f"total recipes:{total}")

            recipe_list = []
            for recipe in recipes:

                all_ingredients = []
                matched_ingredients = []

                for association in recipe.ingredient_associations:
                    ingredient_info = {
                        "ingredient_name": association.ingredient.ingredient_name,
                        "quantity": association.quantity,
                        "unit": association.ingredient.ingredient_unit
                    }
                    all_ingredients.append(ingredient_info)

                    if association.ingredient.ingredient_name in ingredients:
                        matched_ingredients.append(ingredient_info)


                match_ratio = len(matched_ingredients) / len(all_ingredients) if all_ingredients else 0

                recipe_list.append({
                    "recipe_id": recipe.id,
                    "recipe_name": recipe.recipe_name,
                    "difficulty": recipe.difficulty,
                    "cook_time": recipe.cook_time,
                    "match_ratio": match_ratio,
                })

            return {
                "recipes": recipe_list,
                "total": total,
                "page": page,
                "page_size": page_size,
            }

        except Exception as e:
            print(f"Error searching recipes: {e}")
            import traceback
            traceback.print_exc()
            return {
                "recipes": [],
                "total": 0,
                "page": page,
                "page_size": page_size,
                "total_pages": 0
            }

    def add_recipe_view(self, user_id: int, recipe_id: int, db: Session):

        user_recipe = db.query(UserRecipe).filter(
            UserRecipe.user_id == user_id,
            UserRecipe.recipe_id == recipe_id
        ).first()
        if user_recipe:
            user_recipe.count += 1
        else:
            user_recipe = UserRecipe(user_id=user_id, recipe_id=recipe_id, count=1)
            db.add(user_recipe)
        db.commit()

        #     db.refresh(user_recipe)
        return

    def add_ingredients_view(self, user_id: int, ingredients: List[str], db: Session):
        if not ingredients:
            return
        ingredients_records = db.query(Ingredients).filter(Ingredients.ingredient_name.in_(ingredients)).all()
        ingredients_dict = {ingredient.ingredient_name: ingredient.id for ingredient in ingredients_records}
        existing_records = db.query(UserIngredients).filter(
            UserIngredients.user_id == user_id,
            UserIngredients.ingredient_name.in_(ingredients)
        ).all()
        existing_dict = {record.ingredient_name: record for record in existing_records}

        for record in existing_records:
            record.count += 1

        need_ingredients = []
        for ingredient_name in ingredients:
            if ingredient_name not in existing_dict:
                if ingredient_name in ingredients_dict:
                    need_ingredients.append(UserIngredients(
                        user_id=user_id,
                        ingredient_name=str(ingredient_name),
                        ingredient_id=int(ingredients_dict[str(ingredient_name)]),
                        count=1
                    ))

        if need_ingredients:
            db.add_all(need_ingredients)

        db.commit()
        return