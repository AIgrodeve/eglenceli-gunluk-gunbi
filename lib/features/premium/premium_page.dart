import 'dart:async';

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
  late Future<PremiumStoreState> _storeFuture;
  StreamSubscription? _purchaseSubscription;
  bool _isPurchaseInProgress = false;
  bool _isRestoring = false;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _storeFuture = _premiumService.loadStoreState();
    _purchaseSubscription = _premiumService.purchaseUpdates.listen(
      _handlePurchaseUpdates,
      onError: (_) {
        if (!mounted) {
          return;
        }
        _showMessage(
          'Satın alma sırasında bir sorun oluştu. Lütfen tekrar deneyin.',
        );
      },
    );
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }

  Future<void> _handlePurchaseUpdates(List<dynamic> purchases) async {
    final results = await _premiumService.handlePurchaseUpdates(
      purchases.cast(),
    );
    if (!mounted || results.isEmpty) {
      return;
    }

    setState(() {
      _isPurchaseInProgress = false;
      _isRestoring = false;
      _storeFuture = _premiumService.loadStoreState();
    });

    _showMessage(results.last.message);
  }

  Future<void> _startPurchase(PremiumStoreState storeState) async {
    final productDetails = storeState.productDetails;
    if (productDetails == null) {
      _showMessage(PremiumService.unavailableMessage);
      return;
    }

    setState(() => _isPurchaseInProgress = true);
    try {
      final didStart = await _premiumService.buyPremium(productDetails);
      if (!mounted) {
        return;
      }
      if (!didStart) {
        setState(() => _isPurchaseInProgress = false);
        _showMessage('Satın alma tamamlanmadı.');
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isPurchaseInProgress = false);
      _showMessage(
        'Satın alma sırasında bir sorun oluştu. Lütfen tekrar deneyin.',
      );
    }
  }

  Future<void> _retryStoreQuery() async {
    setState(() {
      _isRetrying = true;
      _storeFuture = _premiumService.loadStoreState();
    });

    try {
      final storeState = await _storeFuture;
      if (!mounted) {
        return;
      }

      setState(() => _isRetrying = false);
      if (storeState.productDetails != null) {
        _showMessage('Premium bilgisi güncellendi.');
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isRetrying = false);
      _showMessage(PremiumService.unavailableMessage);
    }
  }

  Future<void> _restorePurchase() async {
    setState(() => _isRestoring = true);
    final wasUnlocked = await _premiumService.isPremiumUnlocked();
    try {
      await _premiumService.restorePurchases();
      await Future<void>.delayed(const Duration(milliseconds: 1800));
      final isUnlocked = await _premiumService.isPremiumUnlocked();
      if (!mounted) {
        return;
      }

      setState(() {
        _isRestoring = false;
        _storeFuture = _premiumService.loadStoreState();
      });

      if (isUnlocked) {
        _showMessage('Premium satın alma geri yüklendi.');
      } else if (!wasUnlocked) {
        _showMessage('Aktif Premium satın alma bulunamadı.');
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isRestoring = false);
      _showMessage(
        'Satın alma bilgisi kontrol edilirken bir sorun oluştu. Lütfen tekrar deneyin.',
      );
    }
  }

  Future<void> _toggleDebugPremium(bool currentValue) async {
    // Bu buton sadece debug testleri içindir; release build'de görünmez.
    // Gerçek premium kaynağı Google Play Billing satın alma durumudur.
    await _premiumService.setPremiumUnlocked(!currentValue);
    if (!mounted) {
      return;
    }

    setState(() => _storeFuture = _premiumService.loadStoreState());
    _showMessage(
      !currentValue
          ? 'Debug: Premium kilidi açıldı.'
          : 'Debug: Premium kilidi kapatıldı.',
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Premium')),
      body: SafeArea(
        child: FutureBuilder<PremiumStoreState>(
          future: _storeFuture,
          builder: (context, snapshot) {
            final storeState =
                snapshot.data ??
                const PremiumStoreState(
                  isPremiumUnlocked: false,
                  isBillingAvailable: false,
                );
            final product = storeState.productDetails;
            final isPremiumUnlocked = storeState.isPremiumUnlocked;
            final isLoading =
                snapshot.connectionState == ConnectionState.waiting;

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
                  'Premium özellikler yalnızca Ebeveyn Alanı içinde, ebeveyn onayıyla açılır.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 22),
                _PremiumStatusCard(
                  isPremiumUnlocked: isPremiumUnlocked,
                  productTitle: product?.title,
                  productPrice: product?.price,
                  message: storeState.message,
                ),
                const SizedBox(height: 14),
                const _FeatureCard(
                  title: 'Satın alma bilgisi',
                  items: [
                    'Tek seferlik satın alma',
                    'Reklam yok',
                    'Abonelik yok',
                    'Çocuk ekranlarında satın alma çağrısı yok',
                    'Satın alma Google Play üzerinden yönetilir',
                    'Uygulama ödeme bilgisi saklamaz',
                  ],
                ),
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
                    'Ebeveyn onaylı gelişmiş Günbi yazı kontrolü altyapısı',
                    'Daha fazla Günbi yazı önerisi',
                    'Gelecekte özel Günbi temaları',
                  ],
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed:
                      isLoading ||
                          isPremiumUnlocked ||
                          product == null ||
                          _isPurchaseInProgress
                      ? null
                      : () => _startPurchase(storeState),
                  icon: Icon(
                    isPremiumUnlocked
                        ? Icons.check_circle_rounded
                        : Icons.workspace_premium_rounded,
                  ),
                  label: Text(
                    isPremiumUnlocked
                        ? 'Premium açık'
                        : _isPurchaseInProgress
                        ? 'Satın alma başlatılıyor...'
                        : "Premium'u aç",
                  ),
                ),
                if (product != null && !isPremiumUnlocked) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Tek seferlik satın alma: ${product.price}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                if (product == null && !isLoading) ...[
                  const SizedBox(height: 10),
                  Text(
                    storeState.message ?? PremiumService.unavailableMessage,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    PremiumService.activationDelayMessage,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: isLoading || _isRetrying ? null : _retryStoreQuery,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(
                    _isRetrying
                        ? 'Premium bilgisi yenileniyor...'
                        : 'Tekrar dene',
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _isRestoring ? null : _restorePurchase,
                  icon: const Icon(Icons.restore_rounded),
                  label: Text(
                    _isRestoring
                        ? 'Satın alma kontrol ediliyor...'
                        : 'Satın almayı geri yükle',
                  ),
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
  const _PremiumStatusCard({
    required this.isPremiumUnlocked,
    this.productTitle,
    this.productPrice,
    this.message,
  });

  final bool isPremiumUnlocked;
  final String? productTitle;
  final String? productPrice;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final title = productTitle?.trim().isNotEmpty == true
        ? productTitle!.trim()
        : 'Eğlenceli Günlük Premium';

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isPremiumUnlocked
                ? Icons.workspace_premium_rounded
                : Icons.lock_outline_rounded,
            color: AppTheme.cocoa,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  isPremiumUnlocked
                      ? 'Premium açık.'
                      : productPrice == null
                      ? (message ?? 'Premium bilgisi bekleniyor.')
                      : 'Tek seferlik satın alma: $productPrice',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
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
