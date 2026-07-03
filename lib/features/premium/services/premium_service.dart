import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumService {
  const PremiumService();

  static const freeEntryLimit = 15;
  static const premiumProductId = 'premium_lifetime';
  static const unavailableMessage =
      'Premium bilgisi şu anda alınamadı. Lütfen internet bağlantınızı kontrol edip tekrar deneyin.';
  static const activationDelayMessage =
      'Ürün yeni etkinleştirildiyse veya Play Store bilgileri henüz güncellenmediyse birkaç dakika sonra tekrar deneyebilirsiniz.';
  static const _isPremiumUnlockedKey = 'isPremiumUnlocked';

  InAppPurchase get _inAppPurchase => InAppPurchase.instance;

  Stream<List<PurchaseDetails>> get purchaseUpdates {
    return _inAppPurchase.purchaseStream;
  }

  Future<bool> isPremiumUnlocked() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_isPremiumUnlockedKey) ?? false;
  }

  Future<PremiumStoreState> loadStoreState() async {
    final isUnlocked = await isPremiumUnlocked();

    final isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      return PremiumStoreState(
        isPremiumUnlocked: isUnlocked,
        isBillingAvailable: false,
        message: unavailableMessage,
      );
    }

    final response = await _inAppPurchase.queryProductDetails({
      premiumProductId,
    });

    if (response.error != null) {
      return PremiumStoreState(
        isPremiumUnlocked: isUnlocked,
        isBillingAvailable: true,
        message: unavailableMessage,
      );
    }

    if (response.productDetails.isEmpty ||
        response.notFoundIDs.contains(premiumProductId)) {
      return PremiumStoreState(
        isPremiumUnlocked: isUnlocked,
        isBillingAvailable: true,
        message: unavailableMessage,
      );
    }

    return PremiumStoreState(
      isPremiumUnlocked: isUnlocked,
      isBillingAvailable: true,
      productDetails: response.productDetails.first,
    );
  }

  Future<bool> buyPremium(ProductDetails productDetails) {
    final purchaseParam = PurchaseParam(productDetails: productDetails);
    return _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restorePurchases() {
    return _inAppPurchase.restorePurchases();
  }

  Future<List<PremiumPurchaseResult>> handlePurchaseUpdates(
    List<PurchaseDetails> purchases,
  ) async {
    final results = <PremiumPurchaseResult>[];

    for (final purchase in purchases) {
      if (purchase.productID != premiumProductId) {
        if (purchase.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchase);
        }
        continue;
      }

      switch (purchase.status) {
        case PurchaseStatus.pending:
          results.add(
            const PremiumPurchaseResult(
              status: PremiumPurchaseResultStatus.pending,
              message: 'Satın alma işlemi beklemede.',
            ),
          );
        case PurchaseStatus.purchased:
          // İlk sürümde satın alma durumu Google Play Billing istemci akışıyla
          // yönetilir. Daha yüksek güvenlik gereksinimlerinde sunucu tarafı
          // doğrulama ayrıca değerlendirilebilir.
          await setPremiumUnlocked(true);
          results.add(
            const PremiumPurchaseResult(
              status: PremiumPurchaseResultStatus.unlocked,
              message: 'Premium açıldı.',
            ),
          );
        case PurchaseStatus.restored:
          await setPremiumUnlocked(true);
          results.add(
            const PremiumPurchaseResult(
              status: PremiumPurchaseResultStatus.restored,
              message: 'Premium satın alma geri yüklendi.',
            ),
          );
        case PurchaseStatus.error:
          results.add(
            const PremiumPurchaseResult(
              status: PremiumPurchaseResultStatus.error,
              message:
                  'Satın alma sırasında bir sorun oluştu. Lütfen tekrar deneyin.',
            ),
          );
        case PurchaseStatus.canceled:
          results.add(
            const PremiumPurchaseResult(
              status: PremiumPurchaseResultStatus.canceled,
              message: 'Satın alma tamamlanmadı.',
            ),
          );
      }

      if (purchase.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchase);
      }
    }

    return results;
  }

  Future<void> setPremiumUnlocked(bool isUnlocked) async {
    // Bu debug/test amaçlı lokal durumdur. Gerçek premium kaynağı Google Play
    // Billing satın alma durumudur.
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_isPremiumUnlockedKey, isUnlocked);
  }

  Future<void> clearPremiumStatus() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_isPremiumUnlockedKey);
  }
}

class PremiumStoreState {
  const PremiumStoreState({
    required this.isPremiumUnlocked,
    required this.isBillingAvailable,
    this.productDetails,
    this.message,
  });

  final bool isPremiumUnlocked;
  final bool isBillingAvailable;
  final ProductDetails? productDetails;
  final String? message;
}

class PremiumPurchaseResult {
  const PremiumPurchaseResult({required this.status, required this.message});

  final PremiumPurchaseResultStatus status;
  final String message;
}

enum PremiumPurchaseResultStatus {
  pending,
  unlocked,
  restored,
  error,
  canceled,
}
