import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // ✅ Server จริงของเพื่อน
  static const String baseUrl = 'https://pbl5-backend-t23i.onrender.com/api';
  
  // ✅ Endpoint ที่ถูกต้อง (ตาม README เพื่อน)
  static const String registerEndpoint = '/auth/register';
  static const String loginEndpoint = '/auth/login';
  static const String meEndpoint = '/auth/me';
  
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }
  
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  // ✅ REGISTER - ใช้ endpoint ที่ถูกต้อง
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    final url = Uri.parse('$baseUrl$registerEndpoint');
    
    final body = {
      'username': username,
      'email': email,
      'password': password,
      'fullName': fullName,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print('Register response status: ${response.statusCode}');
      print('Register response body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': responseData['data'],
          'message': responseData['message'] ?? 'Đăng ký thành công'
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Đăng ký thất bại',
          'errorCode': responseData['errorCode']
        };
      }
    } catch (e) {
      print('Register error: $e');
      return {'success': false, 'message': 'Không thể kết nối đến server: $e'};
    }
  }

  // ✅ LOGIN - ใช้ endpoint ที่ถูกต้อง
  static Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl$loginEndpoint');
    
    final body = {
      'identifier': identifier,
      'password': password,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = responseData['data']['accessToken'];
        await saveToken(token);
        
        return {
          'success': true,
          'data': responseData['data'],
          'message': responseData['message'] ?? 'Đăng nhập thành công'
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Đăng nhập thất bại',
          'errorCode': responseData['errorCode']
        };
      }
    } catch (e) {
      print('Login error: $e');
      return {'success': false, 'message': 'Không thể kết nối đến server: $e'};
    }
  }

  // ✅ GET CURRENT USER
  static Future<Map<String, dynamic>> getCurrentUser() async {
    final url = Uri.parse('$baseUrl$meEndpoint');
    final token = await getToken();
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'message': 'Không thể lấy thông tin user'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối'};
    }
  }
}