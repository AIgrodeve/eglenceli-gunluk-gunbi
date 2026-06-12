import 'package:flutter/material.dart';

import '../features/home/home_page.dart';
import '../features/onboarding/onboarding_flow.dart';
import 'data/app_preferences.dart';
import 'theme/app_theme.dart';

class FunJournalApp extends StatelessWidget {
  const FunJournalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eğlenceli Günlük',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const AppStartup(),
    );
  }
}

class AppStartup extends StatelessWidget {
  const AppStartup({super.key});

  @override
  Widget build(BuildContext context) {
    const preferences = AppPreferences();

    return FutureBuilder<(bool, String?)>(
      future: _loadStartupState(preferences),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final (hasCompletedOnboarding, childName) = snapshot.data!;
        if (hasCompletedOnboarding && childName != null) {
          return HomePage(childName: childName);
        }

        return const OnboardingFlow();
      },
    );
  }

  Future<(bool, String?)> _loadStartupState(AppPreferences preferences) async {
    final hasCompletedOnboarding = await preferences.hasCompletedOnboarding();
    final childName = await preferences.loadChildName();
    return (hasCompletedOnboarding, childName);
  }
}
