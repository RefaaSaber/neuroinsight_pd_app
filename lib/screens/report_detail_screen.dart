import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';

/// Frame 10 — Report Detail: doctor's diagnosis + treatment plan.
class ReportDetailScreen extends StatelessWidget {
  final UserModel user;
  final ReportModel report;

  const ReportDetailScreen({super.key, required this.user, required this.report});

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
              children: [
                CircleAvatar(backgroundColor: AppColors.primary, child: Text(user.initials, style: const TextStyle(color: Colors.white))),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text('${report.date}  •  ${report.doctorName}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Doctor's Diagnosis", style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  _detailRow('Diagnosis Result:', report.diagnosisResult, valueChip: true, chipColor: AppColors.chipViewedBg, chipTextColor: AppColors.chipViewedText),
                  const SizedBox(height: 10),
                  _detailRow('Risk Level:', report.riskLevel, valueChip: true, chipColor: AppColors.warning.withOpacity(0.15), chipTextColor: AppColors.warning),
                  const SizedBox(height: 10),
                  Text('Report written: ${report.reportWrittenDate}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Treatment Plan & Recommendations', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  ...report.recommendations.map((rec) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 6),
                              child: Icon(Icons.circle, size: 6, color: AppColors.primary),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(rec)),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool valueChip = false, Color? chipColor, Color? chipTextColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        if (valueChip)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: chipColor, borderRadius: BorderRadius.circular(20)),
            child: Text(value, style: TextStyle(color: chipTextColor, fontWeight: FontWeight.w600, fontSize: 12)),
          )
        else
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
