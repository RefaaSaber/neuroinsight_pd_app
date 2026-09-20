import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import 'home_tab.dart';
import 'upload_tab.dart';
import 'reports_tab.dart';
import 'profile_tab.dart';

/// Hosts the bottom-navigation shell (Home / Upload / Report / Profile).
class MainShell extends StatefulWidget {
  final UserModel user;
  const MainShell({super.key, required this.user});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  int _homeRefreshKey = 0;

  void _refreshHome() {
    setState(() {
      _homeRefreshKey++;
      _index = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      HomeTab(key: ValueKey(_homeRefreshKey), user: widget.user, onUploadTapped: () => setState(() => _index = 1)),
      UploadTab(user: widget.user, onTestUploaded: _refreshHome),
      ReportsTab(user: widget.user),
      ProfileTab(user: widget.user),
    ];

    return Scaffold(
      body: SafeArea(child: tabs[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primary.withOpacity(0.12),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: AppColors.primary), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.upload_outlined), selectedIcon: Icon(Icons.upload, color: AppColors.primary), label: 'Upload'),
          NavigationDestination(icon: Icon(Icons.description_outlined), selectedIcon: Icon(Icons.description, color: AppColors.primary), label: 'Reports'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: AppColors.primary), label: 'Profile'),
        ],
      ),
    );
  }
}