class ResultData {
  String message;
  dynamic data;
  int code;

  ResultData(this.message, this.data, this.code);


  factory ResultData.fromJson(Map<String, dynamic> json) {
    return ResultData(
      json['message'] ?? '',
      json['data'],
      json['code'] ?? -1,
    );
  }

  @override
  String toString() {
    return '${data}';
  }

  bool isSuccess() {
    return code == 0;
  }

  dynamic dataData() {
    return data['data'];
  }
}