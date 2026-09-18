import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import '../widgets/status_chip.dart';
import 'report_detail_screen.dart';

/// Frame 9 — Diagnostic Reports list.
class ReportsTab extends StatelessWidget {
  final UserModel user;
  const ReportsTab({super.key, required this.user});

  IconData _iconFor(TestType type) {
    switch (type) {
      case TestType.voice:
        return Icons.mic_none_outlined;
      case TestType.drawing:
        return Icons.edit_outlined;
      case TestType.both:
        return Icons.dashboard_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final reports = ReportModel.mockList();

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 12, bottom: 8),
          child: Text('Diagnostic Reports', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: reports.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final r = reports[i];
              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ReportDetailScreen(user: user, report: r)),
                ),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: cardDecoration(),
                  child: Row(
                    children: [
                      CircleAvatar(backgroundColor: AppColors.chipNewBg, child: Icon(_iconFor(r.testType), color: AppColors.primary, size: 18)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text('${r.doctorName}\n${r.date}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          StatusChip(status: r.status),
                          const SizedBox(height: 14),
                          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
