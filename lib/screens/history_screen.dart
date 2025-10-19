import 'package:flutter/material.dart';
import 'package:recipe_app/api/ingredients_api.dart';
import 'package:recipe_app/common/models/user_model.dart';
import '../api/recipe_api.dart';
import '../api/user_api.dart';
import '../common/models/ingredient_count.dart';
import '../common/models/recipe_model.dart';
import '../common/values/server.dart';
import '../services/auth_service.dart';

import 'edit_profile.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

// late var show be initialized before use
class _HistoryPageState extends State<HistoryPage> {
  bool _isLoading = false;
  List<RecipeModel>? _historyRecipes;
  List<IngredientCount>? _historyIngredients;
  List<RecipeModel>? _collectionsRecipes;
  String _label = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void _initializeData() {
    try {
      final args = ModalRoute
          .of(context)
          ?.settings
          .arguments as Map<String, dynamic>?;
      final viewType = args?['view-type'] ?? 1;
      if (viewType == 1) {
        _loadHistoryRecipe();
        _label = 'History Recipes';
      } else if (viewType == 2) {
        _loadHistoryIngredient();
        _label = 'History Ingredients';
      }else {
        _loadCollectionsRecipe();
        _label = 'Collections Recipes';
      }
    } catch (e) {
      _label = 'History';
      _historyRecipes = [];
      _historyIngredients = [];
      logger.e('Error initializing data: $e');
    }
  }

  Future<void> _loadCollectionsRecipe() async {
    try {
      setState(() => _isLoading = true);
      final collectionsRecipes = await RecipeApi.getCollectRecipes();
      if (collectionsRecipes != null) {
        setState((){
          _collectionsRecipes = collectionsRecipes;
        });
      } else {
        logger.e('_loadCollectionsRecipe is null');
      }
    } catch (e) {
      logger.e('_loadCollectionsRecipe is null$e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadHistoryRecipe() async {
    try {
      setState(() => _isLoading = true);
      final historyRecipes = await RecipeApi.getHistoryRecipes();
      logger.d('_loadHistoryRecipe: $historyRecipes');
      if (historyRecipes != null) {
        setState((){
          _historyRecipes = historyRecipes;
        });
      } else {
        logger.e('loadHistoryRecipe: historyRecipes is null');
      }
    } catch (e) {
      logger.e('loadHistoryRecipe: historyRecipes is null$e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadHistoryIngredient() async {
    try {
      setState(() => _isLoading = true);
      final ingredientsHistory = await IngredientsApi.getHistoryIngredients();
      logger.d('historyIngredients: $ingredientsHistory');
      if (ingredientsHistory != null) {
        setState((){
          _historyIngredients = ingredientsHistory;
        });
      } else {
        logger.e('loadHistoryIngredient: ingredientsHistory is null');
      }
    } catch (e) {
      logger.e('loadHistoryIngredient: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7B5EF0), Color(0xFF9B7DF7)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                   Expanded(
                    child: Text(
                      _label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              _isLoading ?
              const Center(child: CircularProgressIndicator()) :
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF6F2FF),
                    borderRadius: BorderRadius.all(Radius.circular(28)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if(_historyRecipes != null)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _historyRecipes!.length,
                            itemBuilder: (context, index) {
                              final recipe = _historyRecipes![index];
                              return _buildRecipeCard(recipe);
                            },
                          ),

                        if(_collectionsRecipes != null)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _collectionsRecipes!.length,
                            itemBuilder: (context, index) {
                              final recipe = _collectionsRecipes![index];
                              return _buildRecipeCard(recipe);
                            },
                          ),
                        if(_historyIngredients != null)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _historyIngredients!.length,
                            itemBuilder: (context, index) {
                              final ingredient = _historyIngredients![index];
                              return _buildIngredientCard(ingredient,index+1);
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeCard(RecipeModel recipe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => {},
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7B5EF0).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.restaurant,
                    color: Color(0xFF7B5EF0),
                    size: 40,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.recipeName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            recipe.cookTime,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(width: 15),
                          const Icon(
                            Icons.signal_cellular_alt,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            recipe.difficulty,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                        Row(
                          children: [
                            SizedBox(
                              width: 150,
                              child: Text(
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF7B5EF0),
                                ),
                                recipe.ingredients.map((ingredient) => ingredient.ingredientName).join('、'),
                              ),
                            ),
                          ],
                        )
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFF7B5EF0),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildIngredientCard(IngredientCount ingredient, int rank) {
    bool isTopThree = rank <= 3;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: isTopThree ? Border.all(
          color: _getRankColor(rank),
          width: 2,
        ) : null,
      ),
      child: Row(
        children: [

          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isTopThree ? _getRankColor(rank) : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  color: isTopThree ? Colors.white : Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),


          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      ingredient.ingredientName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _getRankColor(rank),
                      ),
                    ),
                    if (isTopThree) ...[
                      const SizedBox(width: 8),
                      Icon(
                        _getRankIcon(rank),
                        color: _getRankColor(rank),
                        size: 20,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Number of Visits: ${ingredient.count}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),


          Container(
            width: 60,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(2),
            ),
            child: Stack(
              children: [
                Container(
                  width: 60,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Container(
                  width: _calculateProgressWidth(ingredient.count, rank),
                  height: 4,
                  decoration: BoxDecoration(
                    color: _getRankColor(rank),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return const Color(0xFF7B5EF0);
    }
  }

  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return Icons.emoji_events;
      case 2:
        return Icons.star;
      case 3:
        return Icons.workspace_premium;
      default:
        return Icons.trending_up;
    }
  }

  double _calculateProgressWidth(int count, int rank) {
    double percentage = 1.0;
    switch (rank) {
      case 1:
        percentage = 1.0;
        break;
      case 2:
        percentage = 0.8;
        break;
      case 3:
        percentage = 0.6;
        break;
      default:
        percentage = 0.4;
        break;
    }
    return 60 * percentage;
  }
}