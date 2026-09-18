import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home_tab.dart';
import 'upload_tab.dart';
import 'reports_tab.dart';
import 'profile_tab.dart';

/// Hosts the bottom-navigation shell (Home / Upload / Report / Profile),
/// mirroring frames 6, 7-9, 9, and 11 of the design. Each tab keeps its own
/// scroll position thanks to IndexedStack.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  final UserModel _user = UserModel.mock();

  void _goToTab(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final tabs = [
      HomeTab(user: _user, onUploadTapped: () => _goToTab(1)),
      UploadTab(user: _user),
      ReportsTab(user: _user),
      ProfileTab(user: _user),
    ];

    return Scaffold(
      body: SafeArea(child: IndexedStack(index: _index, children: tabs)),
      bottomNavigationBar: AppBottomNavBar(currentIndex: _index, onTap: _goToTab),
    );
  }
}
