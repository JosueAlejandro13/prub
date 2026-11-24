import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

/// Cliente HTTP configurado con Dio
class ApiClient {
  final Dio dio;

  ApiClient({Dio? client})
      : dio = client ??
            Dio(
              BaseOptions(
                baseUrl: ApiConstants.baseUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
                headers: {'Content-Type': 'application/json'},
              ),
            );
}
