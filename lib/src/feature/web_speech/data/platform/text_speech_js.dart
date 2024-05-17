// ignore_for_file: avoid_types_on_closure_parameters

import 'dart:async';
import 'dart:js_interop' as web;
import 'dart:js_interop_unsafe' as unsafe;

import 'package:poc/src/feature/web_speech/model/text_speech_config.dart';
import 'package:poc/src/feature/web_speech/model/text_speech_result.dart';
import 'package:web/web.dart' as web;

Stream<List<TextSpeechResult>> $startTextSpeech(TextSpeechConfig config) {
  try {
    // new (window.SpeechRecognition || window.webkitSpeechRecognition)()
    final web.JSAny? constructor;
    if (web.window.has('webkitSpeechRecognition')) {
      constructor = web.window['webkitSpeechRecognition'];
    } else if (web.window.has('speechRecognition')) {
      constructor = web.window['speechRecognition'];
    } else {
      throw UnsupportedError('SpeechRecognition is not supported.');
    }
    if (constructor == null) {
      throw UnsupportedError('SpeechRecognition is not supported.');
    }
    if (constructor is! web.JSFunction) {
      throw UnsupportedError('SpeechRecognition is not supported. $constructor');
    }
    final object = constructor.callAsConstructor<web.JSObject>();

    //final speechList = web.SpeechGrammarList();
    final recognition = SpeechRecognition._(object) // web.SpeechRecognition()
      //..grammars = speechList
      ..lang = config.lang
      ..interimResults = config.interimResults
      ..maxAlternatives = config.maxAlternatives
      ..continuous = config.continuous
      ..start();
    final controller = StreamController<List<TextSpeechResult>>(
      onListen: () {
        /* onListen */
      },
      onCancel: () {
        /* onCancel */
        recognition.stop();
      },
    );
    recognition
      ..onresult = (web.SpeechSynthesisEvent event) {
        try {
          controller.add(SpeechSynthesisEvent(event).toList());
        } on Object catch (error, stackTrace) {
          controller.addError(error, stackTrace);
        }
      }.toJS
      ..onend = (web.Event _) {
        controller.close();
      }.toJS;
    return controller.stream;
  } on Object catch (error, stackTrace) {
    return Stream.error(error, stackTrace);
  }
}

extension type SpeechSynthesisEvent(web.SpeechSynthesisEvent _) implements web.SpeechSynthesisEvent {
  external web.SpeechRecognitionResultList results;

  /// Convert to array of results where each result is a list of alternatives.
  List<TextSpeechResult> toList() {
    final results = this.results;
    final list = List<TextSpeechResult>.generate(
      results.length,
      (i) {
        final result = results.item(i);
        // Extract alternatives.
        final alternatives = List<TextSpeechAlternative>.generate(
          result.length,
          (j) {
            final alternative = result.item(j);
            return TextSpeechAlternative(
              transcript: alternative.transcript,
              confidence: alternative.confidence.toDouble(),
            );
          },
          growable: false,
        );
        if (alternatives.isEmpty) return TextSpeechResult(alternatives: alternatives, isFinal: result.isFinal);
        // Exclude duplicates.
        final duplicates = <String, TextSpeechAlternative>{};
        for (final alternative in alternatives) {
          final item = duplicates[alternative.transcript];
          if (item == null || item.confidence < alternative.confidence) {
            duplicates[alternative.transcript] = alternative;
          }
        }
        return TextSpeechResult(
          alternatives: duplicates.values.toList(growable: false)..sort((a, b) => b.confidence.compareTo(a.confidence)),
          isFinal: result.isFinal,
        );
      },
      growable: false,
    );
    return list.where((r) => r.alternatives.isNotEmpty).toList(growable: false);
  }
}

/// The **`SpeechRecognition`** interface of the
/// [Web Speech API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Speech_API)
/// is the controller interface for the recognition service; this also handles
/// the [SpeechRecognitionEvent] sent from the recognition service.
///
/// > **Note:** On some browsers, like Chrome, using Speech Recognition on a web
/// > page involves a server-based recognition engine. Your audio is sent to a
/// > web service for recognition processing, so it won't work offline.
extension type SpeechRecognition._(web.JSObject _) implements web.EventTarget, web.JSObject {
  /// The **`start()`** method of the
  /// [Web Speech API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Speech_API)
  /// starts the speech
  /// recognition service listening to incoming audio with intent to recognize
  /// grammars
  /// associated with the current [SpeechRecognition].
  external void start();

  /// The **`stop()`** method of the
  /// [Web Speech API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Speech_API)
  /// stops the speech
  /// recognition service from listening to incoming audio, and attempts to
  /// return a
  /// [SpeechRecognitionResult] using the audio captured so far.
  external void stop();

  /// The **`abort()`** method of the
  /// [Web Speech API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Speech_API)
  /// stops the speech
  /// recognition service from listening to incoming audio, and doesn't attempt
  /// to return a
  /// [SpeechRecognitionResult].
  external void abort();
  external set grammars(web.SpeechGrammarList value);
  external web.SpeechGrammarList get grammars;
  external set lang(String value);
  external String get lang;
  external set continuous(bool value);
  external bool get continuous;
  external set interimResults(bool value);
  external bool get interimResults;
  external set maxAlternatives(int value);
  external int get maxAlternatives;
  external set onaudiostart(web.EventHandler value);
  external web.EventHandler get onaudiostart;
  external set onsoundstart(web.EventHandler value);
  external web.EventHandler get onsoundstart;
  external set onspeechstart(web.EventHandler value);
  external web.EventHandler get onspeechstart;
  external set onspeechend(web.EventHandler value);
  external web.EventHandler get onspeechend;
  external set onsoundend(web.EventHandler value);
  external web.EventHandler get onsoundend;
  external set onaudioend(web.EventHandler value);
  external web.EventHandler get onaudioend;
  external set onresult(web.EventHandler value);
  external web.EventHandler get onresult;
  external set onnomatch(web.EventHandler value);
  external web.EventHandler get onnomatch;
  external set onerror(web.EventHandler value);
  external web.EventHandler get onerror;
  external set onstart(web.EventHandler value);
  external web.EventHandler get onstart;
  external set onend(web.EventHandler value);
  external web.EventHandler get onend;
}
