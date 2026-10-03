// Report Detail screen: shows one doctor-written report in full, with
// the covered test types, clinical notes, and recommendations.
import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';

/// Frame 10 — Report Detail: doctor's diagnosis + treatment plan.
class ReportDetailScreen extends StatelessWidget {
  final UserModel user;
  final ReportModel report;

  const ReportDetailScreen({super.key, required this.user, required this.report});

  // Lays out the patient header, test-type chips, assessment card, and
  // recommendations list (if any) in a scrollable column.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).maybePop()),
        title: const Text('Diagnostic Report'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(backgroundColor: AppColors.primary, child: Text(user.initials, style: const TextStyle(color: Colors.white))),
                const SizedBox(width: 12),
                // Expanded so a long report title (e.g. a combined
                // multi-test report) wraps onto a second line instead of
                // overflowing past the right edge of the screen.
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(report.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('${report.reportWrittenDate}  •  ${report.doctorName}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            if (report.testTypeLabels.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text('Covers:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ),
                  for (final label in report.testTypeLabels)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.chipNewBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Doctor's Assessment", style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Text(report.clinicalNotes.isEmpty ? 'No notes provided.' : report.clinicalNotes),
                ],
              ),
            ),
            if (report.recommendations.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Recommendations', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    ...report.recommendations.split('\n').where((line) => line.trim().isNotEmpty).map(
                          (line) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 6),
                                  child: Icon(Icons.circle, size: 6, color: AppColors.primary),
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: Text(line.trim())),
                              ],
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
