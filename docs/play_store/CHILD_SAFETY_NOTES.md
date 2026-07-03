# Child Safety Notes

- Uygulama Ã§ocuklarÄ±n yazma alÄ±ÅŸkanlÄ±ÄŸÄ±nÄ± destekler.
- Hedef yaÅŸ gruplarÄ± 6-8 ve 9-12 olarak sÄ±nÄ±rlandÄ±rÄ±lmÄ±ÅŸtÄ±r.
- Ã‡ocuklar arasÄ± iletiÅŸim yoktur.
- Herkese aÃ§Ä±k profil yoktur.
- Herkese aÃ§Ä±k iÃ§erik paylaÅŸÄ±mÄ± yoktur.
- YabancÄ±larla etkileÅŸim yoktur.
- Konum bilgisi alÄ±nmaz.
- Reklam gÃ¶sterilmez.
- Ebeveyn alanÄ± ÅŸifreyle korunur ve gÃ¼nlÃ¼k iÃ§eriklerini deÄŸil, sadece geliÅŸim Ã¶zetini gÃ¶sterir.
- VarsayÄ±lan ebeveyn ÅŸifresi 1234'tÃ¼r, cihazda lokal saklanÄ±r ve deÄŸiÅŸtirilebilir.
- TÃ¼m verileri sil akÄ±ÅŸÄ± ebeveyn ÅŸifresiyle korunur.
- TÃ¼m yerel veriler silinince ebeveyn ÅŸifresi de sÄ±fÄ±rlanÄ±r.
- Ebeveyn ÅŸifresi unutulursa hesap/sunucu olmadÄ±ÄŸÄ± iÃ§in yerel veriler silinerek varsayÄ±lan 1234 deÄŸerine dÃ¶nÃ¼lebilir.
- Premium satÄ±n alma yalnÄ±zca Ebeveyn AlanÄ± Ã¼zerinden yÃ¶netilir.
- Ã‡ocuk ekranlarÄ±nda agresif satÄ±n alma Ã§aÄŸrÄ±sÄ± yoktur.
- Premium satÄ±n alma varsa Google Play Ã¼zerinden geri yÃ¼klenebilir.
- YazÄ± koÃ§u Ã§ocuÄŸun yerine yazmaz, sadece yÃ¶nlendirir.
- GeliÅŸmiÅŸ GÃ¼nbi YazÄ± KontrolÃ¼ Premium ve ebeveyn onaylÄ± Ã¶zellik olarak hazÄ±rlanmÄ±ÅŸtÄ±r.
- Backend baÄŸlantÄ±sÄ± yapÄ±landÄ±rÄ±lÄ±p ebeveyn onayÄ± aÃ§Ä±lÄ±rsa yazÄ±, yalnÄ±zca yazÄ±m ve noktalama Ã¶nerileri Ã¼retmek iÃ§in gÃ¼venli API servisine gÃ¶nderilebilir.
- GeliÅŸmiÅŸ GÃ¼nbi YazÄ± KontrolÃ¼ aÃ§Ä±lÄ±rsa yazÄ±, yalnÄ±zca yazÄ±m ve noktalama Ã¶nerileri Ã¼retmek iÃ§in gÃ¼venli API servisine gÃ¶nderilebilir.
- API destekli yazÄ± kontrolÃ¼ Ã§ocuk yerine yazmaz ve ebeveyn bilgilendirmesiyle kullanÄ±lÄ±r.



## Günbi Yazı Kontrolü veri notu

Gelişmiş Günbi Yazı Kontrolü yalnızca Premium ve ebeveyn onayıyla çalışır. Bu özellik kullanıldığında başlık ve yazı metni, yazım ve noktalama önerileri üretmek için güvenli API servisine gönderilebilir. Bu işlem herkese açık paylaşım, çocuklar arası mesajlaşma veya bulut günlük yedekleme değildir. Günlük kayıtları cihazda saklanır; API isteği günlük kaydı olarak sunucuda tutulmamalıdır.
