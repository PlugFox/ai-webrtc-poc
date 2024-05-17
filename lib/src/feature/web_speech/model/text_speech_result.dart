import 'package:flutter/foundation.dart';

/// Result of the text speech recognition.
@immutable
final class TextSpeechResult {
  const TextSpeechResult({
    required this.alternatives,
    required this.isFinal,
  });

  /// List of speech alternatives.
  final List<TextSpeechAlternative> alternatives;

  /// Whether the result is final.
  final bool isFinal;

  @override
  String toString() => alternatives.firstOrNull?.transcript ?? '';
}

/// Speech alternatives.
@immutable
final class TextSpeechAlternative {
  const TextSpeechAlternative({
    required this.transcript,
    required this.confidence,
  });

  /// Transcript of the alternative.
  final String transcript;

  /// Confidence of the alternative.
  final double confidence;

  @override
  String toString() => transcript;
}
