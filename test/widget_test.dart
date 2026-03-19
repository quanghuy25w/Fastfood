import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/main.dart';

void main() {
  testWidgets('shows login screen by default', (tester) async {
    await tester.pumpWidget(
      const FastFoodApp(
        initialIsLoggedIn: false,
        initialIsDarkMode: false,
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Đăng nhập'), findsWidgets);
  });
}
