import 'package:meta/meta.dart';

@immutable
final class TextSpeechConfig {
  const TextSpeechConfig({
    this.lang = 'en-US',
    this.interimResults = true,
    this.maxAlternatives = 5,
    this.continuous = true,
  }) : assert(maxAlternatives > 0, 'maxAlternatives must be greater than 0');

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

  /// Copy with new values.
  TextSpeechConfig copyWith({
    String? lang,
    bool? interimResults,
    int? maxAlternatives,
    bool? continuous,
  }) =>
      TextSpeechConfig(
        lang: lang ?? this.lang,
        interimResults: interimResults ?? this.interimResults,
        maxAlternatives: maxAlternatives ?? this.maxAlternatives,
        continuous: continuous ?? this.continuous,
      );
}
