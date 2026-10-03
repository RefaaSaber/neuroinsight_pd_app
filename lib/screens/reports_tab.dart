import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../models/user_model.dart';
import '../services/db_helper.dart';
import '../theme/app_theme.dart';
import 'report_detail_screen.dart';

/// Diagnostic Reports — written by a doctor on the companion web portal
/// after reviewing an AI analysis, then synced here via Firestore.
class ReportsTab extends StatefulWidget {
  final UserModel user;
  const ReportsTab({super.key, required this.user});

  @override
  State<ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends State<ReportsTab> {
  bool _loading = true;
  List<ReportModel> _reports = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  // Loads the user's reports from Firestore.
  Future<void> _load() async {
    final userId = widget.user.id;
    if (userId == null) {
      setState(() => _loading = false);
      return;
    }
    final reports = await DbHelper.instance.getReports(userId);
    if (!mounted) return;
    setState(() {
      _reports = reports;
      _loading = false;
    });
  }

  // Marks a "new" report as viewed, then opens its detail screen.
  Future<void> _open(ReportModel report) async {
    final userId = widget.user.id;
    if (userId != null && report.status == ReportStatus.new_) {
      await DbHelper.instance.markReportViewed(userId, report.id);
    }
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ReportDetailScreen(user: widget.user, report: report)),
    );
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Diagnostic Reports', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Reports your doctor has written will appear here.', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _reports.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 80),
                            Icon(Icons.description_outlined, size: 48, color: AppColors.textSecondary),
                            SizedBox(height: 12),
                            Text(
                              'No reports yet',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Upload a test first — a report is generated once it has been analyzed.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: _reports.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final report = _reports[i];
                            final isNew = report.status == ReportStatus.new_;
                            return InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () => _open(report),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: cardDecoration(),
                                child: Row(
                                  children: [
                                    const CircleAvatar(
                                      backgroundColor: AppColors.chipNewBg,
                                      child: Icon(Icons.description_outlined, color: AppColors.primary, size: 18),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(report.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                                          Text(
                                            '${report.doctorName} · ${report.reportWrittenDate}',
                                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isNew)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppColors.chipNewBg,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Text(
                                          'New',
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
