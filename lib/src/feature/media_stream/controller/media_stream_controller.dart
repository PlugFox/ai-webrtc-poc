// ignore_for_file: avoid_types_on_closure_parameters

import 'package:control/control.dart';
import 'package:poc/src/feature/media_stream/controller/media_stream_state.dart';
import 'package:poc/src/feature/media_stream/data/media_stream_repository.dart';
import 'package:poc/src/feature/media_stream/model/media_stream_config.dart';
import 'package:poc/src/feature/media_stream/model/media_stream_context.dart';

final class MediaStreamController extends StateController<MediaStreamState> with ConcurrentControllerHandler {
  MediaStreamController({required IMediaStreamRepository repository, MediaStreamState? initialState})
      : _repository = repository,
        super(initialState: initialState ?? const MediaStreamState.idle());

  final IMediaStreamRepository _repository;

  void start(MediaStreamConfig config) => handle(() async {
        if (state.isProcessing) return;
        setState(MediaStreamState.processing(
          context: state.context,
          message: 'Preparing to start media stream',
        ));
        try {
          final context = await _repository.startMediaStream(config);
          setState(MediaStreamState.processing(
            context: context,
            message: 'Processing',
          ));
          context.subtitles.listen(
            (subtitles) {
              setState(MediaStreamState.processing(
                context: context,
                message: 'Processing',
              ));
            },
            onError: (Object error, StackTrace stackTrace) {
              setState(MediaStreamState.error(
                context: context,
                message: 'An error has occurred. $error',
              ));
              stop();
            },
            cancelOnError: false,
          );
        } on Object catch (error, _) {
          setState(MediaStreamState.error(
            context: state.context,
            message: 'An error has occurred. $error',
          ));
          setState(const MediaStreamState.idle());
          rethrow;
        }
      });

  void stop() => handle(() async {
        if (state.context case MediaStreamContext? context when context != null)
          await _repository.stopMediaStream(context);
        setState(const MediaStreamState.idle());
      });
}
