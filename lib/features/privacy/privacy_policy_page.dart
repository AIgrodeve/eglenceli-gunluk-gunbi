import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/mascot_widget.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gizlilik Politikası')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Center(
              child: MascotWidget(
                size: 96,
                mood: MascotMood.calm,
                showShadow: false,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Eğlenceli Günlük Gizlilik Özeti',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'Günbi, günlük yazılarını güvenli ve sade bir alanda tutmayı önemser.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 22),
            const _PrivacySummaryCard(
              title: 'Kısa özet',
              items: [
                'Günlükler cihazda saklanır.',
                'Veriler sunucuya gönderilmez.',
                'Reklam yoktur.',
                'Konum izni yoktur.',
                'Çocuklar arası mesajlaşma yoktur.',
              ],
            ),
            const SizedBox(height: 14),
            const _InfoCard(
              title: 'Ebeveynler için',
              message:
                  'Ebeveynler gelişim özetini uygulama içinden görebilir. Günlük yazılar çocuğa özel kalır.',
            ),
            const SizedBox(height: 14),
            const _InfoCard(
              title: 'Premium planı',
              message:
                  'Premium tek seferlik uygulama içi satın alma olarak sunulur. Satın alma işlemleri Google Play tarafından yönetilir; ödeme bilgileri uygulama tarafından saklanmaz.',
            ),
            const SizedBox(height: 14),
            const _InfoCard(
              title: 'Verilerin silinmesi',
              message:
                  'Ayarlar bölümünden cihazda saklanan uygulama verileri silinebilir.',
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacySummaryCard extends StatelessWidget {
  const _PrivacySummaryCard({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return _PrivacyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          for (final item in items) _PrivacyBullet(item),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return _PrivacyCard(
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

class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.pastelYellow, width: 1.5),
      ),
      child: child,
    );
  }
}

class _PrivacyBullet extends StatelessWidget {
  const _PrivacyBullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppTheme.lightOrange,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
