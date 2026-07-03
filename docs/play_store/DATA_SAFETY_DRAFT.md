# Data Safety Draft

Bu dosya Play Console Veri Güvenliği bölümü için taslak not olarak hazırlanmıştır.

## Mevcut sürüm için varsayımlar

- Uygulama adı: Eğlenceli Günlük
- Android applicationId: com.aigrodeve.eglenceligunluk
- Geliştirici: AIgrodeve
- İletişim: aigrodeve@gmail.com
- Gizlilik politikası URL’si: https://sites.google.com/view/eglenceli-gunluk
- Uygulama çocuklara yönelik günlük/yazma alışkanlığı uygulamasıdır.
- Hedef yaş grupları: 6-8 ve 9-12.
- Kullanıcıdan çevrim içi hesap alınmaz.
- Veri sunucuya gönderilmez.
- Firebase/API/sunucu kullanılmaz.
- Bulut yedekleme yoktur.
- Günlük yazıları cihazda lokal saklanır.
- Çocuk adı cihazda lokal saklanır.
- Yaş grubu cihazda lokal saklanır.
- Cinsiyet bilgisi cihazda lokal saklanır.
- Duygu seçimleri cihazda lokal saklanır.
- Yazı başlığı ve yazı metni cihazda lokal saklanır.
- PDF kitap başlığı cihazda lokal saklanır.
- Ebeveyn şifresi cihazda lokal saklanır.
- Lokal Premium durumu cihazda saklanabilir.
- Çocuk adı, yaş grubu, cinsiyet, duygu seçimi, yazı başlığı, yazı metni, PDF kitap başlığı, ebeveyn şifresi ve lokal Premium durumu cihazda lokal saklanır.
- PDF oluşturma cihazda yapılır.
- Reklam SDK yok.
- Analitik SDK yok.
- Crash reporting SDK yok.
- Üçüncü taraf veri paylaşımı yok.
- Çocuklar arası mesajlaşma yoktur.
- Herkese açık paylaşım yoktur.
- Konum, kamera, mikrofon ve rehber izni yoktur.
- Uygulama içindeki Ayarlar bölümünden yerel veriler ebeveyn şifresiyle silinebilir.
- Tüm yerel veriler silindiğinde ebeveyn şifresi ve lokal Premium durumu da temizlenir.
- Ebeveyn şifresi unutulursa, hesap/sunucu olmadığı için tüm yerel veriler silinerek varsayılan `1234` şifresine dönülebilir.
- Uygulama içi satın alma vardır.
- Satın alma tipi: tek seferlik Premium kilidi.
- Ürün ID: premium_lifetime
- Google Play Billing kullanılacaktır.
- Google Play Billing satın alma ve geri yükleme işlemleri için internet/Play Store bağlantısı kullanılabilir.
- Ödeme bilgileri uygulama tarafından saklanmayacaktır.
- Uygulama ödeme kartı veya ödeme bilgisi saklamaz.
- Satın alma işlemleri Google Play tarafından yönetilecektir.
- Premium durumu cihazda lokal olarak tutulabilir.
- Tüm verileri sil lokal premium bilgisini temizler; satın alma Google Play üzerinden geri yüklenebilir.
- Premium satın alma yalnızca Ebeveyn Alanı üzerinden yönetilir.
- Çocuk ekranlarında agresif satın alma çağrısı yoktur.
- Ebeveyn Alanı şifreyle korunur.
- Varsayılan ebeveyn şifresi `1234` değeridir, cihazda lokal saklanır ve değiştirilebilir.
- Gelişmiş Günbi Yazı Kontrolü Premium ve ebeveyn onaylı özellik olarak hazırlanmıştır.
- Backend bağlantısı yapılandırılıp ebeveyn onayı açılırsa yazı, yalnızca yazım ve noktalama önerileri üretmek için güvenli API servisine gönderilebilir.
- Backend bağlantısı yapılandırılmamışsa gelişmiş kontrol çalışmaz ve yazılar dış servise gönderilmez.
- Play Console Data Safety formu, backend/API bağlantısının aktif edildiği build için bu veri aktarımını belirtecek şekilde kontrol edilmelidir.
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
