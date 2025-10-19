class DetectionModel {
  final String className;
  final double confidence;

  DetectionModel({
    required this.className,
    required this.confidence,
  });

  factory DetectionModel.fromJson(Map<String, dynamic> json) {
    return DetectionModel(
      className: json['class_name'],
      confidence: json['confidence'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['class_name'] = className;
    data['confidence'] = confidence;
    return data;
  }
  @override
  String toString() {
    return 'DetectionModel(className: $className, confidence: $confidence)';
  }
}