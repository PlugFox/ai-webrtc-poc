import 'package:meta/meta.dart';
import 'package:poc/src/feature/media_stream/model/media_stream_context.dart';

/// {@template media_stream_state}
/// MediaStreamState.
/// {@endtemplate}
sealed class MediaStreamState extends _$MediaStreamStateBase {
  /// {@macro media_stream_state}
  const MediaStreamState({required super.message});

  /// Idling state
  /// {@macro media_stream_state}
  const factory MediaStreamState.idle({
    String message,
  }) = MediaStreamState$Idle;

  /// Processing
  /// {@macro media_stream_state}
  const factory MediaStreamState.processing({
    required MediaStreamContext? data,
    String message,
  }) = MediaStreamState$Processing;

  /// An error has occurred
  /// {@macro media_stream_state}
  const factory MediaStreamState.error({
    required MediaStreamContext? data,
    String message,
  }) = MediaStreamState$Error;
}

/// Idling state
final class MediaStreamState$Idle extends MediaStreamState {
  const MediaStreamState$Idle({super.message = 'Idling'});

  @override
  MediaStreamContext? get data => null;
}

/// Processing
final class MediaStreamState$Processing extends MediaStreamState {
  const MediaStreamState$Processing({required this.data, super.message = 'Processing'});

  @override
  final MediaStreamContext? data;
}

/// Error
final class MediaStreamState$Error extends MediaStreamState {
  const MediaStreamState$Error({required this.data, super.message = 'An error has occurred.'});

  @override
  final MediaStreamContext? data;
}

/// Pattern matching for [MediaStreamState].
typedef MediaStreamStateMatch<R, S extends MediaStreamState> = R Function(S state);

@immutable
abstract base class _$MediaStreamStateBase {
  const _$MediaStreamStateBase({required this.message});

  /// Data entity payload.
  @nonVirtual
  abstract final MediaStreamContext? data;

  /// Message or state description.
  @nonVirtual
  final String message;

  /// Has data?
  bool get hasData => data != null;

  /// If an error has occurred?
  bool get hasError => maybeMap<bool>(orElse: () => false, error: (_) => true);

  /// Is in progress state?
  bool get isProcessing => maybeMap<bool>(orElse: () => true, idle: (_) => false);

  /// Is in idle state?
  bool get isIdling => !isProcessing;

  /// Pattern matching for [MediaStreamState].
  R map<R>({
    required MediaStreamStateMatch<R, MediaStreamState$Idle> idle,
    required MediaStreamStateMatch<R, MediaStreamState$Processing> processing,
    required MediaStreamStateMatch<R, MediaStreamState$Error> error,
  }) =>
      switch (this) {
        MediaStreamState$Idle s => idle(s),
        MediaStreamState$Processing s => processing(s),
        MediaStreamState$Error s => error(s),
        _ => throw AssertionError(),
      };

  /// Pattern matching for [MediaStreamState].
  R maybeMap<R>({
    required R Function() orElse,
    MediaStreamStateMatch<R, MediaStreamState$Idle>? idle,
    MediaStreamStateMatch<R, MediaStreamState$Processing>? processing,
    MediaStreamStateMatch<R, MediaStreamState$Error>? error,
  }) =>
      map<R>(
        idle: idle ?? (_) => orElse(),
        processing: processing ?? (_) => orElse(),
        error: error ?? (_) => orElse(),
      );

  /// Pattern matching for [MediaStreamState].
  R? mapOrNull<R>({
    MediaStreamStateMatch<R, MediaStreamState$Idle>? idle,
    MediaStreamStateMatch<R, MediaStreamState$Processing>? processing,
    MediaStreamStateMatch<R, MediaStreamState$Error>? error,
  }) =>
      map<R?>(
        idle: idle ?? (_) => null,
        processing: processing ?? (_) => null,
        error: error ?? (_) => null,
      );

  @override
  int get hashCode => data.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  String toString() => 'MediaStreamState{message: $message}';
}
