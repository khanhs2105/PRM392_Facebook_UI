import 'package:flutter_test/flutter_test.dart';

import 'package:facebook_ui/main.dart';

void main() {
  testWidgets('Shows login page when not logged in', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp(loggedIn: false));

    expect(find.byType(LoginPage), findsOneWidget);
  });
}
