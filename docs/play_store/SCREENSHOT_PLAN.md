# Screenshot Plan

## Demo profil

- Demo çocuk adı: Meryem
- Yaş grubu: 9-11
- Cinsiyet: Kız

## Demo yazılar

- Tatil
- Parkta Bir Gün
- Bugün Kendimi Nasıl Hissettim?
- Küçük Bir Başarı

## Demo duygular

- Mutlu
- Sakin
- Enerjik
- Heyecanlı

## Demo veriyi oluşturma

Demo veri yalnızca Play Store ekran görüntüsü hazırlığı için kullanılmalıdır. Normal kullanıcı akışında otomatik demo veri oluşturulmaz.

Kod tarafında `ScreenshotDemoDataSeeder` helper'ı vardır:

- Dosya: `lib/core/debug/screenshot_demo_data_seeder.dart`
- Yalnızca `kDebugMode` içinde çalışır.
- Release build içinde çalıştırılmak istenirse hata verir.
- Varsayılan olarak mevcut kullanıcı verisi veya profil varsa işlem yapmaz.
- Sadece ekran görüntüsü için ayrılmış geliştirici cihazında `replaceExisting: true` bilinçli şekilde kullanılmalıdır.

Örnek geçici debug kullanım fikri:

```dart
await const ScreenshotDemoDataSeeder().seed(replaceExisting: true);
```

Bu çağrı uygulama koduna kalıcı olarak eklenmemelidir. Ekran görüntüleri alındıktan sonra release build temiz veriyle ayrıca test edilmelidir.

## Demo yazı içerikleri

1. Tatil
   - Duygu: Enerjik
   - Konu: Bugün yaşadığın en güzel anı detaylarıyla yaz.
   - Yazı: Bugün okul tatildi. Babam işten erken geldi. Parkta çok vakit geçirdik. Eve dönünce günlüğüme yazmak istediğim güzel anılar birikti.
2. Parkta Bir Gün
   - Duygu: Sakin
   - Konu: Bugün zorlandığın bir şey oldu mu? Nasıl hissettin?
   - Yazı: Hava çok sıcak olduğu için bazı arkadaşlarım parka gelmedi. Önce biraz üzüldüm ama sonra kitap okuyup salıncakta sallandım. Günüm yine güzel geçti.
3. Bugün Kendimi Nasıl Hissettim?
   - Duygu: Mutlu
   - Konu: Bugün seni düşündüren bir şey oldu mu?
   - Yazı: Bugün kendimi mutlu hissettim. Çünkü öğretmenim yazımı beğendi. Yazdıkça kendimi daha iyi anlatabildiğimi fark ettim.
4. Küçük Bir Başarı
   - Duygu: Heyecanlı
   - Konu: Bugün öğrendiğin bir şeyi kendi cümlelerinle anlat.
   - Yazı: Bugün yeni kelimeler öğrendim. Önce zor sandım ama sonra cümle içinde kullanınca daha kolay oldu. Günbi de bana yazarken yardımcı oldu.

## Önerilen akış

1. Uygulamayı temiz kurulum gibi aç.
2. Onboarding içinde Meryem profilini oluştur.
3. 9-11 yaş grubunu ve Kız seçimini kullan.
4. Demo yazıları farklı duygu seçimleriyle ekle.
5. Ana sayfa, yazı ekranı, yazı koçu, Yazılarım, Rozetlerim, Haftalık Özet ve Günlük Kitabım ekranlarını sırayla yakala.
6. Gizlilik ve güvenlik vurgusu için Ebeveyn Alanı veya Ayarlar içindeki ilgili ekranı ayrıca yakala.

## Ekran görüntüsü alma sırası

1. Günbi karşılama
2. Ana sayfa
3. Bugünü yaz
4. Günbi'den yardım al
5. Yazılarım
6. Rozetlerim
7. Haftalık Özet
8. Günlük Kitabım
9. Gizlilik ve Güvenlik / Ebeveyn Alanı

## Ekran görüntüsü kısa başlıkları

- Günbi ile tanış
- Bugünü yaz
- Yazarken destek al
- Yazdıkça rozet kazan
- Haftalık gelişimini gör
- Yazıların kitaba dönüşsün
- Güvenli ve reklamsız alan
