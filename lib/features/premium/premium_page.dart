import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/mascot_widget.dart';
import 'services/premium_service.dart';

class PremiumPage extends StatefulWidget {
  const PremiumPage({super.key});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  final PremiumService _premiumService = const PremiumService();
  late Future<bool> _premiumFuture;

  @override
  void initState() {
    super.initState();
    _premiumFuture = _premiumService.isPremiumUnlocked();
  }

  Future<void> _toggleDebugPremium(bool currentValue) async {
    // Bu buton sadece debug testleri içindir; gerçek yayın öncesi
    // Google Play Billing entegrasyonu ile değiştirilmelidir.
    await _premiumService.setPremiumUnlocked(!currentValue);
    if (!mounted) {
      return;
    }

    setState(() => _premiumFuture = _premiumService.isPremiumUnlocked());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          !currentValue
              ? 'Debug: Premium kilidi açıldı.'
              : 'Debug: Premium kilidi kapatıldı.',
        ),
      ),
    );
  }

  void _showComingSoonMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Premium satın alma yakında eklenecek.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Premium')),
      body: SafeArea(
        child: FutureBuilder<bool>(
          future: _premiumFuture,
          builder: (context, snapshot) {
            final isPremiumUnlocked = snapshot.data ?? false;

            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Center(
                  child: MascotWidget(size: 118, mood: MascotMood.proud),
                ),
                const SizedBox(height: 18),
                Text(
                  'Eğlenceli Günlük Premium',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  'Premium özellikler ebeveyn onayıyla açılır.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 22),
                _PremiumStatusCard(isPremiumUnlocked: isPremiumUnlocked),
                const SizedBox(height: 14),
                const _FeatureCard(
                  title: 'Ücretsiz',
                  items: [
                    '15 günlük yazıya kadar kullanım',
                    'Temel rozetler',
                    'Temel haftalık özet',
                    "Günbi'den temel yazı desteği",
                  ],
                ),
                const SizedBox(height: 14),
                const _FeatureCard(
                  title: 'Premium',
                  items: [
                    'Sınırsız günlük yazısı',
                    'PDF Günlük Kitabı oluşturma',
                    'Tüm rozetler',
                    'Gelişmiş haftalık özet',
                    'Daha fazla Günbi yazı önerisi',
                    'Gelecekte özel Günbi temaları',
                  ],
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: _showComingSoonMessage,
                  icon: const Icon(Icons.lock_clock_rounded),
                  label: const Text('Yakında ebeveyn onayıyla açılacak'),
                ),
                if (kDebugMode) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _toggleDebugPremium(isPremiumUnlocked),
                    icon: Icon(
                      isPremiumUnlocked
                          ? Icons.lock_open_rounded
                          : Icons.lock_rounded,
                    ),
                    label: Text(
                      isPremiumUnlocked
                          ? 'Debug: Premium kilidini kapat'
                          : 'Debug: Premium kilidini aç',
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PremiumStatusCard extends StatelessWidget {
  const _PremiumStatusCard({required this.isPremiumUnlocked});

  final bool isPremiumUnlocked;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isPremiumUnlocked
            ? AppTheme.pastelYellow.withValues(alpha: 0.45)
            : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.pastelYellow, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(
            isPremiumUnlocked
                ? Icons.workspace_premium_rounded
                : Icons.lock_outline_rounded,
            color: AppTheme.cocoa,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isPremiumUnlocked
                  ? 'Premium test kilidi açık.'
                  : 'Premium özellikler henüz kilitli.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.title, required this.items});

  final String title;
  final List<String> items;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: AppTheme.lightOrange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
