import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../../core/models/age_group.dart';
import '../models/writing_review_suggestion.dart';

enum AdvancedWritingReviewStatus {
  success,
  notConfigured,
  unavailable,
  invalidResponse,
}

class AdvancedWritingReviewResult {
  const AdvancedWritingReviewResult({
    required this.status,
    required this.suggestions,
    required this.message,
  });

  const AdvancedWritingReviewResult.success({
    required List<WritingReviewSuggestion> suggestions,
    required String message,
  }) : this(
         status: AdvancedWritingReviewStatus.success,
         suggestions: suggestions,
         message: message,
       );

  const AdvancedWritingReviewResult.notConfigured()
    : this(
        status: AdvancedWritingReviewStatus.notConfigured,
        suggestions: const [],
        message:
            'Gelişmiş Günbi kontrolü henüz bağlanmadı. Ebeveyn alanında özellik hazır, API bağlantısı tamamlanınca çalışacak.',
      );

  const AdvancedWritingReviewResult.unavailable()
    : this(
        status: AdvancedWritingReviewStatus.unavailable,
        suggestions: const [],
        message:
            'Günbi şu anda gelişmiş kontrol yapamadı. Lütfen biraz sonra tekrar deneyelim.',
      );

  const AdvancedWritingReviewResult.invalidResponse()
    : this(
        status: AdvancedWritingReviewStatus.invalidResponse,
        suggestions: const [],
        message:
            'Günbi yazıyı kontrol etti ama önerileri anlayamadı. Lütfen tekrar deneyelim.',
      );

  final AdvancedWritingReviewStatus status;
  final List<WritingReviewSuggestion> suggestions;
  final String message;

  bool get isSuccessful => status == AdvancedWritingReviewStatus.success;
}

class AdvancedWritingReviewService {
  const AdvancedWritingReviewService({
    this.endpointUrl = const String.fromEnvironment(
      'GUNBI_REVIEW_API_URL',
      defaultValue: 'https://gunbi-writing-review-api.onrender.com/review',
    ),
  });

  final String endpointUrl;

  bool get isConfigured {
    final uri = Uri.tryParse(endpointUrl.trim());
    return uri != null && uri.hasScheme && uri.hasAuthority;
  }

  Future<AdvancedWritingReviewResult> review({
    String? title,
    required String text,
    required AgeGroup ageGroup,
    required String moodLabel,
  }) async {
    if (!isConfigured) {
      return const AdvancedWritingReviewResult.notConfigured();
    }
    final uri = Uri.parse(endpointUrl.trim());

    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 8);

    try {
      final request = await client
          .postUrl(uri)
          .timeout(const Duration(seconds: 8));
      request.headers.contentType = ContentType.json;
      request.write(
        jsonEncode({
          'title': title?.trim() ?? '',
          'text': text,
          'ageGroup': ageGroup.storageValue,
          'moodLabel': moodLabel,
        }),
      );

      final response = await request.close().timeout(
        const Duration(seconds: 15),
      );
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return const AdvancedWritingReviewResult.unavailable();
      }

      final decoded = jsonDecode(responseBody);
      if (decoded is! Map<String, dynamic>) {
        return const AdvancedWritingReviewResult.invalidResponse();
      }

      final suggestionsJson = decoded['suggestions'];
      if (suggestionsJson is! List) {
        return const AdvancedWritingReviewResult.invalidResponse();
      }

      final suggestions = suggestionsJson
          .whereType<Map<String, dynamic>>()
          .map(_suggestionFromJson)
          .whereType<WritingReviewSuggestion>()
          .take(8)
          .toList(growable: false);
      final message = decoded['summary'] as String?;

      return AdvancedWritingReviewResult.success(
        suggestions: suggestions,
        message: message?.trim().isNotEmpty == true
            ? message!.trim()
            : suggestions.isEmpty
            ? 'Günbi gelişmiş kontrolle baktı, yazın güzel görünüyor!'
            : 'Günbi gelişmiş kontrolle küçük öneriler buldu.',
      );
    } on Object {
      return const AdvancedWritingReviewResult.unavailable();
    } finally {
      client.close(force: true);
    }
  }

  WritingReviewSuggestion? _suggestionFromJson(Map<String, dynamic> json) {
    final type = _typeFromString(json['type'] as String?);
    final message = (json['message'] as String?)?.trim();
    if (type == null || message == null || message.isEmpty) {
      return null;
    }

    return WritingReviewSuggestion(
      type: type,
      message: message,
      original: (json['original'] as String?)?.trim(),
      suggestion: (json['suggestion'] as String?)?.trim(),
    );
  }

  WritingReviewType? _typeFromString(String? value) {
    return switch (value?.trim()) {
      'spelling' => WritingReviewType.spelling,
      'punctuation' => WritingReviewType.punctuation,
      'capitalization' => WritingReviewType.capitalization,
      'spacing' => WritingReviewType.spacing,
      'repeatedWord' => WritingReviewType.repeatedWord,
      'longSentence' => WritingReviewType.longSentence,
      _ => null,
    };
  }
}
