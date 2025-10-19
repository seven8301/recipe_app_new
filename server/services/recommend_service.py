from typing import List, Dict, Any, Counter

import pandas as pd
import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.preprocessing import MinMaxScaler
from sqlalchemy import func
from sqlalchemy.orm import Session

from models import Ingredients, UserRecipe, RecipeIngredients, Recipes, UserIngredients, UserCollectRecipe


class RecipeRecommender:
    def __init__(self):
        self.vectorizer = TfidfVectorizer(stop_words='english')
        self.scaler = MinMaxScaler()

    def get_user_history_recipes(self, user_id: int, db: Session):
        user_recipes = db.query(UserRecipe).filter(UserRecipe.user_id == user_id).all()
        user_recipes_ids = [{'id': ur.recipe_id, 'count': ur.count} for ur in user_recipes]
        return user_recipes_ids

    def get_user_history_ingredients(self, user_id: int, db: Session):
        user_ingredients = db.query(UserIngredients).filter(UserIngredients.user_id == user_id).all()
        user_ingredients_ids = [{'id': ui.ingredient_id, 'count': ui.count} for ui in user_ingredients]
        return user_ingredients_ids

    def get_user_collection_recipes(self, user_id: int, db: Session):
        user_recipes_ids = [row[0] for row in
                            db.query(UserCollectRecipe.recipe_id, UserCollectRecipe.id)
                            .filter(UserCollectRecipe.user_id == user_id,
                                    UserCollectRecipe.is_collect == 1)
                            .order_by(UserCollectRecipe.id.desc())
                            .distinct()
                            .all()]
        return user_recipes_ids

    def get_user_preference_ingredients(self, user_id: int, db: Session):
        """Extract preferred ingredients based on user's collected recipes"""
        collected_recipe_ids = self.get_user_collection_recipes(user_id, db)

        if not collected_recipe_ids:
            return []

        # Collect all ingredients from user's favorite recipes
        preference_ingredients = []
        for recipe_id in collected_recipe_ids:
            recipe = db.query(Recipes).filter(Recipes.id == recipe_id).first()
            if recipe:
                for association in recipe.ingredient_associations:
                    preference_ingredients.append(association.ingredient.ingredient_name)

        # Count ingredient frequency
        ingredient_counter = Counter(preference_ingredients)

        return [ingredient for ingredient, count in ingredient_counter.most_common(10)]

    def get_sample_recipes(self, ingredients: List[str], db: Session):
        """Get candidate recipes based on ingredients"""
        base_query = (db.query(Recipes)
                      .join(RecipeIngredients, Recipes.id == RecipeIngredients.recipe_id)
                      .join(Ingredients, RecipeIngredients.ingredient_id == Ingredients.id)
                      .filter(Ingredients.ingredient_name.in_(ingredients)))
        recipes = (base_query.distinct(Recipes.id).all())
        recipe_list = []
        for recipe in recipes:
            all_ingredients = []
            for association in recipe.ingredient_associations:
                all_ingredients.append(association.ingredient.ingredient_name)
            recipe_list.append({
                "recipe_id": recipe.id,
                "recipe_name": recipe.recipe_name,
                "difficulty": recipe.difficulty,
                "cook_time": recipe.cook_time,
                "ingredients": all_ingredients,
            })
        return recipe_list

    def recommend_recipes(self, user_id: int, input_ingredients: List[str], db: Session, top_n: int = 5) -> List[
        Dict[str, Any]]:
        """
        Recipe recommendation algorithm
        Weight allocation:
        - Collection preference (30%): Based on matching between user preferred ingredients and recipe ingredients
        - Selected ingredients (60%): Based on user input ingredients matching
        - Historical behavior (10%): Based on user browsed ingredients and recipe counts
        """

        user_history_recipes = self.get_user_history_recipes(user_id, db)
        user_history_ingredients = self.get_user_history_ingredients(user_id, db)
        user_preference_ingredients = self.get_user_preference_ingredients(user_id, db)

        user_recipe_ids = [item['id'] for item in user_history_recipes]
        user_recipe_counts = {item['id']: item['count'] for item in user_history_recipes}
        user_ingredient_ids = [item['id'] for item in user_history_ingredients]
        user_ingredient_counts = {item['id']: item['count'] for item in user_history_ingredients}

        # Combine input ingredients with user preferences
        all_ingredients = list(set(input_ingredients + user_preference_ingredients))
        candidate_recipes = self.get_sample_recipes(all_ingredients, db)

        candidate_recipes_ids = [recipe['recipe_id'] for recipe in candidate_recipes]
        print(f"candidate_recipes_ids: {candidate_recipes_ids}")
        if not candidate_recipes:
            return []

        # Calculate recommendation scores
        recommendations = self._calculate_recommendations(
            candidate_recipes,
            user_recipe_ids,
            user_recipe_counts,
            user_preference_ingredients,
            input_ingredients,
            user_ingredient_ids,
            user_ingredient_counts
        )

        # Sort by match ratio and return top N
        recommendations.sort(key=lambda x: x['match_ratio'], reverse=True)
        return recommendations[:top_n]

    def _calculate_recommendations(self, candidate_recipes: List[Dict],
                                   user_recipe_ids: List[int],
                                   user_recipe_counts: Dict[int, int],
                                   user_preferences: List[str],
                                   input_ingredients: List[str],
                                   user_ingredient_ids: List[int],
                                   user_ingredient_counts: Dict[int, int]) -> List[Dict]:
        """
        Calculate recommendation scores - according to new weight allocation
        """
        recommendations = []

        for recipe in candidate_recipes:
            # Calculate preference score based on user's favorite ingredients
            preference_score = self._calculate_preference_score(
                recipe['ingredients'], user_preferences
            )

            # Calculate input ingredient matching score
            input_score = self._calculate_input_ingredient_score(
                recipe['ingredients'], input_ingredients
            )

            # Calculate historical behavior score
            history_score = self._calculate_history_score(
                recipe['recipe_id'],
                user_recipe_ids,
                user_recipe_counts,
                recipe['ingredients'],
                user_ingredient_ids,
                user_ingredient_counts
            )

            # Calculate weighted total score
            total_score = (
                    preference_score * 0.3 +
                    input_score * 0.6 +
                    history_score * 0.1
            )

            recipe['match_ratio'] = total_score
            recipe['preference_score'] = preference_score
            recipe['input_score'] = input_score
            recipe['history_score'] = history_score

            # Format ingredients for return
            return_ingredients = []
            for ingredient in recipe['ingredients']:
                return_ingredients.append({
                    'ingredient_name': ingredient,
                    'quantity': 0,
                    'unit': ""
                })
            recipe["ingredients"] = return_ingredients
            recommendations.append(recipe)

        return recommendations

    def _calculate_preference_score(self, recipe_ingredients: List[str],
                                    user_preferences: List[str]) -> float:
        """Calculate collection preference score (30%)"""
        if not user_preferences:
            return 0.0

        recipe_set = set(recipe_ingredients)
        preference_set = set(user_preferences)

        # Calculate matched preferences
        matched_preferences = len(recipe_set.intersection(preference_set))

        if len(preference_set) > 0:
            match_ratio = matched_preferences / len(preference_set)
        else:
            match_ratio = 0.0

        # Add bonus for multiple matches
        bonus = min(0.15, matched_preferences * 0.05) if matched_preferences > 0 else 0.0
        return min(1.0, match_ratio + bonus)



    def _calculate_input_ingredient_score(self, recipe_ingredients: List[str],
                                          input_ingredients: List[str]) -> float:
        """Calculate selected ingredient matching score (60%)"""
        if not input_ingredients:
            return 0.0

        recipe_set = set(recipe_ingredients)
        input_set = set(input_ingredients)

        # Calculate matched ingredients
        matched_ingredients = len(recipe_set.intersection(input_set))

        if len(input_set) > 0:
            match_ratio = matched_ingredients / len(input_set)
        else:
            match_ratio = 0.0

        # Add bonus for perfect match
        bonus = 0.3 if matched_ingredients == len(input_set) else 0.0
        return min(1.0, match_ratio + bonus)


    def _calculate_history_score(self, recipe_id: int,
                                 user_recipe_ids: List[int],
                                 user_recipe_counts: Dict[int, int],
                                 recipe_ingredients: List[str],
                                 user_ingredient_ids: List[int],
                                 user_ingredient_counts: Dict[int, int]) -> float:
        """Calculate historical behavior score (10%)"""
        score = 0.0

        # Recipe history score
        if recipe_id in user_recipe_ids:
            # Score based on view count
            count = user_recipe_counts.get(recipe_id, 1)
            recipe_score = min(0.05, count * 0.01)
            score += recipe_score

        # Ingredient history score
        if user_ingredient_ids:
            # Calculate ingredient overlap (simplified)
            overlap_ratio = 0.0
            ingredient_score = overlap_ratio * 0.05
            score += ingredient_score
        return min(0.1, score)

    def get_recommendations(self, user_id: int, input_ingredients: List[str], db: Session):
        recommendations = self.recommend_recipes(user_id, input_ingredients, db, top_n=5)
        return recommendations