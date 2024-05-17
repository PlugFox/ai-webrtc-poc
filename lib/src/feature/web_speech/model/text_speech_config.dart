import 'package:meta/meta.dart';

@immutable
final class TextSpeechConfig {
  const TextSpeechConfig({
    this.lang = 'en-US',
    this.interimResults = false,
    this.maxAlternatives = 1,
    this.continuous = false,
  });

  /// Language of the current SpeechRecognition
  final String lang;

  /// Controls whether interim results should be returned (true) or not (false).
  /// Interim results are results that are not yet final
  /// (e.g. the SpeechRecognitionResult.isFinal property is false).
  final bool interimResults;

  /// The maximum number of SpeechRecognitionAlternatives provided per result.
  /// The default value is 1.
  final int maxAlternatives;

  /// Controls whether continuous results are returned for each recognition,
  /// or only a single result. Defaults to single (false).
  final bool continuous;
}
