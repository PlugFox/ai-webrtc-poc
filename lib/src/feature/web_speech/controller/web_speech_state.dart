import 'package:meta/meta.dart';

/// {@template web_speech_state}
/// WebSpeechState.
/// {@endtemplate}
sealed class WebSpeechState extends _$WebSpeechStateBase {
  /// {@macro web_speech_state}
  const WebSpeechState({required super.sentences, required super.message});

  /// Idling state
  /// {@macro web_speech_state}
  const factory WebSpeechState.idle({
    required List<String> sentences,
    String message,
  }) = WebSpeechState$Idle;

  /// Processing
  /// {@macro web_speech_state}
  const factory WebSpeechState.processing({
    required List<String> sentences,
    String message,
  }) = WebSpeechState$Processing;

  /// An error has occurred
  /// {@macro web_speech_state}
  const factory WebSpeechState.error({
    required List<String> sentences,
    String message,
  }) = WebSpeechState$Error;
}

/// Idling state
final class WebSpeechState$Idle extends WebSpeechState {
  const WebSpeechState$Idle({required super.sentences, super.message = 'Idling'});
}

/// Processing
final class WebSpeechState$Processing extends WebSpeechState {
  const WebSpeechState$Processing({required super.sentences, super.message = 'Processing'});
}

/// Error
final class WebSpeechState$Error extends WebSpeechState {
  const WebSpeechState$Error({required super.sentences, super.message = 'An error has occurred.'});
}

/// Pattern matching for [WebSpeechState].
typedef WebSpeechStateMatch<R, S extends WebSpeechState> = R Function(S state);

@immutable
abstract base class _$WebSpeechStateBase {
  const _$WebSpeechStateBase({required this.sentences, required this.message});

  /// Data entity payload.
  @nonVirtual
  final List<String> sentences;

  /// Message or state description.
  @nonVirtual
  final String message;

  /// Has data?
  bool get hasData => sentences.isNotEmpty;

  /// If an error has occurred?
  bool get hasError => maybeMap<bool>(orElse: () => false, error: (_) => true);

  /// Is in progress state?
  bool get isProcessing => maybeMap<bool>(orElse: () => true, idle: (_) => false);

  /// Is in idle state?
  bool get isIdling => !isProcessing;

  /// Pattern matching for [WebSpeechState].
  R map<R>({
    required WebSpeechStateMatch<R, WebSpeechState$Idle> idle,
    required WebSpeechStateMatch<R, WebSpeechState$Processing> processing,
    required WebSpeechStateMatch<R, WebSpeechState$Error> error,
  }) =>
      switch (this) {
        WebSpeechState$Idle s => idle(s),
        WebSpeechState$Processing s => processing(s),
        WebSpeechState$Error s => error(s),
        _ => throw AssertionError(),
      };

  /// Pattern matching for [WebSpeechState].
  R maybeMap<R>({
    required R Function() orElse,
    WebSpeechStateMatch<R, WebSpeechState$Idle>? idle,
    WebSpeechStateMatch<R, WebSpeechState$Processing>? processing,
    WebSpeechStateMatch<R, WebSpeechState$Error>? error,
  }) =>
      map<R>(
        idle: idle ?? (_) => orElse(),
        processing: processing ?? (_) => orElse(),
        error: error ?? (_) => orElse(),
      );

  /// Pattern matching for [WebSpeechState].
  R? mapOrNull<R>({
    WebSpeechStateMatch<R, WebSpeechState$Idle>? idle,
    WebSpeechStateMatch<R, WebSpeechState$Processing>? processing,
    WebSpeechStateMatch<R, WebSpeechState$Error>? error,
  }) =>
      map<R?>(
        idle: idle ?? (_) => null,
        processing: processing ?? (_) => null,
        error: error ?? (_) => null,
      );

  @override
  int get hashCode => sentences.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  String toString() => 'WebSpeechState{$message}';
}
