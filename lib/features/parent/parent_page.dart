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

    setState(() => _pinErrorText = 'Şifre hatalı. Lütfen tekrar deneyin.');
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
      // Bu şifre sıfırlama akışı güçlü kimlik doğrulama yerine geçmez.
      // Uygulamada hesap/sunucu olmadığı için şifre unutma durumunda yerel
      // veriler silinerek ebeveyn şifresi varsayılan değere döndürülür.
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
            'Veriler silinirken bir sorun oluştu. Lütfen tekrar deneyin.',
          ),
        ),
      );
    }
  }

  Future<bool?> _showForgotPinInfoDialog() {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ebeveyn şifresini sıfırla'),
        content: const SingleChildScrollView(
          child: Text(
            'Ebeveyn şifresini sıfırlamak için uygulamadaki tüm yerel verilerin silinmesi gerekir. Bu işlem günlük yazılarını, profil bilgilerini, rozet ilerlemesini, kitap başlığını ve yerel ayarları siler. Premium satın alma varsa Google Play üzerinden tekrar geri yüklenebilir.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Vazgeç'),
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
            'Bu işlem geri alınamaz. Devam edersen ebeveyn şifresi 1234 olarak sıfırlanır ve uygulama ilk kurulum ekranına döner.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Tüm verileri sil ve sıfırla'),
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
      appBar: AppBar(title: const Text('Ebeveyn Alanı')),
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
                  title: 'Güvenli gelişim özeti',
                  message:
                      'Bu alan, çocuğun yazma alışkanlığını güvenli şekilde takip etmek için hazırlanmıştır.',
                ),
                const SizedBox(height: 12),
                const _InfoPanel(
                  title: 'Mahremiyet',
                  message:
                      'Günlük yazılar çocuğa özeldir. Burada sadece gelişim özeti gösterilir.',
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
      return 'Henüz yok';
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
      appBar: AppBar(title: const Text('Ebeveyn Alanı')),
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
                    'Bu alan ebeveynler içindir. Devam etmek için ebeveyn şifresini girin.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Günlük içerikleri çocuğa özeldir; burada sadece gelişim özeti gösterilir.',
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
                      labelText: 'Şifre',
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
                    child: const Text('Şifremi unuttum'),
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
            'Premium satın alma ve geri yükleme işlemleri yalnızca Ebeveyn Alanı üzerinden yönetilir.',
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
            label: const Text('Premium yönetimi'),
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
              : 'Gelişmiş Günbi Yazı Kontrolü kapatıldı.',
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
                          'Gelişmiş Günbi Yazı Kontrolü',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Premium kapsamındaki bu özellik ebeveyn onayıyla açılır. Günbi çocuğun yerine yazmaz; sadece yazım ve noktalama önerileri sunar.',
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
                    : 'API bağlantısı henüz yapılandırılmadı. Bu yüzden yazılar dış servise gönderilmez ve gelişmiş kontrol açılmaz.',
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
                title: const Text('Ebeveyn onayı'),
                subtitle: Text(
                  !state.isPremiumUnlocked
                      ? 'Bu ayar Premium açılınca kullanılabilir.'
                      : !state.isApiConfigured
                      ? 'Backend URL tanımlanınca kullanılabilir.'
                      : 'Premium açık. Gelişmiş kontrolü açıp kapatabilirsin.',
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
    // Bu basit ebeveyn kontrolü, güçlü güvenlik veya kullanıcı hesabı yerine
    // geçmez. Çocukların yanlışlıkla ebeveyn alanına girmesini azaltmak için
    // kullanılır.
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
        const SnackBar(content: Text('Ebeveyn şifresi güncellendi.')),
      );
      return;
    }

    setState(() {
      _errorText = switch (result) {
        ParentPinUpdateResult.empty => 'Şifre boş olamaz.',
        ParentPinUpdateResult.tooShort => 'Şifre en az 4 karakter olmalı.',
        ParentPinUpdateResult.mismatch => 'Yeni şifreler aynı olmalı.',
        ParentPinUpdateResult.wrongCurrentPin => 'Mevcut şifre doğru değil.',
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
            'Ebeveyn Şifresi',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Varsayılan şifre 1234’tür. İstersen buradan değiştirebilirsin.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _currentPinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Mevcut şifre'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _newPinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Yeni şifre'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _repeatPinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Yeni şifre tekrar',
              errorText: _errorText,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _updatePin,
            icon: const Icon(Icons.lock_reset_rounded),
            label: const Text('Şifreyi güncelle'),
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
        title: 'Ebeveyn şifresi',
        message:
            'Bu alan şifreyle açılır. Varsayılan şifre 1234 olarak başlar ve değiştirilebilir.',
      ),
      _TrustItem(
        icon: Icons.child_care_rounded,
        title: 'Çocuğun mahremiyeti',
        message: 'Ebeveyn özetinde günlük yazılarının tam metni gösterilmez.',
      ),
      _TrustItem(
        icon: Icons.cloud_off_rounded,
        title: 'Cihazda saklama',
        message:
            'Günlükler, profil bilgileri ve yerel ayarlar bu cihazda tutulur.',
      ),
      _TrustItem(
        icon: Icons.delete_outline_rounded,
        title: 'Veri kontrolü',
        message:
            'Ayarlar bölümünden ebeveyn şifresiyle tüm yerel veriler silinebilir.',
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
          Text('Güven Özeti', style: Theme.of(context).textTheme.titleLarge),
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
        'Henüz yazı eklenmemiş. İlk yazıdan sonra gelişim özeti burada görünecek.',
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
      _SummaryItem('Çocuk adı', summary.childName),
      _SummaryItem('Yaş grubu', summary.ageGroup.label),
      _SummaryItem('Toplam yazı', '${summary.totalEntries}'),
      _SummaryItem('Toplam kelime', '${summary.totalWords}'),
      _SummaryItem('Yazılan gün', '${summary.totalWrittenDays}'),
      _SummaryItem('Mevcut seri', '${summary.currentStreak} gün'),
      _SummaryItem('En iyi seri', '${summary.bestStreak} gün'),
      _SummaryItem('Bu hafta yazı', '${summary.weeklyEntryCount}'),
      _SummaryItem('Bu hafta gün', '${summary.weeklyWrittenDayCount}'),
      _SummaryItem('En sık duygu', summary.mostFrequentMood),
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
      'Herkese açık paylaşım yok.',
      'Çocuklar arası mesajlaşma yok.',
      'Konum izni kullanılmaz.',
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
            'Güvenlik İlkeleri',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          for (final item in items) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• '),
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
      mostFrequentMood: 'Henüz yok',
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
