import 'dart:math';
import 'package:flutter/material.dart';
import 'package:recipe_app/common/net/init_dio.dart';
import 'package:recipe_app/common/values/server.dart';
import '../api/recipe_api.dart';
import '../common/models/recipe_info_model.dart';
import '../common/models/recipe_model.dart';

class RecipeBookScreen extends StatefulWidget {
  const RecipeBookScreen({super.key});

  @override
  State<RecipeBookScreen> createState() => _RecipeBookScreenState();
}

class _RecipeBookScreenState extends State<RecipeBookScreen> {
  List<String> selectedIngredients = [];
  // if ai recommended , get list of recipes by ingredients.
  // if not,get recommendation list by ingredients
  bool fromAI = false;
  // String _recipeBookPageTitle = 'All Recipes';
  String _recipeBookPageTitle = 'Recommended Recipes';
  late ListRecipeModel recipesData;
  bool _isLoading = false;
  int recipesPage = 1;
  int recipesPageSize = 3;
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();
  bool _hasMore = true;
  bool isRecommend = false;

  @override
  void initState() {
    super.initState();
    recipesData = ListRecipeModel(recipes: [], total: 0);
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }




  void _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      if (!_isLoadingMore && _hasMore) {
        if (selectedIngredients.isEmpty){
          _loadMoreRecipes();
        }else {
          if(fromAI){
            _loadMoreRecipesWithRecommend();
          }
        }
      }
    }
  }

  Future<void> _loadMoreRecipesWithRecommend() async {
    logger.d('_loadMoreRecipesWithRecommend');
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final nextPage = recipesPage + 1;
      ListRecipeModel? response = await RecipeApi.getRecipesByIngredientsRecipeInfo(page: nextPage, page_size: recipesPageSize, ingredients: selectedIngredients);
      if (response != null && mounted) {
        setState(() {
          recipesData.recipes.addAll(response!.recipes);
          recipesPage = nextPage;
          _hasMore = recipesData.recipes.length < recipesData.total;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      logger.e('Failed to load more recipes: $e');
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _loadMoreRecipes() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final nextPage = recipesPage + 1;
      ListRecipeModel? response = await RecipeApi.getRecipeList(page: nextPage, page_size: recipesPageSize);
      if (response != null && mounted) {
        setState(() {
          recipesData.recipes.addAll(response!.recipes);
          recipesPage = nextPage;
          _hasMore = recipesData.recipes.length < recipesData.total;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      logger.e('Failed to load more recipes: $e');
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadRecipes(int page, int pageSize) async {
    logger.d('_loadRecipes page: $page');
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await RecipeApi.getRecipeList(page: page, page_size: pageSize);
      setState(() {
        _isLoading = false;
        recipesData = response!;
        _hasMore = recipesData.recipes.length < recipesData.total;
      });
    } catch (e) {
      logger.e('Failed to load recipes: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRecipesWithRecommend(int page, int pageSize,List<String> ingredients) async {
    logger.d('_loadRecipesWithRecommend page: $page');
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await RecipeApi.getRecipesByIngredientsRecipeInfo(ingredients: ingredients, page: page, page_size: pageSize);
      setState(() {
        _isLoading = false;
        recipesData = response!;
        _hasMore = recipesData.recipes.length < recipesData.total;
      });
    } catch (e) {
      logger.e('Failed to load recipes: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFeedRecipes(List<String> selectedIngredients) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await RecipeApi.getFeedRecipe(selectedIngredients);
      setState(() {
        _isLoading = false;
        _hasMore = false;
        recipesData = response!;
      });
    } catch (e) {
      logger.e('Failed to load recommended recipes: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _initializeData() {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      selectedIngredients = List<String>.from(args['ingredients'] ?? []);
      fromAI = args['fromAI'] ?? false;
      isRecommend = args['recommend']?? false;
    }
    if (selectedIngredients.isNotEmpty) {
      if (fromAI) {
        _recipeBookPageTitle = "All Recipes Containing Ingredients";
        _loadRecipesWithRecommend(recipesPage, recipesPageSize,selectedIngredients);
      }else {
        _recipeBookPageTitle = "Recommended Recipes";
        _loadFeedRecipes(selectedIngredients);
      }
    } else { // if selectedIngredients is Empty -> All Recipes Or Recommend Recipes
      // if (isRecommend){
      //
      // }else {
      //   _recipeBookPageTitle = "All Recipes";
      //   _loadRecipes(recipesPage, recipesPageSize);
      // }
      _recipeBookPageTitle = "Recommended Recipes";
      _loadFeedRecipes([]);
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
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Recommended Recipes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.person, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F3FF),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: _buildContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    setState(() {
      recipesPage = 1;
      recipesData.recipes.clear();
      _hasMore = true;
    });
    if(selectedIngredients.isEmpty) {
      await _loadRecipes(recipesPage, recipesPageSize);
    }else {
      await _loadFeedRecipes(selectedIngredients);
    }
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          if (selectedIngredients.isNotEmpty) ...[
            Text(
              fromAI
                  ? 'AI Recommended Recipes'
                  : 'Recipes for Your Ingredients',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF7B5EF0).withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Ingredients:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7B5EF0),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: selectedIngredients
                        .map(
                          (ingredient) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7B5EF0),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              ingredient,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          Text(
            _recipeBookPageTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 15),
          _isLoading ?
          const Center(child: CircularProgressIndicator()) :
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: recipesData.recipes.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {

                  if (index == recipesData.recipes.length && _hasMore) {
                    return Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  final recipe = recipesData.recipes[index];
                  return _buildRecipeCard(recipe);
                },
              ),
            ),
          ),
        ],
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
          onTap: () => _showRecipeDetails(recipe.recipeId),
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
                      if (!isRecommend)
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
                      else
                        _buildStars(recipe.matchRatio, selectedIngredients.length),
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

  Widget _buildStars(double matchRatio, int totalSelected) {
    final matchedCount = matchRatio / 0.2;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < matchedCount) {
          return Icon(
            Icons.star,
            size: 14,
            color: Colors.amber,
          );
        } else {
          return Icon(
            Icons.star_border,
            size: 14,
            color: Colors.grey,
          );
        }
      }),
    );
  }


  void _showRecipeDetails(int recipeId) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );
      final recipe = await RecipeApi.getRecipeInfo(recipe_id: recipeId);
      Navigator.of(context).pop();
      _showRecipeModal(recipe!);
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Loading failed: $e')),
      );
    }
  }

  void _showRecipeModal(RecipeInfoModel recipe) {

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            recipe.recipeName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        GestureDetector(
                          onTap: () {
                            _toggleFavorite(recipe);
                            setModalState(() {
                              recipe.isCollected = !recipe.isCollected;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey[200]!,
                              ),
                            ),
                            child: Icon(
                              recipe.isCollected ?? false
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: recipe.isCollected ?? false
                                  ? Colors.red
                                  : Colors.grey[600],
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        const Icon(Icons.access_time, color: Color(0xFF7B5EF0)),
                        const SizedBox(width: 5),
                        Text(recipe.cookTime),
                        const SizedBox(width: 20),
                        const Icon(
                          Icons.signal_cellular_alt,
                          color: Color(0xFF7B5EF0),
                        ),
                        const SizedBox(width: 5),
                        Text(recipe.difficulty),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Ingredients:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: SizedBox(
                        height: 200,
                        child: SingleChildScrollView(
                          child: Column(
                            children: List<Widget>.from(
                              (recipe.ingredients as List).map(
                                    (ingredient) => Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(top: 4),
                                        child: Icon(
                                          Icons.circle,
                                          size: 8,
                                          color: Color(0xFF7B5EF0),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          ingredient as String,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Cooking Steps:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    Expanded(
                      child: ListView.builder(
                        itemCount: (recipe.cookSteps as List).length,
                        itemBuilder: (context, index) {
                          final step = (recipe.cookSteps as List)[index] as String;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF7B5EF0),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    step,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }


  void _toggleFavorite(RecipeInfoModel recipe) {
    try {
      if (recipe.isCollected ?? false) {
        logger.d('Remove from favorites: ${recipe.recipeId}');
        RecipeApi.addOrRemoveCollectRecipe(RecipeForCollectModel(recipeId: recipe.recipeId, isCollect: false));
      } else {
        logger.d('Add to favorites: ${recipe.recipeId}');
        RecipeApi.addOrRemoveCollectRecipe(RecipeForCollectModel(recipeId: recipe.recipeId, isCollect: true));
      }
    } catch (e) {
      logger.e('Error toggling favorite: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            recipe.isCollected ?? false
                ? 'Failed to add to favorites'
                : 'Failed to remove from favorites',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

}