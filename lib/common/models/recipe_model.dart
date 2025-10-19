class ListRecipeModel {
  List<RecipeModel> recipes;
  int total;

  ListRecipeModel({required this.recipes, required this.total});

  factory ListRecipeModel.fromJson(Map<String, dynamic> json) {
    List<RecipeModel> recipes = [];
    if (json['recipes'] != null) {
      json['recipes'].forEach((v) {
        recipes.add(RecipeModel.fromJson(v));
      });
    }
    return ListRecipeModel(
      recipes: recipes,
      total: json['total'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['recipes'] = recipes.map((v) => v.toJson()).toList();
    data['total'] = total;
    return data;
  }
}

class RecipeModel {
  int recipeId;
  String recipeName;
  String difficulty;
  String cookTime;
  List<Ingredients> ingredients;
  double matchRatio;

  RecipeModel({
    required this.recipeId,
    required this.recipeName,
    required this.difficulty,
    required this.cookTime,
    required this.ingredients,
    required this.matchRatio,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    List<Ingredients> ingredients = [];
    if (json['ingredients'] != null) {
      json['ingredients'].forEach((v) {
        ingredients.add(Ingredients.fromJson(v));
      });
    }
    return RecipeModel(
      recipeId: json['recipe_id'] ?? 0,
      recipeName: json['recipe_name'] ?? '',
      difficulty: json['difficulty'] ?? '',
      cookTime: json['cook_time'] ?? '',
      matchRatio: json['match_ratio'] ?? 0.0,
      ingredients: ingredients,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['recipe_id'] = recipeId;
    data['recipe_name'] = recipeName;
    data['difficulty'] = difficulty;
    data['cook_time'] = cookTime;
    data['match_ratio'] = matchRatio;
    data['ingredients'] = ingredients.map((v) => v.toJson()).toList();
    return data;
  }
}

class Ingredients {
  String ingredientName;
  int quantity;
  String unit;

  Ingredients({
    required this.ingredientName,
    required this.quantity,
    required this.unit,
  });

  factory Ingredients.fromJson(Map<String, dynamic> json) {
    return Ingredients(
      ingredientName: json['ingredient_name'] ?? '',
      quantity: json['quantity'] ?? 0,
      unit: json['unit'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ingredient_name'] = ingredientName;
    data['quantity'] = quantity;
    data['unit'] = unit;
    return data;
  }
}