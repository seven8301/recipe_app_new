import cv2
import numpy as np
from ultralytics import YOLO

class CustomFoodDetector:
    def __init__(self, custom_model_path):
        """
        Use custom trained model
        Args:
            custom_model_path: Custom trained model path
        """
        self.model = YOLO(custom_model_path)

        self.food_classes = {
            0: 'tomato', 1: 'egg', 2: 'beef', 3: 'vegetables',
            4: 'carrot', 5: 'potato', 6: 'chicken', 7: 'fish'
        }

    def detect_ingredients(self, image_path):
        """
        Detect ingredients and return structured results
        """
        results = self.model.predict(image_path, conf=0.3)

        ingredients = []
        for result in results:
            if result.boxes is not None:
                for box in result.boxes:
                    cls_id = int(box.cls[0])
                    class_name = self.food_classes.get(cls_id, f'unknown{cls_id}')
                    confidence = float(box.conf[0])

                    ingredients.append({
                        'name': class_name,
                        'confidence': confidence,
                        'bbox': box.xyxy[0].cpu().numpy().tolist()
                    })

        return ingredients

    def get_ingredient_list(self, image_path):
        """
        Get ingredient name list (deduplicated)
        """
        ingredients = self.detect_ingredients(image_path)

        unique_ingredients = {}
        for ing in ingredients:
            name = ing['name']
            if name not in unique_ingredients or ing['confidence'] > unique_ingredients[name]['confidence']:
                unique_ingredients[name] = ing

        return list(unique_ingredients.values())


detector = CustomFoodDetector('./best.pt')
ingredients = detector.get_ingredient_list('./beef_00003.jpg')
print("Detected ingredients:", [ing['name'] for ing in ingredients])