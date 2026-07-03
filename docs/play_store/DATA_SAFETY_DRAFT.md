# Data Safety Draft

Bu dosya Play Console Veri GÃ¼venliÄŸi bÃ¶lÃ¼mÃ¼ iÃ§in taslak not olarak hazÄ±rlanmÄ±ÅŸtÄ±r.

## Mevcut sÃ¼rÃ¼m iÃ§in varsayÄ±mlar

- Uygulama adÄ±: EÄŸlenceli GÃ¼nlÃ¼k
- Android applicationId: com.aigrodeve.eglenceligunluk
- GeliÅŸtirici: AIgrodeve
- Ä°letiÅŸim: aigrodeve@gmail.com
- Gizlilik politikasÄ± URLâ€™si: https://aigrodeve.github.io/eglenceli-gunluk-gunbi/
- Uygulama Ã§ocuklara yÃ¶nelik gÃ¼nlÃ¼k/yazma alÄ±ÅŸkanlÄ±ÄŸÄ± uygulamasÄ±dÄ±r.
- Hedef yaÅŸ gruplarÄ±: 6-8 ve 9-12.
- KullanÄ±cÄ±dan Ã§evrim iÃ§i hesap alÄ±nmaz.
- GeliÅŸmiÅŸ GÃ¼nbi YazÄ± KontrolÃ¼ Premium ve ebeveyn onayÄ±yla aÃ§Ä±lÄ±rsa yazÄ±, yalnÄ±zca yazÄ±m ve noktalama Ã¶nerileri Ã¼retmek iÃ§in gÃ¼venli API servisine gÃ¶nderilebilir.
- Firebase tabanlÄ± gÃ¼nlÃ¼k saklama veya bulut yedekleme kullanÄ±lmaz.
- Bulut yedekleme yoktur.
- GÃ¼nlÃ¼k yazÄ±larÄ± cihazda lokal saklanÄ±r.
- Ã‡ocuk adÄ± cihazda lokal saklanÄ±r.
- YaÅŸ grubu cihazda lokal saklanÄ±r.
- Cinsiyet bilgisi cihazda lokal saklanÄ±r.
- Duygu seÃ§imleri cihazda lokal saklanÄ±r.
- YazÄ± baÅŸlÄ±ÄŸÄ± ve yazÄ± metni cihazda lokal saklanÄ±r.
- PDF kitap baÅŸlÄ±ÄŸÄ± cihazda lokal saklanÄ±r.
- Ebeveyn ÅŸifresi cihazda lokal saklanÄ±r.
- Lokal Premium durumu cihazda saklanabilir.
- Ã‡ocuk adÄ±, yaÅŸ grubu, cinsiyet, duygu seÃ§imi, yazÄ± baÅŸlÄ±ÄŸÄ±, yazÄ± metni, PDF kitap baÅŸlÄ±ÄŸÄ±, ebeveyn ÅŸifresi ve lokal Premium durumu cihazda lokal saklanÄ±r.
- PDF oluÅŸturma cihazda yapÄ±lÄ±r.
- Reklam SDK yok.
- Analitik SDK yok.
- Crash reporting SDK yok.
- ÃœÃ§Ã¼ncÃ¼ taraf veri paylaÅŸÄ±mÄ± yok.
- Ã‡ocuklar arasÄ± mesajlaÅŸma yoktur.
- Herkese aÃ§Ä±k paylaÅŸÄ±m yoktur.
- Konum, kamera, mikrofon ve rehber izni yoktur.
- Uygulama iÃ§indeki Ayarlar bÃ¶lÃ¼mÃ¼nden yerel veriler ebeveyn ÅŸifresiyle silinebilir.
- TÃ¼m yerel veriler silindiÄŸinde ebeveyn ÅŸifresi ve lokal Premium durumu da temizlenir.
- Ebeveyn ÅŸifresi unutulursa, hesap/sunucu olmadÄ±ÄŸÄ± iÃ§in tÃ¼m yerel veriler silinerek varsayÄ±lan `1234` ÅŸifresine dÃ¶nÃ¼lebilir.
- Uygulama iÃ§i satÄ±n alma vardÄ±r.
- SatÄ±n alma tipi: tek seferlik Premium kilidi.
- ÃœrÃ¼n ID: premium_lifetime
- Google Play Billing kullanÄ±lacaktÄ±r.
- Google Play Billing satÄ±n alma ve geri yÃ¼kleme iÅŸlemleri iÃ§in internet/Play Store baÄŸlantÄ±sÄ± kullanÄ±labilir.
- Ã–deme bilgileri uygulama tarafÄ±ndan saklanmayacaktÄ±r.
- Uygulama Ã¶deme kartÄ± veya Ã¶deme bilgisi saklamaz.
- SatÄ±n alma iÅŸlemleri Google Play tarafÄ±ndan yÃ¶netilecektir.
- Premium durumu cihazda lokal olarak tutulabilir.
- TÃ¼m verileri sil lokal premium bilgisini temizler; satÄ±n alma Google Play Ã¼zerinden geri yÃ¼klenebilir.
- Premium satÄ±n alma yalnÄ±zca Ebeveyn AlanÄ± Ã¼zerinden yÃ¶netilir.
- Ã‡ocuk ekranlarÄ±nda agresif satÄ±n alma Ã§aÄŸrÄ±sÄ± yoktur.
- Ebeveyn AlanÄ± ÅŸifreyle korunur.
- VarsayÄ±lan ebeveyn ÅŸifresi `1234` deÄŸeridir, cihazda lokal saklanÄ±r ve deÄŸiÅŸtirilebilir.
- GeliÅŸmiÅŸ GÃ¼nbi YazÄ± KontrolÃ¼ Premium ve ebeveyn onaylÄ± Ã¶zellik olarak hazÄ±rlanmÄ±ÅŸtÄ±r.
- Backend baÄŸlantÄ±sÄ± yapÄ±landÄ±rÄ±lÄ±p ebeveyn onayÄ± aÃ§Ä±lÄ±rsa yazÄ±, yalnÄ±zca yazÄ±m ve noktalama Ã¶nerileri Ã¼retmek iÃ§in gÃ¼venli API servisine gÃ¶nderilebilir.
- Play Console Data Safety formu, geliÅŸmiÅŸ yazÄ± kontrolÃ¼ iÃ§in metnin gÃ¼venli API servisine gÃ¶nderilebileceÄŸini belirtecek ÅŸekilde kontrol edilmelidir.
- Reklam kullanÄ±lmayacaktÄ±r.
- Abonelik yoktur.
- Ä°lk sÃ¼rÃ¼mde satÄ±n alma durumu Google Play Billing istemci akÄ±ÅŸÄ±yla yÃ¶netilir. Daha yÃ¼ksek gÃ¼venlik gereksinimlerinde sunucu tarafÄ± doÄŸrulama ayrÄ±ca deÄŸerlendirilebilir.

## KullanÄ±lan paketler kontrol edilmeli

Mevcut bilinen paketler:

- shared_preferences
- pdf
- printing
- rive
- lottie
- in_app_purchase
- package_info_plus

Play Console Veri GÃ¼venliÄŸi formu doldurulmadan Ã¶nce pubspec.yaml ve AndroidManifest izinleri tekrar kontrol edilmelidir.

## Kontrol notu

Bu dosya Play Console formu doldurulmadan Ã¶nce gerÃ§ek kod ve kullanÄ±lan paketlerle tekrar kontrol edilmelidir.



## Günbi Yazı Kontrolü veri notu

Gelişmiş Günbi Yazı Kontrolü yalnızca Premium ve ebeveyn onayıyla çalışır. Bu özellik kullanıldığında başlık ve yazı metni, yazım ve noktalama önerileri üretmek için güvenli API servisine gönderilebilir. Bu işlem herkese açık paylaşım, çocuklar arası mesajlaşma veya bulut günlük yedekleme değildir. Günlük kayıtları cihazda saklanır; API isteği günlük kaydı olarak sunucuda tutulmamalıdır.
