import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/services/system_service.dart';

void main() {
  test('statistics summary uri keeps systemId with date filters', () {
    final uri = SystemService.buildUri(
      '/detections/statistics-summary',
      queryParameters: {
        'systemId': 'system-123',
        'from': '2026-03-01T00:00:00.000',
        'to': '2026-03-31T23:59:59.000',
      },
    );

    expect(uri.path, '/api/detections/statistics-summary');
    expect(uri.queryParameters['systemId'], 'system-123');
    expect(uri.queryParameters['from'], '2026-03-01T00:00:00.000');
    expect(uri.queryParameters['to'], '2026-03-31T23:59:59.000');
  });

  test('history uri includes systemId and pagination together', () {
    final uri = SystemService.buildUri(
      '/detections',
      queryParameters: {
        'systemId': 'system-123',
        'page': '2',
        'size': '10',
        'status': 'COMPLETED',
      },
    );

    expect(uri.path, '/api/detections');
    expect(uri.queryParameters['systemId'], 'system-123');
    expect(uri.queryParameters['page'], '2');
    expect(uri.queryParameters['size'], '10');
    expect(uri.queryParameters['status'], 'COMPLETED');
  });

  test('register system uri encodes query parameter values', () {
    final uri = SystemService.buildUri(
      '/systems/register',
      queryParameters: {
        'name': 'Line A & B',
        'description': 'Camera sorter',
        'location': 'Khu A - Xưởng đóng gói',
      },
    );

    expect(uri.queryParameters['name'], 'Line A & B');
    expect(uri.queryParameters['location'], 'Khu A - Xưởng đóng gói');
  });
}
