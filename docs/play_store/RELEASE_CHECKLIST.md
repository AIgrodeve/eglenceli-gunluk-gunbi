# Release Checklist

## Sürüm ve Android Kontrolleri

- [x] pubspec.yaml version alanı kontrol edildi: `1.0.0+1`
- [x] Android uygulama adı kontrol edildi: `Eğlenceli Günlük`
- [x] Yayın applicationId: `com.aigrodeve.eglenceligunluk`
- [x] Gereksiz izin kontrolü yapıldı. Release/main AndroidManifest içinde konum, kamera, mikrofon, rehber veya depolama izni yok.
- [x] Cinsiyet bilgisi yalnızca cihazda lokal profil bilgisi olarak saklanır.
- [x] Tüm verileri sil akışı cinsiyet bilgisini de temizler.

## Release Build Komutları

- [ ] `flutter clean`
- [ ] `flutter pub get`
- [ ] `dart format lib test`
- [ ] `flutter analyze`
- [ ] `flutter test`
- [ ] `flutter build appbundle`

## AAB Çıktısı

- [ ] `build/app/outputs/bundle/release/app-release.aab`

## Teknik Uyarılar

- [ ] `rive_common` Kotlin Gradle Plugin uyarısı mevcut build'i engellemedi.
- [ ] Java source/target 8 Gradle uyarısı mevcut build'i engellemedi.
- [ ] Bu uyarılar sonraki bakımda takip edilecek.

## Manuel Test Listesi

- [ ] Temiz kurulum onboarding testi
- [ ] Çocuk adı, cinsiyet ve yaş grubu seçimi
- [ ] Duygu seçimi
- [ ] Günlük yazma ve kaydetme
- [ ] Yazılarım listeleme
- [ ] Yazı detay, düzenleme, silme
- [ ] Rozetlerim
- [ ] Seri sistemi
- [ ] Haftalık Özet
- [ ] Günlük Kitabım PDF testi
- [ ] Türkçe karakter PDF testi
- [ ] Ebeveyn Alanı yetişkin doğrulama testi
- [ ] Ayarlar profil düzenleme
- [ ] Gizlilik Politikası
- [ ] Hakkında
- [ ] Tüm verileri sil
- [ ] Veri silme sonrası onboarding'e dönüş
- [ ] Cinsiyet bilgisinin veri silme sonrası temizlenmesi
- [ ] Küçük ekran overflow testi
- [ ] İnternetsiz kullanım testi
- [ ] Geri tuşu çift basışla çıkış testi
- [ ] Demo veri release sürümde otomatik oluşmuyor.
- [ ] Ekran görüntüleri alındıktan sonra gerçek release build temiz veriyle test edildi.

## Geliştirme Doğrulaması

- [ ] Gerçek cihaz testi
- [ ] Veri silme testi
- [ ] PDF Türkçe karakter testi
- [ ] Küçük ekran overflow testi

## Play Store

- [ ] Uygulama adı
- [ ] Kısa açıklama
- [ ] Uzun açıklama
- [ ] Uygulama ikonu
- [ ] Özellik grafiği
- [ ] Ekran görüntüleri
- [ ] Gizlilik politikası bağlantısı
- [ ] Veri Güvenliği formu
- [ ] Hedef kitle ve içerik formu
- [ ] Reklam beyanı
- [ ] Uygulama erişimi beyanı
- [ ] İçerik derecelendirme
- [ ] Kapalı test hazırlığı

## Çocuk güvenliği

- [ ] Reklam yok
- [ ] Mesajlaşma yok
- [ ] Herkese açık paylaşım yok
- [ ] Konum izni yok
- [ ] Gereksiz izin yok
- [ ] Veriler cihazdan silinebiliyor
