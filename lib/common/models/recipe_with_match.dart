class ListRecipeWithMatchInfo {
  List<RecipeWithMatchInfo> recipes;
  int total;

  ListRecipeWithMatchInfo({required this.recipes, required this.total});

  factory ListRecipeWithMatchInfo.fromJson(Map<String, dynamic> json) {
    List<RecipeWithMatchInfo> recipes = [];
    if (json['recipes'] != null) {
      json['recipes'].forEach((v) {
        recipes.add(RecipeWithMatchInfo.fromJson(v));
      });
    }
    return ListRecipeWithMatchInfo(
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

class RecipeWithMatchInfo {
  int recipeId;
  String recipeName;
  String difficulty;
  String cookTime;
  double matchRatio;


  RecipeWithMatchInfo({
    required this.recipeId,
    required this.recipeName,
    required this.difficulty,
    required this.cookTime,
    required this.matchRatio,
  });

  factory RecipeWithMatchInfo.fromJson(Map<String, dynamic> json) {
    return RecipeWithMatchInfo(
      recipeId: json['recipe_id'] ?? 0,
      recipeName: json['recipe_name'] ?? '',
      difficulty: json['difficulty'] ?? '',
      cookTime: json['cook_time'] ?? '',
      matchRatio: json['match_ratio'] ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['recipe_id'] = recipeId;
    data['recipe_name'] = recipeName;
    data['difficulty'] = difficulty;
    data['cook_time'] = cookTime;
    data['match_ratio'] = matchRatio;
    return data;
  }

  @override
  toString() {
    return 'RecipeWithMatchInfo(recipeId: $recipeId, recipeName: $recipeName, difficulty: $difficulty, cookTime: $cookTime,)';
  }
}