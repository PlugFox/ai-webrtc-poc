import 'dart:async';

import 'package:control/control.dart';
import 'package:poc/src/feature/web_speech/controller/web_speech_state.dart';
import 'package:poc/src/feature/web_speech/data/web_speech_repository.dart';
import 'package:poc/src/feature/web_speech/model/text_speech_config.dart';

final class WebSpeechController extends StateController<WebSpeechState> with ConcurrentControllerHandler {
  WebSpeechController({required IWebSpeechRepository repository, WebSpeechState? initialState})
      : _repository = repository,
        super(initialState: initialState ?? const WebSpeechState.idle(sentences: <String>[]));

  final IWebSpeechRepository _repository;
  StreamSubscription<String>? _subscription;

  void start({TextSpeechConfig? config}) => handle(() async {
        if (state.isProcessing) return;
        setState(const WebSpeechState.processing(
          sentences: <String>[],
          message: 'Recognizing',
        ));
        _subscription?.cancel().ignore();
        _subscription = _repository.startTextSpeech(config: config).listen(
              (sentence) {
                final sentences = <String>[...state.sentences, sentence];
                setState(WebSpeechState.processing(
                  sentences: sentences,
                  message: 'Recognized ${sentences.length} sentences',
                ));
              },
              onError: (error) {
                setState(WebSpeechState.error(
                  sentences: state.sentences,
                  message: 'An error has occurred.',
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
