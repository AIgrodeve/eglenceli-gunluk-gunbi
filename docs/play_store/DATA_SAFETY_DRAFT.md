# Data Safety Draft

Bu dosya Play Console Veri Güvenliği bölümü için taslak not olarak hazırlanmıştır.

## Mevcut sürüm için varsayımlar

- Android applicationId: com.aigrodeve.eglenceligunluk
- Kullanıcıdan çevrim içi hesap alınmaz.
- Veri sunucuya gönderilmez.
- Günlük yazıları cihazda lokal saklanır.
- Çocuk adı cihazda lokal saklanır.
- Yaş grubu cihazda lokal saklanır.
- Cinsiyet bilgisi cihazda lokal saklanır.
- Duygu seçimleri cihazda lokal saklanır.
- PDF oluşturma cihazda yapılır.
- Reklam SDK yok.
- Analitik SDK yok.
- Crash reporting SDK yok.
- Üçüncü taraf veri paylaşımı yok.
- Uygulama içindeki Ayarlar bölümünden yerel veriler silinebilir.
- Uygulama içi satın alma vardır.
- Satın alma tipi: tek seferlik Premium kilidi.
- Ürün ID: premium_lifetime
- Google Play Billing kullanılacaktır.
- Google Play Billing satın alma ve geri yükleme işlemleri için internet/Play Store bağlantısı kullanılabilir.
- Ödeme bilgileri uygulama tarafından saklanmayacaktır.
- Satın alma işlemleri Google Play tarafından yönetilecektir.
- Premium durumu cihazda lokal olarak tutulabilir.
- Tüm verileri sil lokal premium bilgisini temizler; satın alma Google Play üzerinden geri yüklenebilir.
- Premium teklifleri ebeveyn alanı/ayarlar üzerinden gösterilecektir.
- Reklam kullanılmayacaktır.
- Abonelik yoktur.
- İlk sürümde satın alma durumu Google Play Billing istemci akışıyla yönetilir. Daha yüksek güvenlik gereksinimlerinde sunucu tarafı doğrulama ayrıca değerlendirilebilir.

## Kullanılan paketler kontrol edilmeli

Mevcut bilinen paketler:

- shared_preferences
- pdf
- printing
- rive
- lottie
- in_app_purchase

Play Console Veri Güvenliği formu doldurulmadan önce pubspec.yaml ve AndroidManifest izinleri tekrar kontrol edilmelidir.

## Kontrol notu

Bu dosya Play Console formu doldurulmadan önce gerçek kod ve kullanılan paketlerle tekrar kontrol edilmelidir.
