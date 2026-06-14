# Release Checklist

## Sürüm ve Android Kontrolleri

- [x] pubspec.yaml version alanı kontrol edildi: `1.0.0+1`
- [x] Android uygulama adı kontrol edildi: `Eğlenceli Günlük`
- [x] Yayın applicationId: `com.aigrodeve.eglenceligunluk`
- [x] Release imzalama debug keystore yerine upload keystore ile yapılandırıldı.
- [x] Upload keystore dosyası: `android/upload-keystore.jks`
- [x] İmzalama bilgileri: `android/key.properties`
- [x] Keystore ve `key.properties` git dışında tutuluyor; güvenli şekilde ayrıca yedeklenmeli.
- [x] Gereksiz izin kontrolü yapıldı. Release/main AndroidManifest içinde konum, kamera, mikrofon, rehber veya depolama izni yok.
- [x] Google Play Billing için `BILLING`, `INTERNET` ve `ACCESS_NETWORK_STATE` izinleri beklenir.
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
- [ ] Premium debug toggle release build'de görünmüyor.
- [ ] Ücretsiz yazı limiti 15 yazıda yeni kayıt eklemeyi durduruyor.
- [ ] PDF Günlük Kitabı Premium kilidi doğru çalışıyor.
- [ ] Tüm verileri sil akışı lokal premium durumunu da temizliyor.
- [ ] Play Console'da `premium_lifetime` one-time product oluşturuldu.
- [ ] Ürün aktif/test edilebilir durumda.
- [ ] Test kullanıcısı lisans tester listesinde.
- [ ] Premium fiyatı ekranda doğru görünüyor.
- [ ] Satın alma başarılı olunca Premium açılıyor.
- [ ] Satın alma iptal edilince Premium açılmıyor.
- [ ] Pending durumunda uygulama çökmüyor.
- [ ] Satın almayı geri yükle çalışıyor.
- [ ] Tüm verileri sil sonrası satın almayı geri yükle çalışıyor.
- [ ] Release build'de debug premium toggle görünmüyor.
- [ ] Premium olmayan kullanıcıda 15 yazı limiti çalışıyor.
- [ ] Premium kullanıcıda sınırsız yazı çalışıyor.
- [ ] Premium olmayan kullanıcıda PDF kilitli.
- [ ] Premium kullanıcıda PDF oluşturma çalışıyor.

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
- [ ] Premium teklifleri çocuk ekranlarında agresif şekilde gösterilmiyor
