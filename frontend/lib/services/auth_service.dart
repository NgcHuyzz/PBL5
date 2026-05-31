import 'dart:convert';

import 'package:http/http.dart' as http;

import 'token_storage_service.dart';

class AuthService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://pbl5-backend-t23i.onrender.com/api',
  );
  static const Duration _requestTimeout = Duration(seconds: 15);

  static const String registerEndpoint = '/auth/register';
  static const String loginEndpoint = '/auth/login';
  static const String meEndpoint = '/auth/me';

  static Uri buildUri(String path) => Uri.parse('$baseUrl$path');

  static Future<void> saveToken(String token) {
    return TokenStorageService.saveToken(token);
  }

  static Future<String?> getToken() {
    return TokenStorageService.getToken();
  }

  static Future<void> removeToken() {
    return TokenStorageService.removeToken();
  }

  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    final url = buildUri(registerEndpoint);
    final body = {
      'username': username,
      'email': email,
      'password': password,
      'fullName': fullName,
    };

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(_requestTimeout);

      final responseData = _decodeObject(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': responseData['data'],
          'message': responseData['message'] ?? 'Đăng ký thành công',
        };
      }

      return {
        'success': false,
        'message': responseData['message'] ?? 'Đăng ký thất bại',
        'errorCode': responseData['errorCode'],
      };
    } catch (_) {
      return {'success': false, 'message': 'Không thể kết nối đến server'};
    }
  }

  static Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    final url = buildUri(loginEndpoint);
    final body = {'identifier': identifier, 'password': password};

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(_requestTimeout);

      final responseData = _decodeObject(response.body);

      if (response.statusCode == 200) {
        final data = responseData['data'];
        final token = data is Map<String, dynamic> ? data['accessToken'] : null;
        if (token is String && token.isNotEmpty) {
          await saveToken(token);
        }

        return {
          'success': true,
          'data': data,
          'message': responseData['message'] ?? 'Đăng nhập thành công',
        };
      }

      return {
        'success': false,
        'message': responseData['message'] ?? 'Đăng nhập thất bại',
        'errorCode': responseData['errorCode'],
      };
    } catch (_) {
      return {'success': false, 'message': 'Không thể kết nối đến server'};
    }
  }

  static Future<Map<String, dynamic>> getCurrentUser() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      return {'success': false, 'message': 'Vui lòng đăng nhập lại'};
    }

    try {
      final response = await http
          .get(
            buildUri(meEndpoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(_requestTimeout);

      final data = _decodeObject(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data['data']};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Không thể lấy thông tin user',
      };
    } catch (_) {
      return {'success': false, 'message': 'Lỗi kết nối'};
    }
  }

  static Map<String, dynamic> _decodeObject(String body) {
    if (body.isEmpty) return {};

    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return {'data': decoded};
  }
}
