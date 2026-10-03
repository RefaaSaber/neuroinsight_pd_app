// App entry point: sets up Firebase, then launches the app starting at
// the Welcome screen.
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/welcome_screen.dart';
import 'theme/app_theme.dart';

// Initializes Firebase before anything else runs, then starts the app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const NeuroInsightApp());
}

/// Root widget: sets up the app's theme and starting screen.
class NeuroInsightApp extends StatelessWidget {
  const NeuroInsightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NeuroInsight-PD',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const WelcomeScreen(),
    );
  }
}