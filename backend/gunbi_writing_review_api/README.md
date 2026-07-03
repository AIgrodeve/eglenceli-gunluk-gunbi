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
OPENAI_MODEL=gpt-5.2
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
      "message": "Burada 'Günlük' yazılır."
    }
  ]
}
```

## Flutter bağlantısı

Release build alırken backend URL'si verilmelidir:

```bash
flutter build appbundle --release --dart-define=GUNBI_REVIEW_API_URL=https://example.com/review
```

URL verilmezse uygulama gelişmiş kontrolün henüz bağlanmadığını söyler ve yanıltıcı yerel yazım kontrolü yapmaz.

## Güvenlik notu

- Çocuk yerine yazı üretmez.
- Günlük metnini yeniden yazmaz.
- En fazla 5 kısa öneri döndürür.
- Sert veya suçlayıcı dil kullanmaz.
- API bağlantısı canlıya alınmadan önce gizlilik politikası ve Play Console Data Safety beyanları gerçek veri aktarımına göre tekrar güncellenmelidir.
