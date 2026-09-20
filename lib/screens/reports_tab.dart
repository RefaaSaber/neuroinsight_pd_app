import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';

/// Diagnostic Reports. Empty until the analysis backend exists —
/// reports are generated separately from the tests you upload.
class ReportsTab extends StatelessWidget {
  final UserModel user;
  const ReportsTab({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Diagnostic Reports', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Reports generated from your tests will appear here.', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 40),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.description_outlined, size: 48, color: AppColors.textSecondary),
                  SizedBox(height: 12),
                  Text('No reports yet', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  SizedBox(height: 4),
                  Text(
                    'Upload a test first — a report is generated once it has been analyzed.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}