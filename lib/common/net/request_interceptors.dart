

import 'package:dio/dio.dart';

import '../../services/auth_service.dart';

class RequestInterceptors  extends InterceptorsWrapper {
   final List<String> publicPaths = ['/auth/login'];

   @override
   Future<void> onRequest(
       RequestOptions options,
       RequestInterceptorHandler handler,
       ) async {
     await _addAuthorizationHeader(options);
     handler.next(options);
   }


   Future<void> _addAuthorizationHeader(RequestOptions options) async {

     if (_isPublicPath(options.path)) {
       return;
     }

     final authService = AuthService();
     final token = await authService.getTokenForInterceptor();
     if (token != null && token.isNotEmpty) {
       options.headers['Authorization'] = 'Bearer $token';
     }
   }

   bool _isPublicPath(String path) {
     return publicPaths.any((publicPath) => path.contains(publicPath));
   }
}