class IngredientCount {
  String ingredientName;
  int count;

  IngredientCount({
    required this.ingredientName,
    required this.count,
  });

  factory IngredientCount.fromJson(Map<String, dynamic> json) {
    return IngredientCount(
      ingredientName: json['ingredient_name'] ?? '',
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ingredient_name'] = ingredientName;
    data['count'] = count;
    return data;
  }

  @override
  String toString() {
    return 'IngredientCount(ingredientName: $ingredientName, count: $count)';
  }
}