from typing import List

from ultralytics import YOLO

class FoodIngredientDetector:
    def __init__(self, model_path='best.pt'):
        """
        Initialize YOLO model
        model_path: Pre-trained model path or custom trained model
        """
        self.model = YOLO(model_path)
        self.init_food_ingredient = {
            "beef": 1,
            "butter": 2,
            "capsicum": 3,
            "carrot": 4,
            "chicken breast": 5,
            "egg": 6,
            "onion": 7,
            "potatoes": 8,
            "shrimp": 9,
            "tofu": 10,
            "tomatoes": 11,
            "rice": 12,
        }

    def detect_image(self, image_path, conf_threshold=0.25):
        """
        Detect ingredients in a single image

        Args:
            image_path: Image file path
            conf_threshold: Confidence threshold

        Returns:
            results: Detection results list
        """

        results = self.model.predict(
            source=image_path,
            conf=conf_threshold,
            save=False
        )

        detections = []
        for result in results:
            boxes = result.boxes
            if boxes is not None:
                for box in boxes:
                    # Extract detection information
                    cls_id = int(box.cls[0])
                    class_name = self.model.names[cls_id]
                    confidence = float(box.conf[0])
                    bbox = box.xyxy[0].cpu().numpy()  # [x1, y1, x2, y2]

                    detections.append({
                        'class_name': class_name,
                        'confidence': confidence,
                        'bbox': bbox.tolist(),
                        'class_id': cls_id
                    })
        process_detections = self.process_detection(detections)
        return process_detections

    def process_detection(self, detections:List[dict]):
        max_confidence = {}
        for detection in detections:
            class_name = detection['class_name']
            confidence = detection['confidence']

            if class_name not in max_confidence or confidence > max_confidence[class_name]['confidence']:
                max_confidence[class_name] = {"class_name": class_name, "confidence": confidence}
        result = list(max_confidence.values())

        # Map detected classes to known food ingredients
        for el in result:
            class_name = el['class_name']
            for food_ingredient in self.init_food_ingredient:
                if food_ingredient in class_name.lower() or class_name.lower() in food_ingredient:
                    el['class_name'] = food_ingredient
        return result