import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neuroinsight_pd/models/signup_data.dart';
import 'package:neuroinsight_pd/screens/forgot_password_screen.dart';
import 'package:neuroinsight_pd/screens/login_screen.dart';
import 'package:neuroinsight_pd/screens/signup/signup_step1_screen.dart';
import 'package:neuroinsight_pd/screens/signup/signup_step3_screen.dart';

// Shows a screen in a test window.
Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: screen));
  await tester.pumpAndSettle();
}

// Scrolls to a button or text and taps it.
Future<void> tapText(WidgetTester tester, String text) async {
  final finder = find.text(text);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  const loginMessage = 'Please enter your National ID and password.';
  const passwordMessage = 'Please meet all password requirements.';

  // Fills the sign up step 1 form. Each test changes only one value.
  Future<void> fill(
    WidgetTester tester, {
    String first = 'Sara',
    String last = 'Ali',
    String id = '1234567890',
    String email = 'sara@gmail.com',
    String phone = '50123456',
  }) async {
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), first);
    await tester.enterText(fields.at(1), last);
    await tester.enterText(fields.at(2), id);
    await tester.enterText(fields.at(3), email);
    await tester.enterText(fields.at(4), phone);
    await tester.ensureVisible(fields.at(5));
    await tester.pumpAndSettle();
    await tester.tap(fields.at(5));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
  }

  // Types the password and the confirmation, then taps Create Account.
  Future<void> submit(
      WidgetTester tester, String password, String confirm) async {
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), password);
    await tester.enterText(fields.at(1), confirm);
    await tester.pumpAndSettle();
    await tapText(tester, 'Create Account');
  }

  // ===== Test case 1: Login with empty fields =====
  testWidgets('Test case 1: Login with empty fields', (tester) async {
    await pumpScreen(tester, const LoginScreen());
    await tapText(tester, 'Log In');
    expect(find.text(loginMessage), findsOneWidget);
  });

  // ===== Test case 2: Login with empty password =====
  testWidgets('Test case 2: Login with empty password', (tester) async {
    await pumpScreen(tester, const LoginScreen());
    await tester.enterText(find.byType(TextField).at(0), '1234567890');
    await tapText(tester, 'Log In');
    expect(find.text(loginMessage), findsOneWidget);
  });

  // ===== Test case 3: Reset password with empty email =====
  testWidgets('Test case 3: Reset password with empty email', (tester) async {
    await pumpScreen(tester, const ForgotPasswordScreen());
    await tapText(tester, 'Send Reset Link');
    expect(find.text('Please enter your email address.'), findsOneWidget);
  });

  // ===== Test case 4: Reset password with invalid email format =====
  testWidgets('Test case 4: Reset password with invalid email format',
      (tester) async {
    await pumpScreen(tester, const ForgotPasswordScreen());
    await tester.enterText(find.byType(TextField), 'test@');
    await tapText(tester, 'Send Reset Link');
    expect(find.text('Please enter a valid email address.'), findsOneWidget);
  });

  // ===== Test case 5: Sign up with one empty field =====
  testWidgets('Test case 5: Sign up with one empty field', (tester) async {
    await pumpScreen(tester, const SignUpStep1Screen());
    await fill(tester, last: '');
    await tapText(tester, 'Continue');
    expect(find.text('Please fill in all fields.'), findsOneWidget);
  });

  // ===== Test case 6: National ID shorter than 10 digits =====
  testWidgets('Test case 6: National ID shorter than 10 digits',
      (tester) async {
    await pumpScreen(tester, const SignUpStep1Screen());
    await fill(tester, id: '12345');
    await tapText(tester, 'Continue');
    expect(find.text('National ID must be exactly 10 digits.'),
        findsOneWidget);
  });

  // ===== Test case 7: Phone shorter than 8 digits =====
  testWidgets('Test case 7: Phone shorter than 8 digits', (tester) async {
    await pumpScreen(tester, const SignUpStep1Screen());
    await fill(tester, phone: '1234567');
    await tapText(tester, 'Continue');
    expect(find.text('Phone number must be exactly 8 digits.'),
        findsOneWidget);
  });

  // ===== Test case 8: National ID with letters =====
  testWidgets('Test case 8: National ID with letters', (tester) async {
    await pumpScreen(tester, const SignUpStep1Screen());
    await tester.enterText(find.byType(TextField).at(2), 'abc123');
    final field = tester.widget<TextField>(find.byType(TextField).at(2));
    expect(field.controller!.text, '123');
  });

  // ===== Test case 9: Password shorter than 8 characters =====
  testWidgets('Test case 9: Password shorter than 8 characters',
      (tester) async {
    await pumpScreen(tester, SignUpStep3Screen(data: SignupData()));
    await submit(tester, 'Ab1!', 'Ab1!');
    expect(find.text(passwordMessage), findsOneWidget);
  });

  // ===== Test case 10: Password without a capital letter =====
  testWidgets('Test case 10: Password without a capital letter',
      (tester) async {
    await pumpScreen(tester, SignUpStep3Screen(data: SignupData()));
    await submit(tester, 'test@1234', 'test@1234');
    expect(find.text(passwordMessage), findsOneWidget);
  });

  // ===== Test case 11: Password without a lowercase letter =====
  testWidgets('Test case 11: Password without a lowercase letter',
      (tester) async {
    await pumpScreen(tester, SignUpStep3Screen(data: SignupData()));
    await submit(tester, 'TEST@1234', 'TEST@1234');
    expect(find.text(passwordMessage), findsOneWidget);
  });

  // ===== Test case 12: Password without a number =====
  testWidgets('Test case 12: Password without a number', (tester) async {
    await pumpScreen(tester, SignUpStep3Screen(data: SignupData()));
    await submit(tester, 'Test@abcd', 'Test@abcd');
    expect(find.text(passwordMessage), findsOneWidget);
  });

  // ===== Test case 13: Password without a special character =====
  testWidgets('Test case 13: Password without a special character',
      (tester) async {
    await pumpScreen(tester, SignUpStep3Screen(data: SignupData()));
    await submit(tester, 'Test1234', 'Test1234');
    expect(find.text(passwordMessage), findsOneWidget);
  });

  // ===== Test case 14: Passwords do not match =====
  testWidgets('Test case 14: Passwords do not match', (tester) async {
    await pumpScreen(tester, SignUpStep3Screen(data: SignupData()));
    await submit(tester, 'Test@1234', 'Test@12345');
    expect(find.text('Passwords do not match.'), findsOneWidget);
  });

  // ===== Test case 15: Strong password shows the checklist =====
  testWidgets('Test case 15: Strong password shows 5 ticks', (tester) async {
    await pumpScreen(tester, SignUpStep3Screen(data: SignupData()));
    await tester.enterText(find.byType(TextField).at(0), 'Test@1234');
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_circle), findsNWidgets(5));
  });

  // ===== Test case 16: Password without a capital letter shows 4 ticks =====
  testWidgets('Test case 16: Password without a capital letter shows 4 ticks',
      (tester) async {
    await pumpScreen(tester, SignUpStep3Screen(data: SignupData()));
    await tester.enterText(find.byType(TextField).at(0), 'test@1234');
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_circle), findsNWidgets(4));
  });
}