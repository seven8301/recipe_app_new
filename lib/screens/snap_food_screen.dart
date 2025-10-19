import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../common/values/server.dart';
import '../api/ingredients_api.dart';
import '../common/models/detection_model.dart';

class SnapFoodScreen extends StatefulWidget {
  @override
  _SnapFoodScreenState createState() => _SnapFoodScreenState();
}

class _SnapFoodScreenState extends State<SnapFoodScreen> {
  File? _selectedImage;
  bool _isAnalyzing = false;
  bool _showResults = false;


  List<Map<String, dynamic>> _recognizedIngredients = [];

  List<String> _customIngredients = [];
  final TextEditingController _customIngredientController =
      TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7B5EF0), Color(0xFF9B7DF7)],
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
                      'Snap Your Food',
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
    if (!_showResults && !_isAnalyzing) {
      return _buildImageSelection();
    } else if (_isAnalyzing) {
      return _buildAnalyzing();
    } else {
      return _buildResults();
    }
  }

  Widget _buildImageSelection() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          SizedBox(height: 20),
          Text(
            'Take a Photo or Upload Image',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          SizedBox(height: 10),

          Text(
            'Our AI will recognize the ingredients in your photo',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),

          SizedBox(height: 30),
          // Image Display
          Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Color(0xFF7B5EF0).withOpacity(0.3)),
              color: Colors.white,
            ),
            child: _selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(_selectedImage!, fit: BoxFit.cover),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Color(0xFF7B5EF0).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            size: 60,
                            color: Color(0xFF7B5EF0),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'No image selected',
                          style: TextStyle(
                            color: Color(0xFF7B5EF0),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap the camera or gallery button below',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          SizedBox(height: 10),

          // Camera and Gallery Buttons
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Color(0xFF7B5EF0),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () => _pickImage(ImageSource.camera),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Camera',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFF7B5EF0), width: 2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () => _pickImage(ImageSource.gallery),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo_library, color: Color(0xFF7B5EF0)),
                          SizedBox(width: 8),
                          Text(
                            'Gallery',
                            style: TextStyle(
                              color: Color(0xFF7B5EF0),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          // Analyze Button
          if (_selectedImage != null)
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
                  onTap: _analyzeImage,
                  child: Center(
                    child: Text(
                      'Analyze Ingredients with AI',
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
        ],
      ),
    );
  }

  Widget _buildAnalyzing() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_selectedImage != null)
            Container(
              width: 300,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.file(_selectedImage!, fit: BoxFit.cover),
              ),
            ),
          SizedBox(height: 40),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFF7B5EF0).withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7B5EF0)),
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 30),
          Text(
            'AI is analyzing your food...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7B5EF0),
            ),
          ),

          SizedBox(height: 10),

          Text(
            'This may take a few seconds',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Result Image
          // Container(
          //   width: double.infinity,
          //   height: 150,
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular(15),
          //   ),
          //   child: ClipRRect(
          //     borderRadius: BorderRadius.circular(15),
          //     child: _selectedImage != null
          //         ? Image.file(
          //             _selectedImage!,
          //             fit: BoxFit.cover,
          //           )
          //         : Container(
          //             color: Colors.grey[300],
          //             child: Icon(Icons.image, size: 50),
          //           ),
          //   ),
          // ),
          Text(
            'AI Recognized Ingredients:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          SizedBox(height: 10),

          Text(
            'Tap to select/deselect ingredients',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),

          SizedBox(height: 15),

          // Recognized Ingredients List
          Expanded(
            child: ListView.builder(
              itemCount: _recognizedIngredients.length,
              itemBuilder: (context, index) {
                final ingredient = _recognizedIngredients[index];
                return _buildRecognizedIngredientCard(ingredient);
              },
            ),
          ),

          SizedBox(height: 15),
          // Add Custom Ingredient Section
          Text(
            'Add missing ingredients:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 10),
          // Add Custom Ingredient
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Color(0xFF7B5EF0).withOpacity(0.3),
                    ),
                  ),
                  child: TextField(
                    controller: _customIngredientController,
                    decoration: InputDecoration(
                      hintText: 'Enter ingredient name',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
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

          // Custom Ingredients Display
          if (_customIngredients.isNotEmpty) ...[
            SizedBox(height: 15),
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
                      Text(ingredient, style: TextStyle(color: Colors.white)),
                      SizedBox(width: 5),
                      GestureDetector(
                        onTap: () => _removeCustomIngredient(ingredient),
                        child: Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],

          SizedBox(height: 20),

          // Get Recipe Button
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
                    'Get Recipes (${_getSelectedCount()} ingredients)',
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

  Widget _buildRecognizedIngredientCard(Map<String, dynamic> ingredient) {
    final isSelected = ingredient['selected'] ?? false;
    final confidence = ingredient['confidence'] ?? 0.0;

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isSelected ? Color(0xFF7B5EF0) : Colors.grey.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            setState(() {
              ingredient['selected'] = !isSelected;
            });
          },
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? Color(0xFF7B5EF0) : Colors.grey,
                  size: 24,
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ingredient['name'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Confidence: ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getConfidenceColor(confidence),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${(confidence * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _showResults = false;
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      _showErrorDialog('Error selecting image. Please try again.');
    }
  }

  void _analyzeImage() async {
    if (_selectedImage == null) {
      _showErrorDialog('Please select an image first.');
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      // upload image to server
      final String? uploadedFilePath =
          await IngredientsApi.uploadIngredientsImg(_selectedImage!.path);
      if (uploadedFilePath == null) {
        setState(() {
          _isAnalyzing = false;
        });
        _showErrorDialog('Image upload failed, please try again');
        return;
      }
      final List<DetectionModel>? detections =
          await IngredientsApi.detectionIngredients(uploadedFilePath);
      setState(() {
        _isAnalyzing = false;
        if (detections != null && detections.isNotEmpty) {
          _recognizedIngredients = [];
          for (var detection in detections) {
            _recognizedIngredients.add({
              'name': detection.className,
              'selected': false,
              'confidence': detection.confidence,
            });
          }
          _showResults = true;
        } else {
          _showErrorDialog('No ingredients detected, please try another image');
        }
      });
    } catch (e) {
      logger.e('Error analyzing image: $e');
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
        _showErrorDialog('Analysis failed: $e');
      }
    }


    // Future.delayed(Duration(seconds: 3), () {
    //   if (mounted) {
    //     setState(() {
    //       _isAnalyzing = false;
    //       _showResults = true;

    //       _randomizeRecognitionResults();
    //     });
    //   }
    // });
  }

  void _randomizeRecognitionResults() {

    final random = DateTime.now().millisecondsSinceEpoch % 3;
    switch (random) {
      case 0:
        _recognizedIngredients = [
          {'name': 'Tomato', 'selected': true, 'confidence': 0.92},
          {'name': 'Lettuce', 'selected': true, 'confidence': 0.87},
          {'name': 'Onion', 'selected': false, 'confidence': 0.74},
          {'name': 'Bell Pepper', 'selected': true, 'confidence': 0.81},
        ];
        break;
      case 1:
        _recognizedIngredients = [
          {'name': 'Chicken', 'selected': true, 'confidence': 0.94},
          {'name': 'Rice', 'selected': true, 'confidence': 0.89},
          {'name': 'Carrot', 'selected': false, 'confidence': 0.72},
          {'name': 'Soy Sauce', 'selected': true, 'confidence': 0.78},
        ];
        break;
      default:
        _recognizedIngredients = [
          {'name': 'Egg', 'selected': true, 'confidence': 0.95},
          {'name': 'Milk', 'selected': true, 'confidence': 0.88},
          {'name': 'Flour', 'selected': false, 'confidence': 0.69},
          {'name': 'Butter', 'selected': false, 'confidence': 0.76},
        ];
    }
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

  int _getSelectedCount() {
    int recognizedSelected = _recognizedIngredients
        .where((ingredient) => ingredient['selected'] == true)
        .length;
    return recognizedSelected + _customIngredients.length;
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) {
      return Colors.green;
    } else if (confidence >= 0.6) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  void _navigateToRecipes() {
    List<String> selectedIngredients = [];

    // Add selected recognized ingredients
    for (var ingredient in _recognizedIngredients) {
      if (ingredient['selected'] == true) {
        selectedIngredients.add(ingredient['name']);
      }
    }

    // Add custom ingredients
    selectedIngredients.addAll(_customIngredients);

    if (selectedIngredients.isEmpty) {
      _showErrorDialog('Please select at least one ingredient.');
      return;
    }

    // Navigate to recipe book with selected ingredients
    Navigator.pushNamed(
      context,
      '/recipe-book',
      arguments: {'ingredients': selectedIngredients, 'fromAI': true},
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Notice'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _customIngredientController.dispose();
    super.dispose();
  }
}