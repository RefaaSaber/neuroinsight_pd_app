import 'package:flutter/material.dart';
import '../services/voice_model_service.dart';
import '../theme/app_theme.dart';

/// Shows the real result returned by the NeuroInsight-PD voice model
/// after a voice-data file has been submitted to /predict.
class VoiceResultScreen extends StatelessWidget {
  final VoicePredictionResult result;

  const VoiceResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final isPd = result.predictionCode == 1;
    final percent = (result.probabilityPd * 100).toStringAsFixed(1);

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
                    decoration: BoxDecoration(
                      color: isPd ? AppColors.warning : AppColors.success,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPd ? Icons.warning_amber_rounded : Icons.check,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Analysis Complete', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(
                    result.prediction,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Probability of Parkinson\'s indicators: $percent%',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'This is an automated model result, not a medical diagnosis. Please discuss it with your doctor.',
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
