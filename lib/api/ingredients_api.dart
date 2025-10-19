import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:recipe_app/common/models/detection_model.dart';
import 'package:recipe_app/common/models/ingredient_count.dart';
import 'package:recipe_app/common/net/init_dio.dart';
import 'package:recipe_app/common/values/server.dart';

import '../common/models/recipe_model.dart';

class IngredientsApi {
  static Future<String?> uploadIngredientsImg(String filePath) async {
    try {
      final multipartFile = await MultipartFile.fromFile(filePath);
      final formData = FormData.fromMap({'file': multipartFile});
      final response = await httpManager.uploadFile('/upload', formData);
      if (response.code == 0) {
        return response.data['filename'];
      }
      return null;
    } catch (e) {
      logger.e("uploadIngredientsImg error: $e");
    }
    return null;
  }

  static Future<List<DetectionModel>?> detectionIngredients(
    String filePath,
  ) async {
    try {
      final response = await httpManager.post(
        "/recipe/detectionIngredients",
        data: {"ingredients_img": filePath},
      );
      if (response.code == 0) {
        final List<DetectionModel> detections = [];
        for (var item in response.data) {
          final detection = DetectionModel.fromJson(item);
          detections.add(detection);
        }
        return detections;
      }
    } catch (e) {
      logger.e("detectionIngredients error: $e");
    }
    return null;
  }

  static Future<List<IngredientCount>?> getHistoryIngredients() async {
    final response = await httpManager.get('/recipe/historyIngredients');
    if (response.code == 0) {
      List<IngredientCount> ingredientCounts = [];
      for (var item in response.data) {
        final ingredientCount = IngredientCount.fromJson(item);
        ingredientCounts.add(ingredientCount);
      }
      return ingredientCounts;
    }
    return null;
  }
}