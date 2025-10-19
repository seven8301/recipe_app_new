class IngredientModel {
  int id;
  String ingredientName;
  String categoryName;

  IngredientModel({
    required this.id,
    required this.ingredientName,
    required this.categoryName,
  });

  factory IngredientModel.fromJson(Map<String, dynamic> json) {
    return IngredientModel(
      id: json['id'] ?? 0,
      ingredientName: json['ingredient_name'] ?? '',
      categoryName: json['category_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['ingredient_name'] = ingredientName;
    data['category_name'] = categoryName;
    return data;
  }

  @override
  String toString() {
    return 'IngredientModel(id: $id, ingredientName: $ingredientName, categoryName: $categoryName)';
  }
}