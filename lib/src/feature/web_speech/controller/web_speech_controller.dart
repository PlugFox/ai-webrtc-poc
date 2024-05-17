import 'dart:async';

import 'package:control/control.dart';
import 'package:poc/src/feature/web_speech/controller/web_speech_state.dart';
import 'package:poc/src/feature/web_speech/data/web_speech_repository.dart';
import 'package:poc/src/feature/web_speech/model/text_speech_config.dart';
import 'package:poc/src/feature/web_speech/model/text_speech_result.dart';

final class WebSpeechController extends StateController<WebSpeechState> with ConcurrentControllerHandler {
  WebSpeechController({required IWebSpeechRepository repository, WebSpeechState? initialState})
      : _repository = repository,
        super(initialState: initialState ?? const WebSpeechState.idle(sentences: <TextSpeechResult>[]));

  final IWebSpeechRepository _repository;
  StreamSubscription<List<TextSpeechResult>>? _subscription;

  void start({TextSpeechConfig? config}) => handle(() async {
        if (state.isProcessing) return;
        setState(const WebSpeechState.processing(
          sentences: <TextSpeechResult>[],
          message: 'Recognizing',
        ));
        _subscription?.cancel().ignore();
        _subscription = _repository.startTextSpeech(config: config).listen(
              (sentences) {
                setState(WebSpeechState.processing(
                  sentences: sentences,
                  message: 'Recognized ${sentences.length} sentences',
                ));
              },
              // ignore: avoid_types_on_closure_parameters
              onError: (Object error, StackTrace stackTrace) {
                setState(WebSpeechState.error(
                  sentences: state.sentences,
                  message: 'An error has occurred. $error',
                ));
              },
              cancelOnError: false,
              onDone: () {
                _subscription = null;
                setState(WebSpeechState.idle(
                  sentences: state.sentences,
                  message: 'Idle',
                ));
              },
            );
      });

  void stop() => handle(() async {
        if (state.isIdling) return;
        setState(WebSpeechState.processing(
          sentences: state.sentences,
          message: 'Stopping',
        ));
        await _subscription?.cancel();
        _subscription = null;
        setState(WebSpeechState.idle(
          sentences: state.sentences,
          message: 'Idle,',
        ));
      });
}
