import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SystemService {
  static const String baseUrl = 'https://pbl5-backend-t23i.onrender.com/api';
  
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // ✅ 1. ดึงรายการ Systems ทั้งหมด
  static Future<Map<String, dynamic>> getSystems() async {
    final url = Uri.parse('$baseUrl/systems');
    final token = await getToken();
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      print('Get systems status: ${response.statusCode}');
      print('Get systems body: ${response.body}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Không thể lấy danh sách systems'};
      }
    } catch (e) {
      print('Error: $e');
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // ✅ 2. Đăng ký System mới
  static Future<Map<String, dynamic>> registerSystem({
    required String name,
    required String description,
    required String location,
  }) async {
    final url = Uri.parse('$baseUrl/systems/register?name=$name&description=$description&location=$location');
    final token = await getToken();
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      print('Register system status: ${response.statusCode}');
      print('Register system body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Đăng ký system thất bại'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // ✅ 3. Lấy trạng thái điều khiển hệ thống (cần systemId)
  static Future<Map<String, dynamic>> getControlState(String systemId) async {
    final url = Uri.parse('$baseUrl/system/control-state?systemId=$systemId');
    final token = await getToken();
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      print('Control state status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Không thể lấy trạng thái'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // ✅ 4. Điều khiển hệ thống (Start/Pause/Stop)
  static Future<Map<String, dynamic>> controlSystem(String systemId, String action) async {
    final url = Uri.parse('$baseUrl/system/control?systemId=$systemId');
    final token = await getToken();
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'action': action}),
      );
      
      print('Control system status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Điều khiển thất bại'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // ✅ 5. Lấy kết quả phân loại mới nhất
  static Future<Map<String, dynamic>> getLatestDetection(String systemId) async {
    final url = Uri.parse('$baseUrl/detections/latest?systemId=$systemId');
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
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Không có dữ liệu phân loại'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // ✅ 6. Lấy danh sách phân loại gần đây
  static Future<Map<String, dynamic>> getRecentDetections(String systemId, {int limit = 10}) async {
    final url = Uri.parse('$baseUrl/detections/recent?systemId=$systemId&limit=$limit');
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
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Không có dữ liệu'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // ✅ 7. Lấy thống kê tổng quan
  static Future<Map<String, dynamic>> getStatisticsSummary(
    String systemId, {
    String? from,
    String? to,
  }) async {
    final url = Uri.parse('$baseUrl/detections/statistics-summary?systemId=$systemId')
        .replace(queryParameters: {
          if (from != null) 'from': from,
          if (to != null) 'to': to,
        });
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
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Lỗi khi lấy thống kê'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối'};
    }
  }

  // ✅ 8. Lấy thống kê theo loại trái cây
  static Future<Map<String, dynamic>> getStatisticsByFruit(
    String systemId, {
    String? from,
    String? to,
  }) async {
    final url = Uri.parse('$baseUrl/detections/count-by-fruit?systemId=$systemId')
        .replace(queryParameters: {
          if (from != null) 'from': from,
          if (to != null) 'to': to,
        });
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
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Lỗi khi lấy thống kê theo loại'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối'};
    }
  }

  // ✅ 9. Lấy lịch sử phân loại (có phân trang)
  static Future<Map<String, dynamic>> getDetectionHistory(
    String systemId, {
    int page = 0,
    int size = 10,
    String? fruitType,
    String? status,
    String? from,
    String? to,
  }) async {
    final url = Uri.parse('$baseUrl/detections?systemId=$systemId')
        .replace(queryParameters: {
          'page': page.toString(),
          'size': size.toString(),
          if (fruitType != null && fruitType != 'all') 'fruitType': fruitType,
          if (status != null && status != 'all') 'status': status,
          if (from != null) 'from': from,
          if (to != null) 'to': to,
        });
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
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Lỗi khi lấy lịch sử'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối'};
    }
  }

  // ✅ 10. Lấy danh sách thông báo
  static Future<Map<String, dynamic>> getNotifications(
    String systemId, {
    String? level,
    int page = 0,
    int size = 10,
  }) async {
    final url = Uri.parse('$baseUrl/notifications?systemId=$systemId')
        .replace(queryParameters: {
          'page': page.toString(),
          'size': size.toString(),
          if (level != null && level != 'all') 'level': level,
        });
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
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Lỗi khi lấy thông báo'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối'};
    }
  }

  // ✅ 11. Đánh dấu đã đọc thông báo
  static Future<Map<String, dynamic>> markNotificationRead(String systemId, String notificationId) async {
    final url = Uri.parse('$baseUrl/notifications/$notificationId/read?systemId=$systemId');
    final token = await getToken();
    
    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Đánh dấu thất bại'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối'};
    }
  }

  // ✅ 12. Đánh dấu tất cả đã đọc
  static Future<Map<String, dynamic>> markAllNotificationsRead(String systemId) async {
    final url = Uri.parse('$baseUrl/notifications/read-all?systemId=$systemId');
    final token = await getToken();
    
    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Đánh dấu thất bại'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối'};
    }
  }

  // ✅ 13. Lấy số lượng thông báo chưa đọc
  static Future<Map<String, dynamic>> getUnreadCount(String systemId) async {
    final url = Uri.parse('$baseUrl/notifications/unread-count?systemId=$systemId');
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
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Lỗi khi lấy số lượng'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối'};
    }
  }
}