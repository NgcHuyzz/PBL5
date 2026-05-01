import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('shows login screen first', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Hệ thống Phân loại Trái cây'), findsOneWidget);
    expect(find.text('Đăng nhập'), findsOneWidget);
    expect(find.text('Đăng ký'), findsOneWidget);
  });
}
