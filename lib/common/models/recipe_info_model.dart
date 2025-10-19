class RecipeInfoModel {
  int recipeId;
  String recipeName;
  String difficulty;
  String cookTime;
  List<String> cookSteps;
  List<String> ingredients;
  bool isCollected;

  RecipeInfoModel({
    required this.recipeId,
    required this.recipeName,
    required this.difficulty,
    required this.cookTime,
    required this.cookSteps,
    required this.ingredients,
    required this.isCollected,
  });

  static List<String> _parseCookSteps(dynamic steps) {
    if (steps is List) {
      return steps.map((step) => step.toString()).toList();
    }
    return [];
  }

  static List<String> _parseIngredients(dynamic ingredients) {
    if (ingredients is List) {
      return ingredients.map((ingredient) => ingredient.toString()).toList();
    }
    return [];
  }

  factory RecipeInfoModel.fromJson(Map<String, dynamic> json) {
    return RecipeInfoModel(
      recipeId: json['recipe_id'] ?? 0,
      recipeName: json['recipe_name'] ?? '',
      difficulty: json['difficulty'] ?? '',
      cookTime: json['cook_time'] ?? '',
      cookSteps: _parseCookSteps(json['cook_steps']),
      ingredients: _parseIngredients(json['ingredients']),
      isCollected: json['is_collected'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['recipe_id'] = recipeId;
    data['recipe_name'] = recipeName;
    data['difficulty'] = difficulty;
    data['cook_time'] = cookTime;
    data['cook_steps'] = cookSteps;
    data['ingredients'] = ingredients;
    data['is_collected'] = isCollected;
    return data;
  }

  @override
  toString() {
    return 'RecipeInfoModel(recipeId: $recipeId, recipeName: $recipeName, difficulty: $difficulty, cookTime: $cookTime, cookSteps: $cookSteps, ingredients: $ingredients)';
  }
}



class RecipeForCollectModel {
  int recipeId;
  bool isCollect;

  RecipeForCollectModel({
    required this.recipeId,
    required this.isCollect,
  });

  Map<String, dynamic> toJson() {
    return {
      "recipe_id": recipeId,
      "is_collect": isCollect
    };
  }
}