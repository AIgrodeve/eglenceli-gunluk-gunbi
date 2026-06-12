import 'package:flutter/material.dart';

import '../features/home/home_page.dart';
import '../features/onboarding/onboarding_flow.dart';
import 'data/app_preferences.dart';
import 'models/age_group.dart';
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

    return FutureBuilder<(bool, String?, AgeGroup?)>(
      future: _loadStartupState(preferences),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final (hasCompletedOnboarding, childName, ageGroup) = snapshot.data!;
        if (hasCompletedOnboarding && childName != null) {
          return HomePage(childName: childName, ageGroup: ageGroup);
        }

        return const OnboardingFlow();
      },
    );
  }

  Future<(bool, String?, AgeGroup?)> _loadStartupState(
    AppPreferences preferences,
  ) async {
    final hasCompletedOnboarding = await preferences.hasCompletedOnboarding();
    final childName = await preferences.loadChildName();
    final ageGroup = await preferences.loadChildAgeGroup();
    return (hasCompletedOnboarding, childName, ageGroup);
  }
}
