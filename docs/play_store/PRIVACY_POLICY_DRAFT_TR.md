# Eğlenceli Günlük Gizlilik Politikası

Son güncelleme tarihi: 15.06.2026

## Uygulama hakkında

Eğlenceli Günlük, çocukların yazma alışkanlığı kazanmasına ve duygularını güvenli bir şekilde ifade etmesine yardımcı olmak için tasarlanmış bir günlük uygulamasıdır.

Uygulama hedef yaş grupları 6-8 ve 9-12 olarak sınırlandırılmıştır.

## Uygulama kimliği

- Uygulama adı: Eğlenceli Günlük
- Paket adı: com.aigrodeve.eglenceligunluk
- Geliştirici: AIgrodeve
- İletişim: aigrodeve@gmail.com
- Gizlilik politikası URL’si: https://sites.google.com/view/eglenceli-gunluk

## Hangi bilgiler cihazda saklanır?

Uygulama mevcut sürümde aşağıdaki bilgileri cihaz içinde lokal olarak saklayabilir:

- Çocuk adı
- Yaş grubu
- Cinsiyet bilgisi
- Seçilen duygu bilgileri
- Yazı başlığı
- Yazı metni
- Yazı önerisi bilgisi
- Yazı tarihi ve saati
- PDF kitap başlığı tercihi
- Ebeveyn şifresi
- Lokal Premium durumu

## Hangi bilgiler toplanmaz?

Mevcut sürümde aşağıdaki bilgiler toplanmaz:

- Konum bilgisi
- Kamera görüntüsü
- Mikrofon kaydı
- Rehber veya kişi listesi
- Çevrim içi hesap bilgisi
- Sosyal medya hesabı
- Ödeme bilgisi

Uygulamada hesap oluşturma, bulut yedekleme, Firebase/API/sunucu tabanlı günlük saklama, çocuklar arası mesajlaşma veya herkese açık paylaşım yoktur. Konum, kamera, mikrofon ve rehber izni kullanılmaz.

## İnternet ve sunucu kullanımı

Mevcut sürümde günlük yazıları bir sunucuya gönderilmez. Uygulama günlük kayıtlarını cihazda saklar. PDF Günlük Kitabı oluşturma işlemi cihaz üzerinde yapılır.

Çocuk adı, yaş grubu ve cinsiyet bilgisi uygulama deneyimini kişiselleştirmek için cihazda lokal olarak kullanılır; bu bilgiler bir sunucuya gönderilmez.

Çocuk adı, yaş grubu, cinsiyet, duygu seçimi, yazı başlığı, yazı metni, PDF kitap başlığı, ebeveyn şifresi ve lokal Premium durumu cihazda lokal olarak saklanır.

## Çocukların gizliliği

Eğlenceli Günlük çocukların günlük yazılarını özel kabul eder. Uygulamada çocuklar arası mesajlaşma, herkese açık profil veya herkese açık paylaşım özelliği yoktur.

## Ebeveyn alanı

Ebeveyn alanı şifreyle korunur ve çocuğun günlük yazılarının içeriğini göstermez. Bu alanda sadece yazma alışkanlığı ve gelişim özeti gibi genel bilgiler yer alır. Varsayılan ebeveyn şifresi `1234` değeridir ve uygulama içinde değiştirilebilir.

Ebeveyn şifresi unutulursa uygulama içinden tüm yerel veriler silinerek şifre varsayılan `1234` değerine sıfırlanabilir. Premium satın alma varsa Google Play üzerinden geri yüklenebilir.

## PDF Günlük Kitabı

PDF Günlük Kitabı özelliği, çocuğun cihazda kayıtlı yazılarından bir kitap önizlemesi ve PDF çıktısı oluşturmak için kullanılır. Bu işlem mevcut sürümde cihaz üzerinde yapılır.

## Reklam ve üçüncü taraf hizmetler

Mevcut sürümde reklam gösterilmez. Reklam SDK, analitik SDK veya crash reporting SDK kullanılmaz. Üçüncü taraf veri paylaşımı yapılmaz.

## Premium özellikler ve ödeme

Uygulama içi satın alma vardır. Satın alma tipi tek seferlik Premium kilididir. Ürün ID: `premium_lifetime`. Satın alma işlemleri Google Play üzerinden yönetilir. Google Play Billing ve `in_app_purchase` satın alma ve geri yükleme işlemleri için internet/Play Store bağlantısı kullanılabilir. Uygulama ödeme kartı veya ödeme bilgisi saklamaz. Premium durumu cihazda lokal olarak tutulabilir. Premium satın alma yalnızca Ebeveyn Alanı üzerinden yönetilir. Çocuk ekranlarında agresif satın alma çağrısı gösterilmez. Reklam ve abonelik kullanılmayacaktır.

Tüm verileri sil işlemi lokal premium bilgisini temizler; satın alma Google Play üzerinden geri yüklenebilir.

İlk sürümde satın alma durumu Google Play Billing istemci akışıyla yönetilir. Daha yüksek güvenlik gereksinimlerinde sunucu tarafı doğrulama ayrıca değerlendirilebilir.

## Günbi yazı kontrolü

Gelişmiş Günbi Yazı Kontrolü Premium kapsamındaki ebeveyn onaylı bir özellik olarak hazırlanmıştır. Backend bağlantısı yapılandırılıp ebeveyn onayı açılırsa yazı, yalnızca yazım ve noktalama önerileri üretmek amacıyla güvenli API servisine gönderilebilir.

Bu özellik çocuğun yerine yazı yazmaz, günlük metnini baştan sona yeniden oluşturmaz ve yalnızca kısa öneriler sunar. Backend bağlantısı yapılandırılmamışsa gelişmiş kontrol çalışmaz ve yazılar dış servise gönderilmez.

## Verilerin silinmesi

Kullanıcı/ebeveyn, uygulama içindeki Ayarlar bölümünden cihazda saklanan günlük yazılarını ve uygulama verilerini silebilir. Tüm verileri sil akışı ebeveyn şifresiyle korunur. Tüm yerel veriler silindiğinde ebeveyn şifresi ve lokal Premium durumu da temizlenir. Ebeveyn şifresi unutulursa, uygulamada hesap veya sunucu olmadığı için Ebeveyn Alanı girişinden tüm yerel veriler silinerek ebeveyn şifresi varsayılan `1234` değerine sıfırlanabilir. Bu işlem cihazdaki yerel verileri temizler ve geri alınamaz. Premium satın alma varsa Google Play üzerinden geri yüklenebilir.

## İletişim

Gizlilik politikası hakkında sorular için:

- Geliştirici: AIgrodeve
- E-posta: aigrodeve@gmail.com

## Değişiklikler

Bu gizlilik politikası uygulamadaki özellikler değiştikçe güncellenebilir. Önemli değişiklikler olduğunda politika metni yeniden gözden geçirilmelidir.
