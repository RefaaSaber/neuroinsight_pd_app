// Smoke test for the Welcome screen: the first screen the app shows.
// This replaces the old default Flutter counter-app test, which referenced
// a class ('MyApp') that no longer exists in this project.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:neuroinsight_pd/screens/welcome_screen.dart';

void main() {
  testWidgets('Welcome screen shows title and entry points', (
    WidgetTester tester,
  ) async {
    // Build just the Welcome screen (not the full app) so this test doesn't
    // need Firebase to be initialized.
    await tester.pumpWidget(
      const MaterialApp(home: WelcomeScreen()),
    );

    expect(find.text('NeuroInsight-PD'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });
}
