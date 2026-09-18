import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../theme/app_theme.dart';

/// Small "New" / "Viewed" pill shown on report list rows.
class StatusChip extends StatelessWidget {
  final ReportStatus status;
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isNew = status == ReportStatus.new_;
    final bg = isNew ? AppColors.chipNewBg : AppColors.chipViewedBg;
    final fg = isNew ? AppColors.chipNewText : AppColors.chipViewedText;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        isNew ? 'New' : 'Viewed',
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
