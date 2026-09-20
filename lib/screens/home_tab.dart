import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../models/user_model.dart';
import '../services/db_helper.dart';
import '../theme/app_theme.dart';

/// Frame 6 — Home. Shows monitoring status, quick actions, and the
/// signed-in user's real recent tests loaded from Firestore.
class HomeTab extends StatefulWidget {
  final UserModel user;
  final VoidCallback onUploadTapped;

  const HomeTab({super.key, required this.user, required this.onUploadTapped});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  bool _loading = true;
  List<RecentTestModel> _tests = [];

  @override
  void initState() {
    super.initState();
    _loadTests();
  }

  Future<void> _loadTests() async {
    final userId = widget.user.id;
    if (userId == null) {
      setState(() => _loading = false);
      return;
    }
    final tests = await DbHelper.instance.getTests(userId);
    if (!mounted) return;
    setState(() {
      _tests = tests;
      _loading = false;
    });
  }

  IconData _iconFor(TestType type) {
    switch (type) {
      case TestType.voice:
        return Icons.mic_none_outlined;
      case TestType.drawing:
      case TestType.both:
        return Icons.edit_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return RefreshIndicator(
      onRefresh: _loadTests,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Good Morning 👋', style: TextStyle(color: Colors.white70)),
                  Text(user.displayName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            const Text('Monitoring Active', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.only(left: 18),
                          child: Text(
                            _tests.isEmpty ? 'No tests yet' : 'Last test: ${_tests.first.date}',
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.mic_none_outlined,
                          title: 'Upload Voice',
                          subtitle: 'Record or upload audio',
                          onTap: widget.onUploadTapped,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.edit_outlined,
                          title: 'Upload Drawing',
                          subtitle: 'Spiral test',
                          onTap: widget.onUploadTapped,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Recent Tests', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 12),
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_tests.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 28),
                      decoration: cardDecoration(),
                      child: const Column(
                        children: [
                          Icon(Icons.inbox_outlined, size: 32, color: AppColors.textSecondary),
                          SizedBox(height: 8),
                          Text('No tests yet', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                          SizedBox(height: 4),
                          Text('Upload a voice or drawing test to get started.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    )
                  else
                    ..._tests.map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: cardDecoration(),
                            child: Row(
                              children: [
                                CircleAvatar(backgroundColor: AppColors.chipNewBg, child: Icon(_iconFor(t.type), color: AppColors.primary, size: 18)),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(t.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    Text(t.date, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}