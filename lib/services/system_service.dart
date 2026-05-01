import 'dart:convert';

import 'package:http/http.dart' as http;

import 'token_storage_service.dart';

class SystemService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://pbl5-backend-t23i.onrender.com/api',
  );
  static const Duration _requestTimeout = Duration(seconds: 15);

  static Uri buildUri(
    String path, {
    Map<String, String?> queryParameters = const {},
  }) {
    final uri = Uri.parse('$baseUrl$path');
    final params = <String, String>{};

    for (final entry in queryParameters.entries) {
      final value = entry.value;
      if (value != null && value.isNotEmpty) {
        params[entry.key] = value;
      }
    }

    return params.isEmpty ? uri : uri.replace(queryParameters: params);
  }

  static Future<String?> getToken() {
    return TokenStorageService.getToken();
  }

  static Future<Map<String, String>?> _authHeaders() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      return null;
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Map<String, dynamic> _unauthenticated() {
    return {'success': false, 'message': 'Vui lòng đăng nhập lại'};
  }

  static Future<Map<String, dynamic>> _sendJson(
    Future<http.Response> Function(Map<String, String> headers) send, {
    Set<int> successStatusCodes = const {200},
    required String failureMessage,
    String connectionMessage = 'Không thể kết nối',
  }) async {
    final headers = await _authHeaders();
    if (headers == null) {
      return _unauthenticated();
    }

    try {
      final response = await send(headers).timeout(_requestTimeout);
      final data = _decodeObject(response.body);

      if (successStatusCodes.contains(response.statusCode)) {
        if (data.containsKey('success') || data.containsKey('data')) {
          return {if (!data.containsKey('success')) 'success': true, ...data};
        }

        return {'success': true, 'data': data};
      }

      return {
        'success': false,
        'message': data['message'] ?? failureMessage,
        if (data['errorCode'] != null) 'errorCode': data['errorCode'],
      };
    } catch (_) {
      return {'success': false, 'message': connectionMessage};
    }
  }

  static Future<Map<String, dynamic>> getSystems() {
    final url = buildUri('/systems');
    return _sendJson(
      (headers) => http.get(url, headers: headers),
      failureMessage: 'Không thể lấy danh sách systems',
      connectionMessage: 'Lỗi kết nối',
    );
  }

  static Future<Map<String, dynamic>> registerSystem({
    required String name,
    required String description,
    required String location,
  }) {
    final url = buildUri(
      '/systems/register',
      queryParameters: {
        'name': name,
        'description': description,
        'location': location,
      },
    );

    return _sendJson(
      (headers) => http.post(url, headers: headers),
      successStatusCodes: const {200, 201},
      failureMessage: 'Đăng ký system thất bại',
      connectionMessage: 'Lỗi kết nối',
    );
  }

  static Future<Map<String, dynamic>> createSystem({
    required String systemId,
    required String systemName,
    required String description,
    required String location,
  }) {
    final url = buildUri('/systems');

    return _sendJson(
      (headers) => http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'systemId': systemId,
          'systemName': systemName,
          'description': description,
          'location': location,
        }),
      ),
      successStatusCodes: const {200, 201},
      failureMessage: 'Tạo hệ thống thất bại',
      connectionMessage: 'Lỗi kết nối',
    );
  }

  static Future<Map<String, dynamic>> getControlState(String systemId) {
    final url = buildUri(
      '/system/control-state',
      queryParameters: {'systemId': systemId},
    );
    return _sendJson(
      (headers) => http.get(url, headers: headers),
      failureMessage: 'Không thể lấy trạng thái',
      connectionMessage: 'Lỗi kết nối',
    );
  }

  static Future<Map<String, dynamic>> controlSystem(
    String systemId,
    String action,
  ) {
    final url = buildUri(
      '/system/control',
      queryParameters: {'systemId': systemId},
    );
    return _sendJson(
      (headers) => http.post(
        url,
        headers: headers,
        body: jsonEncode({'action': action}),
      ),
      failureMessage: 'Điều khiển thất bại',
      connectionMessage: 'Lỗi kết nối',
    );
  }

  static Future<Map<String, dynamic>> getLatestDetection(String systemId) {
    final url = buildUri(
      '/detections/latest',
      queryParameters: {'systemId': systemId},
    );
    return _sendJson(
      (headers) => http.get(url, headers: headers),
      failureMessage: 'Không có dữ liệu phân loại',
      connectionMessage: 'Lỗi kết nối',
    );
  }

  static Future<Map<String, dynamic>> getRecentDetections(
    String systemId, {
    int limit = 10,
  }) {
    final url = buildUri(
      '/detections/recent',
      queryParameters: {'systemId': systemId, 'limit': limit.toString()},
    );
    return _sendJson(
      (headers) => http.get(url, headers: headers),
      failureMessage: 'Không có dữ liệu',
      connectionMessage: 'Lỗi kết nối',
    );
  }

  static Future<Map<String, dynamic>> getStatisticsSummary(
    String systemId, {
    String? from,
    String? to,
  }) {
    final url = buildUri(
      '/detections/statistics-summary',
      queryParameters: {'systemId': systemId, 'from': from, 'to': to},
    );
    return _sendJson(
      (headers) => http.get(url, headers: headers),
      failureMessage: 'Lỗi khi lấy thống kê',
    );
  }

  static Future<Map<String, dynamic>> getStatisticsByFruit(
    String systemId, {
    String? from,
    String? to,
  }) {
    final url = buildUri(
      '/detections/count-by-fruit',
      queryParameters: {'systemId': systemId, 'from': from, 'to': to},
    );
    return _sendJson(
      (headers) => http.get(url, headers: headers),
      failureMessage: 'Lỗi khi lấy thống kê theo loại',
    );
  }

  static Future<Map<String, dynamic>> getDetectionHistory(
    String systemId, {
    int page = 0,
    int size = 10,
    String? fruitType,
    String? status,
    String? from,
    String? to,
  }) {
    final url = buildUri(
      '/detections',
      queryParameters: {
        'systemId': systemId,
        'page': page.toString(),
        'size': size.toString(),
        if (fruitType != null && fruitType != 'all') 'fruitType': fruitType,
        if (status != null && status != 'all') 'status': status,
        'from': from,
        'to': to,
      },
    );
    return _sendJson(
      (headers) => http.get(url, headers: headers),
      failureMessage: 'Lỗi khi lấy lịch sử',
    );
  }

  static Future<Map<String, dynamic>> getNotifications(
    String systemId, {
    String? level,
    int page = 0,
    int size = 10,
  }) {
    final url = buildUri(
      '/notifications',
      queryParameters: {
        'systemId': systemId,
        'page': page.toString(),
        'size': size.toString(),
        if (level != null && level != 'all') 'level': level,
      },
    );
    return _sendJson(
      (headers) => http.get(url, headers: headers),
      failureMessage: 'Lỗi khi lấy thông báo',
    );
  }

  static Future<Map<String, dynamic>> markNotificationRead(
    String systemId,
    String notificationId,
  ) {
    final url = buildUri(
      '/notifications/$notificationId/read',
      queryParameters: {'systemId': systemId},
    );
    return _sendJson(
      (headers) => http.patch(url, headers: headers),
      failureMessage: 'Đánh dấu thất bại',
      connectionMessage: 'Lỗi kết nối',
    );
  }

  static Future<Map<String, dynamic>> markAllNotificationsRead(
    String systemId,
  ) {
    final url = buildUri(
      '/notifications/read-all',
      queryParameters: {'systemId': systemId},
    );
    return _sendJson(
      (headers) => http.patch(url, headers: headers),
      failureMessage: 'Đánh dấu thất bại',
      connectionMessage: 'Lỗi kết nối',
    );
  }

  static Future<Map<String, dynamic>> getUnreadCount(String systemId) {
    final url = buildUri(
      '/notifications/unread-count',
      queryParameters: {'systemId': systemId},
    );
    return _sendJson(
      (headers) => http.get(url, headers: headers),
      failureMessage: 'Lỗi khi lấy số lượng',
    );
  }

  static Map<String, dynamic> _decodeObject(String body) {
    if (body.isEmpty) return {};

    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return {'success': true, 'data': decoded};
  }
}
