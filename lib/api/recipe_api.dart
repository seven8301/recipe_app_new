import 'dart:convert';

import 'package:recipe_app/common/net/init_dio.dart';
import 'package:recipe_app/common/values/server.dart';
import '../common/models/ingredient_model.dart';
import '../common/models/recipe_info_model.dart';
import '../common/models/recipe_model.dart';

class RecipeApi {
  static Future<List<IngredientModel>?> getIngredientsApi() async {
    final response = await httpManager.get(
      '/recipe/allIngredientsWithCategories',
    );
    if (response.code == 0) {
      List<IngredientModel> resultedList = [];
      for (var item in response.data) {
        final recipeModel = IngredientModel.fromJson(item);
        resultedList.add(recipeModel);
      }
      return resultedList;
    }
    return null;
  }

  static Future<ListRecipeModel?> getRecipeList({
    required int page,
    required int page_size,
  }) async {
    final response = await httpManager.get(
      '/recipe/recipesList',
      params: {'page': page, 'page_size': page_size},
    );
    if (response.code == 0) {
      ListRecipeModel result;
      result = ListRecipeModel.fromJson(response.data);
      return result;
    }
    return null;
  }

  static Future<RecipeInfoModel?> getRecipeInfo({
    required int recipe_id,
  }) async {
    final response = await httpManager.get(
      '/recipe/recipeIngredients/${recipe_id}',
    );
    if (response.code == 0) {
      RecipeInfoModel result;
      result = RecipeInfoModel.fromJson(response.data);
      return result;
    }
    return null;
  }


  static Future<ListRecipeModel?> getRecipesByIngredientsRecipeInfo({
    required int page,
    required int page_size,
    required List<String> ingredients,
  }) async {
    final response = await httpManager.post(
      '/recipe/recipesByIngredients',
      data: {'page': page, 'page_size': page_size, 'ingredients': ingredients},
    );
    if (response.code == 0) {
      ListRecipeModel result;
      result = ListRecipeModel.fromJson(response.data);
      return result;
    }
    return null;
  }


  static Future<ListRecipeModel?> getFeedRecipe(
    List<String> ingredients,
  ) async {
    final response = await httpManager.post(
      '/recipe/feedRecipe',
      data: {'ingredients': ingredients},
    );
    if (response.code == 0) {
      ListRecipeModel result;
      result = ListRecipeModel.fromJson(response.data);
      return result;
    }
    return null;
  }

  static Future<List<RecipeModel>?> getHistoryRecipes() async {
    final response = await httpManager.get('/recipe/historyRecipes');
    if (response.code == 0) {
      List<RecipeModel> result = [];
      for (var item in response.data) {
        final recipeModel = RecipeModel.fromJson(item);
        result.add(recipeModel);
      }
      return result;
    }
    return null;
  }

  static Future<List<RecipeModel>?> getCollectRecipes() async {
    final response = await httpManager.get('/recipe/collectRecipes');
    if (response.code == 0) {
      List<RecipeModel> result = [];
      for (var item in response.data) {
        final recipeModel = RecipeModel.fromJson(item);
        result.add(recipeModel);
      }
      return result;
    }
    return null;
  }

  static Future<void> addOrRemoveCollectRecipe(RecipeForCollectModel payload) async {
    final response = await httpManager.post('/auth/collectRecipe', data: payload.toJson());
    if (response.code == 0) {
      logger.d('addOrRemoveCollectRecipe success');
      return;
    }
    return;
  }
}