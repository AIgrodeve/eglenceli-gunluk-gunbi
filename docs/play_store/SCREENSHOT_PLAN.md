# Screenshot Plan

## Demo profil

- Demo Ã§ocuk adÄ±: Meryem
- YaÅŸ grubu: 9-12
- Cinsiyet: KÄ±z

## Demo yazÄ±lar

- Tatil
- Parkta Bir GÃ¼n
- BugÃ¼n Kendimi NasÄ±l Hissettim?
- KÃ¼Ã§Ã¼k Bir BaÅŸarÄ±

## Demo duygular

- Mutlu
- Sakin
- Enerjik
- HeyecanlÄ±

## Demo veriyi oluÅŸturma

Demo veri yalnÄ±zca Play Store ekran gÃ¶rÃ¼ntÃ¼sÃ¼ hazÄ±rlÄ±ÄŸÄ± iÃ§in kullanÄ±lmalÄ±dÄ±r. Normal kullanÄ±cÄ± akÄ±ÅŸÄ±nda otomatik demo veri oluÅŸturulmaz.

Kod tarafÄ±nda `ScreenshotDemoDataSeeder` helper'Ä± vardÄ±r:

- Dosya: `lib/core/debug/screenshot_demo_data_seeder.dart`
- YalnÄ±zca `kDebugMode` iÃ§inde Ã§alÄ±ÅŸÄ±r.
- Release build iÃ§inde Ã§alÄ±ÅŸtÄ±rÄ±lmak istenirse hata verir.
- VarsayÄ±lan olarak mevcut kullanÄ±cÄ± verisi veya profil varsa iÅŸlem yapmaz.
- Sadece ekran gÃ¶rÃ¼ntÃ¼sÃ¼ iÃ§in ayrÄ±lmÄ±ÅŸ geliÅŸtirici cihazÄ±nda `replaceExisting: true` bilinÃ§li ÅŸekilde kullanÄ±lmalÄ±dÄ±r.

Ã–rnek geÃ§ici debug kullanÄ±m fikri:

```dart
await const ScreenshotDemoDataSeeder().seed(replaceExisting: true);
```

Bu Ã§aÄŸrÄ± uygulama koduna kalÄ±cÄ± olarak eklenmemelidir. Ekran gÃ¶rÃ¼ntÃ¼leri alÄ±ndÄ±ktan sonra release build temiz veriyle ayrÄ±ca test edilmelidir.

## Demo yazÄ± iÃ§erikleri

1. Tatil
   - Duygu: Enerjik
   - Konu: BugÃ¼n yaÅŸadÄ±ÄŸÄ±n en gÃ¼zel anÄ± detaylarÄ±yla yaz.
   - YazÄ±: BugÃ¼n okul tatildi. Babam iÅŸten erken geldi. Parkta Ã§ok vakit geÃ§irdik. Eve dÃ¶nÃ¼nce gÃ¼nlÃ¼ÄŸÃ¼me yazmak istediÄŸim gÃ¼zel anÄ±lar birikti.
2. Parkta Bir GÃ¼n
   - Duygu: Sakin
   - Konu: BugÃ¼n zorlandÄ±ÄŸÄ±n bir ÅŸey oldu mu? NasÄ±l hissettin?
   - YazÄ±: Hava Ã§ok sÄ±cak olduÄŸu iÃ§in bazÄ± arkadaÅŸlarÄ±m parka gelmedi. Ã–nce biraz Ã¼zÃ¼ldÃ¼m ama sonra kitap okuyup salÄ±ncakta sallandÄ±m. GÃ¼nÃ¼m yine gÃ¼zel geÃ§ti.
3. BugÃ¼n Kendimi NasÄ±l Hissettim?
   - Duygu: Mutlu
   - Konu: BugÃ¼n seni dÃ¼ÅŸÃ¼ndÃ¼ren bir ÅŸey oldu mu?
   - YazÄ±: BugÃ¼n kendimi mutlu hissettim. Ã‡Ã¼nkÃ¼ Ã¶ÄŸretmenim yazÄ±mÄ± beÄŸendi. YazdÄ±kÃ§a kendimi daha iyi anlatabildiÄŸimi fark ettim.
4. KÃ¼Ã§Ã¼k Bir BaÅŸarÄ±
   - Duygu: HeyecanlÄ±
   - Konu: BugÃ¼n Ã¶ÄŸrendiÄŸin bir ÅŸeyi kendi cÃ¼mlelerinle anlat.
   - YazÄ±: BugÃ¼n yeni kelimeler Ã¶ÄŸrendim. Ã–nce zor sandÄ±m ama sonra cÃ¼mle iÃ§inde kullanÄ±nca daha kolay oldu. GÃ¼nbi de bana yazarken yardÄ±mcÄ± oldu.

## Ã–nerilen akÄ±ÅŸ

1. UygulamayÄ± temiz kurulum gibi aÃ§.
2. Onboarding iÃ§inde Meryem profilini oluÅŸtur.
3. 9-12 yaÅŸ grubunu ve KÄ±z seÃ§imini kullan.
4. Demo yazÄ±larÄ± farklÄ± duygu seÃ§imleriyle ekle.
5. Ana sayfa, yazÄ± ekranÄ±, yazÄ± koÃ§u, YazÄ±larÄ±m, Rozetlerim, HaftalÄ±k Ã–zet ve GÃ¼nlÃ¼k KitabÄ±m ekranlarÄ±nÄ± sÄ±rayla yakala.
6. Gizlilik ve gÃ¼venlik vurgusu iÃ§in Ebeveyn AlanÄ± veya Ayarlar iÃ§indeki ilgili ekranÄ± ayrÄ±ca yakala.

## Ekran gÃ¶rÃ¼ntÃ¼sÃ¼ alma sÄ±rasÄ±

1. GÃ¼nbi karÅŸÄ±lama
2. Ana sayfa
3. BugÃ¼nÃ¼ yaz
4. GÃ¼nbi'den yardÄ±m al
5. YazÄ±larÄ±m
6. Rozetlerim
7. HaftalÄ±k Ã–zet
8. GÃ¼nlÃ¼k KitabÄ±m
9. Gizlilik ve GÃ¼venlik / Ebeveyn AlanÄ±

## Ekran gÃ¶rÃ¼ntÃ¼sÃ¼ kÄ±sa baÅŸlÄ±klarÄ±

- GÃ¼nbi ile tanÄ±ÅŸ
- BugÃ¼nÃ¼ yaz
- Yazarken destek al
- YazdÄ±kÃ§a rozet kazan
- HaftalÄ±k geliÅŸimini gÃ¶r
- YazÄ±larÄ±n kitaba dÃ¶nÃ¼ÅŸsÃ¼n
- GÃ¼venli ve reklamsÄ±z alan

