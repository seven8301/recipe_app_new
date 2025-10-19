import 'package:flutter/material.dart';
import '../common/models/ingredient_model.dart';
import '../common/values/server.dart';
import '../api/recipe_api.dart';

class IngredientsScreen extends StatefulWidget {
  @override
  _IngredientsScreenState createState() => _IngredientsScreenState();
}

class _IngredientsScreenState extends State<IngredientsScreen> {
  late List<IngredientModel> _recipeData;
  late bool _isLoading;
  late String _errorMessage;


  List<Map<String, dynamic>> _popularIngredients = [];
  List<String> _customIngredients = [];
  final TextEditingController _customIngredientController = TextEditingController();
  String _selectedCategory = 'All';
  late  List<String> _categories = ['All'];

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = "Loading...";
      });
      final recipes = await RecipeApi.getIngredientsApi();
      for (var recipe in recipes!){
        _categories.add(recipe.categoryName);
        _popularIngredients.add({'name': recipe.ingredientName, 'category': recipe.categoryName,'selected': false});
      }
      _categories = _categories.toSet().toList();
      setState(() {
        _recipeData = recipes!;
        _isLoading = false;
        _errorMessage = "";
      });
    } catch (e) {
      logger.e('IngredientsScreen _loadRecipes: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load recipe data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF7B5EF0),
              Color(0xFF9B7DF7),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Text(
                      'Ingredients',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.person, color: Colors.white),
                      onPressed: () {
                        // Handle profile
                      },
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
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

  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          // Title
          Text(
            'Popular Ingredients',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          
          SizedBox(height: 15),
          
          // Category Filter
          Container(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Color(0xFF7B5EF0) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Color(0xFF7B5EF0),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Color(0xFF7B5EF0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          SizedBox(height: 20),
          // Selected Ingredients Count
          Text(
            'Selected: ${_getSelectedCount()} ingredients',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF7B5EF0),
              fontWeight: FontWeight.bold,
            ),
          ),
          
          SizedBox(height: 15),
          
          // Ingredients Grid
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 3,
              ),
              itemCount: _getFilteredIngredients().length,
              itemBuilder: (context, index) {
                final ingredient = _getFilteredIngredients()[index];
                return _buildIngredientCard(ingredient);
              },
            ),
          ),
          
          SizedBox(height: 15),
          
          // Add Custom Ingredient
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Color(0xFF7B5EF0).withOpacity(0.3)),
                  ),
                  child: TextField(
                    controller: _customIngredientController,
                    decoration: InputDecoration(
                      hintText: 'Add custom ingredient',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Color(0xFF7B5EF0),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: IconButton(
                  icon: Icon(Icons.add, color: Colors.white),
                  onPressed: _addCustomIngredient,
                ),
              ),
            ],
          ),
          
          // Custom Ingredients List
          if (_customIngredients.isNotEmpty) ...[
            SizedBox(height: 15),
            Text(
              'Custom Ingredients:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _customIngredients.map((ingredient) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFF7B5EF0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        ingredient,
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(width: 5),
                      GestureDetector(
                        onTap: () => _removeCustomIngredient(ingredient),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
          
          SizedBox(height: 20),
          
          // Get Recipe Button
          // if (_getSelectedCount() > 0)
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: Color(0xFF7B5EF0),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () {
                    _navigateToRecipes();
                  },
                  child: Center(
                    child: Text(
                      _getSelectedCount() == 0 ? 'Get Recommended Recipes' : 'Select ${_getSelectedCount()} Ingredients',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildIngredientCard(Map<String, dynamic> ingredient) {
    final isSelected = ingredient['selected'] ?? false;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          ingredient['selected'] = !isSelected;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF7B5EF0) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? Color(0xFF7B5EF0) : Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            SizedBox(width: 15),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? Colors.white : Colors.grey,
              size: 20,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                ingredient['name'],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }



  List<Map<String, dynamic>> _getFilteredIngredients() {
    if (_selectedCategory == 'All') {
      return _popularIngredients;
    }
    return _popularIngredients
        .where((ingredient) => ingredient['category'] == _selectedCategory)
        .toList();
  }

  int _getSelectedCount() {
    int popularSelected = _popularIngredients.where((ingredient) => ingredient['selected'] == true).length;
    return popularSelected + _customIngredients.length;
  }

  void _addCustomIngredient() {
    final ingredient = _customIngredientController.text.trim();
    if (ingredient.isNotEmpty && !_customIngredients.contains(ingredient)) {
      setState(() {
        _customIngredients.add(ingredient);
        _customIngredientController.clear();
      });
    }
  }

  void _removeCustomIngredient(String ingredient) {
    setState(() {
      _customIngredients.remove(ingredient);
    });
  }

  void _navigateToRecipes() {
    List<String> selectedIngredients = [];
    
    // Add selected popular ingredients
    for (var ingredient in _popularIngredients) {
      if (ingredient['selected'] == true) {
        selectedIngredients.add(ingredient['name']);
      }
    }
    
    // Add custom ingredients
    selectedIngredients.addAll(_customIngredients);
    
    // Navigate to recipe book with selected ingredients
    Navigator.pushNamed(
      context, 
      '/recipe-book',
      arguments: {'ingredients': selectedIngredients,"recommend":true},
    );
  }
}