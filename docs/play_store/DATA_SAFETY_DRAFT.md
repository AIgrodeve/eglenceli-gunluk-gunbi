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
- Premium özellikler planlanmaktadır.
- Gerçek satın alma eklenirse Google Play Billing kullanılacaktır.
- Ödeme bilgileri uygulama tarafından saklanmayacaktır.
- Satın alma işlemleri Google Play tarafından yönetilecektir.
- Premium teklifleri ebeveyn alanı/ayarlar üzerinden gösterilecektir.
- Reklam kullanılmayacaktır.

## Kullanılan paketler kontrol edilmeli

Mevcut bilinen paketler:

- shared_preferences
- pdf
- printing
- rive
- lottie

Play Console Veri Güvenliği formu doldurulmadan önce pubspec.yaml ve AndroidManifest izinleri tekrar kontrol edilmelidir.

## Kontrol notu

Bu dosya Play Console formu doldurulmadan önce gerçek kod ve kullanılan paketlerle tekrar kontrol edilmelidir.
