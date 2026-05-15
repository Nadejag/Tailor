import 'package:flutter_test/flutter_test.dart';

import 'package:tailor/main.dart';

void main() {
  testWidgets('shows login screen when signed out', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Tailor App'), findsOneWidget);
    expect(
      find.text('Manage designs, wardrobe, measurements and payments.'),
      findsOneWidget,
    );
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('opens signup screen from login', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    final signUpLink = find.text('Sign Up');
    await tester.ensureVisible(signUpLink);
    await tester.tap(signUpLink);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Create Account'), findsWidgets);
    expect(find.text('Select Role'), findsOneWidget);
  });
}
