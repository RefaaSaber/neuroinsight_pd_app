import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../theme/app_theme.dart';

/// Frames 12 & 13 — "Upload Successful!" confirmation, shared by both the
/// voice and the drawing upload flows.
class UploadSuccessScreen extends StatelessWidget {
  final TestType testType;

  const UploadSuccessScreen({super.key, required this.testType});

  @override
  Widget build(BuildContext context) {
    final noun = testType == TestType.voice ? 'voice recording' : 'drawing image';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: cardDecoration(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                    child: const Icon(Icons.check, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 20),
                  const Text('Upload Successful!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(
                    'Your $noun has been submitted for AI analysis.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'Your doctor will review the AI result and write a report for you.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                      child: const Text('OK — Go to Home'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
