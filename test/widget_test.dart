import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:herresso/main.dart';
import 'package:herresso/providers/auth_provider.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {

    final authProvider = AuthProvider();

    await tester.pumpWidget(HerressoApp(authProvider: authProvider));

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsWidgets);
  });
}
