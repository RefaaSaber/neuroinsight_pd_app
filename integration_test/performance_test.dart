import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:neuroinsight_pd/firebase_options.dart';
import 'package:neuroinsight_pd/services/cloudinary_upload_service.dart';
import 'package:neuroinsight_pd/services/db_helper.dart';
import 'package:neuroinsight_pd/services/drawing_model_service.dart';
import 'package:neuroinsight_pd/services/voice_model_service.dart';

// Reuses the helpers from app_test.dart (makeAccount, seedReport ...)
import 'app_test.dart' hide main;

// Runs an action and returns how many seconds it took.
Future<double> measure(String name, Future<void> Function() action) async {
  final watch = Stopwatch()..start();
  await action();
  watch.stop();
  final seconds = watch.elapsedMilliseconds / 1000;
  print('PERFORMANCE | $name | ${seconds.toStringAsFixed(2)} s');
  return seconds;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late TestAccount patient;

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    patient = await makeAccount();
    await signInAs(patient);
    // 20 submitted reports, so the list has a realistic size
    for (var i = 1; i <= 20; i++) {
      await seedReport(patient.uid, 'perf_$i', 'submitted', 'Report $i');
    }
  });

  tearDownAll(() async {
    await deleteAccount(patient);
  });

  group('Performance', () {
    test('PT-01: Login time (limit 5 s)', () async {
      final s = await measure('PT-01 Login', () async {
        final user = await DbHelper.instance
            .login(nationalId: patient.nationalId, password: testPassword);
        expect(user, isNotNull);
      });
      expect(s, lessThan(5));
    });

    test('PT-02: Loading 20 reports (limit 3 s)', () async {
      final s = await measure('PT-02 Load 20 reports', () async {
        final reports = await DbHelper.instance.getReports(patient.uid);
        expect(reports.length, greaterThanOrEqualTo(20));
      });
      expect(s, lessThan(3));
    });

    test('PT-03: 5 users load reports at the same time (limit 5 s)',
        () async {
      final s = await measure('PT-03 5 parallel loads', () async {
        await Future.wait(
          List.generate(
              5, (_) => DbHelper.instance.getReports(patient.uid)),
        );
      });
      expect(s, lessThan(5));
    });

    test('PT-04: Voice model, first request (limit 60 s)', () async {
      final s = await measure('PT-04 Voice first request', () async {
        await VoiceModelService.instance
            .predict({for (final n in voiceModelFeatureNames) n: 0.5});
      });
      expect(s, lessThan(60));
    }, timeout: longTimeout);

    test('PT-05: Voice model, second request (limit 10 s)', () async {
      final s = await measure('PT-05 Voice second request', () async {
        await VoiceModelService.instance
            .predict({for (final n in voiceModelFeatureNames) n: 0.5});
      });
      expect(s, lessThan(10));
    }, timeout: longTimeout);

    test('PT-06: Drawing model prediction (limit 30 s)', () async {
      final bytes = await makeSpiralPng();
      final s = await measure('PT-06 Drawing prediction', () async {
        await DrawingModelService.instance
            .predict(bytes: bytes, filename: 'spiral.png');
      });
      expect(s, lessThan(30));
    }, timeout: longTimeout);

    test('PT-07: Image upload to Cloudinary (limit 10 s)', () async {
      final bytes = await makeSpiralPng();
      final s = await measure('PT-07 Cloudinary upload', () async {
        await CloudinaryUploadService.instance
            .uploadImage(bytes: bytes, filename: 'spiral.png');
      });
      expect(s, lessThan(10));
    }, timeout: longTimeout);
  });
}