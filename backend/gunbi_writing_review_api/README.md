# Gunbi Writing Review API

Bu küçük backend, Premium ve ebeveyn onaylı **Gelişmiş Günbi Yazı Kontrolü** için hazırlanmıştır.

Mobil uygulama OpenAI API anahtarını taşımaz. Flutter uygulaması bu backend endpoint'ine istek gönderir; OpenAI API anahtarı yalnızca sunucu ortamında tutulur.

## Çalıştırma

```bash
cd backend/gunbi_writing_review_api
copy .env.example .env
npm start
```

Gerekli ortam değişkenleri:

```text
OPENAI_API_KEY=...
OPENAI_MODEL=gpt-5.5
PORT=8787
```

## Endpoint

```http
POST /review
Content-Type: application/json
```

İstek:

```json
{
  "title": "Günluk Deneme",
  "text": "Günluk uygulamasi yazım denetimi nasıl çalışıyor.",
  "ageGroup": "9-12",
  "moodLabel": "Sakin"
}
```

Yanıt:

```json
{
  "summary": "Günbi birkaç küçük öneri buldu.",
  "suggestions": [
    {
      "type": "spelling",
      "original": "Günluk",
      "suggestion": "Günlük",
      "message": "Başlıkta veya yazıda 'Günlük' yazabilirsin."
    }
  ]
}
```

## Flutter bağlantısı

Uygulamada varsayılan endpoint:

```text
https://gunbi-writing-review-api.onrender.com/review
```

Gerekirse release build sırasında farklı backend URL'si verilebilir:

```bash
flutter build appbundle --release --dart-define=GUNBI_REVIEW_API_URL=https://gunbi-writing-review-api.onrender.com/review
```

## Güvenlik notu

- Çocuk yerine yazı üretmez.
- Günlük metnini yeniden yazmaz.
- Başlık ve yazıyı yalnızca yazım ve noktalama önerileri için kontrol eder.
- En fazla 5 kısa öneri döndürür.
- Sert veya suçlayıcı dil kullanmaz.
- OpenAI isteğinde `store:false` kullanılır.
- Gizlilik politikası ve Play Console Data Safety beyanları, başlık ve yazının güvenli API servisine gönderilebileceğini belirtecek şekilde güncel tutulmalıdır.
