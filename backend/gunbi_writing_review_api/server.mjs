import http from "node:http";

const port = Number(process.env.PORT || 8787);
const apiKey = process.env.OPENAI_API_KEY;
const model = process.env.OPENAI_MODEL || "gpt-5.5";
const maxTextLength = 4000;
const maxTitleLength = 160;

const schema = {
  type: "object",
  additionalProperties: false,
  required: ["summary", "suggestions"],
  properties: {
    summary: {
      type: "string",
      description: "Short, warm Turkish summary for the child.",
    },
    suggestions: {
      type: "array",
      maxItems: 5,
      items: {
        type: "object",
        additionalProperties: false,
        required: ["type", "original", "suggestion", "message"],
        properties: {
          type: {
            type: "string",
            enum: [
              "spelling",
              "punctuation",
              "capitalization",
              "spacing",
              "repeatedWord",
              "longSentence",
            ],
          },
          original: { type: "string" },
          suggestion: { type: "string" },
          message: {
            type: "string",
            description: "Child-friendly Turkish explanation.",
          },
        },
      },
    },
  },
};

const server = http.createServer(async (request, response) => {
  try {
    if (request.method === "GET" && request.url === "/health") {
      sendJson(response, 200, { ok: true });
      return;
    }

    if (request.method !== "POST" || request.url !== "/review") {
      sendJson(response, 404, { error: "not_found" });
      return;
    }

    if (!apiKey) {
      sendJson(response, 503, { error: "missing_openai_api_key" });
      return;
    }

    const body = await readJsonBody(request);
    const title = normalizeString(body.title).slice(0, maxTitleLength);
    const text = normalizeString(body.text);
    const ageGroup = normalizeString(body.ageGroup);
    const moodLabel = normalizeString(body.moodLabel);

    if (!text) {
      sendJson(response, 400, { error: "empty_text" });
      return;
    }

    if (text.length > maxTextLength) {
      sendJson(response, 413, { error: "text_too_long" });
      return;
    }

    const review = await reviewWithOpenAI({ title, text, ageGroup, moodLabel });
    sendJson(response, 200, review);
  } catch (error) {
    console.error("Gunbi review API error:", error);
    sendJson(response, 500, { error: "review_failed" });
  }
});

server.listen(port, () => {
  console.log(`Gunbi writing review API listening on :${port}`);
});

async function reviewWithOpenAI({ title, text, ageGroup, moodLabel }) {
  const openaiResponse = await fetch("https://api.openai.com/v1/responses", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${apiKey}`,
    },
    body: JSON.stringify({
      model,
      store: false,
      input: [
        {
          role: "developer",
          content: [
            "Sen Günbi adlı çocuk dostu bir yazı koçusun.",
            "Başlık ve günlük yazısı birlikte kontrol edilir.",
            "Sadece Türkçe yazım, Türkçe karakter, noktalama, boşluk ve cümle düzeni önerileri ver.",
            "Çocuğun yerine yazı yazma, metni baştan sona yeniden yazma.",
            "Sert, suçlayıcı veya utandırıcı dil kullanma.",
            "En fazla 5 kısa öneri üret.",
            "Öneri başlıktaysa mesajda 'Başlıkta' ifadesini kullan.",
            "Soru cümlelerinde nokta yerine soru işareti gerekiyorsa bunu fark et.",
            "Örnek: 'Günluk uygulamasi yazım denetimi nasıl çalışıyor.' cümlesinde 'Günlük', 'uygulaması' ve '?' önerilebilir.",
          ].join(" "),
        },
        {
          role: "user",
          content: JSON.stringify({
            ageGroup,
            moodLabel,
            title,
            text,
          }),
        },
      ],
      text: {
        format: {
          type: "json_schema",
          name: "gunbi_writing_review",
          strict: true,
          schema,
        },
      },
    }),
  });

  if (!openaiResponse.ok) {
    const errorText = await openaiResponse.text();
    throw new Error(
      `OpenAI request failed: ${openaiResponse.status} ${errorText}`,
    );
  }

  const data = await openaiResponse.json();
  const outputText = extractOutputText(data);
  if (!outputText) {
    throw new Error("OpenAI response did not include output text.");
  }

  const parsed = JSON.parse(outputText);
  return {
    summary: normalizeString(parsed.summary) || "Günbi yazını kontrol etti.",
    suggestions: Array.isArray(parsed.suggestions)
      ? parsed.suggestions.map(normalizeSuggestion).filter(Boolean).slice(0, 5)
      : [],
  };
}

function normalizeSuggestion(value) {
  if (!value || typeof value !== "object") {
    return null;
  }

  const type = normalizeString(value.type);
  const original = normalizeString(value.original);
  const suggestion = normalizeString(value.suggestion);
  const message = normalizeString(value.message);

  if (!type || !message) {
    return null;
  }

  return { type, original, suggestion, message };
}

function extractOutputText(data) {
  if (typeof data?.output_text === "string") {
    return data.output_text;
  }

  for (const item of data?.output || []) {
    for (const content of item?.content || []) {
      if (content?.type === "output_text" && typeof content.text === "string") {
        return content.text;
      }
    }
  }

  return "";
}

function readJsonBody(request) {
  return new Promise((resolve, reject) => {
    let raw = "";
    request.setEncoding("utf8");
    request.on("data", (chunk) => {
      raw += chunk;
      if (raw.length > 32_000) {
        request.destroy();
        reject(new Error("Request body too large."));
      }
    });
    request.on("end", () => {
      try {
        resolve(raw ? JSON.parse(raw) : {});
      } catch (error) {
        reject(error);
      }
    });
    request.on("error", reject);
  });
}

function sendJson(response, statusCode, payload) {
  response.writeHead(statusCode, {
    "Content-Type": "application/json; charset=utf-8",
    "Cache-Control": "no-store",
  });
  response.end(JSON.stringify(payload));
}

function normalizeString(value) {
  return typeof value === "string" ? value.trim() : "";
}
