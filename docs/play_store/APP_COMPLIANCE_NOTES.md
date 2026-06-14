# App Compliance Notes

## Uygulama adı

Eğlenceli Günlük

## Android applicationId

com.aigrodeve.eglenceligunluk

## Geliştirici

AIgrodeve

## İletişim

aigrodeve@gmail.com

## Hedef yaş grupları

- 6-8
- 9-11

## Uygulama amacı

Çocukların günlük yazma alışkanlığı kazanması ve yazma becerilerini geliştirmesi.

## Mevcut güvenlik yaklaşımı

- Herkese açık paylaşım yok.
- Çocuklar arası mesajlaşma yok.
- Sosyal özellik yok.
- Konum izni yok.
- Rehber/kişi listesi erişimi yok.
- Kamera erişimi yok.
- Mikrofon erişimi yok.
- Hesap oluşturma yok.
- Bulut yedekleme yok.
- Çocuk cinsiyet bilgisi yalnızca cihazda lokal profil bilgisi olarak saklanır.
- Günlük yazıları cihaz içinde saklanır.
- AI/API/Firebase yok.
- Reklam yok.
- Uygulama içi satın alma şu an yok.

## İlk yayın stratejisi

- Reklam yok.
- Hesap sistemi yok.
- Bulut yedekleme yok.
- Gerçek AI/API yok.
- Uygulamanın temel günlük deneyimi çevrimdışı kullanılabilir; Premium satın alma ve geri yükleme için Google Play bağlantısı gerekebilir.
- Günlük yazıları cihazda saklanır.
- Çocuk adı, yaş grubu ve cinsiyet bilgisi yalnızca cihazda kişiselleştirme için saklanır.
- Kapalı testte çocuk güvenliği ve veri silme akışı ayrıca test edilecek.

## Premium plan notları

- Uygulama içi satın alma vardır.
- Satın alma tipi: tek seferlik Premium kilidi.
- Ürün ID: `premium_lifetime`
- Google Play Billing kullanılacaktır.
- Google Play Billing için `com.android.vending.BILLING`, `INTERNET` ve `ACCESS_NETWORK_STATE` izinleri kullanılabilir.
- Ödeme bilgileri uygulama tarafından saklanmayacaktır.
- Satın alma işlemleri Google Play tarafından yönetilecektir.
- Premium teklifleri ebeveyn alanı/ayarlar üzerinden gösterilecektir.
- Reklam kullanılmayacaktır.
- Abonelik kullanılmayacaktır.
- Reklamsızlaştırma gelir modeli kullanılmayacaktır; uygulama zaten reklamsız kalacaktır.
- Premium durumu cihazda lokal olarak tutulabilir.
- Tüm verileri sil lokal premium bilgisini temizler; satın alma Google Play üzerinden geri yüklenebilir.
- Gelişmiş rozetler, gelişmiş haftalık özet, daha fazla Günbi yazı önerisi ve özel Günbi temaları ileride Premium kapsamında değerlendirilebilir.
- İlk sürümde satın alma durumu Google Play Billing istemci akışıyla yönetilir. Daha yüksek güvenlik gereksinimlerinde sunucu tarafı doğrulama ayrıca değerlendirilebilir.
