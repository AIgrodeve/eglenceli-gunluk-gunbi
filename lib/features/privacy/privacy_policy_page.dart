import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/mascot_widget.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const String privacyPolicyUrl =
      'https://aigrodeve.github.io/eglenceli-gunluk-gunbi/';
  static const MethodChannel _channel = MethodChannel(
    'com.aigrodeve.eglenceligunluk/browser',
  );

  Future<void> _openPrivacyPolicy(BuildContext context) async {
    try {
      await _channel.invokeMethod<void>('openUrl', privacyPolicyUrl);
    } on PlatformException catch (_) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gizlilik politikası şu anda açılamadı.')),
      );
    }
  }

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
              'Günbi, günlük kayıtlarını güvenli ve sade bir alanda tutmayı önemser.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 22),
            const _PrivacySummaryCard(
              title: 'Kısa özet',
              items: [
                'Günlük kayıtları cihazda saklanır.',
                'Ebeveyn şifresi cihazda saklanır ve varsayılan değer 1234’tür.',
                'Gelişmiş yazı kontrolü açılırsa başlık ve yazı yalnızca öneri üretmek için güvenli API servisine gönderilebilir.',
                'Gelişmiş kontrol isteği günlük kaydı veya herkese açık paylaşım olarak saklanmaz.',
                'Reklam yoktur.',
                'Abonelik yoktur.',
                'Konum izni yoktur.',
                'Çocuklar arası mesajlaşma yoktur.',
              ],
            ),
            const SizedBox(height: 14),
            const _InfoCard(
              title: 'Ebeveynler için',
              message:
                  'Ebeveyn Alanı şifreyle korunur. Varsayılan şifre 1234’tür ve değiştirilebilir. Ebeveynler gelişim özetini uygulama içinden görebilir. Günlük yazıların tam metni ebeveyn özetinde gösterilmez.',
            ),
            const SizedBox(height: 14),
            const _InfoCard(
              title: 'Premium planı',
              message:
                  'Premium tek seferlik uygulama içi satın alma olarak sunulur ve yalnızca Ebeveyn Alanı üzerinden yönetilir. Satın alma işlemleri Google Play tarafından yönetilir; ödeme bilgileri uygulama tarafından saklanmaz. Premium durumu cihazda lokal tutulabilir; tüm veriler silinirse satın alma Google Play üzerinden geri yüklenebilir.',
            ),
            const SizedBox(height: 14),
            const _InfoCard(
              title: 'Günbi yazı kontrolü',
              message:
                  'Gelişmiş Günbi Yazı Kontrolü Premium ve ebeveyn onaylı bir özelliktir. Bu özellik açılırsa başlık ve yazı, yalnızca yazım ve noktalama önerileri üretmek amacıyla güvenli API servisine gönderilebilir. Günbi çocuğun yerine yazmaz, metni herkese açık şekilde paylaşmaz ve günlük kaydı olarak sunucuda tutmaz.',
            ),
            const SizedBox(height: 14),
            const _InfoCard(
              title: 'Verilerin silinmesi',
              message:
                  'Ayarlar bölümünden cihazda saklanan uygulama verileri ebeveyn şifresiyle silinebilir. Tüm yerel veriler silinince ebeveyn şifresi de sıfırlanır. Şifre unutulursa, hesap veya sunucu olmadığı için yerel veriler silinerek varsayılan 1234 değerine dönülebilir.',
            ),
            const SizedBox(height: 14),
            _PrivacyCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Web gizlilik politikası',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    privacyPolicyUrl,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _openPrivacyPolicy(context),
                    icon: const Icon(Icons.open_in_browser_rounded),
                    label: const Text('Gizlilik politikasını web’de aç'),
                  ),
                ],
              ),
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
