# Release Checklist

## SÃ¼rÃ¼m ve Android Kontrolleri

- [x] pubspec.yaml version alanÄ± kontrol edildi: `1.0.0+5`
- [x] Hakkında ekranı paket sürümünü otomatik okuyor: 1.0.0+5
- [x] Android uygulama adÄ± kontrol edildi: `EÄŸlenceli GÃ¼nlÃ¼k`
- [x] YayÄ±n applicationId: `com.aigrodeve.eglenceligunluk`
- [x] Release imzalama debug keystore yerine upload keystore ile yapÄ±landÄ±rÄ±ldÄ±.
- [x] Upload keystore dosyasÄ±: `android/upload-keystore.jks`
- [x] Ä°mzalama bilgileri: `android/key.properties`
- [x] Keystore ve `key.properties` git dÄ±ÅŸÄ±nda tutuluyor; gÃ¼venli ÅŸekilde ayrÄ±ca yedeklenmeli.
- [x] Gereksiz izin kontrolÃ¼ yapÄ±ldÄ±. Release/main AndroidManifest iÃ§inde konum, kamera, mikrofon, rehber veya depolama izni yok.
- [x] Google Play Billing iÃ§in `BILLING`, `INTERNET` ve `ACCESS_NETWORK_STATE` izinleri beklenir.
- [x] Cinsiyet bilgisi yalnÄ±zca cihazda lokal profil bilgisi olarak saklanÄ±r.
- [x] TÃ¼m verileri sil akÄ±ÅŸÄ± cinsiyet bilgisini de temizler.
- [x] Hedef yaÅŸ gruplarÄ± uygulama iÃ§inde `6-8` ve `9-12` olarak sÄ±nÄ±rlandÄ±.
- [x] Gizlilik politikası URL adresi uygulama içine eklendi: https://aigrodeve.github.io/eglenceli-gunluk-gunbi/
- [x] Premium sadece Ebeveyn AlanÄ± iÃ§inden yÃ¶netiliyor.
- [x] GeliÅŸmiÅŸ GÃ¼nbi YazÄ± KontrolÃ¼ Premium ve ebeveyn onaylÄ± ayar olarak hazÄ±rlandÄ±.
- [x] GeliÅŸmiÅŸ yazÄ± kontrolÃ¼ backend URL'si: `https://gunbi-writing-review-api.onrender.com/review`
- [x] Gelişmiş Günbi Yazı Kontrolü başlık ve yazı metnini birlikte kontrol ediyor.
- [x] Gelişmiş kontrol isteği herkese açık paylaşım değildir; öneri üretimi için güvenli API isteğidir.
- [x] Bu sürüm için pubspec sürümü 1.0.0+5 olarak korunacak.

## Release Build KomutlarÄ±

- [ ] `flutter clean`
- [ ] `flutter pub get`
- [ ] `dart format lib test`
- [ ] `flutter analyze`
- [ ] `flutter test`
- [ ] `flutter build appbundle`
- [x] `flutter build appbundle --release --dart-define=GUNBI_REVIEW_API_URL=https://gunbi-writing-review-api.onrender.com/review`

## AAB Ã‡Ä±ktÄ±sÄ±

- [ ] `build/app/outputs/bundle/release/app-release.aab`

## Teknik UyarÄ±lar

- [ ] `rive_common` Kotlin Gradle Plugin uyarÄ±sÄ± mevcut build'i engellemedi.
- [ ] Java source/target 8 Gradle uyarÄ±sÄ± mevcut build'i engellemedi.
- [ ] Bu uyarÄ±lar sonraki bakÄ±mda takip edilecek.

## Manuel Test Listesi

- [ ] Temiz kurulum onboarding testi
- [ ] Ã‡ocuk adÄ±, cinsiyet ve yaÅŸ grubu seÃ§imi
- [ ] YaÅŸ grubu seÃ§enekleri yalnÄ±zca 6-8 ve 9-12 gÃ¶rÃ¼nÃ¼yor.
- [ ] Duygu seÃ§imi
- [ ] GÃ¼nlÃ¼k yazma ve kaydetme
- [ ] YazÄ±larÄ±m listeleme
- [ ] YazÄ± detay, dÃ¼zenleme, silme
- [ ] Rozetlerim
- [ ] Seri sistemi
- [ ] HaftalÄ±k Ã–zet
- [ ] GÃ¼nlÃ¼k KitabÄ±m PDF testi
- [ ] TÃ¼rkÃ§e karakter PDF testi
- [ ] Ebeveyn AlanÄ± ÅŸifre giriÅŸi testi
- [ ] Ayarlar profil dÃ¼zenleme
- [ ] Gizlilik PolitikasÄ±
- [ ] HakkÄ±nda
- [ ] TÃ¼m verileri sil
- [ ] Veri silme sonrasÄ± onboarding'e dÃ¶nÃ¼ÅŸ
- [ ] Cinsiyet bilgisinin veri silme sonrasÄ± temizlenmesi
- [ ] KÃ¼Ã§Ã¼k ekran overflow testi
- [ ] Ä°nternetsiz kullanÄ±m testi
- [ ] Geri tuÅŸu Ã§ift basÄ±ÅŸla Ã§Ä±kÄ±ÅŸ testi
- [ ] Demo veri release sÃ¼rÃ¼mde otomatik oluÅŸmuyor.
- [ ] Ekran gÃ¶rÃ¼ntÃ¼leri alÄ±ndÄ±ktan sonra gerÃ§ek release build temiz veriyle test edildi.
- [ ] Premium debug toggle release build'de gÃ¶rÃ¼nmÃ¼yor.
- [ ] Premium satÄ±n alma yalnÄ±zca Ebeveyn AlanÄ± Ã¼zerinden aÃ§Ä±lÄ±yor.
- [ ] Ebeveyn ÅŸifresi varsayÄ±lan `1234` ile Ã§alÄ±ÅŸÄ±yor.
- [ ] Ebeveyn ÅŸifresi deÄŸiÅŸtirildi ve tekrar giriÅŸ test edildi.
- [ ] TÃ¼m verileri sil akÄ±ÅŸÄ± yeni ÅŸifreyle test edildi.
- [ ] Ebeveyn ÅŸifresi unutulursa uygulama iÃ§inden tÃ¼m yerel veriler silinerek ÅŸifre varsayÄ±lan `1234` deÄŸerine sÄ±fÄ±rlanabiliyor.
- [ ] Åifre unutma/veri silerek sÄ±fÄ±rlama davranÄ±ÅŸÄ± belgelendi.
- [ ] Åifre sÄ±fÄ±rlama sonrasÄ± Premium satÄ±n alma varsa Google Play Ã¼zerinden geri yÃ¼klenebiliyor.
- [ ] Ãœcretsiz yazÄ± limiti 15 yazÄ±da yeni kayÄ±t eklemeyi durduruyor.
- [ ] PDF GÃ¼nlÃ¼k KitabÄ± Premium kilidi doÄŸru Ã§alÄ±ÅŸÄ±yor.
- [ ] TÃ¼m verileri sil akÄ±ÅŸÄ± lokal premium durumunu da temizliyor.
- [ ] Play Console'da `premium_lifetime` one-time product oluÅŸturuldu.
- [ ] ÃœrÃ¼n aktif/test edilebilir durumda.
- [ ] Test kullanÄ±cÄ±sÄ± lisans tester listesinde.
- [ ] Premium fiyatÄ± ekranda doÄŸru gÃ¶rÃ¼nÃ¼yor.
- [ ] SatÄ±n alma baÅŸarÄ±lÄ± olunca Premium aÃ§Ä±lÄ±yor.
- [ ] SatÄ±n alma iptal edilince Premium aÃ§Ä±lmÄ±yor.
- [ ] Pending durumunda uygulama Ã§Ã¶kmÃ¼yor.
- [ ] SatÄ±n almayÄ± geri yÃ¼kle Ã§alÄ±ÅŸÄ±yor.
- [ ] TÃ¼m verileri sil sonrasÄ± satÄ±n almayÄ± geri yÃ¼kle Ã§alÄ±ÅŸÄ±yor.
- [ ] Release build'de debug premium toggle gÃ¶rÃ¼nmÃ¼yor.
- [ ] Premium olmayan kullanÄ±cÄ±da 15 yazÄ± limiti Ã§alÄ±ÅŸÄ±yor.
- [ ] Premium kullanÄ±cÄ±da sÄ±nÄ±rsÄ±z yazÄ± Ã§alÄ±ÅŸÄ±yor.
- [ ] Premium olmayan kullanÄ±cÄ±da PDF kilitli.
- [ ] Premium kullanÄ±cÄ±da PDF oluÅŸturma Ã§alÄ±ÅŸÄ±yor.
- [ ] TÃ¼m verileri sil sonrasÄ± parentPin varsayÄ±lan `1234` kabul ediliyor.
- [ ] Åifremi unuttum akÄ±ÅŸÄ± iki aÅŸamalÄ± onayla Ã§alÄ±ÅŸÄ±yor ve onboarding baÅŸlangÄ±cÄ±na dÃ¶nÃ¼yor.

## GeliÅŸtirme DoÄŸrulamasÄ±

- [ ] GerÃ§ek cihaz testi
- [ ] Veri silme testi
- [ ] PDF TÃ¼rkÃ§e karakter testi
- [ ] KÃ¼Ã§Ã¼k ekran overflow testi

## Play Store

- [ ] Uygulama adÄ±
- [ ] KÄ±sa aÃ§Ä±klama
- [ ] Uzun aÃ§Ä±klama
- [ ] Uygulama ikonu
- [ ] Ã–zellik grafiÄŸi
- [ ] Ekran gÃ¶rÃ¼ntÃ¼leri
- [ ] Gizlilik politikasÄ± baÄŸlantÄ±sÄ±
- [ ] Play Console gizlilik politikasÄ± URLâ€™si `https://aigrodeve.github.io/eglenceli-gunluk-gunbi/` adresiyle gÃ¼ncellendi.
- [ ] Veri GÃ¼venliÄŸi formu
- [ ] Data Safety formu bu bilgilerle tekrar kontrol edildi.
- [ ] Hedef kitle ve iÃ§erik formu
- [ ] Reklam beyanÄ±
- [ ] Uygulama eriÅŸimi beyanÄ±
- [ ] Ä°Ã§erik derecelendirme
- [ ] KapalÄ± test hazÄ±rlÄ±ÄŸÄ±
- [ ] Play Console hedef yaÅŸ gruplarÄ± yalnÄ±zca 6-8 ve 9-12 seÃ§ildi.
- [ ] Hedef yaÅŸ gruplarÄ± 6-8 ve 9-12 olarak dÃ¼zeltildi.
- [ ] 13-15, 16-17 ve 18+ seÃ§ilmedi.
- [ ] 5 yaÅŸ ve altÄ± seÃ§ilmedi.
- [ ] MaÄŸaza giriÅŸi Ã§ocuk hedefiyle tutarlÄ±.
- [ ] Families Policy beyanlarÄ± kontrol edildi.
- [ ] Premium satÄ±n alma Ebeveyn AlanÄ± Ã¼zerinden test edildi.

## Ã‡ocuk gÃ¼venliÄŸi

- [ ] Reklam yok
- [ ] MesajlaÅŸma yok
- [ ] Herkese aÃ§Ä±k paylaÅŸÄ±m yok
- [ ] Konum izni yok
- [ ] Gereksiz izin yok
- [ ] Veriler cihazdan silinebiliyor
- [ ] Premium teklifleri Ã§ocuk ekranlarÄ±nda agresif ÅŸekilde gÃ¶sterilmiyor
- [ ] GeliÅŸmiÅŸ GÃ¼nbi YazÄ± KontrolÃ¼ ayarÄ± Premium yokken pasif gÃ¶rÃ¼nÃ¼yor.
- [ ] Premium aÃ§Ä±kken Ebeveyn AlanÄ± iÃ§inden geliÅŸmiÅŸ yazÄ± kontrolÃ¼ ayarÄ± aÃ§Ä±lÄ±p kapatÄ±labiliyor.
- [ ] Backend URL ile alÄ±nan build'de ebeveyn onayÄ± aÃ§Ä±ldÄ±ÄŸÄ±nda geliÅŸmiÅŸ kontrol API endpoint'ine istek gÃ¶nderiyor.

