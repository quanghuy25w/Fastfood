import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mini_shopp/main.dart';
import 'package:mini_shopp/providers/auth_provider.dart';
import 'package:mini_shopp/providers/cart_provider.dart';
import 'package:mini_shopp/providers/theme_provider.dart';

void main() {
  testWidgets('App khởi động (splash)', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
        ],
        child: const MiniShoppRoot(),
      ),
    );
    expect(find.byType(MiniShoppRoot), findsOneWidget);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
