import 'package:flutter/material.dart';

import '../../core/data/app_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/mascot_widget.dart';
import '../home/home_page.dart';
import '../journal/mood_options.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  final AppPreferences _preferences = const AppPreferences();

  int _currentPage = 0;
  MoodOption? _selectedMood;
  bool _isCompleting = false;

  bool get _canContinue {
    if (_currentPage == 1) {
      return _nameController.text.trim().isNotEmpty;
    }
    if (_currentPage == 2) {
      return _selectedMood != null;
    }
    return !_isCompleting;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _goNext() async {
    if (!_canContinue) {
      return;
    }

    if (_currentPage == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Harika! Artık sen ${_nameController.text.trim()}, ben Günbi!',
          ),
          duration: const Duration(milliseconds: 1200),
        ),
      );
    }

    if (_currentPage == 3) {
      await _completeOnboarding();
      return;
    }

    await _pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _completeOnboarding() async {
    setState(() => _isCompleting = true);

    final childName = _nameController.text.trim();
    await _preferences.completeOnboarding(childName: childName);

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => HomePage(childName: childName)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
          child: Column(
            children: [
              _ProgressDots(currentPage: _currentPage),
              const SizedBox(height: 16),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  children: [
                    const _WelcomeStep(),
                    _NameStep(
                      controller: _nameController,
                      onChanged: (_) => setState(() {}),
                    ),
                    _MoodStep(
                      selectedMood: _selectedMood,
                      onMoodSelected: (mood) {
                        setState(() => _selectedMood = mood);
                      },
                    ),
                    _InviteStep(name: _nameController.text.trim()),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _canContinue ? _goNext : null,
                child: Text(_buttonText),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _buttonText {
    if (_isCompleting) {
      return 'Hazırlanıyor...';
    }
    if (_currentPage == 0) {
      return 'Başlayalım!';
    }
    if (_currentPage == 3) {
      return 'Ana sayfaya geç';
    }
    return 'Devam';
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep();

  @override
  Widget build(BuildContext context) {
    return const _OnboardingStep(
      title: 'Merhaba! Ben Günbi!',
      message:
          'Senin yazı arkadaşınım. Birlikte gününü anlatmanın eğlenceli yollarını bulacağız.',
      child: MascotWidget(),
    );
  }
}

class _NameStep extends StatelessWidget {
  const _NameStep({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return _OnboardingStep(
      title: 'Seni nasıl çağırayım?',
      message: 'Seni nasıl çağıracağımı bilmem için küçük bir isim yazalım mı?',
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(hintText: 'Adım...'),
      ),
    );
  }
}

class _MoodStep extends StatelessWidget {
  const _MoodStep({required this.selectedMood, required this.onMoodSelected});

  final MoodOption? selectedMood;
  final ValueChanged<MoodOption> onMoodSelected;

  @override
  Widget build(BuildContext context) {
    return _OnboardingStep(
      title: 'Bugün nasıl hissediyorsun?',
      message: 'Bir duygu seç. Doğru ya da yanlış cevap yok.',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: [
          for (final mood in moodOptions)
            ChoiceChip(
              label: Text(mood.displayText),
              selected: selectedMood == mood,
              onSelected: (_) => onMoodSelected(mood),
              selectedColor: AppTheme.softBlue,
              backgroundColor: Colors.white,
              labelStyle: Theme.of(context).textTheme.bodyLarge,
              side: BorderSide(
                color: selectedMood == mood
                    ? AppTheme.softBlue
                    : AppTheme.pastelYellow,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
        ],
      ),
    );
  }
}

class _InviteStep extends StatelessWidget {
  const _InviteStep({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final greeting = name.isEmpty ? 'Sana' : '$name, sana';

    return _OnboardingStep(
      title: '$greeting küçük bir sır vereyim...',
      message:
          'Yazmak bazen konuşmaktan daha kolay olur. Hazır olduğunda ana sayfanda buluşalım!',
      child: const MascotWidget(size: 132),
    );
  }
}

class _OnboardingStep extends StatelessWidget {
  const _OnboardingStep({
    required this.title,
    required this.message,
    required this.child,
  });

  final String title;
  final String message;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            child,
            const SizedBox(height: 34),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.headlineMedium,
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.currentPage});

  final int currentPage;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final isActive = index == currentPage;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.lightOrange : AppTheme.pastelYellow,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}
