import 'package:recipe_app/common/net/request_interceptors.dart';
import 'package:recipe_app/common/net/result_data.dart';

import '../values/server.dart';
import 'package:dio/dio.dart';

import 'code.dart';

class HttpManager {
  final Dio _dio = Dio(BaseOptions(baseUrl: SERVER_API_URL));

  Dio getDio() {
    return _dio;
  }

  HttpManager() {
    _dio.interceptors.add(RequestInterceptors());
  }

  Future<ResultData> get(String path, {dynamic params}) async {
    Response response;
    final Options options = Options();
    ResponseType resType = ResponseType.json;
    options.responseType = resType;
    try {
      response = await _dio.get(
        path,
        queryParameters: params == null
            ? null
            : Map<String, dynamic>.from(params),
        options: options,
      );
    } on DioException catch (e) {
      logger.d(e);
      return resultError(e, path);
    }
    return ResultData.fromJson(response.data);
  }

  Future<ResultData> uploadFile(String path, FormData formData) async {
    Response response;
    try {
      response = await _dio.post(
        path,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
    } on DioException catch (e) {
      logger.d(e);
      return resultError(e, path);
    }
    if (response.data is DioException) {
      return resultError(response.data, path);
    }
    return ResultData.fromJson(response.data);
  }

  Future<ResultData> post(String path, {dynamic data}) async {
    Response response;
    try {
      response = await _dio.post(path, data: data);
    } on DioException catch (e) {
      logger.d(e);
      return resultError(e, path);
    }
    if (response.data is DioException) {
      return resultError(response.data, path);
    }
    return ResultData.fromJson(response.data);
  }

  Future<ResultData> resultError(DioException e, String path) async {
    Response errorResponse;
    if (e.response != null) {
      errorResponse = e.response!;
    } else {
      errorResponse = Response(
        statusCode: 666,
        requestOptions: RequestOptions(path: path),
      );
    }
    if (e.type == DioErrorType.connectionTimeout ||
        e.type == DioErrorType.receiveTimeout) {
      errorResponse.statusCode = Code.NETWORK_TIMEOUT;
    }
    return ResultData(
      Code.errorHandleFunction(
        errorResponse.statusCode ?? 500,
        // await ResponseInterceptor.dioError(e),
        "Server connection failed, please check network settings",
      ),
      false,
      errorResponse.statusCode!,
    );
  }
}

final HttpManager httpManager = HttpManager();