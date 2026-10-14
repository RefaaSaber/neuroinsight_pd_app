import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:neuroinsight_pd/firebase_options.dart';
import 'package:neuroinsight_pd/models/report_model.dart';
import 'package:neuroinsight_pd/models/user_model.dart';
import 'package:neuroinsight_pd/services/cloudinary_upload_service.dart';
import 'package:neuroinsight_pd/services/db_helper.dart';
import 'package:neuroinsight_pd/services/drawing_model_service.dart';
import 'package:neuroinsight_pd/services/voice_model_service.dart';

// Reuses the helpers from app_test.dart (makeAccount, loginWith, waitFor ...)
import 'app_test.dart' hide main;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late TestAccount patient;

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // ST-01: a new patient account is created
    patient = await makeAccount();
  });

  tearDownAll(() async {
    await deleteAccount(patient);
  });

  group('System test: patient to doctor journey', () {

        // ST-01: the account was created in setUpAll
    test('ST-01: A new patient account is created', () async {
      expect(patient.user.id, isNotNull);
      expect(patient.user.role, 'Patient');
    });
    // ST-02: the patient logs in through the real app screens
    testWidgets('ST-02: Patient logs in and the main screen opens',
        (tester) async {
      await loginWith(tester, patient.nationalId, testPassword);
      await waitFor(tester, find.text('Home'));
      expect(find.text('Reports'), findsWidgets);
    });

    // ST-03: the voice model server returns a prediction
    late Map<String, dynamic> voiceResult;
    test('ST-03: Voice test gets a prediction from the model server',
        () async {
      final result = await VoiceModelService.instance.predict(
        {for (final n in voiceModelFeatureNames) n: 0.5},
      );
      expect(result.prediction, isNotEmpty);
      voiceResult = {
        'prediction': result.prediction,
        'predictionCode': result.prediction == 'PD' ? 1 : 0,
        'probabilityPd': result.probabilityPd,
      };
    }, timeout: longTimeout);

    // ST-04: the drawing is analysed and uploaded
    test('ST-04: Spiral drawing gets a prediction and is uploaded',
        () async {
      final bytes = await makeSpiralPng();
      final result = await DrawingModelService.instance
          .predict(bytes: bytes, filename: 'spiral.png');
      expect(result.prediction, isNotEmpty);
      final url = await CloudinaryUploadService.instance
          .uploadImage(bytes: bytes, filename: 'spiral.png');
      expect(url, startsWith('https://'));
    }, timeout: longTimeout);

    // ST-05: the test is saved and appears in the patient's history
    test('ST-05: The test is saved and waits for the doctor', () async {
      await signInAs(patient);
      await DbHelper.instance.addTest(
        userId: patient.uid,
        title: 'System test voice',
        date: '2026-10-14',
        type: TestType.voice,
        predictionResult: voiceResult,
      );
      final tests = await DbHelper.instance.getTests(patient.uid);
      expect(tests.any((t) => t.title == 'System test voice'), isTrue);
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(patient.uid)
          .collection('tests')
          .where('title', isEqualTo: 'System test voice')
          .get();
      expect(snap.docs.first.data()['status'], 'pending_review');
    });

    // ST-06: the doctor writes a draft and then submits a report
    // (the same data the web portal writes to Firestore)
    test('ST-06: A draft is hidden, a submitted report is shown', () async {
      await seedReport(patient.uid, 'st_draft', 'draft', 'Draft report');
      var reports = await DbHelper.instance.getReports(patient.uid);
      expect(reports.map((r) => r.title), isNot(contains('Draft report')));

      await seedReport(
          patient.uid, 'st_submitted', 'submitted', 'Final report');
      reports = await DbHelper.instance.getReports(patient.uid);
      expect(reports.map((r) => r.title), contains('Final report'));
    });

    // ST-07: the patient opens the report and it is marked as viewed
    test('ST-07: The patient opens the report and it is marked viewed',
        () async {
      await DbHelper.instance.markReportViewed(patient.uid, 'st_submitted');
      final reports = await DbHelper.instance.getReports(patient.uid);
      expect(reports.firstWhere((r) => r.id == 'st_submitted').status,
          ReportStatus.viewed);
    });
  });
}