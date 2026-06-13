import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/mascot_widget.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hakkında')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Center(
              child: MascotWidget(
                size: 116,
                mood: MascotMood.happy,
                animationType: MascotAnimationType.lottie,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Eğlenceli Günlük',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Yazmak bu kadar eğlenceli olabilir miydi?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 22),
            const _AboutInfoCard(),
            const SizedBox(height: 14),
            const _MessageCard(
              title: 'Günbi mesajı',
              message:
                  'Günbi, çocukların yazı yolculuğunda güvenli bir arkadaş olmak için burada.',
            ),
            const SizedBox(height: 14),
            const _SafetyCard(),
          ],
        ),
      ),
    );
  }
}

class _AboutInfoCard extends StatelessWidget {
  const _AboutInfoCard();

  @override
  Widget build(BuildContext context) {
    return const _AboutCard(
      child: Column(
        children: [
          _InfoRow(label: 'Uygulama adı', value: 'Eğlenceli Günlük'),
          _InfoRow(label: 'Maskot', value: 'Günbi'),
          _InfoRow(label: 'Geliştirici', value: 'AIgrodeve'),
          _InfoRow(label: 'İletişim', value: 'aigrodeve@gmail.com'),
          _InfoRow(label: 'Sürüm', value: '1.0.0'),
          SizedBox(height: 8),
          Text(
            'Eğlenceli Günlük, çocukların yazma alışkanlığı kazanmasına ve duygularını güvenli bir şekilde ifade etmesine yardımcı olmak için tasarlanmıştır.',
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return _AboutCard(
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

class _SafetyCard extends StatelessWidget {
  const _SafetyCard();

  @override
  Widget build(BuildContext context) {
    return const _AboutCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Güvenli kullanım notu',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 12),
          _SafetyBullet('Herkese açık paylaşım yoktur.'),
          _SafetyBullet('Çocuklar arası mesajlaşma yoktur.'),
          _SafetyBullet('Reklam gösterilmez.'),
          _SafetyBullet('Konum izni kullanılmaz.'),
          _SafetyBullet('Günlük yazıları cihazda saklanır.'),
        ],
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard({required this.child});

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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _SafetyBullet extends StatelessWidget {
  const _SafetyBullet(this.text);

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
