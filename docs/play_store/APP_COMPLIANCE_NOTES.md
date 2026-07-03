# App Compliance Notes

## Uygulama adı

Eğlenceli Günlük

## Android applicationId

com.aigrodeve.eglenceligunluk

## Geliştirici

AIgrodeve

## İletişim

aigrodeve@gmail.com

## Gizlilik politikası URL’si

https://sites.google.com/view/eglenceli-gunluk

## Hedef yaş grupları

- 6-8
- 9-12

## Uygulama amacı

Çocukların günlük yazma alışkanlığı kazanması ve yazma becerilerini geliştirmesi.

## Play Store temel beyan özeti

- Uygulama çocuklara yönelik günlük/yazma alışkanlığı uygulamasıdır.
- Reklam yoktur.
- Abonelik yoktur.
- Tek seferlik Premium uygulama içi satın alma vardır.
- Satın alma Google Play Billing üzerinden yapılır.
- Premium satın alma yalnızca Ebeveyn Alanı üzerinden yönetilir.
- Çocuk ekranlarında agresif satın alma çağrısı yoktur.
- Uygulama ödeme kartı veya ödeme bilgisi saklamaz.
- Hesap oluşturma yoktur.
- Bulut yedekleme yoktur.
- Firebase/API/sunucu yoktur.
- Çocuklar arası mesajlaşma yoktur.
- Herkese açık paylaşım yoktur.
- Konum, kamera, mikrofon ve rehber izni yoktur.
- Günlük yazıları cihazda lokal saklanır.
- Çocuk adı, yaş grubu, cinsiyet, duygu seçimi, yazı başlığı, yazı metni, PDF kitap başlığı, ebeveyn şifresi ve lokal Premium durumu cihazda lokal saklanır.
- PDF Günlük Kitabı cihaz üzerinde oluşturulur.
- Tüm verileri sil özelliği vardır.
- Tüm verileri sil akışı ebeveyn şifresiyle korunur.
- Tüm yerel veriler silinince ebeveyn şifresi de sıfırlanır.
- Tüm verileri sil lokal Premium durumunu temizler; gerçek satın alma Google Play üzerinden geri yüklenebilir.
- Ebeveyn Alanı şifreyle korunur.
- Varsayılan ebeveyn şifresi `1234` değeridir ve Ebeveyn Alanı içinden değiştirilebilir.
- Ebeveyn şifresi unutulursa uygulama içinden tüm yerel veriler silinerek şifre varsayılan `1234` değerine sıfırlanabilir. Premium satın alma varsa Google Play üzerinden geri yüklenebilir.
- Gelişmiş Günbi Yazı Kontrolü Premium ve ebeveyn onaylı özellik olarak hazırlanmıştır.
- Backend bağlantısı yapılandırılıp ebeveyn onayı açılırsa yazı, yalnızca yazım ve noktalama önerileri üretmek için güvenli API servisine gönderilebilir.
- Backend bağlantısı yapılandırılmamışsa gelişmiş kontrol çalışmaz ve yazılar dış servise gönderilmez.

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
- Ebeveyn Alanı şifreyle korunur.
- Varsayılan ebeveyn şifresi `1234` değeridir, değiştirilebilir ve cihazda lokal saklanır.
- Tüm verileri sil akışı ebeveyn şifresiyle korunur.
- Ebeveyn şifresi unutulursa tüm yerel veriler silinerek şifre varsayılan `1234` değerine döndürülebilir; bu işlem güçlü kimlik doğrulama yerine geçmez.
- Çocuk cinsiyet bilgisi yalnızca cihazda lokal profil bilgisi olarak saklanır.
- Günlük yazıları cihaz içinde saklanır.
- AI/API/Firebase yok.
- Reklam yok.
- Uygulama içi satın alma vardır; satın alma Google Play Billing üzerinden yönetilir.

## İlk yayın stratejisi

- Reklam yok.
- Hesap sistemi yok.
- Bulut yedekleme yok.
- Gerçek AI/API yok.
- Uygulamanın temel günlük deneyimi çevrimdışı kullanılabilir; Premium satın alma ve geri yükleme için Google Play bağlantısı gerekebilir.
- Günlük yazıları cihazda saklanır.
- Çocuk adı, yaş grubu, cinsiyet, duygu seçimi, yazı başlığı, yazı metni, PDF kitap başlığı, ebeveyn şifresi ve lokal Premium durumu yalnızca cihazda saklanır.
- Kapalı testte çocuk güvenliği ve veri silme akışı ayrıca test edilecek.

## Premium plan notları

- Uygulama içi satın alma vardır.
- Satın alma tipi: tek seferlik Premium kilidi.
- Ürün ID: `premium_lifetime`
- Google Play Billing kullanılacaktır.
- Google Play Billing için `com.android.vending.BILLING`, `INTERNET` ve `ACCESS_NETWORK_STATE` izinleri kullanılabilir.
- Ödeme bilgileri uygulama tarafından saklanmayacaktır.
- Satın alma işlemleri Google Play tarafından yönetilecektir.
- Premium teklifleri yalnızca Ebeveyn Alanı üzerinden yönetilecektir.
- Çocuk ekranlarında agresif satın alma çağrısı gösterilmeyecektir.
- Reklam kullanılmayacaktır.
- Abonelik kullanılmayacaktır.
- Reklamsızlaştırma gelir modeli kullanılmayacaktır; uygulama zaten reklamsız kalacaktır.
- Premium durumu cihazda lokal olarak tutulabilir.
- Tüm verileri sil lokal premium bilgisini temizler; satın alma Google Play üzerinden geri yüklenebilir.
- Ebeveyn şifresi unutulduğunda kullanılan sıfırlama akışı da lokal premium bilgisini temizler; satın alma Google Play üzerinden geri yüklenebilir.
- Gelişmiş rozetler, gelişmiş haftalık özet, daha fazla Günbi yazı önerisi ve özel Günbi temaları ileride Premium kapsamında değerlendirilebilir.
- Gelişmiş Günbi Yazı Kontrolü Premium kapsamında ebeveyn onayına bağlıdır. API bağlantısı aktif edilirse çocuk yerine yazmayacak, yalnızca yazım ve noktalama önerileri sunacaktır.
- İlk sürümde satın alma durumu Google Play Billing istemci akışıyla yönetilir. Daha yüksek güvenlik gereksinimlerinde sunucu tarafı doğrulama ayrıca değerlendirilebilir.
