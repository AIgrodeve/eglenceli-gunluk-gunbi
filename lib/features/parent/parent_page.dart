import 'package:flutter/material.dart';

import '../../core/data/app_reset_service.dart';
import '../../core/models/age_group.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/mascot_widget.dart';
import '../journal/data/journal_repository.dart';
import '../journal/models/journal_entry.dart';
import '../journal/services/advanced_writing_review_service.dart';
import '../journal/services/advanced_writing_review_settings_service.dart';
import '../onboarding/onboarding_flow.dart';
import '../premium/premium_page.dart';
import '../premium/services/premium_service.dart';
import '../rewards/models/journal_stats.dart';
import '../streak/services/streak_service.dart';
import '../weekly_summary/services/weekly_summary_service.dart';
import 'services/parent_pin_service.dart';

class ParentPage extends StatefulWidget {
  const ParentPage({
    super.key,
    required this.childName,
    required this.ageGroup,
  });

  final String childName;
  final AgeGroup ageGroup;

  @override
  State<ParentPage> createState() => _ParentPageState();
}

class _ParentPageState extends State<ParentPage> {
  final JournalRepository _repository = const JournalRepository();
  final StreakService _streakService = const StreakService();
  final WeeklySummaryService _weeklySummaryService =
      const WeeklySummaryService();
  final ParentPinService _parentPinService = const ParentPinService();
  final AppResetService _resetService = const AppResetService();
  final TextEditingController _pinController = TextEditingController();

  bool _isVerified = false;
  bool _isResetting = false;
  String? _pinErrorText;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _verifyPin() async {
    if (_isResetting) {
      return;
    }

    final verified = await _parentPinService.verifyPin(_pinController.text);
    if (!mounted) {
      return;
    }

    if (verified) {
      setState(() {
        _isVerified = true;
        _pinErrorText = null;
      });
      return;
    }

    setState(() => _pinErrorText = 'Åifre hatalÄ±. LÃ¼tfen tekrar deneyin.');
  }

  Future<void> _startForgotPinResetFlow() async {
    final shouldContinue = await _showForgotPinInfoDialog();
    if (shouldContinue != true || !mounted) {
      return;
    }

    final shouldReset = await _showForgotPinResetConfirmDialog();
    if (shouldReset != true || !mounted) {
      return;
    }

    setState(() => _isResetting = true);

    try {
      // Bu ÅŸifre sÄ±fÄ±rlama akÄ±ÅŸÄ± gÃ¼Ã§lÃ¼ kimlik doÄŸrulama yerine geÃ§mez.
      // Uygulamada hesap/sunucu olmadÄ±ÄŸÄ± iÃ§in ÅŸifre unutma durumunda yerel
      // veriler silinerek ebeveyn ÅŸifresi varsayÄ±lan deÄŸere dÃ¶ndÃ¼rÃ¼lÃ¼r.
      await _resetService.clearAllLocalData();
      if (!mounted) {
        return;
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => const OnboardingFlow(
            initialMessage: 'Veriler bu cihazdan silindi.',
          ),
        ),
        (_) => false,
      );
    } catch (error, stackTrace) {
      debugPrint('Forgot parent PIN reset failed: $error\n$stackTrace');
      if (!mounted) {
        return;
      }

      setState(() => _isResetting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veriler silinirken bir sorun oluÅŸtu. LÃ¼tfen tekrar deneyin.',
          ),
        ),
      );
    }
  }

  Future<bool?> _showForgotPinInfoDialog() {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ebeveyn ÅŸifresini sÄ±fÄ±rla'),
        content: const SingleChildScrollView(
          child: Text(
            'Ebeveyn ÅŸifresini sÄ±fÄ±rlamak iÃ§in uygulamadaki tÃ¼m yerel verilerin silinmesi gerekir. Bu iÅŸlem gÃ¼nlÃ¼k yazÄ±larÄ±nÄ±, profil bilgilerini, rozet ilerlemesini, kitap baÅŸlÄ±ÄŸÄ±nÄ± ve yerel ayarlarÄ± siler. Premium satÄ±n alma varsa Google Play Ã¼zerinden tekrar geri yÃ¼klenebilir.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('VazgeÃ§'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Devam et'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showForgotPinResetConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tüm veriler silinsin mi?'),
        content: const SingleChildScrollView(
          child: Text(
            'Bu iÅŸlem geri alÄ±namaz. Devam edersen ebeveyn ÅŸifresi 1234 olarak sÄ±fÄ±rlanÄ±r ve uygulama ilk kurulum ekranÄ±na dÃ¶ner.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('VazgeÃ§'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('TÃ¼m verileri sil ve sÄ±fÄ±rla'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVerified) {
      return _ParentGate(
        pinController: _pinController,
        errorText: _pinErrorText,
        onVerify: _verifyPin,
        onForgotPin: _startForgotPinResetFlow,
        isBusy: _isResetting,
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ebeveyn AlanÄ±')),
      body: SafeArea(
        child: FutureBuilder<_ParentSummaryData>(
          future: _loadSummary(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final summary =
                snapshot.data ??
                _ParentSummaryData.empty(
                  childName: widget.childName,
                  ageGroup: widget.ageGroup,
                );

            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Center(
                  child: MascotWidget(
                    size: 96,
                    mood: MascotMood.calm,
                    showShadow: false,
                  ),
                ),
                const SizedBox(height: 16),
                const _InfoPanel(
                  title: 'GÃ¼venli geliÅŸim Ã¶zeti',
                  message:
                      'Bu alan, Ã§ocuÄŸun yazma alÄ±ÅŸkanlÄ±ÄŸÄ±nÄ± gÃ¼venli ÅŸekilde takip etmek iÃ§in hazÄ±rlanmÄ±ÅŸtÄ±r.',
                ),
                const SizedBox(height: 12),
                const _InfoPanel(
                  title: 'Mahremiyet',
                  message:
                      'GÃ¼nlÃ¼k yazÄ±lar Ã§ocuÄŸa Ã¶zeldir. Burada sadece geliÅŸim Ã¶zeti gÃ¶sterilir.',
                  isSoftBlue: true,
                ),
                const SizedBox(height: 18),
                const _TrustOverviewPanel(),
                const SizedBox(height: 18),
                if (summary.totalEntries == 0)
                  const _EmptyParentSummary()
                else
                  _SummaryGrid(summary: summary),
                const SizedBox(height: 18),
                const _PremiumManagementPanel(),
                const SizedBox(height: 18),
                const _AdvancedWritingReviewPanel(),
                const SizedBox(height: 18),
                const _ParentPinSection(),
                const SizedBox(height: 18),
                const _SafetyPrinciples(),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<_ParentSummaryData> _loadSummary() async {
    final entries = await _repository.loadEntries();
    final journalStats = JournalStats.fromEntries(entries);
    final streakStats = _streakService.calculate(entries);
    final weeklySummary = _weeklySummaryService.calculate(entries);

    return _ParentSummaryData(
      childName: widget.childName,
      ageGroup: widget.ageGroup,
      totalEntries: journalStats.totalEntries,
      totalWords: journalStats.totalWords,
      totalWrittenDays: streakStats.totalWrittenDays,
      currentStreak: streakStats.currentStreak,
      bestStreak: streakStats.bestStreak,
      weeklyEntryCount: weeklySummary.entryCount,
      weeklyWrittenDayCount: weeklySummary.writtenDayCount,
      mostFrequentMood: _mostFrequentMood(entries),
    );
  }

  String _mostFrequentMood(List<JournalEntry> entries) {
    if (entries.isEmpty) {
      return 'HenÃ¼z yok';
    }

    final counts = <String, int>{};
    final emojis = <String, String>{};
    for (final entry in entries) {
      counts[entry.moodLabel] = (counts[entry.moodLabel] ?? 0) + 1;
      emojis[entry.moodLabel] = entry.moodEmoji;
    }

    var bestMood = counts.keys.first;
    var bestCount = counts[bestMood] ?? 0;
    for (final entry in counts.entries) {
      if (entry.value > bestCount) {
        bestMood = entry.key;
        bestCount = entry.value;
      }
    }

    return '${emojis[bestMood] ?? ''} $bestMood'.trim();
  }
}

class _ParentGate extends StatelessWidget {
  const _ParentGate({
    required this.pinController,
    required this.errorText,
    required this.onVerify,
    required this.onForgotPin,
    required this.isBusy,
  });

  final TextEditingController pinController;
  final String? errorText;
  final VoidCallback onVerify;
  final VoidCallback onForgotPin;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ebeveyn AlanÄ±')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Bu alan ebeveynler iÃ§indir. Devam etmek iÃ§in ebeveyn ÅŸifresini girin.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'GÃ¼nlÃ¼k iÃ§erikleri Ã§ocuÄŸa Ã¶zeldir; burada sadece geliÅŸim Ã¶zeti gÃ¶sterilir.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: pinController,
                    enabled: !isBusy,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'Åifre',
                      errorText: errorText,
                    ),
                    onSubmitted: (_) => onVerify(),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: isBusy ? null : onVerify,
                    child: Text(isBusy ? 'Sıfırlanıyor...' : 'Giriş yap'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: isBusy ? null : onForgotPin,
                    child: const Text('Åifremi unuttum'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PremiumManagementPanel extends StatelessWidget {
  const _PremiumManagementPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.pastelYellow, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Premium', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Premium satÄ±n alma ve geri yÃ¼kleme iÅŸlemleri yalnÄ±zca Ebeveyn AlanÄ± Ã¼zerinden yÃ¶netilir.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const PremiumPage()),
              );
            },
            icon: const Icon(Icons.workspace_premium_rounded),
            label: const Text('Premium yÃ¶netimi'),
          ),
        ],
      ),
    );
  }
}

class _AdvancedWritingReviewPanel extends StatefulWidget {
  const _AdvancedWritingReviewPanel();

  @override
  State<_AdvancedWritingReviewPanel> createState() =>
      _AdvancedWritingReviewPanelState();
}

class _AdvancedWritingReviewPanelState
    extends State<_AdvancedWritingReviewPanel> {
  final PremiumService _premiumService = const PremiumService();
  final AdvancedWritingReviewService _advancedReviewService =
      const AdvancedWritingReviewService();
  final AdvancedWritingReviewSettingsService _settingsService =
      const AdvancedWritingReviewSettingsService();

  late Future<_AdvancedWritingReviewState> _stateFuture;

  @override
  void initState() {
    super.initState();
    _stateFuture = _loadState();
  }

  Future<_AdvancedWritingReviewState> _loadState() async {
    final isPremiumUnlocked = await _premiumService.isPremiumUnlocked();
    final isEnabled = await _settingsService.isEnabled();
    return _AdvancedWritingReviewState(
      isPremiumUnlocked: isPremiumUnlocked,
      isApiConfigured: _advancedReviewService.isConfigured,
      isEnabled:
          isPremiumUnlocked && _advancedReviewService.isConfigured && isEnabled,
    );
  }

  Future<void> _setEnabled(bool value) async {
    await _settingsService.setEnabled(value);
    if (!mounted) {
      return;
    }

    setState(() => _stateFuture = _loadState());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? 'Gelişmiş Günbi Yazı Kontrolü açıldı.'
              : 'GeliÅŸmiÅŸ GÃ¼nbi YazÄ± KontrolÃ¼ kapatÄ±ldÄ±.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_AdvancedWritingReviewState>(
      future: _stateFuture,
      builder: (context, snapshot) {
        final state =
            snapshot.data ?? const _AdvancedWritingReviewState.empty();
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.softBlue.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.softBlue, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.fact_check_rounded, color: AppTheme.cocoa),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GeliÅŸmiÅŸ GÃ¼nbi YazÄ± KontrolÃ¼',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Premium kapsamÄ±ndaki bu Ã¶zellik ebeveyn onayÄ±yla aÃ§Ä±lÄ±r. GÃ¼nbi Ã§ocuÄŸun yerine yazmaz; sadece yazÄ±m ve noktalama Ã¶nerileri sunar.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                state.isApiConfigured
                    ? 'API bağlantısı yapılandırılmış. Bu ayar açılırsa yazı, yalnızca yazım ve noktalama önerileri için güvenli backend üzerinden kontrol edilir.'
                    : 'API baÄŸlantÄ±sÄ± henÃ¼z yapÄ±landÄ±rÄ±lmadÄ±. Bu yÃ¼zden yazÄ±lar dÄ±ÅŸ servise gÃ¶nderilmez ve geliÅŸmiÅŸ kontrol aÃ§Ä±lmaz.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: state.isEnabled,
                onChanged:
                    isLoading ||
                        !state.isPremiumUnlocked ||
                        !state.isApiConfigured
                    ? null
                    : _setEnabled,
                title: const Text('Ebeveyn onayÄ±'),
                subtitle: Text(
                  !state.isPremiumUnlocked
                      ? 'Bu ayar Premium açılınca kullanılabilir.'
                      : !state.isApiConfigured
                      ? 'Backend URL tanımlanınca kullanılabilir.'
                      : 'Premium aÃ§Ä±k. GeliÅŸmiÅŸ kontrolÃ¼ aÃ§Ä±p kapatabilirsin.',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AdvancedWritingReviewState {
  const _AdvancedWritingReviewState({
    required this.isPremiumUnlocked,
    required this.isApiConfigured,
    required this.isEnabled,
  });

  const _AdvancedWritingReviewState.empty()
    : isPremiumUnlocked = false,
      isApiConfigured = false,
      isEnabled = false;

  final bool isPremiumUnlocked;
  final bool isApiConfigured;
  final bool isEnabled;
}

class _ParentPinSection extends StatefulWidget {
  const _ParentPinSection();

  @override
  State<_ParentPinSection> createState() => _ParentPinSectionState();
}

class _ParentPinSectionState extends State<_ParentPinSection> {
  final ParentPinService _parentPinService = const ParentPinService();
  final TextEditingController _currentPinController = TextEditingController();
  final TextEditingController _newPinController = TextEditingController();
  final TextEditingController _repeatPinController = TextEditingController();

  String? _errorText;

  @override
  void dispose() {
    _currentPinController.dispose();
    _newPinController.dispose();
    _repeatPinController.dispose();
    super.dispose();
  }

  Future<void> _updatePin() async {
    // Bu basit ebeveyn kontrolÃ¼, gÃ¼Ã§lÃ¼ gÃ¼venlik veya kullanÄ±cÄ± hesabÄ± yerine
    // geÃ§mez. Ã‡ocuklarÄ±n yanlÄ±ÅŸlÄ±kla ebeveyn alanÄ±na girmesini azaltmak iÃ§in
    // kullanÄ±lÄ±r.
    final result = await _parentPinService.updatePin(
      currentPin: _currentPinController.text,
      newPin: _newPinController.text,
      repeatedPin: _repeatPinController.text,
    );
    if (!mounted) {
      return;
    }

    if (result == ParentPinUpdateResult.success) {
      _currentPinController.clear();
      _newPinController.clear();
      _repeatPinController.clear();
      setState(() => _errorText = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ebeveyn ÅŸifresi gÃ¼ncellendi.')),
      );
      return;
    }

    setState(() {
      _errorText = switch (result) {
        ParentPinUpdateResult.empty => 'Åifre boÅŸ olamaz.',
        ParentPinUpdateResult.tooShort => 'Åifre en az 4 karakter olmalÄ±.',
        ParentPinUpdateResult.mismatch => 'Yeni ÅŸifreler aynÄ± olmalÄ±.',
        ParentPinUpdateResult.wrongCurrentPin => 'Mevcut ÅŸifre doÄŸru deÄŸil.',
        ParentPinUpdateResult.success => null,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.lightOrange, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Ebeveyn Åifresi',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'VarsayÄ±lan ÅŸifre 1234â€™tÃ¼r. Ä°stersen buradan deÄŸiÅŸtirebilirsin.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _currentPinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Mevcut ÅŸifre'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _newPinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Yeni ÅŸifre'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _repeatPinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Yeni ÅŸifre tekrar',
              errorText: _errorText,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _updatePin,
            icon: const Icon(Icons.lock_reset_rounded),
            label: const Text('Åifreyi gÃ¼ncelle'),
          ),
        ],
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({
    required this.title,
    required this.message,
    this.isSoftBlue = false,
  });

  final String title;
  final String message;
  final bool isSoftBlue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isSoftBlue
            ? AppTheme.softBlue.withValues(alpha: 0.2)
            : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSoftBlue ? AppTheme.softBlue : AppTheme.pastelYellow,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(message, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _TrustOverviewPanel extends StatelessWidget {
  const _TrustOverviewPanel();

  @override
  Widget build(BuildContext context) {
    const items = [
      _TrustItem(
        icon: Icons.lock_rounded,
        title: 'Ebeveyn ÅŸifresi',
        message:
            'Bu alan ÅŸifreyle aÃ§Ä±lÄ±r. VarsayÄ±lan ÅŸifre 1234 olarak baÅŸlar ve deÄŸiÅŸtirilebilir.',
      ),
      _TrustItem(
        icon: Icons.child_care_rounded,
        title: 'Ã‡ocuÄŸun mahremiyeti',
        message:
            'Ebeveyn Ã¶zetinde gÃ¼nlÃ¼k yazÄ±larÄ±nÄ±n tam metni gÃ¶sterilmez.',
      ),
      _TrustItem(
        icon: Icons.cloud_off_rounded,
        title: 'Cihazda saklama',
        message:
            'GÃ¼nlÃ¼kler, profil bilgileri ve yerel ayarlar bu cihazda tutulur.',
      ),
      _TrustItem(
        icon: Icons.delete_outline_rounded,
        title: 'Veri kontrolÃ¼',
        message:
            'Ayarlar bÃ¶lÃ¼mÃ¼nden ebeveyn ÅŸifresiyle tÃ¼m yerel veriler silinebilir.',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.softBlue.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.softBlue, width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('GÃ¼ven Ã–zeti', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          for (final item in items) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(item.icon, color: AppTheme.cocoa, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.message,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (item != items.last) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _TrustItem {
  const _TrustItem({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;
}

class _EmptyParentSummary extends StatelessWidget {
  const _EmptyParentSummary();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.pastelYellow, width: 1.5),
      ),
      child: Text(
        'HenÃ¼z yazÄ± eklenmemiÅŸ. Ä°lk yazÄ±dan sonra geliÅŸim Ã¶zeti burada gÃ¶rÃ¼necek.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.summary});

  final _ParentSummaryData summary;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _SummaryItem('Ã‡ocuk adÄ±', summary.childName),
      _SummaryItem('YaÅŸ grubu', summary.ageGroup.label),
      _SummaryItem('Toplam yazÄ±', '${summary.totalEntries}'),
      _SummaryItem('Toplam kelime', '${summary.totalWords}'),
      _SummaryItem('YazÄ±lan gÃ¼n', '${summary.totalWrittenDays}'),
      _SummaryItem('Mevcut seri', '${summary.currentStreak} gÃ¼n'),
      _SummaryItem('En iyi seri', '${summary.bestStreak} gÃ¼n'),
      _SummaryItem('Bu hafta yazÄ±', '${summary.weeklyEntryCount}'),
      _SummaryItem('Bu hafta gÃ¼n', '${summary.weeklyWrittenDayCount}'),
      _SummaryItem('En sÄ±k duygu', summary.mostFrequentMood),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final card in cards)
              SizedBox(
                width: itemWidth,
                child: _SummaryCard(item: card),
              ),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.item});

  final _SummaryItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 104),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.pastelYellow, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            item.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            item.value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}

class _SafetyPrinciples extends StatelessWidget {
  const _SafetyPrinciples();

  @override
  Widget build(BuildContext context) {
    const items = [
      'Herkese aÃ§Ä±k paylaÅŸÄ±m yok.',
      'Ã‡ocuklar arasÄ± mesajlaÅŸma yok.',
      'Konum izni kullanÄ±lmaz.',
      'Günlük kayıtları cihazda saklanır; gelişmiş yazı kontrolü açılırsa başlık ve yazı yalnızca öneri üretmek için güvenli API servisine gönderilebilir.',
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.lightOrange, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GÃ¼venlik Ä°lkeleri',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          for (final item in items) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('â€¢ '),
                Expanded(
                  child: Text(
                    item,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _ParentSummaryData {
  const _ParentSummaryData({
    required this.childName,
    required this.ageGroup,
    required this.totalEntries,
    required this.totalWords,
    required this.totalWrittenDays,
    required this.currentStreak,
    required this.bestStreak,
    required this.weeklyEntryCount,
    required this.weeklyWrittenDayCount,
    required this.mostFrequentMood,
  });

  factory _ParentSummaryData.empty({
    required String childName,
    required AgeGroup ageGroup,
  }) {
    return _ParentSummaryData(
      childName: childName,
      ageGroup: ageGroup,
      totalEntries: 0,
      totalWords: 0,
      totalWrittenDays: 0,
      currentStreak: 0,
      bestStreak: 0,
      weeklyEntryCount: 0,
      weeklyWrittenDayCount: 0,
      mostFrequentMood: 'HenÃ¼z yok',
    );
  }

  final String childName;
  final AgeGroup ageGroup;
  final int totalEntries;
  final int totalWords;
  final int totalWrittenDays;
  final int currentStreak;
  final int bestStreak;
  final int weeklyEntryCount;
  final int weeklyWrittenDayCount;
  final String mostFrequentMood;
}

class _SummaryItem {
  const _SummaryItem(this.label, this.value);

  final String label;
  final String value;
}
