// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:otopark_demo/main.dart';

void main() {
  testWidgets('Otopark app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const OtoparkApp());

    // Verify that login page is displayed.
    expect(find.text('Otopark Yönetim Sistemi'), findsOneWidget);
    expect(find.text('Kullanıcı Adı'), findsOneWidget);
    expect(find.text('Şifre'), findsOneWidget);
  });
}
