import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:neuroinsight_pd/firebase_options.dart';
import 'package:neuroinsight_pd/main.dart';
import 'package:neuroinsight_pd/models/report_model.dart';
import 'package:neuroinsight_pd/models/user_model.dart';
import 'package:neuroinsight_pd/screens/forgot_password_screen.dart';
import 'package:neuroinsight_pd/services/cloudinary_upload_service.dart';
import 'package:neuroinsight_pd/services/db_helper.dart';
import 'package:neuroinsight_pd/services/drawing_model_service.dart';
import 'package:neuroinsight_pd/services/voice_model_service.dart';

const testPassword = 'Test@1234';

// ---------- A fake patient created just for the tests ----------
class TestAccount {
  TestAccount(this.user, this.nationalId, this.email);
  final UserModel user;
  final String nationalId;
  final String email;
  String get uid => user.id!;
}

Future<TestAccount> makeAccount() async {
  final t = DateTime.now().microsecondsSinceEpoch.toString();
  final nationalId = '9${t.substring(t.length - 9)}';
  final email = 'it_$t@example.com';
  final user = await DbHelper.instance.createUser(
    firstName: 'ITTest',
    lastName: 'Account',
    fullName: 'ITTest Account',
    nationalId: nationalId,
    email: email,
    phone: '50123456',
    dateOfBirth: '2000-01-01',
    password: testPassword,
  );
  if (user == null) throw TestFailure('Could not create the test account.');
  return TestAccount(user, nationalId, email);
}

Future<void> signInAs(TestAccount a) async {
  await FirebaseAuth.instance
      .signInWithEmailAndPassword(email: a.email, password: testPassword);
}

// Removes the test account when the tests finish.
Future<void> deleteAccount(TestAccount a) async {
  try {
    await signInAs(a);
    final uid = a.uid;
    final users = FirebaseFirestore.instance.collection('users').doc(uid);
    try {
      for (final sub in ['reports', 'tests']) {
        final docs = await users.collection(sub).get();
        for (final d in docs.docs) {
          await d.reference.delete();
        }
      }
      await users.delete();
    } catch (_) {}
    await FirebaseAuth.instance.currentUser?.delete();
  } catch (_) {}
}

Future<void> seedReport(
    String uid, String id, String status, String title) async {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('reports')
      .doc(id)
      .set({
    'status': status,
    'title': title,
    'doctorName': 'Dr. Test',
    'writtenAt': Timestamp.now(),
    'testIds': ['t1'],
    'testTypeLabels': ['Voice'],
    'clinicalNotes': 'Notes',
    'recommendations': 'Rest',
    'reportViewed': false,
  });
}

// ---------- Helpers for the screens ----------
Future<void> waitFor(WidgetTester tester, Finder finder,
    {int seconds = 25}) async {
  final end = DateTime.now().add(Duration(seconds: seconds));
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 300));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Did not find $finder within $seconds seconds');
}

Future<void> tapText(WidgetTester tester, String text) async {
  final finder = find.text(text);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pump();
}

Future<void> loginWith(
    WidgetTester tester, String nationalId, String password) async {
  await tester.pumpWidget(const NeuroInsightApp());
  await tester.pumpAndSettle();
  await tapText(tester, 'Log In'); // Welcome screen button
  await tester.pumpAndSettle();
  final fields = find.byType(TextField);
  await tester.enterText(fields.at(0), nationalId);
  await tester.enterText(fields.at(1), password);
  await tester.pumpAndSettle();
  await tapText(tester, 'Log In'); // Login screen button
}

Future<void> resetWith(WidgetTester tester, String email) async {
  await tester.pumpWidget(const MaterialApp(home: ForgotPasswordScreen()));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField).first, email);
  await tester.pumpAndSettle();
  await tapText(tester, 'Send Reset Link');
}

// ---------- A drawn spiral image for the drawing tests ----------
Future<Uint8List> makeSpiralPng() async {
  const size = 256.0;
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  canvas.drawRect(const ui.Rect.fromLTWH(0, 0, size, size),
      ui.Paint()..color = const ui.Color(0xFFFFFFFF));
  final path = ui.Path()..moveTo(size / 2, size / 2);
  for (var t = 0.0; t < 6 * math.pi; t += 0.05) {
    final r = 5 * t;
    path.lineTo(size / 2 + r * math.cos(t), size / 2 + r * math.sin(t));
  }
  canvas.drawPath(
    path,
    ui.Paint()
      ..color = const ui.Color(0xFF000000)
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 3,
  );
  final image = await recorder.endRecording().toImage(256, 256);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}

Matcher throwsMessage(String text) => throwsA(
      isA<Exception>().having((e) => e.toString(), 'message', contains(text)),
    );

const longTimeout = Timeout(Duration(minutes: 3));

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late TestAccount account;

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    account = await makeAccount();
  });

  tearDownAll(() async {
    await deleteAccount(account);
  });

  // ================= Screens with the real Firebase =================
  group('Screens', () {
    testWidgets('IT-01: Login with correct data opens the main screen',
        (tester) async {
      await loginWith(tester, account.nationalId, testPassword);
      await waitFor(tester, find.text('Home'));
      expect(find.text('Reports'), findsWidgets);
    });

    testWidgets('IT-02: Login with an unregistered National ID',
        (tester) async {
      await loginWith(tester, '0000000000', testPassword);
      await waitFor(tester, find.text('Incorrect National ID or password.'));
      expect(find.text('Incorrect National ID or password.'), findsOneWidget);
    });

    testWidgets('IT-03: Login with a wrong password', (tester) async {
      await loginWith(tester, account.nationalId, 'Wrong@999');
      await waitFor(tester, find.text('Incorrect National ID or password.'));
      expect(find.text('Incorrect National ID or password.'), findsOneWidget);
    });

    testWidgets('IT-04: Reset password with a registered email',
        (tester) async {
      await resetWith(tester, account.email);
      await waitFor(tester, find.text('Email Sent!'));
      expect(find.text('Email Sent!'), findsOneWidget);
    });

     testWidgets('IT-05: Reset password with an unregistered email',
        (tester) async {
      await resetWith(tester, 'unknown-person-xyz@example.com');
      await waitFor(tester, find.text('Email Sent!'));
      expect(find.text('Email Sent!'), findsOneWidget);
    });
  });

  // ================= Accounts and tests in Firebase =================
  group('Accounts and data', () {
    test('IT-06: Create an account and log in with it', () async {
      expect(account.user.id, isNotNull);
      expect(account.user.role, 'Patient');
      final logged = await DbHelper.instance
          .login(nationalId: account.nationalId, password: testPassword);
      expect(logged, isNotNull);
      expect(logged!.nationalId, account.nationalId);
    });

    test('IT-07: Create an account with an email already registered',
        () async {
      final again = await DbHelper.instance.createUser(
        firstName: 'ITTest',
        lastName: 'Duplicate',
        fullName: 'ITTest Duplicate',
        nationalId: '9000000000',
        email: account.email,
        phone: '50123456',
        dateOfBirth: '2000-01-01',
        password: testPassword,
      );
print('IT-07 result: ${again == null ? "No account created" : "Account created"}');    });

    test('IT-08: Login with an account that has no email saved', () async {
      final other = await makeAccount();
      await DbHelper.instance
          .updateContact(userId: other.uid, email: '', phone: '50123456');
      final result = await DbHelper.instance
          .login(nationalId: other.nationalId, password: testPassword);
      expect(result, isNull);
      await deleteAccount(other);
    });

    test('IT-13: A saved test appears in the test history', () async {
      await signInAs(account);
      await DbHelper.instance.addTest(
        userId: account.uid,
        title: 'IT voice test',
        date: '2026-10-11',
        type: TestType.voice,
        predictionResult: {
          'prediction': 'PD',
          'predictionCode': 1,
          'probabilityPd': 0.8,
        },
      );
      final tests = await DbHelper.instance.getTests(account.uid);
      expect(
        tests.any((t) => t.title == 'IT voice test' && t.type == TestType.voice),
        isTrue,
      );
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(account.uid)
          .collection('tests')
          .where('title', isEqualTo: 'IT voice test')
          .get();
      expect(snap.docs.first.data()['status'], 'pending_review');
    });
  });

  // ================= Reports =================
  group('Reports', () {
    setUpAll(() async {
      await signInAs(account);
      await seedReport(account.uid, 'r_submitted', 'submitted',
          'Submitted report');
      await seedReport(account.uid, 'r_draft', 'draft', 'Draft report');
    });

    test('IT-09: A submitted report is listed', () async {
      final reports = await DbHelper.instance.getReports(account.uid);
      expect(reports.map((r) => r.title), contains('Submitted report'));
    });

    test('IT-10: A draft report is not listed', () async {
      final reports = await DbHelper.instance.getReports(account.uid);
      expect(reports.map((r) => r.title), isNot(contains('Draft report')));
    });

    test('IT-11: Opening a report marks it as viewed', () async {
      var reports = await DbHelper.instance.getReports(account.uid);
      expect(reports.firstWhere((r) => r.id == 'r_submitted').status,
          ReportStatus.new_);
      await DbHelper.instance.markReportViewed(account.uid, 'r_submitted');
      reports = await DbHelper.instance.getReports(account.uid);
      expect(reports.firstWhere((r) => r.id == 'r_submitted').status,
          ReportStatus.viewed);
    });

    test('IT-12: An account with no reports gets an empty list', () async {
      final other = await makeAccount();
      final reports = await DbHelper.instance.getReports(other.uid);
      expect(reports, isEmpty);
      await deleteAccount(other);
    });
  });

  // ================= Real model servers and Cloudinary =================
  group('Servers', () {
    test('IT-14: Voice model returns a prediction', () async {
      final result = await VoiceModelService.instance.predict(
        {for (final n in voiceModelFeatureNames) n: 0.5},
      );
      expect(result.prediction, isNotEmpty);
      expect(result.probabilityPd, inInclusiveRange(0.0, 1.0));
    }, timeout: longTimeout);

    test('IT-15: Voice model rejects empty features', () async {
      await expectLater(
        VoiceModelService.instance.predict({}),
        throwsMessage('Model API returned'),
      );
    }, timeout: longTimeout);

    test('IT-16: Drawing model returns a prediction', () async {
      final bytes = await makeSpiralPng();
      final result = await DrawingModelService.instance
          .predict(bytes: bytes, filename: 'spiral.png');
      expect(result.prediction, isNotEmpty);
      expect(result.parkinsonProbability, inInclusiveRange(0.0, 1.0));
      expect([0, 1], contains(result.predictionCode));
    }, timeout: longTimeout);

    test('IT-17: Drawing model rejects a file that is not an image',
        () async {
      await expectLater(
        DrawingModelService.instance.predict(
          bytes: Uint8List.fromList([1, 2, 3]),
          filename: 'bad.png',
        ),
        throwsMessage('Model API returned'),
      );
    }, timeout: longTimeout);

    test('IT-18: Cloudinary upload returns an image link', () async {
      final bytes = await makeSpiralPng();
      final url = await CloudinaryUploadService.instance
          .uploadImage(bytes: bytes, filename: 'spiral.png');
      expect(url, startsWith('https://'));
    }, timeout: longTimeout);
  });
}